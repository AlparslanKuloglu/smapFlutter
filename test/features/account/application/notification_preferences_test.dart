import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/account/application/notification_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('defaults (D-24, 8.5)', () {
    test('every category on, quiet hours on, 22:00 to 08:00', () {
      const prefs = NotificationPreferences();
      for (final category in NotificationCategory.values) {
        expect(prefs.isOn(category), isTrue, reason: category.name);
      }
      expect(prefs.quietEnabled, isTrue);
      expect(prefs.quietStart, 22 * 60);
      expect(prefs.quietEnd, 8 * 60);
    });
  });

  group('changes', () {
    test('a category switches without touching the others', () {
      final prefs = const NotificationPreferences().withCategory(
        NotificationCategory.coachAssigned,
        on: false,
      );
      expect(prefs.isOn(NotificationCategory.coachAssigned), isFalse);
      expect(prefs.isOn(NotificationCategory.examReady), isTrue);
      expect(
        prefs.withCategory(NotificationCategory.coachAssigned, on: true),
        const NotificationPreferences(),
      );
    });

    test('the quiet times are set by bound', () {
      final prefs = const NotificationPreferences()
          .withQuietAt(QuietBound.start, 23 * 60 + 30)
          .withQuietAt(QuietBound.end, 7 * 60 + 5);
      expect(prefs.quietAt(QuietBound.start), 23 * 60 + 30);
      expect(prefs.quietAt(QuietBound.end), 7 * 60 + 5);
    });

    test('equal choices are equal whatever the set order', () {
      final a = const NotificationPreferences().withCategory(
        NotificationCategory.examReady,
        on: false,
      );
      final b = const NotificationPreferences().withCategory(
        NotificationCategory.examReady,
        on: false,
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(const NotificationPreferences()));
    });
  });

  group('JSON', () {
    test('round trips', () {
      final prefs = const NotificationPreferences()
          .withCategory(NotificationCategory.meetingPlanned, on: false)
          .copyWith(quietEnabled: false, quietStart: 23 * 60, quietEnd: 6 * 60);
      expect(
        NotificationPreferences.fromJson(
          jsonDecode(jsonEncode(prefs.toJson())),
        ),
        prefs,
      );
    });

    test('anything odd keeps its default', () {
      expect(
        NotificationPreferences.fromJson(null),
        const NotificationPreferences(),
      );
      expect(
        NotificationPreferences.fromJson('x'),
        const NotificationPreferences(),
      );
      final prefs = NotificationPreferences.fromJson(const {
        'categories': {'examReady': false, 'studyReminder': 'yes'},
        'quiet': {'enabled': 'no', 'start': -5, 'end': 99999},
      });
      expect(prefs.isOn(NotificationCategory.examReady), isFalse);
      expect(prefs.isOn(NotificationCategory.studyReminder), isTrue);
      expect(prefs.quietEnabled, isTrue);
      expect(prefs.quietStart, NotificationPreferences.defaultQuietStart);
      expect(prefs.quietEnd, NotificationPreferences.defaultQuietEnd);
    });
  });

  group('NotificationPreferencesStore', () {
    late DevicePreferences device;
    late NotificationPreferencesStore store;

    setUp(() async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      device = await DevicePreferences.load();
      store = NotificationPreferencesStore(device);
    });

    test('loads the defaults when nothing was saved', () {
      expect(store.load(), const NotificationPreferences());
    });

    test('keeps what was saved', () async {
      final prefs = const NotificationPreferences().copyWith(
        quietStart: 21 * 60 + 45,
      );
      await store.save(prefs);
      expect(store.load(), prefs);
    });

    test('a damaged value reads as the defaults', () async {
      await device.setString(
        DevicePreferences.notificationPreferencesKey,
        '{not json',
      );
      expect(store.load(), const NotificationPreferences());
    });
  });
}
