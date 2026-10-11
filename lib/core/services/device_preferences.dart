import 'package:shared_preferences/shared_preferences.dart';

import 'package:smap/core/services/app_logger.dart';

/// Device-only preferences that the first frame needs synchronously (theme,
/// "seen" flags, dismissed hints). Loaded once before `runApp`; reads are
/// synchronous, writes are awaited but never throw.
///
/// Only keys in [allowedKeys] are cached and readable; add a key here, with
/// a doc comment, before using it. Account data (the user JSON, tokens, the
/// session cookie) does not belong here: the session lives in the cookie jar
/// and the session store.
///
/// All key constants live in this file so a key is never typed twice.
final class DevicePreferences {
  DevicePreferences._(this._prefs, this._logger);

  /// Light, dark or system (`ThemeMode.name`). Light until the dark migration.
  static const themeModeKey = 'ui.themeMode';

  /// The intro and onboarding flow ran to its end (`bool`).
  static const onboardingCompletedKey = 'onboarding.completed';

  /// Role, grade and track picked before sign-up, kept until the account
  /// exists (`String`, JSON written by the onboarding feature).
  static const onboardingDraftKey = 'onboarding.draft';

  /// A random id of this install (`String`), for support and diagnostics.
  static const installIdKey = 'device.installId';

  /// The camera pre-permission sheet was answered (`bool`).
  static const cameraPrimerAnsweredKey = 'scan.cameraPrimerAnswered';

  /// The camera tutorial was shown once (`bool`).
  static const cameraTutorialSeenKey = 'scan.tutorialSeen';

  /// "Bir daha sorma" on the learned-card confirmation (`bool`).
  static const skipLearnedConfirmKey = 'cards.skipLearnedConfirm';

  /// The notification permission sheet was answered (`bool`).
  static const notificationPrimerAnsweredKey = 'notif.primerAnswered';

  /// Exam type chosen in the lessons list, e.g. `tyt` / `ayt` (`String`).
  static const lessonsExamTypeKey = 'lessons.examType';

  /// Result ids of the exams the student starred in Denemelerim (`String`,
  /// a JSON list). The favorite lives on the device only (spec decision 4.8).
  static const favoriteExamsKey = 'analytics.favoriteExams';
  /// Section chosen on the Edebiyat detail, `topics` or `authors` (`String`;
  /// pano 7.4 "seçim cihazda hatırlanır").
  static const lessonsLiteratureSectionKey = 'lessons.literatureSection';

  /// Day or week view last used on a program, `day` / `week` (`String`;
  /// pano 3.4).
  static const scheduleProgramViewKey = 'schedule.programView';

  /// Every key the cache loads. Anything else is rejected.
  static const Set<String> allowedKeys = {
    themeModeKey,
    onboardingCompletedKey,
    onboardingDraftKey,
    installIdKey,
    cameraPrimerAnsweredKey,
    cameraTutorialSeenKey,
    skipLearnedConfirmKey,
    notificationPrimerAnsweredKey,
    lessonsExamTypeKey,
    favoriteExamsKey,
    lessonsLiteratureSectionKey,
    scheduleProgramViewKey,
  };

  final SharedPreferencesWithCache _prefs;
  final AppLogger _logger;

  /// Opens the store and loads the allow-listed keys.
  static Future<DevicePreferences> load({AppLogger? logger}) async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: allowedKeys,
      ),
    );
    return DevicePreferences._(prefs, logger ?? AppLogger.silent());
  }

  String? getString(String key) => _read(key, _prefs.getString);

  bool? getBool(String key) => _read(key, _prefs.getBool);

  int? getInt(String key) => _read(key, _prefs.getInt);

  Future<void> setString(String key, String value) =>
      _write(key, () => _prefs.setString(key, value));

  Future<void> setBool(String key, bool value) =>
      _write(key, () => _prefs.setBool(key, value));

  Future<void> setInt(String key, int value) =>
      _write(key, () => _prefs.setInt(key, value));

  Future<void> remove(String key) => _write(key, () => _prefs.remove(key));

  /// Forgets every allow-listed key (sign-out of the device, not of the
  /// account: callers decide whether "seen" flags should survive).
  Future<void> clear() async {
    try {
      await _prefs.clear();
    } on Object catch (e) {
      _logger.warning('clear failed', name: 'Prefs', error: e);
    }
  }

  T? _read<T>(String key, T? Function(String key) reader) {
    if (!allowedKeys.contains(key)) {
      _rejectKey(key);
      return null;
    }
    try {
      return reader(key);
    } on Object catch (e) {
      // A value of another type under the key (older build): treat as unset.
      _logger.warning('$key unreadable', name: 'Prefs', error: e);
      return null;
    }
  }

  Future<void> _write(String key, Future<void> Function() writer) async {
    if (!allowedKeys.contains(key)) {
      _rejectKey(key);
      return;
    }
    try {
      await writer();
    } on Object catch (e) {
      _logger.warning('$key not saved', name: 'Prefs', error: e);
    }
  }

  void _rejectKey(String key) {
    assert(false, 'DevicePreferences: "$key" is not in allowedKeys.');
    _logger.warning('"$key" is not allow-listed', name: 'Prefs');
  }
}
