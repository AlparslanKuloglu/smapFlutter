import 'package:flutter/foundation.dart' show immutable, listEquals;

/// One bar of the "ders dağılımı" chart: a label and its value
/// (`getTotal`'s `total.lessOrSubjects[i]` and `total.data[i]`). What the
/// value counts is not documented by the backend (the legacy chart drew it as
/// a share); it is passed through as sent.
@immutable
class LessonShare {
  const LessonShare({required this.label, required this.value});

  final String label;
  final double value;

  @override
  bool operator ==(Object other) =>
      other is LessonShare && other.label == label && other.value == value;

  @override
  int get hashCode => Object.hash(label, value);
}

/// A subject's question tally in a lesson chart (`getTotal`'s `items`):
/// how many questions came and how many were answered right.
@immutable
class SubjectTally {
  const SubjectTally({
    required this.name,
    required this.count,
    required this.correct,
  });

  final String name;

  /// Questions of the subject across the exams.
  final int count;

  /// Questions answered right.
  final int correct;

  /// Questions not answered right (wrong or blank); what the legacy chart
  /// drew per subject.
  int get missed => count - correct;

  @override
  bool operator ==(Object other) =>
      other is SubjectTally &&
      other.name == name &&
      other.count == count &&
      other.correct == correct;

  @override
  int get hashCode => Object.hash(name, count, correct);
}

/// The answer of `getTotal`: the headline figures of the Analizlerim screen.
@immutable
class AnalyticsTotals {
  const AnalyticsTotals({
    this.examCount,
    this.averageNet,
    this.shares = const [],
    this.subjects = const [],
  });

  /// "Çözülen deneme" (`total.count`).
  final int? examCount;

  /// "Ortalama net" (`total.ortNet`), as the server calculated it.
  final double? averageNet;

  /// The bars of the distribution chart.
  final List<LessonShare> shares;

  /// Per-subject tallies (`items`); present in a lesson chart.
  final List<SubjectTally> subjects;

  @override
  bool operator ==(Object other) =>
      other is AnalyticsTotals &&
      other.examCount == examCount &&
      other.averageNet == averageNet &&
      listEquals(other.shares, shares) &&
      listEquals(other.subjects, subjects);

  @override
  int get hashCode => Object.hash(
    examCount,
    averageNet,
    Object.hashAll(shares),
    Object.hashAll(subjects),
  );
}
