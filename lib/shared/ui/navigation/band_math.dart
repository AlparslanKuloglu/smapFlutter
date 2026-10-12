import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// What sits under the title row of an `AppRootBand` (C80; board 1.18 frame
/// 2, spec C80 "Bant altı").
enum RootBandBottomKind {
  /// A `AppSegmented` (onNavy): 44 high, 16 below it. The band is 178.
  segment,

  /// A `AppTabBar` (onNavy): 48 high, 8 below it. The band is 174.
  tabs,
}

/// Student or coach side of the home band (C81).
enum AppHomeBandRole { student, coach }

/// The pure numbers behind the three top bars (C80, C81, C82): extents,
/// the scroll-linked progress and the interpolations. Widgets only draw
/// them; the rules are tested here (UI guide §6 "saf mantık").
///
/// All "scroll progress" values follow the sliver: a pinned
/// `SliverPersistentHeader` shrinks one point per point of scroll, so a band
/// that goes from 134 to 110 is done after 24 pt. The title size and the
/// corner radius ride the same 0..1 progress, so the three never disagree.
abstract final class BandMath {
  /// 0 when the band is fully open, 1 when it has shrunk to [minExtent].
  /// A band that cannot shrink ([maxExtent] equals [minExtent]) stays at 0.
  static double progress(
    double shrinkOffset, {
    required double maxExtent,
    required double minExtent,
  }) {
    final range = maxExtent - minExtent;
    if (range <= 0) return 0;
    return (shrinkOffset / range).clamp(0.0, 1.0);
  }

  /// Height of the band after [shrinkOffset] points of scroll.
  static double extentAt(
    double shrinkOffset, {
    required double maxExtent,
    required double minExtent,
  }) => math.max(minExtent, maxExtent - shrinkOffset);

  /// Linear interpolation from [from] at progress 0 to [to] at progress 1.
  static double lerp(double from, double to, double progress) =>
      from + (to - from) * progress;
}

/// Extents of the root band (C80; board 1.18 frames 1 to 3; Düzeltmeler (b)).
///
/// `safeTop + 56 + 16 = 134`; with a segment `62 + 56 + 44 + 16 = 178`; with
/// a tab row `62 + 56 + 48 + 8 = 174`. A band without a segment or tab
/// shrinks to `safeTop + 48 = 110`, its title from 24/32 to 17/24 and its
/// bottom corners from 24 to 0. A band that carries the screen's own control
/// does not shrink at all (spec C80: the segment stays pinned; Düzeltmeler
/// (b): "segmentli bant küçülmüyor").
class RootBandMetrics {
  const RootBandMetrics({
    required this.safeTop,
    this.bottom,
    this.bottomHeight,
    this.textScaler = TextScaler.noScaling,
  });

  /// Title row, expanded.
  static const double titleRow = 56;

  /// Title row, collapsed.
  static const double collapsedRow = 48;

  /// Space under the title row when nothing sits under it.
  static const double plainGap = 16;

  /// Space under a segment.
  static const double segmentGap = 16;

  /// Space under a tab row.
  static const double tabsGap = 8;

  /// Segment height at text scale 1 (36 thumb + 4 + 4 track padding).
  static const double segmentBase = 44;

  /// Segment height at text scale 1 when an option has a counter line.
  static const double segmentWithCounterBase = 56;

  /// Tab row height at text scale 1 (C05: 48).
  static const double tabsBase = 48;

  /// Bottom corner radius of an open band (`radius-xl`).
  static const double cornerRadius = 24;

  /// Safe area at the top (status bar and Dynamic Island), 62 on the
  /// reference frame.
  final double safeTop;

  /// What is under the title row; null for a plain band.
  final RootBandBottomKind? bottom;

  /// Measured height of that area; [defaultBottomHeight] when null.
  final double? bottomHeight;

  /// The platform text scale (the band grows with it where it must).
  final TextScaler textScaler;

  /// Default height of the area under the title row at [textScaler]; the
  /// formulas follow `AppSegmented` and `AppTabBar`.
  static double defaultBottomHeight(
    RootBandBottomKind kind,
    TextScaler textScaler, {
    bool counter = false,
  }) => switch (kind) {
    RootBandBottomKind.segment =>
      counter
          ? math.max(segmentWithCounterBase, textScaler.scale(20) * 2 + 12)
          : math.max(segmentBase, textScaler.scale(20) + 12),
    // AppTabBar: a 15/24 label with 12 above and below and a 3 pt line.
    RootBandBottomKind.tabs => math.max(tabsBase, textScaler.scale(24) + 27),
  };

