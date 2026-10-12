import 'package:flutter/foundation.dart';

import 'package:smap/features/account/application/avatar_catalog.dart';
import 'package:smap/features/account/application/phone_number.dart';
import 'package:smap/features/account/domain/profile_update.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/auth/application/register/register_rules.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';

/// What a field of the profile form can be wrong about (pano 9.2 kare 2).
enum ProfileIssue {
  /// The name is empty.
  nameMissing,

  /// The e-mail is empty or has no "@" and domain.
  emailInvalid,

  /// A phone number was typed but is not `5XX XXX XX XX`.
  phoneInvalid,
}

/// The values of the profile form while it is being edited (pano 9.2; spec
/// §4.H 9.2), an immutable value the ViewModel replaces on every change.
///
/// It starts as the account ([ProfileDraft.fromUser]) and knows what the form
/// would send ([toUpdate]: only the changed fields, as the PATCH-like
/// `updateStudent` expects), whether anything changed ([hasChanges]: "Kaydet:
/// değişen alan yoksa pasif") and what is wrong ([issuesAgainst]).
///
/// A field the person did not touch is never checked: an old account whose
/// stored e-mail the form would call invalid can still change its avatar.
///
/// The user name is not part of it ("Kullanıcı adı değiştirilemez."). Pure and
/// unit-tested.
@immutable
class ProfileDraft {
  const ProfileDraft({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.grade,
    this.track,
    this.photo,
  });

  /// The form as the account has it. A name the account lacks stays empty
  /// (the login name is not offered as a display name to edit).
  factory ProfileDraft.fromUser(UserDto user) {
    final parts = [user.firstName, user.surname]
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty);
    final plain = user.name?.trim();
    final grade = SchoolGrade.fromCode(user.seasonType);
    return ProfileDraft(
      name: plain != null && plain.isNotEmpty ? plain : parts.join(' '),
      email: user.email?.trim() ?? '',
      phone: PhoneNumber.grouped(user.phone),
      grade: grade,
      track: grade != null && !grade.requiresTrack
          ? null
          : StudyTrack.fromCode(user.aimType),
      photo: user.photo,
    );
  }

  /// "Ad Soyad".
  final String name;

  /// "E-posta".
  final String email;

  /// The national digits as the field shows them, `532 123 45 67`.
  final String phone;

  /// "Sınıf"; `null` for a coach and for an account without one.
  final SchoolGrade? grade;

  /// "Alan"; `null` when the grade has none.
  final StudyTrack? track;

  /// The avatar file name; `null` when none is set.
  final String? photo;

  /// Whether the grade of this form asks for a track.
  bool get hasTrackField => grade?.requiresTrack ?? false;

  ProfileDraft copyWith({
    String? name,
    String? email,
    String? phone,
    String? photo,
  }) => ProfileDraft(
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    grade: grade,
    track: track,
    photo: photo ?? this.photo,
  );

  /// A new grade. "9. ya da 10. sınıfı seçersen alan kaldırılır": the track
  /// goes with a grade that has none.
  ProfileDraft withGrade(SchoolGrade value) => ProfileDraft(
    name: name,
    email: email,
    phone: phone,
    grade: value,
    track: value.requiresTrack ? track : null,
    photo: photo,
  );

  /// A new track.
  ProfileDraft withTrack(StudyTrack value) => ProfileDraft(
    name: name,
    email: email,
    phone: phone,
    grade: grade,
    track: value,
    photo: photo,
  );

  /// The fields that differ from [original], ready for
  /// `AccountRepository.updateProfile`; `null` when nothing would be sent.
  ///
  /// - text is sent trimmed; a phone number goes out as `+90 532 123 45 67`
  ///   (an emptied one as empty text);
  /// - a track that went away with the grade is not sent: the backend has
  ///   no way to clear it (open question), so only a chosen track is sent;
  /// - the avatar is sent as its file name.
  ProfileUpdate? toUpdate(ProfileDraft original) {
    final nameChanged = name.trim() != original.name.trim();
    final emailChanged = email.trim() != original.email.trim();
    final phoneChanged =
        PhoneNumber.nationalDigits(phone) !=
        PhoneNumber.nationalDigits(original.phone);
    final photoChanged = _file(photo) != _file(original.photo);
    final update = ProfileUpdate(
      name: nameChanged ? name.trim() : null,
      email: emailChanged ? email.trim() : null,
      phone: phoneChanged ? (PhoneNumber.display(phone) ?? '') : null,
      photo: photoChanged ? _file(photo) : null,
      grade: grade != original.grade ? grade : null,
      track: track != original.track ? track : null,
    );
    return update.isEmpty ? null : update;
  }

  /// Whether sending this form would change anything.
  bool hasChanges(ProfileDraft original) => toUpdate(original) != null;

  /// What is wrong with the fields that changed since [original].
  Set<ProfileIssue> issuesAgainst(ProfileDraft original) {
    final issues = <ProfileIssue>{};
    if (name.trim() != original.name.trim() && name.trim().isEmpty) {
      issues.add(ProfileIssue.nameMissing);
    }
    if (email.trim() != original.email.trim() &&
        !RegisterRules.isValidEmail(email)) {
      issues.add(ProfileIssue.emailInvalid);
    }
    final phoneChanged =
        PhoneNumber.nationalDigits(phone) !=
        PhoneNumber.nationalDigits(original.phone);
    if (phoneChanged &&
        PhoneNumber.nationalDigits(phone).isNotEmpty &&
        !PhoneNumber.isComplete(phone)) {
      issues.add(ProfileIssue.phoneInvalid);
    }
    return issues;
  }

  /// [user] with what [update] changed, for a server that accepted the form
  /// but did not send the account back (and a refresh that failed).
  static UserDto applied(UserDto user, ProfileUpdate update) => user.copyWith(
    name: update.name ?? user.name,
    email: update.email ?? user.email,
    phone: update.phone ?? user.phone,
    photo: update.photo ?? user.photo,
    seasonType: update.grade?.code ?? user.seasonType,
    aimType: update.track?.code ?? user.aimType,
  );

  static String? _file(String? photo) {
    final name = photo?.trim().split('/').last;
    return name == null || name.isEmpty ? null : name;
  }

  /// The index of the chosen avatar in the picker, `null` when the avatar is
  /// not one of the seven.
  int? get avatarIndex => AvatarCatalog.indexOf(photo);

  @override
  bool operator ==(Object other) =>
      other is ProfileDraft &&
      other.name == name &&
      other.email == email &&
      other.phone == phone &&
      other.grade == grade &&
      other.track == track &&
      other.photo == photo;

  @override
  int get hashCode => Object.hash(name, email, phone, grade, track, photo);
}
