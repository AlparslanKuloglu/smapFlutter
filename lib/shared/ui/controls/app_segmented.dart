import 'package:flutter/material.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/smap_colors.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_focus_ring.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';
import 'package:smap/shared/ui/controls/segment_layout.dart';

/// One option of an [AppSegmented].
class AppSegment<T> {
  const AppSegment({required this.value, required this.label, this.counter});

  final T value;

  /// "TYT".
  final String label;

  /// The counter line ("28 eksik"), from [SegmentCounter.format]. Null or
  /// empty draws no counter line for this option (handoff 11.13).
  final String? counter;

  bool get hasCounter => counter != null && counter!.isNotEmpty;
}

/// Segmented control: changes the view of the same list (C04; board 1.10
/// "Segment"; UI guide §5 #5). Content that changes completely uses
/// `AppTabBar` instead.
///
/// A `bgSunken` track (radius 12, 4 pt padding, 4 pt between options) with a
/// `primary` thumb (radius 8) that slides in [AppMotion.base] (250 ms,
/// standard curve) under the selected option; under "Reduce motion" the thumb
/// jumps and the label colors cross-fade over 150 ms. Option widths follow
/// their labels ([SegmentLayout.slots]); no label is cut, at text scale 1,3
/// they wrap and the track grows. The visible height is 44 (36 thumb), the
/// touch target 48.
///
/// With a counter on any option every option is two lines (min height 48):
/// title 14/20 · 700 and counter 13/20 · 500 ("TYT / 28 eksik"); with two
/// options that fit, the counter joins the title ("TYT · 7 eksik", 36 high).
/// An option without a counter shows its title alone. There is no badge.
///
/// [onNavy] is the variant inside the navy root band: `bgNavyRaised` track,
/// white thumb with navy text, `textOnNavy2` for the others (board 1.10
/// "Lacivert bant üstünde").
///
/// Read as a radio group: "TYT, 28 eksik, seçili, 3 seçenekten 2". Plays
/// `AppHaptics.selection()` when the choice changes. Keyboard focus draws the
/// inset ring of spec §1.4.
class AppSegmented<T> extends StatelessWidget {
  const AppSegmented({
    required this.segments,
    required this.value,
    required this.onChanged,
    this.onNavy = false,
    super.key,
  }) : assert(segments.length >= 2, 'A segmented control has 2 to 4 options');

  final List<AppSegment<T>> segments;
  final T value;

  /// Null disables the control.
  final ValueChanged<T>? onChanged;

  /// The variant inside the navy band.
  final bool onNavy;

  /// Track padding and the space between options (C04: 4).
  static const double _pad = AppSpacing.s4;

  /// Visible thumb height of a one-line option.
  static const double _thumb = 36;

  /// Minimum option height with a two-line counter.
  static const double _thumbTwoLine = 48;

  /// Breathing room added to a label's width before it is weighed against the
  /// others.
  static const double _labelAir = 16;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final selected = segments.indexWhere((s) => s.value == value);
    final anyCounter = segments.any((s) => s.hasCounter);

