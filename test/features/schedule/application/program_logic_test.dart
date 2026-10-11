import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/features/schedule/application/hour_range.dart';
import 'package:smap/features/schedule/application/program_detail.dart';
import 'package:smap/features/schedule/application/program_entry.dart';
import 'package:smap/features/schedule/application/program_lessons.dart';
import 'package:smap/features/schedule/application/program_span.dart';
import 'package:smap/features/schedule/application/program_summary.dart';
import 'package:smap/features/schedule/application/topic_choice.dart';
import 'package:smap/features/schedule/application/week_grid_layout.dart';
import 'package:smap/features/schedule/data/dtos/bag_item_dto.dart';
import 'package:smap/features/schedule/data/dtos/main_subject_dto.dart';
import 'package:smap/features/schedule/data/dtos/weekly_dto.dart';

import '../program_fixtures.dart';

void main() {
  group('ProgramLessons', () {
    test('finds the subject from the id, then from the name', () {
      expect(ProgramLessons.subjectOf(lessonId: kTurkceId), SubjectKey.turkce);
      expect(
        ProgramLessons.subjectOf(lessonName: 'AYT Türk Dili ve Edebiyatı'),
        SubjectKey.edebiyat,
      );
      expect(ProgramLessons.subjectOf(lessonName: 'Satranç'), isNull);
      expect(ProgramLessons.subjectOf(), isNull);
    });

    test('names a lesson and cuts the exam prefix for small blocks', () {
      expect(
        ProgramLessons.nameOf(lessonId: kTurkceId, lessonName: ' TYT Türkçe '),
        'TYT Türkçe',
      );
      expect(ProgramLessons.nameOf(lessonId: kTurkceId), 'TYT Türkçe');
      expect(ProgramLessons.nameOf(lessonId: 'unknown'), '');
      expect(ProgramLessons.shortName('TYT Türkçe'), 'Türkçe');
      expect(ProgramLessons.shortName('AYT Tarih-2'), 'Tarih-2');
      expect(ProgramLessons.shortName('Türkçe'), 'Türkçe');
    });

    test('every exam lesson has a stored style', () {
      for (final lesson in ExamLessonCatalog.all) {
        final style = ProgramLessons.styleOf(lesson.id);
        expect(style, isNotNull, reason: lesson.name);
        expect(style!.colorHex, matches(RegExp(r'^#[0-9A-F]{6}$')));
        expect(style.mapImage, endsWith('.png'));
      }
    });
  });

  group('TopicChoice', () {
    test('a bag item keeps its item, subject and the lesson style', () {
      final bag = BagItemDto.fromJson({
        'student': 's1',
        'mainSubject': 'm-tarih',
        'data': {'_id': 'i1', 'name': 'Tarih Biliminin Tanımı', 'konu': 'k1'},
        'lesson': {
          '_id': kTytTarihId,
          'name': 'TYT Tarih',
          'lessonColor': '#ffeed6',
          'mapImage': 'assets/icons/icon2.png',
        },
      });
      final choice = TopicChoice.fromBag(bag)!;
      expect(choice.key, 'bag:i1');
      expect(choice.lessonName, 'TYT Tarih');
      final task = choice.toTask(day: DateTime(2026, 10, 12), hour: 16);
      expect(task.itemId, 'i1');
      expect(task.subjectId, 'k1');
      expect(task.mainSubjectId, 'm-tarih');
      expect(task.lessonColor, '#ffeed6');
      expect(task.hour, 16);
      expect(task.minute, 0);
      expect(task.dayKey, '2026-10-12');
    });

    test('a bag item without a lesson or a name cannot be planned', () {
      expect(TopicChoice.fromBag(const BagItemDto()), isNull);
      expect(
        TopicChoice.fromBag(
          BagItemDto.fromJson({
            'data': {'_id': 'i', 'name': ''},
            'lesson': {'_id': kTurkceId},
          }),
        ),
        isNull,
      );
    });

    test('a lesson topic takes the stored style of its lesson', () {
      final spec = ExamLessonCatalog.byId(kTurkceId)!;
      final choice = TopicChoice.fromMainSubject(
        spec,
        const MainSubjectDto(id: 'm1', name: 'Noktalama İşaretleri'),
      )!;
      expect(choice.key, 'lesson:$kTurkceId:m1');
      final task = choice.toTask(day: DateTime(2026, 10, 12), hour: 9);
      expect(task.lessonName, 'TYT Türkçe');
      expect(task.itemId, isNull);
      expect(task.lessonColor, '#F7EDE4');
      expect(task.mapImage, 'icon1.png');
      expect(
        TopicChoice.fromMainSubject(spec, const MainSubjectDto(id: 'x')),
        isNull,
      );
    });
  });

  group('ProgramSpan', () {
    test('widens the topic days to whole weeks', () {
      final span = ProgramSpan.of([DateTime(2026, 10, 10)], today: kToday);
      expect(span.first, DateTime(2026, 10, 5));
      expect(span.last, DateTime(2026, 10, 11));
      expect(span.days.length, 7);
      expect(span.rangeLabel, '5–11 Ekim 2026');
      expect(span.contains(DateTime(2026, 10, 11)), isTrue);
      expect(span.contains(DateTime(2026, 10, 12)), isFalse);
    });

    test('a program with no topic covers the week of today', () {
      final span = ProgramSpan.of(const [], today: kToday);
      expect(span, ProgramSpan.week(kToday));
    });

    test('two weeks and union', () {
      final span = ProgramSpan.of([
        DateTime(2026, 10, 7),
        DateTime(2026, 10, 14),
      ], today: kToday);
      expect(span.days.length, 14);
      final wider = span.union(ProgramSpan.week(DateTime(2026, 10, 25)));
      expect(wider.last, DateTime(2026, 10, 25));
      expect(wider.first, DateTime(2026, 10, 5));
    });

    test('date ranges across months and years', () {
      expect(
        ProgramDateRange.format(DateTime(2026, 10, 12), DateTime(2026, 10, 17)),
        '12–17 Ekim 2026',
      );
      expect(
        ProgramDateRange.format(
          DateTime(2026, 10, 12),
          DateTime(2026, 10, 17),
          withYear: false,
        ),
        '12–17 Ekim',
      );
      expect(
        ProgramDateRange.format(DateTime(2026, 9, 28), DateTime(2026, 10, 4)),
        '28 Eylül–4 Ekim 2026',
      );
      expect(
        ProgramDateRange.format(DateTime(2026, 12, 30), DateTime(2027, 1, 5)),
        '30 Aralık 2026–5 Ocak 2027',
      );
      expect(
        ProgramDateRange.format(DateTime(2026, 10, 10), DateTime(2026, 10, 10)),
        '10 Ekim 2026',
      );
    });

    test('the default name counts weeks from the week of the 1st', () {
      expect(ProgramNaming.weekOfMonth(DateTime(2026, 10, 5)), (
        month: 'Ekim',
        week: 2,
      ));
      expect(ProgramNaming.weekOfMonth(DateTime(2026, 10, 12)), (
        month: 'Ekim',
        week: 3,
      ));
      expect(ProgramNaming.weekOfMonth(DateTime(2026, 10, 1)), (
        month: 'Ekim',
        week: 1,
      ));
      expect(ProgramNaming.weekOfMonth(DateTime(2026, 10, 31)), (
        month: 'Ekim',
        week: 5,
      ));
    });
  });

  group('ProgramSummary and ProgramList', () {
    test('the board program is this week\'s on Cumartesi 10 Ekim', () {
      final summary = ProgramSummary.of(ekimIkinciHafta(), today: kToday)!;
      expect(summary.id, 'w-ekim-2');
      expect(summary.name, 'Ekim 2. Hafta');
      expect(summary.motto, 'Her gün biraz daha');
      expect(summary.isThisWeek, isTrue);
      expect(summary.span!.rangeLabel, '5–11 Ekim 2026');
    });

    test('a program of another week is not "Bu hafta"', () {
      final summary = ProgramSummary.of(
        ekimIkinciHafta(),
        today: DateTime(2026, 10, 12),
      )!;
      expect(summary.isThisWeek, isFalse);
    });

    test('a program without an id is left out', () {
      expect(
        ProgramSummary.of(const WeeklyDto(name: 'x'), today: kToday),
        isNull,
      );
    });

    test('this week first, then the newest span, empty programs last', () {
      WeeklyDto program(String id, String name, String? day) =>
          WeeklyDto.fromJson({
            '_id': id,
            'name': name,
            'content': [
              if (day != null)
                {
                  'id': 't$id',
                  'day': day,
                  'hour': 9,
                  'minute': 0,
                  'lesson': kTurkceId,
                  'title': 'Konu',
                },
            ],
          });
      final list = ProgramList.of([
        program('a', 'Eylül 4', '2026-09-23'),
        program('b', 'Boş', null),
        program('c', 'Ekim 3', '2026-10-14'),
        program('d', 'Ekim 2', '2026-10-08'),
      ], today: kToday);
      expect([for (final p in list.items) p.id], ['d', 'c', 'a', 'b']);
    });

    test('search folds Turkish letters in name and motto', () {
      final list = ProgramList.of([
        ekimIkinciHafta(),
        WeeklyDto.fromJson({
          '_id': 'k',
          'name': 'KASIM Programı',
          'motto': 'IŞIK',
        }),
        WeeklyDto.fromJson({
          '_id': 'z',
          'name': 'Zor hafta',
          'motto': 'İyi gider',
        }),
      ], today: kToday);
      expect([for (final p in list.matching('kasım').items) p.id], ['k']);
      expect([for (final p in list.matching('KASIM').items) p.id], ['k']);
      expect([for (final p in list.matching('ışık').items) p.id], ['k']);
      expect([for (final p in list.matching('isik').items) p.id], ['k']);
      expect([for (final p in list.matching('iyi').items) p.id], ['z']);
      expect(
        [for (final p in list.matching('biraz').items) p.id],
        ['w-ekim-2'],
      );
      expect(list.matching('   ').items.length, 3);
      expect(list.matching('yok böyle').items, isEmpty);
    });
  });

  group('ProgramEntry', () {
    test('reads what the rows need from a task', () {
      final entry = ProgramEntry.of(ekimIkinciHaftaDraft().tasks.first);
      expect(entry.timeLabel, '10:00');
      expect(entry.lessonName, 'TYT Türkçe');
      expect(entry.shortLesson, 'Türkçe');
      expect(entry.subject, SubjectKey.turkce);
      expect(entry.title, 'Fiilde Çatı');
      expect(entry.canOpenTopic, isTrue);
      expect(entry.minutes, 600);
    });
  });

  group('ProgramDetail', () {
    ProgramDetail detail({
      ProgramSpan? keepSpan,
      DateTime? today,
      bool empty = false,
    }) {
      final draft = ekimIkinciHaftaDraft();
      return ProgramDetail.of(
        id: 'w-ekim-2',
        draft: empty ? draft.copyWith(tasks: const []) : draft,
        today: today ?? kToday,
        keepSpan: keepSpan,
      );
    }

    test('lists the days of the span and the entries of each day', () {
      final d = detail();
      expect(d.days.length, 7);
      expect(d.countOn(DateTime(2026, 10, 10)), 3);
      expect(d.countOn(DateTime(2026, 10, 9)), 0);
      expect(
        [for (final e in d.entriesOn(DateTime(2026, 10, 10))) e.timeLabel],
        ['10:00', '14:00', '20:00'],
      );
    });

    test('opens on today, else the requested day, else the first topic', () {
      final d = detail();
      expect(d.openingDay(today: kToday), DateTime(2026, 10, 10));
      expect(
        d.openingDay(today: kToday, requested: DateTime(2026, 10, 8)),
        DateTime(2026, 10, 8),
      );
      expect(
        d.openingDay(today: kToday, requested: DateTime(2026, 11, 8)),
        DateTime(2026, 10, 10),
      );
      expect(
        d.openingDay(today: DateTime(2026, 11, 2)),
        DateTime(2026, 10, 10),
      );
    });

    test('a reset day keeps its place in the strip', () {
      final before = detail();
      final after = detail(empty: true, keepSpan: before.span);
      expect(after.entries, isEmpty);
      expect(after.span, before.span);
      expect(after.days.length, 7);
      // Without the kept span the empty program falls back to today's week.
      final fallback = detail(empty: true, today: DateTime(2026, 11, 2));
      expect(fallback.span, ProgramSpan.week(DateTime(2026, 11, 2)));
    });

    test('value equality', () {
      expect(detail(), detail());
      expect(detail(), isNot(detail(empty: true)));
    });
  });

  group('HourRange', () {
    test('is 06:00 to 23:00 and widens for topics outside it', () {
      expect(HourRange.of(const []), HourRange.standard);
      expect(HourRange.standard.rows, 18);
      expect(HourRange.standard.hours.first, 6);
      expect(HourRange.standard.hours.last, 23);
      final early = ProgramEntry.of(
        ekimIkinciHaftaDraft().tasks.first.copyWith(hour: 5, minute: 30),
      );
      final late = ProgramEntry.of(
        ekimIkinciHaftaDraft().tasks.first.copyWith(hour: 0),
      );
      final wide = HourRange.of([early, late]);
      expect(wide.first, 0);
      expect(wide.last, 23);
    });
  });

  group('WeekGridLayout', () {
    ProgramEntry at(int hour, int minute, String id) => ProgramEntry.of(
      ekimIkinciHaftaDraft().tasks.first.copyWith(hour: hour, minute: minute),
    ).copyId(id);

    test('topics an hour apart share nothing', () {
      final blocks = WeekGridLayout.blocksOf([at(10, 0, 'a'), at(11, 0, 'b')]);
      expect([for (final b in blocks) (b.lane, b.lanes)], [(0, 1), (0, 1)]);
    });

    test('topics that overlap get lanes, and a gap resets the group', () {
      final blocks = WeekGridLayout.blocksOf([
        at(10, 30, 'b'),
        at(10, 0, 'a'),
        at(10, 45, 'c'),
        at(14, 0, 'd'),
      ]);
      final byId = {for (final b in blocks) b.entry.id: b};
      expect(byId['a']!.lane, 0);
      expect(byId['b']!.lane, 1);
      expect(byId['c']!.lane, 2);
      expect(byId['a']!.lanes, 3);
      expect(byId['d']!.lane, 0);
      expect(byId['d']!.lanes, 1);
    });

    test('opens with today third among the visible columns', () {
      final days = ProgramSpan.week(kToday).days;
      // Cumartesi is index 5: Perşembe is the first visible of four columns.
      expect(
        WeekGridLayout.firstVisibleColumn(
          days: days,
          focus: kToday,
          visibleColumns: 4,
        ),
        3,
      );
      expect(
        WeekGridLayout.firstVisibleColumn(
          days: days,
          focus: DateTime(2026, 10, 6),
          visibleColumns: 4,
        ),
        0,
      );
      expect(
        WeekGridLayout.firstVisibleColumn(
          days: days,
          focus: DateTime(2026, 11, 6),
          visibleColumns: 4,
        ),
        0,
      );
      expect(
        WeekGridLayout.firstVisibleColumn(
          days: days,
          focus: kToday,
          visibleColumns: 7,
        ),
        0,
      );
    });

    test('with today outside the program it opens on the earliest topic', () {
      final days = ProgramSpan.week(kToday).days;
      final entries = [
        for (final t in ekimIkinciHaftaDraft().tasks) ProgramEntry.of(t),
      ];
      expect(
        WeekGridLayout.focusDay(days: days, today: kToday, entries: entries),
        kToday,
      );
      expect(
        WeekGridLayout.focusDay(
          days: days,
          today: DateTime(2026, 12, 1),
          entries: entries,
        ),
        DateTime(2026, 10, 10),
      );
      expect(
        WeekGridLayout.focusDay(
          days: days,
          today: DateTime(2026, 12, 1),
          entries: const [],
        ),
        DateTime(2026, 12, 1),
      );
    });

    test('opens one row above the earliest topic', () {
      final entries = [
        for (final t in ekimIkinciHaftaDraft().tasks) ProgramEntry.of(t),
      ];
      expect(
        WeekGridLayout.firstVisibleRow(
          entries: entries,
          range: HourRange.standard,
        ),
        3,
      );
      expect(
        WeekGridLayout.firstVisibleRow(
          entries: const [],
          range: HourRange.standard,
        ),
        0,
      );
    });
  });
}
