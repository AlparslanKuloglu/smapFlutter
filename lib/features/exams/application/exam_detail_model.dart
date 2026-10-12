import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';

/// The four sections of Deneme Detay (pano 5.3 to 5.6; route
/// `?tab=genel|sorular|konular|kartlar`).
enum ExamDetailTab {
  /// Genel.
  general('genel'),

  /// Sorular.
  questions('sorular'),

  /// Konular.
  topics('konular'),

  /// Kartlar.
  cards('kartlar');

  const ExamDetailTab(this.key);

  /// The `tab` query value.
  final String key;

  /// The tab a query value names; [general] for none or an unknown one.
  static ExamDetailTab parse(String? key) {
    for (final tab in values) {
      if (tab.key == key) return tab;
    }
    return general;
  }
}

/// The name of a test of an exam as the screen writes it (pano 5.3: "Türk
/// Dili ve Edebiyatı–Sosyal Bilimler 1", "Sosyal Bilimler 2", "Temel
/// Matematik"). The words live in l10n; this only picks which one.
enum ExamTestLabel {
  /// TYT "Türkçe".
  turkish,

  /// TYT "Sosyal Bilimler".
  socialSciences,

  /// AYT "Türk Dili ve Edebiyatı–Sosyal Bilimler 1".
  socialSciencesLiterature,

  /// AYT "Sosyal Bilimler 2".
  socialSciences2,

  /// TYT "Temel Matematik".
  basicMathematics,

  /// AYT "Matematik".
  mathematics,

  /// "Fen Bilimleri".
  sciences;

  /// The label of [kind] in an exam of [exam]; `null` for a test the app does
  /// not know (a fifth test).
  static ExamTestLabel? of(NetExamType? exam, ExamTestKind? kind) =>
      switch (kind) {
        null => null,
        ExamTestKind.turkish => turkish,
        ExamTestKind.socialSciences => socialSciences,
        ExamTestKind.socialSciences1 => socialSciencesLiterature,
        ExamTestKind.socialSciences2 => socialSciences2,
        ExamTestKind.mathematics =>
          exam == NetExamType.tyt ? basicMathematics : mathematics,
        ExamTestKind.sciences => sciences,
      };
}

/// The score block of the header (pano 5.3 kare 1, Tur 12 B 14.4): the points
/// and ranks of the score type that counts for the student.
@immutable
class ExamScoreView {
  const ExamScoreView({
    required this.field,
    this.point,
    this.rank,
    this.pointHam,
    this.rankHam,
  });

  /// The student's AYT field ("Eşit Ağırlık"); `null` is the TYT block, titled
  /// "TYT".
  final AytField? field;

  /// "Yerleştirme puanı", "412,63".
  final double? point;

  /// "Sıra", "48.215.".
  final int? rank;

  /// "Ham puan"; `null` draws no second row.
  final double? pointHam;

  /// The raw points' rank.
  final int? rankHam;

  /// A placement row has something to show.
  bool get hasPlacement => point != null || rank != null;

  /// A raw row has something to show.
  bool get hasRaw => pointHam != null || rankHam != null;

  @override
  bool operator ==(Object other) =>
      other is ExamScoreView &&
      other.field == field &&
      other.point == point &&
      other.rank == rank &&
      other.pointHam == pointHam &&
      other.rankHam == rankHam;

  @override
  int get hashCode => Object.hash(field, point, rank, pointHam, rankHam);
}

/// What the header of Deneme Detay draws (C26 `ExamHeader`; pano 5.3). A field
/// the data does not have is `null` and is not drawn.
@immutable
class ExamHeaderModel {
  const ExamHeaderModel({
    required this.kind,
    this.name,
    this.publisher,
    this.date,
    this.net,
    this.counts,
    this.coverFile,
    this.score,
  });

