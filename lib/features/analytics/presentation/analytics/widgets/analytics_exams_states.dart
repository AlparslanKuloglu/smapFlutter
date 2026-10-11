part of '../analytics_view.dart';

/// The Denemelerim tab while it loads: the segment and the summary line (only
/// on the very first load; later the real ones stay) and three rows' worth of
/// blocks in the list card's place. The boards draw no skeleton for this tab;
/// it follows the row's own shape (cover 40 x 54, two text lines, the net).
class _ExamsSkeleton extends StatelessWidget {
  const _ExamsSkeleton({required this.withControls});

  final bool withControls;

  static const int _rows = 3;
  static const double _segmentHeight = 56;
  static const double _summaryHeight = 20;
  static const double _coverWidth = 40;
  static const double _coverHeight = 54;
  static const double _nameWidth = 180;
  static const double _metaWidth = 120;
  static const double _netWidth = 48;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        withControls ? _sectionGap : AppSpacing.s12,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: AppSkeleton(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (withControls) ...[
                const SkeletonBox(height: _segmentHeight, radius: AppRadius.md),
                const SizedBox(height: AppSpacing.s8),
                const SkeletonBox(width: _metaWidth, height: _summaryHeight),
                const SizedBox(height: AppSpacing.s12),
              ],
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.bgSurface,
                  borderRadius: AppRadius.borderLg,
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < _rows; i++)
                      const Padding(
                        padding: EdgeInsets.all(AppSpacing.s16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(
                              width: _coverWidth,
                              height: _coverHeight,
                              radius: AppRadius.sm,
                            ),
                            SizedBox(width: AppSpacing.s12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SkeletonBox(width: _nameWidth, height: 20),
                                  SizedBox(height: AppSpacing.s8),
                                  SkeletonBox(width: _metaWidth, height: 16),
                                ],
                              ),
                            ),
                            SizedBox(width: AppSpacing.s8),
                            SkeletonBox(width: _netWidth, height: 32),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The Denemelerim list failed: the same screen error as the Genel tab, with
/// its own title. "Tekrar Dene" reloads from the first page. No haptic.
class _ExamsError extends StatelessWidget {
  const _ExamsError();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<AnalyticsViewModel>(
      context,
      listen: false,
    );
    return SliverToBoxAdapter(
      child: AppErrorState.screen(
        title: l10n.analytics_examsErrorTitle,
        message: l10n.analytics_errorMessage,
        onRetry: viewModel.retryExams,
      ),
    );
  }
}

/// A filter that leaves no exam while the student has some: the controls stay,
/// with a short sentence and "Süzgeci Sıfırla".
class _ExamsFilterEmpty extends StatelessWidget {
  const _ExamsFilterEmpty();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<AnalyticsViewModel>(
      context,
      listen: false,
    );
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s12,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: AppEmptyState.section(
          message: l10n.analytics_filterEmpty,
          actionLabel: l10n.analytics_filterReset,
          onAction: viewModel.resetExamQuery,
        ),
      ),
    );
  }
}
