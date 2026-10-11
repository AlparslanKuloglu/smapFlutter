import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';

/// The routes of the intro flow and the welcome screen (pano 2.1 kare 2-4,
/// 2.2; flow 13.1), merged into `AppRouter.routes`.
///
/// `/onboarding/intro` is one route (`OnboardingView`) whose inner steps are
/// the three intro pages, role, grade and track, and the camera primer; the
/// spec's `/onboarding/role`, `/onboarding/grade` and `/onboarding/camera`
/// are steps of it, not routes (one back stack for the flow, the picks and
/// the step survive a closed app in the draft). `/welcome` is its own route:
/// a sign-out or an account deletion comes back to it.
///
/// Both fade in over 250 ms like the other root flows (`fadeRouteType`).
List<AutoRoute> get onboardingRoutes => [
  AutoRoute(
    page: OnboardingRoute.page,
    path: '/onboarding/intro',
    type: fadeRouteType,
  ),
  AutoRoute(page: WelcomeRoute.page, path: '/welcome', type: fadeRouteType),
];
