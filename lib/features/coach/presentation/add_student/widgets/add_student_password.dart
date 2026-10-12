part of '../add_student_sheet.dart';

/// "Şifre" (masked, with the eye) and "Oluştur" beside it (pano 10.3 kare 1).
/// "Oluştur" writes a readable 10-character password into the field; the help
/// line under it says to pass it on and that changing it at the first sign-in
/// is advised.
class _PasswordRow
    extends SelectorViewModelWidget<AddStudentViewModel, AddStudentIssue?> {
  const _PasswordRow();

  @override
  AddStudentIssue? selector(AddStudentViewModel viewModel) =>
      viewModel.issueFor(AddStudentField.password);

  @override
  Widget build(BuildContext context, AddStudentIssue? issue) {
    final l10n = AppLocalizations.of(context);
    final scope = _AddStudentScope.of(context);
    final viewModel = getParentViewModel<AddStudentViewModel>(
      context,
      listen: false,
    );
    return KeyedSubtree(
      key: scope.anchors[AddStudentField.password],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AppTextField(
              label: l10n.addStudent_password,
              controller: scope.password,
              focusNode: scope.focus[AddStudentField.password],
              password: true,
              errorText: issue == null
                  ? null
                  : addStudentIssueText(l10n, issue),
              helperText: l10n.addStudent_passwordHelp,
              textInputAction: TextInputAction.next,
              onChanged: viewModel.onPassword,
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          Padding(
            padding: EdgeInsets.only(top: _labelBlock(context)),
            child: AppBarAction(
              label: l10n.addStudent_generate,
              field: true,
              focusGapColor: context.appColors.bgRaised,
              onPressed: () =>
                  scope.password.text = viewModel.generatePassword(),
            ),
          ),
        ],
      ),
    );
  }
}
