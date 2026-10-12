part of '../result_moment_view.dart';

/// What the bar selects: the exam's name and type, for the short title.
typedef _BarData = (String? name, String? typeLabel);

/// The bar of the result moment (pano 5.1: the close button, "Kapat", x=4,
/// y=54): the X on the canvas, which leaves like "Anasayfa" does. Once the
/// page has scrolled (large text), the exam's name shows in the bar.
class _MomentBar
    extends SelectorViewModelWidget<ResultMomentViewModel, _BarData> {
  const _MomentBar();

  @override
  _BarData selector(ResultMomentViewModel viewModel) {
    final model = viewModel.model;
    return (model?.name, model?.typeLabel);
  }

  @override
  Widget build(BuildContext context, _BarData data) {
    final (name, typeLabel) = data;
    final viewModel = getParentViewModel<ResultMomentViewModel>(
      context,
      listen: false,
    );
    return AppDetailBar(
      title:
          name ??
          (typeLabel == null
              ? ''
              : AppLocalizations.of(context).analytics_examUntitled(typeLabel)),
      leading: AppDetailBarLeading.close,
      onLeading: viewModel.openHome,
    );
  }
}

/// What the header section selects: the screen state, the moment and the
/// cover's URL.
typedef _HeaderData = (SectionState, ResultMomentModel?, String?);

/// The identity, the net with its change and the large D/Y/B counter, or
/// their skeleton (pano 5.1 kare 1 and 2; 5.8 for the skeleton's way of
/// mirroring the layout). Nothing while the screen is in its error state.
class _MomentHeaderSection
    extends SelectorViewModelWidget<ResultMomentViewModel, _HeaderData> {
  const _MomentHeaderSection();

  @override
  _HeaderData selector(ResultMomentViewModel viewModel) =>
      (viewModel.screenState, viewModel.model, viewModel.coverUrl);

  @override
  Widget build(BuildContext context, _HeaderData data) {
    final (state, model, coverUrl) = data;
    if (state == SectionState.loading) {
      return const SliverToBoxAdapter(child: _HeaderSkeleton());
    }
    if (model == null) return _noSliver;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.s4,
          AppSpacing.gutter,
          0,
        ),
        child: ExamHeader.moment(
          name: _momentTitle(context, model),
          net: model.net,
          counts: model.counts,
          date: model.date,
          typeLabel: model.typeLabel,
          publisher: model.publisher,
          coverUrl: coverUrl,
          delta: model.delta,
        ),
      ),
    );
  }
}

/// The moment while the result loads: the cover, three text lines, the net,
/// the change and the three counters, in the sizes of the real header (pano
/// 5.1: cover 56 x 76, net 56/64).
class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.fromLTRB(
      AppSpacing.gutter,
      AppSpacing.s4,
      AppSpacing.gutter,
      0,
    ),
    child: AppSkeleton(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 56, height: 76),
              SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 110, height: 16),
                    SizedBox(height: AppSpacing.s8),
                    SkeletonBox(width: 220, height: 24),
                    SizedBox(height: AppSpacing.s8),
                    SkeletonBox(width: 90, height: 16),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s24),
          SkeletonBox(width: 160, height: 56),
          SizedBox(height: AppSpacing.s8),
          SkeletonBox(width: 220, height: 20),
          SizedBox(height: AppSpacing.s24),
          Row(
            children: [
              Expanded(child: SkeletonBox(height: 56)),
              SizedBox(width: AppSpacing.s12),
              Expanded(child: SkeletonBox(height: 56)),
              SizedBox(width: AppSpacing.s12),
              Expanded(child: SkeletonBox(height: 56)),
            ],
          ),
        ],
      ),
    ),
  );
}
