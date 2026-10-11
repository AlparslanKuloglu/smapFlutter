part of '../home_view.dart';

/// "Derslerin" (pano 3.1 kare 1 to 3, 3.2; C21 `SubjectTile`): a horizontal
/// strip of 132 pt tiles, the lesson with the most missing items first,
/// Matematik and Geometri last with the "Web'de" tag.
///
/// With missing items the section says "Eksiği en çok olandan başlar" and the
/// tiles carry their "60 eksik" tags; for a new student (no missing item at
/// all, kare 3) it has no sub line and the tiles show the glyph and the name
/// only. A tile opens its lesson detail; a web-only lesson has no screen in
/// the app yet, so its tile does not open anything. Loading shows the
/// skeleton; a failure shows "Dersler yüklenemedi." with "Tekrar Dene".
class _SubjectsSection
    extends SelectorViewModelWidget<HomeViewModel, AsyncSection<SubjectStrip>> {
  const _SubjectsSection();

  @override
  AsyncSection<SubjectStrip> selector(HomeViewModel viewModel) =>
      viewModel.subjects;

  @override
  Widget build(BuildContext context, AsyncSection<SubjectStrip> section) {
    final l10n = AppLocalizations.of(context);
    switch (section.state) {
      case SectionState.loading:
        return const _SubjectsSkeleton();
      case SectionState.empty:
        return const SizedBox.shrink();
      case SectionState.error:
      case SectionState.offline:
        return Padding(
          padding: _gutter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(title: l10n.home_subjects),
              AppErrorState.section(
                message: l10n.home_subjectsError,
                onRetry: getParentViewModel<HomeViewModel>(
                  context,
                  listen: false,
                ).retrySubjects,
              ),
            ],
          ),
        );
      case SectionState.ready:
        final strip = section.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: _gutter,
              child: SectionHeader(
                title: l10n.home_subjects,
                meta: strip.hasMissingData ? l10n.home_subjectsSub : null,
              ),
            ),
            _SubjectTiles(strip: strip),
          ],
        );
    }
  }
}

/// The strip: tiles of one height side by side, 8 apart, 16 at the sides.
class _SubjectTiles extends StatelessWidget {
  const _SubjectTiles({required this.strip});

  final SubjectStrip strip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labelled = strip.hasMissingData;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: _gutter,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (index, tile) in strip.tiles.indexed) ...[
              if (index > 0) const SizedBox(width: AppSpacing.s8),
              SubjectTile(
                name: tile.subject == SubjectKey.edebiyat
                    ? l10n.home_literatureName
                    : tile.name,
                subject: tile.subject,
                missing: labelled ? tile.missing : null,
                webOnly: labelled && tile.webOnly,
                onTap: tile.webOnly
                    ? null
                    : () => _openLesson(context, tile.lessonId),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
