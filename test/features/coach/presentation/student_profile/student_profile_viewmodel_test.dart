import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/features/coach/application/new_meeting_flow.dart';
import 'package:smap/features/coach/application/meeting_schedule_logic.dart';
import 'package:smap/features/coach/application/student_profile.dart';
import 'package:smap/features/coach/data/dtos/coach_student_dto.dart';
import 'package:smap/features/coach/domain/interview_type.dart';
import 'package:smap/features/coach/presentation/student_profile/student_profile_viewmodel.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

import '../../coach_fixtures.dart';
import '../meetings/meetings_fakes.dart';

/// Öğrenci Profili's logic (pano 10.4): who the student is, which tab is on,
/// and "Görüşme Planla". Alparslan Kuloğlu is the board's student.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final alparslan = CoachStudentDto.fromJson(
    studentJson(
      id: 'stu-alparslan',
      name: 'Alparslan',
      surname: 'Kuloğlu',
      totalMexam: 10,
    ),
  );

  late FakeCoachStudents source;
  late FakeInterviewRepository interviews;
  late FakeMeetingsDialogs dialogs;
  late ToastProbe toast;
  late StudentProfileViewModel viewModel;

  StudentProfileViewModel build({
    String id = 'stu-alparslan',
    StudentProfile? initial,
    StudentProfileTab tab = StudentProfileTab.analysis,
    Duration timeout = const Duration(seconds: 15),
    bool loaded = false,
  }) {
    final service = studentsService(source);
    final flow = NewMeetingFlow(
      dialogs: dialogs,
      interviews: interviews,
      toast: toast.service,
      students: service,
    );
    final model = StudentProfileViewModel(
      studentId: id,
      students: service,
      newMeeting: flow,
      initial: initial,
      initialTab: tab,
      timeout: timeout,
    );
    if (loaded) unawaited(service.load());
    return model;
  }

  setUp(() {
    source = FakeCoachStudents([alparslan]);
    interviews = FakeInterviewRepository([]);
    dialogs = FakeMeetingsDialogs();
    toast = ToastProbe();
    viewModel = build();
  });

  tearDown(() {
    viewModel.dispose();
    toast.dispose();
  });

  group('the student', () {
    test('starts as the skeleton and reads the coach\'s list', () async {
      expect(viewModel.profile.state, SectionState.loading);

      await viewModel.init();

      expect(viewModel.profile.state, SectionState.ready);
      final profile = viewModel.profile.data!;
      expect(profile.id, 'stu-alparslan');
      expect(profile.name, 'Alparslan Kuloğlu');
      expect(profile.examCount, 10);
    });

    test(
      'a student that is already in the loaded list needs no request',
      () async {
        final service = studentsService(source);
        await service.load();
        source.failure = serverDown;
        final model = StudentProfileViewModel(
          studentId: 'stu-alparslan',
          students: service,
          newMeeting: NewMeetingFlow(
            dialogs: dialogs,
            interviews: interviews,
            toast: toast.service,
          ),
        );
        addTearDown(model.dispose);

        await model.init();

        expect(model.profile.state, SectionState.ready);
      },
    );

    test(
      'a caller that has the profile shows it at once and reads nothing',
      () async {
        final model = build(
          initial: const StudentProfile(
            id: 'stu-alparslan',
            name: 'Alparslan Kuloğlu',
          ),
        );
        addTearDown(model.dispose);

        expect(model.profile.state, SectionState.ready);
        await model.init();
        expect(model.profile.data!.name, 'Alparslan Kuloğlu');
      },
    );

    test('an id that is not in the list is the "bulunamadı" state', () async {
      final model = build(id: 'stu-none');
      addTearDown(model.dispose);

      await model.init();

      expect(model.profile.state, SectionState.empty);
    });

    test(
      'a list that cannot be read is an error, and Tekrar Dene recovers',
      () async {
        source.failure = serverDown;
        final model = build();
        addTearDown(model.dispose);

        await model.init();
        expect(model.profile.state, SectionState.error);

        source.failure = null;
        final retry = model.retry();
        expect(model.profile.state, SectionState.loading);
        await retry;
        expect(model.profile.state, SectionState.ready);
      },
    );

    test('no connection with nothing saved is the offline state', () async {
      source.failure = offline;
      final model = build();
      addTearDown(model.dispose);

      await model.init();

      expect(model.profile.state, SectionState.offline);
    });

    test(
      'no answer within the limit is the error, not an endless skeleton',
      () async {
        final slow = Completer<void>();
        final service = studentsService(_HangingStudents(slow.future));
        final model = StudentProfileViewModel(
          studentId: 'stu-alparslan',
          students: service,
          newMeeting: NewMeetingFlow(
            dialogs: dialogs,
            interviews: interviews,
            toast: toast.service,
          ),
          timeout: const Duration(milliseconds: 20),
        );
        addTearDown(model.dispose);

        await model.init();

        expect(model.profile.state, SectionState.error);
        slow.complete();
      },
    );

    test('init runs once', () async {
      await viewModel.init();
      await viewModel.init();

      expect(source.students, hasLength(1));
      expect(viewModel.profile.state, SectionState.ready);
    });
  });

  group('tabs (pano 10.4: Analiz · Denemeler · Program)', () {
    test('opens on the tab of the route, only that one is built', () {
      final model = build(tab: StudentProfileTab.program);
      addTearDown(model.dispose);

      expect(model.tab, StudentProfileTab.program);
      expect(model.visited, {StudentProfileTab.program});
    });

    test('a tab is built when first opened and kept', () {
      expect(viewModel.visited, {StudentProfileTab.analysis});

      viewModel.selectTab(StudentProfileTab.exams);
      viewModel.selectTab(StudentProfileTab.program);
      viewModel.selectTab(StudentProfileTab.analysis);

      expect(viewModel.visited, StudentProfileTab.values.toSet());
      expect(viewModel.tab, StudentProfileTab.analysis);
    });

    test(
      'Program keeps the last of Analiz and Denemeler for the shared body',
      () {
        expect(viewModel.analyticsTab, StudentProfileTab.analysis);

        viewModel.selectTab(StudentProfileTab.exams);
        viewModel.selectTab(StudentProfileTab.program);

        expect(viewModel.analyticsTab, StudentProfileTab.exams);
      },
    );

    test('a profile opened on Program starts the analytics body on Analiz', () {
      final model = build(tab: StudentProfileTab.program);
      addTearDown(model.dispose);

      expect(model.analyticsTab, StudentProfileTab.analysis);
    });

    test('choosing the tab on show changes nothing', () {
      var notified = 0;
      viewModel
        ..addListener(() => notified++)
        ..selectTab(StudentProfileTab.analysis);

      expect(notified, 0);
    });
  });

  group('Görüşme Planla', () {
    test('opens the new meeting sheet with this student chosen', () async {
      dialogs.draft = MeetingDraft(
        studentId: 'stu-alparslan',
        type: InterviewType.student,
        moment: DateTime(2026, 10, 12, 16),
      );

      await viewModel.planMeeting();

      expect(dialogs.lastStudentId, 'stu-alparslan');
      expect(interviews.log.first, startsWith('create:stu-alparslan'));
      expect(toast.text, 'Görüşme kaydedildi.');
    });

    test('a dismissed sheet leaves the screen as it was', () async {
      await viewModel.planMeeting();

      expect(dialogs.asked, ['newMeeting']);
      expect(interviews.log, isEmpty);
      expect(viewModel.tab, StudentProfileTab.analysis);
    });
  });
}

class _HangingStudents extends FakeCoachStudents {
  _HangingStudents(this._gate) : super([]);

  final Future<void> _gate;

  @override
  Future<AppResult<List<CoachStudentDto>>> getMyStudents() async {
    await _gate;
    return super.getMyStudents();
  }
}
