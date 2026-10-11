part of '../lessons_view.dart';

/// The skeleton of Derslerim (pano 7.5 kare 1): the band and the segment have
/// come at once; the card holds six rows of a 40 pt tile and a line of 120,
/// 90, 140, 110, 100 and 80 wide. 15 s at most, then the error state.
class _LessonsSkeleton extends StatelessWidget {
  const _LessonsSkeleton();

  /// The widths of the lines (pano 7.5 kare 1).
  static const List<double> _lineWidths = [120, 90, 140, 110, 100, 80];

  /// Height of the line next to the tile.
  static const double _lineHeight = 18;

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
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.bgSurface,
            borderRadius: AppRadius.borderLg,
          ),
          child: AppSkeleton(
            child: Column(
              children: [
                for (final width in _lineWidths)
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: AppSize.rowMinTwoLine,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s16,
                        vertical: AppSpacing.s16,
                      ),
                      child: Row(
                        children: [
                          const SkeletonBox(
                            width: 40,
                            height: 40,
                            radius: AppRadius.md,
                          ),
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

/// The error state of Derslerim: the lessons did not load (or the first load
/// took 15 s). "Tekrar Dene" goes back to the skeleton. Offline with nothing
/// saved reads the same; the shell's strip says why.
class _LessonsError extends StatelessWidget {
  const _LessonsError();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<LessonsViewModel>(
      context,
      listen: false,
    );
    return SliverToBoxAdapter(
      child: AppErrorState.screen(
        title: l10n.lessons_loadErrorTitle,
        message: l10n.lessons_loadErrorMessage,
        onRetry: viewModel.retry,
      ),
    );
  }
}
