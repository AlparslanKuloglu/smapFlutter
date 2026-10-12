import 'dart:math';

/// The readable password of "Oluştur" in "Öğrenci Ekle" (pano 10.3 "Alan
/// kuralları": "10 karakterlik okunur şifre; karışan harfler (I, l, 0, O)
/// yok").
///
/// The coach reads it out or sends it, so look-alikes are left out: I, O, l,
/// and the digits 0 and 1 (1 reads as l). Every password has at least one
/// upper-case letter, one lower-case letter and one digit, so it passes the
/// usual rules. Pure; give it a seeded [Random] in tests and `Random.secure()`
/// in the app.
abstract final class PasswordGenerator {
  /// "Oluştur" makes this many characters.
  static const int length = 10;

  static const String _upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const String _lower = 'abcdefghijkmnopqrstuvwxyz';
  static const String _digits = '23456789';
  static const String _all = _upper + _lower + _digits;

  /// A new password of [length] characters.
  static String generate(Random random) {
    final chars = <String>[
      _pick(_upper, random),
      _pick(_lower, random),
      _pick(_digits, random),
      for (var i = 3; i < length; i++) _pick(_all, random),
    ]..shuffle(random);
    return chars.join();
  }

  static String _pick(String alphabet, Random random) =>
      alphabet[random.nextInt(alphabet.length)];
}
