import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import 'package:smap/app/router/app_router.dart';

/// The coach shell (spec §3 "Koç kabuğu"): an `AutoTabsRouter` whose tabs are
/// the coach's four stacks.
///
/// Skeleton for now: the one tab is the whole legacy app (`RootScreen` with
/// its own bottom bar). E5 builds the real shell here: Anasayfa,
/// Öğrencilerim, Görüşmelerim and Hesap tabs.
@RoutePage()
class CoachShellView extends StatelessWidget {
  const CoachShellView({super.key});

  @override
  Widget build(BuildContext context) => AutoTabsRouter(
    routes: const [LegacyCoachRootRoute()],
    builder: (context, child) => child,
  );
}
