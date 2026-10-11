part of '../topic_detail_view.dart';

/// The bar of Konu Detayı: Back, and the topic's name once the title under it
/// has scrolled away (pano 7.3 kare 2: "Sözcükte Anlam" in the short bar).
class _TopicBar extends SelectorViewModelWidget<TopicDetailViewModel, String> {
  const _TopicBar();

  @override
  String selector(TopicDetailViewModel viewModel) => viewModel.title;

  @override
  Widget build(BuildContext context, String data) => AppDetailBar(title: data);
}

/// The title block (pano 7.3 kare 1): the topic's name 24/32 · 700, under it
/// "Türkçe · TYT · 1. konu" 13/20 · 600 `textSecondary` (2 below) and "5 alt
/// başlık · 25 madde" 15/24 (6 below). While the topic loads, the skeleton of
/// those lines; after a failure nothing (the error state carries the word).
class _TopicTitle
    extends SelectorViewModelWidget<TopicDetailViewModel, _TitleData> {
  const _TopicTitle();

  @override
  _TitleData selector(TopicDetailViewModel viewModel) =>
      (viewModel.header, viewModel.body.state);

  @override
  Widget build(BuildContext context, _TitleData data) {
    final (header, state) = data;
    if (header == null) {
      return state == SectionState.loading ? const _TitleSkeleton() : _noTitle;
    }
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final text = context.appText;
    final lesson = header.isLiterature
        ? l10n.lessons_literatureName
        : header.lessonName;
    final context1 = header.trackLabel == null
        ? l10n.topicDetail_context(lesson, header.number)
        : l10n.topicDetail_contextTrack(
            lesson,
            header.trackLabel!,
            header.number,
          );
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.s8,
          AppSpacing.gutter,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                header.topicName,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: text.titleLg.copyWith(color: colors.textPrimary),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              context1,
              style: text.caption.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (header.subTopicCount > 0) ...[
              const SizedBox(height: AppSpacing.s8),
              Text(
                l10n.topicDetail_counts(
                  TrFormat.sira(header.subTopicCount),
                  TrFormat.sira(header.itemCount),
                ),
                style: text.body.copyWith(color: colors.textPrimary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static const Widget _noTitle = SliverToBoxAdapter(child: SizedBox.shrink());
}

/// What the title selects: the header, or `null` before there is one, and the
/// section's state.
typedef _TitleData = (TopicHeaderData?, SectionState);

/// The title block while loading: a name line and two small lines.
class _TitleSkeleton extends StatelessWidget {
  const _TitleSkeleton();

  @override
  Widget build(BuildContext context) => const SliverToBoxAdapter(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s8,
        AppSpacing.gutter,
        0,
      ),
      child: AppSkeleton(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 200, height: 28),
            SizedBox(height: AppSpacing.s8),
            SkeletonBox(width: 150, height: 14),
            SizedBox(height: AppSpacing.s8),
            SkeletonBox(width: 120, height: 16),
          ],
        ),
      ),
    ),
  );
}
