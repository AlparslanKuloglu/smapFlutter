import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/coach/data/add_student_outcome.dart';
import 'package:smap/features/coach/data/coach_student_repository.dart';
import 'package:smap/features/coach/domain/new_student.dart';

import '../../../core/network/fake_adapter.dart';
import '../../schedule/network_harness.dart';
import '../coach_fixtures.dart';

const _input = NewStudent(
  firstName: 'Zeynep',
  lastName: 'Kaya',
  userName: 'zeynep.kaya',
  password: 'Gizli#2026',
  grade: SchoolGrade.grade12,
  track: StudyTrack.esitAgirlik,
  photo: '1avatarN3.png',
);

void main() {
  late NetworkService network;
  late FakeAdapter adapter;
  late CoachStudentRepository repository;

  void backend(FakeAdapter fake) {
    adapter = fake;
    network = buildNetwork(fake);
    repository = CoachStudentRepository(network);
  }

  FakeAdapter emptyBody() =>
      FakeAdapter((_) => textResponse('', contentType: 'text/plain'));

  tearDown(() => network.dispose());

  group('getMyStudents', () {
    test('reads the students and posts without a body', () async {
      backend(
        FakeAdapter.json({
          'students': [
            studentJson(),
            studentJson(id: 'student-2', name: 'Ali', surname: null),
          ],
        }),
      );

      final students = (await repository.getMyStudents()).rightOrNull!;

      expect(students.map((s) => s.id), ['student-1', 'student-2']);
      expect(students.first.totalMexam, 14);
      expect(adapter.last.method, 'POST');
      expect(adapter.last.path, '/coach/getMyStudents');
      expect(adapter.last.data, isNull);
    });

    test('the legacy call ignored success; so does a missing flag', () async {
      backend(
        FakeAdapter.json({
          'students': [studentJson()],
        }),
      );

      expect((await repository.getMyStudents()).rightOrNull, hasLength(1));
    });

    test('no students yet is a value', () async {
      backend(FakeAdapter.json({'success': true, 'students': <Object?>[]}));

      final result = await repository.getMyStudents();

      expect(result.isRight(), isTrue);
      expect(result.rightOrNull, isEmpty);
    });

    test('a broken entry does not hide the others', () async {
      backend(
        FakeAdapter.json({
          'students': ['nonsense', studentJson(), 4],
        }),
      );

      expect((await repository.getMyStudents()).rightOrNull, hasLength(1));
    });

    test('success false is a validation failure', () async {
      backend(FakeAdapter.json({'success': false, 'message': 'Yetki yok'}));

      final error = failureOf(await repository.getMyStudents());

      expect(error.code, AppErrorCode.validation);
      expect(error.serverMessage, 'Yetki yok');
    });

    test('an empty body is an unusable answer', () async {
      backend(emptyBody());

      expect(
        failureOf(await repository.getMyStudents()).code,
        AppErrorCode.server,
      );
    });

    test('a frame without a list is an unusable answer', () async {
      backend(FakeAdapter.json({'success': true}));

      expect(
        failureOf(await repository.getMyStudents()).code,
        AppErrorCode.server,
      );
    });

    test('a lost session is reported as such', () async {
      backend(FakeAdapter.json({}, status: 401));

      expect(
        failureOf(await repository.getMyStudents()).code,
        AppErrorCode.sessionExpired,
      );
    });

    test('a dropped connection is a network failure', () async {
      backend(
        FakeAdapter.failing(
          (options) => DioException.connectionError(
            requestOptions: options,
            reason: 'refused',
          ),
        ),
      );

      expect(
        failureOf(await repository.getMyStudents()).code,
        AppErrorCode.network,
      );
    });
  });

  group('checkUsername', () {
    test('asks with the name and reads a free name', () async {
      backend(FakeAdapter.json({'success': true, 'available': true}));

      final check = (await repository.checkUsername(
        ' zeynep.kaya ',
      )).rightOrNull!;

      expect(check.available, isTrue);
      expect(adapter.last.method, 'GET');
      expect(adapter.last.path, '/ajax/checkUsername');
      expect(adapter.last.queryParameters, {'name': 'zeynep.kaya'});
    });

    test('reads a taken name', () async {
      backend(FakeAdapter.json({'success': true, 'available': false}));

      expect(
        (await repository.checkUsername('x')).rightOrNull!.available,
        isFalse,
      );
    });

    test('an answer without the flag is not guessed', () async {
      backend(FakeAdapter.json({'success': true}));

      expect(
        failureOf(await repository.checkUsername('x')).code,
        AppErrorCode.server,
      );
    });

    test('a refusal without the flag is a validation failure', () async {
      backend(FakeAdapter.json({'success': false, 'message': 'Geçersiz ad'}));

      final error = failureOf(await repository.checkUsername('x'));

      expect(error.code, AppErrorCode.validation);
      expect(error.serverMessage, 'Geçersiz ad');
    });

    test('an empty body is a failure', () async {
      backend(emptyBody());

      expect(
        failureOf(await repository.checkUsername('x')).code,
        AppErrorCode.server,
      );
    });
  });

  group('addStudent', () {
    test('posts the dataObj and returns the created student', () async {
      backend(
        FakeAdapter.json({'success': true, 'student': studentJson(id: 'new')}),
      );

      final outcome = (await repository.addStudent(_input)).rightOrNull!;

      expect(outcome, isA<StudentAdded>());
      expect((outcome as StudentAdded).student.id, 'new');
      expect(adapter.last.method, 'POST');
      expect(adapter.last.path, '/coach/addNewStudent');
      expect(adapter.last.data, {
        'dataObj': {
          'name': 'Zeynep',
          'surname': 'Kaya',
          'userName': 'zeynep.kaya',
          'password': 'Gizli#2026',
          'seasonType': 12,
          'aimType': 2,
          'photo': '1avatarN3.png',
        },
      });
    });

    test('the created student never carries the password', () async {
      backend(FakeAdapter.json({'success': true, 'student': studentJson()}));

      final outcome =
          (await repository.addStudent(_input)).rightOrNull! as StudentAdded;

      expect(outcome.student.toJson().containsKey('password'), isFalse);
    });

    test('a taken login name is an outcome, not a failure', () async {
      backend(FakeAdapter.json({'success': true, 'userNameUsing': true}));

      final outcome = (await repository.addStudent(_input)).rightOrNull!;

      expect(outcome, isA<UserNameTaken>());
    });

    test('a taken login name is recognised even with success false', () async {
      backend(FakeAdapter.json({'success': false, 'userNameUsing': true}));

      expect(
        (await repository.addStudent(_input)).rightOrNull,
        isA<UserNameTaken>(),
      );
    });

    test('another refusal carries the server text', () async {
      backend(FakeAdapter.json({'success': false, 'message': 'Şifre kısa'}));

      final error = failureOf(await repository.addStudent(_input));

      expect(error.code, AppErrorCode.validation);
      expect(error.serverMessage, 'Şifre kısa');
    });

    test('success without a student is a refusal', () async {
      backend(FakeAdapter.json({'success': true}));

      expect(
        failureOf(await repository.addStudent(_input)).code,
        AppErrorCode.validation,
      );
    });

    test('an empty body is an unusable answer', () async {
      backend(emptyBody());

      expect(
        failureOf(await repository.addStudent(_input)).code,
        AppErrorCode.server,
      );
    });

    test('a timeout is a timeout failure', () async {
      backend(
        FakeAdapter.failing(
          (options) => DioException.sendTimeout(
            timeout: const Duration(seconds: 30),
            requestOptions: options,
          ),
        ),
      );

      expect(
        failureOf(await repository.addStudent(_input)).code,
        AppErrorCode.timeout,
      );
    });
  });
}
