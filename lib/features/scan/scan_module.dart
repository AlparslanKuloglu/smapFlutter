import 'package:get_it/get_it.dart';

import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/onboarding/application/camera_permission.dart';
import 'package:smap/features/onboarding/data/camera_permission_gateway.dart';
import 'package:smap/features/scan/application/image_compressor.dart';
import 'package:smap/features/scan/application/scan_job_service.dart';
import 'package:smap/features/scan/data/scan_camera.dart';
import 'package:smap/features/scan/data/scan_repository.dart';
import 'package:smap/features/scan/data/scan_vision.dart';
import 'package:smap/services/current_user_service.dart';

/// Phase 2 (`kDataModules`): the optical scan's data and services.
///
/// - [ScanRepository] (`opticimage`, `answerArray`, `examrequest`) on the one
///   [NetworkService];
/// - [ScanVision] and [ScanCamera] on the document scanner's native code and
///   the camera plugin;
/// - [ScanJobService]: compress, send, read. The account the reading belongs to
///   is read from [CurrentUserService] (session scope) when the job starts,
///   not when this module registers, so a new session never sends the old one's
///   user;
/// - [CameraPermission] is registered here unless something registered it
///   first (a test, a future onboarding step), so the scan works on its own.
void registerScanData(GetIt l) {
  l
    ..registerLazySingleton<ScanRepository>(
      () => ScanRepository(l<NetworkService>()),
    )
    ..registerLazySingleton<ScanVision>(() => const PlatformScanVision())
    ..registerLazySingleton<ScanCamera>(
      () => CameraPackageScanCamera(vision: l<ScanVision>()),
    )
    ..registerLazySingleton<ScanJobService>(
      () => ScanJobService(
        repository: l<ScanRepository>(),
        user: () => l<CurrentUserService>().user?.toJson(),
        compress: ImageCompressor.compress,
      ),
    );
  if (!l.isRegistered<CameraPermission>()) {
    l.registerLazySingleton<CameraPermission>(
      () => const PermissionHandlerCameraPermission(),
    );
  }
}
