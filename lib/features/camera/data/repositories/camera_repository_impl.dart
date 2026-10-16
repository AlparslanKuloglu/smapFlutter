import 'package:studentmap/features/camera/data/datasources/camera_local_data_source.dart';
import 'package:studentmap/features/camera/domain/repositories/camera_repository.dart';

class CameraRepositoryImpl implements CameraRepository {
  const CameraRepositoryImpl(this._localDataSource);

  final CameraLocalDataSource _localDataSource;

  @override
  Future<void> initialize() {
    return _localDataSource.initialize();
  }
}
