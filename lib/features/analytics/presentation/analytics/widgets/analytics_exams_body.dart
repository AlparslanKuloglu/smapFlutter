part of '../analytics_view.dart';

/// The Denemelerim tab: the controls (type segment and summary line), then
/// what the list's state says. The tab loads on its own the first time it is
/// opened, so an error of the Genel tab does not touch it (pano 6.3 kare 3).
class _ExamsBody extends StatelessWidget {
  const _ExamsBody();

  @override
  Widget build(BuildContext context) => const SliverMainAxisGroup(
    slivers: [_ExamsControls(), _ExamsStateSliver()],
  );
}

typedef _ExamsStateData = ({
  SectionState state,
  bool initialQuery,
  bool firstLoad,
});

/// Skeleton, error, empty or the list (pano 6.2).
class _ExamsStateSliver
    extends SelectorViewModelWidget<AnalyticsViewModel, _ExamsStateData> {
  const _ExamsStateSliver();

  @override
  _ExamsStateData selector(AnalyticsViewModel viewModel) => (
    state: viewModel.examList.state,
    initialQuery: viewModel.query.isInitial,
    firstLoad: !viewModel.examsSettled,
  );

  @override
  Widget build(BuildContext context, _ExamsStateData data) =>
      switch (data.state) {
        SectionState.loading => _ExamsSkeleton(withControls: data.firstLoad),
        SectionState.ready => const _ExamsReady(),
        SectionState.empty =>
          data.initialQuery ? const _NoExamsEmpty() : const _ExamsFilterEmpty(),
        SectionState.error || SectionState.offline => const _ExamsError(),
      };
}

/// The rows and what sits under them.
class _ExamsReady extends StatelessWidget {
  const _ExamsReady();

  @override
  Widget build(BuildContext context) =>
      const SliverMainAxisGroup(slivers: [_ExamRowsSliver(), _ExamsFooter()]);
}
