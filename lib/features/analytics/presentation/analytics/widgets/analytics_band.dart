part of '../analytics_view.dart';

/// What the band redraws on: the selected tab, and whether the offline strip
/// is up (the band then squares its corners).
typedef _BandData = ({AnalyticsTab tab, bool offline});

/// The root band (pano 6.1 "Kök bantta iki sekme"): "Analizlerim" with the
/// tabs "Genel" and "Denemelerim" (the selected one has the orange line).
/// "Analiz" and "Harita" are not in v1 (Ek D-4). While the device is offline
/// the strip sits under the band and the corners are square (pano 6.3 kare
/// 4).
class _AnalyticsBand
    extends SelectorViewModelWidget<AnalyticsViewModel, _BandData> {
  const _AnalyticsBand();

  @override
  _BandData selector(AnalyticsViewModel viewModel) =>
      (tab: viewModel.tab, offline: viewModel.offline);

  @override
  Widget build(BuildContext context, _BandData data) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<AnalyticsViewModel>(
      context,
      listen: false,
    );
    return AppRootBand(
      title: l10n.analytics_title,
      squareCorners: data.offline,
      bottom: AppRootBandBottom.tabs(
        child: Semantics(
          container: true,
          label: l10n.analytics_tabsA11y,
          child: AppTabBar(
            onNavy: true,
            labels: [l10n.analytics_tabGeneral, l10n.analytics_tabExams],
            selectedIndex: data.tab.index,
            onChanged: (index) =>
                viewModel.selectTab(AnalyticsTab.values[index]),
          ),
        ),
      ),
    );
  }
}
