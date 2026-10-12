import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/application/exam_detail_model.dart';
import 'package:smap/features/exams/data/dtos/mock_exam_dto.dart';
import 'package:smap/features/exams/data/mappers/exam_mappers.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';

import 'exam_detail_fixtures.dart';

void main() {
  group('ExamDetailTab.parse', () {
    test('reads the query values', () {
      expect(ExamDetailTab.parse('sorular'), ExamDetailTab.questions);
      expect(ExamDetailTab.parse('konular'), ExamDetailTab.topics);
      expect(ExamDetailTab.parse('kartlar'), ExamDetailTab.cards);
    });

    test('none or unknown opens Genel', () {
      expect(ExamDetailTab.parse(null), ExamDetailTab.general);
      expect(ExamDetailTab.parse('x'), ExamDetailTab.general);
    });
  });

  group('ExamTestLabel', () {
    test('Matematik is "Temel Matematik" only in a TYT', () {
      expect(
        ExamTestLabel.of(NetExamType.tyt, ExamTestKind.mathematics),
        ExamTestLabel.basicMathematics,
      );
      expect(
        ExamTestLabel.of(NetExamType.ayt, ExamTestKind.mathematics),
        ExamTestLabel.mathematics,
      );
    });

    test('an unknown test has no label', () {
      expect(ExamTestLabel.of(NetExamType.ayt, null), isNull);
    });
  });

  group('ExamHeaderModel (pano 5.3)', () {
    test('AYT with the student\'s field: placement and raw points', () {
      final header = ExamHeaderModel.of(
        aytDetail(),
        field: AytField.equalWeight,
      );
      expect(header.name, 'Türkiye Geneli Deneme 6');
      expect(header.publisher, 'Örnek Yayınları');
      expect(header.net, 67.5);
      expect(header.counts, const DybCounts(correct: 86, wrong: 74, blank: 0));
      expect(header.kind, NetExamType.ayt);
      expect(header.score, isNotNull);
      expect(header.score!.field, AytField.equalWeight);
      expect(header.score!.point, 412.63);
      expect(header.score!.rank, 48215);
      expect(header.score!.pointHam, 398.12);
      expect(header.score!.rankHam, 52904);
    });

    test('Sayısal reads its own slot', () {
      final header = ExamHeaderModel.of(aytDetail(), field: AytField.numeric);
      expect(header.score!.point, 398.0);
      expect(header.score!.rank, 50000);
      expect(header.score!.hasRaw, isFalse);
    });

    test('without a known field an AYT has no score block', () {
      expect(ExamHeaderModel.of(aytDetail()).score, isNull);
    });

    test('a TYT without scores draws no block (kare 3)', () {
      final header = ExamHeaderModel.of(tytDetail());
      expect(header.score, isNull);
      expect(header.name, 'TYT Genel Deneme 9');
      expect(header.publisher, isNull);
    });

    test('a TYT with scores is titled TYT (field null)', () {
      final exam = MockExamDto.fromJson({
        ...tytDetailJson(),
        'points': ['384,05'],
        'ranks': ['176.320'],
        'pointsHam': [371.9],
        'ranksHam': [189004],
      }).toDetail()!;
      final header = ExamHeaderModel.of(exam, field: AytField.verbal);
      expect(header.score!.field, isNull);
      expect(header.score!.point, 384.05);
      expect(header.score!.rankHam, 189004);
    });

    test('raw values missing leave the raw row out', () {
      final header = ExamHeaderModel.of(
        aytDetail(withRaw: false),
        field: AytField.equalWeight,
      );
      expect(header.score!.hasPlacement, isTrue);
      expect(header.score!.hasRaw, isFalse);
    });

    test('a blank name is no name; the net falls back to the counts', () {
      final exam = MockExamDto.fromJson({
        ...tytDetailJson(),
        'itemName': '  ',
        'net': null,
      }).toDetail()!;
      final header = ExamHeaderModel.of(exam);
      expect(header.name, isNull);
      expect(header.net, 74.75);
    });
  });

  group('ExamGeneralModel (pano 5.3)', () {
    test('AYT: four tests with the server\'s nets, in order', () {
      final general = ExamGeneralModel.of(aytDetail());
      expect(general.hasBreakdown, isTrue);
      expect(general.tests.map((t) => t.net), [18.75, 11.25, 21.25, 16.25]);
      expect(general.tests.map((t) => t.label), [
        ExamTestLabel.socialSciencesLiterature,
        ExamTestLabel.socialSciences2,
        ExamTestLabel.mathematics,
        ExamTestLabel.sciences,
      ]);
      expect(
        general.tests.first.counts,
        const DybCounts(correct: 23, wrong: 17, blank: 0),
      );
    });

    test('nets by score type: Eşit Ağırlık, Sayısal, Sözel', () {
      final general = ExamGeneralModel.of(aytDetail());
      expect(
        [for (final n in general.scoreTypeNets) (n.field, n.net)],
        [
          (AytField.equalWeight, 40.0),
          (AytField.numeric, 37.5),
          (AytField.verbal, 30.0),
        ],
      );
    });

    test('TYT: tests with their labels, no score type nets', () {
      final general = ExamGeneralModel.of(tytDetail());
      expect(general.tests.map((t) => t.label), [
        ExamTestLabel.turkish,
        ExamTestLabel.socialSciences,
        ExamTestLabel.basicMathematics,
        ExamTestLabel.sciences,
      ]);
      expect(general.tests[2].counts.blank, 13);
      expect(general.scoreTypeNets, isEmpty);
    });

    test('the server\'s net wins over the arithmetic', () {
      final exam = MockExamDto.fromJson({
        ...tytDetailJson(),
        'lessonInfo': '[{"net":19,"true":22,"wrong":5,"pass":13}]',
      }).toDetail()!;
      expect(exam.tests.single.net, 19);
      expect(ExamGeneralModel.of(exam).tests.single.net, 19);
    });

    test('a test without the server net uses D − Y ÷ 4', () {
      final exam = MockExamDto.fromJson({
        ...tytDetailJson(),
        'lessonInfo': '[{"true":22,"wrong":5,"pass":13}]',
      }).toDetail()!;
      expect(ExamGeneralModel.of(exam).tests.single.net, 20.75);
    });

    test('no lessonInfo: no breakdown (pano 5.8 kare 2)', () {
      final exam = MockExamDto.fromJson({
        ...tytDetailJson(),
        'lessonInfo': null,
      }).toDetail()!;
      expect(ExamGeneralModel.of(exam).hasBreakdown, isFalse);
    });
  });
}
