import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/account/data/account_repository.dart';
import 'package:smap/features/account/domain/profile_update.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';

import '../../../core/network/fake_adapter.dart';
import '../../schedule/network_harness.dart';

Map<String, Object?> _student({String name = 'Ayşe Yılmaz'}) => {
  '_id': 'student-1',
  'name': name,
  'password': r'$2a$10$hash',
  'role': 'student',
  'seasonType': 12,
  'aimType': 3,
};

Map<String, Object?> _coach() => {
  '_id': 'coach-1',
  'name': 'Mert Demir',
  'refCode': 'ABCD-1234',
  'photo': 'avatars/4avatarN3.png',
  'role': 'coach',
};

void main() {
  late NetworkService network;
  late FakeAdapter adapter;
  late AccountRepository repository;

  void backend(FakeAdapter fake) {
    adapter = fake;
    network = buildNetwork(fake);
    repository = AccountRepository(network);
  }

  FakeAdapter emptyBody() =>
      FakeAdapter((_) => textResponse('', contentType: 'text/plain'));

  tearDown(() => network.dispose());

  group('updateProfile', () {
    test(
      'posts the changed fields flat and returns the updated user',
      () async {
        backend(
          FakeAdapter.json({
            'success': true,
            'student': _student(name: 'Yeni'),
          }),
        );

        final result = await repository.updateProfile(
          const ProfileUpdate(
            name: 'Yeni',
            email: 'yeni@example.com',
            grade: SchoolGrade.grade12,
            track: StudyTrack.sayisal,
          ),
        );

        final user = result.rightOrNull!;
        expect(user.name, 'Yeni');
        expect(user.seasonType, 12);
        expect(adapter.last.method, 'POST');
        expect(adapter.last.path, '/student/updateStudent');
        expect(adapter.last.data, {
          'name': 'Yeni',
          'email': 'yeni@example.com',
          'seasonType': 12,
          'aimType': 3,
        });
      },
    );

    test('success without the user is a value of null', () async {
      backend(FakeAdapter.json({'success': true}));

      final result = await repository.updateProfile(
        const ProfileUpdate(phone: '5551112233'),
      );

      expect(result.isRight(), isTrue);
      expect(result.rightOrNull, isNull);
    });

    test('a refusal carries the server text', () async {
      backend(
        FakeAdapter.json({'success': false, 'message': 'Geçersiz e-posta'}),
      );

      final error = failureOf(
        await repository.updateProfile(const ProfileUpdate(email: 'x')),
      );

      expect(error.code, AppErrorCode.validation);
      expect(error.serverMessage, 'Geçersiz e-posta');
    });

    test('an empty body is an unusable answer', () async {
      backend(emptyBody());

      expect(
        failureOf(await repository.updateProfile(const ProfileUpdate())).code,
        AppErrorCode.server,
      );
    });

    test('a lost session is reported as such', () async {
      backend(FakeAdapter.json({}, status: 401));

      expect(
        failureOf(await repository.updateProfile(const ProfileUpdate())).code,
        AppErrorCode.sessionExpired,
      );
    });
  });

  group('getLegalDocuments', () {
    final docs = [
      {
        '_id': 'd1',
        'name': 'kullanim_kosullari',
        'title': 'Kullanım Koşulları',
      },
      {'_id': 'd2', 'name': 'gizlilik_politikasi', 'isActive': false},
    ];

    test('reads a bare list', () async {
      backend(FakeAdapter.json(docs));

      final list = (await repository.getLegalDocuments()).rightOrNull!;

      expect(list.map((d) => d.name), [
        'kullanim_kosullari',
        'gizlilik_politikasi',
      ]);
      expect(list.last.active, isFalse);
      expect(adapter.last.method, 'GET');
      expect(adapter.last.path, '/ajax/getLegalDocuments');
    });

    test('reads a list wrapped in data', () async {
      backend(FakeAdapter.json({'success': true, 'data': docs}));

      expect((await repository.getLegalDocuments()).rightOrNull, hasLength(2));
    });

    test('skips entries it cannot read', () async {
      backend(FakeAdapter.json(['junk', docs.first, null]));

      expect((await repository.getLegalDocuments()).rightOrNull, hasLength(1));
    });

    test('an empty list is a value', () async {
      backend(FakeAdapter.json(<Object?>[]));

      final result = await repository.getLegalDocuments();

      expect(result.isRight(), isTrue);
      expect(result.rightOrNull, isEmpty);
    });

    test('an empty body is a failure, not an empty list', () async {
      backend(emptyBody());

      expect(
        failureOf(await repository.getLegalDocuments()).code,
        AppErrorCode.server,
      );
    });

    test('a refusal is a failure', () async {
      backend(FakeAdapter.json({'success': false, 'message': 'Yok'}));

      expect(
        failureOf(await repository.getLegalDocuments()).code,
        AppErrorCode.validation,
      );
    });

    test('is a public call: a 401 is not a lost session', () async {
      backend(FakeAdapter.json({}, status: 401));

      expect(
        failureOf(await repository.getLegalDocuments()).code,
        AppErrorCode.unauthorized,
      );
    });

    test('a timeout is a timeout failure', () async {
      backend(
        FakeAdapter.failing(
          (options) => DioException.receiveTimeout(
            timeout: const Duration(seconds: 30),
            requestOptions: options,
          ),
        ),
      );

      expect(
        failureOf(await repository.getLegalDocuments()).code,
        AppErrorCode.timeout,
      );
    });
  });

  group('deleteAccount', () {
    test('succeeds on success true', () async {
      backend(FakeAdapter.json({'success': true}));

      expect((await repository.deleteAccount()).isRight(), isTrue);
      expect(adapter.last.method, 'GET');
      expect(adapter.last.path, '/ajax/deleteAccount');
    });

    test('a refusal carries the msg text', () async {
      backend(FakeAdapter.json({'success': false, 'msg': 'Hesap silinemedi.'}));

      final error = failureOf(await repository.deleteAccount());

      expect(error.code, AppErrorCode.validation);
      expect(error.serverMessage, 'Hesap silinemedi.');
    });

    test('an empty body does not look like a deleted account', () async {
      backend(emptyBody());

      expect(
        failureOf(await repository.deleteAccount()).code,
        AppErrorCode.server,
      );
    });

    test('a server error is a server failure', () async {
      backend(FakeAdapter.json({}, status: 500));

      expect(
        failureOf(await repository.deleteAccount()).code,
        AppErrorCode.server,
      );
    });
  });

  group('getMyCoach', () {
    test('reads the coach', () async {
      backend(FakeAdapter.json({'success': true, 'coach': _coach()}));

      final coach = (await repository.getMyCoach()).rightOrNull!;

      expect(coach.id, 'coach-1');
      expect(coach.displayName, 'Mert Demir');
      expect(coach.refCode, 'ABCD-1234');
      expect(adapter.last.path, '/student/getStudentsCoach');
    });

    test('a student without a coach gets null', () async {
      backend(FakeAdapter.json({'success': true, 'coach': null}));

      final result = await repository.getMyCoach();

      expect(result.isRight(), isTrue);
      expect(result.rightOrNull, isNull);
    });

    test('success false also reads as no coach', () async {
      backend(FakeAdapter.json({'success': false, 'message': 'Koç yok'}));

      final result = await repository.getMyCoach();

      expect(result.isRight(), isTrue);
      expect(result.rightOrNull, isNull);
    });

    test('an empty body is a failure', () async {
      backend(emptyBody());

      expect(
        failureOf(await repository.getMyCoach()).code,
        AppErrorCode.server,
      );
    });

    test('a lost session is reported as such', () async {
      backend(FakeAdapter.json({}, status: 302));

      expect(
        failureOf(await repository.getMyCoach()).code,
        AppErrorCode.sessionExpired,
      );
    });
  });

  group('addCoach', () {
    test('sends the code and returns the coach', () async {
      backend(FakeAdapter.json({'success': true, 'coach': _coach()}));

      final coach = (await repository.addCoach('  ABCD-1234 ')).rightOrNull!;

      expect(coach.id, 'coach-1');
      expect(adapter.last.method, 'GET');
      expect(adapter.last.path, '/student/addCoach');
      expect(adapter.last.queryParameters, {'code': 'ABCD-1234'});
    });

    test(
      'an unknown code is a validation failure with the server text',
      () async {
        backend(
          FakeAdapter.json({
            'success': false,
            'message': 'Koçluk kodu bulunamadı.',
          }),
        );

        final error = failureOf(await repository.addCoach('ZZZZ-0000'));

        expect(error.code, AppErrorCode.validation);
        expect(error.serverMessage, 'Koçluk kodu bulunamadı.');
      },
    );

    test('success without a coach is also a refusal', () async {
      backend(FakeAdapter.json({'success': true}));

      expect(
        failureOf(await repository.addCoach('ABCD-1234')).code,
        AppErrorCode.validation,
      );
    });

    test('an empty body is a failure', () async {
      backend(emptyBody());

      expect(
        failureOf(await repository.addCoach('ABCD-1234')).code,
        AppErrorCode.server,
      );
    });
  });

  group('removeCoach', () {
    test('sends the coach id (the legacy call dropped it)', () async {
      backend(FakeAdapter.json({'success': true}));

      final result = await repository.removeCoach('coach-1');

      expect(result.isRight(), isTrue);
      expect(adapter.last.method, 'GET');
      expect(adapter.last.path, '/student/deleteCoach');
      expect(adapter.last.queryParameters, {'coach': 'coach-1'});
    });

    test('a refusal carries the server text', () async {
      backend(FakeAdapter.json({'success': false, 'message': 'Bağ yok'}));

      expect(
        failureOf(await repository.removeCoach('c')).serverMessage,
        'Bağ yok',
      );
    });

    test('an empty body is a failure', () async {
      backend(emptyBody());

      expect(
        failureOf(await repository.removeCoach('c')).code,
        AppErrorCode.server,
      );
    });
  });
}
