import 'package:dartz/dartz.dart';

import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';

/// What every student endpoint of the legacy backend wraps its answer in:
/// `{ "success": true, ...payload }` or `{ "success": false, "message": "…" }`.
///
/// Shared by the exams, analytics, lessons and cards data layers (a 200 with
/// `success: false` is a failure, exactly like the legacy `_makeRequest`).
/// The coordinator may move this file to `lib/core` later.
abstract interface class ApiEnvelope {
  /// The backend's own flag; `null` when the answer had none (an empty or
  /// foreign body).
  bool? get success;

  /// The backend's message, when it sent one.
  String? get message;
}

/// Success gate for decoded answers.
extension RequireSuccess<T extends ApiEnvelope> on AppResult<T> {
  /// Keeps the value only when the backend said `success: true` (the legacy
  /// rule). An explicit `success: false` is [AppErrorCode.validation] with the
  /// backend's text as `serverMessage`; an answer without any flag (empty
  /// body, HTML page) is [AppErrorCode.server].
  AppResult<T> requireSuccess(String path) =>
      fold<AppResult<T>>(Left.new, (response) {
        if (response.success == true) return Right(response);
        if (response.success == false) {
          return Left(
            AppException(
              code: AppErrorCode.validation,
              message: 'The server answered success: false',
              path: path,
              serverMessage: response.message,
            ),
          );
        }
        return Left(
          AppException(
            code: AppErrorCode.server,
            message: 'The answer carried no success flag',
            path: path,
            serverMessage: response.message,
          ),
        );
      });
}

/// The decoded body as a string-keyed map, or `null` when it is not a JSON
/// object (an empty answer, a text or HTML page).
Map<String, dynamic>? bodyMap(Object? data) =>
    data is Map ? Map<String, dynamic>.from(data) : null;

/// A query map without `null` and blank values, so absent filters never reach
/// the URL. A `studentId` is added when a coach reads a student's data (the
/// legacy repositories append it to every call).
Map<String, dynamic>? compactQuery(
  Map<String, Object?> params, {
  String? studentId,
}) {
  final out = <String, dynamic>{};
  params.forEach((key, value) {
    if (value == null) return;
    if (value is String && value.trim().isEmpty) return;
    out[key] = value;
  });
  final student = studentId?.trim();
  if (student != null && student.isNotEmpty) out['studentId'] = student;
  return out.isEmpty ? null : out;
}
