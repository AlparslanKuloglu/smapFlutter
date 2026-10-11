import 'package:flutter/widgets.dart';

/// The student a coach is looking at: id for the repository calls, name and
/// picture for the context strip (C85; board 10.4).
@immutable
class StudentRef {
  const StudentRef({required this.id, required this.name, this.avatar});

  /// Backend id; every repository call of a coach screen carries it.
  final String id;

  /// Full name ("Alparslan Kuloğlu").
  final String name;

  /// The student's picture; initials show when null.
  final ImageProvider? avatar;

  @override
  bool operator ==(Object other) =>
      other is StudentRef &&
      other.id == id &&
      other.name == name &&
      other.avatar == avatar;

  @override
  int get hashCode => Object.hash(id, name, avatar);
}

/// Tells the student screens under it whose data they show (C85 "Tur 9").
///
/// Wrap the subtree of a coach's student view in `StudentScope(student: ...)`.
/// Without a scope, or with a null [student], the screens show the signed-in
/// student's own data. With one, the screen is in coach view: it shows the
/// `AppContextStrip`, hides the edit actions and student-only items (favorite
/// star, "Öğrendim", "Günü Sıfırla", "Düzenle", "Yeni Program") and passes
/// [studentIdOf] to the repositories.
///
/// ```dart
/// final student = StudentScope.studentOf(context);
/// if (StudentScope.isCoachView(context)) ...
/// ```
class StudentScope extends InheritedWidget {
  const StudentScope({required this.student, required super.child, super.key});

  /// The student being viewed; null means the user's own data.
  final StudentRef? student;

  /// The scope's student, null outside a scope. Rebuilds when it changes.
  static StudentRef? studentOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<StudentScope>()?.student;

  /// Whether the screen shows a student's data to a coach.
  static bool isCoachView(BuildContext context) => studentOf(context) != null;

  /// The id to pass to repository calls; null for the user's own data.
  static String? studentIdOf(BuildContext context) => studentOf(context)?.id;

  @override
  bool updateShouldNotify(StudentScope oldWidget) =>
      oldWidget.student != student;
}
