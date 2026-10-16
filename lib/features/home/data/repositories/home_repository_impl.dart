import 'package:studentmap/features/home/data/datasources/home_local_data_source.dart';
import 'package:studentmap/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._localDataSource);

  final HomeLocalDataSource _localDataSource;

  @override
  Future<void> initialize() {
    return _localDataSource.initialize();
  }
}
