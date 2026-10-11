import 'package:stacked/stacked.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/features/auth/application/login_input.dart';
import 'package:smap/services/session_manager.dart';

/// The sign-in screen's logic (pano 2.3 kare 1 to 4; spec §4.A "2.3").
///
/// It signs in through the [SessionManager] and nothing else: the role comes
/// from the account, and the router's guards open the right shell, or close
/// this screen when it was opened over the screens of an expired session
/// (`SessionExpiredCoordinator`). So a successful sign-in changes no route
/// here, and [isSubmitting] stays on until the screen is gone (a second tap
/// in that moment would only meet "already signed in").
///
/// A failure is an [AppErrorCode]; the words are the view's (a ViewModel has
/// no `BuildContext`): wrong credentials read "Kullanıcı adı ya da şifre
/// hatalı", never which field.
class LoginViewModel extends BaseViewModel {
  LoginViewModel({
    required SessionManager session,
    required AppRouter router,
    this.forgotPasswordEnabled = false,
    this.socialLoginEnabled = false,
  }) : _session = session,
       _router = router;

  final SessionManager _session;
  final AppRouter _router;

  /// "Şifremi Unuttum" is drawn and works (`FeatureFlags.forgotPasswordEnabled`).
  final bool forgotPasswordEnabled;

  /// The Apple and Google variant is drawn (`FeatureFlags.socialLoginEnabled`).
  final bool socialLoginEnabled;

  bool _isSubmitting = false;
  AppErrorCode? _failure;
  int _failureCount = 0;
  String? _prefillUsername;
  int _prefillCount = 0;

  /// The sign-in is running: the button spins and the fields are locked.
  bool get isSubmitting => _isSubmitting;

  /// Why the last attempt failed; `null` before one and while one runs.
  AppErrorCode? get failure => _failure;

  /// Counts the failures, so the view reacts to two equal ones in a row (the
  /// password is cleared and focused each time, pano 2.3 kare 3).
  int get failureCount => _failureCount;

  /// A user name the view puts in the field (the one a finished password
  /// reset brings back); read it when [prefillCount] changes.
  String? get prefillUsername => _prefillUsername;

  /// Counts the prefills.
  int get prefillCount => _prefillCount;

  /// Signs in with what the form holds.
  ///
  /// The user name is normalized ([LoginInput.normalizeUsername]), the
  /// password goes as typed. An empty field is not sent: it fails like a wrong
  /// pair, which is also what the server would answer.
  Future<void> submit({
    required String username,
    required String password,
  }) async {
    if (_isSubmitting) return;
    final name = LoginInput.normalizeUsername(username);
    if (!LoginInput.isComplete(username: name, password: password)) {
      _fail(AppErrorCode.unauthorized);
      return;
    }
    _isSubmitting = true;
    _failure = null;
    notifyListeners();

    final result = await _session.signIn(username: name, password: password);
    final error = result.leftOrNull;
    if (error == null) return;
    _isSubmitting = false;
    _fail(error.code);
  }

  /// Puts [username] in the user name field (see [prefillUsername]).
  void prefill(String username) {
    if (username.isEmpty) return;
    _prefillUsername = username;
    _prefillCount++;
    notifyListeners();
  }

  /// "Şifremi Unuttum": opens the reset flow; what it brings back (the user
  /// name of the account) is prefilled.
  Future<void> openForgotPassword() async {
    if (!forgotPasswordEnabled || _isSubmitting) return;
    final username = await _router.push<String?>(const ForgotPasswordRoute());
    if (username != null) prefill(username);
  }

  /// "Kayıt Ol": the sign-up screen.
  Future<void> openRegister() async {
    if (_isSubmitting) return;
    await _router.push(const RegisterRoute());
  }

  /// Whether [code] means the pair did not match (the password is then
  /// cleared); a connection failure keeps what was typed.
  static bool isCredentialFailure(AppErrorCode code) =>
      code == AppErrorCode.unauthorized ||
      code == AppErrorCode.validation ||
      code == AppErrorCode.notFound;

  void _fail(AppErrorCode code) {
    _failure = code;
    _failureCount++;
    AppHaptics.error();
    notifyListeners();
  }
}
