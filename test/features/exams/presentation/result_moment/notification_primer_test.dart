import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/exams/presentation/notification_primer/notification_primer.dart';

import 'result_moment_harness.dart';

void main() {
  group('NotificationPrimer (pano 5.2 "Ne zaman", Ek D-23)', () {
    test('while notifications are closed the sheet is never shown', () async {
      final log = <String>[];
      final flag = MemoryPrimerFlag();
      final primer = NotificationPrimer(
        enabled: false,
        flag: flag,
        presenter: RecordingPrimerPresenter(log),
      );
      expect(primer.isDue, isFalse);
      expect(await primer.offer(), isFalse);
      expect(log, isEmpty);
      // Nothing is remembered either: the first read after the flag opens
      // still asks.
      expect(flag.writes, 0);
    });

    test('enabled and never asked: shown once, then never again', () async {
      final log = <String>[];
      final flag = MemoryPrimerFlag();
      final presenter = RecordingPrimerPresenter(log, flag: flag);
      final primer = NotificationPrimer(
        enabled: true,
        flag: flag,
        presenter: presenter,
      );
      expect(primer.isDue, isTrue);
      expect(await primer.offer(), isTrue);
      expect(log, ['sheet']);
      expect(await primer.offer(), isFalse);
      expect(await primer.offer(), isFalse);
      expect(log, ['sheet']);
      expect(flag.writes, 1);
    });

    test('the flag is written before the sheet opens (a killed app never '
        'asks twice)', () async {
      final flag = MemoryPrimerFlag();
      final presenter = RecordingPrimerPresenter([], flag: flag);
      await NotificationPrimer(
        enabled: true,
        flag: flag,
        presenter: presenter,
      ).offer();
      expect(presenter.flagWhenShown, isTrue);
    });

    test('an answered flag keeps it closed', () async {
      final log = <String>[];
      final primer = NotificationPrimer(
        enabled: true,
        flag: MemoryPrimerFlag(shown: true),
        presenter: RecordingPrimerPresenter(log),
      );
      expect(primer.isDue, isFalse);
      expect(await primer.offer(), isFalse);
      expect(log, isEmpty);
    });
  });

  group('PreferencesNotificationPrimerFlag', () {
    test('reads and writes notif.primerAnswered on the device', () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData(const {});
      final preferences = await DevicePreferences.load();
      final flag = PreferencesNotificationPrimerFlag(preferences);
      expect(flag.shown, isFalse);
      await flag.markShown();
      expect(flag.shown, isTrue);
      expect(
        preferences.getBool(DevicePreferences.notificationPrimerAnsweredKey),
        isTrue,
      );
    });
  });
}
