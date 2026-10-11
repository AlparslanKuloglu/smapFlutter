import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/schedule/domain/weekly_draft.dart';

ProgramTaskDraft task(
  String id, {
  DateTime? day,
  int hour = 10,
  int minute = 0,
  String title = 'Konu',
}) => ProgramTaskDraft(
  id: id,
  day: day ?? DateTime(2026, 10, 12),
  hour: hour,
  minute: minute,
  lessonId: 'lesson-1',
  title: title,
);

void main() {
  group('ProgramTaskDraft', () {
    test('create gives every task its own id', () {
      final a = ProgramTaskDraft.create(
        day: DateTime(2026, 10, 12),
        hour: 9,
        minute: 0,
        lessonId: 'l',
        title: 't',
      );
      final b = ProgramTaskDraft.create(
        day: DateTime(2026, 10, 12),
        hour: 9,
        minute: 0,
        lessonId: 'l',
        title: 't',
      );

      expect(a.id, startsWith('task-'));
      expect(a.id, isNot(b.id));
    });

    test('dayKey ignores the time of day and pads', () {
      expect(task('a', day: DateTime(2026, 3, 5, 23, 59)).dayKey, '2026-03-05');
      expect(formatDayKey(DateTime(987, 1, 2)), '0987-01-02');
    });

    test('copyWith keeps the id', () {
      final moved = task('a').copyWith(hour: 14, minute: 45);

      expect(moved.id, 'a');
      expect(moved.minutesOfDay, 14 * 60 + 45);
    });
  });

  group('WeeklyDraft', () {
    final draft = WeeklyDraft(
      name: 'Hafta',
      tasks: [
        task('a', hour: 11),
        task('b', hour: 9),
        task('c', day: DateTime(2026, 10, 14), hour: 8),
        task('d', hour: 9),
      ],
    );

    test('validity helpers', () {
      expect(draft.hasName, isTrue);
      expect(draft.hasTasks, isTrue);
      expect(const WeeklyDraft(name: '  ').hasName, isFalse);
      expect(const WeeklyDraft(name: 'x').hasTasks, isFalse);
    });

    test('days are distinct and oldest first', () {
      expect(draft.days, [DateTime(2026, 10, 12), DateTime(2026, 10, 14)]);
    });

    test('tasksOn orders by time and keeps the order of equal times', () {
      expect(draft.tasksOn(DateTime(2026, 10, 12)).map((t) => t.id), [
        'b',
        'd',
        'a',
      ]);
      expect(draft.tasksOn(DateTime(2026, 10, 13)), isEmpty);
    });

    test('edits return a changed copy and leave the draft alone', () {
      final added = draft.withTask(task('e'));
      expect(added.tasks, hasLength(5));
      expect(draft.tasks, hasLength(4));

      expect(draft.withoutTask('a').tasks.map((t) => t.id), ['b', 'c', 'd']);
      expect(draft.withoutTask('zzz'), draft);

      final replaced = draft.withReplacedTask(task('b', title: 'Yeni'));
      expect(replaced.tasks[1].title, 'Yeni');
      expect(replaced.tasks, hasLength(4));

      final moved = draft.withTaskTime('b', hour: 20, minute: 15);
      expect(moved.tasks[1].minutesOfDay, 20 * 60 + 15);
    });

    test('withoutDay resets one day only', () {
      final reset = draft.withoutDay(DateTime(2026, 10, 12, 17));

      expect(reset.tasks.map((t) => t.id), ['c']);
      expect(reset.days, [DateTime(2026, 10, 14)]);
    });

    test('equality is by value', () {
      expect(
        WeeklyDraft(name: 'a', tasks: [task('x')]),
        WeeklyDraft(name: 'a', tasks: [task('x')]),
      );
      expect(
        WeeklyDraft(name: 'a', tasks: [task('x')]),
        isNot(WeeklyDraft(name: 'a', tasks: [task('y')])),
      );
    });
  });
}
