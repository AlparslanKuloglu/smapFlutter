part of '../student_profile_view.dart';

typedef _BarData = ({SectionState state, String name});

/// The bar (pano 10.4 kare 1 to 3): back, and the one action "Görüşme Planla"
/// with a CalendarBlank, which opens the new meeting sheet with this student
/// chosen. The student's name is the bar's small title once the header has
/// scrolled away. The action waits for the student (a skeleton, an error and
/// a missing student have none). While the Program tab is being edited the bar
/// is the edit bar of pano 14.1 kare 3: no back, the program's name as the
/// small title and the one action "Bitti".
class _ProfileBar
    extends SelectorViewModelWidget<StudentProfileViewModel, _BarData> {
  const _ProfileBar();

  @override
  _BarData selector(StudentProfileViewModel viewModel) => (
    state: viewModel.profile.state,
    name: viewModel.profile.data?.name ?? '',
  );

  @override
  Widget build(BuildContext context, _BarData data) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<StudentProfileViewModel>(
      context,
      listen: false,
    );
    final edit = _PageAnchors.of(context).edit;
    return ValueListenableBuilder<bool>(
      valueListenable: edit.editing,
      builder: (context, editing, _) => editing
          ? AppDetailBar(
              title: edit.title.isEmpty ? data.name : edit.title,
              leading: AppDetailBarLeading.none,
              action: AppBarAction(
                label: l10n.schedule_done,
                onPressed: edit.finish,
              ),
            )
          : AppDetailBar(
              title: data.name,
              action: data.state == SectionState.ready
                  ? AppBarAction(
                      label: l10n.coachStudentProfile_planMeeting,
                      icon: PhosphorIconsRegular.calendarBlank,
                      onPressed: () => unawaited(viewModel.planMeeting()),
                    )
                  : null,
            ),
    );
  }
}

/// The context strip (C83; pano 10.4 "ContextStrip (top 102)"): "Alparslan
/// Kuloğlu'nun verileri" and "12. Sınıf · EA", pinned right under the bar and
/// read first. Not drawn before the student is known.
class _ProfileStrip
    extends
        SelectorViewModelWidget<
          StudentProfileViewModel,
          AsyncSection<StudentProfile>
        > {
  const _ProfileStrip();

  @override
  AsyncSection<StudentProfile> selector(StudentProfileViewModel viewModel) =>
      viewModel.profile;

  @override
  Widget build(BuildContext context, AsyncSection<StudentProfile> profile) {
    final student = _PageAnchors.of(
      context,
    ).studentOf(AppLocalizations.of(context), profile.data);
    if (student == null) return _noSliver;
    return PinnedHeaderSliver(child: AppContextStrip(student: student));
  }
}
