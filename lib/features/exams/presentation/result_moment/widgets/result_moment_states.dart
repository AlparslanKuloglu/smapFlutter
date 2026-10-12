part of '../result_moment_view.dart';

/// The screen error: "Sonuç yüklenemedi", "Bağlantını kontrol edip tekrar
/// dene." and "Tekrar Dene", which returns to the skeleton (the board draws no
/// error frame: this is the 5.8 kare 3 pattern). The close button and the
/// two destination buttons stay; no haptic on the error itself.
class _MomentErrorSection
    extends SelectorViewModelWidget<ResultMomentViewModel, SectionState> {
  const _MomentErrorSection();

  @override
  SectionState selector(ResultMomentViewModel viewModel) =>
      viewModel.screenState;

  @override
  Widget build(BuildContext context, SectionState data) {
    if (data != SectionState.error && data != SectionState.offline) {
      return _noSliver;
    }
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ResultMomentViewModel>(
      context,
      listen: false,
    );
    return SliverToBoxAdapter(
      child: AppErrorState.screen(
        title: l10n.resultMoment_errorTitle,
        message: l10n.resultMoment_errorMessage,
        onRetry: viewModel.retry,
      ),
    );
  }
}
