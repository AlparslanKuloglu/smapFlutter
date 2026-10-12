import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/coach/application/meeting_schedule_logic.dart';
import 'package:smap/features/coach/domain/interview_type.dart';

void main() {
  group('initialMoment: the next half hour', () {
    DateTime of(int h, int m, [int s = 0]) =>
        MeetingSchedule.initialMoment(DateTime(2026, 10, 12, h, m, s));

    test('16:12 opens on 16:30, 16:40 on 17:00', () {
      expect(of(16, 12), DateTime(2026, 10, 12, 16, 30));
      expect(of(16, 40), DateTime(2026, 10, 12, 17));
    });

    test('a full half hour stays', () {
      expect(of(16, 0), DateTime(2026, 10, 12, 16));
      expect(of(16, 30), DateTime(2026, 10, 12, 16, 30));
    });

    test('never earlier than now (seconds aside)', () {
      for (var m = 0; m < 60; m++) {
        final moment = of(9, m);
        expect(moment.isBefore(DateTime(2026, 10, 12, 9, m)), isFalse);
      }
    });

    test('after 23:30 it is tomorrow 00:00 (or 00:30)', () {
      expect(of(23, 40), DateTime(2026, 10, 13));
      expect(of(23, 31), DateTime(2026, 10, 13));
      expect(
        MeetingSchedule.initialMoment(DateTime(2026, 12, 31, 23, 50)),
        DateTime(2027),
      );
    });
  });

  test('combine puts a day and a time of day together', () {
    expect(
      MeetingSchedule.combine(DateTime(2026, 10, 12, 3, 4), hour: 16),
      DateTime(2026, 10, 12, 16),
    );
    expect(
      MeetingSchedule.combine(DateTime(2026, 10, 12), hour: 19, minute: 30),
      DateTime(2026, 10, 12, 19, 30),
    );
  });

  test('the calendar goes a year back', () {
    expect(
      MeetingSchedule.firstDay(DateTime(2026, 10, 12, 8)),
      DateTime(2025, 10, 12),
    );
  });

  test('the note goes out trimmed, empty is none', () {
    expect(MeetingSchedule.noteOf('  Not  '), 'Not');
    expect(MeetingSchedule.noteOf('   '), isNull);
    expect(MeetingSchedule.noteOf(''), isNull);
  });

  test('a draft is equal by content', () {
    final a = MeetingDraft(
      studentId: 's',
      type: InterviewType.parent,
      moment: DateTime(2026, 10, 12, 16),
      note: 'x',
    );
    final b = MeetingDraft(
      studentId: 's',
      type: InterviewType.parent,
      moment: DateTime(2026, 10, 12, 16),
      note: 'x',
    );
    expect(a, b);
    expect(a.hashCode, b.hashCode);
  });
}
