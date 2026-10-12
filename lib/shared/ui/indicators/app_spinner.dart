import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/theme_context.dart';

/// The indeterminate spinner (C47; board 1.15 "Süresi belirsiz bekleme").
///
/// Geometry of the design: in a 24 unit frame a radius 9,5 track and a 90
/// degree arc, 3 wide, round ends; the whole thing scales with [size], so
/// the 20 pt button spinner has the 2,5 pt line of C01. One turn takes
/// [AppMotion.loop] (1200 ms), linear. Under "Reduce motion" it stops and
/// draws the still arc; the wait then rests on the text next to it.
///
/// Use it only for a step of unknown length and always with a text that says
/// what is awaited ([semanticLabel] for the screen reader); a screen that
/// loads shows a skeleton, not a spinner (spec C47 "Kural").
///
/// Sizes: 24 inline (default), 48 full screen (9.4), 20 inside a button.
/// Colors: the kit's `bgSunken` track and `chartLine` arc by default; on navy
/// pass [trackColor] white at 24 % and [color] white.
class AppSpinner extends StatefulWidget {
  const AppSpinner({
    this.size = 24,
    this.color,
    this.trackColor,
    this.semanticLabel,
    super.key,
  });

  /// Edge of the square, 24 / 48 / 20.
  final double size;

  /// The arc; `chartLine` when null.
  final Color? color;

  /// The ring behind the arc; `bgSunken` when null.
  final Color? trackColor;

  /// Read by screen readers ("Cevaplar okunuyor"); null leaves the spinner
  /// out of the semantics tree.
  final String? semanticLabel;

  @override
  State<AppSpinner> createState() => _AppSpinnerState();
}

class _AppSpinnerState extends State<AppSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _turn = AnimationController(
    vsync: this,
    duration: AppMotion.loop,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion) {
      _turn.stop();
    } else if (!_turn.isAnimating) {
      _turn.repeat();
    }
  }

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final painter = _SpinnerPainter(
      turn: _turn,
      color: widget.color ?? colors.chartLine,
      trackColor: widget.trackColor ?? colors.bgSunken,
    );
    final spinner = RepaintBoundary(
      child: CustomPaint(size: Size.square(widget.size), painter: painter),
    );
    final label = widget.semanticLabel;
    if (label == null) return ExcludeSemantics(child: spinner);
    return Semantics(label: label, liveRegion: true, child: spinner);
  }
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter({
    required this.turn,
    required this.color,
    required this.trackColor,
  }) : super(repaint: turn);

  /// Radius and line width as fractions of the 24 unit frame.
  static const double _radius = 9.5 / 24;
  static const double _line = 3 / 24;
  static const double _arc = math.pi / 2;

  final Animation<double> turn;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    // The shortest side, not the width: a parent that stretches the spinner
    // to a wide box (a full-width panel) must not blow the ring up.
    final edge = size.shortestSide;
    final center = size.center(Offset.zero);
    final radius = _radius * edge;
    final stroke = _line * edge;
    Paint line(Color value) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = value;
    canvas
      ..drawCircle(center, radius, line(trackColor))
      ..drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2 + turn.value * 2 * math.pi,
        _arc,
        false,
        line(color),
      );
  }

  @override
  bool shouldRepaint(_SpinnerPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.trackColor != trackColor;
}
