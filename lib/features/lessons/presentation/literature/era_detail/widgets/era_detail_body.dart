part of '../era_detail_view.dart';

/// The accordions of the era: the skeleton, the cards, or the screen-level
/// error (pano 14.5 kare 2, 14.7).
class _EraBody
    extends SelectorViewModelWidget<EraDetailViewModel, EraBodyData> {
  const _EraBody();

  @override
  EraBodyData selector(EraDetailViewModel viewModel) => viewModel.body;

  @override
  Widget build(BuildContext context, EraBodyData data) {
    return switch (data.state) {
      SectionState.loading => const _EraSkeleton(),
      SectionState.ready => _SubList(ids: data.subIds),
      SectionState.empty => const _NoSubs(),
      SectionState.error || SectionState.offline => const _EraError(),
    };
  }
}

/// The accordion cards, 8 apart, 16 under the title block (as in Konu Detayı,
/// pano 7.3 kare 1).
class _SubList extends StatelessWidget {
  const _SubList({required this.ids});

  final List<String> ids;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s16,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverList.separated(
        itemCount: ids.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s8),
        itemBuilder: (_, index) =>
            _SubCard(key: ValueKey(ids[index]), id: ids[index]),
      ),
    );
  }
}

/// One sub-subject accordion (C50 first level, the 7.3 sub-topic card): the
/// name 17/24 · 700, the tag "2 eksik" under it, the caret at the right and
/// the author rows inside. It follows its own sub-subject, so learning a work
/// redraws this card's tag only.
class _SubCard
    extends SelectorViewModelWidget<EraDetailViewModel, SubCardData?> {
  const _SubCard({required this.id, super.key});

  final String id;

  @override
  SubCardData? selector(EraDetailViewModel viewModel) => viewModel.subCard(id);

  /// The header padding of the first level (pano 14.5: 14 / 12 / 14 / 16).
  static const EdgeInsets _headerPadding = EdgeInsets.fromLTRB(
    AppSpacing.s16,
    14,
    AppSpacing.s12,
    14,
  );

  @override
  Widget build(BuildContext context, SubCardData? data) {
    if (data == null) return const SizedBox.shrink();
    final viewModel = getParentViewModel<EraDetailViewModel>(
      context,
      listen: false,
    );
    final l10n = AppLocalizations.of(context);
    final missing = data.missing ?? 0;
    return KeyedSubtree(
      key: _EraAnchors.of(context, data.id),
      child: AppAccordion(
        title: data.name,
        titleStyle: context.appText.headline,
        indicator: AppAccordionIndicator.plain,
        headerPadding: _headerPadding,
        bodyPadding: EdgeInsets.zero,
        expanded: data.open,
        onChanged: (open) => viewModel.setOpen(data.id, open),
        // One reading for the header: "2 eksik".
        summaryLabel: missing > 0
            ? l10n.lessons_missingCount(TrFormat.sira(missing))
            : null,
        summary: missing > 0 ? EksikTag(count: missing) : null,
        child: _SubAuthors(subId: data.id),
      ),
    );
  }
}

/// The skeleton of the accordion list: three cards, each a title line.
class _EraSkeleton extends StatelessWidget {
  const _EraSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s16,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: AppSkeleton(
          child: Column(
            children: [
              for (final width in const [220.0, 180.0, 200.0]) ...[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.bgSurface,
                    borderRadius: AppRadius.borderLg,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SkeletonBox(width: width, height: 20),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// An era the server lists with no sub-subject: the accordion list is simply
/// not drawn (an era's contents come from the curriculum; there is no empty
/// illustration, T12.16).
class _NoSubs extends StatelessWidget {
  const _NoSubs();

  @override
  Widget build(BuildContext context) =>
      const SliverToBoxAdapter(child: SizedBox.shrink());
}

/// The era did not load: the screen-level error with "Tekrar Dene". Back is
/// always there, in the bar.
class _EraError extends StatelessWidget {
  const _EraError();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<EraDetailViewModel>(
      context,
      listen: false,
    );
    return SliverToBoxAdapter(
      child: AppErrorState.screen(
        title: l10n.literature_eraListError,
        message: l10n.lessons_loadErrorMessage,
        onRetry: viewModel.retry,
      ),
    );
  }
}
