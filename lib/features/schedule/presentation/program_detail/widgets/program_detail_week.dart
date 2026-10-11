part of '../program_detail_view.dart';

typedef _WeekData = ({
  SectionState state,
  ProgramViewMode mode,
  ProgramDetail? detail,
  DateTime today,
});

/// The Hafta view (pano 3.4 kare 4, 3.8): the [WeekGrid] fills the page under
/// the segment, over the program's whole span; a block opens the topic.
class _WeekSection
    extends SelectorViewModelWidget<ProgramDetailViewModel, _WeekData> {
  const _WeekSection();

  @override
  _WeekData selector(ProgramDetailViewModel viewModel) => (
    state: viewModel.section.state,
    mode: viewModel.mode,
    detail: viewModel.detail,
    today: viewModel.today,
  );

  @override
  Widget build(BuildContext context, _WeekData data) {
    final detail = data.detail;
    if (data.state != SectionState.ready ||
        data.mode != ProgramViewMode.week ||
        detail == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverFillRemaining(
      hasScrollBody: true,
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.s16),
        child: WeekGrid(
          days: detail.days,
          entries: detail.entries,
          today: data.today,
          bottomPadding: AppBottomBar.heightOf(context),
          onOpenEntry: (entry) => _openTopic(context, entry),
        ),
      ),
    );
  }
}
