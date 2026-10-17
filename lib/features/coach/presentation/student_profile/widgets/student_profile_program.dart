part of '../student_profile_view.dart';

/// The Program tab (Tur 12 A, pano 14.1 kare 1, 3 and 4; 14.3; it replaces
/// pano 10.4 kare 3): the student's programs are read with
/// `ProgramListViewModel` (the student's id goes with the request; the coach
/// may set up and edit while `FeatureFlags.coachProgramWriteEnabled` is on),
/// and the one that matters now (this week's, else the newest) is shown as a
/// section of `ProgramDetailView` with its own ViewModel.
class _ProgramTab extends StatelessWidget {
  const _ProgramTab({required this.student});

  final StudentRef student;

  @override
  Widget build(BuildContext context) {
    return StudentScope(
      student: student,
      child: ViewModelBuilder<ProgramListViewModel>.nonReactive(
        viewModelBuilder: () => ProgramListViewModel(
          schedule: locator<ScheduleService>(),
          navigator: RouterProgramNavigator(context.router, student: student),
          online: locator<ConnectivityService>().online,
          studentId: student.id,
        ),
        onViewModelReady: (viewModel) => unawaited(viewModel.load()),
        builder: (context, viewModel, _) => _ProgramTabBody(student: student),
      ),
    );
  }
}

typedef _ProgramData = ({
  ProgramListPhase phase,
  String? currentId,
  int count,
  bool online,
  bool canWrite,
  int revision,
});

/// Skeleton, section error, empty state or the current program with the
/// notice and the "Programlar" row under it.
class _ProgramTabBody
    extends SelectorViewModelWidget<ProgramListViewModel, _ProgramData> {
  const _ProgramTabBody({required this.student});

  final StudentRef student;

  @override
  _ProgramData selector(ProgramListViewModel viewModel) {
    final all = viewModel.all;
    return (
      phase: viewModel.phase,
      currentId: all.current?.id,
      count: all.items.length,
      online: viewModel.online,
      canWrite: viewModel.canCreate,
      revision: viewModel.revision,
    );
  }

  @override
  Widget build(BuildContext context, _ProgramData data) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ProgramListViewModel>(
      context,
      listen: false,
    );
    final first = student.firstName;
    final id = data.currentId;
    return switch (data.phase) {
      ProgramListPhase.loading => const SliverToBoxAdapter(
        child: ProgramSectionSkeleton(),
      ),
      ProgramListPhase.error => SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.s16,
          AppSpacing.gutter,
          0,
        ),
        sliver: SliverToBoxAdapter(
          child: AppErrorState.section(
            title: l10n.coachStudentProfile_programLoadErrorTitle,
            message: l10n.coachStudentProfile_programLoadErrorBody,
            onRetry: viewModel.retry,
          ),
        ),
      ),
      ProgramListPhase.empty => SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.s16,
          AppSpacing.gutter,
          0,
        ),
        sliver: SliverToBoxAdapter(
          child: AppEmptyState.section(
            title: l10n.coachStudentProfile_programEmptyTitle(
              TurkishSuffix.genitive(first),
            ),
            message: data.canWrite
                ? l10n.coachStudentProfile_programEmptyBody(first)
                : l10n.coachStudentProfile_programEmptyBodyReadOnly(first),
            actionLabel: data.canWrite
                ? l10n.coachStudentProfile_programSetUp
                : null,
            actionIcon: PhosphorIconsRegular.plus,
            primaryAction: true,
            onAction: viewModel.canCreateNow ? viewModel.startNewProgram : null,
          ),
        ),
      ),
      ProgramListPhase.content when id != null => SliverMainAxisGroup(
        slivers: [
          ProgramDetailSection(
            // A new key after the list was visited: the program may have been
            // changed there.
            key: ValueKey<String>('$id/${data.revision}'),
            programId: id,
            student: student,
            link: _PageAnchors.of(context).edit,
          ),
          _ProgramFooter(
            first: first,
            count: data.count,
            online: data.online,
            canWrite: data.canWrite,
            onOpenList: () => unawaited(
              context.router
                  .push(ProgramListRoute(student: student))
                  .then((_) => viewModel.refreshView()),
            ),
          ),
        ],
      ),
      ProgramListPhase.content => _noSliver,
    };
  }
}

/// Under the program: the notice "Bu programı Alparslan da görür ve
/// düzenleyebilir. Yaptığın değişiklik onun programına hemen yansır." (online;
/// pano 14.1 kare 1) or, offline, the one line "Program kurmak ve düzenlemek
/// için bağlantı gerekiyor. Kayıtlı programı görebilirsin." in its place (pano
/// 14.3 kare 3), then the row "Programlar" with the value "3 program" that
/// opens the student's list. A coach who may not write has neither the notice
/// nor the line. Gone while the program is being edited.
class _ProgramFooter extends StatelessWidget {
  const _ProgramFooter({
    required this.first,
    required this.count,
    required this.online,
    required this.canWrite,
    required this.onOpenList,
  });

  final String first;
  final int count;
  final bool online;
  final bool canWrite;
  final VoidCallback onOpenList;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = context.appText;
    return ValueListenableBuilder<bool>(
      valueListenable: _PageAnchors.of(context).edit.editing,
      builder: (context, editing, _) {
        if (editing) return _noSliver;
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.s16,
            AppSpacing.gutter,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (canWrite && online) ...[
                  AppNoticeBox(
                    message: l10n.coachStudentProfile_programInfo(first),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                ] else if (canWrite) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s4,
                    ),
                    child: Text(
                      l10n.coachStudentProfile_programOfflineNote,
                      style: text.caption.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                ],
                AppRowGroup(
                  children: [
                    AppRow(
                      icon: PhosphorIconsRegular.calendarBlank,
                      title: l10n.coachStudentProfile_programsRow,
                      value: l10n.coachStudentProfile_programsCount(
                        TrFormat.sira(count),
                      ),
                      onTap: onOpenList,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
