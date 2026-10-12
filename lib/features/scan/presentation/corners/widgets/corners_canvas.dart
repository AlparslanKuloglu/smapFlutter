part of '../scan_corners_view.dart';

/// Where the photo's room starts and ends on the corner screen (pano 4.4).
abstract final class _CornersLayout {
  /// The band at the bottom: 16 above the buttons, 48 buttons and 68 below
  /// them on the board (34 of it the home indicator's safe area).
  static const double bandTop = AppSpacing.s16;
  static const double bandBelow = AppSpacing.s32;

  /// The room the photo takes starts under the top bar.
  static double photoTop(double safeTop) => safeTop + CameraTopBar.below;

  /// The band's height with the bottom safe area.
  static double bandHeight(double safeBottom) =>
      bandTop + AppSize.touch + bandBelow + safeBottom;

  /// The handle: visible radius and its radius while dragged (18 and 28 pt),
  /// and the white border.
  static const double handleRadius = 9;
  static const double handleRadiusActive = 14;
  static const double handleBorder = 3;

  /// The quadrilateral's edge.
  static const double edge = 3;

  /// The loupe (pano 4.4 kare 2): 116 pt, 2,6 times, a 3 pt white ring, an
  /// orange cross 20 long and 2 thick.
  static const double loupe = 116;
  static const double loupeScale = 2.6;
  static const double loupeRing = 3;
  static const double crossLength = 20;
  static const double crossWidth = 2;
}

/// The photo with the quadrilateral and its handles over it, and the loupe
/// (pano 4.4). A finger within reach of a handle picks it up
/// (`CornerGeometry.pickRadius`, a 48 pt touch area and a little more) and
/// drags it; the quadrilateral is drawn by a painter that listens to the
/// handles, so a drag repaints one layer.
class _CornersCanvas extends ViewModelWidget<ScanCornersViewModel> {
  const _CornersCanvas();

  @override
  bool get reactive => false;

  @override
  Widget build(BuildContext context, ScanCornersViewModel viewModel) {
    final safe = MediaQuery.paddingOf(context);
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    return Positioned(
      top: _CornersLayout.photoTop(safe.top),
      left: 0,
      right: 0,
      bottom: _CornersLayout.bandHeight(safe.bottom),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final area = constraints.biggest;
          final image = CornerGeometry.fitContain(viewModel.photo.size, area);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (details) {
              final corner = CornerGeometry.pick(
                CornerGeometry.toView(viewModel.quad.value, image),
                details.localPosition,
              );
              if (corner == null) return;
              viewModel.dragStart(
                corner,
                CornerGeometry.toUnit(details.localPosition, image),
              );
            },
            onPanUpdate: (details) => viewModel.dragUpdate(
              CornerGeometry.toUnit(details.localPosition, image),
            ),
            onPanEnd: (_) => viewModel.dragEnd(),
            onPanCancel: viewModel.dragEnd,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fromRect(
                  rect: image,
                  child: Image.memory(
                    viewModel.photo.bytes,
                    fit: BoxFit.fill,
                    gaplessPlayback: true,
                    cacheWidth: _decodeWidth(context, image.width),
                  ),
                ),
                ListenableBuilder(
                  listenable: Listenable.merge([
                    viewModel.quad,
                    viewModel.active,
                  ]),
                  builder: (context, _) => CustomPaint(
                    size: area,
                    painter: _QuadPainter(
                      quad: CornerGeometry.toView(viewModel.quad.value, image),
                      image: image,
                      active: viewModel.active.value,
                      veil: colors.cameraVeilStrong,
                      accent: colors.accent,
                      ring: colors.textOnNavy,
                    ),
                  ),
                ),
                for (final corner in QuadCorner.values)
                  _HandleSemantics(
                    corner: corner,
                    image: image,
                    label: _cornerLabel(l10n, corner),
                  ),
                _CornersLoupe(area: area, image: image),
              ],
            ),
          );
        },
      ),
    );
  }

  /// The decode width: what the photo needs on this screen, not the sensor's
  /// 12 million pixels.
  static int _decodeWidth(BuildContext context, double shown) {
    final scale = MediaQuery.devicePixelRatioOf(context);
    return (shown * scale).round().clamp(1, 4096);
  }

  static String _cornerLabel(AppLocalizations l10n, QuadCorner corner) =>
      switch (corner) {
        QuadCorner.topLeft => l10n.scan_cornerTopLeftA11y,
        QuadCorner.topRight => l10n.scan_cornerTopRightA11y,
        QuadCorner.bottomRight => l10n.scan_cornerBottomRightA11y,
        QuadCorner.bottomLeft => l10n.scan_cornerBottomLeftA11y,
      };
}

/// One handle for the screen reader: its name ("Sol alt köşe") and four
/// actions that move it a step (spec C68 "dört yönlü ayar eylemi").
class _HandleSemantics extends ViewModelWidget<ScanCornersViewModel> {
  const _HandleSemantics({
    required this.corner,
    required this.image,
    required this.label,
  });

  final QuadCorner corner;
  final Rect image;
  final String label;

  @override
  bool get reactive => false;

  @override
  Widget build(BuildContext context, ScanCornersViewModel viewModel) {
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<FormQuad>(
      valueListenable: viewModel.quad,
      builder: (context, quad, _) {
        final at = CornerGeometry.toView(quad, image)[corner];
        return Positioned(
          left: at.dx - AppSize.touch / 2,
          top: at.dy - AppSize.touch / 2,
          width: AppSize.touch,
          height: AppSize.touch,
          child: Semantics(
            label: label,
            customSemanticsActions: {
              CustomSemanticsAction(label: l10n.scan_cornerMoveUpA11y): () =>
                  viewModel.nudge(corner, dy: -1),
              CustomSemanticsAction(label: l10n.scan_cornerMoveDownA11y): () =>
                  viewModel.nudge(corner, dy: 1),
              CustomSemanticsAction(label: l10n.scan_cornerMoveLeftA11y): () =>
                  viewModel.nudge(corner, dx: -1),
              CustomSemanticsAction(label: l10n.scan_cornerMoveRightA11y): () =>
                  viewModel.nudge(corner, dx: 1),
            },
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}
