import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:smap/features/auth/data/dtos/user_dto.dart';
import 'package:smap/features/auth/domain/session_state.dart';
import 'package:smap/features/shared/presentation/provider/user_provider.dart';

/// Keeps the legacy `UserProvider` in step with the session
/// (`SessionManager`), from the outside: the provider file is not touched.
///
/// - A signed-in user: `loadUserData()` (it reads the plain `user_data` copy
///   that `SessionStore` mirrors while `kMirrorLegacyUserData` is on). If the
///   copy is missing, [restoreMirror] writes it first and the load runs
///   again.
/// - The user signed out (not an expired session: the screens behind the
///   "oturum bitti" sheet keep their data): `clearUserData()` and
///   [onSignedOut], which the legacy scope uses to drop the other legacy
///   providers' data.
///
/// The state is a `ValueListenable`, so a test drives it with a plain
/// `ValueNotifier`.
class LegacyUserBridge {
  LegacyUserBridge({
    required ValueListenable<SessionState> session,
    required UserProvider userProvider,
    required this.restoreMirror,
    this.onSignedOut,
  }) : _session = session,
       _userProvider = userProvider;

  final ValueListenable<SessionState> _session;
  final UserProvider _userProvider;

  /// Writes the legacy plain copy of [UserDto] (`SessionStore.write`).
  final Future<void> Function(UserDto user) restoreMirror;

  /// Called once per sign-out.
  final VoidCallback? onSignedOut;

  UserDto? _loaded;
  bool _started = false;

  /// Follows the session from now on; applies the current state at once.
  void start() {
    if (_started) return;
    _started = true;
    _session.addListener(_sync);
    _sync();
  }

  void _sync() {
    switch (_session.value) {
      case SessionSignedIn(:final user):
        if (_loaded == user) return;
        _loaded = user;
        unawaited(_load(user));
      case SessionSignedOut(expired: false):
        if (_loaded == null) return;
        _loaded = null;
        _userProvider.clearUserData();
        onSignedOut?.call();
      case SessionSignedOut():
      case SessionUnknown():
      case SessionRestoring():
        break;
    }
  }

  Future<void> _load(UserDto user) async {
    await _userProvider.loadUserData();
    if (_userProvider.user == null) {
      await restoreMirror(user);
      await _userProvider.loadUserData();
    }
  }

  void dispose() {
    if (_started) _session.removeListener(_sync);
    _started = false;
  }
}
