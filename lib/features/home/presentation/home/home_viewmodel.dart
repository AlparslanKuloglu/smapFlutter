import 'dart:async';

import 'package:stacked/stacked.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/features/exams/data/exam_repository.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';
import 'package:smap/features/home/application/last_exam_summary.dart';
import 'package:smap/features/home/application/subject_strip.dart';
import 'package:smap/features/home/application/today_summary.dart';
import 'package:smap/features/home/application/yks_countdown.dart';
import 'package:smap/features/lessons/application/lessons_service.dart';
import 'package:smap/features/schedule/application/schedule_service.dart';
import 'package:smap/services/current_user_service.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

/// The student home screen's logic (pano 3.1 to 3.3; spec §4.B "3.1–3.3";
/// flow 13.3).
///
/// Three independent sections, each with its own [SectionState] (spec: "biri
/// düşerse diğerleri çalışır"):
///
/// - [today] from `ScheduleService` (the programs, "Bugün" picked on the
///   device);
/// - [lastExam] from `ExamRepository` (the newest exam, the change against the
///   previous one of its type, the weakest topic);
/// - [subjects] from `LessonsService` (the lessons with their missing counts).
///
/// The band's data (the first name, the avatar and the YKS counter) is on the
/// device and needs no request ([firstName], [photo], [daysLeft]); the counter
/// and "Bugün" are worked out again at midnight.
///
/// Every first load is limited to 15 s (`SmapDurations.skeletonTimeout`): no
/// answer by then is the section's error state. A refresh that fails keeps
/// the data on screen (the last saved program and exam, "Çevrimdışı" is told
/// by the shell's strip). The services cache for the session; the last exam
/// is kept here for as long as the screen lives.
///
/// The ViewModel never touches a `BuildContext`: it opens the camera through
/// the injected router; the screens it cannot route to yet are opened by the
/// view (`home_view.dart`).
class HomeViewModel extends ReactiveViewModel {
  HomeViewModel({
    required ScheduleService schedule,
    required LessonsService lessons,
    required ExamRepository exams,
    required CurrentUserService currentUser,
    required AppRouter router,
    required DateTime yksDate,
    DateTime Function()? clock,
    Duration timeout = SmapDurations.skeletonTimeout,
  }) : _schedule = schedule,
       _lessons = lessons,
       _exams = exams,
       _currentUser = currentUser,
       _router = router,
       _yksDate = yksDate,
       _clock = clock ?? DateTime.now,
       _timeout = timeout {
    _derive();
  }

  final ScheduleService _schedule;
  final LessonsService _lessons;
  final ExamRepository _exams;
  final CurrentUserService _currentUser;
  final AppRouter _router;
  final DateTime _yksDate;
  final DateTime Function() _clock;
  final Duration _timeout;

  @override
  List<ListenableServiceMixin> get listenableServices => [
    _schedule,
    _lessons,
    _currentUser,
  ];

  // ── Band ──────────────────────────────────────────────────────────────

  String _firstName = '';
  String? _photo;
  int? _daysLeft;

  /// The first word of the profile's name ("Alparslan"): the greeting does
  /// not depend on the hour (assumption 6.3).
  String get firstName => _firstName;

  /// The avatar file name under `assets/avatars/`; `null` draws the initials.
  String? get photo => _photo;

  /// Days until the YKS; `null` once the exam day has passed.
  int? get daysLeft => _daysLeft;

  /// The exam day (`AppConfig.yksDate`).
  DateTime get yksDate => _yksDate;

  // ── Bugün ─────────────────────────────────────────────────────────────

  AsyncSection<TodaySummary> _today = const AsyncSection.loading();
  Object? _todayFailure;
  DateTime _todayDate = DateTime(2000);

  /// Today as a calendar day (local midnight): the date line of "Bugün" is
  /// there before the programs arrive and for a student with none.
  DateTime get todayDate => _todayDate;

  /// "Bugün": loading until the programs arrive, empty when the student has
  /// no program, ready (possibly with no row for today) otherwise.
  AsyncSection<TodaySummary> get today => _today;

  // ── Son denemen ───────────────────────────────────────────────────────

  AsyncSection<LastExamSummary> _lastExam = const AsyncSection.loading();
  bool _lastExamBusy = false;

  /// "Son denemen": empty when no exam has been read yet.
  AsyncSection<LastExamSummary> get lastExam => _lastExam;

  // ── Derslerin ─────────────────────────────────────────────────────────

  AsyncSection<SubjectStrip> _subjects = const AsyncSection.loading();
  bool _subjectsTimedOut = false;

  /// "Derslerin": the tiles, most missing first.
  AsyncSection<SubjectStrip> get subjects => _subjects;

  Timer? _midnight;

  /// Loads the three sections and starts the midnight timer; the view calls
  /// it once when the screen is built.
  Future<void> init() {
    watchMidnight();
    return Future.wait([_loadToday(), _loadLastExam(), _loadSubjects()]);
  }

  /// Pull to refresh: fetches the three sections again. The selection haptic
  /// plays on release (pano 3.2 "Çekip yenileme: bırakınca selectionClick").
  Future<void> refresh() {
    AppHaptics.selection();
    return Future.wait([
      _loadToday(force: true),
      _loadLastExam(),
      _loadSubjects(force: true),
    ]);
  }

  /// "Tekrar Dene" of "Bugün": back to the skeleton, only this section
  /// fetches.
  Future<void> retryToday() {
    _todayFailure = null;
    notifyListeners();
    return _loadToday(force: true);
  }

