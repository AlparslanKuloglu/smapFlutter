import 'dart:async';

import 'package:stacked/stacked.dart';

import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/features/exams/application/exam_cards_model.dart';
import 'package:smap/features/exams/application/exam_detail_model.dart';
import 'package:smap/features/exams/application/exam_finder.dart';
import 'package:smap/features/exams/application/exam_questions_model.dart';
import 'package:smap/features/exams/application/exam_topics_model.dart';
import 'package:smap/features/exams/data/exam_repository.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';
import 'package:smap/features/exams/domain/exam_summary.dart';
import 'package:smap/features/exams/presentation/exam_detail/exam_detail_navigator.dart';
import 'package:smap/features/lessons/data/lesson_content_repository.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/navigation/student_scope.dart';

/// The logic of Deneme Detay (pano 5.3 to 5.10; flow 13.6).
///
/// - The **result** (header, Genel and Sorular) comes from the Denemelerim
///   list answer: the screen opened from the list hands it over ([initial]);
///   from a link ("Analizi Gör", a deep link) [ExamFinder] reads the pages
///   until the id turns up. Only this load can make the whole screen fail
///   (pano 5.8 kare 3); it is bounded by 15 s.
/// - **Konular** (`getMexamSubjectDetail`) and **Kartlar**
///   (`getMexamItemDetail`) load the first time their tab opens and keep
///   their own skeleton, empty and error states (pano 5.8 "Kurallar").
///   Sorular needs no request of its own: the questions are in the result.
/// - Once the result is here a failed refresh never takes it away: what was
///   loaded stays (pano 5.8 kare 4 "Önbellekteki veri gösterilir"; the offline
///   strip is the shell's).
/// - A coach's [student] sends its id with every request, and the screen
///   hides what the student alone does: "Bu Konuyu Çalış" and "Kartları
///   Çalış" (Tur 12, "Koç bağlamında … yine yok").
///
/// [userField] is the signed-in student's AYT field: it decides which score
/// of an AYT result the header shows. A coach's student brings it in the
/// `StudentRef`.
class ExamDetailViewModel extends BaseViewModel {
  ExamDetailViewModel({
    required this.examId,
    required ExamRepository exams,
    required LessonContentRepository lessons,
    required ExamDetailNavigator navigator,
    required ToastService toast,
    required this.cdnBaseUrl,
    this.student,
    this.userField,
    ExamDetail? initial,
    ExamDetailTab initialTab = ExamDetailTab.general,
    Duration timeout = SmapDurations.skeletonTimeout,
  }) : _exams = exams,
       _lessons = lessons,
       _navigator = navigator,
       _toast = toast,
       _finder = ExamFinder(exams),
       _timeout = timeout,
       _tab = initialTab,
       _exam = initial == null
           ? const AsyncSection<ExamDetail>.loading()
           : AsyncSection<ExamDetail>.ready(initial);

  /// The result's id (route `:examId`; what the topic analysis takes).
  final String examId;

  /// The student a coach is looking at; `null` for the user's own exam.
  final StudentRef? student;

  /// The signed-in student's AYT field; `null` when unknown.
  final AytField? userField;

  final ExamRepository _exams;
  final LessonContentRepository _lessons;
  final ExamDetailNavigator _navigator;
  final ToastService _toast;
  final ExamFinder _finder;
  final Duration _timeout;

  bool _started = false;
  bool _disposed = false;
  bool _retrying = false;
  bool _openingTopic = false;

  AsyncSection<ExamDetail> _exam;
  ExamDetailTab _tab;
  QuestionFilter _filter = QuestionFilter.all;
  AsyncSection<ExamTopicsModel> _topics =
      const AsyncSection<ExamTopicsModel>.loading();
  AsyncSection<ExamCardsModel> _cards =
      const AsyncSection<ExamCardsModel>.loading();
  bool _topicsRequested = false;
  bool _cardsRequested = false;

  // Selector values, cleared whenever the ViewModel notifies.
  ExamHeaderModel? _header;
  ExamGeneralModel? _general;
  ExamQuestionsModel? _questions;

