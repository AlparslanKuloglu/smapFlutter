import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:smap/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:smap/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smap/features/auth/data/session/session_store.dart';
import 'package:smap/features/auth/domain/usecases/complete_onboarding_usecase.dart';
import 'package:smap/features/auth/domain/usecases/get_legal_documents_usecase.dart';
import 'package:smap/features/auth/domain/usecases/login_usecase.dart';
import 'package:smap/features/auth/domain/usecases/logout_usecase.dart';
import 'package:smap/features/auth/domain/usecases/register_usecase.dart';
import 'package:smap/features/home/presentation/provider/home_provider.dart';
import 'package:smap/features/legacy/legacy_user_bridge.dart';
import 'package:smap/features/legacy/session_auth_repository.dart';
import 'package:smap/features/shared/presentation/provider/user_provider.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/repository/cards_repository.dart';
import 'package:smap/repository/profile_repository.dart';
import 'package:smap/services/session_manager.dart';

/// The legacy `Provider` tree (what `main.dart` used to build around its
/// `MaterialApp`), kept above `MaterialApp.router` so the legacy screens find
/// their repositories, use cases and notifiers.
///
/// Same providers as before, with these differences:
///
/// - `AuthRepositoryImpl` is a [SessionAuthRepository]: sign-in, sign-out and
///   the intro flag go through the session manager and `DevicePreferences`;
/// - there is one [UserProvider] (the old tree had two, and the one inside the
///   repository was never the one the widgets read), fed by a
///   [LegacyUserBridge] from the session, so nothing calls `loadUserData`
///   by hand any more;
/// - the [HomeProvider] is replaced by a fresh one when the user signs out, so
///   the next account does not see the previous one's lessons and students;
/// - `AppStartNotifier` is gone (the launch screen and the guards decide the
///   first route).
class LegacyScope extends StatefulWidget {
  const LegacyScope({required this.child, super.key});

  final Widget child;

  @override
  State<LegacyScope> createState() => _LegacyScopeState();
}

class _LegacyScopeState extends State<LegacyScope> {
  final UserProvider _userProvider = UserProvider();
  final ProfileRepository _profileRepository = ProfileRepository();
  final CardsRepository _cardsRepository = CardsRepository();
  late final SessionAuthRepository _auth = SessionAuthRepository(
    session: locator<SessionManager>(),
    preferences: locator<DevicePreferences>(),
    localDataSource: AuthLocalDataSource(),
    remoteDataSource: AuthRemoteDataSource(),
    userProvider: _userProvider,
  );
  late final LegacyUserBridge _bridge = LegacyUserBridge(
    session: locator<SessionManager>(),
    userProvider: _userProvider,
    restoreMirror: (user) async {
      await locator<SessionStore>().write(user);
    },
    onSignedOut: _resetHome,
  );
  HomeProvider _home = HomeProvider();

  @override
  void initState() {
    super.initState();
    _bridge.start();
  }

  /// A new, empty [HomeProvider] for the next account. The old one is only
  /// dropped, not disposed: a request it started may still answer.
  void _resetHome() {
    if (!mounted) return;
    setState(() => _home = HomeProvider());
  }

  @override
  void dispose() {
    _bridge.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepositoryImpl>.value(value: _auth),
        Provider<ProfileRepository>.value(value: _profileRepository),
        Provider<CardsRepository>.value(value: _cardsRepository),
        Provider<CompleteOnboardingUseCase>.value(
          value: CompleteOnboardingUseCase(_auth),
        ),
        Provider<LoginUseCase>.value(value: LoginUseCase(_auth)),
        Provider<RegisterUseCase>.value(value: RegisterUseCase(_auth)),
        Provider<GetLegalDocumentsUseCase>.value(
          value: GetLegalDocumentsUseCase(_auth),
        ),
        Provider<LogoutUseCase>.value(value: LogoutUseCase(_auth)),
        ChangeNotifierProvider<HomeProvider>.value(value: _home),
        ChangeNotifierProvider<UserProvider>.value(value: _userProvider),
      ],
      child: widget.child,
    );
  }
}
