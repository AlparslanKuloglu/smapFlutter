part of '../program_detail_view.dart';

typedef _ActionsData = ({
  SectionState state,
  ProgramViewMode mode,
  bool editing,
  bool canEdit,
  bool canEditNow,
  bool dayHasTopics,
  bool canCancel,
});

/// The dangerous text buttons at the end (pano 3.4 kare 3, 3.6 kare 1):
/// "Günü Sıfırla" with ArrowCounterClockwise and, in edit mode and only while
/// the cancel flag is open, "Programı İptal Et" with a Trash at the right.
/// Both are off without a connection; "Günü Sıfırla" is off on an empty day.
///
/// In the coach's Program tab ([embedded]) they belong to edit mode alone: the
/// reading frame of pano 14.1 kare 1 ends with the rows and the notice.
class _DayActions
    extends SelectorViewModelWidget<ProgramDetailViewModel, _ActionsData> {
  const _DayActions({this.embedded = false});

  final bool embedded;

  @override
  _ActionsData selector(ProgramDetailViewModel viewModel) => (
    state: viewModel.section.state,
    mode: viewModel.mode,
    editing: viewModel.editing,
    canEdit: viewModel.canEdit,
    canEditNow: viewModel.canEditNow,
    dayHasTopics: (viewModel.detail?.countOn(viewModel.selectedDay) ?? 0) > 0,
    canCancel: viewModel.canCancel && FeatureFlags.programDeleteEnabled,
  );

  @override
  Widget build(BuildContext context, _ActionsData data) {
    if (data.state != SectionState.ready ||
        data.mode != ProgramViewMode.day ||
        !data.canEdit ||
        (embedded && !data.editing)) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ProgramDetailViewModel>(
      context,
      listen: false,
    );
    final reset = AppButton(
      label: l10n.schedule_resetDay,
      icon: PhosphorIconsRegular.arrowCounterClockwise,
      variant: AppButtonVariant.textDanger,
      size: AppButtonSize.md40,
      onPressed: data.canEditNow && data.dayHasTopics
          ? viewModel.resetDay
          : null,
    );
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter - AppSpacing.s12,
        AppSpacing.s16,
        AppSpacing.gutter - AppSpacing.s12,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            reset,
            if (data.editing && data.canCancel)
              AppButton(
                label: l10n.schedule_cancelProgram,
                icon: PhosphorIconsRegular.trash,
                variant: AppButtonVariant.textDanger,
                size: AppButtonSize.md40,
                onPressed: data.canEditNow ? viewModel.cancelProgram : null,
              ),
          ],
        ),
      ),
    );
  }
}
