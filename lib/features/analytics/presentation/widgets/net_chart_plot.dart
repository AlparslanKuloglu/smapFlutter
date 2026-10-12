import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/smap_colors.dart';
import 'package:smap/core/theme/smap_text.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/analytics/application/chart_axis.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/analytics/presentation/widgets/net_chart_semantics.dart';
import 'package:smap/l10n/app_localizations.dart';

/// The drawing area of [NetChart] (C48; pano 1.4 "Grafik", 6.1): the
/// `fl_chart` `LineChart` with its axes, dots and balloon. A helper of
/// `net_chart.dart`, not used on its own.
///
/// - Y axis fixed `0..axisMax` with horizontal 1 pt `chartGrid` lines and
///   `textSecondary` 13 labels, right aligned; the line is 2,5 pt `chartLine`,
///   straight between points (no curve: nothing is invented between two
///   exams), with the 10 % `chartArea` under it.
/// - A dot is 4,5 pt (fill `bgSurface`, 2 pt `chartLine` edge); the selected
///   one, the last until a tap says otherwise, is 7 pt `chartHighlight` with a
///   2,5 pt `bgSurface` edge.
/// - The balloon (`inverseSurface`, radius 8) shows the name and the short
///   date over the net: "TYT Genel Deneme 9 · 28 Eyl." / "74,75 net". A tap
///   on a point selects it; a tap anywhere else returns to the last point.
///   `fl_chart` draws the balloon without a shadow, which the board does
///   not draw either.
/// - X labels are short dates ("22 Nis."), thinned to what fits.
class NetChartPlot extends StatefulWidget {
  const NetChartPlot({required this.points, required this.axisMax, super.key});

  /// Oldest first, not empty.
  final List<NetChartPoint> points;

  /// The top of the y axis.
  final double axisMax;

  /// Height of the whole plot with its x labels at the normal text size
  /// (pano 6.1).
  static const double baseHeight = 214;

  /// The x labels' strip: one text line and 8 pt of air.
  static const double _labelLine = 20;
  static const double _labelAir = 8;

  /// The height of the plot for [scaler]: the drawing area and the x label
  /// strip grow with the text, because the balloon (two text lines) sits
  /// above the selected point and, in a fixed area, would cover it from
  /// about 1,3 (a 1,35 balloon is 87 pt tall over a point 68 pt below the
  /// top). At scale 1 it is [baseHeight].
  static double heightFor(TextScaler scaler) =>
      scaler.scale(baseHeight - _labelLine - _labelAir) +
      scaler.scale(_labelLine) +
      _labelAir;

  @override
  State<NetChartPlot> createState() => _NetChartPlotState();
}

class _NetChartPlotState extends State<NetChartPlot> {
  /// The tapped point; null means the last one.
  int? _selected;

  static const double _lineWidth = 2.5;
  static const double _dotRadius = 4.5;
  static const double _dotEdge = 2;
  static const double _highlightRadius = 7;
  static const double _highlightEdge = 2.5;
  static const double _touchThreshold = 24;

  /// A date label is about this many 13 pt "ems" wide ("22 Nis.").
  static const double _labelEms = 3.6;

  /// A y label is about this many 13 pt "ems" wide per character.
  static const double _digitEm = 0.62;

