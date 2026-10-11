import 'package:flutter/foundation.dart' show immutable;

import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/schedule/application/program_entry.dart';
import 'package:smap/features/schedule/application/program_span.dart';
import 'package:smap/shared/ui/pickers/calendar_math.dart';

/// What step 3 of a new program tells before saving (pano 3.5 kare 4 "Günler:
/// 12–17 Ekim 2026 · 6 gün", "Çalışmalar: 3 çalışma, hepsi Pazartesi · Salı–
/// Cumartesi henüz boş").
@immutable
class NewProgramSummary {
  const NewProgramSummary({
    required this.range,
    required this.shortRange,
    required this.dayCount,
    required this.studyCount,
    required this.emptyDays,
    this.onlyDay,
  });

  /// The summary of the chosen [days] and the planned [entries].
  factory NewProgramSummary.of(
    List<DateTime> days,
    List<ProgramEntry> entries,
  ) {
    final sorted = CalendarMath.sortedUnique(days);
    final used = {for (final e in entries) CalendarMath.dateOnly(e.day)};
    final empty = [
      for (final day in sorted)
        if (!used.contains(day)) day,
    ];
    return NewProgramSummary(
      range: sorted.isEmpty
          ? ''
          : ProgramDateRange.format(sorted.first, sorted.last),
      shortRange: sorted.isEmpty
          ? ''
          : ProgramDateRange.format(sorted.first, sorted.last, withYear: false),
      dayCount: sorted.length,
      studyCount: entries.length,
      emptyDays: empty,
      onlyDay: used.length == 1 ? used.first : null,
    );
  }

  /// "12–17 Ekim 2026": from the first chosen day to the last.
  final String range;

  /// "12–17 Ekim": the same without the year (the band of step 1).
  final String shortRange;

  /// How many days were chosen.
  final int dayCount;

  /// How many topics were placed.
  final int studyCount;

  /// The chosen days that have no topic yet.
  final List<DateTime> emptyDays;

  /// The one day that holds every topic, when there is only one.
  final DateTime? onlyDay;

  @override
  bool operator ==(Object other) =>
      other is NewProgramSummary &&
      other.range == range &&
      other.shortRange == shortRange &&
      other.dayCount == dayCount &&
      other.studyCount == studyCount &&
      other.onlyDay == onlyDay &&
      _sameDays(other.emptyDays, emptyDays);

  static bool _sameDays(List<DateTime> a, List<DateTime> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    range,
    dayCount,
    studyCount,
    onlyDay,
    Object.hashAll(emptyDays),
  );
}

/// Writes days as runs of weekday names: "Salı–Cumartesi" for days in a row,
/// "Salı, Perşembe" for days apart, "Salı–Çarşamba, Cuma" for both.
abstract final class DayRunsLabel {
  static String of(Iterable<DateTime> days) {
    final sorted = CalendarMath.sortedUnique(days);
    if (sorted.isEmpty) return '';
    final runs = <(DateTime, DateTime)>[];
    var start = sorted.first;
    var end = sorted.first;
    for (final day in sorted.skip(1)) {
      if (CalendarMath.daysBetween(end, day) == 1) {
        end = day;
      } else {
        runs.add((start, end));
        start = day;
        end = day;
      }
    }
    runs.add((start, end));
    return [
      for (final (first, last) in runs)
        CalendarMath.sameDay(first, last)
            ? TrFormat.gunAdi(first)
            : '${TrFormat.gunAdi(first)}–${TrFormat.gunAdi(last)}',
    ].join(', ');
  }
}
