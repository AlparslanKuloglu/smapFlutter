part of '../analytics_view.dart';

/// The Genel tab while it loads (pano 6.3 kare 1): bant and tabs are already
/// there; the pill (140 x 40, only on the very first load, later the real
/// pill stays), the chart card (304 high: a 120 x 20 title, 16, the 220 high
/// plot) and four boxes 88 high.
class _GeneralSkeleton extends StatelessWidget {
  const _GeneralSkeleton({required this.withPill});

  final bool withPill;

  /// Pano 6.3 kare 1: the pill, the plot and the box heights.
  static const double _pillWidth = 140;
  static const double _pillHeight = 40;
  static const double _plotHeight = 220;
  static const double _boxHeight = 88;
  static const double _titleWidth = 120;
  static const double _titleHeight = 20;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        _sectionGap,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: AppSkeleton(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (withPill) ...[
                const SkeletonBox(
                  width: _pillWidth,
                  height: _pillHeight,
                  radius: AppRadius.full,
                ),
                const SizedBox(height: _sectionGap),
              ],
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.bgSurface,
                  borderRadius: AppRadius.borderLg,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(AppSpacing.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: _titleWidth, height: _titleHeight),
                      SizedBox(height: AppSpacing.s16),
                      SkeletonBox.chart(height: _plotHeight),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: _sectionGap),
              const _SkeletonBoxRow(height: _boxHeight),
              const SizedBox(height: _boxGap),
              const _SkeletonBoxRow(height: _boxHeight),
            ],
          ),
        ),
      ),
    );
  }
}

/// Two skeleton boxes side by side (radius 16).
class _SkeletonBoxRow extends StatelessWidget {
  const _SkeletonBoxRow({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: SkeletonBox(height: height, radius: AppRadius.lg),
      ),
      const SizedBox(width: _boxGap),
      Expanded(
        child: SkeletonBox(height: height, radius: AppRadius.lg),
      ),
    ],
  );
}

/// The Genel tab failed (pano 6.3 kare 3): "Analizlerin yüklenemedi" /
/// "Bağlantını kontrol edip tekrar dene." / "Tekrar Dene". The tabs work and
/// Denemelerim loads on its own. Also the offline state without a saved
/// answer: the strip says why. No haptic.
class _GeneralError extends StatelessWidget {
  const _GeneralError();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<AnalyticsViewModel>(
      context,
      listen: false,
    );
    return SliverToBoxAdapter(
      child: AppErrorState.screen(
        title: l10n.analytics_errorTitle,
        message: l10n.analytics_errorMessage,
        onRetry: viewModel.retryGeneral,
      ),
    );
  }
}

/// The student has no exam at all (pano 6.2 kare 3; "Genel sekmesi de aynı
/// boş durumu gösterir"): the clay map, "Henüz deneme yok", one sentence and
/// "İlk Denemeni Okut", which opens the camera.
class _NoExamsEmpty extends StatelessWidget {
  const _NoExamsEmpty();

  /// The clay picture's edge (pano 6.2 kare 3: 128).
  static const double _picture = AppEmptyState.illustrationSize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<AnalyticsViewModel>(
      context,
      listen: false,
    );
    return SliverToBoxAdapter(
      child: AppEmptyState.screen(
        title: l10n.analytics_emptyTitle,
        message: l10n.analytics_emptyMessage,
        actionLabel: l10n.analytics_emptyAction,
        actionIcon: PhosphorIconsRegular.camera,
        onAction: viewModel.openCamera,
        illustration: Assets.illustrations.clayMap.image(
          width: _picture,
          height: _picture,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stack) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

/// A filter that leaves no exam while the student has some: the filter row
/// stays, with a short sentence and "Süzgeci Sıfırla" (back to all of TYT).
class _GeneralFilterEmpty extends StatelessWidget {
  const _GeneralFilterEmpty();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<AnalyticsViewModel>(
      context,
      listen: false,
    );
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        _sectionGap,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: AppEmptyState.section(
          message: l10n.analytics_filterEmpty,
          actionLabel: l10n.analytics_filterReset,
          onAction: () => viewModel.applyFilter(AnalyticsFilter.tyt),
        ),
      ),
    );
  }
}
