part of '../login_view.dart';

/// The bar with the back button (pano 2.3 kare 1 to 4: CaretLeft at the top
/// left, no bar title until the page scrolls).
///
/// The back button is there only while a page lies under this one. The
/// first screen of the signed-out app has none (the welcome screen opens the
/// sign-in as its own page today). The stack changes while a page opens or
/// closes, so the bar listens to the router instead of asking once: a screen
/// opened above (the reset flow) must not give this page a button.
class _LoginBar extends StatelessWidget {
  const _LoginBar();

  @override
  Widget build(BuildContext context) {
    final title = AppLocalizations.of(context).login_title;
    return ListenableBuilder(
      listenable: AutoRouter.of(context),
      builder: (context, _) {
        final below = context.routeBelowName;
        // The launch screen is never somewhere to go back to (it stays under
        // the first screen after a cold start).
        final hasBack = below != null && below != StartupRoute.name;
        return AppDetailBar(
          title: title,
          gutter: AppSpacing.gutterAuth,
          leading: hasBack
              ? AppDetailBarLeading.back
              : AppDetailBarLeading.none,
        );
      },
    );
  }
}
