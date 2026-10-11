import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';

/// The `{success, message, ...}` frame the legacy Node backend wraps its JSON
/// answers in, read without trusting any of it.
///
/// A request decoder gets the decoded body (`Object?`) and builds the response
/// object from `LegacyEnvelope.read(body)`. The repository then decides what
/// the frame means: a `success: true` answer is a value, `success: false` is a
/// business rejection ([rejection]) and a body that is not an object, or has
/// no `success` at all, is an unusable answer ([unusable]).
///
/// New file in `core/domain` (the only core folder the data tasks may add to);
/// the coordinator can move it next to `NetworkService` when convenient.
final class LegacyEnvelope {
  const LegacyEnvelope._(this.body);

  /// Reads a decoded body. Anything that is not a JSON object (an empty
  /// answer, the HTML of a login page, a bare list) is an empty envelope.
  factory LegacyEnvelope.read(Object? data) {
    if (data is! Map) return const LegacyEnvelope._(<String, dynamic>{});
    return LegacyEnvelope._(Map<String, dynamic>.from(data));
  }

  /// The body as a map; empty when the answer was not an object.
  final Map<String, dynamic> body;

  /// `true` when the answer was an object with at least one key.
  bool get hasBody => body.isNotEmpty;

  /// The backend's own flag: `true`/`false`, also from `"true"` and `1`/`0`;
  /// `null` when absent or unreadable.
  bool? get success {
    final value = body['success'];
    if (value is bool) return value;
    if (value is num && (value == 0 || value == 1)) return value == 1;
    if (value is String) {
      switch (value.trim().toLowerCase()) {
        case 'true' || '1':
          return true;
        case 'false' || '0':
          return false;
      }
    }
    return null;
  }

  /// `success: true`.
  bool get isSuccess => success == true;

  /// `success: false`: the server understood the call and said no.
  bool get isRejected => success == false;

  /// The server's own text: `message`, else `msg` (the account endpoints use
  /// both spellings). Blank text and anything over 300 characters is `null`.
  String? get message {
    for (final key in const ['message', 'msg']) {
      final value = body[key];
      if (value is! String) continue;
      final text = value.trim();
      if (text.isNotEmpty && text.length <= 300) return text;
    }
    return null;
  }

  /// `body[key]`.
  Object? operator [](String key) => body[key];

  /// `body[key]` when it is an object.
  Map<String, dynamic>? object(String key) {
    final value = body[key];
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  /// `body[key]` as a list of objects; `null` when the key is missing or not a
  /// list. Entries that are not objects are dropped.
  List<Map<String, dynamic>>? objects(String key) {
    final value = body[key];
    if (value is! List) return null;
    return [
      for (final item in value)
        if (item is Map) Map<String, dynamic>.from(item),
    ];
  }

  /// Decodes every object under [key] with [decode]. An entry that fails to
  /// decode is skipped, so one bad row never hides the rest. `null` when the
  /// key is missing or not a list.
  List<T>? readList<T>(
    String key,
    T Function(Map<String, dynamic> json) decode,
  ) {
    final items = objects(key);
    if (items == null) return null;
    final result = <T>[];
    for (final item in items) {
      try {
        result.add(decode(item));
      } on Object {
        continue;
      }
    }
    return result;
  }

  /// The failure for `success: false` (or any answer the call counts as
  /// refused): [AppErrorCode.validation] carrying the server's [message].
  AppException rejection(String path) => AppException(
    code: AppErrorCode.validation,
    message: 'Server refused the request',
    path: path,
    serverMessage: message,
  );

  /// The failure for an answer that arrived fine but cannot be used: an empty
  /// body, a page instead of JSON, a frame without the expected data.
  AppException unusable(String path, [String detail = '']) => AppException(
    code: AppErrorCode.server,
    message: detail.isEmpty
        ? 'Answer could not be used'
        : 'Answer could not be used: $detail',
    path: path,
    serverMessage: message,
  );
}
