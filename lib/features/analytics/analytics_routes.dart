import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';

/// The Analizlerim tab's routes (pano 6.1 to 6.4; spec §3.6
/// `/analytics?tab=genel|denemelerim`), for the coordinator to merge into the
/// student shell.
///
/// [analyticsTabRoutes] are the children of the shell's `AnalyticsTabRoute`
/// (the tab's own stack): the screen is its `initial` child, so a tab tap
/// opens it and the screens opened from it (the exam detail) are pushed on
/// the same stack and keep the bottom bar. `?tab=denemelerim` selects the
/// second tab (`AnalyticsRoute(tab: 'denemelerim')`).
///
/// Nothing in this feature is a full-screen route, so there are no root
/// routes.
List<AutoRoute> get analyticsTabRoutes => [
  AutoRoute(page: AnalyticsRoute.page, initial: true),
];
