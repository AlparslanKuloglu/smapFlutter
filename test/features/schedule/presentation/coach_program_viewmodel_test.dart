import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/schedule/presentation/new_program/new_program_viewmodel.dart';
import 'package:smap/features/schedule/presentation/program_detail/program_detail_viewmodel.dart';
import 'package:smap/features/schedule/presentation/program_list/program_list_viewmodel.dart';
import 'package:smap/features/schedule/presentation/sheets/topic_picker/topic_picker_viewmodel.dart';
import 'package:smap/features/schedule/application/program_view_preference.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

import 'program_harness.dart';

/// The program screens in a coach's view (Tur 12 A, brief 14.1 to 14.3): the
/// student's id goes with every request, and the coach writes (the old "salt
/// okunur" of pano 10.4 kare 3 is overruled). Alparslan's programs are the
/// board's (Ek C and the brief's §7).
void main() {
  const student = 'stu-alparslan';

  late ProgramRig rig;

  setUp(() => rig = ProgramRig());
  tearDown(() => rig.dispose());

  /// Every request the server saw carried [student].
  void expectAllForStudent() {
    expect(rig.server.requests, isNotEmpty);
    for (final request in rig.server.requests) {
      expect(request.endsWith(' $student'), isTrue, reason: request);
    }
  }

  group('Programlar (brief 14.1 kare 2)', () {
    late ProgramListViewModel viewModel;

    setUp(() {
      viewModel = ProgramListViewModel(
        schedule: rig.schedule,
        navigator: rig.navigator,
        online: rig.online,
        studentId: student,
        clock: () => rig.now,
      );
    });
    tearDown(() => viewModel.dispose());

    test('reads the student\'s programs; the coach may set one up', () async {
      await viewModel.load();

      expect(viewModel.phase, ProgramListPhase.content);
      expect(viewModel.isCoachView, isTrue);
      expect(viewModel.canCreate, isTrue);
      expect(viewModel.visible.items.single.name, 'Ekim 2. Hafta');
      expectAllForStudent();
    });

    test(
      'a student with no program is the empty state with an action',
      () async {
        rig.server.weeklies = [];

        await viewModel.load();

        expect(viewModel.phase, ProgramListPhase.empty);
        expect(viewModel.canCreateNow, isTrue);
      },
    );

    test('"Program Kur" opens the flow and then the saved program', () async {
      rig.server.weeklies = [];
      await viewModel.load();
      rig.navigator.newFlowResult = 'w-new-1';

      await viewModel.startNewProgram();

      expect(rig.navigator.newFlows, 1);
      expect(rig.navigator.opened, ['w-new-1']);
    });

    test('offline the action is off (brief 14.3 kare 3)', () async {
      await viewModel.load();
      rig.online.value = false;

      expect(viewModel.canCreateNow, isFalse);
      await viewModel.startNewProgram();
      expect(rig.navigator.newFlows, 0);
    });

    test('a student\'s own list is not a coach view', () {
      final own = ProgramListViewModel(
        schedule: rig.schedule,
        navigator: rig.navigator,
        online: rig.online,
      );
      addTearDown(own.dispose);

      expect(own.isCoachView, isFalse);
    });
  });

  group('the program (brief 14.1 kare 1 and 3)', () {
    late ProgramDetailViewModel viewModel;

    setUp(() {
      viewModel = ProgramDetailViewModel(
        programId: 'w-ekim-2',
        schedule: rig.schedule,
        toast: rig.toast,
        dialogs: rig.dialogs,
        navigator: rig.navigator,
        online: rig.online,
        preference: ProgramViewPreference(),
        studentId: student,
        clock: () => rig.now,
      );
    });
    tearDown(() => viewModel.dispose());

    Future<void> settle() =>
        Future<void>.delayed(const Duration(milliseconds: 30));

    test('opens on today with the coach able to edit', () async {
      await viewModel.load();

      expect(viewModel.section.state, SectionState.ready);
      expect(viewModel.isCoachView, isTrue);
      expect(viewModel.canEdit, isTrue);
      expect(viewModel.canEditNow, isTrue);
      expect(viewModel.detail!.countOn(viewModel.selectedDay), 3);
      expectAllForStudent();
    });

    test('a removed topic is saved to the student\'s account', () async {
      await viewModel.load();
      viewModel.startEditing();
      expect(viewModel.editing, isTrue);

      viewModel.removeEntry(
        viewModel.detail!.entriesOn(viewModel.selectedDay)[1],
      );
      await settle();

      expect(rig.server.updates, hasLength(1));
      expect(rig.server.lastTasks, [
        '2026-10-10 10:00 Fiilde Çatı',
        '2026-10-10 20:00 İklim Bilgisi',
      ]);
      expect(rig.server.requests.last, '/student/updateProgram $student');
      expectAllForStudent();
    });

    test('a topic placed from the hour grid is saved with the id', () async {
      await viewModel.load();
      viewModel.startEditing();
      rig.dialogs.slot = (hour: 9, choice: noktalamaChoice());

      await viewModel.addTopic();
      await settle();

      expect(
        rig.server.lastTasks,
        contains('2026-10-10 09:00 Noktalama İşaretleri'),
      );
      expect(rig.server.requests.last, '/student/updateProgram $student');
    });

    test(
      'a failed save goes back and says so; the coach keeps the screen',
      () async {
        await viewModel.load();
        viewModel.startEditing();
        rig.server.failWrites = true;

        viewModel.removeEntry(
          viewModel.detail!.entriesOn(viewModel.selectedDay).first,
        );
        await settle();

        expect(rig.toastText, contains('Kaydedilemedi'));
        expect(viewModel.detail!.countOn(viewModel.selectedDay), 3);
        expect(viewModel.editing, isTrue);
      },
    );

    test('offline "Düzenle" is off (brief 14.3 kare 3)', () async {
      await viewModel.load();
      rig.online.value = false;

      expect(viewModel.canEditNow, isFalse);
      viewModel.startEditing();
      expect(viewModel.editing, isFalse);
    });
  });

  group('Yeni Program (brief 14.2)', () {
    late NewProgramViewModel viewModel;

    setUp(() {
      rig.dispose();
      rig = ProgramRig(server: ProgramServer(weeklies: []));
      viewModel = NewProgramViewModel(
        schedule: rig.schedule,
        toast: rig.toast,
        dialogs: rig.dialogs,
        navigator: rig.navigator,
        online: rig.online,
        defaultName: (month, week) => '$month $week. Hafta',
        studentId: student,
        savedText: (l) => l.coachStudentProfile_programSaved("Alparslan'ın"),
        clock: () => rig.now,
      );
    });
    tearDown(() => viewModel.dispose());

    test('saves to the student and says whose account it went to', () async {
      for (var d = 12; d <= 14; d++) {
        viewModel.toggleDay(DateTime(2026, 10, d));
      }
      viewModel.next();
      rig.dialogs.topic = noktalamaChoice();
      await viewModel.placeTopic(10);
      viewModel.next();

      await viewModel.save();

      expect(rig.server.adds, hasLength(1));
      expect(rig.server.requests, ['/student/addNewProgram $student']);
      expect(rig.toastText, "Program Alparslan'ın hesabına kaydedildi.");
      expect(rig.navigator.closedWith, 'w-new-1');
    });

    test('the topic sheet\'s bag and lessons are the student\'s', () async {
      final picker = TopicPickerViewModel(
        schedule: rig.schedule,
        placements: const {},
        studentId: student,
        studentFirstName: 'Alparslan',
      );
      addTearDown(picker.dispose);

      await picker.init();
      await picker.setSource(TopicSource.lessons);

      expect(picker.isCoachView, isTrue);
      expect(picker.studentFirstName, 'Alparslan');
      expect(picker.bag.state, SectionState.ready);
      expect(picker.lessons.state, SectionState.ready);
      expectAllForStudent();
    });
  });
}
