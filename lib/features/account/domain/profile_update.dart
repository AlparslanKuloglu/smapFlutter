import 'package:flutter/foundation.dart';

import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';

/// What the profile screen changed, for `AccountRepository.updateProfile`.
///
/// Only the non-null fields are sent. The legacy screen sent name, e-mail,
/// phone, country and city; avatar, school year and track are what the new
/// design edits (spec §6.3 #11), and whether the server accepts them on
/// `/student/updateStudent` is not confirmed.
///
/// E-mail goes out unverified today (Tur 12 E).
@immutable
class ProfileUpdate {
  const ProfileUpdate({
    this.name,
    this.email,
    this.phone,
    this.country,
    this.city,
    this.photo,
    this.grade,
    this.track,
  });

  /// Display name.
  final String? name;

  final String? email;
  final String? phone;
  final String? country;
  final String? city;

  /// Avatar file name such as `1avatarN3.png` (the part after `avatars/`).
  /// A path is cut down to its last segment when sent.
  final String? photo;

  /// School year ("sınıf").
  final SchoolGrade? grade;

  /// Study track ("alan"). A track without a confirmed code
  /// ([StudyTrack.dil]) is left out.
  final StudyTrack? track;

  /// `true` when nothing would be sent.
  bool get isEmpty => toBody().isEmpty;

  /// The JSON body: the non-null fields under the backend's names.
  Map<String, Object> toBody() {
    final body = <String, Object>{};
    void put(String key, Object? value) {
      if (value != null) body[key] = value;
    }

    put('name', name);
    put('email', email);
    put('phone', phone);
    put('country', country);
    put('city', city);
    final file = photo?.trim();
    if (file != null && file.isNotEmpty) {
      put('photo', file.split('/').last);
    }
    put('seasonType', grade?.code);
    put('aimType', track?.code);
    return body;
  }
}
