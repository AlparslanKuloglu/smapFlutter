part of '../scan_request_view.dart';

/// "Talebin alındı" (pano 4.9 kare 4; `role=status`): an 80 pt `successBg`
/// circle with a CheckCircle (40, `success`), "Talebin alındı" (24/32 · 700),
/// "En geç 72 saat içinde hazır. Hazır olunca Analizlerim › Denemelerim'de
/// görünecek." and the one primary "Anasayfa". Kapat is at the top left. No
/// promise about notifications is made.
class _RequestDone extends ViewModelWidget<ScanRequestViewModel> {
  const _RequestDone({super.key});

  @override
  bool get reactive => false;

  /// The circle sits 220 from the top of the board's phone (62 is the safe
  /// area the status view adds itself).
  static const double _top = 158;

  @override
  Widget build(BuildContext context, ScanRequestViewModel viewModel) {
    final l10n = AppLocalizations.of(context);
    return AppStatusView(
      title: l10n.scan_enfDoneTitle,
      message: l10n.scan_enfDoneBody,
      tone: AppStatusTone.success,
      icon: PhosphorIconsRegular.checkCircle,
      size: AppStatusSize.flow,
      topPadding: _top,
      onClose: viewModel.close,
      closeLabel: l10n.common_close,
      primary: AppStatusAction(
        label: l10n.scan_goHome,
        onPressed: viewModel.goHome,
      ),
    );
  }
}
