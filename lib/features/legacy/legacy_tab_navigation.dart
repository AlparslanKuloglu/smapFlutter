import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import 'package:smap/app/router/app_router.dart';

/// Where a legacy screen used to switch the root tab
/// (`RootNavNotifier.changeTab`): it opens the tab's stack on the shell
/// instead. Each call site is a single line there; it goes with the screen
/// when the screen is migrated.
abstract final class LegacyTabNavigation {
  /// Student: Derslerim.
  static void openLessons(BuildContext context) =>
      context.navigateTo(const LessonsTabRoute());

  /// Student: Analizlerim, on its in-screen tab [initialTabIndex]
  /// (0 Genel, 1 Denemelerim).
  static void openAnalytics(BuildContext context, {int? initialTabIndex}) =>
      context.navigateTo(
        AnalyticsTabRoute(
          children: [
            AnalyticsRoute(tab: initialTabIndex == 1 ? 'denemelerim' : null),
          ],
        ),
      );

  /// Coach: Öğrencilerim.
  static void openStudents(BuildContext context) =>
      context.navigateTo(const CoachStudentsTabRoute());

  /// Coach: Görüşmelerim.
  static void openMeetings(BuildContext context) =>
      context.navigateTo(const CoachMeetingsTabRoute());
}
