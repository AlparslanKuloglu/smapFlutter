import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/services/session_manager.dart';

/// The few places where a legacy screen used a named route
/// (`Navigator.pushNamed('/login')`), which `MaterialApp.router` does not
/// have. The legacy call sites call these instead; each one is a single line
/// there.
abstract final class LegacyNavigation {
  /// The legacy intro finished and its flag is saved: on to the sign-in.
  ///
  /// Replaces the whole stack, so the intro cannot be reached with Back.
  static Future<void> afterOnboarding(BuildContext context) =>
      context.router.root.replaceAll([const WelcomeRoute()]);

  /// The account was deleted on the server: clear the session. The router's
  /// auth guard then takes the user to the welcome screen.
  static void afterAccountDeleted() =>
      unawaited(locator<SessionManager>().completeAccountDeletion());
}
