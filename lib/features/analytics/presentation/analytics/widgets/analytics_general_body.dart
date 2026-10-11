part of '../analytics_view.dart';

/// The Genel tab: the filter row, then what the section's state says.
class _GeneralBody extends StatelessWidget {
  const _GeneralBody();

  @override
  Widget build(BuildContext context) => const SliverMainAxisGroup(
    slivers: [_GeneralFilterRow(), _GeneralStateSliver()],
  );
}

typedef _GeneralStateData = ({
  SectionState state,
  bool noExamsAtAll,
  bool firstLoad,
  bool countsSettled,
});

/// Skeleton, error, empty or the chart with the boxes (pano 6.1, 6.3).
class _GeneralStateSliver
    extends SelectorViewModelWidget<AnalyticsViewModel, _GeneralStateData> {
  const _GeneralStateSliver();

  @override
  _GeneralStateData selector(AnalyticsViewModel viewModel) => (
    state: viewModel.general.state,
    noExamsAtAll: viewModel.noExamsAtAll,
    firstLoad: !viewModel.generalSettled,
    countsSettled: viewModel.countsSettled,
  );

  @override
  Widget build(BuildContext context, _GeneralStateData data) =>
      switch (data.state) {
        SectionState.loading => _GeneralSkeleton(withPill: data.firstLoad),
        SectionState.ready => const _GeneralReady(),
        // No exam for this filter: wait for the counters to tell "no exam
        // at all" from "none for this filter".
        SectionState.empty when !data.countsSettled => _GeneralSkeleton(
          withPill: data.firstLoad,
        ),
        SectionState.empty =>
          data.noExamsAtAll
              ? const _NoExamsEmpty()
              : const _GeneralFilterEmpty(),
        SectionState.error || SectionState.offline => const _GeneralError(),
      };
}

/// The chart and the boxes of the loaded filter.
class _GeneralReady extends StatelessWidget {
  const _GeneralReady();

  @override
  Widget build(BuildContext context) =>
      const SliverMainAxisGroup(slivers: [_ChartSection(), _StatsSection()]);
}
