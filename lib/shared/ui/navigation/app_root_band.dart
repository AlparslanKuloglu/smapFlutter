import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/shared/ui/navigation/app_system_overlay.dart';
import 'package:smap/shared/ui/navigation/band_math.dart';

/// What a root band carries under its title (C80; pano 1.18 kare 2): the
/// screen's own control, so it stays pinned in the band instead of floating
/// over the list.
///
/// [AppRootBandBottom.segment] holds an `AppSegmented(onNavy: true)` (the
/// band becomes 178); [AppRootBandBottom.tabs] holds an
/// `AppTabBar(onNavy: true)` (174). A band with a bottom does not shrink.
///
/// [height] is the height of [child] when it is not the default (a segment
/// with counter lines, a wrapped label); the band takes it into account so
/// the list starts right under the control.
class AppRootBandBottom {
  const AppRootBandBottom.segment({
    required this.child,
    this.height,
    this.hasCounter = false,
  }) : kind = RootBandBottomKind.segment;

  const AppRootBandBottom.tabs({required this.child, this.height})
    : kind = RootBandBottomKind.tabs,
      hasCounter = false;

  final RootBandBottomKind kind;
  final Widget child;

  /// The child's height; null uses the kit's default at the current text
  /// scale.
  final double? height;

  /// Segment only: an option has a counter line ("28 eksik"), so the segment
  /// is two lines high.
  final bool hasCounter;
}

/// The navy band at the top of a tab root screen (C80 `SmapRootBand`; pano
/// 1.18 kare 1 to 3, 1.24 kare 1; UI guide §5 #32).
///
/// A pinned sliver: put it first in the screen's `CustomScrollView`.
/// `bgNavy` in both themes, bottom corners 24, the status bar over it (light
/// icons). The [title] is `title-lg` 24/32 · 700 in white, with at most one
/// [action] on the right, an `AppIconButton(variant: onNavy)` that has an
/// accessible name ("Yeni görüşme", "Öğrenci ekle"). No logo and no avatar
/// (those belong to the home band and the profile summary).
///
/// Height: 134 (62 safe area + 56 + 16). With [bottom] 178 (segment) or 174
/// (tabs). Without a bottom the band shrinks while the page scrolls: 134 to
/// 110, the title 24 to 17/24 and the bottom corners flat. The shrink has no
/// duration; it follows the scroll (a pinned header shrinks one point per
/// point, so it is done after 24 pt). [squareCorners] flattens the corners
/// for good: use it while the offline strip sits under the band.
class AppRootBand extends StatelessWidget {
  const AppRootBand({
    required this.title,
    this.action,
    this.bottom,
    this.squareCorners = false,
    this.safeTop,
    super.key,
  });

  /// "Görüşmelerim".
  final String title;

  /// The single action on the right.
  final Widget? action;

  /// The screen's segment or tab row.
  final AppRootBandBottom? bottom;

  /// Draw the bottom corners flat at every scroll position.
  final bool squareCorners;

  /// Override for the top safe area; the media padding when null (a gallery
  /// frame sets it).
  final double? safeTop;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final bottom = this.bottom;
    final metrics = RootBandMetrics(
      safeTop: safeTop ?? MediaQuery.paddingOf(context).top,
      bottom: bottom?.kind,
      bottomHeight: bottom == null
          ? null
          : bottom.height ??
                RootBandMetrics.defaultBottomHeight(
                  bottom.kind,
                  scaler,
                  counter: bottom.hasCounter,
                ),
      textScaler: scaler,
    );
    return SliverPersistentHeader(
      pinned: true,
      delegate: _RootBandDelegate(
        metrics: metrics,
        title: title,
        action: action,
        bottom: bottom,
        squareCorners: squareCorners,
      ),
    );
  }
}

class _RootBandDelegate extends SliverPersistentHeaderDelegate {
  _RootBandDelegate({
    required this.metrics,
    required this.title,
    required this.action,
    required this.bottom,
    required this.squareCorners,
  });

  final RootBandMetrics metrics;
  final String title;
  final Widget? action;
  final AppRootBandBottom? bottom;
  final bool squareCorners;

  @override
  double get maxExtent => metrics.maxExtent;

  @override
  double get minExtent => metrics.minExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = metrics.progressAt(shrinkOffset);
    return AppSystemOverlayRegion(
      kind: AppSystemOverlayKind.band,
      child: _RootBandSurface(
        metrics: metrics,
        progress: progress,
        title: title,
        action: action,
        bottom: bottom,
        squareCorners: squareCorners,
      ),
    );
  }

  @override
  bool shouldRebuild(_RootBandDelegate oldDelegate) =>
      title != oldDelegate.title ||
      action != oldDelegate.action ||
      bottom != oldDelegate.bottom ||
      squareCorners != oldDelegate.squareCorners ||
      metrics.safeTop != oldDelegate.metrics.safeTop ||
      metrics.maxExtent != oldDelegate.metrics.maxExtent ||
      metrics.textScaler != oldDelegate.metrics.textScaler;
}

class _RootBandSurface extends StatelessWidget {
  const _RootBandSurface({
    required this.metrics,
    required this.progress,
    required this.title,
    required this.action,
    required this.bottom,
    required this.squareCorners,
  });

  final RootBandMetrics metrics;
  final double progress;
  final String title;
  final Widget? action;
  final AppRootBandBottom? bottom;
  final bool squareCorners;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final radius = squareCorners ? 0.0 : RootBandMetrics.cornerAt(progress);
    final titleStyle = TextStyle.lerp(
      text.titleLg,
      text.headline,
      progress,
    )!.copyWith(color: colors.textOnNavy);
    final below = bottom;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bgNavy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(radius)),
      ),
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minHeight: 0,
          maxHeight: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: metrics.safeTop),
              SizedBox(
                height: RootBandMetrics.titleRowAt(progress),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: AppSpacing.gutter,
                          right: AppSpacing.s8,
                        ),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Semantics(
                            header: true,
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: titleStyle,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (action case final trailing?)
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.s4),
                        child: trailing,
                      ),
                  ],
                ),
              ),
              if (below != null)
                SizedBox(
                  height: metrics.bottomHeight,
                  child: below.kind == RootBandBottomKind.segment
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.gutter,
                          ),
                          child: below.child,
                        )
                      : below.child,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
