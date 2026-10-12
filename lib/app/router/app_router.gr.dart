// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AccountDeletionDoneView]
class AccountDeletionDoneRoute extends PageRouteInfo<void> {
  const AccountDeletionDoneRoute({List<PageRouteInfo>? children})
    : super(AccountDeletionDoneRoute.name, initialChildren: children);

  static const String name = 'AccountDeletionDoneRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AccountDeletionDoneView();
    },
  );
}

/// generated route for
/// [AccountDeletionProgressView]
class AccountDeletionProgressRoute extends PageRouteInfo<void> {
  const AccountDeletionProgressRoute({List<PageRouteInfo>? children})
    : super(AccountDeletionProgressRoute.name, initialChildren: children);

  static const String name = 'AccountDeletionProgressRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AccountDeletionProgressView();
    },
  );
}

/// generated route for
/// [AccountDeletionView]
class AccountDeletionRoute extends PageRouteInfo<void> {
  const AccountDeletionRoute({List<PageRouteInfo>? children})
    : super(AccountDeletionRoute.name, initialChildren: children);

  static const String name = 'AccountDeletionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AccountDeletionView();
    },
  );
}

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
/// [AccountView]
class AccountRoute extends PageRouteInfo<void> {
  const AccountRoute({List<PageRouteInfo>? children})
    : super(AccountRoute.name, initialChildren: children);

  static const String name = 'AccountRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AccountView();
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
/// [CardDeckView]
class CardDeckRoute extends PageRouteInfo<CardDeckRouteArgs> {
  CardDeckRoute({
    String? lessonId,
    String? examId,
    String? group,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         CardDeckRoute.name,
         args: CardDeckRouteArgs(
           lessonId: lessonId,
           examId: examId,
           group: group,
           key: key,
         ),
         rawQueryParams: {
           'lessonId': lessonId,
           'examId': examId,
           'group': group,
         },
         initialChildren: children,
       );

  static const String name = 'CardDeckRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<CardDeckRouteArgs>(
        orElse: () => CardDeckRouteArgs(
          lessonId: queryParams.optString('lessonId'),
          examId: queryParams.optString('examId'),
          group: queryParams.optString('group'),
        ),
      );
      return CardDeckView(
        lessonId: args.lessonId,
        examId: args.examId,
        group: args.group,
        key: args.key,
      );
    },
  );
}

class CardDeckRouteArgs {
  const CardDeckRouteArgs({this.lessonId, this.examId, this.group, this.key});

  final String? lessonId;

  final String? examId;

  final String? group;

  final Key? key;

  @override
  String toString() {
    return 'CardDeckRouteArgs{lessonId: $lessonId, examId: $examId, group: $group, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CardDeckRouteArgs) return false;
    return lessonId == other.lessonId &&
        examId == other.examId &&
        group == other.group &&
        key == other.key;
  }

  @override
  int get hashCode =>
      lessonId.hashCode ^ examId.hashCode ^ group.hashCode ^ key.hashCode;
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
/// [CoachHomeView]
class CoachHomeRoute extends PageRouteInfo<void> {
  const CoachHomeRoute({List<PageRouteInfo>? children})
    : super(CoachHomeRoute.name, initialChildren: children);

  static const String name = 'CoachHomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CoachHomeView();
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
/// [CoachingView]
class CoachingRoute extends PageRouteInfo<void> {
  const CoachingRoute({List<PageRouteInfo>? children})
    : super(CoachingRoute.name, initialChildren: children);

  static const String name = 'CoachingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CoachingView();
    },
  );
}

/// generated route for
/// [ContractReaderView]
class ContractReaderRoute extends PageRouteInfo<ContractReaderRouteArgs> {
  ContractReaderRoute({
    required LegalDocumentDto document,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         ContractReaderRoute.name,
         args: ContractReaderRouteArgs(document: document, key: key),
         initialChildren: children,
       );

  static const String name = 'ContractReaderRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ContractReaderRouteArgs>();
      return ContractReaderView(document: args.document, key: args.key);
    },
  );
}

class ContractReaderRouteArgs {
  const ContractReaderRouteArgs({required this.document, this.key});

  final LegalDocumentDto document;

  final Key? key;

