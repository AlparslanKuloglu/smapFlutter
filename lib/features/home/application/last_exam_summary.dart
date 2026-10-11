import 'package:flutter/foundation.dart' show immutable;

import 'package:smap/core/utils/turkish_text.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/application/topic_ranking.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';
import 'package:smap/features/exams/domain/topic_result.dart';

/// The topic the student missed most in the last exam (pano 3.1 "En çok
/// kaçırdığın konu": "Kurtuluş Savaşı Hazırlık Dönemi'nde 13 sorudan 9'unu
/// kaçırdın.").
@immutable
class WeakestTopic {
  const WeakestTopic({
    required this.name,
    required this.total,
    required this.wrong,
  });

  final String name;

  /// Questions of the topic in the exam: D + Y + B.
  final int total;

  /// Wrong answers.
  final int wrong;

  /// The name with the locative a possessed topic takes: "Kurtuluş Savaşı
  /// Hazırlık Dönemi'nde" (spec §1.11 "Ek uyumu"; a topic name is a noun
  /// phrase that ends in its possessive).
  String get nameLocative => TurkishSuffix.locative(name, possessed: true);

  /// [total] as written in the sentence: "13".
  String get totalText => '$total';

  /// [wrong] with its possessive and accusative: "9'unu".
  String get wrongAccusative => TurkishSuffix.possessiveAccusative('$wrong');

  @override
  bool operator ==(Object other) =>
      other is WeakestTopic &&
      other.name == name &&
      other.total == total &&
      other.wrong == wrong;

  @override
  int get hashCode => Object.hash(name, total, wrong);
}

/// "Son denemen" of the home screen (pano 3.1 kare 1 and 2; spec §4.B "(c)
/// Son denemen"; assumption 6.2): the newest exam with the change in net
/// against the previous exam of the same type and its weakest topic.
/// Immutable with value equality.
///
/// Every field the card has to draw is here and non-null ([name] aside, which
/// the screen replaces with "{tür} denemesi" when the server had none, board
/// 6.2); an exam the server sent without its type, date or counts is not a
/// usable "last exam" and [of] moves on to the next one.
@immutable
class LastExamSummary {
  const LastExamSummary({
    required this.examId,
    required this.kind,
    required this.date,
    required this.net,
    required this.counts,
    this.name,
    this.publisher,
    this.delta,
    this.weakestTopic,
  });

  /// Id of the student's result: what the exam detail opens by.
  final String examId;

  /// TYT or AYT.
  final NetExamType kind;

  final DateTime date;

  /// The net the server calculated (or `D − Y ÷ 4` when it sent none).
  final double net;

  final DybCounts counts;

  /// "Türkiye Geneli Deneme 6".
  final String? name;

  /// "Örnek Yayınları"; `null` on a result with none.
  final String? publisher;

  /// The net minus the net of the previous exam of the same type; `null`
  /// when there is no previous one (no change is drawn then).
  final double? delta;

  /// The topic missed most; `null` before the topic analysis arrives, when it
  /// failed, or when nothing was missed.
  final WeakestTopic? weakestTopic;

  /// The last exam of [exams], which the server lists newest first.
  ///
  /// The change is measured against the next exam of the same type in the
  /// list. `null` for an empty list or when no exam is usable. The
  /// [analysis] (the topic analysis of that exam) is optional: without it
  /// there is no weakest topic.
  static LastExamSummary? of(
    List<ExamDetail> exams, {
    ExamTopicAnalysis? analysis,
  }) {
    for (final (index, exam) in exams.indexed) {
      final kind = exam.summary.kind;
      final date = exam.summary.date;
      final counts = exam.summary.counts;
      final net = _netOf(exam);
      if (kind == null || date == null || counts == null || net == null) {
        continue;
      }
      double? delta;
      for (final earlier in exams.skip(index + 1)) {
        if (earlier.summary.kind != kind) continue;
        final earlierNet = _netOf(earlier);
        if (earlierNet == null) continue;
        delta = _quarter(net - earlierNet);
        break;
      }
      return LastExamSummary(
        examId: exam.id,
        kind: kind,
        date: date,
        net: net,
        counts: counts,
        name: _clean(exam.summary.name),
        publisher: _clean(exam.summary.publisherName),
        delta: delta,
        weakestTopic: analysis == null ? null : weakestTopicOf(analysis),
      );
    }
    return null;
  }

  /// The topic with the most wrong answers over all lessons of [analysis];
  /// with equal counts the one with the lower success percentage (assumption
  /// 3.6), then the one the server lists first. `null` when no topic has a
  /// wrong answer.
  static WeakestTopic? weakestTopicOf(ExamTopicAnalysis analysis) {
    TopicResult? best;
    for (final lesson in analysis.lessons) {
      for (final topic in lesson.topics) {
        if (topic.counts.wrong <= 0) continue;
        if (best == null || _worse(topic, best)) best = topic;
      }
    }
    if (best == null) return null;
    return WeakestTopic(
      name: best.name,
      total: best.counts.total,
      wrong: best.counts.wrong,
    );
  }

  /// A copy with [weakestTopic] set from [analysis].
  LastExamSummary withAnalysis(ExamTopicAnalysis analysis) => LastExamSummary(
    examId: examId,
    kind: kind,
    date: date,
    net: net,
    counts: counts,
    name: name,
    publisher: publisher,
    delta: delta,
    weakestTopic: weakestTopicOf(analysis),
  );

  static bool _worse(TopicResult candidate, TopicResult best) {
    final byWrong = candidate.counts.wrong.compareTo(best.counts.wrong);
    if (byWrong != 0) return byWrong > 0;
    final candidatePercent = TopicRanking.percent(candidate.counts) ?? 100;
    final bestPercent = TopicRanking.percent(best.counts) ?? 100;
    return candidatePercent < bestPercent;
  }

  static double? _netOf(ExamDetail exam) =>
      exam.summary.net ?? exam.summary.counts?.net;

  /// Nets move in quarter steps; the subtraction of two of them is exact, the
  /// rounding only guards a net the server rounded itself.
  static double _quarter(double value) => (value * 4).round() / 4;

  static String? _clean(String? text) {
    final trimmed = text?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  @override
  bool operator ==(Object other) =>
      other is LastExamSummary &&
      other.examId == examId &&
      other.kind == kind &&
      other.date == date &&
      other.net == net &&
      other.counts == counts &&
      other.name == name &&
      other.publisher == publisher &&
      other.delta == delta &&
      other.weakestTopic == weakestTopic;

  @override
  int get hashCode => Object.hash(
    examId,
    kind,
    date,
    net,
    counts,
    name,
    publisher,
    delta,
    weakestTopic,
  );
}
