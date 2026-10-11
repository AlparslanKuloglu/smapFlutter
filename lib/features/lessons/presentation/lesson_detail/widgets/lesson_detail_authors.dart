part of '../lesson_detail_view.dart';

/// The author list of the Edebiyat detail (pano 7.4 kare 1): the skeleton,
/// the card of author rows (C28), the empty note or the error state. Nothing
/// while the topics show.
class _LessonAuthorsSection
    extends
        SelectorViewModelWidget<
          LessonDetailViewModel,
          (LessonAuthorsData, bool)
        > {
  const _LessonAuthorsSection();

  @override
  (LessonAuthorsData, bool) selector(LessonDetailViewModel viewModel) =>
      (viewModel.authors, viewModel.showsAuthors);

  @override
  Widget build(BuildContext context, (LessonAuthorsData, bool) data) {
    final (authors, show) = data;
    if (!show) return _noSliver;
    return switch (authors.state) {
      SectionState.loading => const _AuthorsSkeleton(),
      SectionState.ready => _AuthorRowsCard(data: authors),
      SectionState.empty => const _AuthorsEmpty(),
      SectionState.error || SectionState.offline => const _AuthorsError(),
    };
  }
}

/// The card of author rows: photo or initials, name, era (pano 7.4).
class _AuthorRowsCard extends StatelessWidget {
  const _AuthorRowsCard({required this.data});

  final LessonAuthorsData data;

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
            for (final author in data.authors.authors)
              AuthorRow(
                key: ValueKey(author.key),
                name: author.name,
                era: author.eraName,
                photo: author.photo,
                onTap: () => viewModel.openAuthor(author),
              ),
          ],
        ),
      ),
    );
  }
}
