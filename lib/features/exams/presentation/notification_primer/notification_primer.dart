import 'package:smap/core/services/device_preferences.dart';

/// The "was it asked already" flag of the notification permission sheet, kept
/// behind a seam so the rule below can be tested without a device store.
abstract interface class NotificationPrimerFlag {
  /// The sheet was shown before (answered or dismissed).
  bool get shown;

  /// Remembers that the sheet was shown, so it is never offered again.
  Future<void> markShown();
}

/// [NotificationPrimerFlag] on the device preferences: the key
/// `DevicePreferences.notificationPrimerAnsweredKey` (the spec's
/// `notif_primer_shown`, pano 5.2 "Bayrak").
class PreferencesNotificationPrimerFlag implements NotificationPrimerFlag {
  const PreferencesNotificationPrimerFlag(this._preferences);

  final DevicePreferences _preferences;

  @override
  bool get shown =>
      _preferences.getBool(DevicePreferences.notificationPrimerAnsweredKey) ??
      false;

  @override
  Future<void> markShown() => _preferences.setBool(
    DevicePreferences.notificationPrimerAnsweredKey,
    true,
  );
}

/// Shows the sheet; completes when the sheet has closed. A seam so the rule
/// can be tested without a screen (`SheetNotificationPrimerPresenter` in the
/// app).
abstract interface class NotificationPrimerPresenter {
  Future<void> show();
}

/// The rule of the notification permission sheet (pano 5.2 "Ne zaman"; Ek
/// D-23; spec T2.17): it is offered **once**, on the first successful read,
/// when the student leaves the result moment ("Anasayfa", "Detaylı Analiz" or
/// the cards row), and **only while notifications are enabled**
/// (`FeatureFlags.notificationsEnabled`; closed until the backend sends
/// push). "Sonra" and a dismissed sheet both count as an answer: the flag is
/// written before the sheet opens, so even a killed app never asks twice. The
/// permission is then switched in Hesap › Bildirimler.
///
/// [offer] completes after the sheet has closed (the caller then goes on to
/// its destination: "Seçimden sonra hedef ekrana gidilir").
class NotificationPrimer {
  const NotificationPrimer({
    required this.enabled,
    required NotificationPrimerFlag flag,
    required NotificationPrimerPresenter presenter,
  }) : _flag = flag,
       _presenter = presenter;

  /// `FeatureFlags.notificationsEnabled`.
  final bool enabled;

  final NotificationPrimerFlag _flag;
  final NotificationPrimerPresenter _presenter;

  /// Whether the sheet would open now.
  bool get isDue => enabled && !_flag.shown;

  /// Offers the sheet when it is due. Returns whether it was shown.
  Future<bool> offer() async {
    if (!isDue) return false;
    await _flag.markShown();
    await _presenter.show();
    return true;
  }
}
