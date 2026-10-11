import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/features/onboarding/application/onboarding_flow.dart';

/// Where the onboarding screens lead outside their own flow. The view models
/// hold this seam instead of the router, so they stay context-free and
/// testable.
abstract interface class OnboardingNavigator {
  /// The flow is over: the welcome screen replaces it (the intro never shows
  /// again).
  Future<void> toWelcome();

  /// "Giriş Yap" (pano 2.2 kare 5): the sign-in screen (`/auth/login`).
  Future<void> toLogin();

  /// "Kayıt Ol" (pano 2.2 kare 5): the sign-up form (`/auth/register`) with
  /// the picks of the flow; [selections] is `null` when nothing was picked on
  /// this device (a user who signed out and came back to the welcome screen).
  Future<void> toRegister(OnboardingSelections? selections);
}

/// [OnboardingNavigator] on the app router.
final class RouterOnboardingNavigator implements OnboardingNavigator {
  const RouterOnboardingNavigator(this._router);

  final AppRouter _router;

  @override
  Future<void> toWelcome() => _router.replaceAll([const WelcomeRoute()]);

  @override
  Future<void> toLogin() => _router.push(const LoginRoute());

  @override
  Future<void> toRegister(OnboardingSelections? selections) =>
      _router.push(registerRoute(selections));
}

/// The one place the picks of the flow become route parameters of the sign-up
/// form (spec 2.2-5 "Kayıt Ol → /auth/register, role seçimi parametre"; the E4 task's
/// `RegisterView({UserRole? role, SchoolGrade? grade, StudyTrack? track})`).
///
/// E4's route has no parameters yet. When it is merged, this becomes
/// `RegisterRoute(role: picks.role, grade: picks.grade, track: picks.track)`
/// for a non-null `selections` (already passed through
/// [OnboardingSelections.forRegistration]) and a plain `RegisterRoute()`
/// otherwise.
PageRouteInfo registerRoute(OnboardingSelections? selections) =>
    const RegisterRoute();
