import 'dart:async';

import 'package:dartz/dartz.dart' show Right;
import 'package:flutter/foundation.dart'
    show ValueNotifier, immutable, listEquals;
import 'package:stacked/stacked.dart';

import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/app/router/app_router.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/services/connectivity_service.dart';
import 'package:smap/features/analytics/application/analytics_filter.dart';
import 'package:smap/features/analytics/application/analytics_general.dart';
import 'package:smap/features/analytics/application/exam_favorites.dart';
import 'package:smap/features/analytics/application/exam_list_query.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/analytics/data/analytics_repository.dart';
import 'package:smap/features/exams/data/exam_repository.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';
import 'package:smap/features/exams/domain/exam_summary.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/navigation/student_scope.dart';
import 'package:smap/features/scan/presentation/scan_entry.dart';

/// The two tabs of the root band (pano 6.1 "Genel", 6.2 "Denemelerim").
enum AnalyticsTab { general, exams }

/// How many exams each type has (the counters of the type segment, pano 6.2
/// "10 deneme", "6 deneme", "4 deneme"). A count the server did not give is
/// `null` and its counter line is not drawn.
typedef ExamCounts = ({int? all, int? tyt, int? ayt});

/// The loaded part of the Denemelerim list and the state of its footer.
@immutable
class ExamListData {
  const ExamListData({
    this.exams = const [],
    this.hasMore = false,
    this.loadingMore = false,
    this.moreFailed = false,
  });

  /// The exams so far, newest first.
  final List<ExamDetail> exams;

  /// Another page may exist.
  final bool hasMore;

  /// The next page is loading: a small spinner under the list.
  final bool loadingMore;

  /// The next page failed: a section error with "Tekrar Dene" under the list.
  final bool moreFailed;

  @override
  bool operator ==(Object other) =>
      other is ExamListData &&
      other.hasMore == hasMore &&
      other.loadingMore == loadingMore &&
      other.moreFailed == moreFailed &&
      listEquals(other.exams, exams);

  @override
  int get hashCode =>
      Object.hash(hasMore, loadingMore, moreFailed, Object.hashAll(exams));
}

/// The logic of Analizlerim (pano 6.1 to 6.4; flow 13.7).
///
/// - **Genel** reads `getTotal` and `getLineChartData` together
///   ([AnalyticsRepository.getOverview]) for one [AnalyticsFilter]. The AYT
///   field comes from the signed-in user, never a constant. Answers are kept
///   per filter for the session, so going back to a filter shows it at once
///   (and a failed refresh keeps it; "Çevrimdışıyken son kaydedilen veri").
/// - **Denemelerim** pages `getMyMockExams` 8 at a time. The exam type goes to
///   the server; the date range is cut here ([ExamListQuery]). It loads on
///   its own, the first time its tab opens, and keeps its pages when the
///   student comes back (the ViewModel lives as long as the tab's page).
/// - Both sections have their own [SectionState] and a 15 s limit on the
///   first load.
///
/// A coach reading a student passes [student] (E17; pano 10.4): every request
/// carries the student's id, the AYT field is the student's ([userField]), a
/// row opens the exam detail in the coach's view and the list has no
/// favorite star (the star is kept on the student's own device, Ek D-25).
/// [studentId] alone is the same without the ref. The student's own screen
/// leaves both `null`.
class AnalyticsViewModel extends BaseViewModel {
  AnalyticsViewModel({
    required AnalyticsRepository analytics,
    required ExamRepository exams,
    required ConnectivityService connectivity,
    required ExamFavorites favorites,
    required AppRouter router,
    this.userField,
    String? studentId,
    this.student,
    AnalyticsTab initialTab = AnalyticsTab.general,
    DateTime Function()? clock,
    Duration timeout = SmapDurations.skeletonTimeout,
  }) : _analytics = analytics,
       _exams = exams,
       _connectivity = connectivity,
       _favorites = favorites,
       _router = router,
       _clock = clock ?? DateTime.now,
       _timeout = timeout,
       studentId = student?.id ?? studentId,
       _tab = initialTab,
       _filter = AnalyticsFilter.tyt,
       _favoriteIds = favorites.ids;

