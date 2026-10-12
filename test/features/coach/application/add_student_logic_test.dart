import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/auth/application/register/username_live_check.dart';
import 'package:smap/features/auth/presentation/register/register_viewmodel.dart';
import 'package:smap/features/coach/application/add_student_rules.dart';
import 'package:smap/features/coach/application/password_generator.dart';
import 'package:smap/features/coach/application/student_avatars.dart';
import 'package:smap/features/coach/data/dtos/coach_student_dto.dart';

/// The form of pano 10.3 kare 1, filled in (Zeynep Kaya, 12. sınıf, EA).
const _zeynep = AddStudentValues(
  firstName: 'Zeynep',
  lastName: 'Kaya',
  username: 'zeynep.kaya',
  password: 'Kx7mP2qRtv',
  grade: SchoolGrade.grade12,
  track: StudyTrack.esitAgirlik,
  avatarIndex: 3,
  usernameStatus: UsernameStatus.available,
);

AddStudentValues _with({
  String? firstName,
  String? lastName,
  String? username,
  String? password,
  SchoolGrade? grade,
  StudyTrack? track,
  UsernameStatus? status,
}) => AddStudentValues(
  firstName: firstName ?? _zeynep.firstName,
  lastName: lastName ?? _zeynep.lastName,
  username: username ?? _zeynep.username,
  password: password ?? _zeynep.password,
  grade: grade ?? _zeynep.grade,
  track: track ?? _zeynep.track,
  avatarIndex: _zeynep.avatarIndex,
  usernameStatus: status ?? _zeynep.usernameStatus,
);

