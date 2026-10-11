/// A coach's share code ("koçluk kodu"): four letters and four digits, shown
/// as `AAAA-0000` (spec §6.2 8.8, §6.3 #15).
///
/// Pure text helpers for the entry field. Whether the backend stores the code
/// with or without the dash, and whether it compares case-insensitively, is an
/// open question; `AccountRepository.addCoach` therefore sends the text as the
/// caller gives it, and the UI decides between [display] and [compact].
final class CoachCode {
  const CoachCode._(this.letters, this.digits);

  /// The four letters, upper case.
  final String letters;

  /// The four digits.
  final String digits;

  static final RegExp _shape = RegExp(r'^([A-Za-z]{4})-?([0-9]{4})$');

  /// Reads typed text: surrounding spaces and the dash are optional, letters
  /// may be lower case. `null` when the text is not four letters and four
  /// digits.
  static CoachCode? tryParse(String? input) {
    if (input == null) return null;
    final match = _shape.firstMatch(input.trim().replaceAll(' ', ''));
    if (match == null) return null;
    return CoachCode._(match.group(1)!.toUpperCase(), match.group(2)!);
  }

  /// Whether [input] is a well-formed code.
  static bool isValid(String? input) => tryParse(input) != null;

  /// `AAAA-0000`.
  String get display => '$letters-$digits';

  /// `AAAA0000`.
  String get compact => '$letters$digits';

  @override
  bool operator ==(Object other) =>
      other is CoachCode && other.letters == letters && other.digits == digits;

  @override
  int get hashCode => Object.hash(letters, digits);

  @override
  String toString() => display;
}
