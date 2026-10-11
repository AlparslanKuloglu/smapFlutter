part of '../forgot_password_view.dart';

typedef _CodeData = ({bool verifying, CodeIssue? issue, int shake, int clears});

/// "Kodu gir" (pano 2.4 kare 2): "Kodu {email} adresine gönderdik. Gelen
/// kutunda yoksa istenmeyen klasörüne bak.", the six boxes "Doğrulama kodu",
/// "Kodu Tekrar Gönder (0:24)" and "E-postayı Değiştir".
class _CodeStep
    extends SelectorViewModelWidget<ForgotPasswordViewModel, _CodeData> {
  const _CodeStep();

  @override
  _CodeData selector(ForgotPasswordViewModel viewModel) => (
    verifying: viewModel.isVerifying,
    issue: viewModel.codeIssue,
    shake: viewModel.codeShake,
    clears: viewModel.codeClears,
  );

  @override
  Widget build(BuildContext context, _CodeData data) => _CodeForm(data: data);
}

/// The boxes with the controller and the focus the screen owns.
///
/// The sixth digit checks the code at once (typed, pasted or filled in by the
/// system). A wrong code leaves the digits in red boxes that shake (the box
/// plays the error haptic) with the sentence below; the next edit clears the
/// red. The boxes are locked while the check runs and take the focus back
/// afterwards; the digits are cleared when the ViewModel says so (a connection
/// failure, a new code, coming back from the password step).
class _CodeForm extends StatefulWidget {
  const _CodeForm({required this.data});

  final _CodeData data;

  @override
  State<_CodeForm> createState() => _CodeFormState();
}

class _CodeFormState extends State<_CodeForm> {
  final TextEditingController _code = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void didUpdateWidget(_CodeForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data.clears != oldWidget.data.clears) _code.clear();
    if (oldWidget.data.verifying && !widget.data.verifying) {
      // Locked while the check ran; the focus can come back once enabled.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ForgotPasswordViewModel>(
      context,
      listen: false,
    );
    final data = widget.data;
    return _StepFrame(
      title: l10n.forgotPassword_codeTitle,
      description: l10n.forgotPassword_codeBody(viewModel.email),
      children: [
        AppCodeInput(
          label: l10n.forgotPassword_codeLabel,
          controller: _code,
          focusNode: _focus,
          autofocus: true,
          enabled: !data.verifying,
          errorText: switch (data.issue) {
            CodeIssue.wrongOrExpired => l10n.forgotPassword_errCode,
            CodeIssue.tooManyAttempts => l10n.forgotPassword_errTooMany,
            null => null,
          },
          errorShake: data.shake,
          onChanged: (_) => viewModel.codeEdited(),
          onCompleted: viewModel.submitCode,
        ),
        // The two text buttons sit under each other, flush left: their own
        // 12 pt side padding is pushed out of the 24 gutter (pano 2.4 kare 2
        // "margin-left -12").
        Align(
          alignment: Alignment.centerLeft,
          child: Transform.translate(
            offset: const Offset(-AppSpacing.s12, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ResendButton(),
                AppButton(
                  label: l10n.forgotPassword_changeEmail,
                  variant: AppButtonVariant.text,
                  onPressed: viewModel.changeEmail,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// "Kodu Tekrar Gönder (0:24)", closed for 30 seconds after a code was sent
/// (pano 2.4 kare 2; T7.8), then "Kodu Tekrar Gönder".
///
/// While it counts it is not a live button: it is drawn in the secondary
/// color the board gives it (the kit's disabled color is too faint to read)
/// and read as a disabled button. The seconds change every second, so only
/// this widget follows them.
class _ResendButton extends StatelessWidget {
  const _ResendButton();

  @override
  Widget build(BuildContext context) {
    final viewModel = getParentViewModel<ForgotPasswordViewModel>(
      context,
      listen: false,
    );
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<int>(
      valueListenable: viewModel.resendSeconds,
      builder: (context, seconds, _) {
        if (seconds <= 0) {
          return AppButton(
            label: l10n.forgotPassword_resend,
            variant: AppButtonVariant.text,
            onPressed: viewModel.resend,
          );
        }
        final label = l10n.forgotPassword_resendIn(
          ForgotPasswordRules.formatCountdown(seconds),
        );
        return Semantics(
          button: true,
          enabled: false,
          label: label,
          excludeSemantics: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSize.touch),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: 1,
                child: Text(
                  label,
                  style: context.appText.labelLg.copyWith(
                    color: context.appColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
