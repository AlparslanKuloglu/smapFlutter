import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/theme_context.dart';

/// Where the focus ring sits relative to the control (spec §1.4; board 1.9
/// "Odak").
enum AppFocusRingStyle {
  /// 2 pt gap in the page color, then a 2 pt ring, outside the control
  /// (`0 0 0 2 <zemin>, 0 0 0 4 focus-ring`). Buttons, chips, inputs.
  gapped,

  /// A 2 pt ring touching the control, no gap (the text button).
  flush,

  /// A 2 pt ring drawn inside the control (`inset 0 0 0 2`, a segment
  /// option).
  inset,
}

/// Draws the keyboard focus ring of the design around [child] while
/// [focused] is true (spec §1.4; handoff 11.12 `focus-ring`).
///
/// The ring paints outside the child's bounds without taking layout space, so
/// the parent leaves 4 pt of room for it. [gapColor] is the page color
/// behind the control (the canvas by default, `bgRaised` inside a sheet).
class AppFocusRing extends StatelessWidget {
  const AppFocusRing({
    required this.focused,
    required this.child,
    this.borderRadius = AppRadius.borderMd,
    this.style = AppFocusRingStyle.gapped,
    this.gapColor,
    super.key,
  });

  final bool focused;
  final Widget child;

  /// The radius of the control the ring surrounds.
  final BorderRadius borderRadius;
  final AppFocusRingStyle style;

  /// The color of the 2 pt gap; defaults to `bgCanvas`.
  final Color? gapColor;

  @override
  Widget build(BuildContext context) {
    if (!focused) return child;
    final colors = context.appColors;
    return CustomPaint(
      foregroundPainter: _FocusRingPainter(
        radius: borderRadius,
        style: style,
        ringColor: colors.focusRing,
        gapColor: gapColor ?? colors.bgCanvas,
      ),
      child: child,
    );
  }
}

class _FocusRingPainter extends CustomPainter {
  const _FocusRingPainter({
    required this.radius,
    required this.style,
    required this.ringColor,
    required this.gapColor,
  });

  static const double _stroke = 2;

  final BorderRadius radius;
  final AppFocusRingStyle style;
  final Color ringColor;
  final Color gapColor;

  RRect _grow(Rect rect, double by) {
    final grown = rect.inflate(by);
    return RRect.fromRectAndCorners(
      grown,
      topLeft: _corner(radius.topLeft, by),
      topRight: _corner(radius.topRight, by),
      bottomLeft: _corner(radius.bottomLeft, by),
      bottomRight: _corner(radius.bottomRight, by),
    );
  }

  Radius _corner(Radius corner, double by) {
    final x = corner.x + by;
    final y = corner.y + by;
    return Radius.elliptical(x < 0 ? 0 : x, y < 0 ? 0 : y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    Paint line(Color color) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..color = color;
    switch (style) {
      case AppFocusRingStyle.gapped:
        // Stroke centers: 1 pt out is the gap, 3 pt out is the ring.
        canvas
          ..drawRRect(_grow(rect, _stroke / 2), line(gapColor))
          ..drawRRect(_grow(rect, _stroke * 1.5), line(ringColor));
      case AppFocusRingStyle.flush:
        canvas.drawRRect(_grow(rect, _stroke / 2), line(ringColor));
      case AppFocusRingStyle.inset:
        canvas.drawRRect(_grow(rect, -_stroke / 2), line(ringColor));
    }
  }

  @override
  bool shouldRepaint(_FocusRingPainter oldDelegate) =>
      oldDelegate.radius != radius ||
      oldDelegate.style != style ||
      oldDelegate.ringColor != ringColor ||
      oldDelegate.gapColor != gapColor;
}
