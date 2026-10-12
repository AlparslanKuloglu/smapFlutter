part of '../students_view.dart';

/// The list under the search field: the skeleton, the card of rows, the
/// no-match card, the empty state or the error state, by the section's state
/// (pano 10.2 kare 1 to 4).
class _StudentsListSection
    extends SelectorViewModelWidget<StudentsViewModel, StudentsListData> {
  const _StudentsListSection({required this.onClearSearch});

  /// "Aramayı Temizle": the page empties its field.
  final VoidCallback onClearSearch;

  @override
  StudentsListData selector(StudentsViewModel viewModel) => viewModel.list;

  @override
  Widget build(BuildContext context, StudentsListData data) {
    return switch (data.state) {
      SectionState.loading => const _StudentsSkeleton(),
      SectionState.ready =>
        data.noMatch
            ? _NoMatchCard(query: data.query, onClear: onClearSearch)
            : _StudentsCard(rows: data.rows, query: data.query),
      SectionState.empty => const _StudentsEmpty(),
      SectionState.error || SectionState.offline => const _StudentsError(),
    };
  }
}

/// The card of student rows (pano 10.2 kare 1 and 2): `bgSurface`, radius 16,
/// the content clipped, a full-width 1 pt rule between two rows (the 10.x
/// variant of the row: "ayraç tam genişlikte"), 16 at the sides.
class _StudentsCard extends StatelessWidget {
  const _StudentsCard({required this.rows, required this.query});

  final List<StudentRowData> rows;
  final String query;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<StudentsViewModel>(
      context,
      listen: false,
    );
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      sliver: SliverToBoxAdapter(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.bgSurface,
            borderRadius: AppRadius.borderLg,
          ),
          child: ClipRRect(
            borderRadius: AppRadius.borderLg,
            child: Column(
              children: [
                for (final (i, row) in rows.indexed) ...[
                  if (i > 0)
                    Divider(height: 1, thickness: 1, color: colors.bgSunken),
                  StudentRow(
                    key: ValueKey(row.id),
                    name: row.name,
                    query: query,
                    avatar: CoachAvatars.imageOf(row.photo),
                    meta: StudentTexts.meta(l10n, row),
                    semanticLabel: StudentTexts.semanticLabel(l10n, row),
                    onTap: () => viewModel.openStudent(row),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The card of a search nobody matched (pano 10.2 kare 3): 16 under the field,
/// padding 24 / 16 / 12, centered; "“selin” ile eşleşen öğrenci yok" 16/24 ·
/// 700, how the search works 13/20 `textSecondary`, and the text button
/// "Aramayı Temizle".
class _NoMatchCard extends StatelessWidget {
  const _NoMatchCard({required this.query, required this.onClear});

  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s16,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: SizedBox(
          width: double.infinity,
          child: AppCard(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s16,
              AppSpacing.s24,
              AppSpacing.s16,
              AppSpacing.s12,
            ),
            child: Semantics(
              container: true,
              liveRegion: true,
              child: Column(
                children: [
                  Text(
                    l10n.students_noResultTitle(query),
                    textAlign: TextAlign.center,
                    style: text.bodyStrong.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    l10n.students_noResultMessage,
                    textAlign: TextAlign.center,
                    style: text.caption.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  AppButton(
                    label: l10n.students_clearSearch,
                    variant: AppButtonVariant.text,
                    onPressed: onClear,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
