/// What the camera primer knows about the camera permission.
enum CameraPermissionState {
  /// Not decided (never asked, or asked and left open): "İzin Ver" asks.
  notAsked,

  /// Granted: the flow goes on.
  granted,

  /// Refused, and the system will not ask again (or the device forbids it):
  /// the primer offers "Ayarları Aç" (pano 4.1 kare 2).
  denied,
}

/// The camera permission, behind a seam so the view model stays testable
/// (`permission_handler` in the app, a fake in tests).
abstract interface class CameraPermission {
  /// The current state, without asking.
  Future<CameraPermissionState> status();

  /// Shows the system dialog; [CameraPermissionState.denied] when refused.
  Future<CameraPermissionState> request();

  /// Opens the app's page in the system settings.
  Future<void> openSettings();
}
