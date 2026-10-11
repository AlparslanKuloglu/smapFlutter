import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/services/app_logger.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/account/account_module.dart';
import 'package:smap/features/account/data/account_repository.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../core/services/fake_connectivity.dart';

void main() {
  late FakeConnectivity device;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    device = FakeConnectivity();
  });

  tearDown(() async {
    await resetDependencies();
    await device.close();
  });

  test('the data module resolves the repository', () async {
    await configureDependencies(
      config: AppConfig.resolve(),
      logger: AppLogger.silent(),
      cookieJar: CookieJar(),
      connectivity: device,
      dataModules: [registerAccountData],
      serviceModules: const [],
    );

    expect(locator<AccountRepository>(), isA<AccountRepository>());
    expect(locator<AccountRepository>(), same(locator<AccountRepository>()));
  });
}
