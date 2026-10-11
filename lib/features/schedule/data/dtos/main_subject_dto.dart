import 'package:dart_mappable/dart_mappable.dart';

import 'package:smap/features/auth/data/dtos/lenient_hooks.dart';

part 'generated/main_subject_dto.mapper.dart';

/// One main subject ("ana konu") of a lesson, from
/// `GET /student/getAllMainSubjects` (`subjectsJson`, keyed by the lesson's
/// id): the topic the program editor lists under a lesson.
@MappableClass(ignoreNull: true)
class MainSubjectDto with MainSubjectDtoMappable {
  const MainSubjectDto({this.id, this.name});

  factory MainSubjectDto.fromJson(Map<String, dynamic> json) =>
      MainSubjectDtoMapper.fromJson(json);

  /// Mongo `_id`; a task's `mainSubject`.
  @MappableField(key: '_id', hook: TextOrNullHook())
  final String? id;

  @MappableField(hook: TextOrNullHook())
  final String? name;
}
