part of '../add_student_sheet.dart';

typedef _SchoolData = (
  SchoolGrade?,
  StudyTrack?,
  AddStudentIssue?,
  AddStudentIssue?,
);

/// "Sınıf" and "Alan" side by side, 12 apart (pano 10.3 kare 1 and 2). Both
/// open a sheet with one radio row per option; the grade has "Mezun" too. In
/// the 9th and 10th grade the track is passive ("Seçilmez"; "9. ve 10. sınıfta
/// alan seçilmez."). The tracks are those with a confirmed server code
/// (`StudyTrack.selectable`: Sayısal, Eşit Ağırlık, Sözel).
class _SchoolRow
    extends SelectorViewModelWidget<AddStudentViewModel, _SchoolData> {
  const _SchoolRow();

  @override
  _SchoolData selector(AddStudentViewModel viewModel) => (
    viewModel.grade,
    viewModel.track,
    viewModel.issueFor(AddStudentField.grade),
    viewModel.issueFor(AddStudentField.track),
  );

  @override
  Widget build(BuildContext context, _SchoolData data) {
    final (grade, track, gradeIssue, trackIssue) = data;
    final l10n = AppLocalizations.of(context);
    final scope = _AddStudentScope.of(context);
    final viewModel = getParentViewModel<AddStudentViewModel>(
      context,
      listen: false,
    );
    final trackEnabled = grade == null || grade.requiresTrack;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: KeyedSubtree(
            key: scope.anchors[AddStudentField.grade],
            child: AppSelectField<SchoolGrade>(
              label: l10n.addStudent_grade,
              focusNode: scope.focus[AddStudentField.grade],
              value: grade,
              options: [
                for (final option in SchoolGrade.values)
                  AppSelectOption(
                    value: option,
                    label: accountGradeLabel(l10n, option),
                  ),
              ],
              errorText: gradeIssue == null
                  ? null
                  : addStudentIssueText(l10n, gradeIssue),
              onChanged: viewModel.setGrade,
            ),
          ),
        ),
        const SizedBox(width: _addStudentColumnGap),
        Expanded(
          child: KeyedSubtree(
            key: scope.anchors[AddStudentField.track],
            child: AppSelectField<StudyTrack>(
              label: l10n.addStudent_track,
              focusNode: scope.focus[AddStudentField.track],
              value: trackEnabled ? track : null,
              enabled: trackEnabled,
              disabledValueText: l10n.addStudent_trackNotSelectable,
              helperText: trackEnabled
                  ? null
                  : l10n.addStudent_trackNotSelectableReason,
              options: [
                for (final option in StudyTrack.selectable)
                  AppSelectOption(
                    value: option,
                    label: accountTrackLabel(l10n, option),
                  ),
              ],
              errorText: trackIssue == null
                  ? null
                  : addStudentIssueText(l10n, trackIssue),
              onChanged: viewModel.setTrack,
            ),
          ),
        ),
      ],
    );
  }
}
