import 'package:permission_handler/permission_handler.dart';

import 'package:smap/features/onboarding/application/camera_permission.dart';

/// [CameraPermission] on `permission_handler` (`Permission.camera`).
class PermissionHandlerCameraPermission implements CameraPermission {
  const PermissionHandlerCameraPermission();

  @override
  Future<CameraPermissionState> status() async =>
      _stateOf(await Permission.camera.status, asked: false);

  @override
  Future<CameraPermissionState> request() async =>
      _stateOf(await Permission.camera.request(), asked: true);

  @override
  Future<void> openSettings() async {
    await openAppSettings();
  }

  /// Granted (or limited) is granted; permanently denied and restricted are
  /// denied for good. A plain "denied" is open before the first question
  /// (`status`, Android reports it for "never asked") and a refusal right
  /// after one (`request`).
  static CameraPermissionState _stateOf(
    PermissionStatus status, {
    required bool asked,
  }) => switch (status) {
    PermissionStatus.granted ||
    PermissionStatus.limited => CameraPermissionState.granted,
    PermissionStatus.permanentlyDenied ||
    PermissionStatus.restricted => CameraPermissionState.denied,
    PermissionStatus.denied || PermissionStatus.provisional =>
      asked ? CameraPermissionState.denied : CameraPermissionState.notAsked,
  };
}
