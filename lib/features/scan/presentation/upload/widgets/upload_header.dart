part of '../scan_upload_view.dart';

/// The head of the screen (pano 4.5): "Formun okunuyor" (24/32 · 700) and
/// "Birkaç saniye sürebilir." (15/24, `textSecondary`) 4 below it; after a
/// failure "Formun gönderilemedi" and the reason. A live region ("polite"):
/// a change of step or failure is read out.
class _UploadHeader
    extends SelectorViewModelWidget<ScanUploadViewModel, ScanFailureKind?> {
  const _UploadHeader();

  @override
  ScanFailureKind? selector(ScanUploadViewModel viewModel) =>
      viewModel.failure?.kind;

  @override
  Widget build(BuildContext context, ScanFailureKind? failure) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final title = failure == null
        ? l10n.scan_uploadTitle
        : l10n.scan_uploadFailTitle;
    final sub = switch (failure) {
      null => l10n.scan_uploadSub,
      ScanFailureKind.timeout ||
      ScanFailureKind.server => l10n.scan_uploadTimeoutBody,
      ScanFailureKind.maintenance => l10n.scan_omrClosedBody,
      ScanFailureKind.connection ||
      ScanFailureKind.cancelled => l10n.scan_uploadFailBody,
    };
    return Semantics(
      container: true,
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: text.titleLg.copyWith(color: colors.textPrimary),
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(sub, style: text.body.copyWith(color: colors.textSecondary)),
        ],
      ),
    );
  }
}
