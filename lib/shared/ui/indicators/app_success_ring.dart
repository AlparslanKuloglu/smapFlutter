import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/indicators/progress_math.dart';

/// The success percentage ring (C46 "SuccessRing"; board 1.15 "Başarı yüzdesi
/// halkası"; UI guide §5 #18; topic rows 5.5, 5.10).
///
/// 48 pt, a 5 pt line, a `bgSunken` track and a `chartLine` arc that starts at
/// the top (-90 degrees) with round ends; the centre reads "%42" at 13/20 ·
/// 700 in `textPrimary`. One color only: no threshold colors. The percentage
/// is [correct] of [total] rounded to the nearest whole number (5 of 12 is
/// %42), through `TrFormat.yuzde`.
///
/// States: 100 % is a full ring; 0 % is the bare track with "%0"; with no
/// questions at all ([total] zero) no ring is drawn and the 48 pt box says
/// "Soru yok" (13/16 · 600 `textSecondary`), so "no questions" and "0 %" are
/// never the same picture. The arc grows in [AppMotion.base] unless "Reduce
/// motion" is on. Read as "Yüzde 42".
class AppSuccessRing extends StatelessWidget {
  const AppSuccessRing({
    required this.correct,
    required this.total,
    this.noDataLabel,
    super.key,
  });

  /// Correct answers.
  final int correct;

  /// Answered questions of the topic; zero draws "Soru yok".
  final int total;

  /// Overrides the no-data text; "Soru yok" from l10n when null.
  final String? noDataLabel;

  /// Edge of the box.
  static const double size = 48;

  /// Line width.
  static const double line = 5;

  /// Radius of the ring centerline.
  static const double radius = 21;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final percent = ProgressMath.percent(correct, total);

    if (percent == null) {
      final label = noDataLabel ?? l10n.kit_noQuestions;
      return Semantics(
        label: label,
        excludeSemantics: true,
        child: SizedBox.square(
          dimension: size,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: text.caption.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                  height: 16 / 13,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final duration = context.motion(AppMotion.base, reduced: Duration.zero);
    return Semantics(
      label: l10n.kit_percentA11y(percent),
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: percent / 100),
          duration: duration,
          curve: AppMotion.standard,
          builder: (context, sweep, child) => CustomPaint(
            painter: _RingPainter(
              sweep: sweep,
              track: colors.bgSunken,
              arc: colors.chartLine,
            ),
            child: child,
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                TrFormat.yuzde(correct, total),
                style: text.caption.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.sweep,
    required this.track,
    required this.arc,
  });

  final double sweep;
  final Color track;
  final Color arc;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    Paint line(Color color) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = AppSuccessRing.line
      ..color = color;
    canvas.drawCircle(center, AppSuccessRing.radius, line(track));
    if (sweep <= 0) return;
    final rect = Rect.fromCircle(center: center, radius: AppSuccessRing.radius);
    if (sweep >= 1) {
      canvas.drawCircle(center, AppSuccessRing.radius, line(arc));
      return;
    }
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * sweep, false, line(arc));
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.sweep != sweep ||
      oldDelegate.track != track ||
      oldDelegate.arc != arc;
}
