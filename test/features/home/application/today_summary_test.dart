import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/features/home/application/today_summary.dart';
import 'package:smap/features/schedule/application/schedule_snapshot.dart';
import 'package:smap/features/schedule/data/dtos/program_task_dto.dart';
import 'package:smap/features/schedule/data/dtos/weekly_dto.dart';

const _turkce = '69d3c972fdfe9f2106fa471e';
const _tarih = '69d3ccc2fdfe9f2106fa471f';
const _cografya = '69d3cccbfdfe9f2106fa4720';

ProgramTaskDto _task({
  String day = '2026-10-10',
  int hour = 10,
  int minute = 0,
  String? lesson = _turkce,
  String? lessonName = 'Türkçe',
  String? title = 'Fiilde Çatı',
  String? mainSubject,
}) => ProgramTaskDto(
  id: 't-$day-$hour-$title',
  day: day,
  hour: hour,
  minute: minute,
  lesson: lesson,
  lessonName: lessonName,
  title: title,
  mainSubject: mainSubject,
);

ScheduleSnapshot _snapshot(List<WeeklyDto> weeklies) => ScheduleSnapshot(
  weeklies: weeklies,
  bagItems: const [],
  loadedAt: DateTime(2026, 10, 10),
);

final _now = DateTime(2026, 10, 10, 9, 41);

void main() {
  group('today of the board (pano 3.1 kare 1)', () {
    late TodaySummary summary;

    setUp(() {
      summary = TodaySummary.of(
        _snapshot([
          WeeklyDto(
            id: 'w1',
            name: 'Ekim 2. Hafta',
            tasks: [
              _task(
                hour: 20,
                minute: 0,
                lesson: _cografya,
                lessonName: 'Coğrafya',
                title: 'İklim Bilgisi',
              ),
              _task(),
              _task(
                hour: 14,
                lesson: _tarih,
                lessonName: 'Tarih',
                title: 'Kurtuluş Savaşı Hazırlık Dönemi',
                mainSubject: 'ms-1',
              ),
              _task(day: '2026-10-11', title: 'Yarın'),
            ],
          ),
        ]),
        _now,
      );
    });

    test('lists the tasks of the day, earliest first', () {
      expect(summary.rows.map((r) => '${r.hour}:${r.topic}'), [
        '10:Fiilde Çatı',
        '14:Kurtuluş Savaşı Hazırlık Dönemi',
        '20:İklim Bilgisi',
      ]);
    });

    test('carries the subject name, color and the ids a tap opens', () {
      final tarih = summary.rows[1];

      expect(tarih.subjectName, 'Tarih');
      expect(tarih.subject, SubjectKey.tarih);
      expect(tarih.lessonId, _tarih);
      expect(tarih.mainSubjectId, 'ms-1');
      expect(summary.rows[0].mainSubjectId, isNull);
    });

    test('names the program of the day and the day itself', () {
      expect(summary.programName, 'Ekim 2. Hafta');
      expect(summary.day, DateTime(2026, 10, 10));
    });
  });

  group('edge cases', () {
    test('a program with nothing today has no rows and no program name', () {
      final summary = TodaySummary.of(
        _snapshot([
          WeeklyDto(
            id: 'w',
            name: 'Hafta',
            tasks: [_task(day: '2026-10-12')],
          ),
        ]),
        _now,
      );

      expect(summary.rows, isEmpty);
      expect(summary.programName, isNull);
    });

    test('tasks of several programs are merged by time', () {
      final summary = TodaySummary.of(
        _snapshot([
          WeeklyDto(
            id: 'a',
            name: 'A',
            tasks: [_task(hour: 15, title: 'a1')],
          ),
          WeeklyDto(
            id: 'b',
            name: 'B',
            tasks: [_task(hour: 8, title: 'b1')],
          ),
        ]),
        _now,
      );

      expect(summary.rows.map((r) => r.topic), ['b1', 'a1']);
      expect(summary.programName, 'B');
    });

    test('a task without a topic is not drawn (nothing is made up)', () {
      final summary = TodaySummary.of(
        _snapshot([
          WeeklyDto(
            id: 'w',
            tasks: [
              _task(title: null),
              _task(title: ' '),
            ],
          ),
        ]),
        _now,
      );

      expect(summary.rows, isEmpty);
    });

    test('a task without a lesson name takes the catalog name', () {
      final summary = TodaySummary.of(
        _snapshot([
          WeeklyDto(id: 'w', tasks: [_task(lessonName: null)]),
        ]),
        _now,
      );

      expect(summary.rows.single.subjectName, 'Türkçe');
      expect(summary.rows.single.subject, SubjectKey.turkce);
    });

    test('a lesson the app does not know is a neutral tile', () {
      final summary = TodaySummary.of(
        _snapshot([
          WeeklyDto(
            id: 'w',
            tasks: [_task(lesson: 'x', lessonName: 'Felsefe')],
          ),
        ]),
        _now,
      );

      expect(summary.rows.single.subject, isNull);
      expect(summary.rows.single.subjectName, 'Felsefe');
    });

    test('a task without a usable time is left out', () {
      final summary = TodaySummary.of(
        _snapshot([
          WeeklyDto(
            id: 'w',
            tasks: [
              const ProgramTaskDto(
                day: '2026-10-10',
                title: 'Saatsiz',
                lessonName: 'Türkçe',
              ),
              _task(),
            ],
          ),
        ]),
        _now,
      );

      expect(summary.rows.map((r) => r.topic), ['Fiilde Çatı']);
    });

    test('has value equality, so an unchanged section does not rebuild', () {
      final snapshot = _snapshot([
        WeeklyDto(id: 'w', name: 'H', tasks: [_task()]),
      ]);

      expect(TodaySummary.of(snapshot, _now), TodaySummary.of(snapshot, _now));
      expect(
        TodaySummary.of(snapshot, _now),
        isNot(TodaySummary.of(snapshot, DateTime(2026, 10, 11))),
      );
    });
  });
}
