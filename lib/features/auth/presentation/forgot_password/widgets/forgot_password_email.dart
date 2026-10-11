part of '../forgot_password_view.dart';

typedef _EmailData = ({bool sending, bool invalid});

/// "Şifreni sıfırla" (pano 2.4 kare 1): "Hesabındaki e-posta adresini yaz; 6
/// haneli bir kod gönderelim.", the "E-posta" field and the primary "Kod
/// Gönder".
class _EmailStep
    extends SelectorViewModelWidget<ForgotPasswordViewModel, _EmailData> {
  const _EmailStep();

  @override
  _EmailData selector(ForgotPasswordViewModel viewModel) =>
      (sending: viewModel.isSending, invalid: viewModel.emailInvalid);

  @override
  Widget build(BuildContext context, _EmailData data) {
    final initial = getParentViewModel<ForgotPasswordViewModel>(
      context,
      listen: false,
    ).email;
    return _EmailForm(data: data, initialEmail: initial);
  }
}

/// The e-mail field and its button, with the controller the screen owns. The
/// field starts with the address the user sent a code to when they come back
/// to change it. E-mail keyboard; "bitti" sends the form.
class _EmailForm extends StatefulWidget {
  const _EmailForm({required this.data, required this.initialEmail});

  final _EmailData data;
  final String initialEmail;

  @override
  State<_EmailForm> createState() => _EmailFormState();
}

class _EmailFormState extends State<_EmailForm> {
  late final TextEditingController _email = TextEditingController(
    text: widget.initialEmail,
  );

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() => getParentViewModel<ForgotPasswordViewModel>(
    context,
    listen: false,
  ).submitEmail(_email.text);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ForgotPasswordViewModel>(
      context,
      listen: false,
    );
    final sending = widget.data.sending;
    return _StepFrame(
      title: l10n.forgotPassword_emailTitle,
      description: l10n.forgotPassword_emailBody,
      children: [
        AppTextField(
          label: l10n.forgotPassword_emailLabel,
          controller: _email,
          autofocus: true,
          enabled: !sending,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          errorText: widget.data.invalid
              ? l10n.forgotPassword_errEmailFormat
              : null,
          onChanged: (_) => viewModel.emailEdited(),
          onSubmitted: (_) => _submit(),
        ),
        AppButton(
          label: l10n.forgotPassword_sendCode,
          loading: sending,
          expand: true,
          onPressed: _submit,
        ),
      ],
    );
  }
}