  final AnalyticsRepository _analytics;
  final ExamRepository _exams;
  final ConnectivityService _connectivity;
  final ExamFavorites _favorites;
  final AppRouter _router;
  final DateTime Function() _clock;
  final Duration _timeout;

  /// The signed-in student's AYT field (`aimType`); `null` when unknown.
  final AytField? userField;

  /// Whose numbers these are; `null` for the signed-in student.
  final String? studentId;

  /// The student a coach is looking at; `null` for the user's own numbers.
  final StudentRef? student;

  /// A coach reads a student's numbers.
  bool get isCoachView => studentId != null;

  // ── Tab ──────────────────────────────────────────────────────────────

  AnalyticsTab _tab;

  /// The tab on show.
  AnalyticsTab get tab => _tab;

  /// The tab as a listenable (the screen restores each tab's scroll offset).
  late final ValueNotifier<AnalyticsTab> tabChanges = ValueNotifier(_tab);

  /// Shows [tab]; the first visit to Denemelerim loads its list.
  void selectTab(AnalyticsTab tab) {
    if (tab == _tab) return;
    _tab = tab;
    tabChanges.value = tab;
    notifyListeners();
    if (tab == AnalyticsTab.exams) unawaited(_ensureExams());
  }

  /// The device has no link: the root band squares its corners under the
  /// offline strip (pano 6.3 kare 4).
  bool get offline => !_connectivity.isOnline;

  // ── Genel ────────────────────────────────────────────────────────────

  AnalyticsFilter _filter;
  AsyncSection<GeneralContent> _general =
      const AsyncSection<GeneralContent>.loading();
  final Map<AnalyticsFilter, GeneralContent> _generalCache = {};
  int _generalToken = 0;
  bool _generalSettled = false;

  /// The filter of the Genel tab; the pill reads it.
  AnalyticsFilter get filter => _filter;

  /// The Genel tab's section.
  AsyncSection<GeneralContent> get general => _general;

  /// The first answer (data or failure) has come: the pill stops being a
  /// skeleton.
  bool get generalSettled => _generalSettled;

  /// What the sheet opens with: the filter, and the AYT field to start on
  /// (the filter's own, else the user's).
  AytField? get sheetField => _filter.field ?? userField;

  /// Starts the screen: Genel, the type counters, and Denemelerim when it is
  /// the first tab.
  void init() {
    _connectivity.online.addListener(_onConnectivity);
    unawaited(_loadGeneral());
    unawaited(_loadCounts());
    if (_tab == AnalyticsTab.exams) unawaited(_ensureExams());
  }

  /// Applies the filter sheet's choice and reloads (the chart redraws in
  /// 350 ms; the selection haptic is the sheet's "Uygula").
  void applyFilter(AnalyticsFilter next) {
    if (next == _filter) return;
    _filter = next;
    unawaited(_loadGeneral());
  }

  /// "Tekrar Dene" on the Genel error.
  void retryGeneral() => unawaited(_loadGeneral());

  AytField? _fieldFor(AnalyticsFilter filter) =>
      filter.exam == NetExamType.ayt ? (filter.field ?? userField) : null;

  Future<void> _loadGeneral() async {
    final filter = _filter;
    final token = ++_generalToken;
    final cached = _generalCache[filter];
    _general = cached == null
        ? const AsyncSection<GeneralContent>.loading()
        : AsyncSection.of(cached, isEmpty: (c) => c.isEmpty);
    notifyListeners();

    final field = _fieldFor(filter);
    final next = await AsyncSection.load<GeneralContent>(
      () => _unwrap(
        _analytics.getOverview(
          exam: filter.exam,
          field: field,
          lessonId: filter.lessonId,
          studentId: studentId,
        ),
      ).then((overview) => GeneralContent.from(filter, overview)),
      isEmpty: (content) => content.isEmpty,
      timeout: _timeout,
    );
    if (token != _generalToken) return;
    if (next.data case final content?) _generalCache[filter] = content;
    // A failed refresh keeps what the filter showed before.
    if (!(next.isError || next.isOffline) || cached == null) _general = next;
    _generalSettled = true;
    notifyListeners();
  }

