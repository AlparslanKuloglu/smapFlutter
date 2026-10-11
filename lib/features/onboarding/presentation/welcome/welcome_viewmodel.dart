import 'package:stacked/stacked.dart';

import 'package:smap/features/onboarding/application/onboarding_draft.dart';
import 'package:smap/features/onboarding/onboarding_navigation.dart';

/// The logic of the welcome screen (pano 2.2 kare 5): where "Kayıt Ol" and
/// "Giriş Yap" lead. Context-free; navigation goes through
/// [OnboardingNavigator].
class WelcomeViewModel extends BaseViewModel {
  WelcomeViewModel({
    required OnboardingDraftStore draft,
    required OnboardingNavigator navigator,
  }) : _draft = draft,
       _navigator = navigator;

  final OnboardingDraftStore _draft;
  final OnboardingNavigator _navigator;

  /// "Kayıt Ol": the sign-up form opens with what the user picked in the
  /// intro flow ("Seçtiklerin kayıt formuna gelir"). With no draft on the
  /// device (a user who signed out and came back here) nothing is passed.
  Future<void> register() => _navigator.toRegister(
    _draft.exists ? _draft.read().selections.forRegistration() : null,
  );

  /// "Giriş Yap": the sign-in screen.
  Future<void> login() => _navigator.toLogin();
}
