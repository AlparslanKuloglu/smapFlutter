import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/network/base_request.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/core/network/session_expired_event.dart';
import 'package:smap/core/services/connectivity_service.dart';

import 'fake_adapter.dart';
import '../services/fake_connectivity.dart';

BaseRequest<Map<String, Object?>> _get([
  String path = '/student/me',
  Set<int> successStatuses = const {},
  bool requiresSession = true,
]) => BaseRequest<Map<String, Object?>>(
  method: HttpMethod.get,
  path: path,
  requiresSession: requiresSession,
  successStatuses: successStatuses,
  decoder: (data) => Map<String, Object?>.from(data! as Map),
);

void main() {
  late FakeAdapter adapter;
  late CookieJar jar;
  late NetworkService service;
  late List<SessionExpiredEvent> events;

  NetworkService build(
    FakeAdapter fake, {
    ConnectivityService? connectivity,
    AppConfig? config,
  }) {
    adapter = fake;
    service = NetworkService(
      config: config ?? AppConfig.resolve(),
      cookieJar: jar,
      connectivity: connectivity,
      logTraffic: false,
      httpClientAdapter: fake,
    );
    events = [];
    service.onSessionExpired.listen(events.add);
    return service;
  }

  setUp(() => jar = CookieJar());
  tearDown(() => service.dispose());

  AppException failure(Either<AppException, Object?> result) =>
      result.leftOrNull ?? fail('expected a failure, got $result');

  group('configuration', () {
    test('timeouts, redirects and base URL follow the spec', () {
      build(FakeAdapter.json({}));
      final options = service.dio.options;

      expect(options.baseUrl, 'https://www.smaptr.com');
      expect(options.connectTimeout, const Duration(seconds: 15));
      expect(options.receiveTimeout, const Duration(seconds: 30));
      expect(options.followRedirects, isFalse);
      expect(options.validateStatus(200), isTrue);
      expect(options.validateStatus(204), isTrue);
      expect(options.validateStatus(302), isFalse);
      expect(options.validateStatus(404), isFalse);
      expect(options.validateStatus(null), isFalse);
    });

    test('the base URL comes from AppConfig', () {
      build(
        FakeAdapter.json({}),
        config: AppConfig.resolve(apiBaseUrl: 'https://api.example.com'),
      );

      expect(service.dio.options.baseUrl, 'https://api.example.com');
    });
  });

  group('success', () {
    test('200 JSON is decoded', () async {
      build(FakeAdapter.json({'success': true, 'name': 'Ada'}));

      final result = await service.send(_get());

      expect(result.rightOrNull, {'success': true, 'name': 'Ada'});
      expect(adapter.last.path, '/student/me');
      expect(adapter.last.method, 'GET');
    });

    test('JSON sent as text/html is still parsed', () async {
      build(FakeAdapter((_) => textResponse('{"success":true}')));

      final result = await service.send(_get());

      expect(result.rightOrNull, {'success': true});
    });

    test('an empty 200 body decodes as null', () async {
      build(FakeAdapter((_) => textResponse('', contentType: 'text/plain')));
      final request = BaseRequest<bool>(
        method: HttpMethod.post,
        path: '/ajax/ping',
        decoder: (data) => data == null,
      );

      expect((await service.send(request)).rightOrNull, isTrue);
    });

    test('query, body and headers reach the adapter', () async {
      build(FakeAdapter.json({'ok': 1}));

      await service.send(
        BaseRequest<Object?>(
          method: HttpMethod.post,
          path: '/student/updateProgram',
          query: {'page': 2},
          body: {'a': 1},
          headers: {'X-Test': 'yes'},
          decoder: (data) => data,
        ),
      );

      expect(adapter.last.method, 'POST');
      expect(adapter.last.queryParameters, {'page': 2});
      expect(adapter.last.data, {'a': 1});
      expect(adapter.last.headers['X-Test'], 'yes');
    });

    test(
      'a decoder that throws becomes an unknown failure, not an exception',
      () async {
        build(FakeAdapter.json({'unexpected': true}));
        final request = BaseRequest<int>(
          method: HttpMethod.get,
          path: '/a',
          decoder: (data) => (data! as Map)['count'] as int,
        );

        final e = failure(await service.send(request));

        expect(e.code, AppErrorCode.unknown);
        expect(e.path, '/a');
        expect(events, isEmpty);
      },
    );
  });

  group('redirects (302)', () {
    ResponseBody redirect(RequestOptions _) => textResponse(
      'Found. Redirecting to /student/login',
      status: 302,
      headers: {
        'location': ['/student/login'],
      },
    );

    test('302 is not a success: it reads as an expired session', () async {
      build(FakeAdapter(redirect));

      final e = failure(await service.send(_get()));

      expect(e.code, AppErrorCode.sessionExpired);
      expect(e.statusCode, 302);
      expect(events.map((e) => e.statusCode), [302]);
    });

    test('redirects are not followed', () async {
      build(FakeAdapter(redirect));

      await service.send(_get());

      expect(adapter.requests, hasLength(1));
      expect(adapter.last.followRedirects, isFalse);
    });

    test(
      'a call that lists 302 as success (login, logout) gets the answer',
      () async {
        build(
          FakeAdapter(
            (_) => jsonResponse({
              'user': {'name': 'Ada'},
            }, status: 302),
          ),
        );

        final result = await service.send(
          _get('/student/login', const {302}, false),
        );

        expect(result.isRight(), isTrue);
        expect(events, isEmpty);
      },
    );

    test(
      '302 on a public call is unknown and fires no session event',
      () async {
        build(FakeAdapter(redirect));

        final e = failure(
          await service.send(_get('/ajax/getLegalDocuments', const {}, false)),
        );

        expect(e.code, AppErrorCode.unknown);
        expect(events, isEmpty);
      },
    );
  });

  group('session expiry (401 / 403)', () {
    test('401 -> sessionExpired and one event', () async {
      build(FakeAdapter.json({'message': 'login'}, status: 401));

      final e = failure(await service.send(_get()));

      expect(e.code, AppErrorCode.sessionExpired);
      expect(events.single.path, '/student/me');
      expect(events.single.statusCode, 401);
    });

    test('403 -> sessionExpired and an event', () async {
      build(FakeAdapter.json({}, status: 403));

      final e = failure(await service.send(_get()));

      expect(e.code, AppErrorCode.sessionExpired);
      expect(events, hasLength(1));
    });

    test('a burst of 401s emits once, markSessionStarted re-arms', () async {
      build(FakeAdapter.json({}, status: 401));

      await Future.wait([
        service.send(_get('/a')),
        service.send(_get('/b')),
        service.send(_get('/c')),
      ]);
      expect(events, hasLength(1));

      await service.send(_get('/d'));
      expect(events, hasLength(1));

      service.markSessionStarted();
      await service.send(_get('/e'));
      expect(events, hasLength(2));
      expect(events.last.path, '/e');
    });

    test(
      'wrong credentials on a public call are unauthorized, with no event',
      () async {
        build(FakeAdapter.json({'message': 'Hatalı şifre'}, status: 401));

        final e = failure(
          await service.send(_get('/student/login', const {}, false)),
        );

        expect(e.code, AppErrorCode.unauthorized);
        expect(events, isEmpty);
      },
    );

    test('the status policy is configurable', () async {
      adapter = FakeAdapter.json({}, status: 403);
      service = NetworkService(
        config: AppConfig.resolve(),
        cookieJar: jar,
        logTraffic: false,
        httpClientAdapter: adapter,
        sessionExpiredStatuses: const {401},
      );
      events = [];
      service.onSessionExpired.listen(events.add);

      final e = failure(await service.send(_get()));

      expect(e.code, AppErrorCode.forbidden);
      expect(events, isEmpty);
    });
  });

  group('other statuses', () {
    test('404, 400 with the server message, 503, 500', () async {
      build(
        FakeAdapter((o) {
          return switch (o.path) {
            '/missing' => jsonResponse({}, status: 404),
            '/invalid' => jsonResponse({'message': 'Eksik alan'}, status: 400),
            '/maintenance' => textResponse('<html>bakım</html>', status: 503),
            _ => jsonResponse({}, status: 500),
          };
        }),
      );

      expect(
        failure(await service.send(_get('/missing'))).code,
        AppErrorCode.notFound,
      );
      final invalid = failure(await service.send(_get('/invalid')));
      expect(invalid.code, AppErrorCode.validation);
      expect(invalid.serverMessage, 'Eksik alan');
      expect(
        failure(await service.send(_get('/maintenance'))).code,
        AppErrorCode.maintenance,
      );
      expect(
        failure(await service.send(_get('/boom'))).code,
        AppErrorCode.server,
      );
      expect(events, isEmpty);
    });

    test(
      'a 500 while the device reads offline is still a server error',
      () async {
        final connectivity = ConnectivityService(
          connectivity: FakeConnectivity(
            initial: const [ConnectivityResult.none],
          ),
        );
        await connectivity.initialize();
        addTearDown(connectivity.dispose);
        build(FakeAdapter.json({}, status: 500), connectivity: connectivity);

        final e = failure(await service.send(_get()));

        expect(connectivity.isOnline, isFalse);
        expect(e.code, AppErrorCode.server);
      },
    );
  });

  group('transport failures', () {
    test('connect timeout -> timeout', () async {
      build(
        FakeAdapter.failing(
          (o) => DioException.connectionTimeout(
            timeout: const Duration(seconds: 15),
            requestOptions: o,
          ),
        ),
      );

      expect(failure(await service.send(_get())).code, AppErrorCode.timeout);
    });

    test('receive timeout -> timeout', () async {
      build(
        FakeAdapter.failing(
          (o) => DioException.receiveTimeout(
            timeout: const Duration(seconds: 30),
            requestOptions: o,
          ),
        ),
      );

      expect(failure(await service.send(_get())).code, AppErrorCode.timeout);
    });

    test('no route to the host -> offline', () async {
      build(
        FakeAdapter.failing(
          (o) => DioException.connectionError(
            requestOptions: o,
            reason: 'Failed host lookup',
            error: const SocketException('Failed host lookup: www.smaptr.com'),
          ),
        ),
      );

      final e = failure(await service.send(_get()));

      expect(e.code, AppErrorCode.offline);
      expect(events, isEmpty);
    });

    test(
      'a refused connection while the device reads online -> network',
      () async {
        final connectivity = ConnectivityService(
          connectivity: FakeConnectivity(
            initial: const [ConnectivityResult.wifi],
          ),
        );
        await connectivity.initialize();
        addTearDown(connectivity.dispose);
        build(
          FakeAdapter.failing(
            (o) => DioException.connectionError(
              requestOptions: o,
              reason: 'refused',
              error: const SocketException('refused', osError: OSError('', 61)),
            ),
          ),
          connectivity: connectivity,
        );

        expect(failure(await service.send(_get())).code, AppErrorCode.network);
      },
    );

    test('a connection error with the device offline -> offline', () async {
      final connectivity = ConnectivityService(
        connectivity: FakeConnectivity(
          initial: const [ConnectivityResult.none],
        ),
      );
      await connectivity.initialize();
      addTearDown(connectivity.dispose);
      build(
        FakeAdapter.failing(
          (o) => DioException.connectionError(
            requestOptions: o,
            reason: 'reset',
            error: const SocketException('Connection reset by peer'),
          ),
        ),
        connectivity: connectivity,
      );

      expect(failure(await service.send(_get())).code, AppErrorCode.offline);
    });

    test('cancelling returns cancelled', () async {
      final gate = Completer<ResponseBody>();
      build(FakeAdapter((_) => gate.future));
      final token = CancelToken();

      final pending = service.send(_get(), cancelToken: token);
      await Future<void>.delayed(Duration.zero);
      token.cancel('user left');

      expect(failure(await pending).code, AppErrorCode.cancelled);
      expect(events, isEmpty);
    });
  });

  group('hosts', () {
    test('OMR requests go to omrBaseUrl', () async {
      build(
        FakeAdapter.json({'ok': true}),
        config: AppConfig.resolve(
          apiBaseUrl: 'https://api.example.com',
          omrBaseUrl: 'https://omr.example.com/',
        ),
      );

      await service.send(
        BaseRequest<Object?>(
          method: HttpMethod.post,
          path: '/opticimage',
          host: ApiHost.omr,
          decoder: (data) => data,
        ),
      );

      expect(adapter.last.uri.toString(), 'https://omr.example.com/opticimage');
    });

    test('API requests keep the API base URL', () async {
      build(FakeAdapter.json({}));

      await service.send(_get());

      expect(adapter.last.uri.toString(), 'https://www.smaptr.com/student/me');
    });
  });

  group('multipart', () {
    MultipartRequest<Object?> upload() => MultipartRequest<Object?>(
      path: '/opticimage',
      host: ApiHost.omr,
      fields: const {'user_data': '{}'},
      files: [
        UploadFile.fromBytes(
          field: 'image',
          bytes: Uint8List.fromList([1, 2, 3]),
          filename: 'form.jpg',
          contentType: 'image/jpeg',
        ),
      ],
      decoder: (data) => data,
    );

    test('sends form data with a 60 second send timeout', () async {
      build(FakeAdapter.json({'success': true}));

      final result = await service.send(upload());

      expect(result.isRight(), isTrue);
      final body = adapter.last.data as FormData;
      expect(body.fields.single.key, 'user_data');
      expect(body.fields.single.value, '{}');
      expect(body.files.single.key, 'image');
      expect(body.files.single.value.filename, 'form.jpg');
      expect(adapter.last.sendTimeout, const Duration(seconds: 60));
    });

    test('a retry builds a fresh form', () async {
      build(FakeAdapter.json({}));
      final request = upload();

      await service.send(request);
      final first = adapter.last.data;
      await service.send(request);

      expect(adapter.last.data, isNot(same(first)));
    });

    test('per-call timeouts override the defaults', () async {
      build(FakeAdapter.json({}));

      await service.send(
        BaseRequest<Object?>(
          method: HttpMethod.get,
          path: '/slow',
          decoder: (data) => data,
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 6),
        ),
      );

      expect(adapter.last.receiveTimeout, const Duration(seconds: 5));
      expect(adapter.last.sendTimeout, const Duration(seconds: 6));
    });
  });

  group('cookie session', () {
    test('a Set-Cookie answer is stored and sent on the next call', () async {
      var call = 0;
      build(
        FakeAdapter((options) {
          call++;
          if (call == 1) {
            return jsonResponse(
              {'ok': true},
              headers: {
                HttpHeaders.setCookieHeader: [
                  'connect.sid=abc123; Path=/; HttpOnly',
                ],
              },
            );
          }
          return jsonResponse({'ok': true});
        }),
      );

      await service.send(_get('/student/login', const {}, false));
      await service.send(_get());

      expect(
        adapter.requests.last.headers[HttpHeaders.cookieHeader],
        contains('connect.sid=abc123'),
      );
      final stored = await jar.loadForRequest(
        Uri.parse('https://www.smaptr.com/'),
      );
      expect(stored.map((c) => c.name), contains('connect.sid'));
    });

    test(
      'a redirect that sets the session cookie keeps it (login 302)',
      () async {
        build(
          FakeAdapter(
            (_) => jsonResponse(
              {'user': {}},
              status: 302,
              headers: {
                HttpHeaders.setCookieHeader: ['connect.sid=fresh; Path=/'],
              },
            ),
          ),
        );

        await service.send(_get('/student/login', const {302}, false));

        final stored = await jar.loadForRequest(
          Uri.parse('https://www.smaptr.com/'),
        );
        expect(stored.map((c) => c.value), contains('fresh'));
      },
    );
  });
}
