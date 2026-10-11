import 'package:flutter_test/flutter_test.dart';
import 'package:smap/shared/ui/pickers/calendar_math.dart';

void main() {
  // October 2026 starts on a Thursday and has 31 days; the 5th is a Monday.
  final october = DateTime(2026, 10);

  test('dateOnly drops the time and sameDay compares calendar days', () {
    expect(
      CalendarMath.dateOnly(DateTime(2026, 10, 10, 23, 59)),
      DateTime(2026, 10, 10),
    );
    expect(
      CalendarMath.sameDay(
        DateTime(2026, 10, 10, 1),
        DateTime(2026, 10, 10, 23),
      ),
      isTrue,
    );
    expect(
      CalendarMath.sameDay(DateTime(2026, 10, 10), DateTime(2026, 11, 10)),
      isFalse,
    );
    expect(
      CalendarMath.isBeforeDay(
        DateTime(2026, 10, 9, 23),
        DateTime(2026, 10, 10, 1),
      ),
      isTrue,
    );
    expect(
      CalendarMath.isBeforeDay(
        DateTime(2026, 10, 10, 1),
        DateTime(2026, 10, 10, 23),
      ),
      isFalse,
    );
  });

  test('addDays crosses months and years', () {
    expect(CalendarMath.addDays(DateTime(2026, 10, 31), 1), DateTime(2026, 11));
    expect(CalendarMath.addDays(DateTime(2026, 12, 31), 1), DateTime(2027));
    expect(
      CalendarMath.addDays(DateTime(2026, 3, 1), -1),
      DateTime(2026, 2, 28),
    );
    expect(
      CalendarMath.daysBetween(DateTime(2026, 10, 5), DateTime(2026, 10, 12)),
      7,
    );
    expect(
      CalendarMath.daysBetween(DateTime(2026, 10, 12), DateTime(2026, 10, 5)),
      -7,
    );
  });

  test('daysBetween ignores daylight saving changes', () {
    // Turkey has no DST today, but the arithmetic must not depend on it.
    expect(
      CalendarMath.daysBetween(DateTime(2026, 3, 28), DateTime(2026, 3, 30)),
      2,
    );
    expect(
      CalendarMath.daysBetween(DateTime(2026, 10, 24), DateTime(2026, 10, 26)),
      2,
    );
  });

  test('month helpers', () {
    expect(CalendarMath.monthStart(DateTime(2026, 10, 17)), october);
    expect(
      CalendarMath.addMonths(DateTime(2026, 10, 17), 1),
      DateTime(2026, 11),
    );
    expect(
      CalendarMath.addMonths(DateTime(2026, 1, 31), -1),
      DateTime(2025, 12),
    );
    expect(CalendarMath.daysInMonth(2026, 10), 31);
    expect(CalendarMath.daysInMonth(2028, 2), 29);
    expect(CalendarMath.daysInMonth(2026, 2), 28);
  });

  test('the month grid is Monday first', () {
    expect(CalendarMath.leadingBlanks(october), 3);
    expect(CalendarMath.rowCount(october), 5);
    expect(CalendarMath.cellDay(october, 0, 0), isNull);
    expect(CalendarMath.cellDay(october, 0, 2), isNull);
    expect(CalendarMath.cellDay(october, 0, 3), DateTime(2026, 10, 1));
    expect(CalendarMath.cellDay(october, 1, 0), DateTime(2026, 10, 5));
    expect(CalendarMath.cellDay(october, 4, 5), DateTime(2026, 10, 31));
    expect(CalendarMath.cellDay(october, 4, 6), isNull);
    // February 2027 starts on a Monday and fills four rows exactly.
    expect(CalendarMath.rowCount(DateTime(2027, 2)), 4);
    // A 31-day month starting on Saturday needs six rows (August 2026).
    expect(CalendarMath.rowCount(DateTime(2026, 8)), 6);
  });

  test('weeks run Monday to Sunday', () {
    expect(
      CalendarMath.mondayOf(DateTime(2026, 10, 10)),
      DateTime(2026, 10, 5),
    );
    expect(CalendarMath.mondayOf(DateTime(2026, 10, 5)), DateTime(2026, 10, 5));
    expect(
      CalendarMath.mondayOf(DateTime(2026, 10, 11)),
      DateTime(2026, 10, 5),
    );
    expect(
      CalendarMath.sundayOf(DateTime(2026, 10, 10)),
      DateTime(2026, 10, 11),
    );
    final week = CalendarMath.weekOf(DateTime(2026, 10, 10));
    expect(week.length, 7);
    expect(week.first, DateTime(2026, 10, 5));
    expect(week.last, DateTime(2026, 10, 11));
  });

  test('daysFromTo and sortedUnique', () {
    expect(
      CalendarMath.daysFromTo(DateTime(2026, 10, 30), DateTime(2026, 11, 2)),
      [
        DateTime(2026, 10, 30),
        DateTime(2026, 10, 31),
        DateTime(2026, 11),
        DateTime(2026, 11, 2),
      ],
    );
    expect(
      CalendarMath.daysFromTo(DateTime(2026, 10, 3), DateTime(2026, 10, 2)),
      isEmpty,
    );
    expect(
      CalendarMath.sortedUnique([
        DateTime(2026, 10, 12, 9),
        DateTime(2026, 10, 10),
        DateTime(2026, 10, 12, 18),
      ]),
      [DateTime(2026, 10, 10), DateTime(2026, 10, 12)],
    );
  });
}
