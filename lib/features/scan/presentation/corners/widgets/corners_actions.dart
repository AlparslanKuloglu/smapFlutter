part of '../scan_corners_view.dart';

/// The band under the photo (pano 4.4): 132 high on the board, `rgba(10,20,36,
/// .92)`, 16 / 16 / 0 padding and 12 between the two buttons: the outline
/// "Tekrar Çek" (150 wide) and the primary "Devam" (the rest), both in the
/// camera's dark set (the theme is dark, so they are, light navy fill for the
/// primary). "Devam" shows its spinner while the photo is being straightened.
class _CornersBand extends SelectorViewModelWidget<ScanCornersViewModel, bool> {
  const _CornersBand();

  @override
  bool selector(ScanCornersViewModel viewModel) => viewModel.working;

  /// The width of "Tekrar Çek" (pano 4.4).
  static const double _retakeWidth = 150;

  @override
  Widget build(BuildContext context, bool busy) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final vm = getParentViewModel<ScanCornersViewModel>(context, listen: false);
    final safe = MediaQuery.paddingOf(context);
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: _CornersLayout.bandHeight(safe.bottom),
      child: DecoratedBox(
        decoration: BoxDecoration(color: colors.cameraBand),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s16,
            AppSpacing.s16,
            AppSpacing.s16,
            0,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: Row(
              children: [
                SizedBox(
                  width: _retakeWidth,
                  child: AppButton(
                    label: l10n.scan_retake,
                    variant: AppButtonVariant.outline,
                    expand: true,
                    onPressed: busy ? null : vm.retake,
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: AppButton(
                    label: l10n.scan_next,
                    expand: true,
                    loading: busy,
                    onPressed: busy ? null : vm.next,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
