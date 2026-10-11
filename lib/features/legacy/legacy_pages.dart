import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smap/core/domain/user_role.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smap/features/auth/domain/usecases/login_usecase.dart';
import 'package:smap/features/auth/presentation/provider/login_provider.dart';
import 'package:smap/features/auth/presentation/screens/login_screen.dart';
import 'package:smap/features/legacy/legacy_theme.dart';
import 'package:smap/features/legacy/session_login_notifier.dart';
import 'package:smap/features/root/presentation/screens/root_screen.dart';
import 'package:smap/features/shared/presentation/provider/user_provider.dart';
import 'package:smap/repository/profile_repository.dart';
import 'package:smap/services/session_manager.dart';

/// The legacy sign-in (`LoginView`, the card with the login form) as
/// `LoginRoute`, until E3 replaces it.
@RoutePage(name: 'LoginRoute')
class LegacyLoginPage extends StatelessWidget {
  const LegacyLoginPage({super.key});

  @override
  Widget build(BuildContext context) => const _LegacyAuthScreen();
}

/// Sign-up. The legacy sign-up form lives inside the sign-in card (the
/// "Kayıt ol" switch), so `RegisterRoute` shows that card until E4 replaces
/// it.
@RoutePage(name: 'RegisterRoute')
class LegacyRegisterPage extends StatelessWidget {
  const LegacyRegisterPage({super.key});

  @override
  Widget build(BuildContext context) => const _LegacyAuthScreen();
}

/// `LoginView` with a `LoginNotifier` that signs in through the session
/// manager (see `SessionLoginNotifier`).
class _LegacyAuthScreen extends StatelessWidget {
  const _LegacyAuthScreen();

  @override
  Widget build(BuildContext context) {
    return LegacyTheme(
      child: ChangeNotifierProvider<LoginNotifier>(
        create: (context) => SessionLoginNotifier(
          session: locator<SessionManager>(),
          loginUseCase: LoginUseCase(context.read<AuthRepositoryImpl>()),
        ),
        child: const LoginView(),
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
