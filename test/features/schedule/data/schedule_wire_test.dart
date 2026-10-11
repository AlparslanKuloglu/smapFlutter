import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/schedule/data/requests/schedule_wire.dart';
import 'package:smap/features/schedule/domain/weekly_draft.dart';

void main() {
  group('taskToWire', () {
    test('writes the keys the legacy editor wrote', () {
      final wire = taskToWire(
        ProgramTaskDraft(
          id: 'task-1',
          day: DateTime(2026, 10, 12, 23),
          hour: 9,
          minute: 5,
          lessonId: 'lesson-1',
          title: 'Fiilde Çatı',
          lessonName: 'Türkçe',
          mainSubjectId: 'main-1',
          subjectId: 'konu-1',
          itemId: 'item-1',
          lessonColor: '#2f6fde',
          mapImage: 'assets/icons/open-book.png',
        ),
      );

      expect(wire, {
        'id': 'task-1',
        'day': '2026-10-12',
        'hour': 9,
        'minute': 5,
        'lesson': 'lesson-1',
        'lessonName': 'Türkçe',
        'mainSubject': 'main-1',
        'subject': 'konu-1',
        'item': 'item-1',
        'title': 'Fiilde Çatı',
        'category': '0',
        'lessonColor': '#2F6FDE',
        'mapImage': 'open-book.png',
      });
    });

    test('sends empty text for absent ids and the default color', () {
      final wire = taskToWire(
        ProgramTaskDraft(
          id: 'task-1',
          day: DateTime(2026, 10, 12),
          hour: 9,
          minute: 0,
          lessonId: 'lesson-1',
          title: 'Konu',
        ),
      );

      expect(wire['lessonName'], '');
      expect(wire['mainSubject'], '');
      expect(wire['subject'], '');
      expect(wire['item'], '');
      expect(wire['mapImage'], '');
      expect(wire['lessonColor'], '#000000');
    });
  });

  group('weeklyToDataObj', () {
    final draft = WeeklyDraft(
      name: '  Hafta  ',
      motto: ' Devam ',
      tasks: [
        ProgramTaskDraft(
          id: 'a',
          day: DateTime(2026, 10, 12),
          hour: 9,
          minute: 0,
          lessonId: 'l',
          title: 't',
        ),
      ],
    );

    test('a new program has no weeklyId', () {
      final data = weeklyToDataObj(draft);

      expect(data['name'], 'Hafta');
      expect(data['motto'], 'Devam');
      expect(data['tasks'], hasLength(1));
      expect(data.containsKey('weeklyId'), isFalse);
    });

    test('an update carries the weeklyId', () {
      expect(weeklyToDataObj(draft, weeklyId: 'w1')['weeklyId'], 'w1');
    });
  });

  group('normalizeHexColor', () {
    test('accepts the forms the app has met', () {
      expect(normalizeHexColor('#2f6fde'), '#2F6FDE');
      expect(normalizeHexColor('2F6FDE'), '#2F6FDE');
      expect(normalizeHexColor('0xFF2F6FDE'), '#2F6FDE');
      expect(normalizeHexColor('#FF2F6FDE'), '#2F6FDE');
      expect(normalizeHexColor('  #abcdef '), '#ABCDEF');
    });

    test('reads the legacy Color(...) text', () {
      expect(
        normalizeHexColor(
          'Color(alpha: 1.0000, red: 1.0000, green: 0.0000, blue: 0.5020, '
          'colorSpace: ColorSpace.sRGB)',
        ),
        '#FF0080',
      );
    });

    test('rejects everything else', () {
      expect(normalizeHexColor(null), isNull);
      expect(normalizeHexColor(''), isNull);
      expect(normalizeHexColor('red'), isNull);
      expect(normalizeHexColor('#12345'), isNull);
      expect(normalizeHexColor('#GGGGGG'), isNull);
      expect(normalizeHexColor('Color(alpha: 1.0)'), isNull);
    });
  });
}
