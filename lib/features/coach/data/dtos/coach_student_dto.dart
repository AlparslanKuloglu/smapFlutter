import 'package:dart_mappable/dart_mappable.dart';

import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/auth/data/dtos/lenient_hooks.dart';

part 'generated/coach_student_dto.mapper.dart';

/// One student of the coach: an element of `students` in
/// `POST /coach/getMyStudents`, and the `student` the "Öğrenci Ekle" call
/// returns.
///
/// It is the student's Mongo document. Fields follow the legacy `Student`
/// model, all optional and read leniently; nothing is filled with a made-up
/// default (the legacy model invented "Öğrenci" as a name and the avatar
/// `avatars/1avatarN3.png`).
///
/// The document's `password` hash is **not** modelled (spec S4): decoding
/// drops it and nothing here can write it back. `__v` is dropped as well.
///
/// What the design's student list also wants (last net, last exam date, spec
/// §6.3 #29) is not in the document; only [totalMexam], the number of exams
/// read, is.
@MappableClass(ignoreNull: true)
class CoachStudentDto with CoachStudentDtoMappable {
  const CoachStudentDto({
    this.id,
    this.name,
    this.firstName,
    this.surname,
    this.userName,
    this.email,
    this.phone,
    this.photo,
    this.schoolNo,
    this.totalMexam,
    this.status,
    this.seasonType,
    this.aimType,
    this.registerType,
    this.degreePoint,
    this.date,
    this.coach,
  });

  factory CoachStudentDto.fromJson(Map<String, dynamic> json) =>
      CoachStudentDtoMapper.fromJson(json);

  /// Mongo `_id`; the `studentId` of every coach-context call.
  @MappableField(key: '_id', hook: TextOrNullHook())
  final String? id;

  /// Display name. For a student a coach added this is the first name only.
  @MappableField(hook: TextOrNullHook())
  final String? name;

  @MappableField(hook: TextOrNullHook())
  final String? firstName;

  @MappableField(hook: TextOrNullHook())
  final String? surname;

  /// Login name.
  @MappableField(hook: TextOrNullHook())
  final String? userName;

  @MappableField(hook: TextOrNullHook())
  final String? email;

  @MappableField(hook: TextOrNullHook())
  final String? phone;

  /// Avatar file name or path (`avatars/1avatarN3.png`, `1avatarN3.png`).
  @MappableField(hook: TextOrNullHook())
  final String? photo;

  @MappableField(hook: IntOrNullHook())
  final int? schoolNo;

  /// Number of exams the student has read.
  @MappableField(hook: IntOrNullHook())
  final int? totalMexam;

  @MappableField(hook: IntOrNullHook())
  final int? status;

  /// School year as the backend's number; read it through [grade].
  @MappableField(hook: IntOrNullHook())
  final int? seasonType;

  /// Study track as the backend's number; read it through [track].
  @MappableField(hook: IntOrNullHook())
  final int? aimType;

  @MappableField(hook: IntOrNullHook())
  final int? registerType;

  @MappableField(hook: IntOrNullHook())
  final int? degreePoint;

  /// Registration date.
  @MappableField(hook: DateOrNullHook())
  final DateTime? date;

  /// The coach's id (the backend sends an id or a populated object).
  @MappableField(hook: CoachRefHook())
  final String? coach;

  /// [seasonType] as the app's enum; `null` when absent or unknown.
  SchoolGrade? get grade => SchoolGrade.fromCode(seasonType);

  /// [aimType] as the app's enum; `null` when absent, 0, 1 or unknown.
  StudyTrack? get track => StudyTrack.fromCode(aimType);

  /// The name to show: [name], else first name and surname, else the login
  /// name; `null` when the document has none of them.
  String? get displayName {
    final plain = name?.trim();
    if (plain != null && plain.isNotEmpty) return plain;
    final full = [firstName, surname]
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty);
    if (full.isNotEmpty) return full.join(' ');
    return userName;
  }
}
