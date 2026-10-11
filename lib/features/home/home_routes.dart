import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';

/// The routes of the student home (pano 3.1 to 3.3; spec §3.6 `/home`),
/// merged by the coordinator into the Anasayfa tab's stack in `shellRoutes`:
///
/// ```dart
/// AutoRoute(
///   page: HomeTabRoute.page,
///   path: 'home',
///   children: homeTabRoutes,
/// ),
/// ```
///
/// [HomeRoute] is the tab's root (`initial: true`). The screens opened from it
/// (Programım, Deneme Detay, Ders Detayı, Konu Detayı) are other tasks' routes
/// and join this stack in their own lists; until they land the home screen
/// opens the legacy ones (`LegacyLinksE6`).
///
/// Anasayfa has no full-screen route of its own (the scan flow is the
/// shell's), so there is no `homeRootRoutes`.
List<AutoRoute> get homeTabRoutes => [
  AutoRoute(page: HomeRoute.page, initial: true),
];
