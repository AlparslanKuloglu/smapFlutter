import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/debug/launch_env.dart';

/// Scroll area of one gallery page: 16 pt page edge, a column of sections.
/// `GALLERY_SCROLL` (process environment, pixels) starts it scrolled, so a
/// screenshot run can walk a long page without taps.
class GalleryPageFrame extends StatefulWidget {
  const GalleryPageFrame({required this.child, super.key});

  final Widget child;

  @override
  State<GalleryPageFrame> createState() => _GalleryPageFrameState();
}

class _GalleryPageFrameState extends State<GalleryPageFrame> {
  final ScrollController _scroll = ScrollController(
    initialScrollOffset:
        double.tryParse(debugLaunchEnv('GALLERY_SCROLL') ?? '') ?? 0,
  );

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s16,
        AppSpacing.gutter,
        AppSpacing.s64,
      ),
      child: widget.child,
    );
  }
}

/// A titled block of a gallery page: the component name with its code in the
/// title, an optional note and the demos.
class GallerySection extends StatelessWidget {
  const GallerySection({
    required this.title,
    required this.children,
    this.note,
    super.key,
  });

  /// "AppButton · C01 · pano 1.9".
  final String title;

  /// A line under the title: the rule the demos show.
  final String? note;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: text.titleMd.copyWith(color: colors.textPrimary),
            ),
          ),
          if (note case final line?) ...[
            const SizedBox(height: AppSpacing.s4),
            Text(
              line,
              style: text.caption.copyWith(color: colors.textSecondary),
            ),
          ],
          const SizedBox(height: AppSpacing.s16),
          for (final (i, child) in children.indexed) ...[
            if (i > 0) const SizedBox(height: AppSpacing.s16),
            child,
          ],
        ],
      ),
    );
  }
}

/// A small caption naming a state ("Basılı", "Pasif").
class GalleryLabel extends StatelessWidget {
  const GalleryLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Text(
        label,
        style: context.appText.caption.copyWith(
          color: context.appColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// A caption with its demo underneath.
class GalleryState extends StatelessWidget {
  const GalleryState({required this.label, required this.child, super.key});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [GalleryLabel(label), child],
    );
  }
}

/// Demos side by side, wrapping.
class GalleryWrap extends StatelessWidget {
  const GalleryWrap({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.s16,
      runSpacing: AppSpacing.s16,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: children,
    );
  }
}

/// The surface a demo sits on.
enum GalleryTone {
  /// The page background.
  canvas,

  /// A card surface.
  surface,

  /// The sheet surface.
  raised,

  /// The navy root band.
  navy,
}

/// A padded rounded panel on a given surface, so a component is seen on the
/// background it is designed for (the navy variants on navy, the sheet
/// controls on the sheet color).
class GalleryPanel extends StatelessWidget {
  const GalleryPanel({
    required this.child,
    this.tone = GalleryTone.surface,
    super.key,
  });

  final Widget child;
  final GalleryTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final fill = switch (tone) {
      GalleryTone.canvas => colors.bgCanvas,
      GalleryTone.surface => colors.bgSurface,
      GalleryTone.raised => colors.bgRaised,
      GalleryTone.navy => colors.bgNavy,
    };
    return DecoratedBox(
      decoration: BoxDecoration(color: fill, borderRadius: AppRadius.borderLg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}

/// A line of plain explanation under a demo.
class GalleryNote extends StatelessWidget {
  const GalleryNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.appText.caption.copyWith(
        color: context.appColors.textSecondary,
      ),
    );
  }
}

/// A short label drawn on the navy panel.
class GalleryOnNavyLabel extends StatelessWidget {
  const GalleryOnNavyLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: context.appText.labelMd.copyWith(
          color: context.appColors.textOnNavy,
        ),
      ),
    );
  }
}
