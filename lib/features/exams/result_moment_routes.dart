import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';

/// The result moment's route (pano 5.1; spec §3.6), for the coordinator to
/// merge into the root list of `AppRouter.routes` (it covers the shell and
/// the bottom bar, like `/scan`, and is a sibling of the shells, not a tab
/// child).
///
/// | path | screen |
/// |---|---|
/// | `/scan/result/:examId` | `ResultMomentView` |
///
/// The camera flow pushes it on the root stack once a read has recognized the
/// exam (`ResultMomentRoute(examId: ...)`). The notification permission sheet
/// (pano 5.2) is not a route: the screen opens it with `AppSheet`.
///
/// There are no tab children in this feature.
List<AutoRoute> get resultMomentRootRoutes => [
  AutoRoute(page: ResultMomentRoute.page, path: '/scan/result/:examId'),
];
