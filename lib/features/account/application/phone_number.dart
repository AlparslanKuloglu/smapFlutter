import 'package:smap/shared/ui/inputs/input_masks.dart';

/// A Turkish mobile number as the profile edits and shows it (pano 9.2:
/// "+90 5XX XXX XX XX", number keyboard).
///
/// The field keeps only the ten national digits (`5321234567`); the "+90 " is
/// drawn before them. The stored text of an older account can be in any form
/// the unmasked legacy field allowed ("0532 123 45 67", "+905321234567",
/// "532-123-4567"), so everything reads through [nationalDigits]. Pure and
/// unit-tested.
abstract final class PhoneNumber {
  /// A national number has this many digits (`5XX XXX XX XX`).
  static const int nationalLength = 10;

  /// The country prefix the design writes before the digits.
  static const String countryPrefix = '+90';

  /// The national digits of [raw]: every non-digit is dropped, then a
  /// leading `0090`, `90` or `0` that is a country or trunk prefix is cut.
  /// An empty string for `null` or text without digits.
  static String nationalDigits(String? raw) {
    var digits = (raw ?? '').replaceAll(RegExp('[^0-9]'), '');
    if (digits.startsWith('0090') && digits.length == nationalLength + 4) {
      digits = digits.substring(4);
    } else if (digits.startsWith('90') && digits.length == nationalLength + 2) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0') && digits.length == nationalLength + 1) {
      digits = digits.substring(1);
    }
    return digits;
  }

  /// The digits grouped as the field shows them: `532 123 45 67`. Empty
  /// when there are none.
  static String grouped(String? raw) =>
      AppInputMasks.formatPhone(nationalDigits(raw));

  /// The whole number as the profile shows it in view mode and sends it:
  /// `+90 532 123 45 67`. `null` when [raw] holds no digits.
  static String? display(String? raw) {
    final digits = grouped(raw);
    return digits.isEmpty ? null : '$countryPrefix $digits';
  }

  /// Whether [raw] is a complete mobile number: ten digits, the first a 5.
  static bool isComplete(String? raw) {
    final digits = nationalDigits(raw);
    return digits.length == nationalLength && digits.startsWith('5');
  }
}
