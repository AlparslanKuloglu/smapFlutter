import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/core/config/feature_flags.dart';

/// The Hesap tab's settings screens of E14b (pano 9.3 to 9.6; spec §3.6;
/// flow 13.10), for the coordinator to merge.
///
/// [accountSettingsTabRoutes] are siblings of the Hesap screen inside the
/// shell's `AccountTabRoute` (`path: 'account'`), so they are pushed on the
/// tab's own stack and keep the bottom bar:
///
/// | path (under `/account`) | screen |
/// |---|---|
/// | `password` | `PasswordView` (only while `FeatureFlags.passwordChangeEnabled`) |
/// | `coaching` | `CoachingView` (student only) |
/// | `notifications` | `NotificationsView` |
/// | `delete` | `AccountDeletionView` (the explanation; opened from Profil) |
///
/// [accountSettingsRootRoutes] cover the shell and its bottom bar, for
/// `AppRouter.routes` at the root (pano 9.4 kare 4 and 5: "tam ekran, sekme
/// kabuğunun dışında"): `/account/delete/progress` (`AccountDeletionProgressView`,
/// back closed) and `/account/delete/done` (`AccountDeletionDoneView`, back
/// closed). They are pushed, never deep-linked; list them **before** the
/// shells so `/account/delete/progress` is not read as a child of
/// `/account`.
///
/// Neither screen of the coach's shell uses these routes, except
/// `NotificationsRoute` (the coach's Hesap has the same row), which the
/// coordinator adds to the coach's `CoachAccountTabRoute` children too.
List<AutoRoute> get accountSettingsTabRoutes => [
  if (FeatureFlags.passwordChangeEnabled)
    AutoRoute(page: PasswordRoute.page, path: 'password'),
  AutoRoute(page: CoachingRoute.page, path: 'coaching'),
  AutoRoute(page: NotificationsRoute.page, path: 'notifications'),
  AutoRoute(page: AccountDeletionRoute.page, path: 'delete'),
];

/// The full-screen routes of "Hesabı sil"; see [accountSettingsTabRoutes].
List<AutoRoute> get accountSettingsRootRoutes => [
  AutoRoute(
    page: AccountDeletionProgressRoute.page,
    path: '/account/delete/progress',
  ),
  AutoRoute(page: AccountDeletionDoneRoute.page, path: '/account/delete/done'),
];
