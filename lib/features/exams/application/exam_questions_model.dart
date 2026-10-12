import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/application/exam_detail_model.dart';
import 'package:smap/features/exams/application/question_status.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';

/// The question filter of the Sorular tab (pano 5.4 "Soru süzgeci": "Tümü",
/// "Yanlışlar", "Boşlar").
enum QuestionFilter {
  /// Tümü.
  all,

  /// Yanlışlar.
  wrong,

  /// Boşlar.
  blank;

  /// Whether a question of [outcome] passes the filter.
  bool admits(QuestionOutcome outcome) => switch (this) {
    all => true,
    wrong => outcome == QuestionOutcome.wrong,
    blank => outcome == QuestionOutcome.blank,
  };
}

/// One test with the questions the filter lets through (the accordion of pano
/// 5.4).
@immutable
class TestQuestions {
  const TestQuestions({
    required this.index,
    required this.counts,
    required this.questionCount,
    required this.questions,
    this.label,
  });

  /// Position of the test (0-based); `getQuestion` takes it as `lessonOrder`.
  final int index;
  final ExamTestLabel? label;

  /// D/Y/B of the whole test (the header of the accordion keeps them under
  /// every filter: "Kapalı testler sayaçlarıyla durur").
  final DybCounts counts;

  /// Questions the test has, before the filter.
  final int questionCount;

  /// The questions the filter lets through, in order.
  final List<QuestionResult> questions;

  @override
  bool operator ==(Object other) =>
      other is TestQuestions &&
      other.index == index &&
      other.label == label &&
      other.counts == counts &&
      other.questionCount == questionCount &&
      listEquals(other.questions, questions);

  @override
  int get hashCode => Object.hash(
    index,
    label,
    counts,
    questionCount,
    Object.hashAll(questions),
  );
}

/// The Sorular tab (pano 5.4): every test with its questions, the counters of
/// the filter and the filtering itself. Pure.
@immutable
class ExamQuestionsModel {
  const ExamQuestionsModel(this.tests, {this.examKind});

  /// The questions of a result; a test without questions is left out.
  factory ExamQuestionsModel.of(ExamDetail detail) {
    final exam = detail.kind;
    return ExamQuestionsModel([
      for (final test in detail.tests)
        if (test.questions.isNotEmpty)
          TestQuestions(
            index: test.index,
            label: ExamTestLabel.of(exam, test.kind),
            counts: test.counts ?? test.questionCounts!,
            questionCount: test.questions.length,
            questions: test.questions,
          ),
    ], examKind: exam);
  }

  /// The tests with all their questions (before any filter).
  final List<TestQuestions> tests;

  /// TYT or AYT; the question-to-lesson layout depends on it.
  final NetExamType? examKind;

  /// No test has a question: "Bu deneme için soru ayrıntısı yok."
  bool get isEmpty => tests.isEmpty;

  /// All questions: the "160 soru" counter.
  int get total => tests.fold(0, (sum, test) => sum + test.questionCount);

  /// Wrong questions: the "74 yanlış" counter.
  int get wrong => _count(QuestionOutcome.wrong);

  /// Blank questions: the "boş yok" counter.
  int get blank => _count(QuestionOutcome.blank);

  int _count(QuestionOutcome outcome) => tests.fold(
    0,
    (sum, test) =>
        sum + test.questions.where((q) => q.outcome == outcome).length,
  );

  /// The count behind [filter]'s counter.
  int countOf(QuestionFilter filter) => switch (filter) {
    QuestionFilter.all => total,
    QuestionFilter.wrong => wrong,
    QuestionFilter.blank => blank,
  };

  /// The tests that still have a question under [filter], each holding only
  /// the questions the filter lets through. [QuestionFilter.all] keeps every
  /// test.
  List<TestQuestions> filtered(QuestionFilter filter) {
    if (filter == QuestionFilter.all) return tests;
    return [
      for (final test in tests)
        if (test.questions.any((q) => filter.admits(q.outcome)))
          TestQuestions(
            index: test.index,
            label: test.label,
            counts: test.counts,
            questionCount: test.questionCount,
            questions: [
              for (final q in test.questions)
                if (filter.admits(q.outcome)) q,
            ],
          ),
    ];
  }

  @override
  bool operator ==(Object other) =>
      other is ExamQuestionsModel &&
      other.examKind == examKind &&
      listEquals(other.tests, tests);

  @override
  int get hashCode => Object.hash(examKind, Object.hashAll(tests));
}
