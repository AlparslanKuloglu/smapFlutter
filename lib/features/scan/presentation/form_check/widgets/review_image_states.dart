part of '../scan_review_view.dart';

/// The 346 x 212 skeleton with "Form görüntüsü yükleniyor" (13/20 · 600).
class _ImageSkeleton extends StatelessWidget {
  const _ImageSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    return AppSkeleton(
      semanticLabel: l10n.scan_imageLoading,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const SkeletonBox(height: double.infinity, radius: AppRadius.sm),
          Center(
            child: Text(
              l10n.scan_imageLoading,
              style: text.caption.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Görüntü yüklenemedi" with the text button "Tekrar Dene" (pano 4.8 kare 1
/// note: the section error pattern, in the image's place).
class _ImageFailed extends StatelessWidget {
  const _ImageFailed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bgSunken,
        borderRadius: AppRadius.borderSm,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              liveRegion: true,
              child: Text(
                l10n.scan_imageLoadFailed,
                style: text.body.copyWith(color: colors.textSecondary),
              ),
            ),
            AppButton(
              label: l10n.common_retry,
              variant: AppButtonVariant.text,
              size: AppButtonSize.md40,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

/// "Formu büyüt": a 48 pt target around a 40 pt white circle (94 %) with a
/// MagnifyingGlassPlus in `primary`, the `raised` shadow under it.
class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.onPressed, required this.size});

  final VoidCallback onPressed;
  final double size;

  /// The circle's white at 94 %.
  static const double _alpha = 0.94;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.scan_zoomFormA11y,
      excludeSemantics: true,
      onTap: onPressed,
      child: Tooltip(
        message: l10n.scan_zoomFormA11y,
        excludeFromSemantics: true,
        child: AppPressable(
          onTap: onPressed,
          builder: (context, states) => SizedBox.square(
            dimension: AppSize.touch,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.bgRaised.withValues(alpha: _alpha),
                  boxShadow: AppShadows.raisedOf(context),
                ),
                child: SizedBox.square(
                  dimension: size,
                  child: Center(
                    child: PhosphorIcon(
                      PhosphorIconsRegular.magnifyingGlassPlus,
                      size: 20,
                      color: colors.primary,
                    ),
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
