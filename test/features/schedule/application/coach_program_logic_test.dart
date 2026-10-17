import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/schedule/application/program_edit_link.dart';
import 'package:smap/features/schedule/application/program_entry.dart';
import 'package:smap/features/schedule/application/program_summary.dart';
import 'package:smap/features/schedule/application/topic_choice.dart';
import 'package:smap/features/schedule/application/topic_groups.dart';
import 'package:smap/features/schedule/application/topic_row_text.dart';
import 'package:smap/features/schedule/data/dtos/bag_item_dto.dart';
import 'package:smap/features/schedule/data/dtos/weekly_dto.dart';

import '../program_fixtures.dart';

/// The pure logic behind the coach's program screens (Tur 12 A, pano 14.1 to
/// 14.3): the list's order and "Bu hafta", the line under a bag topic, and the
/// link the profile uses to follow edit mode. The values are Ek C's.
void main() {
  final today = DateTime(2026, 10, 10);

  List<WeeklyDto> weeklies(List<Map<String, Object?>> json) => [
    for (final item in json) WeeklyDto.fromJson(item),
  ];

  /// "Ekim 3. Hafta", 12–17 Ekim: a program just set up for next week.
  Map<String, Object?> ekimUcuncuHafta() => weeklyJsonOnDays(
    'w-new-1',
    'Ekim 3. Hafta',
    'Az ama her gün',
    ['2026-10-12', '2026-10-14', '2026-10-17'],
  );

  group('ProgramList (pano 14.1 kare 2, T12.4)', () {
    test('the three programs of the board, this week tagged', () {
      final list = ProgramList.of(
        weeklies(alparslanProgramsJson()),
        today: today,
        thisWeekFirst: false,
      );

      expect(list.items.map((p) => p.name), [
        'Ekim 2. Hafta',
        'Deneme haftası',
        'Yaz tekrarı',
      ]);
      expect(list.items.map((p) => p.isThisWeek), [true, false, false]);
      expect(list.items.first.span!.rangeLabel, '5–11 Ekim 2026');
      expect(list.items[1].span!.rangeLabel, '28 Eylül–4 Ekim 2026');
      expect(list.items[2].span!.rangeLabel, '17–23 Ağustos 2026');
    });

    test('a coach\'s list is newest to oldest; a new program is on top', () {
      final all = weeklies([ekimUcuncuHafta(), ...alparslanProgramsJson()]);

      final coach = ProgramList.of(all, today: today, thisWeekFirst: false);
      final student = ProgramList.of(all, today: today);

      expect(coach.items.map((p) => p.name), [
        'Ekim 3. Hafta',
        'Ekim 2. Hafta',
        'Deneme haftası',
        'Yaz tekrarı',
      ]);
      expect(student.items.map((p) => p.name), [
        'Ekim 2. Hafta',
        'Ekim 3. Hafta',
        'Deneme haftası',
        'Yaz tekrarı',
      ]);
      expect(
        coach.items.where((p) => p.isThisWeek).single.name,
        'Ekim 2. Hafta',
      );
    });

    test('the tab shows this week\'s program, else the newest', () {
      final withNext = ProgramList.of(
        weeklies([ekimUcuncuHafta(), ...alparslanProgramsJson()]),
        today: today,
        thisWeekFirst: false,
      );
      expect(withNext.current!.name, 'Ekim 2. Hafta');

      final past = ProgramList.of(
        weeklies(alparslanProgramsJson().sublist(1)),
        today: today,
        thisWeekFirst: false,
      );
      expect(past.current!.name, 'Deneme haftası');
      expect(const ProgramList([]).current, isNull);
    });

    test('the "Programlar" row counts the listed programs', () {
      final list = ProgramList.of(
        weeklies(alparslanProgramsJson()),
        today: today,
        thisWeekFirst: false,
      );
      expect(list.items, hasLength(3));

      final four = ProgramList.of(
        weeklies([ekimUcuncuHafta(), ...alparslanProgramsJson()]),
        today: today,
        thisWeekFirst: false,
      );
      expect(four.items, hasLength(4));
    });
  });

  group('the line under a bag topic (pano 14.2 kare 3 and 6)', () {
    String inProgramAt(String day, String time) => 'Programda: $day $time';

    BagItemDto bagItem(
      String id,
      String topic,
      String lessonId,
      String lesson,
    ) => BagItemDto.fromJson({
      'student': 's1',
      'mainSubject': 'm-$id',
      'data': {'_id': id, 'name': topic, 'konu': 'k-$id'},
      'lesson': {'_id': lessonId, 'name': lesson},
    });

    final noktalama = TopicChoice.fromBag(
      bagItem('i1', 'Noktalama İşaretleri', kTurkceId, 'TYT Türkçe'),
    )!;
    final fiil = TopicChoice.fromBag(
      bagItem('i2', 'Fiilde Çatı', kTurkceId, 'TYT Türkçe'),
    )!;
    final kurtulus = TopicChoice.fromBag(
      bagItem(
        'i3',
        'Kurtuluş Savaşı Hazırlık Dönemi',
        '66b0e7e5c99f8fc189ff35ff',
        'AYT Tarih',
      ),
    )!;
    final iklim = TopicChoice.fromBag(
      bagItem('i4', 'İklim Bilgisi', kTytCografyaId, 'TYT Coğrafya'),
    )!;

    /// The program being built: Fiilde Çatı Pzt 10:00, Kurtuluş Savaşı Pzt
    /// 14:00 (12 Ekim).
    final placements = placementsOf([
      ProgramEntry.of(fiil.toTask(day: DateTime(2026, 10, 12), hour: 10)),
      ProgramEntry.of(kurtulus.toTask(day: DateTime(2026, 10, 12), hour: 14)),
    ]);

    String? line(TopicChoice choice, {bool showLesson = true}) =>
        TopicRowText.subline(
          choice: choice,
          showLesson: showLesson,
          placed: placements[choice.key],
          inProgramAt: inProgramAt,
        );

    test('the lesson, then where the topic already sits', () {
      expect(line(noktalama), 'TYT Türkçe');
      expect(line(fiil), 'TYT Türkçe · Programda: Pzt 10:00');
      expect(line(kurtulus), 'AYT Tarih · Programda: Pzt 14:00');
      expect(line(iklim), 'TYT Coğrafya');
    });

    test('"Dersler" has no lesson under the name (it has headings)', () {
      expect(line(noktalama, showLesson: false), isNull);
      expect(line(fiil, showLesson: false), 'Programda: Pzt 10:00');
    });

    test('there is no "eksik" tag text and no "Son denemede" line', () {
      for (final choice in [noktalama, fiil, kurtulus, iklim]) {
        final text = line(choice)!;
        expect(text, isNot(contains('Eksik')));
        expect(text, isNot(contains('Son denemede')));
      }
    });

    test('the bag is the student\'s list in the bag\'s order', () {
      final groups = TopicGroups.bag([
        bagItem('i1', 'Noktalama İşaretleri', kTurkceId, 'TYT Türkçe'),
        bagItem('i2', 'Fiilde Çatı', kTurkceId, 'TYT Türkçe'),
        bagItem(
          'i3',
          'Kurtuluş Savaşı Hazırlık Dönemi',
          '66b0e7e5c99f8fc189ff35ff',
          'AYT Tarih',
        ),
        bagItem('i4', 'İklim Bilgisi', kTytCografyaId, 'TYT Coğrafya'),
      ]);

      expect(
        [for (final g in groups) ...g.choices.map((c) => c.title)],
        [
          'Noktalama İşaretleri',
          'Fiilde Çatı',
          'Kurtuluş Savaşı Hazırlık Dönemi',
          'İklim Bilgisi',
        ],
      );
    });
  });

  group('ProgramEditLink (pano 14.1 kare 3)', () {
    test('"Bitti" of the bar ends the section\'s edit mode', () {
      final link = ProgramEditLink();
      addTearDown(link.dispose);
      var finished = 0;
      link.attach(() => finished++);

      link.finish();

      expect(finished, 1);
    });

    test('a section that goes away ends edit mode, later', () async {
      final link = ProgramEditLink();
      addTearDown(link.dispose);
      link.attach(() {});
      link.editing.value = true;

      link.detach();
      expect(link.editing.value, isTrue);
      await Future<void>.delayed(Duration.zero);

      expect(link.editing.value, isFalse);
      link.finish();
    });
  });
}
