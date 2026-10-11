part of '../lessons_view.dart';

/// The list under the band: the skeleton, the card of rows or the error
/// state, by the section's state (pano 7.1, 7.5 kare 1).
class _LessonsListSection
    extends SelectorViewModelWidget<LessonsViewModel, LessonsListData> {
  const _LessonsListSection();

  @override
  LessonsListData selector(LessonsViewModel viewModel) => viewModel.list;

  @override
  Widget build(BuildContext context, LessonsListData data) {
    return switch (data.state) {
      SectionState.loading => const _LessonsSkeleton(),
      SectionState.ready => _LessonRowsCard(rows: data.rows),
      SectionState.empty ||
      SectionState.error ||
      SectionState.offline => const _LessonsError(),
    };
  }
}

/// The card of subject rows (pano 7.1): 16 under the band, 16 at the sides.
class _LessonRowsCard extends StatelessWidget {
  const _LessonRowsCard({required this.rows});

  final List<LessonRow> rows;

  @override
  Widget build(BuildContext context) {
    final viewModel = getParentViewModel<LessonsViewModel>(
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
            for (final row in rows)
              _LessonRowTile(
                key: ValueKey(row.key),
                row: row,
                onTap: () => viewModel.openRow(row),
              ),
          ],
        ),
      ),
    );
  }
}

/// One lesson row (C20 `SubjectRow`): the name, the test line and the tag as
/// the row says them.
class _LessonRowTile extends StatelessWidget {
  const _LessonRowTile({required this.row, required this.onTap, super.key});

  final LessonRow row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = switch (row.nameKind) {
      LessonRowName.server => row.name,
      LessonRowName.literature => l10n.lessons_literatureName,
      LessonRowName.sos2 => l10n.lessons_sos2Name(row.name),
    };
    final test = switch (row.test) {
      LessonRowTest.none => null,
      LessonRowTest.socialSciences1 => l10n.lessons_testSocialSciences1,
      LessonRowTest.socialSciences2 => l10n.lessons_testSocialSciences2,
    };
    return SubjectRow(
      name: name,
      subject: row.subject,
      testName: test,
      missing: row.missing,
      webOnly: row.webOnly,
      cardsKnown: row.cardsKnown,
      cardsTotal: row.cardsTotal,
      onTap: onTap,
    );
  }
}
