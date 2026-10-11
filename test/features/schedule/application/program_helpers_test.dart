import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/features/schedule/application/new_program_summary.dart';
import 'package:smap/features/schedule/application/program_entry.dart';
import 'package:smap/features/schedule/application/program_view_preference.dart';
import 'package:smap/features/schedule/application/topic_groups.dart';
import 'package:smap/features/schedule/data/dtos/bag_item_dto.dart';
import 'package:smap/features/schedule/data/dtos/main_subject_dto.dart';

import '../program_fixtures.dart';

void main() {
  group('DayRunsLabel', () {
    test('runs of days in a row, apart, and both', () {
      expect(
        DayRunsLabel.of([for (var d = 13; d <= 17; d++) DateTime(2026, 10, d)]),
        'Salı–Cumartesi',
      );
      expect(
        DayRunsLabel.of([DateTime(2026, 10, 13), DateTime(2026, 10, 15)]),
        'Salı, Perşembe',
      );
      expect(
        DayRunsLabel.of([
          DateTime(2026, 10, 13),
          DateTime(2026, 10, 14),
          DateTime(2026, 10, 16),
        ]),
        'Salı–Çarşamba, Cuma',
      );
      expect(DayRunsLabel.of([DateTime(2026, 10, 12)]), 'Pazartesi');
      expect(DayRunsLabel.of(const []), '');
    });
  });

  group('NewProgramSummary', () {
    final days = [for (var d = 12; d <= 17; d++) DateTime(2026, 10, d)];

    test('the board case: 3 topics, all on Pazartesi', () {
      final monday = ekimIkinciHaftaDraft().tasks.map(
        (t) => ProgramEntry.of(t.copyWith(day: DateTime(2026, 10, 12))),
      );

      final summary = NewProgramSummary.of(days, monday.toList());

      expect(summary.range, '12–17 Ekim 2026');
      expect(summary.shortRange, '12–17 Ekim');
      expect(summary.dayCount, 6);
      expect(summary.studyCount, 3);
      expect(summary.onlyDay, DateTime(2026, 10, 12));
      expect(DayRunsLabel.of(summary.emptyDays), 'Salı–Cumartesi');
    });

    test('topics on two days have no single day', () {
      final entries = [
        ProgramEntry.of(
          ekimIkinciHaftaDraft().tasks[0].copyWith(day: DateTime(2026, 10, 12)),
        ),
        ProgramEntry.of(
          ekimIkinciHaftaDraft().tasks[1].copyWith(day: DateTime(2026, 10, 13)),
        ),
      ];

      final summary = NewProgramSummary.of(days, entries);

      expect(summary.onlyDay, isNull);
      expect(summary.emptyDays.length, 4);
    });

    test('value equality', () {
      expect(
        NewProgramSummary.of(days, const []),
        NewProgramSummary.of(days, const []),
      );
      expect(
        NewProgramSummary.of(days, const []),
        isNot(NewProgramSummary.of(days.take(2).toList(), const [])),
      );
    });
  });

  group('TopicGroups', () {
    test(
      'the bag keeps the first-seen lesson order and drops unplannable items',
      () {
        BagItemDto item(
          String id,
          String lessonId,
          String lesson,
          String? name,
        ) => BagItemDto.fromJson({
          'mainSubject': 'm-$id',
          'data': {'_id': id, 'name': ?name},
          'lesson': {'_id': lessonId, 'name': lesson},
        });

        final groups = TopicGroups.bag([
          item('1', kTytTarihId, 'TYT Tarih', 'Tarih Bilimi'),
          item('2', kTurkceId, 'TYT Türkçe', 'Noktalama'),
          item('3', kTytTarihId, 'TYT Tarih', 'İlk Uygarlıklar'),
          item('4', kTurkceId, 'TYT Türkçe', null),
        ]);

        expect(
          [for (final g in groups) g.lessonName],
          ['TYT Tarih', 'TYT Türkçe'],
        );
        expect(groups.first.choices.map((c) => c.title), [
          'Tarih Bilimi',
          'İlk Uygarlıklar',
        ]);
        expect(groups.last.choices.map((c) => c.title), ['Noktalama']);
      },
    );

    test('Dersler follows the catalog order and skips empty lessons', () {
      final ayt = ExamLessonCatalog.all.firstWhere(
        (l) => l.name == 'AYT Fizik',
      );
      final groups = TopicGroups.lessons({
        kTytTarihId: [const MainSubjectDto(id: 'a', name: 'Tarih')],
        kTurkceId: [const MainSubjectDto(id: 'b', name: 'Noktalama')],
        ayt.id: [const MainSubjectDto(id: 'c')],
        'unknown': [const MainSubjectDto(id: 'd', name: 'x')],
      });

      expect(
        [for (final g in groups) g.lessonName],
        ['TYT Türkçe', 'TYT Tarih'],
      );
    });
  });

  group('ProgramViewPreference', () {
    test(
      'keeps the choice for the session without a preference store',
      () async {
        final preference = ProgramViewPreference();

        expect(preference.read(), ProgramViewMode.day);
        await preference.write(ProgramViewMode.week);

        expect(preference.read(), ProgramViewMode.week);
        // No store injected: in memory only. The key itself is allowed.
        expect(preference.persists, isFalse);
        expect(
          DevicePreferences.allowedKeys,
          contains(ProgramViewPreference.key),
        );
      },
    );

    test('parses the stored names', () {
      expect(ProgramViewMode.parse('week'), ProgramViewMode.week);
      expect(ProgramViewMode.parse('day'), ProgramViewMode.day);
      expect(ProgramViewMode.parse('x'), isNull);
      expect(ProgramViewMode.parse(null), isNull);
    });
  });
}
