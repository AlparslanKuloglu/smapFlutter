import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/domain/user_role.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/auth/application/register/register_rules.dart';
import 'package:smap/features/auth/application/register/username_live_check.dart';

RegisterFormValues _valid({
  UserRole role = UserRole.student,
  SchoolGrade? grade = SchoolGrade.grade12,
  StudyTrack? track = StudyTrack.esitAgirlik,
}) => RegisterFormValues(
  role: role,
  fullName: 'Alparslan Kuloğlu',
  username: 'alparslan.k',
  email: 'alparslan@ornek.com',
  password: 'Gizli#2026',
  passwordRepeat: 'Gizli#2026',
  grade: grade,
  track: track,
  consent: true,
  usernameStatus: UsernameStatus.available,
);

void main() {
  group('normalizeUserName', () {
    test('lower-cases the Turkish way and keeps letters, digits . and _', () {
      expect(RegisterRules.normalizeUserName('ALPARSLAN.K'), 'alparslan.k');
      expect(RegisterRules.normalizeUserName('IŞIK_İPEK'), 'ışık_ipek');
      expect(RegisterRules.normalizeUserName('ali_veli.99'), 'ali_veli.99');
    });

    test('drops spaces, dashes, symbols and emoji', () {
      expect(RegisterRules.normalizeUserName(' ali veli '), 'aliveli');
      expect(RegisterRules.normalizeUserName('ali-veli@x!'), 'alivelix');
      expect(RegisterRules.normalizeUserName('ali😀'), 'ali');
    });

    test('isValidUserName wants a non-empty normalized name', () {
      expect(RegisterRules.isValidUserName('alparslan.k'), isTrue);
      expect(RegisterRules.isValidUserName(''), isFalse);
      expect(RegisterRules.isValidUserName('Alparslan'), isFalse);
      expect(RegisterRules.isValidUserName('a b'), isFalse);
    });
  });

  group('isValidEmail', () {
    test('accepts an address with a dotted domain', () {
      expect(RegisterRules.isValidEmail('alparslan@ornek.com'), isTrue);
      expect(RegisterRules.isValidEmail(' ad@alan.com.tr '), isTrue);
    });

    test('rejects what pano 2.6 kare 1 shows and similar', () {
      expect(RegisterRules.isValidEmail('alparslan@ornek'), isFalse);
      expect(RegisterRules.isValidEmail('alparslan'), isFalse);
      expect(RegisterRules.isValidEmail('@ornek.com'), isFalse);
      expect(RegisterRules.isValidEmail('a b@ornek.com'), isFalse);
      expect(RegisterRules.isValidEmail(''), isFalse);
    });
  });

  group('validate', () {
    test('a complete student form has no issue', () {
      expect(RegisterRules.validate(_valid()), isEmpty);
    });

    test('a coach needs no grade or track', () {
      expect(
        RegisterRules.validate(
          _valid(role: UserRole.coach, grade: null, track: null),
        ),
        isEmpty,
      );
    });

    test('an empty form lists the issues from top to bottom', () {
      final issues = RegisterRules.validate(
        const RegisterFormValues(role: UserRole.student),
      );

      expect(issues.keys.toList(), [
        RegisterField.fullName,
        RegisterField.username,
        RegisterField.email,
        RegisterField.password,
        RegisterField.grade,
        RegisterField.consent,
      ]);
      expect(issues[RegisterField.password], RegisterIssue.passwordTooShort);
      expect(issues[RegisterField.grade], RegisterIssue.gradeMissing);
    });

    test('a password of 7 characters is too short, of 8 is fine', () {
      const short = RegisterFormValues(
        role: UserRole.coach,
        fullName: 'A B',
        username: 'ab',
        email: 'a@b.co',
        password: '1234567',
        passwordRepeat: '1234567',
        consent: true,
      );

      expect(
        RegisterRules.issueOf(RegisterField.password, short),
        RegisterIssue.passwordTooShort,
      );
      expect(
        RegisterRules.issueOf(
          RegisterField.password,
          const RegisterFormValues(
            role: UserRole.coach,
            password: '12345678',
            passwordRepeat: '12345678',
          ),
        ),
        isNull,
      );
    });

    test(
      'different passwords read "Şifreler aynı değil." (pano 2.6 kare 2)',
      () {
        const values = RegisterFormValues(
          role: UserRole.coach,
          password: 'Gizli#2026',
          passwordRepeat: 'Gizli#2027',
          consent: true,
        );

        expect(
          RegisterRules.issueOf(RegisterField.passwordRepeat, values),
          RegisterIssue.passwordMismatch,
        );
      },
    );

    test(
      'grade 11 and up ask for a track; 9 and 10 do not (pano 2.6 kare 4)',
      () {
        expect(
          RegisterRules.issueOf(RegisterField.track, _valid(track: null)),
          RegisterIssue.trackMissing,
        );
        expect(
          RegisterRules.issueOf(
            RegisterField.track,
            _valid(grade: SchoolGrade.grade10, track: null),
          ),
          isNull,
        );
        expect(
          RegisterRules.issueOf(
            RegisterField.track,
            _valid(grade: SchoolGrade.graduate, track: null),
          ),
          RegisterIssue.trackMissing,
        );
      },
    );

    test('a taken user name beats a filled one', () {
      const values = RegisterFormValues(
        role: UserRole.coach,
        username: 'alparslan',
        usernameStatus: UsernameStatus.taken,
      );

      expect(
        RegisterRules.issueOf(RegisterField.username, values),
        RegisterIssue.usernameTaken,
      );
    });

    test('a missing consent is an issue', () {
      expect(
        RegisterRules.issueOf(
          RegisterField.consent,
          const RegisterFormValues(role: UserRole.student),
        ),
        RegisterIssue.consentMissing,
      );
    });
  });

  group('trackFor', () {
    test('keeps the track for grade 11 and up, drops it below', () {
      expect(
        RegisterRules.trackFor(SchoolGrade.grade12, StudyTrack.sayisal),
        StudyTrack.sayisal,
      );
      expect(
        RegisterRules.trackFor(SchoolGrade.grade10, StudyTrack.sayisal),
        isNull,
      );
      expect(RegisterRules.trackFor(null, StudyTrack.sayisal), isNull);
    });
  });
}
