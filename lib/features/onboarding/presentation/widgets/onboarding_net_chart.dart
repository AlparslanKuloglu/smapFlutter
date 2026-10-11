import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/onboarding/application/onboarding_samples.dart';

/// The small net chart of the second intro page (pano 2.1 kare 3: 268 x 120,
/// y axis 40 · 55 · 70, dates "8 May." and "5 Eki.").
///
/// The same chart roles as `NetChart` (`chartLine`, `chartArea`,
/// `chartHighlight`, `chartGrid`; 2,5 pt line, 4 pt dots, the last point
/// 6 pt orange with a white ring), but with the board's own frame: the axis
/// does not start at 0 and there is no balloon, no title and no footnote, so
/// it is a picture of the real chart, not the real chart. Not interactive,
/// read as [semanticLabel]. The numbers are the board's example data
/// (`OnboardingSamples`).
class OnboardingNetChart extends StatelessWidget {
  const OnboardingNetChart({
    required this.points,
    required this.semanticLabel,
    super.key,
  });

  /// Oldest first; the board draws four.
  final List<NetChartPoint> points;

  /// "AYT net grafiği: 8 Mayıs 48,5 netten 5 Ekim 67,5 nete".
  final String semanticLabel;

  /// The board's frame.
  static const double width = 268;
  static const double height = 120;

  /// Left room of the y labels, top room above the highest line, right room
  /// of the last dot, and the row of the date labels.
  static const double _labels = 28;
  static const double _top = 8;
  static const double _rightRoom = 10;
  static const double _dates = 26;

  static const double _lineWidth = 2.5;
  static const double _dotRadius = 4;
  static const double _dotEdge = 2;
  static const double _lastRadius = 6;
  static const double _lastEdge = 2.5;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final label = context.appText.caption.copyWith(color: colors.textSecondary);
    final last = points.length - 1;
    final spots = [
      for (final (i, point) in points.indexed)
        FlSpot(i.toDouble(), point.net - OnboardingSamples.chartMin),
    ];
    final bar = LineChartBarData(
      spots: spots,
      isCurved: false,
      color: colors.chartLine,
      barWidth: _lineWidth,
      isStrokeCapRound: true,
      dotData: FlDotData(
        getDotPainter: (spot, percent, bar, index) => index == last
            ? FlDotCirclePainter(
                color: colors.chartHighlight,
                radius: _lastRadius,
                strokeColor: colors.bgSurface,
                strokeWidth: _lastEdge,
              )
            : FlDotCirclePainter(
                color: colors.bgSurface,
                radius: _dotRadius,
                strokeColor: colors.chartLine,
                strokeWidth: _dotEdge,
              ),
      ),
      belowBarData: BarAreaData(show: true, color: colors.chartArea),
    );
    final data = LineChartData(
      minX: 0,
      maxX: last.toDouble(),
      // fl_chart puts its ticks on multiples of the interval, so the plot is
      // shifted to start at 0 and the labels add the shift back: 40, 55, 70.
      minY: 0,
      maxY: OnboardingSamples.chartMax - OnboardingSamples.chartMin,
      clipData: const FlClipData.none(),
      lineBarsData: [bar],
      lineTouchData: const LineTouchData(enabled: false),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        drawVerticalLine: false,
        horizontalInterval: OnboardingSamples.chartStep,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: colors.chartGrid, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(),
        rightTitles: const AxisTitles(),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: _labels,
            interval: OnboardingSamples.chartStep,
            getTitlesWidget: (value, meta) => SideTitleWidget(
              meta: meta,
              child: Text(
                TrFormat.net(value + OnboardingSamples.chartMin),
                style: label,
              ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: _dates,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.round();
              // The board writes the first and the last date only.
              if ((value - index).abs() > 0.001 ||
                  (index != 0 && index != last)) {
                return const SizedBox.shrink();
              }
              return SideTitleWidget(
                meta: meta,
                fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                child: Text(
                  TrFormat.kisaTarih(points[index].date),
                  style: label,
                ),
              );
            },
          ),
        ),
      ),
    );
    return Semantics(
      image: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        width: width,
        height: height,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, _top, _rightRoom, 0),
          child: LineChart(data, duration: Duration.zero),
        ),
      ),
    );
  }
}
