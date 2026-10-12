import 'package:flutter/widgets.dart';

/// The student a coach is looking at: id for the repository calls, name and
/// picture for the context strip (C85; board 10.4).
///
/// [detail] and [detailSemantics] are the class and field the strip writes on
/// its right ("12. Sınıf · EA", "12. Sınıf, Eşit Ağırlık"); the screen that
/// opens the student composes them (the kit has no Turkish words for grades).
/// [aimType] is the student's field as the backend's number, for the screens
/// that pick a score by field (the AYT score of an exam); null when unknown.
@immutable
class StudentRef {
  const StudentRef({
    required this.id,
    required this.name,
    this.avatar,
    this.detail,
    this.detailSemantics,
    this.aimType,
  });

  /// Backend id; every repository call of a coach screen carries it.
  final String id;

  /// Full name ("Alparslan Kuloğlu").
  final String name;

  /// The student's picture; initials show when null.
  final ImageProvider? avatar;

  /// The visible class and field, "12. Sınıf · EA"; the strip leaves the
  /// right side empty when null.
  final String? detail;

  /// The spoken form of [detail], "12. Sınıf, Eşit Ağırlık".
  final String? detailSemantics;

  /// The student's study field as the backend's `aimType`; null when unknown.
  final int? aimType;

  /// The name without its last word, the part the coach calls the student by
  /// ("Alparslan Kuloğlu" → "Alparslan", "Ayşe Nur Kaya" → "Ayşe Nur"); a
  /// single word is kept whole.
  String get firstName {
    final words = name.trim().split(RegExp(r'\s+'));
    return words.length < 2
        ? words.first
        : words.sublist(0, words.length - 1).join(' ');
  }

  @override
  bool operator ==(Object other) =>
      other is StudentRef &&
      other.id == id &&
      other.name == name &&
      other.avatar == avatar &&
      other.detail == detail &&
      other.detailSemantics == detailSemantics &&
      other.aimType == aimType;

  @override
  int get hashCode =>
      Object.hash(id, name, avatar, detail, detailSemantics, aimType);
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
