import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/coach/application/meeting_schedule_logic.dart';
import 'package:smap/features/coach/application/new_meeting_flow.dart';
import 'package:smap/features/coach/domain/interview_type.dart';

import '../presentation/meetings/meetings_fakes.dart';

/// The flow Görüşmelerim, Öğrenci Profili ("Görüşme Planla") and Koç Anasayfa
/// ("Yeni Görüşme") share (pano 10.5 kare 2). Values: Alparslan Kuloğlu,
/// Pazartesi 12 Ekim 2026 16:00 (Ek C).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeInterviewRepository repository;
  late FakeMeetingsDialogs dialogs;
  late FakeCoachStudents students;
  late ToastProbe toast;

  final draft = MeetingDraft(
    studentId: 'student-1',
    type: InterviewType.student,
    moment: DateTime(2026, 10, 12, 16),
  );

  NewMeetingFlow build({bool withStudents = true}) => NewMeetingFlow(
    dialogs: dialogs,
    interviews: repository,
    toast: toast.service,
    students: withStudents ? studentsService(students) : null,
  );

  setUp(() {
    repository = FakeInterviewRepository([]);
    dialogs = FakeMeetingsDialogs();
    students = FakeCoachStudents([elifStudent, alparslanStudent]);
    toast = ToastProbe();
  });

  tearDown(() => toast.dispose());

  test('opens the sheet with the coach\'s students in Turkish order', () async {
    dialogs.draft = draft;

    final saved = await build().run();

    expect(saved, isTrue);
    expect(dialogs.lastStudents!.map((s) => s.firstName), [
      'Alparslan',
      'Elif',
    ]);
    expect(dialogs.lastStudentId, isNull);
  });

  test('"Görüşme Planla" opens it with the student chosen', () async {
    dialogs.draft = draft;

    await build().run(studentId: 'student-1');

    expect(dialogs.lastStudentId, 'student-1');
  });

  test('a saved meeting says so and answers true', () async {
    dialogs.draft = draft;

    final saved = await build().run(studentId: 'student-1');

    expect(saved, isTrue);
    expect(repository.log.first, startsWith('create:student-1'));
    expect(toast.text, 'Görüşme kaydedildi.');
  });

  test('a note goes in a second call, under the new id', () async {
    dialogs.draft = MeetingDraft(
      studentId: 'student-1',
      type: InterviewType.parent,
      moment: DateTime(2026, 10, 12, 16),
      note: 'Tarih eksikleri için haftada 3 saat ayrıldı.',
    );

    await build().run();

    expect(repository.log, [startsWith('create:student-1'), 'addNote:iv-100']);
  });

  test('a note that failed does not undo the meeting', () async {
    repository.noteFailure = serverDown;
    dialogs.draft = MeetingDraft(
      studentId: 'student-1',
      type: InterviewType.student,
      moment: DateTime(2026, 10, 12, 16),
      note: 'Not',
    );

    final saved = await build().run();

    expect(saved, isTrue);
    expect(toast.isError, isTrue);
  });

  test(
    'a meeting that failed keeps the sheet open and saves nothing',
    () async {
      repository.createFailure = serverDown;
      dialogs.draft = draft;

      final saved = await build().run();

      expect(saved, isFalse);
      expect(dialogs.submitted, [false]);
      expect(toast.isError, isTrue);
    },
  );

  test('a dismissed sheet saves nothing and says nothing', () async {
    final saved = await build().run();

    expect(saved, isFalse);
    expect(repository.log, isEmpty);
    expect(toast.text, isNull);
  });

  test('a coach with no student is told, and no sheet opens', () async {
    students.students = [];

    final saved = await build().run();

    expect(saved, isFalse);
    expect(dialogs.asked, isEmpty);
    expect(toast.text, isNotNull);
  });

  test('students that cannot be read are an error, no sheet', () async {
    students.failure = offline;

    final saved = await build().run();

    expect(saved, isFalse);
    expect(dialogs.asked, isEmpty);
    expect(toast.isError, isTrue);
  });

  test(
    'without the student service (the shell preview) it is an error',
    () async {
      final saved = await build(withStudents: false).run();

      expect(saved, isFalse);
      expect(toast.isError, isTrue);
    },
  );
}
