import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';

/// The two shells and what they hold, merged into `AppRouter.routes`.
///
/// Paths follow spec §3.6: `/home` for the student shell, `/coach/home` for
/// the coach shell. Each shell has one tab for now, the legacy app; E5
/// replaces the `children` with the four tabs of the role.
List<AutoRoute> get shellRoutes => [
  AutoRoute(
    page: StudentShellRoute.page,
    path: '/home',
    type: fadeRouteType,
    children: [AutoRoute(page: LegacyStudentRootRoute.page, initial: true)],
  ),
  AutoRoute(
    page: CoachShellRoute.page,
    path: '/coach/home',
    type: fadeRouteType,
    children: [AutoRoute(page: LegacyCoachRootRoute.page, initial: true)],
  ),
];