  // ── Denemelerim ──────────────────────────────────────────────────────

  ExamListQuery _query = ExamListQuery.initial;
  AsyncSection<ExamListData> _examList =
      const AsyncSection<ExamListData>.loading();
  ExamCounts _counts = (all: null, tyt: null, ayt: null);
  bool _countsSettled = false;
  List<ExamDetail> _loaded = const [];
  int _page = 0;
  bool _hasMore = false;
  bool _loadingMore = false;
  bool _moreFailed = false;
  bool _examsStarted = false;
  bool _examsSettled = false;
  List<ExamSummary> _summaries = const [];
  int _examsToken = 0;
  Set<String> _favoriteIds;

  /// The type segment and the date range.
  ExamListQuery get query => _query;

  /// The Denemelerim list's section; the first page decides its state.
  AsyncSection<ExamListData> get examList => _examList;

  /// The first load of the list has ended (data or failure): the controls
  /// stay on screen while a later load runs.
  bool get examsSettled => _examsSettled;

  /// The rows of the loaded exams. A new list only when the exams change, so
  /// a selector on it rebuilds the list only then.
  List<ExamSummary> get examSummaries => _summaries;

  /// The counters of the type segment.
  ExamCounts get counts => _counts;

  /// The counters have answered (or failed): "no exam at all" can be told
  /// from "this filter has none".
  bool get countsSettled => _countsSettled;

  /// The student has no exam at all: both counters are known and zero. Then
  /// both tabs show the empty state (pano 6.3 "Deneme yoksa iki sekme de boş
  /// durumu gösterir").
  bool get noExamsAtAll => _counts.all == 0;

  /// The starred result ids.
  Set<String> get favoriteIds => _favoriteIds;

  /// The exam with result id [id] in the loaded list; `null` when it is not
  /// there.
  ExamDetail? detailOf(String id) {
    for (final exam in _loaded) {
      if (exam.id == id) return exam;
    }
    return null;
  }

  /// Chooses the type segment's option and reloads from the first page.
  void selectType(ExamTypeFilter type) {
    if (type == _query.type) return;
    _query = _query.copyWith(type: type);
    unawaited(_reloadExams());
  }

  /// Applies the "Süz ve Sırala" sheet's date range.
  void applyDate(ExamDatePreset date) {
    if (date == _query.date) return;
    _query = _query.copyWith(date: date);
    unawaited(_reloadExams());
  }

  /// "Süzgeci Sıfırla" of the empty filtered list.
  void resetExamQuery() {
    if (_query.isInitial) return;
    _query = ExamListQuery.initial;
    unawaited(_reloadExams());
  }

  /// "Tekrar Dene" on the Denemelerim error.
  void retryExams() => unawaited(_reloadExams());

  /// The list reached its end: the next page ("Sonsuz kaydırma, 8'erli
  /// sayfa"). Also the "Tekrar Dene" of a failed page.
  Future<void> loadMore() async {
    if (!_examList.isReady || _loadingMore || !_hasMore) return;
    _loadingMore = true;
    _moreFailed = false;
    _publishExams();
    final token = _examsToken;
    final result = await _fetchPage(_page + 1);
    if (token != _examsToken) return;
    _loadingMore = false;
    result.fold((_) => _moreFailed = true, (page) {
      _loaded = [..._loaded, ...page.exams];
      _page = page.page;
      _hasMore = page.hasMore;
    });
    _publishExams();
  }

  /// Loads the list the first time (a coach's profile shows it as a tab of
  /// its own, there is no tab switch to wait for).
  Future<void> loadExams() => _ensureExams();

  Future<void> _ensureExams() async {
    if (_examsStarted) return;
    await _reloadExams();
  }

