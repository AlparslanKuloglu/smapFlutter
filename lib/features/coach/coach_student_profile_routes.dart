import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';

/// The routes under a student of the coach's Öğrencilerim tab (pano 10.4;
/// spec §3.6 `/coach/students/:studentId?tab=analysis|exams|program`), for
/// `shell_routes.dart` to add to the children of `CoachStudentsTabRoute` next
/// to [coachStudentsTabRoutes]:
///
/// | path (under `/coach/students`) | screen |
/// |---|---|
/// | `exam/:examId` | `ExamDetailView` in the coach's view (pano 10.4 kare 4) |
/// | `exam/:examId/question?lesson=&q=` | `QuestionDetailView`, same |
/// | `program` | `ProgramListView`, the student's programs (Tur 12 A, 14.1 kare 2) |
/// | `program/:programId?view=&date=` | `ProgramDetailView`, same (14.1 kare 3) |
/// | `:studentId?tab=` | `StudentProfileView` |
///
/// The screens are pushed on the tab's own stack, so the bottom bar stays and
/// Back returns to the profile. The student the coach looks at is not in the
/// path: it travels as the `student` argument of every route
/// (`ExamDetailRoute(examId:, student:)` and so on), which is what puts the
/// context strip on those screens and the student's id on their requests. The
/// profile alone reads the id from its path and finds the student in the
/// coach's list. The fixed paths come before `:studentId`, so a path is never
/// taken for a student id.
///
/// "Yeni Program" is the full-screen flow of `scheduleRootRoutes`
/// (`NewProgramRoute(student:)`), not a child of the tab.
///
/// ```dart
/// AutoRoute(
///   page: CoachStudentsTabRoute.page,
///   path: 'students',
///   children: [...coachStudentsTabRoutes, ...coachStudentProfileRoutes],
/// ),
/// ```
List<AutoRoute> get coachStudentProfileRoutes => [
  AutoRoute(page: ExamDetailRoute.page, path: 'exam/:examId'),
  AutoRoute(page: QuestionDetailRoute.page, path: 'exam/:examId/question'),
  AutoRoute(page: ProgramListRoute.page, path: 'program'),
  AutoRoute(page: ProgramDetailRoute.page, path: 'program/:programId'),
  AutoRoute(page: StudentProfileRoute.page, path: ':studentId'),
];