  @override
  String toString() {
    return 'ContractReaderRouteArgs{document: $document, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ContractReaderRouteArgs) return false;
    return document == other.document && key == other.key;
  }

  @override
  int get hashCode => document.hashCode ^ key.hashCode;
}

/// generated route for
/// [ContractsView]
class ContractsRoute extends PageRouteInfo<void> {
  const ContractsRoute({List<PageRouteInfo>? children})
    : super(ContractsRoute.name, initialChildren: children);

  static const String name = 'ContractsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ContractsView();
    },
  );
}

/// generated route for
/// [ExamDetailView]
class ExamDetailRoute extends PageRouteInfo<ExamDetailRouteArgs> {
  ExamDetailRoute({
    required String examId,
    String? tab,
    StudentRef? student,
    ExamDetail? exam,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         ExamDetailRoute.name,
         args: ExamDetailRouteArgs(
           examId: examId,
           tab: tab,
           student: student,
           exam: exam,
           key: key,
         ),
         rawPathParams: {'examId': examId},
         rawQueryParams: {'tab': tab},
         initialChildren: children,
       );

  static const String name = 'ExamDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final queryParams = data.queryParams;
      final args = data.argsAs<ExamDetailRouteArgs>(
        orElse: () => ExamDetailRouteArgs(
          examId: pathParams.getString('examId'),
          tab: queryParams.optString('tab'),
        ),
      );
      return ExamDetailView(
        examId: args.examId,
        tab: args.tab,
        student: args.student,
        exam: args.exam,
        key: args.key,
      );
    },
  );
}

class ExamDetailRouteArgs {
  const ExamDetailRouteArgs({
    required this.examId,
    this.tab,
    this.student,
    this.exam,
    this.key,
  });

  final String examId;

  final String? tab;

  final StudentRef? student;

  final ExamDetail? exam;

  final Key? key;

  @override
  String toString() {
    return 'ExamDetailRouteArgs{examId: $examId, tab: $tab, student: $student, exam: $exam, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ExamDetailRouteArgs) return false;
    return examId == other.examId &&
        tab == other.tab &&
        student == other.student &&
        exam == other.exam &&
        key == other.key;
  }

  @override
  int get hashCode =>
      examId.hashCode ^
      tab.hashCode ^
      student.hashCode ^
      exam.hashCode ^
      key.hashCode;
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
/// [MeetingDetailView]
class MeetingDetailRoute extends PageRouteInfo<MeetingDetailRouteArgs> {
  MeetingDetailRoute({
    required String meetingId,
    MeetingEntry? meeting,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         MeetingDetailRoute.name,
         args: MeetingDetailRouteArgs(
           meetingId: meetingId,
           meeting: meeting,
           key: key,
         ),
         rawPathParams: {'meetingId': meetingId},
         initialChildren: children,
       );

  static const String name = 'MeetingDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<MeetingDetailRouteArgs>(
        orElse: () => MeetingDetailRouteArgs(
          meetingId: pathParams.getString('meetingId'),
        ),
      );
      return MeetingDetailView(
        meetingId: args.meetingId,
        meeting: args.meeting,
        key: args.key,
      );
    },
  );
}

class MeetingDetailRouteArgs {
  const MeetingDetailRouteArgs({
    required this.meetingId,
    this.meeting,
    this.key,
  });

  final String meetingId;

  final MeetingEntry? meeting;

  final Key? key;

  @override
  String toString() {
    return 'MeetingDetailRouteArgs{meetingId: $meetingId, meeting: $meeting, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MeetingDetailRouteArgs) return false;
    return meetingId == other.meetingId &&
        meeting == other.meeting &&
        key == other.key;
  }

  @override
  int get hashCode => meetingId.hashCode ^ meeting.hashCode ^ key.hashCode;
}

/// generated route for
/// [MeetingsView]
class MeetingsRoute extends PageRouteInfo<void> {
  const MeetingsRoute({List<PageRouteInfo>? children})
    : super(MeetingsRoute.name, initialChildren: children);

  static const String name = 'MeetingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MeetingsView();
    },
  );
}

