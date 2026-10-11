import 'package:flutter/foundation.dart';

import 'package:smap/core/errors/app_error_code.dart';

/// The only failure type repositories return (`Either<AppException, T>`).
///
/// It never carries text meant for the user: the UI picks the message from
/// [code] (see [AppErrorCode.l10nKey]). [message] and [serverMessage] are for
/// logs and for validation texts the backend wrote itself.
@immutable
class AppException implements Exception {
  const AppException({
    required this.code,
    this.message = '',
    this.statusCode,
    this.path,
    this.serverMessage,
    this.cause,
    this.stackTrace,
  });

  /// Wraps an arbitrary thrown [error]; an [AppException] passes through.
  factory AppException.from(Object error, [StackTrace? stackTrace]) {
    if (error is AppException) return error;
    return AppException(
      code: AppErrorCode.unknown,
      message: error.toString(),
      cause: error,
      stackTrace: stackTrace,
    );
  }

  /// A decoder or parser could not read a response that arrived fine.
  factory AppException.parse(
    Object error, [
    StackTrace? stackTrace,
    String? path,
  ]) {
    return AppException(
      code: AppErrorCode.unknown,
      message: 'Response could not be decoded: $error',
      path: path,
      cause: error,
      stackTrace: stackTrace,
    );
  }

  /// What the UI should branch on.
  final AppErrorCode code;

  /// Technical description for logs; may contain an HTTP reason or a decoder
  /// error. Not for the screen.
  final String message;

  /// HTTP status of the answer, when there was one.
  final int? statusCode;

  /// Request path that failed, without query string.
  final String? path;

  /// The backend's own `message` field, when the answer had one. Only worth
  /// showing for [AppErrorCode.validation]; it is whatever the server wrote.
  final String? serverMessage;

  /// The error that was caught (a `DioException`, a `FormatException`, ...).
  final Object? cause;

  /// Where [cause] was thrown.
  final StackTrace? stackTrace;

  bool get isOffline => code == AppErrorCode.offline;
  bool get isSessionExpired => code == AppErrorCode.sessionExpired;
  bool get isCancelled => code == AppErrorCode.cancelled;

  @override
  String toString() {
    final status = statusCode == null ? '' : ' [$statusCode]';
    final where = path == null ? '' : ' $path';
    final text = message.isEmpty ? '' : ': $message';
    return 'AppException(${code.name})$status$where$text';
  }
}
