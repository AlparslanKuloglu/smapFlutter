part of '../scan_corners_view.dart';

/// The quadrilateral over the photo (pano 4.4): everything of the photo
/// outside it dimmed (`rgba(0,0,0,.55)`), the orange edge (3 pt) and four
/// handles. A handle is a white ring around an orange dot, 18 pt across and
/// 28 while it is dragged (spec C68).
class _QuadPainter extends CustomPainter {
  const _QuadPainter({
    required this.quad,
    required this.image,
    required this.active,
    required this.veil,
    required this.accent,
    required this.ring,
  });

  /// The corners, in view points.
  final FormQuad quad;

  /// Where the photo is drawn, in the same points.
  final Rect image;
  final QuadCorner? active;
  final Color veil;
  final Color accent;
  final Color ring;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Path()..addPolygon(quad.corners, true);
    canvas
      ..drawPath(
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(image)
          ..addPath(outline, Offset.zero),
        Paint()..color = veil,
      )
      ..drawPath(
        outline,
        Paint()
          ..color = accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = _CornersLayout.edge
          ..strokeJoin = StrokeJoin.round,
      );
    for (final corner in QuadCorner.values) {
      final radius = corner == active
          ? _CornersLayout.handleRadiusActive
          : _CornersLayout.handleRadius;
      canvas
        ..drawCircle(quad[corner], radius, Paint()..color = ring)
        ..drawCircle(
          quad[corner],
          radius - _CornersLayout.handleBorder,
          Paint()..color = accent,
        );
    }
  }

  @override
  bool shouldRepaint(_QuadPainter oldDelegate) =>
      oldDelegate.quad != quad ||
      oldDelegate.image != image ||
      oldDelegate.active != active ||
      oldDelegate.veil != veil ||
      oldDelegate.accent != accent ||
      oldDelegate.ring != ring;
}
