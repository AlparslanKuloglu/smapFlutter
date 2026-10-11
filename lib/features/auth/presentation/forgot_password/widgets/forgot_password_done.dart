part of '../forgot_password_view.dart';

/// "Şifren güncellendi" (pano 2.4 kare 4): the green circle with the check,
/// "Yeni şifrenle giriş yapabilirsin." and the primary "Giriş Yap".
///
/// One icon, one sentence, one action, in the success color; no back button,
/// and the system back does nothing. "Giriş Yap" closes the flow and the
/// sign-in screen shows the user name the server gave (kare 4: "kullanıcı
/// adını hazır getirir"). The `success` haptic was played when the password
/// was saved.
class _DoneStep extends StatelessWidget {
  const _DoneStep();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ForgotPasswordViewModel>(
      context,
      listen: false,
    );
    return AppSystemOverlayRegion(
      kind: AppSystemOverlayKind.bar,
      child: AppStatusView(
        title: l10n.forgotPassword_doneTitle,
        message: l10n.forgotPassword_doneBody,
        icon: PhosphorIconsRegular.checkCircle,
        tone: AppStatusTone.success,
        blocking: true,
        primary: AppStatusAction(
          label: l10n.forgotPassword_doneAction,
          onPressed: viewModel.finish,
        ),
      ),
    );
  }
}
