import 'package:flutter/foundation.dart' show immutable;
import 'package:smap/features/exams/application/net_math.dart';

/// The three outcomes of a question, always in this order: Doğru, Yanlış,
/// Boş (board 1.14 "D/Y/B Ailesi"; C40).
enum DybKind {
  /// Doğru (D).
  correct,

  /// Yanlış (Y).
  wrong,

  /// Boş (B).
  blank;

  /// The fixed display order of every D/Y/B component: correct, wrong, blank.
  static const List<DybKind> ordered = [correct, wrong, blank];
}

/// The correct / wrong / blank count of an exam, a test or a topic
/// (C41 `DybCounter`, C42 `DybStackedBar`).
///
/// Blank is kept even when it is zero: "Boş sıfır da olsa görünür: veri var,
/// değeri sıfır". No count may be negative.
@immutable
class DybCounts {
  const DybCounts({
    required this.correct,
    required this.wrong,
    required this.blank,
  }) : assert(correct >= 0 && wrong >= 0 && blank >= 0);

  /// Doğru.
  final int correct;

  /// Yanlış.
  final int wrong;

  /// Boş.
  final int blank;

  /// All questions: D + Y + B.
  int get total => correct + wrong + blank;

  /// The net of these counts, `D − Y ÷ 4` ([NetMath.net]).
  double get net => NetMath.net(correct, wrong);

  /// The count of [kind].
  int of(DybKind kind) => switch (kind) {
    DybKind.correct => correct,
    DybKind.wrong => wrong,
    DybKind.blank => blank,
  };

  @override
  bool operator ==(Object other) =>
      other is DybCounts &&
      other.correct == correct &&
      other.wrong == wrong &&
      other.blank == blank;

  @override
  int get hashCode => Object.hash(correct, wrong, blank);

  @override
  String toString() => 'DybCounts($correct D, $wrong Y, $blank B)';
}
