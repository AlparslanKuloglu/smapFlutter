part of '../era_detail_view.dart';

/// The bar of the era detail: Back, and the era's name once the title under it
/// has scrolled away (pano 14.5 kare 2).
class _EraBar extends SelectorViewModelWidget<EraDetailViewModel, String> {
  const _EraBar();

  @override
  String selector(EraDetailViewModel viewModel) => viewModel.title;

  @override
  Widget build(BuildContext context, String data) => AppDetailBar(title: data);
}

/// The title block (pano 14.5 kare 2): the era's name 24/32 · 700 and the tag
/// "2 eksik eser" 8 under it, nothing drawn for none. Until the name is known
/// the skeleton of those two lines.
class _EraTitle
    extends SelectorViewModelWidget<EraDetailViewModel, EraHeaderData> {
  const _EraTitle();

  @override
  EraHeaderData selector(EraDetailViewModel viewModel) => viewModel.header;

  @override
  Widget build(BuildContext context, EraHeaderData data) {
    final name = data.name;
    if (name == null) return const _TitleSkeleton();
    final missing = data.missing ?? 0;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.s8,
          AppSpacing.gutter,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                name,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: context.appText.titleLg.copyWith(
                  color: context.appColors.textPrimary,
                ),
              ),
            ),
            if (missing > 0) ...[
              const SizedBox(height: AppSpacing.s8),
              Semantics(
                liveRegion: true,
                child: EksikTag(count: missing, works: true),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The title block while the era is not known: a name line and a tag line.
class _TitleSkeleton extends StatelessWidget {
  const _TitleSkeleton();

  @override
  Widget build(BuildContext context) => const SliverToBoxAdapter(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s8,
        AppSpacing.gutter,
        0,
      ),
      child: AppSkeleton(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 200, height: 28),
            SizedBox(height: AppSpacing.s8),
            SkeletonBox(width: 110, height: 24),
          ],
        ),
      ),
    ),
  );
}
