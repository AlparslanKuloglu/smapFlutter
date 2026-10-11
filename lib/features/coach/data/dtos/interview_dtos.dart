import 'dart:convert';

import 'package:dart_mappable/dart_mappable.dart';

import 'package:smap/features/auth/data/dtos/lenient_hooks.dart';
import 'package:smap/features/coach/domain/interview_type.dart';

part 'generated/interview_dtos.mapper.dart';

/// The student an interview is with, as the interview document carries it:
/// a populated object (`_id`, `firstName`, `surname`, `photo`) or just an id.
@MappableClass(ignoreNull: true)
class InterviewStudentDto with InterviewStudentDtoMappable {
  const InterviewStudentDto({
    this.id,
    this.name,
    this.firstName,
    this.surname,
    this.photo,
  });

  factory InterviewStudentDto.fromJson(Map<String, dynamic> json) =>
      InterviewStudentDtoMapper.fromJson(json);

  @MappableField(key: '_id', hook: TextOrNullHook())
  final String? id;

  @MappableField(hook: TextOrNullHook())
  final String? name;

  @MappableField(hook: TextOrNullHook())
  final String? firstName;

  @MappableField(hook: TextOrNullHook())
  final String? surname;

  /// Avatar file name or path.
  @MappableField(hook: TextOrNullHook())
  final String? photo;

  /// First name and surname, else [name]; `null` when the document has none.
  String? get displayName {
    final full = [firstName, surname]
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty);
    if (full.isNotEmpty) return full.join(' ');
    return name;
  }
}

/// One note of an interview (`{note, date}` inside `notesStr`).
///
/// Notes have no id: the server addresses them by their position in the
/// interview's list (`editIndex`, `deleteIndex`), so the position the app
/// holds must be the one the server holds.
@MappableClass(ignoreNull: true)
class InterviewNoteDto with InterviewNoteDtoMappable {
  const InterviewNoteDto({this.note, this.date});

  factory InterviewNoteDto.fromJson(Map<String, dynamic> json) =>
      InterviewNoteDtoMapper.fromJson(json);

  @MappableField(hook: TextOrNullHook())
  final String? note;

  /// When the note was written or last edited (an ISO instant from the
  /// server, shown in local time).
  @MappableField(hook: DateOrNullHook())
  final DateTime? date;
}

/// One interview of `POST /coach/getInterviews` (also the `newInterview` the
/// create call returns). Only coaches have them (spec §6.2 9.7).
@MappableClass(ignoreNull: true)
class InterviewDto with InterviewDtoMappable {
  const InterviewDto({
    this.id,
    this.type,
    this.date,
    this.student,
    this.notes = const [],
  });

  factory InterviewDto.fromJson(Map<String, dynamic> json) =>
      InterviewDtoMapper.fromJson(json);

  /// Mongo `_id`.
  @MappableField(key: '_id', hook: TextOrNullHook())
  final String? id;

  /// 1 student, 2 parent; read it through [interviewType].
  @MappableField(hook: IntOrNullHook())
  final int? type;

  /// When the interview is. An instant: the app sends UTC and reads local
  /// time (see `InterviewRepository.createInterview`).
  @MappableField(hook: DateOrNullHook())
  final DateTime? date;

  /// With whom: populated by the server, or just an id.
  @MappableField(hook: InterviewStudentHook())
  final InterviewStudentDto? student;

  /// The notes in server order (the wire field `notesStr`, which is a JSON
  /// text or a list).
  @MappableField(key: 'notesStr', hook: InterviewNotesHook())
  final List<InterviewNoteDto> notes;

  /// [type] as the app's enum; `null` when absent or unknown.
  InterviewType? get interviewType => InterviewType.fromCode(type);
}

/// Reads `student` as an object: a populated map stays, a bare id becomes
/// `{_id: id}`, anything else is `null`.
final class InterviewStudentHook extends MappingHook {
  const InterviewStudentHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is Map) return value;
    final id = const TextOrNullHook().beforeDecode(value);
    return id == null ? null : <String, dynamic>{'_id': id};
  }
}

/// Reads `notesStr`: a JSON text of a list, or the list itself. Entries that
/// are not objects are dropped; anything unreadable is an empty list.
final class InterviewNotesHook extends MappingHook {
  const InterviewNotesHook();

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
