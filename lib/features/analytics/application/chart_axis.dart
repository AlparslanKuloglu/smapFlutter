import 'dart:math' as math;

import 'package:smap/core/utils/tr_format.dart';

/// The axis and range rules of the net chart (C48 `NetChart`; pano 1.4 and
/// 6.1), pure and unit-tested. The old chart's interval table
/// (`analytics_view_provider.dart` `getYLabels`: 120→30, 80→20, 40→5, 30→5,
/// 24→4, 5, 6, 7→1, otherwise 10) is kept; 160→40 is added from pano 6.1
/// (0, 40, 80, 120, 160).
abstract final class ChartAxis {
  /// The y step for an axis that ends at [max].
  ///
  /// 120 → 30 and 160 → 40 (four bands, panos 6.1 and 1.4); a lesson chart
  /// uses its question count: 80 → 20, 40 → 5, 30 → 5, 24 → 4, 5 to 7 → 1.
  /// Anything else gets 10, doubled until the axis has at most nine lines.
  static double stepFor(double max) {
    const table = <int, double>{
      160: 40,
      120: 30,
      80: 20,
      40: 5,
      30: 5,
      24: 4,
      7: 1,
      6: 1,
      5: 1,
    };
    final known = table[max.round()];
    if (known != null) return known;
    var step = 10.0;
    while (max / step > 8) {
      step *= 2;
    }
    return step;
  }

  /// The y lines from 0 to [max], both ends included: `0, 30, 60, 90, 120`.
  static List<double> ticks(double max) {
    final step = stepFor(max);
    final out = <double>[];
    for (var value = 0.0; value < max; value += step) {
      out.add(value);
    }
    out.add(max);
    return out;
  }

  /// [net] limited to the fixed axis `0..max`. The axis never grows to fit a
  /// value ("Y sabit"); a negative net sits on the 0 line (its real value is
  /// still in the balloon).
  static double clampNet(double net, double max) => net.clamp(0.0, max);

  /// Half a step of room beyond the first and last point so the dots are not
  /// cut by the plot edge.
  static const double xPadding = 0.3;

  /// The x range for [count] points that sit at 0, 1, …, count − 1:
  /// `(−0.3, count − 1 + 0.3)`. A single point gets `(−0.5, 0.5)` so the
  /// range is never empty.
  static (double, double) xBounds(int count) {
    if (count <= 1) return (-0.5, 0.5);
    return (-xPadding, count - 1 + xPadding);
  }

  /// Which x labels are written, as point indices: all of them when they
  /// fit, otherwise the first, the last and evenly spaced ones between, at
  /// most [maxLabels] (the old chart's rule). With [maxLabels] below 2 only
  /// the last point is labelled.
  static Set<int> visibleLabelIndices(int count, int maxLabels) {
    if (count <= 0) return const {};
    if (count <= maxLabels) return {for (var i = 0; i < count; i++) i};
    if (maxLabels < 2) return {count - 1};
    final out = <int>{0, count - 1};
    final step = (count - 1) / (maxLabels - 1);
    for (var i = 1; i < maxLabels - 1; i++) {
      out.add((i * step).round());
    }
    return out;
  }

  /// How many x labels fit in [plotWidth] when one label is about
  /// [labelWidth] wide (it grows with the text scale), with a small gap, never
  /// fewer than two and never more than [count].
  static int maxLabelsFor({
    required double plotWidth,
    required double labelWidth,
    required int count,
    double gap = 4,
  }) {
    if (labelWidth <= 0) return count;
    final fit = ((plotWidth + gap) / (labelWidth + gap)).floor();
    return math.min(count, math.max(2, fit));
  }

  /// The point selected after a tap: the tapped one, or the last point when
  /// the tap missed every point ("dışına dokununca son noktaya döner").
  /// Null when there are no points.
  static int? selectionAfterTap({required int? tapped, required int count}) {
    if (count <= 0) return null;
    if (tapped != null && tapped >= 0 && tapped < count) return tapped;
    return count - 1;
  }

  /// The x label of a date: `22 Nis.`.
  static String dateLabel(DateTime date) => TrFormat.kisaTarih(date);

  /// The day and month of a date for the screen reader: `22 Nisan`.
  static String longDayMonth(DateTime date) =>
      '${date.day} ${TrFormat.months[date.month - 1]}';
}
