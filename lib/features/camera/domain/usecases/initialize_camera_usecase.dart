import 'package:smap/features/camera/domain/repositories/camera_repository.dart';

class InitializeCameraUseCase {
  const InitializeCameraUseCase(this._repository);

  final CameraRepository _repository;

  Future<void> call() {
    return _repository.initialize();
  }
}
