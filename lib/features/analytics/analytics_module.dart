import 'package:get_it/get_it.dart';

import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/analytics/data/analytics_repository.dart';

/// Phase 2 (`kDataModules`): the Analizlerim endpoints. Stateless, one lazy
/// singleton in the root scope; a coach passes the student's id per call.
void registerAnalyticsData(GetIt l) {
  l.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepository(l<NetworkService>()),
  );
}
