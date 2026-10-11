import 'dart:async';

import 'package:dartz/dartz.dart' show Left, Right;
import 'package:flutter/foundation.dart';

import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/core/network/session_expired_event.dart';
import 'package:smap/core/services/app_logger.dart';
import 'package:smap/core/services/connectivity_service.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/auth/data/auth_repository.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';
import 'package:smap/features/auth/data/session/legacy_session_migration.dart';
import 'package:smap/features/auth/data/session/session_store.dart';
import 'package:smap/features/auth/domain/session_state.dart';

/// Opens the session scope; `pushSessionScope` unless a test says otherwise.
typedef SessionScopePush = void Function();

/// Closes the session scope; `popSessionScope` unless a test says otherwise.
typedef SessionScopePop = Future<void> Function();

/// The one owner of the signed-in session.
///
/// The session is the `connect.sid` cookie in `NetworkService.cookieJar`; the
/// manager decides when it counts, caches who owns it, and brings the `session`
/// DI scope up and down with it. Root scope, created before `runApp`.
///
/// - [restore] runs once at launch. A cached user opens the app at once
///   ("iyimser açılış", also offline); when the device is online the server
///   confirms the session in the background ([revalidate]).
/// - [signIn] logs in, confirms with `checkUser`, caches the user and pushes
///   the scope. Any failure undoes what it did.
/// - [signOut] and [completeAccountDeletion] end the session and clear every
///   trace of it (cookie, cache, legacy keys, the scope).
/// - A 401 on a call that needs the session (`NetworkService.onSessionExpired`)
///   turns the state into `signedOut(expired: true)` and keeps the scope: the
///   user stays on their screen, signs in again in the "oturum bitti" sheet,
///   and goes on. Signing in as somebody else rebuilds the scope.
///
/// The state is a [ValueListenable], so the router can use the manager as its
/// `refreshListenable` and a widget can listen to a single value.
class SessionManager extends ChangeNotifier
    implements ValueListenable<SessionState> {
  SessionManager({
    required AuthRepository auth,
    required SessionStore store,
    required NetworkService network,
    required ConnectivityService connectivity,
    required AppConfig config,
    LegacySessionMigration? migration,
    AppLogger? logger,
    SessionScopePush? pushScope,
    SessionScopePop? popScope,
    Duration logoutTimeout = const Duration(seconds: 8),
  }) : _auth = auth,
       _store = store,
       _network = network,
       _connectivity = connectivity,
       _apiBaseUri = Uri.parse(config.apiBaseUrl),
       _migration = migration,
       _logger = logger ?? AppLogger.silent(),
       _pushScope = pushScope ?? (() => pushSessionScope()),
       _popScope = popScope ?? popSessionScope,
       _logoutTimeout = logoutTimeout {
    _expirySubscription = _network.onSessionExpired.listen(_onSessionExpired);
  }

  static const String _tag = 'Session';

  final AuthRepository _auth;
  final SessionStore _store;
  final NetworkService _network;
  final ConnectivityService _connectivity;
  final Uri _apiBaseUri;
  final LegacySessionMigration? _migration;
  final AppLogger _logger;
  final SessionScopePush _pushScope;
  final SessionScopePop _popScope;
  final Duration _logoutTimeout;

  late final StreamSubscription<SessionExpiredEvent> _expirySubscription;

  SessionState _state = const SessionState.unknown();
  bool _scopeOpen = false;
  bool _signingIn = false;
  bool _disposed = false;

  /// Counts identity changes; a check that was started under an older number
  /// ignores its own answer.
  int _epoch = 0;

  /// Id of the user whose scope is open, kept across an expired session so the
  /// same user can continue without rebuilding the scope.
  String? _scopeUserId;

  Future<void>? _restoring;
  Future<void>? _revalidating;
  Future<void>? _ending;

  SessionState get state => _state;

  @override
  SessionState get value => _state;

  /// The signed-in user, `null` otherwise.
  UserDto? get user => _state.user;

  bool get isSignedIn => _state.isSignedIn;

  /// `true` while [signIn] runs, for a login button's busy state.
  bool get isSigningIn => _signingIn;

  // ---------------------------------------------------------------- restore

  /// Decides the state at launch. Call it once, before the first route; the
  /// native splash stays up until it returns. Later calls return the same
  /// future.
  ///
  /// 1. Moves the legacy plain-text user into secure storage (once).
  /// 2. No session cookie on the device: signed out (a cached user left over,
  ///    for example in an iOS Keychain that survived a reinstall, is deleted).
  /// 3. A cached user: signed in at once, unverified, and the server check
  ///    runs in the background when the device is online.
  /// 4. No cached user but a cookie: asks the server (online only).
  Future<void> restore() => _restoring ??= _restore();

  Future<void> _restore() async {
    _setState(const SessionState.restoring());
    try {
      await _migration?.run();
      final cached = await _store.read();

      if (!await _hasSessionCookie()) {
        if (cached != null) await _store.clear();
        _setState(const SessionState.signedOut());
        return;
      }

      if (cached != null) {
        if (!_openScope(cached.id)) {
          _setState(const SessionState.signedOut());
          return;
        }
        _network.markSessionStarted();
        _setState(SessionState.signedIn(cached));
        if (_connectivity.isOnline) unawaited(revalidate());
        return;
      }

      await _restoreFromServer();
    } on Object catch (error, stackTrace) {
      _logger.error(
        'restore failed',
        name: _tag,
        error: error,
        stackTrace: stackTrace,
      );
      if (!_state.isResolved) _setState(const SessionState.signedOut());
    }
  }

  /// The cookie is there but no user is cached: the server knows who it is.
  Future<void> _restoreFromServer() async {
    if (!_connectivity.isOnline) {
      _setState(const SessionState.signedOut());
      return;
    }
    final result = await _auth.checkUser();
    final failure = result.leftOrNull;
    if (failure != null) {
      if (failure.isSessionExpired) await _clearCookies();
      _logger.info('restore: no session (${failure.code.name})', name: _tag);
    }
    final user = result.rightOrNull;
    if (user == null || !_openScope(user.id)) {
      _setState(const SessionState.signedOut());
      return;
    }
    await _store.write(user);
    _network.markSessionStarted();
    _setState(SessionState.signedIn(user, verified: true));
  }

  /// Asks the server whether the cached session still holds, and refreshes the
  /// cached user from the answer. [restore] starts it in the background;
  /// call it again to re-check (when the app returns from the background, say).
  ///
  /// A session the server rejects ends in `signedOut(expired: true)`. A failed
  /// check (offline, timeout, 5xx) changes nothing: the user keeps working on
  /// the cached data. Does nothing while the device is offline.
  Future<void> revalidate() {
    return _revalidating ??= _revalidate().whenComplete(
      () => _revalidating = null,
    );
  }

  Future<void> _revalidate() async {
    if (!_state.isSignedIn || !_connectivity.isOnline) return;
    final epoch = _epoch;
    final result = await _auth.checkUser();
    if (epoch != _epoch || !_state.isSignedIn) return;
    await result.fold(
      (failure) async {
        if (failure.isSessionExpired) {
          _expire();
        } else {
          _logger.info(
            'session check skipped (${failure.code.name})',
            name: _tag,
          );
        }
      },
      (user) async {
        await _store.write(user);
        if (epoch != _epoch || !_state.isSignedIn) return;
        _setState(
          SessionState.signedIn(user, verified: true),
          sameIdentity: true,
        );
      },
    );
  }

  // ---------------------------------------------------------------- sign in

  /// Logs in and starts the session.
  ///
  /// The answer of `/student/login` is not trusted alone: `checkUser` must
  /// confirm the session and gives the user. If any step fails, the cookie the
  /// login may have set is thrown away (and the server asked to log out, best
  /// effort), so a failed attempt leaves nothing behind.
  ///
  /// Failures: [AppErrorCode.unauthorized] for wrong credentials; offline,
  /// timeout, network and server errors as the repository reports them.
  Future<AppResult<UserDto>> signIn({
    required String username,
    required String password,
  }) async {
    final pending = _ending;
    if (pending != null) await pending;
    if (_signingIn || _state.isSignedIn) {
      return Left(
        AppException(
          code: AppErrorCode.unknown,
          message: _signingIn ? 'signIn already running' : 'already signed in',
        ),
      );
    }
    _signingIn = true;
    notifyListeners();
    try {
      return await _signIn(username, password);
    } finally {
      _signingIn = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<AppResult<UserDto>> _signIn(String username, String password) async {
    final login = await _auth.login(username: username, password: password);
    final loginFailure = login.leftOrNull;
    if (loginFailure != null) return Left(loginFailure);

    final check = await _auth.checkUser();
    final checked = check.rightOrNull;
    if (checked == null) {
      await _rollbackLogin();
      final cause = check.leftOrNull!;
      // A login the server accepted but then does not recognise as a session
      // is a failed login, not an expired session.
      return Left(
        cause.isSessionExpired
            ? AppException(
                code: AppErrorCode.unauthorized,
                message: 'Login accepted but checkUser found no session',
                statusCode: cause.statusCode,
                path: cause.path,
              )
            : cause,
      );
    }

    await _store.write(checked);
    try {
      await _enterScopeFor(checked);
    } on Object catch (error, stackTrace) {
      _logger.error(
        'session scope failed, rolling back',
        name: _tag,
        error: error,
        stackTrace: stackTrace,
      );
      await _rollbackLogin();
      await _store.clear();
      await _closeScope();
      return Left(AppException.from(error, stackTrace));
    }
    _network.markSessionStarted();
    _setState(SessionState.signedIn(checked, verified: true));
    return Right(checked);
  }

  /// Same user after an expired session keeps the open scope; anybody else
  /// starts from a clean one.
  Future<void> _enterScopeFor(UserDto user) async {
    final sameUser =
        _scopeOpen && _scopeUserId != null && _scopeUserId == user.id;
    if (sameUser) return;
    if (_scopeOpen) await _closeScope();
    _scopeUserId = user.id;
    // Marked open before the push: a push that fails half-way must still be
    // dropped by the rollback.
    _scopeOpen = true;
    _pushScope();
  }

  Future<void> _rollbackLogin() async {
    try {
      await _auth.logout().timeout(_logoutTimeout);
    } on Object catch (error) {
      _logger.info('rollback logout failed', name: _tag, error: error);
    }
    await _clearCookies();
  }

  // --------------------------------------------------------------- sign out

  /// Ends the session: the UI leaves at once, then the server is told (unless
  /// the device is offline; a failure never stops the cleanup), then the
  /// cookie, the cache, the legacy keys and the DI scope go.
  Future<void> signOut() => _end(remote: true);

  /// The local half of account deletion. The delete call is not made here (its
  /// endpoint belongs to the account screens); once it succeeded, this clears
  /// the same traces as [signOut] but does not call `/ajax/logout`, because the
  /// session no longer exists on the server.
  Future<void> completeAccountDeletion() => _end(remote: false);

  Future<void> _end({required bool remote}) {
    return _ending ??= _runEnd(remote: remote).whenComplete(() {
      _ending = null;
    });
  }

  Future<void> _runEnd({required bool remote}) async {
    final hadSession = _state.isSignedIn || _scopeOpen;
    // The screens go first, so their ViewModels are gone before the services
    // they hold are dropped.
    _setState(const SessionState.signedOut());
    if (remote && hadSession && _connectivity.isOnline) {
      try {
        await _auth.logout().timeout(_logoutTimeout);
      } on Object catch (error) {
        _logger.info('logout call failed', name: _tag, error: error);
      }
    }
    await _clearCookies();
    await _store.clear();
    await _closeScope();
    _logger.info('session ended', name: _tag);
  }

  // ------------------------------------------------------------ user updates

  /// Replaces the signed-in user after the account screens changed it, and
  /// caches it. Ignored when nobody is signed in.
  Future<void> updateUser(UserDto user) async {
    final current = _state;
    if (current is! SessionSignedIn) return;
    final epoch = _epoch;
    await _store.write(user);
    if (epoch != _epoch || !_state.isSignedIn) return;
    _setState(
      SessionState.signedIn(user, verified: current.verified),
      sameIdentity: true,
    );
  }

  /// Reloads the user with `checkUser`. A session the server no longer knows
  /// fails with [AppErrorCode.sessionExpired] (and `NetworkService` reports it
  /// to this manager, which flips the state).
  Future<AppResult<UserDto>> refreshUser() async {
    if (!_state.isSignedIn) {
      return const Left(
        AppException(
          code: AppErrorCode.sessionExpired,
          message: 'refreshUser without a session',
        ),
      );
    }
    final result = await _auth.checkUser();
    final user = result.rightOrNull;
    if (user != null) await updateUser(user);
    return result;
  }

  // ----------------------------------------------------------------- expiry

  void _onSessionExpired(SessionExpiredEvent event) {
    if (_signingIn || _ending != null) return;
    if (!_state.isSignedIn) return;
    _logger.info('session expired at ${event.path}', name: _tag);
    _expire();
  }

  void _expire() {
    if (!_state.isSignedIn) return;
    _setState(const SessionState.signedOut(expired: true));
  }

  // --------------------------------------------------------------- internals

  Future<bool> _hasSessionCookie() async {
    try {
      final cookies = await _network.cookieJar.loadForRequest(_apiBaseUri);
      return cookies.isNotEmpty;
    } on Object catch (error) {
      // An unreadable jar is not proof of "no session".
      _logger.warning('cookie jar unreadable', name: _tag, error: error);
      return true;
    }
  }

  Future<void> _clearCookies() async {
    try {
      await _network.cookieJar.deleteAll();
    } on Object catch (error) {
      _logger.warning('cookie jar not cleared', name: _tag, error: error);
    }
  }

  bool _openScope(String? userId) {
    if (_scopeOpen) return true;
    _scopeUserId = userId;
    _scopeOpen = true;
    try {
      _pushScope();
      return true;
    } on Object catch (error, stackTrace) {
      _logger.error(
        'session scope failed',
        name: _tag,
        error: error,
        stackTrace: stackTrace,
      );
      unawaited(_closeScope());
      return false;
    }
  }

  Future<void> _closeScope() async {
    if (!_scopeOpen) return;
    _scopeOpen = false;
    _scopeUserId = null;
    try {
      await _popScope();
    } on Object catch (error, stackTrace) {
      _logger.error(
        'session scope not dropped',
        name: _tag,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _setState(SessionState next, {bool sameIdentity = false}) {
    if (next == _state || _disposed) return;
    if (!sameIdentity) _epoch++;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_expirySubscription.cancel());
    super.dispose();
  }
}
