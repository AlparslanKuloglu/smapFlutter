import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import 'package:smap/app/shell/scroll_to_top.dart';
import 'package:smap/app/shell/shell_preview.dart';
import 'package:smap/app/shell/shell_tab_spec.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/shell/application/shell_bar_policy.dart';
import 'package:smap/features/shell/presentation/shell_viewmodel.dart';
import 'package:smap/shared/ui/feedback/app_offline_strip.dart';
import 'package:smap/shared/ui/feedback/offline_strip_logic.dart';
import 'package:smap/shared/ui/navigation/app_bottom_bar.dart';
import 'package:smap/shared/ui/navigation/bottom_bar_tabs.dart';

part 'widgets/shell_offline_strip.dart';
part 'widgets/shell_tab_stack.dart';

/// What the student shell and the coach shell have in common: four tab stacks
/// under the bottom bar with the camera button, and the offline strip on top
/// (spec §3.1, §3.2, §3.5; pano 1.19, 1.24 kare 1 and 5; Tur 1 varsayım
/// 1.9).
///
/// An `AutoTabsRouter` keeps the four stacks alive side by side (each in its
/// own `AutoRouter`, so Back walks the stack of the tab that is showing and
/// the bar stays on every page of it). Under it a [Scaffold] with
/// `extendBody` puts the [AppBottomBar] at the bottom: every screen scrolls
/// behind its blur.
///
/// - Tapping another tab shows it; tapping the selected one pops its stack to
///   the root page and scrolls it to the top ([ShellBarPolicy.onTap]).
/// - "Okut" is no tab: it opens the scan flow on the root router, which
///   covers the shell and so the bar ([ShellViewModel.openCamera]).
/// - Android Back leaves a tab's stack first, then returns to Anasayfa, then
///   leaves the app (`homeIndex: 0`).
/// - The shell tells the toast service where the bar is (a toast sits 8 pt
///   above it) through [ShellViewModel].
class ShellFrame extends StatefulWidget {
  const ShellFrame({
    required this.role,
    required this.tabs,
    required this.viewModel,
    super.key,
  });

  final AppBottomBarRole role;

  /// The four tabs, in bar order (the camera sits between the second and the
  /// third).
  final List<ShellTabSpec> tabs;

  final ShellViewModel viewModel;

  @override
  State<ShellFrame> createState() => _ShellFrameState();
}

class _ShellFrameState extends State<ShellFrame> {
  late final List<PageRouteInfo> _routes = [
    for (final tab in widget.tabs) tab.route,
  ];

  /// One key per tab: the root of the walk that scrolls the tab to the top.
  late final List<GlobalKey> _tabKeys = List.generate(
    widget.tabs.length,
    (_) => GlobalKey(),
  );

  /// The debug preview opens on `SHELL_PREVIEW_TAB` once.
  bool _previewTabApplied = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.attach();
  }

  void _applyPreviewTab(TabsRouter tabs) {
    if (_previewTabApplied) return;
    _previewTabApplied = true;
    final index = ShellPreview.initialTab;
    if (index == 0 || index >= widget.tabs.length) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) tabs.setActiveIndex(index);
    });
  }

  void _onTab(TabsRouter tabs, int index) {
    switch (ShellBarPolicy.onTap(tapped: index, active: tabs.activeIndex)) {
      case ShellTabAction.switchTab:
        tabs.setActiveIndex(index);
      case ShellTabAction.backToRoot:
        tabs.stackRouterOfIndex(index)?.popUntilRoot();
        // The popped pages leave over the next frames; the root page is the
        // only one left to scroll when this runs.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final tab = _tabKeys[index].currentContext;
          if (!mounted || tab == null) return;
          scrollTabToTop(
            tab,
            duration: context.motion(AppMotion.slow, reduced: Duration.zero),
          );
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter.builder(
      routes: _routes,
      homeIndex: 0,
      builder: (context, children, tabs) {
        _applyPreviewTab(tabs);
        // Read here, above the Scaffold: its body sees `viewPadding.bottom`
        // as 0 (the bar takes the inset).
        final deviceBottom = MediaQuery.viewPaddingOf(context).bottom;
        return Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,
          backgroundColor: context.appColors.bgCanvas,
          body: _ShellOfflineStrip(
            online: widget.viewModel.online,
            child: _ShellTabStack(
              activeIndex: tabs.activeIndex,
              specs: widget.tabs,
              keys: _tabKeys,
              deviceBottom: deviceBottom,
              children: children,
            ),
          ),
          bottomNavigationBar: AppBottomBar(
            role: widget.role,
            selectedIndex: tabs.activeIndex,
            onTap: (index) => _onTab(tabs, index),
            onCamera: widget.viewModel.openCamera,
          ),
        );
      },
    );
  }
}
