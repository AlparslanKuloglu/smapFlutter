import 'package:get_it/get_it.dart';

import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/services/app_logger.dart';
import 'package:smap/features/startup/application/launch_handover.dart';
import 'package:smap/features/startup/application/startup_gate.dart';
import 'package:smap/features/startup/application/store_launcher.dart';

/// Phase 3 (`kServiceModules`): the launch gate, the launch hand-over signal
/// and the store opener.
///
/// The gate is closed ([DisabledStartupGate]) until the backend has a public
/// config endpoint (S10).
void registerStartupServices(GetIt l) {
  l
    ..registerLazySingleton<StartupGate>(() => const DisabledStartupGate())
    ..registerLazySingleton<LaunchHandover>(LaunchHandover.new)
    ..registerLazySingleton<StoreLauncher>(
      () => StoreLauncher(config: l<AppConfig>(), logger: l<AppLogger>()),
    );
}
