import 'package:smap/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<bool> call({
    required String username,
    required String password,
  }) async {
    return _repository.login(username: username, password: password);
  }
}
