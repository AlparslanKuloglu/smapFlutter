import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/coach/application/meeting_list_logic.dart';
import 'package:smap/features/coach/application/meeting_models.dart';
import 'package:smap/features/coach/domain/interview_type.dart';

import '../meetings_fakes.dart';

MeetingEntry entry(
  String id,
  String name, {
  DateTime? at,
  InterviewType type = InterviewType.student,
}) => MeetingEntry(id: id, studentName: name, moment: at, type: type);

void main() {
  final now = morning; // 12 Ekim 2026, 08:00

  group('sections (pano 10.5 kare 1)', () {
    test('"Yaklaşan" is from now on, nearest first; past is newest first', () {
      final result = MeetingListLogic.sections([
        entry('far', 'Elif Şahin', at: DateTime(2026, 10, 15, 19, 30)),
        entry('old', 'Ali Veli', at: DateTime(2026, 10, 1, 10)),
        entry('near', 'Alparslan Kuloğlu', at: DateTime(2026, 10, 12, 16)),
        entry('older', 'Ali Veli', at: DateTime(2026, 9, 20, 10)),
        entry('mid', 'Ali Veli', at: DateTime(2026, 10, 5, 10)),
      ], now: now);
      expect(result.upcoming.map((e) => e.id), ['near', 'far']);
      expect(result.past.map((e) => e.id), ['mid', 'old', 'older']);
    });

    test('a meeting at exactly now is still upcoming', () {
      final result = MeetingListLogic.sections([
        entry('now', 'A', at: now),
        entry('before', 'B', at: DateTime(2026, 10, 12, 7, 59)),
      ], now: now);
      expect(result.upcoming.map((e) => e.id), ['now']);
      expect(result.past.map((e) => e.id), ['before']);
    });

    test('a meeting without a time goes last among the past ones', () {
      final result = MeetingListLogic.sections([
        entry('none', 'A'),
        entry('old', 'B', at: DateTime(2026, 1, 1)),
      ], now: now);
      expect(result.upcoming, isEmpty);
      expect(result.past.map((e) => e.id), ['old', 'none']);
    });

    test('equal times keep the loaded order', () {
      final at = DateTime(2026, 10, 13, 9);
      final result = MeetingListLogic.sections([
        entry('b', 'B', at: at),
        entry('a', 'A', at: at),
      ], now: now);
      expect(result.upcoming.map((e) => e.id), ['b', 'a']);
    });

    test('nothing in gives empty sections', () {
      expect(MeetingListLogic.sections(const [], now: now).isEmpty, isTrue);
      expect(MeetingListLogic.sections(const [], now: now).length, 0);
    });
  });

  group('"Kiminle" (pano 10.5 kare 1)', () {
    final entries = [
      entry('s', 'Alparslan Kuloğlu', at: DateTime(2026, 10, 12, 16)),
      entry(
        'p',
        'Elif Şahin',
        at: DateTime(2026, 10, 15, 19, 30),
        type: InterviewType.parent,
      ),
      const MeetingEntry(id: 'u', studentName: 'Bilinmeyen'),
    ];

    test('"Tümü" keeps every kind', () {
      expect(MeetingListLogic.sections(entries, now: now).length, 3);
    });

    test('"Öğrenci" and "Veli" keep that kind only', () {
      final students = MeetingListLogic.sections(
        entries,
        now: now,
        kind: MeetingWith.student,
      );
      final parents = MeetingListLogic.sections(
        entries,
        now: now,
        kind: MeetingWith.parent,
      );
      expect([...students.upcoming, ...students.past].map((e) => e.id), ['s']);
      expect([...parents.upcoming, ...parents.past].map((e) => e.id), ['p']);
    });
  });

  group('search by the student name (Turkish folding, like pano 10.2)', () {
    final entries = [
      entry('a', 'Alparslan Kuloğlu', at: DateTime(2026, 10, 12, 16)),
      entry('e', 'Elif Şahin', at: DateTime(2026, 10, 15, 19, 30)),
      entry('i', 'İlker Işık', at: DateTime(2026, 10, 20, 9)),
      entry('i2', 'Ihsan Aydın', at: DateTime(2026, 10, 21, 9)),
      const MeetingEntry(id: 'n'),
    ];

    List<String> ids(String query) => [
      for (final e in MeetingListLogic.sections(
        entries,
        now: now,
        query: query,
      ).upcoming)
        e.id,
    ];

    test('a prefix of a word, any case', () {
      expect(ids('alp'), ['a']);
      expect(ids('ALP'), ['a']);
      expect(ids('kulo'), ['a']);
    });

    test('every word of the query, in any order', () {
      expect(ids('kuloğlu alp'), ['a']);
      expect(ids('zey ka'), isEmpty);
    });

    test('İ, I, ı and i meet their plain forms', () {
      expect(ids('ilker'), ['i']);
      expect(ids('İLKER'), ['i']);
      expect(ids('ışık'), ['i']);
      expect(ids('isik'), ['i']);
      expect(ids('ihsan'), ['i2']);
      expect(ids('aydin'), ['i2']);
    });

    test(
      'a blank query keeps everyone; a nameless meeting matches no query',
      () {
        expect(ids(''), ['a', 'e', 'i', 'i2']);
        expect(ids('   '), ['a', 'e', 'i', 'i2']);
        expect(
          MeetingListLogic.matches(const MeetingEntry(id: 'n'), 'x'),
          isFalse,
        );
      },
    );
  });

  group('merge', () {
    test('appends only what is new and keeps the order', () {
      final loaded = [entry('a', 'A'), entry('b', 'B')];
      final merged = MeetingListLogic.merge(loaded, [
        entry('b', 'B2'),
        entry('c', 'C'),
      ]);
      expect(merged.map((e) => e.id), ['a', 'b', 'c']);
      expect(merged[1].studentName, 'B');
    });
  });
}
