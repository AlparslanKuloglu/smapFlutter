import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'package:smap/features/analytics/application/analytics_filter.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/analytics/domain/analytics_summary.dart';

/// How the Genel tab draws the exams of a filter (pano 6.1 and 6.3).
enum GeneralChartKind {
  /// No exam with a date: no chart card.
  none,

  /// One exam: "İlk denemen" with the net instead of a line (6.3 kare 2).
  single,

  /// Two or more: the line chart ("Grafik iki denemeden itibaren çizilir").
  line,
}

/// Everything the Genel tab shows for one [AnalyticsFilter], worked out from
/// the two answers (`getTotal`, `getLineChartData`) once, as an immutable
/// value the screen's selectors compare.
///
/// A figure that cannot be worked out is `null` and its box is not drawn
/// (never a made-up zero). The rank and the points of the boxes are the
/// whole exam's, so a lesson filter has none.
@immutable
class GeneralContent {
  const GeneralContent({
    required this.filter,
    required this.points,
    required this.axisMax,
    this.examCount,
    this.averageNet,
    this.averagePoint,
    this.averageRank,
    this.netDelta,
  });

  /// Works the content out of [overview] for [filter].
  factory GeneralContent.from(
    AnalyticsFilter filter,
    AnalyticsOverview overview,
  ) {
    final points = overview.series.toChartPoints();
    final summary = overview.summary;
    final lesson = filter.lesson;
    final axis =
        overview.series.totalQuestion?.toDouble() ??
        (lesson == null
            ? filter.exam.axisMax
            : lesson.totalQuestion.toDouble());
    return GeneralContent(
      filter: filter,
      points: points,
      axisMax: axis,
      examCount: summary.examCount ?? (points.isEmpty ? null : points.length),
      averageNet: summary.averageNet,
      averagePoint: lesson == null ? summary.averagePoint : null,
      averageRank: lesson == null ? summary.averageRank : null,
      netDelta: lastTwoDelta(points),
    );
  }

  final AnalyticsFilter filter;

  /// The exams the chart draws, oldest first.
  final List<NetChartPoint> points;

  /// The top of the y axis: the exam's 120 or 160, or a lesson's question
  /// count.
  final double axisMax;

  /// "6 deneme": the server's count.
  final int? examCount;
  final double? averageNet;
  final double? averagePoint;
  final int? averageRank;

  /// "+3,25 son denemede": the last exam's net minus the one before it of
  /// the same filter; `null` with fewer than two exams.
  final double? netDelta;

  GeneralChartKind get chartKind => switch (points.length) {
    0 => GeneralChartKind.none,
    1 => GeneralChartKind.single,
    _ => GeneralChartKind.line,
  };

  /// Nothing to show: no exam at all.
  bool get isEmpty => points.isEmpty && (examCount ?? 0) == 0;

  /// What the chart and its reading call the scope: "TYT", "TYT Türkçe".
  String get scopeLabel {
    final lesson = filter.lesson;
    return lesson == null ? filter.exam.label : lesson.name;
  }

  /// The last exam minus the one before it, rounded to two decimals; `null`
  /// with fewer than two [points] (oldest first).
  static double? lastTwoDelta(List<NetChartPoint> points) {
    if (points.length < 2) return null;
    final change = points.last.net - points[points.length - 2].net;
    return (change * 100).round() / 100;
  }

  @override
  bool operator ==(Object other) =>
      other is GeneralContent &&
      other.filter == filter &&
      other.axisMax == axisMax &&
      other.examCount == examCount &&
      other.averageNet == averageNet &&
      other.averagePoint == averagePoint &&
      other.averageRank == averageRank &&
      other.netDelta == netDelta &&
      listEquals(other.points, points);

  @override
  int get hashCode => Object.hash(
    filter,
    axisMax,
    examCount,
    averageNet,
    averagePoint,
    averageRank,
    netDelta,
    Object.hashAll(points),
  );
}
