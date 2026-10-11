import 'package:smap/core/utils/turkish_text.dart';
import 'package:smap/features/coach/data/dtos/coach_student_dto.dart';

/// Pure list logic of the coach's student list (spec §6.2 9.3).

/// The students in Turkish alphabetical order of their display name
/// ("Çağla" after "Cem", "Işık" before "İpek"); students without any name go
/// last, in their original order. A new list; [students] is not changed.
List<CoachStudentDto> sortStudentsByName(Iterable<CoachStudentDto> students) {
  final indexed = students.toList().asMap().entries.toList();
  indexed.sort((a, b) {
    final left = a.value.displayName;
    final right = b.value.displayName;
    if (left == null && right == null) return a.key.compareTo(b.key);
    if (left == null) return 1;
    if (right == null) return -1;
    final byName = TurkishText.compare(left, right);
    return byName != 0 ? byName : a.key.compareTo(b.key);
  });
  return [for (final entry in indexed) entry.value];
}

/// The students whose name matches [query]: every word of the query starts
/// some word of the name, in any order, ignoring case and Turkish marks
/// ("zey ka" finds "Zeynep Kaya"). A blank query keeps everyone. The order of
/// [students] is kept.
List<CoachStudentDto> searchStudents(
  Iterable<CoachStudentDto> students,
  String query,
) {
  if (query.trim().isEmpty) return students.toList();
  return [
    for (final student in students)
      if (_matches(student, query)) student,
  ];
}

bool _matches(CoachStudentDto student, String query) {
  final name = student.displayName;
  if (name != null && TurkishText.matchesTokens(name, query)) return true;
  final login = student.userName;
  return login != null && TurkishText.matchesTokens(login, query);
}
