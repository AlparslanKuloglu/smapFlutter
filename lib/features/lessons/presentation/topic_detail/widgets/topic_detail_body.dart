part of '../topic_detail_view.dart';

/// The content of the topic: the skeleton, the sub-topic cards, the empty
/// note or the error state (pano 7.3, 7.5 kare 3).
class _TopicBody
    extends SelectorViewModelWidget<TopicDetailViewModel, TopicBodyData> {
  const _TopicBody();

  @override
  TopicBodyData selector(TopicDetailViewModel viewModel) => viewModel.body;

  @override
  Widget build(BuildContext context, TopicBodyData data) {
    return switch (data.state) {
      SectionState.loading => const _TopicSkeleton(),
      SectionState.ready => _SubTopicList(ids: data.subTopicIds),
      SectionState.empty => const _TopicEmpty(),
      SectionState.error || SectionState.offline => const _TopicError(),
    };
  }
}

/// The accordion cards, 8 apart, 16 under the title block (pano 7.3 kare 1
/// y=206).
class _SubTopicList extends StatelessWidget {
  const _SubTopicList({required this.ids});

  final List<String> ids;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s16,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverList.separated(
        itemCount: ids.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s8),
        itemBuilder: (_, index) =>
            _SubTopicCard(key: ValueKey(ids[index]), id: ids[index]),
      ),
    );
  }
}

/// One sub-topic card (C50 first level): the name 17/24 · 700, "4 madde" and
/// "1 eksik" under it, the caret at the right, and the items inside. It
/// follows its own sub-topic, so learning an item redraws this card only.
class _SubTopicCard
    extends SelectorViewModelWidget<TopicDetailViewModel, SubTopicView?> {
  const _SubTopicCard({required this.id, super.key});

  final String id;

  @override
  SubTopicView? selector(TopicDetailViewModel viewModel) =>
      viewModel.subTopic(id);

  /// The header padding of the first level (pano 7.3: 14 / 12 / 14 / 16).
  static const EdgeInsets _headerPadding = EdgeInsets.fromLTRB(
    AppSpacing.s16,
    14,
    AppSpacing.s12,
    14,
  );

  @override
  Widget build(BuildContext context, SubTopicView? data) {
    if (data == null) return const SizedBox.shrink();
    final viewModel = getParentViewModel<TopicDetailViewModel>(
      context,
      listen: false,
    );
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final text = context.appText;
    return AppAccordion(
      title: data.name,
      titleStyle: text.headline,
      indicator: AppAccordionIndicator.plain,
      headerPadding: _headerPadding,
      bodyPadding: EdgeInsets.zero,
      initiallyExpanded: viewModel.opensInitially(data.id),
      summary: Wrap(
        spacing: AppSpacing.s8,
        runSpacing: AppSpacing.s4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            l10n.topicDetail_itemCount(TrFormat.sira(data.items.length)),
            style: text.caption.copyWith(color: colors.textSecondary),
          ),
          if (data.missingCount > 0) EksikTag(count: data.missingCount),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in data.items)
            _ItemTile(
              key: ValueKey(item.key),
              item: item,
              initiallyOpen: item.key == viewModel.initialOpenItem,
              onOpenCard: () => viewModel.openCard(item.key),
            ),
        ],
      ),
    );
  }
}
