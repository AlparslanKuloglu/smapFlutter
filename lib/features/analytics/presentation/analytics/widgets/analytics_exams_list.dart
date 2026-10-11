part of '../analytics_view.dart';

/// The list card (pano 6.2 kare 1 "Liste kartı"): `ExamRow`s on one rounded
/// surface, divided by 1 pt rules, 8 per page with more below. Only the rows
/// of the loaded exams rebuild when the exams change; the star of a row
/// follows its own selector.
class _ExamRowsSliver
    extends SelectorViewModelWidget<AnalyticsViewModel, List<ExamSummary>> {
  const _ExamRowsSliver();

  @override
  List<ExamSummary> selector(AnalyticsViewModel viewModel) =>
      viewModel.examSummaries;

  @override
  Widget build(BuildContext context, List<ExamSummary> exams) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s12,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverList.builder(
        itemCount: exams.length,
        itemBuilder: (context, index) => _ExamRowItem(
          key: ValueKey(exams[index].id),
          exam: exams[index],
          first: index == 0,
          last: index == exams.length - 1,
        ),
      ),
    );
  }
}

/// One row: the surface with the card's corners at the ends, the rule above
/// it (not for the first), the `ExamRow` and its star.
class _ExamRowItem extends SelectorViewModelWidget<AnalyticsViewModel, bool> {
  const _ExamRowItem({
    required this.exam,
    required this.first,
    required this.last,
    super.key,
  });

  final ExamSummary exam;
  final bool first;
  final bool last;

  @override
  bool selector(AnalyticsViewModel viewModel) =>
      viewModel.favoriteIds.contains(exam.id);

  @override
  Widget build(BuildContext context, bool favorite) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final viewModel = getParentViewModel<AnalyticsViewModel>(
      context,
      listen: false,
    );
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: first ? AppRadius.radiusLg : Radius.zero,
        bottom: last ? AppRadius.radiusLg : Radius.zero,
      ),
      child: ColoredBox(
        color: colors.bgSurface,
        child: Column(
          children: [
            if (!first)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.s16),
                child: Divider(height: 1, thickness: 1, color: colors.bgSunken),
              ),
            ExamRow(
              name: _examTitle(l10n, exam.name, exam.kind),
              typeLabel: exam.kind?.label ?? '',
              net: exam.net,
              counts: exam.counts,
              date: exam.date,
              publisher: exam.publisherName,
              isFavorite: favorite,
              onFavoriteChanged: (_) => viewModel.toggleFavorite(exam.id),
              onTap: () {
                final detail = viewModel.detailOf(exam.id);
                if (detail != null) _openExam(context, detail);
              },
            ),
          ],
        ),
      ),
    );
  }
}

typedef _FooterData = ({bool loading, bool failed});

/// Under the list: a small spinner while the next page loads ("altta küçük
/// çark"), a section error with "Tekrar Dene" if it failed. Nothing when the
/// list is complete: no "Hepsi bu kadar" (pano 6.2).
class _ExamsFooter
    extends SelectorViewModelWidget<AnalyticsViewModel, _FooterData> {
  const _ExamsFooter();

  @override
  _FooterData selector(AnalyticsViewModel viewModel) {
    final data = viewModel.examList.data;
    return (
      loading: data?.loadingMore ?? false,
      failed: data?.moreFailed ?? false,
    );
  }

  @override
  Widget build(BuildContext context, _FooterData data) {
    final l10n = AppLocalizations.of(context);
    if (data.failed) {
      final viewModel = getParentViewModel<AnalyticsViewModel>(
        context,
        listen: false,
      );
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.s12,
          AppSpacing.gutter,
          0,
        ),
        sliver: SliverToBoxAdapter(
          child: AppErrorState.section(
            message: l10n.analytics_moreError,
            onRetry: () => unawaited(viewModel.loadMore()),
          ),
        ),
      );
    }
    if (!data.loading) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.s16),
        child: Center(
          child: AppSpinner(semanticLabel: l10n.analytics_loadingMoreA11y),
        ),
      ),
    );
  }
}
