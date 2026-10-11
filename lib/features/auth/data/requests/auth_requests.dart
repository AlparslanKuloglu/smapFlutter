import 'package:dartz/dartz.dart';

import 'package:smap/core/network/base_request.dart';
import 'package:smap/features/auth/data/dtos/check_user_response.dart';
import 'package:smap/features/auth/data/dtos/login_response.dart';

/// The auth endpoints as typed requests (`NetworkService.send`).
///
/// Bodies, paths and the redirect behaviour follow the legacy
/// `AuthRemoteDataSource`; the receive timeouts are the legacy ones (it used
/// 8 s for login and logout, 5 s for the session check) except where noted.
abstract final class AuthRequests {
  /// `POST /student/login` with the credentials as JSON.
  ///
  /// Public call: a 401 is "wrong credentials", not "session expired". The
  /// backend answers a successful login with a 200 or a 302, so 302 is listed
  /// as a status that may succeed; the repository still reads the body before
  /// it believes it.
  static BaseRequest<LoginResponse> login({
    required String username,
    required String password,
  }) => BaseRequest<LoginResponse>(
    method: HttpMethod.post,
    path: '/student/login',
    body: <String, String>{'username': username, 'password': password},
    requiresSession: false,
    successStatuses: const {302},
    sendTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    decoder: LoginResponse.fromBody,
  );

  /// `GET /ajax/checkUser`: is the cookie session still valid, and for whom.
  ///
  /// A 302 here is the backend sending an unauthenticated caller to the login
  /// page, so it is not a success status (it reads as an expired session).
  static BaseRequest<CheckUserResponse> checkUser() =>
      const BaseRequest<CheckUserResponse>(
        method: HttpMethod.get,
        path: '/ajax/checkUser',
        receiveTimeout: Duration(seconds: 8),
        decoder: CheckUserResponse.fromBody,
      );

  /// `GET /ajax/logout`. The backend ends the session with a redirect, so 302
  /// counts as done.
  static BaseRequest<Unit> logout() => BaseRequest<Unit>(
    method: HttpMethod.get,
    path: '/ajax/logout',
    successStatuses: const {302},
    receiveTimeout: const Duration(seconds: 8),
    decoder: (_) => unit,
  );
}
