import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/services/app_logger.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/coach/application/coach_students_service.dart';
import 'package:smap/features/coach/coach_module.dart';
import 'package:smap/features/coach/data/coach_student_repository.dart';
import 'package:smap/features/coach/data/interview_repository.dart';
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
    'the repositories are in the root scope, the service in the session',
    () async {
      await configureDependencies(
        config: AppConfig.resolve(),
        logger: AppLogger.silent(),
        cookieJar: CookieJar(),
        connectivity: device,
        dataModules: [registerCoachData],
        serviceModules: const [],
      );

      expect(locator<CoachStudentRepository>(), isA<CoachStudentRepository>());
      expect(locator<InterviewRepository>(), isA<InterviewRepository>());
      expect(locator.isRegistered<CoachStudentsService>(), isFalse);

      pushSessionScope(modules: [registerCoachSession]);
      final service = locator<CoachStudentsService>();
      expect(service, same(locator<CoachStudentsService>()));
      expect(service.isLoaded, isFalse);

      await popSessionScope();
      expect(locator.isRegistered<CoachStudentsService>(), isFalse);
    },
  );
}
