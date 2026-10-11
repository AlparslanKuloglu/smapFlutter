import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/app/router/guards/route_access.dart';
import 'package:smap/app/shell/shell_preview.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/auth/domain/session_state.dart';
import 'package:smap/features/startup/application/launch_handover.dart';
import 'package:smap/features/startup/application/startup_gate.dart';
import 'package:smap/features/startup/application/startup_timing.dart';
import 'package:smap/services/session_manager.dart';

/// The launch screen's logic (pano 2.1 kare 1).
///
/// Waits for `SessionManager.restore()` (already running; the native splash
/// holds the first frame for up to [StartupTiming.nativeSplashPatience]),
/// asks the [StartupGate], and replaces the stack with where the app opens:
/// a stop screen, the intro, the welcome screen or the shell of the signed-in
/// role. After [StartupTiming.spinnerDelay] without an answer it raises
/// [showSpinner].
class StartupViewModel extends BaseViewModel {
  StartupViewModel({
    required AppRouter router,
    required SessionManager session,
    required DevicePreferences preferences,
    required StartupGate gate,
    required LaunchHandover handover,
  }) : _router = router,
       _session = session,
       _preferences = preferences,
       _gate = gate,
       _handover = handover;

  final AppRouter _router;
  final SessionManager _session;
  final DevicePreferences _preferences;
  final StartupGate _gate;
  final LaunchHandover _handover;

  final ValueNotifier<bool> _showSpinner = ValueNotifier<bool>(false);
  Timer? _spinnerTimer;
  bool _disposed = false;
  bool _started = false;

  /// `true` once opening has taken longer than a second.
  ValueListenable<bool> get showSpinner => _showSpinner;

  /// Decides and navigates; runs once.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    _spinnerTimer = Timer(StartupTiming.spinnerDelay, () {
      if (!_disposed) _showSpinner.value = true;
    });
    try {
      // Debug only: `--dart-define=SHELL_PREVIEW=student|coach` opens a shell
      // without an account (see `ShellPreview`).
      final preview = ShellPreview.role;
      if (preview != null) {
        await _router.replaceAll([_router.pageFor(targetForRole(preview))]);
        return;
      }
      await _session.restore();
      final block = await _gate.check();
      if (_disposed) return;
      final target = targetFor(
        block: block,
        onboardingSeen:
            _preferences.getBool(DevicePreferences.onboardingCompletedKey) ??
            false,
        session: _session.state,
      );
      await _router.replaceAll([_router.pageFor(target)]);
    } finally {
      _handover.complete();
    }
  }

  /// Where the app opens: a stop screen first (forced update, then
  /// maintenance), then the launch target of the session.
  static RouteTarget targetFor({
    required StartupBlock block,
    required bool onboardingSeen,
    required SessionState session,
  }) => switch (block) {
    StartupBlock.forceUpdate => RouteTarget.forceUpdate,
    StartupBlock.maintenance => RouteTarget.maintenance,
    StartupBlock.none => resolveLaunchTarget(
      onboardingSeen: onboardingSeen,
      session: session,
    ),
  };

  @override
  void dispose() {
    _disposed = true;
    _handover.complete();
    _spinnerTimer?.cancel();
    _showSpinner.dispose();
    super.dispose();
  }
}
