import 'dart:convert';

import 'package:dart_mappable/dart_mappable.dart';

import 'package:smap/features/auth/data/dtos/lenient_hooks.dart';

/// Hooks for the list and nested-object shapes of the learning-content DTOs
/// (exams, analytics, lessons, cards). They build on the scalar hooks of
/// `features/auth/data/dtos/lenient_hooks.dart` (`TextOrNullHook`,
/// `IntOrNullHook`, ...): anything unreadable becomes `null` or an empty list
/// instead of failing the whole answer. Hooks only run on decode.
///
/// The coordinator may move both hook files to `lib/core/mappable`.

/// A nested JSON object, copied into a string-keyed map (decoded JSON may carry
/// `Map<dynamic, dynamic>`). Anything that is not an object is `null`.
final class ObjectHook extends MappingHook {
  const ObjectHook();

  @override
  Object? beforeDecode(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;
}

/// A JSON array of objects. Elements that are not objects are dropped; a value
/// that is not an array is `null`.
final class MapListHook extends MappingHook {
  const MapListHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is! List) return null;
    return [
      for (final element in value)
        if (element is Map) Map<String, dynamic>.from(element),
    ];
  }
}

/// Like [MapListHook] but keeps positions: an element that is not an object
/// becomes an empty object, so index `i` of the result is still index `i` of
/// the answer (the exam tests are addressed by position).
final class PositionalMapListHook extends MappingHook {
  const PositionalMapListHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is! List) return null;
    return [
      for (final element in value)
        element is Map
            ? Map<String, dynamic>.from(element)
            : <String, dynamic>{},
    ];
  }
}

/// A JSON array of text. Numbers become their text, blank and unreadable
/// elements are dropped; a lone text is a one-element list; anything else is
/// an empty list.
final class StringListHook extends MappingHook {
  const StringListHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is String) {
      final text = value.trim();
      return text.isEmpty ? const <String>[] : [text];
    }
    if (value is! List) return const <String>[];
    return [
      for (final element in value)
        if (const TextOrNullHook().beforeDecode(element) case final String text)
          text,
    ];
  }
}

/// A JSON array of text where every slot keeps its position: a slot that is
/// blank or unreadable is `null` (parallel arrays, like `lessOrSubjects` next
/// to `data`, must stay aligned). Anything that is not an array is `null`.
final class TextSlotsHook extends MappingHook {
  const TextSlotsHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is! List) return null;
    return [
      for (final slot in value) const TextOrNullHook().beforeDecode(slot),
    ];
  }
}

/// A JSON array of whole numbers (`[0, 1, "1"]`). Elements that cannot be read
/// are dropped; anything that is not an array is an empty list.
final class IntListHook extends MappingHook {
  const IntListHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is! List) return const <int>[];
    return [
      for (final element in value)
        if (const IntOrNullHook().beforeDecode(element) case final int number)
          number,
    ];
  }
}

/// A reference to another document: its id as text, or a populated object
/// whose `_id` is the id. Anything else is `null`.
final class IdRefHook extends MappingHook {
  const IdRefHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is Map) {
      return const TextOrNullHook().beforeDecode(value['_id'] ?? value['id']);
    }
    return const TextOrNullHook().beforeDecode(value);
  }
}

/// Reads [value] as JSON when it is text (the backend stores some arrays as
/// JSON strings), passes an already decoded value on, and returns `null` for
/// text that is not JSON.
Object? decodeJsonText(Object? value) {
  if (value is! String) return value;
  final text = value.trim();
  if (text.isEmpty) return null;
  try {
    return jsonDecode(text);
  } on FormatException {
    return null;
  }
}
