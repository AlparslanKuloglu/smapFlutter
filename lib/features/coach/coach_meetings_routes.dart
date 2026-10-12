import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';

/// The routes of the coach's Görüşmelerim tab (pano 10.5 and 10.6; spec §3.6
/// `/coach/meetings`, `/coach/meetings/:meetingId`; flow 13.11), for
/// `shell_routes.dart` to put under `CoachMeetingsTabRoute`
/// (`path: 'meetings'`):
///
/// ```dart
/// AutoRoute(
///   page: CoachMeetingsTabRoute.page,
///   path: 'meetings',
///   children: coachMeetingsTabRoutes,
/// ),
/// ```
///
/// | path (under `/coach/meetings`) | screen |
/// |---|---|
/// | `` (initial) | `MeetingsView` (Görüşmelerim) |
/// | `:meetingId` | `MeetingDetailView` |
///
/// `MeetingDetailRoute` also carries the `meeting` the list has
/// (`MeetingEntry`, not in the path); a deep link without it finds the
/// meeting in the list. "Yeni görüşme" and the note sheet are sheets, not
/// routes. The tab's entry in `CoachShellView.tabs` becomes
/// `ShellTabContent.screen`.
///
/// Nothing in this feature is a full-screen route, so there are no root
/// routes.
List<AutoRoute> get coachMeetingsTabRoutes => [
  AutoRoute(page: MeetingsRoute.page, initial: true),
  AutoRoute(page: MeetingDetailRoute.page, path: ':meetingId'),
];
