import 'package:flutter/foundation.dart' show immutable;

import 'package:smap/features/schedule/application/hour_range.dart';
import 'package:smap/features/schedule/application/program_entry.dart';
import 'package:smap/shared/ui/pickers/calendar_math.dart';

/// A block of the week grid: an entry and the lane it sits in when blocks of
/// one day overlap in time (two topics 30 minutes apart share a column).
@immutable
class WeekBlock {
  const WeekBlock({
    required this.entry,
    required this.lane,
    required this.lanes,
  });

  final ProgramEntry entry;

  /// 0-based lane inside the day column.
  final int lane;

  /// How many lanes the overlapping group has.
  final int lanes;

  @override
  bool operator ==(Object other) =>
      other is WeekBlock &&
      other.entry == entry &&
      other.lane == lane &&
      other.lanes == lanes;

  @override
  int get hashCode => Object.hash(entry, lane, lanes);
}

/// The arithmetic of the week grid (C63 "WeekGrid"; pano 3.4 kare 4): which
/// blocks share a column, where the grid first opens. Pure, tested apart from
/// the widget.
abstract final class WeekGridLayout {
  /// How many minutes a block covers: 36 pt of a 40 pt hour row.
  static const int blockMinutes = 54;

  /// Lays out the blocks of one day: sorted by time, and topics that overlap
  /// (less than [blockMinutes] apart) are given separate lanes.
  static List<WeekBlock> blocksOf(List<ProgramEntry> dayEntries) {
    final sorted = [...dayEntries]
      ..sort((a, b) {
        final byTime = a.minutes.compareTo(b.minutes);
        return byTime != 0 ? byTime : a.id.compareTo(b.id);
      });
    final blocks = <WeekBlock>[];
    var group = <(ProgramEntry, int)>[];
    var laneEnds = <int>[];

    void flush() {
      final lanes = laneEnds.length;
      for (final (entry, lane) in group) {
        blocks.add(WeekBlock(entry: entry, lane: lane, lanes: lanes));
      }
      group = [];
      laneEnds = [];
    }

    var groupEnd = -1;
    for (final entry in sorted) {
      if (group.isNotEmpty && entry.minutes >= groupEnd) flush();
      var lane = laneEnds.indexWhere((end) => end <= entry.minutes);
      if (lane < 0) {
        lane = laneEnds.length;
        laneEnds.add(0);
      }
      laneEnds[lane] = entry.minutes + blockMinutes;
      group.add((entry, lane));
      groupEnd = laneEnds.reduce((a, b) => a > b ? a : b);
    }
    if (group.isNotEmpty) flush();
    return blocks;
  }

  /// The day the grid opens on: [today] when [days] holds it, else the day of
  /// the earliest topic, else [today] (then the first column shows).
  static DateTime focusDay({
    required List<DateTime> days,
    required DateTime today,
    required Iterable<ProgramEntry> entries,
  }) {
    if (days.any((day) => CalendarMath.sameDay(day, today))) return today;
    ProgramEntry? first;
    for (final entry in entries) {
      if (first == null ||
          entry.day.isBefore(first.day) ||
          (entry.day == first.day && entry.minutes < first.minutes)) {
        first = entry;
      }
    }
    return first?.day ?? today;
  }

  /// The column the grid opens on: [focus]'s column when [days] holds it, so
  /// it lands third among the visible columns (pano 3.4 kare 4: Perşembe to
  /// Pazar shown, "Pazartesi–Çarşamba solda"); otherwise the first column.
  /// Clamped to the columns that can scroll.
  static int firstVisibleColumn({
    required List<DateTime> days,
    required DateTime focus,
    required int visibleColumns,
  }) {
    final index = days.indexWhere((day) => CalendarMath.sameDay(day, focus));
    if (index < 0) return 0;
    final maxStart = days.length - visibleColumns;
    if (maxStart <= 0) return 0;
    final start = index - 2;
    if (start < 0) return 0;
    return start > maxStart ? maxStart : start;
  }

  /// The hour row the grid opens on: the row of the earliest topic, one row
  /// above it so the topic is not under the edge; the first row when there is
  /// no topic.
  static int firstVisibleRow({
    required Iterable<ProgramEntry> entries,
    required HourRange range,
  }) {
    int? earliest;
    for (final entry in entries) {
      if (earliest == null || entry.hour < earliest) earliest = entry.hour;
    }
    if (earliest == null) return 0;
    final row = earliest - range.first - 1;
    return row < 0 ? 0 : row;
  }
}
