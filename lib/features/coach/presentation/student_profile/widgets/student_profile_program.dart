part of '../student_profile_view.dart';

/// The Program tab (Tur 12 A, brief 14.1 kare 1; pano 10.4 kare 3): the
/// student's programs are read with `ProgramListViewModel` (the student's id
/// goes with the request; the coach may set up and edit), and the one that
/// matters now (this week's, else the newest) is shown as a section of
/// `ProgramDetailView` with its own ViewModel.
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
      currentId: all.isEmpty ? null : all.items.first.id,
      count: all.items.length,
      online: viewModel.online,
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
      ProgramListPhase.loading => const _ProgramSkeleton(),
      ProgramListPhase.error => SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.s16,
          AppSpacing.gutter,
          0,
        ),
        sliver: SliverToBoxAdapter(
          child: AppErrorState.section(
            message: l10n.coachStudentProfile_programLoadError,
            onRetry: viewModel.retry,
          ),
        ),
      ),
      ProgramListPhase.empty => SliverToBoxAdapter(
        child: AppEmptyState.screen(
          title: l10n.coachStudentProfile_programEmptyTitle(
            TurkishSuffix.genitive(first),
          ),
          message: l10n.coachStudentProfile_programEmptyBody(first),
          actionLabel: l10n.coachStudentProfile_programSetUp,
          actionIcon: PhosphorIconsRegular.plus,
          onAction: viewModel.canCreateNow ? viewModel.startNewProgram : null,
          topPadding: AppSpacing.s24,
        ),
      ),
      ProgramListPhase.content when id != null => SliverMainAxisGroup(
        slivers: [
          ProgramDetailSection(
            key: ValueKey<String>(id),
            programId: id,
            student: student,
          ),
          _ProgramFooter(
            first: first,
            count: data.count,
            online: data.online,
            onOpenList: () => unawaited(
              context.router.push(ProgramListRoute(student: student)),
            ),
          ),
        ],
      ),
      ProgramListPhase.content => _noSliver,
    };
  }
}

/// Under the program: the notice "Bu programı Alparslan da görür ve
/// düzenleyebilir. Yaptığın değişiklik onun programına hemen yansır.", the
/// row "Programlar" with "3 program" that opens the student's list (brief
/// 14.1 kare 1) and, while offline, the note that saving needs a connection
/// (brief 14.3 kare 3).
class _ProgramFooter extends StatelessWidget {
  const _ProgramFooter({
    required this.first,
    required this.count,
    required this.online,
    required this.onOpenList,
  });

  final String first;
  final int count;
  final bool online;
  final VoidCallback onOpenList;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = context.appText;
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
            AppNoticeBox(message: l10n.coachStudentProfile_programInfo(first)),
            const SizedBox(height: AppSpacing.s16),
            AppRowGroup(
              children: [
                AppRow(
                  icon: PhosphorIconsRegular.calendarBlank,
                  title: l10n.coachStudentProfile_programsRow,
                  subtitle: l10n.coachStudentProfile_programsCount(
                    TrFormat.sira(count),
                  ),
                  onTap: onOpenList,
                ),
              ],
            ),
            if (!online)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s4,
                  AppSpacing.s12,
                  AppSpacing.s4,
                  0,
                ),
                child: Text(
                  l10n.coachStudentProfile_programOfflineNote,
                  style: text.caption.copyWith(
                    color: context.appColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The program as a skeleton, in the tab (brief 14.3 kare 1; the rows are
/// those of pano 3.7 kare 2): the title row, the day strip and three rows.
class _ProgramSkeleton extends StatelessWidget {
  const _ProgramSkeleton();

  @override
  Widget build(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonBox(width: 180, height: 24),
              const SizedBox(height: AppSpacing.s8),
              const SkeletonBox(width: 140, height: 14),
              const SizedBox(height: AppSpacing.s16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < 7; i++)
                    const SkeletonBox(
                      width: 48,
                      height: 64,
                      radius: AppRadius.md,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.s24),
              for (var i = 0; i < 3; i++) ...[
                const SkeletonBox(height: 64, radius: AppRadius.lg),
                const SizedBox(height: AppSpacing.s8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
