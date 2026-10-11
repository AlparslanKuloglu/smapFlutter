import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/lessons/data/dtos/lesson_answers.dart';
import 'package:smap/features/lessons/data/dtos/lesson_item_dto.dart';
import 'package:smap/features/lessons/data/mappers/lesson_mappers.dart';
import 'package:smap/features/lessons/domain/lesson_content.dart';

import 'lesson_fixtures.dart';

void main() {
  group('items', () {
    final lists = ItemsResponse.fromBody(itemsAnswer()).itemLists!;
    final items = lessonItemsOf(lists.first.items);

    test('reads a topic item with its cards and progress', () {
      final item = items.first;

      expect(item.id, 'item-1');
      expect(item.name, 'Orta Asya');
      expect(item.descriptions, ['Birinci paragraf.', 'İkinci.']);
      expect(item.text, 'Birinci paragraf.\n\nİkinci.');
      expect(item.prompts, hasLength(3));
      expect(item.prompts[0].content, 'Metin 1');
      expect(item.prompts[0].isFavorite, isTrue);
      expect(item.prompts[1].content, 'Metin 2', reason: '`text` fallback');
      expect(item.prompts[2].content, isNull);
      expect(item.progress!.id, 'prog-1');
      expect(item.progress!.status, 0);
      expect(item.progress!.statusArray, [0, 1, 0]);
      expect(item.progress!.hasMissing, isTrue);
      expect(item.progress!.isLearned, isFalse);
      expect(item.progress!.missingCount, 2);
      expect(item.missingCount, 2);
      expect(item.hasMissing, isTrue);
      expect(item.isAuthor, isFalse);
    });

    test('a stand-alone item counts as one missing card', () {
      final item = items[1];

      expect(item.name, 'Bağımsız');
      expect(item.progress!.status, 0);
      expect(item.progress!.isIndependent, isTrue);
      expect(item.progress!.statusArray, isEmpty);
      expect(item.progress!.missingCount, 1);
    });

    test('entries without a name are dropped and positions are kept', () {
      expect(items, hasLength(2));
      expect(lists, hasLength(2));
      expect(lists.last.items, isEmpty);
    });

    test('a learned item has nothing missing', () {
      final item = LessonItemDto.fromJson({
        'name': 'x',
        'itemData': {
          'status': 1,
          'statusArray': [1, 1],
        },
      }).toDomain()!;

      expect(item.progress!.isLearned, isTrue);
      expect(item.progress!.hasMissing, isFalse);
      expect(item.missingCount, 0);
      expect(item.hasMissing, isFalse);
    });

    test('status reads the legacy spellings', () {
      ItemProgress read(Object? status, [Object? array]) =>
          ItemDataDto.fromJson({
            'status': status,
            'statusArray': array,
          }).toDomain();

      expect(read(true).status, 1);
      expect(read('true').status, 1);
      expect(read('1').status, 1);
      expect(read(false).status, 0);
      expect(read('0').status, 0);
      expect(read(0).status, 0);
      expect(read(2).status, isNull);
      expect(read('later').status, isNull);
      expect(read(null, 'x').statusArray, isEmpty);
      expect(read(null, [1, 'true', 'x', null, 0]).statusArray, [1, 1, 0]);
    });

    test('odd shapes do not fail an item', () {
      final item = LessonItemDto.fromJson({
        'name': 'x',
        'desc': 42,
        'itemData': 'not an object',
        'works': 'no',
        'itemDatas': [1, 2],
        'itsYazar': 'maybe',
      }).toDomain()!;

      expect(item.descriptions, isEmpty);
      expect(item.progress, isNull);
      expect(item.works, isEmpty);
      expect(item.isAuthor, isFalse);
      expect(item.missingCount, 0);
    });
  });

  group('sub-subjects', () {
    test('pair every sub-subject with its list of items', () {
      final subs = SubSubjectsResponse.fromBody(
        subSubjectsAnswer(),
      ).subSubjects!;
      final lists = ItemsResponse.fromBody(itemsAnswer()).itemLists!;

      final first = subs[0].toDomain(items: lists[0].items)!;
      final second = subs[1].toDomain(items: lists[1].items)!;

      expect(first.id, 'ss-1');
      expect(first.items, hasLength(2));
      expect(first.computedMissing, 3);
      expect(first.missing, 3, reason: 'no server count: computed');
      expect(second.items, isEmpty);
      expect(subs[2].toDomain(), isNull);
    });

    test('the server count wins in Yazar & Eserler', () {
      final sub = SubSubjectsResponse.fromBody(
        authorSubSubjectsAnswer(),
      ).subSubjects!.single.toDomain()!;

      expect(sub.missingCount, 2);
      expect(sub.missing, 2);
    });

    test('an era takes the records of its own authors', () {
      final subDto = SubSubjectsResponse.fromBody(
        authorSubSubjectsAnswer(),
      ).subSubjects!.single;
      final items = ItemsResponse.fromBody(eraItemsAnswer()).itemLists!.single;

      final sub = subDto.toDomain(items: items.items)!;

      final era1 = sub.items[0];
      final era2 = sub.items[1];
      expect(era1.id, 'era-1');
      expect(era1.progressRecords.map((r) => r.id), ['rec-1', 'rec-2']);
      expect(era1.missingCount, 1, reason: 'rec-1 has one 0, rec-2 none');
      expect(era1.hasMissing, isTrue);
      expect(era2.progressRecords.map((r) => r.id), ['rec-3']);
      expect(era2.missingCount, 0, reason: 'no card list and not independent');
      expect(era1.descriptions, ['Dönem açıklaması']);
    });

    test('withItems keeps the rest', () {
      const sub = SubSubject(id: 'a', name: 'b', missingCount: 4);

      expect(sub.withItems(const []).missingCount, 4);
      expect(sub.withItems(const []).name, 'b');
    });
  });

  group('authors', () {
    final authors = lessonItemsOf(
      SubjectAuthorsResponse.fromBody(authorsAnswer()).authors,
    );

    test('reads an author with works and their types', () {
      final fuzuli = authors.first;

      expect(fuzuli.isAuthor, isTrue);
      expect(fuzuli.id, 'au-1');
      expect(fuzuli.authorCategoryId, 'era-1');
      expect(fuzuli.imageFile, '/authors/fuzuli.png');
      expect(fuzuli.text, '16. yüzyıl şairi.');
      expect(fuzuli.works.map((w) => w.title), [
        'Leyla ile Mecnun',
        'Su Kasidesi',
        'Bilinmeyen tür',
      ]);
      expect(fuzuli.works[0].typeName, 'Mesnevi');
      expect(fuzuli.works[1].typeName, 'Şiir');
      expect(fuzuli.works[2].typeName, isNull, reason: 'outside the table');
      expect(fuzuli.works[0].progress!.id, 'w-1');
      expect(fuzuli.works[0].progress!.status, 0);
      expect(fuzuli.works[2].progress, isNull);
    });

    test('counts each missing work once', () {
      expect(authors.first.missingCount, 1);
      expect(authors.first.hasMissing, isTrue);
      expect(authors.last.missingCount, 0);
      expect(authors.last.works, isEmpty);
    });
  });

  group('main subjects of Yazar & Eserler', () {
    test('keep the server counts', () {
      final subjects = mainSubjectsOf(
        YazarMainSubjectsResponse.fromBody({
          'success': true,
          'mainSubjects': [
            {'_id': 'm1', 'name': 'Divan', 'itemDataCount': '7', 'order': 1},
            {'_id': 'm2', 'name': 'Halk'},
            {'name': 'x'},
          ],
        }).subjects,
      );

      expect(subjects.map((s) => (s.name, s.missingCount)), [
        ('Divan', 7),
        ('Halk', null),
      ]);
    });
  });
}
