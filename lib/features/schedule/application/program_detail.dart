import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'package:smap/features/schedule/application/program_entry.dart';
import 'package:smap/features/schedule/application/program_span.dart';
import 'package:smap/features/schedule/domain/weekly_draft.dart';
import 'package:smap/shared/ui/pickers/calendar_math.dart';

/// A program as the detail screen shows it (pano 3.4 kare 3 and 4, 3.6): its
/// name and motto, the days of its span and the entries of each day. Immutable
/// with value equality, so a selector can compare it.
@immutable
class ProgramDetail {
  const ProgramDetail({
    required this.id,
    required this.name,
    required this.motto,
    required this.span,
    required this.entries,
  });

  /// The program [id] as [draft] holds it.
  ///
  /// [keepSpan] keeps the days the screen already shows when the topics of a
  /// day were all removed ("Günü Sıfırla" must leave an empty day, pano 3.6
  /// kare 3, not drop it from the strip).
  factory ProgramDetail.of({
    required String id,
    required WeeklyDraft draft,
    required DateTime today,
    ProgramSpan? keepSpan,
  }) {
    final entries = [for (final task in draft.tasks) ProgramEntry.of(task)]
      ..sort((a, b) {
        final byDay = a.day.compareTo(b.day);
        if (byDay != 0) return byDay;
        final byTime = a.minutes.compareTo(b.minutes);
        return byTime != 0 ? byTime : a.id.compareTo(b.id);
      });
    final ProgramSpan span;
    if (entries.isEmpty) {
      span = keepSpan ?? ProgramSpan.week(today);
    } else {
      final own = ProgramSpan.of([
        for (final e in entries) e.day,
      ], today: today);
      span = keepSpan == null ? own : own.union(keepSpan);
    }
    return ProgramDetail(
      id: id,
      name: draft.name,
      motto: draft.motto,
      span: span,
      entries: entries,
    );
  }

  final String id;
  final String name;
  final String motto;
  final ProgramSpan span;

  /// Every entry, by day and time.
  final List<ProgramEntry> entries;

  /// The days of the span, oldest first.
  List<DateTime> get days => span.days;

  /// The entries of [day], earliest first.
  List<ProgramEntry> entriesOn(DateTime day) => [
    for (final entry in entries)
      if (CalendarMath.sameDay(entry.day, day)) entry,
  ];

  /// [day] with its entries, as a value a selector can compare.
  ProgramDay dayOf(DateTime day) =>
      ProgramDay(day: CalendarMath.dateOnly(day), entries: entriesOn(day));

  /// Where each topic of the program sits (see [placementsOf]).
  Map<String, ProgramEntry> get placements => placementsOf(entries);

  /// How many topics [day] holds.
  int countOn(DateTime day) => entriesOn(day).length;

  /// The day the screen opens on: [requested] when it is in the span, else
  /// [today] when it is, else the first day that has a topic, else the span's
  /// first day (pano 3.4 "Gün görünümünde bugünü açar; bugün aralıkta değilse
  /// ilk günü").
  DateTime openingDay({required DateTime today, DateTime? requested}) {
    if (requested != null && span.contains(requested)) {
      return CalendarMath.dateOnly(requested);
    }
    if (span.contains(today)) return CalendarMath.dateOnly(today);
    if (entries.isNotEmpty) return entries.first.day;
    return span.first;
  }

  @override
  bool operator ==(Object other) =>
      other is ProgramDetail &&
      other.id == id &&
      other.name == name &&
      other.motto == motto &&
      other.span == span &&
      listEquals(other.entries, entries);

  @override
  int get hashCode =>
      Object.hash(id, name, motto, span, Object.hashAll(entries));
}

/// One day of a program: the date and its entries, earliest first. Value
/// equality, so a day list selector rebuilds only when the day changed.
@immutable
class ProgramDay {
  const ProgramDay({required this.day, required this.entries});

  final DateTime day;
  final List<ProgramEntry> entries;

  bool get isEmpty => entries.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is ProgramDay &&
      other.day == day &&
      listEquals(other.entries, entries);

  @override
  int get hashCode => Object.hash(day, Object.hashAll(entries));
}
