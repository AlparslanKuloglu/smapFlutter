import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// App-wide logger on top of the `logger` package.
///
/// It prints only in debug builds. In release (and profile) builds every call
/// is a no-op that does not even build the message, so nothing a request or an
/// error carried can reach the device log. Pass sensitive payloads through
/// `LogMasker` before logging them.
///
/// Features inject it from the locator; they never call `print`/`debugPrint`.
final class AppLogger {
  /// [enabled] defaults to `kDebugMode`.
  AppLogger({bool? enabled, Logger? logger})
    : _enabled = enabled ?? kDebugMode,
      _logger = logger;

  /// A logger that never prints (tests, release fallbacks).
  AppLogger.silent() : _enabled = false, _logger = null;

  final bool _enabled;
  Logger? _logger;

  bool get isEnabled => _enabled;

  Logger get _sink => _logger ??= Logger(
    filter: ProductionFilter(),
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 6,
      lineLength: 100,
      colors: false,
      printEmojis: false,
      noBoxingByDefault: true,
    ),
  );

  void debug(
    Object? message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) => _log(Level.debug, message, name, error, stackTrace);

  void info(
    Object? message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) => _log(Level.info, message, name, error, stackTrace);

  void warning(
    Object? message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) => _log(Level.warning, message, name, error, stackTrace);

  void error(
    Object? message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) => _log(Level.error, message, name, error, stackTrace);

  void _log(
    Level level,
    Object? message,
    String? name,
    Object? error,
    StackTrace? stackTrace,
  ) {
    if (!_enabled) return;
    final text = name == null ? '$message' : '[$name] $message';
    _sink.log(level, text, error: error, stackTrace: stackTrace);
  }
}
