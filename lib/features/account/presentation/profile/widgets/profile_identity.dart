part of '../profile_view.dart';

/// The avatar and "Avatarı Değiştir" (pano 9.2 kare 1 and 2): the 72 pt
/// avatar and a text button beside it (12 pulled to the left, 16 between).
/// The button opens the avatar sheet; from the read-only view it opens the
/// form first, because the choice is saved with "Kaydet". While editing the
/// chosen avatar shows at once.
class _ProfileAvatarRow
    extends SelectorViewModelWidget<ProfileViewModel, String?> {
  const _ProfileAvatarRow();

  /// Space between the avatar and the button (pano 9.2: 16, less the
  /// button's own 12 side padding).
  static const double _gap = 4;

  @override
  String? selector(ProfileViewModel viewModel) => viewModel.photo;

  @override
  Widget build(BuildContext context, String? photo) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ProfileViewModel>(
      context,
      listen: false,
    );
    final asset = AvatarAsset.pathOf(photo);
    return Row(
      children: [
        AppAvatar(
          name: viewModel.draft.name,
          image: asset == null ? null : AssetImage(asset),
          size: AppAvatarSize.sheet,
          decorative: true,
        ),
        const SizedBox(width: _gap),
        AppButton(
          label: l10n.account_profileChangeAvatar,
          variant: AppButtonVariant.text,
          size: AppButtonSize.md40,
          onPressed: () => unawaited(viewModel.changeAvatar()),
        ),
      ],
    );
  }
}
