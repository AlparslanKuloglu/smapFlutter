import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/features/startup/application/startup_gate.dart';

/// "SMAP şu an bakımda": asks the gate again, on "Tekrar Dene" and each time
/// the app comes back to the front, and goes back to the launch screen once
/// the block is gone ("öne gelince kendiliğinden dener", pano 2.7 kare 3).
class MaintenanceViewModel extends BaseViewModel with WidgetsBindingObserver {
  MaintenanceViewModel({required AppRouter router, required StartupGate gate})
    : _router = router,
      _gate = gate;

  final AppRouter _router;
  final StartupGate _gate;

  final ValueNotifier<bool> _checking = ValueNotifier<bool>(false);
  bool _disposed = false;

  /// `true` while the gate is being asked (the button shows its spinner).
  ValueListenable<bool> get checking => _checking;

  /// Starts watching the app lifecycle; call it once the view is ready.
  void attach() => WidgetsBinding.instance.addObserver(this);

  /// Asks the gate; opens the launch screen when maintenance is over.
  Future<void> retry() async {
    if (_checking.value) return;
    _checking.value = true;
    try {
      final block = await _gate.check();
      if (_disposed || block == StartupBlock.maintenance) return;
      await _router.replaceAll([const StartupRoute()]);
    } finally {
      if (!_disposed) _checking.value = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) retry().ignore();
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _checking.dispose();
    super.dispose();
  }
}
