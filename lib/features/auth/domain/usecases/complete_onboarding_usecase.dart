import 'package:studentmap/features/auth/domain/repositories/auth_repository.dart';

class CompleteOnboardingUseCase {
  const CompleteOnboardingUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() {
    return _repository.completeOnboarding();
  }
}
