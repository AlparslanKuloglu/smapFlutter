import 'package:flutter/material.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/analytics/application/chart_axis.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/l10n/app_localizations.dart';

/// Screen reader support of the net chart (C48 "Erişilebilirlik"): the
/// one-sentence summary and a focusable item for every point.
///
/// `fl_chart` draws everything on one canvas, so the points are not nodes. This
/// layer lays an invisible, focusable item over each point's x position:
/// "TYT Genel Deneme 9, 28 Eylül, 74,75 net". Activating it selects the
/// point, as a tap does.
abstract final class NetChartReading {
  /// "TYT net grafiği, 22 Nisan 61,5 netten 28 Eylül 74,75 nete, 6 deneme".
  static String summary(
    AppLocalizations l10n,
    String scope,
    List<NetChartPoint> points,
  ) {
    final first = points.first;
    final last = points.last;
    if (points.length == 1) {
      return l10n.analytics_netChartSingleA11y(
        scope,
        ChartAxis.longDayMonth(first.date),
        TrFormat.net(first.net),
      );
    }
    return l10n.analytics_netChartA11y(
      scope,
      ChartAxis.longDayMonth(first.date),
      TrFormat.net(first.net),
      ChartAxis.longDayMonth(last.date),
      TrFormat.net(last.net),
      points.length,
    );
  }

  /// "TYT Genel Deneme 9, 28 Eylül, 74,75 net"; without a name the date and
  /// the net only.
  static String point(AppLocalizations l10n, NetChartPoint point) {
    final date = ChartAxis.longDayMonth(point.date);
    final net = TrFormat.net(point.net);
    return switch (point.name) {
      final name? => l10n.analytics_netChartPointA11y(name, date, net),
      null => l10n.analytics_netChartPointNoNameA11y(date, net),
    };
  }
}

/// The invisible per-point items laid over the plot area.
class NetChartPointSemantics extends StatelessWidget {
  const NetChartPointSemantics({
    required this.points,
    required this.minX,
    required this.maxX,
    required this.onSelect,
    super.key,
  });

  final List<NetChartPoint> points;

  /// The x range of the chart; the point `i` sits at `x = i`.
  final double minX;
  final double maxX;

  /// Called with the index of the activated point.
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final unit = box.maxWidth / (maxX - minX);
        return Stack(
          children: [
            for (final (i, point) in points.indexed)
              Positioned(
                // Kept inside the plot: the first and last items used to be
                // cut by its edge to 0,8 of a slot (44 pt of 54).
                left: ((i - minX) * unit - unit / 2).clamp(
                  0.0,
                  box.maxWidth - unit,
                ),
                width: unit,
                top: 0,
                bottom: 0,
                child: Semantics(
                  button: true,
                  label: NetChartReading.point(l10n, point),
                  onTap: () => onSelect(i),
                  child: const SizedBox.expand(),
                ),
              ),
          ],
        );
      },
    );
  }
}
