import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/network/dio_error_mapper.dart';

RequestOptions _options() =>
    RequestOptions(path: '/student/me', baseUrl: 'https://x.test');

DioException _badResponse(int status, {Object? data}) =>
    DioException.badResponse(
      statusCode: status,
      requestOptions: _options(),
      response: Response<Object?>(
        requestOptions: _options(),
        statusCode: status,
        data: data,
      ),
    );

DioException _transport(DioExceptionType type, {Object? error}) =>
    DioException(requestOptions: _options(), type: type, error: error);

void main() {
  group('transport failures', () {
    test('cancel -> cancelled', () {
      final e = mapDioException(
        DioException.requestCancelled(requestOptions: _options(), reason: null),
      );

      expect(e.code, AppErrorCode.cancelled);
      expect(e.path, '/student/me');
    });

    test('send and receive timeouts -> timeout, even when offline', () {
      for (final type in [
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect(mapDioException(_transport(type)).code, AppErrorCode.timeout);
        expect(
          mapDioException(_transport(type), deviceOnline: false).code,
          AppErrorCode.timeout,
        );
      }
    });

    test(
      'connect timeout -> timeout, but offline when the device has no link',
      () {
        final error = _transport(DioExceptionType.connectionTimeout);

        expect(mapDioException(error).code, AppErrorCode.timeout);
        expect(
          mapDioException(error, deviceOnline: true).code,
          AppErrorCode.timeout,
        );
        expect(
          mapDioException(error, deviceOnline: false).code,
          AppErrorCode.offline,
        );
      },
    );

    test('DNS failure -> offline', () {
      final error = _transport(
        DioExceptionType.connectionError,
        error: const SocketException('Failed host lookup: www.smaptr.com'),
      );

      expect(mapDioException(error).code, AppErrorCode.offline);
    });

    test('network unreachable errno -> offline', () {
      for (final errno in [101, 51, 50, 113, 65]) {
        final error = _transport(
          DioExceptionType.connectionError,
          error: SocketException('send failed', osError: OSError('', errno)),
        );

        expect(
          mapDioException(error).code,
          AppErrorCode.offline,
          reason: 'errno $errno',
        );
      }
    });

    test('connection refused or reset is the server side -> network', () {
      for (final errno in [61, 111, 54, 104]) {
        final error = _transport(
          DioExceptionType.connectionError,
          error: SocketException(
            'Connection failed',
            osError: OSError('', errno),
          ),
        );

        expect(
          mapDioException(error).code,
          AppErrorCode.network,
          reason: 'errno $errno',
        );
      }
    });

    test('a connection error with no link at all -> offline', () {
      final error = _transport(
        DioExceptionType.connectionError,
        error: const SocketException('Connection reset'),
      );

      expect(
        mapDioException(error, deviceOnline: false).code,
        AppErrorCode.offline,
      );
      expect(
        mapDioException(error, deviceOnline: true).code,
        AppErrorCode.network,
      );
    });

    test(
      'unknown type wrapping a SocketException behaves like a connection error',
      () {
        final error = _transport(
          DioExceptionType.unknown,
          error: const SocketException('Failed host lookup'),
        );

        expect(mapDioException(error).code, AppErrorCode.offline);
      },
    );

    test('bad certificate and TLS handshake failures -> network', () {
      expect(
        mapDioException(_transport(DioExceptionType.badCertificate)).code,
        AppErrorCode.network,
      );
      expect(
        mapDioException(
          _transport(
            DioExceptionType.unknown,
            error: const HandshakeException('bad'),
          ),
        ).code,
        AppErrorCode.network,
      );
    });

    test('anything else -> unknown', () {
      final error = _transport(
        DioExceptionType.unknown,
        error: StateError('x'),
      );

      expect(mapDioException(error).code, AppErrorCode.unknown);
    });

    test('an AppException already wrapped in the error passes through', () {
      const inner = AppException(code: AppErrorCode.maintenance);
      final error = _transport(DioExceptionType.unknown, error: inner);

      expect(mapDioException(error), same(inner));
    });
  });

  group('HTTP status (request needs a session)', () {
    AppErrorCode code(int status) => mapDioException(_badResponse(status)).code;

    test('401 and 403 -> sessionExpired', () {
      expect(code(401), AppErrorCode.sessionExpired);
      expect(code(403), AppErrorCode.sessionExpired);
    });

    test('a redirect -> sessionExpired, never success', () {
      for (final status in [301, 302, 303, 307, 308]) {
        expect(code(status), AppErrorCode.sessionExpired, reason: '$status');
      }
    });

    test('403 is forbidden when the policy leaves it out', () {
      final e = mapDioException(
        _badResponse(403),
        sessionExpiredStatuses: const {401},
      );

      expect(e.code, AppErrorCode.forbidden);
    });

    test('404, validation, maintenance, server', () {
      expect(code(404), AppErrorCode.notFound);
      expect(code(400), AppErrorCode.validation);
      expect(code(409), AppErrorCode.validation);
      expect(code(422), AppErrorCode.validation);
      expect(code(503), AppErrorCode.maintenance);
      expect(code(500), AppErrorCode.server);
      expect(code(502), AppErrorCode.server);
      expect(code(504), AppErrorCode.server);
      expect(code(429), AppErrorCode.server);
      expect(code(408), AppErrorCode.timeout);
      expect(code(418), AppErrorCode.unknown);
    });

    test(
      'a server failure is never offline, whatever the connectivity says',
      () {
        final e = mapDioException(_badResponse(500), deviceOnline: false);

        expect(e.code, AppErrorCode.server);
        expect(e.isOffline, isFalse);
      },
    );

    test('status and path are kept', () {
      final e = mapDioException(_badResponse(404));

      expect(e.statusCode, 404);
      expect(e.path, '/student/me');
    });
  });

  group('HTTP status (public request)', () {
    AppErrorCode code(int status) =>
        mapDioException(_badResponse(status), requiresSession: false).code;

    test('401 is unauthorized, 403 is forbidden', () {
      expect(code(401), AppErrorCode.unauthorized);
      expect(code(403), AppErrorCode.forbidden);
    });

    test('a redirect is unexpected, not an expired session', () {
      expect(code(302), AppErrorCode.unknown);
    });
  });

  group('server message', () {
    test('a short message field is kept for validation errors', () {
      final e = mapDioException(
        _badResponse(400, data: {'message': ' Bu kullanıcı adı alınmış. '}),
      );

      expect(e.serverMessage, 'Bu kullanıcı adı alınmış.');
    });

    test('HTML, long and non-string messages are dropped', () {
      expect(
        mapDioException(_badResponse(400, data: '<html></html>')).serverMessage,
        isNull,
      );
      expect(
        mapDioException(
          _badResponse(400, data: {'message': 'x' * 301}),
        ).serverMessage,
        isNull,
      );
      expect(
        mapDioException(_badResponse(400, data: {'message': 5})).serverMessage,
        isNull,
      );
      expect(
        mapDioException(
          _badResponse(400, data: {'message': ' '}),
        ).serverMessage,
        isNull,
      );
    });
  });

  test('mapStatus without a status is unknown', () {
    expect(mapStatus(null, path: '/a').code, AppErrorCode.unknown);
  });
}
