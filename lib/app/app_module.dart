import 'package:get_it/get_it.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/core/services/app_logger.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/services/session_manager.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// Phase 3 (`kServiceModules`): the router and the toast service.
///
/// Both share the router's root navigator key: [ToastService] draws in that
/// navigator's overlay, and `AppSheet.navigatorKey` (set here, once, when the
/// router is first built) lets ViewModels open sheets without a context. The
/// router reads the session from the [SessionManager] registered in the auth
/// module (a lazy factory, so the order inside the phase does not matter).
void registerAppServices(GetIt l) {
  l
    ..registerLazySingleton<AppRouter>(() {
      final router = AppRouter(
        session: () => l<SessionManager>().state,
        preferences: l<DevicePreferences>(),
        logger: l<AppLogger>(),
      );
      AppSheet.navigatorKey = router.navigatorKey;
      return router;
    })
    ..registerLazySingleton<ToastService>(
      () => ToastService.navigator(l<AppRouter>().navigatorKey),
      dispose: (service) => service.dispose(),
    );
}
