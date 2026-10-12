import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/account/application/app_version.dart';
import 'package:smap/features/account/application/system_label.dart';

void main() {
  group('SystemLabel', () {
    test('names the system and tidies the version', () {
      expect(
        SystemLabel.of('ios', 'Version 18.2 (Build 22C150)'),
        'iOS 18.2 (Build 22C150)',
      );
      expect(SystemLabel.of('android', '  14  '), 'Android 14');
    });

    test('a system without a version is just its name', () {
      expect(SystemLabel.of('macos', ''), 'macOS');
    });

    test('an unknown system keeps its own name', () {
      expect(SystemLabel.of('fuchsia', '1.0'), 'fuchsia 1.0');
    });
  });

  group('AppVersion', () {
    test('writes the build in brackets', () {
      const version = AppVersion(version: '3.0.0', build: '300');

      expect(version.hasBuild, isTrue);
      expect(version.plain, '3.0.0 (300)');
    });

    test('a build is optional', () {
      const version = AppVersion(version: '3.0.0');

      expect(version.hasBuild, isFalse);
      expect(version.plain, '3.0.0');
    });

    test('is equal by value', () {
      expect(
        const AppVersion(version: '3.0.0', build: '300'),
        const AppVersion(version: '3.0.0', build: '300'),
      );
    });
  });
}
