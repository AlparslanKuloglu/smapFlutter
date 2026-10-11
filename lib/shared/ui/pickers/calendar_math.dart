/// The date arithmetic behind the calendar and the day strips (C62, C65) as
/// pure functions, tested apart from the widgets.
///
/// All dates are calendar days: a `DateTime` of the device's zone whose time
/// part is ignored. Weeks start on Monday (Turkish calendar; `DateTime.monday`
/// is 1). Days are stepped with the `DateTime(y, m, d + n)` constructor, never
/// by adding a `Duration`, so a daylight-saving change cannot move a day.
abstract final class CalendarMath {
  /// [day] at local midnight.
  static DateTime dateOnly(DateTime day) =>
      DateTime(day.year, day.month, day.day);

  /// Whether [a] and [b] are the same calendar day.
  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Whether the calendar day of [a] is before the calendar day of [b].
  static bool isBeforeDay(DateTime a, DateTime b) =>
      dateOnly(a).isBefore(dateOnly(b));

  /// [day] moved by [days] calendar days.
  static DateTime addDays(DateTime day, int days) =>
      DateTime(day.year, day.month, day.day + days);

  /// Calendar days from [from] to [to] (negative when [to] is earlier).
  static int daysBetween(DateTime from, DateTime to) {
    final a = DateTime.utc(from.year, from.month, from.day);
    final b = DateTime.utc(to.year, to.month, to.day);
    return b.difference(a).inDays;
  }

  /// The first day of the month of [day].
  static DateTime monthStart(DateTime day) => DateTime(day.year, day.month);

  /// The first day of the month [delta] months from the month of [day].
  static DateTime addMonths(DateTime day, int delta) =>
      DateTime(day.year, day.month + delta);

  /// How many days the month has.
  static int daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  /// Empty cells before the 1st of the month of [day] in a Monday-first grid
  /// (Monday 0 … Sunday 6).
  static int leadingBlanks(DateTime day) => monthStart(day).weekday - 1;

  /// Rows the month of [day] needs in a Monday-first grid of 7 columns.
  static int rowCount(DateTime day) {
    final cells = leadingBlanks(day) + daysInMonth(day.year, day.month);
    return (cells / 7).ceil();
  }

  /// The day shown in cell ([row], [column]) of the month grid of [month], or
  /// `null` for a blank cell before the 1st or after the last day.
  static DateTime? cellDay(DateTime month, int row, int column) {
    final index = row * 7 + column - leadingBlanks(month);
    if (index < 0 || index >= daysInMonth(month.year, month.month)) return null;
    return DateTime(month.year, month.month, index + 1);
  }

  /// The Monday of the week of [day].
  static DateTime mondayOf(DateTime day) =>
      addDays(dateOnly(day), 1 - day.weekday);

  /// The Sunday of the week of [day].
  static DateTime sundayOf(DateTime day) => addDays(mondayOf(day), 6);

  /// The seven days of the week of [day], Monday first.
  static List<DateTime> weekOf(DateTime day) {
    final monday = mondayOf(day);
    return [for (var i = 0; i < 7; i++) addDays(monday, i)];
  }

  /// Every day from [from] to [to], both included; empty when [to] is
  /// earlier.
  static List<DateTime> daysFromTo(DateTime from, DateTime to) {
    final count = daysBetween(from, to);
    if (count < 0) return const [];
    return [for (var i = 0; i <= count; i++) addDays(from, i)];
  }

  /// [days] without duplicates, as calendar days, oldest first.
  static List<DateTime> sortedUnique(Iterable<DateTime> days) {
    final byKey = <int, DateTime>{};
    for (final day in days) {
      final only = dateOnly(day);
      byKey[only.year * 10000 + only.month * 100 + only.day] = only;
    }
    final keys = byKey.keys.toList()..sort();
    return [for (final key in keys) byKey[key]!];
  }
}
