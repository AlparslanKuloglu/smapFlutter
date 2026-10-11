import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A scripted [HttpClientAdapter]: [handler] answers every request, or throws
/// the transport failure to simulate.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  final FutureOr<ResponseBody> Function(RequestOptions options) handler;
  final List<RequestOptions> requests = [];

  RequestOptions get last => requests.last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}

  /// Answers every request with [status] and a JSON [body].
  static FakeAdapter json(
    Object? body, {
    int status = 200,
    Map<String, List<String>> headers = const {},
  }) =>
      FakeAdapter((_) => jsonResponse(body, status: status, headers: headers));

  /// Answers every request with a failure thrown by the transport.
  static FakeAdapter failing(
    DioException Function(RequestOptions options) error,
  ) => FakeAdapter((options) => throw error(options));
}

ResponseBody jsonResponse(
  Object? body, {
  int status = 200,
  Map<String, List<String>> headers = const {},
}) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
    ...headers,
  },
);

ResponseBody textResponse(
  String body, {
  int status = 200,
  String contentType = 'text/html',
  Map<String, List<String>> headers = const {},
}) => ResponseBody.fromString(
  body,
  status,
  headers: {
    Headers.contentTypeHeader: [contentType],
    ...headers,
  },
);
