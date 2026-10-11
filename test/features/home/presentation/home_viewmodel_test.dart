import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
// ignore: depend_on_referenced_packages
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smap/app/router/app_router.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';
import 'package:smap/features/auth/domain/session_state.dart';
import 'package:smap/features/exams/data/exam_repository.dart';
import 'package:smap/features/home/presentation/home/home_viewmodel.dart';
import 'package:smap/features/lessons/application/lessons_service.dart';
import 'package:smap/features/lessons/data/lesson_content_repository.dart';
import 'package:smap/features/schedule/application/schedule_service.dart';
import 'package:smap/features/schedule/data/schedule_repository.dart';
import 'package:smap/services/current_user_service.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:stacked/stacked.dart';

import '../../../core/network/fake_adapter.dart';
import '../../exams/data/data_harness.dart';
import '../../lessons/data/lesson_fixtures.dart';
import '../application/home_fixtures.dart';

/// The signed-in user the home screen greets.
class _FakeUserService
    with ListenableServiceMixin
    implements CurrentUserService {
  _FakeUserService(this._user);

  UserDto? _user;

  void set(UserDto? user) {
    _user = user;
    notifyListeners();
  }

  @override
  UserDto? get user => _user;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A backend with the five endpoints of the home screen; each can be told to
/// fail or to wait.
class _Backend {
  List<Map<String, Object?>> weeklies = [];
  List<Object?> exams = [];
  List<Object?> secondPage = [];
  Map<String, Object?> missing = {
    'success': true,
    'lessonObj': <String, Object?>{},
  };
  bool weekliesFail = false;
  bool weekliesOffline = false;
  bool examsFail = false;
  bool topicsFail = false;
  bool lessonsFail = false;
  Completer<void>? lessonsGate;
  final List<String> paths = [];

  late final FakeAdapter adapter = FakeAdapter((options) async {
    paths.add(options.path);
    switch (options.path) {
      case '/student/getMyWeeklies':
        if (weekliesOffline) {
          throw DioException.connectionError(
            requestOptions: options,
            reason: 'offline',
            error: const SocketException('Failed host lookup'),
          );
        }
        return weekliesFail
            ? jsonResponse({'success': false}, status: 500)
            : jsonResponse({'success': true, 'weeklies': weeklies});
      case '/student/getMyMockExams':
        if (examsFail) return jsonResponse({'success': false}, status: 500);
        final page = options.queryParameters['page'];
        return jsonResponse({
          'success': true,
          'enrichedMockExams': page == 2 || page == '2' ? secondPage : exams,
        });
      case '/student/getMexamSubjectDetail':
        return topicsFail
            ? jsonResponse({'success': false}, status: 500)
            : jsonResponse(topicAnalysisJson());
      case '/ajax/getGeneralLessons':
        final gate = lessonsGate;
        if (gate != null) await gate.future;
        return lessonsFail
            ? jsonResponse({'success': false}, status: 500)
            : jsonResponse(generalLessonsAnswer());
      case '/student/getLessonsTotalMissing':
        return jsonResponse(missing);
    }
    return jsonResponse({'error': 'no route'}, status: 404);
  });
}

Map<String, Object?> _weekly({String day = '2026-10-10'}) => {
  '_id': 'w1',
  'name': 'Ekim 2. Hafta',
  'content': [
    {
      'id': 'a',
      'day': day,
      'hour': 14,
      'minute': 0,
      'lesson': turkceId,
      'lessonName': 'Türkçe',
      'title': 'Fiilde Çatı',
    },
    {
      'id': 'b',
      'day': day,
      'hour': 10,
      'minute': 0,
      'lesson': tarihId,
      'lessonName': 'Tarih',
      'title': 'İslamiyet Öncesi Türk Tarihi',
    },
  ],
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _Backend backend;
  late NetworkService network;
  late ScheduleService schedule;
  late LessonsService lessons;
  late _FakeUserService user;
  late AppRouter router;
  late DateTime now;
  late HomeViewModel viewModel;
  late int notifications;

  HomeViewModel build({Duration timeout = const Duration(seconds: 15)}) =>
      HomeViewModel(
        schedule: schedule,
        lessons: lessons,
        exams: ExamRepository(network),
        currentUser: user,
        router: router,
        yksDate: DateTime(2027, 6, 19),
        clock: () => now,
        timeout: timeout,
      );

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    router = AppRouter(
      session: () => const SessionState.signedOut(),
      preferences: await DevicePreferences.load(),
    );
    backend = _Backend();
    network = networkOver(backend.adapter);
    now = DateTime(2026, 10, 10, 9, 41);
    schedule = ScheduleService(
      repository: ScheduleRepository(network),
      clock: () => now,
    );
    lessons = LessonsService(
      repository: LessonContentRepository(network),
      clock: () => now,
    );
    user = _FakeUserService(
      const UserDto(name: 'Alparslan Kuloğlu', photo: '1avatarN3.png'),
    );
    viewModel = build();
    notifications = 0;
    viewModel.addListener(() => notifications++);
  });

  tearDown(() {
    viewModel.dispose();
    schedule.dispose();
    lessons.dispose();
    network.dispose();
  });

  group('the band (on the device, no request)', () {
    test('greets with the first word of the name', () {
      expect(viewModel.firstName, 'Alparslan');
      expect(viewModel.photo, '1avatarN3.png');
    });

    test('the profile first name wins', () {
      user.set(const UserDto(firstName: 'Ayşe', name: 'Ayşe Nur Yılmaz'));

      expect(viewModel.firstName, 'Ayşe');
    });

    test('counts the days to the YKS: 252 on 10 Oct 2026 (pano 3.1)', () {
      expect(viewModel.daysLeft, 252);
      expect(viewModel.yksDate, DateTime(2027, 6, 19));
      expect(viewModel.todayDate, DateTime(2026, 10, 10));
    });

    test('has no counter after the exam day', () {
      now = DateTime(2027, 6, 20);
      user.set(const UserDto(name: 'Ayşe'));

      expect(viewModel.daysLeft, isNull);
    });

    test('is worked out again at midnight, without a request', () {
      fakeAsync((async) {
        var clock = DateTime(2026, 10, 10, 23, 59);
        final vm = HomeViewModel(
          schedule: schedule,
          lessons: lessons,
          exams: ExamRepository(network),
          currentUser: user,
          router: router,
          yksDate: DateTime(2027, 6, 19),
          clock: () => clock,
        );
        var changes = 0;
        vm.addListener(() => changes++);
        vm.watchMidnight();
        expect(vm.daysLeft, 252);

        clock = DateTime(2026, 10, 11, 0, 0, 2);
        async.elapse(const Duration(minutes: 1, seconds: 1));

        expect(vm.daysLeft, 251);
        expect(vm.todayDate, DateTime(2026, 10, 11));
        expect(changes, 1);
        expect(backend.paths, isEmpty);

        // And again the next midnight.
        clock = DateTime(2026, 10, 12, 0, 0, 2);
        async.elapse(const Duration(days: 1));
        expect(vm.daysLeft, 250);
        vm.dispose();
      });
    });
  });

  group('the data of the board', () {
    setUp(() {
      backend
        ..weeklies = [_weekly()]
        ..exams = [
          examJson(),
          examJson(
            id: 'res-5',
            name: 'Deneme 5',
            net: 59.25,
            correct: 70,
            wrong: 43,
            blank: 47,
          ),
        ]
        ..missing = {
          'success': true,
          'lessonObj': {
            tarihId: {'1': 60},
            turkceId: {'1': 31},
          },
        };
    });

    test('starts with three skeletons', () {
      expect(viewModel.today.state, SectionState.loading);
      expect(viewModel.lastExam.state, SectionState.loading);
      expect(viewModel.subjects.state, SectionState.loading);
    });

    test('fills the three sections', () async {
      await viewModel.init();

      final today = viewModel.today.data!;
      expect(today.rows.map((r) => '${r.hour}:${r.topic}'), [
        '10:İslamiyet Öncesi Türk Tarihi',
        '14:Fiilde Çatı',
      ]);
      expect(today.programName, 'Ekim 2. Hafta');

      final last = viewModel.lastExam.data!;
      expect(last.name, 'Türkiye Geneli Deneme 6');
      expect(last.kind, NetExamType.ayt);
      expect(last.net, 67.5);
      expect(last.delta, 8.25);
      expect(last.weakestTopic?.name, 'Kurtuluş Savaşı Hazırlık Dönemi');
      expect(last.weakestTopic?.wrong, 9);

      final strip = viewModel.subjects.data!;
      expect(strip.tiles.map((t) => t.name), ['Tarih', 'Türkçe', 'Matematik']);
      expect(strip.tiles.first.missing, 60);
      expect(strip.hasMissingData, isTrue);
      expect(notifications, greaterThan(0));
    });

    test('the previous exam of the type is found on the second page', () async {
      backend
        ..exams = [
          examJson(),
          for (var i = 0; i < 7; i++) examJson(id: 'tyt-$i', type: 1),
        ]
        ..secondPage = [
          examJson(id: 'res-5', net: 59.25, correct: 70, wrong: 43, blank: 47),
        ];

      await viewModel.init();

      expect(viewModel.lastExam.data!.delta, 8.25);
    });

    test('a topic analysis that fails only leaves the sentence out', () async {
      backend.topicsFail = true;

      await viewModel.init();

      expect(viewModel.lastExam.isReady, isTrue);
      expect(viewModel.lastExam.data!.weakestTopic, isNull);
      expect(viewModel.lastExam.data!.delta, 8.25);
    });
  });

  group('a new user (pano 3.1 kare 3)', () {
    test('has no program, no exam and bare tiles', () async {
      await viewModel.init();

      expect(viewModel.today.state, SectionState.empty);
      expect(viewModel.lastExam.state, SectionState.empty);
      expect(viewModel.subjects.isReady, isTrue);
      expect(viewModel.subjects.data!.hasMissingData, isFalse);
    });

    test('programs with nothing today are ready with no rows', () async {
      backend.weeklies = [_weekly(day: '2026-10-12')];

      await viewModel.init();

      expect(viewModel.today.isReady, isTrue);
      expect(viewModel.today.data!.rows, isEmpty);
    });
  });

  group('sections fail on their own (pano 3.2 kare 2)', () {
    test('a failing program leaves the exam and the lessons working', () async {
      backend
        ..weekliesFail = true
        ..exams = [examJson()];

      await viewModel.init();

      expect(viewModel.today.state, SectionState.error);
      expect(viewModel.lastExam.isReady, isTrue);
      expect(viewModel.subjects.isReady, isTrue);
    });

    test('no connection is the offline state', () async {
      backend.weekliesOffline = true;

      await viewModel.init();

      expect(viewModel.today.state, SectionState.offline);
    });

    test('"Tekrar Dene" refreshes only the section', () async {
      backend
        ..weekliesFail = true
        ..exams = [examJson()];
      await viewModel.init();
      final examCalls = backend.paths
          .where((p) => p == '/student/getMyMockExams')
          .length;
      backend
        ..weekliesFail = false
        ..weeklies = [_weekly()];

      await viewModel.retryToday();

      expect(viewModel.today.isReady, isTrue);
      expect(
        backend.paths.where((p) => p == '/student/getMyMockExams').length,
        examCalls,
      );
    });

    test('a failing exam list is the section error, retry recovers', () async {
      backend.examsFail = true;
      await viewModel.init();
      expect(viewModel.lastExam.state, SectionState.error);

      backend
        ..examsFail = false
        ..exams = [examJson()];
      await viewModel.retryLastExam();

      expect(viewModel.lastExam.isReady, isTrue);
    });

    test('failing lessons are the section error, retry recovers', () async {
      backend.lessonsFail = true;
      await viewModel.init();
      expect(viewModel.subjects.state, SectionState.error);

      backend.lessonsFail = false;
      await viewModel.retrySubjects();

      expect(viewModel.subjects.isReady, isTrue);
    });

    test(
      'no answer in 15 s is the error state, a late answer recovers',
      () async {
        viewModel.dispose();
        viewModel = build(timeout: const Duration(milliseconds: 40));
        notifications = 0;
        viewModel.addListener(() => notifications++);
        backend.lessonsGate = Completer<void>();

        await viewModel.init();

        expect(viewModel.subjects.state, SectionState.error);

        backend.lessonsGate!.complete();
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(viewModel.subjects.isReady, isTrue);
      },
    );
  });

  group('refresh keeps what is on screen', () {
    setUp(() {
      backend
        ..weeklies = [_weekly()]
        ..exams = [examJson()];
    });

    test(
      'a failed refresh leaves the saved program, exam and lessons',
      () async {
        await viewModel.init();
        backend
          ..weekliesFail = true
          ..examsFail = true
          ..lessonsFail = true;

        await viewModel.refresh();

        expect(viewModel.today.isReady, isTrue);
        expect(viewModel.lastExam.isReady, isTrue);
        expect(viewModel.subjects.isReady, isTrue);
      },
    );

    test('a refresh fetches everything again and shows the news', () async {
      await viewModel.init();
      backend.exams = [examJson(id: 'res-7', name: 'Deneme 7', net: 70)];

      await viewModel.refresh();

      expect(viewModel.lastExam.data!.examId, 'res-7');
    });
  });
}
