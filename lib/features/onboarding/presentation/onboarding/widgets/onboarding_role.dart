part of '../onboarding_view.dart';

/// "SMAP'i nasıl kullanacaksın?" (pano 2.2 kare 1): the two [RoleOption]
/// cards in a radio group named "Rol" and "Devam Et". "Öğrenciyim" is
/// selected from the start (spec §4.A 2.2-1 [Karar]); a coach goes on to the
/// camera primer, a student to the grade step.
class _RoleStep extends SelectorViewModelWidget<OnboardingViewModel, UserRole> {
  const _RoleStep();

  /// The gap between the sentence under the title and the first card (pano:
  /// the group starts 240 from the top).
  static const double _groupGap = 18;

  @override
  UserRole selector(OnboardingViewModel viewModel) => viewModel.selections.role;

  @override
  Widget build(BuildContext context, UserRole role) {
    final l10n = AppLocalizations.of(context);
    final vm = getParentViewModel<OnboardingViewModel>(context, listen: false);
    return _StepFrame(
      title: l10n.onboarding_roleTitle,
      subtitle: l10n.onboarding_roleSubtitle,
      onContinue: vm.next,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            _StepFrame._gutter,
            _groupGap,
            _StepFrame._gutter,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: Semantics(
              container: true,
              label: l10n.onboarding_roleGroupA11y,
              child: Column(
                children: [
                  RoleOption(
                    title: l10n.onboarding_roleStudent,
                    description: l10n.onboarding_roleStudentDesc,
                    avatar: Assets.avatars.a1avatarN3.provider(),
                    selected: role == UserRole.student,
                    onTap: () => vm.selectRole(UserRole.student),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  RoleOption(
                    title: l10n.onboarding_roleCoach,
                    description: l10n.onboarding_roleCoachDesc,
                    avatar: Assets.avatars.a3avatarN3.provider(),
                    selected: role == UserRole.coach,
                    onTap: () => vm.selectRole(UserRole.coach),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
