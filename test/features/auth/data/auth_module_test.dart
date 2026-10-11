import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/core/services/app_logger.dart';
import 'package:smap/core/services/connectivity_service.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/auth/auth_module.dart';
import 'package:smap/features/auth/data/auth_repository.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';
import 'package:smap/features/auth/data/session/legacy_session_migration.dart';
import 'package:smap/features/auth/data/session/session_store.dart';
import 'package:smap/features/auth/domain/session_state.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smap/services/current_user_service.dart';
import 'package:smap/services/session_manager.dart';

import '../../../core/services/fake_connectivity.dart';
import 'auth_fixtures.dart';

void main() {
  late FakeConnectivity device;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    device = FakeConnectivity();
  });

  tearDown(() async {
    await resetDependencies();
    await device.close();
  });

  Future<void> configure({
    CookieJar? jar,
    List<ModuleRegistration> dataModules = const [],
    List<ModuleRegistration> serviceModules = const [],
  }) => configureDependencies(
    config: AppConfig.resolve(),
    logger: AppLogger.silent(),
    cookieJar: jar ?? CookieJar(),
    connectivity: device,
    dataModules: dataModules,
    serviceModules: serviceModules,
  );

  test('the data and service modules resolve', () async {
    await configure(
      dataModules: [registerAuthData],
      serviceModules: [registerAuthServices],
    );

    expect(locator<AuthRepository>(), isA<AuthRepository>());
    expect(locator<SessionStore>().legacyMirror, kMirrorLegacyUserData);
    expect(locator<LegacySessionMigration>(), isA<LegacySessionMigration>());
    expect(locator<SessionManager>().state, const SessionState.unknown());
    expect(
      locator<SessionManager>(),
      same(locator<SessionManager>()),
      reason: 'one manager in the root scope',
    );
    expect(isSessionScopeActive, isFalse);
    expect(locator.isRegistered<CurrentUserService>(), isFalse);
  });

  test('CurrentUserService lives and dies with the session scope', () async {
    final jar = CookieJar();
    await saveSessionCookie(jar);
    final store = SessionStore(
      storage: FakeSecureStore(),
      retryDelay: Duration.zero,
    );
    await store.write(UserDto.fromJson(studentJson()));
    device.current = [ConnectivityResult.none];

    await configure(
      jar: jar,
      dataModules: [
        (l) => l
          ..registerLazySingleton<AuthRepository>(
            () => AuthRepository(l<NetworkService>()),
          )
          ..registerSingleton<SessionStore>(store),
      ],
      serviceModules: [
        (l) => l.registerSingleton<SessionManager>(
          SessionManager(
            auth: l<AuthRepository>(),
            store: l<SessionStore>(),
            network: l<NetworkService>(),
            connectivity: l<ConnectivityService>(),
            config: l<AppConfig>(),
            // What `kSessionModules` will hold once the coordinator wires it.
            pushScope: () => pushSessionScope(modules: [registerAuthSession]),
          ),
          dispose: (manager) => manager.dispose(),
        ),
      ],
    );
    final manager = locator<SessionManager>();
    expect(locator.isRegistered<CurrentUserService>(), isFalse);

    await manager.restore();

    expect(manager.state.isSignedIn, isTrue);
    expect(isSessionScopeActive, isTrue);
    final service = locator<CurrentUserService>();
    expect(service.user?.id, 'student-1');
    expect(service.role.isStudent, isTrue);

    await manager.signOut();

    expect(manager.state, const SessionState.signedOut());
    expect(isSessionScopeActive, isFalse);
    expect(locator.isRegistered<CurrentUserService>(), isFalse);
  });
}