  @override
  void notifyListeners() {
    if (_disposed) return;
    _header = null;
    _general = null;
    _questions = null;
    super.notifyListeners();
  }

  /// Where the covers live (`AppConfig.cdnBaseUrl`).
  final String cdnBaseUrl;

  /// The student's id for repository calls; `null` for the user's own data.
  String? get studentId => student?.id;

  /// A coach is looking at the student's exam: the student-only actions are
  /// not offered.
  bool get isCoachView => student != null;

  // ── Result ───────────────────────────────────────────────────────────

  /// The state of the result: it decides the header, the tab bodies of
  /// Genel and Sorular, and the screen-level error.
  SectionState get screenState => _exam.state;

  ExamDetail? get exam => _exam.data;

  /// The header of the result; `null` until it is here.
  ExamHeaderModel? get header => _exam.data == null
      ? null
      : _header ??= ExamHeaderModel.of(_exam.data!, field: userField);

  /// The cover's full URL; `null` without a cover.
  String? get coverUrl => header == null
      ? null
      : ExamDefinition(imageFile: header!.coverFile).imageUrl(cdnBaseUrl);

  /// The Genel tab's content; `null` until the result is here.
  ExamGeneralModel? get general =>
      _exam.data == null ? null : _general ??= ExamGeneralModel.of(_exam.data!);

  /// The Sorular tab's content; `null` until the result is here.
  ExamQuestionsModel? get questions => _exam.data == null
      ? null
      : _questions ??= ExamQuestionsModel.of(_exam.data!);

  /// Starts the screen: reads the result when it was not handed over, and
  /// the tab the link names.
  void init() {
    if (_started) return;
    _started = true;
    if (_exam.isLoading) unawaited(_loadExam());
    _ensureTab(_tab);
  }

  /// "Tekrar Dene" of the screen error: back to the skeleton; a repeated
  /// failure plays the error haptic (pano 5.8 "Hareket ve haptik").
  Future<void> retry() {
    _retrying = true;
    return _loadExam();
  }

  Future<void> _loadExam() async {
    _exam = const AsyncSection<ExamDetail>.loading();
    notifyListeners();
    final next = await AsyncSection.load<ExamDetail>(
      () => _unwrap(_finder.find(examId, studentId: studentId)),
      timeout: _timeout,
    );
    if (_disposed) return;
    _exam = next;
    if ((next.isError || next.isOffline) && _retrying) AppHaptics.error();
    _retrying = false;
    notifyListeners();
  }

  // ── Tabs ─────────────────────────────────────────────────────────────

  /// The tab on show.
  ExamDetailTab get tab => _tab;

  /// Shows [tab]; the first visit to Konular and Kartlar loads it.
  void selectTab(ExamDetailTab tab) {
    if (tab == _tab) return;
    _tab = tab;
    notifyListeners();
    _ensureTab(tab);
  }

  void _ensureTab(ExamDetailTab tab) {
    switch (tab) {
      case ExamDetailTab.topics:
        if (!_topicsRequested) unawaited(_loadTopics());
      case ExamDetailTab.cards:
        if (!_cardsRequested) unawaited(_loadCards());
      case ExamDetailTab.general || ExamDetailTab.questions:
        break;
    }
  }

  // ── Sorular ──────────────────────────────────────────────────────────

  /// The question filter.
  QuestionFilter get filter => _filter;

  /// A filter option was chosen (the segment plays the selection haptic).
  void selectFilter(QuestionFilter filter) {
    if (filter == _filter) return;
    _filter = filter;
    notifyListeners();
  }

  /// A question cell was pressed: Soru Detay.
  Future<void> openQuestion({
    required int testIndex,
    required int questionOrder,
  }) async {
    final current = _exam.data;
    if (current == null) return;
    await _navigator.openQuestion(
      exam: current,
      testIndex: testIndex,
      questionOrder: questionOrder,
      student: student,
    );
  }

  // ── Konular ──────────────────────────────────────────────────────────

  AsyncSection<ExamTopicsModel> get topics => _topics;

