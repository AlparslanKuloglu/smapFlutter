import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/lessons/application/topic_outline.dart';
import 'package:smap/features/lessons/presentation/literature/sheets/author_sheet_viewmodel.dart';

import '../lessons_harness.dart';

void main() {
  late LessonsHarness harness;

  setUp(() async {
    harness = await LessonsHarness.create();
    await harness.literature.loadEras();
    await harness.literature.loadSubs('m-tanzimat');
    await harness.literature.loadAuthors('m-tanzimat', 'ss-1');
  });

  tearDown(() => harness.dispose());

  AuthorSheetViewModel open([String key = 'au-nk']) {
    final model = AuthorSheetViewModel(
      service: harness.literature,
      eraId: 'm-tanzimat',
      subId: 'ss-1',
      authorKey: key,
    );
    addTearDown(model.dispose);
    return model;
  }

  group('the author sheet (pano 14.6, 14.7)', () {
    test(
      'shows the author under the era: "Namık Kemal", "Tanzimat Dönemi"',
      () {
        final model = open();

        expect(model.author!.name, 'Namık Kemal');
        expect(model.eraName, 'Tanzimat Dönemi');
        expect(model.author!.workCount, 8);
        expect(model.author!.missingCount, 2);
      },
    );

    test('an author the list no longer holds shows nothing', () {
      expect(open('au-yok').author, isNull);
    });

    test(
      '"Öğrendim": the work turns known and the counter reads "1 eksik"',
      () async {
        final model = open();
        var redraws = 0;
        model.addListener(() => redraws++);

        model.learn('w-1');
        await pumpEventQueue();

        expect(model.author!.workOf('w-1')!.card, ItemCardState.learned);
        expect(model.author!.missingCount, 1);
        expect(model.author!.workCount, 8);
        expect(redraws, greaterThan(0));
        expect(toastText(harness.toast), 'İntibah bildiklerine eklendi.');
      },
    );

    test('the sheet follows "Geri Al" from the toast', () async {
      final model = open();
      model.learn('w-1');

      pressToastUndo(harness.toast);
      await pumpEventQueue();

      expect(model.author!.workOf('w-1')!.card, ItemCardState.missing);
      expect(model.author!.missingCount, 2);
    });

    test(
      'the request goes out after 6 s even if the sheet is closed',
      () async {
        final model = AuthorSheetViewModel(
          service: harness.literature,
          eraId: 'm-tanzimat',
          subId: 'ss-1',
          authorKey: 'au-nk',
        );
        model.learn('w-1');
        model.dispose();

        harness.timers.advance(const Duration(seconds: 6));
        await pumpEventQueue();

        expect(harness.backend.literature.learned, ['w-1']);
      },
    );

    test(
      'offline: "Öğrendim" is off and the note sits under the first missing work',
      () async {
        harness.online.value = false;
        final model = open();

        expect(model.isOnline, isFalse);
        expect(model.offlineNoteFor, 'w-1');

        model.learn('w-1');
        expect(model.author!.missingCount, 2, reason: 'nothing changed');
      },
    );

    test('online there is no offline note', () {
      expect(open().offlineNoteFor, isNull);
    });

    test('the sheet follows the connection coming back', () async {
      harness.online.value = false;
      final model = open();
      var redraws = 0;
      model.addListener(() => redraws++);

      harness.online.value = true;

      expect(model.isOnline, isTrue);
      expect(redraws, 1);
      expect(model.offlineNoteFor, isNull);
    });

    test(
      'a work that failed to save is missing again and the toast says so',
      () async {
        harness.backend.literature.failLearn = true;
        final model = open();
        model.learn('w-1');

        harness.timers.advance(const Duration(seconds: 6));
        await pumpEventQueue();

        expect(model.author!.workOf('w-1')!.card, ItemCardState.missing);
        expect(
          toastText(harness.toast),
          'Kaydedilemedi. Bağlantını kontrol edip tekrar dene.',
        );
      },
    );

    test(
      'an author whose works have no status offers nothing to learn (pano 14.6 kare 3)',
      () {
        final model = open('au-s');

        expect(model.author!.missingCount, 0);
        expect(model.author!.firstMissingId, isNull);
        expect(model.author!.workCount, 3);
        expect(model.offlineNoteFor, isNull);
      },
    );

    test(
      'an author with no works has an empty list: "Bu yazarın eser listesi henüz yok."',
      () async {
        await harness.literature.loadAuthors('m-tanzimat', 'ss-2');
        final model = AuthorSheetViewModel(
          service: harness.literature,
          eraId: 'm-tanzimat',
          subId: 'ss-2',
          authorKey: 'au-Sami Paşazade Sezai',
        );
        addTearDown(model.dispose);

        expect(model.author!.hasWorks, isFalse);
      },
    );
  });
}
