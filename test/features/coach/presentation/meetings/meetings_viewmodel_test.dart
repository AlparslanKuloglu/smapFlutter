// ignore: depend_on_referenced_packages
import 'package:fake_async/fake_async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/coach/application/meeting_models.dart';
import 'package:smap/features/coach/application/meeting_schedule_logic.dart';
import 'package:smap/features/coach/domain/interview_type.dart';
import 'package:smap/features/coach/presentation/meetings/meetings_viewmodel.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

import 'meetings_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeInterviewRepository repository;
  late FakeMeetingsDialogs dialogs;
  late FakeMeetingsNavigator navigator;
  late FakeCoachStudents students;
  late ToastProbe toast;
  late ValueNotifier<bool> online;
  late MeetingsViewModel viewModel;

  MeetingsViewModel build({
    Duration timeout = const Duration(seconds: 15),
    bool withStudents = true,
  }) => MeetingsViewModel(
    interviews: repository,
    navigator: navigator,
    dialogs: dialogs,
    toast: toast.service,
    online: online,
    students: withStudents ? studentsService(students) : null,
    clock: () => morning,
    timeout: timeout,
  );

  Future<void> started([MeetingsViewModel? vm]) async {
    (vm ?? viewModel).init();
    await pumpEventQueue();
  }

  List<String> ids(MeetingSections sections) => [
    ...sections.upcoming.map((e) => e.id),
    ...sections.past.map((e) => e.id),
  ];

  setUp(() {
    repository = FakeInterviewRepository([alparslanMeeting(), elifMeeting()]);
    dialogs = FakeMeetingsDialogs();
    navigator = FakeMeetingsNavigator();
    students = FakeCoachStudents([alparslanStudent, elifStudent]);
    toast = ToastProbe();
    online = ValueNotifier<bool>(true);
    viewModel = build();
  });

  tearDown(() {
    viewModel.dispose();
    toast.dispose();
    online.dispose();
  });

  group('load (pano 10.5 kare 1)', () {
    test(
      'starts on the skeleton, then shows "Yaklaşan" in time order',
      () async {
        expect(viewModel.list.state, SectionState.loading);

        await started();

        final data = viewModel.list;
        expect(data.state, SectionState.ready);
        expect(data.sections.upcoming.map((e) => e.studentName), [
          'Alparslan Kuloğlu',
          'Elif Şahin',
        ]);
        expect(data.sections.past, isEmpty);
        expect(data.hasMore, isFalse);
        expect(repository.log, ['list:1']);
      },
    );

    test('past meetings are their own group, newest first', () async {
      repository.interviews.add(
        interview(
          id: 'old',
          studentId: 'student-3',
          first: 'Ali',
          last: 'Veli',
          date: DateTime(2026, 10, 1, 10),
        ),
      );
      repository.interviews.add(
        interview(
          id: 'older',
          studentId: 'student-3',
          first: 'Ali',
          last: 'Veli',
          date: DateTime(2026, 9, 20, 10),
        ),
      );

      await started();

      expect(viewModel.list.sections.upcoming.map((e) => e.id), [
        'iv-1',
        'iv-2',
      ]);
      expect(viewModel.list.sections.past.map((e) => e.id), ['old', 'older']);
    });

    test('no meeting at all is the empty state (kare 4)', () async {
      repository.interviews.clear();

      await started();

      expect(viewModel.list.state, SectionState.empty);
      expect(viewModel.state, SectionState.empty);
    });

    test(
      'a failed first page is the error state; "Tekrar Dene" loads',
      () async {
        repository.listFailure = serverDown;
        await started();
        expect(viewModel.list.state, SectionState.error);

        repository.listFailure = null;
        viewModel.retry();
        expect(viewModel.list.state, SectionState.loading);
        await pumpEventQueue();
        expect(viewModel.list.state, SectionState.ready);
      },
    );

    test('no connection is the offline state', () async {
      repository.listFailure = offline;
      await started();
      expect(viewModel.list.state, SectionState.offline);
    });

    test('no answer in 15 s is the error state, never an endless skeleton', () {
      fakeAsync((async) {
        final never = FakeInterviewRepositoryHanging();
        final vm = MeetingsViewModel(
          interviews: never,
          navigator: navigator,
          dialogs: dialogs,
          toast: toast.service,
          online: online,
          clock: () => morning,
        )..init();
        async.elapse(const Duration(seconds: 14));
        expect(vm.list.state, SectionState.loading);
        async.elapse(const Duration(seconds: 2));
        expect(vm.list.state, SectionState.error);
        vm.dispose();
      });
    });

    test('the band squares its corners while offline', () async {
      expect(viewModel.offline, isFalse);
      viewModel.init();
      online.value = false;
      expect(viewModel.offline, isTrue);
    });
  });

  group('"Kiminle" (server filter) and search (loaded pages)', () {
    test('a chip reloads from the first page with filter.types', () async {
      await started();

      viewModel.selectKind(MeetingWith.parent);
      expect(viewModel.list.state, SectionState.loading);
      await pumpEventQueue();

      expect(repository.filters.last.types, [InterviewType.parent]);
      expect(ids(viewModel.list.sections), ['iv-2']);
      expect(viewModel.kind, MeetingWith.parent);
    });

    test('"Tümü" sends no type', () async {
      await started();
      viewModel.selectKind(MeetingWith.student);
      await pumpEventQueue();

      viewModel.selectKind(MeetingWith.all);
      await pumpEventQueue();

      expect(repository.filters.last.types, isEmpty);
      expect(ids(viewModel.list.sections), ['iv-1', 'iv-2']);
    });

    test(
      'a choice with no meeting keeps the list, not the empty state',
      () async {
        repository.interviews.removeWhere((i) => i.type == 2);
        await started();

        viewModel.selectKind(MeetingWith.parent);
        await pumpEventQueue();

        expect(viewModel.list.state, SectionState.ready);
        expect(viewModel.list.sections.isEmpty, isTrue);
        expect(viewModel.list.kind, MeetingWith.parent);
      },
    );

    test('the search matches the student name, any case, İ and ı', () async {
      repository.interviews.add(
        interview(
          id: 'iv-3',
          studentId: 'student-3',
          first: 'İlker',
          last: 'Işık',
          date: DateTime(2026, 10, 20, 9),
        ),
      );
      await started();

      viewModel.setQuery('  ILKER ');
      expect(ids(viewModel.list.sections), ['iv-3']);
      expect(viewModel.list.query, 'ILKER');

      viewModel.setQuery('alp');
      expect(ids(viewModel.list.sections), ['iv-1']);

      viewModel.setQuery('');
      expect(ids(viewModel.list.sections), ['iv-1', 'iv-2', 'iv-3']);
    });

    test('a search with no hit is an empty result of a ready list', () async {
      await started();

      viewModel.setQuery('zzz');

      expect(viewModel.list.state, SectionState.ready);
      expect(viewModel.list.sections.isEmpty, isTrue);
    });

    test('"Aramayı Temizle" empties the query and tells the field', () async {
      await started();
      viewModel.setQuery('alp');
      final cleared = viewModel.searchCleared.value;

      viewModel.clearSearch();

      expect(viewModel.list.query, '');
      expect(viewModel.searchCleared.value, cleared + 1);
      expect(ids(viewModel.list.sections), ['iv-1', 'iv-2']);
    });
  });

  group('pages (8 a page)', () {
    List<MeetingEntry> loaded() => [
      ...viewModel.list.sections.upcoming,
      ...viewModel.list.sections.past,
    ];

    setUp(() {
      repository = FakeInterviewRepository([
        for (var i = 0; i < 20; i++)
          interview(
            id: 'm-$i',
            studentId: 's$i',
            first: 'Öğrenci',
            last: '$i',
            date: DateTime(2026, 10, 13 + i % 5, 9 + i % 8),
          ),
      ]);
      viewModel = build();
    });

    test('the next page is asked for when the end is near', () async {
      await started();
      expect(loaded(), hasLength(8));
      expect(viewModel.list.hasMore, isTrue);

      await viewModel.loadMore();
      expect(loaded(), hasLength(16));

      await viewModel.loadMore();
      expect(loaded(), hasLength(20));
      expect(viewModel.list.hasMore, isFalse);
      expect(repository.log, ['list:1', 'list:2', 'list:3']);
    });

    test('a call while a page loads joins it (one request)', () async {
      await started();

      final first = viewModel.loadMore();
      final second = viewModel.loadMore();
      await Future.wait([first, second]);

      expect(repository.log, ['list:1', 'list:2']);
    });

    test('a failed page leaves the list and waits for "Tekrar Dene"', () async {
      await started();
      repository.failPage = 2;

      await viewModel.loadMore();
      expect(viewModel.list.moreFailed, isTrue);
      expect(loaded(), hasLength(8));

      // The screen asks again at every layout: nothing goes out meanwhile.
      await viewModel.loadMore();
      expect(repository.log.where((l) => l == 'list:2'), hasLength(1));

      repository.failPage = null;
      await viewModel.retryMore();
      expect(viewModel.list.moreFailed, isFalse);
      expect(loaded(), hasLength(16));
    });

    test('a search reads the pages that are missing', () async {
      repository.interviews.add(
        interview(
          id: 'late',
          studentId: 'sx',
          first: 'Zeynep',
          last: 'Kaya',
          date: DateTime(2026, 11, 1, 9),
        ),
      );
      await started();
      expect(viewModel.list.hasMore, isTrue);

      viewModel.setQuery('zeynep');
      await pumpEventQueue();

      expect(ids(viewModel.list.sections), ['late']);
      expect(viewModel.list.hasMore, isFalse);
    });

    test('the search walk is bounded', () async {
      viewModel.dispose();
      viewModel = MeetingsViewModel(
        interviews: repository,
        navigator: navigator,
        dialogs: dialogs,
        toast: toast.service,
        online: online,
        clock: () => morning,
        maxSearchPages: 1,
      );
      await started();

      viewModel.setQuery('öğrenci');
      await pumpEventQueue();

      expect(repository.log, ['list:1', 'list:2'], reason: 'one page walked');
    });

    test('pull to refresh keeps the list while it loads', () async {
      await started();
      repository.interviews.insert(
        0,
        interview(
          id: 'new',
          studentId: 'sn',
          first: 'Yeni',
          last: 'Kayıt',
          date: DateTime(2026, 10, 12, 9),
        ),
      );

      final refreshing = viewModel.refresh();
      expect(viewModel.list.state, SectionState.ready, reason: 'no skeleton');
      await refreshing;

      expect(loaded().map((e) => e.id), contains('new'));
    });

    test('a failed refresh keeps the list and toasts', () async {
      await started();
      repository.listFailure = offline;

      await viewModel.refresh();

      expect(viewModel.list.state, SectionState.ready);
      expect(loaded(), hasLength(8));
      expect(toast.isError, isTrue);
      expect(
        toast.text,
        'Liste yenilenemedi. Bağlantını kontrol edip tekrar dene.',
      );
    });
  });

  group('a row opens the detail', () {
    test('with the meeting the list has', () async {
      await started();
      final meeting = viewModel.list.sections.upcoming.first;

      await viewModel.openMeeting(meeting);

      expect(navigator.opened, [meeting]);
    });
  });

  group('Yeni görüşme (pano 10.5 kare 2)', () {
    final draft = MeetingDraft(
      studentId: 'student-1',
      type: InterviewType.student,
      moment: DateTime(2026, 10, 12, 16),
    );

    test('opens with the coach\'s students in Turkish order', () async {
      students.students = [elifStudent, alparslanStudent];
      await started();

      await viewModel.newMeeting();

      expect(dialogs.asked, ['newMeeting']);
      expect(dialogs.lastStudents!.map((s) => s.id), [
        'student-1',
        'student-2',
      ]);
      expect(dialogs.lastStudentId, isNull);
    });

    test('a student can be chosen up front (Öğrenci Profili)', () async {
      await started();

      await viewModel.newMeeting(studentId: 'student-2');

      expect(dialogs.lastStudentId, 'student-2');
    });

    test('saving sends the picked moment as it is and toasts', () async {
      dialogs.draft = draft;
      await started();

      await viewModel.newMeeting();

      expect(
        repository.log,
        contains('create:student-1:2026-10-12T16:00:00.000:1'),
      );
      expect(dialogs.submitted, [true]);
      expect(toast.text, 'Görüşme kaydedildi.');
      expect(toast.isError, isFalse);
    });

    test('the list is read again and shows the new meeting', () async {
      dialogs.draft = draft;
      await started();
      final before = repository.listCalls;

      await viewModel.newMeeting();
      await pumpEventQueue();

      expect(repository.listCalls, before + 1);
      expect(
        viewModel.list.sections.upcoming.map((e) => e.studentName),
        contains('Yeni'),
      );
    });

    test('a note goes in a second call, under the new id', () async {
      dialogs.draft = MeetingDraft(
        studentId: 'student-1',
        type: InterviewType.parent,
        moment: DateTime(2026, 10, 12, 16),
        note: 'Deneme sonucunu birlikte inceleyeceğiz.',
      );
      await started();

      await viewModel.newMeeting();

      expect(repository.noteCalls, [
        ('iv-100', null, 'Deneme sonucunu birlikte inceleyeceğiz.'),
      ]);
      expect(toast.text, 'Görüşme kaydedildi.');
    });

    test('a failed save keeps the sheet open and says so', () async {
      dialogs.draft = draft;
      repository.createFailure = offline;
      await started();
      final before = repository.listCalls;

      await viewModel.newMeeting();

      expect(dialogs.submitted, [false]);
      expect(toast.isError, isTrue);
      expect(
        toast.text,
        'Görüşme kaydedilemedi. Bağlantını kontrol edip tekrar dene.',
      );
      expect(repository.listCalls, before, reason: 'no reload, nothing saved');
    });

    test('a note that failed does not undo the meeting', () async {
      dialogs.draft = MeetingDraft(
        studentId: 'student-1',
        type: InterviewType.student,
        moment: DateTime(2026, 10, 12, 16),
        note: 'Not',
      );
      repository.noteFailure = serverDown;
      await started();

      await viewModel.newMeeting();

      expect(dialogs.submitted, [true]);
      expect(toast.isError, isTrue);
      expect(toast.text, 'Görüşme kaydedildi ama not eklenemedi.');
    });

    test('a created meeting the server did not echo loses its note', () async {
      dialogs.draft = MeetingDraft(
        studentId: 'student-1',
        type: InterviewType.student,
        moment: DateTime(2026, 10, 12, 16),
        note: 'Not',
      );
      repository.echoCreated = false;
      await started();

      await viewModel.newMeeting();

      expect(repository.noteCalls, isEmpty);
      expect(toast.text, 'Görüşme kaydedildi ama not eklenemedi.');
    });

    test('dismissing the sheet changes nothing', () async {
      await started();
      final before = repository.log.length;

      await viewModel.newMeeting();

      expect(repository.log.length, before);
      expect(toast.text, isNull);
    });

    test('a coach with no student is told to add one first', () async {
      students.students = [];
      await started();

      await viewModel.newMeeting();

      expect(dialogs.asked, isEmpty);
      expect(
        toast.text,
        'Görüşme planlamak için önce bir öğrenci eklemelisin.',
      );
    });

    test(
      'students that cannot be loaded are a toast, not an empty sheet',
      () async {
        students.failure = offline;
        await started();

        await viewModel.newMeeting();

        expect(dialogs.asked, isEmpty);
        expect(toast.isError, isTrue);
      },
    );

    test('without a session there are no students', () async {
      final preview = build(withStudents: false);
      await started(preview);

      await preview.newMeeting();

      expect(dialogs.asked, isEmpty);
      expect(toast.isError, isTrue);
      preview.dispose();
    });

    test('a second tap while the sheet is open does nothing', () async {
      dialogs.draft = draft;
      await started();

      final first = viewModel.newMeeting();
      final second = viewModel.newMeeting();
      await Future.wait([first, second]);

      expect(dialogs.asked, ['newMeeting']);
    });
  });
}
