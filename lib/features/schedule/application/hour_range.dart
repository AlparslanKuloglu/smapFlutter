import 'package:flutter/foundation.dart' show immutable;

import 'package:smap/features/schedule/application/program_entry.dart';

/// The hours a grid draws: 06:00 to 23:00 (pano 3.4 "Izgara 06:00–23:00",
/// pano 3.5 kare 2), widened when a stored topic sits outside them so no topic
/// disappears from the screen.
@immutable
class HourRange {
  const HourRange({required this.first, required this.last});

  /// The range that holds [entries] and the default hours.
  factory HourRange.of(Iterable<ProgramEntry> entries) {
    var first = defaultFirst;
    var last = defaultLast;
    for (final entry in entries) {
      if (entry.hour < first) first = entry.hour;
      if (entry.hour > last) last = entry.hour;
    }
    return HourRange(first: first, last: last);
  }

  /// The planner's first hour.
  static const int defaultFirst = 6;

  /// The planner's last hour.
  static const int defaultLast = 23;

  static const HourRange standard = HourRange(
    first: defaultFirst,
    last: defaultLast,
  );

  /// First hour row, 0 to 23.
  final int first;

  /// Last hour row, 0 to 23.
  final int last;

  /// How many hour rows the grid has.
  int get rows => last - first + 1;

  /// The hours, first to last.
  List<int> get hours => [for (var h = first; h <= last; h++) h];

  @override
  bool operator ==(Object other) =>
      other is HourRange && other.first == first && other.last == last;

  @override
  int get hashCode => Object.hash(first, last);
}
