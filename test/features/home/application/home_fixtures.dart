import 'package:smap/features/exams/data/dtos/mock_exam_dto.dart';
import 'package:smap/features/exams/data/mappers/exam_mappers.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';

/// `getMyMockExams` result as the legacy list sends it, with the values of the
/// design's Ek C: "Türkiye Geneli Deneme 6", AYT, 67,5 net, 86 / 74 / 0.
Map<String, Object?> examJson({
  String id = 'res-6',
  String? name = 'Türkiye Geneli Deneme 6',
  String? publisher = 'Örnek Yayınları',
  int type = 2,
  Object? net = 67.5,
  int correct = 86,
  int wrong = 74,
  int blank = 0,
  String? date = '2026-10-05',
}) => {
  '_id': id,
  'itemName': ?name,
  'publisherName': ?publisher,
  'net': net,
  'true': correct,
  'wrong': wrong,
  'pass': blank,
  'date': ?date,
  'mexam': {'_id': 'exam-$id', 'order': 6, 'type': type},
};

ExamDetail examDetail(Map<String, Object?> json) =>
    MockExamDto.fromJson(json).toDetail()!;

/// `getMexamSubjectDetail`: the Konu Analizi with the board's weakest topic
/// (13 questions, 9 wrong).
Map<String, Object?> topicAnalysisJson() => {
  'success': true,
  'data': {
    'Tarih': {
      'Kurtuluş Savaşı Hazırlık Dönemi': {
        'trueValue': 4,
        'wrongValue': 9,
        'passValue': 0,
      },
      'İslamiyet Öncesi Türk Tarihi': {
        'trueValue': 5,
        'wrongValue': 3,
        'passValue': 0,
      },
    },
    'Türkçe': {
      'Paragraf': {'trueValue': 12, 'wrongValue': 2, 'passValue': 1},
    },
  },
};
