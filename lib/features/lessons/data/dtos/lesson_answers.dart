import 'package:dart_mappable/dart_mappable.dart';

import 'package:smap/features/auth/data/dtos/lenient_hooks.dart';
import 'package:smap/features/exams/data/api_support.dart';
import 'package:smap/features/exams/data/dtos/lenient_list_hooks.dart';
import 'package:smap/features/lessons/data/dtos/lesson_hooks.dart';
import 'package:smap/features/lessons/data/dtos/lesson_item_dto.dart';

part 'generated/lesson_answers.mapper.dart';

/// One lesson of `getGeneralLessons`. The first six fields are the ones the
/// legacy `GeneralLesson.fromJson` reads; the rest are the lesson ids the
/// legacy catalog stores next to them and are read if the server sends them.
@MappableClass(ignoreNull: true)
class GeneralLessonDto with GeneralLessonDtoMappable {
  const GeneralLessonDto({
    this.id,
    this.name,
    this.image,
    this.order,
    this.tytAyt,
    this.mindMap,
    this.edebiyat,
    this.lessonId,
    this.lessonTyt,
    this.lessonAyt,
    this.lessonSos2,
  });

  factory GeneralLessonDto.fromJson(Map<String, dynamic> json) =>
      GeneralLessonDtoMapper.fromJson(json);

  @MappableField(key: '_id', hook: TextOrNullHook())
  final String? id;

  @MappableField(hook: TextOrNullHook())
  final String? name;

  @MappableField(hook: TextOrNullHook())
  final String? image;

  @MappableField(hook: IntOrNullHook())
  final int? order;

  /// `1`: TYT / AYT choice.
  @MappableField(hook: IntOrNullHook())
  final int? tytAyt;

  /// `1`: opens on the web.
  @MappableField(hook: IntOrNullHook())
  final int? mindMap;

  /// `1`: has Yazar & Eserler.
  @MappableField(hook: IntOrNullHook())
  final int? edebiyat;

  @MappableField(hook: TextOrNullHook())
  final String? lessonId;

  @MappableField(hook: TextOrNullHook())
  final String? lessonTyt;

  @MappableField(hook: TextOrNullHook())
  final String? lessonAyt;

  @MappableField(hook: TextOrNullHook())
  final String? lessonSos2;
}

/// Answer of `GET /ajax/getGeneralLessons`. The legacy reader never looked at
/// a `success` flag, so it is optional here.
@MappableClass(ignoreNull: true)
class GeneralLessonsResponse
    with GeneralLessonsResponseMappable
    implements ApiEnvelope {
  const GeneralLessonsResponse({this.success, this.message, this.lessons});

  factory GeneralLessonsResponse.fromBody(Object? data) {
    final map = bodyMap(data);
    if (map == null) return const GeneralLessonsResponse();
    return GeneralLessonsResponseMapper.fromJson(map);
  }

  @override
  @MappableField(hook: BoolOrNullHook())
  final bool? success;

  @override
  @MappableField(hook: TextOrNullHook())
  final String? message;

  /// `generalLessons`; `null` when the answer has no list.
  @MappableField(key: 'generalLessons', hook: MapListHook())
  final List<GeneralLessonDto>? lessons;
}

/// Missing-item counts of one general lesson in `getLessonsTotalMissing`.
@MappableClass(ignoreNull: true)
class LessonMissingDto with LessonMissingDtoMappable {
  const LessonMissingDto({this.lessonId, this.tyt, this.ayt, this.sos2});

  factory LessonMissingDto.fromJson(Map<String, dynamic> json) =>
      LessonMissingDtoMapper.fromJson(json);

  @MappableField(hook: TextOrNullHook())
  final String? lessonId;

  /// Track `"1"`.
  @MappableField(key: '1', hook: IntOrNullHook())
  final int? tyt;

  /// Track `"2"`.
  @MappableField(key: '2', hook: IntOrNullHook())
  final int? ayt;

  /// Track `"3"`.
  @MappableField(key: '3', hook: IntOrNullHook())
  final int? sos2;
}

