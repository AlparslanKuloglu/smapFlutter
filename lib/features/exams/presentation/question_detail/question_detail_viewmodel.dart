import 'dart:async';

import 'package:stacked/stacked.dart';

import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/features/exams/application/exam_finder.dart';
import 'package:smap/features/exams/application/question_detail_model.dart';
import 'package:smap/features/exams/data/exam_repository.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';
import 'package:smap/features/exams/domain/question_detail.dart';
import 'package:smap/features/exams/presentation/exam_detail/exam_detail_navigator.dart';
import 'package:smap/features/exams/presentation/question_detail/sheets/question_card_sheet.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/navigation/student_scope.dart';

/// The logic of Soru Detay (pano 5.7; flow 13.6).
///
/// - What the result says about the question (its test, lesson and outcome,
///   [place]) comes from the exam result: handed over by Deneme Detay
///   ([initial]) or, from a link, found by [ExamFinder]. Only a result that
///   cannot be read fails the screen.
/// - The explanation and the related cards come from `getQuestion` (the
///   result's own exam object posted back, the question and the test's
///   0-based order) once the result is here. They are a section of their
///   own: if they fail the answer card stays and the section says so with
///   "Tekrar Dene".
/// - There is no previous/next question (pano 5.7 "önceki/sonraki yok").
/// - A coach's [student] sends its id with the request; "Kartları Çalış" is
///   not offered to a coach.
class QuestionDetailViewModel extends BaseViewModel {
  QuestionDetailViewModel({
    required this.examId,
    required this.testIndex,
    required this.questionOrder,
    required ExamRepository exams,
    required ExamDetailNavigator navigator,
    this.student,
    ExamDetail? initial,
    Duration timeout = SmapDurations.skeletonTimeout,
  }) : _exams = exams,
       _navigator = navigator,
       _finder = ExamFinder(exams),
       _timeout = timeout,
       _exam = initial == null
           ? const AsyncSection<ExamDetail>.loading()
           : AsyncSection<ExamDetail>.ready(initial);

  final String examId;

  /// The test (0-based; the route's `lesson`).
  final int testIndex;

  /// The question's number in the test (1-based; the route's `q`).
  final int questionOrder;
  final StudentRef? student;

  final ExamRepository _exams;
  final ExamDetailNavigator _navigator;
  final ExamFinder _finder;
  final Duration _timeout;

  AsyncSection<ExamDetail> _exam;
  AsyncSection<QuestionDetail> _question =
      const AsyncSection<QuestionDetail>.loading();
  bool _started = false;
  bool _disposed = false;
  QuestionPlace? _place;

  @override
  void notifyListeners() {
    if (_disposed) return;
    _place = null;
    super.notifyListeners();
  }

  String? get studentId => student?.id;
  bool get isCoachView => student != null;

  /// The state of the result: the whole screen follows it.
  SectionState get screenState => _exam.state;

  /// The question's place in the exam; `null` until the result is here.
  QuestionPlace? get place {
    final data = _exam.data;
    if (data == null) return null;
    return _place ??= QuestionPlace.of(
      data,
      testIndex: testIndex,
      number: questionOrder,
    );
  }

  /// The explanation and the related cards.
  AsyncSection<QuestionDetail> get question => _question;

  /// "Kartları Çalış" shows: the question has related cards, a student (not
  /// a coach) is looking, and the lesson's deck is known.
  bool get canStudyCards =>
      !isCoachView &&
      (_question.data?.cards.isNotEmpty ?? false) &&
      place?.lessonId != null;

  /// Starts the screen.
  void init() {
    if (_started) return;
    _started = true;
    unawaited(_load());
  }

  /// "Tekrar Dene" of the screen error.
  Future<void> retry() => _load();

  /// "Tekrar Dene" of the explanation section.
  Future<void> retryQuestion() => _loadQuestion();

  Future<void> _load() async {
    if (_exam.data == null) {
      _exam = const AsyncSection<ExamDetail>.loading();
      notifyListeners();
      final next = await AsyncSection.load<ExamDetail>(
        () => _unwrap(_finder.find(examId, studentId: studentId)),
        timeout: _timeout,
      );
      if (_disposed) return;
      _exam = next;
      notifyListeners();
    }
    await _loadQuestion();
  }

  Future<void> _loadQuestion() async {
    final current = _exam.data;
    if (current == null) return;
    _question = const AsyncSection<QuestionDetail>.loading();
    notifyListeners();
    final next = await AsyncSection.load<QuestionDetail>(
      () => _unwrap(
        _exams.getQuestion(
          exam: current.summary.definition,
          questionOrder: questionOrder,
          lessonOrder: testIndex,
          studentId: studentId,
        ),
      ),
      timeout: _timeout,
    );
    if (_disposed) return;
    _question = next;
    notifyListeners();
  }

  /// A related card was pressed: its sheet.
  Future<void> openCard(QuestionTopicCard card) =>
      QuestionCardSheet.show(card: card);

  /// "Kartları Çalış": the deck of the question's lesson.
  Future<void> studyCards() async {
    if (!canStudyCards) return;
    await _navigator.openCardDeck(
      examId: examId,
      backendLessonId: place?.lessonId,
      lessonName: place?.lessonName,
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
