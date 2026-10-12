import 'package:auto_route/auto_route.dart';
import 'package:smap/app/router/app_router.dart';

/// The two places the optical scan (`features/scan`) leads to that other
/// tasks own, gathered in one file so the day they land is one edit
/// (task E8; flow 13.4, 13.5).
///
/// **Result.** The recognised exam opens the result moment (pano 5.1,
/// `ResultMomentRoute(examId:)` of task E9), which replaces the scan on the
/// root stack. Until that screen is on this branch the student goes straight
/// to Deneme Detay in the Analizlerim tab, which is where the result moment's
/// "Detaylı Analiz" leads anyway. When E9 is merged, replace the body with
///
/// ```dart
/// router.replace(ResultMomentRoute(examId: examId));
/// ```
///
/// (and let it `removeWhere` the scan's route underneath, or leave that to
/// the result moment's own "Detaylı Analiz", which closes the camera flow).
void openScanResult(StackRouter router, String examId) {
  router.navigate(
    AnalyticsTabRoute(
      children: [
        AnalyticsRoute(),
        ExamDetailRoute(examId: examId),
      ],
    ),
  );
}

/// Anasayfa with the scan gone ("Anasayfa" after "Talebin alındı", pano 4.9
/// kare 4): the root stack is popped down to the shell and the Anasayfa tab is
/// selected.
void goHomeAfterScan(StackRouter router) {
  router.popUntilRoot();
  router.navigate(const HomeTabRoute());
}
