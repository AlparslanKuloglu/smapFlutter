import 'package:auto_route/auto_route.dart';

// The root page of each tab's own stack (spec §3.1 "sekme başına yığın",
// pano 1.19 "her sekmenin kendi gezinme yığını"): an empty page that holds
// an `AutoRouter`, so a screen opened from a tab (an exam detail, a lesson)
// is pushed on that tab's stack, keeps the bar, and Back walks that stack.
//
// The names read `HomeTabRoute`, `AnalyticsTabRoute`, `LessonsTabRoute`,
// `AccountTabRoute` for the student and `CoachHomeTabRoute`,
// `CoachStudentsTabRoute`, `CoachMeetingsTabRoute`, `CoachAccountTabRoute`
// for the coach; a screen is opened in a tab with
// `context.navigateTo(AnalyticsTabRoute(children: [ExamDetailRoute(...)]))`.

/// Student, Anasayfa tab (`/home`).
@RoutePage()
class HomeTabPage extends AutoRouter {
  const HomeTabPage({super.key});
}

/// Student, Analizlerim tab (`/analytics`).
@RoutePage()
class AnalyticsTabPage extends AutoRouter {
  const AnalyticsTabPage({super.key});
}

/// Student, Derslerim tab (`/lessons`).
@RoutePage()
class LessonsTabPage extends AutoRouter {
  const LessonsTabPage({super.key});
}

/// Student, Hesap tab (`/account`).
@RoutePage()
class AccountTabPage extends AutoRouter {
  const AccountTabPage({super.key});
}

/// Coach, Anasayfa tab (`/coach/home`).
@RoutePage()
class CoachHomeTabPage extends AutoRouter {
  const CoachHomeTabPage({super.key});
}

/// Coach, Öğrencilerim tab (`/coach/students`).
@RoutePage()
class CoachStudentsTabPage extends AutoRouter {
  const CoachStudentsTabPage({super.key});
}

/// Coach, Görüşmelerim tab (`/coach/meetings`).
@RoutePage()
class CoachMeetingsTabPage extends AutoRouter {
  const CoachMeetingsTabPage({super.key});
}

/// Coach, Hesap tab (`/coach/account`).
@RoutePage()
class CoachAccountTabPage extends AutoRouter {
  const CoachAccountTabPage({super.key});
}
