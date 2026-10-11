part of '../lesson_detail_view.dart';

/// The skeleton of the topic list (pano 7.5 kare 1 pattern): rows of a 28 pt
/// number circle and a line. 15 s at most, then the error state.
class _TopicsSkeleton extends StatelessWidget {
  const _TopicsSkeleton();

  /// The widths of the lines.
  static const List<double> _lineWidths = [160, 130, 180, 140, 120, 150];

  @override
  Widget build(BuildContext context) => const _SkeletonCard(
    rowHeight: TopicRow.minHeight,
    leading: SkeletonBox(width: 28, height: 28, circle: true),
    widths: _lineWidths,
  );
}

/// The skeleton of the author list: rows of a 48 pt round photo and a line.
class _AuthorsSkeleton extends StatelessWidget {
  const _AuthorsSkeleton();

  static const List<double> _lineWidths = [140, 100, 150, 120, 130, 110];

  @override
  Widget build(BuildContext context) => const _SkeletonCard(
    rowHeight: AppSize.rowMinTwoLine,
    leading: SkeletonBox(width: 48, height: 48, circle: true),
    widths: _lineWidths,
  );
}

/// A card of skeleton rows: [leading] and a line [widths] wide, at least
/// [rowHeight] high.
class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({
    required this.rowHeight,
    required this.leading,
    required this.widths,
  });

  final double rowHeight;
  final Widget leading;
  final List<double> widths;

  /// Height of the line next to the leading shape.
  static const double _lineHeight = 18;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s16,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.appColors.bgSurface,
            borderRadius: AppRadius.borderLg,
          ),
          child: AppSkeleton(
            child: Column(
              children: [
                for (final width in widths)
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: rowHeight),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s16,
                        vertical: AppSpacing.s12,
                      ),
                      child: Row(
                        children: [
                          leading,
                          const SizedBox(width: AppSpacing.s12),
                          SkeletonBox(width: width, height: _lineHeight),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A lesson with no topic: one sentence in a section card.
class _LessonEmpty extends StatelessWidget {
  const _LessonEmpty();

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
        message: AppLocalizations.of(context).lessonDetail_noTopics,
      ),
    ),
  );
}

/// The topic list did not load: the screen-level error with "Tekrar Dene".
/// The bar and its Back button stay (pano 7.5 kare 3).
class _TopicsError extends StatelessWidget {
  const _TopicsError();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<LessonDetailViewModel>(
      context,
      listen: false,
    );
    return SliverToBoxAdapter(
      child: AppErrorState.screen(
        title: l10n.lessonDetail_errorTitle,
        message: l10n.lessons_loadErrorMessage,
        onRetry: viewModel.retryTopics,
      ),
    );
  }
}

/// No author to list: one sentence in a section card.
class _AuthorsEmpty extends StatelessWidget {
  const _AuthorsEmpty();

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
        message: AppLocalizations.of(context).literature_empty,
      ),
    ),
  );
}

/// The author list did not load: the screen-level error with "Tekrar Dene".
class _AuthorsError extends StatelessWidget {
  const _AuthorsError();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<LessonDetailViewModel>(
      context,
      listen: false,
    );
    return SliverToBoxAdapter(
      child: AppErrorState.screen(
        title: l10n.literature_errorTitle,
        message: l10n.lessons_loadErrorMessage,
        onRetry: viewModel.retryAuthors,
      ),
    );
  }
}
