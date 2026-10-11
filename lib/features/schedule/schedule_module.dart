import 'package:get_it/get_it.dart';

import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/schedule/application/schedule_service.dart';
import 'package:smap/features/schedule/data/schedule_repository.dart';

/// Phase 2 (`kDataModules`): the weekly program endpoints.
void registerScheduleData(GetIt l) {
  l.registerLazySingleton<ScheduleRepository>(
    () => ScheduleRepository(l<NetworkService>()),
  );
}

/// `kSessionModules`: the programs' cache for the signed-in user and for the
/// students a coach opens. Dropped with the session.
void registerScheduleSession(GetIt l) {
  l.registerLazySingleton<ScheduleService>(
    () => ScheduleService(repository: l<ScheduleRepository>()),
    dispose: (service) => service.dispose(),
  );
}
