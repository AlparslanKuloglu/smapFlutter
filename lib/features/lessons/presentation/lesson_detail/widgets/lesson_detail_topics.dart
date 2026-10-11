part of '../lesson_detail_view.dart';

/// The topic list: the skeleton, the card of topic rows, the empty filter
/// card or the error state (pano 7.2, 7.5 kare 1 to 3). Nothing while the
/// Edebiyat detail shows its authors.
class _LessonTopicsSection
    extends
        SelectorViewModelWidget<
          LessonDetailViewModel,
          (LessonTopicsData, bool)
        > {
  const _LessonTopicsSection();

  @override
  (LessonTopicsData, bool) selector(LessonDetailViewModel viewModel) =>
      (viewModel.topics, !viewModel.showsAuthors);

  @override
  Widget build(BuildContext context, (LessonTopicsData, bool) data) {
    final (topics, show) = data;
    if (!show) return _noSliver;
    return switch (topics.state) {
      SectionState.loading => const _TopicsSkeleton(),
      SectionState.ready =>
        topics.topics.isEmpty
            ? _FilterEmptyCard(data: topics)
            : _TopicRowsCard(data: topics),
      SectionState.empty => const _LessonEmpty(),
      SectionState.error || SectionState.offline => const _TopicsError(),
    };
  }
}

/// The card of topic rows (C22 `TopicRow`; pano 7.2): 16 under the controls,
/// the numbers of the full list. With the filter on, the footnote under the
/// card says so.
class _TopicRowsCard extends StatelessWidget {
  const _TopicRowsCard({required this.data});

  final LessonTopicsData data;

  /// Gap above the footnote (pano 7.2 kare 2: card end to note).
  static const double _noteGap = AppSpacing.s12;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final viewModel = getParentViewModel<LessonDetailViewModel>(
      context,
      listen: false,
    );
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s16,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppRowGroup(
              children: [
                for (final topic in data.topics)
                  TopicRow(
                    key: ValueKey(topic.id),
                    number: topic.number,
                    name: topic.name,
                    missing: topic.missing,
                    onTap: () => viewModel.openTopic(topic),
                  ),
              ],
            ),
            if (data.onlyMissing)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s4,
                  _noteGap,
                  AppSpacing.s4,
                  0,
                ),
                child: Text(
                  l10n.lessonDetail_filterNote,
                  style: context.appText.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The card shown when the missing filter hides every topic (pano 7.5 kare
/// 2): "Bu süzgeçte gösterilecek konu yok", the sentence for the chosen
/// segment and the text button "Süzgeci Kapat". Centered, 24 padding.
class _FilterEmptyCard extends StatelessWidget {
  const _FilterEmptyCard({required this.data});

  final LessonTopicsData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final text = context.appText;
    final viewModel = getParentViewModel<LessonDetailViewModel>(
      context,
      listen: false,
    );
    final label = data.segmentLabel;
    final body = data.isAllSegment || label == null
        ? l10n.lessonDetail_filterEmptyBodyAll
        : l10n.lessonDetail_filterEmptyBody(label);
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s16,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Semantics(
            container: true,
            liveRegion: true,
            child: Column(
              children: [
                Text(
                  l10n.lessonDetail_filterEmptyTitle,
                  textAlign: TextAlign.center,
                  style: text.titleSm.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: text.caption.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.s8),
                AppButton(
                  label: l10n.lessonDetail_filterEmptyAction,
                  variant: AppButtonVariant.text,
                  size: AppButtonSize.md40,
                  onPressed: viewModel.closeFilter,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