  double get _bottomArea {
    final kind = bottom;
    if (kind == null) return 0;
    return bottomHeight ?? defaultBottomHeight(kind, textScaler);
  }

  double get _gap => switch (bottom) {
    null => plainGap,
    RootBandBottomKind.segment => segmentGap,
    RootBandBottomKind.tabs => tabsGap,
  };

  /// Whether the band shrinks while the page scrolls.
  bool get collapses => bottom == null;

  /// Band height with the safe area, fully open.
  double get maxExtent => safeTop + titleRow + _bottomArea + _gap;

  /// Band height at the end of the shrink (equal to [maxExtent] when the
  /// band does not collapse).
  double get minExtent => collapses ? safeTop + collapsedRow : maxExtent;

  /// Progress 0..1 after [shrinkOffset] points of scroll.
  double progressAt(double shrinkOffset) => BandMath.progress(
    shrinkOffset,
    maxExtent: maxExtent,
    minExtent: minExtent,
  );

  /// Band height after [shrinkOffset] points of scroll.
  double extentAt(double shrinkOffset) => BandMath.extentAt(
    shrinkOffset,
    maxExtent: maxExtent,
    minExtent: minExtent,
  );

  /// Height of the title row at [progress].
  static double titleRowAt(double progress) =>
      BandMath.lerp(titleRow, collapsedRow, progress);

  /// Bottom corner radius at [progress]: 24 open, flat when shrunk.
  static double cornerAt(double progress) =>
      BandMath.lerp(cornerRadius, 0, progress);
}

/// Extents of the home band (C81; board 3.1 frames 1 and 2, 10.1).
///
/// Student: `62 + 56 + 8 + 48 + 20 = 194` with the counter, `62 + 56 + 20 =
/// 138` without. Coach: `62 + 56 + 20 = 138`. Both shrink to `62 + 48 =
/// 110`. At large text the band grows with its content instead of cutting
/// it: the open greeting may wrap to two lines ([greetingHeight], measured
/// by the band at the width it gets) and the counter row is as tall as its
/// tallest part ([counterHeight]: the figure, or "gün kaldı" plus the exam
/// date, which wraps). Collapsed, the greeting is one line and may end in
/// an ellipsis ([greetingMaxLines]).
class HomeBandMetrics {
  const HomeBandMetrics({
    required this.role,
    required this.safeTop,
    this.hasCounter = true,
    this.greetingHeight,
    this.subtitleHeight,
    this.counterHeight,
    this.textScaler = TextScaler.noScaling,
  });

  /// Avatar and greeting row, expanded (min).
  static const double row = 56;

  /// Row when collapsed.
  static const double collapsedRow = 48;

  /// Gap between the greeting row and the counter row.
  static const double counterGap = 8;

  /// Counter row height at text scale 1 (metric-lg 40/48).
  static const double counterRowBase = 48;

  /// Space under the content of an open band.
  static const double bottomPadding = 20;

  /// Avatar edge, open and collapsed (C81: 40 and 32).
  static const double avatarOpen = 40;
  static const double avatarCollapsed = 32;

  /// The greeting may wrap to this many lines while the band is open.
  static const int openGreetingLines = 2;

  /// Scroll progress up to which the greeting keeps its two lines; after it
  /// the greeting is one line (ellipsis allowed) so it fits the shrinking
  /// row.
  static const double twoLineUntil = 0.25;

  final AppHomeBandRole role;
  final double safeTop;

  /// Student only: whether the YKS counter row exists.
  final bool hasCounter;

  /// The measured height of the open greeting (up to two lines at the width
  /// it gets); one scaled line (20/28) when null.
  final double? greetingHeight;

  /// Coach only: the measured height of the sub line (it may wrap to two
  /// lines on a narrow screen or at large text); one scaled line (13/20)
  /// when null.
  final double? subtitleHeight;

  /// Student only: the measured height of the counter row; one scaled
  /// metric line when null.
  final double? counterHeight;
  final TextScaler textScaler;

  bool get _hasCounterRow => role == AppHomeBandRole.student && hasCounter;

  /// Greeting row when open: 56 for a student; a coach also fits the sub
  /// line (13/20) under the greeting, and both grow at large text.
  double get openRow {
    final greeting = greetingHeight ?? textScaler.scale(28);
    return role == AppHomeBandRole.coach
        ? math.max(row, greeting + (subtitleHeight ?? textScaler.scale(20)))
        : math.max(row, greeting);
  }

