import 'package:flutter/foundation.dart' show immutable;

import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/shared/ui/pickers/calendar_math.dart';

/// The calendar a program covers: whole weeks, Monday to Sunday, from the week
/// of its first topic to the week of its last (pano 3.4 "5–11 Ekim 2026").
///
/// The server stores a program's topics and no dates of its own, so the span
/// is read from the topics' days (spec §6.3 #19). A program with no topics
/// covers the week of "today", so the day strip is never empty.
@immutable
class ProgramSpan {
  const ProgramSpan({required this.first, required this.last});

  /// The span of [days] widened to whole weeks; the week of [today] when
  /// [days] is empty.
  factory ProgramSpan.of(Iterable<DateTime> days, {required DateTime today}) {
    final sorted = CalendarMath.sortedUnique(days);
    if (sorted.isEmpty) return ProgramSpan.week(today);
    return ProgramSpan(
      first: CalendarMath.mondayOf(sorted.first),
      last: CalendarMath.sundayOf(sorted.last),
    );
  }

  /// The week of [day].
  factory ProgramSpan.week(DateTime day) => ProgramSpan(
    first: CalendarMath.mondayOf(day),
    last: CalendarMath.sundayOf(day),
  );

  /// The first Monday.
  final DateTime first;

  /// The last Sunday.
  final DateTime last;

  /// Every day of the span, oldest first.
  List<DateTime> get days => CalendarMath.daysFromTo(first, last);

  /// Whether [day] lies inside the span.
  bool contains(DateTime day) =>
      !CalendarMath.isBeforeDay(day, first) &&
      !CalendarMath.isBeforeDay(last, day);

  /// The span that covers both this one and [other].
  ProgramSpan union(ProgramSpan other) => ProgramSpan(
    first: CalendarMath.isBeforeDay(other.first, first) ? other.first : first,
    last: CalendarMath.isBeforeDay(last, other.last) ? other.last : last,
  );

  /// "5–11 Ekim 2026" (see [ProgramDateRange]).
  String get rangeLabel => ProgramDateRange.format(first, last);

  @override
  bool operator ==(Object other) =>
      other is ProgramSpan && other.first == first && other.last == last;

  @override
  int get hashCode => Object.hash(first, last);
}

/// Writes a range of days the way the program screens do (pano 3.4 "5–11 Ekim
/// 2026"; pano 3.5 kare 4 "12–17 Ekim 2026").
abstract final class ProgramDateRange {
  /// `5–11 Ekim 2026` inside a month, `28 Eylül–4 Ekim 2026` across months,
  /// `30 Aralık 2026–5 Ocak 2027` across years, `10 Ekim 2026` for one day.
  /// [withYear] false leaves the year out inside one year (`12–17 Ekim`, the
  /// band of pano 3.5 kare 1).
  static String format(DateTime first, DateTime last, {bool withYear = true}) {
    final a = CalendarMath.dateOnly(first);
    final b = CalendarMath.dateOnly(last);
    final monthA = TrFormat.months[a.month - 1];
    final monthB = TrFormat.months[b.month - 1];
    final year = withYear ? ' ${a.year}' : '';
    if (CalendarMath.sameDay(a, b)) return '${a.day} $monthA$year';
    if (a.year == b.year && a.month == b.month) {
      return '${a.day}–${b.day} $monthA$year';
    }
    if (a.year == b.year) {
      return '${a.day} $monthA–${b.day} $monthB$year';
    }
    return '${a.day} $monthA ${a.year}–${b.day} $monthB ${b.year}';
  }
}

/// The default name of a new program (pano 3.5 kare 4 "Ekim 3. Hafta"): the
/// month and the number of the week inside it. Week 1 is the week that holds
/// the 1st (so 5 Ekim 2026, a Monday, starts "Ekim 2. Hafta"; spec §6.1 6.1).
abstract final class ProgramNaming {
  /// The month name and the week number of [day].
  static ({String month, int week}) weekOfMonth(DateTime day) {
    final blanks = CalendarMath.leadingBlanks(day);
    return (
      month: TrFormat.months[day.month - 1],
      week: (day.day + blanks - 1) ~/ 7 + 1,
    );
  }
}
