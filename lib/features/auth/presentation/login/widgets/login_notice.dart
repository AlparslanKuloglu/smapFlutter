part of '../login_view.dart';

/// The red box between "Şifremi Unuttum" and the button (pano 2.3 kare 3:
/// "Kullanıcı adı ya da şifre hatalı. Tekrar dene ya da şifreni sıfırla.").
///
/// It is announced as an alert; the words come from [loginErrorText] (no raw
/// error), and it never says which field is wrong.
class _LoginErrorBox extends StatelessWidget {
  const _LoginErrorBox({required this.code, required this.forgotPasswordOpen});

  final AppErrorCode code;
  final bool forgotPasswordOpen;

  @override
  Widget build(BuildContext context) {
    return AppNoticeBox(
      tone: AppNoticeTone.error,
      message: loginErrorText(
        AppLocalizations.of(context),
        code,
        forgotPasswordOpen: forgotPasswordOpen,
      ),
    );
  }
}
