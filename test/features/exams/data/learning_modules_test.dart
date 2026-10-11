import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/services/app_logger.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/analytics/analytics_module.dart';
import 'package:smap/features/analytics/data/analytics_repository.dart';
import 'package:smap/features/cards/cards_module.dart';
import 'package:smap/features/cards/data/card_repository.dart';
import 'package:smap/features/exams/data/exam_repository.dart';
import 'package:smap/features/exams/exams_module.dart';
import 'package:smap/features/lessons/application/lessons_service.dart';
import 'package:smap/features/lessons/data/lesson_content_repository.dart';
import 'package:smap/features/lessons/lessons_module.dart';

import '../../../core/services/fake_connectivity.dart';

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

  Future<void> configure() => configureDependencies(
    config: AppConfig.resolve(),
    logger: AppLogger.silent(),
    cookieJar: CookieJar(),
    connectivity: device,
    dataModules: [
      registerExamsData,
      registerAnalyticsData,
      registerLessonsData,
      registerCardsData,
    ],
    // Only the data layer under test; the app's services (session manager,
    // router) need modules this test does not register.
    serviceModules: const [],
  );

  test('the data modules resolve to one repository each', () async {
    await configure();

    expect(locator<ExamRepository>(), same(locator<ExamRepository>()));
    expect(locator<AnalyticsRepository>(), isA<AnalyticsRepository>());
    expect(locator<LessonContentRepository>(), isA<LessonContentRepository>());
    expect(locator<CardRepository>(), isA<CardRepository>());
    expect(locator.isRegistered<LessonsService>(), isFalse);
  });

  test('the lessons service lives and dies with the session scope', () async {
    await configure();

    pushSessionScope(modules: [registerLessonsSession]);
    final service = locator<LessonsService>();
    expect(service, same(locator<LessonsService>()));
    expect(service.entries, isEmpty);

    await popSessionScope();

    expect(locator.isRegistered<LessonsService>(), isFalse);
  });
}
