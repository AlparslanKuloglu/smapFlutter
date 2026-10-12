import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:mihr_ui/mihr_ui.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_shadows.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/smap_colors.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/navigation/app_camera_button.dart';
import 'package:smap/shared/ui/navigation/app_nav_tab.dart';
import 'package:smap/shared/ui/navigation/band_text.dart';
import 'package:smap/shared/ui/navigation/bottom_bar_tabs.dart';

/// The bottom bar of the student and coach shells (C84 `SmapBottomBar(role:
/// student | coach)`; pano 1.19 and 1.24; UI guide §5 #35).
///
/// Five slots: four [AppNavTab]s and the [AppCameraButton] in the middle.
/// Student: Anasayfa, Analizlerim, [Okut], Derslerim, Hesap; coach:
/// Anasayfa, Öğrencilerim, [Okut], Görüşmelerim, Hesap. Height 68 plus the
/// bottom safe area (102 on the reference frame); the camera button rises 16
/// above it, so the widget itself is 16 taller and that strip is transparent
/// and lets touches through.
///
/// The surface is `bgBar` (92 % opaque) over a 20 pt blur
/// (`FrostedContainer`; Düzeltmeler #4: `BackdropBlurStyle.custom` with both
/// overlays set to the bgBar of each theme, and only the top corners
/// rounded, 24), a 1 pt `borderSubtle` line along the top edge and no
/// shadow. Content scrolls under it (give the screen's scroll view the bottom
/// padding [heightOf]).
///
/// One 32 x 4 position indicator (`accentLine`, bottom corners 4) sits on the
/// top edge and slides under the selected tab in 250 ms (a 150 ms fade
/// under "Reduce motion"). [selectedIndex] counts the tabs only, 0 to 3; null
/// shows no indicator (a screen that belongs to no tab).
///
/// There is no routing here: [onTap] gets the tab index on every tap,
/// including the selected one (the shell turns that into "back to the
/// branch root and scroll to the top"); the selection haptic plays only
/// when the choice changes. [onCamera] opens the full-screen camera flow.
/// The bar is hidden by the shell on full-screen flows (spec §3.2).
class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    required this.role,
    required this.selectedIndex,
    required this.onTap,
    required this.onCamera,
    this.safeBottom,
    super.key,
  });

  final AppBottomBarRole role;

  /// The selected tab, 0 to 3; null for none.
  final int? selectedIndex;

  /// A tab was tapped.
  final ValueChanged<int> onTap;

  /// The camera button was tapped.
  final VoidCallback onCamera;

  /// Override for the bottom safe area (gallery frames).
  final double? safeBottom;

  /// Indicator size (C84: 32 x 4, bottom corners 4).
  static const double indicatorWidth = 32;
  static const double indicatorHeight = 4;

  /// The bar's own height with the safe area: 68 + inset. Use it as the
  /// bottom padding of a screen that scrolls under the bar.
  static double heightOf(BuildContext context, {double? safeBottom}) =>
      AppSize.bottomBar +
      (safeBottom ?? MediaQuery.viewPaddingOf(context).bottom);

  static BackdropBlurStyle get _blur => BackdropBlurStyle.custom(
    sigma: AppBlur.bar,
    blurPx: (2 * AppBlur.bar).round(),
    lightOverlay: SmapColors.light.bgBar,
    darkOverlay: SmapColors.dark.bgBar,
  );

  @override
  Widget build(BuildContext context) {
    final inset = safeBottom ?? MediaQuery.viewPaddingOf(context).bottom;
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final tabs = AppBottomBarTabs.forRole(role);
    final index = selectedIndex;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: l10n.nav_barLabel,
      child: SizedBox(
        height: AppSize.cameraButtonLift + AppSize.bottomBar + inset,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final labelScale = _labelScaleOf(
              context,
              width: constraints.maxWidth,
              labels: [for (final tab in tabs) _labelOf(l10n, tab.destination)],
              cameraLabel: l10n.nav_cameraLabel,
            );
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: AppSize.bottomBar + inset,
                  child: FrostedContainer(
                    blur: _blur,
                    overlayColor: colors.bgBar,
                    borderRadius: AppRadius.barTop,
                    child: CustomPaint(
                      foregroundPainter: _TopEdgePainter(
                        color: colors.borderSubtle,
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: inset),
                        child: _Slots(
                          width: constraints.maxWidth,
                          tabs: tabs,
                          selectedIndex: index,
                          labelOf: (d) => _labelOf(l10n, d),
                          labelScale: labelScale,
                          positionPhraseOf: l10n.nav_a11yTabPosition,
                          onTap: (i) {
                            if (i != index) AppHaptics.selection();
                            onTap(i);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Center(
                    child: AppCameraButton(
                      label: l10n.nav_cameraLabel,
                      semanticLabel: l10n.nav_cameraA11y,
                      onPressed: onCamera,
                      labelScale: labelScale,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// The one label scale of the five labels (four tabs and "Okut"): each is
  /// measured in the heaviest weight at the platform text scale against the
  /// room its slot gives it (pano 1.19 "sığmazsa küçülür"; C77 to C79).
  static double _labelScaleOf(
    BuildContext context, {
    required double width,
    required List<String> labels,
    required String cameraLabel,
  }) {
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    final style = context.appText.labelSm.copyWith(fontWeight: FontWeight.w700);
    double measure(String text) => BandText.size(
      text: text,
      style: style,
      width: double.infinity,
      textScaler: scaler,
      textDirection: direction,
      maxLines: 1,
    ).width;
    final tabWidth =
        (width - AppCameraButton.slotWidth) / AppBottomBarTabs.tabCount;
    return AppBottomBarTabs.labelScale(
      textWidths: [
        for (final label in labels) measure(label),
        measure(cameraLabel),
      ],
      slotWidths: [
        for (var i = 0; i < labels.length; i++) tabWidth,
        AppCameraButton.slotWidth,
      ],
    );
  }

  static String _labelOf(
    AppLocalizations l10n,
    AppNavDestination destination,
  ) => switch (destination) {
    AppNavDestination.home => l10n.nav_tabHome,
    AppNavDestination.analytics => l10n.nav_tabAnalytics,
    AppNavDestination.lessons => l10n.nav_tabLessons,
    AppNavDestination.students => l10n.nav_tabStudents,
    AppNavDestination.meetings => l10n.nav_tabMeetings,
    AppNavDestination.account => l10n.nav_tabAccount,
  };
}

/// The tab row: four tabs around the 72 pt camera slot and the sliding
/// position indicator on top of them.
class _Slots extends StatelessWidget {
  const _Slots({
    required this.width,
    required this.tabs,
    required this.selectedIndex,
    required this.labelOf,
    required this.labelScale,
    required this.positionPhraseOf,
    required this.onTap,
  });

  final double width;
  final List<AppNavTabSpec> tabs;
  final int? selectedIndex;
  final String Function(AppNavDestination) labelOf;
  final double labelScale;
  final String Function(int position) positionPhraseOf;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = selectedIndex;
    // Only the tabs sit under the tab-bar role; the camera button is a
    // button, not a tab, and lives outside this node.
    return Semantics(
      container: true,
      role: SemanticsRole.tabBar,
      explicitChildNodes: true,
      child: Stack(
        children: [
          for (final (i, tab) in tabs.indexed)
            _positioned(
              slot: AppBottomBarTabs.slotOf(i),
              child: AppNavTab(
                icon: tab.icon,
                activeIcon: tab.activeIcon,
                label: labelOf(tab.destination),
                semanticLabel: AppBottomBarTabs.semanticLabel(
                  labelOf(tab.destination),
                  positionPhraseOf(AppBottomBarTabs.positionOf(i)),
                ),
                selected: i == selected,
                labelScale: labelScale,
                onTap: () => onTap(i),
              ),
            ),
          if (selected != null)
            _Indicator(slot: AppBottomBarTabs.slotOf(selected), width: width),
        ],
      ),
    );
  }

  Widget _positioned({required int slot, required Widget child}) {
    final rect = AppBottomBarTabs.slotRect(
      slot,
      width: width,
      cameraWidth: AppCameraButton.slotWidth,
    );
    return Positioned(
      left: rect.left,
      width: rect.width,
      top: 0,
      height: AppSize.bottomBar,
      child: child,
    );
  }
}

/// The single position indicator: slides under the selected tab, or fades
/// between positions under "Reduce motion".
class _Indicator extends StatelessWidget {
  const _Indicator({required this.slot, required this.width});

  final int slot;
  final double width;

  @override
  Widget build(BuildContext context) {
    final rect = AppBottomBarTabs.slotRect(
      slot,
      width: width,
      cameraWidth: AppCameraButton.slotWidth,
    );
    final left = rect.left + (rect.width - AppBottomBar.indicatorWidth) / 2;
    final bar = DecoratedBox(
      decoration: BoxDecoration(
        color: context.appColors.accentLine,
        borderRadius: const BorderRadius.vertical(bottom: AppRadius.radiusXs),
      ),
      child: const SizedBox(
        width: AppBottomBar.indicatorWidth,
        height: AppBottomBar.indicatorHeight,
      ),
    );
    if (context.reduceMotion) {
      return Positioned(
        left: left,
        top: 0,
        child: AnimatedSwitcher(
          duration: AppMotion.reducedFade,
          child: KeyedSubtree(key: ValueKey<int>(slot), child: bar),
        ),
      );
    }
    return AnimatedPositioned(
      left: left,
      top: 0,
      duration: AppMotion.base,
      curve: AppMotion.standard,
      child: bar,
    );
  }
}

/// A 1 pt line along the top edge, following the two rounded corners (the
/// board's `inset 0 1px 0 border-subtle`).
class _TopEdgePainter extends CustomPainter {
  const _TopEdgePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const radius = AppRadius.xl;
    const half = 0.5;
    final path = Path()
      ..moveTo(half, radius)
      ..arcToPoint(
        const Offset(radius, half),
        radius: const Radius.circular(radius - half),
      )
      ..lineTo(size.width - radius, half)
      ..arcToPoint(
        Offset(size.width - half, radius),
        radius: const Radius.circular(radius - half),
      );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_TopEdgePainter oldDelegate) => oldDelegate.color != color;
}
