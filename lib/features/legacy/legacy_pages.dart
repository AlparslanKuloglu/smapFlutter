import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smap/features/auth/domain/usecases/login_usecase.dart';
import 'package:smap/features/auth/presentation/provider/login_provider.dart';
import 'package:smap/features/auth/presentation/screens/login_screen.dart';
import 'package:smap/features/legacy/legacy_theme.dart';
import 'package:smap/features/legacy/session_login_notifier.dart';
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
