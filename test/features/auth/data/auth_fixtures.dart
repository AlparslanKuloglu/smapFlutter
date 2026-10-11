import 'dart:async';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/auth/data/session/secure_value_store.dart';

import '../../../core/network/fake_adapter.dart';

/// A student document as the legacy login stores it, password hash included.
Map<String, Object?> studentJson({
  String id = 'student-1',
  String name = 'Ayşe Yılmaz',
  String role = 'student',
}) => {
  '_id': id,
  'name': name,
  'userName': 'ayse',
  'password': r'$2a$10$abcdefghijklmnopqrstuv',
  'photo': 'avatars/1avatarN3.png',
  'seasonType': 12,
  'aimType': 3,
  'email': 'ayse@example.com',
  'role': role,
  'points': 120,
  'progress': 0.4,
};

/// An in-memory [SecureValueStore] that can be told to fail.
class FakeSecureStore implements SecureValueStore {
  final Map<String, String> values = {};
  int failReads = 0;
  bool failWrites = false;
  int reads = 0;

  @override
  Future<String?> read(String key) async {
    reads++;
    if (failReads > 0) {
      failReads--;
      throw StateError('keychain not ready');
    }
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    if (failWrites) throw StateError('keychain full');
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async => values.remove(key);
}

/// The SMAP backend as far as the session cares: a login that sets the
/// `connect.sid` cookie, a check that honours it, a logout that ends it.
class FakeBackend {
  FakeBackend({Map<String, Object?>? user}) : user = user ?? studentJson();

  Map<String, Object?> user;

  /// `true`: the device can reach the server.
  bool online = true;

  /// What `/student/login` answers when the credentials are accepted.
  int loginStatus = 200;
  Object? loginBody;

  /// Wrong credentials: this status (401 by default) with an HTML or JSON body.
  bool acceptCredentials = true;
  int rejectStatus = 401;

  /// What `/ajax/checkUser` answers an unauthenticated caller with.
  int noSessionStatus = 401;

  /// `/ajax/checkUser` answers a valid session with a body without a user.
  bool checkUserWithoutUser = false;

  /// `/ajax/checkUser` fails with this status although the session is fine.
  int? checkUserFailsWith;

  /// `/ajax/logout` fails with this status.
  int? logoutFailsWith;

  /// When set, `/ajax/logout` answers only after it completes.
  Completer<void>? logoutGate;

  /// The cookie value the server accepts, `null` when no session exists.
  String? validCookie;

  final List<RequestOptions> requests = [];
  int _logins = 0;

  Iterable<RequestOptions> calls(String path) =>
      requests.where((r) => r.path == path);

  FutureOr<ResponseBody> handle(RequestOptions options) {
    requests.add(options);
    if (!online) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
        error: const SocketException('Failed host lookup: www.smaptr.com'),
      );
    }
    final cookie = '${options.headers['cookie'] ?? ''}';
    final signedIn = validCookie != null && cookie.contains(validCookie!);
    switch (options.path) {
      case '/student/login':
        if (!acceptCredentials) {
          return jsonResponse({
            'success': false,
            'message': 'hatalı',
          }, status: rejectStatus);
        }
        _logins++;
        validCookie = 'sid-$_logins';
        return jsonResponse(
          loginBody ?? {'success': true, 'user': user},
          status: loginStatus,
          headers: {
            'set-cookie': ['connect.sid=$validCookie; Path=/; HttpOnly'],
          },
        );
      case '/ajax/checkUser':
        final failure = checkUserFailsWith;
        if (failure != null) {
          return jsonResponse({'error': 'x'}, status: failure);
        }
        if (!signedIn) {
          return noSessionStatus == 302
              ? textResponse(
                  'Found. Redirecting to /login',
                  status: 302,
                  headers: {
                    'location': ['/login'],
                  },
                )
              : jsonResponse({'success': false}, status: noSessionStatus);
        }
        return jsonResponse(
          checkUserWithoutUser
              ? {'success': true}
              : {'success': true, 'user': user},
        );
      case '/ajax/logout':
        final failure = logoutFailsWith;
        if (failure != null) {
          return jsonResponse({'error': 'x'}, status: failure);
        }
        validCookie = null;
        final answer = textResponse(
          'Found. Redirecting to /',
          status: 302,
          headers: {
            'location': ['/'],
          },
        );
        final gate = logoutGate;
        return gate == null ? answer : gate.future.then((_) => answer);
    }
    return jsonResponse({'error': 'unexpected ${options.path}'}, status: 404);
  }

  /// A signed-in session without going through the login.
  void startSession([String value = 'sid-0']) => validCookie = value;
}

/// A [NetworkService] over [backend] with an in-memory cookie jar.
NetworkService buildNetwork(FakeBackend backend, CookieJar jar) =>
    NetworkService(
      config: AppConfig.resolve(),
      cookieJar: jar,
      logTraffic: false,
      httpClientAdapter: FakeAdapter(backend.handle),
    );

/// Puts a `connect.sid` cookie for the API host into [jar], as an earlier
/// launch would have left it.
Future<void> saveSessionCookie(CookieJar jar, [String value = 'sid-0']) =>
    jar.saveFromResponse(Uri.parse(AppConfig.defaultApiBaseUrl), [
      Cookie('connect.sid', value),
    ]);
