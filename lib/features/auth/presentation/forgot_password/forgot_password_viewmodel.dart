import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/features/auth/application/forgot_password_logic.dart';
import 'package:smap/features/auth/application/forgot_password_repository.dart';
import 'package:smap/shared/ui/inputs/code_input_logic.dart';

/// Why the code boxes are red (pano 2.4 "Hata metinleri").
enum CodeIssue {
  /// "Kod hatalı ya da süresi dolmuş. Yeni kod iste."
  wrongOrExpired,

  /// "Çok fazla deneme yaptın. 10 dakika sonra tekrar dene."
  tooManyAttempts,
}

/// What is wrong with the new password (pano 2.4 kare 3).
enum PasswordIssue {
  /// Under eight characters: the rule line under the first field turns red.
  tooShort,

  /// "Şifreler aynı değil." under the repeat field.
  mismatch,
}

/// The password reset flow's logic (pano 2.4 kare 1 to 4; spec §4.A "2.4").
///
/// One ViewModel for the four steps, `email -> code -> newPassword -> done`.
/// It talks to a [ForgotPasswordRepository] (no implementation exists yet; the
/// flow is closed by `FeatureFlags.forgotPasswordEnabled` until the backend
/// has the endpoints). What it decides:
///
/// - **E-mail:** an address that does not look like one is refused on the
///   spot; otherwise the code is requested. Whatever the server says about the
///   account is the same answer, so nothing here tells whether it exists.
/// - **Code:** the sixth digit verifies at once. A wrong or expired code, or
///   too many tries, is shown under the boxes (they shake, the screen plays
///   the error haptic); a failed connection is a toast and the boxes empty so
///   the code can be typed again. "Kodu Tekrar Gönder" opens after 30
///   seconds ([resendSeconds] counts down) and starts the wait again.
/// - **New password:** eight characters or more, typed twice. The server
///   checks the code once more; if it no longer accepts it the flow goes back
///   to the code step.
/// - **Done:** `success` haptic. [finish] closes the flow with the user name
///   the server gave, so the sign-in screen has it ready.
///
/// Back goes one step back (a step further than the code step asks for a new
/// code), and leaves the flow from the first step.
class ForgotPasswordViewModel extends BaseViewModel {
  ForgotPasswordViewModel({
    required ForgotPasswordRepository repository,
    required AppRouter router,
    required ToastService toast,
  }) : _repository = repository,
       _router = router,
       _toast = toast;

  final ForgotPasswordRepository _repository;
  final AppRouter _router;
  final ToastService _toast;

  final ValueNotifier<int> _resendSeconds = ValueNotifier<int>(0);
  Timer? _countdown;

  ForgotPasswordStep _step = ForgotPasswordStep.email;
  bool _forward = true;
  String _email = '';
  String _code = '';
  String? _userName;

  bool _sending = false;
  bool _verifying = false;
  bool _updating = false;
  bool _emailInvalid = false;
  CodeIssue? _codeIssue;
  int _codeShake = 0;
  int _codeClears = 0;
  PasswordIssue? _passwordIssue;

  /// The step on screen.
  ForgotPasswordStep get step => _step;

  /// The last move went to a later step (the slide goes left to right).
  bool get movingForward => _forward;

  /// The address a code was sent to; what the e-mail field starts with when
  /// the user comes back to change it.
  String get email => _email;

  /// The account's user name once the password is reset, if the server told.
  String? get userName => _userName;

  /// A code is being requested (first send or resend).
  bool get isSending => _sending;

  /// The code is being checked.
  bool get isVerifying => _verifying;

  /// The new password is being saved.
  bool get isUpdating => _updating;

  /// The e-mail field holds something that does not look like an address.
  bool get emailInvalid => _emailInvalid;

  /// Why the code boxes are red, if they are.
  CodeIssue? get codeIssue => _codeIssue;

  /// Counts the wrong codes, so the boxes shake again for the same issue.
  int get codeShake => _codeShake;

  /// Counts the times the boxes must be emptied.
  int get codeClears => _codeClears;

  /// What is wrong with the new password, if anything.
  PasswordIssue? get passwordIssue => _passwordIssue;

  /// Seconds until "Kodu Tekrar Gönder" opens; 0 when it is open. Changes
  /// every second, so it is a `ValueListenable` and not part of the state.
  ValueListenable<int> get resendSeconds => _resendSeconds;

  // ---------------------------------------------------------------- e-mail

  /// "Kod Gönder": checks [raw] and asks for the code.
  Future<void> submitEmail(String raw) async {
    if (_sending) return;
    final email = raw.trim();
    if (!ForgotPasswordRules.isEmail(email)) {
      _emailInvalid = true;
      notifyListeners();
      return;
    }
    _emailInvalid = false;
    _sending = true;
    notifyListeners();
    final result = await _repository.requestCode(email: email);
    _sending = false;
    if (result.leftOrNull != null) {
      _toastSendFailed();
      notifyListeners();
      return;
    }
    _email = email;
    _codeIssue = null;
    _codeClears++;
    _startCountdown();
    _goTo(ForgotPasswordStep.code);
  }

  /// The e-mail field changed: the format error goes away.
  void emailEdited() {
    if (!_emailInvalid) return;
    _emailInvalid = false;
    notifyListeners();
  }

