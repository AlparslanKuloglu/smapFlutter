import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/coach/application/student_rows.dart';
import 'package:smap/features/coach/data/dtos/coach_student_dto.dart';

import '../coach_fixtures.dart';

CoachStudentDto _student({
  String id = 's1',
  String name = 'Zeynep',
  String? surname = 'Kaya',
  Object? seasonType = 12,
  Object? aimType = 2,
  Object? totalMexam = 0,
}) => CoachStudentDto.fromJson(
  studentJson(
    id: id,
    name: name,
    surname: surname,
    seasonType: seasonType,
    aimType: aimType,
    totalMexam: totalMexam,
  ),
);

/// The five students of the design (Ek C; pano 10.2 kare 1), in server order.
List<CoachStudentDto> _board() => [
  _student(id: 's5', name: 'Zeynep', surname: 'Kaya'),
  _student(id: 's1', name: 'Alparslan', surname: 'Kuloğlu', totalMexam: 10),
  _student(
    id: 's4',
    name: 'Mert',
    surname: 'Yıldız',
    seasonType: 10,
    aimType: 0,
  ),
  _student(
    id: 's3',
    name: 'Kerem',
    surname: 'Aydın',
    seasonType: 13,
    aimType: 4,
  ),
  _student(
    id: 's2',
    name: 'Elif',
    surname: 'Şahin',
    seasonType: 11,
    aimType: 3,
  ),
];

void main() {
  group('fullName', () {
    test('a student the coach added: first name and surname', () {
      expect(StudentRows.fullName(_student()), 'Zeynep Kaya');
    });

    test('a self-registered student carries the whole name in "name"', () {
      const student = CoachStudentDto(name: 'Ayşe Demir', userName: 'ayse');
      expect(StudentRows.fullName(student), 'Ayşe Demir');
    });

    test('a surname that "name" already ends with is not written twice', () {
      const student = CoachStudentDto(name: 'Ayşe DEMİR', surname: 'Demir');
      expect(StudentRows.fullName(student), 'Ayşe DEMİR');
    });

    test('falls back to the first name, the surname, then the login', () {
      expect(
        StudentRows.fullName(const CoachStudentDto(firstName: 'Can')),
        'Can',
      );
      expect(
        StudentRows.fullName(const CoachStudentDto(surname: 'Kaya')),
        'Kaya',
      );
      expect(
        StudentRows.fullName(const CoachStudentDto(userName: 'can.k')),
        'can.k',
      );
      expect(StudentRows.fullName(const CoachStudentDto(name: '  ')), isNull);
    });
  });

  group('build (pano 10.2 kare 1)', () {
    final rows = StudentRows.build(_board());

    test('is alphabetical, in the Turkish alphabet', () {
      expect(rows.map((r) => r.name), [
        'Alparslan Kuloğlu',
        'Elif Şahin',
        'Kerem Aydın',
        'Mert Yıldız',
        'Zeynep Kaya',
      ]);
    });

    test('Ç, Ş, İ and I fall where the Turkish alphabet puts them', () {
      final sorted = StudentRows.build([
        _student(id: '1', name: 'Işık', surname: 'A'),
        _student(id: '2', name: 'İpek', surname: 'A'),
        _student(id: '3', name: 'Cem', surname: 'A'),
        _student(id: '4', name: 'Çağla', surname: 'A'),
        _student(id: '5', name: 'Şule', surname: 'A'),
        _student(id: '6', name: 'Sevgi', surname: 'A'),
      ]);
      expect(sorted.map((r) => r.id), ['3', '4', '1', '2', '6', '5']);
    });

    test('the grade and the track are what the server said', () {
      final alparslan = rows.first;
      expect(alparslan.grade, SchoolGrade.grade12);
      expect(alparslan.track, StudyTrack.esitAgirlik);
      expect(rows[1].grade, SchoolGrade.grade11);
      expect(rows[1].track, StudyTrack.sayisal);
      expect(rows[2].grade, SchoolGrade.graduate);
      expect(rows[2].track, StudyTrack.sozel);
    });

    test('the 10th grade has no track (Mert Yıldız: "10. Sınıf")', () {
      final mert = rows.firstWhere((r) => r.name == 'Mert Yıldız');
      expect(mert.grade, SchoolGrade.grade10);
      expect(mert.track, isNull);
    });

    test('a 10th grader with a stale track code still has no track', () {
      final row = StudentRows.build([_student(seasonType: 10, aimType: 2)]);
      expect(row.single.track, isNull);
    });

    test('the exam count is there only when the student read an exam', () {
      expect(rows.first.examCount, 10);
      expect(rows.skip(1).every((r) => r.examCount == null), isTrue);
    });

    test('the avatar is the file the server holds', () {
      expect(rows.first.photo, 'avatars/1avatarN3.png');
    });

    test('leaves out a student without an id or a name', () {
      final built = StudentRows.build([
        const CoachStudentDto(name: 'Idsiz'),
        const CoachStudentDto(id: 'x'),
        _student(id: 'ok'),
      ]);
      expect(built.map((r) => r.id), ['ok']);
    });

    test('equal names keep the server order', () {
      final built = StudentRows.build([
        _student(id: '1'),
        _student(id: '2'),
        _student(id: '3'),
      ]);
      expect(built.map((r) => r.id), ['1', '2', '3']);
    });

    test('rows are equal by content', () {
      expect(StudentRows.build(_board()), rows);
    });
  });

  group('search (pano 10.2 kare 2 and 3)', () {
    final rows = StudentRows.build(_board());

    List<String> find(String query) =>
        StudentRows.search(rows, query).map((r) => r.name).toList();

    test('"aydin" finds "Kerem Aydın"; so do "AYDIN" and "aydın"', () {
      expect(find('aydin'), ['Kerem Aydın']);
      expect(find('AYDIN'), ['Kerem Aydın']);
      expect(find('aydın'), ['Kerem Aydın']);
      expect(find('AYDİN'), ['Kerem Aydın']);
    });

    test('I, ı, İ and i are not told apart', () {
      expect(find('ISIK'), isEmpty);
      final row = StudentRows.build([
        _student(id: '1', name: 'Işık', surname: 'Yalçın'),
        _student(id: '2', name: 'İlker', surname: 'Işıldak'),
      ]);
      List<String> names(String q) =>
          StudentRows.search(row, q).map((r) => r.id).toList();
      expect(names('isik'), ['1']);
      expect(names('ILKER'), ['2']);
      expect(names('ısıl'), ['2']);
      expect(names('işık'), ['1']);
    });

    test('name and surname are searched together ("kerem a")', () {
      expect(find('kerem a'), ['Kerem Aydın']);
      expect(find('a kerem'), ['Kerem Aydın']);
      expect(find('kaya zey'), ['Zeynep Kaya']);
    });

    test('a query matches the start of a word, not its middle', () {
      expect(find('ydin'), isEmpty);
      expect(find('zeyn'), ['Zeynep Kaya']);
    });

    test('"selin" matches nobody (kare 3)', () {
      expect(find('selin'), isEmpty);
    });

    test('a blank query keeps everyone, in order', () {
      expect(find('  '), hasLength(5));
      expect(find(''), rows.map((r) => r.name));
    });

    test('searches the name only, not the login', () {
      final row = StudentRows.build([
        CoachStudentDto.fromJson(studentJson(name: 'Zeynep', surname: 'Kaya')),
      ]);
      expect(StudentRows.search(row, 'zeynep.kaya'), isEmpty);
    });
  });
}
