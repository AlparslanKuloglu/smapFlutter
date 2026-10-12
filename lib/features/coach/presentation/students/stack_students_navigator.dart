import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/features/coach/application/student_rows.dart';
import 'package:smap/features/coach/presentation/students/students_navigator.dart';

/// A [StudentsNavigator] on the stack of the page that owns the ViewModel:
/// Öğrenci Profili (pano 10.4) is pushed on the Öğrencilerim tab's own stack,
/// so the bottom bar stays and Back returns to the list (pano 1.19 "sekme
/// başına yığın").
class StackStudentsNavigator implements StudentsNavigator {
  const StackStudentsNavigator(this._router);

  final StackRouter _router;

  @override
  Future<void> openStudent(StudentRowData student) =>
      _router.push(StudentProfileRoute(studentId: student.id));
}
