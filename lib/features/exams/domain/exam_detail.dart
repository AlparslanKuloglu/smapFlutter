import 'package:flutter/foundation.dart' show immutable, listEquals, mapEquals;

import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/application/question_status.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/features/exams/domain/exam_scores.dart';
import 'package:smap/features/exams/domain/exam_summary.dart';

/// The net and D/Y/B of one score type of an AYT result (`aytNets`).
@immutable
class NetBreakdown {
  const NetBreakdown({this.net, this.counts});

  final double? net;
  final DybCounts? counts;

  @override
  bool operator ==(Object other) =>
      other is NetBreakdown && other.net == net && other.counts == counts;

  @override
  int get hashCode => Object.hash(net, counts);
}

/// One lesson of an exam result (`lessonmockexams`): which lesson, its net and
/// D/Y/B. [lessonId] is a catalog lesson id (`ExamLessonCatalog`).
@immutable
class LessonResult {
  const LessonResult({required this.lessonId, this.net, this.counts});

  final String lessonId;
  final double? net;
  final DybCounts? counts;

  @override
  bool operator ==(Object other) =>
      other is LessonResult &&
      other.lessonId == lessonId &&
      other.net == net &&
      other.counts == counts;

  @override
  int get hashCode => Object.hash(lessonId, net, counts);
}

/// The block of an exam a student sits in one go: TYT has four, AYT four.
/// The screen writes the names ("Türkçe", "Sosyal Bilimler", "Matematik",
/// "Fen Bilimleri", "Sosyal Bilimler - 2").
enum ExamTestKind {
  /// TYT Türkçe.
  turkish,

  /// TYT Sosyal Bilimler.
  socialSciences,

  /// AYT Türk Dili ve Edebiyatı – Sosyal Bilimler-1 (the legacy label is
  /// "Sosyal Bilimler").
  socialSciences1,

  /// AYT Sosyal Bilimler-2.
  socialSciences2,

  /// Matematik (TYT and AYT).
  mathematics,

  /// Fen Bilimleri (TYT and AYT).
  sciences;

  /// The test at [index] (0-based, the order of `questionsArrStr` and
  /// `lessonInfo`) of an exam of [exam]; `null` past the fourth.
  static ExamTestKind? at(NetExamType exam, int index) {
    final order = switch (exam) {
      NetExamType.tyt => const [turkish, socialSciences, mathematics, sciences],
      NetExamType.ayt => const [
        socialSciences1,
        socialSciences2,
        mathematics,
        sciences,
      ],
    };
    return index >= 0 && index < order.length ? order[index] : null;
  }
}

/// One question of a test (C43 `QuestionCell`, `result` variant).
///
/// [markedOption] and [correctOption] are the letters the Sorular tab shows
/// ("işaretin C, doğru cevap A"). **The backend does not send them today**
/// (`questionsArrStr` carries only `{order, type}`; spec §6.3 #9), so they are
/// always `null` for now and the cell shows the outcome only.
@immutable
class QuestionResult {
  const QuestionResult({
    required this.order,
    required this.outcome,
    this.markedOption,
    this.correctOption,
  });

  /// The question's number in the test.
  final int order;

  final QuestionOutcome outcome;

  /// The letter the student marked, when the backend sends it.
  final String? markedOption;

  /// The right letter, when the backend sends it.
  final String? correctOption;

  @override
  bool operator ==(Object other) =>
      other is QuestionResult &&
      other.order == order &&
      other.outcome == outcome &&
      other.markedOption == markedOption &&
      other.correctOption == correctOption;

  @override
  int get hashCode => Object.hash(order, outcome, markedOption, correctOption);
}

/// One test of an exam (Türkçe, Matematik, ...): its D/Y/B and its questions
/// (C25 `TestBarRow`, the Sorular tab).
@immutable
class TestResult {
  const TestResult({
    required this.index,
    this.kind,
    this.counts,
    this.questions = const [],
  });

  /// Position of the test (0-based). `getQuestion` takes it as `lessonOrder`.
  final int index;

  final ExamTestKind? kind;

  /// D/Y/B of the test: the server's per-test figures (`lessonInfo`); when it
  /// sent none, counted from [questions]; `null` when neither exists.
  final DybCounts? counts;

  /// The questions in order; empty when the server sent none for this test.
  final List<QuestionResult> questions;

  /// D/Y/B counted from [questions]; `null` for a test without questions.
  DybCounts? get questionCounts {
    if (questions.isEmpty) return null;
    var correct = 0;
    var wrong = 0;
    var blank = 0;
    for (final question in questions) {
      switch (question.outcome) {
        case QuestionOutcome.correct:
          correct++;
        case QuestionOutcome.wrong:
          wrong++;
        case QuestionOutcome.blank:
          blank++;
      }
    }
    return DybCounts(correct: correct, wrong: wrong, blank: blank);
  }

  @override
  bool operator ==(Object other) =>
      other is TestResult &&
      other.index == index &&
      other.kind == kind &&
      other.counts == counts &&
      listEquals(other.questions, questions);

  @override
  int get hashCode =>
      Object.hash(index, kind, counts, Object.hashAll(questions));
}

/// A whole exam result (Deneme Detay, Sonuç Anı; boards 5.1 to 5.3).
@immutable
class ExamDetail {
  const ExamDetail({
    required this.summary,
    this.scores = ExamScores.none,
    this.aytNets = const {},
    this.lessons = const [],
    this.tests = const [],
  });

  final ExamSummary summary;

  /// Points and ranks per score type; read the one that counts with
  /// [scoreFor].
  final ExamScores scores;

  /// AYT net per field (`aytNets`); empty for a TYT result.
  final Map<AytField, NetBreakdown> aytNets;

  /// Per-lesson results, in the server's order.
  final List<LessonResult> lessons;

  /// The tests with their questions, in order.
  final List<TestResult> tests;

  String get id => summary.id;

  NetExamType? get kind => summary.kind;

  /// The points and ranks of the student's score type: slot 0 for a TYT
  /// result, the [field]'s slot for an AYT result. `null` for an AYT without
  /// a known [field] or for an exam of unknown type.
  ScoreEntry? scoreFor(AytField? field) {
    final exam = kind;
    return exam == null ? null : scores.forExam(exam, field);
  }

  @override
  bool operator ==(Object other) =>
      other is ExamDetail &&
      other.summary == summary &&
      other.scores == scores &&
      mapEquals(other.aytNets, aytNets) &&
      listEquals(other.lessons, lessons) &&
      listEquals(other.tests, tests);

  @override
  int get hashCode => Object.hash(
    summary,
    scores,
    Object.hashAll(aytNets.entries.map((e) => Object.hash(e.key, e.value))),
    Object.hashAll(lessons),
    Object.hashAll(tests),
  );
}
