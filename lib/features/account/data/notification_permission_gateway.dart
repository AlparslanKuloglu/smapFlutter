import 'package:permission_handler/permission_handler.dart';

import 'package:smap/features/account/application/notification_permission.dart';

/// [NotificationPermission] on `permission_handler`
/// (`Permission.notification`).
class PermissionHandlerNotificationPermission
    implements NotificationPermission {
  const PermissionHandlerNotificationPermission();

  @override
  Future<NotificationPermissionStatus> status() async =>
      statusOf(await Permission.notification.status);

  @override
  Future<void> openSettings() async {
    await openAppSettings();
  }

  /// Granted, provisional and limited allow notifications; permanently denied
  /// and restricted are off for good; a plain denied can still be asked.
  static NotificationPermissionStatus statusOf(PermissionStatus status) =>
      switch (status) {
        PermissionStatus.granted ||
        PermissionStatus.provisional ||
        PermissionStatus.limited => NotificationPermissionStatus.granted,
        PermissionStatus.permanentlyDenied ||
        PermissionStatus.restricted => NotificationPermissionStatus.blocked,
        PermissionStatus.denied => NotificationPermissionStatus.denied,
      };
}
