import 'package:smap/core/utils/tr_format.dart';

/// The net arithmetic of the exams (Ek D-1: "Net = doğru − yanlış ÷ 4").
///
/// The server calculates the net the screens show; these helpers exist for
/// the places that must agree with it (a test's net from its D/Y/B, the sum of
/// the tests, the gallery) and are unit-tested. Four wrong answers cancel one
/// correct answer; a blank has no effect.
abstract final class NetMath {
  /// Wrong answers that cancel one correct answer.
  static const int wrongPerCorrect = 4;

  /// `correct − wrong ÷ 4`. Moves in quarter steps, so the double is exact.
  /// It can be negative (many wrong, few correct).
  static double net(int correct, int wrong) =>
      correct - wrong / wrongPerCorrect;

  /// The blank count of [total] questions with [correct] and [wrong]
  /// answered, never below zero.
  static int blank({
    required int total,
    required int correct,
    required int wrong,
  }) {
    final rest = total - correct - wrong;
    return rest < 0 ? 0 : rest;
  }

  /// The net written for the screen: `67,5`, `74,75`, `68`, `−2,5`
  /// (`TrFormat.net`).
  static String format(double net) => TrFormat.net(net);
}
