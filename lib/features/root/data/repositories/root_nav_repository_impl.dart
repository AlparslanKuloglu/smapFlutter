import 'package:studentmap/features/root/data/datasources/root_nav_local_data_source.dart';
import 'package:studentmap/features/root/domain/repositories/root_nav_repository.dart';

class RootNavRepositoryImpl implements RootNavRepository {
  const RootNavRepositoryImpl(this._localDataSource);

  final RootNavLocalDataSource _localDataSource;

  @override
  Future<void> initialize() {
    return _localDataSource.initialize();
  }
}
