import 'package:smap/features/home/domain/repositories/home_repository.dart';

class InitializeHomeUseCase {
  const InitializeHomeUseCase(this._repository);

  final HomeRepository _repository;

  Future<void> call() {
    return _repository.initialize();
  }
}
