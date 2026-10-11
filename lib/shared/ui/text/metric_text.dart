import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/smap_text.dart';
import 'package:smap/core/theme/theme_context.dart';

/// The four metric sizes of the design (handoff 11.12 "Tipografi"; C49).
enum MetricSize {
  /// 56/64 · 800: the net of the result moment.
  xl,

  /// 40/48 · 800: exam detail and home net, the YKS counter.
  lg,

  /// 24/32 · 700: stat box value, score, rank, coaching code.
  md,

  /// 17/24 · 700: D/Y/B counters, subject net.
  sm;

  /// The style of the size, colorless, with tabular figures.
  TextStyle styleOf(SmapText text) => switch (this) {
    xl => text.metricXl,
    lg => text.metricLg,
    md => text.metricMd,
    sm => text.metricSm,
  };
}

/// A figure at a metric size (C49 `SmapMetricText`; UI guide §5 #20).
///
/// Pass the text already formatted by `TrFormat` ("67,5", "412,63", "48.215",
/// "%42"); this widget never formats a number itself. Digits are tabular, so
/// columns of metrics line up and a counter does not jitter as it changes.
/// The optional [unit] is the quiet word under the figure ("net", "puan");
/// the whole is read as one phrase ("67,5 net").
class MetricText extends StatelessWidget {
  const MetricText({
    required this.value,
    this.size = MetricSize.md,
    this.unit,
    this.color,
    this.textAlign,
    super.key,
  });

  final String value;
  final MetricSize size;

  /// "net".
  final String? unit;

  /// `textPrimary` when null.
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final figure = Text(
      value,
      textAlign: textAlign,
      style: size
          .styleOf(context.appText)
          .copyWith(color: color ?? colors.textPrimary),
    );
    final unitText = unit;
    if (unitText == null) return figure;
    return Semantics(
      label: '$value $unitText',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          figure,
          const SizedBox(height: AppSpacing.s4 / 2),
          Text(
            unitText,
            style: context.appText.caption.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