  Future<void> _reloadExams() async {
    _examsStarted = true;
    final token = ++_examsToken;
    _loaded = const [];
    _summaries = const [];
    _page = 0;
    _hasMore = false;
    _loadingMore = false;
    _moreFailed = false;
    _examList = const AsyncSection<ExamListData>.loading();
    notifyListeners();

    final first = await AsyncSection.load<_Page>(
      () async => _unwrap(_fetchPage(1)),
      timeout: _timeout,
    );
    if (token != _examsToken) return;
    _examsSettled = true;
    final page = first.data;
    if (page == null) {
      _examList = first.isOffline
          ? const AsyncSection<ExamListData>.offline()
          : AsyncSection<ExamListData>.error(first.error);
      notifyListeners();
      return;
    }
    _loaded = page.exams;
    _page = page.page;
    _hasMore = page.hasMore;
    _publishExams();
  }

  void _publishExams() {
    if (_summaries.length != _loaded.length ||
        !_loaded.indexed.every((e) => _summaries[e.$1].id == e.$2.id)) {
      _summaries = List.unmodifiable([for (final e in _loaded) e.summary]);
    }
    _examList = _loaded.isEmpty
        ? const AsyncSection<ExamListData>.empty()
        : AsyncSection<ExamListData>.ready(
            ExamListData(
              exams: List.unmodifiable(_loaded),
              hasMore: _hasMore,
              loadingMore: _loadingMore,
              moreFailed: _moreFailed,
            ),
          );
    notifyListeners();
  }

  /// One page that passes the date range. A page the range empties is
  /// followed by the next one (a few times at most), so the list never stops
  /// on a page that shows nothing while more exams follow.
  Future<AppResult<_Page>> _fetchPage(int first) async {
    final query = _query;
    final now = _clock();
    var number = first;
    AppResult<_Page> last = Right(_Page(first, const [], false));
    for (var attempt = 0; attempt < _maxEmptyPages; attempt++) {
      final at = number;
      final result = await _exams.getMyExams(
        page: at,
        filter: query.serverFilter,
        studentId: studentId,
      );
      last = result.map((page) {
        final kept = [
          for (final exam in page.exams)
            if (query.accepts(exam.summary, now)) exam,
        ];
        final ended = query.endsRange(page.summaries, now);
        return _Page(at, kept, page.hasMore && !ended);
      });
      final page = last.rightOrNull;
      if (page == null || page.exams.isNotEmpty || !page.hasMore) return last;
      number++;
    }
    return last;
  }

  /// The pages a date range may skip in a row before the list gives up.
  static const int _maxEmptyPages = 5;

  // ── Counters ─────────────────────────────────────────────────────────

  Future<void> _loadCounts() async {
    final answers = await (
      _analytics.getTotal(exam: NetExamType.tyt, studentId: studentId),
      _analytics.getTotal(
        exam: NetExamType.ayt,
        field: userField,
        studentId: studentId,
      ),
    ).wait;
    final tyt = answers.$1.fold<int?>((_) => null, (t) => t.examCount);
    final ayt = answers.$2.fold<int?>((_) => null, (t) => t.examCount);
    _countsSettled = true;
    _counts = (
      all: tyt == null || ayt == null ? null : tyt + ayt,
      tyt: tyt,
      ayt: ayt,
    );
    notifyListeners();
  }

  // ── Favorites and navigation ─────────────────────────────────────────

  /// Stars or unstars the exam with result id [id] (the device only).
  Future<void> toggleFavorite(String id) async {
    await _favorites.toggle(id);
    _favoriteIds = _favorites.ids;
    notifyListeners();
  }

  /// "İlk Denemeni Okut": the camera, as the shell's "Okut" opens it.
  Future<void> openCamera() => ScanEntry.start(_router);

  // ── Plumbing ─────────────────────────────────────────────────────────

  void _onConnectivity() => notifyListeners();

  /// A repository answer as a value; a failure is thrown for
  /// [AsyncSection.load] to turn into a state.
  Future<T> _unwrap<T>(Future<AppResult<T>> answer) async =>
      (await answer).fold((AppException failure) => throw failure, (v) => v);

  @override
  void dispose() {
    _connectivity.online.removeListener(_onConnectivity);
    tabChanges.dispose();
    super.dispose();
  }
}

/// One page after the date range: its number, its exams, whether more follow.
@immutable
class _Page {
  const _Page(this.page, this.exams, this.hasMore);

  final int page;
  final List<ExamDetail> exams;
  final bool hasMore;
}
