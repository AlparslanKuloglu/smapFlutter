import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/cards/application/deck_card.dart';
import 'package:smap/features/cards/application/deck_group.dart';
import 'package:smap/features/cards/application/deck_library.dart';
import 'package:smap/features/cards/domain/lesson_cards.dart';

import 'deck_fixtures.dart';

void main() {
  group('the library of pano 8.1', () {
    final library = tarihLibrary();

    test('counts the three groups (23 · 41 · 6)', () {
      expect(
        library.counts,
        const DeckCounts(missing: 23, known: 41, favorite: 6),
      );
      expect(library.counts.of(DeckGroup.known), 41);
      expect(library.isEmpty, isFalse);
    });

    test('keeps the server order', () {
      expect(library.keysOf(DeckGroup.missing).take(3), [
        'edirne',
        'otlukbeli',
        'm3',
      ]);
      expect(library.keysOf(DeckGroup.favorite), [
        'm5',
        'm9',
        'k1',
        'k2',
        'k3',
        'f-only',
      ]);
    });

    test('a card in Eksiklerim and in Favorilerim is one card with a star', () {
      final five = library.cardOf('m5')!;
      expect(five.status, CardStatus.missing);
      expect(five.isFavorite, isTrue);
      expect(library.cardOf('m6')!.isFavorite, isFalse);
    });

    test('a card only the favorites list knows has an unknown status', () {
      final only = library.cardOf('f-only')!;
      expect(only.status, CardStatus.unknown);
      expect(only.isFavorite, isTrue);
      expect(only.canLearn, isFalse);
      expect(library.keysOf(DeckGroup.missing), isNot(contains('f-only')));
      expect(library.keysOf(DeckGroup.known), isNot(contains('f-only')));
    });

    test('writes the body one paragraph per line', () {
      final edirne = library.cardOf('edirne')!;
      expect(edirne.title, 'Edirne-Segedin Antlaşması (1444)');
      expect(edirne.body, startsWith("Haçlılarla Osmanlı Devleti'nin"));
      expect(edirne.lessonId, tarihLesson);
      const two = DeckCard(
        key: 'x',
        card: InfoCard(itemId: 'x', name: 'A', descriptions: ['b', ' ', 'c ']),
      );
      expect(two.body, 'b\nc');
    });
  });

  group('learning (pano 8.1 kare 3)', () {
    test('moves the card to the front of Bildiklerim: 22 · 42 · 6', () {
      final next = tarihLibrary().learned('edirne');

      expect(
        next.counts,
        const DeckCounts(missing: 22, known: 42, favorite: 6),
      );
      expect(next.keysOf(DeckGroup.missing).first, 'otlukbeli');
      expect(next.keysOf(DeckGroup.known).first, 'edirne');
      expect(next.cardOf('edirne')!.status, CardStatus.known);
    });

    test('keeps a starred card in Favorilerim', () {
      final next = tarihLibrary().learned('m5');
      expect(next.keysOf(DeckGroup.favorite), contains('m5'));
      expect(next.cardOf('m5')!.isFavorite, isTrue);
      expect(next.counts.favorite, 6);
    });

    test('a card that is not missing is not learned', () {
      final library = tarihLibrary();
      expect(library.learned('k1'), same(library));
      expect(library.learned('f-only'), same(library));
      expect(library.learned('nobody'), same(library));
    });

    test('"Geri Al" puts the card back where it stood', () {
      final library = tarihLibrary();
      final at = library.missingIndexOf('m7');
      expect(at, 6);

      final back = library.learned('m7').unlearned('m7', index: at);

      expect(back, library);
      expect(back.keysOf(DeckGroup.missing)[at], 'm7');
      expect(back.counts, library.counts);
    });

    test('a card that is not known is not taken back', () {
      final library = tarihLibrary();
      expect(library.unlearned('m3'), same(library));
    });
  });

  group('the star', () {
    test('adds and removes the card from Favorilerim', () {
      final library = tarihLibrary();

      final starred = library.withFavorite('m6', value: true);
      expect(starred.counts.favorite, 7);
      expect(starred.keysOf(DeckGroup.favorite).last, 'm6');

      final plain = starred.withFavorite('m6', value: false);
      expect(plain.counts.favorite, 6);
      expect(plain, library);
    });

    test('the same value changes nothing', () {
      final library = tarihLibrary();
      expect(library.withFavorite('m5', value: true), same(library));
    });
  });

  group('building from the server answer', () {
    test(
      'a card that is starred but not repeated in the list still counts',
      () {
        final library = DeckLibrary.fromSources([
          DeckSource(
            decks: LessonCardDecks(
              missing: [card('a', 'A', text: 't', favorite: true)],
            ),
          ),
        ]);
        expect(library.keysOf(DeckGroup.favorite), ['a']);
      },
    );

    test('leaves out a card with nothing to read', () {
      final library = DeckLibrary.fromSources(const [
        DeckSource(
          decks: LessonCardDecks(
            missing: [
              InfoCard(itemId: 'e'),
              InfoCard(itemId: 'f', name: 'F'),
            ],
          ),
        ),
      ]);
      expect(library.keysOf(DeckGroup.missing), ['f']);
    });

    test('a card without an id gets a made-up key and cannot be learned', () {
      final library = DeckLibrary.fromSources(const [
        DeckSource(
          decks: LessonCardDecks(missing: [InfoCard(name: 'Kimliksiz')]),
        ),
      ]);
      final key = library.keysOf(DeckGroup.missing).single;
      expect(library.cardOf(key)!.canLearn, isFalse);
      expect(library.cardOf(key)!.canFavorite, isFalse);
    });

    test('keeps the lesson of each source', () {
      final library = DeckLibrary.fromSources([
        DeckSource(
          lessonId: 'a',
          decks: LessonCardDecks(missing: [card('1', 'Bir')]),
        ),
        DeckSource(
          lessonId: 'b',
          decks: LessonCardDecks(missing: [card('2', 'İki')]),
        ),
      ]);
      expect(library.cardOf('1')!.lessonId, 'a');
      expect(library.cardOf('2')!.lessonId, 'b');
      expect(library.keysOf(DeckGroup.missing), ['1', '2']);
    });

    test('no cards is an empty library', () {
      expect(const DeckLibrary.empty().isEmpty, isTrue);
      expect(const DeckLibrary.empty().counts.isEmpty, isTrue);
      expect(DeckLibrary.fromSources(const []).isEmpty, isTrue);
    });
  });

  test('parses the route parameter of a group', () {
    expect(DeckGroup.parse('eksik'), DeckGroup.missing);
    expect(DeckGroup.parse('bildik'), DeckGroup.known);
    expect(DeckGroup.parse('favori'), DeckGroup.favorite);
    expect(DeckGroup.parse('x'), isNull);
    expect(DeckGroup.parse(null), isNull);
  });
}