    return LayoutBuilder(
      builder: (context, constraints) {
        final inner = constraints.maxWidth - 2 * _pad;
        final titleStyle = anyCounter
            ? text.labelMd.copyWith(fontWeight: FontWeight.w700)
            : text.labelMd;
        double measure(String value, TextStyle style) {
          final painter = TextPainter(
            text: TextSpan(text: value, style: style),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
            maxLines: 1,
          )..layout();
          final width = painter.width;
          painter.dispose();
          return width;
        }

        final inline =
            anyCounter &&
            SegmentLayout.counterInline(
              segmentCount: segments.length,
              inlineWidths: [
                for (final s in segments)
                  measure(_inlineText(s), text.labelMd) + _labelAir,
              ],
              available: inner,
              gap: _pad,
            );
        final naturals = [
          for (final s in segments)
            (inline
                    ? measure(_inlineText(s), text.labelMd)
                    : _stackedWidth(s, measure, titleStyle, text.caption)) +
                _labelAir,
        ];
        final slots = SegmentLayout.slots(naturals, inner, gap: _pad);
        final minHeight = anyCounter && !inline ? _thumbTwoLine : _thumb;
        final slide = context.motion(AppMotion.base, reduced: Duration.zero);

        final track = DecoratedBox(
          decoration: BoxDecoration(
            color: onNavy ? colors.bgNavyRaised : colors.bgSunken,
            borderRadius: AppRadius.borderMd,
          ),
          child: Padding(
            padding: const EdgeInsets.all(_pad),
            child: Stack(
              children: [
                if (selected >= 0)
                  AnimatedPositioned(
                    duration: slide,
                    curve: AppMotion.standard,
                    left: slots[selected].left,
                    width: slots[selected].width,
                    top: 0,
                    bottom: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: onNavy ? colors.textOnNavy : colors.primary,
                        borderRadius: AppRadius.borderSm,
                      ),
                    ),
                  ),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (i, segment) in segments.indexed) ...[
                        if (i > 0) const SizedBox(width: _pad),
                        SizedBox(
                          width: slots[i].width,
                          child: _SegmentOption<T>(
                            segment: segment,
                            index: i,
                            total: segments.length,
                            selected: i == selected,
                            inline: inline,
                            minHeight: minHeight,
                            onNavy: onNavy,
                            colors: colors,
                            onTap: onChanged == null
                                ? null
                                : () {
                                    if (i == selected) return;
                                    AppHaptics.selection();
                                    onChanged!(segment.value);
                                  },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
        // The track is 44 (or more) high; the 48 touch target is the extra
        // 2 pt above and below, kept as invisible padding.
        return ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSize.touch),
          child: Center(child: track),
        );
      },
    );
  }

  static String _inlineText(AppSegment<dynamic> s) =>
      s.hasCounter ? '${s.label} · ${s.counter}' : s.label;

  static double _stackedWidth(
    AppSegment<dynamic> s,
    double Function(String, TextStyle) measure,
    TextStyle title,
    TextStyle counter,
  ) {
    final a = measure(s.label, title);
    if (!s.hasCounter) return a;
    final b = measure(s.counter!, counter);
    return a > b ? a : b;
  }
}

class _SegmentOption<T> extends StatelessWidget {
  const _SegmentOption({
    required this.segment,
    required this.index,
    required this.total,
    required this.selected,
    required this.inline,
    required this.minHeight,
    required this.onNavy,
    required this.colors,
    required this.onTap,
  });

  final AppSegment<T> segment;
  final int index;
  final int total;
  final bool selected;
  final bool inline;
  final double minHeight;
  final bool onNavy;
  final SmapColors colors;
  final VoidCallback? onTap;

  Color get _title {
    if (onNavy) return selected ? colors.bgNavy : colors.textOnNavy2;
    return selected ? colors.onPrimary : colors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = context.appText;
    final stacked = segment.hasCounter && !inline;
    final fade = context.motion(AppMotion.fast, reduced: AppMotion.reducedFade);

    final titleColor = stacked && !onNavy
        ? (selected ? colors.onPrimary : colors.textPrimary)
        : _title;
    final counterColor = onNavy
        ? (selected ? colors.bgNavy : colors.textOnNavy2)
        : (selected
              ? colors.onPrimary.withValues(alpha: 0.78)
              : colors.textSecondary);

    final base = stacked
        ? text.labelMd.copyWith(fontWeight: FontWeight.w700)
        : text.labelMd;
    final title = inline && segment.hasCounter
        ? '${segment.label} · ${segment.counter}'
        : segment.label;

    final label = [
      segment.label,
      if (segment.hasCounter) segment.counter!,
      if (selected) l10n.kit_a11ySelected,
      l10n.kit_a11yOptionOf(total, index + 1),
    ].join(', ');

    return Semantics(
      label: label,
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      enabled: onTap != null,
      excludeSemantics: true,
      onTap: onTap,
      child: AppPressable(
        onTap: onTap,
        scale: 1,
        builder: (context, states) => AppFocusRing(
          focused: states.contains(WidgetState.focused),
          style: AppFocusRingStyle.inset,
          borderRadius: AppRadius.borderSm,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s4,
                vertical: AppSpacing.s4 / 2,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FadingText(
                      text: title,
                      style: base,
                      color: titleColor,
                      duration: fade,
                    ),
                    if (stacked)
                      _FadingText(
                        text: segment.counter!,
                        style: text.caption,
                        color: counterColor,
                        duration: fade,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A centered line whose color cross-fades when the option is (de)selected.
class _FadingText extends StatelessWidget {
  const _FadingText({
    required this.text,
    required this.style,
    required this.color,
    required this.duration,
  });

  final String text;
  final TextStyle style;
  final Color color;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: color),
      duration: duration,
      builder: (context, value, _) => Text(
        text,
        textAlign: TextAlign.center,
        style: style.copyWith(color: value),
      ),
    );
  }
}
