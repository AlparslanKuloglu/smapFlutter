import 'package:get_it/get_it.dart';

import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/cards/data/card_repository.dart';

/// Phase 2 (`kDataModules`): the info-card endpoints. Stateless, one lazy
/// singleton in the root scope.
void registerCardsData(GetIt l) {
  l.registerLazySingleton<CardRepository>(
    () => CardRepository(l<NetworkService>()),
  );
}
