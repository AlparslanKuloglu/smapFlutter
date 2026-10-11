import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/network/base_request.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/core/services/app_logger.dart';
import 'package:smap/core/services/connectivity_service.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/dependency_injection/injection_container.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../core/services/fake_connectivity.dart';

class _Probe {
  _Probe(this.name);
  final String name;
  bool disposed = false;
}

class _Always401 implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString('{}', 401);

  @override
  void close({bool force = false}) {}
}

BaseRequest<Object?> _request() => BaseRequest<Object?>(
  method: HttpMethod.get,
  path: '/student/me',
  decoder: (data) => data,
);

void main() {
  late FakeConnectivity plugin;

  Future<void> configure({
    List<ModuleRegistration> dataModules = const [],
    List<ModuleRegistration> serviceModules = const [],
    AppConfig? config,
  }) => configureDependencies(
    config: config ?? AppConfig.resolve(),
    logger: AppLogger.silent(),
    cookieJar: CookieJar(),
    connectivity: plugin,
    dataModules: dataModules,
    serviceModules: serviceModules,
  );

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    plugin = FakeConnectivity();
  });

  tearDown(() async {
    await resetDependencies();
    await plugin.close();
  });

  group('root scope', () {
    test('every core registration resolves', () async {
      await configure();

      expect(locator<AppLogger>(), isA<AppLogger>());
      expect(locator<AppConfig>().apiBaseUrl, 'https://www.smaptr.com');
      expect(locator<DevicePreferences>(), isA<DevicePreferences>());
      expect(locator<ConnectivityService>(), isA<ConnectivityService>());
      expect(locator<NetworkService>(), isA<NetworkService>());
    });

    test('registrations are singletons', () async {
      await configure();

      expect(locator<NetworkService>(), same(locator<NetworkService>()));
      expect(locator<AppConfig>(), same(locator<AppConfig>()));
    });

    test(
      'the network service is wired to the config and the connectivity service',
      () async {
        await configure(
          config: AppConfig.resolve(apiBaseUrl: 'https://api.example.com'),
        );

        expect(
          locator<NetworkService>().dio.options.baseUrl,
          'https://api.example.com',
        );
      },
    );

    test('the connectivity service is started', () async {
      await configure();

      expect(locator<ConnectivityService>().results, isNotNull);
    });

    test('a second configure is a no-op', () async {
      await configure();
      final first = locator<NetworkService>();

      await configure(
        config: AppConfig.resolve(apiBaseUrl: 'https://other.test'),
      );

      expect(locator<NetworkService>(), same(first));
      expect(locator<AppConfig>().apiBaseUrl, 'https://www.smaptr.com');
    });

    test('reset disposes the services and allows configuring again', () async {
      await configure();
      final connectivity = locator<ConnectivityService>();

      await resetDependencies();

      expect(locator.isRegistered<AppConfig>(), isFalse);
      // A disposed ConnectivityService ignores further updates.
      plugin.emit(const [ConnectivityResult.none]);
      await Future<void>.delayed(Duration.zero);
      expect(connectivity.isOnline, isTrue);

      await configure();
      expect(locator.isRegistered<NetworkService>(), isTrue);
    });
  });

  group('phases and modules', () {
    test('core, then data modules, then service modules', () async {
      final order = <String>[];
      await configure(
        dataModules: [
          (l) {
            expect(
              l.isRegistered<NetworkService>(),
              isTrue,
              reason: 'core is ready first',
            );
            order.add('data');
            l.registerLazySingleton<_Probe>(() => _Probe('data'));
          },
        ],
        serviceModules: [
          (l) {
            expect(
              l.isRegistered<_Probe>(),
              isTrue,
              reason: 'data is ready before services',
            );
            order.add('services');
          },
        ],
      );

      expect(order, ['data', 'services']);
      expect(locator<_Probe>().name, 'data');
    });

    test('a module can resolve core services lazily', () async {
      await configure(
        dataModules: [
          (l) => l.registerLazySingleton<_Probe>(
            () => _Probe(l<AppConfig>().playPackage),
          ),
        ],
      );

      expect(locator<_Probe>().name, 'com.smap.smap');
    });

    test('the shipped module lists are well formed', () {
      expect(kDataModules, isA<List<ModuleRegistration>>());
      expect(kServiceModules, isA<List<ModuleRegistration>>());
      expect(kSessionModules, isA<List<ModuleRegistration>>());
    });
  });

  group('session scope', () {
    test('is not active until pushed', () async {
      await configure();

      expect(isSessionScopeActive, isFalse);
      expect(locator.currentScopeName, isNot(kSessionScope));
    });

    test(
      'push runs the session modules, pop disposes what they registered',
      () async {
        await configure();
        final probes = <_Probe>[];

        pushSessionScope(
          modules: [
            (l) => l.registerLazySingleton<_Probe>(
              () => _Probe('session'),
              dispose: (p) => p.disposed = true,
            ),
          ],
        );
        expect(isSessionScopeActive, isTrue);
        final probe = locator<_Probe>();
        probes.add(probe);
        expect(probe.name, 'session');
        // Root services stay reachable inside the scope.
        expect(locator<NetworkService>(), isNotNull);

        await popSessionScope();

        expect(isSessionScopeActive, isFalse);
        expect(probes.single.disposed, isTrue);
        expect(locator.isRegistered<_Probe>(), isFalse);
        expect(locator<NetworkService>(), isNotNull);
      },
    );

    test('a new session gets a fresh instance', () async {
      await configure();
      void module(GetIt l) => l.registerLazySingleton<_Probe>(
        () => _Probe('p'),
        dispose: (p) => p.disposed = true,
      );

      pushSessionScope(modules: [module]);
      final first = locator<_Probe>();
      await popSessionScope();
      pushSessionScope(modules: [module]);

      expect(locator<_Probe>(), isNot(same(first)));
      expect(first.disposed, isTrue);
    });

    test('push is idempotent', () async {
      await configure();
      var runs = 0;
      void module(GetIt l) => runs++;

      pushSessionScope(modules: [module]);
      pushSessionScope(modules: [module]);

      expect(runs, 1);
      await popSessionScope();
      expect(isSessionScopeActive, isFalse);
    });

    test('pop without a session does nothing', () async {
      await configure();

      await popSessionScope();

      expect(locator.isRegistered<NetworkService>(), isTrue);
    });

    test('pushing a session re-arms the session-expired stream', () async {
      await configure();
      final network = locator<NetworkService>();
      // Latch the stream as if a 401 had been reported.
      network.dio.httpClientAdapter = _Always401();
      var events = 0;
      network.onSessionExpired.listen((_) => events++);
      final request = _request();

      await network.send(request);
      await network.send(request);
      expect(events, 1);

      pushSessionScope(modules: const []);
      await network.send(request);

      expect(events, 2);
    });

    test(
      'works before configureDependencies as a harmless no-op pair',
      () async {
        expect(isSessionScopeActive, isFalse);

        await popSessionScope();

        expect(isSessionScopeActive, isFalse);
      },
    );
  });
}
