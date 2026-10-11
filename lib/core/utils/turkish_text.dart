/// Turkish-aware text helpers (spec §1.11; AGENTS: never `toUpperCase()` on
/// Turkish text).
///
/// Dart's `toLowerCase` maps "I" to "i" and `toUpperCase` maps "i" to "I",
/// both wrong in Turkish ("İ" and "ı" exist); `compareTo` orders by code
/// unit, so "Ç" lands after "Z". Everything here works one UTF-16 unit at a
/// time through a small table, so [lower], [upper] and [fold] keep the
/// length of the input and an offset found in the folded text is the same
/// offset in the original (used to highlight a search match).
abstract final class TurkishText {
  static const Map<String, String> _lowerSpecial = {'I': 'ı', 'İ': 'i'};
  static const Map<String, String> _upperSpecial = {'i': 'İ', 'ı': 'I'};

  /// Turkish lower case: "IŞIK" → "ışık", "İPEK" → "ipek".
  static String lower(String text) {
    final out = StringBuffer();
    for (final unit in text.split('')) {
      out.write(_lowerSpecial[unit] ?? unit.toLowerCase());
    }
    return out.toString();
  }

  /// Turkish upper case: "ışık" → "IŞIK", "istanbul" → "İSTANBUL".
  ///
  /// Product rule: the UI has no all-caps text (no uppercase buttons or
  /// letter-spaced labels). This exists for data that must be upper case,
  /// such as a code or a sort key; it is not a styling tool.
  static String upper(String text) {
    final out = StringBuffer();
    for (final unit in text.split('')) {
      out.write(_upperSpecial[unit] ?? unit.toUpperCase());
    }
    return out.toString();
  }

  /// First letter upper case, the rest untouched: "işık" → "İşık".
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return upper(text[0]) + text.substring(1);
  }

  /// Each word starts upper case and continues lower case: "MEHMET ÖZKAN" →
  /// "Mehmet Özkan", "ilknur" → "İlknur", "ayşe-nur" → "Ayşe-Nur". Words are
  /// split at spaces and hyphens; an apostrophe does not start a new word.
  static String titleCase(String text) {
    final out = StringBuffer();
    var atWordStart = true;
    for (final unit in text.split('')) {
      if (unit == ' ' || unit == '-') {
        out.write(unit);
        atWordStart = true;
      } else {
        out.write(atWordStart ? upper(unit) : lower(unit));
        atWordStart = false;
      }
    }
    return out.toString();
  }

  static const Map<String, String> _fold = {
    'ı': 'i',
    'ş': 's',
    'ğ': 'g',
    'ü': 'u',
    'ö': 'o',
    'ç': 'c',
    'â': 'a',
    'î': 'i',
    'û': 'u',
  };

  /// Search key: Turkish lower case with the Turkish marks removed, so
  /// "nevresim", "Nevresim" and "NEVRESİM" match, and "cay" finds "Çay".
  /// Keeps the length of [text].
  static String fold(String text) {
    final out = StringBuffer();
    for (final unit in lower(text).split('')) {
      out.write(_fold[unit] ?? unit);
    }
    return out.toString();
  }

  /// Whether [query] occurs in [text], ignoring case and Turkish marks. A
  /// blank [query] matches everything.
  static bool contains(String text, String query) =>
      fold(text).contains(fold(query.trim()));

  static List<_Token> _tokens(String text) => [
    for (final match in RegExp(r'\S+').allMatches(text))
      _Token(match.start, match.group(0)!),
  ];

  /// Name search: every word of [query] is the start of some word of
  /// [text], in any order, ignoring case and Turkish marks. "mehmet oz"
  /// finds "Mehmet Özkan". A blank [query] matches everything.
  static bool matchesTokens(String text, String query) {
    final queryTokens = _queryTokens(query);
    if (queryTokens.isEmpty) return true;
    return matchRanges(text, query).isNotEmpty;
  }

  /// The ranges of [text] that a [matchesTokens] search matched, for
  /// highlighting: for each query word the start of the first text word it
  /// begins, as offsets into the original [text] (end exclusive). Sorted,
  /// overlaps merged. Empty when the query is blank or some query word has
  /// no match.
  static List<({int start, int end})> matchRanges(String text, String query) {
    final queryTokens = _queryTokens(query);
    if (queryTokens.isEmpty) return const [];
    final textTokens = _tokens(fold(text));
    final ranges = <({int start, int end})>[];
    for (final q in queryTokens) {
      final index = textTokens.indexWhere((t) => t.text.startsWith(q));
      if (index < 0) return const [];
      final start = textTokens[index].start;
      ranges.add((start: start, end: start + q.length));
    }
    ranges.sort((a, b) => a.start.compareTo(b.start));
    final merged = <({int start, int end})>[ranges.first];
    for (final range in ranges.skip(1)) {
      final last = merged.last;
      if (range.start <= last.end) {
        merged[merged.length - 1] = (
          start: last.start,
          end: range.end > last.end ? range.end : last.end,
        );
      } else {
        merged.add(range);
      }
    }
    return merged;
  }

  static List<String> _queryTokens(String query) => [
    for (final token in fold(query).split(RegExp(r'\s+')))
      if (token.isNotEmpty) token,
  ];

  /// The Turkish alphabet; q, w and x sit where they fall in loanwords.
  static const String _alphabet = 'abcçdefgğhıijklmnoöpqrsştuüvwxyz';

  /// Sort key for alphabetical lists: Turkish order, case-insensitive ("Çay"
  /// between "Cam" and "Dolap", "ısıtıcı" before "iplik").
  static String collationKey(String text) {
    final out = StringBuffer();
    for (final unit in lower(text).split('')) {
      final letter = switch (unit) {
        'â' => 'a',
        'î' => 'i',
        'û' => 'u',
        _ => unit,
      };
      final index = _alphabet.indexOf(letter);
      // Letters map into a private range in alphabet order, above spaces,
      // digits and punctuation, which keep their code unit.
      out.writeCharCode(index >= 0 ? 0xE000 + index : letter.codeUnitAt(0));
    }
    return out.toString();
  }

  /// Compares two strings in Turkish alphabetical order, for `List.sort`.
  static int compare(String a, String b) =>
      collationKey(a).compareTo(collationKey(b));
}

