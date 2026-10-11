import 'dart:typed_data';

import 'package:dio/dio.dart';

/// HTTP verb of a [BaseRequest].
enum HttpMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  patch('PATCH'),
  delete('DELETE');

  const HttpMethod(this.verb);

  final String verb;
}

/// Which configured host a request goes to (`AppConfig`).
enum ApiHost {
  /// `AppConfig.apiBaseUrl`: the student/coach backend.
  api,

  /// `AppConfig.omrBaseUrl`: optical mark reading.
  omr,
}

/// Turns the decoded response body into [T]. The body is already JSON-decoded:
/// a `Map`, a `List`, a `String` or `null` (empty answer).
typedef ResponseDecoder<T> = T Function(Object? data);

/// One typed endpoint call, built per use and handed to
/// `NetworkService.send`. Features keep their requests in small factory
/// functions or subclasses next to their repository.
///
/// ```dart
/// BaseRequest<Profile>(
///   method: HttpMethod.get,
///   path: '/student/getProfile',
///   decoder: (data) => ProfileMapper.fromJson(data as Map<String, dynamic>),
/// );
/// ```
class BaseRequest<T> {
  const BaseRequest({
    required this.method,
    required this.path,
    required this.decoder,
    this.host = ApiHost.api,
    this.query,
    this.body,
    this.headers,
    this.contentType,
    this.requiresSession = true,
    this.successStatuses = const {},
    this.sendTimeout,
    this.receiveTimeout,
  });

  final HttpMethod method;

  /// Path starting with `/`, appended to the host's base URL.
  final String path;

  final ResponseDecoder<T> decoder;

  final ApiHost host;

  final Map<String, dynamic>? query;

  /// JSON-encodable body (`Map`/`List`), a `String`, or form fields when
  /// [contentType] is `application/x-www-form-urlencoded`.
  final Object? body;

  final Map<String, dynamic>? headers;

  /// Overrides the content type Dio picks from [body].
  final String? contentType;

  /// `true` (default) when the call needs the signed-in session: a 401, a 403
  /// or a redirect then means the session is gone (`sessionExpired`) and the
  /// session-expired stream fires. Set `false` for login, register, password
  /// reset and other public calls, where 401 simply means wrong credentials.
  final bool requiresSession;

  /// Statuses besides 2xx that this call treats as success. The backend
  /// answers a successful login or logout with a 302 redirect, so those calls
  /// list `{302}`; everything else leaves it empty and a 302 reads as "go to
  /// the login page" (session expired).
  final Set<int> successStatuses;

  /// Per-call override of the default send timeout.
  final Duration? sendTimeout;

  /// Per-call override of the default receive timeout.
  final Duration? receiveTimeout;

  /// The value passed to Dio. Called once per attempt, so one-shot bodies such
  /// as `FormData` are rebuilt every time.
  Future<Object?> resolveBody() async => body;
}

/// A file part of a [MultipartRequest]: either [path] or [bytes].
class UploadFile {
  const UploadFile.fromPath({
    required this.field,
    required String this.path,
    this.filename,
    this.contentType,
  }) : bytes = null;

  const UploadFile.fromBytes({
    required this.field,
    required Uint8List this.bytes,
    required String this.filename,
    this.contentType,
  }) : path = null;

  /// Form field name the server reads the file from.
  final String field;

  final String? path;
  final Uint8List? bytes;
  final String? filename;

  /// MIME type such as `image/jpeg`; Dio guesses from the name when `null`.
  final String? contentType;

  Future<MultipartFile> toMultipartFile() {
    final type = contentType == null ? null : DioMediaType.parse(contentType!);
    final bytes = this.bytes;
    if (bytes != null) {
      return Future.value(
        MultipartFile.fromBytes(bytes, filename: filename, contentType: type),
      );
    }
    return MultipartFile.fromFile(path!, filename: filename, contentType: type);
  }
}

/// `multipart/form-data` upload (optical mark reading, avatars). Upload
/// progress comes from `NetworkService.send(onSendProgress:)`.
class MultipartRequest<T> extends BaseRequest<T> {
  const MultipartRequest({
    required super.path,
    required super.decoder,
    required this.files,
    this.fields = const {},
    super.method = HttpMethod.post,
    super.host,
    super.query,
    super.headers,
    super.requiresSession,
    super.successStatuses,
    super.sendTimeout,
    super.receiveTimeout,
  });

  /// Plain text parts.
  final Map<String, Object> fields;

  final List<UploadFile> files;

  @override
  Future<Object?> resolveBody() async {
    final form = FormData();
    fields.forEach((key, value) => form.fields.add(MapEntry(key, '$value')));
    for (final file in files) {
      form.files.add(MapEntry(file.field, await file.toMultipartFile()));
    }
    return form;
  }
}
