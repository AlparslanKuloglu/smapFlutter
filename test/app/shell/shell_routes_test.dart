import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/app/router/app_router.dart';
import 'package:smap/app/shell/coach_shell_view.dart';
import 'package:smap/app/shell/shell_preview.dart';
import 'package:smap/app/shell/student_shell_view.dart';
import 'package:smap/core/domain/user_role.dart';
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

  /// The route names a path resolves to, outermost first.
  List<String> namesOf(String path) {
    final matches = router.matcher.match(path);
    expect(matches, isNotNull, reason: path);
    final names = <String>[];
    for (
      List<RouteMatch>? level = matches;
      level != null && level.isNotEmpty;
      level = level.first.children
    ) {
      names.add(level.first.name);
    }
    return names;
  }

  group('student tabs (spec §3.6)', () {
    test('/home, /analytics, /lessons and /account', () {
      expect(namesOf('/home'), [
        StudentShellRoute.name,
        HomeTabRoute.name,
        HomeRoute.name,
      ]);
      expect(namesOf('/analytics'), [
        StudentShellRoute.name,
        AnalyticsTabRoute.name,
        AnalyticsRoute.name,
      ]);
      expect(namesOf('/lessons'), [
        StudentShellRoute.name,
        LessonsTabRoute.name,
        LessonsRoute.name,
      ]);
      expect(namesOf('/account'), [
        StudentShellRoute.name,
        AccountTabRoute.name,
        LegacyAccountTabRoute.name,
      ]);
    });

    test('the shell lists the same four tabs in bar order', () {
      expect(StudentShellView.tabs.map((tab) => tab.route.routeName), [
        HomeTabRoute.name,
        AnalyticsTabRoute.name,
        LessonsTabRoute.name,
        AccountTabRoute.name,
      ]);
    });
  });

  group('coach tabs (spec §3.6)', () {
    test('/coach/home, /coach/students, /coach/meetings, /coach/account', () {
      expect(namesOf('/coach/home'), [
        CoachShellRoute.name,
        CoachHomeTabRoute.name,
        LegacyCoachHomeTabRoute.name,
      ]);
      expect(namesOf('/coach/students'), [
        CoachShellRoute.name,
        CoachStudentsTabRoute.name,
        LegacyStudentsTabRoute.name,
      ]);
      expect(namesOf('/coach/meetings'), [
        CoachShellRoute.name,
        CoachMeetingsTabRoute.name,
        LegacyMeetingsTabRoute.name,
      ]);
      expect(namesOf('/coach/account'), [
        CoachShellRoute.name,
        CoachAccountTabRoute.name,
        LegacyCoachAccountTabRoute.name,
      ]);
    });

    test('the shell lists the same four tabs in bar order', () {
      expect(CoachShellView.tabs.map((tab) => tab.route.routeName), [
        CoachHomeTabRoute.name,
        CoachStudentsTabRoute.name,
        CoachMeetingsTabRoute.name,
        CoachAccountTabRoute.name,
      ]);
    });
  });

  test('the scan flow is a root page, not a tab', () {
    expect(namesOf('/scan'), [LegacyScanRoute.name]);
    final tabs = [
      ...StudentShellView.tabs,
      ...CoachShellView.tabs,
    ].map((tab) => tab.route.routeName);
    expect(tabs, isNot(contains(LegacyScanRoute.name)));
  });

  test('the launch screen keeps "/"', () {
    expect(namesOf('/'), [StartupRoute.name]);
  });

  test('the tab stacks are in no guard group (only the shells are)', () {
    expect(router.groupOf(HomeTabRoute.name), RouteGroup.other);
    expect(router.groupOf(CoachStudentsTabRoute.name), RouteGroup.other);
    expect(router.groupOf(LegacyScanRoute.name), RouteGroup.other);
  });

  group('ShellPreview', () {
    test('names the two roles and nothing else', () {
      expect(ShellPreview.parse('student'), UserRole.student);
      expect(ShellPreview.parse('coach'), UserRole.coach);
      expect(ShellPreview.parse(''), isNull);
      expect(ShellPreview.parse('admin'), isNull);
    });

    test('is off without the define', () {
      expect(ShellPreview.role, isNull);
      expect(ShellPreview.active, isFalse);
    });
  });
}
