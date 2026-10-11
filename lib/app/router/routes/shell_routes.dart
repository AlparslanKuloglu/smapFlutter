import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';

/// The two shells with their tab stacks, and the full-screen scan page, merged
/// into `AppRouter.routes`.
///
/// Paths follow spec §3.6: the student's tabs are `/home`, `/analytics`,
/// `/lessons` and `/account` (the shell is the empty prefix `/`, so it shares
/// no page of its own), the coach's `/coach/home`, `/coach/students`,
/// `/coach/meetings` and `/coach/account`. Each tab is an empty shell page
/// that holds the tab's own stack; the screen the tab shows is its `initial`
/// child. Today they are the legacy screens (`Legacy…TabRoute`); a screen
/// task swaps the `page:` of its tab's child and adds the tab's detail screens
/// as siblings of it.
///
/// `/scan` is on the root stack, a sibling of the shells, so it covers the
/// shell and the bottom bar (spec §3.2). The shells are guarded by their
/// route group (`AppRouter.groupOf`); the tab and scan routes are not.
List<AutoRoute> get shellRoutes => [
  AutoRoute(
    page: StudentShellRoute.page,
    path: '/',
    type: fadeRouteType,
    children: [
      AutoRoute(
        page: HomeTabRoute.page,
        path: 'home',
        children: [AutoRoute(page: LegacyHomeTabRoute.page, initial: true)],
      ),
      AutoRoute(
        page: AnalyticsTabRoute.page,
        path: 'analytics',
        children: [
          AutoRoute(page: LegacyAnalyticsTabRoute.page, initial: true),
        ],
      ),
      AutoRoute(
        page: LessonsTabRoute.page,
        path: 'lessons',
        children: [AutoRoute(page: LegacyLessonsTabRoute.page, initial: true)],
      ),
      AutoRoute(
        page: AccountTabRoute.page,
        path: 'account',
        children: [AutoRoute(page: LegacyAccountTabRoute.page, initial: true)],
      ),
    ],
  ),
  AutoRoute(
    page: CoachShellRoute.page,
    path: '/coach',
    type: fadeRouteType,
    children: [
      AutoRoute(
        page: CoachHomeTabRoute.page,
        path: 'home',
        children: [
          AutoRoute(page: LegacyCoachHomeTabRoute.page, initial: true),
        ],
      ),
      AutoRoute(
        page: CoachStudentsTabRoute.page,
        path: 'students',
        children: [AutoRoute(page: LegacyStudentsTabRoute.page, initial: true)],
      ),
      AutoRoute(
        page: CoachMeetingsTabRoute.page,
        path: 'meetings',
        children: [AutoRoute(page: LegacyMeetingsTabRoute.page, initial: true)],
      ),
      AutoRoute(
        page: CoachAccountTabRoute.page,
        path: 'account',
        children: [
          AutoRoute(page: LegacyCoachAccountTabRoute.page, initial: true),
        ],
      ),
    ],
  ),
  AutoRoute(page: LegacyScanRoute.page, path: '/scan'),
];
