part of '../topic_detail_view.dart';

/// The skeleton of the content: three sub-topic cards, each a title line and
/// a small line (15 s at most, then the error state).
class _TopicSkeleton extends StatelessWidget {
  const _TopicSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s16,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: AppSkeleton(
          child: Column(
            children: [
              for (final width in const [220.0, 180.0, 200.0]) ...[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.bgSurface,
                    borderRadius: AppRadius.borderLg,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: width, height: 20),
                        const SizedBox(height: AppSpacing.s8),
                        const SkeletonBox(width: 70, height: 14),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A topic without sub-topics (pano 7.5 "Boş metinler"): "Bu konunun içeriği
/// hazırlanıyor."
class _TopicEmpty extends StatelessWidget {
  const _TopicEmpty();

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.gutter,
      AppSpacing.s16,
      AppSpacing.gutter,
      0,
    ),
    sliver: SliverToBoxAdapter(
      child: AppEmptyState.section(
        message: AppLocalizations.of(context).topicDetail_empty,
      ),
    ),
  );
}

/// The topic did not load (pano 7.5 kare 3): the screen-level error "Konu
/// yüklenemedi" with "Tekrar Dene". Back is always there, in the bar.
class _TopicError extends StatelessWidget {
  const _TopicError();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<TopicDetailViewModel>(
      context,
      listen: false,
    );
    return SliverToBoxAdapter(
      child: AppErrorState.screen(
        title: l10n.topicDetail_errorTitle,
        message: l10n.lessons_loadErrorMessage,
        onRetry: viewModel.retry,
      ),
    );
  }
}
