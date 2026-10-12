part of '../scan_capture_view.dart';

/// The shutter (pano 4.3; spec C67): a 76 pt circle, a 4 pt white ring around
/// a 60 pt orange disk, 38 above the bottom safe area. Pressed it scales to
/// 0,92 in 100 ms (no scale under "reduce motion") and plays
/// `AppHaptics.medium`; it works whether or not a form is found ("her zaman
/// çalışır: algılama bir öneri, zorunluluk değil"). Read as "Fotoğraf çek".
class _CaptureShutter
    extends SelectorViewModelWidget<ScanCaptureViewModel, bool> {
  const _CaptureShutter();

  @override
  bool selector(ScanCaptureViewModel viewModel) =>
      viewModel.phase == CapturePhase.ready;

  /// The white ring's width and the gap inside it (76 = 60 + 2 x (4 + 4)).
  static const double _ring = 4;
  static const double _disk = 60;

  @override
  Widget build(BuildContext context, bool enabled) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final vm = getParentViewModel<ScanCaptureViewModel>(context, listen: false);
    final safe = MediaQuery.paddingOf(context);
    return Positioned(
      bottom: safe.bottom + _CaptureLayout.shutterBottom,
      left: 0,
      right: 0,
      child: Center(
        child: Semantics(
          button: true,
          enabled: enabled,
          label: l10n.scan_shutterA11y,
          excludeSemantics: true,
          onTap: enabled ? vm.capture : null,
          child: AppPressable(
            onTap: enabled ? vm.capture : null,
            scale: AppMotion.shutterScale,
            builder: (context, states) => SizedBox.square(
              dimension: _CaptureLayout.shutter,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.textOnNavy, width: _ring),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(_ring),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: enabled ? colors.accent : colors.borderStrong,
                    ),
                    child: const SizedBox.square(dimension: _disk),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
