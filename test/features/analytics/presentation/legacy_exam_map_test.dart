import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/exams/data/dtos/mock_exam_dto.dart';
import 'package:smap/features/exams/data/mappers/exam_mappers.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';
import 'package:smap/features/legacy/legacy_links_e11.dart';

import '../../exams/data/exam_fixtures.dart';

ExamDetail _detail(Map<String, Object?> json) =>
    MockExamDto.fromJson(Map<String, dynamic>.of(json)).toDetail()!;

void main() {
  group('legacyExamMap', () {
    test('rebuilds what the legacy detail screen reads', () {
      final map = legacyExamMap(_detail(tytResultJson()));

      expect(map['_id'], 'res-1');
      expect(map['itemName'], 'TYT Genel Deneme 9');
      expect(map['net'], 74.75);
      expect([map['true'], map['wrong'], map['pass']], [80, 21, 19]);
      expect(map['mexam']['type'], 1);
      expect(map['mexam']['order'], 9);
      expect(map['ranks'][0], 48215);
      expect(map['points'][0], 412.63);

      final info = jsonDecode(map['lessonInfo'] as String) as List;
      expect(info, hasLength(4));
      expect(info.first, {'true': 30, 'wrong': 6, 'pass': 4});

      final questions = jsonDecode(map['questionsArrStr'] as String) as List;
      expect(questions, hasLength(4));
      expect((questions.first as List).map((q) => q['type']), [1, 3, 2]);

      final lessons = map['lessonmockexams'] as List;
      expect(lessons.first['lesson'], '663e37a24fb443839593141b');
      expect(lessons.first['true'], 30);
    });

    test('a result without counts leaves the totals out instead of 0', () {
      final map = legacyExamMap(
        _detail({
          '_id': 'x',
          'mexam': {'_id': 'e', 'order': 1, 'type': 2},
        }),
      );

      expect(map.containsKey('true'), isFalse);
      expect(map.containsKey('net'), isFalse);
      expect(map.containsKey('lessonInfo'), isFalse);
      expect(map['mexam']['type'], 2);
    });
  });
}
