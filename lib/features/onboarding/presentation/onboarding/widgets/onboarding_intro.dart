part of '../onboarding_view.dart';

/// The three intro pages (pano 2.1 kare 2-4): a `PageView` of
/// [_IntroPage]s, "Geç" at the top right of the first two, and the footer
/// with the page dots and the one primary button ("Devam Et", "Başla" on the
/// last page). Swiping or the button moves between pages (350 ms).
class _IntroStep extends StatelessWidget {
  const _IntroStep({required this.pages});

  final PageController pages;

  @override
  Widget build(BuildContext context) {
    final vm = getParentViewModel<OnboardingViewModel>(context, listen: false);
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: PageView(
                controller: pages,
                onPageChanged: vm.setIntroPage,
                children: const [
                  _IntroPage(pageIndex: 0, visual: OnboardingScanVisual()),
                  _IntroPage(pageIndex: 1, visual: OnboardingAnalysisVisual()),
                  _IntroPage(pageIndex: 2, visual: OnboardingGapsVisual()),
                ],
              ),
            ),
            const _IntroFooter(),
          ],
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top,
          right: AppSpacing.s8,
          child: const _IntroSkip(),
        ),
      ],
    );
  }
}

/// One intro page (pano 2.1 kare 2-4): the picture in a 380 pt area, then the
/// `display` title (two lines at most on the board) and the 16/26 sentence in
/// `textSecondary` 12 below. The picture appears 250 ms late. A large text
/// size scales the picture down, then scrolls. The picture keeps its own text
/// size (it is an illustration with example data, drawn for the board's size):
/// if its texts grew with the system size the cards would outgrow the area
/// and cover the title (checked at 1,35).
class _IntroPage extends StatelessWidget {
  const _IntroPage({required this.pageIndex, required this.visual});

  final int pageIndex;
  final Widget visual;

  /// The picture area and the gap under it.
  static const double _visualHeight = 380;
  static const double _visualGap = 36;

  /// The room the "Geç" button takes at the top (the button is 48 high).
  static const double _skipRoom = 48;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final text = context.appText;
    final (title, body) = switch (pageIndex) {
      0 => (l10n.onboarding_intro1Title, l10n.onboarding_intro1Body),
      1 => (l10n.onboarding_intro2Title, l10n.onboarding_intro2Body),
      _ => (l10n.onboarding_intro3Title, l10n.onboarding_intro3Body),
    };
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + _skipRoom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        height: _visualHeight,
                        child: Align(
                          child: OnboardingReveal(
                            child: MediaQuery.withNoTextScaling(child: visual),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: _visualGap),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.gutterAuth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          title,
                          style: text.display.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Text(
                        body,
                        style: text.bodyReading.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// "Geç" (pano 2.1 kare 2 and 3): a text button at the top right, only on the
/// first two pages; it goes to the role question.
class _IntroSkip extends StatelessWidget {
  const _IntroSkip();

  @override
  Widget build(BuildContext context) {
    final vm = getParentViewModel<OnboardingViewModel>(context, listen: false);
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<int>(
      valueListenable: vm.introPage,
      builder: (context, page, _) {
        if (page >= OnboardingFlowState.introPageCount - 1) {
          return const SizedBox.shrink();
        }
        return AppButton(
          label: l10n.onboarding_skip,
          variant: AppButtonVariant.text,
          onPressed: vm.skipIntro,
        );
      },
    );
  }
}

/// The bottom block: the page dots, then the primary button; 24 at the sides,
/// 8 over the safe area (pano: 42 from the screen's bottom).
class _IntroFooter extends StatelessWidget {
  const _IntroFooter();

  @override
  Widget build(BuildContext context) {
    final vm = getParentViewModel<OnboardingViewModel>(context, listen: false);
    final l10n = AppLocalizations.of(context);
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.gutterAuth,
        0,
        AppSpacing.gutterAuth,
        safeBottom + AppSpacing.s8,
      ),
      child: ValueListenableBuilder<int>(
        valueListenable: vm.introPage,
        builder: (context, page, _) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: AppPageDots(
                count: OnboardingFlowState.introPageCount,
                index: page,
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            AppButton(
              label: page == OnboardingFlowState.introPageCount - 1
                  ? l10n.onboarding_start
                  : l10n.common_continue,
              expand: true,
              onPressed: vm.next,
            ),
          ],
        ),
      ),
    );
  }
}
