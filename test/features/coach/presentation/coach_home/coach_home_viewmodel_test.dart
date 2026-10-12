import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';
import 'package:smap/features/coach/application/coach_code_actions.dart';
import 'package:smap/features/coach/application/coach_students_service.dart';
import 'package:smap/features/coach/data/coach_student_repository.dart';
import 'package:smap/features/coach/data/interview_repository.dart';
import 'package:smap/features/coach/domain/attention_item.dart';
import 'package:smap/features/coach/domain/new_student.dart';
import 'package:smap/features/coach/presentation/coach_home/coach_home_viewmodel.dart';
import 'package:smap/l10n/app_localizations_tr.dart';
import 'package:smap/services/current_user_service.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/feedback/toast_host.dart';
import 'package:smap/shared/ui/feedback/toast_slot.dart';
import 'package:stacked/stacked.dart';

import '../../../../core/network/fake_adapter.dart';
import '../../../schedule/network_harness.dart';
import '../../coach_fixtures.dart';

/// The signed-in coach.
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

class _NoPresenter implements ToastPresenter {
  @override
  bool screenReaderOn = false;

  @override
  bool present(ToastSlot slot, ValueListenable<double?> barHeight) => true;
}

/// The two endpoints of the coach home, each able to fail, to be offline or
/// to wait.
class _Server {
  List<Map<String, Object?>> students = [
    studentJson(id: 's5', name: 'Zeynep', surname: 'Kaya'),
    studentJson(id: 's1', name: 'Alparslan', surname: 'Kuloğlu'),
    studentJson(id: 's2', name: 'Elif', surname: 'Şahin'),
  ];
  List<Map<String, Object?>> interviews = [];
  bool studentsFail = false;
  bool interviewsFail = false;
  bool interviewsOffline = false;
  Completer<void>? interviewsGate;
  int studentCalls = 0;
  final List<Object?> interviewBodies = [];

  late final FakeAdapter adapter = FakeAdapter((options) async {
    switch (options.path) {
      case '/coach/getMyStudents':
        studentCalls++;
        if (studentsFail) return jsonResponse({}, status: 500);
        return jsonResponse({'success': true, 'students': students});
      case '/coach/addNewStudent':
        return jsonResponse({
          'success': true,
          'student': studentJson(id: 's9', name: 'Mert', surname: 'Yıldız'),
        });
      case '/coach/getInterviews':
        interviewBodies.add(options.data);
        final gate = interviewsGate;
        if (gate != null) await gate.future;
        if (interviewsOffline) {
          throw DioException.connectionError(
            requestOptions: options,
            reason: 'offline',
            error: const SocketException('Failed host lookup'),
          );
        }
        if (interviewsFail) return jsonResponse({}, status: 500);
        return jsonResponse({'success': true, 'interviews': interviews});
    }
    return jsonResponse({}, status: 404);
  });
}

class _Attention implements AttentionRepository {
  AppResult<List<AttentionItem>> answer = const Right([]);
  int calls = 0;

  @override
  Future<AppResult<List<AttentionItem>>> getAttentionList() async {
    calls++;
    return answer;
  }
}

/// An interview of [studentId] on [date] (local time, sent as an instant).
Map<String, Object?> _interview(
  String id,
  DateTime date, {
  String student = 'Alparslan',
  String surname = 'Kuloğlu',
  Object? type = 1,
  String studentId = 's1',
}) => interviewJson(
  id: id,
  type: type,
  student: {
    '_id': studentId,
    'firstName': student,
    'surname': surname,
    'photo': '1avatarN3.png',
  },
)..['date'] = date.toUtc().toIso8601String();

