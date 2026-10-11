import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/features/exams/domain/exam_scores.dart';

/// One exam of the net series (`getLineChartData`'s `mockexams`): when it was
/// solved, what it was called, its net and its D/Y/B and scores.
@immutable
class NetSeriesPoint {
  const NetSeriesPoint({
    required this.net,
    this.date,
    this.name,
    this.counts,
    this.scores = ExamScores.none,
  });

  /// The net; can be negative.
  final double net;

  /// The day of the exam; `null` when the server sent none or an unreadable
  /// one (such a point cannot sit on the time axis, see [NetSeries.toChartPoints]).
  final DateTime? date;

  /// "TYT Genel Deneme 9" when the server names the exam (`itemName`; the
  /// field is assumed, spec §6.3 #26); `null` otherwise.
  final String? name;

  /// D/Y/B of the exam in the series' scope (whole exam, or one lesson in a
  /// lesson chart); `null` unless all three came.
  final DybCounts? counts;

  /// Points and ranks per score type.
  final ExamScores scores;

  /// The chart point of this exam, or `null` without a date.
  NetChartPoint? toChartPoint() {
    final day = date;
    return day == null ? null : NetChartPoint(date: day, net: net, name: name);
  }

  @override
  bool operator ==(Object other) =>
      other is NetSeriesPoint &&
      other.net == net &&
      other.date == date &&
      other.name == name &&
      other.counts == counts &&
      other.scores == scores;

  @override
  int get hashCode => Object.hash(net, date, name, counts, scores);
}

/// The answer of `getLineChartData`: the exams of one scope (TYT, or an AYT
/// field; the whole exam or one lesson) in the server's order.
@immutable
class NetSeries {
  const NetSeries({this.points = const [], this.totalQuestion, this.userField});

  final List<NetSeriesPoint> points;

  /// Question count of the scope when the server sends it (`totalQuestion`);
  /// the top of the chart's y axis for a lesson chart. When absent the axis
  /// is the exam type's (`NetExamType.axisMax`).
  final int? totalQuestion;

  /// The student's AYT field as the server's `user.aimType` says (`null` when
  /// absent or not an AYT field). The legacy screen ignored it and forced
  /// 2 (a TODO); callers may use it for the field chips' initial selection.
  final AytField? userField;

  bool get isEmpty => points.isEmpty;

  /// The points the chart can draw (they have a date), oldest first.
  List<NetChartPoint> toChartPoints() => NetChartPoint.sortedByDate([
    for (final point in points)
      if (point.toChartPoint() case final NetChartPoint chart) chart,
  ]);

  @override
  bool operator ==(Object other) =>
      other is NetSeries &&
      other.totalQuestion == totalQuestion &&
      other.userField == userField &&
      listEquals(other.points, points);

  @override
  int get hashCode =>
      Object.hash(totalQuestion, userField, Object.hashAll(points));
}
