part of '../forgot_password_view.dart';

typedef _PasswordData = ({bool updating, PasswordIssue? issue});

/// "Yeni şifreni belirle" (pano 2.4 kare 3): "Yeni şifre" (with the rule "En
/// az 8 karakter." under it), "Yeni şifre (tekrar)" and the primary "Şifreyi
/// Güncelle".
class _NewPasswordStep
    extends SelectorViewModelWidget<ForgotPasswordViewModel, _PasswordData> {
  const _NewPasswordStep();

  @override
  _PasswordData selector(ForgotPasswordViewModel viewModel) =>
      (updating: viewModel.isUpdating, issue: viewModel.passwordIssue);

  @override
  Widget build(BuildContext context, _PasswordData data) =>
      _NewPasswordForm(data: data);
}

/// The two password fields with the controllers and focus nodes the screen
/// owns. The rule is written under the first field from the start and turns
/// red when the password is too short; two different passwords put "Şifreler
/// aynı değil." under the second (kare 3). "ileri" moves to the second field,
/// "bitti" there sends the form.
class _NewPasswordForm extends StatefulWidget {
  const _NewPasswordForm({required this.data});

  final _PasswordData data;

  @override
  State<_NewPasswordForm> createState() => _NewPasswordFormState();
}

class _NewPasswordFormState extends State<_NewPasswordForm> {
  final TextEditingController _password = TextEditingController();
  final TextEditingController _repeat = TextEditingController();
  final FocusNode _repeatFocus = FocusNode();

  @override
  void dispose() {
    _password.dispose();
    _repeat.dispose();
    _repeatFocus.dispose();
    super.dispose();
  }

  void _submit() => getParentViewModel<ForgotPasswordViewModel>(
    context,
    listen: false,
  ).submitPassword(_password.text, _repeat.text);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ForgotPasswordViewModel>(
      context,
      listen: false,
    );
    final data = widget.data;
    return _StepFrame(
      title: l10n.forgotPassword_newTitle,
      children: [
        AppTextField(
          label: l10n.forgotPassword_newPasswordLabel,
          controller: _password,
          password: true,
          autofocus: true,
          enabled: !data.updating,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          helperText: l10n.forgotPassword_passwordRule,
          errorText: data.issue == PasswordIssue.tooShort
              ? l10n.forgotPassword_passwordRule
              : null,
          onChanged: (_) => viewModel.passwordEdited(),
          onSubmitted: (_) => _repeatFocus.requestFocus(),
        ),
        AppTextField(
          label: l10n.forgotPassword_newPasswordRepeatLabel,
          controller: _repeat,
          focusNode: _repeatFocus,
          password: true,
          enabled: !data.updating,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          errorText: data.issue == PasswordIssue.mismatch
              ? l10n.forgotPassword_errMismatch
              : null,
          onChanged: (_) => viewModel.passwordEdited(),
          onSubmitted: (_) => _submit(),
        ),
        AppButton(
          label: l10n.forgotPassword_update,
          loading: data.updating,
          expand: true,
          onPressed: _submit,
        ),
      ],
    );
  }
}
