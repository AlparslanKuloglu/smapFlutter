import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';

/// The card deck's route (pano 8.1 and 8.2; spec §3.6), for `shell_routes.dart`
/// to put in the Derslerim tab's stack (`LessonsTabRoute`, `path: 'lessons'`):
///
/// | path (under `/lessons`) | screen |
/// |---|---|
/// | `deck?lessonId=&examId=&group=eksik\|bildik\|favori` | `CardDeckView` |
///
/// The route is a child of the Derslerim tab, so the bottom bar stays with
/// Derslerim selected, and it **must be listed before `:lessonId`** of
/// `lessonsTabRoutes`, or "deck" is read as a lesson id.
List<AutoRoute> get cardsTabRoutes => [
  AutoRoute(page: CardDeckRoute.page, path: 'deck'),
];
