import 'package:dartz/dartz.dart';

import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';

/// What "Şifre" asks of the backend (pano 9.3; spec §4.C "9.3" "Veri", §6.3
/// #8).
///
/// **No implementation exists on purpose.** The backend has no endpoint that
/// changes the password (S7; the legacy screen only showed a success
/// message), so nothing is registered in the locator and
/// `FeatureFlags.passwordChangeEnabled` keeps the screen closed. When the
/// endpoint arrives, write the implementation next to `AccountRepository`,
/// register it in `registerAccountData` and open the flag.
///
/// The contract the screen relies on:
///
/// - the server checks [currentPassword]; a wrong one is an
///   `AppErrorCode.validation` failure ([PasswordFailures.isWrongCurrent]);
/// - on success this device's session stays open and the account's other
///   sessions end (pano 9.3 "Davranış");
/// - anything else (offline, timeout, server) is a toast and the form keeps
///   what was typed.
abstract interface class PasswordRepository {
  /// Replaces [currentPassword] with [newPassword] for the signed-in account.
  Future<AppResult<Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

/// How the screen reads a failure of [PasswordRepository].
abstract final class PasswordFailures {
  /// Whether [failure] says the current password was not right.
  static bool isWrongCurrent(AppException failure) =>
      failure.code == AppErrorCode.validation;
}
