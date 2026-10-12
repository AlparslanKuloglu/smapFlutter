part of '../account_deletion_view.dart';

/// The two buttons above the bottom bar (pano 9.4 kare 2: "alta sabit, bottom
/// 118, aralık 12"): the red "Hesabımı Sil" and the quiet "Vazgeç". The red
/// one is the only danger button of the flow; the confirm sheet asks once
/// more.
class _DeletionActions extends StatelessWidget {
  const _DeletionActions();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<AccountDeletionViewModel>(
      context,
      listen: false,
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s16,
        AppSpacing.gutter,
        AppBottomBar.heightOf(context) + AppSpacing.s16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            label: l10n.deletion_confirmAction,
            variant: AppButtonVariant.danger,
            expand: true,
            onPressed: viewModel.requestDeletion,
          ),
          const SizedBox(height: AppSpacing.s12),
          AppButton(
            label: l10n.common_cancel,
            variant: AppButtonVariant.quiet,
            expand: true,
            onPressed: viewModel.cancel,
          ),
        ],
      ),
    );
  }
}
