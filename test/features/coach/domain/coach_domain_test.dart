import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/coach/domain/interview_filter.dart';
import 'package:smap/features/coach/domain/interview_type.dart';
import 'package:smap/features/coach/domain/new_student.dart';

void main() {
  group('InterviewType', () {
    test('codes follow the legacy screens', () {
      expect(InterviewType.student.code, 1);
      expect(InterviewType.parent.code, 2);
      expect(InterviewType.fromCode(1), InterviewType.student);
      expect(InterviewType.fromCode(2), InterviewType.parent);
      expect(InterviewType.fromCode(0), isNull);
      expect(InterviewType.fromCode(null), isNull);
    });
  });

  group('InterviewFilter', () {
    test('no filter sends empty lists, like the legacy call', () {
      const filter = InterviewFilter();

      expect(filter.isEmpty, isTrue);
      expect(filter.toBody(), {'types': <int>[], 'dates': <String>[]});
    });

    test('types go as numbers and days as yyyy-MM-dd', () {
      final filter = InterviewFilter(
        types: const [InterviewType.parent],
        dates: [DateTime(2026, 6, 28, 15, 45), DateTime(2027, 1, 5)],
      );

      expect(filter.isEmpty, isFalse);
      expect(filter.toBody(), {
        'types': [2],
        'dates': ['2026-06-28', '2027-01-05'],
      });
    });

    test('equality is by value', () {
      expect(
        const InterviewFilter(types: [InterviewType.student]),
        const InterviewFilter(types: [InterviewType.student]),
      );
      expect(
        const InterviewFilter(types: [InterviewType.student]),
        isNot(const InterviewFilter()),
      );
    });
  });

  group('NewStudent', () {
    const student = NewStudent(
      firstName: ' Zeynep ',
      lastName: 'Kaya ',
      userName: ' zeynep.kaya ',
      password: 'Gizli#2026',
      grade: SchoolGrade.grade12,
      track: StudyTrack.esitAgirlik,
      photo: 'assets/avatars/3avatarN3.png',
    );

    test('writes the dataObj the legacy dialog wrote', () {
      expect(student.toDataObj(), {
        'name': 'Zeynep',
        'surname': 'Kaya',
        'userName': 'zeynep.kaya',
        'password': 'Gizli#2026',
        'seasonType': 12,
        'aimType': 2,
        'photo': '3avatarN3.png',
      });
    });

    test('leaves out a track and an avatar that are not set', () {
      const bare = NewStudent(
        firstName: 'A',
        lastName: 'B',
        userName: 'ab',
        password: 'x',
        grade: SchoolGrade.grade9,
        track: StudyTrack.dil,
        photo: ' ',
      );

      final data = bare.toDataObj();

      expect(data.containsKey('aimType'), isFalse);
      expect(data.containsKey('photo'), isFalse);
      expect(data['seasonType'], 9);
    });

    test('never prints the password', () {
      expect(student.toString(), isNot(contains('Gizli')));
      expect(student.toString(), contains('zeynep.kaya'));
    });

    test('a graduate is sent as 13', () {
      const graduate = NewStudent(
        firstName: 'A',
        lastName: 'B',
        userName: 'ab',
        password: 'x',
        grade: SchoolGrade.graduate,
      );

      expect(graduate.toDataObj()['seasonType'], 13);
    });
  });
}
