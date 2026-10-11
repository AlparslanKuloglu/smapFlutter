/// The YKS countdown of the home band (pano 3.1 kare 1: "252 gün kaldı · YKS
/// · 19 Haziran 2027 Cumartesi"; decision D-21, assumption 6.4): worked out
/// on the device from the clock, so it needs no network, and renewed at
/// midnight. The exam date comes from `AppConfig.yksDate`. Pure and
/// unit-tested.
abstract final class YksCountdown {
  /// Whole calendar days from the day of [now] to the day of [examDate]:
  /// 252 on 10 Oct 2026 for 19 Jun 2027, 0 on the exam day itself.
  ///
  /// `null` once the exam day has passed: the band then draws no counter
  /// (there is no "−3 gün kaldı"). Only the dates count, not the time of day,
  /// and a daylight-saving change cannot move the result (both days are read
  /// as UTC midnights).
  static int? daysLeft(DateTime now, DateTime examDate) {
    final today = DateTime.utc(now.year, now.month, now.day);
    final exam = DateTime.utc(examDate.year, examDate.month, examDate.day);
    final days = exam.difference(today).inDays;
    return days < 0 ? null : days;
  }

  /// How long until the next local midnight after [now]: when the counter
  /// (and "Bugün") must be worked out again. A second past midnight, so the
  /// timer never fires a hair before the date changes.
  static Duration untilNextMidnight(DateTime now) {
    final midnight = DateTime(now.year, now.month, now.day + 1);
    return midnight.difference(now) + const Duration(seconds: 1);
  }
}
