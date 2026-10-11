import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/smap_colors.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/controls/clear_color.dart';

/// The loading placeholder region (C76 "Skeleton"; board 1.22 kare 2; UI
/// guide §5 #28).
///
/// Lay the screen's real shape out with [SkeletonBox]es inside it (title,
/// chart, four boxes) and it draws one shimmer over all of them: a 120 pt
/// wide band that runs from the left edge to the right in 1200 ms, linear,
/// repeating (`AppMotion.loop`). The band is white at 65 % in light theme
/// (the design leaves the dark one open: here `borderStrong`, one step
/// lighter than the `bgSunken` blocks). Under "Reduce motion" nothing
/// moves and the blocks stay flat `bgSunken`. The bar and tabs of the screen
/// are not part of it: they come at once.
///
/// A skeleton is not endless: the owner limits it to 15 s
/// (`withSkeletonTimeout`, `AsyncSection.load`) and then draws an
/// `AppErrorState`. For the screen reader the region is one busy
/// element named [semanticLabel] ("Yükleniyor"); the blocks are skipped.
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({required this.child, this.semanticLabel, super.key});

  /// The layout of [SkeletonBox]es.
  final Widget child;

  /// Read instead of the blocks; "Yükleniyor" by default.
  final String? semanticLabel;

  /// Width of the shimmer band.
  static const double bandWidth = 120;

  /// Opacity of the light band at its center.
  static const double bandAlpha = 0.65;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.loop,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Repeating an idle controller costs frames for nothing: run it only
    // while motion is allowed.
    if (context.reduceMotion) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _highlight(SmapColors colors) =>
      Theme.brightnessOf(context) == Brightness.dark
      ? colors.borderStrong
      : colors.bgSurface;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final label =
        widget.semanticLabel ?? AppLocalizations.of(context).kit_loading;
    final blocks = ExcludeSemantics(child: widget.child);
    Widget body = blocks;
    if (!context.reduceMotion) {
      final highlight = _highlight(colors);
      body = RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          child: blocks,
          builder: (context, child) => ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) {
              final travel = bounds.width + AppSkeleton.bandWidth;
              final left = -AppSkeleton.bandWidth + travel * _controller.value;
              return ui.Gradient.linear(
                Offset(bounds.left + left, 0),
                Offset(bounds.left + left + AppSkeleton.bandWidth, 0),
                [
                  highlight.clear,
                  highlight.withValues(alpha: AppSkeleton.bandAlpha),
                  highlight.clear,
                ],
                const [0, 0.5, 1],
              );
            },
            child: child,
          ),
        ),
      );
    }
    return Semantics(
      label: label,
      container: true,
      liveRegion: true,
      child: body,
    );
  }
}

/// One placeholder block with the corners of the real component (C76:
/// radius 8, 12 for a chart block; [circle] for avatars).
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    this.width,
    this.height = 16,
    this.radius = AppRadius.sm,
    this.circle = false,
    super.key,
  });

  /// A chart block (radius 12).
  const SkeletonBox.chart({this.width, this.height = 200, super.key})
    : radius = AppRadius.md,
      circle = false;

  /// Null fills the available width.
  final double? width;
  final double height;
  final double radius;

  /// A round block (avatar, glyph); [height] is the diameter.
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final fill = context.appColors.bgSunken;
    return SizedBox(
      width: circle ? height : width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle
              ? null
              : BorderRadius.all(Radius.circular(radius)),
        ),
      ),
    );
  }
}
