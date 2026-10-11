import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Haptics for moments with an outcome only (handoff 11.15; spec §1.13):
/// exactly four calls, nothing on scroll, press, accordion, sheet, shrinking
/// bar, skeleton or page transition.
///
/// | call | when |
/// |---|---|
/// | [selection] | a choice changed: segment, tab, bottom bar, chip, switch, checkbox, radio, option, corner snap, add/remove a program block |
/// | [medium] | the shutter (and the camera button) |
/// | [success] | result ready (once), request received, answers confirmed, "Öğrendim" |
/// | [error] | send or read failed, form validation, wrong code, camera failed, an error toast |
///
/// [selection] and [medium] are Flutter's `HapticFeedback`. [success] and
/// [error] are notification feedback, which Flutter does not have, so they
/// go through the `smap/haptics` method channel: iOS
/// `UINotificationFeedbackGenerator` (`AppDelegate.swift`), Android
/// `HapticFeedbackConstants.CONFIRM` / `REJECT` with a fallback below API 30
/// (`MainActivity.kt`).
///
/// Every call is fire-and-forget and best effort: no `await` at the call
/// site, and a missing channel (tests, desktop) or a device with haptics
/// switched off does nothing and throws nothing. The system haptics setting
/// silences them natively (Android returns false; iOS plays nothing).
///
/// Reduce motion does not silence haptics: spec §1.13 says "haptikler
/// değişmez". If product wants that anyway, set [enabled] to false from the
/// place that reads `MediaQuery.disableAnimations` (the app shell).
abstract final class AppHaptics {
  /// Channel shared with `AppDelegate.swift` and `MainActivity.kt`.
  @visibleForTesting
  static const MethodChannel channel = MethodChannel('smap/haptics');

  /// Master switch. When false every call is a silent no-op.
  static bool enabled = true;

  /// A choice changed.
  static void selection() => _impact(HapticFeedback.selectionClick);

  /// The shutter.
  static void medium() => _impact(HapticFeedback.mediumImpact);

  /// Something succeeded.
  static void success() => _notify('success');

  /// Something failed.
  static void error() => _notify('error');

  static void _impact(Future<void> Function() play) {
    if (!enabled) return;
    unawaited(_guard(play));
  }

  static void _notify(String type) {
    if (!enabled) return;
    unawaited(_guard(() => channel.invokeMethod<void>(type)));
  }

  static Future<void> _guard(Future<void> Function() play) async {
    try {
      await play();
    } on Object {
      // Best effort: a missing plugin or a platform without haptics is not
      // an error the user should see.
    }
  }
}
