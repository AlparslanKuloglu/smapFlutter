import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/app/router/guards/route_access.dart';
import 'package:smap/core/config/app_config.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';
import 'package:smap/features/auth/domain/session_state.dart';
import 'package:smap/features/startup/application/startup_gate.dart';
import 'package:smap/features/startup/application/store_launcher.dart';
import 'package:smap/features/startup/presentation/startup/startup_viewmodel.dart';

void main() {
  group('StartupViewModel.targetFor', () {
    const student = SessionState.signedIn(UserDto(id: '1', role: 'student'));

    test('a stop screen wins over everything', () {
      expect(
        StartupViewModel.targetFor(
          block: StartupBlock.forceUpdate,
          onboardingSeen: false,
          session: student,
        ),
        RouteTarget.forceUpdate,
      );
      expect(
        StartupViewModel.targetFor(
          block: StartupBlock.maintenance,
          onboardingSeen: true,
          session: student,
        ),
        RouteTarget.maintenance,
      );
    });

    test('without a block the session and the intro decide', () {
      expect(
        StartupViewModel.targetFor(
          block: StartupBlock.none,
          onboardingSeen: false,
          session: student,
        ),
        RouteTarget.onboarding,
      );
      expect(
        StartupViewModel.targetFor(
          block: StartupBlock.none,
          onboardingSeen: true,
          session: const SessionState.signedOut(),
        ),
        RouteTarget.welcome,
      );
      expect(
        StartupViewModel.targetFor(
          block: StartupBlock.none,
          onboardingSeen: true,
          session: student,
        ),
        RouteTarget.studentShell,
      );
    });
  });

  test(
    'the shipped gate is closed until the backend has a public config',
    () async {
      expect(await const DisabledStartupGate().check(), StartupBlock.none);
    },
  );

  group('StoreLauncher', () {
    final opened = <Uri>[];

    setUp(opened.clear);

    StoreLauncher launcher({
      AppConfig? config,
      TargetPlatform platform = TargetPlatform.android,
      bool succeed = true,
    }) => StoreLauncher(
      config: config ?? AppConfig.resolve(),
      platform: platform,
      opener: (uri) async {
        opened.add(uri);
        return succeed;
      },
    );

    test('opens the Play page on Android', () async {
      final ok = await launcher().openStorePage();

      expect(ok, isTrue);
      expect(opened.single.host, 'play.google.com');
      expect(opened.single.queryParameters['id'], 'com.smap.smap');
    });

    test('opens the App Store page on iOS once an id is configured', () async {
      final ok = await launcher(
        config: AppConfig.resolve(appStoreId: '1234567890'),
        platform: TargetPlatform.iOS,
      ).openStorePage();

      expect(ok, isTrue);
      expect(
        opened.single.toString(),
        'https://apps.apple.com/app/id1234567890',
      );
    });

    test('has nothing to open on iOS without an App Store id', () async {
      final ok = await launcher(platform: TargetPlatform.iOS).openStorePage();

      expect(ok, isFalse);
      expect(opened, isEmpty);
    });

    test('writes to support only with a configured address', () async {
      expect(launcher().canWriteSupport, isFalse);
      expect(await launcher().writeSupport(), isFalse);
      expect(opened, isEmpty);

      final withMail = launcher(
        config: AppConfig.resolve(supportEmail: 'destek@example.com'),
      );
      expect(withMail.canWriteSupport, isTrue);
      expect(await withMail.writeSupport(), isTrue);
      expect(opened.single.scheme, 'mailto');
    });

    test('reports a failed open instead of throwing', () async {
      final failing = StoreLauncher(
        config: AppConfig.resolve(),
        platform: TargetPlatform.android,
        opener: (_) async => throw StateError('no handler'),
      );

      expect(await failing.openStorePage(), isFalse);
    });
  });
}
