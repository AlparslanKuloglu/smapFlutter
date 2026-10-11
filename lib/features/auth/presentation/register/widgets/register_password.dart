part of '../register_view.dart';

typedef _PasswordData = (RegisterIssue?, RegisterIssue?);

/// "Şifre" with "En az 8 karakter." and "Şifre (tekrar)" (pano 2.5 kare 2;
/// "Şifreler aynı değil." pano 2.6 kare 2). Both have the show/hide eye.
class _PasswordFields
    extends SelectorViewModelWidget<RegisterViewModel, _PasswordData> {
  const _PasswordFields();

  @override
  _PasswordData selector(RegisterViewModel viewModel) => (
    viewModel.issueFor(RegisterField.password),
    viewModel.issueFor(RegisterField.passwordRepeat),
  );

  @override
  Widget build(BuildContext context, _PasswordData data) {
    final (passwordIssue, repeatIssue) = data;
    final l10n = AppLocalizations.of(context);
    final scope = _RegisterScope.of(context);
    final viewModel = getParentViewModel<RegisterViewModel>(
      context,
      listen: false,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KeyedSubtree(
          key: scope.anchors[RegisterField.password],
          child: AppTextField(
            label: l10n.register_fieldPassword,
            controller: scope.password,
            focusNode: scope.focus[RegisterField.password],
            password: true,
            helperText: l10n.register_passwordHint,
            errorText: passwordIssue == null
                ? null
                : registerIssueText(l10n, passwordIssue),
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            onChanged: viewModel.onPassword,
          ),
        ),
        const SizedBox(height: _registerFieldGap),
        KeyedSubtree(
          key: scope.anchors[RegisterField.passwordRepeat],
          child: AppTextField(
            label: l10n.register_fieldPasswordRepeat,
            controller: scope.passwordRepeat,
            focusNode: scope.focus[RegisterField.passwordRepeat],
            password: true,
            errorText: repeatIssue == null
                ? null
                : registerIssueText(l10n, repeatIssue),
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            onChanged: viewModel.onPasswordRepeat,
          ),
        ),
      ],
    );
  }
}