  /// Counter row height at the current text scale: the figure alone.
  double get counterRow => textScaler.scale(counterRowBase);

  /// The counter row as laid out: at least [counterRow], and as tall as the
  /// measured [counterHeight].
  double get counterRowOpen => math.max(counterRow, counterHeight ?? 0);

  double get maxExtent =>
      safeTop +
      openRow +
      (_hasCounterRow ? counterGap + counterRowOpen : 0) +
      bottomPadding;

  double get minExtent =>
      safeTop + math.max(collapsedRow, textScaler.scale(24));

  double progressAt(double shrinkOffset) => BandMath.progress(
    shrinkOffset,
    maxExtent: maxExtent,
    minExtent: minExtent,
  );

  double extentAt(double shrinkOffset) => BandMath.extentAt(
    shrinkOffset,
    maxExtent: maxExtent,
    minExtent: minExtent,
  );

  /// Avatar edge at [progress].
  static double avatarAt(double progress) =>
      BandMath.lerp(avatarOpen, avatarCollapsed, progress);

  /// Lines the greeting may use at [progress]: two while the band is open,
  /// one once it has started to shrink.
  static int greetingMaxLines(double progress) =>
      progress < twoLineUntil ? openGreetingLines : 1;

  /// Opacity of the open-only content (counter row, coach sub line): gone
  /// before the band is half shrunk so it never crowds the greeting.
  static double openContentOpacity(double progress) =>
      (1 - progress * 2).clamp(0.0, 1.0);

  /// Opacity of the collapsed-only content (the one-line counter): appears in
  /// the second half of the shrink.
  static double collapsedContentOpacity(double progress) =>
      (progress * 2 - 1).clamp(0.0, 1.0);

  /// Share of its width the collapsed one-line counter takes at [progress]:
  /// none while the band is open, so the greeting gets the whole row (it
  /// used to be cut to "Merhaba, Al…" by a hidden counter).
  static double collapsedCounterWidthFactor(double progress) =>
      collapsedContentOpacity(progress);
}

/// Numbers of the detail bar (C82; board 1.18 frames 4 and 5).
///
/// The bar is `safeTop + 48` (110) and never changes height. The page title
/// sits big in the content ([LargeTitleMetrics]); once it has scrolled up
/// under the bar the same text appears small in the bar and a 1 pt divider
/// fades in. That hand-over is [revealProgress].
class DetailBarMetrics {
  const DetailBarMetrics({
    required this.safeTop,
    this.textScaler = TextScaler.noScaling,
  });

  /// Row under the safe area at text scale 1.
  static const double row = 48;

  /// Scroll distance over which the compact title fades in.
  static const double revealRange = 16;

  final double safeTop;
  final TextScaler textScaler;

  /// The row grows at large text so a two-line compact title (17/24) fits.
  double get rowHeight => math.max(row, 2 * textScaler.scale(24));

  /// Bar height with the safe area.
  double get extent => safeTop + rowHeight;

  /// 0..1: how far the compact title and the divider have faded in at
  /// [scrollOffset]. The reveal starts [revealRange] points before the large
  /// title is completely under the bar: [titleBottom] is the scroll offset
  /// at which the large title's last line has gone (its top padding plus its
  /// height).
  static double revealProgress(
    double scrollOffset, {
    required double titleBottom,
    double range = revealRange,
  }) {
    final start = math.max(0.0, titleBottom - range);
    return ((scrollOffset - start) / range).clamp(0.0, 1.0);
  }
}

/// Measures the big page title of a detail screen (C82 "Büyük başlık":
/// 24/32 · 700, up to three lines, padding 8/16/0).
abstract final class LargeTitleMetrics {
  /// Space above the title.
  static const double topPadding = 8;

  /// The title may wrap to three lines (C82).
  static const int maxLines = 3;

  /// Height of [title] laid out at [width] in [style], capped at three lines.
  static double titleHeight({
    required String title,
    required TextStyle style,
    required double width,
    required TextScaler textScaler,
    required TextDirection textDirection,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: title, style: style),
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: maxLines,
    )..layout(maxWidth: math.max(0, width));
    final height = painter.height;
    painter.dispose();
    return height;
  }

  /// The scroll offset at which the whole large title has passed under the
  /// bar: top padding plus its height.
  static double titleBottom(double titleHeight) => topPadding + titleHeight;
}
