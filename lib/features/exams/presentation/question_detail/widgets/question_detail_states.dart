part of '../question_detail_view.dart';

/// The screen error: the result could not be read ("Soru yüklenemedi",
/// "Bağlantını kontrol edip tekrar dene.", "Tekrar Dene"). The bar and its
/// Back button stay.
class _QuestionScreenError
    extends SelectorViewModelWidget<QuestionDetailViewModel, SectionState> {
  const _QuestionScreenError();

  @override
  SectionState selector(QuestionDetailViewModel viewModel) =>
      viewModel.screenState;

  @override
  Widget build(BuildContext context, SectionState data) {
    if (data != SectionState.error && data != SectionState.offline) {
      return _noSliver;
    }
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<QuestionDetailViewModel>(
      context,
      listen: false,
    );
    return SliverToBoxAdapter(
      child: AppErrorState.screen(
        title: l10n.examDetail_questionErrorTitle,
        message: l10n.examDetail_errorMessage,
        onRetry: viewModel.retry,
      ),
    );
  }
}

/// The skeleton of the analysis while it loads: a heading line and three text
/// lines.
class _AnalysisSkeleton extends StatelessWidget {
  const _AnalysisSkeleton();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
    child: AppSkeleton(
      semanticLabel: AppLocalizations.of(context).kit_loading,
      child: const SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 120, height: 20),
            SizedBox(height: AppSpacing.s8),
            SizedBox(width: double.infinity, child: SkeletonBox(height: 16)),
            SizedBox(height: AppSpacing.s8),
            SizedBox(width: double.infinity, child: SkeletonBox(height: 16)),
            SizedBox(height: AppSpacing.s8),
            SkeletonBox(width: 180, height: 16),
          ],
        ),
      ),
    ),
  );
}
