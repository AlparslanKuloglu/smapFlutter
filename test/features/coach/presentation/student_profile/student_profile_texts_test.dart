import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/coach/application/student_profile.dart';
import 'package:smap/features/coach/presentation/student_profile/student_profile_texts.dart';
import 'package:smap/l10n/app_localizations_tr.dart';
import 'package:smap/shared/ui/navigation/student_scope.dart';

/// The lines of pano 10.4: "alparslan.k · 10 deneme", "12. Sınıf · EA".
void main() {
  final l10n = AppLocalizationsTr();

  const alparslan = StudentProfile(
    id: 'stu-alparslan',
    name: 'Alparslan Kuloğlu',
    userName: 'alparslan.k',
    grade: SchoolGrade.grade12,
    track: StudyTrack.esitAgirlik,
    examCount: 10,
    aimType: 2,
  );

  group('meta line', () {
    test('is the login name and the exam count', () {
      expect(
        StudentProfileTexts.meta(l10n, alparslan),
        'alparslan.k · 10 deneme',
      );
    });

    test('leaves out what the document does not have (no made-up count)', () {
      expect(
        StudentProfileTexts.meta(
          l10n,
          const StudentProfile(id: '1', name: 'Ali', userName: 'ali.v'),
        ),
        'ali.v',
      );
      expect(
        StudentProfileTexts.meta(
          l10n,
          const StudentProfile(id: '1', name: 'Ali', examCount: 3),
        ),
        '3 deneme',
      );
      expect(
        StudentProfileTexts.meta(
          l10n,
          const StudentProfile(id: '1', name: 'Ali'),
        ),
        isNull,
      );
    });

    test('writes a big count with the thousands dot', () {
      expect(
        StudentProfileTexts.meta(
          l10n,
          const StudentProfile(id: '1', name: 'Ali', examCount: 1200),
        ),
        '1.200 deneme',
      );
    });
  });

  group('context strip', () {
    test('writes the class and the field short form', () {
      expect(
        StudentProfileTexts.stripDetail(l10n, alparslan),
        '12. Sınıf · EA',
      );
      expect(
        StudentProfileTexts.stripDetailSemantics(l10n, alparslan),
        '12. Sınıf, Eşit Ağırlık',
      );
    });

    test('knows the four field short forms', () {
      String detail(StudyTrack track) => StudentProfileTexts.stripDetail(
        l10n,
        StudentProfile(
          id: '1',
          name: 'Ali',
          grade: SchoolGrade.grade11,
          track: track,
        ),
      )!;

      expect(detail(StudyTrack.sayisal), '11. Sınıf · SAY');
      expect(detail(StudyTrack.esitAgirlik), '11. Sınıf · EA');
      expect(detail(StudyTrack.sozel), '11. Sınıf · SÖZ');
      expect(detail(StudyTrack.dil), '11. Sınıf · DİL');
    });

    test('a 9th grader has the class alone, "Mezun" is a class too', () {
      expect(
        StudentProfileTexts.stripDetail(
          l10n,
          const StudentProfile(id: '1', name: 'Ali', grade: SchoolGrade.grade9),
        ),
        '9. Sınıf',
      );
      expect(
        StudentProfileTexts.stripDetail(
          l10n,
          const StudentProfile(
            id: '1',
            name: 'Ali',
            grade: SchoolGrade.graduate,
            track: StudyTrack.sayisal,
          ),
        ),
        'Mezun · SAY',
      );
    });

    test('has nothing to say without a class and a field', () {
      const bare = StudentProfile(id: '1', name: 'Ali');

      expect(StudentProfileTexts.stripDetail(l10n, bare), isNull);
      expect(StudentProfileTexts.stripDetailSemantics(l10n, bare), isNull);
    });
  });

  group('the reference every student screen carries', () {
    test('has the id, the name, the strip texts and the field number', () {
      final ref = StudentProfileTexts.ref(l10n, alparslan);

      expect(ref.id, 'stu-alparslan');
      expect(ref.name, 'Alparslan Kuloğlu');
      expect(ref.detail, '12. Sınıf · EA');
      expect(ref.detailSemantics, '12. Sınıf, Eşit Ağırlık');
      expect(ref.aimType, 2);
      expect(ref.avatar, isNull);
      expect(ref.firstName, 'Alparslan');
    });

    test('has the avatar when the student has a picture', () {
      final ref = StudentProfileTexts.ref(
        l10n,
        const StudentProfile(
          id: '1',
          name: 'Ali',
          photo: 'avatars/1avatarN3.png',
        ),
      );

      expect(ref.avatar, isNotNull);
    });
  });

  group('StudentRef.firstName', () {
    test('drops the last word', () {
      expect(
        const StudentRef(id: '1', name: 'Alparslan Kuloğlu').firstName,
        'Alparslan',
      );
      expect(
        const StudentRef(id: '1', name: 'Ayşe Nur Kaya').firstName,
        'Ayşe Nur',
      );
    });

    test('keeps a single word and survives an empty name', () {
      expect(
        const StudentRef(id: '1', name: 'Alparslan').firstName,
        'Alparslan',
      );
      expect(const StudentRef(id: '1', name: '').firstName, '');
      expect(
        const StudentRef(id: '1', name: '  Elif   Şahin ').firstName,
        'Elif',
      );
    });
  });
}
