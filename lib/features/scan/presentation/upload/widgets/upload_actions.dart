part of '../scan_upload_view.dart';

/// The buttons at the bottom (pano 4.5): the text button "Vazgeç" centered
/// while the job runs; after a failure the primary "Tekrar Dene" over the quiet
/// "Yeni Fotoğraf" (12 apart, full width, 16 from the sides). "Vazgeç" stops the
/// call and goes back to the corners with the photo.
class _UploadActions
    extends SelectorViewModelWidget<ScanUploadViewModel, bool> {
  const _UploadActions();

  @override
  bool selector(ScanUploadViewModel viewModel) => viewModel.failure != null;

  @override
  Widget build(BuildContext context, bool failed) {
    final l10n = AppLocalizations.of(context);
    final vm = getParentViewModel<ScanUploadViewModel>(context, listen: false);
    final safe = MediaQuery.paddingOf(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s16,
        0,
        AppSpacing.s16,
        safe.bottom + AppSpacing.s8,
      ),
      child: failed
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppButton(
                  label: l10n.common_retry,
                  expand: true,
                  autofocus: true,
                  onPressed: vm.start,
                ),
                const SizedBox(height: AppSpacing.s12),
                AppButton(
                  label: l10n.scan_newPhoto,
                  variant: AppButtonVariant.quiet,
                  expand: true,
                  onPressed: vm.newPhoto,
                ),
              ],
            )
          : Align(
              alignment: Alignment.bottomCenter,
              heightFactor: 1,
              child: AppButton(
                label: l10n.common_cancel,
                variant: AppButtonVariant.text,
                onPressed: vm.cancel,
              ),
            ),
    );
  }
}
