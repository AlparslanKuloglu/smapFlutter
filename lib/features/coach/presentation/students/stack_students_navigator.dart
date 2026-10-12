import 'package:auto_route/auto_route.dart';

import 'package:smap/features/coach/application/student_rows.dart';
import 'package:smap/features/coach/presentation/students/students_navigator.dart';
import 'package:smap/features/legacy/legacy_links_e16.dart';

/// A [StudentsNavigator] on the stack of the page that owns the ViewModel:
/// the student's screens are pushed on the Öğrencilerim tab's own stack, so
/// the bottom bar stays and Back walks it (pano 1.19 "sekme başına yığın").
///
/// Until E17's `StudentProfileRoute(studentId:)` exists, a student opens the
/// coach's legacy analysis screen (`openLegacyStudentProfile`); the
/// integration replaces the one call with
/// `_router.push(StudentProfileRoute(studentId: student.id))` and deletes
/// `legacy_links_e16.dart`.
class StackStudentsNavigator implements StudentsNavigator {
  const StackStudentsNavigator(this._router);

  final StackRouter _router;

  @override
  Future<void> openStudent(StudentRowData student) => openLegacyStudentProfile(
    _router.navigatorKey.currentState,
    studentId: student.id,
    studentName: student.name,
    photo: student.photo,
  );
}