void main() {
  group('AddStudentRules.validate', () {
    test('the board form has no issue', () {
      expect(AddStudentRules.validate(_zeynep), isEmpty);
    });

    test('an empty form lists every field in screen order', () {
      final issues = AddStudentRules.validate(const AddStudentValues());
      expect(issues, {
        AddStudentField.firstName: AddStudentIssue.firstNameMissing,
        AddStudentField.lastName: AddStudentIssue.lastNameMissing,
        AddStudentField.username: AddStudentIssue.usernameMissing,
        AddStudentField.password: AddStudentIssue.passwordMissing,
        AddStudentField.grade: AddStudentIssue.gradeMissing,
      });
      expect(issues.keys.first, AddStudentField.firstName);
    });

    test('names of spaces are missing', () {
      final issues = AddStudentRules.validate(
        _with(firstName: '  ', lastName: ' '),
      );
      expect(issues.keys, [
        AddStudentField.firstName,
        AddStudentField.lastName,
      ]);
    });

    test('a taken user name is an issue even when the field is filled', () {
      expect(
        AddStudentRules.issueOf(
          AddStudentField.username,
          _with(status: UsernameStatus.taken),
        ),
        AddStudentIssue.usernameTaken,
      );
    });

    test('a password is at least 8 characters', () {
      expect(
        AddStudentRules.issueOf(
          AddStudentField.password,
          _with(password: '1234567'),
        ),
        AddStudentIssue.passwordTooShort,
      );
      expect(
        AddStudentRules.issueOf(
          AddStudentField.password,
          _with(password: '12345678'),
        ),
        isNull,
      );
    });

    test('the track is asked from the 11th grade (Mezun included)', () {
      for (final grade in [
        SchoolGrade.grade11,
        SchoolGrade.grade12,
        SchoolGrade.graduate,
      ]) {
        final values = AddStudentValues(
          firstName: 'A',
          lastName: 'B',
          username: 'ab',
          password: '12345678',
          grade: grade,
        );
        expect(
          AddStudentRules.issueOf(AddStudentField.track, values),
          AddStudentIssue.trackMissing,
          reason: '$grade',
        );
      }
    });

    test('the 9th and 10th grade are valid with no track', () {
      for (final grade in [SchoolGrade.grade9, SchoolGrade.grade10]) {
        final values = AddStudentValues(
          firstName: 'Mert',
          lastName: 'Yıldız',
          username: 'mert',
          password: '12345678',
          grade: grade,
          usernameStatus: UsernameStatus.available,
        );
        expect(AddStudentRules.validate(values), isEmpty, reason: '$grade');
      }
    });

    test('trackFor keeps a track only while the grade asks for one', () {
      expect(
        AddStudentRules.trackFor(SchoolGrade.grade10, StudyTrack.sayisal),
        isNull,
      );
      expect(
        AddStudentRules.trackFor(SchoolGrade.grade11, StudyTrack.sayisal),
        StudyTrack.sayisal,
      );
      expect(AddStudentRules.trackFor(null, StudyTrack.sayisal), isNull);
    });
  });

  group('AddStudentRules.toNewStudent', () {
    test('is the request of the board form', () {
      final request = AddStudentRules.toNewStudent(_zeynep)!;
      expect(request.toDataObj(), {
        'name': 'Zeynep',
        'surname': 'Kaya',
        'userName': 'zeynep.kaya',
        'password': 'Kx7mP2qRtv',
        'seasonType': 12,
        'aimType': 2,
        'photo': '5avatarN3.png',
      });
    });

    test('"Mezun" is sent as 13', () {
      final request = AddStudentRules.toNewStudent(
        _with(grade: SchoolGrade.graduate, track: StudyTrack.sozel),
      )!;
      expect(request.toDataObj()['seasonType'], 13);
      expect(request.toDataObj()['aimType'], 4);
    });

    test('a 10th grader is sent without a track', () {
      final request = AddStudentRules.toNewStudent(
        const AddStudentValues(
          firstName: 'Mert',
          lastName: 'Yıldız',
          username: 'mert',
          password: '12345678',
          grade: SchoolGrade.grade10,
          track: StudyTrack.sayisal,
          usernameStatus: UsernameStatus.available,
        ),
      )!;
      expect(request.toDataObj().containsKey('aimType'), isFalse);
    });

    test('is null while the form has an issue', () {
      expect(AddStudentRules.toNewStudent(const AddStudentValues()), isNull);
    });

    test('the names are trimmed, the password is not', () {
      final request = AddStudentRules.toNewStudent(
        _with(
          firstName: ' Zeynep ',
          lastName: ' Kaya ',
          password: ' pass word ',
        ),
      )!;
      expect(request.firstName, 'Zeynep');
      expect(request.lastName, 'Kaya');
      expect(request.password, ' pass word ');
    });
  });

  group('AddedStudent', () {
    test('never prints the password', () {
      const added = AddedStudent(
        student: CoachStudentDto(id: 's1'),
        fullName: 'Zeynep Kaya',
        userName: 'zeynep.kaya',
        password: 'secret-pass',
      );
      expect(added.toString(), isNot(contains('secret-pass')));
      expect(added.toString(), contains('Zeynep Kaya'));
    });
  });

  group('PasswordGenerator (pano 10.3 "Oluştur")', () {
    test('makes 10 characters', () {
      expect(PasswordGenerator.generate(Random(1)), hasLength(10));
    });

    test('never uses the look-alikes I, l, O, 0 or 1', () {
      final random = Random(42);
      for (var i = 0; i < 500; i++) {
        final password = PasswordGenerator.generate(random);
        expect(password, isNot(matches(RegExp('[IlO01]'))), reason: password);
      }
    });

    test('has an upper-case letter, a lower-case letter and a digit', () {
      final random = Random(7);
      for (var i = 0; i < 500; i++) {
        final password = PasswordGenerator.generate(random);
        expect(password, contains(RegExp('[A-Z]')), reason: password);
        expect(password, contains(RegExp('[a-z]')), reason: password);
        expect(password, contains(RegExp('[0-9]')), reason: password);
      }
    });

    test('is only letters and digits', () {
      final random = Random(3);
      for (var i = 0; i < 200; i++) {
        expect(
          PasswordGenerator.generate(random),
          matches(RegExp(r'^[A-Za-z0-9]{10}$')),
        );
      }
    });

    test('the same seed gives the same password', () {
      expect(
        PasswordGenerator.generate(Random(5)),
        PasswordGenerator.generate(Random(5)),
      );
    });

    test('new passwords differ from each other', () {
      final random = Random(9);
      final seen = {
        for (var i = 0; i < 100; i++) PasswordGenerator.generate(random),
      };
      expect(seen.length, greaterThan(95));
    });

    test('passes the form\'s own length rule', () {
      expect(
        PasswordGenerator.generate(Random(2)).length,
        greaterThanOrEqualTo(AddStudentRules.minPasswordLength),
      );
    });
  });

  group('StudentAvatars', () {
    test('are the seven the sign-up picker offers, in the same order', () {
      expect(StudentAvatars.files, RegisterViewModel.avatarFiles);
    });

    test('the first is chosen at the start (Tur 12 D)', () {
      expect(StudentAvatars.initialIndex, 0);
      expect(
        StudentAvatars.fileOf(StudentAvatars.initialIndex),
        '1avatarN3.png',
      );
    });

    test('an index outside the set has no file', () {
      expect(StudentAvatars.fileOf(-1), isNull);
      expect(StudentAvatars.fileOf(7), isNull);
      expect(StudentAvatars.assetOf(7), isNull);
    });

    test('the asset path is under assets/avatars', () {
      expect(StudentAvatars.assetOf(3), 'assets/avatars/5avatarN3.png');
    });

    test('finds an avatar by its file, with or without the folder', () {
      expect(StudentAvatars.indexOf('5avatarN3.png'), 3);
      expect(StudentAvatars.indexOf('avatars/5avatarN3.png'), 3);
      expect(StudentAvatars.indexOf('assets/avatars/5avatarN3.png'), 3);
      expect(StudentAvatars.indexOf('Jonas.png'), isNull);
      expect(StudentAvatars.indexOf(null), isNull);
      expect(StudentAvatars.indexOf(' '), isNull);
    });

    test('the empty state shows av-1, av-4 and av-3 (pano 10.2 kare 4)', () {
      expect(StudentAvatars.emptyStateIndices.map(StudentAvatars.fileOf), [
        '1avatarN3.png',
        '5avatarN3.png',
        '4avatarN3.png',
      ]);
    });
  });
}
