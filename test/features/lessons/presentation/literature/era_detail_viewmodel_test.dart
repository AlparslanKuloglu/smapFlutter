import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/lessons/presentation/literature/era_detail/era_detail_viewmodel.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

import '../lessons_harness.dart';

void main() {
  late LessonsHarness harness;

  setUp(() async {
    harness = await LessonsHarness.create();
  });

  tearDown(() => harness.dispose());

  Future<EraDetailViewModel> open([String era = 'm-tanzimat']) async {
    final model = EraDetailViewModel(eraId: era, service: harness.literature);
    addTearDown(model.dispose);
    await model.init();
    await pumpEventQueue();
    return model;
  }

  group('the era detail (pano 14.5 kare 2)', () {
    test('the title is the era and "2 eksik eser"', () async {
      final model = await open();

      expect(model.title, 'Tanzimat Dönemi');
      expect(model.header.name, 'Tanzimat Dönemi');
      expect(model.header.missing, 2);
    });

    test(
      'while the era list is not here the title is a skeleton, then it shows',
      () async {
        final model = EraDetailViewModel(
          eraId: 'm-tanzimat',
          service: harness.literature,
        );
        addTearDown(model.dispose);
        expect(model.header.name, isNull);
        expect(model.body.state, SectionState.loading);

        await model.init();

        expect(model.header.name, 'Tanzimat Dönemi');
        expect(model.body.state, SectionState.ready);
      },
    );

    test(
      'the accordions are the sub-subjects in the server order, with their tags',
      () async {
        final model = await open();

        expect(model.body.subIds, ['ss-1', 'ss-2']);
        expect(model.subCard('ss-1')!.name, 'Birinci Dönem Sanatçıları');
        expect(model.subCard('ss-1')!.missing, 2);
        expect(model.subCard('ss-2')!.missing, isNull);
      },
    );

    test(
      'the first accordion with a missing work opens; its authors load',
      () async {
        final model = await open();

        expect(model.subCard('ss-1')!.open, isTrue);
        expect(model.subCard('ss-2')!.open, isFalse);
        expect(model.subAuthors('ss-1').state, SectionState.ready);
        expect(model.subAuthors('ss-1').rows.map((r) => r.name), [
          'Namık Kemal',
          'Şinasi',
          'Ziya Paşa',
        ]);
        expect(
          harness.backend.literature.asked.where(
            (a) => a.startsWith('/student/getSubjectAuthors'),
          ),
          ['/student/getSubjectAuthors?itemId=grp-1'],
          reason: 'a closed accordion loads nothing',
        );
      },
    );

    test(
      'an author row has the photo, the count "8 eser" and "2 eksik"',
      () async {
        final model = await open();

        final rows = model.subAuthors('ss-1').rows;
        expect(rows.map((r) => (r.name, r.workCount, r.missing)), [
          ('Namık Kemal', 8, 2),
          ('Şinasi', 3, 0),
          ('Ziya Paşa', 6, 0),
        ]);
        expect(rows.first.photo, '/authors/a/namikkemal.png');
        expect(rows[1].photo, isNull, reason: 'the initials are drawn');
      },
    );

    test('the first accordion at the top asks for no scrolling', () async {
      final model = await open();

      expect(model.focusRequest.value, isNull);
    });

    test(
      'a later accordion with a missing work opens and the page scrolls to it',
      () async {
        harness.backend.literature.missingInSecondSub = true;

        final model = await open();

        expect(model.subCard('ss-1')!.open, isFalse);
        expect(model.subCard('ss-2')!.open, isTrue);
        expect(model.focusRequest.value!.subId, 'ss-2');
        expect(model.subAuthors('ss-2').state, SectionState.ready);
      },
    );

    test(
      'with nothing missing the first accordion opens and nothing scrolls',
      () async {
        harness.backend.literature.noSubCounts = true;

        final model = await open();

        expect(model.subCard('ss-1')!.open, isTrue);
        expect(model.subCard('ss-2')!.open, isFalse);
        expect(model.focusRequest.value, isNull);
      },
    );

    test(
      'opening an accordion reads its authors once; closing keeps them',
      () async {
        final model = await open();

        model.setOpen('ss-2', true);
        expect(model.subCard('ss-2')!.open, isTrue);
        expect(model.subAuthors('ss-2').state, SectionState.loading);
        await pumpEventQueue();
        expect(model.subAuthors('ss-2').state, SectionState.ready);
        expect(model.subAuthors('ss-2').rows, hasLength(3));

        model.setOpen('ss-2', false);
        expect(model.subCard('ss-2')!.open, isFalse);
        model.setOpen('ss-2', true);
        await pumpEventQueue();
        expect(model.subAuthors('ss-2').state, SectionState.ready);
      },
    );

    test(
      'three skeleton rows show while the authors load (pano 14.5 kare 3)',
      () async {
        harness.backend.literature.authorsGate = Completer<void>();
        final gate = harness.backend.literature.authorsGate!;
        final model = EraDetailViewModel(
          eraId: 'm-tanzimat',
          service: harness.literature,
        );
        addTearDown(model.dispose);

        final started = model.init();
        await pumpEventQueue();

        expect(model.subCard('ss-1')!.open, isTrue);
        expect(model.subAuthors('ss-1').state, SectionState.loading);

        gate.complete();
        await started;
        await pumpEventQueue();
        expect(model.subAuthors('ss-1').state, SectionState.ready);
      },
    );

    test(
      'a failing accordion shows its own error; the others work (pano 14.7 kare 2)',
      () async {
        harness.backend.literature.failGroups.add('grp-2');
        final model = await open();

        model.setOpen('ss-2', true);
        await pumpEventQueue();

        expect(model.subAuthors('ss-2').state, SectionState.error);
        expect(model.subAuthors('ss-1').state, SectionState.ready);
        expect(model.body.state, SectionState.ready, reason: 'not the screen');
      },
    );

    test(
      '"Tekrar Dene" of an accordion reads only that accordion again',
      () async {
        harness.backend.literature.failGroups.add('grp-2');
        final model = await open();
        model.setOpen('ss-2', true);
        await pumpEventQueue();
        final before = harness.backend.literature.count(
          '/student/getSubjectAuthors',
        );

        harness.backend.literature.failGroups.clear();
        final retry = model.retryAuthors('ss-2');
        await pumpEventQueue();
        await retry;
        await pumpEventQueue();

        expect(model.subAuthors('ss-2').state, SectionState.ready);
        expect(
          harness.backend.literature.count('/student/getSubjectAuthors'),
          before + 1,
        );
      },
    );

    test('a group of authors without works draws rows with no count', () async {
      final model = await open();

      model.setOpen('ss-2', true);
      await pumpEventQueue();

      expect(model.subAuthors('ss-2').rows.map((r) => r.name), [
        'Recaizade Mahmut Ekrem',
        'Abdülhak Hamit Tarhan',
        'Sami Paşazade Sezai',
      ]);
      expect(
        model.subAuthors('ss-2').rows.every((r) => r.workCount == 0),
        isTrue,
      );
    });

    test(
      'a failed sub-subject read is the screen error; "Tekrar Dene" recovers',
      () async {
        harness.backend.literature.failSubsOf.add('m-tanzimat');
        final model = await open();

        expect(model.body.state, SectionState.error);

        harness.backend.literature.failSubsOf.clear();
        await model.retry();
        await pumpEventQueue();

        expect(model.body.state, SectionState.ready);
        expect(
          model.subCard('ss-1')!.open,
          isTrue,
          reason: 'opens after the retry',
        );
      },
    );

    test(
      'a failed era list is the screen error (the era cannot be titled)',
      () async {
        harness.backend.literature.failEras = true;
        final model = await open();

        expect(model.body.state, SectionState.error);
        expect(model.header.name, isNull);
      },
    );

    test('an era the list does not know is the screen error', () async {
      final model = await open('m-yok');

      expect(model.body.state, SectionState.error);
    });

    test('an era without sub-subjects shows nothing under the title', () async {
      final model = await open('m-fecr');

      expect(model.body.state, SectionState.ready);
      expect(model.body.subIds, isEmpty);
    });
  });

  group('"Öğrendim" behind the sheet (pano 14.6 kare 2)', () {
    test(
      'the tags of the era, the accordion and the author row drop together',
      () async {
        final model = await open();

        harness.literature.learn(
          eraId: 'm-tanzimat',
          subId: 'ss-1',
          authorKey: 'au-nk',
          progressId: 'w-1',
        );
        await pumpEventQueue();

        expect(model.header.missing, 1);
        expect(model.subCard('ss-1')!.missing, 1);
        expect(model.subAuthors('ss-1').rows.first.missing, 1);
        expect(model.subAuthors('ss-1').rows.first.workCount, 8);
      },
    );

    test('"Geri Al" brings them back', () async {
      final model = await open();
      harness.literature.learn(
        eraId: 'm-tanzimat',
        subId: 'ss-1',
        authorKey: 'au-nk',
        progressId: 'w-1',
      );

      pressToastUndo(harness.toast);
      await pumpEventQueue();

      expect(model.header.missing, 2);
      expect(model.subCard('ss-1')!.missing, 2);
      expect(model.subAuthors('ss-1').rows.first.missing, 2);
    });
  });
}
