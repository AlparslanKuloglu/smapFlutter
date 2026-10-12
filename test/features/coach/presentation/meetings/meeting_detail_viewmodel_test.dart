// ignore: depend_on_referenced_packages
import 'package:fake_async/fake_async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/coach/application/interview_locator.dart';
import 'package:smap/features/coach/application/meeting_models.dart';
import 'package:smap/features/coach/presentation/meetings/detail/meeting_detail_viewmodel.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

import 'meetings_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeInterviewRepository repository;
  late FakeMeetingsDialogs dialogs;
  late FakeMeetingsNavigator navigator;
  late ToastProbe toast;
  late ManualTimers timers;
  late ValueNotifier<bool> online;
  late MeetingDetailViewModel viewModel;

  /// What the list screen passes: the meeting with the notes it saw.
  MeetingEntry hint() => MeetingEntry.fromDto(alparslanMeeting())!;

  MeetingDetailViewModel build({
    MeetingEntry? meeting,
    FakeInterviewRepository? repo,
  }) => MeetingDetailViewModel(
    meetingId: 'iv-1',
    meeting: meeting,
    interviews: repo ?? repository,
    locator: InterviewLocator(repo ?? repository),
    navigator: navigator,
    dialogs: dialogs,
    toast: toast.service,
    online: online,
    timerFactory: timers.create,
  );

  Future<void> started() async {
    viewModel.init();
    await pumpEventQueue();
  }

  List<String> texts() => [for (final n in viewModel.notes.notes) n.text];

  setUp(() {
    repository = FakeInterviewRepository([alparslanMeeting(), elifMeeting()]);
    dialogs = FakeMeetingsDialogs();
    navigator = FakeMeetingsNavigator();
    toast = ToastProbe();
    timers = ManualTimers();
    online = ValueNotifier<bool>(true);
    viewModel = build(meeting: hint());
  });

  tearDown(() {
    viewModel.dispose();
    toast.dispose();
    online.dispose();
  });

  group('load (pano 10.5 kare 3)', () {
    test('the header is drawn at once from the list\'s meeting', () {
      viewModel.init();

      expect(viewModel.screenState, SectionState.ready);
      expect(viewModel.meeting?.studentName, 'Alparslan Kuloğlu');
      expect(viewModel.meeting?.moment, DateTime(2026, 10, 12, 16));
    });

    test(
      'the notes are read again before they show (their positions)',
      () async {
        viewModel.init();
        expect(viewModel.notes.state, SectionState.loading);
        expect(viewModel.canWrite, isFalse);

        await pumpEventQueue();

        expect(viewModel.notes.state, SectionState.ready);
        expect(texts(), [noteText]);
        expect(viewModel.canWrite, isTrue);
      },
    );

    test(
      'a note another visit added is there, not the list\'s old view',
      () async {
        repository.interviews[0] = alparslanMeeting(
          notes: [noteText, 'Yeni not'],
        );

        await started();

        expect(texts(), [noteText, 'Yeni not']);
      },
    );

    test('a meeting without notes is the empty notes card', () async {
      repository.interviews[0] = alparslanMeeting(notes: const []);

      await started();

      expect(viewModel.notes.state, SectionState.empty);
      expect(viewModel.canWrite, isTrue);
    });

    test(
      'a link without a hint shows the skeleton until it finds it',
      () async {
        viewModel.dispose();
        viewModel = build();

        viewModel.init();
        expect(viewModel.screenState, SectionState.loading);
        expect(viewModel.meeting, isNull);
        await pumpEventQueue();

        expect(viewModel.screenState, SectionState.ready);
        expect(viewModel.meeting?.id, 'iv-1');
        expect(repository.filters.every((f) => f.isEmpty), isTrue);
      },
    );

    test(
      'a meeting that is not in the list any more is "bulunamadı"',
      () async {
        repository.interviews.removeAt(0);
        viewModel.dispose();
        viewModel = build();

        await started();

        expect(viewModel.screenState, SectionState.empty);
      },
    );

    test('a failed load of the whole screen is the error state', () async {
      repository.listFailure = serverDown;
      viewModel.dispose();
      viewModel = build();

      await started();
      expect(viewModel.screenState, SectionState.error);

      repository.listFailure = null;
      viewModel.retry();
      expect(viewModel.screenState, SectionState.loading);
      await pumpEventQueue();
      expect(viewModel.screenState, SectionState.ready);
    });

    test('a failure with a header leaves the header, the notes fail', () async {
      repository.listFailure = offline;

      await started();

      expect(viewModel.screenState, SectionState.ready);
      expect(viewModel.notes.state, SectionState.offline);
      expect(viewModel.canWrite, isFalse);

      repository.listFailure = null;
      viewModel.retry();
      await pumpEventQueue();
      expect(viewModel.notes.state, SectionState.ready);
    });

    test('no answer in 15 s is the error state', () {
      fakeAsync((async) {
        final hanging = FakeInterviewRepositoryHanging();
        final vm = MeetingDetailViewModel(
          meetingId: 'iv-1',
          meeting: hint(),
          interviews: hanging,
          locator: InterviewLocator(hanging),
          navigator: navigator,
          dialogs: dialogs,
          toast: toast.service,
          online: online,
          timerFactory: timers.create,
        )..init();
        async.elapse(const Duration(seconds: 14));
        expect(vm.notes.state, SectionState.loading);
        async.elapse(const Duration(seconds: 2));
        expect(vm.notes.state, SectionState.error);
        vm.dispose();
      });
    });
  });

  group('"Öğrencinin verileri"', () {
    test('opens the student\'s data in the coach\'s view', () async {
      await started();

      await viewModel.openStudentData();

      expect(navigator.studentData, ['student-1:Alparslan Kuloğlu']);
    });

    test('a meeting with no student id has no link', () async {
      viewModel.dispose();
      viewModel = build(meeting: const MeetingEntry(id: 'iv-1'));
      viewModel.init();

      await viewModel.openStudentData();

      expect(navigator.studentData, isEmpty);
    });
  });

  group('Not ekle (pano 10.6 kare 1)', () {
    test(
      'opens with the day and the student, saves trimmed, reloads',
      () async {
        await started();
        dialogs.noteToSave = '  Haftada 3 saat ayrıldı.  ';

        await viewModel.addNote();

        expect(dialogs.asked, ['addNote']);
        expect(dialogs.lastNoteDate, DateTime(2026, 10, 12, 16));
        expect(dialogs.lastNoteStudent, 'Alparslan Kuloğlu');
        expect(repository.noteCalls, [
          ('iv-1', null, 'Haftada 3 saat ayrıldı.'),
        ]);
        expect(texts(), [noteText, 'Haftada 3 saat ayrıldı.']);
        expect(toast.text, 'Not eklendi.');
      },
    );

    test('a failed save keeps the sheet open (it answered false)', () async {
      await started();
      dialogs.noteToSave = 'Not';
      repository.noteFailure = serverDown;

      await viewModel.addNote();

      expect(dialogs.submitted, [false]);
      expect(toast.isError, isTrue);
      expect(
        toast.text,
        'Not kaydedilemedi. Bağlantını kontrol edip tekrar dene.',
      );
      expect(texts(), [noteText]);
    });

    test('dismissing the sheet writes nothing', () async {
      await started();

      await viewModel.addNote();

      expect(repository.noteCalls, isEmpty);
      expect(toast.text, isNull);
    });

    test('while the notes are not loaded the sheet does not open', () async {
      viewModel.init();

      await viewModel.addNote();

      expect(dialogs.asked, isEmpty);
    });
  });

  group('Notu düzenle (pano 10.6 kare 2)', () {
    test('opens with the note and replaces it at its position', () async {
      repository.interviews[0] = alparslanMeeting(notes: ['ilk', noteText]);
      await started();
      dialogs.noteToSave = 'Haftada 4 saat ayrıldı.';

      await viewModel.editNote(viewModel.notes.notes.last);

      expect(dialogs.lastInitialText, noteText);
      expect(repository.noteCalls, [('iv-1', 1, 'Haftada 4 saat ayrıldı.')]);
      expect(texts(), ['ilk', 'Haftada 4 saat ayrıldı.']);
      expect(toast.text, 'Not güncellendi.');
    });

    test('a failed edit changes nothing', () async {
      await started();
      dialogs.noteToSave = 'Başka';
      repository.noteFailure = offline;

      await viewModel.editNote(viewModel.notes.notes.single);

      expect(texts(), [noteText]);
      expect(toast.isError, isTrue);
    });
  });

  group('Sil (pano 10.6 kare 3 and 4)', () {
    test('the confirmation quotes the note', () async {
      await started();

      await viewModel.deleteNote(viewModel.notes.notes.single);

      expect(dialogs.lastDeleteQuote, noteText);
    });

    test('"Vazgeç" keeps the note and sends nothing', () async {
      await started();
      dialogs.confirmDelete = false;

      await viewModel.deleteNote(viewModel.notes.notes.single);

      expect(texts(), [noteText]);
      expect(toast.text, isNull);
      expect(timers.waiting, 0);
    });

    test(
      'the note leaves the screen at once and its request waits 6 s',
      () async {
        await started();

        await viewModel.deleteNote(viewModel.notes.notes.single);

        expect(
          viewModel.notes.state,
          SectionState.empty,
          reason: '"Henüz not yok."',
        );
        expect(toast.text, 'Not silindi.');
        expect(toast.hasUndo, isTrue);
        expect(timers.waiting, 1);
        expect(
          repository.log.where((l) => l.startsWith('deleteNote')),
          isEmpty,
        );
      },
    );

    test('"Geri Al" brings the note back; nothing is ever sent', () async {
      await started();
      await viewModel.deleteNote(viewModel.notes.notes.single);

      expect(toast.pressUndo(), isTrue);

      expect(texts(), [noteText]);
      expect(timers.waiting, 0);
      await pumpEventQueue();
      expect(repository.log.where((l) => l.startsWith('deleteNote')), isEmpty);
    });

    test(
      'after 6 s the request goes out and the screen reads the server',
      () async {
        await started();
        await viewModel.deleteNote(viewModel.notes.notes.single);

        timers.fire();
        await pumpEventQueue();

        expect(repository.log, contains('deleteNote:iv-1:0'));
        expect(viewModel.notes.state, SectionState.empty);
        expect(repository.interviews[0].notes, isEmpty);
      },
    );

    test('the note does not flicker back while its request runs', () async {
      repository.interviews[0] = alparslanMeeting(notes: ['ilk', 'ikinci']);
      await started();
      await viewModel.deleteNote(viewModel.notes.notes.first);

      timers.fire(); // the request is in flight, the list not yet read again
      expect(texts(), ['ikinci']);
      await pumpEventQueue();
      expect(texts(), ['ikinci']);
    });

    test('a failed request brings the note back and says so', () async {
      await started();
      await viewModel.deleteNote(viewModel.notes.notes.single);
      repository.deleteFailure = offline;

      timers.fire();
      await pumpEventQueue();

      expect(texts(), [noteText]);
      expect(toast.isError, isTrue);
      expect(
        toast.text,
        'Not silinemedi. Bağlantını kontrol edip tekrar dene.',
      );
    });

    test(
      '"Geri Al" after the request went out finds nothing to undo',
      () async {
        await started();
        await viewModel.deleteNote(viewModel.notes.notes.single);
        timers.fire();
        await pumpEventQueue();

        toast.pressUndo(); // a screen reader keeps the toast open

        expect(texts(), isEmpty);
      },
    );

    test(
      'leaving the screen sends a waiting deletion (it is not lost)',
      () async {
        await started();
        await viewModel.deleteNote(viewModel.notes.notes.single);

        viewModel.dispose();
        await pumpEventQueue();

        expect(repository.log, contains('deleteNote:iv-1:0'));
        expect(repository.interviews[0].notes, isEmpty);
        viewModel = build(meeting: hint()); // for the tearDown
      },
    );
  });

  group('positions stay the server\'s', () {
    test('another write sends a waiting deletion first', () async {
      repository.interviews[0] = alparslanMeeting(notes: ['ilk', 'ikinci']);
      await started();
      await viewModel.deleteNote(viewModel.notes.notes.first);
      dialogs.noteToSave = 'üçüncü';

      await viewModel.addNote();

      final writes = repository.log
          .where((l) => l.startsWith('deleteNote') || l.startsWith('addNote'))
          .toList();
      expect(writes, ['deleteNote:iv-1:0', 'addNote:iv-1']);
      expect(texts(), ['ikinci', 'üçüncü']);
    });

    test('a second deletion uses the position after the first one', () async {
      repository.interviews[0] = alparslanMeeting(notes: ['ilk', 'ikinci']);
      await started();
      final first = viewModel.notes.notes.first;
      final second = viewModel.notes.notes.last; // index 1 when it was drawn
      await viewModel.deleteNote(first);

      await viewModel.deleteNote(second);

      // The first went out and the server moved "ikinci" to position 0.
      expect(dialogs.lastDeleteQuote, 'ikinci');
      timers.fire();
      await pumpEventQueue();
      final deletes = repository.log.where((l) => l.startsWith('deleteNote'));
      expect(deletes, ['deleteNote:iv-1:0', 'deleteNote:iv-1:0']);
      expect(texts(), isEmpty);
    });

    test('a note that is gone meanwhile is not edited', () async {
      await started();
      final stale = viewModel.notes.notes.single;
      repository.interviews[0] = alparslanMeeting(notes: const []);
      viewModel.retry();
      await pumpEventQueue();
      dialogs.noteToSave = 'x';

      await viewModel.editNote(stale);

      expect(dialogs.asked, isEmpty);
      expect(repository.noteCalls, isEmpty);
    });
  });
}
