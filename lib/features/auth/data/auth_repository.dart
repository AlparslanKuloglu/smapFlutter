import 'package:dartz/dartz.dart';

import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/auth/data/dtos/login_response.dart';
import 'package:smap/features/auth/data/dtos/new_registration.dart';
import 'package:smap/features/auth/data/dtos/register_outcome.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';
import 'package:smap/features/auth/data/requests/auth_requests.dart';
import 'package:smap/features/auth/data/requests/register_requests.dart';

/// Talks to the auth endpoints and answers `Either<AppException, T>`.
///
/// It only does HTTP and reading the answers. Where the session lives (cookie
/// jar, user cache, DI scope) is `SessionManager`'s business.
class AuthRepository {
  AuthRepository(this._network);

  final NetworkService _network;

  /// `POST /student/login`.
  ///
  /// Succeeds only when the answer's body proves the login: a 200 or 302
  /// whose body is not `success: false` and carries `success: true` or the
  /// user. A redirect that is just the login page again, a `success: false`
  /// body and an answer in the wrong format all fail with
  /// [AppErrorCode.unauthorized].
  ///
  /// Like the legacy login, any 4xx the server answers with a client-error
  /// meaning ("bad request", "not found") reads as wrong credentials; a 403
  /// stays [AppErrorCode.forbidden] and 5xx stay server errors.
  Future<AppResult<LoginResponse>> login({
    required String username,
    required String password,
  }) async {
    final result = await _network.send(
      AuthRequests.login(username: username, password: password),
    );
    return result.fold((failure) => Left(_loginFailure(failure)), (response) {
      if (response.isAuthenticated) return Right(response);
      return Left(
        AppException(
          code: AppErrorCode.unauthorized,
          message: 'Login answered without a valid session body',
          path: '/student/login',
          serverMessage: response.message,
        ),
      );
    });
  }

  /// `GET /ajax/checkUser`: the account that owns the cookie session.
  ///
  /// A `success: false` answer or one without a user is
  /// [AppErrorCode.sessionExpired], the same as a 401 or a redirect, so a
  /// caller has one "no session" case to handle.
  Future<AppResult<UserDto>> checkUser() async {
    final result = await _network.send(AuthRequests.checkUser());
    return result.fold(Left.new, (response) {
      final user = response.user;
      if (response.isSignedIn && user != null) return Right(user);
      return Left(
        AppException(
          code: AppErrorCode.sessionExpired,
          message: 'checkUser reported no session',
          path: '/ajax/checkUser',
          serverMessage: response.message,
        ),
      );
    });
  }

  /// `GET /ajax/logout`: ends the server session. The cookie jar is not
  /// touched; the caller clears it.
  Future<AppResult<Unit>> logout() => _network.send(AuthRequests.logout());

  /// `POST /student/register`: creates the account (student or coach).
  ///
  /// Succeeds with [RegisterOutcome.registered] when the answer's body says
  /// `success: true` (the legacy rule: a 2xx or 302 whose body proves it), and
  /// with [RegisterOutcome.userNameTaken] when the server says the user name
  /// is in use, whether as `userNameUsing: true` or as a refusal text that
  /// reads so (`RegisterOutcome.readsAsUserNameTaken`), with a 200 or with a
  /// 4xx. Any other refusal is `AppErrorCode.validation` with the server's text
  /// in `serverMessage`; an answer that is not the backend's frame is a
  /// `server` failure.
  ///
  /// The call does not sign anybody in: the caller does, with the same user
  /// name and password (`SessionManager.signIn`).
  Future<AppResult<RegisterOutcome>> register(
    NewRegistration registration,
  ) async {
    const path = '/student/register';
    final result = await _network.send(RegisterRequests.register(registration));
    return result.fold(
      (failure) => RegisterOutcome.readsAsUserNameTaken(failure.serverMessage)
          ? const Right(RegisterOutcome.userNameTaken)
          : Left(failure),
      (envelope) {
        if (envelope.isSuccess) return const Right(RegisterOutcome.registered);
        if (envelope['userNameUsing'] == true ||
            RegisterOutcome.readsAsUserNameTaken(envelope.message)) {
          return const Right(RegisterOutcome.userNameTaken);
        }
        if (envelope.isRejected) return Left(envelope.rejection(path));
        return Left(envelope.unusable(path, 'no success flag'));
      },
    );
  }

  AppException _loginFailure(AppException failure) {
    final status = failure.statusCode;
    final readsAsWrongCredentials =
        failure.code == AppErrorCode.validation ||
        failure.code == AppErrorCode.notFound;
    if (!readsAsWrongCredentials || status == null) return failure;
    return AppException(
      code: AppErrorCode.unauthorized,
      message: failure.message,
      statusCode: status,
      path: failure.path,
      serverMessage: failure.serverMessage,
      cause: failure.cause,
      stackTrace: failure.stackTrace,
    );
  }
}
