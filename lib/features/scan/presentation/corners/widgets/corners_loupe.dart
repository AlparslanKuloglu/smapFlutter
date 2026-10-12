part of '../scan_corners_view.dart';

/// The loupe (pano 4.4 kare 2; spec C68): a 116 pt circle with a 3 pt white
/// ring that magnifies what is under the dragged handle 2,6 times, set 70
/// right and 150 above it (kept inside the photo's room, and dropped below the
/// finger near the top) so the finger does not cover it. An orange cross, 20
/// long and 2 thick, marks the handle's exact place. It scales in over 100 ms
/// (nothing under "reduce motion") and goes away when the finger lifts.
class _CornersLoupe extends ViewModelWidget<ScanCornersViewModel> {
  const _CornersLoupe({required this.area, required this.image});

  final Size area;
  final Rect image;

  @override
  bool get reactive => false;

  @override
  Widget build(BuildContext context, ScanCornersViewModel viewModel) {
    return ValueListenableBuilder<QuadCorner?>(
      valueListenable: viewModel.active,
      builder: (context, corner, _) {
        if (corner == null) return const SizedBox.shrink();
        return ValueListenableBuilder<FormQuad>(
          valueListenable: viewModel.quad,
          builder: (context, quad, _) {
            final handle = CornerGeometry.toView(quad, image)[corner];
            final center = CornerGeometry.loupeCenter(
              handle: handle,
              bounds: Offset.zero & area,
              diameter: _CornersLayout.loupe,
            );
            const half = _CornersLayout.loupe / 2;
            return Positioned(
              left: center.dx - half,
              top: center.dy - half,
              child: IgnorePointer(
                child: _LoupePopIn(
                  child: RawMagnifier(
                    size: const Size.square(_CornersLayout.loupe),
                    magnificationScale: _CornersLayout.loupeScale,
                    focalPointOffset: handle - center,
                    decoration: MagnifierDecoration(
                      shape: CircleBorder(
                        side: BorderSide(
                          color: context.appColors.textOnNavy,
                          width: _CornersLayout.loupeRing,
                        ),
                      ),
                    ),
                    child: CustomPaint(
                      painter: _CrossPainter(context.appColors.accent),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Scales its child in from 0,6 to 1 in 100 ms when it appears.
class _LoupePopIn extends StatelessWidget {
  const _LoupePopIn({required this.child});

  final Widget child;

  static const double _from = 0.6;

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: _from, end: 1),
      duration: AppMotion.instant,
      curve: AppMotion.enter,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: child,
    );
  }
}

/// The orange cross in the middle of the loupe.
class _CrossPainter extends CustomPainter {
  const _CrossPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = _CornersLayout.crossWidth;
    final center = size.center(Offset.zero);
    const arm = _CornersLayout.crossLength / 2;
    canvas
      ..drawLine(
        center - const Offset(arm, 0),
        center + const Offset(arm, 0),
        paint,
      )
      ..drawLine(
        center - const Offset(0, arm),
        center + const Offset(0, arm),
        paint,
      );
  }

  @override
  bool shouldRepaint(_CrossPainter oldDelegate) => oldDelegate.color != color;
}
