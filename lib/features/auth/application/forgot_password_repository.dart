import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';

/// What the password reset flow asks of the backend (pano 2.4; spec §4.A
/// "2.4" "Veri", §6.3 #7).
///
/// **No implementation exists on purpose.** The backend has no endpoint for
/// any of the three calls yet (S7), so nothing is registered in the locator
/// and `FeatureFlags.forgotPasswordEnabled` keeps the flow closed. When the
/// endpoints arrive, write the implementation next to the other auth
/// repositories, register it in `registerAuthData` and open the flag.
///
/// Failures are [AppException]s like everywhere else; the flow reads them
/// this way:
///
/// - `AppErrorCode.validation` on `verifyCode` and `resetPassword`: the code
///   is wrong or has expired (T7.8: 10 minutes). With
///   `ForgotPasswordFailures.tooManyStatus` as the status code: too many
///   attempts, "10 dakika sonra tekrar dene";
/// - anything else (offline, timeout, server): "Gönderilemedi. Bağlantını
///   kontrol edip tekrar dene." as a toast; the user stays on the step.
abstract interface class ForgotPasswordRepository {
  /// Sends a six-digit code to [email].
  ///
  /// Answers the same for an address that has no account (T7.8: the
  /// existence of an account is never given away).
  Future<AppResult<Unit>> requestCode({required String email});

  /// Checks [code] without using it up, so the user can go back to the code
  /// step and still use it.
  Future<AppResult<Unit>> verifyCode({
    required String email,
    required String code,
  });

  /// Sets [newPassword] for the account of [email]; the server checks [code]
  /// again. The other sessions of the account end (as in `PasswordScreen`).
  Future<AppResult<ResetOutcome>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
}

/// What a finished reset hands back.
@immutable
class ResetOutcome {
  const ResetOutcome({this.userName});

  /// The account's user name, when the server tells it; the sign-in screen
  /// then has it ready ("Giriş Yap kullanıcı adını hazır getirir", pano 2.4
  /// kare 4). `null` leaves the field empty.
  final String? userName;

  @override
  bool operator ==(Object other) =>
      other is ResetOutcome && other.userName == userName;

  @override
  int get hashCode => userName.hashCode;
}

/// How the flow reads a failure of [ForgotPasswordRepository].
abstract final class ForgotPasswordFailures {
  /// HTTP 429, "Too Many Requests".
  static const int tooManyStatus = 429;

  /// Whether [failure] says the user tried too often.
  static bool isTooManyAttempts(AppException failure) =>
      failure.statusCode == tooManyStatus;
}
