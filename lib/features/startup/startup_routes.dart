import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';

/// The routes of the launch and the general screens (pano 2.1 kare 1, 2.7),
/// merged into `AppRouter.routes`.
///
/// The three stop screens and the shells fade in over 250 ms ("hazır olunca
/// 250 ms geçiş", pano 2.1 kare 1); see `fadeRouteType` in `app_router.dart`.
List<AutoRoute> get startupRoutes => [
  AutoRoute(page: StartupRoute.page, path: '/', initial: true),
  AutoRoute(
    page: ForceUpdateRoute.page,
    path: '/blocking/force-update',
    type: fadeRouteType,
  ),
  AutoRoute(
    page: MaintenanceRoute.page,
    path: '/blocking/maintenance',
    type: fadeRouteType,
  ),
  AutoRoute(
    page: UnknownRoleRoute.page,
    path: '/blocking/unknown-role',
    type: fadeRouteType,
  ),
];
