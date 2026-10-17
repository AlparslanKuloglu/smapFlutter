part of '../lesson_detail_view.dart';

/// The era list of the Edebiyat detail (pano 14.5 kare 1, 14.7 kare 1): the
/// skeleton, the card of era rows, or "Dönemler yüklenemedi." with "Tekrar
/// Dene" under the segment. Nothing while the topics show.
class _LessonErasSection
    extends
        SelectorViewModelWidget<LessonDetailViewModel, (LessonErasData, bool)> {
  const _LessonErasSection();

  @override
  (LessonErasData, bool) selector(LessonDetailViewModel viewModel) =>
      (viewModel.eras, viewModel.showsEras);

  @override
  Widget build(BuildContext context, (LessonErasData, bool) data) {
    final (eras, show) = data;
    if (!show) return _noSliver;
    return switch (eras.state) {
      SectionState.loading => const _TopicsSkeleton(),
      SectionState.ready => _EraRowsCard(data: eras),
      SectionState.empty ||
      SectionState.error ||
      SectionState.offline => const _ErasError(),
    };
  }
}

/// The card of era rows (C22 `TopicRow` in its era form, 28 pt number, name,
/// "2 eksik eser"; pano 14.5 kare 1). The server's order, no author count
/// (the answer has none). A row opens the era detail.
class _EraRowsCard extends StatelessWidget {
  const _EraRowsCard({required this.data});

  final LessonErasData data;

  @override
  Widget build(BuildContext context) {
    final viewModel = getParentViewModel<LessonDetailViewModel>(
      context,
      listen: false,
    );
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s16,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: AppRowGroup(
          children: [
            for (final era in data.eras)
              TopicRow(
                key: ValueKey(era.id),
                number: era.number,
                name: era.name,
                missing: era.missing,
                missingWorks: true,
                onTap: () => viewModel.openEra(era.id),
              ),
          ],
        ),
      ),
    );
  }
}

/// The era list did not load: the section error under the segment, "Dönemler
/// yüklenemedi." and the text button "Tekrar Dene" (pano 14.7).
class _ErasError extends StatelessWidget {
  const _ErasError();

  @override
  Widget build(BuildContext context) {
    final viewModel = getParentViewModel<LessonDetailViewModel>(
      context,
      listen: false,
    );
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s16,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: AppErrorState.section(
          message: AppLocalizations.of(context).literature_eraListError,
          onRetry: viewModel.retryEras,
        ),
      ),
    );
  }
}
