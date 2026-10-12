part of '../coaching_view.dart';

/// The skeleton of "Koçluk" (pano 9.5 kare 1 layout, 15 s at most): the coach
/// card with its round avatar and two lines, and the box under it.
class _CoachingSkeleton extends StatelessWidget {
  const _CoachingSkeleton();

  /// The skeleton of the info box.
  static const double _boxHeight = 60;

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
        child: AppSkeleton(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.bgSurface,
                  borderRadius: AppRadius.borderLg,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(AppSpacing.s16),
                  child: Row(
                    children: [
                      SkeletonBox(
                        width: AppAvatarSize.coachCard,
                        height: AppAvatarSize.coachCard,
                        circle: true,
                      ),
                      SizedBox(width: AppSpacing.s16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 140, height: _lineHeight),
                          SizedBox(height: AppSpacing.s8),
                          SkeletonBox(width: 64, height: _lineHeight),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              const SkeletonBox(width: double.infinity, height: _boxHeight),
            ],
          ),
        ),
      ),
    );
  }
}

/// The load failed or ran out of time: the screen-level error with "Tekrar
/// Dene". The bar and its Back button stay.
class _CoachingError extends StatelessWidget {
  const _CoachingError();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<CoachingViewModel>(
      context,
      listen: false,
    );
    return SliverToBoxAdapter(
      child: AppErrorState.screen(
        title: l10n.coaching_errorTitle,
        message: l10n.accountSettings_loadErrorMessage,
        onRetry: viewModel.retry,
      ),
    );
  }
}
