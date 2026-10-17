import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/coach/application/coach_students_service.dart';
import 'package:smap/features/coach/data/add_student_outcome.dart';
import 'package:smap/features/coach/data/coach_student_repository.dart';
import 'package:smap/features/coach/domain/new_student.dart';

import '../../../core/network/fake_adapter.dart';
import '../../schedule/network_harness.dart';
import '../coach_fixtures.dart';

const _input = NewStudent(
  firstName: 'Yeni',
  lastName: 'Öğrenci',
  userName: 'yeni.ogrenci',
  password: 'x',
  grade: SchoolGrade.grade10,
);

class _Server {
  List<Map<String, Object?>> students = [
    studentJson(id: 's2', name: 'Çağla', surname: 'Özkan'),
    studentJson(id: 's1', name: 'Ali', surname: 'Veli'),
  ];
  int listCalls = 0;
  bool usernameTaken = false;
  bool failList = false;

  /// The answer to "add" carries no `photo` (an older server).
  bool omitPhoto = false;

  FakeAdapter get adapter => FakeAdapter((options) async {
    switch (options.path) {
      case '/coach/getMyStudents':
        listCalls++;
        if (failList) return jsonResponse({}, status: 500);
        return jsonResponse({'success': true, 'students': students});
      case '/coach/addNewStudent':
        if (usernameTaken) {
          return jsonResponse({'success': true, 'userNameUsing': true});
        }
        final created = studentJson(id: 's3', name: 'Yeni', surname: 'Öğrenci');
        if (omitPhoto) created.remove('photo');
        return jsonResponse({'success': true, 'student': created});
      case '/ajax/checkUsername':
        return jsonResponse({'success': true, 'available': !usernameTaken});
    }
    return jsonResponse({}, status: 404);
  });
}