  // ------------------------------------------------------------------ code

  /// The sixth digit was typed (or a whole code pasted): checks it.
  Future<void> submitCode(String code) async {
    if (_verifying || !CodeInputLogic.isComplete(code)) return;
    _verifying = true;
    _codeIssue = null;
    notifyListeners();
    final result = await _repository.verifyCode(email: _email, code: code);
    _verifying = false;
    final failure = result.leftOrNull;
    if (failure == null) {
      _code = code;
      _stopCountdown();
      _goTo(ForgotPasswordStep.newPassword);
      return;
    }
    if (failure.code == AppErrorCode.validation) {
      _showCodeIssue(failure);
    } else {
      _toastSendFailed();
      _codeClears++;
    }
    notifyListeners();
  }

  /// The boxes changed: the red goes away.
  void codeEdited() {
    if (_codeIssue == null) return;
    _codeIssue = null;
    notifyListeners();
  }

  /// "Kodu Tekrar Gönder": a new code, and the wait starts again.
  Future<void> resend() async {
    if (_sending || _resendSeconds.value > 0 || _email.isEmpty) return;
    _sending = true;
    notifyListeners();
    final result = await _repository.requestCode(email: _email);
    _sending = false;
    if (result.leftOrNull != null) {
      _toastSendFailed();
      notifyListeners();
      return;
    }
    _codeIssue = null;
    _codeClears++;
    _startCountdown();
    notifyListeners();
  }

  /// "E-postayı Değiştir".
  void changeEmail() {
    if (_step != ForgotPasswordStep.code) return;
    back();
  }

  // -------------------------------------------------------------- password

  /// "Şifreyi Güncelle": checks the two fields and saves the new password.
  Future<void> submitPassword(String password, String repeat) async {
    if (_updating) return;
    final issue = !ForgotPasswordRules.isLongEnough(password)
        ? PasswordIssue.tooShort
        : !ForgotPasswordRules.matches(password, repeat)
        ? PasswordIssue.mismatch
        : null;
    if (issue != null) {
      _passwordIssue = issue;
      notifyListeners();
      return;
    }
    _passwordIssue = null;
    _updating = true;
    notifyListeners();
    final result = await _repository.resetPassword(
      email: _email,
      code: _code,
      newPassword: password,
    );
    _updating = false;
    final failure = result.leftOrNull;
    if (failure == null) {
      _userName = result.rightOrNull?.userName;
      AppHaptics.success();
      _goTo(ForgotPasswordStep.done);
      return;
    }
    if (failure.code == AppErrorCode.validation) {
      // The server no longer accepts the code: back to the boxes.
      _showCodeIssue(failure);
      _codeClears++;
      _goTo(ForgotPasswordStep.code);
      return;
    }
    _toastSendFailed();
    notifyListeners();
  }

  /// One of the password fields changed: the red goes away.
  void passwordEdited() {
    if (_passwordIssue == null) return;
    _passwordIssue = null;
    notifyListeners();
  }

  // ------------------------------------------------------------ navigation

  /// The back button and the system back: one step back, or out of the flow
  /// from the first step. From the code step the user asks for a new code
  /// by sending again; from the new password step the boxes come back empty.
  void back() {
    final previous = _step.previous;
    if (previous == null) {
      if (_step == ForgotPasswordStep.email) unawaited(_router.maybePop());
      return;
    }
    if (_step == ForgotPasswordStep.newPassword) {
      _codeIssue = null;
      _codeClears++;
      _resendSeconds.value = 0;
    }
    _stopCountdown();
    _passwordIssue = null;
    _goTo(previous, forward: false);
  }

  /// "Giriş Yap" on the last screen: closes the flow and hands the user name
  /// to the sign-in screen. Without a screen under it (a link into the flow)
  /// it opens the sign-in instead.
  Future<void> finish() async {
    final name = _userName;
    if (_router.canPop()) {
      // `pop`, not `maybePop`: the last screen is blocking (`PopScope`), and
      // `maybePop` would ask that and be told no.
      _router.pop<String?>(name);
    } else {
      await _router.replaceAll([const LoginRoute()]);
    }
  }

  // -------------------------------------------------------------- internals

  void _goTo(ForgotPasswordStep step, {bool forward = true}) {
    _step = step;
    _forward = forward;
    notifyListeners();
  }

  void _showCodeIssue(AppException failure) {
    _codeIssue = ForgotPasswordFailures.isTooManyAttempts(failure)
        ? CodeIssue.tooManyAttempts
        : CodeIssue.wrongOrExpired;
    _codeShake++;
  }

  void _toastSendFailed() =>
      _toast.error((l10n) => l10n.forgotPassword_errSendFailed);

  void _startCountdown() {
    _countdown?.cancel();
    _resendSeconds.value = ForgotPasswordRules.resendDelay.inSeconds;
    _countdown = Timer.periodic(ForgotPasswordRules.tick, (timer) {
      final next = _resendSeconds.value - 1;
      _resendSeconds.value = next < 0 ? 0 : next;
      if (next <= 0) timer.cancel();
    });
  }

  void _stopCountdown() {
    _countdown?.cancel();
    _countdown = null;
  }

  @override
  void dispose() {
    _stopCountdown();
    _resendSeconds.dispose();
    super.dispose();
  }
}
