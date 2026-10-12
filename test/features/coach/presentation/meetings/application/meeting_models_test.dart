import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/coach/application/meeting_models.dart';
import 'package:smap/features/coach/data/dtos/interview_dtos.dart';
import 'package:smap/features/coach/domain/interview_type.dart';

import '../meetings_fakes.dart';

void main() {
  group('MeetingEntry.fromDto', () {
    test('reads the meeting of pano 10.5 kare 3', () {
      final entry = MeetingEntry.fromDto(alparslanMeeting())!;
      expect(entry.id, 'iv-1');
      expect(entry.type, InterviewType.student);
      expect(entry.moment, DateTime(2026, 10, 12, 16));
      expect(entry.studentId, 'student-1');
      expect(entry.studentName, 'Alparslan Kuloğlu');
      expect(entry.photo, '1avatarN3.png');
      expect(entry.notes.single.text, noteText);
      expect(entry.notes.single.index, 0);
    });

    test('a document without an id cannot be opened', () {
      expect(MeetingEntry.fromDto(const InterviewDto(type: 1)), isNull);
      expect(MeetingEntry.fromDto(const InterviewDto(id: '')), isNull);
    });

    test('nothing is made up: no student, no name, no time', () {
      final entry = MeetingEntry.fromDto(const InterviewDto(id: 'x'))!;
      expect(entry.studentName, isNull);
      expect(entry.studentId, isNull);
      expect(entry.moment, isNull);
      expect(entry.type, isNull);
      expect(entry.notes, isEmpty);
    });

    test('a note keeps the position the server holds, blanks skipped', () {
      final entry = MeetingEntry.fromDto(
        const InterviewDto(
          id: 'x',
          notes: [
            InterviewNoteDto(note: 'ilk'),
            InterviewNoteDto(note: '   '),
            InterviewNoteDto(),
            InterviewNoteDto(note: ' üçüncü '),
          ],
        ),
      )!;
      expect(entry.notes.map((n) => (n.index, n.text)), [
        (0, 'ilk'),
        (3, 'üçüncü'),
      ]);
    });

    test('the wall clock is the fields the server sent, not shifted', () {
      // "…T16:00:00.000Z": the coach typed 16:00; the UTC fields are kept.
      final utc = MeetingEntry.fromDto(
        InterviewDto(id: 'x', date: DateTime.utc(2026, 10, 12, 16)),
      )!;
      expect(utc.moment, DateTime(2026, 10, 12, 16));
      expect(utc.moment!.isUtc, isFalse);
      expect(MeetingMoment.wallClock(null), isNull);
    });

    test('an unknown kind number is no kind', () {
      expect(
        MeetingEntry.fromDto(const InterviewDto(id: 'x', type: 7))!.type,
        isNull,
      );
    });
  });

  test('MeetingWith keeps the kind the chip names', () {
    expect(MeetingWith.all.type, isNull);
    expect(MeetingWith.student.type, InterviewType.student);
    expect(MeetingWith.parent.type, InterviewType.parent);
    expect(MeetingWith.of(InterviewType.parent), MeetingWith.parent);
    expect(MeetingWith.of(null), MeetingWith.all);
  });

  test('entries are equal by content (a selector can rely on it)', () {
    final a = MeetingEntry.fromDto(alparslanMeeting())!;
    final b = MeetingEntry.fromDto(alparslanMeeting())!;
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a.withNotes(const []), isNot(a));
    expect(const MeetingSections(), const MeetingSections());
  });
}