void main() {
  late _Server server;
  late NetworkService network;
  late CoachStudentsService service;
  late DateTime now;

  setUp(() {
    server = _Server();
    now = DateTime(2026, 10, 12, 8);
    network = buildNetwork(server.adapter);
    service = CoachStudentsService(
      repository: CoachStudentRepository(network),
      clock: () => now,
      staleAfter: const Duration(minutes: 5),
    );
  });

  tearDown(() {
    service.dispose();
    network.dispose();
  });

  test('starts empty and not loaded', () {
    expect(service.isLoaded, isFalse);
    expect(service.students, isEmpty);
    expect(service.loadedAt, isNull);
    expect(service.byId('s1'), isNull);
  });

  group('load', () {
    test(
      'fetches once, then answers from the cache while it is fresh',
      () async {
        final first = await service.load();
        now = now.add(const Duration(minutes: 4));
        final second = await service.load();

        expect(first.rightOrNull, hasLength(2));
        expect(second.rightOrNull, same(first.rightOrNull));
        expect(server.listCalls, 1);
        expect(service.isLoaded, isTrue);
        expect(service.loadedAt, DateTime(2026, 10, 12, 8));
      },
    );

    test('fetches again when stale or forced', () async {
      await service.load();
      now = now.add(const Duration(minutes: 6));
      await service.load();
      await service.load(forceRefresh: true);

      expect(server.listCalls, 3);
    });

    test('joins a fetch that is already running', () async {
      await Future.wait([service.load(), service.load(), service.load()]);

      expect(server.listCalls, 1);
    });

    test('keeps server order and offers the alphabetical one', () async {
      await service.load();

      expect(service.students.map((s) => s.id), ['s2', 's1']);
      expect(service.sortedStudents.map((s) => s.id), ['s1', 's2']);
      expect(service.byId('s2')?.name, 'Çağla');
    });

    test(
      'a failed refresh keeps the old list and reports the failure',
      () async {
        await service.load();
        server.failList = true;

        final failed = await service.load(forceRefresh: true);

        expect(failureOf(failed).code, AppErrorCode.server);
        expect(service.students, hasLength(2));
        expect(service.isLoaded, isTrue);
      },
    );

    test('a first load that fails leaves the service unloaded', () async {
      server.failList = true;

      final failed = await service.load();

      expect(failed.isLeft(), isTrue);
      expect(service.isLoaded, isFalse);
    });

    test('a failure does not poison the next call', () async {
      server.failList = true;
      await service.load();
      server.failList = false;

      expect((await service.load()).isRight(), isTrue);
    });

    test('the list cannot be changed from outside', () async {
      await service.load();

      expect(
        () => service.students.add(service.students.first),
        throwsUnsupportedError,
      );
    });

    test('search runs on the loaded list', () async {
      await service.load();

      expect(service.search('cag').map((s) => s.id), ['s2']);
      expect(service.search('').map((s) => s.id), ['s1', 's2']);
    });

    test(
      'invalidate makes the next load fetch; clear forgets the list',
      () async {
        await service.load();
        service.invalidate();
        await service.load();
        service.clear();

        expect(server.listCalls, 2);
        expect(service.isLoaded, isFalse);
        expect(service.students, isEmpty);
      },
    );
  });

  group('addStudent', () {
    test('a created student joins the list', () async {
      await service.load();

      final result = await service.addStudent(_input);

      expect(result.rightOrNull, isA<StudentAdded>());
      expect(service.students.map((s) => s.id), ['s2', 's1', 's3']);
      expect(server.listCalls, 1);
    });

    test('the avatar that was sent shows when the answer has none', () async {
      await service.load();
      server.omitPhoto = true;

      final result = await service.addStudent(
        NewStudent(
          firstName: _input.firstName,
          lastName: _input.lastName,
          userName: _input.userName,
          password: _input.password,
          grade: _input.grade,
          photo: 'assets/avatars/5avatarN3.png',
        ),
      );

      expect(service.byId('s3')?.photo, '5avatarN3.png');
      final outcome = result.rightOrNull! as StudentAdded;
      expect(outcome.student.photo, '5avatarN3.png');
    });

    test('the server\'s own photo is kept', () async {
      await service.load();

      await service.addStudent(
        NewStudent(
          firstName: _input.firstName,
          lastName: _input.lastName,
          userName: _input.userName,
          password: _input.password,
          grade: _input.grade,
          photo: '5avatarN3.png',
        ),
      );

      expect(service.byId('s3')?.photo, 'avatars/1avatarN3.png');
    });

    test('a student without an avatar stays without one', () async {
      await service.load();
      server.omitPhoto = true;

      await service.addStudent(_input);

      expect(service.byId('s3')?.photo, isNull);
    });

    test('a taken login name changes nothing', () async {
      await service.load();
      server.usernameTaken = true;

      final result = await service.addStudent(_input);

      expect(result.rightOrNull, isA<UserNameTaken>());
      expect(service.students, hasLength(2));
    });

    test('a failure changes nothing', () async {
      await service.load();
      network.dispose();
      network = buildNetwork(FakeAdapter.json({}, status: 500));
      final broken = CoachStudentsService(
        repository: CoachStudentRepository(network),
        clock: () => now,
      );

      final result = await broken.addStudent(_input);

      expect(failureOf(result).code, AppErrorCode.server);
      expect(broken.students, isEmpty);
    });

    test('adding before the first load starts the list', () async {
      await service.addStudent(_input);

      expect(service.students.map((s) => s.id), ['s3']);
    });
  });

  test('checkUsername passes the answer through', () async {
    expect((await service.checkUsername('a')).rightOrNull!.available, isTrue);
    server.usernameTaken = true;
    expect((await service.checkUsername('a')).rightOrNull!.available, isFalse);
  });

  test('notifies listeners when the list changes', () async {
    var notified = 0;
    service.addListener(() => notified++);
    await Future<void>.delayed(Duration.zero);
    final before = notified;

    await service.load();
    await Future<void>.delayed(Duration.zero);

    expect(notified, greaterThan(before));
  });

  test('a transport failure on load is a network failure', () async {
    network.dispose();
    network = buildNetwork(
      FakeAdapter.failing(
        (o) => DioException.connectionError(requestOptions: o, reason: 'x'),
      ),
    );
    final offline = CoachStudentsService(
      repository: CoachStudentRepository(network),
    );

    expect(failureOf(await offline.load()).code, AppErrorCode.network);
  });
}