/// generated route for
/// [NewProgramView]
class NewProgramRoute extends PageRouteInfo<NewProgramRouteArgs> {
  NewProgramRoute({
    StudentRef? student,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         NewProgramRoute.name,
         args: NewProgramRouteArgs(student: student, key: key),
         initialChildren: children,
       );

  static const String name = 'NewProgramRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NewProgramRouteArgs>(
        orElse: () => const NewProgramRouteArgs(),
      );
      return NewProgramView(student: args.student, key: args.key);
    },
  );
}

class NewProgramRouteArgs {
  const NewProgramRouteArgs({this.student, this.key});

  final StudentRef? student;

  final Key? key;

  @override
  String toString() {
    return 'NewProgramRouteArgs{student: $student, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NewProgramRouteArgs) return false;
    return student == other.student && key == other.key;
  }

  @override
  int get hashCode => student.hashCode ^ key.hashCode;
}

/// generated route for
/// [NotificationsView]
class NotificationsRoute extends PageRouteInfo<void> {
  const NotificationsRoute({List<PageRouteInfo>? children})
    : super(NotificationsRoute.name, initialChildren: children);

  static const String name = 'NotificationsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NotificationsView();
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
/// [PasswordView]
class PasswordRoute extends PageRouteInfo<void> {
  const PasswordRoute({List<PageRouteInfo>? children})
    : super(PasswordRoute.name, initialChildren: children);

  static const String name = 'PasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PasswordView();
    },
  );
}

/// generated route for
/// [ProfileView]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileView();
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
    StudentRef? student,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         ProgramDetailRoute.name,
         args: ProgramDetailRouteArgs(
           programId: programId,
           view: view,
           date: date,
           student: student,
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
        student: args.student,
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
    this.student,
    this.key,
  });

  final String programId;

  final String? view;

  final String? date;

  final StudentRef? student;

  final Key? key;

  @override
  String toString() {
    return 'ProgramDetailRouteArgs{programId: $programId, view: $view, date: $date, student: $student, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProgramDetailRouteArgs) return false;
    return programId == other.programId &&
        view == other.view &&
        date == other.date &&
        student == other.student &&
        key == other.key;
  }

  @override
  int get hashCode =>
      programId.hashCode ^
      view.hashCode ^
      date.hashCode ^
      student.hashCode ^
      key.hashCode;
}

/// generated route for
/// [ProgramListView]
class ProgramListRoute extends PageRouteInfo<ProgramListRouteArgs> {
  ProgramListRoute({
    StudentRef? student,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         ProgramListRoute.name,
         args: ProgramListRouteArgs(student: student, key: key),
         initialChildren: children,
       );

  static const String name = 'ProgramListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProgramListRouteArgs>(
        orElse: () => const ProgramListRouteArgs(),
      );
      return ProgramListView(student: args.student, key: args.key);
    },
  );
}

class ProgramListRouteArgs {
  const ProgramListRouteArgs({this.student, this.key});

  final StudentRef? student;

  final Key? key;

  @override
  String toString() {
    return 'ProgramListRouteArgs{student: $student, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProgramListRouteArgs) return false;
    return student == other.student && key == other.key;
  }

  @override
  int get hashCode => student.hashCode ^ key.hashCode;
}

/// generated route for
/// [QuestionDetailView]
class QuestionDetailRoute extends PageRouteInfo<QuestionDetailRouteArgs> {
  QuestionDetailRoute({
    required String examId,
    int lesson = 0,
    int q = 1,
    StudentRef? student,
    ExamDetail? exam,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         QuestionDetailRoute.name,
         args: QuestionDetailRouteArgs(
           examId: examId,
           lesson: lesson,
           q: q,
           student: student,
           exam: exam,
           key: key,
         ),
         rawPathParams: {'examId': examId},
         rawQueryParams: {'lesson': lesson, 'q': q},
         initialChildren: children,
       );

  static const String name = 'QuestionDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final queryParams = data.queryParams;
      final args = data.argsAs<QuestionDetailRouteArgs>(
        orElse: () => QuestionDetailRouteArgs(
          examId: pathParams.getString('examId'),
          lesson: queryParams.getInt('lesson', 0),
          q: queryParams.getInt('q', 1),
        ),
      );
      return QuestionDetailView(
        examId: args.examId,
        lesson: args.lesson,
        q: args.q,
        student: args.student,
        exam: args.exam,
        key: args.key,
      );
    },
  );
}

