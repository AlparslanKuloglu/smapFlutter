import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_bar_action.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/buttons/app_icon_button.dart';
import 'package:smap/shared/ui/navigation/app_system_overlay.dart';
import 'package:smap/shared/ui/navigation/band_math.dart';

/// The left item of a detail bar (C82 "Alternatif sol öğe").
enum AppDetailBarLeading {
  /// CaretLeft, "Geri": every pushed screen.
  back,

  /// X, "Kapat": the first step of a full-screen flow and the screens after
  /// the camera.
  close,

  /// The text "Vazgeç": edit mode of the profile (9.2).
  cancel,

  /// Nothing (3.6, program edit mode).
  none,
}

/// The light bar of a detail screen (C82 `SmapDetailBar`; pano 1.18 kare 4
/// and 5, 1.24 kare 2; UI guide §5 #33).
///
/// A pinned sliver on the canvas color; put it first in the screen's
/// `CustomScrollView`, followed by a [LargeTitleSliver] with the same
/// [title]. The bar is the safe area plus 48 (110) and holds the [leading]
/// item (back by default, 48 wide) and at most one [action] on the right: an
/// `AppIconButton` (48) or an `AppBarAction` (40; then the right padding is
/// 16 instead of 4).
///
/// The title lives big in the content. Once it has scrolled up under the bar,
/// the same text shows in the bar, `barTitle` 17/24 · 700, left aligned, two
/// lines at most, and a 1 pt `borderSubtle` divider appears under the bar
/// (spec Ç-21; the board drew 15/20 and centered). The hand-over follows the
/// scroll, it has no duration. [compactTitle] replaces the text when a
/// shorter one reads better in the bar. Under a navy band the status bar
/// icons are light, here dark in the light theme.
///
/// Put the bar first: it reads the scroll offset of its own sliver. The back
/// button calls [onLeading], by default `Navigator.maybePop` (Android's
/// system back works on its own). A coach's student screens add a pinned
/// `AppContextStrip` right after it.
class AppDetailBar extends StatelessWidget {
  const AppDetailBar({
    required this.title,
    this.compactTitle,
    this.action,
    this.leading = AppDetailBarLeading.back,
    this.onLeading,
    this.display = false,
    this.gutter = AppSpacing.gutter,
    this.safeTop,
    this.compactAlways = false,
    super.key,
  });

  /// The page title, as the [LargeTitleSliver] shows it.
  final String title;

  /// A shorter title for the bar.
  final String? compactTitle;

  /// The single action on the right.
  final Widget? action;
  final AppDetailBarLeading leading;

  /// What the left item does; pops the route when null.
  final VoidCallback? onLeading;

  /// The large title uses `display` (sign-in screens).
  final bool display;

  /// The large title's side padding, to measure it exactly.
  final double gutter;

  /// Override for the top safe area (gallery frames).
  final double? safeTop;

  /// The bar shows its compact title (and the divider) from the start, with
  /// no large title under it: a screen that opens already "scrolled" (the
  /// week grid of pano 3.4 kare 4, "Başlık bara inmiş").
  final bool compactAlways;

  @override
  Widget build(BuildContext context) {
    final text = context.appText;
    final scaler = MediaQuery.textScalerOf(context);
    final width = MediaQuery.sizeOf(context).width - 2 * gutter;
    final titleHeight = LargeTitleMetrics.titleHeight(
      title: title,
      style: display ? text.display : text.titleLg,
      width: width,
      textScaler: scaler,
      textDirection: Directionality.of(context),
    );
    final metrics = DetailBarMetrics(
      safeTop: safeTop ?? MediaQuery.paddingOf(context).top,
      textScaler: scaler,
    );
    return SliverPersistentHeader(
      pinned: true,
      delegate: _DetailBarDelegate(
        metrics: metrics,
        titleBottom: LargeTitleMetrics.titleBottom(titleHeight),
        bar: this,
      ),
    );
  }
}

class _DetailBarDelegate extends SliverPersistentHeaderDelegate {
  _DetailBarDelegate({
    required this.metrics,
    required this.titleBottom,
    required this.bar,
  });

