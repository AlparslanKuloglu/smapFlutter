import 'package:dio/dio.dart';

/// Hides credentials and shortens big payloads before anything is logged.
///
/// Keys are compared case-insensitively with `_`, `-` and `.` removed, so
/// `Set-Cookie`, `set_cookie` and `setCookie` are the same key.
final class LogMasker {
  const LogMasker({
    this.sensitiveKeys = defaultSensitiveKeys,
    this.maxStringLength = 120,
    this.maxListLength = 10,
  });

  /// Normalised names of fields whose value is never logged.
  static const Set<String> defaultSensitiveKeys = {
    'authorization',
    'cookie',
    'setcookie',
    'connectsid',
    'session',
    'password',
    'passwordconfirm',
    'newpassword',
    'oldpassword',
    'currentpassword',
    'token',
    'accesstoken',
    'refreshtoken',
    'idtoken',
    'secret',
    'code',
    'otp',
    'userdata',
  };

  static const String mask = '***';

  final Set<String> sensitiveKeys;
  final int maxStringLength;
  final int maxListLength;

  bool isSensitive(String key) =>
      sensitiveKeys.contains(key.toLowerCase().replaceAll(RegExp('[-_.]'), ''));

  /// Request or response headers with sensitive ones replaced.
  Map<String, Object?> maskHeaders(Map<String, dynamic> headers) => {
    for (final entry in headers.entries)
      entry.key: isSensitive(entry.key) ? mask : _short(entry.value),
  };

  /// [uri] with sensitive query parameters replaced.
  Uri maskUri(Uri uri) {
    if (uri.queryParameters.isEmpty) return uri;
    return uri.replace(
      queryParameters: {
        for (final entry in uri.queryParameters.entries)
          entry.key: isSensitive(entry.key) ? mask : entry.value,
      },
    );
  }

  /// A copy of [value] that is safe to print: sensitive map entries replaced,
  /// long strings and lists cut, files and form data described by name only.
  Object? maskBody(Object? value) {
    if (value == null || value is num || value is bool) return value;
    if (value is String) return _cutString(value);
    if (value is Map) {
      return {
        for (final entry in value.entries)
          '${entry.key}': isSensitive('${entry.key}')
              ? mask
              : maskBody(entry.value),
      };
    }
    if (value is Iterable) {
      final items = value.toList();
      return [
        ...items.take(maxListLength).map(maskBody),
        if (items.length > maxListLength)
          '...(${items.length - maxListLength} more)',
      ];
    }
    if (value is FormData) {
      return {
        'fields': maskBody({for (final f in value.fields) f.key: f.value}),
        'files': value.files.map((f) => f.key).toList(),
      };
    }
    return '<${value.runtimeType}>';
  }

  Object? _short(Object? value) => value is String ? _cutString(value) : value;

  String _cutString(String text) => text.length <= maxStringLength
      ? text
      : '${text.substring(0, maxStringLength)}...(${text.length} chars)';
}
