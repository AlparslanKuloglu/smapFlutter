import 'package:smap/features/cards/application/deck_library.dart';
import 'package:smap/features/cards/domain/lesson_cards.dart';

/// The Tarih deck of pano 8.1: 23 missing cards (the first two are the ones on
/// the board), 41 known, 6 starred.
const tarihLesson = '66214a6982ff212039ea3294';

InfoCard card(
  String id,
  String name, {
  String? text,
  bool favorite = false,
  String? subject,
}) => InfoCard(
  itemId: id,
  name: name,
  mainSubjectName: subject,
  descriptions: [?text],
  isFavorite: favorite,
);

/// 23 missing cards: "edirne", "otlukbeli", then "Konu 3" to "Konu 23".
List<InfoCard> missingCards() => [
  card(
    'edirne',
    'Edirne-Segedin Antlaşması (1444)',
    text:
        "Haçlılarla Osmanlı Devleti'nin imzaladığı ilk antlaşma. Tuna sınır "
        'olur, on yıl savaş yapılmaz.',
    subject: 'Osmanlı Tarihi',
  ),
  card(
    'otlukbeli',
    'Otlukbeli Savaşı (1473)',
    text: 'Fatih Sultan Mehmet – Uzun Hasan (Akkoyunlu).',
    subject: 'Osmanlı Tarihi',
  ),
  for (var i = 3; i <= 23; i++) card('m$i', 'Konu $i', text: 'Açıklama $i.'),
];

List<InfoCard> knownCards([int count = 41]) => [
  for (var i = 1; i <= count; i++) card('k$i', 'Bilinen $i', text: 'Metin $i.'),
];

/// Six starred cards: two missing, three known and one that only the favorites
/// list knows.
List<InfoCard> favoriteCards() => [
  card('m5', 'Konu 5', favorite: true),
  card('m9', 'Konu 9', favorite: true),
  card('k1', 'Bilinen 1', favorite: true),
  card('k2', 'Bilinen 2', favorite: true),
  card('k3', 'Bilinen 3', favorite: true),
  card('f-only', 'Yalnız favoride', text: 'Durumu bilinmiyor.', favorite: true),
];

LessonCardDecks tarihDecks() => LessonCardDecks(
  missing: missingCards(),
  known: knownCards(),
  favorites: favoriteCards(),
);

DeckLibrary tarihLibrary() => DeckLibrary.fromSources([
  DeckSource(lessonId: tarihLesson, decks: tarihDecks()),
]);

/// `getLessonInfoCards` as the server writes it.
Map<String, Object?> decksAnswer(LessonCardDecks decks) => {
  'success': true,
  'data': {
    'failedCards': [for (final c in decks.missing) _entry(c)],
    'successCards': [for (final c in decks.known) _entry(c)],
    'favoriteCards': [for (final c in decks.favorites) _entry(c)],
  },
};

Map<String, Object?> _entry(InfoCard c) => {
  'favorite': c.isFavorite ? 1 : 0,
  'item': {
    '_id': c.itemId,
    'name': c.name,
    'desc': c.descriptions,
    if (c.mainSubjectName != null) 'mainSubject': {'name': c.mainSubjectName},
  },
};
