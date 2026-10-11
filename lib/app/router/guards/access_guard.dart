import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';

import 'package:smap/app/router/guards/route_access.dart';
import 'package:smap/app/router/guards/route_catalog.dart';
import 'package:smap/core/services/app_logger.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/auth/domain/session_state.dart';

/// One stage of the guard chain (Onboarding > Auth > Role): reads the target
/// route's group, the intro flag and the session, asks its stage function and
/// carries the verdict out.
///
/// Decisions are made against the **target** route
/// (`NavigationResolver.route`), never `router.current`: comparing with the
/// current route makes a guard fire on its own redirect.
abstract class AccessGuard extends AutoRouteGuard {
  const AccessGuard({
    required this.catalog,
    required this.session,
    required this.preferences,
    required this.stage,
    required this.name,
    this.logger,
  });

  final RouteCatalog catalog;

  /// The session state, read when a navigation arrives
  /// (`() => sessionManager.state`).
  final ValueGetter<SessionState> session;
  final DevicePreferences preferences;

  /// The stage function of `route_access.dart`.
  final AccessDecision Function(AccessInput input) stage;

  /// For the log line of a redirect.
  final String name;
  final AppLogger? logger;

  @override
  Future<void> onNavigation(
    NavigationResolver resolver,
    StackRouter router,
  ) async {
    final root = router.root;
    final input = AccessInput(
      group: catalog.groupOf(resolver.route.name),
      onboardingSeen:
          preferences.getBool(DevicePreferences.onboardingCompletedKey) ??
          false,
      session: session(),
      shellInStack: root.stack.any(
        (page) => switch (catalog.groupOf(page.routeData.name)) {
          RouteGroup.studentShell || RouteGroup.coachShell => true,
          _ => false,
        },
      ),
    );
    switch (stage(input)) {
      case AccessAllow():
        resolver.next();
      case AccessReject():
        logger?.info(
          'reject ${resolver.route.name} (${input.session})',
          name: name,
        );
        resolver.next(false);
      case AccessRedirect(:final target):
        logger?.info(
          'redirect ${resolver.route.name} -> ${target.name}',
          name: name,
        );
        resolver.next(false);
        await root.replaceAll([catalog.pageFor(target)]);
    }
  }
}
