import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/account/application/coaching_logic.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';

const _mehmet = CoachLink(
  id: 'coach-1',
  name: 'Mehmet Özkan',
  photo: 'avatars/2avatarN3.png',
  code: 'MOZK-4821',
);

void main() {
  group('CoachLink.fromUser', () {
    test('reads the coach of getStudentsCoach', () {
      final link = CoachLink.fromUser(
        const UserDto(
          id: 'coach-1',
          name: 'Mehmet Özkan',
          photo: 'avatars/2avatarN3.png',
          refCode: 'MOZK-4821',
        ),
      );
      expect(link, _mehmet);
    });

    test('falls back to first name and surname', () {
      final link = CoachLink.fromUser(
        const UserDto(id: 'c', firstName: 'Ayşe', surname: 'Demir'),
      );
      expect(link?.name, 'Ayşe Demir');
    });

    test('no id or no name means no coach to draw', () {
      expect(CoachLink.fromUser(null), isNull);
      expect(CoachLink.fromUser(const UserDto(name: 'Adsız Id')), isNull);
      expect(CoachLink.fromUser(const UserDto(id: 'c')), isNull);
      expect(CoachLink.fromUser(const UserDto(id: 'c', name: '  ')), isNull);
    });
  });

  group('CoachingRules.verdict', () {
    test('a complete code is ready', () {
      expect(CoachingRules.verdict('ABCD-1234'), CoachCodeVerdict.ready);
    });

    test('an unfinished code is incomplete', () {
      expect(CoachingRules.verdict(''), CoachCodeVerdict.incomplete);
      expect(CoachingRules.verdict('MOZK-48'), CoachCodeVerdict.incomplete);
    });

    test(
      'the current coach\'s code is recognised with or without the dash',
      () {
        expect(
          CoachingRules.verdict('MOZK-4821', current: _mehmet),
          CoachCodeVerdict.currentCoach,
        );
        expect(
          CoachingRules.verdict('mozk4821', current: _mehmet),
          CoachCodeVerdict.currentCoach,
        );
      },
    );

    test('another code is ready even when the current code is unknown', () {
      expect(
        CoachingRules.verdict('ABCD-1234', current: _mehmet),
        CoachCodeVerdict.ready,
      );
      const unknown = CoachLink(id: 'c', name: 'Ayşe Demir');
      expect(
        CoachingRules.verdict('MOZK-4821', current: unknown),
        CoachCodeVerdict.ready,
      );
    });
  });

  test('isSameCoach compares ids', () {
    expect(CoachingRules.isSameCoach(_mehmet, _mehmet), isTrue);
    expect(
      CoachingRules.isSameCoach(
        _mehmet,
        const CoachLink(id: 'coach-2', name: 'Ayşe Demir'),
      ),
      isFalse,
    );
    expect(CoachingRules.isSameCoach(null, _mehmet), isFalse);
  });

  test('a link result holds a coach or a failure, never both', () {
    const ok = CoachLinkResult.linked(_mehmet);
    expect(ok.coach, _mehmet);
    expect(ok.failure, isNull);
    const bad = CoachLinkResult.failed(CoachLinkFailure.notFound);
    expect(bad.coach, isNull);
    expect(bad.failure, CoachLinkFailure.notFound);
  });
}
