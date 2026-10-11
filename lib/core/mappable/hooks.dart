import 'package:dart_mappable/dart_mappable.dart';

/// Shared `dart_mappable` hooks for the legacy backend's loose JSON.
///
/// The Node backend is not strict about types: a count may arrive as `12`,
/// `"12"` or `"12.0"`, a flag as `true` or `"true"`, an empty field as `""`.
/// Put a hook on the field that needs it:
///
/// ```dart
/// @MappableField(hook: LenientIntHook())
/// final int point;
/// ```
///
/// Hooks only run on decode; encoding is unchanged. A value that cannot be
/// read is passed on untouched, so dart_mappable reports its usual type error
/// instead of this file inventing a default.

Object _wholeOr(num number, Object fallback) =>
    number.isFinite && number == number.truncate() ? number.toInt() : fallback;

/// Reads `12`, `12.0`, `"12"` and `"12.0"` as [int]; blank text as `null`.
final class LenientIntHook extends MappingHook {
  const LenientIntHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is num) return _wholeOr(value, value);
    if (value is String) {
      final text = value.trim();
      if (text.isEmpty) return null;
      final parsed = num.tryParse(text.replaceAll(',', '.'));
      if (parsed != null) return _wholeOr(parsed, value);
    }
    return value;
  }
}

/// Reads `12`, `"12"`, `"12.5"` and `"12,5"` as [double]; blank text as
/// `null`.
final class LenientDoubleHook extends MappingHook {
  const LenientDoubleHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final text = value.trim();
      if (text.isEmpty) return null;
      final parsed = double.tryParse(text.replaceAll(',', '.'));
      if (parsed != null) return parsed;
    }
    return value;
  }
}

/// Reads `true`/`false`, `"true"`/`"false"`, `1`/`0` and `"1"`/`"0"` as
/// [bool].
final class LenientBoolHook extends MappingHook {
  const LenientBoolHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is num && (value == 0 || value == 1)) return value == 1;
    if (value is String) {
      switch (value.trim().toLowerCase()) {
        case 'true' || '1':
          return true;
        case 'false' || '0':
          return false;
      }
    }
    return value;
  }
}

/// Reads numbers as their text (`42` becomes `"42"`), for ids and codes the
/// backend sometimes sends as numbers.
final class LenientStringHook extends MappingHook {
  const LenientStringHook();

  @override
  Object? beforeDecode(Object? value) => value is num ? '$value' : value;
}

/// Reads empty or whitespace-only text as `null`, so optional fields do not
/// carry `""` into the UI.
final class BlankToNullHook extends MappingHook {
  const BlankToNullHook();

  @override
  Object? beforeDecode(Object? value) =>
      value is String && value.trim().isEmpty ? null : value;
}

/// Reads dates the backend writes as ISO-8601 text, epoch milliseconds, or
/// `null`/blank for "not set".
///
/// dart_mappable's own `DateTime` decoding already takes ISO text and epoch
/// numbers; this hook adds the blank-to-null step and keeps the date in the
/// device's local time zone.
final class LenientDateTimeHook extends MappingHook {
  const LenientDateTimeHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is String) {
      final text = value.trim();
      if (text.isEmpty) return null;
      final parsed = DateTime.tryParse(text);
      return parsed?.toLocal().toIso8601String() ?? value;
    }
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(
        value.toInt(),
      ).toIso8601String();
    }
    return value;
  }
}

/// Class-level hook that drops [fields] from the encoded map, for values that
/// are filled at runtime and must never be sent back.
final class IgnoreFieldsHook extends MappingHook {
  const IgnoreFieldsHook(this.fields);

  final List<String> fields;

  @override
  Object? afterEncode(Object? value) {
    if (value is Map<String, dynamic>) fields.forEach(value.remove);
    return value;
  }
}
