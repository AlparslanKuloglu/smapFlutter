import 'package:flutter/foundation.dart';

import 'package:smap/features/coach/data/dtos/coach_student_dto.dart';

/// What `CoachStudentRepository.addStudent` came back with.
@immutable
sealed class AddStudentOutcome {
  const AddStudentOutcome();

  /// The student was created.
  const factory AddStudentOutcome.added(CoachStudentDto student) = StudentAdded;

  /// The login name is taken (`userNameUsing: true`); the form marks the
  /// field instead of showing a failure.
  const factory AddStudentOutcome.userNameTaken() = UserNameTaken;
}

/// See [AddStudentOutcome.added].
final class StudentAdded extends AddStudentOutcome {
  const StudentAdded(this.student);

  final CoachStudentDto student;
}

/// See [AddStudentOutcome.userNameTaken].
final class UserNameTaken extends AddStudentOutcome {
  const UserNameTaken();
}
