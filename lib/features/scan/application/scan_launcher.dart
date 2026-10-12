import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/onboarding/application/camera_permission.dart';

/// What the gate in front of the camera decided (pano 4.1, 4.10 kare 2).
enum ScanGate {
  /// The reading service is off ("okuma açık" flag): the information sheet
  /// "Optik okuma şu an kapalı", and the camera does not open.
  closed,

  /// The camera is allowed: the scan opens.
  open,

  /// The permission was never asked and the primer was never shown: the
  /// primer sheet comes first (pano 4.1 kare 1).
  askPermission,

  /// The permission was never asked but the primer was shown before ("Sonra"):
  /// the system dialog comes straight away.
  requestPermission,

  /// The permission is refused: "Kamera izni kapalı" (pano 4.1 kare 2).
  denied,
}

/// The decision of the gate as a pure function of what it knows.
ScanGate decideScanGate({
  required bool readingEnabled,
  required CameraPermissionState permission,
  required bool primerAnswered,
}) {
  if (!readingEnabled) return ScanGate.closed;
  return switch (permission) {
    CameraPermissionState.granted => ScanGate.open,
    CameraPermissionState.denied => ScanGate.denied,
    CameraPermissionState.notAsked =>
      primerAnswered ? ScanGate.requestPermission : ScanGate.askPermission,
  };
}

/// How the permission primer was answered.
enum PrimerAnswer {
  /// "Kameraya İzin Ver".
  allow,

  /// "Sonra" (or the sheet was dismissed).
  later,
}

/// The sheets the gate shows, behind a seam so the gate is testable.
abstract interface class ScanGateSheets {
  /// 4.1 kare 1: the primer. `null` when it was dismissed.
  Future<PrimerAnswer?> askPrimer();

  /// 4.1 kare 2: the refused permission. `true` for "Ayarları Aç".
  Future<bool> askOpenSettings();

  /// 4.10 kare 2: the reading is off ("Tamam").
  Future<void> showClosed();
}

/// Opens the scan and waits for the app to come back from the settings.
abstract interface class ScanGateExits {
  /// Opens the scan (the camera flow).
  Future<void> openScan();

  /// Completes when the app is in front again after the system settings.
  Future<void> waitForResume();
}

/// The gate in front of the camera: what happens when the student taps "Okut"
/// (pano 4.1 and 4.10 kare 2; flow 13.4; spec §3.6 "Okut: izin yoksa 4.1
/// sheet; bakımdaysa 4.10-2 sheet; değilse push('/scan')").
///
/// The sheets open over the screen the student is on, before the camera
/// screen exists, so the primer and the maintenance note sit on Anasayfa as in
/// the boards. The primer is shown once: after it was answered the system
/// dialog is asked for directly.
class ScanLauncher {
  ScanLauncher({
    required CameraPermission permission,
    required DevicePreferences preferences,
    required ScanGateSheets sheets,
    required ScanGateExits exits,
    required bool readingEnabled,
  }) : _permission = permission,
       _preferences = preferences,
       _sheets = sheets,
       _exits = exits,
       _readingEnabled = readingEnabled;

  final CameraPermission _permission;
  final DevicePreferences _preferences;
  final ScanGateSheets _sheets;
  final ScanGateExits _exits;
  final bool _readingEnabled;

  bool get _primerAnswered =>
      _preferences.getBool(DevicePreferences.cameraPrimerAnsweredKey) ?? false;

  /// Runs the gate. Completes with `true` when the scan was opened.
  Future<bool> start() async {
    var status = await _permission.status();
    final gate = decideScanGate(
      readingEnabled: _readingEnabled,
      permission: status,
      primerAnswered: _primerAnswered,
    );
    switch (gate) {
      case ScanGate.closed:
        await _sheets.showClosed();
        return false;
      case ScanGate.open:
        return _open();
      case ScanGate.askPermission:
        final answer = await _sheets.askPrimer();
        if (answer != null) {
          await _preferences.setBool(
            DevicePreferences.cameraPrimerAnsweredKey,
            true,
          );
        }
        if (answer != PrimerAnswer.allow) return false;
        status = await _permission.request();
      case ScanGate.requestPermission:
        status = await _permission.request();
      case ScanGate.denied:
        break;
    }
    if (status == CameraPermissionState.granted) return _open();
    return _deniedPath();
  }

  Future<bool> _open() async {
    await _exits.openScan();
    return true;
  }

  Future<bool> _deniedPath() async {
    if (!await _sheets.askOpenSettings()) return false;
    await _permission.openSettings();
    await _exits.waitForResume();
    final status = await _permission.status();
    return status == CameraPermissionState.granted ? _open() : false;
  }
}

/// The longest the gate waits for the student to come back from the system
/// settings; past it the permission is checked anyway.
const Duration kSettingsWaitLimit = Duration(minutes: 5);
