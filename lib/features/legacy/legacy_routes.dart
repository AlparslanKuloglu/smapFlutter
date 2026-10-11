import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';

/// The signed-out doors, still the legacy screens (intro, sign-in card),
/// merged into `AppRouter.routes`. E2 (intro, role, welcome), E3 (sign-in) and
/// E4 (sign-up) swap the `page:` of their route for the new view.
List<AutoRoute> get legacyAuthRoutes => [
  AutoRoute(
    page: OnboardingRoute.page,
    path: '/onboarding/intro',
    type: fadeRouteType,
  ),
  AutoRoute(page: WelcomeRoute.page, path: '/welcome', type: fadeRouteType),
  AutoRoute(page: LoginRoute.page, path: '/auth/login'),
  AutoRoute(page: RegisterRoute.page, path: '/auth/register'),
];
