import 'dart:async';

import 'package:stacked/stacked.dart';

import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/features/cards/data/card_repository.dart';
import 'package:smap/features/cards/domain/card_totals.dart';
import 'package:smap/features/lessons/application/general_lesson_spec.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/features/lessons/application/lesson_category.dart';
import 'package:smap/features/lessons/application/lesson_rows.dart';
import 'package:smap/features/lessons/application/lesson_segments.dart';
import 'package:smap/features/lessons/application/lessons_service.dart';
import 'package:smap/features/lessons/application/literature_authors.dart';
import 'package:smap/features/lessons/data/lesson_content_repository.dart';
import 'package:smap/features/lessons/domain/general_lesson.dart';
import 'package:smap/features/lessons/domain/main_subjects.dart';
import 'package:smap/features/lessons/presentation/lesson_detail/lesson_detail_state.dart';
import 'package:smap/features/lessons/presentation/lessons_navigator.dart';
import 'package:smap/features/lessons/presentation/literature/sheets/author_sheet.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

/// The logic of Ders Detayı (pano 7.2, 7.4, 7.5 kare 2 and 3; spec §4.F 7.2).
///
/// - The lesson comes from the session's [LessonsService] (counts per track)
///   or, before it answers, from the built-in catalog: the screen never waits
///   for the list to open.
/// - A lesson with tracks reads the topics of the chosen track's backend
///   lesson and keeps them (going back is instant); a lesson without tracks
///   has one topic list and "Tümü" plus the server's filters. It opens on the
///   category of the link, else the device's last exam type.
/// - "Eksiklerim" keeps the topics with something missing under the segment,
///   with their numbers of the full list.
/// - Edebiyat has a second segment, Konular and Yazar ve Eserler (kept on the
///   device); the authors load the first time they are shown.
/// - Returning from a topic reloads the counts without a skeleton; every first
///   load is bounded by 15 s, then the error state shows.
class LessonDetailViewModel extends ReactiveViewModel {
  LessonDetailViewModel({
    required this.lessonId,
    required LessonsService lessons,
    required LessonContentRepository content,
    required CardRepository cards,
    required DevicePreferences preferences,
    required LessonsNavigator navigator,
    required ToastService toast,
    LessonCat? cat,
    bool onlyMissing = false,
    LiteratureSection? section,
    Duration timeout = SmapDurations.skeletonTimeout,
  }) : _lessons = lessons,
       _content = content,
       _cards = cards,
       _preferences = preferences,
       _navigator = navigator,
       _toast = toast,
       _requestedCat = cat,
       _onlyMissing = onlyMissing,
       _requestedSection = section,
       _timeout = timeout,
       _fallback = LessonCatalog.byId(lessonId)?.toGeneralLesson();

  /// The general lesson's id (route `:lessonId`).
  final String lessonId;

  final LessonsService _lessons;
  final LessonContentRepository _content;
  final CardRepository _cards;
  final DevicePreferences _preferences;
  final LessonsNavigator _navigator;
  final ToastService _toast;
  final LessonCat? _requestedCat;
  final LiteratureSection? _requestedSection;
  final Duration _timeout;
  final GeneralLesson? _fallback;

  /// Main subjects by backend lesson id.
  final Map<String, AsyncSection<MainSubjects>> _subjects = {};
  AsyncSection<LiteratureAuthors> _authors =
      const AsyncSection<LiteratureAuthors>.loading();
  bool _authorsRequested = false;
  CardTotals _cardTotals = const CardTotals.empty();
  int? _selectedValue;
  bool _onlyMissing;
  LiteratureSection _section = LiteratureSection.topics;
  bool _started = false;
  bool _disposed = false;

  // Selector values, cleared whenever the ViewModel notifies.
  LessonHeaderData? _header;
  LessonFilterBarData? _filterBar;
  LessonSegmentBarData? _segmentBar;
  LessonTopicsData? _topicsData;
  LessonAuthorsData? _authorsData;

  @override
  List<ListenableServiceMixin> get listenableServices => [_lessons];

  @override
  void notifyListeners() {
    _header = null;
    _filterBar = null;
    _segmentBar = null;
    _topicsData = null;
    _authorsData = null;
    super.notifyListeners();
  }

