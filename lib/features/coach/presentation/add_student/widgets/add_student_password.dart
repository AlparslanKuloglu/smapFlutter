part of '../add_student_sheet.dart';

/// The gap between the row and its help line (pano 14.8 `margin-top: 6`).
const double _helpGap = 6;

/// "Şifre" (masked, with the eye) and "Oluştur" beside it (pano 10.3 kare 1).
/// "Oluştur" writes a readable 10-character password into the field; the help
/// line under it says to pass it on and that changing it at the first sign-in
/// is advised; it stands under the whole row (pano 14.8 kare 1: full width,
/// 6 under it, one line), not under the field alone.
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
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
          if (issue == null) ...[
            const SizedBox(height: _helpGap),
            Text(
              l10n.addStudent_passwordHelp,
              style: context.appText.caption.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
