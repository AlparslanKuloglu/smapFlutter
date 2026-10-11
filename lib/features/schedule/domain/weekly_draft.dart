import 'package:flutter/foundation.dart';

/// One planned topic inside a [WeeklyDraft]: what the program editor builds
/// and `ScheduleRepository` sends. The read side is `ProgramTaskDto`.
///
/// Field names follow the backend's task object (`day`, `hour`, `minute`,
/// `lesson`, `mainSubject`, `subject`, `item`, `title`, ...), so a legacy
/// program and a new one are the same thing on the server.
@immutable
class ProgramTaskDraft {
  const ProgramTaskDraft({
    required this.id,
    required this.day,
    required this.hour,
    required this.minute,
    required this.lessonId,
    required this.title,
    this.lessonName,
    this.mainSubjectId,
    this.subjectId,
    this.itemId,
    this.lessonColor,
    this.mapImage,
  });

  /// A task with a fresh id (`task-<microseconds>-<n>`, unique per process).
  factory ProgramTaskDraft.create({
    required DateTime day,
    required int hour,
    required int minute,
    required String lessonId,
    required String title,
    String? lessonName,
    String? mainSubjectId,
    String? subjectId,
    String? itemId,
    String? lessonColor,
    String? mapImage,
  }) => ProgramTaskDraft(
    id: nextId(),
    day: day,
    hour: hour,
    minute: minute,
    lessonId: lessonId,
    title: title,
    lessonName: lessonName,
    mainSubjectId: mainSubjectId,
    subjectId: subjectId,
    itemId: itemId,
    lessonColor: lessonColor,
    mapImage: mapImage,
  );

  static int _counter = 0;

  /// A new task id. The legacy form used `task-<epoch ms>-<hash>`.
  static String nextId() =>
      'task-${DateTime.now().microsecondsSinceEpoch}-${_counter++}';

  /// Unique within the program; kept when an existing program is edited.
  final String id;

  /// The calendar day; only year, month and day count.
  final DateTime day;

  /// 0 to 23.
  final int hour;

  /// 0 to 59.
  final int minute;

  /// The general lesson's id (`/ajax/getGeneralLessons`, `_id`): "Türkçe".
  final String lessonId;

  /// The topic's name as shown: "Fiilde Çatı".
  final String title;

  final String? lessonName;

  /// The main subject's id (`/student/getAllMainSubjects`, `_id`); for a
  /// "Çantam" item it is the bag item's `mainSubject`.
  final String? mainSubjectId;

  /// The subject ("konu") id, set for "Çantam" items (`data.konu`).
  final String? subjectId;

  /// The bag item's own id (`data._id`), set for "Çantam" items.
  final String? itemId;

  /// `#RRGGBB`; the other clients draw the block with it. Sent as `#000000`
  /// when unknown, like the legacy form.
  final String? lessonColor;

  /// Icon file name such as `sine.png` (a path is cut to its last segment).
  final String? mapImage;

  /// `yyyy-MM-dd`: the wire form of [day].
  String get dayKey => formatDayKey(day);

  /// Minutes since midnight, for ordering inside a day.
  int get minutesOfDay => hour * 60 + minute;

  ProgramTaskDraft copyWith({
    DateTime? day,
    int? hour,
    int? minute,
    String? lessonId,
    String? title,
    String? lessonName,
    String? mainSubjectId,
    String? subjectId,
    String? itemId,
    String? lessonColor,
    String? mapImage,
  }) => ProgramTaskDraft(
    id: id,
    day: day ?? this.day,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    lessonId: lessonId ?? this.lessonId,
    title: title ?? this.title,
    lessonName: lessonName ?? this.lessonName,
    mainSubjectId: mainSubjectId ?? this.mainSubjectId,
    subjectId: subjectId ?? this.subjectId,
    itemId: itemId ?? this.itemId,
    lessonColor: lessonColor ?? this.lessonColor,
    mapImage: mapImage ?? this.mapImage,
  );

  @override
  bool operator ==(Object other) =>
      other is ProgramTaskDraft &&
      other.id == id &&
      other.dayKey == dayKey &&
      other.hour == hour &&
      other.minute == minute &&
      other.lessonId == lessonId &&
      other.title == title &&
      other.lessonName == lessonName &&
      other.mainSubjectId == mainSubjectId &&
      other.subjectId == subjectId &&
      other.itemId == itemId &&
      other.lessonColor == lessonColor &&
      other.mapImage == mapImage;

