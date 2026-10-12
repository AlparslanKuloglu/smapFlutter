import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/account/application/notification_permission.dart';
import 'package:smap/features/account/application/notification_preferences.dart';
import 'package:smap/features/account/presentation/notifications/notifications_dialogs.dart';
import 'package:smap/features/account/presentation/notifications/notifications_viewmodel.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../account_settings_fakes.dart';

class _FakePermission implements NotificationPermission {
  NotificationPermissionStatus current = NotificationPermissionStatus.granted;
  int settingsOpened = 0;

  @override
  Future<NotificationPermissionStatus> status() async => current;

  @override
  Future<void> openSettings() async => settingsOpened++;
}

class _FakeDialogs implements NotificationsDialogs {
  /// What the wheel returns; `null` is "dismissed".
  int? picked;
  final List<({QuietBound bound, int initial})> asked = [];

  @override
  Future<int?> pickQuietTime({
    required QuietBound bound,
    required int initialMinutes,
  }) async {
    asked.add((bound: bound, initial: initialMinutes));
    return picked;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DevicePreferences device;
  late _FakePermission permission;
  late _FakeDialogs dialogs;
  late FakeAccountRepository account;
  late FakeUserService user;
  late NotificationsViewModel viewModel;

  NotificationsViewModel build({bool enabled = false}) =>
      NotificationsViewModel(
        store: NotificationPreferencesStore(device),
        permission: permission,
        dialogs: dialogs,
        currentUser: user,
        account: account,
        preferences: device,
        notificationsEnabled: enabled,
      );

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    device = await DevicePreferences.load();
    permission = _FakePermission();
    dialogs = _FakeDialogs();
    account = FakeAccountRepository()..myCoach = const Right(mehmet);
    user = FakeUserService(alparslan);
    viewModel = build();
  });

  tearDown(() => viewModel.dispose());

  group('opening', () {
    test('starts with every category on and quiet hours 22:00 to 08:00', () {
      expect(viewModel.preferences, const NotificationPreferences());
    });

    test(
      'while the flag is closed the box says notifications are planned',
      () async {
        await viewModel.init();
        expect(viewModel.notice, NotificationsNotice.planned);
      },
    );

    test('with the flag open and the permission on there is no box', () async {
      viewModel.dispose();
      viewModel = build(enabled: true);
      await viewModel.init();
      expect(viewModel.notice, NotificationsNotice.none);
    });

    test('shows the saved choices', () async {
      final saved = const NotificationPreferences().withCategory(
        NotificationCategory.studyReminder,
        on: false,
      );
      await NotificationPreferencesStore(device).save(saved);
      viewModel.dispose();
      viewModel = build();
      expect(viewModel.preferences, saved);
    });

    test('names the coach in the second category', () async {
      await viewModel.init();
      expect(viewModel.coachName, 'Mehmet Özkan');
    });

    test('a student without a coach asks the server for none', () async {
      user.set(alparslanNoCoach);
      await viewModel.init();
      expect(viewModel.coachName, isNull);
      expect(account.myCoachCalls, 0);
    });

    test('a failed coach call is silent', () async {
      account.myCoach = const Left(offline);
      await viewModel.init();
      expect(viewModel.coachName, isNull);
    });

    test('a coach has no category group', () async {
      user.set(mehmet);
      expect(viewModel.isCoach, isTrue);
      await viewModel.init();
      expect(viewModel.coachName, isNull);
    });
  });

  group('switches save at once', () {
    test('a category', () async {
      await viewModel.setCategory(NotificationCategory.examReady, on: false);
      expect(
        viewModel.preferences.isOn(NotificationCategory.examReady),
        isFalse,
      );
      expect(
        NotificationPreferencesStore(
          device,
        ).load().isOn(NotificationCategory.examReady),
        isFalse,
      );
      expect(
        viewModel.preferences.isOn(NotificationCategory.meetingPlanned),
        isTrue,
      );
    });

    test('the quiet hours switch', () async {
      await viewModel.setQuietEnabled(on: false);
      expect(viewModel.preferences.quietEnabled, isFalse);
      expect(NotificationPreferencesStore(device).load().quietEnabled, isFalse);
    });

    test('a switch to the same value saves and notifies nothing', () async {
      var notified = 0;
      viewModel.addListener(() => notified++);
      await viewModel.setCategory(NotificationCategory.examReady, on: true);
      expect(notified, 0);
    });
  });

  group('quiet hours wheel (pano 9.6 kare 3)', () {
    test('opens on the saved start and saves the picked time', () async {
      dialogs.picked = 23 * 60 + 30;
      await viewModel.pickQuietTime(QuietBound.start);
      expect(dialogs.asked.single, (bound: QuietBound.start, initial: 22 * 60));
      expect(viewModel.preferences.quietStart, 23 * 60 + 30);
      expect(
        NotificationPreferencesStore(device).load().quietStart,
        23 * 60 + 30,
      );
    });

    test('the end row edits the end', () async {
      dialogs.picked = 7 * 60;
      await viewModel.pickQuietTime(QuietBound.end);
      expect(dialogs.asked.single.initial, 8 * 60);
      expect(viewModel.preferences.quietEnd, 7 * 60);
      expect(viewModel.preferences.quietStart, 22 * 60);
    });

    test('dismissing the sheet changes nothing', () async {
      dialogs.picked = null;
      await viewModel.pickQuietTime(QuietBound.start);
      expect(viewModel.preferences, const NotificationPreferences());
    });
  });

  group('system permission (pano 9.6 kare 2)', () {
    test(
      'blocked turns the box into the warning and locks the switches',
      () async {
        permission.current = NotificationPermissionStatus.blocked;
        await viewModel.init();
        expect(viewModel.permissionOff, isTrue);
        expect(viewModel.notice, NotificationsNotice.permissionOff);
      },
    );

    test('the choices stay visible while locked', () async {
      permission.current = NotificationPermissionStatus.blocked;
      await viewModel.init();
      expect(viewModel.preferences, const NotificationPreferences());
    });

    test('a denied permission never asked for is not a warning', () async {
      permission.current = NotificationPermissionStatus.denied;
      await viewModel.init();
      expect(viewModel.notice, NotificationsNotice.planned);
    });

    test(
      'a denied permission after the app\'s own sheet is a warning',
      () async {
        await device.setBool(
          DevicePreferences.notificationPrimerAnsweredKey,
          true,
        );
        permission.current = NotificationPermissionStatus.denied;
        await viewModel.init();
        expect(viewModel.notice, NotificationsNotice.permissionOff);
      },
    );

    test('coming back from the settings reads it again', () async {
      permission.current = NotificationPermissionStatus.blocked;
      await viewModel.init();
      expect(viewModel.permissionOff, isTrue);

      permission.current = NotificationPermissionStatus.granted;
      var notified = 0;
      viewModel.addListener(() => notified++);
      await viewModel.refreshPermission();
      expect(viewModel.permissionOff, isFalse);
      expect(viewModel.notice, NotificationsNotice.planned);
      expect(notified, 1);
    });

    test('an unchanged permission does not rebuild the screen', () async {
      await viewModel.init();
      var notified = 0;
      viewModel.addListener(() => notified++);
      await viewModel.refreshPermission();
      expect(notified, 0);
    });

    test('"Ayarları Aç" opens the system settings', () async {
      await viewModel.openSettings();
      expect(permission.settingsOpened, 1);
    });
  });
}
