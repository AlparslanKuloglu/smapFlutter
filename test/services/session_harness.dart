import 'package:cookie_jar/cookie_jar.dart';
import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/core/services/connectivity_service.dart';
import 'package:smap/features/auth/data/auth_repository.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';
import 'package:smap/features/auth/data/session/legacy_session_migration.dart';
import 'package:smap/features/auth/data/session/session_store.dart';
import 'package:smap/features/auth/domain/session_state.dart';
import 'package:smap/services/session_manager.dart';

import '../core/services/fake_connectivity.dart';
import '../features/auth/data/auth_fixtures.dart';

/// Everything a [SessionManager] needs, on fakes.
class SessionHarness {
  SessionHarness() {
    network = buildNetwork(backend, jar);
    store = SessionStore(storage: secure, retryDelay: Duration.zero);
    manager = build();
    manager.addListener(() => history.add(manager.state));
  }

  final FakeBackend backend = FakeBackend();
  final CookieJar jar = CookieJar();
  final FakeSecureStore secure = FakeSecureStore();
  final FakeConnectivity device = FakeConnectivity();
  late final ConnectivityService connectivity = ConnectivityService(
    connectivity: device,
  );
  late final NetworkService network;
  late final SessionStore store;
  late SessionManager manager;

  final List<SessionState> history = [];
  int pushes = 0;
  int pops = 0;
  Object? pushError;

  SessionManager build() => SessionManager(
    auth: AuthRepository(network),
    store: store,
    network: network,
    connectivity: connectivity,
    config: AppConfig.resolve(),
    migration: LegacySessionMigration(store: store),
    logoutTimeout: const Duration(milliseconds: 200),
    pushScope: () {
      pushes++;
      final error = pushError;
      if (error != null) throw error;
    },
    popScope: () async => pops++,
  );

  Future<void> goOffline() async {
    backend.online = false;
    device.current = [ConnectivityResult.none];
    await connectivity.refresh();
  }

  /// A device that was signed in on an earlier launch: cookie in the jar,
  /// user in the secure cache, session valid on the server.
  Future<void> leaveSignedInSession({String name = 'Ayşe Yılmaz'}) async {
    backend
      ..user = studentJson(name: name)
      ..startSession();
    await saveSessionCookie(jar);
    await store.write(UserDto.fromJson(studentJson(name: 'Eski Ad')));
  }

  Future<bool> hasCookie() async => (await jar.loadForRequest(
    Uri.parse(AppConfig.defaultApiBaseUrl),
  )).isNotEmpty;

  Future<void> dispose() async {
    manager.dispose();
    network.dispose();
    await device.close();
  }
}