  /// Reads the header out of a result. [field] is the signed-in student's AYT
  /// field: without it an AYT result has no score block (nothing is guessed);
  /// a TYT result reads slot 0.
  factory ExamHeaderModel.of(ExamDetail detail, {AytField? field}) {
    final summary = detail.summary;
    final entry = detail.scoreFor(field);
    final hasScore = entry != null && !entry.isEmpty;
    return ExamHeaderModel(
      kind: summary.kind,
      name: _clean(summary.name),
      publisher: _clean(summary.publisherName),
      date: summary.date,
      net: summary.net ?? summary.counts?.net,
      counts: summary.counts,
      coverFile: summary.definition.imageFile,
      score: !hasScore
          ? null
          : ExamScoreView(
              field: summary.kind == NetExamType.tyt ? null : field,
              point: entry.point,
              rank: entry.rank,
              pointHam: entry.pointHam,
              rankHam: entry.rankHam,
            ),
    );
  }

  /// TYT or AYT; `null` for a type this build does not know.
  final NetExamType? kind;

  /// "Türkiye Geneli Deneme 6"; `null` when the server sent none (the screen
  /// writes "AYT denemesi").
  final String? name;
  final String? publisher;
  final DateTime? date;
  final double? net;
  final DybCounts? counts;

  /// Cover file name (or URL) as the server sent it.
  final String? coverFile;
  final ExamScoreView? score;

  /// "TYT" or "AYT"; empty for a type the app does not know.
  String get typeLabel => kind?.label ?? '';

  static String? _clean(String? text) {
    final trimmed = text?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  @override
  bool operator ==(Object other) =>
      other is ExamHeaderModel &&
      other.kind == kind &&
      other.name == name &&
      other.publisher == publisher &&
      other.date == date &&
      other.net == net &&
      other.counts == counts &&
      other.coverFile == coverFile &&
      other.score == score;

  @override
  int get hashCode =>
      Object.hash(kind, name, publisher, date, net, counts, coverFile, score);
}

/// One test of the exam in the Genel list (C25 `TestBarRow`; pano 5.3).
@immutable
class TestRow {
  const TestRow({
    required this.index,
    required this.counts,
    required this.net,
    this.label,
  });

  /// Position of the test (0-based).
  final int index;

  /// `null` for a test the app has no name for.
  final ExamTestLabel? label;
  final DybCounts counts;

  /// The server's net of the test; when it sent none, the arithmetic of the
  /// counts ("doğru − yanlış ÷ 4").
  final double net;

  @override
  bool operator ==(Object other) =>
      other is TestRow &&
      other.index == index &&
      other.label == label &&
      other.counts == counts &&
      other.net == net;

  @override
  int get hashCode => Object.hash(index, label, counts, net);
}

/// The net of an AYT score type ("Eşit Ağırlık 40").
@immutable
class ScoreTypeNet {
  const ScoreTypeNet({required this.field, required this.net});

  final AytField field;
  final double net;

  @override
  bool operator ==(Object other) =>
      other is ScoreTypeNet && other.field == field && other.net == net;

  @override
  int get hashCode => Object.hash(field, net);
}

/// The Genel tab (pano 5.3): the tests with their bars, the net rule and the
/// nets by score type.
@immutable
class ExamGeneralModel {
  const ExamGeneralModel({
    this.tests = const [],
    this.scoreTypeNets = const [],
  });

  /// Builds the tab out of a result.
  factory ExamGeneralModel.of(ExamDetail detail) {
    final exam = detail.kind;
    final rows = <TestRow>[
      for (final test in detail.tests)
        if (test.counts case final counts?)
          TestRow(
            index: test.index,
            label: ExamTestLabel.of(exam, test.kind),
            counts: counts,
            net: test.net ?? counts.net,
          ),
    ];
    final nets = <ScoreTypeNet>[
      for (final field in AytField.values)
        if (detail.aytNets[field]?.net case final net?)
          ScoreTypeNet(field: field, net: net),
    ];
    return ExamGeneralModel(tests: rows, scoreTypeNets: nets);
  }

  /// The tests that have D/Y/B, in order.
  final List<TestRow> tests;

  /// The nets of the score types, Eşit Ağırlık, Sayısal, Sözel; empty for a
  /// TYT result.
  final List<ScoreTypeNet> scoreTypeNets;

  /// The exam has no per-test result: "Ders kırılımı yok" (pano 5.8 kare 2).
  bool get hasBreakdown => tests.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      other is ExamGeneralModel &&
      listEquals(other.tests, tests) &&
      listEquals(other.scoreTypeNets, scoreTypeNets);

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(tests), Object.hashAll(scoreTypeNets));
}