class QuestionDetailRouteArgs {
  const QuestionDetailRouteArgs({
    required this.examId,
    this.lesson = 0,
    this.q = 1,
    this.student,
    this.exam,
    this.key,
  });

  final String examId;

  final int lesson;

  final int q;

  final StudentRef? student;

  final ExamDetail? exam;

  final Key? key;

  @override
  String toString() {
    return 'QuestionDetailRouteArgs{examId: $examId, lesson: $lesson, q: $q, student: $student, exam: $exam, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! QuestionDetailRouteArgs) return false;
    return examId == other.examId &&
        lesson == other.lesson &&
        q == other.q &&
        student == other.student &&
        exam == other.exam &&
        key == other.key;
  }

  @override
  int get hashCode =>
      examId.hashCode ^
      lesson.hashCode ^
      q.hashCode ^
      student.hashCode ^
      exam.hashCode ^
      key.hashCode;
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
/// [ResultMomentView]
class ResultMomentRoute extends PageRouteInfo<ResultMomentRouteArgs> {
  ResultMomentRoute({
    required String examId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         ResultMomentRoute.name,
         args: ResultMomentRouteArgs(examId: examId, key: key),
         rawPathParams: {'examId': examId},
         initialChildren: children,
       );

  static const String name = 'ResultMomentRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ResultMomentRouteArgs>(
        orElse: () =>
            ResultMomentRouteArgs(examId: pathParams.getString('examId')),
      );
      return ResultMomentView(examId: args.examId, key: args.key);
    },
  );
}

class ResultMomentRouteArgs {
  const ResultMomentRouteArgs({required this.examId, this.key});

  final String examId;

  final Key? key;

  @override
  String toString() {
    return 'ResultMomentRouteArgs{examId: $examId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ResultMomentRouteArgs) return false;
    return examId == other.examId && key == other.key;
  }

  @override
  int get hashCode => examId.hashCode ^ key.hashCode;
}

/// generated route for
/// [ScanFlowView]
class ScanFlowRoute extends PageRouteInfo<void> {
  const ScanFlowRoute({List<PageRouteInfo>? children})
    : super(ScanFlowRoute.name, initialChildren: children);

  static const String name = 'ScanFlowRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ScanFlowView();
    },
  );
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
/// [StudentProfileView]
class StudentProfileRoute extends PageRouteInfo<StudentProfileRouteArgs> {
  StudentProfileRoute({
    required String studentId,
    String? tab,
    StudentRef? student,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         StudentProfileRoute.name,
         args: StudentProfileRouteArgs(
           studentId: studentId,
           tab: tab,
           student: student,
           key: key,
         ),
         rawPathParams: {'studentId': studentId},
         rawQueryParams: {'tab': tab},
         initialChildren: children,
       );

  static const String name = 'StudentProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final queryParams = data.queryParams;
      final args = data.argsAs<StudentProfileRouteArgs>(
        orElse: () => StudentProfileRouteArgs(
          studentId: pathParams.getString('studentId'),
          tab: queryParams.optString('tab'),
        ),
      );
      return StudentProfileView(
        studentId: args.studentId,
        tab: args.tab,
        student: args.student,
        key: args.key,
      );
    },
  );
}

class StudentProfileRouteArgs {
  const StudentProfileRouteArgs({
    required this.studentId,
    this.tab,
    this.student,
    this.key,
  });

  final String studentId;

  final String? tab;

  final StudentRef? student;

  final Key? key;

  @override
  String toString() {
    return 'StudentProfileRouteArgs{studentId: $studentId, tab: $tab, student: $student, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StudentProfileRouteArgs) return false;
    return studentId == other.studentId &&
        tab == other.tab &&
        student == other.student &&
        key == other.key;
  }

  @override
  int get hashCode =>
      studentId.hashCode ^ tab.hashCode ^ student.hashCode ^ key.hashCode;
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
/// [StudentsView]
class StudentsRoute extends PageRouteInfo<void> {
  const StudentsRoute({List<PageRouteInfo>? children})
    : super(StudentsRoute.name, initialChildren: children);

  static const String name = 'StudentsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const StudentsView();
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
