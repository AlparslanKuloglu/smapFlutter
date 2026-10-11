part of '../analytics_view.dart';

/// The four stat boxes (pano 6.1 "StatGrid, 2 sütun, aralık 8"): "Çözülen
/// deneme", "Ortalama net" with the change of the last two exams, "Ortalama
/// puan", "Ortalama sıralama". A box with no figure is not drawn (pano 6.1
/// kare 2: AYT without scores has two), and with one exam there is no change
/// line (pano 6.3 kare 2).
class _StatsSection
    extends SelectorViewModelWidget<AnalyticsViewModel, GeneralContent?> {
  const _StatsSection();

  @override
  GeneralContent? selector(AnalyticsViewModel viewModel) =>
      viewModel.general.data;

  @override
  Widget build(BuildContext context, GeneralContent? content) {
    if (content == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final l10n = AppLocalizations.of(context);
    final count = content.examCount;
    final net = content.averageNet;
    final point = content.averagePoint;
    final rank = content.averageRank;
    final boxes = <Widget>[
      if (count != null)
        AppStatBox(label: l10n.analytics_boxExams, value: TrFormat.sira(count)),
      if (net != null)
        AppStatBox(
          label: l10n.analytics_boxAverageNet,
          value: TrFormat.net(net),
          delta: content.netDelta,
          deltaSuffix: l10n.analytics_deltaSuffix,
        ),
      if (point != null)
        AppStatBox(
          label: l10n.analytics_boxAveragePoint,
          value: TrFormat.puan(point),
        ),
      if (rank != null)
        AppStatBox(
          label: l10n.analytics_boxAverageRank,
          value: TrFormat.sira(rank),
        ),
    ];
    if (boxes.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        _sectionGap,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(child: _StatGrid(boxes: boxes)),
    );
  }
}

/// Two columns of equal boxes; a row's boxes are as tall as the taller one.
class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.boxes});

  final List<Widget> boxes;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < boxes.length; i += 2) ...[
          if (i > 0) const SizedBox(height: _boxGap),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: boxes[i]),
                const SizedBox(width: _boxGap),
                Expanded(
                  child: i + 1 < boxes.length
                      ? boxes[i + 1]
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
