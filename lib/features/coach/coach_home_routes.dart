import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';

/// The routes of the coach home (pano 10.1 kare 1 to 4; spec §3.6
/// `/coach/home`), merged by the coordinator into the Anasayfa tab's stack in
/// `shellRoutes`:
///
/// ```dart
/// AutoRoute(
///   page: CoachHomeTabRoute.page,
///   path: 'home',
///   children: coachHomeTabRoutes,
/// ),
/// ```
///
/// [CoachHomeRoute] is the tab's root (`initial: true`). The screens opened
/// from it (a student's profile, a meeting's detail) live in the tabs they
/// belong to (Öğrencilerim, Görüşmelerim) and are opened there.
///
/// The coach home has no full-screen route of its own (the add-student sheet
/// is a sheet, the scan flow is the shell's), so there is no
/// `coachHomeRootRoutes`.
List<AutoRoute> get coachHomeTabRoutes => [
  AutoRoute(page: CoachHomeRoute.page, initial: true),
];
