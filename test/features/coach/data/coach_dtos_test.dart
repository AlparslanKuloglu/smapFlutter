import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/coach/data/dtos/coach_student_dto.dart';
import 'package:smap/features/coach/data/dtos/interview_dtos.dart';
import 'package:smap/features/coach/domain/interview_type.dart';

import '../coach_fixtures.dart';

void main() {
  group('CoachStudentDto', () {
    test('reads a student as getMyStudents sends it', () {
      final student = CoachStudentDto.fromJson(studentJson());

      expect(student.id, 'student-1');
      expect(student.name, 'Zeynep');
      expect(student.firstName, 'Zeynep');
      expect(student.surname, 'Kaya');
      expect(student.userName, 'zeynep.kaya');
      expect(student.photo, 'avatars/1avatarN3.png');
      expect(student.totalMexam, 14);
      expect(student.seasonType, 12);
      expect(student.aimType, 2);
      expect(student.email, 'zeynep@example.com');
      expect(student.coach, 'coach-1');
      expect(student.date, isNotNull);
      expect(student.grade, SchoolGrade.grade12);
      expect(student.track, StudyTrack.esitAgirlik);
    });

    test('never models the password (spec S4)', () {
      final student = CoachStudentDto.fromJson(studentJson());

      final json = student.toJson();
      expect(json.containsKey('password'), isFalse);
      expect(student.toString(), isNot(contains('abcdefghijklmnopqrstuv')));
      expect(student.toJsonString(), isNot(contains('abcdefghijklmnopqrstuv')));
      expect(json.containsKey('__v'), isFalse);
    });

    test('reads counts and codes sent as text', () {
      final student = CoachStudentDto.fromJson(
        studentJson(seasonType: '11', aimType: '3', totalMexam: '7'),
      );

      expect(student.seasonType, 11);
      expect(student.aimType, 3);
      expect(student.totalMexam, 7);
      expect(student.track, StudyTrack.sayisal);
    });

    test('invents nothing for a sparse document', () {
      final student = CoachStudentDto.fromJson({'_id': 's'});

      expect(student.id, 's');
      expect(student.name, isNull);
      expect(student.photo, isNull, reason: 'no made-up avatar');
      expect(student.totalMexam, isNull);
      expect(student.grade, isNull);
      expect(student.track, isNull);
      expect(student.displayName, isNull);
      expect(CoachStudentDto.fromJson(const {}).id, isNull);
    });

    test('survives wrong types', () {
      final student = CoachStudentDto.fromJson({
        '_id': 5,
        'name': ['x'],
        'totalMexam': 'many',
        'date': 'yesterday',
        'coach': {'_id': 'c9', 'name': 'Koç'},
        'email': false,
      });

      expect(student.id, '5');
      expect(student.name, isNull);
      expect(student.totalMexam, isNull);
      expect(student.date, isNull);
      expect(student.coach, 'c9');
      expect(student.email, isNull);
    });

    test(
      'displayName prefers name, then first name and surname, then login',
      () {
        expect(
          CoachStudentDto.fromJson({
            'name': 'Ali',
            'firstName': 'A',
          }).displayName,
          'Ali',
        );
        expect(
          CoachStudentDto.fromJson({
            'firstName': 'Ali',
            'surname': 'Veli',
          }).displayName,
          'Ali Veli',
        );
        expect(
          CoachStudentDto.fromJson({'userName': 'ali.veli'}).displayName,
          'ali.veli',
        );
      },
    );

    test(
      'a coach-dialog track code that means something else is just a code',
      () {
        // 1 was "Sayısal" in the old coach dialog; it is no track now.
        expect(CoachStudentDto.fromJson(studentJson(aimType: 1)).track, isNull);
      },
    );
  });

  group('InterviewDto', () {
    test('reads an interview with a populated student and JSON-text notes', () {
      final interview = InterviewDto.fromJson(interviewJson());

      expect(interview.id, 'iv-1');
      expect(interview.type, 1);
      expect(interview.interviewType, InterviewType.student);
      expect(interview.student?.id, 'student-1');
      expect(interview.student?.displayName, 'Zeynep Kaya');
      expect(interview.student?.photo, '1avatarN3.png');
      expect(interview.date, isNotNull);
      expect(interview.notes, hasLength(1));
      expect(interview.notes.single.note, 'İlk not');
      expect(interview.notes.single.date, isNotNull);
    });

    test('the date is an instant, read in local time', () {
      final interview = InterviewDto.fromJson(interviewJson());

      expect(interview.date!.toUtc(), DateTime.utc(2026, 6, 28, 11, 30));
      expect(interview.date!.isUtc, isFalse);
    });

    test('reads notes sent as a list', () {
      final interview = InterviewDto.fromJson(
        interviewJson(
          notesStr: [
            {'note': 'a', 'date': '2026-06-28T12:00:00.000Z'},
            'junk',
            {'note': 'b'},
          ],
        ),
      );

      expect(interview.notes.map((n) => n.note), ['a', 'b']);
      expect(interview.notes.last.date, isNull);
    });

    test('unreadable notes are an empty list', () {
      for (final notes in ['', 'not json', '{"a":1}', 7, null]) {
        final json = interviewJson()..['notesStr'] = notes;
        expect(InterviewDto.fromJson(json).notes, isEmpty, reason: '$notes');
      }
      expect(InterviewDto.fromJson(const {}).notes, isEmpty);
    });

    test('a bare student id becomes a student with only an id', () {
      final interview = InterviewDto.fromJson(
        interviewJson(student: 'student-9'),
      );

      expect(interview.student?.id, 'student-9');
      expect(interview.student?.displayName, isNull);
    });

    test('a missing or odd student is null', () {
      expect(InterviewDto.fromJson({'_id': 'x'}).student, isNull);
      expect(
        InterviewDto.fromJson({
          'student': ['a'],
        }).student,
        isNull,
      );
    });

    test('type 2 is a parent interview, others are unknown', () {
      expect(
        InterviewDto.fromJson(interviewJson(type: 2)).interviewType,
        InterviewType.parent,
      );
      expect(
        InterviewDto.fromJson(interviewJson(type: 7)).interviewType,
        isNull,
      );
      expect(
        InterviewDto.fromJson(interviewJson(type: '1')).interviewType,
        InterviewType.student,
      );
      expect(InterviewDto.fromJson(const {}).interviewType, isNull);
    });

    test('survives a document of the wrong types', () {
      final interview = InterviewDto.fromJson({
        '_id': 3,
        'date': 'someday',
        'type': 'x',
      });

      expect(interview.id, '3');
      expect(interview.date, isNull);
      expect(interview.type, isNull);
    });
  });
}
