import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/features/account/application/account_header.dart';
import 'package:smap/features/account/application/app_version.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/account/presentation/account/account_viewmodel.dart';
import 'package:smap/features/account/presentation/account_navigator.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';
import 'package:smap/l10n/app_localizations_tr.dart';

import 'account_harness.dart';

void main() {
  late AccountBackend backend;
  late FakeUserService user;
  late FakeSession session;
  late RecordingNavigator navigator;
  late ScriptedDialogs dialogs;
  late List<String> clipboard;
  late List<Uri> opened;
  late bool openSucceeds;
  late int pending;
  late ToastService toast;
  AppVersion? version;
  late AccountViewModel viewModel;

  AccountViewModel build({
    String? supportEmail,
    Duration timeout = const Duration(seconds: 15),
    Future<AppVersion?> Function()? readVersion,
  }) {
    toast = recordingToast();
    return viewModel = AccountViewModel(
      currentUser: user,
      accounts: backend.repository,
      session: session,
      navigator: navigator,
      dialogs: dialogs,
      toast: toast,
      config: AppConfig.resolve(supportEmail: supportEmail),
      readVersion: readVersion ?? () async => version,
      systemLabel: () => 'iOS 18.2 (Build 22C150)',
      openUrl: (uri) async {
        opened.add(uri);
        return openSucceeds;
      },
      copyText: (text) async => clipboard.add(text),
      pendingForms: () => pending,
      timeout: timeout,
    );
  }

  setUp(() {
    backend = AccountBackend()..coach = coachJson();
    user = FakeUserService(alparslan());
    session = FakeSession();
    navigator = RecordingNavigator();
    dialogs = ScriptedDialogs();
    clipboard = [];
    opened = [];
    openSucceeds = true;
    pending = 0;
    version = const AppVersion(version: '3.0.0', build: '300');
  });

  tearDown(() {
    viewModel.dispose();
    backend.dispose();
  });

  group('a student', () {
    test('the band has the account at once and no coach yet', () {
      build();

      final header = viewModel.header!;

      expect(header.name, 'Alparslan Kuloğlu');
      expect(header.grade, SchoolGrade.grade12);
      expect(header.track, StudyTrack.esitAgirlik);
      expect(header.coachName, isNull);
      expect(viewModel.menu.link, CoachLinkState.unknown);
      expect(viewModel.menu.isCoach, isFalse);
    });

    test('init asks for the coach and the version once', () async {
      build();

      await viewModel.init();
      await viewModel.init();

      expect(viewModel.header!.coachName, 'Mehmet Özkan');
      expect(viewModel.menu.link, CoachLinkState.linked);
      expect(viewModel.menu.coachName, 'Mehmet Özkan');
      expect(viewModel.version, version);
      expect(backend.count('/student/getStudentsCoach'), 1);
    });

    test('a student without a coach reads as none', () async {
      backend.coach = null;
      build();

      await viewModel.init();

      expect(viewModel.menu.link, CoachLinkState.none);
      expect(viewModel.header!.coachName, isNull);
    });

    test('a failed call draws nothing about the coach', () async {
      backend.coachFails = true;
      build();

      await viewModel.init();

      expect(viewModel.menu.link, CoachLinkState.unknown);
      expect(viewModel.header!.coachName, isNull);
    });

    test('offline is the same as a failed call', () async {
      backend.coachOffline = true;
      build();

      await viewModel.init();

      expect(viewModel.menu.link, CoachLinkState.unknown);
    });

    test('a coach call that never answers does not block the screen', () async {
      backend.coachGate = Completer<void>();
      build(timeout: const Duration(milliseconds: 20));

      await viewModel.init();

      expect(viewModel.menu.link, CoachLinkState.unknown);
      expect(viewModel.version, version);
    });

    test('a failed call keeps the coach that is already known', () async {
      build();
      await viewModel.init();
      backend.coachFails = true;

      await viewModel.openCoaching();

      expect(viewModel.menu.link, CoachLinkState.linked);
      expect(viewModel.menu.coachName, 'Mehmet Özkan');
    });

    test('"Koçluk" asks for the coach again when it closes', () async {
      build();
      await viewModel.init();
      // While the Koçluk screen is up the student removes the coach.
      navigator.whileOpen = (_) => backend.coach = null;

      await viewModel.openCoaching();

      expect(navigator.calls, ['open:coaching']);
      expect(viewModel.menu.link, CoachLinkState.none);
      expect(backend.count('/student/getStudentsCoach'), 2);
    });

    test('the band follows the account when it changes', () async {
      build();
      var notified = 0;
      viewModel.addListener(() => notified++);

      user.set(alparslan(name: 'Alparslan K.', seasonType: 11));
      await Future<void>.delayed(Duration.zero);

      expect(notified, greaterThan(0));
      expect(viewModel.header!.name, 'Alparslan K.');
      expect(viewModel.header!.grade, SchoolGrade.grade11);
    });
  });

  group('a coach', () {
    setUp(() => user = FakeUserService(mehmetOzkan()));

    test('has the coaching code and never asks for a coach', () async {
      build();

      await viewModel.init();

      final header = viewModel.header!;
      expect(header.isCoach, isTrue);
      expect(header.coachCode, 'MOZK-4821');
      expect(viewModel.menu.isCoach, isTrue);
      expect(viewModel.menu.coachCode, 'MOZK-4821');
      expect(backend.count('/student/getStudentsCoach'), 0);
    });

    test('the code row opens the code sheet (pano 14.11)', () async {
      build();

      await viewModel.openCoachCode();

      expect(dialogs.calls, ['coachCode']);
      expect(clipboard, isEmpty);
    });

    test('without a code the menu has no code to show', () {
      user = FakeUserService(const UserDto(name: 'Mehmet', role: 'coach'));
      build();

      expect(viewModel.menu.coachCode, isNull);
    });
  });

  group('the menu', () {
    test('offers what the router has', () {
      navigator = RecordingNavigator(
        available: {AccountDestination.coaching, AccountDestination.deletion},
      );
      build();

      expect(viewModel.menu.canOpenCoaching, isTrue);
      expect(viewModel.menu.canOpenPassword, isFalse);
      expect(viewModel.menu.canOpenNotifications, isFalse);
    });

    test('"Bize Yaz" needs a configured address', () {
      build();
      expect(viewModel.menu.hasSupport, isFalse);

      viewModel.dispose();
      build(supportEmail: 'destek@smaptr.com');
      expect(viewModel.menu.hasSupport, isTrue);
    });

    test('is equal by value so the groups rebuild only on a change', () {
      build();

      expect(viewModel.menu, viewModel.menu);
      expect(
        viewModel.menu,
        isNot(
          const AccountMenuData(
            isCoach: true,
            link: CoachLinkState.unknown,
            coachName: null,
            coachCode: null,
            canOpenPassword: true,
            canOpenCoaching: true,
            canOpenNotifications: true,
            hasSupport: false,
          ),
        ),
      );
    });
  });

  group('navigation', () {
    test('the rows open their screens', () async {
      build();

      await viewModel.openProfile();
      await viewModel.openPassword();
      await viewModel.openNotifications();
      await viewModel.openContracts();

      expect(navigator.calls, [
        'profile',
        'open:password',
        'open:notifications',
        'contracts',
      ]);
    });

    test('a screen that is not in the router is not opened', () async {
      navigator = RecordingNavigator(available: {});
      build();

      await viewModel.openPassword();

      expect(navigator.calls, isEmpty);
    });
  });

  group('logout', () {
    test('asks first and signs out once confirmed', () async {
      build();

      await viewModel.logout();

      expect(dialogs.calls, ['logout:0']);
      expect(session.signOuts, 1);
    });

    test('"Vazgeç" keeps the session', () async {
      dialogs.logout = false;
      build();

      await viewModel.logout();

      expect(session.signOuts, 0);
    });

    test('the confirmation says how many forms would be lost', () async {
      pending = 1;
      build();

      await viewModel.logout();

      expect(dialogs.calls, ['logout:1']);
    });

    test('a second press while it runs does nothing', () async {
      session.gate = Completer<void>();
      build();

      final first = viewModel.logout();
      await Future<void>.delayed(Duration.zero);
      await viewModel.logout();
      session.gate!.complete();
      await first;

      expect(session.signOuts, 1);
      expect(dialogs.calls, ['logout:0']);
    });
  });

  group('the version line', () {
    test('a long press copies it for support', () async {
      build();
      await viewModel.init();

      await viewModel.copyVersion();

      expect(clipboard, ['3.0.0 (300)']);
      expect(toastText(toast), 'Sürüm kopyalandı.');
    });

    test('there is nothing to copy before it is read', () async {
      version = null;
      build();
      await viewModel.init();

      await viewModel.copyVersion();

      expect(viewModel.version, isNull);
      expect(clipboard, isEmpty);
    });

    test('a platform that cannot tell leaves the line out', () async {
      build(readVersion: () async => throw StateError('no plugin'));

      await viewModel.init();

      expect(viewModel.version, isNull);
    });
  });

  group('"Bize Yaz"', () {
    test('opens a draft with the version and the system', () async {
      build(supportEmail: 'destek@smaptr.com');
      await viewModel.init();

      await viewModel.writeSupport(AppLocalizationsTr());

      final uri = opened.single;
      expect(uri.scheme, 'mailto');
      expect(uri.path, 'destek@smaptr.com');
      final query = Uri.splitQueryString(uri.query);
      expect(query['subject'], 'SMAP · Destek');
      expect(query['body'], contains('Uygulama sürümü: 3.0.0 (300)'));
      expect(query['body'], contains('Sistem: iOS 18.2 (Build 22C150)'));
    });

    test('still opens, without a version line, before it is read', () async {
      build(supportEmail: 'destek@smaptr.com');

      await viewModel.writeSupport(AppLocalizationsTr());

      final body = Uri.splitQueryString(opened.single.query)['body']!;
      expect(body, isNot(contains('Uygulama sürümü')));
      expect(body, contains('Sistem: iOS'));
    });

    test('does nothing without an address', () async {
      build();

      await viewModel.writeSupport(AppLocalizationsTr());

      expect(opened, isEmpty);
    });

    test('a mail app that cannot open is a toast', () async {
      openSucceeds = false;
      build(supportEmail: 'destek@smaptr.com');

      await viewModel.writeSupport(AppLocalizationsTr());

      expect(opened, hasLength(1));
      expect(toastText(toast), 'E-posta uygulaması açılamadı.');
      expect(toastKind(toast), AppToastKind.error);
    });
  });
}
