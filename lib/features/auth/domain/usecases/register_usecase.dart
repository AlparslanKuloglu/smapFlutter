// features/auth/domain/usecases/register_usecase.dart
import '../repositories/auth_repository.dart'; // Kendi yoluna göre düzenle

class RegisterUseCase {
  RegisterUseCase(this._repository);

  final AuthRepository _repository;

  // Parametreleri tek tek almak yerine doğrudan payload map'ini kabul ediyoruz
  Future<bool> call({
    required Map<String, dynamic> payload,
  }) {
    // Aldığımız bu paketlenmiş veriyi hiç bozmadan direkt Repository katmanına paslıyoruz
    return _repository.register(payload: payload);
  }
}