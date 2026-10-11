import 'package:flutter/foundation.dart' show immutable;

import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/analytics/domain/analytics_totals.dart';
import 'package:smap/features/analytics/domain/net_series.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/features/exams/domain/exam_scores.dart';

/// The four boxes of the Analizlerim "Genel" tab (board 6.1): solved exams,
/// average net, average rank, average points. Every figure that cannot be
/// worked out is `null` and its box is not drawn (never a made-up zero or a
/// dash from a fake value).
///
/// Built by [AnalyticsSummary.compute] from the two answers the legacy screen
/// combined by hand (`getTotal` + `getLineChartData`).
@immutable
class AnalyticsSummary {
  const AnalyticsSummary({
    this.examCount,
    this.averageNet,
    this.averageRank,
    this.averagePoint,
    this.counts,
  });

  /// "Çözülen deneme".
  final int? examCount;

  /// "Ortalama net".
  final double? averageNet;

  /// "Ort. sıralama": the mean of the ranks of the student's score type over
  /// the exams that have one, rounded.
  final int? averageRank;

  /// "Ortalama puan": the mean of the points of the student's score type over
  /// the exams that have one.
  final double? averagePoint;

  /// D/Y/B added up over the exams of a lesson chart ("Toplam doğru / yanlış /
  /// boş"); `null` for the general chart or when an exam has no counts.
  final DybCounts? counts;

  /// Works the boxes out.
  ///
  /// - [examCount] is the server's `total.count`.
  /// - [lessonScope] is `true` when one lesson is selected (not "Genel").
  ///   Then [averageNet] is the mean of the exams' nets and [counts] their
  ///   D/Y/B sum (the legacy rules). Otherwise [averageNet] is the server's
  ///   `total.ortNet`, or the mean of the series when the server sent none.
  /// - Rank and points are read from the score slot of [exam] and [field]
  ///   ([ExamScores.slotFor]); an AYT without a [field] has none.
  static AnalyticsSummary compute({
    required AnalyticsTotals totals,
    required NetSeries series,
    required NetExamType exam,
    AytField? field,
    bool lessonScope = false,
  }) {
    final slot = ExamScores.slotFor(exam, field);
    var rankSum = 0;
    var rankCount = 0;
    var pointSum = 0.0;
    var pointCount = 0;
    if (slot != null) {
      for (final point in series.points) {
        final entry = point.scores.at(slot);
        final rank = entry.rank;
        if (rank != null) {
          rankSum += rank;
          rankCount++;
        }
        final score = entry.point;
        if (score != null) {
          pointSum += score;
          pointCount++;
        }
      }
    }

    final meanNet = series.points.isEmpty
        ? null
        : series.points.fold<double>(0, (sum, p) => sum + p.net) /
              series.points.length;

    return AnalyticsSummary(
      examCount: totals.examCount,
      averageNet: lessonScope ? meanNet : (totals.averageNet ?? meanNet),
      averageRank: rankCount == 0 ? null : (rankSum / rankCount).round(),
      averagePoint: pointCount == 0 ? null : pointSum / pointCount,
      counts: lessonScope ? _sumCounts(series.points) : null,
    );
  }

  static DybCounts? _sumCounts(List<NetSeriesPoint> points) {
    if (points.isEmpty) return null;
    var correct = 0;
    var wrong = 0;
    var blank = 0;
    for (final point in points) {
      final counts = point.counts;
      if (counts == null) return null;
      correct += counts.correct;
      wrong += counts.wrong;
      blank += counts.blank;
    }
    return DybCounts(correct: correct, wrong: wrong, blank: blank);
  }

  @override
  bool operator ==(Object other) =>
      other is AnalyticsSummary &&
      other.examCount == examCount &&
      other.averageNet == averageNet &&
      other.averageRank == averageRank &&
      other.averagePoint == averagePoint &&
      other.counts == counts;

  @override
  int get hashCode =>
      Object.hash(examCount, averageNet, averageRank, averagePoint, counts);
}

/// Both answers of the Genel tab and the boxes worked out from them.
@immutable
class AnalyticsOverview {
  const AnalyticsOverview({
    required this.totals,
    required this.series,
    required this.summary,
  });

  final AnalyticsTotals totals;
  final NetSeries series;
  final AnalyticsSummary summary;
}
