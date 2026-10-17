import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/exams/application/exam_detail_model.dart';
import 'package:smap/features/exams/domain/exam_scores.dart';
import 'package:smap/features/exams/presentation/widgets/exam_score_card.dart';
import 'package:smap/l10n/app_localizations_tr.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';

/// Tur 12 B (pano 14.4): the score card's reading sentences, number formats
/// and the score slots, with the board's example values.
void main() {
  final l10n = AppLocalizationsTr();

  group('ExamScoreCard.rowSpeech (pano 14.4 Erişilebilirlik)', () {
    test('placement row: "Yerleştirme puanı 412,63, sıra 48.215"', () {
      expect(
        ExamScoreCard.rowSpeech(
          l10n,
          label: l10n.exams_placementScore,
          points: 412.63,
          rank: 48215,
        ),
        'Yerleştirme puanı 412,63, sıra 48.215',
      );
    });

    test('raw row: "Ham puan 398,12, sıra 52.904"', () {
      expect(
        ExamScoreCard.rowSpeech(
          l10n,
          label: l10n.examDetail_rawScore,
          points: 398.12,
          rank: 52904,
        ),
        'Ham puan 398,12, sıra 52.904',
      );
    });

    test('TYT values keep the thousands dot and drop the ordinal dot', () {
      expect(
        ExamScoreCard.rowSpeech(
          l10n,
          label: l10n.exams_placementScore,
          points: 384.05,
          rank: 176320,
        ),
        'Yerleştirme puanı 384,05, sıra 176.320',
      );
    });

    test('a missing value is left out of the sentence', () {
      expect(
        ExamScoreCard.rowSpeech(
          l10n,
          label: l10n.examDetail_rawScore,
          points: 398.12,
        ),
        'Ham puan 398,12',
      );
      expect(
        ExamScoreCard.rowSpeech(
          l10n,
          label: l10n.examDetail_rawScore,
          rank: 52904,
        ),
        'Ham puan sırası 52.904',
      );
      expect(
        ExamScoreCard.rowSpeech(l10n, label: l10n.examDetail_rawScore),
        isNull,
      );
    });
  });

  group('Number formats on the card', () {
    test('rank is written with the ordinal dot', () {
      expect(TrFormat.siraOrdinal(48215), '48.215.');
      expect(TrFormat.siraOrdinal(52904), '52.904.');
      expect(TrFormat.siraOrdinal(176320), '176.320.');
      expect(TrFormat.puan(412.63), '412,63');
      expect(TrFormat.puan(371.9), '371,90');
    });
  });

  group('Score slots (AYT, TYT)', () {
    const scores = ExamScores(
      points: [384.05, null, 398.0, 412.63, 401.2],
      pointsHam: [371.9, null, null, 398.12, null],
      ranks: [176320, null, 50000, 48215, 49000],
      ranksHam: [189004, null, null, 52904, null],
    );

    test('TYT reads slot 0', () {
      final entry = scores.forExam(NetExamType.tyt, null)!;
      expect(entry.point, 384.05);
      expect(entry.rank, 176320);
      expect(entry.pointHam, 371.9);
      expect(entry.rankHam, 189004);
    });

    test('an AYT reads its aimType slot; an unknown field reads nothing', () {
      expect(scores.forExam(NetExamType.ayt, null), isNull);
    });

    test('no arrays at all: the entry is empty and no card is drawn', () {
      final entry = ExamScores.none.at(3);
      expect(entry.isEmpty, isTrue);
      final view = ExamScoreView(
        field: null,
        point: entry.point,
        rank: entry.rank,
        pointHam: entry.pointHam,
        rankHam: entry.rankHam,
      );
      expect(view.hasPlacement, isFalse);
      expect(view.hasRaw, isFalse);
    });
  });
}
