import 'dart:io';

import 'package:dio/dio.dart';

import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';

/// Statuses that mean "your session is gone" on a request that needs one.
const Set<int> kDefaultSessionExpiredStatuses = {401, 403};

/// Turns a [DioException] into an [AppException].
///
/// [requiresSession] is the request's flag (`BaseRequest.requiresSession`).
/// [deviceOnline] is the connectivity reading, `null` when unknown; it only
/// decides ambiguous connection failures, never an answered request, so a 5xx
/// is a `server` error even when the device just went offline: a backend
/// failure must not look like "no connection".
AppException mapDioException(
  DioException error, {
  bool requiresSession = true,
  bool? deviceOnline,
  Set<int> sessionExpiredStatuses = kDefaultSessionExpiredStatuses,
}) {
  final path = error.requestOptions.uri.path;
  final wrapped = error.error;
  if (wrapped is AppException) return wrapped;

  AppException make(AppErrorCode code, String message, {int? status}) =>
      AppException(
        code: code,
        message: message,
        statusCode: status,
        path: path,
        cause: error,
        stackTrace: error.stackTrace,
      );

  switch (error.type) {
    case DioExceptionType.cancel:
      return make(AppErrorCode.cancelled, 'Request cancelled');
    case DioExceptionType.connectionTimeout:
      // Connecting never finished: with no link this is "offline".
      return deviceOnline == false
          ? make(AppErrorCode.offline, 'Connect timeout while offline')
          : make(AppErrorCode.timeout, 'Connect timeout');
    case DioExceptionType.sendTimeout:
      return make(AppErrorCode.timeout, 'Send timeout');
    case DioExceptionType.receiveTimeout:
      return make(AppErrorCode.timeout, 'Receive timeout');
    case DioExceptionType.transformTimeout:
      return make(AppErrorCode.timeout, 'Response transform timeout');
    case DioExceptionType.badCertificate:
      return make(AppErrorCode.network, 'Bad certificate');
    case DioExceptionType.connectionError:
      return _connectionFailure(wrapped, deviceOnline, make);
    case DioExceptionType.badResponse:
      return mapStatus(
        error.response?.statusCode,
        path: path,
        data: error.response?.data,
        requiresSession: requiresSession,
        sessionExpiredStatuses: sessionExpiredStatuses,
        cause: error,
        stackTrace: error.stackTrace,
      );
    case DioExceptionType.unknown:
      if (wrapped is SocketException || wrapped is HandshakeException) {
        return _connectionFailure(wrapped, deviceOnline, make);
      }
      return make(AppErrorCode.unknown, '${error.message ?? wrapped}');
  }
}

/// Maps an HTTP [status] the server answered with.
AppException mapStatus(
  int? status, {
  required String path,
  Object? data,
  bool requiresSession = true,
  Set<int> sessionExpiredStatuses = kDefaultSessionExpiredStatuses,
  Object? cause,
  StackTrace? stackTrace,
}) {
  AppException make(AppErrorCode code, String message) => AppException(
    code: code,
    message: message,
    statusCode: status,
    path: path,
    serverMessage: _serverMessage(data),
    cause: cause,
    stackTrace: stackTrace,
  );

  if (status == null) return make(AppErrorCode.unknown, 'No status code');

  if (requiresSession && sessionExpiredStatuses.contains(status)) {
    return make(AppErrorCode.sessionExpired, 'HTTP $status: session rejected');
  }
  // followRedirects is off, so a 3xx reaches us. The backend redirects to the
  // login page when the cookie is gone, which for a call that needs a session
  // means "expired", never "success".
  if (status >= 300 && status < 400) {
    return requiresSession
        ? make(AppErrorCode.sessionExpired, 'HTTP $status: redirected')
        : make(AppErrorCode.unknown, 'HTTP $status: unexpected redirect');
  }
  return switch (status) {
    401 => make(AppErrorCode.unauthorized, 'HTTP 401'),
    403 => make(AppErrorCode.forbidden, 'HTTP 403'),
    404 => make(AppErrorCode.notFound, 'HTTP 404'),
    408 => make(AppErrorCode.timeout, 'HTTP 408'),
    400 || 409 || 422 => make(AppErrorCode.validation, 'HTTP $status'),
    503 => make(AppErrorCode.maintenance, 'HTTP 503'),
    >= 500 => make(AppErrorCode.server, 'HTTP $status'),
    429 => make(AppErrorCode.server, 'HTTP 429: rate limited'),
    _ => make(AppErrorCode.unknown, 'HTTP $status'),
  };
}

AppException _connectionFailure(
  Object? wrapped,
  bool? deviceOnline,
  AppException Function(AppErrorCode code, String message, {int? status}) make,
) {
  if (deviceOnline == false || _isNoRoute(wrapped)) {
    return make(AppErrorCode.offline, 'No route to the server: $wrapped');
  }
  return make(AppErrorCode.network, 'Connection failed: $wrapped');
}

/// DNS failure or "network unreachable": the device has no way out. A refused
/// or reset connection is not in this set; it is the server's side.
bool _isNoRoute(Object? error) {
  if (error is! SocketException) return false;
  final text = '${error.message} ${error.osError?.message ?? ''}'.toLowerCase();
  if (text.contains('failed host lookup') ||
      text.contains('network is unreachable') ||
      text.contains('no address associated') ||
      text.contains('nodename nor servname')) {
    return true;
  }
  // ENETDOWN, ENETUNREACH, EHOSTUNREACH on Linux/Android and Darwin.
  const noRouteErrnos = {100, 101, 113, 50, 51, 65};
  return noRouteErrnos.contains(error.osError?.errorCode);
}

String? _serverMessage(Object? data) {
  if (data is! Map) return null;
  final message = data['message'];
  if (message is! String) return null;
  final trimmed = message.trim();
  if (trimmed.isEmpty || trimmed.length > 300) return null;
  return trimmed;
}
