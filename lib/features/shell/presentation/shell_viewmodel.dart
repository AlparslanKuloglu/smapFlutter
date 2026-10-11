import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/core/services/connectivity_service.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/features/shell/application/shell_bar_policy.dart';

/// The logic of a shell (student or coach; pano 1.19).
///
/// - Keeps `ToastService.bottomBarHeight` in step with the bar: it is set
///   while a shell is the topmost page of the root stack and cleared while a
///   full-screen flow covers it, so a toast sits 8 pt above the bar and falls
///   back to the safe area when the bar is gone.
/// - Opens the camera ("Okut") as a full-screen page on the root router, so
///   the bar disappears by itself. The medium haptic is the camera button's.
///
/// The tab switching itself is the `TabsRouter`'s and lives in the shell view
/// (it needs the widget tree).
class ShellViewModel extends BaseViewModel {
  ShellViewModel({
    required AppRouter router,
    required ToastService toast,
    required ConnectivityService connectivity,
  }) : _router = router,
       _toast = toast,
       _connectivity = connectivity;

  final AppRouter _router;
  final ToastService _toast;
  final ConnectivityService _connectivity;

  /// `true` while the device has a link; drives the offline strip.
  ValueListenable<bool> get online => _connectivity.online;

  /// The two shells: whichever is on top shows its bar.
  static final Set<String> shellRouteNames = {
    StudentShellRoute.name,
    CoachShellRoute.name,
  };

  bool _attached = false;

  /// Starts following the root router; the shell view calls it once.
  void attach() {
    if (_attached) return;
    _attached = true;
    _router.addListener(_onRouter);
    _onRouter();
  }

  void _onRouter() => updateBar(
    _router.stack.map((page) => page.routeData.name).toList(growable: false),
  );

  /// Recomputes the toast offset for the root stack [rootStack] (route names,
  /// bottom to top).
  @visibleForTesting
  void updateBar(List<String> rootStack) {
    _toast.bottomBarHeight.value = ShellBarPolicy.toastBarHeight(
      barVisible: ShellBarPolicy.barVisible(
        rootStack: rootStack,
        shellRouteNames: shellRouteNames,
      ),
    );
  }

  /// "Okut": the full-screen scan flow (today the legacy OMR flow).
  Future<void> openCamera() => _router.push(const LegacyScanRoute());

  @override
  void dispose() {
    if (_attached) {
      _router.removeListener(_onRouter);
      // The stack already changed when a shell is replaced (sign-out, role
      // change): this follows what is on top now, so a new shell that is
      // already up keeps its bar offset.
      _onRouter();
    }
    super.dispose();
  }
}
