part of '../students_view.dart';

/// The search field "Öğrenci ara" (pano 10.2 kare 1 to 3), 16 under the band.
/// It is there in the skeleton and in the list (also while nobody matches),
/// not in the empty state (kare 4) nor in the error state.
class _StudentsSearch
    extends SelectorViewModelWidget<StudentsViewModel, SectionState> {
  const _StudentsSearch({required this.controller});

  final TextEditingController controller;

  @override
  SectionState selector(StudentsViewModel viewModel) => viewModel.list.state;

  @override
  Widget build(BuildContext context, SectionState state) {
    final shown = state == SectionState.loading || state == SectionState.ready;
    if (!shown) return const SliverToBoxAdapter(child: SizedBox.shrink());
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<StudentsViewModel>(
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
        child: AppSearchField(
          controller: controller,
          semanticLabel: l10n.students_searchHint,
          hintText: l10n.students_searchHint,
          enabled: state == SectionState.ready,
          onQueryChanged: viewModel.setQuery,
        ),
      ),
    );
  }
}

/// The counter "5 öğrenci" under the search field (pano 10.2 kare 1 and 2):
/// 13/20 · 600 `textSecondary`, 12 under the field and 20 from the left. It
/// counts what the list shows and is announced when a search changes it. A
/// search nobody matched shows the no-match card instead (kare 3).
class _StudentsCounter
    extends SelectorViewModelWidget<StudentsViewModel, int?> {
  const _StudentsCounter();

  /// The counter's left offset: the gutter and 4 (pano 10.2 "left 20").
  static const double _left = AppSpacing.gutter + AppSpacing.s4;

  @override
  int? selector(StudentsViewModel viewModel) {
    final list = viewModel.list;
    if (list.state != SectionState.ready || list.rows.isEmpty) return null;
    return list.rows.length;
  }

  @override
  Widget build(BuildContext context, int? count) {
    if (count == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final l10n = AppLocalizations.of(context);
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        _left,
        AppSpacing.s12,
        AppSpacing.gutter,
        AppSpacing.s8,
      ),
      sliver: SliverToBoxAdapter(
        child: Semantics(
          liveRegion: true,
          child: Text(
            l10n.students_count(TrFormat.sira(count)),
            style: context.appText.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: context.appColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
