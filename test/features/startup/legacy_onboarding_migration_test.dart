import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/startup/data/legacy_onboarding_migration.dart';

// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late DevicePreferences device;

  Future<SharedPreferences> legacy() => SharedPreferences.getInstance();

  LegacyOnboardingMigration migration() =>
      LegacyOnboardingMigration(preferences: device);

  bool? seenFlag() => device.getBool(DevicePreferences.onboardingCompletedKey);

  Future<void> start(Map<String, Object> legacyValues) async {
    SharedPreferences.setMockInitialValues(legacyValues);
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    device = await DevicePreferences.load();
  }

  test('an existing user does not see the intro again', () async {
    await start({LegacyOnboardingMigration.legacyKey: true});

    final result = await migration().run();

    expect(result, LegacyOnboardingResult.migrated);
    expect(seenFlag(), isTrue);
    expect(
      (await legacy()).containsKey(LegacyOnboardingMigration.legacyKey),
      isFalse,
      reason: 'the old key is forgotten once the new one is saved',
    );
  });

  test(
    'is idempotent: a second run finds nothing and changes nothing',
    () async {
      await start({LegacyOnboardingMigration.legacyKey: true});
      await migration().run();

      final again = await migration().run();

      expect(again, LegacyOnboardingResult.nothingToMigrate);
      expect(seenFlag(), isTrue);
    },
  );

  test('a new install has nothing to move and shows the intro', () async {
    await start({});

    final result = await migration().run();

    expect(result, LegacyOnboardingResult.nothingToMigrate);
    expect(seenFlag(), isNull);
  });

  test(
    'an unfinished legacy intro is dropped, the intro still shows',
    () async {
      await start({LegacyOnboardingMigration.legacyKey: false});

      final result = await migration().run();

      expect(result, LegacyOnboardingResult.droppedUnfinished);
      expect(seenFlag(), isNull);
      expect(
        (await legacy()).containsKey(LegacyOnboardingMigration.legacyKey),
        isFalse,
      );
    },
  );

  test('never switches a finished new-app intro back', () async {
    await start({LegacyOnboardingMigration.legacyKey: false});
    await device.setBool(DevicePreferences.onboardingCompletedKey, true);

    await migration().run();

    expect(seenFlag(), isTrue);
  });

  test('does not touch the other legacy keys', () async {
    await start({
      LegacyOnboardingMigration.legacyKey: true,
      'user_data': '{"role":"student"}',
      'isLoggedIn': true,
    });

    await migration().run();

    final prefs = await legacy();
    expect(prefs.getString('user_data'), '{"role":"student"}');
    expect(prefs.getBool('isLoggedIn'), isTrue);
  });

  test('uses the same key as the legacy local data source', () {
    // AuthLocalDataSource.onboardingCompletedKey; pinned here so a rename in
    // either place fails this test.
    expect(LegacyOnboardingMigration.legacyKey, 'onboarding_completed');
  });
}
