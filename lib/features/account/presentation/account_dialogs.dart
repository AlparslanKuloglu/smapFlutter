/// The questions the account screens ask in sheets (UI guide §6 rule 15: a
/// sheet returns a typed result; the ViewModel that asked does the writing).
/// The ViewModels hold this interface, the app gives them the sheets
/// (`SheetAccountDialogs`), tests give them answers.
abstract interface class AccountDialogs {
  /// "Çıkış yapılsın mı?" (pano 9.1 kare 3): normal confirmation. With
  /// [pendingForms] above zero the body says how many forms would be lost.
  /// `true` when the person confirmed.
  Future<bool> confirmLogout({int pendingForms = 0});

  /// "Değişiklikler kaydedilmesin mi?" (pano 9.2): leaving the profile form
  /// with changes. `true` when the person wants to leave.
  Future<bool> confirmDiscardEdits();

  /// "Avatarını seç" (pano 9.2 kare 3): the index of the chosen avatar, or
  /// `null` when the sheet was dismissed. [selectedIndex] is the avatar in
  /// use, `null` when it is not one of the seven.
  Future<int?> pickAvatar({int? selectedIndex});

  /// "Koçluk kodun" (pano 14.11 kare 2): the coach's code sheet with the code,
  /// the explanation and "Kopyala" and "Paylaş". It does its own reading and
  /// copying; completes when it is closed.
  Future<void> showCoachCode();
}
