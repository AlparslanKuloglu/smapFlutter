import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/account/application/account_header.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';

void main() {
  const student = UserDto(
    name: 'Alparslan Kuloğlu',
    role: 'student',
    seasonType: 12,
    aimType: 2,
    photo: '1avatarN3.png',
  );
  const coach = UserDto(
    name: 'Mehmet Özkan',
    role: 'coach',
    refCode: 'MOZK-4821',
  );

  group('a student', () {
    test('carries the grade, the track and the coach', () {
      final header = AccountHeader.of(student, coachName: ' Mehmet Özkan ');

      expect(header.name, 'Alparslan Kuloğlu');
      expect(header.isCoach, isFalse);
      expect(header.grade, SchoolGrade.grade12);
      expect(header.track, StudyTrack.esitAgirlik);
      expect(header.coachName, 'Mehmet Özkan');
      expect(header.photo, '1avatarN3.png');
      expect(header.subLineCount, 2);
    });

    test('without a coach the third line is not counted', () {
      final header = AccountHeader.of(student);

      expect(header.coachName, isNull);
      expect(header.subLineCount, 1);
    });

    test('a blank coach name is no coach', () {
      expect(AccountHeader.of(student, coachName: '  ').coachName, isNull);
    });

    test('the 10th grade has no track line part', () {
      final header = AccountHeader.of(
        const UserDto(
          name: 'Ayşe',
          role: 'student',
          seasonType: 10,
          aimType: 2,
        ),
      );

      expect(header.track, isNull);
      expect(header.subLineCount, 1);
    });

    test('an account without grade or track has no first line', () {
      final header = AccountHeader.of(
        const UserDto(name: 'Ayşe', role: 'student'),
      );

      expect(header.subLineCount, 0);
    });

    test('falls back to the login name when there is no display name', () {
      expect(
        AccountHeader.of(
          const UserDto(userName: 'ayse.y', role: 'student'),
        ).name,
        'ayse.y',
      );
    });
  });

  group('a coach', () {
    test('carries the coaching code and always the role line', () {
      final header = AccountHeader.of(coach);

      expect(header.isCoach, isTrue);
      expect(header.coachCode, 'MOZK-4821');
      expect(header.subLineCount, 2);
    });

    test('writes a code without its dash the way the design does', () {
      expect(
        AccountHeader.of(
          const UserDto(role: 'coach', refCode: 'mozk4821'),
        ).coachCode,
        'MOZK-4821',
      );
    });

    test('keeps a code of another shape as it is', () {
      expect(
        AccountHeader.of(
          const UserDto(role: 'coach', refCode: ' K-77 '),
        ).coachCode,
        'K-77',
      );
    });

    test('without a code only the role line is counted', () {
      final header = AccountHeader.of(const UserDto(role: 'coach'));

      expect(header.coachCode, isNull);
      expect(header.subLineCount, 1);
    });
  });

  test('headers are equal by value', () {
    expect(AccountHeader.of(student), AccountHeader.of(student));
    expect(
      AccountHeader.of(student, coachName: 'A'),
      isNot(AccountHeader.of(student, coachName: 'B')),
    );
  });
}
