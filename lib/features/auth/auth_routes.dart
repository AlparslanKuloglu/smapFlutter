import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/core/config/feature_flags.dart';

/// The routes of the sign-in screens (pano 2.3, 2.4), merged into
/// `AppRouter.routes`.
///
/// - `/auth/login`: Giriş. The sign-up screen (`RegisterRoute`) is E4's.
/// - `/auth/forgot-password`: Şifremi Unuttum. Listed only while
///   `FeatureFlags.forgotPasswordEnabled` is on, so a closed flow cannot be
///   reached by a link or a stray push either; the link on the sign-in screen
///   is hidden by the same flag.
///
/// Both are signed-out screens: `LoginRoute` is in the guards' `signedOutEntry`
/// group, so a signed-in account never sees it, and a sign-in opened over the
/// screens of an expired session closes itself when it succeeds.
List<AutoRoute> get authRoutes => [
  AutoRoute(page: LoginRoute.page, path: '/auth/login'),
  if (FeatureFlags.forgotPasswordEnabled)
    AutoRoute(page: ForgotPasswordRoute.page, path: '/auth/forgot-password'),
];
