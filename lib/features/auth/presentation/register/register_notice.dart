import 'package:flutter/foundation.dart';

import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';

/// Why the notice above "Kayıt Ol" is showing (pano 2.6 "Gönderim hataları").
/// The screen picks the Turkish sentence; no server code ever reaches it.
@immutable
class RegisterNotice {
  const RegisterNotice._(this.kind, this.code, this.serverMessage);

  /// The register call failed.
  factory RegisterNotice.failed(AppException failure) => RegisterNotice._(
    RegisterNoticeKind.failed,
    failure.code,
    failure.serverMessage,
  );

  /// The account was created but the sign-in that follows it failed.
  const RegisterNotice.signInFailed()
    : this._(RegisterNoticeKind.signInFailed, null, null);

  final RegisterNoticeKind kind;

  /// What went wrong, for [RegisterNoticeKind.failed].
  final AppErrorCode? code;

  /// The backend's own text of a refusal (`AppErrorCode.validation`).
  final String? serverMessage;

  @override
  bool operator ==(Object other) =>
      other is RegisterNotice &&
      other.kind == kind &&
      other.code == code &&
      other.serverMessage == serverMessage;

  @override
  int get hashCode => Object.hash(kind, code, serverMessage);
}

enum RegisterNoticeKind { failed, signInFailed }