  @override
  int get hashCode => Object.hash(
    id,
    dayKey,
    hour,
    minute,
    lessonId,
    title,
    lessonName,
    mainSubjectId,
    subjectId,
    itemId,
    lessonColor,
    mapImage,
  );
}

/// `yyyy-MM-dd` of [day] (the device's calendar day, no time zone shift).
String formatDayKey(DateTime day) {
  final month = day.month.toString().padLeft(2, '0');
  final date = day.day.toString().padLeft(2, '0');
  return '${day.year.toString().padLeft(4, '0')}-$month-$date';
}

/// A weekly program as the editor holds it: a name, a motto and the planned
/// topics of its days (screens 3.4 to 3.6).
///
/// The backend has no partial update: `updateProgram` replaces the whole
/// program. "Instant save" (spec §6.2 6.9) therefore means: change the draft
/// with the methods below, then send the whole draft again. The methods leave
/// the draft untouched and return a changed copy.
@immutable
class WeeklyDraft {
  const WeeklyDraft({
    required this.name,
    this.motto = '',
    this.tasks = const [],
  });

  /// The program's name ("Program Adı"); required by the legacy form.
  final String name;

  /// The motivation sentence; may be empty.
  final String motto;

  final List<ProgramTaskDraft> tasks;

  /// A program can be created when it has a name; the legacy form also asked
  /// for at least one topic ([hasTasks]).
  bool get hasName => name.trim().isNotEmpty;

  bool get hasTasks => tasks.isNotEmpty;

  /// The program's days, each once, oldest first.
  List<DateTime> get days {
    final byKey = <String, DateTime>{};
    for (final task in tasks) {
      byKey.putIfAbsent(
        task.dayKey,
        () => DateTime(task.day.year, task.day.month, task.day.day),
      );
    }
    final days = byKey.values.toList()..sort();
    return days;
  }

  /// The topics of [day], earliest first (equal times keep their order).
  List<ProgramTaskDraft> tasksOn(DateTime day) {
    final key = formatDayKey(day);
    final indexed =
        [
          for (var i = 0; i < tasks.length; i++)
            if (tasks[i].dayKey == key) (i, tasks[i]),
        ]..sort((a, b) {
          final byTime = a.$2.minutesOfDay.compareTo(b.$2.minutesOfDay);
          return byTime != 0 ? byTime : a.$1.compareTo(b.$1);
        });
    return [for (final entry in indexed) entry.$2];
  }

  WeeklyDraft copyWith({
    String? name,
    String? motto,
    List<ProgramTaskDraft>? tasks,
  }) => WeeklyDraft(
    name: name ?? this.name,
    motto: motto ?? this.motto,
    tasks: tasks ?? this.tasks,
  );

  /// Adds [task] at the end.
  WeeklyDraft withTask(ProgramTaskDraft task) =>
      copyWith(tasks: [...tasks, task]);

  /// Removes the task with [id]; the draft is returned as is when there is
  /// none.
  WeeklyDraft withoutTask(String id) => copyWith(
    tasks: [
      for (final t in tasks)
        if (t.id != id) t,
    ],
  );

  /// Replaces the task that has [task]'s id.
  WeeklyDraft withReplacedTask(ProgramTaskDraft task) =>
      copyWith(tasks: [for (final t in tasks) t.id == task.id ? task : t]);

  /// Gives the task with [id] a new time ("Saat 10:00, değiştir").
  WeeklyDraft withTaskTime(
    String id, {
    required int hour,
    required int minute,
  }) => copyWith(
    tasks: [
      for (final t in tasks)
        t.id == id ? t.copyWith(hour: hour, minute: minute) : t,
    ],
  );

  /// Empties [day] ("Günü Sıfırla"): every task of that day is removed.
  WeeklyDraft withoutDay(DateTime day) {
    final key = formatDayKey(day);
    return copyWith(
      tasks: [
        for (final t in tasks)
          if (t.dayKey != key) t,
      ],
    );
  }

  @override
  bool operator ==(Object other) =>
      other is WeeklyDraft &&
      other.name == name &&
      other.motto == motto &&
      listEquals(other.tasks, tasks);

  @override
  int get hashCode => Object.hash(name, motto, Object.hashAll(tasks));
}
