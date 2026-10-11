import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/core/network/session_expired_event.dart';
import 'package:smap/features/auth/data/auth_repository.dart';

import '../../../core/network/fake_adapter.dart';
import 'auth_fixtures.dart';

void main() {
  late FakeBackend backend;
  late NetworkService network;
  late AuthRepository repository;
  late List<SessionExpiredEvent> expiryEvents;

  setUp(() {
    backend = FakeBackend();
    network = buildNetwork(backend, CookieJar());
    repository = AuthRepository(network);
    expiryEvents = [];
    network.onSessionExpired.listen(expiryEvents.add);
  });

  tearDown(() => network.dispose());

  group('login', () {
    test('posts the credentials as JSON and reads the user', () async {
      final result = await repository.login(
        username: 'ayse',
        password: 'secret-1',
      );

      final response = result.rightOrNull!;
      expect(response.isAuthenticated, isTrue);
      expect(response.user?.id, 'student-1');
      final request = backend.requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/student/login');
      expect(request.data, {'username': 'ayse', 'password': 'secret-1'});
      expect(request.contentType, contains('application/json'));
    });

    test('a 302 whose body carries the user is a login', () async {
      backend.loginStatus = 302;

      final result = await repository.login(username: 'a', password: 'b');

      expect(result.rightOrNull?.user?.id, 'student-1');
    });

    test('a 302 that is just the login page again is not a login', () async {
      network.dispose();
      final adapter = FakeAdapter(
        (_) => textResponse(
          'Found. Redirecting to /student/login',
          status: 302,
          headers: {
            'location': ['/student/login'],
          },
        ),
      );
      network = _networkOver(adapter);
      repository = AuthRepository(network);

      final failure = (await repository.login(
        username: 'a',
        password: 'wrong',
      )).leftOrNull!;

      expect(failure.code, AppErrorCode.unauthorized);
    });

    test('a 200 with success: false is wrong credentials', () async {
      backend.loginBody = {'success': false, 'message': 'Şifre hatalı'};

      final failure = (await repository.login(
        username: 'a',
        password: 'b',
      )).leftOrNull!;

      expect(failure.code, AppErrorCode.unauthorized);
      expect(failure.serverMessage, 'Şifre hatalı');
    });

    test('a 200 with an empty or foreign body is not a login', () async {
      backend.loginBody = <String, Object?>{};
      expect(
        (await repository.login(username: 'a', password: 'b')).leftOrNull?.code,
        AppErrorCode.unauthorized,
      );

      backend.loginBody = '<html>maintenance</html>';
      expect(
        (await repository.login(username: 'a', password: 'b')).leftOrNull?.code,
        AppErrorCode.unauthorized,
      );
    });

    test('401 is wrong credentials and is not a session expiry', () async {
      backend
        ..acceptCredentials = false
        ..rejectStatus = 401;

      final failure = (await repository.login(
        username: 'a',
        password: 'b',
      )).leftOrNull!;

      expect(failure.code, AppErrorCode.unauthorized);
      expect(failure.statusCode, 401);
      expect(expiryEvents, isEmpty);
    });

    test('other client errors read as wrong credentials, as in the legacy '
        'login', () async {
      backend.acceptCredentials = false;
      for (final status in [400, 404, 422]) {
        backend.rejectStatus = status;
        final failure = (await repository.login(
          username: 'a',
          password: 'b',
        )).leftOrNull!;
        expect(failure.code, AppErrorCode.unauthorized, reason: '$status');
        expect(failure.statusCode, status);
      }
    });

    test('403 and 5xx keep their own meaning', () async {
      backend.acceptCredentials = false;

      backend.rejectStatus = 403;
      expect(
        (await repository.login(username: 'a', password: 'b')).leftOrNull?.code,
        AppErrorCode.forbidden,
      );
      backend.rejectStatus = 500;
      expect(
        (await repository.login(username: 'a', password: 'b')).leftOrNull?.code,
        AppErrorCode.server,
      );
      backend.rejectStatus = 503;
      expect(
        (await repository.login(username: 'a', password: 'b')).leftOrNull?.code,
        AppErrorCode.maintenance,
      );
    });

    test('offline fails with the offline code', () async {
      backend.online = false;

      final failure = (await repository.login(
        username: 'a',
        password: 'b',
      )).leftOrNull!;

      expect(failure.code, AppErrorCode.offline);
    });
  });

  group('checkUser', () {
    test('returns the user of a valid session', () async {
      backend.startSession();
      await saveSessionCookie(network.cookieJar);

      final result = await repository.checkUser();

      expect(result.rightOrNull?.id, 'student-1');
      expect(backend.requests.single.method, 'GET');
      expect(backend.requests.single.path, '/ajax/checkUser');
    });

    test('401 is an expired session and fires the expiry event', () async {
      final failure = (await repository.checkUser()).leftOrNull!;

      expect(failure.code, AppErrorCode.sessionExpired);
      expect(expiryEvents, hasLength(1));
      expect(expiryEvents.single.path, '/ajax/checkUser');
    });

    test('a redirect to the login page is an expired session', () async {
      backend.noSessionStatus = 302;

      final failure = (await repository.checkUser()).leftOrNull!;

      expect(failure.code, AppErrorCode.sessionExpired);
      expect(failure.statusCode, 302);
    });

    test('success: false and a missing user are expired sessions', () async {
      backend.startSession();
      await saveSessionCookie(network.cookieJar);
      backend.checkUserWithoutUser = true;

      final failure = (await repository.checkUser()).leftOrNull!;

      expect(failure.code, AppErrorCode.sessionExpired);
      expect(expiryEvents, isEmpty, reason: 'the HTTP call itself was fine');
    });

    test('offline fails with the offline code, no expiry', () async {
      backend.online = false;

      final failure = (await repository.checkUser()).leftOrNull!;

      expect(failure.code, AppErrorCode.offline);
      expect(expiryEvents, isEmpty);
    });

    test('a 5xx is a server error, no expiry', () async {
      backend.checkUserFailsWith = 500;

      final failure = (await repository.checkUser()).leftOrNull!;

      expect(failure.code, AppErrorCode.server);
      expect(expiryEvents, isEmpty);
    });
  });

  group('logout', () {
    test('a 302 counts as done', () async {
      backend.startSession();
      await saveSessionCookie(network.cookieJar);

      final result = await repository.logout();

      expect(result.isRight(), isTrue);
      expect(backend.requests.single.path, '/ajax/logout');
      expect(backend.requests.single.method, 'GET');
      expect(backend.validCookie, isNull);
    });

    test('a failure comes back as a Left', () async {
      backend.logoutFailsWith = 500;

      expect((await repository.logout()).leftOrNull?.code, AppErrorCode.server);
    });

    test('offline comes back as a Left', () async {
      backend.online = false;

      expect(
        (await repository.logout()).leftOrNull?.code,
        AppErrorCode.offline,
      );
    });
  });
}

NetworkService _networkOver(FakeAdapter adapter) => NetworkService(
  config: AppConfig.resolve(),
  cookieJar: CookieJar(),
  logTraffic: false,
  httpClientAdapter: adapter,
);
