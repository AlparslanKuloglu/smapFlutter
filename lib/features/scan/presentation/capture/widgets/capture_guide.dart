part of '../scan_capture_view.dart';

/// Where the pieces of the camera screen sit, from the board's 402 x 874
/// frame (pano 4.3; spec C67). The top values are measured from the bottom
/// of the safe area, which is 62 pt on the board's phone.
abstract final class _CaptureLayout {
  /// The guide frame's top, under the safe area (board: y 200 = 62 + 138).
  static const double guideTop = 138;

  /// The guide frame at its largest: 330 x 400 (ratio 0,825).
  static const double guideWidth = 330;
  static const double guideHeight = 400;
  static const double guideRatio = 0.825;

  /// Side margin of the guide frame (board: 36).
  static const double guideSide = 36;

  /// The corner marks: arm length and line width.
  static const double markArm = 30;
  static const double markWidth = 5;

  /// The shutter: 76, 38 above the bottom safe area (board: y 726).
  static const double shutter = 76;
  static const double shutterBottom = 38;

  /// Room kept between the guide frame and the shutter.
  static const double shutterGap = 24;

  /// The hint pill's top under the safe area (board: y 112).
  static const double hintTop = 50;

  /// The orange quadrilateral: line width, dot radius, dot border.
  static const double quadWidth = 3;
  static const double dotRadius = 7;
  static const double dotBorder = 3;

  /// The guide frame inside [size], for a screen with [safe] insets: the
  /// board's 330 x 400, shrunk to what fits between the hint and the shutter
  /// on a short screen.
  static Rect guide(Size size, EdgeInsets safe) {
    final top = safe.top + guideTop;
    final room =
        size.height - top - safe.bottom - shutterBottom - shutter - shutterGap;
    final height = room < guideHeight ? room : guideHeight;
    final byHeight = height * guideRatio;
    final byWidth = size.width - 2 * guideSide;
    var width = guideWidth;
    if (byHeight < width) width = byHeight;
    if (byWidth < width) width = byWidth;
    return Rect.fromLTWH(
      (size.width - width) / 2,
      top,
      width,
      width / guideRatio,
    );
  }
}

/// The dimmed outside of the guide frame, its corner marks, and, when the
/// camera sees the form, the orange quadrilateral with its four dots (pano
/// 4.3 kare 1 and 2; spec C67).
///
/// The marks fade to 35 % and the quadrilateral fades in over 150 ms when the
/// form is found (`AppMotion.fast`; the same under "reduce motion", it is an
/// opacity change). The live form is a `ValueListenable` because it changes
/// twice a second; only this layer repaints.
class _CaptureGuide extends ViewModelWidget<ScanCaptureViewModel> {
  const _CaptureGuide();

  @override
  bool get reactive => false;

  @override
  Widget build(BuildContext context, ScanCaptureViewModel viewModel) {
    final colors = context.appColors;
    final safe = MediaQuery.paddingOf(context);
    final fade = context.motion(AppMotion.fast, reduced: AppMotion.fast);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final guide = _CaptureLayout.guide(size, safe);
        return ValueListenableBuilder<FormQuad?>(
          valueListenable: viewModel.liveForm,
          builder: (context, form, _) {
            final preview = viewModel.session?.previewSize;
            final quad = form == null || preview == null
                ? null
                : CornerGeometry.toView(
                    form,
                    CornerGeometry.fitCover(preview, size),
                  );
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(end: quad == null ? 0 : 1),
              duration: fade,
              builder: (context, found, _) => CustomPaint(
                size: size,
                painter: _GuidePainter(
                  guide: guide,
                  quad: quad,
                  found: found,
                  veil: colors.cameraVeil,
                  mark: colors.textOnNavy,
                  accent: colors.accent,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _GuidePainter extends CustomPainter {
  const _GuidePainter({
    required this.guide,
    required this.quad,
    required this.found,
    required this.veil,
    required this.mark,
    required this.accent,
  });

  final Rect guide;
  final FormQuad? quad;

  /// 0 while searching, 1 once the form is found (animated).
  final double found;
  final Color veil;
  final Color mark;
  final Color accent;

  /// The corner marks' alpha once the form is found.
  static const double _markFoundAlpha = 0.35;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(Offset.zero & size)
        ..addRect(guide),
      Paint()..color = veil,
    );

    final alpha = 1 - (1 - _markFoundAlpha) * found;
    final marks = Paint()
      ..color = mark.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _CaptureLayout.markWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    const arm = _CaptureLayout.markArm;
    final path = Path()
      ..moveTo(guide.left, guide.top + arm)
      ..lineTo(guide.left, guide.top)
      ..lineTo(guide.left + arm, guide.top)
      ..moveTo(guide.right - arm, guide.top)
      ..lineTo(guide.right, guide.top)
      ..lineTo(guide.right, guide.top + arm)
      ..moveTo(guide.left, guide.bottom - arm)
      ..lineTo(guide.left, guide.bottom)
      ..lineTo(guide.left + arm, guide.bottom)
      ..moveTo(guide.right - arm, guide.bottom)
      ..lineTo(guide.right, guide.bottom)
      ..lineTo(guide.right, guide.bottom - arm);
    canvas.drawPath(path, marks);

    final found4 = quad;
    if (found4 == null || found <= 0) return;
    final outline = Path()..addPolygon(found4.corners, true);
    canvas
      ..drawPath(
        outline,
        Paint()..color = accent.withValues(alpha: 0.10 * found),
      )
      ..drawPath(
        outline,
        Paint()
          ..color = accent.withValues(alpha: found)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _CaptureLayout.quadWidth
          ..strokeJoin = StrokeJoin.round,
      );
    for (final corner in found4.corners) {
      canvas
        ..drawCircle(
          corner,
          _CaptureLayout.dotRadius,
          Paint()..color = accent.withValues(alpha: found),
        )
        ..drawCircle(
          corner,
          _CaptureLayout.dotRadius,
          Paint()
            ..color = mark.withValues(alpha: found)
            ..style = PaintingStyle.stroke
            ..strokeWidth = _CaptureLayout.dotBorder,
        );
    }
  }

  @override
  bool shouldRepaint(_GuidePainter oldDelegate) =>
      oldDelegate.guide != guide ||
      oldDelegate.quad != quad ||
      oldDelegate.found != found ||
      oldDelegate.veil != veil ||
      oldDelegate.mark != mark ||
      oldDelegate.accent != accent;
}
