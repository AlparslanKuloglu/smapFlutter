import 'package:studentmap/features/root/domain/repositories/root_nav_repository.dart';

class InitializeRootNavUseCase {
  const InitializeRootNavUseCase(this._repository);

  final RootNavRepository _repository;

  Future<void> call() {
    return _repository.initialize();
  }
}
