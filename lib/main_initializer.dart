import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:smap/app/app.dart';
import 'package:smap/app/boot_failure_app.dart';
import 'package:smap/core/bloc/app_bloc_observer.dart';
import 'package:smap/core/network/dio_client.dart';
import 'package:smap/core/services/app_logger.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/startup/application/launch_handover.dart';
import 'package:smap/features/startup/application/startup_timing.dart';
import 'package:smap/features/startup/data/legacy_onboarding_migration.dart';
import 'package:smap/services/session_manager.dart';

/// Starts the app (`main()` calls [run] and nothing else).
///
/// 1. `runZonedGuarded` around everything, so an error that escapes a future
///    is logged and does not end the app; `FlutterError.onError` and
///    `PlatformDispatcher.onError` are routed to the same logger.
/// 2. The native splash (navy, S-route lockup; `flutter_native_splash`) is
///    kept with `preserve`, which also holds the first Flutter frame.
/// 3. `configureDependencies()` (core, data, services), the legacy network
///    client (it shares the cookie jar of the new one), the date formats and
///    the one-time move of the legacy "intro seen" flag.
/// 4. `SessionManager.restore()` starts and `runApp` follows at once: the
///    launch screen (the same picture as the splash) waits for the answer and
///    hands over to the first screen.
/// 5. The native splash comes down when that hand-over happened, or after one
///    second at most, whichever is first; a slower start shows the launch
///    screen with its spinner (pano 2.1 kare 1).
///
/// If step 3 fails the user gets [BootFailureApp] with "Tekrar Dene" instead of
/// a splash that never ends.
abstract final class MainInitializer {
  static final AppLogger _bootLogger = AppLogger();

  /// Runs the whole start-up inside the guarded zone.
  static Future<void> run() async {
    await runZonedGuarded<Future<void>>(_boot, _onZoneError);
  }

  static Future<void> _boot() async {
    final binding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: binding);
    _installErrorHandlers();
    await _start();
  }

  static Future<void> _start() async {
    try {
      await _initialize();
    } on Object catch (error, stackTrace) {
      _bootLogger.error(
        'start-up failed',
        name: 'MainInitializer',
        error: error,
        stackTrace: stackTrace,
      );
      runApp(BootFailureApp(onRetry: _retry));
      FlutterNativeSplash.remove();
      return;
    }

    final handover = locator<LaunchHandover>();
    // Starts the restore; the launch screen awaits the same future.
    unawaited(locator<SessionManager>().restore());
    runApp(const SmapApp());
    await handover.done.timeout(
      StartupTiming.nativeSplashPatience,
      onTimeout: () {},
    );
    FlutterNativeSplash.remove();
  }

  static Future<void> _retry() async {
    await resetDependencies();
    await _start();
  }

  static Future<void> _initialize() async {
    await configureDependencies();
    // The legacy Dio shares NetworkService's cookie jar: after the container.
    await DioClient().init();
    await initializeDateFormatting('tr_TR');
    await initializeDateFormatting('tr');
    Bloc.observer = AppBlocObserver();
    await LegacyOnboardingMigration(
      preferences: locator<DevicePreferences>(),
      logger: locator<AppLogger>(),
    ).run();
  }

  static void _installErrorHandlers() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _bootLogger.error(
        'flutter error',
        name: 'MainInitializer',
        error: details.exception,
        stackTrace: details.stack,
      );
    };
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      _onZoneError(error, stackTrace);
      return true;
    };
  }

  static void _onZoneError(Object error, StackTrace stackTrace) {
    _bootLogger.error(
      'uncaught error',
      name: 'MainInitializer',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
