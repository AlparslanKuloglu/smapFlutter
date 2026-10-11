/// The arithmetic of the time wheel as pure functions (C66 "TimeWheel": minutes
/// in 5 steps, hours and minutes loop), tested apart from the widget.
abstract final class TimeWheelMath {
  /// Minute step of the wheel (C66 "dakika 5'er adım").
  static const int minuteStep = 5;

  static const int hoursPerDay = 24;
  static const int minutesPerHour = 60;

  /// The minute values of a wheel with [step]: 0, 5, ... 55.
  static List<int> minutes({int step = minuteStep}) => [
    for (var m = 0; m < minutesPerHour; m += step) m,
  ];

  /// How many minute rows a wheel with [step] has.
  static int minuteCount({int step = minuteStep}) => minutesPerHour ~/ step;

  /// [minute] snapped down to the wheel's step ("22:58" opens on "22:55";
  /// never carried into the next hour). Out-of-range values are clamped to
  /// 0..59 first.
  static int snapMinute(int minute, {int step = minuteStep}) {
    final clamped = minute.clamp(0, minutesPerHour - 1);
    return clamped - clamped % step;
  }

  /// [hour] clamped to 0..23.
  static int clampHour(int hour) => hour.clamp(0, hoursPerDay - 1);

  /// The row index (0-based, looping) for [hour].
  static int hourIndex(int hour) => clampHour(hour);

  /// The row index for [minute] on a wheel with [step].
  static int minuteIndex(int minute, {int step = minuteStep}) =>
      snapMinute(minute, step: step) ~/ step;

  /// The hour a (possibly looped, possibly negative) scroll [index] shows.
  static int hourAt(int index) => _mod(index, hoursPerDay);

  /// The minute a (possibly looped, possibly negative) scroll [index] shows.
  static int minuteAt(int index, {int step = minuteStep}) =>
      _mod(index, minuteCount(step: step)) * step;

  /// One notch up or down for a screen reader's increase / decrease (C66
  /// "yukarı / aşağı 5 dk"): the minute moves by [step], carrying into the
  /// hour; the hour wraps at midnight.
  static ({int hour, int minute}) nudge(
    int hour,
    int minute, {
    required int notches,
    int step = minuteStep,
  }) {
    final total =
        clampHour(hour) * minutesPerHour +
        snapMinute(minute, step: step) +
        notches * step;
    const day = hoursPerDay * minutesPerHour;
    final wrapped = _mod(total, day);
    return (hour: wrapped ~/ minutesPerHour, minute: wrapped % minutesPerHour);
  }

  /// The signed number of hour rows to turn to get from hour [from] to hour
  /// [to] the short way round (23 to 0 is +1, not -23).
  static int shortestHourMove(int from, int to) {
    var move = (to - from) % hoursPerDay;
    if (move > hoursPerDay ~/ 2) move -= hoursPerDay;
    return move;
  }

  static int _mod(int value, int modulus) =>
      ((value % modulus) + modulus) % modulus;
}
