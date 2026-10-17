import 'package:flutter/foundation.dart';

import 'package:smap/core/domain/user_role.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';

/// What the sign-up form hands to `AuthRepository.register` (pano 2.5, 2.6).
///
/// The wire body follows the legacy registration form and
/// `AuthRemoteDataSource.register` field by field:
///
/// ```json
/// { "userType": 1,
///   "data": { "name": "", "firstName": "", "surname": "", "userName": "",
///             "email": "",
///             "password": "", "password2": "", "seasonType": 12,
///             "aimType": 2, "photo": "1avatarN3.png" } }
/// ```
///
/// `userType` is 1 for a student and 2 for a coach. The form has one "Ad
/// Soyad" field: `name` is the whole of it, `firstName` all but the last word
/// and `surname` the last word ("Ayşe Nur Kaya" → "Ayşe Nur Kaya", "Ayşe Nur",
/// "Kaya"), as the owner's app sends it since October 2026 (upstream
/// e615595); before that `name` carried only the first name. A coach sends `seasonType: 0` and `aimType: null`, a student
/// below grade 11 `aimType: null`. The password goes out as typed and is never
/// kept: [toString] leaves it out.
@immutable
class NewRegistration {
  const NewRegistration({
    required this.role,
    required this.fullName,
    required this.userName,
    required this.email,
    required this.password,
    required this.passwordRepeat,
    required this.photo,
    this.grade,
    this.track,
    this.acceptedTermsVersion,
    this.acceptedKvkkVersion,
    this.acceptedPrivacyVersion,
  }) : assert(
         role == UserRole.student || role == UserRole.coach,
         'Only a student or a coach can register',
       );

  /// [UserRole.student] or [UserRole.coach].
  final UserRole role;

  /// "Alparslan Kuloğlu".
  final String fullName;

  /// Sent as `userName` (trimmed).
  final String userName;

  /// Sent trimmed.
  final String email;
  final String password;

  /// Sent as `password2`.
  final String passwordRepeat;

  /// The avatar file such as `1avatarN3.png`; a path is cut down to its last
  /// segment.
  final String photo;

  /// A student's school year; a coach has none.
  final SchoolGrade? grade;

  /// A student's study track; asked from grade 11 on.
  final StudyTrack? track;

  /// The version of the legal text the person accepted, when the backend sent
  /// one (`version` of the document, see `LegalDocumentDto`).
  final String? acceptedTermsVersion;
  final String? acceptedKvkkVersion;
  final String? acceptedPrivacyVersion;

  bool get isCoach => role == UserRole.coach;

  /// The split of "Ad Soyad": one word is a `firstName` with an empty
  /// `surname`; otherwise the last word is the `surname`. [whole] is the name
  /// with its spaces tidied ("  Ayşe   Nur  Kaya " → "Ayşe Nur Kaya").
  static ({String whole, String firstName, String surname}) splitFullName(
    String fullName,
  ) {
    final words = fullName.trim().split(RegExp(r'\s+'));
    final whole = words.join(' ');
    if (words.length < 2) {
      return (whole: whole, firstName: words.first, surname: '');
    }
    return (
      whole: whole,
      firstName: words.sublist(0, words.length - 1).join(' '),
      surname: words.last,
    );
  }

  /// The `seasonType` on the wire: the grade's code, 0 for a coach (the legacy
  /// form's placeholder).
  int get seasonType => isCoach ? 0 : (grade?.code ?? SchoolGrade.grade9.code);

  /// The `aimType` on the wire: only a student of grade 11 or above with a
  /// track that has a confirmed code sends one.
  int? get aimType {
    if (isCoach) return null;
    if (grade?.requiresTrack != true) return null;
    return track?.code;
  }

  /// The request body.
  ///
  /// [withAcceptedVersions] adds `acceptedTermsVersion`,
  /// `acceptedKvkkVersion` and `acceptedPrivacyVersion` next to `userType`
  /// when they are known (the legacy `RegisterNotifier` put them there; its
  /// data source dropped them, see `RegisterRequests.sendAcceptedVersions`).
  Map<String, Object?> toBody({bool withAcceptedVersions = true}) {
    final (:whole, :firstName, :surname) = splitFullName(fullName);
    return <String, Object?>{
      'userType': isCoach ? 2 : 1,
      'data': <String, Object?>{
        'name': whole,
        'firstName': firstName,
        'surname': surname,
        'userName': userName.trim(),
        'email': email.trim(),
        'password': password,
        'password2': passwordRepeat,
        'seasonType': seasonType,
        'aimType': aimType,
        'photo': photo.trim().split('/').last,
      },
      if (withAcceptedVersions) ...{
        'acceptedTermsVersion': ?acceptedTermsVersion,
        'acceptedKvkkVersion': ?acceptedKvkkVersion,
        'acceptedPrivacyVersion': ?acceptedPrivacyVersion,
      },
    };
  }

  @override
  String toString() =>
      'NewRegistration(${role.name}, userName: $userName, email: $email)';
}
