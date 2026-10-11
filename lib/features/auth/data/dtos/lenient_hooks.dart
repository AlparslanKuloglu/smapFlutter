import 'package:dart_mappable/dart_mappable.dart';

import 'package:smap/core/mappable/hooks.dart';

/// Field hooks for the auth DTOs.
///
/// The shared hooks in `core/mappable/hooks.dart` pass a value they cannot read
/// on, so `dart_mappable` throws and the whole user is lost over one odd field.
/// These wrap them and turn "cannot read" into `null`: the session cache and
/// the login must survive a backend that sends `"phone": 5551234567` or
/// `"coach": {"_id": ...}`.

/// Text field: numbers become their text, blank text and anything else
/// (objects, lists, booleans) become `null`.
final class TextOrNullHook extends MappingHook {
  const TextOrNullHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is String) {
      final text = value.trim();
      return text.isEmpty ? null : text;
    }
    if (value is num && value.isFinite) {
      return const LenientStringHook().beforeDecode(value);
    }
    return null;
  }
}

/// Whole-number field; text such as `"12"` is read, anything else is `null`.
final class IntOrNullHook extends MappingHook {
  const IntOrNullHook();

  @override
  Object? beforeDecode(Object? value) {
    final read = const LenientIntHook().beforeDecode(value);
    return read is int ? read : null;
  }
}

/// Decimal field; text with a comma is read, anything else is `null`.
final class DoubleOrNullHook extends MappingHook {
  const DoubleOrNullHook();

  @override
  Object? beforeDecode(Object? value) {
    final read = const LenientDoubleHook().beforeDecode(value);
    return read is double ? read : null;
  }
}

/// Flag field; `"true"`, `1` and friends are read, anything else is `null`.
final class BoolOrNullHook extends MappingHook {
  const BoolOrNullHook();

  @override
  Object? beforeDecode(Object? value) {
    final read = const LenientBoolHook().beforeDecode(value);
    return read is bool ? read : null;
  }
}

/// Date field in ISO-8601 text or epoch milliseconds; unreadable text is
/// `null`.
final class DateOrNullHook extends MappingHook {
  const DateOrNullHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is num) {
      return const LenientDateTimeHook().beforeDecode(value);
    }
    if (value is! String) return null;
    final read = const LenientDateTimeHook().beforeDecode(value);
    return read is String && DateTime.tryParse(read) != null ? read : null;
  }
}

/// A nested JSON object (`user`); anything that is not an object is `null`.
final class ObjectOrNullHook extends MappingHook {
  const ObjectOrNullHook();

  @override
  Object? beforeDecode(Object? value) => value is Map ? value : null;
}

/// The student's coach: an id as text, or a populated object whose `_id` is
/// the id. Anything else is `null`.
final class CoachRefHook extends MappingHook {
  const CoachRefHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is Map) {
      return const TextOrNullHook().beforeDecode(value['_id'] ?? value['id']);
    }
    return const TextOrNullHook().beforeDecode(value);
  }
}