  final DetailBarMetrics metrics;
  final double titleBottom;
  final AppDetailBar bar;

  @override
  double get maxExtent => metrics.extent;

  @override
  double get minExtent => metrics.extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = bar.compactAlways
        ? 1.0
        : DetailBarMetrics.revealProgress(
            shrinkOffset,
            titleBottom: titleBottom,
          );
    return AppSystemOverlayRegion(
      kind: AppSystemOverlayKind.bar,
      child: _DetailBarSurface(bar: bar, metrics: metrics, progress: progress),
    );
  }

  @override
  bool shouldRebuild(_DetailBarDelegate oldDelegate) =>
      titleBottom != oldDelegate.titleBottom ||
      metrics.extent != oldDelegate.metrics.extent ||
      bar.title != oldDelegate.bar.title ||
      bar.compactTitle != oldDelegate.bar.compactTitle ||
      bar.action != oldDelegate.bar.action ||
      bar.leading != oldDelegate.bar.leading ||
      bar.onLeading != oldDelegate.bar.onLeading ||
      bar.compactAlways != oldDelegate.bar.compactAlways;
}

class _DetailBarSurface extends StatelessWidget {
  const _DetailBarSurface({
    required this.bar,
    required this.metrics,
    required this.progress,
  });

  final AppDetailBar bar;
  final DetailBarMetrics metrics;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final action = bar.action;
    final hasLeading = bar.leading != AppDetailBarLeading.none;
    // A 40 pt BarAction keeps 16 from the edge; a 48 pt icon button 4.
    final rightPad = action is AppBarAction ? AppSpacing.gutter : AppSpacing.s4;

    return ColoredBox(
      color: colors.bgCanvas,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: metrics.safeTop, right: rightPad),
            child: SizedBox(
              height: metrics.rowHeight,
              child: Row(
                children: [
                  if (hasLeading)
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.s4),
                      child: _Leading(
                        kind: bar.leading,
                        onPressed: bar.onLeading,
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: hasLeading ? AppSpacing.s4 : AppSpacing.gutter,
                        right: AppSpacing.s8,
                      ),
                      child: _CompactTitle(
                        title: bar.compactTitle ?? bar.title,
                        progress: progress,
                      ),
                    ),
                  ),
                  ?action,
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 1,
            child: Opacity(
              opacity: progress,
              child: ColoredBox(color: colors.borderSubtle),
            ),
          ),
        ],
      ),
    );
  }
}

class _Leading extends StatelessWidget {
  const _Leading({required this.kind, required this.onPressed});

  final AppDetailBarLeading kind;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    void pop() => Navigator.maybePop(context);
    return switch (kind) {
      AppDetailBarLeading.back => AppIconButton(
        icon: PhosphorIconsRegular.caretLeft,
        semanticLabel: l10n.nav_back,
        onPressed: onPressed ?? pop,
      ),
      AppDetailBarLeading.close => AppIconButton(
        icon: PhosphorIconsRegular.x,
        semanticLabel: l10n.common_close,
        onPressed: onPressed ?? pop,
      ),
      AppDetailBarLeading.cancel => AppButton(
        label: l10n.common_cancel,
        variant: AppButtonVariant.text,
        size: AppButtonSize.md40,
        onPressed: onPressed ?? pop,
      ),
      AppDetailBarLeading.none => const SizedBox.shrink(),
    };
  }
}

class _CompactTitle extends StatelessWidget {
  const _CompactTitle({required this.title, required this.progress});

  final String title;
  final double progress;

  /// How far the title rises into place while it fades in.
  static const double _rise = 6;

  @override
  Widget build(BuildContext context) {
    final rise = context.reduceMotion ? 0.0 : (1 - progress) * _rise;
    return ExcludeSemantics(
      // The large title is the page's heading until the bar shows its own.
      excluding: progress < 1,
      child: Opacity(
        opacity: progress,
        child: Transform.translate(
          offset: Offset(0, rise),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Semantics(
              header: true,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.appText.barTitle.copyWith(
                  color: context.appColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
