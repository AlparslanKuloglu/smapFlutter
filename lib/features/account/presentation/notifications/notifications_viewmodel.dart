import 'package:stacked/stacked.dart';

import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/account/application/notification_permission.dart';
import 'package:smap/features/account/application/notification_preferences.dart';
import 'package:smap/features/account/data/account_repository.dart';
import 'package:smap/services/current_user_service.dart';
import 'package:smap/features/account/presentation/notifications/notifications_dialogs.dart';

/// What the box at the top of "Bildirimler" says (pano 9.6 kare 1 and 2).
enum NotificationsNotice {
  /// Nothing: the system allows notifications and the backend sends them.
  none,

  /// "Bildirimler planlı: tercihlerin şimdiden kaydedilir, ..." (kare 1).
  planned,

  /// "Bildirim izni kapalı. ..." with "Ayarları Aç" (kare 2).
  permissionOff,
}

/// The logic of "Bildirimler" (pano 9.6 kare 1 to 3; spec §4.C 9.6).
///
/// - **Choices on the device.** The four categories and the quiet hours live
///   in `DevicePreferences` ([NotificationPreferencesStore]) because the
///   backend has no preferences endpoint and no push yet (`FeatureFlags
///   .notificationsEnabled`, spec 8.4). A switch saves at once; there is no
///   Save button. Nothing is sent to a server, so nothing can fail and
///   nothing is rolled back.
/// - **The box.** While the flag is closed the info box says notifications are
///   planned. When the system permission is off it is replaced by the
///   warning with "Ayarları Aç" (kare 2) and the switches are inactive but
///   keep showing the choice. The permission is read when the screen opens
///   and again each time the app comes back to the front ([refreshPermission]).
///   It is never asked for here: that happens after the first successful
///   read (D-23).
/// - **Quiet hours.** "Sessiz saatler" is a switch; when it is off the
///   "Başlangıç" and "Bitiş" rows are not drawn. A row opens the time wheel
///   (5-minute steps).
/// - **Coach.** The categories are the student's; a coach's are not designed
///   (spec §4 "Rol farkları"), so a coach sees only the quiet hours.
class NotificationsViewModel extends BaseViewModel {
  NotificationsViewModel({
    required NotificationPreferencesStore store,
    required NotificationPermission permission,
    required NotificationsDialogs dialogs,
    required CurrentUserService currentUser,
    required AccountRepository account,
    required DevicePreferences preferences,
    required bool notificationsEnabled,
  }) : _store = store,
       _permission = permission,
       _dialogs = dialogs,
       _currentUser = currentUser,
       _account = account,
       _devicePreferences = preferences,
       _notificationsEnabled = notificationsEnabled,
       _preferences = store.load();

  final NotificationPreferencesStore _store;
  final NotificationPermission _permission;
  final NotificationsDialogs _dialogs;
  final CurrentUserService _currentUser;
  final AccountRepository _account;
  final DevicePreferences _devicePreferences;
  final bool _notificationsEnabled;

  NotificationPreferences _preferences;
  bool _permissionOff = false;
  String? _coachName;
  bool _disposed = false;

  /// The saved choices.
  NotificationPreferences get preferences => _preferences;

  /// The system permission is off: the switches are inactive.
  bool get permissionOff => _permissionOff;

  /// The coach's name for the second category's sentence, when known.
  String? get coachName => _coachName;

  /// The signed-in user is a coach: no category group (not designed).
  bool get isCoach => _currentUser.isCoach;

  /// Which box the page draws.
  NotificationsNotice get notice => _permissionOff
      ? NotificationsNotice.permissionOff
      : _notificationsEnabled
      ? NotificationsNotice.none
      : NotificationsNotice.planned;

  /// Reads the permission and, for a student with a coach, the coach's name
  /// (for "Mehmet Özkan yeni bir şey atadığında"); the view calls it once.
  Future<void> init() async {
    await Future.wait([refreshPermission(), _loadCoachName()]);
  }

  /// Reads the system permission again; the view calls it when the app comes
  /// back to the front ("Dönüşte izin yeniden okunur").
  Future<void> refreshPermission() async {
    final status = await _permission.status();
    if (_disposed) return;
    final off = NotificationPermissionRules.isOff(
      status,
      primerAnswered:
          _devicePreferences.getBool(
            DevicePreferences.notificationPrimerAnsweredKey,
          ) ??
          false,
    );
    if (off == _permissionOff) return;
    _permissionOff = off;
    notifyListeners();
  }

  Future<void> _loadCoachName() async {
    if (_currentUser.isCoach || (_currentUser.user?.coach ?? '').isEmpty) {
      return;
    }
    final result = await _account.getMyCoach();
    if (_disposed) return;
    final name = result.rightOrNull?.name?.trim();
    if (name == null || name.isEmpty) return;
    _coachName = name;
    notifyListeners();
  }

  /// A category switch.
  Future<void> setCategory(NotificationCategory category, {required bool on}) =>
      _apply(_preferences.withCategory(category, on: on));

  /// The "Sessiz saatler" switch.
  Future<void> setQuietEnabled({required bool on}) =>
      _apply(_preferences.copyWith(quietEnabled: on));

  /// A quiet-hours row: opens the time wheel and saves what it returns.
  Future<void> pickQuietTime(QuietBound bound) async {
    final minutes = await _dialogs.pickQuietTime(
      bound: bound,
      initialMinutes: _preferences.quietAt(bound),
    );
    if (minutes == null || _disposed) return;
    await _apply(_preferences.withQuietAt(bound, minutes));
  }

  /// "Ayarları Aç".
  Future<void> openSettings() => _permission.openSettings();

  Future<void> _apply(NotificationPreferences next) async {
    if (next == _preferences) return;
    _preferences = next;
    notifyListeners();
    await _store.save(next);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
