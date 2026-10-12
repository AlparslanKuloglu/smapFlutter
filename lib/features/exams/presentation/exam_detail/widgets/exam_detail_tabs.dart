part of '../exam_detail_view.dart';

/// The four in-screen tabs (C05; pano 5.3 "Sekmeler": Genel · Sorular ·
/// Konular · Kartlar): pinned under the bar once the header has scrolled
/// away, real and tappable while the result still loads (pano 5.8 kare 1),
/// not drawn when the screen failed (kare 3). A change plays the selection
/// haptic (the bar does) and the body cross-fades in 150 ms.
class _ExamTabsBar
    extends SelectorViewModelWidget<ExamDetailViewModel, (SectionState, int)> {
  const _ExamTabsBar();

  @override
  (SectionState, int) selector(ExamDetailViewModel viewModel) =>
      (viewModel.screenState, viewModel.tab.index);

  @override
  Widget build(BuildContext context, (SectionState, int) data) {
    final (state, selected) = data;
    if (state == SectionState.error || state == SectionState.offline) {
      return _noSliver;
    }
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ExamDetailViewModel>(
      context,
      listen: false,
    );
    final anchors = _PageAnchors.of(context);
    return PinnedHeaderSliver(
      child: ColoredBox(
        color: context.appColors.bgCanvas,
        child: Semantics(
          container: true,
          label: l10n.examDetail_tabsA11y,
          child: AppTabBar(
            labels: [
              l10n.examDetail_tabGeneral,
              l10n.examDetail_tabQuestions,
              l10n.examDetail_tabTopics,
              l10n.examDetail_tabCards,
            ],
            selectedIndex: selected,
            onChanged: (index) {
              viewModel.selectTab(ExamDetailTab.values[index]);
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => anchors.settleScroll(),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// The selected tab's body. The four bodies are lazy: only the one on show
/// is built, and Konular and Kartlar ask for their data when first shown.
/// Switching cross-fades in 150 ms (a plain fade under "Reduce motion").
class _ExamTabBody
    extends SelectorViewModelWidget<ExamDetailViewModel, (SectionState, int)> {
  const _ExamTabBody();

  @override
  (SectionState, int) selector(ExamDetailViewModel viewModel) =>
      (viewModel.screenState, viewModel.tab.index);

  @override
  Widget build(BuildContext context, (SectionState, int) data) {
    final (state, index) = data;
    if (state == SectionState.error || state == SectionState.offline) {
      return _noSliver;
    }
    final tab = ExamDetailTab.values[index];
    return SliverToBoxAdapter(
      child: AnimatedSwitcher(
        duration: context.motion(
          AppMotion.fast,
          reduced: AppMotion.reducedFade,
        ),
        child: Padding(
          key: ValueKey(tab),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            _sectionGap,
            AppSpacing.gutter,
            0,
          ),
          child: switch (tab) {
            ExamDetailTab.general => const _GeneralTab(),
            ExamDetailTab.questions => const _QuestionsTab(),
            ExamDetailTab.topics => const _TopicsTab(),
            ExamDetailTab.cards => const _CardsTab(),
          },
        ),
      ),
    );
  }
}