  @override
  void didUpdateWidget(NetChartPlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points) _selected = null;
  }

  int get _current {
    final last = widget.points.length - 1;
    final tapped = _selected;
    return tapped == null || tapped > last ? last : tapped;
  }

  void _select(int? tapped) {
    setState(
      () => _selected = ChartAxis.selectionAfterTap(
        tapped: tapped,
        count: widget.points.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final scaler = MediaQuery.textScalerOf(context);
    final points = widget.points;
    final max = widget.axisMax;
    final step = ChartAxis.stepFor(max);
    final (minX, maxX) = ChartAxis.xBounds(points.length);
    final label = text.caption.copyWith(color: colors.textSecondary);
    final digits = TrFormat.net(max).length;
    final left = (scaler.scale(13) * _digitEm * digits + 8).ceilToDouble();
    final bottom =
        (scaler.scale(NetChartPlot._labelLine) + NetChartPlot._labelAir)
            .ceilToDouble();

    return LayoutBuilder(
      builder: (context, box) {
        final plotWidth = box.maxWidth - left;
        final visible = ChartAxis.visibleLabelIndices(
          points.length,
          ChartAxis.maxLabelsFor(
            plotWidth: plotWidth,
            labelWidth: scaler.scale(13) * _labelEms,
            count: points.length,
          ),
        );
        final spots = [
          for (final (i, point) in points.indexed)
            FlSpot(i.toDouble(), ChartAxis.clampNet(point.net, max)),
        ];
        final bar = LineChartBarData(
          spots: spots,
          isCurved: false,
          color: colors.chartLine,
          barWidth: _lineWidth,
          isStrokeCapRound: true,
          dotData: FlDotData(
            getDotPainter: (spot, percent, bar, index) =>
                _dotPainter(colors, selected: index == _current),
          ),
          belowBarData: BarAreaData(show: true, color: colors.chartArea),
        );
        final data = LineChartData(
          minX: minX,
          maxX: maxX,
          minY: 0,
          maxY: max,
          lineBarsData: [bar],
          showingTooltipIndicators: [
            ShowingTooltipIndicators([LineBarSpot(bar, 0, spots[_current])]),
          ],
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: step,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: colors.chartGrid, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: left,
                interval: step,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(TrFormat.net(value), style: label),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: bottom,
                interval: 1,
                minIncluded: false,
                maxIncluded: false,
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  final onPoint = (value - index).abs() < 0.001;
                  if (!onPoint ||
                      index < 0 ||
                      index >= points.length ||
                      !visible.contains(index)) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      ChartAxis.dateLabel(points[index].date),
                      style: label,
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            handleBuiltInTouches: false,
            touchSpotThreshold: _touchThreshold,
            touchCallback: (event, response) {
              if (event is! FlTapUpEvent) return;
              _select(response?.lineBarSpots?.firstOrNull?.spotIndex);
            },
            touchTooltipData: _tooltip(colors, text, points),
          ),
        );

        return Stack(
          children: [
            ExcludeSemantics(
              child: LineChart(
                data,
                duration: context.motion(
                  AppMotion.slow,
                  reduced: Duration.zero,
                ),
                curve: AppMotion.standard,
              ),
            ),
            Positioned(
              left: left,
              top: 0,
              right: 0,
              bottom: bottom,
              child: NetChartPointSemantics(
                points: points,
                minX: minX,
                maxX: maxX,
                onSelect: _select,
              ),
            ),
          ],
        );
      },
    );
  }

  static FlDotCirclePainter _dotPainter(
    SmapColors colors, {
    required bool selected,
  }) => selected
      ? FlDotCirclePainter(
          color: colors.chartHighlight,
          radius: _highlightRadius,
          strokeColor: colors.bgSurface,
          strokeWidth: _highlightEdge,
        )
      : FlDotCirclePainter(
          color: colors.bgSurface,
          radius: _dotRadius,
          strokeColor: colors.chartLine,
          strokeWidth: _dotEdge,
        );

  LineTouchTooltipData _tooltip(
    SmapColors colors,
    SmapText text,
    List<NetChartPoint> points,
  ) => LineTouchTooltipData(
    getTooltipColor: (_) => colors.inverseSurface,
    tooltipBorderRadius: AppRadius.borderSm,
    tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    tooltipMargin: 12,
    maxContentWidth: 240,
    fitInsideHorizontally: true,
    fitInsideVertically: true,
    getTooltipItems: (spots) => [
      for (final spot in spots)
        if (spot.spotIndex < points.length)
          _balloonItem(colors, text, points[spot.spotIndex], context),
    ],
  );

  static LineTooltipItem _balloonItem(
    SmapColors colors,
    SmapText text,
    NetChartPoint point,
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context);
    final date = ChartAxis.dateLabel(point.date);
    final head = switch (point.name) {
      final name? => l10n.analytics_netChartBalloonHead(name, date),
      null => date,
    };
    return LineTooltipItem(
      '$head\n',
      text.caption.copyWith(color: colors.inverseInfo),
      textAlign: TextAlign.start,
      children: [
        TextSpan(
          text: l10n.analytics_netChartBalloonNet(TrFormat.net(point.net)),
          style: text.bodyStrong.copyWith(
            color: colors.onInverseSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
