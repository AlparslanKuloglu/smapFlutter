/// The seven avatars a coach can give a student (Tur 12 D, brief 14.8;
/// board 1.17 "Avatar seçimi"): the 3D caricature set under
/// `assets/avatars/`, in the order the picker shows them. The file name is
/// what `NewStudent.photo` carries to the server.
///
/// The same seven as the sign-up form's picker (`RegisterViewModel
/// .avatarFiles`); a test keeps the two lists equal. Pure.
abstract final class StudentAvatars {
  /// The files, in picker order.
  static const List<String> files = [
    '1avatarN3.png',
    '3avatarN3.png',
    '4avatarN3.png',
    '5avatarN3.png',
    '6avatarN3.png',
    '8avatarN3.png',
    '9avatarN3.png',
  ];

  /// The avatar chosen when the form opens: the first (Tur 12 D "Listedeki ilk
  /// avatar seçili gelir"; choosing is not required).
  static const int initialIndex = 0;

  /// The three avatars of the empty state (pano 10.1 kare 3, 10.2 kare 4:
  /// av-1, av-4, av-3), as indices into [files].
  static const List<int> emptyStateIndices = [0, 3, 2];

  /// The asset path of the avatar at [index]; `null` outside the set.
  static String? assetOf(int index) => index >= 0 && index < files.length
      ? 'assets/avatars/${files[index]}'
      : null;

  /// The file name of the avatar at [index]; `null` outside the set.
  static String? fileOf(int index) =>
      index >= 0 && index < files.length ? files[index] : null;

  /// The index of [photo] (a file name, with or without its folder); `null`
  /// when it is not one of the seven (an older avatar of the server).
  static int? indexOf(String? photo) {
    final name = photo?.trim().split('/').last;
    if (name == null || name.isEmpty) return null;
    final index = files.indexOf(name);
    return index < 0 ? null : index;
  }
}
