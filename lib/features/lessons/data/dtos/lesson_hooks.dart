import 'package:dart_mappable/dart_mappable.dart';

import 'package:smap/features/exams/data/dtos/lenient_list_hooks.dart';

/// Hooks for the lesson-content answers.

/// A learning status: `1`, `"1"`, `true`, `"true"` read as 1 and `0`, `"0"`,
/// `false`, `"false"` as 0 (the legacy screens compare `toString()` against
/// `'1'` and `'true'`). Anything else is `null`.
final class ItemStatusHook extends MappingHook {
  const ItemStatusHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is bool) return value ? 1 : 0;
    if (value is num) return value == 1 ? 1 : (value == 0 ? 0 : null);
    if (value is String) {
      return switch (value.trim().toLowerCase()) {
        '1' || 'true' => 1,
        '0' || 'false' => 0,
        _ => null,
      };
    }
    return null;
  }
}

/// `statusArray`: a list of learning statuses; elements that are not a status
/// are dropped, anything that is not a list is empty.
final class ItemStatusListHook extends MappingHook {
  const ItemStatusListHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is! List) return const <int>[];
    return [
      for (final element in value)
        if (const ItemStatusHook().beforeDecode(element) case final int status)
          status,
    ];
  }
}

/// `getLessonsTotalMissing`'s `lessonObj`: an object keyed by general lesson
/// id whose values count missing items per track (`"1"`, `"2"`, `"3"`).
/// Becomes `[{lessonId, "1": n, ...}]`.
final class LessonMissingMapHook extends MappingHook {
  const LessonMissingMapHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is! Map) return null;
    return [
      for (final entry in value.entries)
        <String, dynamic>{
          if (entry.value is Map)
            ...Map<String, dynamic>.from(entry.value as Map),
          'lessonId': '${entry.key}',
        },
    ];
  }
}

/// `mainSubjects`' `resultByType`: `{ "<filter value>": { "<subject id>": n } }`.
/// Becomes `[{type, subjects: [{id, count}]}]` in the answer's order.
final class MissingByTypeHook extends MappingHook {
  const MissingByTypeHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is! Map) return null;
    return [
      for (final type in value.entries)
        <String, dynamic>{
          'type': '${type.key}',
          'subjects': [
            if (type.value is Map)
              for (final subject in (type.value as Map).entries)
                <String, dynamic>{
                  'id': '${subject.key}',
                  'count': subject.value,
                },
          ],
        },
    ];
  }
}

/// `getItems`' `itemsArray`: one list of items per sub-subject, in the order
/// of the ids that were asked for. Becomes `[{items: [...]}, ...]`; an entry
/// that is not a list is an empty one (positions are kept).
final class ItemListsHook extends MappingHook {
  const ItemListsHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is! List) return null;
    return [
      for (final list in value)
        <String, dynamic>{
          'items': const MapListHook().beforeDecode(list) ?? const <Object>[],
        },
    ];
  }
}
