import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/application/exam_detail_model.dart';
import 'package:smap/features/exams/data/dtos/mock_exam_dto.dart';
import 'package:smap/features/exams/data/mappers/exam_mappers.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';
import 'package:smap/features/exams/presentation/result_moment/result_moment_model.dart';

import '../../application/exam_detail_fixtures.dart';

ExamDetail _detail(Map<String, Object?> json) =>
    MockExamDto.fromJson(json).toDetail()!;

void main() {
  group('an AYT result (pano 5.1 kare 1)', () {
    // 67,5 net, 86 / 74 / 0, Eşit Ağırlık 412,63 and 48.215., EA 40, SAY
    // 37,5, SÖZ 30; the previous AYT had 59,25.
    final model = ResultMomentModel.of(
      aytDetail(),
      previousNet: 59.25,
      userField: AytField.equalWeight,
    )!;

    test('identity, net, counts and the change', () {
      expect(model.examId, 'res-6');
      expect(model.kind, NetExamType.ayt);
      expect(model.typeLabel, 'AYT');
      expect(model.name, 'Türkiye Geneli Deneme 6');
      expect(model.publisher, 'Örnek Yayınları');
      expect(model.coverFile, 'c6.png');
      expect(model.date.toUtc(), DateTime.utc(2026, 10, 5, 9));
      expect(model.net, 67.5);
      expect(model.counts, const DybCounts(correct: 86, wrong: 74, blank: 0));
      expect(model.delta, 8.25);
    });

    test('the segment opens on the student\'s field with its figures', () {
      expect(model.hasFieldSegment, isTrue);
      expect(model.defaultField, AytField.equalWeight);
      final score = model.scoreFor(AytField.equalWeight);
      expect(score.point, 412.63);
      expect(score.rank, 48215);
      expect(score.fieldNet, 40);
      expect(score.hasBoxes, isTrue);
    });

    test('another score type swaps the figures', () {
      final numeric = model.scoreFor(AytField.numeric);
      expect(numeric.fieldNet, 37.5);
      expect(numeric.point, 398);
      expect(numeric.rank, 50000);
      expect(model.scoreFor(AytField.verbal).fieldNet, 30);
    });

    test('the raw points are not part of the moment (Tur 12 B)', () {
      // The fixture carries raw points and ranks; the model has no field for
      // them, so the screen cannot draw them.
      expect(
        model.scoreFor(AytField.equalWeight),
        const MomentScore(point: 412.63, rank: 48215, fieldNet: 40),
      );
    });

    test('without a known field the first score type with data opens', () {
      final open = ResultMomentModel.of(aytDetail())!;
      expect(open.defaultField, AytField.equalWeight);
      expect(open.scoreFor(null), MomentScore.none);
    });
  });

  group('a TYT result with missing data (pano 5.1 kare 2)', () {
    final model = ResultMomentModel.of(tytDetail(), previousNet: 71.5)!;

    test('net, counts and the change; no publisher', () {
      expect(model.name, 'TYT Genel Deneme 9');
      expect(model.typeLabel, 'TYT');
      expect(model.net, 74.75);
      expect(model.counts, const DybCounts(correct: 80, wrong: 21, blank: 19));
      expect(model.publisher, isNull);
      expect(model.delta, 3.25);
    });

    test('no segment, no score boxes, no field net: nothing is invented', () {
      expect(model.hasFieldSegment, isFalse);
      expect(model.defaultField, isNull);
      expect(model.tytScore, MomentScore.none);
      expect(model.scoreFor(AytField.equalWeight), MomentScore.none);
      expect(model.scoreFor(null).hasBoxes, isFalse);
    });

    test(
      'a TYT result that has points shows them, still without a segment',
      () {
        final json = {
          ...tytDetailJson(),
          'points': ['384,05', null, null, null, null],
          'ranks': ['176.320', null, null, null, null],
        };
        final withPoints = ResultMomentModel.of(_detail(json))!;
        expect(withPoints.hasFieldSegment, isFalse);
        expect(withPoints.scoreFor(null).point, 384.05);
        expect(withPoints.scoreFor(null).rank, 176320);
        expect(withPoints.scoreFor(null).fieldNet, isNull);
      },
    );
  });

  group('the change', () {
    test('is not drawn without a previous exam of the type', () {
      expect(ResultMomentModel.of(aytDetail())!.delta, isNull);
    });

    test('a fall is negative and a tie is zero, in quarter steps', () {
      expect(ResultMomentModel.of(aytDetail(), previousNet: 70)!.delta, -2.5);
      expect(ResultMomentModel.of(aytDetail(), previousNet: 67.5)!.delta, 0);
    });

    test('quarterStep guards a net the server rounded itself', () {
      expect(ResultMomentModel.quarterStep(67.5 - 59.25), 8.25);
      expect(ResultMomentModel.quarterStep(8.2500001), 8.25);
      expect(ResultMomentModel.quarterStep(-0.12), 0);
    });
  });

  group('a result that cannot be drawn', () {
    test('without D/Y/B there is no moment', () {
      final json = {...aytDetailJson()}
        ..remove('true')
        ..remove('wrong')
        ..remove('pass');
      expect(ResultMomentModel.of(_detail(json)), isNull);
    });

    test('without a date there is no moment', () {
      final json = {...aytDetailJson()}..remove('date');
      expect(ResultMomentModel.of(_detail(json)), isNull);
    });

    test('a missing net falls back to D − Y ÷ 4', () {
      final json = {...tytDetailJson()}..remove('net');
      final model = ResultMomentModel.of(_detail(json))!;
      // 80 − 21 ÷ 4
      expect(model.net, 74.75);
    });
  });

  group('field tests (pano 5.1 "Eşit Ağırlık neti 40" line)', () {
    test(
      'Eşit Ağırlık is Türk Dili ve Edebiyatı–Sosyal Bilimler 1 + Matematik',
      () {
        expect(momentFieldTests(AytField.equalWeight), [
          ExamTestLabel.socialSciencesLiterature,
          ExamTestLabel.mathematics,
        ]);
      },
    );

    test(
      'Sayısal is Matematik + Fen, Sözel is TDE–SB1 + Sosyal Bilimler 2',
      () {
        expect(momentFieldTests(AytField.numeric), [
          ExamTestLabel.mathematics,
          ExamTestLabel.sciences,
        ]);
        expect(momentFieldTests(AytField.verbal), [
          ExamTestLabel.socialSciencesLiterature,
          ExamTestLabel.socialSciences2,
        ]);
      },
    );

    test('each score type\'s net is the sum of its two tests (Ek C)', () {
      final detail = aytDetail();
      double testNet(ExamTestLabel label) {
        final test = detail.tests.firstWhere(
          (t) => ExamTestLabel.of(NetExamType.ayt, t.kind) == label,
        );
        return test.net!;
      }

      for (final field in AytField.values) {
        final sum = momentFieldTests(
          field,
        ).fold<double>(0, (total, label) => total + testNet(label));
        expect(
          sum,
          detail.aytNets[field]!.net,
          reason: '${field.name} net equals its two tests',
        );
      }
    });
  });
}
