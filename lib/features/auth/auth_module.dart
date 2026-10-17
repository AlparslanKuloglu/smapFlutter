import 'package:get_it/get_it.dart';

import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/core/services/app_logger.dart';
import 'package:smap/core/services/connectivity_service.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/auth/data/auth_repository.dart';
import 'package:smap/features/auth/data/session/legacy_session_migration.dart';
import 'package:smap/features/auth/data/session/secure_value_store.dart';
import 'package:smap/features/auth/data/session/session_store.dart';
import 'package:smap/services/current_user_service.dart';
import 'package:smap/services/session_manager.dart';

/// Keeps the legacy plain-text `user_data` in `SharedPreferences` in step with
/// the secure copy. It was on while legacy screens read it; the last legacy
/// reader is gone (FIN2), so it is off and the migration deletes the plain
/// copy on the next launch (`LegacySessionMigration`).
const bool kMirrorLegacyUserData = false;

/// Phase 2 (`kDataModules`): the auth endpoints, the secure user cache and the
/// one-time legacy migration.
void registerAuthData(GetIt l) {
  l
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepository(l<NetworkService>()),
    )
    ..registerLazySingleton<SessionStore>(
      () => SessionStore(
        storage: const FlutterSecureValueStore(),
        logger: l<AppLogger>(),
        legacyMirror: kMirrorLegacyUserData,
      ),
    )
    ..registerLazySingleton<LegacySessionMigration>(
      () => LegacySessionMigration(
        store: l<SessionStore>(),
        logger: l<AppLogger>(),
      ),
    );
}

/// Phase 3 (`kServiceModules`): the [SessionManager], in the root scope. It is
/// created at once, not lazily, because it must already be listening to
/// `NetworkService.onSessionExpired` when the first request fails.
void registerAuthServices(GetIt l) {
  l.registerSingleton<SessionManager>(
    SessionManager(
      auth: l<AuthRepository>(),
      store: l<SessionStore>(),
      network: l<NetworkService>(),
      connectivity: l<ConnectivityService>(),
      config: l<AppConfig>(),
      migration: l<LegacySessionMigration>(),
      logger: l<AppLogger>(),
      forgetAccountData: l<DevicePreferences>().clearAccount,
    ),
    dispose: (manager) => manager.dispose(),
  );
}

/// `kSessionModules`: what lives only while somebody is signed in.
void registerAuthSession(GetIt l) {
  l.registerLazySingleton<CurrentUserService>(
    () => CurrentUserService(session: l<SessionManager>()),
    dispose: (service) => service.dispose(),
  );
}
