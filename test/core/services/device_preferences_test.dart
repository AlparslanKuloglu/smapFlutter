import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/services/device_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  void useStore([Map<String, Object> data = const {}]) {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData(data);
  }

  setUp(useStore);

  test('values written are readable at once and survive a reload', () async {
    final prefs = await DevicePreferences.load();

    await prefs.setString(DevicePreferences.themeModeKey, 'light');
    await prefs.setBool(DevicePreferences.onboardingCompletedKey, true);
    await prefs.setInt(DevicePreferences.installIdKey, 7);

    expect(prefs.getString(DevicePreferences.themeModeKey), 'light');
    expect(prefs.getBool(DevicePreferences.onboardingCompletedKey), isTrue);
    expect(prefs.getInt(DevicePreferences.installIdKey), 7);

    final reloaded = await DevicePreferences.load();
    expect(reloaded.getString(DevicePreferences.themeModeKey), 'light');
    expect(reloaded.getBool(DevicePreferences.onboardingCompletedKey), isTrue);
  });

  test('unset keys read as null', () async {
    final prefs = await DevicePreferences.load();

    expect(prefs.getString(DevicePreferences.themeModeKey), isNull);
    expect(prefs.getBool(DevicePreferences.cameraTutorialSeenKey), isNull);
    expect(prefs.getInt(DevicePreferences.installIdKey), isNull);
  });

  test('remove forgets a key', () async {
    final prefs = await DevicePreferences.load();
    await prefs.setString(DevicePreferences.lessonsExamTypeKey, 'tyt');

    await prefs.remove(DevicePreferences.lessonsExamTypeKey);

    expect(prefs.getString(DevicePreferences.lessonsExamTypeKey), isNull);
  });

  test('clear forgets every allow-listed key', () async {
    final prefs = await DevicePreferences.load();
    await prefs.setBool(DevicePreferences.cameraTutorialSeenKey, true);
    await prefs.setString(DevicePreferences.themeModeKey, 'dark');

    await prefs.clear();

    expect(prefs.getBool(DevicePreferences.cameraTutorialSeenKey), isNull);
    expect(prefs.getString(DevicePreferences.themeModeKey), isNull);
  });

  test('a value of another type reads as unset instead of throwing', () async {
    useStore({DevicePreferences.themeModeKey: 5});
    final prefs = await DevicePreferences.load();

    expect(prefs.getString(DevicePreferences.themeModeKey), isNull);
  });

  group('allow-list', () {
    test('every key constant is allow-listed and keys are unique', () {
      const keys = [
        DevicePreferences.themeModeKey,
        DevicePreferences.onboardingCompletedKey,
        DevicePreferences.onboardingDraftKey,
        DevicePreferences.installIdKey,
        DevicePreferences.cameraPrimerAnsweredKey,
        DevicePreferences.cameraTutorialSeenKey,
        DevicePreferences.skipLearnedConfirmKey,
        DevicePreferences.notificationPrimerAnsweredKey,
        DevicePreferences.lessonsExamTypeKey,
        DevicePreferences.favoriteExamsKey,
      ];

      expect(DevicePreferences.allowedKeys, keys.toSet());
      expect(keys.toSet(), hasLength(keys.length));
    });

    test('a key outside the list is rejected (assert in debug)', () async {
      final prefs = await DevicePreferences.load();

      expect(
        () => prefs.getString('user_data'),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => prefs.setString('user_data', '{}'),
        throwsA(isA<AssertionError>()),
      );
    });

    test('keys written by the legacy code are not cached', () async {
      useStore({
        'user_data': '{"name":"Ada"}',
        DevicePreferences.themeModeKey: 'light',
      });
      final prefs = await DevicePreferences.load();

      expect(prefs.getString(DevicePreferences.themeModeKey), 'light');
      expect(
        () => prefs.getString('user_data'),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
