import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/smap_colors.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/application/stacked_bar_math.dart';
import 'package:smap/l10n/app_localizations.dart';

/// The stacked D/Y/B bar (C42 "StackedBar"; pano 1.14 "Yığılmış yatay çubuk";
/// screen 5.3; `DybStackedBar` in Tur 1).
///
/// 12 pt high, fully rounded, the parts as wide as their counts, a 2 pt gap
/// between them (so the border shows without color vision) and the content
/// clipped to the rounded ends. A part with a zero count is not drawn; its
/// counter still is, next to the bar. No bar is drawn for an exam with no
/// questions.
///
/// On first show the bar fills from the left in [AppMotion.slow] (350 ms);
/// under "Reduce motion", or with [animate] false, it appears in its final
/// shape. Read as an image: "40 sorudan 23 doğru, 17 yanlış, 0 boş".
class DybStackedBar extends StatelessWidget {
  const DybStackedBar({required this.counts, this.animate = true, super.key});

  final DybCounts counts;

  /// Fills on first show; false draws the final shape at once.
  final bool animate;

  /// Height of the bar.
  static const double height = 12;

  @override
  Widget build(BuildContext context) {
    if (counts.total <= 0) return const SizedBox.shrink();
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final duration = animate
        ? context.motion(AppMotion.slow, reduced: Duration.zero)
        : Duration.zero;
    return Semantics(
      image: true,
      label: l10n.exams_stackedBarA11y(
        counts.total,
        counts.correct,
        counts.wrong,
        counts.blank,
      ),
      excludeSemantics: true,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: duration,
          curve: AppMotion.standard,
          builder: (context, fill, _) => CustomPaint(
            painter: _StackedBarPainter(
              counts: counts,
              colors: colors,
              fill: fill,
            ),
          ),
        ),
      ),
    );
  }
}

class _StackedBarPainter extends CustomPainter {
  const _StackedBarPainter({
    required this.counts,
    required this.colors,
    required this.fill,
  });

  final DybCounts counts;
  final SmapColors colors;

  /// 0 to 1: how much of the bar width is drawn.
  final double fill;

  Color _colorOf(DybKind kind) => switch (kind) {
    DybKind.correct => colors.dybCorrect,
    DybKind.wrong => colors.dybWrong,
    DybKind.blank => colors.dybBlank,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width * fill;
    if (width <= 0) return;
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, width, size.height),
        const Radius.circular(AppRadius.full),
      ),
    );
    for (final part in StackedBarMath.segments(counts, width)) {
      canvas.drawRect(
        Rect.fromLTRB(part.left, 0, part.right, size.height),
        Paint()..color = _colorOf(part.kind),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StackedBarPainter oldDelegate) =>
      oldDelegate.counts != counts ||
      oldDelegate.colors != colors ||
      oldDelegate.fill != fill;
}