class _Token {
  const _Token(this.start, this.text);
  final int start;
  final String text;
}

/// Turkish suffix harmony for strings built at runtime (spec §1.11, "Ek
/// uyumu"). The templates that need it:
///
/// | template | call |
/// |---|---|
/// | `{topic}'nde` | `locative(topic, possessed: true)` |
/// | `{wrong}'unu` | `possessiveAccusative('9')` → `9'unu` |
/// | `{wrong}'u yanlış` | `possessive('9')` → `9'u` |
/// | `{weekday}'yi` | `accusative('Cumartesi')` → `Cumartesi'yi` |
/// | `{type}'ye` | `dative('TYT')` → `TYT'ye` |
/// | `{name}'ın verileri` | `genitive('Mehmet Özkan')` → `Mehmet Özkan'ın` |
/// | `{name}'a bağlandın` | `dative('Mehmet Özkan')` → `Mehmet Özkan'a` |
///
/// Every function returns the word with the apostrophe and suffix attached
/// (the apostrophe is the straight U+0027 the boards use). The suffix is
/// chosen from how the last word is _read_, not how it is written:
///
/// - a number is read by its last spoken part (9 "dokuz" → u, 6 "altı" →
///   ends in a vowel, 20 "yirmi", 100 "yüz", 1000 "bin");
/// - a short all-capitals token is spelled letter by letter (TYT "…te" → the
///   dative is `'ye`, YKS "…se" → `'ye`); a spelled token of more than three
///   letters is only recognized when it has no vowel (KPSS, LGS). Pass
///   `spelled: true` / `false` to override;
/// - anything else is read as written, by its last vowel.
///
/// Limits, on purpose: with an apostrophe the word is a proper name, so the
/// final consonant does not soften ("Çiçek'e", not "Çiçeğe"), and the rare
/// words that break vowel harmony (saat, kalp, hâl) are not special-cased.
abstract final class TurkishSuffix {
  static const String _apostrophe = "'";
  static const String _vowels = 'aeıioöuü';
  static const String _backVowels = 'aıou';
  static const String _voiceless = 'fstkçşhp';