  Future<void> _loadTopics() async {
    _topicsRequested = true;
    _topics = const AsyncSection<ExamTopicsModel>.loading();
    notifyListeners();
    final next = await AsyncSection.load<ExamTopicsModel>(
      () async => ExamTopicsModel.of(
        await _unwrap(
          _exams.getTopicAnalysis(examId: examId, studentId: studentId),
        ),
      ),
      isEmpty: (model) => model.isEmpty,
      timeout: _timeout,
    );
    if (_disposed) return;
    _topics = next;
    notifyListeners();
  }

  /// "Tekrar Dene" of the Konular error.
  Future<void> retryTopics() => _loadTopics();

  /// A topic row or "Bu Konuyu Çalış" was pressed: Konu Detayı of the topic
  /// in Derslerim. The topic is found by its name among the lesson's main
  /// subjects; a topic that is not there opens the lesson instead, with a
  /// toast saying so. A lesson with no topic screen (Matematik, Geometri)
  /// does nothing; the screen does not offer it.
  Future<void> openTopic({
    required String lessonName,
    required String topicName,
  }) async {
    if (isCoachView || _openingTopic) return;
    final target = TopicLinks.resolve(
      lessonName: lessonName,
      exam: _exam.data?.kind,
    );
    if (target == null) return;
    _openingTopic = true;
    try {
      final answer = await _lessons.getMainSubjects(
        lessonId: target.backendLessonId,
      );
      if (_disposed) return;
      final subjects = answer.rightOrNull?.subjects;
      if (subjects == null) {
        _toast.error((l) => l.examDetail_topicsError);
        return;
      }
      final topic = TopicLinks.findTopic(subjects, topicName);
      if (topic == null) {
        _toast.error((l) => l.examDetail_topicNotFound);
        await _navigator.openLesson(
          lessonId: target.lesson.id,
          cat: target.cat,
        );
        return;
      }
      await _navigator.openTopic(
        lessonId: target.lesson.id,
        topicId: topic.id,
        cat: target.cat,
      );
    } finally {
      _openingTopic = false;
    }
  }

  /// Whether the lesson named [lessonName] has a topic screen the rows can
  /// open (the rows of Matematik and Geometri stay static).
  bool canStudyLesson(String lessonName) =>
      !isCoachView &&
      TopicLinks.resolve(lessonName: lessonName, exam: _exam.data?.kind) !=
          null;

  // ── Kartlar ──────────────────────────────────────────────────────────

  AsyncSection<ExamCardsModel> get cards => _cards;

  Future<void> _loadCards() async {
    _cardsRequested = true;
    _cards = const AsyncSection<ExamCardsModel>.loading();
    notifyListeners();
    final next = await AsyncSection.load<ExamCardsModel>(
      () async => ExamCardsModel.of(
        await _unwrap(
          _exams.getCardBreakdown(examId: examId, studentId: studentId),
        ),
      ),
      isEmpty: (model) => model.isEmpty,
      timeout: _timeout,
    );
    if (_disposed) return;
    _cards = next;
    notifyListeners();
  }

  /// "Tekrar Dene" of the Kartlar error.
  Future<void> retryCards() => _loadCards();

  /// "Kartları Çalış": the deck of the exam, starting on its first lesson
  /// with cards.
  Future<void> studyCards() async {
    if (isCoachView) return;
    final first = _cards.data?.groups.firstOrNull;
    await _navigator.openCardDeck(
      examId: examId,
      backendLessonId: first?.backendLessonId,
      lessonName: first?.name,
    );
  }

  /// A lesson group of the Kartlar tab: that lesson's deck.
  Future<void> studyLessonCards(ExamCardGroup group) async {
    if (isCoachView) return;
    await _navigator.openCardDeck(
      examId: examId,
      backendLessonId: group.backendLessonId,
      lessonName: group.name,
    );
  }

  static Future<T> _unwrap<T>(Future<AppResult<T>> future) async {
    final result = await future;
    return result.fold<T>(
      (AppException failure) => throw failure,
      (value) => value,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
