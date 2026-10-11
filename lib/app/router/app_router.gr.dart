// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AccountTabPage]
class AccountTabRoute extends PageRouteInfo<void> {
  const AccountTabRoute({List<PageRouteInfo>? children})
    : super(AccountTabRoute.name, initialChildren: children);

  static const String name = 'AccountTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AccountTabPage();
    },
  );
}

/// generated route for
/// [AnalyticsTabPage]
class AnalyticsTabRoute extends PageRouteInfo<void> {
  const AnalyticsTabRoute({List<PageRouteInfo>? children})
    : super(AnalyticsTabRoute.name, initialChildren: children);

  static const String name = 'AnalyticsTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AnalyticsTabPage();
    },
  );
}

/// generated route for
/// [CoachAccountTabPage]
class CoachAccountTabRoute extends PageRouteInfo<void> {
  const CoachAccountTabRoute({List<PageRouteInfo>? children})
    : super(CoachAccountTabRoute.name, initialChildren: children);

  static const String name = 'CoachAccountTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CoachAccountTabPage();
    },
  );
}

/// generated route for
/// [CoachHomeTabPage]
class CoachHomeTabRoute extends PageRouteInfo<void> {
  const CoachHomeTabRoute({List<PageRouteInfo>? children})
    : super(CoachHomeTabRoute.name, initialChildren: children);

  static const String name = 'CoachHomeTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CoachHomeTabPage();
    },
  );
}

/// generated route for
/// [CoachMeetingsTabPage]
class CoachMeetingsTabRoute extends PageRouteInfo<void> {
  const CoachMeetingsTabRoute({List<PageRouteInfo>? children})
    : super(CoachMeetingsTabRoute.name, initialChildren: children);

  static const String name = 'CoachMeetingsTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CoachMeetingsTabPage();
    },
  );
}

/// generated route for
/// [CoachShellView]
class CoachShellRoute extends PageRouteInfo<void> {
  const CoachShellRoute({List<PageRouteInfo>? children})
    : super(CoachShellRoute.name, initialChildren: children);

  static const String name = 'CoachShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CoachShellView();
    },
  );
}

/// generated route for
/// [CoachStudentsTabPage]
class CoachStudentsTabRoute extends PageRouteInfo<void> {
  const CoachStudentsTabRoute({List<PageRouteInfo>? children})
    : super(CoachStudentsTabRoute.name, initialChildren: children);

  static const String name = 'CoachStudentsTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CoachStudentsTabPage();
    },
  );
}

/// generated route for
/// [ForceUpdateView]
class ForceUpdateRoute extends PageRouteInfo<void> {
  const ForceUpdateRoute({List<PageRouteInfo>? children})
    : super(ForceUpdateRoute.name, initialChildren: children);

  static const String name = 'ForceUpdateRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ForceUpdateView();
    },
  );
}

/// generated route for
/// [ForgotPasswordView]
class ForgotPasswordRoute extends PageRouteInfo<void> {
  const ForgotPasswordRoute({List<PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ForgotPasswordView();
    },
  );
}

/// generated route for
/// [HomeTabPage]
class HomeTabRoute extends PageRouteInfo<void> {
  const HomeTabRoute({List<PageRouteInfo>? children})
    : super(HomeTabRoute.name, initialChildren: children);

  static const String name = 'HomeTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeTabPage();
    },
  );
}

/// generated route for
/// [LegacyAccountTabPage]
class LegacyAccountTabRoute extends PageRouteInfo<void> {
  const LegacyAccountTabRoute({List<PageRouteInfo>? children})
    : super(LegacyAccountTabRoute.name, initialChildren: children);

  static const String name = 'LegacyAccountTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LegacyAccountTabPage();
    },
  );
}

/// generated route for
/// [LegacyAnalyticsTabPage]
class LegacyAnalyticsTabRoute
    extends PageRouteInfo<LegacyAnalyticsTabRouteArgs> {
  LegacyAnalyticsTabRoute({
    Key? key,
    int? initialTabIndex,
    List<PageRouteInfo>? children,
  }) : super(
         LegacyAnalyticsTabRoute.name,
         args: LegacyAnalyticsTabRouteArgs(
           key: key,
           initialTabIndex: initialTabIndex,
         ),
         initialChildren: children,
       );

  static const String name = 'LegacyAnalyticsTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LegacyAnalyticsTabRouteArgs>(
        orElse: () => const LegacyAnalyticsTabRouteArgs(),
      );
      return LegacyAnalyticsTabPage(
        key: args.key,
        initialTabIndex: args.initialTabIndex,
      );
    },
  );
}

class LegacyAnalyticsTabRouteArgs {
  const LegacyAnalyticsTabRouteArgs({this.key, this.initialTabIndex});

  final Key? key;

  final int? initialTabIndex;

  @override
  String toString() {
    return 'LegacyAnalyticsTabRouteArgs{key: $key, initialTabIndex: $initialTabIndex}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LegacyAnalyticsTabRouteArgs) return false;
    return key == other.key && initialTabIndex == other.initialTabIndex;
  }

  @override
  int get hashCode => key.hashCode ^ initialTabIndex.hashCode;
}

/// generated route for
/// [LegacyCoachAccountTabPage]
class LegacyCoachAccountTabRoute extends PageRouteInfo<void> {
  const LegacyCoachAccountTabRoute({List<PageRouteInfo>? children})
    : super(LegacyCoachAccountTabRoute.name, initialChildren: children);

  static const String name = 'LegacyCoachAccountTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LegacyCoachAccountTabPage();
    },
  );
}

