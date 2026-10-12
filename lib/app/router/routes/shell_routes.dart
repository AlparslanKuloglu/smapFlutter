import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/features/account/account_routes.dart';
import 'package:smap/features/account/account_settings_routes.dart';
import 'package:smap/features/cards/cards_routes.dart';
import 'package:smap/features/exams/exams_routes.dart';
import 'package:smap/features/analytics/analytics_routes.dart';
import 'package:smap/features/home/home_routes.dart';
import 'package:smap/features/lessons/lessons_routes.dart';
import 'package:smap/features/schedule/schedule_routes.dart';

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
        children: [...homeTabRoutes, ...scheduleHomeTabRoutes],
      ),
      AutoRoute(
        page: AnalyticsTabRoute.page,
        path: 'analytics',
        children: [...analyticsTabRoutes, ...examsAnalyticsTabRoutes],
      ),
      AutoRoute(
        page: LessonsTabRoute.page,
        path: 'lessons',
        // The deck's fixed path comes before `:lessonId` (E13).
        children: [...cardsTabRoutes, ...lessonsTabRoutes],
      ),
      AutoRoute(
        page: AccountTabRoute.page,
        path: 'account',
        children: [...accountTabRoutes, ...accountSettingsTabRoutes],
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
        // A coach has no Koçluk, Şifre or Hesabı Sil rows yet (spec §6.5 #6).
        children: [
          ...accountTabRoutes,
          AutoRoute(page: NotificationsRoute.page, path: 'notifications'),
        ],
      ),
    ],
  ),
  AutoRoute(page: LegacyScanRoute.page, path: '/scan'),
];
