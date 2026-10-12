import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';

/// The routes of the exam screens (pano 5.3 to 5.10; spec §3.6), for the
/// coordinator to merge into the Analizlerim tab's stack: they are siblings of
/// `AnalyticsRoute` in `analyticsTabRoutes`, so the screens are pushed on the
/// tab's own stack, keep the bottom bar and Back returns to the list.
///
/// | path (under `/analytics`) | screen |
/// |---|---|
/// | `exam/:examId?tab=genel\|sorular\|konular\|kartlar` | `ExamDetailView` |
/// | `exam/:examId/question?lesson=&q=` | `QuestionDetailView` |
///
/// `ExamDetailRoute` also carries two arguments that are not in the path: the
/// `student` a coach looks at (`StudentRef`) and the `exam` result when the
/// caller has it (the Denemelerim list does), so no request is made; a deep
/// link without them reads the list until the id turns up.
/// `QuestionDetailRoute` takes the same two.
///
/// There are no full-screen routes in this feature.
List<AutoRoute> get examsAnalyticsTabRoutes => [
  AutoRoute(page: ExamDetailRoute.page, path: 'exam/:examId'),
  AutoRoute(page: QuestionDetailRoute.page, path: 'exam/:examId/question'),
];
