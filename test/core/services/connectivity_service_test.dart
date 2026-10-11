import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/services/connectivity_service.dart';

import 'fake_connectivity.dart';

void main() {
  late FakeConnectivity plugin;
  late ConnectivityService service;

  ConnectivityService build({List<ConnectivityResult>? initial}) {
    plugin = FakeConnectivity(
      initial: initial ?? const [ConnectivityResult.wifi],
    );
    service = ConnectivityService(connectivity: plugin);
    return service;
  }

  tearDown(() async {
    await service.dispose();
    await plugin.close();
  });

  test('reads online before the first check (unknown is online)', () {
    build();

    expect(service.isOnline, isTrue);
    expect(service.results, isNull);
  });

  test('initialize reads the current state', () async {
    build(initial: const [ConnectivityResult.none]);

    await service.initialize();

    expect(service.isOnline, isFalse);
    expect(service.results, const [ConnectivityResult.none]);
  });

  test('follows the plugin stream and emits only changes', () async {
    build();
    await service.initialize();
    final changes = <bool>[];
    service.onlineChanges.listen(changes.add);
    final notified = <bool>[];
    service.online.addListener(() => notified.add(service.isOnline));

    plugin.emit(const [ConnectivityResult.none]);
    plugin.emit(const [ConnectivityResult.none]);
    plugin.emit(const [ConnectivityResult.mobile]);
    plugin.emit(const [ConnectivityResult.wifi, ConnectivityResult.mobile]);
    await Future<void>.delayed(Duration.zero);

    expect(changes, [false, true]);
    expect(notified, [false, true]);
    expect(service.isOnline, isTrue);
  });

  test('an empty reading counts as online', () async {
    build(initial: const []);

    await service.initialize();

    expect(service.isOnline, isTrue);
  });

  test('a failing plugin leaves the service online', () async {
    build();
    plugin.failChecks = true;

    await service.initialize();

    expect(service.isOnline, isTrue);
    expect(service.results, isNull);
  });

  test('initialize twice listens once', () async {
    build();
    await service.initialize();
    await service.initialize();
    final changes = <bool>[];
    service.onlineChanges.listen(changes.add);

    plugin.emit(const [ConnectivityResult.none]);
    await Future<void>.delayed(Duration.zero);

    expect(changes, [false]);
  });

  test('refresh re-reads the plugin', () async {
    build();
    await service.initialize();

    plugin.current = const [ConnectivityResult.none];
    await service.refresh();

    expect(service.isOnline, isFalse);
  });

  group('isNotCellular', () {
    test(
      'true while unknown, on Wi-Fi, ethernet or with a VPN on Wi-Fi',
      () async {
        build();
        expect(service.isNotCellular, isTrue);

        await service.initialize();
        expect(service.isNotCellular, isTrue);

        plugin.current = const [
          ConnectivityResult.mobile,
          ConnectivityResult.wifi,
        ];
        await service.refresh();
        expect(service.isNotCellular, isTrue);
      },
    );

    test('false when cellular is the only link', () async {
      build(initial: const [ConnectivityResult.mobile]);

      await service.initialize();

      expect(service.isNotCellular, isFalse);
    });

    test('true for a VPN-only link', () async {
      build(initial: const [ConnectivityResult.vpn]);

      await service.initialize();

      expect(service.isNotCellular, isTrue);
    });
  });

  test('dispose is safe to call twice and stops updates', () async {
    build();
    await service.initialize();

    await service.dispose();
    await service.dispose();
    plugin.emit(const [ConnectivityResult.none]);
    await Future<void>.delayed(Duration.zero);

    // tearDown disposes again; no error expected.
    expect(service.isOnline, isTrue);
  });
}
