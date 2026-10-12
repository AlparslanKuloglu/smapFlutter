import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:smap/app/router/guards/auth_guard.dart';
import 'package:smap/app/router/guards/onboarding_guard.dart';
import 'package:smap/app/router/guards/role_guard.dart';
import 'package:smap/app/router/guards/route_access.dart';
import 'package:smap/app/router/guards/route_catalog.dart';
import 'package:smap/app/router/routes/shell_routes.dart';
import 'package:smap/app/shell/coach_shell_view.dart';
import 'package:smap/app/shell/student_shell_view.dart';
import 'package:smap/core/services/app_logger.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/features/auth/domain/session_state.dart';
import 'package:smap/app/shell/tab_stack_pages.dart';
import 'package:smap/features/account/data/dtos/legal_document_dto.dart';
import 'package:smap/features/account/presentation/account/account_view.dart';
import 'package:smap/features/account/presentation/contract_reader/contract_reader_view.dart';
import 'package:smap/features/account/presentation/contracts/contracts_view.dart';
import 'package:smap/features/account/presentation/profile/profile_view.dart';
import 'package:smap/features/account/account_settings_routes.dart';
import 'package:smap/features/account/presentation/coaching/coaching_view.dart';
import 'package:smap/features/account/presentation/deletion/account_deletion_view.dart';
import 'package:smap/features/account/presentation/deletion/done/account_deletion_done_view.dart';
import 'package:smap/features/account/presentation/deletion/progress/account_deletion_progress_view.dart';
import 'package:smap/features/account/presentation/notifications/notifications_view.dart';
import 'package:smap/features/account/presentation/password/password_view.dart';
import 'package:smap/features/cards/presentation/deck/card_deck_view.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';
import 'package:smap/features/exams/presentation/exam_detail/exam_detail_view.dart';
import 'package:smap/features/exams/presentation/question_detail/question_detail_view.dart';
import 'package:smap/shared/ui/navigation/student_scope.dart';
import 'package:smap/features/analytics/presentation/analytics/analytics_view.dart';
import 'package:smap/features/home/presentation/home/home_view.dart';
import 'package:smap/features/lessons/presentation/lesson_detail/lesson_detail_view.dart';
import 'package:smap/features/lessons/presentation/lessons/lessons_view.dart';
import 'package:smap/features/lessons/presentation/topic_detail/topic_detail_view.dart';
import 'package:smap/features/schedule/presentation/new_program/new_program_view.dart';
import 'package:smap/features/schedule/presentation/program_detail/program_detail_view.dart';
import 'package:smap/features/schedule/presentation/program_list/program_list_view.dart';
import 'package:smap/features/schedule/schedule_routes.dart';
import 'package:smap/core/domain/user_role.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/auth/auth_routes.dart';
import 'package:smap/features/auth/presentation/forgot_password/forgot_password_view.dart';
import 'package:smap/features/auth/presentation/login/login_view.dart';
import 'package:smap/features/auth/presentation/register/register_view.dart';
import 'package:smap/features/auth/register_routes.dart';
import 'package:smap/features/coach/presentation/coach_home/coach_home_view.dart';
import 'package:smap/features/coach/presentation/meetings/detail/meeting_detail_view.dart';
import 'package:smap/features/coach/presentation/meetings/meetings_view.dart';
import 'package:smap/features/coach/presentation/students/students_view.dart';
import 'package:smap/features/exams/presentation/result_moment/result_moment_view.dart';
import 'package:smap/features/exams/result_moment_routes.dart';
import 'package:smap/features/scan/presentation/scan_flow/scan_flow_view.dart';
import 'package:smap/features/scan/scan_routes.dart';
import 'package:smap/features/onboarding/onboarding_routes.dart';
import 'package:smap/features/onboarding/presentation/onboarding/onboarding_view.dart';
import 'package:smap/features/onboarding/presentation/welcome/welcome_view.dart';
import 'package:smap/features/startup/presentation/force_update/force_update_view.dart';
import 'package:smap/features/startup/presentation/maintenance/maintenance_view.dart';
import 'package:smap/features/startup/presentation/startup/startup_view.dart';
import 'package:smap/features/startup/presentation/unknown_role/unknown_role_view.dart';
import 'package:smap/features/startup/startup_routes.dart';

