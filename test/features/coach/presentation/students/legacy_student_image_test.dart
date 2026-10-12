import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/legacy/legacy_links_e16.dart';

void main() {
  group('legacyStudentImage (the one avatar rule for the legacy screen)', () {
    test('a file name gets its folder', () {
      expect(legacyStudentImage('1avatarN3.png'), 'avatars/1avatarN3.png');
    });

    test('a path with the folder stays as it is', () {
      expect(
        legacyStudentImage('avatars/1avatarN3.png'),
        'avatars/1avatarN3.png',
      );
    });

    test('a full asset path loses only the assets/ the screen adds', () {
      expect(
        legacyStudentImage('assets/avatars/1avatarN3.png'),
        'avatars/1avatarN3.png',
      );
    });

    test('no photo is an empty string (the screen draws the initial)', () {
      expect(legacyStudentImage(null), isEmpty);
      expect(legacyStudentImage('  '), isEmpty);
    });
  });
}
