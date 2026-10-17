import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/domain/user_role.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/auth/data/auth_repository.dart';
import 'package:smap/features/auth/data/dtos/new_registration.dart';
import 'package:smap/features/auth/data/dtos/register_outcome.dart';

import '../../../core/network/fake_adapter.dart';
import '../../schedule/network_harness.dart';

NewRegistration _student({
  String fullName = 'Alparslan Kuloğlu',
  SchoolGrade? grade = SchoolGrade.grade12,
  StudyTrack? track = StudyTrack.esitAgirlik,
}) => NewRegistration(
  role: UserRole.student,
  fullName: fullName,
  userName: ' alparslan.k ',
  email: ' alparslan@ornek.com ',
  password: 'Gizli#2026',
  passwordRepeat: 'Gizli#2026',
  photo: 'assets/avatars/1avatarN3.png',
  grade: grade,
  track: track,
  acceptedTermsVersion: '1.2.0',
  acceptedKvkkVersion: '1.1.0',
  acceptedPrivacyVersion: '1.0.0',
);

void main() {
  late NetworkService network;
  late FakeAdapter adapter;
  late AuthRepository repository;

  void backend(FakeAdapter fake) {
    adapter = fake;
    network = buildNetwork(fake);
    repository = AuthRepository(network);
  }

  group('NewRegistration body', () {
    test('a student: the form body, field by field', () {
      final body = _student().toBody(withAcceptedVersions: false);

      expect(body, {
        'userType': 1,
        'data': {
          'name': 'Alparslan Kuloğlu',
          'firstName': 'Alparslan',
          'surname': 'Kuloğlu',
          'userName': 'alparslan.k',
          'email': 'alparslan@ornek.com',
          'password': 'Gizli#2026',
          'password2': 'Gizli#2026',
          'seasonType': 12,
          'aimType': 2,
          'photo': '1avatarN3.png',
        },
      });
    });

    test('a coach sends seasonType 0 and no aimType', () {
      const coach = NewRegistration(
        role: UserRole.coach,
        fullName: 'Mehmet Özkan',
        userName: 'mehmet',
        email: 'mehmet@ornek.com',
        password: 'Gizli#2026',
        passwordRepeat: 'Gizli#2026',
        photo: '3avatarN3.png',
        grade: SchoolGrade.grade12,
        track: StudyTrack.sayisal,
      );

      final body = coach.toBody();
      final data = body['data']! as Map<String, Object?>;

      expect(body['userType'], 2);
      expect(data['seasonType'], 0);
      expect(data.containsKey('aimType'), isTrue);
      expect(data['aimType'], isNull);
    });

    test('grade 9 and 10 have no track; the graduate sends 13', () {
      expect(_student(grade: SchoolGrade.grade10).aimType, isNull);
      expect(_student(grade: SchoolGrade.grade9).seasonType, 9);
      expect(_student(grade: SchoolGrade.graduate).seasonType, 13);
      expect(_student(grade: SchoolGrade.graduate).aimType, 2);
    });

    test('one word is a first name; the last of several is the surname', () {
      expect(NewRegistration.splitFullName('Ayşe'), (
        whole: 'Ayşe',
        firstName: 'Ayşe',
        surname: '',
      ));
      expect(NewRegistration.splitFullName('  Ayşe   Nur  Kaya '), (
        whole: 'Ayşe Nur Kaya',
        firstName: 'Ayşe Nur',
        surname: 'Kaya',
      ));
    });

    test('the accepted versions ride next to userType, only when known', () {
      final body = _student().toBody();

      expect(body['acceptedTermsVersion'], '1.2.0');
      expect(body['acceptedKvkkVersion'], '1.1.0');
      expect(body['acceptedPrivacyVersion'], '1.0.0');
      expect(
        _student().toBody(withAcceptedVersions: false).keys,
        isNot(contains('acceptedTermsVersion')),
      );
      expect(
        const NewRegistration(
          role: UserRole.student,
          fullName: 'A B',
          userName: 'ab',
          email: 'a@b.co',
          password: 'x',
          passwordRepeat: 'x',
          photo: 'p.png',
        ).toBody().keys,
        isNot(contains('acceptedKvkkVersion')),
      );
    });

    test('toString never prints the password', () {
      expect(_student().toString(), isNot(contains('Gizli')));
    });
  });

  group('register', () {
    tearDown(() => network.dispose());

    test('posts the body as JSON without a session', () async {
      backend(FakeAdapter.json({'success': true, 'user': <String, Object?>{}}));

      final result = await repository.register(_student());

      expect(result.rightOrNull, RegisterOutcome.registered);
      expect(adapter.last.method, 'POST');
      expect(adapter.last.path, '/student/register');
      expect(adapter.last.contentType, contains('application/json'));
      final body = adapter.last.data as Map<String, Object?>;
      expect(body['userType'], 1);
      expect((body['data']! as Map)['userName'], 'alparslan.k');
      expect(body['acceptedTermsVersion'], '1.2.0');
    });

    test('a 201 with success: true is a registration', () async {
      backend(FakeAdapter.json({'success': true}, status: 201));

      expect(
        (await repository.register(_student())).rightOrNull,
        RegisterOutcome.registered,
      );
    });

    test('a 302 with success: true is a registration', () async {
      backend(FakeAdapter.json({'success': true}, status: 302));

      expect(
        (await repository.register(_student())).rightOrNull,
        RegisterOutcome.registered,
      );
    });

    test('a 200 without success: true is not one', () async {
      backend(FakeAdapter.json({'user': <String, Object?>{}}));

      final failure = failureOf(await repository.register(_student()));

      expect(failure.code, AppErrorCode.server);
    });

    test(
      'success: false carries the server text as a validation failure',
      () async {
        backend(
          FakeAdapter.json({'success': false, 'message': 'E-posta geçersiz'}),
        );

        final failure = failureOf(await repository.register(_student()));

        expect(failure.code, AppErrorCode.validation);
        expect(failure.serverMessage, 'E-posta geçersiz');
      },
    );

    test('userNameUsing: true is a taken user name', () async {
      backend(FakeAdapter.json({'success': false, 'userNameUsing': true}));

      expect(
        (await repository.register(_student())).rightOrNull,
        RegisterOutcome.userNameTaken,
      );
    });

    test(
      'a refusal text that says the user name is in use is one too',
      () async {
        backend(
          FakeAdapter.json({
            'success': false,
            'message': 'Bu kullanıcı adı zaten kullanımda',
          }),
        );

        expect(
          (await repository.register(_student())).rightOrNull,
          RegisterOutcome.userNameTaken,
        );
      },
    );

    test(
      'the same text on a 400 is a taken user name, not a failure',
      () async {
        backend(
          FakeAdapter.json({
            'success': false,
            'message': 'Kullanıcı adı alınmış',
          }, status: 400),
        );

        expect(
          (await repository.register(_student())).rightOrNull,
          RegisterOutcome.userNameTaken,
        );
      },
    );

    test('a 400 with another text stays a validation failure', () async {
      backend(
        FakeAdapter.json({
          'success': false,
          'message': 'Şifre çok kısa',
        }, status: 400),
      );

      final failure = failureOf(await repository.register(_student()));

      expect(failure.code, AppErrorCode.validation);
      expect(failure.serverMessage, 'Şifre çok kısa');
    });

    test('a 500 is a server failure', () async {
      backend(FakeAdapter.json({'error': 'x'}, status: 500));

      expect(
        failureOf(await repository.register(_student())).code,
        AppErrorCode.server,
      );
    });

    test('a 401 is not read as an expired session', () async {
      final events = <Object>[];
      backend(FakeAdapter.json({'success': false}, status: 401));
      network.onSessionExpired.listen(events.add);

      final failure = failureOf(await repository.register(_student()));

      expect(failure.code, AppErrorCode.unauthorized);
      expect(events, isEmpty);
    });

    test('a broken connection is a network failure', () async {
      backend(
        FakeAdapter.failing(
          (options) => DioException.connectionTimeout(
            timeout: const Duration(seconds: 15),
            requestOptions: options,
          ),
        ),
      );

      expect(
        failureOf(await repository.register(_student())).code,
        AppErrorCode.timeout,
      );
    });
  });

  group('RegisterOutcome.readsAsUserNameTaken', () {
    test('needs the user name and a "taken" word', () {
      expect(RegisterOutcome.readsAsUserNameTaken(null), isFalse);
      expect(RegisterOutcome.readsAsUserNameTaken(''), isFalse);
      expect(
        RegisterOutcome.readsAsUserNameTaken('Bu kullanıcı adı alınmış.'),
        isTrue,
      );
      expect(
        RegisterOutcome.readsAsUserNameTaken('KULLANICI ADI ZATEN VAR'),
        isTrue,
      );
      expect(
        RegisterOutcome.readsAsUserNameTaken('Username already exists'),
        isTrue,
      );
      expect(
        RegisterOutcome.readsAsUserNameTaken('E-posta zaten kayıtlı'),
        isFalse,
      );
      expect(
        RegisterOutcome.readsAsUserNameTaken('Kullanıcı adı geçersiz'),
        isFalse,
      );
    });
  });
}
