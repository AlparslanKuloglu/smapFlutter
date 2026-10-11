import 'package:flutter/foundation.dart';

import 'package:smap/app/router/guards/route_access.dart';
import 'package:smap/features/auth/domain/session_state.dart';

/// Wakes the router when the session changes in a way the guards care about
/// (`AutoRouterDelegate.reevaluateListenable`).
///
/// `SessionManager` notifies on every change, also for a sign-in's busy flag;
/// re-running the guards each time would be wasted work and could race with a
/// navigation in flight. This forwards a change only when the
/// [SessionRouteKey] of the state changed: signed in or out, expired, decided
/// for the first time, a different role.
class RouteRefresh extends ChangeNotifier {
  RouteRefresh(ValueListenable<SessionState> session) : _session = session {
    _key = SessionRouteKey.of(session.value);
    session.addListener(_onSession);
  }

  final ValueListenable<SessionState> _session;
  late SessionRouteKey _key;

  void _onSession() {
    final next = SessionRouteKey.of(_session.value);
    if (next == _key) return;
    _key = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _session.removeListener(_onSession);
    super.dispose();
  }
}
