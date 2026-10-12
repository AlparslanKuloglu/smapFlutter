import 'package:flutter/foundation.dart' show immutable, mapEquals;

import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/application/exam_detail_model.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';

/// The tests an AYT score type is made of (pano 5.1 kare 1: "Eşit Ağırlık neti
/// 40" over "Türk Dili ve Edebiyatı–Sosyal Bilimler 1 ve Matematik"; Ek C
/// "EA 40 (TDE–SB1 + Matematik), SAY 37,5, SÖZ 30"). The words live in l10n,
/// this only says which tests: Eşit Ağırlık is Türk Dili ve Edebiyatı–Sosyal
/// Bilimler 1 and Matematik, Sayısal is Matematik and Fen Bilimleri, Sözel is
/// Türk Dili ve Edebiyatı–Sosyal Bilimler 1 and Sosyal Bilimler 2.
List<ExamTestLabel> momentFieldTests(AytField field) => switch (field) {
  AytField.equalWeight => const [
    ExamTestLabel.socialSciencesLiterature,
    ExamTestLabel.mathematics,
  ],
  AytField.numeric => const [ExamTestLabel.mathematics, ExamTestLabel.sciences],
  AytField.verbal => const [
    ExamTestLabel.socialSciencesLiterature,
    ExamTestLabel.socialSciences2,
  ],
};

/// What the result moment shows for one score type (pano 5.1 kare 1: the two
/// boxes "412,63 · Yerleştirme puanı" and "48.215. · Sıra" and the line "Eşit
/// Ağırlık neti 40"). A value the result does not have is `null` and is not
/// drawn; nothing is replaced by a zero or a dash (kare 2). The raw points
/// are not shown here (Tur 12 B: "5.1 sonuç anına ham puan eklenmez").
@immutable
class MomentScore {
  const MomentScore({this.point, this.rank, this.fieldNet});

  /// Nothing known for the score type.
  static const MomentScore none = MomentScore();

  /// "Yerleştirme puanı".
  final double? point;

  /// "Sıra".
  final int? rank;

  /// The net of the AYT score type (`aytNets`); `null` for a TYT result.
  final double? fieldNet;

  /// At least one of the two boxes has a value.
  bool get hasBoxes => point != null || rank != null;

  bool get isEmpty => point == null && rank == null && fieldNet == null;

  @override
  bool operator ==(Object other) =>
      other is MomentScore &&
      other.point == point &&
      other.rank == rank &&
      other.fieldNet == fieldNet;

  @override
  int get hashCode => Object.hash(point, rank, fieldNet);
}

/// Everything the result moment draws, read out of one exam result (spec
/// §4.D 5.1 "Veri"). Immutable with value equality, so a section rebuilds
/// only when something it shows changed.
///
/// A result that cannot be drawn (no D/Y/B, no net, no date) gives no model:
/// [of] returns `null` and the screen shows its error state instead of a
/// half-empty moment.
@immutable
class ResultMomentModel {
  const ResultMomentModel({
    required this.examId,
    required this.date,
    required this.net,
    required this.counts,
    this.kind,
    this.name,
    this.publisher,
    this.coverFile,
    this.delta,
    this.fieldScores = const {},
    this.tytScore = MomentScore.none,
    this.defaultField,
  });

