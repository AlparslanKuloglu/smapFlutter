import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/schedule/application/today_program.dart';
import 'package:smap/features/schedule/data/dtos/weekly_dto.dart';

Map<String, Object?> _task(String id, Object? day, Object? hour, [int m = 0]) =>
    {
      'id': id,
      'day': day,
      'hour': hour,
      'minute': m,
      'lesson': 'l',
      'title': id,
    };

WeeklyDto _weekly(String id, List<Object?> content) =>
    WeeklyDto.fromJson({'_id': id, 'name': id, 'content': content});

void main() {
  final monday = DateTime(2026, 10, 12);
  final tuesday = DateTime(2026, 10, 13);

  final first = _weekly('w1', [
    _task('a', '2026-10-12', 11),
    _task('b', '2026-10-12', 9, 30),
    _task('c', '2026-10-13', 8),
    _task('broken', null, 8),
  ]);
  final second = _weekly('w2', [
    _task('d', '2026-10-12', 9, 30),
    _task('e', '2026-10-12', 7),
  ]);

  group('tasksOnDay', () {
    test('keeps only that day and orders by time', () {
      final tasks = tasksOnDay([first, second], monday);

      expect(tasks.map((t) => t.task.id), ['e', 'b', 'd', 'a']);
    });

    test('equal times keep the order of the programs', () {
      expect(tasksOnDay([second, first], monday).map((t) => t.task.id), [
        'e',
        'd',
        'b',
        'a',
      ]);
    });

    test('knows the program of each task and ignores the clock time', () {
      final tasks = tasksOnDay([first, second], DateTime(2026, 10, 12, 23, 59));

      expect(tasks.first.weekly.id, 'w2');
      expect(tasks.first.day, monday);
      expect(tasks.first.minutesOfDay, 7 * 60);
    });

    test('an empty day, no programs and unplaceable tasks give nothing', () {
      expect(tasksOnDay([first, second], DateTime(2026, 10, 20)), isEmpty);
      expect(tasksOnDay(const [], monday), isEmpty);
      expect(tasksOnDay([first], tuesday).map((t) => t.task.id), ['c']);
    });
  });

  group('tasksByDay', () {
    test('groups by day, oldest first, each day by time', () {
      final grid = tasksByDay([first, second]);

      expect(grid.keys, [monday, tuesday]);
      expect(grid[monday]!.map((t) => t.task.id), ['e', 'b', 'd', 'a']);
      expect(grid[tuesday]!.map((t) => t.task.id), ['c']);
    });

    test('is empty without placeable tasks', () {
      expect(tasksByDay(const []), isEmpty);
      expect(
        tasksByDay([
          _weekly('w', [_task('x', 'soon', 9)]),
        ]),
        isEmpty,
      );
    });
  });

  test('weeklyTouchesDay', () {
    expect(weeklyTouchesDay(first, tuesday), isTrue);
    expect(weeklyTouchesDay(second, tuesday), isFalse);
  });
}
