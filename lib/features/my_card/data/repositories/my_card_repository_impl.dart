import 'package:studentmap/features/my_card/data/datasources/my_card_local_data_source.dart';
import 'package:studentmap/features/my_card/domain/repositories/my_card_repository.dart';

class MyCardRepositoryImpl implements MyCardRepository {
  const MyCardRepositoryImpl(this._localDataSource);

  final MyCardLocalDataSource _localDataSource;

  @override
  Future<void> initialize() {
    return _localDataSource.initialize();
  }
}
