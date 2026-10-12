part of '../profile_view.dart';

/// "Hesabı Sil" at the bottom of the profile (pano 9.2 / 9.4 kare 1): a
/// 1 pt rule 8 under the form, then the red text button with a Trash, pulled
/// to the left edge. It opens the deletion flow of E14b; while that screen
/// is not in the router the link is not drawn.
class _ProfileDelete extends SelectorViewModelWidget<ProfileViewModel, bool> {
  const _ProfileDelete();

  /// Space between the form and the rule (pano 9.4 kare 1: margin-top 8,
  /// on top of the 16 between rows).
  static const double _ruleTop = _fieldGap + AppSpacing.s8;

  @override
  bool selector(ProfileViewModel viewModel) => viewModel.canDeleteAccount;

  @override
  Widget build(BuildContext context, bool canDelete) {
    if (!canDelete) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ProfileViewModel>(
      context,
      listen: false,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: _ruleTop),
        Divider(height: 1, thickness: 1, color: context.appColors.borderSubtle),
        const SizedBox(height: AppSpacing.s8),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AlignedTextAction(
            child: AppButton(
              label: l10n.account_profileDelete,
              variant: AppButtonVariant.textDanger,
              size: AppButtonSize.md40,
              icon: PhosphorIconsRegular.trash,
              onPressed: () => unawaited(viewModel.openDeletion()),
            ),
          ),
        ),
      ],
    );
  }
}
