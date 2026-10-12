/// What the system says about notifications for this app (pano 9.6 kare 2).
enum NotificationPermissionStatus {
  /// Allowed (also provisional and limited).
  granted,

  /// Not allowed: never asked, or asked and left open.
  denied,

  /// Refused for good, or forbidden by the device: only the system settings
  /// can change it.
  blocked,
}

/// The notification permission behind a seam, so the ViewModel stays testable
/// (`permission_handler` in the app, a fake in tests).
abstract interface class NotificationPermission {
  /// The current state, without asking (the question is asked once, after the
  /// first successful read: D-23).
  Future<NotificationPermissionStatus> status();

  /// Opens the app's page in the system settings ("Ayarları Aç").
  Future<void> openSettings();
}

/// Pure reading of the permission for "Bildirimler", unit-tested.
abstract final class NotificationPermissionRules {
  /// Whether the "Bildirim izni kapalı" warning replaces the info box (pano
  /// 9.6 kare 2).
  ///
  /// `denied` is also what the system answers before the question was ever
  /// asked, and the warning would then point to a settings page that has no
  /// switch for the app yet. So a plain `denied` counts only once the app's
  /// own permission sheet was answered ([primerAnswered]).
  static bool isOff(
    NotificationPermissionStatus status, {
    required bool primerAnswered,
  }) => switch (status) {
    NotificationPermissionStatus.granted => false,
    NotificationPermissionStatus.blocked => true,
    NotificationPermissionStatus.denied => primerAnswered,
  };
}