void main() {
  late _Server server;
  late NetworkService network;
  late CoachStudentsService students;
  late _FakeUserService user;
  late ToastService toast;
  late DateTime now;
  late List<String> copied;
  late List<String> shared;
  late CoachHomeViewModel viewModel;

  const coach = UserDto(
    id: 'coach-1',
    name: 'Mehmet Özkan',
    role: 'coach',
    photo: 'avatars/2avatarN3.png',
    refCode: 'MOZK-4821',
  );

  CoachHomeViewModel build({
    AttentionRepository? attention,
    Duration timeout = const Duration(seconds: 15),
  }) {
    viewModel = CoachHomeViewModel(
      students: students,
      interviews: InterviewRepository(network),
      currentUser: user,
      codeActions: CoachCodeActions(
        copyText: (text) async => copied.add(text),
        shareText: (text, {origin}) async => shared.add(text),
        toast: toast,
      ),
      attention: attention,
      clock: () => now,
      timeout: timeout,
    );
    return viewModel;
  }

  setUp(() {
    server = _Server();
    now = DateTime(2026, 10, 10, 9);
    network = buildNetwork(server.adapter);
    students = CoachStudentsService(
      repository: CoachStudentRepository(network),
      clock: () => now,
    );
    user = _FakeUserService(coach);
    toast = ToastService(presenter: _NoPresenter());
    copied = [];
    shared = [];
  });

  tearDown(() {
    viewModel.dispose();
    toast.dispose();
    network.dispose();
  });

  group('the band', () {
    test('greets with the first name, the avatar and the code, at once', () {
      build();

      expect(viewModel.firstName, 'Mehmet');
      expect(viewModel.photo, 'avatars/2avatarN3.png');
      expect(viewModel.coachCode, 'MOZK-4821');
      expect(viewModel.studentCount, isNull);
      expect(viewModel.meetingCount, isNull);
    });

    test('the profile first name wins over the name', () {
      user.set(const UserDto(firstName: 'Mehmet', name: 'Özkan Mehmet'));
      build();

      expect(viewModel.firstName, 'Mehmet');
    });

    test('there is no code card without a code', () {
      user.set(const UserDto(name: 'Mehmet Özkan', role: 'coach'));
      build();

      expect(viewModel.coachCode, isNull);
    });

    test('a code of another shape is shown as the server sent it', () {
      user.set(const UserDto(name: 'Mehmet', refCode: 'mozk4821'));
      build();

      expect(viewModel.coachCode, 'MOZK-4821');
    });
  });

  group('students', () {
    test(
      'loading first, then the strip in Turkish alphabetical order',
      () async {
        build();
        expect(viewModel.students.state, SectionState.loading);

        await viewModel.init();

        expect(viewModel.students.state, SectionState.ready);
        expect(viewModel.students.data!.students.map((s) => s.name), [
          'Alparslan Kuloğlu',
          'Elif Şahin',
          'Zeynep Kaya',
        ]);
        expect(viewModel.studentCount, 3);
        expect(viewModel.hasNoStudents, isFalse);
      },
    );

    test(
      'a coach with no student gets the empty page and a zero count',
      () async {
        server.students = [];
        build();

        await viewModel.init();

        expect(viewModel.students.state, SectionState.empty);
        expect(viewModel.hasNoStudents, isTrue);
        expect(viewModel.studentCount, 0);
        expect(viewModel.coachCode, 'MOZK-4821');
      },
    );

    test('a failure is the section error, the meetings still load', () async {
      server.studentsFail = true;
      server.interviews = [_interview('i1', DateTime(2026, 10, 12, 16))];
      build();

      await viewModel.init();

      expect(viewModel.students.state, SectionState.error);
      expect(viewModel.studentCount, isNull);
      expect(viewModel.meetings.state, SectionState.ready);
      expect(viewModel.hasNoStudents, isFalse);
    });

    test('"Tekrar Dene" goes back to the skeleton and refetches', () async {
      server.studentsFail = true;
      build();
      await viewModel.init();
      server.studentsFail = false;

      final retry = viewModel.retryStudents();
      expect(viewModel.students.state, SectionState.loading);
      await retry;

      expect(viewModel.students.state, SectionState.ready);
      expect(viewModel.studentCount, 3);
    });

    test('a refresh that fails keeps the list on screen', () async {
      build();
      await viewModel.init();
      server.studentsFail = true;

      await viewModel.refresh();

      expect(server.studentCalls, 2);
      expect(viewModel.students.state, SectionState.ready);
      expect(viewModel.studentCount, 3);
    });

    test('a meetings load with no answer in time is the error state', () async {
      server.students = [];
      final gate = Completer<void>();
      server.interviewsGate = gate;
      build(timeout: const Duration(milliseconds: 20));

      await viewModel.init();

      expect(viewModel.meetings.state, SectionState.error);
      gate.complete();
    });

    test('a student the coach adds joins the strip and the count', () async {
      build();
      await viewModel.init();

      await students.addStudent(
        const NewStudent(
          firstName: 'Mert',
          lastName: 'Yıldız',
          userName: 'mert.yildiz',
          password: 'x',
          grade: SchoolGrade.grade10,
        ),
      );

      await pumpEventQueue();

      expect(viewModel.studentCount, 4);
      expect(
        viewModel.students.data!.students.map((s) => s.name),
        contains('Mert Yıldız'),
      );
    });

    test('reloadStudents asks the server again', () async {
      build();
      await viewModel.init();

      await viewModel.reloadStudents();

      expect(server.studentCalls, 2);
    });
  });

  group('meetings', () {
    test(
      'the next seven days, earliest first, with the count in the band',
      () async {
        server.interviews = [
          _interview(
            'late',
            DateTime(2026, 10, 15, 19, 30),
            student: 'Elif',
            surname: 'Şahin',
            type: 2,
            studentId: 's2',
          ),
          _interview('past', DateTime(2026, 10, 9, 16)),
          _interview('soon', DateTime(2026, 10, 12, 16)),
          _interview('far', DateTime(2026, 10, 20, 16)),
        ];
        build();

        await viewModel.init();

        final upcoming = viewModel.meetings.data!;
        expect(upcoming.rows.map((m) => m.id), ['soon', 'late']);
        expect(upcoming.rows.first.studentName, 'Alparslan Kuloğlu');
        expect(viewModel.meetingCount, 2);
      },
    );

    test('none in the window is the empty state and a zero count', () async {
      build();

      await viewModel.init();

      expect(viewModel.meetings.state, SectionState.empty);
      expect(viewModel.meetingCount, 0);
    });

    test('asks for the eight calendar days from today', () async {
      build();

      await viewModel.init();

      expect(server.interviewBodies, hasLength(1));
      final filter = (server.interviewBodies.single as Map)['filter'] as Map;
      expect(filter['dates'], [
        '2026-10-10',
        '2026-10-11',
        '2026-10-12',
        '2026-10-13',
        '2026-10-14',
        '2026-10-15',
        '2026-10-16',
        '2026-10-17',
      ]);
    });

    test('a failure is the section error and leaves the count out', () async {
      server.interviewsFail = true;
      build();

      await viewModel.init();

      expect(viewModel.meetings.state, SectionState.error);
      expect(viewModel.meetingCount, isNull);
      expect(viewModel.students.state, SectionState.ready);
    });

    test('no connection is the offline state', () async {
      server.interviewsOffline = true;
      build();

      await viewModel.init();

      expect(viewModel.meetings.state, SectionState.offline);
    });

    test('"Tekrar Dene" fetches only the meetings', () async {
      server.interviewsFail = true;
      build();
      await viewModel.init();
      server.interviewsFail = false;
      server.interviews = [_interview('i1', DateTime(2026, 10, 12, 16))];

      await viewModel.retryMeetings();

      expect(viewModel.meetings.state, SectionState.ready);
      expect(viewModel.meetingCount, 1);
      expect(server.studentCalls, 1);
    });

    test('a name the interview lacks is taken from the student list', () async {
      server.interviews = [
        interviewJson(id: 'i1', student: {'_id': 's2'})
          ..['date'] = DateTime(2026, 10, 12, 16).toUtc().toIso8601String(),
      ];
      build();

      await viewModel.init();

      expect(viewModel.meetings.data!.rows.single.studentName, 'Elif Şahin');
    });
  });

  group('the attention list', () {
    test('does not exist without a repository (flag closed)', () async {
      build();

      await viewModel.init();

      expect(viewModel.attentionEnabled, isFalse);
    });

    test('with one: ready, empty, error and retry', () async {
      final attention = _Attention()
        ..answer = const Right([
          AttentionItem.inactive(
            studentId: 's1',
            name: 'Alparslan Kuloğlu',
            daysSinceLastExam: 45,
          ),
        ]);
      build(attention: attention);
      expect(viewModel.attentionEnabled, isTrue);
      expect(viewModel.attention.state, SectionState.loading);

      await viewModel.init();
      expect(viewModel.attention.state, SectionState.ready);
      expect(viewModel.attention.data, hasLength(1));

      attention.answer = const Right([]);
      await viewModel.refresh();
      expect(viewModel.attention.state, SectionState.empty);

      attention.answer = Left(AppException.parse('x', StackTrace.empty, '/x'));
      await viewModel.retryAttention();
      expect(viewModel.attention.state, SectionState.error);
      expect(attention.calls, 3);
    });
  });

  group('the coaching code', () {
    test('Kopyala puts the code on the clipboard and toasts', () async {
      build();

      await viewModel.copyCode();

      expect(copied, ['MOZK-4821']);
      expect(
        toast.slot.current.value!.title(AppLocalizationsTr()),
        'Kod kopyalandı.',
      );
    });

    test('Paylaş opens the share sheet with the code in a sentence', () async {
      build();

      await viewModel.shareCode(AppLocalizationsTr());

      expect(shared, ["SMAP'te koçluk kodum: MOZK-4821"]);
    });

    test('nothing happens without a code', () async {
      user.set(const UserDto(name: 'Mehmet', role: 'coach'));
      build();

      await viewModel.copyCode();
      await viewModel.shareCode(AppLocalizationsTr());

      expect(copied, isEmpty);
      expect(shared, isEmpty);
    });
  });
}
