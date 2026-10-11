import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import 'package:smap/app/router/app_router.dart';

/// The student shell (spec §3 "Öğrenci kabuğu"): an `AutoTabsRouter` whose
/// tabs are the student's four stacks.
///
/// Skeleton for now: the one tab is the whole legacy app (`RootScreen` with
/// its own bottom bar). E5 builds the real shell here: Anasayfa, Analizlerim,
/// Derslerim and Hesap tabs with the new bottom bar, the camera button and
/// the offline strip, each tab with its own stack.
@RoutePage()
class StudentShellView extends StatelessWidget {
  const StudentShellView({super.key});

  @override
  Widget build(BuildContext context) => AutoTabsRouter(
    routes: const [LegacyStudentRootRoute()],
    builder: (context, child) => child,
  );
}
