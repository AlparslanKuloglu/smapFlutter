import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/home/application/avatar_asset.dart';

void main() {
  test('a file name goes under assets/avatars', () {
    expect(AvatarAsset.pathOf('1avatarN3.png'), 'assets/avatars/1avatarN3.png');
  });

  test('a name with its folder keeps it', () {
    expect(
      AvatarAsset.pathOf('avatars/1avatarN3.png'),
      'assets/avatars/1avatarN3.png',
    );
  });

  test('a full asset path stays as it is', () {
    expect(
      AvatarAsset.pathOf('assets/avatars/4avatarN3.png'),
      'assets/avatars/4avatarN3.png',
    );
  });

  test('no photo means no picture (the initials show)', () {
    expect(AvatarAsset.pathOf(null), isNull);
    expect(AvatarAsset.pathOf(''), isNull);
    expect(AvatarAsset.pathOf('   '), isNull);
  });
}
