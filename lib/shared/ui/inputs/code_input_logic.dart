import 'dart:math' as math;

/// Pure rules of `AppCodeInput` (C11), unit-tested.
abstract final class CodeInputLogic {
  /// The number of boxes.
  static const int length = 6;

  /// Keeps only the digits of [raw] and cuts to [length]: what a paste or a
  /// one-time-code autofill leaves in the six boxes. "271 524" and "271-524"
  /// both become `271524`; an over-long paste keeps its first six digits.
  static String sanitize(String raw, {int length = CodeInputLogic.length}) {
    final digits = raw.replaceAll(RegExp('[^0-9]'), '');
    return digits.length > length ? digits.substring(0, length) : digits;
  }

  /// Index of the box that takes the next digit: the first empty one, or the
  /// last box when the code is complete.
  static int activeIndex(int filled, {int length = CodeInputLogic.length}) =>
      filled >= length ? length - 1 : filled;

  /// Whether [code] is a complete code.
  static bool isComplete(String code, {int length = CodeInputLogic.length}) =>
      code.length == length;

  /// Shake displacement at progress [t] (0 to 1) of an error shake: [cycles]
  /// swings of [amplitude] pt that die out to zero (C11 "Hatada kutular
  /// sallanır").
  static double shakeOffset(
    double t, {
    required double amplitude,
    required int cycles,
  }) {
    final progress = t.clamp(0.0, 1.0);
    return math.sin(progress * 2 * math.pi * cycles) *
        amplitude *
        (1 - progress);
  }
}
