import 'dart:async';
import 'dart:convert';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/network/base_request.dart';
import 'package:smap/core/network/dio_error_mapper.dart';
import 'package:smap/core/network/masking_log_interceptor.dart';
import 'package:smap/core/network/session_expired_event.dart';
import 'package:smap/core/services/app_logger.dart';
import 'package:smap/core/services/connectivity_service.dart';

/// Deadlines of the shared Dio (spec §6.3 #2).
abstract final class NetworkTimeouts {
  static const Duration connect = Duration(seconds: 15);
  static const Duration receive = Duration(seconds: 30);

  /// Default send timeout of small JSON bodies.
  static const Duration send = Duration(seconds: 30);

  /// Send timeout of [MultipartRequest]s (photo upload).
  static const Duration upload = Duration(seconds: 60);
}

/// The app's single HTTP client.
///
/// - One [Dio], cookie session: the backend identifies the user by the
///   `connect.sid` cookie, which [cookieJar] persists across launches.
/// - Only 2xx is success. Redirects are not followed (`followRedirects:
///   false`) and a 3xx is a failure, because the backend answers a missing
///   session with a redirect to the login page; calls that really succeed
///   with a redirect (login, logout) list it in `BaseRequest.successStatuses`.
/// - Every call returns `Either<AppException, T>`; nothing throws.
/// - When a call that needs the session finds it gone (401, 403 or a
///   redirect), [onSessionExpired] fires once, until [markSessionStarted].
final class NetworkService {
  NetworkService({
    required AppConfig config,
    required CookieJar cookieJar,
    AppLogger? logger,
    ConnectivityService? connectivity,
    bool? logTraffic,
    Set<int> sessionExpiredStatuses = kDefaultSessionExpiredStatuses,
    HttpClientAdapter? httpClientAdapter,
  }) : _config = config,
       _cookieJar = cookieJar,
       _connectivity = connectivity,
       _sessionExpiredStatuses = sessionExpiredStatuses,
       _dio = Dio(
         BaseOptions(
           baseUrl: config.apiBaseUrl,
           connectTimeout: NetworkTimeouts.connect,
           receiveTimeout: NetworkTimeouts.receive,
           sendTimeout: NetworkTimeouts.send,
           followRedirects: false,
           validateStatus: _isSuccess,
         ),
       ) {
    final log = logger ?? AppLogger.silent();
    if (httpClientAdapter != null) _dio.httpClientAdapter = httpClientAdapter;
    _dio.interceptors.add(CookieManager(_cookieJar));
    if (logTraffic ?? kDebugMode) {
      _dio.interceptors.add(MaskingLogInterceptor(log));
    }
  }

  /// Cookie jar at the location and format the legacy `DioClient` uses
  /// (`<documents>/.cookies/`, expired cookies dropped), so a signed-in user
  /// stays signed in when screens move to this service.
  static Future<CookieJar> createPersistentCookieJar() async {
    final documents = await getApplicationDocumentsDirectory();
    return PersistCookieJar(
      storage: FileStorage('${documents.path}/.cookies/'),
    );
  }

  final AppConfig _config;
  final CookieJar _cookieJar;
  final ConnectivityService? _connectivity;
  final Set<int> _sessionExpiredStatuses;
  final Dio _dio;
  final StreamController<SessionExpiredEvent> _sessionExpired =
      StreamController<SessionExpiredEvent>.broadcast(sync: true);

  bool _sessionExpiryReported = false;

  /// The session cookie store. Clear it on sign-out.
  CookieJar get cookieJar => _cookieJar;

  /// The underlying client, for the rare caller that needs a raw download
  /// (image cache, file save). Typed calls go through [send].
  Dio get dio => _dio;

  /// Fires when a call that needs the session found it gone. Emits once per
  /// signed-in session: concurrent calls that all fail with 401 produce a
  /// single event, and the stream stays quiet until [markSessionStarted].
  Stream<SessionExpiredEvent> get onSessionExpired => _sessionExpired.stream;

  /// Re-arms [onSessionExpired]. Call it when a session starts (successful
  /// login or restore); `pushSessionScope` does.
  void markSessionStarted() => _sessionExpiryReported = false;

  /// Sends [request] and decodes the answer.
  ///
  /// [onSendProgress] reports upload progress of multipart bodies.
  Future<AppResult<T>> send<T>(
    BaseRequest<T> request, {
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final body = await request.resolveBody();
      final response = await _dio.request<Object?>(
        _urlFor(request),
        data: body,
        queryParameters: request.query,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        options: Options(
          method: request.method.verb,
          headers: request.headers,
          contentType: request.contentType,
          sendTimeout:
              request.sendTimeout ??
              (request is MultipartRequest ? NetworkTimeouts.upload : null),
          receiveTimeout: request.receiveTimeout,
          validateStatus: (status) =>
              _isSuccess(status) ||
              (status != null && request.successStatuses.contains(status)),
        ),
      );
      try {
        return Right(request.decoder(_decodeBody(response.data)));
      } on Object catch (error, stackTrace) {
        return Left(AppException.parse(error, stackTrace, request.path));
      }
    } on DioException catch (error) {
      final exception = mapDioException(
        error,
        requiresSession: request.requiresSession,
        deviceOnline: _connectivity?.isOnline,
        sessionExpiredStatuses: _sessionExpiredStatuses,
      );
      _reportSessionExpiry(exception, request);
      return Left(exception);
    } on Object catch (error, stackTrace) {
      return Left(AppException.from(error, stackTrace));
    }
  }

  void dispose() {
    _dio.close();
    unawaited(_sessionExpired.close());
  }

  void _reportSessionExpiry(
    AppException exception,
    BaseRequest<Object?> request,
  ) {
    if (!exception.isSessionExpired || !request.requiresSession) return;
    if (_sessionExpiryReported || _sessionExpired.isClosed) return;
    _sessionExpiryReported = true;
    _sessionExpired.add(
      SessionExpiredEvent(
        path: exception.path ?? request.path,
        statusCode: exception.statusCode,
      ),
    );
  }

  String _urlFor(BaseRequest<Object?> request) => switch (request.host) {
    ApiHost.api => request.path,
    ApiHost.omr => '${_config.omrBaseUrl}${request.path}',
  };

  static bool _isSuccess(int? status) =>
      status != null && status >= 200 && status < 300;

  /// The backend sometimes sends JSON with a non-JSON content type, so Dio
  /// hands the raw string over. Parse it here once; plain text stays text and
  /// an empty body becomes `null`.
  static Object? _decodeBody(Object? data) {
    if (data is! String) return data;
    final text = data.trim();
    if (text.isEmpty) return null;
    if (text.startsWith('{') || text.startsWith('[')) {
      try {
        return jsonDecode(text);
      } on FormatException {
        return data;
      }
    }
    return data;
  }
}
