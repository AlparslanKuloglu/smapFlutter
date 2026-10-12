import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';

/// The routes of the coach's Öğrencilerim tab (pano 10.2; spec §3.6
/// `/coach/students`), for `shell_routes.dart` to put under
/// `CoachStudentsTabRoute` (`path: 'students'`) in place of
/// `LegacyStudentsTabRoute`:
///
/// | path (under `/coach/students`) | screen |
/// |---|---|
/// | `` (initial) | `StudentsView` (Öğrencilerim) |
///
/// "Öğrenci Ekle" (pano 10.3) is a sheet, not a route. E17 adds
/// `:studentId` (Öğrenci Profili) and its children as siblings of this one;
/// until then a student opens the legacy analysis screen
/// (`legacy_links_e16.dart`).
///
/// ```dart
/// AutoRoute(
///   page: CoachStudentsTabRoute.page,
///   path: 'students',
///   children: coachStudentsTabRoutes,
/// ),
/// ```
///
/// The tab shows its own band, so its `ShellTabSpec` in `CoachShellView` is
/// `content: ShellTabContent.screen`.
List<AutoRoute> get coachStudentsTabRoutes => [
  AutoRoute(page: StudentsRoute.page, initial: true),
];