  /// Reads the moment out of [exam].
  ///
  /// [previousNet] is the net of the previous exam of the same type (the
  /// loader finds it); the change is the difference, in quarter steps, and is
  /// `null` without one. [userField] is the signed-in student's AYT field: it
  /// is the segment the moment opens on; without it the first score type that
  /// has data opens.
  static ResultMomentModel? of(
    ExamDetail exam, {
    double? previousNet,
    AytField? userField,
  }) {
    final summary = exam.summary;
    final counts = summary.counts;
    final date = summary.date;
    final net = summary.net ?? counts?.net;
    if (counts == null || date == null || net == null) return null;

    final kind = summary.kind;
    final scores = <AytField, MomentScore>{};
    var tytScore = MomentScore.none;
    if (kind == NetExamType.ayt) {
      for (final field in AytField.values) {
        final entry = exam.scores.at(field.wireValue);
        final score = MomentScore(
          point: entry.point,
          rank: entry.rank,
          fieldNet: exam.aytNets[field]?.net,
        );
        if (!score.isEmpty) scores[field] = score;
      }
    } else if (kind == NetExamType.tyt) {
      final entry = exam.scores.at(0);
      tytScore = MomentScore(point: entry.point, rank: entry.rank);
    }

    return ResultMomentModel(
      examId: exam.id,
      kind: kind,
      name: _clean(summary.name),
      publisher: _clean(summary.publisherName),
      coverFile: summary.definition.imageFile,
      date: date,
      net: net,
      counts: counts,
      delta: previousNet == null ? null : quarterStep(net - previousNet),
      fieldScores: scores,
      tytScore: tytScore,
      defaultField: scores.isEmpty ? null : (userField ?? scores.keys.first),
    );
  }

  /// Nets move in quarter steps (D − Y ÷ 4), so the difference of two of them
  /// is exact; the rounding only guards a net the server rounded itself.
  static double quarterStep(double value) => (value * 4).round() / 4;

  /// The result's id.
  final String examId;

  /// TYT or AYT; `null` for a type this build does not know.
  final NetExamType? kind;

  /// "Türkiye Geneli Deneme 6"; `null` when the server sent none (the screen
  /// writes "AYT denemesi").
  final String? name;

  /// "Örnek Yayınları"; `null` on a TYT result.
  final String? publisher;

  /// Cover file name (or URL) as the server sent it.
  final String? coverFile;
  final DateTime date;

  /// The net the server calculated (or `D − Y ÷ 4` when it sent none).
  final double net;
  final DybCounts counts;

  /// The net minus the previous exam's net, same type; `null` without one.
  final double? delta;

  /// The AYT score types that have data, by field. Empty for TYT.
  final Map<AytField, MomentScore> fieldScores;

  /// The TYT result's points and rank (slot 0); [MomentScore.none] for AYT or
  /// when the data has none.
  final MomentScore tytScore;

  /// The segment the moment opens on.
  final AytField? defaultField;

  /// "TYT" or "AYT"; empty for a type the app does not know.
  String get typeLabel => kind?.label ?? '';

  /// The "Puan türü" segment is drawn: an AYT result with a score type that
  /// has data. A TYT result has no score type (kare 2).
  bool get hasFieldSegment => fieldScores.isNotEmpty;

  /// What to draw for [field]; [MomentScore.none] when the data has nothing.
  MomentScore scoreOf(AytField field) => fieldScores[field] ?? MomentScore.none;

  /// What the score area draws when [field] is the selected segment: the
  /// chosen score type of an AYT result, the plain points of a TYT result.
  MomentScore scoreFor(AytField? field) {
    if (kind == NetExamType.tyt) return tytScore;
    if (field == null) return MomentScore.none;
    return scoreOf(field);
  }

  static String? _clean(String? text) {
    final trimmed = text?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  @override
  bool operator ==(Object other) =>
      other is ResultMomentModel &&
      other.examId == examId &&
      other.kind == kind &&
      other.name == name &&
      other.publisher == publisher &&
      other.coverFile == coverFile &&
      other.date == date &&
      other.net == net &&
      other.counts == counts &&
      other.delta == delta &&
      mapEquals(other.fieldScores, fieldScores) &&
      other.tytScore == tytScore &&
      other.defaultField == defaultField;

  @override
  int get hashCode => Object.hash(
    examId,
    kind,
    name,
    publisher,
    coverFile,
    date,
    net,
    counts,
    delta,
    Object.hashAll(fieldScores.entries.map((e) => Object.hash(e.key, e.value))),
    tytScore,
    defaultField,
  );
}
