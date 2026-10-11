import 'package:flutter/foundation.dart';

import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';

/// The form of "Öğrenci Ekle", for `CoachStudentRepository.addStudent`.
///
/// The coach chooses the student's password; it goes to the server in the
/// request body and is never kept: [toString] leaves it out and no response
/// model has a password field.
@immutable
class NewStudent {
  const NewStudent({
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.password,
    required this.grade,
    this.track,
    this.photo,
  });

  /// Sent as `name`.
  final String firstName;

  /// Sent as `surname`.
  final String lastName;

  final String userName;

  final String password;

  final SchoolGrade grade;

  /// Study track; asked from 11th grade on (`SchoolGrade.requiresTrack`). A
  /// track without a confirmed code is left out.
  final StudyTrack? track;

  /// Avatar file name such as `1avatarN3.png`; a path is cut down to its last
  /// segment when sent (Tur 12 D).
  final String? photo;

  /// The `dataObj` of the request body.
  Map<String, Object> toDataObj() {
    final data = <String, Object>{
      'name': firstName.trim(),
      'surname': lastName.trim(),
      'userName': userName.trim(),
      'password': password,
      'seasonType': grade.code,
    };
    final code = track?.code;
    if (code != null) data['aimType'] = code;
    final file = photo?.trim();
    if (file != null && file.isNotEmpty) data['photo'] = file.split('/').last;
    return data;
  }

  @override
  String toString() =>
      'NewStudent(userName: $userName, grade: ${grade.name}, '
      'track: ${track?.name}, password: ***)';
}
