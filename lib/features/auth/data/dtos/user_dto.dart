import 'package:dart_mappable/dart_mappable.dart';

import 'package:smap/core/domain/user_role.dart';
import 'package:smap/features/auth/data/dtos/lenient_hooks.dart';

part 'generated/user_dto.mapper.dart';

/// The signed-in account, as the backend's `user` object describes it.
///
/// This is the shape the legacy app keeps under `user_data` and that
/// `/student/login` and `/ajax/checkUser` return. It is a Mongo document, so
/// every field is optional here: the backend does not guarantee any of them and
/// a missing or odd value must never fail a login (each field reads leniently,
/// see `lenient_hooks.dart`). Fields the legacy code reads: `name`, `role`,
/// `photo`, `aimType`, `points`, `progress`, `email`, `phone`, `country`,
/// `city`, `refCode`. The rest come from the student schema
/// (`domain/models/student_model.dart`).
///
/// The `password` field the student document carries is **not** modelled:
/// decoding drops it and [toJson] can never write it back.
@MappableClass(ignoreNull: true)
class UserDto with UserDtoMappable {
  const UserDto({
    this.id,
    this.name,
    this.firstName,
    this.surname,
    this.userName,
    this.email,
    this.phone,
    this.country,
    this.city,
    this.role,
    this.photo,
    this.seasonType,
    this.aimType,
    this.refCode,
    this.coach,
    this.schoolNo,
    this.totalMexam,
    this.status,
    this.registerType,
    this.degreePoint,
    this.points,
    this.progress,
    this.date,
  });

  /// Reads a user object from decoded JSON.
  factory UserDto.fromJson(Map<String, dynamic> json) =>
      UserDtoMapper.fromJson(json);

  /// Mongo `_id`.
  @MappableField(key: '_id', hook: TextOrNullHook())
  final String? id;

  /// Display name ("Ayşe Yılmaz"). May be a first name only.
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

  @MappableField(hook: TextOrNullHook())
  final String? country;

  @MappableField(hook: TextOrNullHook())
  final String? city;

  /// The backend's role string; read it through [userRole].
  @MappableField(hook: TextOrNullHook())
  final String? role;

  /// Avatar file name or path (`avatars/1avatarN3.png`, `user.png`). The
  /// legacy screens treat it both as an asset name and as a URL; how it is
  /// shown is the screen's decision.
  @MappableField(hook: TextOrNullHook())
  final String? photo;

  /// School year of a student (9, 10, 11, 12; the "Mezun" value is an open
  /// backend question, spec §6.3 #30).
  @MappableField(hook: IntOrNullHook())
  final int? seasonType;

  /// Study track of a student: 2 EA, 3 SAY, 4 SÖZ in the legacy code (Dil is
  /// an open question, spec §6.3 #18).
  @MappableField(hook: IntOrNullHook())
  final int? aimType;

  /// A coach's share code ("koçluk kodu").
  @MappableField(hook: TextOrNullHook())
  final String? refCode;

  /// A student's coach: the coach's id. The backend sends either the id or a
  /// populated object; both read as the id.
  @MappableField(hook: CoachRefHook())
  final String? coach;

  @MappableField(hook: IntOrNullHook())
  final int? schoolNo;

  /// Number of exams the student has read.
  @MappableField(hook: IntOrNullHook())
  final int? totalMexam;

  @MappableField(hook: IntOrNullHook())
  final int? status;

  @MappableField(hook: IntOrNullHook())
  final int? registerType;

  @MappableField(hook: IntOrNullHook())
  final int? degreePoint;

  /// Points shown on the legacy home card.
  @MappableField(hook: IntOrNullHook())
  final int? points;

  /// 0..1 progress shown on the legacy home card.
  @MappableField(hook: DoubleOrNullHook())
  final double? progress;

  /// Registration date.
  @MappableField(hook: DateOrNullHook())
  final DateTime? date;

  /// [role] as the app's enum; [UserRole.unknown] when absent or not known.
  UserRole get userRole => UserRole.fromLegacy(role);

  /// The name to show: [name], else first name and surname, else the login
  /// name; `null` when the backend sent none of them.
  String? get displayName {
    final plain = name?.trim();
    if (plain != null && plain.isNotEmpty) return plain;
    final full = [
      firstName,
      surname,
    ].whereType<String>().map((part) => part.trim()).where((p) => p.isNotEmpty);
    if (full.isNotEmpty) return full.join(' ');
    return userName;
  }
}
