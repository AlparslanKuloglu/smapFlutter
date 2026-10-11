import 'package:smap/features/exams/data/dtos/mock_exam_dto.dart';
import 'package:smap/features/exams/data/mappers/exam_mappers.dart';
import 'package:smap/features/exams/domain/exam_summary.dart';

/// Result of a TYT exam as `getMyMockExams` lists it (legacy field names).
Map<String, Object?> tytResultJson({
  String id = 'res-1',
  Object? net = 74.75,
}) => {
  '_id': id,
  'itemName': 'TYT Genel Deneme 9',
  'publisherName': 'Smap Yayınları',
  'net': net,
  'true': 80,
  'wrong': 21,
  'pass': 19,
  'date': '2026-09-28T09:30:00.000Z',
  'isStarred': false,
  'mexam': {
    '_id': 'exam-9',
    'order': 9,
    'type': 1,
    'image': 'cover9.png',
    'questionCount': 120,
  },
  'points': ['412,63', '', null, null, null],
  'ranks': ['48.215', null, null, null, null],
  'pointsHam': [380.5, null, null, null, null],
  'ranksHam': [51000, null, null, null, null],
  'lessonInfo':
      '[{"true":30,"wrong":6,"pass":4},{"true":15,"wrong":3,"pass":2},'
      '{"true":20,"wrong":10,"pass":10},{"true":15,"wrong":2,"pass":3}]',
  'questionsArrStr':
      '[[{"order":1,"type":1},{"order":2,"type":3},{"order":3,"type":2}],'
      '[{"order":1,"type":1}],[],[{"order":1,"type":3}]]',
  'lessonmockexams': [
    {
      'lesson': '663e37a24fb443839593141b',
      'net': 28.5,
      'true': 30,
      'wrong': 6,
      'pass': 4,
    },
    {
      'lesson': '66214a6982ff212039ea3294',
      'net': 4,
      'true': 4,
      'wrong': 0,
      'pass': 1,
    },
  ],
};

/// Result of an AYT exam, with the `aytNets` breakdown.
Map<String, Object?> aytResultJson() => {
  '_id': 'res-2',
  'itemName': 'AYT Deneme 3',
  'net': '55',
  'true': 60,
  'wrong': 20,
  'pass': 80,
  'date': '2026-08-02',
  'mexam': {'_id': 'exam-3', 'order': 3, 'type': 2, 'image': ''},
  'points': [null, null, 410.2, 395.1, 380.0],
  'ranks': [null, null, 1200, '2.345', 3000],
  'aytNets': {
    '2': {'net': 55, 'true': 60, 'wrong': 20, 'pass': 80},
    '3': {'net': 50.5, 'true': 55, 'wrong': 18, 'pass': 87},
    '4': {'net': '40', 'true': 45, 'wrong': 20, 'pass': 95},
  },
  'lessonMockExams': [
    {'lesson': 'ayt-mat', 'net': 20, 'true': 22, 'wrong': 8, 'pass': 0},
  ],
};

/// The `getMyMockExams` answer holding [results].
Map<String, Object?> examsAnswer(List<Object?> results) => {
  'success': true,
  'enrichedMockExams': results,
};

/// A `getMexamSubjectDetail` answer: two lessons, topics in server order.
Map<String, Object?> topicAnalysisAnswer() => {
  'success': true,
  'data': {
    'Türkçe': {
      'Sözcükte Anlam': {
        'trueValue': 3,
        'wrongValue': 1,
        'passValue': 0,
        'netRate': 0.75,
      },
      'Paragraf': {'trueValue': 5, 'wrongValue': 2, 'passValue': 1},
    },
    'Tarih': {
      'İslamiyet Öncesi Türk Tarihi': {
        'trueValue': '2',
        'wrongValue': 0,
        'passValue': 1,
      },
    },
  },
};

/// The definition of [tytResultJson]'s exam as the repository would hand it
/// out (with or without the server's own object).
ExamDefinition repositoryExam({bool withObject = true}) {
  final definition = MockExamDto.fromJson(tytResultJson()).mexam!.toDomain();
  if (withObject) return definition;
  return ExamDefinition(
    id: definition.id,
    order: definition.order,
    kind: definition.kind,
    imageFile: definition.imageFile,
  );
}
