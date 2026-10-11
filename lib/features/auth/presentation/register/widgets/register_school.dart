part of '../register_view.dart';

typedef _SchoolData = (
  UserRole,
  SchoolGrade?,
  StudyTrack?,
  RegisterIssue?,
  RegisterIssue?,
);

/// A student's "Sınıf" and "Alan" (pano 2.5 kare 2; 9 and 10 have no track,
/// pano 2.6 kare 4) or, for a coach, the note about the coaching code (pano
/// 2.5 kare 3). Both selects open a sheet with one radio row per option.
class _SchoolSection
    extends SelectorViewModelWidget<RegisterViewModel, _SchoolData> {
  const _SchoolSection();

  @override
  _SchoolData selector(RegisterViewModel viewModel) => (
    viewModel.role,
    viewModel.grade,
    viewModel.track,
    viewModel.issueFor(RegisterField.grade),
    viewModel.issueFor(RegisterField.track),
  );

  @override
  Widget build(BuildContext context, _SchoolData data) {
    final (role, grade, track, gradeIssue, trackIssue) = data;
    final l10n = AppLocalizations.of(context);
    if (role == UserRole.coach) {
      return AppNoticeBox(message: l10n.register_coachCodeInfo);
    }
    final scope = _RegisterScope.of(context);
    final viewModel = getParentViewModel<RegisterViewModel>(
      context,
      listen: false,
    );
    final trackEnabled = grade == null || grade.requiresTrack;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KeyedSubtree(
          key: scope.anchors[RegisterField.grade],
          child: AppSelectField<SchoolGrade>(
            label: l10n.register_fieldGrade,
            focusNode: scope.focus[RegisterField.grade],
            value: grade,
            options: [
              for (final option in SchoolGrade.values)
                AppSelectOption(
                  value: option,
                  label: registerGradeLabel(l10n, option),
                ),
            ],
            errorText: gradeIssue == null
                ? null
                : registerIssueText(l10n, gradeIssue),
            onChanged: viewModel.setGrade,
          ),
        ),
        const SizedBox(height: _registerFieldGap),
        KeyedSubtree(
          key: scope.anchors[RegisterField.track],
          child: AppSelectField<StudyTrack>(
            label: l10n.register_fieldTrack,
            focusNode: scope.focus[RegisterField.track],
            value: trackEnabled ? track : null,
            enabled: trackEnabled,
            disabledValueText: l10n.register_trackNotSelectable,
            helperText: trackEnabled
                ? null
                : l10n.register_trackNotSelectableReason,
            options: [
              for (final option in StudyTrack.selectable)
                AppSelectOption(
                  value: option,
                  label: registerTrackLabel(l10n, option),
                ),
            ],
            errorText: trackIssue == null
                ? null
                : registerIssueText(l10n, trackIssue),
            onChanged: viewModel.setTrack,
          ),
        ),
      ],
    );
  }
}
