import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/schedule/data/dtos/bag_item_dto.dart';
import 'package:smap/features/schedule/data/dtos/main_subject_dto.dart';
import 'package:smap/features/schedule/data/dtos/program_task_dto.dart';
import 'package:smap/features/schedule/data/dtos/weekly_dto.dart';

Map<String, Object?> taskJson({
  String id = 'task-1',
  Object? day = '2026-10-12',
  Object? hour = 10,
  Object? minute = 30,
}) => {
  'id': id,
  'day': day,
  'hour': hour,
  'minute': minute,
  'lesson': '69d3c972fdfe9f2106fa471e',
  'lessonName': 'Türkçe',
  'mainSubject': 'main-1',
  'subject': '',
  'item': '',
  'title': 'Fiilde Çatı',
  'category': '0',
  'lessonColor': '#2F6FDE',
  'mapImage': 'open-book.png',
};

void main() {
  group('ProgramTaskDto', () {
    test('reads a task as the legacy editor wrote it', () {
      final task = ProgramTaskDto.fromJson(taskJson());

      expect(task.id, 'task-1');
      expect(task.date, DateTime(2026, 10, 12));
      expect(task.hour, 10);
      expect(task.minute, 30);
      expect(task.lesson, '69d3c972fdfe9f2106fa471e');
      expect(task.title, 'Fiilde Çatı');
      expect(task.subject, isNull, reason: 'empty text is not a value');
      expect(task.item, isNull);
      expect(task.isPlaceable, isTrue);
      expect(task.minutesOfDay, 630);
    });

    test('reads hour and minute sent as text or decimals', () {
      final task = ProgramTaskDto.fromJson(taskJson(hour: '9', minute: 15.0));

      expect(task.hour, 9);
      expect(task.minute, 15);
    });

    test('a day with a time part keeps its written date', () {
      final task = ProgramTaskDto.fromJson(
        taskJson(day: '2026-10-12T21:30:00.000Z'),
      );

      expect(task.date, DateTime(2026, 10, 12));
    });

    test('is not placeable without a usable day or time', () {
      expect(ProgramTaskDto.fromJson(taskJson(day: null)).isPlaceable, isFalse);
      expect(
        ProgramTaskDto.fromJson(taskJson(day: 'tomorrow')).isPlaceable,
        isFalse,
      );
      expect(ProgramTaskDto.fromJson(taskJson(day: '2026-13-40')).date, isNull);
      expect(
        ProgramTaskDto.fromJson(taskJson(hour: null)).isPlaceable,
        isFalse,
      );
      expect(ProgramTaskDto.fromJson(taskJson(hour: 24)).isPlaceable, isFalse);
      expect(
        ProgramTaskDto.fromJson(taskJson(minute: 60)).isPlaceable,
        isFalse,
      );
      expect(ProgramTaskDto.fromJson(taskJson(hour: 'x')).minutesOfDay, isNull);
    });

    test('survives a task with wrong types and an empty object', () {
      final odd = ProgramTaskDto.fromJson({
        'id': 7,
        'title': ['not', 'text'],
        'lesson': {'_id': 'x'},
      });

      expect(odd.id, '7');
      expect(odd.title, isNull);
      expect(odd.lesson, isNull);
      expect(odd.isPlaceable, isFalse);
      expect(ProgramTaskDto.fromJson(const {}).isPlaceable, isFalse);
    });

    test('becomes an editor draft only when it can be placed', () {
      final draft = ProgramTaskDto.fromJson(taskJson()).toDraft()!;

      expect(draft.id, 'task-1');
      expect(draft.dayKey, '2026-10-12');
      expect(draft.hour, 10);
      expect(draft.lessonId, '69d3c972fdfe9f2106fa471e');
      expect(draft.title, 'Fiilde Çatı');
      expect(draft.mapImage, 'open-book.png');
      expect(ProgramTaskDto.fromJson(taskJson(day: null)).toDraft(), isNull);
      expect(
        ProgramTaskDto.fromJson({...taskJson(), 'lesson': null}).toDraft(),
        isNull,
      );
    });
  });

  group('WeeklyDto', () {
    Map<String, Object?> weeklyJson(Object? content) => {
      '_id': 'weekly-1',
      'name': 'Ekim 2. Hafta',
      'motto': 'Devam',
      'student': 'student-1',
      'content': content,
      '__v': 0,
    };

    test('reads content sent as a list', () {
      final weekly = WeeklyDto.fromJson(
        weeklyJson([taskJson(), taskJson(id: 'task-2', hour: 11)]),
      );

      expect(weekly.id, 'weekly-1');
      expect(weekly.name, 'Ekim 2. Hafta');
      expect(weekly.motto, 'Devam');
      expect(weekly.student, 'student-1');
      expect(weekly.tasks.map((t) => t.id), ['task-1', 'task-2']);
    });

    test('reads content sent as a JSON text', () {
      final weekly = WeeklyDto.fromJson(
        weeklyJson(jsonEncode([taskJson(), taskJson(id: 'task-2')])),
      );

      expect(weekly.tasks, hasLength(2));
      expect(weekly.tasks.first.title, 'Fiilde Çatı');
    });

    test('unreadable content is an empty program, not a failure', () {
      for (final content in [null, '', 'not json', 5, <String, Object?>{}]) {
        expect(WeeklyDto.fromJson(weeklyJson(content)).tasks, isEmpty);
      }
      expect(WeeklyDto.fromJson(const {}).tasks, isEmpty);
      expect(WeeklyDto.fromJson(const {}).id, isNull);
    });

    test('drops content entries that are not objects', () {
      final weekly = WeeklyDto.fromJson(weeklyJson([taskJson(), 'x', null, 3]));

      expect(weekly.tasks, hasLength(1));
    });

    test('reads a populated student as its id', () {
      final weekly = WeeklyDto.fromJson({
        ...weeklyJson(const []),
        'student': {'_id': 'student-9', 'name': 'Ayşe'},
      });

      expect(weekly.student, 'student-9');
    });

    test('lists its placed days once, oldest first', () {
      final weekly = WeeklyDto.fromJson(
        weeklyJson([
          taskJson(id: 'a', day: '2026-10-14'),
          taskJson(id: 'b', day: '2026-10-12'),
          taskJson(id: 'c', day: '2026-10-14'),
          taskJson(id: 'd', day: null),
        ]),
      );

      expect(weekly.days, [DateTime(2026, 10, 12), DateTime(2026, 10, 14)]);
      expect(weekly.placedTasks.map((t) => t.id), ['a', 'b', 'c']);
    });

    test('becomes an editor draft with the placeable tasks', () {
      final draft = WeeklyDto.fromJson(
        weeklyJson([taskJson(), taskJson(id: 'bad', day: null)]),
      ).toDraft();

      expect(draft.name, 'Ekim 2. Hafta');
      expect(draft.motto, 'Devam');
      expect(draft.tasks.map((t) => t.id), ['task-1']);
    });
  });

  group('BagItemDto', () {
    test('reads a bag item as getMyWeeklies sends it', () {
      final item = BagItemDto.fromJson({
        'student': 'student-1',
        'mainSubject': 'main-1',
        'data': {
          '_id': 'item-1',
          'name': 'Tarih Biliminin Tanımı',
          'konu': 'k1',
        },
        'lesson': {
          '_id': 'lesson-1',
          'name': 'TYT Tarih',
          'lessonColor': '#B8860B',
          'mapImage': 'historybook2.png',
        },
      });

      expect(item.student, 'student-1');
      expect(item.mainSubject, 'main-1');
      expect(item.data?.id, 'item-1');
      expect(item.data?.name, 'Tarih Biliminin Tanımı');
      expect(item.data?.subject, 'k1');
      expect(item.lesson?.id, 'lesson-1');
      expect(item.lesson?.name, 'TYT Tarih');
      expect(item.lesson?.mapImage, 'historybook2.png');
    });

    test('missing or wrong-typed parts read as null', () {
      final item = BagItemDto.fromJson({'data': 'oops', 'lesson': null});

      expect(item.data, isNull);
      expect(item.lesson, isNull);
      expect(item.student, isNull);
      expect(BagItemDto.fromJson(const {}).mainSubject, isNull);
    });
  });

  group('MainSubjectDto', () {
    test('reads id and name', () {
      final subject = MainSubjectDto.fromJson({'_id': 's1', 'name': 'Fiiller'});

      expect(subject.id, 's1');
      expect(subject.name, 'Fiiller');
      expect(MainSubjectDto.fromJson(const {}).name, isNull);
    });
  });
}
