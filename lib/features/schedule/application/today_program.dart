import 'package:flutter/foundation.dart';

import 'package:smap/features/schedule/data/dtos/program_task_dto.dart';
import 'package:smap/features/schedule/data/dtos/weekly_dto.dart';
import 'package:smap/features/schedule/domain/weekly_draft.dart';

/// A planned topic together with the program it belongs to.
@immutable
class ScheduledTask {
  const ScheduledTask({required this.task, required this.weekly});

  final ProgramTaskDto task;

  /// The program the task is part of.
  final WeeklyDto weekly;

  /// The task's calendar day (always set for a [ScheduledTask] built by the
  /// functions below).
  DateTime get day => task.date!;

  /// Minutes since midnight.
  int get minutesOfDay => task.minutesOfDay!;
}

/// The "Bugün" view: the tasks of [day] across every program, earliest first.
///
/// The backend has no "today" endpoint; `getMyWeeklies` returns whole programs
/// and the day is picked here (spec §6.3 #19). Tasks without a usable day or
/// time are skipped. Two tasks at the same minute keep the order they have in
/// [weeklies] (programs in list order, tasks in stored order).
List<ScheduledTask> tasksOnDay(Iterable<WeeklyDto> weeklies, DateTime day) {
  final key = formatDayKey(day);
  final found = <ScheduledTask>[];
  for (final weekly in weeklies) {
    for (final task in weekly.tasks) {
      final date = task.date;
      if (date == null || !task.isPlaceable) continue;
      if (formatDayKey(date) == key) {
        found.add(ScheduledTask(task: task, weekly: weekly));
      }
    }
  }
  return _byTime(found);
}

/// Every placed task of [weeklies] grouped by calendar day, days oldest first,
/// each day's tasks earliest first: the weekly grid's data.
Map<DateTime, List<ScheduledTask>> tasksByDay(Iterable<WeeklyDto> weeklies) {
  final byKey = <String, List<ScheduledTask>>{};
  final dayOf = <String, DateTime>{};
  for (final weekly in weeklies) {
    for (final task in weekly.tasks) {
      final date = task.date;
      if (date == null || !task.isPlaceable) continue;
      final key = formatDayKey(date);
      dayOf.putIfAbsent(key, () => date);
      (byKey[key] ??= []).add(ScheduledTask(task: task, weekly: weekly));
    }
  }
  final keys = dayOf.keys.toList()..sort();
  return {for (final key in keys) dayOf[key]!: _byTime(byKey[key]!)};
}

/// Whether [weekly] has at least one placed task on [day].
bool weeklyTouchesDay(WeeklyDto weekly, DateTime day) {
  final key = formatDayKey(day);
  return weekly.tasks.any((task) {
    final date = task.date;
    return date != null && task.isPlaceable && formatDayKey(date) == key;
  });
}

List<ScheduledTask> _byTime(List<ScheduledTask> tasks) {
  final indexed = tasks.asMap().entries.toList()
    ..sort((a, b) {
      final byTime = a.value.minutesOfDay.compareTo(b.value.minutesOfDay);
      return byTime != 0 ? byTime : a.key.compareTo(b.key);
    });
  return [for (final entry in indexed) entry.value];
}