  /// "-(y)A": `'e`, `'a`, `'ye`, `'ya`. "Ahmet'e", "Ayşe'ye", "TYT'ye".
  static String dative(String word, {bool? spelled}) {
    final r = _Reading.of(word, spelled);
    return '${word.trim()}$_apostrophe${r.endsInVowel ? 'y' : ''}${r.a2}';
  }

  /// "-(y)I": `'i`, `'ı`, `'u`, `'ü` (+ `y` after a vowel). "Cumartesi'yi",
  /// "Salı'yı", "Pazar'ı".
  static String accusative(String word, {bool? spelled}) {
    final r = _Reading.of(word, spelled);
    return '${word.trim()}$_apostrophe${r.endsInVowel ? 'y' : ''}${r.i4}';
  }

  /// "-(n)In": `'in`, `'ın`, `'un`, `'ün` (+ `n` after a vowel).
  /// "Ayşe'nin", "Mehmet Özkan'ın".
  static String genitive(String word, {bool? spelled}) {
    final r = _Reading.of(word, spelled);
    return '${word.trim()}$_apostrophe${r.endsInVowel ? 'n' : ''}${r.i4}n';
  }

  /// "-DA": `'de`, `'da`, `'te`, `'ta` (`t` after a voiceless consonant).
  ///
  /// With [possessed] the word already carries the third-person possessive
  /// (a topic such as "Kurtuluş Savaşı Hazırlık Dönemi") and takes `'nde` /
  /// `'nda`.
  static String locative(String word, {bool possessed = false, bool? spelled}) {
    final r = _Reading.of(word, spelled);
    final stem = possessed ? 'nd' : (r.endsVoiceless ? 't' : 'd');
    return '${word.trim()}$_apostrophe$stem${r.a2}';
  }

  /// "-DAn": `'den`, `'dan`, `'ten`, `'tan`; [possessed] gives `'nden` /
  /// `'ndan`.
  static String ablative(
    String word, {
    bool possessed = false,
    bool? spelled,
  }) => '${locative(word, possessed: possessed, spelled: spelled)}n';

  /// Third-person possessive "-(s)I": `'u`, `'ü`, `'ı`, `'i` (+ `s` after a
  /// vowel). `possessive('9')` → `9'u`, `possessive('6')` → `6'sı`: "13
  /// sorudan 9'u yanlış".
  static String possessive(String word, {bool? spelled}) {
    final r = _Reading.of(word, spelled);
    return '${word.trim()}$_apostrophe${r.endsInVowel ? 's' : ''}${r.i4}';
  }

  /// Possessive then accusative "-(s)InI": `'unu`, `'ünü`, `'ını`, `'ini`
  /// (`'sını` after a vowel). `possessiveAccusative('9')` → `9'unu`:
  /// "13 sorudan 9'unu kaçırdın".
  static String possessiveAccusative(String word, {bool? spelled}) {
    final r = _Reading.of(word, spelled);
    final prefix = r.endsInVowel ? 's' : '';
    return '${word.trim()}$_apostrophe$prefix${r.i4}n${r.i4}';
  }

  static const Map<String, String> _letterNames = {
    'a': 'a',
    'b': 'be',
    'c': 'ce',
    'ç': 'çe',
    'd': 'de',
    'e': 'e',
    'f': 'fe',
    'g': 'ge',
    'ğ': 'ge',
    'h': 'he',
    'ı': 'ı',
    'i': 'i',
    'j': 'je',
    'k': 'ke',
    'l': 'le',
    'm': 'me',
    'n': 'ne',
    'o': 'o',
    'ö': 'ö',
    'p': 'pe',
    'q': 'kü',
    'r': 're',
    's': 'se',
    'ş': 'şe',
    't': 'te',
    'u': 'u',
    'ü': 'ü',
    'v': 've',
    'w': 've',
    'x': 'iks',
    'y': 'ye',
    'z': 'ze',
  };

