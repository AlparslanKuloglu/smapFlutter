import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/features/exams/application/exam_detail_model.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';
import 'package:smap/features/exams/presentation/result_moment/result_moment_navigator.dart';

/// A [ResultMomentNavigator] on the root router (the moment is a root page
/// above the shell, spec §3.6 `/scan/result/:examId`).
///
/// `navigate` to the shell with the tab's stack spelled out pops everything
/// above the shell (the scan pages and the moment itself), switches to the
/// tab and puts the screens on that tab's own stack: Deneme Detay on top of
/// Analizlerim (the bottom bar is back and Back returns to the list), or
/// Anasayfa.
class StackResultMomentNavigator implements ResultMomentNavigator {
  const StackResultMomentNavigator(this._router);

  final StackRouter _router;

  @override
  Future<void> openExamDetail({
    required String examId,
    ExamDetail? exam,
    ExamDetailTab tab = ExamDetailTab.general,
  }) => _router.root.navigate(
    StudentShellRoute(
      children: [
        AnalyticsTabRoute(
          children: [
            AnalyticsRoute(),
            ExamDetailRoute(examId: examId, tab: tab.key, exam: exam),
          ],
        ),
      ],
    ),
  );

  @override
  Future<void> openHome() => _router.root.navigate(
    const StudentShellRoute(
      children: [
        HomeTabRoute(children: [HomeRoute()]),
      ],
    ),
  );
}