/// Answer of `GET /student/getLessonsTotalMissing`.
@MappableClass(ignoreNull: true)
class LessonsMissingResponse
    with LessonsMissingResponseMappable
    implements ApiEnvelope {
  const LessonsMissingResponse({this.success, this.message, this.lessons});

  factory LessonsMissingResponse.fromBody(Object? data) {
    final map = bodyMap(data);
    if (map == null) return const LessonsMissingResponse();
    return LessonsMissingResponseMapper.fromJson(map);
  }

  @override
  @MappableField(hook: BoolOrNullHook())
  final bool? success;

  @override
  @MappableField(hook: TextOrNullHook())
  final String? message;

  /// `lessonObj`, lesson by lesson.
  @MappableField(key: 'lessonObj', hook: LessonMissingMapHook())
  final List<LessonMissingDto>? lessons;
}

/// A main subject (`mainSubjects`' `subjects[]`, `yazarEserMainSubjects`'
/// `mainSubjects[]`).
@MappableClass(ignoreNull: true)
class MainSubjectDto with MainSubjectDtoMappable {
  const MainSubjectDto({
    this.id,
    this.name,
    this.order,
    this.image,
    this.imageColor,
    this.barColor,
    this.itemDataCount,
  });

  factory MainSubjectDto.fromJson(Map<String, dynamic> json) =>
      MainSubjectDtoMapper.fromJson(json);

  @MappableField(key: '_id', hook: TextOrNullHook())
  final String? id;

  @MappableField(hook: TextOrNullHook())
  final String? name;

  @MappableField(hook: IntOrNullHook())
  final int? order;

  @MappableField(hook: TextOrNullHook())
  final String? image;

  @MappableField(hook: TextOrNullHook())
  final String? imageColor;

  @MappableField(hook: TextOrNullHook())
  final String? barColor;

  @MappableField(hook: IntOrNullHook())
  final int? itemDataCount;
}

/// A segment of the type filter (`filterObjs[]`).
@MappableClass(ignoreNull: true)
class FilterObjDto with FilterObjDtoMappable {
  const FilterObjDto({this.name, this.value});

  factory FilterObjDto.fromJson(Map<String, dynamic> json) =>
      FilterObjDtoMapper.fromJson(json);

  @MappableField(hook: TextOrNullHook())
  final String? name;

  @MappableField(hook: IntOrNullHook())
  final int? value;
}

/// One main subject's missing count under a filter value.
@MappableClass(ignoreNull: true)
class SubjectCountDto with SubjectCountDtoMappable {
  const SubjectCountDto({this.id, this.count});

  factory SubjectCountDto.fromJson(Map<String, dynamic> json) =>
      SubjectCountDtoMapper.fromJson(json);

  @MappableField(hook: TextOrNullHook())
  final String? id;

  @MappableField(hook: IntOrNullHook())
  final int? count;
}

/// The missing counts of one filter value (`resultByType["<value>"]`).
@MappableClass(ignoreNull: true)
class TypeMissingDto with TypeMissingDtoMappable {
  const TypeMissingDto({this.type, this.subjects});

  factory TypeMissingDto.fromJson(Map<String, dynamic> json) =>
      TypeMissingDtoMapper.fromJson(json);

  @MappableField(hook: IntOrNullHook())
  final int? type;

  @MappableField(hook: MapListHook())
  final List<SubjectCountDto>? subjects;
}

/// Answer of `GET /student/mainSubjects?lessonId=`.
@MappableClass(ignoreNull: true)
class MainSubjectsResponse
    with MainSubjectsResponseMappable
    implements ApiEnvelope {
  const MainSubjectsResponse({
    this.success,
    this.message,
    this.subjects,
    this.filters,
    this.missingByType,
  });

  factory MainSubjectsResponse.fromBody(Object? data) {
    final map = bodyMap(data);
    if (map == null) return const MainSubjectsResponse();
    return MainSubjectsResponseMapper.fromJson(map);
  }

  @override
  @MappableField(hook: BoolOrNullHook())
  final bool? success;

  @override
  @MappableField(hook: TextOrNullHook())
  final String? message;

  @MappableField(hook: MapListHook())
  final List<MainSubjectDto>? subjects;

  @MappableField(key: 'filterObjs', hook: MapListHook())
  final List<FilterObjDto>? filters;

  @MappableField(key: 'resultByType', hook: MissingByTypeHook())
  final List<TypeMissingDto>? missingByType;
}

