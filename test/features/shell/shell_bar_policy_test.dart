import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/features/shell/application/shell_bar_policy.dart';

void main() {
  group('ShellBarPolicy.onTap', () {
    test('another tab switches to it', () {
      for (var active = 0; active < 4; active++) {
        for (var tapped = 0; tapped < 4; tapped++) {
          if (tapped == active) continue;
          expect(
            ShellBarPolicy.onTap(tapped: tapped, active: active),
            ShellTabAction.switchTab,
            reason: '$active -> $tapped',
          );
        }
      }
    });

    test('the selected tab goes back to its root', () {
      for (var index = 0; index < 4; index++) {
        expect(
          ShellBarPolicy.onTap(tapped: index, active: index),
          ShellTabAction.backToRoot,
        );
      }
    });
  });

  group('ShellBarPolicy.barVisible', () {
    const shells = {'StudentShellRoute', 'CoachShellRoute'};

    test('a shell on top shows the bar', () {
      expect(
        ShellBarPolicy.barVisible(
          rootStack: const ['StudentShellRoute'],
          shellRouteNames: shells,
        ),
        isTrue,
      );
      expect(
        ShellBarPolicy.barVisible(
          rootStack: const ['CoachShellRoute'],
          shellRouteNames: shells,
        ),
        isTrue,
      );
    });

    test('a full-screen flow over the shell hides it', () {
      expect(
        ShellBarPolicy.barVisible(
          rootStack: const ['StudentShellRoute', 'ScanFlowRoute'],
          shellRouteNames: shells,
        ),
        isFalse,
      );
    });

    test('the flow closing shows it again', () {
      final stack = ['StudentShellRoute', 'ScanFlowRoute'];
      expect(
        ShellBarPolicy.barVisible(rootStack: stack, shellRouteNames: shells),
        isFalse,
      );

      stack.removeLast();

      expect(
        ShellBarPolicy.barVisible(rootStack: stack, shellRouteNames: shells),
        isTrue,
      );
    });

    test('no shell, no bar', () {
      expect(
        ShellBarPolicy.barVisible(
          rootStack: const ['WelcomeRoute'],
          shellRouteNames: shells,
        ),
        isFalse,
      );
      expect(
        ShellBarPolicy.barVisible(rootStack: const [], shellRouteNames: shells),
        isFalse,
      );
    });
  });

  test('the toast offset is the bar height while the bar shows', () {
    expect(ShellBarPolicy.toastBarHeight(barVisible: true), AppSize.bottomBar);
    expect(ShellBarPolicy.toastBarHeight(barVisible: false), isNull);
  });
}
