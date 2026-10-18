import 'package:flutter/foundation.dart';

import 'package:smap/core/utils/turkish_text.dart';
import 'package:smap/features/account/domain/coach_code.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';

/// The student's coach as "Koçluk" shows it (pano 9.5 kare 1): who, the
/// picture and the code the link was made with.
@immutable
class CoachLink {
  const CoachLink({
    required this.id,
    required this.name,
    this.photo,
    this.code,
  });

  /// The coach's id; what `deleteCoach` is given.
  final String id;

  /// "Mehmet Özkan".
  final String name;

  /// The avatar file name, `null` draws the initials.
  final String? photo;

  /// The coach's `refCode` as the server sent it ("MOZK-4821"), when it did.
  final String? code;

  /// The coach in [user]'s words; `null` when the answer has no id or no
  /// name to show (the screen then treats the student as having no coach
  /// rather than drawing an empty card).
  static CoachLink? fromUser(UserDto? user) {
    final id = user?.id;
    final name = _displayName(user);
    if (user == null || id == null || id.isEmpty || name == null) return null;
    return CoachLink(id: id, name: name, photo: user.photo, code: user.refCode);
  }

  static String? _displayName(UserDto? user) {
    final name = user?.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    final joined = [user?.firstName, user?.surname]
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .join(' ');
    return joined.isEmpty ? null : joined;
  }

  @override
  bool operator ==(Object other) =>
      other is CoachLink &&
      other.id == id &&
      other.name == name &&
      other.photo == photo &&
      other.code == code;

  @override
  int get hashCode => Object.hash(id, name, photo, code);

  @override
  String toString() => 'CoachLink($id, $name)';
}

/// How a typed code reads against the current coach (pano 9.5 kare 3;
/// Tur 12 F "Girilen kod mevcut koçunun").
enum CoachCodeVerdict {
  /// Four letters and four digits, and not the current coach's.
  ready,

  /// Not yet four letters and four digits: "Koça Bağlan" stays closed.
  incomplete,

  /// The code of the coach the student already has: "Bu kod zaten koçun
  /// Mehmet Özkan'a ait."
  currentCoach,
}

/// Pure rules of "Koçluk" (pano 9.5, Tur 12 F), unit-tested.
abstract final class CoachingRules {
  /// [name] with the "ile" suffix, for "Mehmet Özkan'la bağlantın kalkar"
  /// (pano 14.10 kare 2): "'la" / "'le" after a consonant, "'yla" / "'yle"
  /// after a vowel ("Ayşe'yle"). The vowel follows the same harmony as the
  /// dative (`TurkishSuffix.dative`: "'a", "'e", "'ya", "'ye"), so the
  /// suffix is that one with an "l" before its last vowel.
  static String withSuffix(String name) {
    final dative = TurkishSuffix.dative(name);
    final cut = dative.length - 1;
    return '${dative.substring(0, cut)}l${dative.substring(cut)}';
  }

  /// Reads [typed] against [current] (`null` for a student with no coach).
  static CoachCodeVerdict verdict(String typed, {CoachLink? current}) {
    final code = CoachCode.tryParse(typed);
    if (code == null) return CoachCodeVerdict.incomplete;
    final own = CoachCode.tryParse(current?.code);
    if (own != null && own == code) return CoachCodeVerdict.currentCoach;
    return CoachCodeVerdict.ready;
  }

  /// Whether an answer of `addCoach` is the coach the student already had
  /// (the server linked the same coach again).
  static bool isSameCoach(CoachLink? before, CoachLink after) =>
      before != null && before.id == after.id;
}

/// Why a code did not link (pano 9.5 kare 3; Tur 12 F "Hata").
enum CoachLinkFailure {
  /// The server knows no coach with the code: "Bu kodla bir koç
  /// bulunamadı. Kodu koçundan yeniden iste."
  notFound,

  /// The code is the current coach's: "Bu kod zaten koçun Mehmet Özkan'a
  /// ait."
  sameCoach,

  /// Offline, timeout, server or an answer the app cannot read: a plain
  /// "try again", the typed code is kept.
  failed,
}

/// The outcome of one `addCoach` try: the coach that is linked now, or why
/// not. Exactly one of the two is set.
@immutable
class CoachLinkResult {
  const CoachLinkResult.linked(CoachLink this.coach) : failure = null;

  const CoachLinkResult.failed(CoachLinkFailure this.failure) : coach = null;

  /// The new coach.
  final CoachLink? coach;

  final CoachLinkFailure? failure;

  @override
  bool operator ==(Object other) =>
      other is CoachLinkResult &&
      other.coach == coach &&
      other.failure == failure;

  @override
  int get hashCode => Object.hash(coach, failure);
}
