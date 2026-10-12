import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/account/application/profile_draft.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';

/// The student of the design's Hesap and Profil boards.
const UserDto _alparslan = UserDto(
  id: 'student-1',
  name: 'Alparslan Kuloğlu',
  userName: 'alparslan.k',
  email: 'alparslan@ornek.com',
  phone: '05321234567',
  role: 'student',
  seasonType: 12,
  aimType: 2,
  photo: 'avatars/1avatarN3.png',
);

void main() {
  late ProfileDraft original;

  setUp(() => original = ProfileDraft.fromUser(_alparslan));

  group('fromUser', () {
    test('reads the account into the form', () {
      expect(original.name, 'Alparslan Kuloğlu');
      expect(original.email, 'alparslan@ornek.com');
      expect(original.phone, '532 123 45 67');
      expect(original.grade, SchoolGrade.grade12);
      expect(original.track, StudyTrack.esitAgirlik);
      expect(original.photo, 'avatars/1avatarN3.png');
      expect(original.avatarIndex, 0);
      expect(original.hasTrackField, isTrue);
    });

    test('joins first name and surname when there is no name', () {
      final draft = ProfileDraft.fromUser(
        const UserDto(firstName: ' Mehmet ', surname: 'Özkan', userName: 'm'),
      );

      expect(draft.name, 'Mehmet Özkan');
    });

    test('does not offer the login name as a display name', () {
      expect(
        ProfileDraft.fromUser(const UserDto(userName: 'm.ozkan')).name,
        '',
      );
    });

    test('a grade without a track drops the stored track', () {
      final draft = ProfileDraft.fromUser(
        const UserDto(seasonType: 10, aimType: 3),
      );

      expect(draft.grade, SchoolGrade.grade10);
      expect(draft.track, isNull);
      expect(draft.hasTrackField, isFalse);
    });

    test('a coach has neither grade nor track', () {
      final draft = ProfileDraft.fromUser(
        const UserDto(name: 'Mehmet Özkan', role: 'coach'),
      );

      expect(draft.grade, isNull);
      expect(draft.track, isNull);
    });
  });

  group('changes', () {
    test('an untouched form changes nothing', () {
      expect(original.hasChanges(original), isFalse);
      expect(original.toUpdate(original), isNull);
    });

    test('only the changed fields are sent, text trimmed', () {
      final draft = original.copyWith(
        name: '  Alparslan K.  ',
        email: 'yeni@ornek.com ',
      );

      expect(draft.toUpdate(original)!.toBody(), {
        'name': 'Alparslan K.',
        'email': 'yeni@ornek.com',
      });
    });

    test('a phone number goes out with the prefix, whatever the old form', () {
      final draft = original.copyWith(phone: '532 999 88 77');

      expect(draft.toUpdate(original)!.toBody(), {
        'phone': '+90 532 999 88 77',
      });
    });

    test('the same phone number in another form is not a change', () {
      final draft = original.copyWith(phone: '5321234567');

      expect(draft.hasChanges(original), isFalse);
    });

    test('an emptied phone number is sent as empty text', () {
      final draft = original.copyWith(phone: '');

      expect(draft.toUpdate(original)!.toBody(), {'phone': ''});
    });

    test('the avatar is sent as its file name', () {
      final draft = original.copyWith(photo: '3avatarN3.png');

      expect(draft.toUpdate(original)!.toBody(), {'photo': '3avatarN3.png'});
    });

    test('choosing the avatar already in use is not a change', () {
      final draft = original.copyWith(photo: '1avatarN3.png');

      expect(draft.hasChanges(original), isFalse);
    });

    test('grade and track are sent with their codes', () {
      final draft = original
          .withGrade(SchoolGrade.graduate)
          .withTrack(StudyTrack.sayisal);

      expect(draft.toUpdate(original)!.toBody(), {
        'seasonType': 13,
        'aimType': 3,
      });
    });
  });

  group('the track follows the grade', () {
    test('a grade without a track takes the track away', () {
      final draft = original.withGrade(SchoolGrade.grade10);

      expect(draft.grade, SchoolGrade.grade10);
      expect(draft.track, isNull);
      expect(draft.hasTrackField, isFalse);
    });

    test('only the grade is sent: the backend cannot clear a track', () {
      final draft = original.withGrade(SchoolGrade.grade10);

      expect(draft.toUpdate(original)!.toBody(), {'seasonType': 10});
    });

    test('a grade with a track keeps the chosen one', () {
      final draft = original.withGrade(SchoolGrade.grade11);

      expect(draft.track, StudyTrack.esitAgirlik);
    });
  });

  group('issuesAgainst', () {
    test('a clean form has none', () {
      expect(original.issuesAgainst(original), isEmpty);
    });

    test('an emptied name and a broken e-mail are issues', () {
      final draft = original.copyWith(name: '   ', email: 'alparslan@');

      expect(draft.issuesAgainst(original), {
        ProfileIssue.nameMissing,
        ProfileIssue.emailInvalid,
      });
    });

    test('an unfinished phone number is an issue, an empty one is not', () {
      expect(original.copyWith(phone: '532 12').issuesAgainst(original), {
        ProfileIssue.phoneInvalid,
      });
      expect(original.copyWith(phone: '').issuesAgainst(original), isEmpty);
    });

    test('a field that was not touched is never checked', () {
      // An old account with an e-mail the form would call invalid.
      final old = ProfileDraft.fromUser(
        const UserDto(name: 'Ayşe', email: 'ayse@', phone: '12345'),
      );
      final draft = old.copyWith(photo: '3avatarN3.png');

      expect(draft.issuesAgainst(old), isEmpty);
      expect(draft.toUpdate(old)!.toBody(), {'photo': '3avatarN3.png'});
    });
  });

  group('applied', () {
    test('puts what was sent on the account', () {
      final draft = original
          .copyWith(name: 'Alparslan K.', phone: '532 999 88 77')
          .withGrade(SchoolGrade.grade11)
          .copyWith(photo: '3avatarN3.png');

      final user = ProfileDraft.applied(_alparslan, draft.toUpdate(original)!);

      expect(user.name, 'Alparslan K.');
      expect(user.phone, '+90 532 999 88 77');
      expect(user.seasonType, 11);
      expect(user.photo, '3avatarN3.png');
      expect(user.userName, 'alparslan.k');
      expect(user.email, 'alparslan@ornek.com');
    });
  });

  test('drafts are equal by value', () {
    expect(ProfileDraft.fromUser(_alparslan), original);
    expect(original.copyWith(name: 'X'), isNot(original));
    expect(original.hashCode, ProfileDraft.fromUser(_alparslan).hashCode);
  });
}
