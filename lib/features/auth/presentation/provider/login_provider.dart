import 'package:flutter/foundation.dart';
import 'package:studentmap/features/auth/domain/usecases/login_usecase.dart';

class LoginNotifier extends ChangeNotifier {
  LoginNotifier(this._loginUseCase) : _state = const LoginState.initial();

  final LoginUseCase _loginUseCase;
  LoginState _state;
  LoginState get state => _state;

  Future<void> login({
    required String username,
    required String password,
  }) async {
    _updateState(const LoginState.loading());
    try {
      final isSuccess = await _loginUseCase(
        username: username,
        password: password,
      );
      if (isSuccess) {
        _updateState(const LoginState.success());
      } else {
        _updateState(
          const LoginState.failure('Hata: Kullanıcı adı veya şifre yanlış.'),
        );
      }
    } catch (e, s) {
      // e: Hatanın kendisi (örn. Timeout, 404, Null Error)
      // s: Hatanın oluştuğu dosya ve satır bilgisi (Stack Trace)

      final fullErrorMessage =
          '''
🔴 Hata Oluştu!
Mesaj: $e

📍 Kaynak:
${s.toString().split('\n').take(3).join('\n')} 
''';

      _updateState(LoginState.failure(fullErrorMessage));
    }
  }

  void _updateState(LoginState newState) {
    _state = newState;
    notifyListeners();
  }
}

class LoginState {
  const LoginState._({
    required this.isLoading,
    required this.isSuccess,
    this.errorMessage,
  });

  const LoginState.initial() : this._(isLoading: false, isSuccess: false);

  const LoginState.loading() : this._(isLoading: true, isSuccess: false);

  const LoginState.success() : this._(isLoading: false, isSuccess: true);

  const LoginState.failure(String message)
    : this._(isLoading: false, isSuccess: false, errorMessage: message);

  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
}
