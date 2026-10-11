import 'package:dartz/dartz.dart';

import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/coach/data/add_student_outcome.dart';
import 'package:smap/features/coach/data/dtos/coach_student_dto.dart';
import 'package:smap/features/coach/data/requests/coach_student_requests.dart';
import 'package:smap/features/coach/domain/new_student.dart';
import 'package:smap/features/coach/domain/username_check.dart';

/// The coach's students: the list, the username check and "Öğrenci Ekle".
/// Answers `Either<AppException, T>`; nothing throws.
///
/// There is no per-student detail endpoint in the legacy code: the student
/// card and the detail sheet read the list entry. A `success: false` answer is
/// an `AppErrorCode.validation` failure carrying the server's text; an answer
/// that is not the backend's JSON frame is an `AppErrorCode.server` failure.
class CoachStudentRepository {
  CoachStudentRepository(this._network);

  final NetworkService _network;

  /// `POST /coach/getMyStudents`: every student of the signed-in coach, in
  /// server order. An empty list is a valid answer.
  ///
  /// The legacy call never looked at `success`, only at the `students` list,
  /// so a missing flag is accepted when the list is there.
  Future<AppResult<List<CoachStudentDto>>> getMyStudents() async {
    const path = '/coach/getMyStudents';
    final result = await _network.send(CoachStudentRequests.myStudents());
    return result.fold(Left.new, (envelope) {
      if (envelope.isRejected) return Left(envelope.rejection(path));
      final students = envelope.readList('students', CoachStudentDto.fromJson);
      if (students == null) {
        return Left(envelope.unusable(path, 'no students list'));
      }
      return Right(students);
    });
  }

  /// `GET /ajax/checkUsername`: whether [userName] is free.
  Future<AppResult<UsernameCheck>> checkUsername(String userName) async {
    const path = '/ajax/checkUsername';
    final result = await _network.send(
      CoachStudentRequests.checkUsername(userName.trim()),
    );
    return result.fold(Left.new, (envelope) {
      final available = envelope['available'];
      if (available is bool) return Right(UsernameCheck(available: available));
      if (envelope.isRejected) return Left(envelope.rejection(path));
      return Left(envelope.unusable(path, 'no "available" flag'));
    });
  }

  /// `POST /coach/addNewStudent`: creates the student.
  ///
  /// Succeeds with [AddStudentOutcome.added] and the created student, or with
  /// [AddStudentOutcome.userNameTaken] when the login name is in use (the
  /// server says so with `userNameUsing: true`, whether or not it also sets
  /// `success`). Any other refusal is a failure.
  Future<AppResult<AddStudentOutcome>> addStudent(NewStudent student) async {
    const path = '/coach/addNewStudent';
    final result = await _network.send(
      CoachStudentRequests.addStudent(student),
    );
    return result.fold(Left.new, (envelope) {
      final created = envelope.object('student');
      if (created != null && !envelope.isRejected) {
        try {
          return Right(
            AddStudentOutcome.added(CoachStudentDto.fromJson(created)),
          );
        } on Object catch (error, stackTrace) {
          return Left(AppException.parse(error, stackTrace, path));
        }
      }
      if (envelope['userNameUsing'] == true) {
        return const Right(AddStudentOutcome.userNameTaken());
      }
      if (envelope.isRejected || envelope.isSuccess) {
        return Left(envelope.rejection(path));
      }
      return Left(envelope.unusable(path, 'no student in the answer'));
    });
  }
}
