import 'package:smap/features/my_card/domain/repositories/my_card_repository.dart';

class InitializeMyCardUseCase {
  const InitializeMyCardUseCase(this._repository);

  final MyCardRepository _repository;

  Future<void> call() {
    return _repository.initialize();
  }
}
