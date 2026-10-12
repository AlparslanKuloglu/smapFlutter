import 'package:flutter/material.dart';
import 'package:smap/core/theme/smap_colors.dart';
import 'package:smap/core/theme/smap_text.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/scan/presentation/widgets/omr_form_art.dart';

/// The picture of the permission sheet (pano 4.1 kare 1, spec "işlevli
/// görsel 160 × 170"): the optical form inside four navy frame corners, the
/// thing the camera will be asked to read. Decorative; the sheet's title says
/// what it is for.
class OmrPrimerIllustration extends StatelessWidget {
  const OmrPrimerIllustration({super.key});

  static const double width = 160;
  static const double height = 170;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ExcludeSemantics(
      child: CustomPaint(
        size: const Size(width, height),
        painter: _PrimerPainter(colors),
      ),
    );
  }
}

class _PrimerPainter extends CustomPainter {
  const _PrimerPainter(this.colors);

  final SmapColors colors;

  /// The form sits 20 right and 10 down of the picture, 120 x 150 big, and is
  /// drawn at 0,319 inside it, 12,1 from its left edge.
  static const Offset _formOffset = Offset(20 + 12.1, 10);
  static const double _formScale = 0.319;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..translate(_formOffset.dx, _formOffset.dy)
      ..scale(_formScale);
    OmrFormArt.paint(canvas, colors, handleRadius: 9);
    canvas.restore();

    final bracket = Paint()
      ..color = colors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(6, 34)
      ..lineTo(6, 6)
      ..lineTo(34, 6)
      ..moveTo(126, 6)
      ..lineTo(154, 6)
      ..lineTo(154, 34)
      ..moveTo(6, 136)
      ..lineTo(6, 164)
      ..lineTo(34, 164)
      ..moveTo(126, 164)
      ..lineTo(154, 164)
      ..lineTo(154, 136);
    canvas.drawPath(path, bracket);
  }

  @override
  bool shouldRepaint(_PrimerPainter oldDelegate) =>
      oldDelegate.colors != colors;
}

/// The drawing of the how-to-shoot sheet (pano 4.2): the form with the answer
/// area in the orange dashed frame, the subject-name strip crossed out in
/// red, and three numbered badges that point at them (1 the area, 2 the
/// strip, 3 the corner handles), in a 330 x 250 box.
class OmrTutorialIllustration extends StatelessWidget {
  const OmrTutorialIllustration({super.key});

  static const double width = 330;
  static const double height = 250;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    return ExcludeSemantics(
      child: FittedBox(
        child: CustomPaint(
          size: const Size(width, height),
          painter: _TutorialPainter(colors, text),
        ),
      ),
    );
  }
}

class _TutorialPainter extends CustomPainter {
  const _TutorialPainter(this.colors, this.text);

  final SmapColors colors;
  final SmapText text;

  static const Offset _formOffset = Offset(24, 8);
  static const double _formScale = 0.4979;

  /// The badges: where the leader line starts and ends and the badge center,
  /// with the number it carries.
  static const List<(double, double, double, int)> _badges = [
    (172.4, 203.4, 53.8, 2),
    (172.4, 203.4, 150.9, 1),
    (178.4, 203.4, 238.0, 3),
  ];
  static const double _badgeX = 217.4;
  static const double _badgeRadius = 14;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..translate(_formOffset.dx, _formOffset.dy)
      ..scale(_formScale);
    OmrFormArt.paint(canvas, colors);
    canvas.restore();

    final leader = Paint()
      ..color = colors.primary
      ..strokeWidth = 1.5;
    final disc = Paint()..color = colors.infoBg;
    for (final (from, to, y, number) in _badges) {
      canvas.drawLine(Offset(from, y), Offset(to, y), leader);
      canvas.drawCircle(Offset(_badgeX, y), _badgeRadius, disc);
      final painter = TextPainter(
        text: TextSpan(
          text: '$number',
          style: text.bodyStrong.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(_badgeX - painter.width / 2, y - painter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_TutorialPainter oldDelegate) =>
      oldDelegate.colors != colors || oldDelegate.text != text;
}
