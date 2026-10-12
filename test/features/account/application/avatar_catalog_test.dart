import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/account/application/avatar_catalog.dart';

void main() {
  test('there are seven avatars, the same pictures as sign-up', () {
    expect(AvatarCatalog.count, 7);
    expect(AvatarCatalog.files.first, '1avatarN3.png');
    expect(AvatarCatalog.files.toSet().length, 7);
  });

  group('indexOf', () {
    test('finds a file name and a path with its folder', () {
      expect(AvatarCatalog.indexOf('4avatarN3.png'), 2);
      expect(AvatarCatalog.indexOf('avatars/4avatarN3.png'), 2);
      expect(AvatarCatalog.indexOf(' 9avatarN3.png '), 6);
    });

    test('is null for an avatar outside the seven or no avatar', () {
      expect(AvatarCatalog.indexOf('user.png'), isNull);
      expect(AvatarCatalog.indexOf('1avatarN.png'), isNull);
      expect(AvatarCatalog.indexOf(''), isNull);
      expect(AvatarCatalog.indexOf(null), isNull);
    });
  });

  test('fileAt and assetAt follow the catalog', () {
    expect(AvatarCatalog.fileAt(1), '3avatarN3.png');
    expect(AvatarCatalog.fileAt(7), isNull);
    expect(AvatarCatalog.fileAt(-1), isNull);
    expect(AvatarCatalog.fileAt(null), isNull);
    expect(AvatarCatalog.assetAt(1), 'assets/avatars/3avatarN3.png');
  });
}
