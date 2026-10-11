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
/// [AnalyticsView]
class AnalyticsRoute extends PageRouteInfo<AnalyticsRouteArgs> {
  AnalyticsRoute({String? tab, Key? key, List<PageRouteInfo>? children})
    : super(
        AnalyticsRoute.name,
        args: AnalyticsRouteArgs(tab: tab, key: key),
        rawQueryParams: {'tab': tab},
        initialChildren: children,
      );

  static const String name = 'AnalyticsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<AnalyticsRouteArgs>(
        orElse: () => AnalyticsRouteArgs(tab: queryParams.optString('tab')),
      );
      return AnalyticsView(tab: args.tab, key: args.key);
    },
  );
}

class AnalyticsRouteArgs {
  const AnalyticsRouteArgs({this.tab, this.key});

  final String? tab;

  final Key? key;

  @override
  String toString() {
    return 'AnalyticsRouteArgs{tab: $tab, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AnalyticsRouteArgs) return false;
    return tab == other.tab && key == other.key;
  }

  @override
  int get hashCode => tab.hashCode ^ key.hashCode;
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
/// [HomeView]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeView();
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
/// [LessonDetailView]
class LessonDetailRoute extends PageRouteInfo<LessonDetailRouteArgs> {
  LessonDetailRoute({
    required String lessonId,
    String? cat,
    bool onlyMissing = false,
    String? section,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         LessonDetailRoute.name,
         args: LessonDetailRouteArgs(
           lessonId: lessonId,
           cat: cat,
           onlyMissing: onlyMissing,
           section: section,
           key: key,
         ),
         rawPathParams: {'lessonId': lessonId},
         rawQueryParams: {'cat': cat, 'eksik': onlyMissing, 'section': section},
         initialChildren: children,
       );

  static const String name = 'LessonDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final queryParams = data.queryParams;
      final args = data.argsAs<LessonDetailRouteArgs>(
        orElse: () => LessonDetailRouteArgs(
          lessonId: pathParams.getString('lessonId'),
          cat: queryParams.optString('cat'),
          onlyMissing: queryParams.getBool('eksik', false),
          section: queryParams.optString('section'),
        ),
      );
      return LessonDetailView(
        lessonId: args.lessonId,
        cat: args.cat,
        onlyMissing: args.onlyMissing,
        section: args.section,
        key: args.key,
      );
    },
  );
}

class LessonDetailRouteArgs {
  const LessonDetailRouteArgs({
    required this.lessonId,
    this.cat,
    this.onlyMissing = false,
    this.section,
    this.key,
  });

  final String lessonId;

  final String? cat;

  final bool onlyMissing;

  final String? section;

  final Key? key;

  @override
  String toString() {
    return 'LessonDetailRouteArgs{lessonId: $lessonId, cat: $cat, onlyMissing: $onlyMissing, section: $section, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LessonDetailRouteArgs) return false;
    return lessonId == other.lessonId &&
        cat == other.cat &&
        onlyMissing == other.onlyMissing &&
        section == other.section &&
        key == other.key;
  }

  @override
  int get hashCode =>
      lessonId.hashCode ^
      cat.hashCode ^
      onlyMissing.hashCode ^
      section.hashCode ^
      key.hashCode;
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
/// [LessonsView]
class LessonsRoute extends PageRouteInfo<void> {
  const LessonsRoute({List<PageRouteInfo>? children})
    : super(LessonsRoute.name, initialChildren: children);

  static const String name = 'LessonsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LessonsView();
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
/// [NewProgramView]
class NewProgramRoute extends PageRouteInfo<void> {
  const NewProgramRoute({List<PageRouteInfo>? children})
    : super(NewProgramRoute.name, initialChildren: children);

  static const String name = 'NewProgramRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NewProgramView();
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
/// [ProgramDetailView]
class ProgramDetailRoute extends PageRouteInfo<ProgramDetailRouteArgs> {
  ProgramDetailRoute({
    required String programId,
    String? view,
    String? date,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         ProgramDetailRoute.name,
         args: ProgramDetailRouteArgs(
           programId: programId,
           view: view,
           date: date,
           key: key,
         ),
         rawPathParams: {'programId': programId},
         rawQueryParams: {'view': view, 'date': date},
         initialChildren: children,
       );

  static const String name = 'ProgramDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final queryParams = data.queryParams;
      final args = data.argsAs<ProgramDetailRouteArgs>(
        orElse: () => ProgramDetailRouteArgs(
          programId: pathParams.getString('programId'),
          view: queryParams.optString('view'),
          date: queryParams.optString('date'),
        ),
      );
      return ProgramDetailView(
        programId: args.programId,
        view: args.view,
        date: args.date,
        key: args.key,
      );
    },
  );
}

class ProgramDetailRouteArgs {
  const ProgramDetailRouteArgs({
    required this.programId,
    this.view,
    this.date,
    this.key,
  });

  final String programId;

  final String? view;

  final String? date;

  final Key? key;

  @override
  String toString() {
    return 'ProgramDetailRouteArgs{programId: $programId, view: $view, date: $date, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProgramDetailRouteArgs) return false;
    return programId == other.programId &&
        view == other.view &&
        date == other.date &&
        key == other.key;
  }

  @override
  int get hashCode =>
      programId.hashCode ^ view.hashCode ^ date.hashCode ^ key.hashCode;
}

/// generated route for
/// [ProgramListView]
class ProgramListRoute extends PageRouteInfo<void> {
  const ProgramListRoute({List<PageRouteInfo>? children})
    : super(ProgramListRoute.name, initialChildren: children);

  static const String name = 'ProgramListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProgramListView();
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
/// [TopicDetailView]
class TopicDetailRoute extends PageRouteInfo<TopicDetailRouteArgs> {
  TopicDetailRoute({
    required String lessonId,
    required String topicId,
    String? focus = 'firstMissing',
    String? cat,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         TopicDetailRoute.name,
         args: TopicDetailRouteArgs(
           lessonId: lessonId,
           topicId: topicId,
           focus: focus,
           cat: cat,
           key: key,
         ),
         rawPathParams: {'lessonId': lessonId, 'topicId': topicId},
         rawQueryParams: {'focus': focus, 'cat': cat},
         initialChildren: children,
       );

  static const String name = 'TopicDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final queryParams = data.queryParams;
      final args = data.argsAs<TopicDetailRouteArgs>(
        orElse: () => TopicDetailRouteArgs(
          lessonId: pathParams.getString('lessonId'),
          topicId: pathParams.getString('topicId'),
          focus: queryParams.optString('focus', 'firstMissing'),
          cat: queryParams.optString('cat'),
        ),
      );
      return TopicDetailView(
        lessonId: args.lessonId,
        topicId: args.topicId,
        focus: args.focus,
        cat: args.cat,
        key: args.key,
      );
    },
  );
}

class TopicDetailRouteArgs {
  const TopicDetailRouteArgs({
    required this.lessonId,
    required this.topicId,
    this.focus = 'firstMissing',
    this.cat,
    this.key,
  });

  final String lessonId;

  final String topicId;

  final String? focus;

  final String? cat;

  final Key? key;

  @override
  String toString() {
    return 'TopicDetailRouteArgs{lessonId: $lessonId, topicId: $topicId, focus: $focus, cat: $cat, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TopicDetailRouteArgs) return false;
    return lessonId == other.lessonId &&
        topicId == other.topicId &&
        focus == other.focus &&
        cat == other.cat &&
        key == other.key;
  }

  @override
  int get hashCode =>
      lessonId.hashCode ^
      topicId.hashCode ^
      focus.hashCode ^
      cat.hashCode ^
      key.hashCode;
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
