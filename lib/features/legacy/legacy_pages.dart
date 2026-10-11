import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smap/core/domain/user_role.dart';
import 'package:smap/features/auth/domain/usecases/get_legal_documents_usecase.dart';
import 'package:smap/features/auth/domain/usecases/register_usecase.dart';
import 'package:smap/features/auth/presentation/login/login_view.dart';
import 'package:smap/features/auth/presentation/provider/register_provider.dart';
import 'package:smap/features/auth/presentation/widgets/register_form.dart';
import 'package:smap/features/legacy/legacy_theme.dart';
import 'package:smap/features/onboarding/onboarding_page.dart';
import 'package:smap/features/root/presentation/screens/root_screen.dart';
import 'package:smap/features/shared/presentation/provider/user_provider.dart';
import 'package:smap/repository/profile_repository.dart';

/// The legacy intro (`OnboardingScreen`) as `OnboardingRoute`, until E2
/// replaces it.
@RoutePage(name: 'OnboardingRoute')
class LegacyOnboardingPage extends StatelessWidget {
  const LegacyOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const LegacyTheme(child: OnboardingScreen());
}

/// The welcome screen. There is none in the legacy app: the sign-in card was
/// the first screen after the intro, so `WelcomeRoute` shows the new sign-in
/// screen (`LoginView`, E3) until E2 draws the real welcome screen. As the
/// first screen of the stack it has no back button.
@RoutePage(name: 'WelcomeRoute')
class LegacyWelcomePage extends StatelessWidget {
  const LegacyWelcomePage({super.key});

  @override
  Widget build(BuildContext context) => const LoginView();
}

/// Sign-up. The legacy sign-up form lived inside the sign-in card (the "Kayıt
/// ol" switch); the sign-in is the new `LoginView` now, so `RegisterRoute`
/// shows the form on its own (`_LegacyRegisterHost`) until E4 replaces it.
@RoutePage(name: 'RegisterRoute')
class LegacyRegisterPage extends StatelessWidget {
  const LegacyRegisterPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const LegacyTheme(child: _LegacyRegisterHost());
}

/// The legacy `RegisterForm` with the `RegisterNotifier` the sign-in card used
/// to create for it (the legal documents load when the screen opens). The
/// form's back button closes the page. A finished sign-up signs in through
/// `SessionAuthRepository` and the router's guards open the shell.
class _LegacyRegisterHost extends StatelessWidget {
  const _LegacyRegisterHost();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RegisterNotifier>(
      create: (context) => RegisterNotifier(
        registerUseCase: context.read<RegisterUseCase>(),
        getLegalDocumentsUseCase: context.read<GetLegalDocumentsUseCase>(),
      )..fetchLegalDocuments(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: RegisterForm(onBackPressed: () => context.router.maybePop()),
          ),
        ),
      ),
    );
  }
}

/// The whole legacy student app (`RootScreen` with its bottom bar and four
/// tabs) as the one tab of `StudentShellRoute`, until E5 builds the new shell.
@RoutePage()
class LegacyStudentRootPage extends StatelessWidget {
  const LegacyStudentRootPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const _LegacyRoot(role: UserRole.student);
}

/// The whole legacy coach app as the one tab of `CoachShellRoute`, until E5
/// builds the new shell.
@RoutePage()
class LegacyCoachRootPage extends StatelessWidget {
  const LegacyCoachRootPage({super.key});

  @override
  Widget build(BuildContext context) => const _LegacyRoot(role: UserRole.coach);
}

/// `RootScreen` for [role]. It waits for the legacy `UserProvider` to hold the
/// user (it reads the user JSON asynchronously), as the old `/home` route did.
class _LegacyRoot extends StatelessWidget {
  const _LegacyRoot({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return LegacyTheme(
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          if (userProvider.userRole == null) {
            userProvider.loadUserData();
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return RootScreen(
            profileRepository: context.read<ProfileRepository>(),
            userRole: role.wireName ?? 'student',
          );
        },
      ),
    );
  }
}
