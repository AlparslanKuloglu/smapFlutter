import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smap/features/legacy/legacy_error_text.dart';
import 'package:smap/services/session_manager.dart';

/// The legacy `AuthRepositoryImpl` that the legacy screens still get from
/// `Provider<AuthRepositoryImpl>`, with the parts that decide who is signed in
/// handed to the [SessionManager] and the intro flag to `DevicePreferences`.
///
/// What it changes, so there is one session instead of two:
///
/// - [validateSession] answers from the session manager (no second
///   `checkUser` call, and offline launches keep the cached user);
/// - [login] signs in through the manager (the sign-in screen itself uses
///   `SessionLoginNotifier`; this keeps any other caller consistent);
/// - [register] runs the legacy call, then signs in with the same credentials
///   so the manager and the router know about the new account;
/// - [logout] ends the session through the manager, which clears both cookie
///   stacks (they share one jar), the secure cache, the legacy keys and the
///   session scope;
/// - [getOnboardingCompleted] and [completeOnboarding] use the
///   `DevicePreferences` flag.
///
/// Everything else (legal documents) stays legacy. It goes away with the last
/// legacy auth screen (E3, E4).
class SessionAuthRepository extends AuthRepositoryImpl {
  SessionAuthRepository({
    required SessionManager session,
    required DevicePreferences preferences,
    required super.localDataSource,
    required super.remoteDataSource,
    required super.userProvider,
  }) : _session = session,
       _preferences = preferences;

  final SessionManager _session;
  final DevicePreferences _preferences;

  @override
  Future<bool> validateSession() async {
    await _session.restore();
    return _session.isSignedIn;
  }

  @override
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    final result = await _session.signIn(
      username: username,
      password: password,
    );
    return result.rightOrNull != null;
  }

  @override
  Future<bool> register({required Map<String, dynamic> payload}) async {
    final created = await super.register(payload: payload);
    if (!created) return false;
    final account = payload['userJson'];
    final username = account is Map ? account['userName'] : null;
    final password = account is Map ? account['password'] : null;
    if (username is! String || password is! String) {
      throw Exception(legacyL10n().startup_registerSignInFailed);
    }
    final result = await _session.signIn(
      username: username,
      password: password,
    );
    if (result.rightOrNull == null) {
      throw Exception(legacyL10n().startup_registerSignInFailed);
    }
    return true;
  }

  @override
  Future<bool> logout() async {
    await _session.signOut();
    return true;
  }

  @override
  Future<bool> getOnboardingCompleted() async =>
      _preferences.getBool(DevicePreferences.onboardingCompletedKey) ?? false;

  @override
  Future<void> completeOnboarding() =>
      _preferences.setBool(DevicePreferences.onboardingCompletedKey, true);
}
