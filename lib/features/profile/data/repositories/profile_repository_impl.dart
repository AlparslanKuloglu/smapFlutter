import 'package:studentmap/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:studentmap/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._localDataSource);

  final ProfileLocalDataSource _localDataSource;

  @override
  Future<void> initialize() {
    return _localDataSource.initialize();
  }
}
