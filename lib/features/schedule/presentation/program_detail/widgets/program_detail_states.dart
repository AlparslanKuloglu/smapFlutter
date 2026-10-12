part of '../program_detail_view.dart';

/// The program as a skeleton (pano 3.7 kare 2 pattern): the title, the
/// segment, seven day chips and three rows, where the real screen will be.
/// At 15 s without an answer the screen turns to the error.
class _DetailLoading
    extends SelectorViewModelWidget<ProgramDetailViewModel, SectionState> {
  const _DetailLoading();

  @override
  SectionState selector(ProgramDetailViewModel viewModel) =>
      viewModel.section.state;

  @override
  Widget build(BuildContext context, SectionState state) {
    if (state != SectionState.loading) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s8,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: AppSkeleton(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonBox(width: 180, height: 28),
              const SizedBox(height: AppSpacing.s12),
              const SkeletonBox(width: 120, height: 14),
              const SizedBox(height: AppSpacing.s16),
              const SkeletonBox(height: 44, radius: AppRadius.md),
              const SizedBox(height: AppSpacing.s16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < 7; i++)
                    const SkeletonBox(
                      width: 48,
                      height: 64,
                      radius: AppRadius.md,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.s24),
              const SkeletonBox(width: 150, height: 20),
              const SizedBox(height: AppSpacing.s12),
              for (var i = 0; i < 3; i++) ...[
                const SkeletonBox(height: 64, radius: AppRadius.lg),
                const SizedBox(height: AppSpacing.s8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The program could not be loaded (pano 3.7 kare 3): "Programların
/// yüklenemedi", "Bağlantını kontrol edip tekrar dene.", "Tekrar Dene".
class _DetailError
    extends SelectorViewModelWidget<ProgramDetailViewModel, SectionState> {
  const _DetailError();

  @override
  SectionState selector(ProgramDetailViewModel viewModel) =>
      viewModel.section.state;

  @override
  Widget build(BuildContext context, SectionState state) {
    if (state != SectionState.error && state != SectionState.offline) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ProgramDetailViewModel>(
      context,
      listen: false,
    );
    return SliverToBoxAdapter(
      child: AppErrorState.screen(
        title: l10n.schedule_loadError,
        message: l10n.schedule_loadErrorBody,
        onRetry: viewModel.retry,
      ),
    );
  }
}

/// Room under the day view for the bottom bar.
class _BottomSpace
    extends SelectorViewModelWidget<ProgramDetailViewModel, ProgramViewMode> {
  const _BottomSpace();

  @override
  ProgramViewMode selector(ProgramDetailViewModel viewModel) => viewModel.mode;

  @override
  Widget build(BuildContext context, ProgramViewMode mode) {
    if (mode == ProgramViewMode.week) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: SizedBox(height: AppBottomBar.heightOf(context) + AppSpacing.s24),
    );
  }
}
