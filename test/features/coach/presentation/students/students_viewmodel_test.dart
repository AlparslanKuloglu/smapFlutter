import 'dart:async';
import 'dart:io';
import 'dart:ui' show Rect;

import 'package:dio/dio.dart';
// ignore: depend_on_referenced_packages
import 'package:fake_async/fake_async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/coach/application/coach_code_actions.dart';
import 'package:smap/features/coach/application/coach_students_service.dart';
import 'package:smap/features/coach/application/student_rows.dart';
import 'package:smap/features/coach/data/coach_student_repository.dart';
import 'package:smap/features/coach/presentation/students/students_navigator.dart';
import 'package:smap/features/coach/presentation/students/students_texts.dart';
import 'package:smap/features/coach/presentation/students/students_viewmodel.dart';
import 'package:smap/l10n/app_localizations_tr.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

import '../../../../core/network/fake_adapter.dart';
import '../../../account/presentation/account_settings_fakes.dart';
import '../../../schedule/network_harness.dart';
import '../../coach_fixtures.dart';

/// The students of the design (Ek C; pano 10.2 kare 1) as `getMyStudents`
/// returns them, in server order.
List<Map<String, Object?>> _boardStudents() => [
  studentJson(id: 's5', name: 'Zeynep', surname: 'Kaya', totalMexam: 0),
  studentJson(id: 's1', name: 'Alparslan', surname: 'Kuloğlu', totalMexam: 10),
  studentJson(
    id: 's4',
    name: 'Mert',
    surname: 'Yıldız',
    seasonType: 10,
    aimType: 0,
    totalMexam: 0,
  ),
  studentJson(
    id: 's3',
    name: 'Kerem',
    surname: 'Aydın',
    seasonType: 13,
    aimType: 4,
    totalMexam: 0,
  ),
  studentJson(
    id: 's2',
    name: 'Elif',
    surname: 'Şahin',
    seasonType: 11,
    aimType: 3,
    totalMexam: 0,
  ),
];

class _Server {
  List<Map<String, Object?>> students = _boardStudents();
  int listCalls = 0;
  bool fail = false;
  bool offline = false;
  Completer<void>? hold;

  FakeAdapter get adapter => FakeAdapter((options) async {
    if (options.path == '/coach/getMyStudents') {
      listCalls++;
      await hold?.future;
      if (offline) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: const SocketException('Failed host lookup: www.smaptr.com'),
        );
      }
      if (fail) return jsonResponse({}, status: 500);
      return jsonResponse({'success': true, 'students': students});
    }
    return jsonResponse({}, status: 404);
  });
}

class _Navigator implements StudentsNavigator {
  final List<String> opened = [];

  @override
  Future<void> openStudent(StudentRowData student) async =>
      opened.add(student.id);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _Server server;
  late NetworkService network;
  late CoachStudentsService service;
  late _Navigator navigator;
  late ToastProbe toast;
  late ValueNotifier<bool> online;
  late List<(String, Rect?)> shared;
  late int addOpened;
  late String? code;
  late StudentsViewModel viewModel;

  StudentsViewModel build({Duration? timeout}) => StudentsViewModel(
    students: service,
    navigator: navigator,
    openAddStudent: () async {
      addOpened++;
      return null;
    },
    codeActions: CoachCodeActions(
      copyText: (text) async {},
      shareText: (text, {origin}) async => shared.add((text, origin)),
      toast: toast.service,
    ),
    online: online,
    coachCode: () => code,
    timeout: timeout ?? const Duration(seconds: 15),
  );

  setUp(() {
    server = _Server();
    network = buildNetwork(server.adapter);
    service = CoachStudentsService(repository: CoachStudentRepository(network));
    navigator = _Navigator();
    toast = ToastProbe();
    online = ValueNotifier<bool>(true);
    shared = [];
    addOpened = 0;
    code = 'MOZK-4821';
    viewModel = build();
  });

  tearDown(() {
    viewModel.dispose();
    service.dispose();
    network.dispose();
    toast.dispose();
    online.dispose();
  });

  List<String> names() => viewModel.list.rows.map((r) => r.name).toList();

