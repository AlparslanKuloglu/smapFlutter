import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/smap_colors.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/onboarding/presentation/widgets/onboarding_visual_frame.dart';
import 'package:smap/l10n/app_localizations.dart';

/// The picture of intro page 1, "Optik formunu kamerayla okut" (pano 2.1
/// kare 2, `OnboardingScanVisual`; spec §1 "Diğer").
///
/// A 250 x 330 phone mock-up (radius 28, the 16 % intro shadow): the camera
/// view with an optik form lying a little askew (header, three boxes, the
/// 4 x 40 answer grid), the orange dashed quadrilateral with four corner
/// handles that the scan flow draws (pano 4.4), and the 56 pt orange camera
/// button (radius 16, navy icon) 14 pt from the bottom. Drawn with a painter
/// in the theme's colors; one image for the screen reader.
class OnboardingScanVisual extends StatelessWidget {
  const OnboardingScanVisual({super.key});

  /// The mock-up on the board.
  static const double width = 250;
  static const double height = 330;

  /// The mock-up's corner (28 is the board's own value for this picture; it
  /// is not a radius token).
  static const BorderRadius _corner = BorderRadius.all(Radius.circular(28));

  /// The picture inside the phone is a photograph, so it keeps the light
  /// theme's colors in the dark theme too (a dark room, a light sheet); only
  /// the phone's own shadow and the camera button follow the theme.
  static const SmapColors photo = SmapColors.light;