  /// The lesson, from the session or the catalog; `null` for an id the app
  /// does not know.
  GeneralLesson? get lesson => _lessons.entryOf(lessonId)?.lesson ?? _fallback;

  LessonMissing? get _missing => _lessons.entryOf(lessonId)?.missing;

  /// The lesson is Türk Dili ve Edebiyatı, which has the two sections.
  bool get isLiterature => lesson?.isLiterature ?? false;

  /// The category of the chosen segment (what a topic opens on).
  LessonCat get selectedCat => _selectedSegment?.cat ?? LessonCat.all;

  // ── Derivations ──

  List<LessonSegment> get _segments {
    final current = lesson;
    if (current == null) return const [];
    final data = _subjectsOf(_singleBackendId)?.data;
    return LessonSegments.of(
      current,
      missing: _missing,
      filters: data?.filters ?? const [],
      byType: data?.missing,
    );
  }

  LessonSegment? get _selectedSegment {
    final value = _selectedValue;
    if (value == null) return null;
    for (final segment in _segments) {
      if (segment.value == value) return segment;
    }
    return null;
  }

  /// The backend lesson of the lesson without tracks.
  String? get _singleBackendId => lesson?.ids.single;

  /// The backend lesson whose topics the chosen segment shows.
  String? get _backendId {
    final current = lesson;
    final segment = _selectedSegment;
    if (current == null || segment == null) return null;
    return LessonSegments.backendLessonId(current, segment);
  }

  /// The backend lesson whose data the topic section follows: the chosen
  /// segment's, or before a segment is chosen the lesson's own (the single
  /// lesson, or the first track).
  String? get _activeBackendId {
    final chosen = _backendId;
    if (chosen != null) return chosen;
    final current = lesson;
    if (current == null) return null;
    return current.hasTrackChoice
        ? _firstTrackBackendId(current)
        : current.ids.single;
  }

  AsyncSection<MainSubjects>? _subjectsOf(String? backendId) =>
      backendId == null ? null : _subjects[backendId];

  // ── Section values (what the view's selectors read) ──

  /// The title block.
  LessonHeaderData get header => _header ??= LessonHeaderData(
    name: lesson?.name ?? '',
    nameKind: isLiterature ? LessonRowName.literature : LessonRowName.server,
    subject: lesson?.subject,
  );

  /// The Edebiyat detail shows its author list instead of the topics.
  bool get showsAuthors =>
      isLiterature && _section == LiteratureSection.authors;

  /// The Edebiyat section choice; `null` for any other lesson.
  LessonSectionData get sectionData =>
      LessonSectionData(isLiterature ? _section : null);

  /// The chip and button row.
  LessonFilterBarData get filterBar => _filterBar ??= _buildFilterBar();

  /// The category segment.
  LessonSegmentBarData get segmentBar =>
      _segmentBar ??= _section == LiteratureSection.authors && isLiterature
      ? const LessonSegmentBarData()
      : LessonSegmentBarData(segments: _segments, selected: _selectedValue);

  /// The topic list.
  LessonTopicsData get topics => _topicsData ??= _buildTopics();

  /// The author list.
  LessonAuthorsData get authors => _authorsData ??= LessonAuthorsData(
    state: _authors.state,
    authors: _authors.data ?? const LiteratureAuthors([]),
  );

  LessonFilterBarData _buildFilterBar() {
    final state = _topicsState;
    final inTopics = !isLiterature || _section == LiteratureSection.topics;
    final shown =
        inTopics &&
        (state == SectionState.loading ||
            state == SectionState.ready ||
            state == SectionState.empty);
    if (!shown) return const LessonFilterBarData();
    final missing = _missing;
    final byType = _subjectsOf(_activeBackendId)?.data?.missing;
    final total =
        missing?.total ??
        (byType == null || byType.byType.isEmpty ? null : byType.totalFor(9));
    final deckId = _activeBackendId;
    final counts = deckId == null ? null : _cardTotals.of(deckId);
    final miss = counts?.missCount;
    final known = counts?.trueCount;
    final deck = miss == null || known == null ? 0 : miss + known;
    return LessonFilterBarData(
      visible: true,
      missingTotal: total,
      onlyMissing: _onlyMissing,
      cardsKnown: deck > 0 ? known : null,
      cardsTotal: deck > 0 ? deck : null,
    );
  }

