import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/lessons/application/topic_outline.dart';
import 'package:smap/features/lessons/domain/lesson_content.dart';

import 'topic_samples.dart';

void main() {
  group('TopicOutline.of', () {
    final outline = TopicOutline.of(sozcukteAnlam());

    test('leaves out a sub-topic without items', () {
      expect(outline.subTopics.map((s) => s.name), [
        'Anlamı Yönünden Sözcükler',
        'Sözcükler Arası Anlam İlişkileri',
      ]);
      expect(outline.itemCount, 5);
    });

    test('numbers the items inside their sub-topic, 1 to n', () {
      expect(outline.subTopics.first.items.map((i) => i.number), [1, 2, 3, 4]);
      expect(outline.subTopics.last.items.single.number, 1);
    });

    test('reads the card state: missing, learned, unknown', () {
      final items = outline.subTopics.first.items;
      expect(items.map((i) => i.card), [
        ItemCardState.missing,
        ItemCardState.learned,
        ItemCardState.unknown, // no record at all
        ItemCardState.unknown, // a record without any status
      ]);
      // One card of two missing is a missing item.
      expect(outline.subTopics.last.items.single.isMissing, isTrue);
    });

    test('counts the missing items of a sub-topic (not the cards)', () {
      expect(outline.subTopics.first.missingCount, 1);
      expect(outline.subTopics.last.missingCount, 1);
    });

    test('offers the card only where its state is known', () {
      final items = outline.subTopics.first.items;
      expect(items.map((i) => i.hasCard), [true, true, false, false]);
    });

    test('splits the text of the item into definition and example', () {
      final first = outline.subTopics.first.items.first;
      expect(first.text.definition, hasLength(1));
      expect(
        first.text.examples.single.text,
        'Bazı insanlar karanlıktan korkar.',
      );
    });

    test('"Öğrendim" needs a missing card and a record id', () {
      final items = outline.subTopics.first.items;
      expect(items.map((i) => i.canLearn), [true, false, false, false]);
    });

    test('keeps the favorite of the item', () {
      expect(outline.subTopics.first.items[3].isFavorite, isTrue);
    });
  });

  group('first missing item (pano 7.3 "ilk eksik açık")', () {
    test('is the first missing item over all sub-topics', () {
      final outline = TopicOutline.of(sozcukteAnlam());
      expect(
        outline.firstMissing,
        const FocusTarget(subTopicId: 'ss-1', itemKey: 'ss-1:0'),
      );
      expect(outline.initiallyOpenSubTopic, 'ss-1');
    });

    test('skips sub-topics where everything is learned', () {
      final outline = TopicOutline.of([
        const SubSubject(
          id: 'a',
          name: 'A',
          items: [
            LessonItem(
              name: 'x',
              progress: ItemProgress(id: 'p', status: 1, statusArray: [1]),
            ),
          ],
        ),
        const SubSubject(
          id: 'b',
          name: 'B',
          items: [
            LessonItem(
              name: 'y',
              progress: ItemProgress(id: 'q', status: 0),
            ),
          ],
        ),
      ]);
      expect(outline.firstMissing?.subTopicId, 'b');
      expect(outline.initiallyOpenSubTopic, 'b');
    });

    test(
      'with nothing missing the first sub-topic opens and nothing scrolls',
      () {
        final outline = TopicOutline.of([
          const SubSubject(
            id: 'a',
            name: 'A',
            items: [LessonItem(name: 'x')],
          ),
        ]);
        expect(outline.firstMissing, isNull);
        expect(outline.initiallyOpenSubTopic, 'a');
      },
    );

    test('an empty topic has no sub-topic to open', () {
      final outline = TopicOutline.of(const []);
      expect(outline.isEmpty, isTrue);
      expect(outline.initiallyOpenSubTopic, isNull);
    });
  });

  group('changing one item', () {
    test('learned: only that item changes, the tag and the count follow', () {
      final outline = TopicOutline.of(sozcukteAnlam());
      final next = outline.withItem(
        'ss-1:0',
        (item) => item.copyWith(card: ItemCardState.learned),
      );

      expect(next.itemOf('ss-1:0')!.card, ItemCardState.learned);
      expect(next.subTopics.first.missingCount, 0);
      expect(next.itemOf('ss-1:1'), outline.itemOf('ss-1:1'));
      expect(next.subTopics.last, same(outline.subTopics.last));
      expect(next.firstMissing?.subTopicId, 'ss-2');
      expect(outline.itemOf('ss-1:0')!.isMissing, isTrue, reason: 'unchanged');
    });

    test('an unknown key changes nothing', () {
      final outline = TopicOutline.of(sozcukteAnlam());
      expect(outline.withItem('nope', (item) => item), outline);
      expect(outline.itemOf('nope'), isNull);
    });

    test('knows the sub-topic of an item', () {
      final outline = TopicOutline.of(sozcukteAnlam());
      expect(outline.subTopicOf('ss-2:0')?.id, 'ss-2');
      expect(outline.subTopicOf('nope'), isNull);
    });
  });

  group('cardStateOf', () {
    test('reads a learned status or a list of ones', () {
      expect(
        TopicOutline.cardStateOf(const ItemProgress(status: 1)),
        ItemCardState.learned,
      );
      expect(
        TopicOutline.cardStateOf(const ItemProgress(statusArray: [1, 1])),
        ItemCardState.learned,
      );
    });

    test('a zero anywhere is missing', () {
      expect(
        TopicOutline.cardStateOf(const ItemProgress(statusArray: [1, 0])),
        ItemCardState.missing,
      );
      expect(
        TopicOutline.cardStateOf(const ItemProgress(status: 0)),
        ItemCardState.missing,
      );
    });

    test('no record, no status: unknown', () {
      expect(TopicOutline.cardStateOf(null), ItemCardState.unknown);
      expect(
        TopicOutline.cardStateOf(const ItemProgress()),
        ItemCardState.unknown,
      );
    });
  });
}
