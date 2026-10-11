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

/// The student shell (spec §3 "Öğrenci kabuğu"; pano 1.19 kare 1 and 2):
/// Anasayfa, Analizlerim, [Okut], Derslerim and Hesap under the bottom bar,
/// each tab with its own stack (`/home`, `/analytics`, `/lessons`,
/// `/account`).
///
/// The tabs show the legacy screens for now (`Legacy…TabRoute`); the screen
/// tasks (E6 and on) replace them one by one and set the tab's
/// `ShellTabContent.screen` here. The guards put only a signed-in student
/// here (`RoleGuard`).
@RoutePage()
class StudentShellView extends StackedView<ShellViewModel> {
  const StudentShellView({super.key});

  /// The four tabs, in bar order.
  static const List<ShellTabSpec> tabs = [
    ShellTabSpec(route: HomeTabRoute(), content: ShellTabContent.screen),
    ShellTabSpec(route: AnalyticsTabRoute(), content: ShellTabContent.screen),
    ShellTabSpec(route: LessonsTabRoute(), content: ShellTabContent.screen),
    ShellTabSpec(route: AccountTabRoute()),
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
    role: AppBottomBarRole.student,
    tabs: tabs,
    viewModel: viewModel,
  );
}
