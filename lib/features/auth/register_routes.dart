import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';

/// The sign-up route (pano 2.5, 2.6), merged into `AppRouter.routes`.
///
/// `RegisterRoute` takes the role, grade and track the welcome screens
/// collected (`RegisterRoute(role: …, grade: …, track: …)`); all optional.
/// The guards treat it as a signed-out door (`RouteGroup.signedOutEntry`).
List<AutoRoute> get registerRoutes => [
  AutoRoute(page: RegisterRoute.page, path: '/auth/register'),
];
