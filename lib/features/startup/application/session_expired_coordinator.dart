import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:smap/features/auth/domain/session_state.dart';

/// Runs the "Oturumun sona erdi" flow (pano 2.7 kare 2; spec §3.5).
///
/// When the session turns `signedOut(expired: true)` (a call that needs the
/// session got a 401; `NetworkService.onSessionExpired` reaches this through
/// `SessionManager`), the sheet opens above whatever screen the user is on.
/// Its only button opens the sign-in over that screen; when the sign-in
/// succeeds the router closes it (the auth guard) and the user is back where
/// they were. If they leave the sign-in without signing in, the sheet asks
/// again.
///
/// The coordinator holds no widgets: the app wires [showSheet] and
/// [openSignIn] (`SessionExpiredSheet.show`, `router.push(LoginRoute())`).
class SessionExpiredCoordinator {
  SessionExpiredCoordinator({
    required ValueListenable<SessionState> session,
    required this.showSheet,
    required this.openSignIn,
  }) : _session = session;

  final ValueListenable<SessionState> _session;

  /// Shows the sheet; completes with `true` when "Giriş Yap" was pressed and
  /// `false` when the sheet could not open.
  final Future<bool> Function() showSheet;

  /// Opens the sign-in over the current screen; completes when it closes.
  final Future<void> Function() openSignIn;

  bool _running = false;
  bool _started = false;

  /// Whether the flow is on screen now (the sheet or the sign-in over it).
  bool get isRunning => _running;

  /// Starts listening. Safe to call twice.
  void start() {
    if (_started) return;
    _started = true;
    _session.addListener(_onSession);
    _onSession();
  }

  void _onSession() {
    if (_running || !_session.value.isExpired) return;
    unawaited(_run());
  }

  Future<void> _run() async {
    _running = true;
    try {
      while (_session.value.isExpired) {
        final pressed = await showSheet();
        if (!pressed || !_session.value.isExpired) return;
        await openSignIn();
      }
    } finally {
      _running = false;
    }
  }

  void dispose() {
    if (_started) _session.removeListener(_onSession);
    _started = false;
  }
}
