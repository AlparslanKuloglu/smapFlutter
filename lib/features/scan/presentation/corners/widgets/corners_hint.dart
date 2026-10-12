part of '../scan_corners_view.dart';

/// The hint card (pano 4.4 kare 1): under the top bar, 16 from the sides, a
/// `bgRaised` card (radius 16, 12 padding, 12 apart) with a white mini
/// picture of the form (44 x 64), "Noktaları cevap alanının köşelerine getir."
/// (15/24 · 600), "Ders adları şeridi dışarıda kalsın." (13/20,
/// `textSecondary`) and the text button "Bir daha gösterme", which hides it for
/// good. It fades out while a handle is dragged (150 ms) and is not drawn once
/// hidden.
class _CornersHint extends SelectorViewModelWidget<ScanCornersViewModel, bool> {
  const _CornersHint();

  @override
  bool selector(ScanCornersViewModel viewModel) => viewModel.hintOffered;

  /// The card's top, under the safe area (board: y 110 = 62 + 48).
  static const double _top = 48;

  @override
  Widget build(BuildContext context, bool offered) {
    if (!offered) return const SizedBox.shrink();
    final vm = getParentViewModel<ScanCornersViewModel>(context, listen: false);
    final safe = MediaQuery.paddingOf(context);
    final fade = context.motion(AppMotion.fast, reduced: AppMotion.fast);
    return Positioned(
      top: safe.top + _top,
      left: AppSpacing.s16,
      right: AppSpacing.s16,
      child: ValueListenableBuilder<QuadCorner?>(
        valueListenable: vm.active,
        builder: (context, dragging, child) => IgnorePointer(
          ignoring: dragging != null,
          child: AnimatedOpacity(
            opacity: dragging == null ? 1 : 0,
            duration: fade,
            child: child,
          ),
        ),
        child: const _HintCard(),
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard();

  static const double _textButtonInset = AppSpacing.s12;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final vm = getParentViewModel<ScanCornersViewModel>(context, listen: false);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bgRaised,
        borderRadius: AppRadius.borderLg,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _MiniForm(),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.scan_cornersHint,
                    style: text.bodyStrong.copyWith(color: colors.textPrimary),
                  ),
                  Text(
                    l10n.scan_cornersHintSub,
                    style: text.caption.copyWith(color: colors.textSecondary),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    // The text button pads its label by 12; the board sets the
                    // label flush with the text above it.
                    child: Transform.translate(
                      offset: const Offset(-_HintCard._textButtonInset, 0),
                      child: AppButton(
                        label: l10n.scan_dontShowAgain,
                        variant: AppButtonVariant.text,
                        size: AppButtonSize.md40,
                        focusGapColor: colors.bgRaised,
                        onPressed: vm.hideHint,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The white mini picture of the form: 44 x 64, radius 8, 4 padding.
class _MiniForm extends StatelessWidget {
  const _MiniForm();

  static const double _width = 44;
  static const double _height = 64;
  static const double _pad = 4;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: SmapColors.light.bgSurface,
          borderRadius: AppRadius.borderSm,
        ),
        child: Padding(
          padding: const EdgeInsets.all(_pad),
          child: CustomPaint(
            size: const Size(_width - 2 * _pad, _height - 2 * _pad),
            painter: _MiniFormPainter(colors),
          ),
        ),
      ),
    );
  }
}

class _MiniFormPainter extends CustomPainter {
  const _MiniFormPainter(this.colors);

  final SmapColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(
        size.width / (OmrFormArt.width + 2),
        size.height / (OmrFormArt.height + 2),
      )
      ..translate(1, 1);
    OmrFormArt.paint(canvas, colors, hatchStrip: false, frame: false);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MiniFormPainter oldDelegate) =>
      oldDelegate.colors != colors;
}
