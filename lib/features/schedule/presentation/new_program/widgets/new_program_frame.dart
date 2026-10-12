part of '../new_program_view.dart';

/// The system back: one step back, or on the first step the discard question
/// (pano 3.5 "Vazgeç (X) değişiklik varsa onay sorar"). With nothing entered
/// on the first step it leaves at once.
class _BackGuard extends SelectorViewModelWidget<NewProgramViewModel, bool> {
  const _BackGuard({required this.child});

  final Widget child;

  @override
  bool selector(NewProgramViewModel viewModel) => viewModel.interceptsBack;

  @override
  Widget build(BuildContext context, bool intercepts) {
    final viewModel = getParentViewModel<NewProgramViewModel>(
      context,
      listen: false,
    );
    return PopScope(
      canPop: !intercepts,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (!viewModel.back()) viewModel.requestClose();
      },
      child: child,
    );
  }
}

/// The bar: X "Vazgeç" on step 1, Back after, "Adım N/3" at the right (13/20 ·
/// 600 `textSecondary`), and the step's title as the compact bar title.
class _StepBar
    extends SelectorViewModelWidget<NewProgramViewModel, NewProgramStep> {
  const _StepBar();

  @override
  NewProgramStep selector(NewProgramViewModel viewModel) => viewModel.step;

  @override
  Widget build(BuildContext context, NewProgramStep step) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<NewProgramViewModel>(
      context,
      listen: false,
    );
    final first = step == NewProgramStep.days;
    final student = StudentScope.studentOf(context);
    return AppDetailBar(
      title: _titleOf(l10n, step, coach: student != null),
      leading: first ? AppDetailBarLeading.close : AppDetailBarLeading.back,
      onLeading: first ? viewModel.requestClose : viewModel.back,
      action: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.s12),
        child: Text(
          l10n.schedule_stepOf('${step.index + 1}'),
          style: context.appText.caption.copyWith(
            color: context.appColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// A coach's flow keeps the context strip under the bar on every step (brief
/// 14.2 "tam ekran akışta başlığın altında ContextStrip").
class _StepStrip extends StatelessWidget {
  const _StepStrip();

  @override
  Widget build(BuildContext context) {
    final student = StudentScope.studentOf(context);
    return student == null
        ? const SliverToBoxAdapter(child: SizedBox.shrink())
        : PinnedHeaderSliver(child: AppContextStrip(student: student));
  }
}

/// The step's title; a coach's flow says "çalışacak" and "Programa ad ver"
/// (brief 14.2).
String _titleOf(
  AppLocalizations l10n,
  NewProgramStep step, {
  bool coach = false,
}) => switch (step) {
  NewProgramStep.days =>
    coach ? l10n.coachStudentProfile_newDaysTitle : l10n.schedule_daysTitle,
  NewProgramStep.grid => l10n.schedule_gridTitle,
  NewProgramStep.name =>
    coach ? l10n.coachStudentProfile_newNameTitle : l10n.schedule_nameTitle,
};

/// The title, the sentence under it and the step's body.
class _StepContent
    extends SelectorViewModelWidget<NewProgramViewModel, NewProgramStep> {
  const _StepContent();

  @override
  NewProgramStep selector(NewProgramViewModel viewModel) => viewModel.step;

  @override
  Widget build(BuildContext context, NewProgramStep step) {
    final l10n = AppLocalizations.of(context);
    final student = StudentScope.studentOf(context);
    final body = switch (step) {
      NewProgramStep.days =>
        student == null
            ? l10n.schedule_daysBody
            : l10n.coachStudentProfile_newDaysBody(student.firstName),
      NewProgramStep.grid => l10n.schedule_gridBody,
      NewProgramStep.name => null,
    };
    return SliverMainAxisGroup(
      slivers: [
        LargeTitleSliver(title: _titleOf(l10n, step, coach: student != null)),
        if (body != null) _StepSentence(text: body),
        switch (step) {
          NewProgramStep.days => const _DaysStep(),
          NewProgramStep.grid => const _GridStep(),
          NewProgramStep.name => const _NameStep(),
        },
      ],
    );
  }
}

/// The 15/24 `textSecondary` sentence under the title (4 below it).
class _StepSentence extends StatelessWidget {
  const _StepSentence({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s4,
        AppSpacing.gutter,
        AppSpacing.s16,
      ),
      sliver: SliverToBoxAdapter(
        child: Text(
          text,
          style: context.appText.body.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

typedef _BandData = ({
  NewProgramStep step,
  bool canContinue,
  bool saving,
  int dayCount,
  String range,
});

/// The fixed band at the bottom: `bgSurface`, a 1 pt rule on top, padding 12 /
/// 24 / safe area + 8, one primary button; on step 1 "6 gün seçildi · 12–17
/// Ekim" above it.
class _BottomBand
    extends SelectorViewModelWidget<NewProgramViewModel, _BandData> {
  const _BottomBand();

  @override
  _BandData selector(NewProgramViewModel viewModel) => (
    step: viewModel.step,
    canContinue: viewModel.canContinue,
    saving: viewModel.saving,
    dayCount: viewModel.days.length,
    range: viewModel.step == NewProgramStep.days
        ? viewModel.summary.shortRange
        : '',
  );

  @override
  Widget build(BuildContext context, _BandData data) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<NewProgramViewModel>(
      context,
      listen: false,
    );
    final saveStep = data.step == NewProgramStep.name;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bgSurface,
        border: Border(top: BorderSide(color: colors.borderSubtle)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.s24,
          AppSpacing.s12,
          AppSpacing.s24,
          MediaQuery.paddingOf(context).bottom + AppSpacing.s8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (data.step == NewProgramStep.days && data.dayCount > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                child: Semantics(
                  liveRegion: true,
                  child: Wrap(
                    spacing: AppSpacing.s8,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: [
                      Text(
                        l10n.schedule_daysSelected(
                          TrFormat.sira(data.dayCount),
                        ),
                        style: text.bodyStrong.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        data.range,
                        style: text.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            AppButton(
              label: saveStep
                  ? l10n.schedule_saveProgram
                  : l10n.common_continue,
              loading: data.saving,
              expand: true,
              onPressed: data.canContinue
                  ? (saveStep ? viewModel.save : viewModel.next)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
