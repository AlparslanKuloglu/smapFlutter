import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';
import 'package:smap/features/coach/application/coach_code_actions.dart';
import 'package:smap/features/coach/application/meeting_schedule_logic.dart';
import 'package:smap/features/coach/application/new_meeting_flow.dart';
import 'package:smap/features/coach/domain/interview_type.dart';
import 'package:smap/features/coach/presentation/coach_home/coach_home_viewmodel.dart';
import 'package:smap/services/current_user_service.dart';
import 'package:stacked/stacked.dart';

import '../meetings/meetings_fakes.dart';

class _User with ListenableServiceMixin implements CurrentUserService {
  @override
  UserDto? get user =>
      const UserDto(id: 'coach-1', name: 'Mehmet Özkan', role: 'coach');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// "Yeni Görüşme" of "Yaklaşan görüşmeler" (pano 10.1 kare 1): the flow of
/// Görüşmelerim, then the upcoming list is read again.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeInterviewRepository interviews;
  late FakeMeetingsDialogs dialogs;
  late FakeCoachStudents source;
  late ToastProbe toast;
  late CoachHomeViewModel viewModel;

  final now = DateTime(2026, 10, 12, 8);

  CoachHomeViewModel build({bool withFlow = true}) {
    final students = studentsService(source);
    return CoachHomeViewModel(
      students: students,
      interviews: interviews,
      currentUser: _User(),
      codeActions: CoachCodeActions(
        copyText: (_) async {},
        shareText: (_, {origin}) async {},
        toast: toast.service,
      ),
      newMeeting: withFlow
          ? NewMeetingFlow(
              dialogs: dialogs,
              interviews: interviews,
              toast: toast.service,
              students: students,
            )
          : null,
      clock: () => now,
    );
  }

  setUp(() {
    interviews = FakeInterviewRepository([alparslanMeeting()]);
    dialogs = FakeMeetingsDialogs();
    source = FakeCoachStudents([alparslanStudent, elifStudent]);
    toast = ToastProbe();
    viewModel = build();
  });

  tearDown(() {
    viewModel.dispose();
    toast.dispose();
  });

  test('a saved meeting reads the upcoming list again', () async {
    await viewModel.init();
    final before = interviews.listCalls;
    dialogs.draft = MeetingDraft(
      studentId: 'student-2',
      type: InterviewType.student,
      moment: DateTime(2026, 10, 13, 16),
    );

    await viewModel.newMeeting();

    expect(interviews.log.any((e) => e.startsWith('create:student-2')), isTrue);
    expect(interviews.listCalls, greaterThan(before));
    expect(toast.text, 'Görüşme kaydedildi.');
    expect(
      viewModel.meetings.data!.rows.map((m) => m.studentName),
      contains('Yeni'),
    );
  });

  test('a dismissed sheet reads nothing again', () async {
    await viewModel.init();
    final before = interviews.listCalls;

    await viewModel.newMeeting();

    expect(dialogs.asked, ['newMeeting']);
    expect(interviews.listCalls, before);
  });

  test('without a flow (a screen that has none) it does nothing', () async {
    final bare = build(withFlow: false);
    addTearDown(bare.dispose);

    await bare.newMeeting();

    expect(dialogs.asked, isEmpty);
    expect(toast.text, isNull);
  });
}
