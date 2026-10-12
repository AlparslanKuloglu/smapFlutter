/// The rules of the note sheet (pano 10.6 kare 1 and 2), as pure functions.
abstract final class NoteRules {
  /// The most characters a note holds ("0/500", "44/500").
  static const int maxLength = 500;

  /// [text] as it goes out: trimmed.
  static String normalize(String text) => text.trim();

  /// "Notu Kaydet" (new note) works once there is something to save: "Metin
  /// yokken düğme pasif".
  static bool canAdd(String text) => normalize(text).isNotEmpty;

  /// "Kaydet" (edit) works when the text differs from [original] and is not
  /// empty: "Yalnız değişiklik varsa çalışır". A change of surrounding
  /// whitespace alone is no change.
  static bool canSaveEdit(String text, {required String original}) {
    final next = normalize(text);
    return next.isNotEmpty && next != normalize(original);
  }
}
