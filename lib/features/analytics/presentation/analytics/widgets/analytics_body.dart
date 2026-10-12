part of '../analytics_view.dart';

/// The selected tab's sections.
class _AnalyticsBody
    extends SelectorViewModelWidget<AnalyticsViewModel, AnalyticsTab> {
  const _AnalyticsBody();

  @override
  AnalyticsTab selector(AnalyticsViewModel viewModel) => viewModel.tab;

  @override
  Widget build(BuildContext context, AnalyticsTab tab) => switch (tab) {
    AnalyticsTab.general => const _GeneralBody(),
    AnalyticsTab.exams => const _ExamsBody(),
  };
}
