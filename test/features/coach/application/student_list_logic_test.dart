import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/coach/application/student_list_logic.dart';
import 'package:smap/features/coach/data/dtos/coach_student_dto.dart';

CoachStudentDto _s(String id, String? name, {String? userName}) =>
    CoachStudentDto(id: id, name: name, userName: userName);

void main() {
  group('sortStudentsByName', () {
    test('uses the Turkish alphabet', () {
      final sorted = sortStudentsByName([
        _s('1', 'Işık'),
        _s('2', 'İpek'),
        _s('3', 'Cem'),
        _s('4', 'Çağla'),
        _s('5', 'Ali'),
        _s('6', 'Şule'),
        _s('7', 'Sevgi'),
      ]);

      expect(sorted.map((s) => s.name), [
        'Ali',
        'Cem',
        'Çağla',
        'Işık',
        'İpek',
        'Sevgi',
        'Şule',
      ]);
    });

    test('ignores case and keeps ties in their order', () {
      final sorted = sortStudentsByName([
        _s('1', 'ayşe'),
        _s('2', 'Ayşe'),
        _s('3', 'AYŞE'),
      ]);

      expect(sorted.map((s) => s.id), ['1', '2', '3']);
    });

    test('students without any name go last in their original order', () {
      final sorted = sortStudentsByName([
        _s('1', null),
        _s('2', 'Zeki'),
        _s('3', null),
        _s('4', 'Ali'),
      ]);

      expect(sorted.map((s) => s.id), ['4', '2', '1', '3']);
    });

    test('does not change its input', () {
      final input = [_s('1', 'Zeki'), _s('2', 'Ali')];

      sortStudentsByName(input);

      expect(input.map((s) => s.id), ['1', '2']);
    });
  });

  group('searchStudents', () {
    final students = [
      _s('1', 'Zeynep Kaya', userName: 'zeynep.kaya'),
      _s('2', 'Çağla Özkan'),
      _s('3', 'Mehmet Özkan'),
      _s('4', null, userName: 'ghost'),
    ];

    test('a blank query keeps everyone', () {
      expect(searchStudents(students, '  '), hasLength(4));
    });

    test('every word of the query starts some word of the name', () {
      expect(searchStudents(students, 'zey ka').map((s) => s.id), ['1']);
      expect(searchStudents(students, 'kaya zeynep').map((s) => s.id), ['1']);
    });

    test('ignores case and Turkish marks', () {
      expect(searchStudents(students, 'cagla').map((s) => s.id), ['2']);
      expect(searchStudents(students, 'OZKAN').map((s) => s.id), ['2', '3']);
      expect(searchStudents(students, 'çAĞLA').map((s) => s.id), ['2']);
    });

    test('also finds by login name', () {
      expect(searchStudents(students, 'ghost').map((s) => s.id), ['4']);
    });

    test('finds nothing for an unknown name', () {
      expect(searchStudents(students, 'xyz'), isEmpty);
    });
  });
}
