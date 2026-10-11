import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';

/// The routes of the Derslerim tab (pano 7.1 to 7.6; spec §3.6), for
/// `shell_routes.dart` to put under `LessonsTabRoute` (`path: 'lessons'`):
///
/// | path (under `/lessons`) | screen |
/// |---|---|
/// | `` (initial) | `LessonsView` (Derslerim) |
/// | `:lessonId?cat=&eksik=&section=` | `LessonDetailView` |
/// | `:lessonId/topics/:topicId?cat=&focus=` | `TopicDetailView` |
///
/// The card deck (`/lessons/deck`, E13) must be listed **before**
/// `:lessonId`, or "deck" is read as a lesson id.
List<AutoRoute> get lessonsTabRoutes => [
  AutoRoute(page: LessonsRoute.page, initial: true),
  AutoRoute(page: LessonDetailRoute.page, path: ':lessonId'),
  AutoRoute(page: TopicDetailRoute.page, path: ':lessonId/topics/:topicId'),
];
