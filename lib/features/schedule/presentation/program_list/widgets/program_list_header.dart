part of '../program_list_view.dart';

typedef _BarData = ({ProgramListPhase phase, bool canCreate, bool enabled});

/// The detail bar: back, and "Yeni Program" (pano 3.4 kare 1; the action is
/// off while offline, pano 3.7 kare 4; not drawn in the skeleton, the empty
/// and the error states, pano 3.7 kare 1 to 3).
class _ListBar extends SelectorViewModelWidget<ProgramListViewModel, _BarData> {
  const _ListBar();

  @override
  _BarData selector(ProgramListViewModel viewModel) => (
    phase: viewModel.phase,
    canCreate: viewModel.canCreate,
    enabled: viewModel.canCreateNow,
  );

  @override
  Widget build(BuildContext context, _BarData data) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ProgramListViewModel>(
      context,
      listen: false,
    );
    final showAction = data.canCreate && data.phase == ProgramListPhase.content;
    return AppDetailBar(
      title: viewModel.isCoachView
          ? l10n.coachStudentProfile_programsTitle
          : l10n.schedule_title,
      action: showAction
          ? AppBarAction(
              label: l10n.schedule_new,
              icon: PhosphorIconsRegular.plus,
              onPressed: data.enabled ? viewModel.startNewProgram : null,
            )
          : null,
    );
  }
}

/// "Programım" as the large title; the error state has none (pano 3.7 kare 3
/// "başlık çizilmemiş").
class _ListTitle
    extends SelectorViewModelWidget<ProgramListViewModel, ProgramListPhase> {
  const _ListTitle();

  @override
  ProgramListPhase selector(ProgramListViewModel viewModel) => viewModel.phase;

  @override
  Widget build(BuildContext context, ProgramListPhase phase) {
    if (phase == ProgramListPhase.error) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final l10n = AppLocalizations.of(context);
    final coach = getParentViewModel<ProgramListViewModel>(
      context,
      listen: false,
    ).isCoachView;
    return LargeTitleSliver(
      title: coach
          ? l10n.coachStudentProfile_programsTitle
          : l10n.schedule_title,
    );
  }
}

/// The search field "Program ara" (pano 3.4 kare 1), under the title in the
/// skeleton and the list; not in the empty and error states.
class _ListSearch
    extends SelectorViewModelWidget<ProgramListViewModel, ProgramListPhase> {
  const _ListSearch({required this.controller});

  final TextEditingController controller;

  @override
  ProgramListPhase selector(ProgramListViewModel viewModel) => viewModel.phase;

  @override
  Widget build(BuildContext context, ProgramListPhase phase) {
    final shown =
        phase == ProgramListPhase.loading || phase == ProgramListPhase.content;
    if (!shown) return const SliverToBoxAdapter(child: SizedBox.shrink());
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ProgramListViewModel>(
      context,
      listen: false,
    );
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s16,
        AppSpacing.gutter,
        AppSpacing.s16,
      ),
      sliver: SliverToBoxAdapter(
        child: AppSearchField(
          controller: controller,
          semanticLabel: l10n.schedule_searchHint,
          hintText: l10n.schedule_searchHint,
          onQueryChanged: viewModel.setQuery,
        ),
      ),
    );
  }
}
