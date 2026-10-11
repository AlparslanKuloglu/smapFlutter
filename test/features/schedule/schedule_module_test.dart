import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/services/app_logger.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/schedule/application/schedule_service.dart';
import 'package:smap/features/schedule/data/schedule_repository.dart';
import 'package:smap/features/schedule/schedule_module.dart';
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

  test(
    'the repository is in the root scope, the service in the session',
    () async {
      await configureDependencies(
        config: AppConfig.resolve(),
        logger: AppLogger.silent(),
        cookieJar: CookieJar(),
        connectivity: device,
        dataModules: [registerScheduleData],
        serviceModules: const [],
      );

      expect(locator<ScheduleRepository>(), isA<ScheduleRepository>());
      expect(locator.isRegistered<ScheduleService>(), isFalse);

      pushSessionScope(modules: [registerScheduleSession]);
      final service = locator<ScheduleService>();
      expect(service, same(locator<ScheduleService>()));

      await popSessionScope();
      expect(locator.isRegistered<ScheduleService>(), isFalse);
      expect(locator<ScheduleRepository>(), isA<ScheduleRepository>());
    },
  );
}
