import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/analytics/presentation/widgets/net_chart_plot.dart';
import 'package:smap/features/analytics/presentation/widgets/net_chart_semantics.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';

/// The net progress card (C48 "NetChart"; pano 1.4 "Grafik", 6.1 "Analizlerim
/// · Genel", 10.4 coach view; `SmapNetChart`).
///
/// A card (padding 16): the title "Net gelişimi" 17 · 700 with "Son 6 deneme"
/// 13 · 600 `textSecondary` at the right; the [NetChartPlot], 214 high, 12
/// below; and 8 below it the footnote 13 `textSecondary`: "net · TYT 0–120 ·
/// son nokta vurgulu". The y axis is fixed to the exam: TYT 0–120, AYT 0–160
/// ([NetExamType.axisMax]); a lesson chart passes its question count as
/// [axisMax]. Colors are the chart roles of the theme (`chartLine`,
/// `chartArea`, `chartHighlight`, `chartGrid`), in both themes.
///
/// [points] are the exams of the current filter, oldest first
/// (`NetChartPoint.sortedByDate`). With no point nothing is drawn: the screen
/// shows its empty state. A single exam draws a dot and no line.
///
/// A tap on a point shows its balloon, a tap elsewhere returns to the last
/// point; when the filter changes the plot redraws over 350 ms (the filter
/// plays the selection haptic). Read as "TYT net grafiği, 22 Nisan 61,5
/// netten 28 Eylül 74,75 nete, 6 deneme", with every point its own item.
class NetChart extends StatelessWidget {
  const NetChart({
    required this.points,
    required this.examType,
    this.axisMax,
    this.scopeLabel,
    super.key,
  });

  /// Oldest first.
  final List<NetChartPoint> points;

  /// Sets the axis and the default scope label.
  final NetExamType examType;

  /// The top of the y axis when it is not the exam's question count (a
  /// single lesson chart); [NetExamType.axisMax] otherwise.
  final double? axisMax;

  /// What the footnote and the reading call the chart: "TYT" by default,
  /// "TYT Türkçe" for a lesson.
  final String? scopeLabel;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final top = axisMax ?? examType.axisMax;
    final scope = scopeLabel ?? examType.label;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    l10n.analytics_netChartTitle,
                    style: text.headline.copyWith(color: colors.textPrimary),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Text(
                l10n.analytics_netChartRange(points.length),
                style: text.caption.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Semantics(
            container: true,
            explicitChildNodes: true,
            label: NetChartReading.summary(l10n, scope, points),
            child: SizedBox(
              height: NetChartPlot.heightFor(MediaQuery.textScalerOf(context)),
              child: NetChartPlot(points: points, axisMax: top),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            l10n.analytics_netChartFootnote(scope, TrFormat.net(top)),
            style: text.caption.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
