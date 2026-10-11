import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/features/lessons/application/literature_authors.dart';
import 'package:smap/features/lessons/application/topic_outline.dart';
import 'package:smap/features/lessons/data/lesson_content_repository.dart';

import '../../exams/data/data_harness.dart';
import 'literature_samples.dart';

void main() {
  group('LiteratureLoader', () {
    test(
      'reads the eras and their authors, in order (pano 7.4 kare 1)',
      () async {
        final backend = LiteratureBackend();
        final loader = LiteratureLoader(
          LessonContentRepository(networkOver(backend.adapter)),
        );

        final eras = (await loader.load()).rightOrNull!;
        final authors = LiteratureAuthors.of(eras);

        expect(authors.authors.map((a) => (a.name, a.eraName)), [
          ('Namık Kemal', 'Tanzimat'),
          ('Şinasi', 'Tanzimat'),
          ('Ziya Paşa', 'Tanzimat'),
          ('Tevfik Fikret', 'Servet-i Fünun'),
          ('Halit Ziya Uşaklıgil', 'Servet-i Fünun'),
          ('Mehmet Akif Ersoy', 'Millî Edebiyat Dönemi'),
        ]);
        expect(authors.authors.map((a) => a.initials), [
          'NK',
          'Ş',
          'ZP',
          'TF',
          'HZ',
          'MA',
        ]);
      },
    );

    test('asks for the authors of every era', () async {
      final backend = LiteratureBackend();
      final loader = LiteratureLoader(
        LessonContentRepository(networkOver(backend.adapter)),
      );

      await loader.load();

      expect(backend.authorCalls, ['era-tanzimat', 'era-servet', 'era-milli']);
    });

    test('runs a few era requests at a time, not all at once', () async {
      final backend = LiteratureBackend();
      final loader = LiteratureLoader(
        LessonContentRepository(networkOver(backend.adapter)),
        batch: 2,
      );

      await loader.load();

      expect(backend.maxParallel, 2);
    });

    test('one failing era fails the load: no list with a hole in it', () async {
      final backend = LiteratureBackend(failEra: 'era-servet');
      final loader = LiteratureLoader(
        LessonContentRepository(networkOver(backend.adapter)),
      );

      final result = await loader.load();

      expect(result.leftOrNull, isNotNull);
    });

    test('a failing first request is the failure', () async {
      final loader = LiteratureLoader(
        LessonContentRepository(networkOver(offlineAdapter())),
      );

      final result = await loader.load();

      expect(result.leftOrNull?.code, AppErrorCode.offline);
    });
  });

  group('LiteratureAuthors', () {
    late LiteratureAuthors authors;

    setUp(() async {
      final backend = LiteratureBackend();
      final loader = LiteratureLoader(
        LessonContentRepository(networkOver(backend.adapter)),
      );
      authors = LiteratureAuthors.of((await loader.load()).rightOrNull!);
    });

    test('groups the works by type, with the unknown types last', () {
      final kemal = authors.authors.first;
      expect(kemal.groups.map((g) => g.typeName).toList(), [
        'Roman',
        'Tiyatro',
        null,
      ]);
      expect(
        [
          for (final g in kemal.groups) [for (final w in g.works) w.title],
        ],
        [
          ['İntibah', 'Cezmi'],
          ['Vatan yahut Silistre', 'Gülnihal'],
          ['Bilinmeyen'],
        ],
      );
    });

    test('reads the biography paragraph by paragraph', () {
      expect(authors.authors.first.biography, hasLength(2));
    });

    test('counts the missing works and keeps their record ids', () {
      final kemal = authors.authors.first;
      expect(kemal.missingCount, 2);
      expect(kemal.missingProgressIds, ['w-3', 'w-4']);
      expect(kemal.groups.first.works.every((w) => !w.isMissing), isTrue);
      expect(
        kemal.groups.last.works.single.card,
        ItemCardState.unknown,
        reason: 'a work without a record has no state',
      );
    });

    test('an author without works has no groups and nothing to learn', () {
      final sinasi = authors.authors[1];
      expect(sinasi.hasWorks, isFalse);
      expect(sinasi.missingCount, 0);
    });

    test('keeps the photo path and draws the initials without one', () {
      expect(authors.authors.first.photo, '/authors/a/namikkemal.png');
      expect(authors.authors[1].photo, isNull);
    });

    test(
      'learning the missing works of one author changes only that author',
      () {
        final kemal = authors.authors.first;
        final next = authors.withLearned(
          kemal.key,
          kemal.missingProgressIds.toSet(),
        );

        expect(next.authorOf(kemal.key)!.missingCount, 0);
        expect(next.authorOf(kemal.key)!.groups.first, kemal.groups.first);
        expect(next.authors[1], authors.authors[1]);
        expect(kemal.missingCount, 2, reason: 'the old list is unchanged');
      },
    );

    test('a record id that is not missing is left alone', () {
      final kemal = authors.authors.first;
      final next = authors.withLearned(kemal.key, {'w-1'});
      expect(next.authorOf(kemal.key), kemal);
    });
  });

  group('AuthorInitials', () {
    test('takes the first letter of the first two words', () {
      expect(AuthorInitials.of('Namık Kemal'), 'NK');
      expect(AuthorInitials.of('Halit Ziya Uşaklıgil'), 'HZ');
      expect(AuthorInitials.of('Mehmet Akif Ersoy'), 'MA');
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