  group('load', () {
    test('starts on the skeleton', () {
      expect(viewModel.list.state, SectionState.loading);
    });

    test('lists the students alphabetically (pano 10.2 kare 1)', () async {
      await viewModel.init();
      expect(viewModel.list.state, SectionState.ready);
      expect(names(), [
        'Alparslan Kuloğlu',
        'Elif Şahin',
        'Kerem Aydın',
        'Mert Yıldız',
        'Zeynep Kaya',
      ]);
      expect(viewModel.list.total, 5);
    });

    test('a coach with no student is the empty state (kare 4)', () async {
      server.students = [];
      await viewModel.init();
      expect(viewModel.list.state, SectionState.empty);
      expect(viewModel.list.rows, isEmpty);
    });

    test(
      'a failed call is the error state; "Tekrar Dene" loads again',
      () async {
        server.fail = true;
        await viewModel.init();
        expect(viewModel.list.state, SectionState.error);

        server.fail = false;
        final retry = viewModel.retry();
        expect(viewModel.list.state, SectionState.loading);
        await retry;
        expect(viewModel.list.state, SectionState.ready);
        expect(server.listCalls, 2);
      },
    );

    test('no connection and nothing saved is the offline state', () async {
      server.offline = true;
      await viewModel.init();
      expect(viewModel.list.state, SectionState.offline);
    });

    test('no answer in 15 s is the error state; a late answer fills it', () {
      fakeAsync((async) {
        // Built inside the fake zone, so the service's streams run in it.
        final slowNetwork = buildNetwork(server.adapter);
        final slowService = CoachStudentsService(
          repository: CoachStudentRepository(slowNetwork),
        );
        final hold = Completer<void>();
        server.hold = hold;
        final slow = StudentsViewModel(
          students: slowService,
          navigator: navigator,
          openAddStudent: () async => null,
          codeActions: CoachCodeActions(
            copyText: (text) async {},
            shareText: (text, {origin}) async {},
            toast: toast.service,
          ),
          online: online,
        )..init().ignore();

        async.elapse(const Duration(seconds: 14));
        expect(slow.list.state, SectionState.loading);
        async.elapse(const Duration(seconds: 2));
        expect(slow.list.state, SectionState.error);

        hold.complete();
        async.elapse(const Duration(seconds: 1));
        expect(slow.list.state, SectionState.ready);
        expect(slow.list.total, 5);

        slow.dispose();
        slowService.dispose();
        slowNetwork.dispose();
      });
    });

    test('a list that is there survives a failed refresh', () async {
      await viewModel.init();
      server.fail = true;
      await viewModel.retry();
      expect(viewModel.list.state, SectionState.ready);
      expect(viewModel.list.total, 5);
    });

    test('init runs once', () async {
      await viewModel.init();
      await viewModel.init();
      expect(server.listCalls, 1);
    });

    test('the connection coming back reloads an error by itself', () async {
      server.fail = true;
      await viewModel.init();
      expect(viewModel.list.state, SectionState.error);

      server.fail = false;
      online.value = false;
      online.value = true;
      for (var i = 0; i < 50; i++) {
        if (viewModel.list.state == SectionState.ready) break;
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect(viewModel.list.state, SectionState.ready);
    });
  });

  group('search (pano 10.2 kare 2 and 3)', () {
    setUp(() async => viewModel.init());

    test('"aydin" is one student, "Kerem Aydın"', () {
      viewModel.setQuery('aydin');
      expect(names(), ['Kerem Aydın']);
      expect(viewModel.list.total, 5);
      expect(viewModel.list.query, 'aydin');
      expect(viewModel.list.noMatch, isFalse);
    });

    test('"AYDIN" and "aydın" give the same answer', () {
      viewModel.setQuery('AYDIN');
      final upper = names();
      viewModel.setQuery('aydın');
      expect(names(), upper);
      expect(upper, ['Kerem Aydın']);
    });

    test('the query is trimmed', () {
      viewModel.setQuery('  aydin  ');
      expect(viewModel.query, 'aydin');
      expect(names(), ['Kerem Aydın']);
    });

    test('"selin" matches nobody: the no-match card with the query', () {
      viewModel.setQuery('selin');
      expect(viewModel.list.state, SectionState.ready);
      expect(viewModel.list.rows, isEmpty);
      expect(viewModel.list.noMatch, isTrue);
      expect(viewModel.list.query, 'selin');
    });

    test('"Aramayı Temizle" brings everyone back', () {
      viewModel.setQuery('selin');
      viewModel.clearSearch();
      expect(viewModel.list.noMatch, isFalse);
      expect(viewModel.list.rows, hasLength(5));
      expect(viewModel.query, isEmpty);
    });

    test('the same query does not notify again', () {
      viewModel.setQuery('aydin');
      var notified = 0;
      viewModel.addListener(() => notified++);
      viewModel.setQuery('aydin ');
      expect(notified, 0);
    });

    test('a search never turns a coach with students into the empty state', () {
      viewModel.setQuery('xyz');
      expect(viewModel.list.state, SectionState.ready);
    });

    test(
      'the list value is equal by content (a selector does not rebuild)',
      () {
        final first = viewModel.list;
        viewModel.setQuery('aydin');
        viewModel.setQuery('');
        expect(viewModel.list, first);
      },
    );
  });

  group('rows (pano 10.2 kare 1)', () {
    setUp(() async => viewModel.init());

    final l10n = AppLocalizationsTr();

    String? metaOf(String name) => StudentTexts.meta(
      l10n,
      viewModel.list.rows.firstWhere((r) => r.name == name),
    );

    test('"12. Sınıf · Eşit Ağırlık · 10 deneme"', () {
      expect(
        metaOf('Alparslan Kuloğlu'),
        '12. Sınıf · Eşit Ağırlık · 10 deneme',
      );
    });

    test('"11. Sınıf · Sayısal", "Mezun · Sözel", "10. Sınıf"', () {
      expect(metaOf('Elif Şahin'), '11. Sınıf · Sayısal');
      expect(metaOf('Kerem Aydın'), 'Mezun · Sözel');
      expect(metaOf('Mert Yıldız'), '10. Sınıf');
      expect(metaOf('Zeynep Kaya'), '12. Sınıf · Eşit Ağırlık');
    });

    test('no deneme count is written for a student with no exam', () {
      expect(metaOf('Zeynep Kaya'), isNot(contains('deneme')));
    });

    test('a row is read as the name and the meta line', () {
      final row = viewModel.list.rows.first;
      expect(
        StudentTexts.semanticLabel(l10n, row),
        'Alparslan Kuloğlu, 12. Sınıf, Eşit Ağırlık, 10 deneme',
      );
    });

    test('a student with nothing to say has no meta line', () {
      const bare = StudentRowData(id: 'x', name: 'Ada Lovelace');
      expect(StudentTexts.meta(l10n, bare), isNull);
      expect(StudentTexts.semanticLabel(l10n, bare), 'Ada Lovelace');
    });

    test('a big exam count is written the Turkish way', () {
      const row = StudentRowData(
        id: 'x',
        name: 'Ada',
        grade: SchoolGrade.grade12,
        track: StudyTrack.sayisal,
        examCount: 48215,
      );
      expect(
        StudentTexts.meta(l10n, row),
        '12. Sınıf · Sayısal · 48.215 deneme',
      );
    });
  });

  group('actions', () {
    setUp(() async => viewModel.init());

    test('a row opens the student', () async {
      await viewModel.openStudent(viewModel.list.rows.first);
      expect(navigator.opened, ['s1']);
    });

    test('the Plus and "Öğrenci Ekle" open the add sheet', () async {
      await viewModel.addStudent();
      expect(addOpened, 1);
    });

    test('"Kodunu Paylaş" shares the code in a sentence, anchored', () async {
      const origin = Rect.fromLTWH(10, 20, 30, 40);
      await viewModel.shareCode(AppLocalizationsTr(), origin: origin);
      expect(shared, [("SMAP'te koçluk kodum: MOZK-4821", origin)]);
    });

    test('a coach with no code has nothing to share', () async {
      code = null;
      expect(viewModel.canShareCode, isFalse);
      await viewModel.shareCode(AppLocalizationsTr());
      expect(shared, isEmpty);
    });

    test('a blank code counts as none', () {
      code = '  ';
      expect(viewModel.coachCode, isNull);
      expect(viewModel.canShareCode, isFalse);
    });
  });
}
