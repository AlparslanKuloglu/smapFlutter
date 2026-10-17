import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/core/config/feature_flags.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/onboarding/application/camera_permission.dart';
import 'package:smap/features/scan/application/scan_launcher.dart';
import 'package:smap/features/scan/presentation/permission/camera_denied_sheet.dart';
import 'package:smap/features/scan/presentation/permission/camera_primer_sheet.dart';
import 'package:smap/features/scan/presentation/scan_error/omr_closed_sheet.dart';

/// The door to the scan: what "Okut" calls (spec §3.6 "Okut: izin yoksa 4.1
/// sheet; bakımdaysa 4.10-2 sheet; değilse push('/scan')"; flow 13.4).
///
/// ```dart
/// await ScanEntry.start(router);
/// ```
///
/// It runs the gate over the screen the student is on (the permission primer,
/// the refused-permission sheet, the maintenance note; `ScanLauncher`) and, when
/// the camera is allowed, pushes the scan (`ScanFlowRoute`) on the root stack.
/// Completes with whether the scan was opened.
abstract final class ScanEntry {
  /// Runs the gate and opens the scan.
  static Future<bool> start(StackRouter router) => ScanLauncher(
    permission: locator<CameraPermission>(),
    preferences: locator<DevicePreferences>(),
    sheets: const SheetScanGateSheets(),
    exits: RouterScanGateExits(router),
    readingEnabled: FeatureFlags.omrEnabled,
  ).start();
}

/// [ScanGateSheets] on the app's sheets: they open on the root navigator, over
/// whatever is on screen.
class SheetScanGateSheets implements ScanGateSheets {
  const SheetScanGateSheets();

  @override
  Future<PrimerAnswer?> askPrimer() => CameraPrimerSheet.show();

  @override
  Future<bool> askOpenSettings() => CameraDeniedSheet.show();

  @override
  Future<void> showClosed() => OmrClosedSheet.show();
}

/// [ScanGateExits] on auto_route and the app lifecycle.
class RouterScanGateExits implements ScanGateExits {
  const RouterScanGateExits(this._router);

  final StackRouter _router;

  @override
  Future<void> openScan() => _router.push(const ScanFlowRoute());

  @override
  Future<void> waitForResume() =>
      _ResumeWaiter().wait().timeout(kSettingsWaitLimit, onTimeout: () {});
}

/// Completes when the app comes back to the front after it left (the student
/// went to the system settings to give the camera permission).
class _ResumeWaiter with WidgetsBindingObserver {
  final Completer<void> _done = Completer<void>();
  bool _left = false;

  Future<void> wait() {
    WidgetsBinding.instance.addObserver(this);
    return _done.future.whenComplete(
      () => WidgetsBinding.instance.removeObserver(this),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_left && !_done.isCompleted) _done.complete();
    } else {
      _left = true;
    }
  }
}