/// Answer of `GET /student/yazarEserMainSubjects`.
@MappableClass(ignoreNull: true)
class YazarMainSubjectsResponse
    with YazarMainSubjectsResponseMappable
    implements ApiEnvelope {
  const YazarMainSubjectsResponse({this.success, this.message, this.subjects});

  factory YazarMainSubjectsResponse.fromBody(Object? data) {
    final map = bodyMap(data);
    if (map == null) return const YazarMainSubjectsResponse();
    return YazarMainSubjectsResponseMapper.fromJson(map);
  }

  @override
  @MappableField(hook: BoolOrNullHook())
  final bool? success;

  @override
  @MappableField(hook: TextOrNullHook())
  final String? message;

  @MappableField(key: 'mainSubjects', hook: MapListHook())
  final List<MainSubjectDto>? subjects;
}

/// A sub-subject (`getSubSubjects`' `subSubjects[]`).
@MappableClass(ignoreNull: true)
class SubSubjectDto with SubSubjectDtoMappable {
  const SubSubjectDto({this.id, this.name, this.itemDataCount, this.itemDatas});

  factory SubSubjectDto.fromJson(Map<String, dynamic> json) =>
      SubSubjectDtoMapper.fromJson(json);

  @MappableField(key: '_id', hook: TextOrNullHook())
  final String? id;

  @MappableField(hook: TextOrNullHook())
  final String? name;

  /// Missing items, counted by the server (Yazar & Eserler).
  @MappableField(hook: IntOrNullHook())
  final int? itemDataCount;

  /// The student's progress records under the sub-subject (Yazar & Eserler).
  @MappableField(hook: MapListHook())
  final List<ItemDataDto>? itemDatas;
}

/// Answer of `GET /student/getSubSubjects?mainSubjectId=`.
@MappableClass(ignoreNull: true)
class SubSubjectsResponse
    with SubSubjectsResponseMappable
    implements ApiEnvelope {
  const SubSubjectsResponse({this.success, this.message, this.subSubjects});

  factory SubSubjectsResponse.fromBody(Object? data) {
    final map = bodyMap(data);
    if (map == null) return const SubSubjectsResponse();
    return SubSubjectsResponseMapper.fromJson(map);
  }

  @override
  @MappableField(hook: BoolOrNullHook())
  final bool? success;

  @override
  @MappableField(hook: TextOrNullHook())
  final String? message;

  @MappableField(hook: MapListHook())
  final List<SubSubjectDto>? subSubjects;
}

/// Answer of `POST /student/getItems`.
@MappableClass(ignoreNull: true)
class ItemsResponse with ItemsResponseMappable implements ApiEnvelope {
  const ItemsResponse({this.success, this.message, this.itemLists});

  factory ItemsResponse.fromBody(Object? data) {
    final map = bodyMap(data);
    if (map == null) return const ItemsResponse();
    return ItemsResponseMapper.fromJson(map);
  }

  @override
  @MappableField(hook: BoolOrNullHook())
  final bool? success;

  @override
  @MappableField(hook: TextOrNullHook())
  final String? message;

  /// `itemsArray`: one list per asked sub-subject, in order.
  @MappableField(key: 'itemsArray', hook: ItemListsHook())
  final List<ItemListDto>? itemLists;
}

/// Answer of `GET /student/getSubjectAuthors?itemId=`.
@MappableClass(ignoreNull: true)
class SubjectAuthorsResponse
    with SubjectAuthorsResponseMappable
    implements ApiEnvelope {
  const SubjectAuthorsResponse({this.success, this.message, this.authors});

  factory SubjectAuthorsResponse.fromBody(Object? data) {
    final map = bodyMap(data);
    if (map == null) return const SubjectAuthorsResponse();
    return SubjectAuthorsResponseMapper.fromJson(map);
  }

  @override
  @MappableField(hook: BoolOrNullHook())
  final bool? success;

  @override
  @MappableField(hook: TextOrNullHook())
  final String? message;

  @MappableField(hook: MapListHook())
  final List<LessonItemDto>? authors;
}

/// An answer that is only `{success, message}` (`learnedItem`).
@MappableClass(ignoreNull: true)
class SuccessResponse with SuccessResponseMappable implements ApiEnvelope {
  const SuccessResponse({this.success, this.message});

  factory SuccessResponse.fromBody(Object? data) {
    final map = bodyMap(data);
    if (map == null) return const SuccessResponse();
    return SuccessResponseMapper.fromJson(map);
  }

  @override
  @MappableField(hook: BoolOrNullHook())
  final bool? success;

  @override
  @MappableField(hook: TextOrNullHook())
  final String? message;
}
