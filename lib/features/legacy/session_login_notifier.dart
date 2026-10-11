import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/features/auth/domain/usecases/login_usecase.dart';
import 'package:smap/features/auth/presentation/provider/login_provider.dart';
import 'package:smap/features/legacy/legacy_error_text.dart';
import 'package:smap/services/session_manager.dart';

/// The legacy sign-in screen's `LoginNotifier`, signing in through the
/// [SessionManager] (cookie jar, secure user cache, session scope, router
/// guards) instead of the legacy repository.
///
/// The legacy screen reads `state` and listens to the notifier, so this
/// overrides the same two things: [login] and [state]. A wrong password and a
/// network failure get the Turkish sentence of their `AppErrorCode`
/// (`errors_tr.arb`) instead of the legacy "Hata: ..." text and the raw stack
/// trace the old catch block showed.
///
/// On success the state turns to `success` as before; the screen no longer
/// navigates by itself, the router's auth guard opens the shell when the
/// session changes.
class SessionLoginNotifier extends LoginNotifier {
  SessionLoginNotifier({
    required SessionManager session,
    required LoginUseCase loginUseCase,
  }) : _session = session,
       super(loginUseCase);

  final SessionManager _session;
  LoginState _current = const LoginState.initial();

  @override
  LoginState get state => _current;

  @override
  Future<void> login({
    required String username,
    required String password,
  }) async {
    _set(const LoginState.loading());
    final result = await _session.signIn(
      username: username,
      password: password,
    );
    final failure = result.leftOrNull;
    _set(
      failure == null
          ? const LoginState.success()
          : LoginState.failure(legacyErrorText(legacyL10n(), failure.code)),
    );
  }

  void _set(LoginState next) {
    _current = next;
    notifyListeners();
  }
}
