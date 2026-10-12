part of '../scan_capture_view.dart';

/// The hint pill under the top bar: "Cevap alanını çerçeveye al. / Ders adları
/// şeridi dışarıda kalsın." while the form is looked for, and a green check
/// with "Hazır. Telefonu sabit tut ve çek." once it is found (pano 4.3 kare 1
/// and 2; spec C67).
///
/// 15/24 · 600 white on `rgba(10,20,36,.80)`, 16 radius, 8 / 16 padding. The
/// text cross-fades in 150 ms; the pill is a live region, read as a status
/// when it changes.
class _CaptureHint extends ViewModelWidget<ScanCaptureViewModel> {
  const _CaptureHint();

  @override
  bool get reactive => false;

  @override
  Widget build(BuildContext context, ScanCaptureViewModel viewModel) {
    final safe = MediaQuery.paddingOf(context);
    return Positioned(
      top: safe.top + _CaptureLayout.hintTop,
      left: AppSpacing.s16,
      right: AppSpacing.s16,
      child: Center(
        child: ValueListenableBuilder<FormQuad?>(
          valueListenable: viewModel.liveForm,
          builder: (context, form, _) => _HintPill(found: form != null),
        ),
      ),
    );
  }
}

class _HintPill extends StatelessWidget {
  const _HintPill({required this.found});

  final bool found;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final fade = context.motion(AppMotion.fast, reduced: AppMotion.fast);
    final message = found ? l10n.scan_hintReady : l10n.scan_hintSearching;
    return Semantics(
      liveRegion: true,
      container: true,
      label: message,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.cameraPill,
          borderRadius: AppRadius.borderLg,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s8,
          ),
          child: AnimatedSwitcher(
            duration: fade,
            child: Row(
              key: ValueKey(found),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (found) ...[
                  PhosphorIcon(
                    PhosphorIconsRegular.check,
                    size: AppSize.iconInButton,
                    color: colors.success,
                  ),
                  const SizedBox(width: AppSpacing.s8),
                ],
                Flexible(
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: text.bodyStrong.copyWith(color: colors.textOnNavy),
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
