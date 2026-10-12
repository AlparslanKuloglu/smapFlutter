part of '../student_profile_view.dart';

typedef _TabsData = ({SectionState state, int selected});

/// The three in-screen tabs (C05; pano 10.4 "InScreenTabs `.tabs3`": Analiz ·
/// Denemeler · Program): pinned under the strip once the header has scrolled
/// away, a tab list for the screen reader, the selected one announced. A
/// change plays the selection haptic (the bar does).
class _ProfileTabs
    extends SelectorViewModelWidget<StudentProfileViewModel, _TabsData> {
  const _ProfileTabs();

  @override
  _TabsData selector(StudentProfileViewModel viewModel) =>
      (state: viewModel.profile.state, selected: viewModel.tab.index);

  @override
  Widget build(BuildContext context, _TabsData data) {
    if (data.state != SectionState.ready) return _noSliver;
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<StudentProfileViewModel>(
      context,
      listen: false,
    );
    final anchors = _PageAnchors.of(context);
    return PinnedHeaderSliver(
      child: ColoredBox(
        color: context.appColors.bgCanvas,
        child: Semantics(
          container: true,
          label: l10n.coachStudentProfile_tabsA11y,
          child: AppTabBar(
            labels: [
              l10n.coachStudentProfile_tabAnalysis,
              l10n.coachStudentProfile_tabExams,
              l10n.coachStudentProfile_tabProgram,
            ],
            selectedIndex: data.selected,
            onChanged: (index) {
              viewModel.selectTab(StudentProfileTab.values[index]);
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => anchors.settleScroll(),
              );
            },
          ),
        ),
      ),
    );
  }
}