  /// The camera button: edge and distance from the bottom.
  static const double _button = 56;
  static const double _buttonBottom = 14;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    return Semantics(
      image: true,
      label: l10n.onboarding_scanVisualA11y,
      excludeSemantics: true,
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: _corner,
            boxShadow: OnboardingShadows.phone(colors),
          ),
          child: ClipRRect(
            borderRadius: _corner,
            child: Stack(
              children: [
                const Positioned.fill(
                  child: CustomPaint(painter: _ScanPhotoPainter(photo)),
                ),
                Positioned(
                  bottom: _buttonBottom,
                  left: (width - _button) / 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.accent,
                      borderRadius: AppRadius.borderLg,
                    ),
                    child: SizedBox.square(
                      dimension: _button,
                      child: Center(
                        child: PhosphorIcon(
                          PhosphorIconsRegular.camera,
                          size: 28,
                          color: colors.onAccent,
                        ),
                      ),
                    ),
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

/// The camera view: background, the askew form, the dashed quadrilateral and
/// its four handles. Coordinates are the board's (250 x 330 frame; the form
/// is 300 x 470 scaled 0,53, turned -4 degrees). Always painted with the light
/// theme's colors: a photograph does not invert in the dark theme.
class _ScanPhotoPainter extends CustomPainter {
  const _ScanPhotoPainter(this.colors);

  final SmapColors colors;

  /// The form, as the board draws it: size, and the grid's rows and columns.
  static const double _formW = 300;
  static const double _formH = 470;
  static const double _rowH = 8.5;
  static const int _columns = 4;
  static const double _columnW = 72;
  static const double _gridTop = 117;
  static const double _gridH = 340;

  /// The quadrilateral and the handle.
  static const List<Offset> _corners = [
    Offset(44.8, 90.8),
    Offset(197.1, 80.2),
    Offset(210, 265.2),
    Offset(57.8, 275.9),
  ];
  static const double _handle = 7;

  @override
  void paint(Canvas canvas, Size size) {
    final ink = colors.textPrimary;
    // The room: a dark wall and a darker table.
    canvas.drawRect(Offset.zero & size, Paint()..color = ink);
    canvas.drawRect(
      Rect.fromLTWH(0, 211, size.width, size.height - 211),
      Paint()..color = Color.lerp(ink, colors.bgNavy, 0.35) ?? ink,
    );

    canvas.save();
    canvas.translate(46, 26);
    canvas.scale(0.53);
    canvas.translate(150, 235);
    canvas.rotate(-4 * math.pi / 180);
    canvas.translate(-150, -235);
    _paintForm(canvas);
    canvas.restore();

    _paintFrame(canvas);
  }

  void _paintForm(Canvas canvas) {
    final paper = Paint()..color = colors.bgCanvas;
    final light = Paint()..color = colors.borderStrong;
    final band = Paint()..color = colors.bgSunken;
    final dark = Paint()..color = colors.textSecondary;
    final line = Paint()
      ..color = colors.borderControl
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    RRect r(double x, double y, double w, double h, double radius) =>
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, w, h),
          Radius.circular(radius),
        );

    canvas
      ..drawRRect(r(0, 0, _formW, _formH, 4), paper)
      ..drawRRect(r(14, 14, 150, 6, 2), light)
      ..drawRRect(r(14, 26, 110, 6, 2), light)
      ..drawRect(const Rect.fromLTWH(6, 80, 288, 24), band);
    for (final x in const [14.0, 104.0, 194.0]) {
      canvas.drawRRect(r(x, 44, 84, 26, 2), line);
    }
    for (final x in const [20.0, 92.0, 164.0, 236.0]) {
      canvas.drawRRect(r(x, 88, 44, 7, 2), dark);
    }
    canvas.drawRect(const Rect.fromLTWH(6, 112, 288, 350), line);

    // The answer grid: per row a dash and five empty bubbles; every eighth
    // row has the filled marks of the example form.
    final bubbles = Path();
    final dashes = Path();
    final marks = Path();
    const filledAt = [42.0, 20.0, 53.0, 31.0, 64.0, 42.0, 31.0, 53.0];
    final rows = (_gridH / _rowH).floor();
    for (var c = 0; c < _columns; c++) {
      final left = 6 + c * _columnW;
      for (var row = 0; row < rows; row++) {
        final top = _gridTop + row * _rowH;
        dashes.addRect(Rect.fromLTWH(left + 2, top + 3.45, 8, 1.6));
        for (final cx in const [20.0, 31.0, 42.0, 53.0, 64.0]) {
          bubbles.addOval(
            Rect.fromCircle(center: Offset(left + cx, top + 4.25), radius: 2.5),
          );
        }
        marks.addOval(
          Rect.fromCircle(
            center: Offset(left + filledAt[row % 8], top + 4.25),
            radius: 2.6,
          ),
        );
      }
    }
    canvas
      ..drawPath(
        bubbles,
        Paint()
          ..color = colors.borderControl
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9,
      )
      ..drawPath(dashes, Paint()..color = colors.borderControl)
      ..drawPath(marks, Paint()..color = colors.textPrimary);
    // The four corner squares of the sheet.
    final square = Paint()..color = colors.textPrimary;
    for (final p in const [
      Offset(3, 109),
      Offset(291, 109),
      Offset(3, 459),
      Offset(291, 459),
    ]) {
      canvas.drawRect(p & const Size.square(6), square);
    }
  }

  void _paintFrame(Canvas canvas) {
    final quad = Path()..addPolygon(_corners, true);
    canvas.drawPath(
      quad,
      Paint()..color = colors.accent.withValues(alpha: 0.10),
    );
    final stroke = Paint()
      ..color = colors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    for (final metric in quad.computeMetrics()) {
      var at = 0.0;
      while (at < metric.length) {
        canvas.drawPath(
          metric.extractPath(at, math.min(at + 8, metric.length)),
          stroke,
        );
        at += 14;
      }
    }
    for (final corner in _corners) {
      canvas
        ..drawCircle(corner, _handle, Paint()..color = colors.accent)
        ..drawCircle(
          corner,
          _handle,
          Paint()
            ..color = colors.bgSurface
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
    }
  }

  @override
  bool shouldRepaint(_ScanPhotoPainter oldDelegate) =>
      oldDelegate.colors != colors;
}
