import 'package:shared_preferences/shared_preferences.dart';

import 'package:smap/core/services/app_logger.dart';
import 'package:smap/core/services/device_preferences.dart';

/// What [LegacyOnboardingMigration.run] did.
enum LegacyOnboardingResult {
  /// No legacy flag on the device (a new install, or already migrated).
  nothingToMigrate,

  /// The legacy flag was set: the new flag was set too, the old key removed.
  migrated,

  /// The legacy flag was `false` (the intro was started but not finished); it
  /// was removed, and the user sees the intro.
  droppedUnfinished,
}

/// One-time move of the legacy "intro seen" flag.
///
/// The old app kept it as `onboarding_completed` in `SharedPreferences`
/// (`AuthLocalDataSource.onboardingCompletedKey`); the new one keeps it in
/// `DevicePreferences` (`onboardingCompletedKey`). Without the move every
/// existing user would see the intro again after the update.
///
/// The old key is removed once it was read, so a second run finds nothing
/// (idempotent), and a flag the user already finished in the new app is never
/// switched back. It never throws.
class LegacyOnboardingMigration {
  LegacyOnboardingMigration({
    required DevicePreferences preferences,
    AppLogger? logger,
    Future<SharedPreferences> Function()? legacyPreferences,
  }) : _preferences = preferences,
       _logger = logger ?? AppLogger.silent(),
       _legacyPreferences = legacyPreferences ?? SharedPreferences.getInstance;

  /// The legacy key (`AuthLocalDataSource.onboardingCompletedKey`).
  static const String legacyKey = 'onboarding_completed';

  final DevicePreferences _preferences;
  final AppLogger _logger;
  final Future<SharedPreferences> Function() _legacyPreferences;

  Future<LegacyOnboardingResult> run() async {
    try {
      final legacy = await _legacyPreferences();
      if (!legacy.containsKey(legacyKey)) {
        return LegacyOnboardingResult.nothingToMigrate;
      }
      final seen = legacy.getBool(legacyKey) ?? false;
      if (seen) {
        await _preferences.setBool(
          DevicePreferences.onboardingCompletedKey,
          true,
        );
        // Only forget the old key once the new one is proven.
        if (_preferences.getBool(DevicePreferences.onboardingCompletedKey) !=
            true) {
          _logger.warning('onboarding flag not saved', name: 'Startup');
          return LegacyOnboardingResult.nothingToMigrate;
        }
      }
      await legacy.remove(legacyKey);
      _logger.info(
        'legacy onboarding flag moved (seen: $seen)',
        name: 'Startup',
      );
      return seen
          ? LegacyOnboardingResult.migrated
          : LegacyOnboardingResult.droppedUnfinished;
    } on Object catch (error, stackTrace) {
      _logger.error(
        'legacy onboarding migration failed',
        name: 'Startup',
        error: error,
        stackTrace: stackTrace,
      );
      return LegacyOnboardingResult.nothingToMigrate;
    }
  }
}
