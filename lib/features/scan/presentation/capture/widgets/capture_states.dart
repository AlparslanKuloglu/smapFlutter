part of '../scan_capture_view.dart';

/// The preview page: the camera, the guide, the top bar, the hint and the
/// shutter, stacked (pano 4.3).
class _CapturePreview extends ViewModelWidget<ScanCaptureViewModel> {
  const _CapturePreview({super.key});

  @override
  bool get reactive => false;

  @override
  Widget build(BuildContext context, ScanCaptureViewModel viewModel) {
    final session = viewModel.session;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (session != null) session.buildPreview(),
        const _CaptureGuide(),
        CameraTopBar(
          title: AppLocalizations.of(context).scan_topTitle,
          onClose: viewModel.close,
          onHelp: viewModel.showTutorial,
        ),
        const _CaptureHint(),
        const _CaptureShutter(),
      ],
    );
  }
}

/// The camera is starting: the dark page with a spinner and the top bar (so
/// Kapat is there the whole time).
class _CaptureOpening extends ViewModelWidget<ScanCaptureViewModel> {
  const _CaptureOpening({super.key});

  @override
  bool get reactive => false;

  @override
  Widget build(BuildContext context, ScanCaptureViewModel viewModel) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: AppSpinner(
            color: colors.textOnNavy,
            trackColor: colors.textOnNavy.withValues(alpha: 0.3),
            semanticLabel: l10n.scan_cameraLoadingA11y,
          ),
        ),
        CameraTopBar(title: l10n.scan_topTitle, onClose: viewModel.close),
      ],
    );
  }
}

/// "Kamera açılamadı" (pano 4.10 kare 4): the camera stage's own failure
/// screen, dark. An 80 pt badge in `bgRaised` with a CameraSlash in
/// `textPrimary`, the title (20/28), "Başka bir uygulama kamerayı kullanıyor
/// olabilir. Onu kapatıp tekrar dene.", Kapat at the top left, and the one
/// primary "Tekrar Dene" (the camera set's light navy) at the bottom. The
/// plugin's own "No Camera" text is never shown. `AppHaptics.error` plays
/// when the screen appears (the view model does).
class _CaptureFailed extends ViewModelWidget<ScanCaptureViewModel> {
  const _CaptureFailed({super.key});

  @override
  bool get reactive => false;

  /// The badge sits 260 from the top on the board; 62 of that is the safe area
  /// the status view adds itself.
  static const double _top = 198;

  /// The CameraSlash inside the badge (pano 4.10 kare 4: 36).
  static const double _badgeIcon = 36;

  @override
  Widget build(BuildContext context, ScanCaptureViewModel viewModel) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        AppStatusView(
          title: l10n.scan_cameraFailTitle,
          message: l10n.scan_cameraFailBody,
          size: AppStatusSize.compact,
          topPadding: _top,
          leading: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.bgRaised,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: PhosphorIcon(
                PhosphorIconsRegular.cameraSlash,
                size: _badgeIcon,
                color: colors.textPrimary,
              ),
            ),
          ),
          primary: AppStatusAction(
            label: l10n.common_retry,
            onPressed: viewModel.init,
          ),
          secondary: viewModel.canPickFromGallery
              ? AppStatusAction(
                  label: l10n.scan_debugGalleryPick,
                  variant: AppButtonVariant.quiet,
                  onPressed: viewModel.pickFromGallery,
                )
              : null,
        ),
        CameraTopBar(title: l10n.scan_topTitle, onClose: viewModel.close),
      ],
    );
  }
}
