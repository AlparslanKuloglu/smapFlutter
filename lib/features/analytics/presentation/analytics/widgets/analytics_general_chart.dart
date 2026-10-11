part of '../analytics_view.dart';

/// The chart card of the loaded filter (pano 6.1; 6.3 kare 2).
class _ChartSection
    extends SelectorViewModelWidget<AnalyticsViewModel, GeneralContent?> {
  const _ChartSection();

  @override
  GeneralContent? selector(AnalyticsViewModel viewModel) =>
      viewModel.general.data;

  @override
  Widget build(BuildContext context, GeneralContent? content) {
    if (content == null || content.chartKind == GeneralChartKind.none) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        _sectionGap,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: switch (content.chartKind) {
          GeneralChartKind.line => NetChart(
            points: content.points,
            examType: content.filter.exam,
            axisMax: content.axisMax,
            scopeLabel: content.scopeLabel,
          ),
          _ => _SingleExamCard(point: content.points.first),
        },
      ),
    );
  }
}

/// The card that stands in for the chart while there is one exam (pano 6.3
/// kare 2): "İlk denemen", the net, "TYT Genel Deneme 9 · 28 Eylül 2026" and
/// "İkinci denemenden sonra gelişim grafiğin burada çizilir." The line starts
/// with the second exam; nothing is drawn between points that do not exist.
class _SingleExamCard extends StatelessWidget {
  const _SingleExamCard({required this.point});

  final NetChartPoint point;

  /// The card's own padding (pano 6.3 kare 2: 20).
  static const double _padding = AppSpacing.s16 + AppSpacing.s4;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final text = context.appText;
    final secondary = text.caption.copyWith(color: colors.textSecondary);
    final name = point.name?.trim();
    final date = TrFormat.uzunTarih(point.date);
    final net = TrFormat.net(point.net);
    return AppCard(
      padding: const EdgeInsets.all(_padding),
      child: Semantics(
        container: true,
        label: [
          l10n.analytics_singleTitle,
          '$net ${AppLocalizations.of(context).exams_netUnit}',
          if (name != null && name.isNotEmpty)
            l10n.analytics_singleNameDate(name, date)
          else
            date,
          l10n.analytics_singleNote,
        ].join(', '),
        excludeSemantics: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.analytics_singleTitle,
              style: secondary.copyWith(fontWeight: FontWeight.w600),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  net,
                  style: text.metricLg.copyWith(color: colors.textPrimary),
                ),
                const SizedBox(width: AppSpacing.s4),
                Text(
                  l10n.exams_netUnit,
                  style: secondary.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Text(
              name != null && name.isNotEmpty
                  ? l10n.analytics_singleNameDate(name, date)
                  : date,
              style: text.body.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.s12),
            Text(l10n.analytics_singleNote, style: secondary),
          ],
        ),
      ),
    );
  }
}
