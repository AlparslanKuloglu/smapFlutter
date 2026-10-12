import 'dart:convert';

import 'package:smap/features/exams/data/dtos/mock_exam_dto.dart';
import 'package:smap/features/exams/data/mappers/exam_mappers.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';

/// The wrong questions of the first AYT test of pano 5.4 kare 1.
const List<int> firstTestWrong = [
  1, 2, 3, 4, 5, 7, 8, 11, 12, 13, 15, 18, 25, 31, 33, 35, 37, //
];

List<Map<String, Object?>> _cells(int count, Set<int> wrong, Set<int> blank) =>
    [
      for (var order = 1; order <= count; order++)
        {
          'order': order,
          'type': wrong.contains(order) ? 3 : (blank.contains(order) ? 2 : 1),
        },
    ];

/// "Türkiye Geneli Deneme 6" as `getMyMockExams` lists it: pano 5.3 kare 1
/// (AYT, 67,5 net, 86 / 74 / 0, Eşit Ağırlık 412,63 and 48.215., raw 398,12
/// and 52.904.). Test nets and counts are the board's.
Map<String, Object?> aytDetailJson({bool withRaw = true}) => {
  '_id': 'res-6',
  'itemName': 'Türkiye Geneli Deneme 6',
  'publisherName': 'Örnek Yayınları',
  'net': 67.5,
  'true': 86,
  'wrong': 74,
  'pass': 0,
  'date': '2026-10-05T09:00:00.000Z',
  'mexam': {'_id': 'exam-6', 'order': 6, 'type': 2, 'image': 'c6.png'},
  'points': [null, null, '412,63', '398,0', '380,2'],
  'ranks': [null, null, '48.215', 50000, 60000],
  if (withRaw) 'pointsHam': [null, null, 398.12, null, null],
  if (withRaw) 'ranksHam': [null, null, '52.904', null, null],
  'aytNets': {
    '2': {'net': 40, 'true': 50, 'wrong': 40, 'pass': 70},
    '3': {'net': 37.5, 'true': 49, 'wrong': 46, 'pass': 65},
    '4': {'net': 30, 'true': 45, 'wrong': 60, 'pass': 55},
  },
  'lessonInfo': jsonEncode([
    {'net': 18.75, 'true': 23, 'wrong': 17, 'pass': 0},
    {'net': 11.25, 'true': 17, 'wrong': 23, 'pass': 0},
    {'net': 21.25, 'true': 25, 'wrong': 15, 'pass': 0},
    {'net': 16.25, 'true': 21, 'wrong': 19, 'pass': 0},
  ]),
  'questionsArrStr': jsonEncode([
    _cells(40, firstTestWrong.toSet(), {}),
    _cells(40, {for (var i = 1; i <= 23; i++) i}, {}),
    _cells(40, {for (var i = 1; i <= 15; i++) i}, {}),
    _cells(40, {for (var i = 1; i <= 19; i++) i}, {}),
  ]),
  'lessonmockexams': const <Object?>[],
};

/// "TYT Genel Deneme 9" without scores: pano 5.3 kare 3 (80 / 21 / 19, 74,75
/// net; Türkçe 32/6/2, Sosyal 14/4/2, Temel Matematik 22/5/13, Fen 12/6/2).
Map<String, Object?> tytDetailJson() => {
  '_id': 'res-9',
  'itemName': 'TYT Genel Deneme 9',
  'net': 74.75,
  'true': 80,
  'wrong': 21,
  'pass': 19,
  'date': '2026-09-28T09:00:00.000Z',
  'mexam': {'_id': 'exam-9', 'order': 9, 'type': 1},
  'lessonInfo': jsonEncode([
    {'net': 30.5, 'true': 32, 'wrong': 6, 'pass': 2},
    {'net': 13, 'true': 14, 'wrong': 4, 'pass': 2},
    {'net': 20.75, 'true': 22, 'wrong': 5, 'pass': 13},
    {'net': 10.5, 'true': 12, 'wrong': 6, 'pass': 2},
  ]),
};

ExamDetail aytDetail({bool withRaw = true}) =>
    MockExamDto.fromJson(aytDetailJson(withRaw: withRaw)).toDetail()!;

ExamDetail tytDetail() => MockExamDto.fromJson(tytDetailJson()).toDetail()!;
