import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/features/lessons/application/literature_authors.dart';
import 'package:smap/features/lessons/application/topic_outline.dart';
import 'package:smap/features/lessons/data/dtos/lesson_item_dto.dart';
import 'package:smap/features/lessons/data/mappers/lesson_mappers.dart';

import 'literature_samples.dart';

AuthorView viewOf(Map<String, Object?> json) =>
    AuthorViews.of(LessonItemDto.fromJson(json).toDomain()!);

void main() {
  group('AuthorView (pano 14.5 kare 2, 14.6)', () {
    late AuthorView kemal;
    late AuthorView shinasi;

    setUp(() {
      kemal = viewOf(namikKemal());
      shinasi = viewOf(sinasi());
    });

    test('counts the works and the missing ones: "8 eser", "2 eksik"', () {
      expect(kemal.workCount, 8);
      expect(kemal.missingCount, 2);
    });

    test('groups the works by type in the order they come, "Roman · 2"', () {
      expect(kemal.groups.map((g) => (g.typeName, g.works.length)), [
        ('Roman', 2),
        ('Tiyatro', 6),
      ]);
      expect(kemal.groups.first.works.map((w) => w.title), [
        'İntibah',
        'Cezmi',
      ]);
    });

    test('a type outside the table of 33 comes last, with no name', () {
      expect(shinasi.groups.map((g) => g.typeName), ['Tiyatro', 'Şiir', null]);
    });

    test('the type names are the legacy table of 33 types', () {
      expect(AuthorWorkTypes.names, hasLength(33));
    });

    test('a work with no status is not drawn as missing or known (T12.14)', () {
      final unknown = shinasi.groups[1].works.single;
      expect(unknown.card, ItemCardState.unknown);
      expect(unknown.isMissing, isFalse);
      expect(unknown.canLearn, isFalse);
      expect(shinasi.missingCount, 0, reason: 'the counter says only "3 eser"');
      expect(shinasi.workCount, 3);
    });

    test('reads status 0 as missing and 1 as known', () {
      expect(kemal.workOf('w-1')!.card, ItemCardState.missing);
      expect(kemal.workOf('w-2')!.card, ItemCardState.learned);
      expect(kemal.workOf('w-1')!.canLearn, isTrue);
      expect(kemal.workOf('w-2')!.canLearn, isFalse);
    });

    test('knows the type of a work and the first missing one', () {
      expect(kemal.typeOf('w-3'), 'Tiyatro');
      expect(kemal.firstMissingId, 'w-1');
      expect(shinasi.firstMissingId, isNull);
    });

    test('learning one work lowers the count and changes only that work', () {
      final next = kemal.withWorkCard('w-1', ItemCardState.learned);

      expect(next.missingCount, 1);
      expect(next.workCount, 8);
      expect(next.workOf('w-1')!.card, ItemCardState.learned);
      expect(next.workOf('w-3'), kemal.workOf('w-3'));
      expect(kemal.missingCount, 2, reason: 'the old author is unchanged');
    });

    test('putting a work back to missing undoes it', () {
      final learned = kemal.withWorkCard('w-1', ItemCardState.learned);
      expect(learned.withWorkCard('w-1', ItemCardState.missing), kemal);
    });

    test('a progress id that is not there changes nothing', () {
      expect(kemal.withWorkCard('nope', ItemCardState.learned), same(kemal));
    });

    test('reads the biography paragraph by paragraph', () {
      expect(kemal.biography, hasLength(2));
    });

    test('keeps the photo path; the placeholder photo draws the initials', () {
      expect(kemal.photo, '/authors/a/namikkemal.png');
      expect(shinasi.photo, isNull);
    });

    test('an author without works has no groups', () {
      final empty = viewOf(authorWithoutWorks('Sami Paşazade Sezai', 'g'));
      expect(empty.hasWorks, isFalse);
      expect(empty.workCount, 0);
      expect(empty.missingCount, 0);
    });
  });

  group('AuthorInitials', () {
    test('takes the first letter of the first two words', () {
      expect(AuthorInitials.of('Namık Kemal'), 'NK');
      expect(AuthorInitials.of('Halit Ziya Uşaklıgil'), 'HZ');
      expect(AuthorInitials.of('Ziya Paşa'), 'ZP');
    });

    test('one word gives one letter, with the Turkish rule', () {
      expect(AuthorInitials.of('Şinasi'), 'Ş');
      expect(AuthorInitials.of('ilhan Berk'), 'İB');
    });

    test('a blank name gives nothing', () {
      expect(AuthorInitials.of('  '), '');
    });
  });
}
