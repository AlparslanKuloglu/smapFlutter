part of '../onboarding_view.dart';

typedef _GradeData = (SchoolGrade? grade, StudyTrack? track, bool trackError);

/// "Kaçıncı sınıftasın?" (pano 2.2 kare 2 and 3): the grade chips (9, 10, 11,
/// 12, Mezun; 56 x 48, Mezun 88), then "Alanın" with the track chips (Sayısal,
/// Eşit Ağırlık, Sözel, Dil) for 11, 12 and Mezun, or one info line for 9 and
/// 10 ("9. ve 10. sınıfta alan seçilmez; 11. sınıfa geçince Hesap'tan
/// eklersin.").
///
/// "Devam Et" is live once a grade is picked. For 11, 12 and Mezun a missing
/// track is told on the tap, under the chips ("Alanını seç."); nothing is
/// picked for the user. "Dil" is drawn but cannot be picked while the backend
/// has no code for it (`StudyTrack.selectable`).
class _GradeStep
    extends SelectorViewModelWidget<OnboardingViewModel, _GradeData> {
  const _GradeStep();

  @override
  _GradeData selector(OnboardingViewModel viewModel) => (
    viewModel.selections.grade,
    viewModel.selections.track,
    viewModel.trackError,
  );

  @override
  Widget build(BuildContext context, _GradeData data) {
    final (grade, track, trackError) = data;
    final l10n = AppLocalizations.of(context);
    final vm = getParentViewModel<OnboardingViewModel>(context, listen: false);
    return _StepFrame(
      title: l10n.onboarding_gradeTitle,
      onContinue: grade == null ? null : vm.next,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            _StepFrame._gutter,
            AppSpacing.s16,
            _StepFrame._gutter,
            0,
          ),
          sliver: SliverList.list(
            children: [
              _GradeChips(grade: grade),
              if (grade != null) ...[
                const SizedBox(height: _TrackSection.gap),
                _TrackSection(
                  grade: grade,
                  track: track,
                  showError: trackError,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// The five grade chips, one radio group "Sınıf".
class _GradeChips extends StatelessWidget {
  const _GradeChips({required this.grade});

  final SchoolGrade? grade;

  /// Chip widths: the numbers and "Mezun" (C04 "Sınıf çipleri").
  static const double _numberWidth = 56;
  static const double _graduateWidth = 88;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = getParentViewModel<OnboardingViewModel>(context, listen: false);
    return Semantics(
      container: true,
      label: l10n.onboarding_gradeGroupA11y,
      child: Wrap(
        spacing: AppSpacing.s8,
        children: [
          for (final option in SchoolGrade.values)
            AppChip.square(
              label: option == SchoolGrade.graduate
                  ? l10n.onboarding_gradeGraduate
                  : '${option.code}',
              width: option == SchoolGrade.graduate
                  ? _graduateWidth
                  : _numberWidth,
              selected: option == grade,
              onTap: () => vm.selectGrade(option),
            ),
        ],
      ),
    );
  }
}

/// "Alanın" with its chips, or the info line of 9 and 10.
class _TrackSection extends StatelessWidget {
  const _TrackSection({
    required this.grade,
    required this.track,
    required this.showError,
  });

  final SchoolGrade grade;
  final StudyTrack? track;
  final bool showError;

  /// The gap above "Alanın" (pano: 258 from the top under the chips).
  static const double gap = AppSpacing.s32 + AppSpacing.s8;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final vm = getParentViewModel<OnboardingViewModel>(context, listen: false);
    String labelOf(StudyTrack option) => switch (option) {
      StudyTrack.sayisal => l10n.onboarding_trackSayisal,
      StudyTrack.esitAgirlik => l10n.onboarding_trackEsitAgirlik,
      StudyTrack.sozel => l10n.onboarding_trackSozel,
      StudyTrack.dil => l10n.onboarding_trackDil,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n.onboarding_trackTitle,
            style: context.appText.titleMd.copyWith(color: colors.textPrimary),
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        if (!grade.requiresTrack)
          AppNoticeBox(message: l10n.onboarding_gradeNoFieldInfo)
        else ...[
          Semantics(
            container: true,
            label: l10n.onboarding_trackGroupA11y,
            child: AppChipGroup<StudyTrack>(
              size: AppChipSize.lg48,
              selected: {?track},
              onChanged: vm.selectTrack,
              items: [
                // The design's order; a track without a backend code is shown
                // and cannot be picked.
                for (final option in const [
                  StudyTrack.sayisal,
                  StudyTrack.esitAgirlik,
                  StudyTrack.sozel,
                  StudyTrack.dil,
                ])
                  AppChipItem<StudyTrack>(
                    value: option,
                    label: labelOf(option),
                    enabled: StudyTrack.selectable.contains(option),
                  ),
              ],
            ),
          ),
          if (showError) _TrackError(message: l10n.onboarding_trackRequired),
        ],
      ],
    );
  }
}

/// The error line under the track chips: WarningCircle 16 and "Alanını seç."
/// 13/20 · 600 in `error`, announced as an alert.
class _TrackError extends StatelessWidget {
  const _TrackError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: PhosphorIcon(
                PhosphorIconsRegular.warningCircle,
                size: 16,
                color: colors.error,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                message,
                style: context.appText.caption.copyWith(
                  color: colors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
