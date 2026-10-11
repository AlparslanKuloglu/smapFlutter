import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/account/domain/coach_code.dart';
import 'package:smap/features/account/domain/profile_update.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';

void main() {
  group('SchoolGrade', () {
    test('maps the registration form codes', () {
      expect(SchoolGrade.fromCode(9), SchoolGrade.grade9);
      expect(SchoolGrade.fromCode(10), SchoolGrade.grade10);
      expect(SchoolGrade.fromCode(11), SchoolGrade.grade11);
      expect(SchoolGrade.fromCode(12), SchoolGrade.grade12);
      expect(SchoolGrade.fromCode(13), SchoolGrade.graduate);
      expect(SchoolGrade.graduate.code, 13);
    });

    test('unknown or missing codes are null', () {
      expect(SchoolGrade.fromCode(null), isNull);
      expect(SchoolGrade.fromCode(0), isNull);
      expect(SchoolGrade.fromCode(8), isNull);
      expect(SchoolGrade.fromCode(14), isNull);
    });

    test('a track is asked from the 11th grade on', () {
      expect(SchoolGrade.grade9.requiresTrack, isFalse);
      expect(SchoolGrade.grade10.requiresTrack, isFalse);
      expect(SchoolGrade.grade11.requiresTrack, isTrue);
      expect(SchoolGrade.grade12.requiresTrack, isTrue);
      expect(SchoolGrade.graduate.requiresTrack, isTrue);
      expect(SchoolGrade.graduate.isSchoolYear, isFalse);
    });

    test('codes are unique', () {
      final codes = SchoolGrade.values.map((g) => g.code).toSet();
      expect(codes, hasLength(SchoolGrade.values.length));
    });
  });

  group('StudyTrack', () {
    test(
      'follows the registration form and the readers: EA 2, Sayısal 3, Sözel 4',
      () {
        expect(StudyTrack.esitAgirlik.code, 2);
        expect(StudyTrack.sayisal.code, 3);
        expect(StudyTrack.sozel.code, 4);
        expect(StudyTrack.fromCode(2), StudyTrack.esitAgirlik);
        expect(StudyTrack.fromCode(3), StudyTrack.sayisal);
        expect(StudyTrack.fromCode(4), StudyTrack.sozel);
      },
    );

    test('0, 1, unknown and missing are no track', () {
      for (final code in [null, 0, 1, 5, 99]) {
        expect(StudyTrack.fromCode(code), isNull);
      }
    });

    test('Dil has no confirmed code and is not selectable', () {
      expect(StudyTrack.dil.code, isNull);
      expect(StudyTrack.dil.isConfirmed, isFalse);
      expect(StudyTrack.selectable, isNot(contains(StudyTrack.dil)));
      expect(StudyTrack.selectable.every((t) => t.isConfirmed), isTrue);
      expect(StudyTrack.selectable, [
        StudyTrack.sayisal,
        StudyTrack.esitAgirlik,
        StudyTrack.sozel,
      ]);
    });
  });

  group('CoachCode', () {
    test('reads AAAA-0000 in the forms people type', () {
      for (final input in [
        'ABCD-1234',
        'abcd-1234',
        'ABCD1234',
        ' ab cd 1234 ',
      ]) {
        expect(CoachCode.tryParse(input)?.display, 'ABCD-1234', reason: input);
      }
      expect(CoachCode.tryParse('ABCD-1234')?.compact, 'ABCD1234');
    });

    test('rejects other shapes', () {
      for (final input in [
        null,
        '',
        'ABC-1234',
        'ABCDE-1234',
        'ABCD-123',
        'ABCD-12345',
        '1234-ABCD',
        'ABCD--1234',
        'ÇĞİŞ-1234',
      ]) {
        expect(CoachCode.tryParse(input), isNull, reason: '$input');
        expect(CoachCode.isValid(input), isFalse);
      }
    });

    test('is a value', () {
      expect(CoachCode.tryParse('abcd1234'), CoachCode.tryParse('ABCD-1234'));
      expect('${CoachCode.tryParse('abcd1234')}', 'ABCD-1234');
    });
  });

  group('ProfileUpdate', () {
    test('sends only what is set', () {
      expect(const ProfileUpdate().toBody(), isEmpty);
      expect(const ProfileUpdate().isEmpty, isTrue);
      expect(const ProfileUpdate(phone: '555').toBody(), {'phone': '555'});
    });

    test('writes every field under the backend names', () {
      const update = ProfileUpdate(
        name: 'Ayşe Yılmaz',
        email: 'ayse@example.com',
        phone: '5551112233',
        country: 'Türkiye',
        city: 'İzmir',
        photo: 'avatars/3avatarN3.png',
        grade: SchoolGrade.graduate,
        track: StudyTrack.sozel,
      );

      expect(update.toBody(), {
        'name': 'Ayşe Yılmaz',
        'email': 'ayse@example.com',
        'phone': '5551112233',
        'country': 'Türkiye',
        'city': 'İzmir',
        'photo': '3avatarN3.png',
        'seasonType': 13,
        'aimType': 4,
      });
    });

    test('leaves out a track without a code and a blank photo', () {
      const update = ProfileUpdate(track: StudyTrack.dil, photo: '  ');

      expect(update.toBody(), isEmpty);
      expect(update.isEmpty, isTrue);
    });
  });
}
