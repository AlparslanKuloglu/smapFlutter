import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/onboarding/application/camera_permission.dart';
import 'package:smap/features/scan/application/scan_launcher.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class _Permission implements CameraPermission {
  _Permission(
    this.current, {
    this.afterRequest = CameraPermissionState.granted,
  });

  CameraPermissionState current;
  CameraPermissionState afterRequest;
  CameraPermissionState afterSettings = CameraPermissionState.granted;
  int requests = 0;
  int settings = 0;

  @override
  Future<CameraPermissionState> status() async => current;

  @override
  Future<CameraPermissionState> request() async {
    requests++;
    return current = afterRequest;
  }

  @override
  Future<void> openSettings() async {
    settings++;
    current = afterSettings;
  }
}

class _Sheets implements ScanGateSheets {
  PrimerAnswer? primer = PrimerAnswer.allow;
  bool openSettings = true;
  final List<String> shown = [];

  @override
  Future<PrimerAnswer?> askPrimer() async {
    shown.add('primer');
    return primer;
  }

  @override
  Future<bool> askOpenSettings() async {
    shown.add('denied');
    return openSettings;
  }

  @override
  Future<void> showClosed() async => shown.add('closed');
}

class _Exits implements ScanGateExits {
  int opened = 0;
  int waited = 0;

  @override
  Future<void> openScan() async => opened++;

  @override
  Future<void> waitForResume() async => waited++;
}

Future<DevicePreferences> prefs([Map<String, Object> values = const {}]) async {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData(values);
  return DevicePreferences.load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('decideScanGate', () {
    test('the maintenance flag wins over everything', () {
      for (final permission in CameraPermissionState.values) {
        expect(
          decideScanGate(
            readingEnabled: false,
            permission: permission,
            primerAnswered: true,
          ),
          ScanGate.closed,
        );
      }
    });

    test('a granted camera opens the scan', () {
      expect(
        decideScanGate(
          readingEnabled: true,
          permission: CameraPermissionState.granted,
          primerAnswered: false,
        ),
        ScanGate.open,
      );
    });

    test('the primer comes once, then the system dialog directly', () {
      expect(
        decideScanGate(
          readingEnabled: true,
          permission: CameraPermissionState.notAsked,
          primerAnswered: false,
        ),
        ScanGate.askPermission,
      );
      expect(
        decideScanGate(
          readingEnabled: true,
          permission: CameraPermissionState.notAsked,
          primerAnswered: true,
        ),
        ScanGate.requestPermission,
      );
    });

    test('a refused camera shows the refused sheet', () {
      expect(
        decideScanGate(
          readingEnabled: true,
          permission: CameraPermissionState.denied,
          primerAnswered: true,
        ),
        ScanGate.denied,
      );
    });
  });

  group('ScanLauncher', () {
    late _Sheets sheets;
    late _Exits exits;

    setUp(() {
      sheets = _Sheets();
      exits = _Exits();
    });

    ScanLauncher launcher(
      _Permission permission,
      DevicePreferences preferences, {
      bool enabled = true,
    }) => ScanLauncher(
      permission: permission,
      preferences: preferences,
      sheets: sheets,
      exits: exits,
      readingEnabled: enabled,
    );

    test('opens the scan with no sheet when the camera is allowed', () async {
      final opened = await launcher(
        _Permission(CameraPermissionState.granted),
        await prefs(),
      ).start();
      expect(opened, isTrue);
      expect(exits.opened, 1);
      expect(sheets.shown, isEmpty);
    });

    test('shows the maintenance note and does not open the camera', () async {
      final opened = await launcher(
        _Permission(CameraPermissionState.granted),
        await prefs(),
        enabled: false,
      ).start();
      expect(opened, isFalse);
      expect(sheets.shown, ['closed']);
      expect(exits.opened, 0);
    });

    test(
      'the first tap: primer, then the system dialog, then the scan',
      () async {
        final permission = _Permission(CameraPermissionState.notAsked);
        final preferences = await prefs();
        final opened = await launcher(permission, preferences).start();
        expect(opened, isTrue);
        expect(sheets.shown, ['primer']);
        expect(permission.requests, 1);
        expect(
          preferences.getBool(DevicePreferences.cameraPrimerAnsweredKey),
          isTrue,
        );
      },
    );

    test(
      '"Sonra" stays where it was and the primer is remembered as answered',
      () async {
        sheets.primer = PrimerAnswer.later;
        final permission = _Permission(CameraPermissionState.notAsked);
        final preferences = await prefs();
        expect(await launcher(permission, preferences).start(), isFalse);
        expect(permission.requests, 0);
        expect(exits.opened, 0);
        expect(
          preferences.getBool(DevicePreferences.cameraPrimerAnsweredKey),
          isTrue,
        );
      },
    );

    test('a dismissed primer is not remembered', () async {
      sheets.primer = null;
      final preferences = await prefs();
      await launcher(
        _Permission(CameraPermissionState.notAsked),
        preferences,
      ).start();
      expect(
        preferences.getBool(DevicePreferences.cameraPrimerAnsweredKey),
        isNull,
      );
    });

    test(
      'after the primer was answered the next tap asks the system directly',
      () async {
        final permission = _Permission(CameraPermissionState.notAsked);
        final preferences = await prefs({'scan.cameraPrimerAnswered': true});
        final opened = await launcher(permission, preferences).start();
        expect(opened, isTrue);
        expect(sheets.shown, isEmpty);
        expect(permission.requests, 1);
      },
    );

    test('a refusal at the system dialog shows the refused sheet', () async {
      final permission = _Permission(
        CameraPermissionState.notAsked,
        afterRequest: CameraPermissionState.denied,
      );
      sheets.openSettings = false;
      final opened = await launcher(permission, await prefs()).start();
      expect(opened, isFalse);
      expect(sheets.shown, ['primer', 'denied']);
      expect(permission.settings, 0);
    });

    test(
      '"Ayarları Aç" waits for the way back and opens the scan once allowed',
      () async {
        final permission = _Permission(CameraPermissionState.denied);
        final opened = await launcher(permission, await prefs()).start();
        expect(opened, isTrue);
        expect(sheets.shown, ['denied']);
        expect(permission.settings, 1);
        expect(exits.waited, 1);
        expect(exits.opened, 1);
      },
    );

    test(
      'coming back from the settings still refused does not open the camera',
      () async {
        final permission = _Permission(CameraPermissionState.denied)
          ..afterSettings = CameraPermissionState.denied;
        final opened = await launcher(permission, await prefs()).start();
        expect(opened, isFalse);
        expect(exits.opened, 0);
      },
    );
  });
}
