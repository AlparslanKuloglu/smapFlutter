import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/schedule/application/program_edit_link.dart';
import 'package:smap/features/schedule/domain/weekly_draft.dart';
import 'package:smap/features/schedule/presentation/new_program/new_program_viewmodel.dart';
import 'package:smap/features/schedule/presentation/program_detail/program_detail_viewmodel.dart';
import 'package:smap/features/schedule/presentation/program_list/program_list_viewmodel.dart';
import 'package:smap/features/schedule/presentation/sheets/topic_picker/topic_picker_viewmodel.dart';
import 'package:smap/features/schedule/application/program_view_preference.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

import '../program_fixtures.dart';
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

    test(
      '"Program Kur" opens the flow; the saved program shows in the tab',
      () async {
        rig.server.weeklies = [];
        await viewModel.load();
        rig.navigator.newFlowResult = 'w-new-1';

        await viewModel.startNewProgram();

        expect(rig.navigator.newFlows, 1);
        expect(rig.navigator.opened, isEmpty);
      },
    );

    test('offline the action is off (brief 14.3 kare 3)', () async {
      await viewModel.load();
      rig.online.value = false;

      expect(viewModel.canCreateNow, isFalse);
      await viewModel.startNewProgram();
      expect(rig.navigator.newFlows, 0);
    });

    test('the list is newest to oldest with "Bu hafta" on this week\'s '
        'program; a program set up for next week is on top (T12.4)', () async {
      rig.server.weeklies = [
        weeklyJsonOnDays('w-new-1', 'Ekim 3. Hafta', 'Az ama her gün', [
          '2026-10-12',
          '2026-10-17',
        ]),
        ...alparslanProgramsJson(),
      ];

      await viewModel.load();

      expect(viewModel.visible.items.map((p) => p.name), [
        'Ekim 3. Hafta',
        'Ekim 2. Hafta',
        'Deneme haftası',
        'Yaz tekrarı',
      ]);
      expect(viewModel.visible.items.map((p) => p.isThisWeek), [
        false,
        true,
        false,
        false,
      ]);
      expect(viewModel.all.current!.id, 'w-ekim-2');
    });

    test('a saved program makes the "Programlar" count 4 and the tab stays '
        'on this week\'s program (T12.6)', () async {
      rig.server.weeklies = alparslanProgramsJson();
      await viewModel.load();
      expect(viewModel.all.items, hasLength(3));

      final saved = await rig.schedule.createWeekly(
        const WeeklyDraft(
          name: 'Ekim 3. Hafta',
          motto: 'Az ama her gün',
        ).withTask(
          noktalamaChoice().toTask(day: DateTime(2026, 10, 12), hour: 10),
        ),
        studentId: student,
      );

      expect(saved.isRight(), isTrue);
      expect(viewModel.all.items, hasLength(4));
      expect(viewModel.all.items.first.name, 'Ekim 3. Hafta');
      expect(viewModel.all.current!.id, 'w-ekim-2');
    });

    test(
      'after a save the coach stays on the tab; nothing opens (T12.6)',
      () async {
        await viewModel.load();
        rig.navigator.newFlowResult = 'w-new-1';

        await viewModel.startNewProgram();

        expect(rig.navigator.newFlows, 1);
        expect(rig.navigator.opened, isEmpty);
        expect(rig.navigator.closed, isFalse);
      },
    );

    test(
      'a coach\'s list pushed over the tab closes after a save (T12.6)',
      () async {
        final pushed = ProgramListViewModel(
          schedule: rig.schedule,
          navigator: rig.navigator,
          online: rig.online,
          studentId: student,
          leaveAfterCreate: true,
          clock: () => rig.now,
        );
        addTearDown(pushed.dispose);
        await pushed.load();
        rig.navigator.newFlowResult = 'w-new-1';

        await pushed.startNewProgram();

        expect(rig.navigator.closed, isTrue);
        expect(rig.navigator.opened, isEmpty);
      },
    );

    test('a flow left without saving changes nothing', () async {
      final pushed = ProgramListViewModel(
        schedule: rig.schedule,
        navigator: rig.navigator,
        online: rig.online,
        studentId: student,
        leaveAfterCreate: true,
        clock: () => rig.now,
      );
      addTearDown(pushed.dispose);
      await pushed.load();

      await pushed.startNewProgram();

      expect(rig.navigator.newFlows, 1);
      expect(rig.navigator.closed, isFalse);
    });

    test('a student\'s own list still opens the saved program', () async {
      final own = ProgramListViewModel(
        schedule: rig.schedule,
        navigator: rig.navigator,
        online: rig.online,
        clock: () => rig.now,
      );
      addTearDown(own.dispose);
      await own.load();
      rig.navigator.newFlowResult = 'w-new-1';

      await own.startNewProgram();

      expect(rig.navigator.opened, ['w-new-1']);
    });

    test(
      'with the write flag closed the coach\'s list only reads (T12.8)',
      () async {
        final closed = ProgramListViewModel(
          schedule: rig.schedule,
          navigator: rig.navigator,
          online: rig.online,
          studentId: student,
          coachWriteEnabled: false,
          clock: () => rig.now,
        );
        addTearDown(closed.dispose);
        await closed.load();

        expect(closed.phase, ProgramListPhase.content);
        expect(closed.visible.items, hasLength(1));
        expect(closed.canCreate, isFalse);
        expect(closed.canCreateNow, isFalse);
        rig.navigator.newFlowResult = 'w-new-1';
        await closed.startNewProgram();
        expect(rig.navigator.newFlows, 0);
      },
    );

    test(
      'with the flag closed a student without programs has no action',
      () async {
        rig.server.weeklies = [];
        final closed = ProgramListViewModel(
          schedule: rig.schedule,
          navigator: rig.navigator,
          online: rig.online,
          studentId: student,
          coachWriteEnabled: false,
          clock: () => rig.now,
        );
        addTearDown(closed.dispose);

        await closed.load();

        expect(closed.phase, ProgramListPhase.empty);
        expect(closed.canCreate, isFalse);
      },
    );

    test('a failed read is the error phase; "Tekrar Dene" reads again '
        '(brief 14.3 kare 2)', () async {
      rig.server.failList = true;
      await viewModel.load();
      expect(viewModel.phase, ProgramListPhase.error);

      rig.server.failList = false;
      await viewModel.retry();

      expect(viewModel.phase, ProgramListPhase.content);
      expectAllForStudent();
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

        expect(
          rig.toastText,
          'Program kaydedilemedi. Bağlantını kontrol edip tekrar dene.',
        );
        expect(viewModel.detail!.countOn(viewModel.selectedDay), 3);
        expect(viewModel.editing, isTrue);
      },
    );

    test(
      'a coach\'s program closed by the flag cannot be edited (T12.8)',
      () async {
        final closed = ProgramDetailViewModel(
          programId: 'w-ekim-2',
          schedule: rig.schedule,
          toast: rig.toast,
          dialogs: rig.dialogs,
          navigator: rig.navigator,
          online: rig.online,
          preference: ProgramViewPreference(),
          studentId: student,
          coachWriteEnabled: false,
          clock: () => rig.now,
        );
        addTearDown(closed.dispose);
        await closed.load();

        expect(closed.section.state, SectionState.ready);
        expect(closed.canEdit, isFalse);
        expect(closed.canEditNow, isFalse);
        closed.startEditing();
        expect(closed.editing, isFalse);
        expect(closed.detail!.countOn(closed.selectedDay), 3);
      },
    );

    test(
      'the student\'s own program is editable whatever the coach flag says',
      () async {
        final own = ProgramDetailViewModel(
          programId: 'w-ekim-2',
          schedule: rig.schedule,
          toast: rig.toast,
          dialogs: rig.dialogs,
          navigator: rig.navigator,
          online: rig.online,
          preference: ProgramViewPreference(),
          coachWriteEnabled: false,
          clock: () => rig.now,
        );
        addTearDown(own.dispose);
        await own.load();

        expect(own.canEdit, isTrue);
      },
    );

    test('edit mode is told to the hosting profile and "Bitti" ends it '
        '(brief 14.1 kare 3)', () async {
      final link = ProgramEditLink();
      addTearDown(link.dispose);
      final hosted = ProgramDetailViewModel(
        programId: 'w-ekim-2',
        schedule: rig.schedule,
        toast: rig.toast,
        dialogs: rig.dialogs,
        navigator: rig.navigator,
        online: rig.online,
        preference: ProgramViewPreference(),
        studentId: student,
        link: link,
        clock: () => rig.now,
      );
      addTearDown(hosted.dispose);
      await hosted.load();

      hosted.startEditing();
      expect(link.editing.value, isTrue);
      expect(link.title, 'Ekim 2. Hafta');

      link.finish();
      expect(hosted.editing, isFalse);
      expect(link.editing.value, isFalse);

      hosted.startEditing();
      hosted.setMode(ProgramViewMode.week);
      expect(link.editing.value, isFalse);
    });

    test('every change is saved at once with a selection haptic, and a day '
        'reset asks first (brief 14.1 kare 3)', () async {
      await viewModel.load();
      viewModel.startEditing();

      await viewModel.resetDay();
      await settle();

      expect(rig.dialogs.resetAsked, 1);
      expect(rig.dialogs.resetCount, 3);
      expect(rig.server.updates, hasLength(1));
      expect(rig.server.lastTasks, isEmpty);
      expect(rig.server.requests.last, '/student/updateProgram $student');
    });

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

    test(
      'a failed save says so, keeps the form and the choices, and stays',
      () async {
        for (var d = 12; d <= 14; d++) {
          viewModel.toggleDay(DateTime(2026, 10, d));
        }
        viewModel.next();
        rig.dialogs.topic = noktalamaChoice();
        await viewModel.placeTopic(10);
        viewModel.next();
        viewModel.setName('Ekim 3. Hafta');
        viewModel.setMotto('Az ama her gün');
        rig.server.failWrites = true;

        await viewModel.save();

        expect(
          rig.toastText,
          'Program kaydedilemedi. Bağlantını kontrol edip tekrar dene.',
        );
        expect(rig.navigator.closed, isFalse);
        expect(viewModel.step, NewProgramStep.name);
        expect(viewModel.name, 'Ekim 3. Hafta');
        expect(viewModel.motto, 'Az ama her gün');
        expect(viewModel.days, hasLength(3));
        expect(viewModel.entries, hasLength(1));
        expect(viewModel.saving, isFalse);

        rig.server.failWrites = false;
        await viewModel.save();
        expect(rig.navigator.closedWith, 'w-new-1');
      },
    );

    test('back keeps the choices and the X asks "Program kaydedilmesin mi?" '
        'when something was chosen (brief 14.2 "Akış")', () async {
      viewModel.toggleDay(DateTime(2026, 10, 12));
      viewModel.next();
      expect(viewModel.back(), isTrue);
      expect(viewModel.days, hasLength(1));

      rig.dialogs.discardAnswer = false;
      await viewModel.requestClose();
      expect(rig.dialogs.discardAsked, 1);
      expect(rig.navigator.closed, isFalse);

      rig.dialogs.discardAnswer = true;
      await viewModel.requestClose();
      expect(rig.navigator.closed, isTrue);
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
