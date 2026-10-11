/// Where the avatar of the signed-in user lives in the app's assets.
///
/// The account keeps the avatar as a file name (`1avatarN3.png`) or, in older
/// data, with its folder (`avatars/1avatarN3.png`); the pictures are the 3D
/// caricature set under `assets/avatars/`. Pure and unit-tested.
abstract final class AvatarAsset {
  static const String _folder = 'assets/avatars/';

  /// The asset path of [photo]; `null` for no picture (the initials show).
  static String? pathOf(String? photo) {
    final name = photo?.trim();
    if (name == null || name.isEmpty) return null;
    if (name.startsWith('assets/')) return name;
    if (name.startsWith('avatars/')) return 'assets/$name';
    return '$_folder$name';
  }
}
