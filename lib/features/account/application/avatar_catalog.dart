/// The seven avatars a person can pick (pano 9.2 kare 3 "7 avatar"; sign-up
/// pano 2.5), as file names under `assets/avatars/`.
///
/// The order is the order of the picker and the same as the sign-up form's,
/// so "Avatar 3" is the same picture on both. The account stores the file
/// name (`1avatarN3.png`); older accounts may carry a file outside this set
/// or a path with its folder (`avatars/1avatarN3.png`), which read as "no
/// avatar chosen" in the picker but still draw as they are. Pure and
/// unit-tested.
abstract final class AvatarCatalog {
  /// The picker's avatars, in order.
  static const List<String> files = [
    '1avatarN3.png',
    '3avatarN3.png',
    '4avatarN3.png',
    '5avatarN3.png',
    '6avatarN3.png',
    '8avatarN3.png',
    '9avatarN3.png',
  ];

  /// How many avatars there are.
  static int get count => files.length;

  /// The index of the avatar [photo] names, `null` when it is empty or not
  /// one of the seven. A path is read by its last segment.
  static int? indexOf(String? photo) {
    final name = photo?.trim().split('/').last;
    if (name == null || name.isEmpty) return null;
    final index = files.indexOf(name);
    return index < 0 ? null : index;
  }

  /// The file name of avatar [index]; `null` outside the catalog.
  static String? fileAt(int? index) =>
      index == null || index < 0 || index >= files.length ? null : files[index];

  /// The asset path of avatar [index] (`assets/avatars/1avatarN3.png`).
  static String assetAt(int index) => 'assets/avatars/${files[index]}';
}
