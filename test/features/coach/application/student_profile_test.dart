import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/coach/application/student_profile.dart';
import 'package:smap/features/coach/data/dtos/coach_student_dto.dart';

import '../coach_fixtures.dart';

/// Alparslan Kuloğlu of pano 10.4: "12. Sınıf · EA", "alparslan.k · 10
/// deneme".
void main() {
  CoachStudentDto alparslan({
    Object? seasonType = 12,
    Object? aimType = 2,
    Object? totalMexam = 10,
    String? surname = 'Kuloğlu',
  }) => CoachStudentDto.fromJson(
    studentJson(
      id: 'stu-alparslan',
      name: 'Alparslan',
      surname: surname,
      seasonType: seasonType,
      aimType: aimType,
      totalMexam: totalMexam,
    )..['userName'] = 'alparslan.k',
  );

  group('StudentProfile.of', () {
    test('reads the facts of the student document', () {
      final profile = StudentProfile.of(alparslan())!;

      expect(profile.id, 'stu-alparslan');
      expect(profile.name, 'Alparslan Kuloğlu');
      expect(profile.userName, 'alparslan.k');
      expect(profile.photo, 'avatars/1avatarN3.png');
      expect(profile.grade, SchoolGrade.grade12);
      expect(profile.track, StudyTrack.esitAgirlik);
      expect(profile.examCount, 10);
      expect(profile.aimType, 2);
    });

    test('a 9th grader has no track, whatever the document says', () {
      final profile = StudentProfile.of(alparslan(seasonType: 9, aimType: 2))!;

      expect(profile.grade, SchoolGrade.grade9);
      expect(profile.track, isNull);
    });

    test('a student who read no exam has no count (never "0 deneme")', () {
      expect(StudentProfile.of(alparslan(totalMexam: 0))!.examCount, isNull);
      expect(StudentProfile.of(alparslan(totalMexam: null))!.examCount, isNull);
    });

    test('a student without an id or a name cannot be opened', () {
      expect(StudentProfile.of(const CoachStudentDto()), isNull);
      expect(StudentProfile.of(const CoachStudentDto(id: 'x')), isNull);
      expect(
        StudentProfile.of(const CoachStudentDto(firstName: 'Ali')),
        isNull,
      );
    });

    test('a student who registered alone keeps the whole name', () {
      final profile = StudentProfile.of(alparslan(surname: null)..toString())!;

      expect(profile.name, 'Alparslan');
    });

    test('has value equality', () {
      expect(StudentProfile.of(alparslan()), StudentProfile.of(alparslan()));
      expect(
        StudentProfile.of(alparslan()) ==
            StudentProfile.of(alparslan(totalMexam: 11)),
        isFalse,
      );
    });
  });

  group('StudentProfileTab.parse', () {
    test('reads the three tabs of the route', () {
      expect(StudentProfileTab.parse('analysis'), StudentProfileTab.analysis);
      expect(StudentProfileTab.parse('exams'), StudentProfileTab.exams);
      expect(StudentProfileTab.parse('program'), StudentProfileTab.program);
    });

    test('anything else opens Analiz', () {
      expect(StudentProfileTab.parse(null), StudentProfileTab.analysis);
      expect(StudentProfileTab.parse('programs'), StudentProfileTab.analysis);
    });
  });
}
