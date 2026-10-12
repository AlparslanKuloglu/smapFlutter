part of '../student_profile_view.dart';

/// What stands in for the screen while the student is not known: the skeleton
/// (the bar is there already; the title, the line and the tabs as blocks),
/// the screen error with "Tekrar Dene", or the sentence for an id that is not
/// in the coach's list. Nothing once the student is here.
class _ProfileStates
    extends SelectorViewModelWidget<StudentProfileViewModel, SectionState> {
  const _ProfileStates();

  @override
  SectionState selector(StudentProfileViewModel viewModel) =>
      viewModel.profile.state;

  @override
  Widget build(BuildContext context, SectionState state) {
    final l10n = AppLocalizations.of(context);
    return switch (state) {
      SectionState.ready => _noSliver,
      SectionState.loading => const _ProfileSkeleton(),
      SectionState.empty => SliverToBoxAdapter(
        child: AppEmptyState.screen(
          title: l10n.coachStudentProfile_notFoundTitle,
          message: l10n.coachStudentProfile_notFoundMessage,
        ),
      ),
      SectionState.error || SectionState.offline => SliverToBoxAdapter(
        child: AppErrorState.screen(
          title: l10n.coachStudentProfile_errorTitle,
          message: l10n.coachStudentProfile_errorMessage,
          onRetry: getParentViewModel<StudentProfileViewModel>(
            context,
            listen: false,
          ).retry,
        ),
      ),
    };
  }
}

/// The screen as a skeleton (pano 10.4 measures): the strip's 40, the name's
/// 24/32 and the meta line, the 48 high tabs and one card of rows. At 15 s
/// without an answer the screen turns to the error.
class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  static const double _nameWidth = 200;
  static const double _metaWidth = 160;
  static const double _stripHeight = AppContextStrip.height;
  static const double _tabsHeight = 48;
  static const double _cardHeight = 160;

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: AppSkeleton(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonBox(height: _stripHeight),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.s16,
                AppSpacing.gutter,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: _nameWidth, height: 32),
                  SizedBox(height: AppSpacing.s8),
                  SkeletonBox(width: _metaWidth, height: 16),
                  SizedBox(height: AppSpacing.s16),
                  SkeletonBox(height: _tabsHeight),
                  SizedBox(height: AppSpacing.s16),
                  SkeletonBox(height: _cardHeight, radius: AppRadius.lg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
