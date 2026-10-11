import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/shared/ui/indicators/progress_math.dart';

/// Which color a linear bar fills with.
enum AppProgressStyle {
  /// The subject accent (`context.appSubject(key).fg`) on a 8 pt track:
  /// card progress on a subject row ("41 / 64 kart biliniyor").
  subject,

  /// `accentLine` orange: "where you are" progress (card session, upload).
  /// Orange is allowed for progress and position only.
  accent,
}

/// The linear progress bar (C44 "Ders / vurgu ilerlemesi"; board 1.15 "İlerleme";
/// UI guide §5 #18).
///
/// A `bgSunken` track with a fill, both fully rounded. [style] `subject`: 8
/// pt high, the fill in the subject [color]; `accent`: 4 pt (8 on the upload
/// screen), the fill `accentLine`. The bar is only for a real ratio: when
/// [total] is null or zero nothing is drawn, not an empty track; a "%0" bar
/// that looks full or a made-up "%75" are exactly what the redesign removed.
///
/// The text under it names the count ("41 / 64 kart biliniyor", 13/20, 6
/// below); the percentage is not written again. The fill follows [value]
/// in [AppMotion.base] for the subject style and immediately (linear) for the
/// accent style when [animate] is false, as the upload percentage does.
/// Read as a progress bar: "40 karttan 12'si" ([semanticLabel]).
class AppLinearProgress extends StatelessWidget {
  const AppLinearProgress({
    required this.value,
    required this.total,
    this.style = AppProgressStyle.accent,
    this.color,
    this.height,
    this.label,
    this.semanticLabel,
    this.animate,
    super.key,
  });

  /// Completed count.
  final int value;

  /// The whole; null or zero draws nothing.
  final int? total;
  final AppProgressStyle style;

  /// The fill; the subject accent for `subject` (pass
  /// `context.appSubject(key).fg`), `accentLine` for `accent` when null.
  final Color? color;

  /// Track height; 8 for `subject`, 4 for `accent` when null.
  final double? height;

  /// The count text under the bar.
  final String? label;

  /// The accessible reading ("40 karttan 12'si").
  final String? semanticLabel;

  /// Animates changes; true for `subject`, false for `accent` by default.
  final bool? animate;

  /// Heights of the two styles.
  static const double subjectHeight = 8;
  static const double accentHeight = 4;

  @override
  Widget build(BuildContext context) {
    final fraction = ProgressMath.fraction(value, total);
    if (fraction == null) return const SizedBox.shrink();
    final colors = context.appColors;
    final bar =
        height ??
        (style == AppProgressStyle.subject ? subjectHeight : accentHeight);
    final fill =
        color ??
        (style == AppProgressStyle.accent ? colors.accentLine : colors.primary);
    final animated = animate ?? style == AppProgressStyle.subject;
    final duration = animated
        ? context.motion(AppMotion.base, reduced: Duration.zero)
        : Duration.zero;

    return Semantics(
      label: semanticLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: ClipRRect(
              borderRadius: AppRadius.borderFull,
              child: SizedBox(
                height: bar,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: colors.bgSunken),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: fraction),
                      duration: duration,
                      curve: AppMotion.standard,
                      builder: (context, current, _) => FractionallySizedBox(
                        widthFactor: current,
                        heightFactor: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: fill,
                            borderRadius: AppRadius.borderFull,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (label case final text?) ...[
            const SizedBox(height: 6),
            ExcludeSemantics(
              child: Text(
                text,
                style: context.appText.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The session progress row (C45 "SessionProgress"; Tur 5 G5; screens 8.1,
/// 8.2): an `accent` bar 4 pt high, 12 pt gap, and the count at the right
/// ("12/23", 15/24 · 700 `textPrimary`).
///
/// The bar is `bgSunken` with an `accentLine` fill (dark: `bgSunken` and the
/// lighter accent line of the theme); the 8.1 markup draws it 8 pt with a
/// 13/20 counter, which is a documented deviation: the kit value 4 pt and
/// 15/24 wins (spec C45 "ÇELİŞKİ").
class AppSessionProgress extends StatelessWidget {
  const AppSessionProgress({
    required this.value,
    required this.total,
    required this.counter,
    this.semanticLabel,
    super.key,
  });

  final int value;

  /// The whole; null or zero draws nothing.
  final int? total;

  /// The count text ("12/23").
  final String counter;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (ProgressMath.fraction(value, total) == null) {
      return const SizedBox.shrink();
    }
    final colors = context.appColors;
    return Row(
      children: [
        Expanded(
          child: AppLinearProgress(
            value: value,
            total: total,
            semanticLabel: semanticLabel,
          ),
        ),
        const SizedBox(width: AppSpacing.s12),
        ExcludeSemantics(
          child: Text(
            counter,
            style: context.appText.bodyStrong.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
