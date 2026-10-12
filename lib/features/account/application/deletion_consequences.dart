import 'package:flutter/foundation.dart';

/// What the account takes with it, one line of "Hesabını silersen:" (pano 9.4
/// kare 2).
enum DeletionConsequenceKind {
  /// "Okuttuğun 10 deneme ve analizleri silinir." With no count known:
  /// "Okuttuğun denemeler ve analizleri silinir."
  exams,

  /// "Eksik konuların, programların ve bilgi kartı ilerlemen silinir."
  progress,

  /// "Koçun Mehmet Özkan ile bağlantın kalkar." Without the name:
  /// "Koçunla bağlantın kalkar."
  coach,

  /// "Bu işlem geri alınamaz."
  irreversible,
}

/// One line of the list with the data it names.
@immutable
class DeletionConsequence {
  const DeletionConsequence(this.kind, {this.examCount, this.coachName});

  final DeletionConsequenceKind kind;

  /// How many exams the student has read; only for [DeletionConsequenceKind.exams]
  /// and only when the account says so (a positive number).
  final int? examCount;

  /// The coach's name; only for [DeletionConsequenceKind.coach].
  final String? coachName;

  @override
  bool operator ==(Object other) =>
      other is DeletionConsequence &&
      other.kind == kind &&
      other.examCount == examCount &&
      other.coachName == coachName;

  @override
  int get hashCode => Object.hash(kind, examCount, coachName);

  @override
  String toString() => 'DeletionConsequence($kind, $examCount, $coachName)';
}

/// Builds the list of "Hesabını sil" (pano 9.4 kare 2, "Veri": "Deneme sayısı
/// ... Koç adı ve kullanıcının adı soyadı"), unit-tested.
///
/// Nothing is made up: a count the account does not carry is left out of the
/// sentence, and the coach line is drawn only for a student who has a coach
/// ("Koç yoksa 3. madde gizlenir"; decision recorded in the task report).
abstract final class DeletionConsequences {
  static List<DeletionConsequence> of({
    int? examCount,
    required bool hasCoach,
    String? coachName,
  }) {
    final count = examCount != null && examCount > 0 ? examCount : null;
    final name = coachName?.trim();
    return [
      DeletionConsequence(DeletionConsequenceKind.exams, examCount: count),
      const DeletionConsequence(DeletionConsequenceKind.progress),
      if (hasCoach)
        DeletionConsequence(
          DeletionConsequenceKind.coach,
          coachName: name == null || name.isEmpty ? null : name,
        ),
      const DeletionConsequence(DeletionConsequenceKind.irreversible),
    ];
  }
}
