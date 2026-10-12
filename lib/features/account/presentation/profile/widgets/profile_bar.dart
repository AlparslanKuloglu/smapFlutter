part of '../profile_view.dart';

/// The bar of Profil (C82 detail bar + C03 bar action; pano 9.2 kare 1 and
/// 2): reading has Back and the outlined "Düzenle" with a pencil; editing
/// has the text "Vazgeç" at the left and the filled "Kaydet" at the right,
/// which is off until a field changed (and while the device is offline or a
/// save runs). The large title "Profil" follows it in the page.
class _ProfileBar
    extends SelectorViewModelWidget<ProfileViewModel, ProfileBarData> {
  const _ProfileBar();

  @override
  ProfileBarData selector(ProfileViewModel viewModel) => viewModel.bar;

  @override
  Widget build(BuildContext context, ProfileBarData data) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ProfileViewModel>(
      context,
      listen: false,
    );
    final editing = data.mode == ProfileMode.edit;
    return AppDetailBar(
      title: l10n.account_profileTitle,
      leading: editing ? AppDetailBarLeading.cancel : AppDetailBarLeading.back,
      onLeading: editing ? () => unawaited(viewModel.cancel()) : null,
      action: editing
          ? AppBarAction(
              label: l10n.common_save,
              style: AppBarActionStyle.filled,
              onPressed: data.canSave
                  ? () => unawaited(viewModel.save())
                  : null,
            )
          : (data.canEdit
                ? AppBarAction(
                    label: l10n.account_profileEdit,
                    icon: PhosphorIconsRegular.pencilSimple,
                    onPressed: viewModel.edit,
                  )
                : null),
    );
  }
}
