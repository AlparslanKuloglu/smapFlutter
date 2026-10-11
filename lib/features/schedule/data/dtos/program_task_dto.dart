import 'package:dart_mappable/dart_mappable.dart';

import 'package:smap/features/auth/data/dtos/lenient_hooks.dart';
import 'package:smap/features/schedule/domain/weekly_draft.dart';

part 'generated/program_task_dto.mapper.dart';

/// One planned topic of a weekly program: an element of the program's
/// `content` (what the editor sent as `tasks`).
///
/// Every field is optional and read leniently; a task without a usable day
/// and time is not [isPlaceable] and the screens skip it (the legacy editor
/// did the same). The lesson and subject fields are ids; the matching names
/// and colors come from the lesson data, `lessonName`, `lessonColor` and
/// `mapImage` are the copies the editor stored.
@MappableClass(ignoreNull: true)
class ProgramTaskDto with ProgramTaskDtoMappable {
  const ProgramTaskDto({
    this.id,
    this.day,
    this.hour,
    this.minute,
    this.lesson,
    this.lessonName,
    this.mainSubject,
    this.subject,
    this.item,
    this.title,
    this.category,
    this.lessonColor,
    this.mapImage,
  });

  factory ProgramTaskDto.fromJson(Map<String, dynamic> json) =>
      ProgramTaskDtoMapper.fromJson(json);

  /// Task id (`task-<epoch>-<hash>`), unique inside the program.
  @MappableField(hook: TextOrNullHook())
  final String? id;

  /// The day as `yyyy-MM-dd`; read it through [date].
  @MappableField(hook: TextOrNullHook())
  final String? day;

  /// 0 to 23.
  @MappableField(hook: IntOrNullHook())
  final int? hour;

  /// 0 to 59.
  @MappableField(hook: IntOrNullHook())
  final int? minute;

  /// The general lesson's id.
  @MappableField(hook: TextOrNullHook())
  final String? lesson;

  @MappableField(hook: TextOrNullHook())
  final String? lessonName;

  /// The main subject's id.
  @MappableField(hook: TextOrNullHook())
  final String? mainSubject;

  /// The subject ("konu") id; set for "Çantam" items.
  @MappableField(hook: TextOrNullHook())
  final String? subject;

  /// The bag item's id; set for "Çantam" items.
  @MappableField(hook: TextOrNullHook())
  final String? item;

  /// The topic's name as shown.
  @MappableField(hook: TextOrNullHook())
  final String? title;

  /// Always `"0"` in what the legacy editor wrote; unused by the app.
  @MappableField(hook: TextOrNullHook())
  final String? category;

  /// `#RRGGBB` as stored by the editor.
  @MappableField(hook: TextOrNullHook())
  final String? lessonColor;

  /// Icon file name such as `sine.png`.
  @MappableField(hook: TextOrNullHook())
  final String? mapImage;

  static final RegExp _dayShape = RegExp(r'^(\d{4})-(\d{2})-(\d{2})');

  /// [day] as a calendar date (local midnight); `null` when absent or not a
  /// date. A day with a time part keeps its written date; no zone shift.
  DateTime? get date {
    final text = day;
    if (text == null) return null;
    final match = _dayShape.firstMatch(text.trim());
    if (match != null) {
      final year = int.parse(match.group(1)!);
      final month = int.parse(match.group(2)!);
      final date = int.parse(match.group(3)!);
      final result = DateTime(year, month, date);
      return result.month == month && result.day == date ? result : null;
    }
    final parsed = DateTime.tryParse(text.trim());
    return parsed == null
        ? null
        : DateTime(parsed.year, parsed.month, parsed.day);
  }

  /// Whether the task has a calendar day and a time of day.
  bool get isPlaceable {
    final h = hour;
    final m = minute;
    return date != null &&
        h != null &&
        m != null &&
        h >= 0 &&
        h < 24 &&
        m >= 0 &&
        m < 60;
  }

  /// Minutes since midnight; `null` unless [isPlaceable].
  int? get minutesOfDay => isPlaceable ? hour! * 60 + minute! : null;

  /// The editor's copy of this task; `null` unless [isPlaceable] and a lesson
  /// is set.
  ProgramTaskDraft? toDraft() {
    final taskDate = date;
    final taskLesson = lesson;
    if (!isPlaceable || taskDate == null || taskLesson == null) return null;
    return ProgramTaskDraft(
      id: id ?? ProgramTaskDraft.nextId(),
      day: taskDate,
      hour: hour!,
      minute: minute!,
      lessonId: taskLesson,
      title: title ?? '',
      lessonName: lessonName,
      mainSubjectId: mainSubject,
      subjectId: subject,
      itemId: item,
      lessonColor: lessonColor,
      mapImage: mapImage,
    );
  }
}
