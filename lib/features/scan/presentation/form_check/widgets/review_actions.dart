part of '../scan_review_view.dart';

/// The inline alert above the band (pano 4.8 kare 2): "Cevaplar gönderilemedi.
/// Düzeltmelerin duruyor; tekrar dene." (or "Bağlantı yok. Bağlantı gelince
/// tekrar dene." when the device is offline) in an `errorBg` box with a
/// WarningCircle, 16 from the sides, a live alert. It grows in over 250 ms
/// (a fade under "reduce motion") and goes when the student tries again.
class _ReviewAlert
    extends SelectorViewModelWidget<ScanReviewViewModel, (ReviewSend, bool)> {
  const _ReviewAlert();

  @override
  (ReviewSend, bool) selector(ScanReviewViewModel viewModel) =>
      (viewModel.send, viewModel.offline);

  @override
  Widget build(BuildContext context, (ReviewSend, bool) data) {
    final (send, offline) = data;
    final l10n = AppLocalizations.of(context);
    final duration = context.motion(AppMotion.base, reduced: AppMotion.fast);
    return AnimatedSize(
      duration: duration,
      curve: AppMotion.standard,
      alignment: Alignment.bottomCenter,
      child: send == ReviewSend.failed
          ? Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16,
                AppSpacing.s8,
                AppSpacing.s16,
                AppSpacing.s8,
              ),
              child: AppNoticeBox(
                tone: AppNoticeTone.error,
                message: offline
                    ? l10n.scan_answersOffline
                    : l10n.scan_answersSendFailed,
              ),
            )
          : const SizedBox(width: double.infinity),
    );
  }
}

/// The bottom band (pano 4.7): `bgSurface`, a hairline above, 16 / 16 / 0
/// padding, 12 between the buttons: the outline "Düzelt" with a pencil (120
/// wide) and the primary "Cevapları Onayla" (the rest). While the answers are
/// being sent "Düzelt" is off and the primary shows its spinner; after a
/// failure the primary reads "Tekrar Dene". No second confirmation is asked.
/// From a text scale of 1,25 the two buttons are stacked, the primary on top.
class _ReviewActions
    extends SelectorViewModelWidget<ScanReviewViewModel, ReviewSend> {
  const _ReviewActions();

  @override
  ReviewSend selector(ScanReviewViewModel viewModel) => viewModel.send;

  /// The width of "Düzelt" (pano 4.7).
  static const double _fixWidth = 120;

  /// From this text scale on the buttons are stacked.
  static const double _stackScale = 1.25;

  @override
  Widget build(BuildContext context, ReviewSend send) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final vm = getParentViewModel<ScanReviewViewModel>(context, listen: false);
    final safe = MediaQuery.paddingOf(context);
    final sending = send == ReviewSend.sending;
    // At a large text scale the two labels no longer share a row ("Cevapları
    // Onayla" was cut at 1,35): the primary goes on top, "Düzelt" under it.
    final stacked = MediaQuery.textScalerOf(context).scale(1) >= _stackScale;
    final fix = AppButton(
      label: l10n.scan_fix,
      variant: AppButtonVariant.outline,
      icon: PhosphorIconsRegular.pencilSimple,
      expand: true,
      onPressed: sending ? null : () => unawaited(vm.fix()),
    );
    final confirm = AppButton(
      label: switch (send) {
        ReviewSend.idle => l10n.scan_confirmAnswers,
        ReviewSend.sending => l10n.scan_sending,
        ReviewSend.failed => l10n.common_retry,
      },
      expand: true,
      loading: sending,
      onPressed: sending ? null : () => unawaited(vm.confirm()),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bgSurface,
        border: Border(top: BorderSide(color: colors.borderSubtle)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.s16,
          AppSpacing.s16,
          AppSpacing.s16,
          safe.bottom + AppSpacing.s8,
        ),
        child: stacked
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  confirm,
                  const SizedBox(height: AppSpacing.s12),
                  fix,
                ],
              )
            : Row(
                children: [
                  SizedBox(
                    width: MediaQuery.textScalerOf(context).scale(_fixWidth),
                    child: fix,
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(child: confirm),
                ],
              ),
      ),
    );
  }
}
