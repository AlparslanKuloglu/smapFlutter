/// The three decks of a lesson's cards (pano 8.1 "Sayaçlı segment": Eksiklerim,
/// Bildiklerim, Favorilerim).
///
/// [key] is the value of the `group` query parameter of the deck route
/// (`/lessons/deck?...&group=eksik|bildik|favori`, spec §3.6).
enum DeckGroup {
  /// Eksiklerim: cards the student has not learned yet.
  missing('eksik'),

  /// Bildiklerim: cards moved there with "Öğrendim".
  known('bildik'),

  /// Favorilerim: cards the student starred.
  favorite('favori');

  const DeckGroup(this.key);

  /// The route parameter value.
  final String key;

  /// The group of a route parameter; `null` for anything else (the deck then
  /// opens on Eksiklerim).
  static DeckGroup? parse(String? key) {
    for (final group in values) {
      if (group.key == key) return group;
    }
    return null;
  }
}
