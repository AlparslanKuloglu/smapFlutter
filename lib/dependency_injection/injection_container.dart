import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:get_it/get_it.dart';

import 'package:smap/app/app_module.dart';
import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/core/services/app_logger.dart';
import 'package:smap/core/services/connectivity_service.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/account/account_module.dart';
import 'package:smap/features/analytics/analytics_module.dart';
import 'package:smap/features/auth/auth_module.dart';
import 'package:smap/features/cards/cards_module.dart';
import 'package:smap/features/coach/coach_module.dart';
import 'package:smap/features/exams/exams_module.dart';
import 'package:smap/features/lessons/lessons_module.dart';
import 'package:smap/features/schedule/schedule_module.dart';
import 'package:smap/features/startup/startup_module.dart';

/// Global service locator.
///
/// ViewModels are never registered here; a view's `viewModelBuilder` builds
/// them and passes services in from `locator`.
final GetIt locator = GetIt.instance;

/// Name of the signed-in scope. Everything registered while it is on the
/// stack (per-user caches, the current-user service, session-bound
/// repositories) is disposed when it is popped, so sign-out and account
/// deletion cannot leak the previous user's data into the next session.
const String kSessionScope = 'session';

/// A feature's DI entry point: `void registerXxx(GetIt l)` in
/// `features/<f>/xxx_module.dart`.
///
/// Register lazily (`registerLazySingleton`) so the order inside a phase does
/// not matter and unused features cost nothing at startup.
typedef ModuleRegistration = void Function(GetIt l);

/// Phase 2: data layer modules (datasources, repositories).
///
/// The coordinator adds `registerXxx` functions here as features land.
const List<ModuleRegistration> kDataModules = <ModuleRegistration>[
  registerAuthData,
  registerExamsData,
  registerAnalyticsData,
  registerLessonsData,
  registerCardsData,
  registerScheduleData,
  registerAccountData,
  registerCoachData,
];

/// Phase 3: app-level services modules (stateful services that depend on the
/// repositories of phase 2).
///
/// `registerAuthServices` (the session manager) comes first; the router and
/// the toast service (`registerAppServices`) read it lazily.
const List<ModuleRegistration> kServiceModules = <ModuleRegistration>[
  registerAuthServices,
  registerStartupServices,
  registerAppServices,
];

/// Modules that register into the [kSessionScope] when it is pushed.
const List<ModuleRegistration> kSessionModules = <ModuleRegistration>[
  registerAuthSession,
  registerLessonsSession,
  registerScheduleSession,
  registerCoachSession,
];

/// Registers the root scope in three phases, in this order:
///
/// 1. **core**: [AppLogger], [AppConfig], [DevicePreferences],
///    [ConnectivityService], [NetworkService]. Awaited, because everything
///    later may use them on its first call.
/// 2. **data**: [dataModules].
/// 3. **services**: [serviceModules].
///
/// Call it once before `runApp`. A second call is a no-op until
/// [resetDependencies], which keeps hot restarts and tests simple.
///
/// The optional parameters exist for tests: they replace what needs a
/// platform (config defines, the on-disk cookie jar, the connectivity plugin).
Future<void> configureDependencies({
  AppConfig? config,
  AppLogger? logger,
  CookieJar? cookieJar,
  Connectivity? connectivity,
  List<ModuleRegistration> dataModules = kDataModules,
  List<ModuleRegistration> serviceModules = kServiceModules,
}) async {
  if (locator.isRegistered<AppConfig>()) return;

  await _registerCore(
    config: config,
    logger: logger,
    cookieJar: cookieJar,
    connectivity: connectivity,
  );
  _runModules(dataModules);
  _runModules(serviceModules);
  locator<AppLogger>().info('root scope ready', name: 'DI');
}

Future<void> _registerCore({
  AppConfig? config,
  AppLogger? logger,
  CookieJar? cookieJar,
  Connectivity? connectivity,
}) async {
  final log = logger ?? AppLogger();
  final appConfig = config ?? AppConfig.fromEnvironment();

  final preferences = await DevicePreferences.load(logger: log);
  final connectivityService = ConnectivityService(
    connectivity: connectivity,
    logger: log,
  );
  await connectivityService.initialize();
  final jar = cookieJar ?? await NetworkService.createPersistentCookieJar();

  locator
    ..registerSingleton<AppLogger>(log)
    ..registerSingleton<AppConfig>(appConfig)
    ..registerSingleton<DevicePreferences>(preferences)
    ..registerSingleton<ConnectivityService>(
      connectivityService,
      dispose: (service) => service.dispose(),
    )
    ..registerSingleton<NetworkService>(
      NetworkService(
        config: appConfig,
        cookieJar: jar,
        logger: log,
        connectivity: connectivityService,
      ),
      dispose: (service) => service.dispose(),
    );
}

void _runModules(List<ModuleRegistration> modules) {
  for (final register in modules) {
    register(locator);
  }
}

/// Whether the [kSessionScope] is on the stack.
bool get isSessionScopeActive => locator.hasScope(kSessionScope);

/// Pushes the [kSessionScope] and runs the session [modules].
///
/// Call it when a session starts: after a successful sign-in and when a
/// stored session is restored. It also re-arms `NetworkService.
/// onSessionExpired`. Idempotent: does nothing when the scope is already on
/// the stack.
void pushSessionScope({List<ModuleRegistration> modules = kSessionModules}) {
  if (isSessionScopeActive) {
    if (locator.isRegistered<AppLogger>()) {
      locator<AppLogger>().warning('session scope already active', name: 'DI');
    }
    return;
  }
  locator.pushNewScope(scopeName: kSessionScope);
  _runModules(modules);
  if (locator.isRegistered<NetworkService>()) {
    locator<NetworkService>().markSessionStarted();
  }
}

/// Pops the [kSessionScope], disposing every registration made in it. Safe to
/// call when no session is active.
Future<void> popSessionScope() async {
  if (!isSessionScopeActive) return;
  await locator.dropScope(kSessionScope);
}

/// Disposes and forgets everything (tests, full sign-out of the process).
Future<void> resetDependencies() => locator.reset();
