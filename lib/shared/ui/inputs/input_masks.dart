import 'package:flutter/services.dart';

/// The two masked inputs of C09 "masked": the phone number
/// (`+90 5XX XXX XX XX`, number keyboard) and the coaching code
/// (`MOZK-4821`: four letters, a dash that appears by itself, four digits).
///
/// The format functions are pure and unit-tested; [phone] and [coachCode]
/// are the matching `TextInputFormatter`s, which keep the caret after the same
/// letter or digit it was after before the reformat.
abstract final class AppInputMasks {
  /// The digits of a Turkish mobile number after the "+90 " prefix, grouped
  /// 3-3-2-2: `5321234567` becomes `532 123 45 67`. Anything that is not a
  /// digit is dropped; more than ten digits are cut.
  static String formatPhone(String raw) {
    final digits = raw.replaceAll(RegExp('[^0-9]'), '');
    final kept = digits.length > 10 ? digits.substring(0, 10) : digits;
    const groups = [3, 3, 2, 2];
    final parts = <String>[];
    var at = 0;
    for (final size in groups) {
      if (at >= kept.length) break;
      final end = at + size > kept.length ? kept.length : at + size;
      parts.add(kept.substring(at, end));
      at = end;
    }
    return parts.join(' ');
  }

  /// A coaching code `MOZK-4821`: up to four Latin letters (upper-cased; ASCII
  /// only, so no Turkish "i" rule applies), then, once a digit is typed, a
  /// dash and up to four digits. Other characters are dropped. The dash is
  /// not written before the first digit, so deleting that digit does not
  /// leave a dash that cannot be deleted.
  static String formatCoachCode(String raw) {
    final letters = StringBuffer();
    final digits = StringBuffer();
    for (final unit in raw.codeUnits) {
      final isLetter =
          (unit >= 0x41 && unit <= 0x5A) || (unit >= 0x61 && unit <= 0x7A);
      final isDigit = unit >= 0x30 && unit <= 0x39;
      if (isLetter && letters.length < 4 && digits.isEmpty) {
        // ASCII upper-casing by code: a lower-case letter is 32 above its
        // capital.
        letters.writeCharCode(unit >= 0x61 ? unit - 0x20 : unit);
      } else if (isDigit && letters.length == 4 && digits.length < 4) {
        digits.writeCharCode(unit);
      }
    }
    final head = letters.toString();
    return digits.isEmpty ? head : '$head-$digits';
  }

  /// Formatter for [formatPhone].
  static TextInputFormatter get phone => _MaskFormatter(
    format: formatPhone,
    significant: (c) => c.codeUnitAt(0) >= 0x30 && c.codeUnitAt(0) <= 0x39,
  );

  /// Formatter for [formatCoachCode].
  static TextInputFormatter get coachCode =>
      _MaskFormatter(format: formatCoachCode, significant: (c) => c != '-');
}

class _MaskFormatter extends TextInputFormatter {
  _MaskFormatter({required this.format, required this.significant});

  final String Function(String) format;

  /// Whether a character counts when placing the caret (digits and letters,
  /// not the separators the mask adds).
  final bool Function(String) significant;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = format(newValue.text);
    final caret = newValue.selection.baseOffset.clamp(0, newValue.text.length);
    var before = 0;
    for (var i = 0; i < caret; i++) {
      if (significant(newValue.text[i])) before++;
    }
    var offset = 0;
    var seen = 0;
    while (offset < formatted.length && seen < before) {
      if (significant(formatted[offset])) seen++;
      offset++;
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
