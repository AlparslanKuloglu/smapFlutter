part of '../add_student_sheet.dart';

/// "Ad" and "Soyad" side by side, 12 apart (pano 10.3 kare 1: two columns; a
/// name and a surname are separate so the list can be sorted by either).
class _NameRow extends StatelessWidget {
  const _NameRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _NameField(field: AddStudentField.firstName)),
        SizedBox(width: _addStudentColumnGap),
        Expanded(child: _NameField(field: AddStudentField.lastName)),
      ],
    );
  }
}

/// One of the two name fields; each shows its own issue.
class _NameField
    extends SelectorViewModelWidget<AddStudentViewModel, AddStudentIssue?> {
  const _NameField({required this.field});

  final AddStudentField field;

  bool get _isFirst => field == AddStudentField.firstName;

  @override
  AddStudentIssue? selector(AddStudentViewModel viewModel) =>
      viewModel.issueFor(field);

  @override
  Widget build(BuildContext context, AddStudentIssue? issue) {
    final l10n = AppLocalizations.of(context);
    final scope = _AddStudentScope.of(context);
    final viewModel = getParentViewModel<AddStudentViewModel>(
      context,
      listen: false,
    );
    return KeyedSubtree(
      key: scope.anchors[field],
      child: AppTextField(
        label: _isFirst ? l10n.addStudent_firstName : l10n.addStudent_lastName,
        controller: _isFirst ? scope.firstName : scope.lastName,
        focusNode: scope.focus[field],
        errorText: issue == null ? null : addStudentIssueText(l10n, issue),
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.words,
        onChanged: _isFirst ? viewModel.onFirstName : viewModel.onLastName,
      ),
    );
  }
}

typedef _UsernameData = (UsernameCheckState, AddStudentIssue?);

/// "Kullanıcı adı" with its live check and "Kontrol Et" beside it (pano 10.3
/// kare 1: "Bu kullanıcı adı boşta."; spec 10.3 for a taken name with the
/// free-name chip). A spinner at the right of the box while the server is
/// asked.
class _UsernameRow
    extends SelectorViewModelWidget<AddStudentViewModel, _UsernameData> {
  const _UsernameRow();

  @override
  _UsernameData selector(AddStudentViewModel viewModel) =>
      (viewModel.usernameCheck, viewModel.issueFor(AddStudentField.username));

  @override
  Widget build(BuildContext context, _UsernameData data) {
    final (check, issue) = data;
    final l10n = AppLocalizations.of(context);
    final scope = _AddStudentScope.of(context);
    final viewModel = getParentViewModel<AddStudentViewModel>(
      context,
      listen: false,
    );
    final available = issue == null && check.status == UsernameStatus.available;
    final suggestion = issue == AddStudentIssue.usernameTaken
        ? check.suggestion
        : null;
    return KeyedSubtree(
      key: scope.anchors[AddStudentField.username],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  label: l10n.addStudent_username,
                  controller: scope.username,
                  focusNode: scope.focus[AddStudentField.username],
                  errorText: issue == null
                      ? null
                      : addStudentIssueText(l10n, issue),
                  successText: available ? l10n.addStudent_usernameFree : null,
                  helperText: check.status == UsernameStatus.offline
                      ? l10n.addStudent_usernameOffline
                      : null,
                  checking: check.status == UsernameStatus.checking,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  inputFormatters: const [UserNameInputFormatter()],
                  onChanged: viewModel.onUsername,
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Padding(
                padding: EdgeInsets.only(top: _labelBlock(context)),
                child: AppBarAction(
                  label: l10n.addStudent_check,
                  field: true,
                  focusGapColor: context.appColors.bgRaised,
                  onPressed: viewModel.checkUsernameNow,
                ),
              ),
            ],
          ),
          if (suggestion != null) ...[
            const SizedBox(height: AppSpacing.s8),
            _UsernameSuggestion(
              name: suggestion,
              onPicked: () {
                scope.username.value = TextEditingValue(
                  text: suggestion,
                  selection: TextSelection.collapsed(offset: suggestion.length),
                );
                viewModel.onUsername(suggestion, immediately: true);
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// "Boşta olan:" and the free name as a 40 pt chip; a tap writes it into the
/// field and runs the check again (the sign-up's pano 2.6 kare 1 pattern).
class _UsernameSuggestion extends StatelessWidget {
  const _UsernameSuggestion({required this.name, required this.onPicked});

  final String name;
  final VoidCallback onPicked;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    return Row(
      children: [
        Text(
          l10n.addStudent_usernameSuggest,
          style: context.appText.caption.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(width: AppSpacing.s8),
        Flexible(
          child: Semantics(
            label: l10n.addStudent_usernameSuggestA11y(name),
            excludeSemantics: true,
            button: true,
            onTap: onPicked,
            child: AppChip(
              label: name,
              onTap: onPicked,
              size: AppChipSize.md40,
              focusGapColor: colors.bgRaised,
            ),
          ),
        ),
      ],
    );
  }
}
