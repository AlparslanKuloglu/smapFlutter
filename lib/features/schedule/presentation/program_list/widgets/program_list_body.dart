part of '../program_list_view.dart';

typedef _BodyData = ({
  ProgramListPhase phase,
  ProgramList items,
  String query,
  bool online,
});

/// What is under the search field: the skeleton, the empty state, the error,
/// or the programs (with the no-match card and the offline note).
class _ListBody
    extends SelectorViewModelWidget<ProgramListViewModel, _BodyData> {
  const _ListBody();

  @override
  _BodyData selector(ProgramListViewModel viewModel) => (
    phase: viewModel.phase,
    items: viewModel.visible,
    query: viewModel.query,
    online: viewModel.online,
  );

  @override
  Widget build(BuildContext context, _BodyData data) {
    final viewModel = getParentViewModel<ProgramListViewModel>(
      context,
      listen: false,
    );
    return switch (data.phase) {
      ProgramListPhase.loading => const _ListSkeleton(),
      ProgramListPhase.empty => _ListEmpty(
        onSetUp: viewModel.canCreateNow ? viewModel.startNewProgram : null,
        canCreate: viewModel.canCreate,
        studentFirstName: StudentScope.studentOf(context)?.firstName,
      ),
      ProgramListPhase.error => _ListError(
        onRetry: viewModel.retry,
        coach: viewModel.isCoachView,
      ),
      ProgramListPhase.content => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (data.items.isEmpty)
                _NoMatch(query: data.query)
              else
                _ProgramRows(items: data.items, onOpen: viewModel.openProgram),
              if (!data.online) const _OfflineNote(),
            ],
          ),
        ),
      ),
    };
  }
}

/// The card of program rows with the rules between them (pano 3.4 kare 1).
class _ProgramRows extends StatelessWidget {
  const _ProgramRows({required this.items, required this.onOpen});

  final ProgramList items;
  final ValueChanged<ProgramSummary> onOpen;

  @override
  Widget build(BuildContext context) {
    final rule = context.appColors.bgSunken;
    return AppCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: Column(
        children: [
          for (final (i, program) in items.items.indexed) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.only(left: ProgramRow.textInset),
                child: Divider(height: 1, thickness: 1, color: rule),
              ),
            ProgramRow(
              name: program.name,
              motto: program.motto,
              range: program.span?.rangeLabel,
              isThisWeek: program.isThisWeek,
              onTap: () => onOpen(program),
            ),
          ],
        ],
      ),
    );
  }
}

/// A search with no result (pano 3.4 kare 2): a status card, centered,
/// padding 24 / 16 / 12; "“kasım” ile eşleşen program yok", what the search
/// reads, and the "Aramayı Temizle" text button.
class _NoMatch extends StatelessWidget {
  const _NoMatch({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    return AppCard(
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
              l10n.schedule_searchNoMatch(query),
              textAlign: TextAlign.center,
              style: text.titleSm.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              l10n.schedule_searchHelp,
              textAlign: TextAlign.center,
              style: text.caption.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.s8),
            AppButton(
              label: l10n.schedule_clearSearch,
              variant: AppButtonVariant.text,
              size: AppButtonSize.md40,
              onPressed: () => context
                  .findAncestorStateOfType<_ProgramListPageState>()
                  ?.clearSearch(),
            ),
          ],
        ),
      ),
    );
  }
}

/// The note under the saved list while offline (pano 3.7 kare 4): "Program
/// kurmak ve düzenlemek için bağlantı gerekiyor. Kayıtlı programını
/// görebilirsin." ("…Kayıtlı programı görebilirsin." for a coach, brief 14.3
/// kare 3).
class _OfflineNote extends StatelessWidget {
  const _OfflineNote();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s4,
        AppSpacing.s12,
        AppSpacing.s4,
        0,
      ),
      child: Text(
        StudentScope.isCoachView(context)
            ? AppLocalizations.of(
                context,
              ).coachStudentProfile_programOfflineNote
            : AppLocalizations.of(context).schedule_offlineNote,
        style: context.appText.caption.copyWith(
          color: context.appColors.textSecondary,
        ),
      ),
    );
  }
}