  SectionState get _topicsState {
    if (lesson == null) return SectionState.error;
    final entry = _subjectsOf(_activeBackendId);
    if (entry == null) return SectionState.loading;
    if (entry.isReady && entry.data!.subjects.isEmpty) {
      return SectionState.empty;
    }
    return entry.state;
  }

  LessonTopicsData _buildTopics() {
    final state = _topicsState;
    final segment = _selectedSegment;
    if (state == SectionState.ready && segment == null) {
      // The data is here but the option to show is not chosen yet.
      return const LessonTopicsData(state: SectionState.loading);
    }
    if (state != SectionState.ready || segment == null) {
      return LessonTopicsData(state: state);
    }
    final data = _subjectsOf(_activeBackendId)!.data!;
    final all = LessonTopicList.of(data.subjects, data.missing, segment.value);
    return LessonTopicsData(
      state: SectionState.ready,
      topics: _onlyMissing ? LessonTopicList.onlyMissing(all) : all,
      onlyMissing: _onlyMissing,
      segmentLabel: segment.label,
      isAllSegment: segment.cat == LessonCat.all,
    );
  }

  // ── Loading ──

  /// Starts loading; the view calls it once.
  Future<void> init() async {
    if (_started) return;
    _started = true;
    if (lesson == null) {
      notifyListeners();
      return;
    }
    unawaited(_lessons.load().catchError((Object _) {}));
    unawaited(_loadCards());
    if (isLiterature) {
      _section =
          _requestedSection ??
          LiteratureSection.parse(
            _preferences.getString(
              DevicePreferences.lessonsLiteratureSectionKey,
            ),
          ) ??
          LiteratureSection.topics;
    }
    _resolveSelection();
    notifyListeners();
    await Future.wait([_loadTopics(), if (_wantsAuthors) _loadAuthors()]);
  }

  bool get _wantsAuthors =>
      isLiterature && _section == LiteratureSection.authors;

  /// Picks the segment to open on once the options are known: at once for a
  /// lesson with tracks, after the server's filters for the others.
  void _resolveSelection() {
    if (_selectedValue != null) return;
    final segments = _segments;
    if (segments.isEmpty) return;
    final lessonHasTracks = lesson?.hasTrackChoice ?? false;
    if (!lessonHasTracks && segments.length < 2 && _singleLoaded == false) {
      return; // wait for the server's filters
    }
    final saved = LessonsExamType.fromKey(
      _preferences.getString(DevicePreferences.lessonsExamTypeKey),
    ).cat;
    _selectedValue = LessonSegments.pick(
      segments,
      requested: _requestedCat,
      fallback: saved,
    ).value;
  }

  bool get _singleLoaded => _subjectsOf(_singleBackendId)?.isReady ?? false;

  Future<void> _loadCards() async {
    final result = await _cards.getTotals();
    if (_disposed) return;
    // A failure leaves "Kartlarım" without its progress.
    _cardTotals = result.rightOrNull ?? _cardTotals;
    notifyListeners();
  }

  /// Reads the topics of the chosen segment's backend lesson, unless they
  /// are already here.
  Future<void> _loadTopics() async {
    // A lesson without tracks reads its one lesson even before a segment is
    // chosen: its filters are what the segment is made of.
    final id = _activeBackendId;
    if (id == null) return;
    final cached = _subjects[id];
    if (cached != null && cached.isReady) return;
    _subjects[id] = const AsyncSection<MainSubjects>.loading();
    notifyListeners();
    _subjects[id] = await AsyncSection.load(
      () async => _unwrap(_content.getMainSubjects(lessonId: id)),
      timeout: _timeout,
    );
    if (_disposed) return;
    _resolveSelection();
    notifyListeners();
  }

  static String? _firstTrackBackendId(GeneralLesson current) => current.ids
      .forTrack(current.tracks.isEmpty ? null : current.tracks.first);

  /// Reads the counts again after the student came back from a topic, without
  /// the skeleton; a failure keeps what is shown.
  Future<void> _refreshTopics() async {
    final id = _activeBackendId;
    if (id == null) return;
    final result = await _content.getMainSubjects(lessonId: id);
    if (_disposed) return;
    final fresh = result.rightOrNull;
    if (fresh == null) return;
    _subjects[id] = AsyncSection<MainSubjects>.ready(fresh);
    notifyListeners();
  }

