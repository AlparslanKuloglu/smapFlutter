import 'package:get_it/get_it.dart';

import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/account/data/account_repository.dart';

/// Phase 2 (`kDataModules`): the account endpoints (profile, legal texts,
/// account deletion, coach link).
void registerAccountData(GetIt l) {
  l.registerLazySingleton<AccountRepository>(
    () => AccountRepository(l<NetworkService>()),
  );
}