  /// "Tekrar Dene" of "Son denemen".
  Future<void> retryLastExam() {
    _lastExam = const AsyncSection.loading();
    notifyListeners();
    return _loadLastExam();
  }

  /// "Tekrar Dene" of "Derslerin".
  Future<void> retrySubjects() {
    _subjectsTimedOut = false;
    notifyListeners();
    return _loadSubjects(force: true);
  }

  /// "İlk Denemeni Okut": the scan flow, today the legacy one.
  Future<void> openScan() => _router.push(const LegacyScanRoute());

  // ── Loading ───────────────────────────────────────────────────────────

  Future<void> _loadToday({bool force = false}) async {
    try {
      final result = await withSkeletonTimeout(
        _schedule.load(forceRefresh: force),
        timeout: _timeout,
      );
      _todayFailure = result.leftOrNull;
    } on Object catch (error) {
      _todayFailure = error;
    }
    notifyListeners();
  }

  Future<void> _loadLastExam() async {
    if (_lastExamBusy) return;
    _lastExamBusy = true;
    try {
      final summary = await withSkeletonTimeout(
        _fetchLastExam(),
        timeout: _timeout,
      );
      _lastExam = summary == null
          ? const AsyncSection.empty()
          : AsyncSection.ready(summary);
    } on Object catch (error) {
      // A failed refresh keeps what is on screen.
      if (!_lastExam.isReady && !_lastExam.isEmpty) {
        _lastExam = AsyncSection.failed(error);
      }
    } finally {
      _lastExamBusy = false;
    }
    notifyListeners();
  }

  /// The newest exam; the previous one of its type is looked for on the
  /// first two pages, the topic analysis is best effort (its failure only
  /// leaves the weakest-topic sentence out).
  Future<LastExamSummary?> _fetchLastExam() async {
    final exams = <ExamDetail>[];
    LastExamSummary? summary;
    for (var page = 1; page <= 2; page++) {
      final result = await _exams.getMyExams(page: page);
      final failure = result.leftOrNull;
      if (failure != null) throw failure;
      final fetched = result.rightOrNull!;
      exams.addAll(fetched.exams);
      summary = LastExamSummary.of(exams);
      if (!fetched.hasMore || (summary != null && summary.delta != null)) {
        break;
      }
    }
    if (summary == null) return null;
    final analysis = (await _exams.getTopicAnalysis(
      examId: summary.examId,
    )).rightOrNull;
    return analysis == null ? summary : summary.withAnalysis(analysis);
  }

  Future<void> _loadSubjects({bool force = false}) async {
    try {
      await withSkeletonTimeout(
        force ? _lessons.refresh() : _lessons.load(),
        timeout: _timeout,
      );
    } on TimeoutException {
      _subjectsTimedOut = true;
    }
    notifyListeners();
  }

  // ── Derived state ─────────────────────────────────────────────────────

  /// Works every value the sections read out again from the services; called
  /// on each change so the selectors compare ready-made immutable values.
  @override
  void notifyListeners() {
    if (disposed) return;
    _derive();
    super.notifyListeners();
  }

  void _derive() {
    final now = _clock();
    final user = _currentUser.user;
    _firstName = _firstNameOf(user?.firstName, user?.name);
    _photo = user?.photo;
    _daysLeft = YksCountdown.daysLeft(now, _yksDate);
    _todayDate = DateTime(now.year, now.month, now.day);
    _today = _deriveToday(now);
    _subjects = _deriveSubjects();
  }

  AsyncSection<TodaySummary> _deriveToday(DateTime now) {
    final snapshot = _schedule.snapshot();
    if (snapshot != null) {
      // No program at all is the "yeni kullanıcı" card (pano 3.1 kare 3).
      return snapshot.weeklies.isEmpty
          ? const AsyncSection.empty()
          : AsyncSection.ready(TodaySummary.of(snapshot, now));
    }
    final failure = _todayFailure;
    return failure == null
        ? const AsyncSection.loading()
        : AsyncSection.failed(failure);
  }

  AsyncSection<SubjectStrip> _deriveSubjects() {
    final state = _lessons.state;
    if (state.hasData) {
      return state.entries.isEmpty
          ? const AsyncSection.empty()
          : AsyncSection.ready(SubjectStrip.of(state.entries));
    }
    if (_subjectsTimedOut) return const AsyncSection.error();
    final failure = state.error;
    return failure == null
        ? const AsyncSection.loading()
        : AsyncSection.failed(failure);
  }

  /// "Alparslan Kuloğlu" → "Alparslan"; the profile's `firstName` wins.
  static String _firstNameOf(String? firstName, String? name) {
    final first = firstName?.trim();
    if (first != null && first.isNotEmpty) return first;
    final words = name?.trim().split(RegExp(r'\s+'));
    return words == null || words.isEmpty ? '' : words.first;
  }

  /// Starts the midnight timer: at each midnight the counter and "Bugün" are
  /// worked out again (no network needed, decision D-21). [init] starts it;
  /// calling it again restarts it.
  void watchMidnight() {
    _midnight?.cancel();
    _midnight = Timer(YksCountdown.untilNextMidnight(_clock()), () {
      notifyListeners();
      watchMidnight();
    });
  }

  @override
  void dispose() {
    _midnight?.cancel();
    super.dispose();
  }
}
