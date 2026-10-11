import 'package:flutter/foundation.dart' show immutable;

/// The exam a net chart belongs to; it sets the y axis (C48 `NetChart`:
/// "TYT 0–120, AYT 0–160").
enum NetExamType {
  /// TYT: 120 questions, axis 0 to 120.
  tyt('TYT', 120),

  /// AYT: 160 questions, axis 0 to 160.
  ayt('AYT', 160);

  const NetExamType(this.label, this.axisMax);

  /// The name the screens write ("TYT", "AYT").
  final String label;

  /// The top of the fixed y axis, which is the question count.
  final double axisMax;
}

/// One exam on the net chart: when it was solved, what it was called and its
/// net.
@immutable
class NetChartPoint {
  const NetChartPoint({required this.date, required this.net, this.name});

  /// The day of the exam; the x axis label and the balloon date.
  final DateTime date;

  /// The net; can be negative, the chart then draws it on the 0 line.
  final double net;

  /// "TYT Genel Deneme 9"; null when the exam has no name (the balloon then
  /// shows the date and the net only, pano 6.1).
  final String? name;

  /// [points] oldest first (a new list); the chart's x axis runs forward in
  /// time. Points on the same day keep their given order.
  static List<NetChartPoint> sortedByDate(Iterable<NetChartPoint> points) {
    final indexed = [for (final (i, point) in points.indexed) (i, point)];
    indexed.sort((a, b) {
      final byDate = a.$2.date.compareTo(b.$2.date);
      return byDate != 0 ? byDate : a.$1.compareTo(b.$1);
    });
    return [for (final entry in indexed) entry.$2];
  }

  @override
  bool operator ==(Object other) =>
      other is NetChartPoint &&
      other.date == date &&
      other.net == net &&
      other.name == name;

  @override
  int get hashCode => Object.hash(date, net, name);
}
