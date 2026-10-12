import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_shadows.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/shared/ui/buttons/app_focus_ring.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';

/// One tab of the bottom bar (C84 `SmapNavTab`; pano 1.19 "Sekme"; UI guide
/// §5 #35).
///
/// A 24 pt icon over a 12/16 · 600 label, 14 from the top and 6 between
/// them; the touch target is the whole slot, 68 high. Not selected: the Regular
/// icon and `textSecondary`. Selected: the Fill icon in navy (`primary`; in
/// the dark theme `textPrimary`, the light text that has the contrast) and a
/// 700 label. The Regular to Fill change takes 150 ms. The orange position
/// indicator is not drawn here: the bar draws one indicator that slides
/// between the tabs.
///
/// The label is 12/16 · 600 and grows with the text scale, but it never wraps
/// or leaves its slot (C84; pano 1.19 "Etiket 12 pt: ikincil metin kuralının
/// tek istisnası": a label that does not fit shrinks). The bar measures all
/// five labels and passes one shared [labelScale] (0..1), so at large text
/// "Anasayfa", "Analizlerim" and "Okut" are the same size on the same
/// baseline instead of each shrinking by itself; the heaviest label just
/// fits its slot. Without a [labelScale] (a tab on its own) the label
/// shrinks to its own slot with `FittedBox(scaleDown)`. A long press shows a
/// balloon with a large icon and the full name above the tab, for as long as
/// the finger is down.
///
/// Read as [semanticLabel] ("Analizlerim, sekme, 5'te 2"), a selected tab
/// says so. A tap plays `AppHaptics.selection()` in the bar when the choice
/// changes, not here.
class AppNavTab extends StatefulWidget {
  const AppNavTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.semanticLabel,
    required this.selected,
    required this.onTap,
    this.labelScale,
    super.key,
  });

  /// Phosphor Regular icon.
  final IconData icon;

  /// Phosphor Fill icon of the selected state.
  final IconData activeIcon;

  /// "Analizlerim".
  final String label;

  /// "Analizlerim, sekme, 5'te 2".
  final String semanticLabel;
  final bool selected;
  final VoidCallback onTap;

  /// The shared shrink factor of the bar's labels (0..1, see
  /// `AppBottomBarTabs.labelScale`); null shrinks this label to its slot
  /// alone.
  final double? labelScale;

  /// Space above the icon.
  static const double topPadding = 14;

  /// Space between the icon and the label.
  static const double iconGap = AppSpacing.s4 + 2;

  /// Icon edge.
  static const double iconSize = AppSize.icon;

  /// [style] at the platform [textScaler] times the shared [factor]; the
  /// label then carries its own scale and ignores `MediaQuery`'s.
  static TextStyle sharedStyle(
    TextStyle style,
    TextScaler textScaler,
    double factor,
  ) {
    final base = style.fontSize ?? 12;
    return style.apply(fontSizeFactor: textScaler.scale(base) / base * factor);
  }

  @override
  State<AppNavTab> createState() => _AppNavTabState();
}

class _AppNavTabState extends State<AppNavTab> {
  OverlayEntry? _balloon;

  void _showBalloon() {
    if (_balloon != null) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached) return;
    final anchor = box.localToGlobal(Offset.zero) & box.size;
    final entry = OverlayEntry(
      builder: (_) => _TabBalloon(
        anchor: anchor,
        icon: widget.activeIcon,
        label: widget.label,
      ),
    );
    _balloon = entry;
    Overlay.of(context).insert(entry);
  }

  void _hideBalloon() {
    _balloon
      ?..remove()
      ..dispose();
    _balloon = null;
  }

  @override
  void dispose() {
    _hideBalloon();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final dark = Theme.brightnessOf(context) == Brightness.dark;
    final selected = widget.selected;
    final ink = selected
        ? (dark ? colors.textPrimary : colors.primary)
        : colors.textSecondary;
    final fade = context.motion(AppMotion.fast, reduced: AppMotion.reducedFade);

    return Semantics(
      role: SemanticsRole.tab,
      selected: selected,
      label: widget.semanticLabel,
      onTap: widget.onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPressStart: (_) => _showBalloon(),
        onLongPressEnd: (_) => _hideBalloon(),
        onLongPressCancel: _hideBalloon,
        child: AppPressable(
          onTap: widget.onTap,
          scale: 1,
          builder: (context, states) => AppFocusRing(
            focused: states.contains(WidgetState.focused),
            style: AppFocusRingStyle.inset,
            child: SizedBox(
              height: AppSize.bottomBar,
              child: Column(
                children: [
                  const SizedBox(height: AppNavTab.topPadding),
                  AnimatedSwitcher(
                    duration: fade,
                    child: PhosphorIcon(
                      selected ? widget.activeIcon : widget.icon,
                      key: ValueKey<bool>(selected),
                      size: AppNavTab.iconSize,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: AppNavTab.iconGap),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s4,
                    ),
                    child: _TabLabel(
                      label: widget.label,
                      style: text.labelSm.copyWith(
                        color: ink,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                      scale: widget.labelScale,
                      duration: fade,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The long-press balloon of a tab: a large icon and the full name above the
/// tab, kept inside the screen. Inverse surface (the toast's colors), the
/// overlay shadow, radius 16; the name at its normal size.
class _TabBalloon extends StatelessWidget {
  const _TabBalloon({
    required this.anchor,
    required this.icon,
    required this.label,
  });

  final Rect anchor;
  final IconData icon;
  final String label;

  /// Large icon edge.
  static const double _iconSize = 32;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return IgnorePointer(
      child: Material(
        type: MaterialType.transparency,
        child: CustomSingleChildLayout(
          delegate: _BalloonLayout(anchor),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.inverseSurface,
              borderRadius: AppRadius.borderLg,
              boxShadow: AppShadows.overlayOf(context),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PhosphorIcon(
                    icon,
                    size: _iconSize,
                    color: colors.onInverseSurface,
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    label,
                    maxLines: 1,
                    style: context.appText.bodyStrong.copyWith(
                      color: colors.onInverseSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BalloonLayout extends SingleChildLayoutDelegate {
  const _BalloonLayout(this.anchor);

  final Rect anchor;

  static const double _edge = AppSpacing.s8;
  static const double _gap = AppSpacing.s8;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final left = (anchor.center.dx - childSize.width / 2)
        .clamp(_edge, math.max(_edge, size.width - childSize.width - _edge))
        .toDouble();
    final top = math.max(_edge, anchor.top - childSize.height - _gap);
    return Offset(left, top);
  }

  @override
  bool shouldRelayout(_BalloonLayout oldDelegate) =>
      anchor != oldDelegate.anchor;
}

/// The label of a tab. With a shared [scale] it is drawn at the platform text
/// scale times that factor, one line, so all labels of the bar match; without
/// it, `FittedBox(scaleDown)` fits it to its own slot.
class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.label,
    required this.style,
    required this.scale,
    required this.duration,
  });

  final String label;
  final TextStyle style;
  final double? scale;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final shared = scale;
    if (shared == null) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: AnimatedDefaultTextStyle(
          duration: duration,
          style: style,
          maxLines: 1,
          softWrap: false,
          child: Text(label),
        ),
      );
    }
    return AnimatedDefaultTextStyle(
      duration: duration,
      style: AppNavTab.sharedStyle(
        style,
        MediaQuery.textScalerOf(context),
        shared,
      ),
      maxLines: 1,
      softWrap: false,
      child: Text(label, textScaler: TextScaler.noScaling),
    );
  }
}