part 'app_router.gr.dart';

/// The fade the root flows enter with (250 ms, opacity only, so it already is
/// the "reduce motion" form): the launch screen hands over to the first
/// screen with it (pano 2.1 kare 1 "hazır olunca 250 ms geçiş").
final RouteType fadeRouteType = RouteType.custom(
  transitionsBuilder: TransitionsBuilders.fadeIn,
  duration: AppMotion.base,
  reverseDuration: AppMotion.base,
);

/// The app's one router (auto_route; K1).
///
/// **Routes.** Each feature lists its own routes in
/// `features/<f>/<f>_routes.dart` (`List<AutoRoute> get xxxRoutes`) and this
/// class merges the lists in [routes]; the screen tasks only write their own
/// list, the coordinator adds it here.
///
/// **Guards.** Onboarding > Auth > Role, run for every navigation against the
/// target route's [RouteGroup]; the decisions are the pure functions of
/// `guards/route_access.dart`. `config(reevaluateListenable: RouteRefresh)`
/// re-runs them when the session changes, which is how a sign-out moves the
/// user to the welcome screen and a sign-in to the shell.
///
/// Route names: `XxxView`, `XxxPage` and `XxxScreen` become `XxxRoute`
/// (`replaceInRouteName`, Düzeltmeler #12).
@AutoRouterConfig(replaceInRouteName: 'Page|Screen|View,Route')
final class AppRouter extends RootStackRouter implements RouteCatalog {
  AppRouter({
    required ValueGetter<SessionState> session,
    required DevicePreferences preferences,
    AppLogger? logger,
    super.navigatorKey,
  }) : _session = session,
       _preferences = preferences,
       _logger = logger;

  final ValueGetter<SessionState> _session;
  final DevicePreferences _preferences;
  final AppLogger? _logger;

  @override
  List<AutoRoute> get routes => [
    ...startupRoutes,
    ...onboardingRoutes,
    ...authRoutes,
    ...registerRoutes,
    ...scheduleRootRoutes,
    ...accountSettingsRootRoutes,
    ...scanRootRoutes,
    ...resultMomentRootRoutes,
    ...shellRoutes,
  ];

  @override
  late final List<AutoRouteGuard> guards = [
    OnboardingGuard(
      catalog: this,
      session: _session,
      preferences: _preferences,
      logger: _logger,
    ),
    AuthGuard(
      catalog: this,
      session: _session,
      preferences: _preferences,
      logger: _logger,
    ),
    RoleGuard(
      catalog: this,
      session: _session,
      preferences: _preferences,
      logger: _logger,
    ),
  ];

  @override
  RouteGroup groupOf(String routeName) =>
      _groups[routeName] ?? RouteGroup.other;

  @override
  PageRouteInfo pageFor(RouteTarget target) => switch (target) {
    RouteTarget.onboarding => const OnboardingRoute(),
    RouteTarget.welcome => const WelcomeRoute(),
    RouteTarget.studentShell => const StudentShellRoute(),
    RouteTarget.coachShell => const CoachShellRoute(),
    RouteTarget.unknownRole => const UnknownRoleRoute(),
    RouteTarget.forceUpdate => const ForceUpdateRoute(),
    RouteTarget.maintenance => const MaintenanceRoute(),
  };

  /// Route name to guard group; a name not listed is [RouteGroup.other].
  static final Map<String, RouteGroup> _groups = {
    StartupRoute.name: RouteGroup.startup,
    ForceUpdateRoute.name: RouteGroup.blocking,
    MaintenanceRoute.name: RouteGroup.blocking,
    OnboardingRoute.name: RouteGroup.onboarding,
    WelcomeRoute.name: RouteGroup.signedOutEntry,
    LoginRoute.name: RouteGroup.signedOutEntry,
    RegisterRoute.name: RouteGroup.signedOutEntry,
    StudentShellRoute.name: RouteGroup.studentShell,
    CoachShellRoute.name: RouteGroup.coachShell,
    UnknownRoleRoute.name: RouteGroup.unknownRole,
  };
}
