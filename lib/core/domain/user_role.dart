/// Which side of the app the signed-in account belongs to.
///
/// The backend sends the role as a free string in the user JSON (`role`). Only
/// `student` and `coach` are documented; the legacy shell also compares against
/// `teacher`, so that spelling counts as a coach. Anything else (a new role,
/// a missing field) is [unknown] and lands on the "bilinmeyen rol" screen
/// instead of silently opening the student app.
enum UserRole {
  student,
  coach,

  /// A role this build does not know, or no role at all.
  unknown;

  /// Reads the backend's role value; case and surrounding spaces do not matter.
  static UserRole fromLegacy(Object? raw) {
    if (raw is! String) return unknown;
    return switch (raw.trim().toLowerCase()) {
      'student' => student,
      'coach' || 'teacher' => coach,
      _ => unknown,
    };
  }

  bool get isStudent => this == student;
  bool get isCoach => this == coach;

  /// `true` for roles the app has a shell for.
  bool get isKnown => this != unknown;

  /// The value the backend and the legacy code use (`student`, `coach`).
  /// [unknown] has none.
  String? get wireName => switch (this) {
    student => 'student',
    coach => 'coach',
    unknown => null,
  };
}
