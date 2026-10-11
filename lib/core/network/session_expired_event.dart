import 'package:flutter/foundation.dart';

/// Emitted by `NetworkService.onSessionExpired` when a request that needs the
/// signed-in session found it gone.
@immutable
class SessionExpiredEvent {
  const SessionExpiredEvent({required this.path, this.statusCode});

  /// Path of the request that noticed.
  final String path;

  /// 401, 403 or a 3xx redirect status.
  final int? statusCode;

  @override
  String toString() => 'SessionExpiredEvent($path, $statusCode)';
}
