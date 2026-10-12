import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/app/shell/shell_frame.dart';
import 'package:smap/app/shell/shell_tab_spec.dart';
import 'package:smap/core/services/connectivity_service.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/shell/presentation/shell_viewmodel.dart';
import 'package:smap/shared/ui/navigation/bottom_bar_tabs.dart';

/// The coach shell (spec §3 "Koç kabuğu"; pano 1.19 kare 3 and 4, D-29):
/// Anasayfa, Öğrencilerim, [Okut], Görüşmelerim and Hesap under the bottom
/// bar, each tab with its own stack (`/coach/home`, `/coach/students`,
/// `/coach/meetings`, `/coach/account`).
///
/// The camera is here too (a coach picks the student first in the scan flow
/// to come). The tabs show the legacy screens for now; the guards put only a
/// signed-in coach here (`RoleGuard`).
@RoutePage()
class CoachShellView extends StackedView<ShellViewModel> {
  const CoachShellView({super.key});

  /// The four tabs, in bar order.
  static const List<ShellTabSpec> tabs = [
    ShellTabSpec(route: CoachHomeTabRoute()),
    ShellTabSpec(route: CoachStudentsTabRoute()),
    ShellTabSpec(route: CoachMeetingsTabRoute()),
    ShellTabSpec(
      route: CoachAccountTabRoute(),
      content: ShellTabContent.screen,
    ),
  ];

  @override
  bool get reactive => false;

  @override
  ShellViewModel viewModelBuilder(BuildContext context) => ShellViewModel(
    router: locator<AppRouter>(),
    toast: locator<ToastService>(),
    connectivity: locator<ConnectivityService>(),
  );

  @override
  Widget builder(
    BuildContext context,
    ShellViewModel viewModel,
    Widget? child,
  ) => ShellFrame(
    role: AppBottomBarRole.coach,
    tabs: tabs,
    viewModel: viewModel,
  );
}
