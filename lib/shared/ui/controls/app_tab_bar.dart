import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_focus_ring.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';
import 'package:smap/shared/ui/controls/tab_layout.dart';

/// In-screen tabs: moves between sections of the same object (C05; board
/// 1.10 "Ekran içi sekme"; UI guide §5 #6).
///
/// 48 high with a 1 pt `borderSubtle` rule under it; labels are 15/24, the
/// selected one 700 in `textPrimary`, the others 600 in `textSecondary`. The
/// selected tab carries the accent line (3 pt, `accentLine`, as wide as its
/// label) that slides in [AppMotion.base] (250 ms, standard); it speaks the
/// same position language as the bottom bar: orange line and heavier label.
///
/// Fixed: equal shares. When the labels do not fit that way the bar becomes
/// scrollable by itself ([scrollable] null) with 16 pt ends and 24 pt
/// between tabs, a 40 pt fade on the edge that continues, and the selected
/// tab scrolled into view. Switching plays `AppHaptics.selection()`.
///
/// [onNavy] is the variant in the root band: no rule, labels `textOnNavy2` /
/// `textOnNavy`, an orange-500 line (`accent`; 4,98:1 on navy). The line
/// stays `accent` there in both themes (spec C05 "Koyu").
///
/// Read as a tab list: "Genel, sekme, 4 sekmeden 1", selected announced.
class AppTabBar extends StatefulWidget {
  const AppTabBar({
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.scrollable,
    this.onNavy = false,
    super.key,
  }) : assert(labels.length > 0, 'A tab bar has at least one tab');

  /// Tab titles ("Genel", "Sorular", "Konular", "Kartlar").
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  /// Forces the scrollable (true) or fixed (false) variant; null chooses
  /// by fit.
  final bool? scrollable;

  /// The variant on the navy band.
  final bool onNavy;

  /// Accent line height (C05: 3).
  static const double lineHeight = 3;

  /// Edge fade of the scrollable variant (C05: 40).
  static const double fadeWidth = 40;

  @override
  State<AppTabBar> createState() => _AppTabBarState();
}

