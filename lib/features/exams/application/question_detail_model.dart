import 'package:flutter/foundation.dart' show immutable;

import 'package:smap/features/exams/application/exam_detail_model.dart';
import 'package:smap/features/exams/application/exam_question_layout.dart';
import 'package:smap/features/exams/application/question_status.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';

/// What Soru Detay knows about the question from the exam result itself
/// (pano 5.7): its number, which test it is in and the lesson that test cuts
/// it into, and how it came out. Pure.
@immutable
class QuestionPlace {
  const QuestionPlace({
    required this.number,
    required this.testIndex,
    this.testLabel,
    this.lessonName,
    this.lessonId,
    this.outcome,
    this.markedOption,
    this.correctOption,
  });

  /// Finds question [number] (1-based) of the test [testIndex] (0-based) in
  /// [exam]. A question the result does not list still has its place: the
  /// number and the test name; [outcome] is then `null`.
  factory QuestionPlace.of(
    ExamDetail exam, {
    required int testIndex,
    required int number,
  }) {
    TestResult? test;
    for (final candidate in exam.tests) {
      if (candidate.index == testIndex) test = candidate;
    }
    QuestionResult? question;
    for (final candidate in test?.questions ?? const <QuestionResult>[]) {
      if (candidate.order == number) question = candidate;
    }
    final kind = exam.kind;
    final lesson = kind == null
        ? null
        : ExamQuestionLayout.lessonOf(kind, testIndex, number);
    return QuestionPlace(
      number: number,
      testIndex: testIndex,
      testLabel: ExamTestLabel.of(kind, test?.kind),
      lessonName: lesson?.name,
      lessonId: lesson?.id,
      outcome: question?.outcome,
      markedOption: question?.markedOption,
      correctOption: question?.correctOption,
    );
  }

  final int number;
  final int testIndex;

  /// The test's name word ("Türk Dili ve Edebiyatı–Sosyal Bilimler 1");
  /// `null` for a test the app has no name for.
  final ExamTestLabel? testLabel;

  /// The lesson of the question ("Tarih"); `null` when the form layout does
  /// not cover it.
  final String? lessonName;

  /// The lesson's exam lesson id, when the catalog knows it (Felsefe and Din
  /// Kültürü have none): what the lesson's card deck takes.
  final String? lessonId;

  /// Doğru, Yanlış or Boş; `null` when the result does not list the question.
  final QuestionOutcome? outcome;

  /// The letter the student marked, when the backend sends it (it does not
  /// today, spec §6.3 #9).
  final String? markedOption;

  /// The right letter, when the backend sends it.
  final String? correctOption;

  /// The letters are known: the answer card can write them.
  bool get hasLetters =>
      (markedOption?.trim().isNotEmpty ?? false) ||
      (correctOption?.trim().isNotEmpty ?? false);

  @override
  bool operator ==(Object other) =>
      other is QuestionPlace &&
      other.number == number &&
      other.testIndex == testIndex &&
      other.testLabel == testLabel &&
      other.lessonName == lessonName &&
      other.lessonId == lessonId &&
      other.outcome == outcome &&
      other.markedOption == markedOption &&
      other.correctOption == correctOption;

  @override
  int get hashCode => Object.hash(
    number,
    testIndex,
    testLabel,
    lessonName,
    lessonId,
    outcome,
    markedOption,
    correctOption,
  );
}
