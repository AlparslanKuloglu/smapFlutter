import 'package:smap/core/utils/turkish_text.dart';

/// The fallback letters of an avatar (C55 "Görsel yüklenemezse: baş harfler").
abstract final class AvatarInitials {
  /// The first letter of the first and of the last word of [name], upper-case
  /// with the Turkish rule ("alparslan kuloğlu" gives "AK", "ilker" gives
  /// "İ"). One word gives one letter, several words give the outer two (a
  /// middle name is skipped); a blank name gives an empty string.
  static String of(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList(growable: false);
    if (words.isEmpty) return '';
    String first(String word) =>
        TurkishText.upper(String.fromCharCode(word.runes.first));
    if (words.length == 1) return first(words.first);
    return '${first(words.first)}${first(words.last)}';
  }
}