class _AppTabBarState extends State<AppTabBar> {
  final ScrollController _scroll = ScrollController();
  double _viewport = 0;
  double _extent = 0;
  List<TabSlot> _slots = const [];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    // A bar that starts on a later tab shows it.
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
  }

  @override
  void didUpdateWidget(AppTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
    }
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() => setState(() {});

  void _reveal() {
    if (!mounted || !_scroll.hasClients || _slots.isEmpty) return;
    final index = widget.selectedIndex.clamp(0, _slots.length - 1);
    final target = TabBarLayout.scrollTarget(
      slot: _slots[index],
      viewport: _viewport,
      extent: _extent,
      current: _scroll.offset,
    );
    if ((target - _scroll.offset).abs() < 0.5) return;
    final duration = context.motion(
      AppMotion.base,
      reduced: AppMotion.reducedFade,
    );
    unawaited(
      _scroll.animateTo(target, duration: duration, curve: AppMotion.standard),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final selectedStyle = text.body.copyWith(fontWeight: FontWeight.w700);
    final restStyle = text.body.copyWith(fontWeight: FontWeight.w600);

    return LayoutBuilder(
      builder: (context, constraints) {
        Size measure(String label) {
          final painter = TextPainter(
            text: TextSpan(text: label, style: selectedStyle),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
            maxLines: 1,
          )..layout();
          final size = painter.size;
          painter.dispose();
          return size;
        }

        final sizes = [for (final l in widget.labels) measure(l)];
        final widths = [for (final size in sizes) size.width];
        // 48 high, 52 and up when the text is scaled (C05).
        final labelHeight = sizes.isEmpty ? 0.0 : sizes.first.height;
        final height = math.max(
          AppSize.touch,
          labelHeight + 2 * AppSpacing.s12 + AppTabBar.lineHeight,
        );
        final available = constraints.maxWidth;
        final scrolls =
            widget.scrollable ?? !TabBarLayout.fitsFixed(widths, available);
        final slots = scrolls
            ? TabBarLayout.scrollSlots(widths)
            : TabBarLayout.fixedSlots(widths, available);
        _slots = slots;
        _viewport = available;
        _extent = scrolls ? TabBarLayout.scrollExtent(slots) : available;

        final selected = widget.selectedIndex.clamp(0, slots.length - 1);
        final line = widget.onNavy ? colors.accent : colors.accentLine;
        final slide = context.motion(AppMotion.base, reduced: Duration.zero);
        final fade = context.motion(
          AppMotion.fast,
          reduced: AppMotion.reducedFade,
        );

        final row = SizedBox(
          width: scrolls ? _extent : available,
          height: height,
          child: Stack(
            children: [
              for (final (i, slot) in slots.indexed)
                Positioned(
                  left: slot.left,
                  width: slot.width,
                  top: 0,
                  bottom: 0,
                  child: _TabItem(
                    label: widget.labels[i],
                    selected: i == selected,
                    index: i,
                    total: slots.length,
                    onNavy: widget.onNavy,
                    selectedStyle: selectedStyle,
                    restStyle: restStyle,
                    fade: fade,
                    onTap: widget.onChanged == null
                        ? null
                        : () {
                            if (i == selected) return;
                            AppHaptics.selection();
                            widget.onChanged!(i);
                          },
                  ),
                ),
              AnimatedPositioned(
                duration: slide,
                curve: AppMotion.standard,
                left: slots[selected].labelLeft,
                width: slots[selected].labelWidth,
                bottom: 0,
                height: AppTabBar.lineHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: line,
                    borderRadius: AppRadius.borderFull,
                  ),
                ),
              ),
            ],
          ),
        );

        final Widget body = scrolls
            ? _ScrollEdges(
                controller: _scroll,
                viewport: available,
                extent: _extent,
                child: SingleChildScrollView(
                  controller: _scroll,
                  scrollDirection: Axis.horizontal,
                  child: row,
                ),
              )
            : row;
        return Semantics(
          container: true,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: widget.onNavy
                  ? null
                  : Border(bottom: BorderSide(color: colors.borderSubtle)),
            ),
            child: body,
          ),
        );
      },
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.selected,
    required this.index,
    required this.total,
    required this.onNavy,
    required this.selectedStyle,
    required this.restStyle,
    required this.fade,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final int index;
  final int total;
  final bool onNavy;
  final TextStyle selectedStyle;
  final TextStyle restStyle;
  final Duration fade;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final Color ink;
    if (onNavy) {
      ink = selected ? colors.textOnNavy : colors.textOnNavy2;
    } else {
      ink = selected ? colors.textPrimary : colors.textSecondary;
    }
    final semantics = [label, l10n.kit_a11yTabOf(total, index + 1)].join(', ');

    return Semantics(
      label: semantics,
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      excludeSemantics: true,
      onTap: onTap,
      child: AppPressable(
        onTap: onTap,
        scale: 1,
        builder: (context, states) => AppFocusRing(
          focused: states.contains(WidgetState.focused),
          style: AppFocusRingStyle.inset,
          borderRadius: AppRadius.borderSm,
          child: Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.s12,
              bottom: AppSpacing.s12 + AppTabBar.lineHeight,
            ),
            child: Center(
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: ink),
                duration: fade,
                builder: (context, color, _) => Text(
                  label,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: (selected ? selectedStyle : restStyle).copyWith(
                    color: color,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fades the edge of the scrollable tab row that continues (C05: 40 pt,
/// opaque to transparent) by masking the row's own alpha, so it works on any
/// background.
class _ScrollEdges extends StatelessWidget {
  const _ScrollEdges({
    required this.controller,
    required this.viewport,
    required this.extent,
    required this.child,
  });

  final ScrollController controller;
  final double viewport;
  final double extent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final offset = controller.hasClients ? controller.offset : 0.0;
    final more = extent - viewport;
    final left = offset > 1;
    final right = more > 0 && offset < more - 1;
    if (!left && !right || viewport <= 0) return child;
    final stop = AppTabBar.fadeWidth / viewport;
    final ink = context.appColors.textPrimary;
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => LinearGradient(
        colors: [
          ink.withValues(alpha: left ? 0 : 1),
          ink,
          ink,
          ink.withValues(alpha: right ? 0 : 1),
        ],
        stops: [0, stop, 1 - stop, 1],
      ).createShader(rect),
      child: child,
    );
  }
}
