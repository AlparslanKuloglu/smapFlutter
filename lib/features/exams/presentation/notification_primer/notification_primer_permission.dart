import 'package:permission_handler/permission_handler.dart';

/// Asks the system for the notification permission (a seam: the
/// `permission_handler` call in the app, a fake in tests).
abstract interface class NotificationPrimerPermission {
  /// Opens the system dialog and completes when the student has answered. The
  /// answer itself is not needed here: Hesap › Bildirimler reads the state
  /// when it opens.
  Future<void> request();
}

/// [NotificationPrimerPermission] on `permission_handler`
/// (`Permission.notification`). A failure of the platform is swallowed: the
/// sheet closes and the student can switch notifications on in Hesap.
class PermissionHandlerPrimerPermission
    implements NotificationPrimerPermission {
  const PermissionHandlerPrimerPermission();

  @override
  Future<void> request() async {
    try {
      await Permission.notification.request();
    } on Object {
      // Best effort: nothing to show for a failed system call.
    }
  }
}