  Future<void> _loadAuthors() async {
    _authorsRequested = true;
    _authors = const AsyncSection<LiteratureAuthors>.loading();
    notifyListeners();
    _authors = await AsyncSection.load(
      () async => LiteratureAuthors.of(
        await _unwrap(LiteratureLoader(_content).load()),
      ),
      isEmpty: (list) => list.isEmpty,
      timeout: _timeout,
    );
    if (_disposed) return;
    notifyListeners();
  }

  static Future<T> _unwrap<T>(Future<AppResult<T>> future) async {
    final result = await future;
    return result.fold<T>(
      (AppException failure) => throw failure,
      (value) => value,
    );
  }

  // ── Actions ──

  /// A segment option was chosen.
  Future<void> selectSegment(int value) async {
    if (value == _selectedValue) return;
    _selectedValue = value;
    notifyListeners();
    await _loadTopics();
  }

  /// The "Eksiklerim" chip was pressed.
  void toggleOnlyMissing() {
    _onlyMissing = !_onlyMissing;
    notifyListeners();
  }

  /// "Süzgeci Kapat" of the empty filter card.
  void closeFilter() {
    if (!_onlyMissing) return;
    _onlyMissing = false;
    notifyListeners();
  }

  /// The Edebiyat section segment changed; the choice is kept.
  Future<void> selectSection(LiteratureSection section) async {
    if (!isLiterature || section == _section) return;
    _section = section;
    unawaited(
      _preferences.setString(
        DevicePreferences.lessonsLiteratureSectionKey,
        section.key,
      ),
    );
    notifyListeners();
    if (section == LiteratureSection.authors && !_authorsRequested) {
      await _loadAuthors();
    }
  }

  /// "Tekrar Dene" of the topic list.
  Future<void> retryTopics() async {
    final id = _activeBackendId;
    if (id != null) _subjects.remove(id);
    notifyListeners();
    await _loadTopics();
  }

  /// "Tekrar Dene" of the author list.
  Future<void> retryAuthors() => _loadAuthors();

  /// A topic row was pressed: Konu Detayı opens on the chosen category; the
  /// counts are read again when it closes.
  Future<void> openTopic(TopicListItem topic) async {
    await _navigator.openTopic(
      lessonId: lessonId,
      topicId: topic.id,
      cat: selectedCat,
    );
    if (!_disposed) await _refreshTopics();
  }

  /// "Kartlarım": the deck of the chosen track's lesson.
  Future<void> openCards() async {
    final id = _activeBackendId;
    final name = lesson?.name;
    if (id == null || name == null) return;
    await _navigator.openCardDeck(backendLessonId: id, lessonName: name);
  }

  /// An author row was pressed: the sheet opens; its "Öğrendim" marks the
  /// author's missing works learned.
  Future<void> openAuthor(AuthorView author) async {
    final learn = await AuthorSheet.show(author: author);
    if (learn ?? false) await learnAuthor(author.key);
  }

  /// Marks the missing works of the author [authorKey] learned. The list
  /// follows at once; a work whose request failed goes back to missing and
  /// the toast says nothing was sent. There is no undo on the server.
  Future<void> learnAuthor(String authorKey) async {
    final before = _authors.data;
    final author = before?.authorOf(authorKey);
    if (before == null || author == null) return;
    final ids = author.missingProgressIds;
    if (ids.isEmpty) return;

    _authors = AsyncSection<LiteratureAuthors>.ready(
      before.withLearned(authorKey, ids.toSet()),
    );
    notifyListeners();

    final answers = await Future.wait([
      for (final id in ids) _content.markItemLearned(itemId: id),
    ]);
    if (_disposed) return;
    final sent = <String>{
      for (final (index, answer) in answers.indexed)
        if (answer.isRight()) ids[index],
    };
    if (sent.length < ids.length) {
      // Back to missing for the works that were not sent.
      final current = _authors.data ?? before;
      _authors = AsyncSection<LiteratureAuthors>.ready(
        current.withAuthor(author.withLearned(sent)),
      );
      notifyListeners();
      _toast.error((l) => l.lessons_sendFailed);
    }
    if (sent.isNotEmpty) {
      AppHaptics.success();
      unawaited(_lessons.refresh().catchError((Object _) {}));
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