  static const List<String> _digitWords = [
    'sıfır',
    'bir',
    'iki',
    'üç',
    'dört',
    'beş',
    'altı',
    'yedi',
    'sekiz',
    'dokuz',
  ];

  static const List<String> _tensWords = [
    '',
    'on',
    'yirmi',
    'otuz',
    'kırk',
    'elli',
    'altmış',
    'yetmiş',
    'seksen',
    'doksan',
  ];

  static const List<String> _scaleWords = [
    'bin',
    'milyon',
    'milyar',
    'trilyon',
    'katrilyon',
  ];

  /// The last spoken word of a digit string: "9" → "dokuz", "20" → "yirmi",
  /// "300" → "yüz", "5000" → "bin", "0" → "sıfır". Works on the digits, so
  /// a number of any length needs no parsing.
  static String _numberReading(String digits) {
    var place = 0; // rightmost non-zero digit, counted from the right
    var found = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      if (digits[i] != '0') {
        found = true;
        break;
      }
      place++;
    }
    if (!found) return _digitWords[0];
    final digit = int.parse(digits[digits.length - 1 - place]);
    if (place == 0) return _digitWords[digit];
    if (place == 1) return _tensWords[digit];
    if (place == 2) return 'yüz';
    final scale = ((place ~/ 3) - 1).clamp(0, _scaleWords.length - 1);
    return _scaleWords[scale];
  }

  static String _spell(String letters) {
    final last = TurkishText.lower(letters[letters.length - 1]);
    return _letterNames[last] ?? last;
  }

  static bool _isUpperLetters(String token) {
    if (token.isEmpty) return false;
    return token == TurkishText.upper(token) &&
        token != TurkishText.lower(token) &&
        !token.contains(RegExp(r'[0-9\s]'));
  }

  static bool _hasVowel(String token) {
    for (final unit in TurkishText.lower(token).split('')) {
      if (_vowels.contains(unit)) return true;
    }
    return false;
  }

  static bool _looksSpelled(String token) {
    if (token.length < 2 || token.length > 5 || !_isUpperLetters(token)) {
      return false;
    }
    return token.length <= 3 || !_hasVowel(token);
  }
}

/// How the end of a word sounds, which is all vowel harmony needs.
class _Reading {
  const _Reading._(this.endsInVowel, this.endsVoiceless, this.a2, this.i4);

  factory _Reading.of(String word, bool? spelled) {
    final trimmed = word.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(word, 'word', 'must not be blank');
    }
    final parts = trimmed.split(RegExp(r'\s+'));
    final token = parts.last;
    final String reading;
    if (RegExp(r'^[0-9]+$').hasMatch(token)) {
      reading = TurkishSuffix._numberReading(token);
    } else if (spelled ?? TurkishSuffix._looksSpelled(token)) {
      reading = TurkishSuffix._spell(token);
    } else {
      reading = TurkishText.lower(token);
    }

    final last = reading[reading.length - 1];
    var vowel = 'e';
    for (var i = reading.length - 1; i >= 0; i--) {
      if (TurkishSuffix._vowels.contains(reading[i])) {
        vowel = reading[i];
        break;
      }
    }
    final back = TurkishSuffix._backVowels.contains(vowel);
    final i4 = switch (vowel) {
      'a' || 'ı' => 'ı',
      'e' || 'i' => 'i',
      'o' || 'u' => 'u',
      _ => 'ü',
    };
    return _Reading._(
      TurkishSuffix._vowels.contains(last),
      TurkishSuffix._voiceless.contains(last),
      back ? 'a' : 'e',
      i4,
    );
  }

  final bool endsInVowel;
  final bool endsVoiceless;

  /// Two-way harmony vowel: a or e.
  final String a2;

  /// Four-way harmony vowel: ı, i, u or ü.
  final String i4;
}
