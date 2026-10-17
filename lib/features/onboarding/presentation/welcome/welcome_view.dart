import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/onboarding/application/onboarding_draft.dart';
import 'package:smap/features/onboarding/onboarding_navigation.dart';
import 'package:smap/features/onboarding/presentation/welcome/welcome_viewmodel.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/illustrations/app_clay.dart';
import 'package:smap/shared/ui/navigation/app_system_overlay.dart';

part 'widgets/welcome_content.dart';

/// "SMAP'e hoş geldin" (route `/welcome`, `WelcomeRoute`; pano 2.2 kare 5;
/// flow 13.1): the clay map picture (160), the `display` title, one sentence,
/// the primary "Kayıt Ol" and the outline "Giriş Yap" at the bottom.
///
/// The door of the signed-out app: the intro flow ends here, and a sign-out
/// or an account deletion comes back here (flows 13.10). No Back button.
/// "Kayıt Ol" opens the sign-up form with the role, grade and track picked in
/// the intro flow; "Giriş Yap" opens the sign-in screen. Static: nothing
/// loads, so there is no loading, empty or error state to draw.
@RoutePage()
class WelcomeView extends StackedView<WelcomeViewModel> {
  const WelcomeView({super.key});

  @override
  bool get reactive => false;

  @override
  WelcomeViewModel viewModelBuilder(BuildContext context) => WelcomeViewModel(
    draft: OnboardingDraftStore(locator<DevicePreferences>()),
    navigator: RouterOnboardingNavigator(locator<AppRouter>()),
  );

  @override
  Widget builder(
    BuildContext context,
    WelcomeViewModel viewModel,
    Widget? child,
  ) {
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    return AppSystemOverlayRegion(
      kind: AppSystemOverlayKind.bar,
      child: Scaffold(
        backgroundColor: context.appColors.bgCanvas,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const Expanded(child: _WelcomeHero()),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.gutterAuth,
                  AppSpacing.s8,
                  AppSpacing.gutterAuth,
                  safeBottom + AppSpacing.s8,
                ),
                child: const _WelcomeActions(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