/// generated route for
/// [LegacyCoachHomeTabPage]
class LegacyCoachHomeTabRoute extends PageRouteInfo<void> {
  const LegacyCoachHomeTabRoute({List<PageRouteInfo>? children})
    : super(LegacyCoachHomeTabRoute.name, initialChildren: children);

  static const String name = 'LegacyCoachHomeTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LegacyCoachHomeTabPage();
    },
  );
}

/// generated route for
/// [LegacyHomeTabPage]
class LegacyHomeTabRoute extends PageRouteInfo<void> {
  const LegacyHomeTabRoute({List<PageRouteInfo>? children})
    : super(LegacyHomeTabRoute.name, initialChildren: children);

  static const String name = 'LegacyHomeTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LegacyHomeTabPage();
    },
  );
}

/// generated route for
/// [LegacyLessonsTabPage]
class LegacyLessonsTabRoute extends PageRouteInfo<void> {
  const LegacyLessonsTabRoute({List<PageRouteInfo>? children})
    : super(LegacyLessonsTabRoute.name, initialChildren: children);

  static const String name = 'LegacyLessonsTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LegacyLessonsTabPage();
    },
  );
}

/// generated route for
/// [LegacyMeetingsTabPage]
class LegacyMeetingsTabRoute extends PageRouteInfo<void> {
  const LegacyMeetingsTabRoute({List<PageRouteInfo>? children})
    : super(LegacyMeetingsTabRoute.name, initialChildren: children);

  static const String name = 'LegacyMeetingsTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LegacyMeetingsTabPage();
    },
  );
}

/// generated route for
/// [LegacyScanPage]
class LegacyScanRoute extends PageRouteInfo<void> {
  const LegacyScanRoute({List<PageRouteInfo>? children})
    : super(LegacyScanRoute.name, initialChildren: children);

  static const String name = 'LegacyScanRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LegacyScanPage();
    },
  );
}

/// generated route for
/// [LegacyStudentsTabPage]
class LegacyStudentsTabRoute extends PageRouteInfo<void> {
  const LegacyStudentsTabRoute({List<PageRouteInfo>? children})
    : super(LegacyStudentsTabRoute.name, initialChildren: children);

  static const String name = 'LegacyStudentsTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LegacyStudentsTabPage();
    },
  );
}

/// generated route for
/// [LessonsTabPage]
class LessonsTabRoute extends PageRouteInfo<void> {
  const LessonsTabRoute({List<PageRouteInfo>? children})
    : super(LessonsTabRoute.name, initialChildren: children);

  static const String name = 'LessonsTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LessonsTabPage();
    },
  );
}

/// generated route for
/// [LoginView]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginView();
    },
  );
}

/// generated route for
/// [MaintenanceView]
class MaintenanceRoute extends PageRouteInfo<void> {
  const MaintenanceRoute({List<PageRouteInfo>? children})
    : super(MaintenanceRoute.name, initialChildren: children);

  static const String name = 'MaintenanceRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MaintenanceView();
    },
  );
}

/// generated route for
/// [OnboardingView]
class OnboardingRoute extends PageRouteInfo<void> {
  const OnboardingRoute({List<PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OnboardingView();
    },
  );
}

/// generated route for
/// [RegisterView]
class RegisterRoute extends PageRouteInfo<RegisterRouteArgs> {
  RegisterRoute({
    UserRole? role,
    SchoolGrade? grade,
    StudyTrack? track,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         RegisterRoute.name,
         args: RegisterRouteArgs(
           role: role,
           grade: grade,
           track: track,
           key: key,
         ),
         initialChildren: children,
       );

  static const String name = 'RegisterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RegisterRouteArgs>(
        orElse: () => const RegisterRouteArgs(),
      );
      return RegisterView(
        role: args.role,
        grade: args.grade,
        track: args.track,
        key: args.key,
      );
    },
  );
}

class RegisterRouteArgs {
  const RegisterRouteArgs({this.role, this.grade, this.track, this.key});

  final UserRole? role;

  final SchoolGrade? grade;

  final StudyTrack? track;

  final Key? key;

  @override
  String toString() {
    return 'RegisterRouteArgs{role: $role, grade: $grade, track: $track, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RegisterRouteArgs) return false;
    return role == other.role &&
        grade == other.grade &&
        track == other.track &&
        key == other.key;
  }

  @override
  int get hashCode =>
      role.hashCode ^ grade.hashCode ^ track.hashCode ^ key.hashCode;
}

/// generated route for
/// [StartupView]
class StartupRoute extends PageRouteInfo<void> {
  const StartupRoute({List<PageRouteInfo>? children})
    : super(StartupRoute.name, initialChildren: children);

  static const String name = 'StartupRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const StartupView();
    },
  );
}

/// generated route for
/// [StudentShellView]
class StudentShellRoute extends PageRouteInfo<void> {
  const StudentShellRoute({List<PageRouteInfo>? children})
    : super(StudentShellRoute.name, initialChildren: children);

  static const String name = 'StudentShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const StudentShellView();
    },
  );
}

/// generated route for
/// [UnknownRoleView]
class UnknownRoleRoute extends PageRouteInfo<void> {
  const UnknownRoleRoute({List<PageRouteInfo>? children})
    : super(UnknownRoleRoute.name, initialChildren: children);

  static const String name = 'UnknownRoleRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UnknownRoleView();
    },
  );
}

/// generated route for
/// [WelcomeView]
class WelcomeRoute extends PageRouteInfo<void> {
  const WelcomeRoute({List<PageRouteInfo>? children})
    : super(WelcomeRoute.name, initialChildren: children);

  static const String name = 'WelcomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WelcomeView();
    },
  );
}
