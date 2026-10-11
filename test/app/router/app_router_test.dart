import 'package:flutter_test/flutter_test.dart';
import 'package:smap/app/router/app_router.dart';
import 'package:smap/app/router/guards/route_access.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/auth/domain/session_state.dart';

// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late AppRouter router;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    router = AppRouter(
      session: () => const SessionState.signedOut(),
      preferences: await DevicePreferences.load(),
    );
  });

  test('every redirect target is a route of the router', () {
    final names = {for (final route in router.routes) route.name};

    for (final target in RouteTarget.values) {
      expect(
        names,
        contains(router.pageFor(target).routeName),
        reason: target.name,
      );
    }
  });

  test('every redirect target lands in the group the guards expect', () {
    const expected = {
      RouteTarget.onboarding: RouteGroup.onboarding,
      RouteTarget.welcome: RouteGroup.signedOutEntry,
      RouteTarget.studentShell: RouteGroup.studentShell,
      RouteTarget.coachShell: RouteGroup.coachShell,
      RouteTarget.unknownRole: RouteGroup.unknownRole,
      RouteTarget.forceUpdate: RouteGroup.blocking,
      RouteTarget.maintenance: RouteGroup.blocking,
    };

    for (final target in RouteTarget.values) {
      expect(
        router.groupOf(router.pageFor(target).routeName),
        expected[target],
        reason: target.name,
      );
    }
  });

  test('the doors and the launch screen are classified', () {
    expect(router.groupOf(StartupRoute.name), RouteGroup.startup);
    expect(router.groupOf(LoginRoute.name), RouteGroup.signedOutEntry);
    expect(router.groupOf(RegisterRoute.name), RouteGroup.signedOutEntry);
    expect(router.groupOf(LegacyHomeTabRoute.name), RouteGroup.other);
  });

  test('guards run in the order onboarding, auth, role', () {
    expect(router.guards.map((guard) => guard.runtimeType.toString()), [
      'OnboardingGuard',
      'AuthGuard',
      'RoleGuard',
    ]);
  });

  test('the launch screen is the initial route at "/"', () {
    final initial = router.routes.firstWhere((route) => route.initial);

    expect(initial.name, StartupRoute.name);
    expect(initial.path, '/');
  });
}
