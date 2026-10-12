part of '../student_profile_view.dart';

typedef _BodyData = ({
  AsyncSection<StudentProfile> profile,
  StudentProfileTab tab,
  StudentProfileTab analytics,
  Set<StudentProfileTab> visited,
});

/// The selected tab's body. A tab is built the first time it is opened and
/// kept (hidden, not rebuilt) when another is chosen, so Analiz and Denemeler
/// keep what they loaded (they share one ViewModel, `StudentAnalyticsView`)
/// and Program keeps its program and its edit mode.
class _ProfileBody
    extends SelectorViewModelWidget<StudentProfileViewModel, _BodyData> {
  const _ProfileBody();

  @override
  _BodyData selector(StudentProfileViewModel viewModel) => (
    profile: viewModel.profile,
    tab: viewModel.tab,
    analytics: viewModel.analyticsTab,
    visited: viewModel.visited,
  );

  @override
  Widget build(BuildContext context, _BodyData data) {
    final student = _PageAnchors.of(
      context,
    ).studentOf(AppLocalizations.of(context), data.profile.data);
    if (student == null) return _noSliver;
    final onProgram = data.tab == StudentProfileTab.program;
    return SliverMainAxisGroup(
      slivers: [
        if (data.visited.contains(StudentProfileTab.analysis) ||
            data.visited.contains(StudentProfileTab.exams))
          SliverVisibility(
            visible: !onProgram,
            maintainState: true,
            sliver: StudentAnalyticsView(
              student: student,
              part: data.analytics == StudentProfileTab.exams
                  ? StudentAnalyticsPart.exams
                  : StudentAnalyticsPart.general,
            ),
          ),
        if (data.visited.contains(StudentProfileTab.program))
          SliverVisibility(
            visible: onProgram,
            maintainState: true,
            sliver: _ProgramTab(student: student),
          ),
      ],
    );
  }
}
