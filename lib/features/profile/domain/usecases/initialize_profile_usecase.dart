import 'package:smap/features/profile/domain/repositories/profile_repository.dart';

class InitializeProfileUseCase {
  const InitializeProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<void> call() {
    return _repository.initialize();
  }
}
