import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';

/// The score and rank of one score type of an exam result.
///
/// A value the server did not send is `null`; nothing is drawn for it (spec
/// 2.12: "TYT'de puan, kart sayısı yok (null çizilmez)").
@immutable
class ScoreEntry {
  const ScoreEntry({this.point, this.pointHam, this.rank, this.rankHam});

  /// Placement points ("Yerleştirme puanı"), e.g. 412,63.
  final double? point;

  /// Raw points ("Ham puan"). Whether the screen shows them is an open
  /// question (spec §6.5 #7).
  final double? pointHam;

  /// Rank among all students, e.g. 48215.
  final int? rank;

  /// Rank of the raw points.
  final int? rankHam;

  /// Nothing known.
  bool get isEmpty =>
      point == null && pointHam == null && rank == null && rankHam == null;

  @override
  bool operator ==(Object other) =>
      other is ScoreEntry &&
      other.point == point &&
      other.pointHam == pointHam &&
      other.rank == rank &&
      other.rankHam == rankHam;

  @override
  int get hashCode => Object.hash(point, pointHam, rank, rankHam);
}

/// The four score arrays of an exam result (`points`, `pointsHam`, `ranks`,
/// `ranksHam`), one slot per score type. Slot 0 is TYT; an AYT field uses the
/// slot of its `aimType` value (2, 3 or 4), the rule both the legacy analytics
/// and the optical-reading result use.
@immutable
class ExamScores {
  const ExamScores({
    this.points = const [],
    this.pointsHam = const [],
    this.ranks = const [],
    this.ranksHam = const [],
  });

  /// No scores at all.
  static const ExamScores none = ExamScores();

  final List<double?> points;
  final List<double?> pointsHam;
  final List<int?> ranks;
  final List<int?> ranksHam;

  /// The slot that counts for [exam] and, for an AYT, the student's [field];
  /// `null` for an AYT without a known field (nothing is guessed).
  static int? slotFor(NetExamType exam, AytField? field) => switch (exam) {
    NetExamType.tyt => 0,
    NetExamType.ayt => field?.wireValue,
  };

  /// The entry of [slot]; empty when the arrays do not reach it.
  ScoreEntry at(int slot) => ScoreEntry(
    point: _read(points, slot),
    pointHam: _read(pointsHam, slot),
    rank: _read(ranks, slot),
    rankHam: _read(ranksHam, slot),
  );

  /// The entry that counts for [exam] and [field]; `null` when the slot is
  /// unknown.
  ScoreEntry? forExam(NetExamType exam, AytField? field) {
    final slot = slotFor(exam, field);
    return slot == null ? null : at(slot);
  }

  static T? _read<T>(List<T?> list, int slot) =>
      slot >= 0 && slot < list.length ? list[slot] : null;

  @override
  bool operator ==(Object other) =>
      other is ExamScores &&
      listEquals(other.points, points) &&
      listEquals(other.pointsHam, pointsHam) &&
      listEquals(other.ranks, ranks) &&
      listEquals(other.ranksHam, ranksHam);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(points),
    Object.hashAll(pointsHam),
    Object.hashAll(ranks),
    Object.hashAll(ranksHam),
  );
}
