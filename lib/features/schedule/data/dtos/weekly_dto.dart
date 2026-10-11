import 'dart:convert';

import 'package:dart_mappable/dart_mappable.dart';

import 'package:smap/features/auth/data/dtos/lenient_hooks.dart';
import 'package:smap/features/schedule/data/dtos/program_task_dto.dart';
import 'package:smap/features/schedule/domain/weekly_draft.dart';

part 'generated/weekly_dto.mapper.dart';

/// A weekly program of `POST /student/getMyWeeklies` (also the `weekly` of
/// `addNewProgram` and `updateProgram`).
///
/// A Mongo document: `_id`, `name`, `motto`, `student` and `content`, the list
/// of planned topics, which the server stores as a JSON text or as a list
/// (both are read). Fields the legacy code never reads (dates, owner, flags)
/// are not modelled.
@MappableClass(ignoreNull: true)
class WeeklyDto with WeeklyDtoMappable {
  const WeeklyDto({
    this.id,
    this.name,
    this.motto,
    this.student,
    this.tasks = const [],
  });

  factory WeeklyDto.fromJson(Map<String, dynamic> json) =>
      WeeklyDtoMapper.fromJson(json);

  /// Mongo `_id`; the `weeklyId` of an update.
  @MappableField(key: '_id', hook: TextOrNullHook())
  final String? id;

  /// "Program Adı".
  @MappableField(hook: TextOrNullHook())
  final String? name;

  /// The motivation sentence.
  @MappableField(hook: TextOrNullHook())
  final String? motto;

  /// The student the program belongs to (an id; the server may populate it).
  @MappableField(hook: CoachRefHook())
  final String? student;

  /// The planned topics (wire field `content`), in stored order. Tasks
  /// without a day or a time are kept here; filter with
  /// `ProgramTaskDto.isPlaceable` before drawing.
  @MappableField(key: 'content', hook: ProgramTasksHook())
  final List<ProgramTaskDto> tasks;

  /// The tasks that have a calendar day and a time.
  List<ProgramTaskDto> get placedTasks => [
    for (final task in tasks)
      if (task.isPlaceable) task,
  ];

  /// The program's days, each once, oldest first.
  List<DateTime> get days {
    final byKey = <String, DateTime>{};
    for (final task in tasks) {
      final date = task.date;
      if (date == null || !task.isPlaceable) continue;
      byKey.putIfAbsent(formatDayKey(date), () => date);
    }
    return byKey.values.toList()..sort();
  }

  /// The editor's copy of this program (tasks that cannot be placed, or have
  /// no lesson, are left out). Pass it back to `updateWeekly` after changing
  /// it.
  WeeklyDraft toDraft() => WeeklyDraft(
    name: name ?? '',
    motto: motto ?? '',
    tasks: [for (final task in tasks) ?task.toDraft()],
  );
}

/// Reads `content`: a JSON text of a list, or the list itself. Entries that
/// are not objects are dropped; anything unreadable is an empty list.
final class ProgramTasksHook extends MappingHook {
  const ProgramTasksHook();

  @override
  Object? beforeDecode(Object? value) {
    Object? list = value;
    if (value is String) {
      final text = value.trim();
      if (text.isEmpty) return const <Object?>[];
      try {
        list = jsonDecode(text);
      } on FormatException {
        return const <Object?>[];
      }
    }
    if (list is! List) return const <Object?>[];
    return [
      for (final item in list)
        if (item is Map) item,
    ];
  }
}
