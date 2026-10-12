import 'package:smap/features/coach/application/student_rows.dart';

/// Where the student list leads (pano 13.11): the ViewModel calls this, not a
/// router, so a test can record the calls.
abstract interface class StudentsNavigator {
  /// A student was tapped: Öğrenci Profili (E17, pano 10.4) of that student.
  Future<void> openStudent(StudentRowData student);
}
