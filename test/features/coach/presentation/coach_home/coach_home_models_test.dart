import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/coach/application/coach_home_models.dart';
import 'package:smap/features/coach/data/dtos/coach_student_dto.dart';
import 'package:smap/features/coach/data/dtos/interview_dtos.dart';
import 'package:smap/features/coach/domain/interview_type.dart';

import '../../coach_fixtures.dart';

InterviewDto _interview(
  String? id,
  DateTime? date, {
  Object? type = 1,
  Map<String, Object?>? student,
}) => InterviewDto.fromJson({
  '_id': ?id,
  'type': type,
  'date': ?date?.toUtc().toIso8601String(),
  'student':
      student ?? {'_id': 's1', 'firstName': 'Alparslan', 'surname': 'Kuloğlu'},
});

void main() {
  group('StudentStrip', () {
    test('keeps the order it is given and the avatar', () {
      final strip = StudentStrip.of([
        CoachStudentDto.fromJson(studentJson(id: 'a', name: 'Ali')),
        CoachStudentDto.fromJson(studentJson(id: 'b', name: 'Çağla')),
      ]);

      expect(strip.students.map((s) => s.id), ['a', 'b']);
      expect(strip.students.first.photo, 'avatars/1avatarN3.png');
    });

    test('leaves out a student with no id or no name at all', () {
      final strip = StudentStrip.of(const [
        CoachStudentDto(name: 'Ali'),
        CoachStudentDto(id: 'x'),
        CoachStudentDto(id: 'y', userName: 'yedek'),
      ]);

      expect(strip.students.map((s) => s.id), ['y']);
      expect(strip.students.single.name, 'yedek');
    });

    test('has value equality, so a selector does not rebuild for nothing', () {
      StudentStrip make() => StudentStrip.of([
        CoachStudentDto.fromJson(studentJson(id: 'a', name: 'Ali')),
      ]);

      expect(make(), make());
      expect(make().hashCode, make().hashCode);
      expect(make() == const StudentStrip([]), isFalse);
    });
  });

  group('CoachStudentFullName', () {
    CoachStudentDto student(Map<String, Object?> json) =>
        CoachStudentDto.fromJson(json);

    test('adds the surname to a first name the coach typed', () {
      expect(
        student(studentJson(name: 'Elif', surname: 'Şahin')).fullName,
        'Elif Şahin',
      );
    });

    test('keeps a name that already holds the surname', () {
      expect(
        student(studentJson(name: 'Elif Şahin', surname: 'Şahin')).fullName,
        'Elif Şahin',
      );
      expect(
        student(studentJson(name: 'Elif ŞAHİN', surname: 'Şahin')).fullName,
        'Elif ŞAHİN',
      );
    });

    test('has no surname to add, or no name at all', () {
      expect(
        student(studentJson(name: 'Elif', surname: null)).fullName,
        'Elif',
      );
      expect(const CoachStudentDto().fullName, isNull);
    });
  });

  group('UpcomingMeetings', () {
    final now = DateTime(2026, 10, 10, 9);

    test('keeps the next seven days, earliest first', () {
      final meetings = UpcomingMeetings.of([
        _interview('c', DateTime(2026, 10, 17, 9)),
        _interview('a', DateTime(2026, 10, 12, 16)),
        _interview('b', DateTime(2026, 10, 15, 19, 30), type: 2),
      ], now);

      expect(meetings.items.map((m) => m.id), ['a', 'b', 'c']);
      expect(meetings.count, 3);
      expect(meetings.items[1].type, InterviewType.parent);
      expect(meetings.items.first.studentName, 'Alparslan Kuloğlu');
    });

    test('drops the past, the far, the dateless and the idless', () {
      final meetings = UpcomingMeetings.of([
        _interview('past', DateTime(2026, 10, 10, 8, 59)),
        _interview('far', DateTime(2026, 10, 17, 9, 1)),
        _interview('nodate', null),
        _interview(null, DateTime(2026, 10, 12)),
        _interview('ok', DateTime(2026, 10, 10, 9)),
      ], now);

      expect(meetings.items.map((m) => m.id), ['ok']);
    });

    test('counts an interview once even if the server repeats it', () {
      final meetings = UpcomingMeetings.of([
        _interview('a', DateTime(2026, 10, 12, 16)),
        _interview('a', DateTime(2026, 10, 12, 16)),
      ], now);

      expect(meetings.count, 1);
    });

    test('takes a missing name from the student list, else drops the row', () {
      final bare = {'_id': 's2'};
      final meetings = UpcomingMeetings.of(
        [
          _interview('a', DateTime(2026, 10, 12, 16), student: bare),
          _interview('b', DateTime(2026, 10, 13, 16), student: {'_id': 's9'}),
        ],
        now,
        studentOf: (id) => id == 's2'
            ? CoachStudentDto.fromJson(
                studentJson(id: 's2', name: 'Elif', surname: 'Şahin'),
              )
            : null,
      );

      expect(meetings.items.map((m) => m.studentName), ['Elif Şahin']);
      expect(meetings.items.single.photo, 'avatars/1avatarN3.png');
    });

    test('draws at most five rows but counts them all', () {
      final meetings = UpcomingMeetings.of([
        for (var i = 0; i < 7; i++)
          _interview('i$i', DateTime(2026, 10, 11 + i % 5, 8 + i)),
      ], now);

      expect(meetings.count, 7);
      expect(meetings.rows, hasLength(UpcomingMeetings.maxRows));
    });

    test('the eight calendar days of the window, today first', () {
      final days = UpcomingMeetings.daysOf(DateTime(2026, 10, 28, 23, 30));

      expect(days.first, DateTime(2026, 10, 28));
      expect(days.last, DateTime(2026, 11, 4));
      expect(days, hasLength(8));
    });

    test('has value equality', () {
      UpcomingMeetings make() => UpcomingMeetings.of([
        _interview('a', DateTime(2026, 10, 12, 16)),
      ], now);

      expect(make(), make());
    });
  });
}
