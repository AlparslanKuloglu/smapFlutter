import 'package:flutter/material.dart';

/// Motion scale (handoff 11.12 "Hareket", 11.15; spec §1.13).
///
/// Durations and curves of every animation come from here, never from
/// inline `Duration(...)`. Under "reduce motion" slides turn into a 150 ms
/// opacity fade ([reducedFade]); pass it to `context.motion(..., reduced:)`.
abstract final class AppMotion {
  /// `duration-instant` 100 ms: pressed state (color and 0.98 scale).
  static const Duration instant = Duration(milliseconds: 100);

  /// `duration-fast` 150 ms: switch, chip, checkbox, icon Regular to Fill;
  /// the opacity fade under reduce motion.
  static const Duration fast = Duration(milliseconds: 150);

  /// `duration-base` 250 ms: segment thumb, indicator, accordion, toast,
  /// add/remove.
  static const Duration base = Duration(milliseconds: 250);

  /// `duration-slow` 350 ms: sheet open, page transition, scroll to the first
  /// missing item.
  static const Duration slow = Duration(milliseconds: 350);

  /// `duration-loop` 1200 ms: one turn of the skeleton shimmer.
  static const Duration loop = Duration(milliseconds: 1200);

  /// Sheet close: 250 ms, about 70% of the opening (spec 11.15).
  static const Duration sheetClose = Duration(milliseconds: 250);

  /// The cross-fade that replaces slides and scales under reduce motion.
  static const Duration reducedFade = fast;

  /// `ease-standard` `Cubic(0.2, 0, 0, 1)`: change in place (segment,
  /// indicator, accordion).
  static const Curve standard = Cubic(0.2, 0, 0, 1);

  /// `ease-enter` `Cubic(0, 0, 0, 1)`: an element entering (sheet, toast).
  static const Curve enter = Cubic(0, 0, 0, 1);

  /// `ease-exit` `Cubic(0.3, 0, 1, 1)`: an element leaving; its duration is
  /// 70% of the entrance ([exitOf]).
  static const Curve exit = Cubic(0.3, 0, 1, 1);

  /// `linear`: skeleton shimmer, upload percentage, scroll-linked shrink.
  static const Curve linear = Curves.linear;

  /// The duration of an exit for an entrance of [entrance]: 70%.
  static Duration exitOf(Duration entrance) => entrance * 0.7;

  /// Pressed button scale.
  static const double pressedScale = 0.98;

  /// Camera shutter scale on press (no scale under reduce motion).
  static const double shutterScale = 0.92;

  /// Sheet drag: closes when dragged past this fraction of its height.
  static const double sheetDismissFraction = 0.25;

  /// Sheet drag: closes on a fling faster than this, in px/s (the design
  /// leaves the threshold open; 700 is the spec decision).
  static const double sheetFlingVelocity = 700;

  /// Card swipe: commits past this fraction of the width.
  static const double swipeCommitFraction = 0.30;

  /// Card swipe: commits on a fling faster than this, in px/s.
  static const double swipeCommitVelocity = 800;

  /// Code-box shake amplitude, in pt (the design leaves it open; spec
  /// decision), and the number of oscillations. Duration is [fast].
  static const double shakeAmplitude = 6;
  static const int shakeCycles = 3;
}

/// Product timings that are not part of the motion scale (UI guide §4.5,
/// spec §1.13).
abstract final class SmapDurations {
  /// A plain informational toast stays this long.
  static const Duration toast = Duration(seconds: 4);

  /// A toast with a "Geri Al" action stays this long.
  static const Duration undoToast = Duration(seconds: 6);

  /// A skeleton that has no data after this long becomes an error state;
  /// there is no endless skeleton.
  static const Duration skeletonTimeout = Duration(seconds: 15);

  /// "Bağlandın" stays this long after the connection returns.
  static const Duration connectedNotice = Duration(seconds: 2);

  /// Resend the sign-up / reset code after this long.
  static const Duration codeResend = Duration(seconds: 30);

  /// Photo upload timeout (spec 2.6).
  static const Duration submitTimeout = Duration(seconds: 60);

  /// Optical read reply timeout (spec 2.6).
  static const Duration readTimeout = Duration(seconds: 30);

  /// Program and student/meeting search debounce.
  static const Duration searchDebounce = Duration(milliseconds: 150);

  /// Username availability check debounce (the request is cancellable).
  static const Duration usernameDebounce = Duration(milliseconds: 400);

  /// Rows of "Günü Sıfırla" fade out this far apart.
  static const Duration resetDayStagger = Duration(milliseconds: 150);
}

/// Reduce-motion access on a [BuildContext].
extension MotionContext on BuildContext {
  /// The platform "Reduce motion" setting (`MediaQuery.disableAnimations`).
  bool get reduceMotion => MediaQuery.disableAnimationsOf(this);

  /// [duration], or [reduced] when reduce motion is on.
  ///
  /// [reduced] is required on purpose (Düzeltmeler #18): the Sepello helper
  /// defaulted to `Duration.zero`, which turns an opacity fade into a jump.
  /// A slide or scale passes `AppMotion.reducedFade` (150 ms fade); a change
  /// that must be instant passes `Duration.zero`.
  Duration motion(Duration duration, {required Duration reduced}) =>
      reduceMotion ? reduced : duration;
}
