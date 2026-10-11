import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';

/// The big page title of a detail screen, in the content (C82 "Büyük
/// başlık"; pano 1.18 kare 4 and 6).
///
/// `title-lg` 24/32 · 700 (`display` 32/40 · 800 on the sign-in and sign-up
/// screens), up to three lines, padding 8/16/0 (24 at the sides on the 2.x
/// screens: pass `gutter: AppSpacing.gutterAuth`). It is the page's heading
/// for screen readers. When it has scrolled up under the bar,
/// `AppDetailBar` shows the same text small; give both the same [title],
/// [display] and [gutter].
///
/// A sliver: put it right after the `AppDetailBar`.
class LargeTitleSliver extends StatelessWidget {
  const LargeTitleSliver({
    required this.title,
    this.display = false,
    this.gutter = AppSpacing.gutter,
    super.key,
  });

  /// "Türkçe", "Türkiye Geneli Deneme 6".
  final String title;

  /// The `display` style instead of `title-lg`.
  final bool display;

  /// Side padding.
  final double gutter;

  @override
  Widget build(BuildContext context) {
    final text = context.appText;
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 0),
        child: Semantics(
          header: true,
          child: Text(
            title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: (display ? text.display : text.titleLg).copyWith(
              color: context.appColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
