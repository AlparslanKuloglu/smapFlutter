part of '../onboarding_view.dart';

/// The frame of the role and grade steps (pano 2.2 kare 1-3): a Back button,
/// the `display` title (it shrinks into the bar when the page scrolls), the
/// content, and the one primary button 8 pt over the safe area.
///
/// The page edge is 24 (the 2.x screens). The content is a list of slivers in
/// the screen's single `CustomScrollView`; the button stays under it.
class _StepFrame extends StatelessWidget {
  const _StepFrame({
    required this.title,
    required this.slivers,
    required this.onContinue,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<Widget> slivers;

  /// Null leaves the button disabled.
  final VoidCallback? onContinue;

  static const double _gutter = AppSpacing.gutterAuth;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final vm = getParentViewModel<OnboardingViewModel>(context, listen: false);
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              AppDetailBar(
                title: title,
                display: true,
                gutter: _gutter,
                onLeading: () => vm.back(),
              ),
              LargeTitleSliver(title: title, display: true, gutter: _gutter),
              if (subtitle case final line?)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      _gutter,
                      AppSpacing.s8,
                      _gutter,
                      0,
                    ),
                    child: Text(
                      line,
                      style: context.appText.bodyLg.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ...slivers,
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s24)),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            _gutter,
            AppSpacing.s8,
            _gutter,
            safeBottom + AppSpacing.s8,
          ),
          child: AppButton(
            label: l10n.common_continue,
            expand: true,
            onPressed: onContinue,
          ),
        ),
      ],
    );
  }
}
