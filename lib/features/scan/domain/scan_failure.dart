import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';

/// Why a step of the scan failed, in the terms the screens speak (pano 4.5
/// kare 4, 4.8 kare 2, 4.10).
///
/// The screens pick their sentence from the kind; an inner code, a status or
/// the raw exception never reaches the user.
enum ScanFailureKind {
  /// The connection broke, was refused, or the device has no route:
  /// "Bağlantı koptu. Fotoğrafın duruyor; …".
  connection,

  /// A deadline passed: "Sunucu yanıt vermedi.".
  timeout,

  /// The server failed or answered something that cannot be read.
  server,

  /// The reading service is in maintenance (503): "Optik okuma şu an kapalı".
  maintenance,

  /// The caller stopped the step ("Vazgeç"); nothing is shown.
  cancelled,
}

/// A failed step: its [kind] and the exception behind it, for logs.
class ScanFailure implements Exception {
  const ScanFailure(this.kind, [this.cause]);

  /// Sorts an [AppException] of the network layer into a [ScanFailureKind].
  factory ScanFailure.of(AppException exception) =>
      ScanFailure(switch (exception.code) {
        AppErrorCode.network ||
        AppErrorCode.offline => ScanFailureKind.connection,
        AppErrorCode.timeout => ScanFailureKind.timeout,
        AppErrorCode.maintenance => ScanFailureKind.maintenance,
        AppErrorCode.cancelled => ScanFailureKind.cancelled,
        AppErrorCode.unauthorized ||
        AppErrorCode.sessionExpired ||
        AppErrorCode.forbidden ||
        AppErrorCode.notFound ||
        AppErrorCode.validation ||
        AppErrorCode.server ||
        AppErrorCode.unknown => ScanFailureKind.server,
      }, exception);

  final ScanFailureKind kind;
  final AppException? cause;

  /// Whether the device had no connection (the answer check says "Bağlantı
  /// yok." instead of the general line).
  bool get isOffline => cause?.isOffline ?? false;

  @override
  String toString() => 'ScanFailure(${kind.name})';
}
