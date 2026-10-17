import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/lessons/application/literature_service.dart';
import 'package:smap/features/lessons/application/topic_outline.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

import '../presentation/lessons_harness.dart';

void main() {
  late LessonsHarness harness;
  late LiteratureService service;

  Future<void> openTanzimat() async {
    await service.loadEras();
    await service.loadSubs('m-tanzimat');
    await service.loadAuthors('m-tanzimat', 'ss-1');
  }

  bool learnIntibah() => service.learn(
    eraId: 'm-tanzimat',
    subId: 'ss-1',
    authorKey: 'au-nk',
    progressId: 'w-1',
  );

  int? eraMissing(String id) => service.eraOf(id)?.missing;
  int? subMissing(String eraId, String subId) => [
    for (final s in service.subsOf(eraId).data!)
      if (s.id == subId) s.missing,
  ].single;
  int kemalMissing() => service.authorOf('ss-1', 'au-nk')!.missingCount;

  setUp(() async {
    harness = await LessonsHarness.create();
    service = harness.literature;
  });

  tearDown(() => harness.dispose());

  group('reading the levels (pano 14.5, 14.7)', () {
    test(
      'the era list: the total of the counts is the segment counter',
      () async {
        expect(service.state.eras.state, SectionState.loading);

        await service.loadEras();

        expect(service.state.eras.state, SectionState.ready);
        expect(service.state.eras.data!.map((e) => e.name), [
          'Tanzimat Dönemi',
          'Servet-i Fünun Dönemi',
          'Fecr-i Âti',
          'Millî Edebiyat Dönemi',
          'Cumhuriyet Dönemi',
        ]);
        expect(service.totalMissing, 3);
      },
    );

    test('calls that arrive while a read runs share it', () async {
      await Future.wait([service.loadEras(), service.loadEras()]);

      expect(
        harness.backend.literature.count('/student/yazarEserMainSubjects'),
        1,
      );
    });

    test(
      'a failed era list is the error; "Tekrar Dene" shows the skeleton first',
      () async {
        harness.backend.literature.failEras = true;
        await service.loadEras();
        expect(service.state.eras.state, SectionState.error);
        expect(service.totalMissing, isNull);

        harness.backend.literature.failEras = false;
        final retry = service.loadEras(force: true);
        expect(service.state.eras.state, SectionState.loading);
        await retry;

        expect(service.state.eras.state, SectionState.ready);
      },
    );

    test(
      'a read again that fails keeps what is shown (no skeleton, no error)',
      () async {
        await service.loadEras();
        harness.backend.literature.failEras = true;

        final again = service.loadEras();
        expect(service.state.eras.state, SectionState.ready);
        await again;

        expect(service.state.eras.state, SectionState.ready);
        expect(service.totalMissing, 3);
      },
    );

    test('the sub-subjects load per era and fail per era', () async {
      harness.backend.literature.failSubsOf.add('m-servet');
      await service.loadEras();

      await service.loadSubs('m-tanzimat');
      await service.loadSubs('m-servet');

      expect(service.subsOf('m-tanzimat').data!.map((s) => s.name), [
        'Birinci Dönem Sanatçıları',
        'İkinci Dönem Sanatçıları',
      ]);
      expect(service.subsOf('m-servet').state, SectionState.error);
    });

    test(
      'the authors load when asked and fail inside their own accordion',
      () async {
        harness.backend.literature.failGroups.add('grp-2');
        await service.loadEras();
        await service.loadSubs('m-tanzimat');

        await service.loadAuthors('m-tanzimat', 'ss-1');
        await service.loadAuthors('m-tanzimat', 'ss-2');

        expect(service.authorsOf('ss-1').state, SectionState.ready);
        expect(service.authorsOf('ss-1').data!.map((a) => a.name), [
          'Namık Kemal',
          'Şinasi',
          'Ziya Paşa',
        ]);
        expect(service.authorsOf('ss-2').state, SectionState.error);

        harness.backend.literature.failGroups.clear();
        final retry = service.loadAuthors('m-tanzimat', 'ss-2', force: true);
        expect(service.authorsOf('ss-2').state, SectionState.loading);
        await retry;
        expect(service.authorsOf('ss-2').state, SectionState.ready);
        expect(service.authorsOf('ss-1').state, SectionState.ready);
      },
    );

    test('authors are not read before their sub-subject is known', () async {
      await service.loadAuthors('m-tanzimat', 'ss-1');

      expect(harness.backend.literature.count('/student/getSubjectAuthors'), 0);
    });

    test('an accordion without authors is empty, not an error', () async {
      await service.loadEras();
      await service.loadSubs('m-fecr');

      expect(service.subsOf('m-fecr').data, isEmpty);
    });
  });

  group('"Öğrendim" (pano 14.6 kare 2)', () {
    setUp(openTanzimat);

    test(
      'every count drops in the same change: author, accordion, era, segment',
      () async {
        expect(kemalMissing(), 2);
        expect(subMissing('m-tanzimat', 'ss-1'), 2);
        expect(eraMissing('m-tanzimat'), 2);
        expect(service.totalMissing, 3);
        await pumpEventQueue();
        var notified = 0;
        service.addListener(() => notified++);

        expect(learnIntibah(), isTrue);
        await pumpEventQueue();

        expect(kemalMissing(), 1);
        expect(subMissing('m-tanzimat', 'ss-1'), 1);
        expect(eraMissing('m-tanzimat'), 1);
        expect(service.totalMissing, 2);
        expect(
          service.authorOf('ss-1', 'au-nk')!.workOf('w-1')!.card,
          ItemCardState.learned,
        );
        expect(notified, 1, reason: 'one state change, so one redraw');
      },
    );

    test('the toast says "İntibah bildiklerine eklendi." with "Geri Al"', () {
      learnIntibah();

      expect(toastText(harness.toast), 'İntibah bildiklerine eklendi.');
      expect(toastHasUndo(harness.toast), isTrue);
    });

    test(
      'the request waits 6 s: nothing is sent before, one request after',
      () async {
        learnIntibah();

        harness.timers.advance(const Duration(seconds: 5, milliseconds: 900));
        await pumpEventQueue();
        expect(harness.backend.literature.learned, isEmpty);

        harness.timers.advance(const Duration(milliseconds: 200));
        await pumpEventQueue();
        expect(harness.backend.literature.learned, ['w-1']);
        expect(kemalMissing(), 1, reason: 'it stays learned');
      },
    );

    test('the lessons are read again after the request was saved', () async {
      final before = harness.backend.count('/student/getLessonsTotalMissing');
      learnIntibah();

      harness.timers.advance(const Duration(seconds: 6));
      await pumpEventQueue();

      expect(
        harness.backend.count('/student/getLessonsTotalMissing'),
        before + 1,
      );
    });

    test(
      '"Geri Al" puts every count back and the request never goes out',
      () async {
        learnIntibah();

        expect(pressToastUndo(harness.toast), isTrue);

        expect(kemalMissing(), 2);
        expect(subMissing('m-tanzimat', 'ss-1'), 2);
        expect(eraMissing('m-tanzimat'), 2);
        expect(service.totalMissing, 3);
        expect(
          service.authorOf('ss-1', 'au-nk')!.workOf('w-1')!.card,
          ItemCardState.missing,
        );
        harness.timers.advance(const Duration(seconds: 10));
        await pumpEventQueue();
        expect(harness.backend.literature.learned, isEmpty);
      },
    );

    test(
      '"Geri Al" after the request went out finds nothing to undo',
      () async {
        learnIntibah();
        harness.timers.advance(const Duration(seconds: 6));
        await pumpEventQueue();

        service.undo('w-1');

        expect(kemalMissing(), 1);
      },
    );

    test(
      'a failed request puts the work back and says nothing was saved',
      () async {
        harness.backend.literature.failLearn = true;
        learnIntibah();

        harness.timers.advance(const Duration(seconds: 6));
        await pumpEventQueue();

        expect(kemalMissing(), 2);
        expect(subMissing('m-tanzimat', 'ss-1'), 2);
        expect(eraMissing('m-tanzimat'), 2);
        expect(service.totalMissing, 3);
        expect(
          toastText(harness.toast),
          'Kaydedilemedi. Bağlantını kontrol edip tekrar dene.',
        );
        expect(toastHasUndo(harness.toast), isFalse);
      },
    );

    test('offline "Öğrendim" does nothing (the button is off)', () {
      harness.online.value = false;

      expect(learnIntibah(), isFalse);

      expect(kemalMissing(), 2);
      expect(toastText(harness.toast), isNull);
    });

    test(
      'a known work, a work with no status and an unknown work cannot be learned',
      () {
        for (final id in ['w-2', 'w-9']) {
          expect(
            service.learn(
              eraId: 'm-tanzimat',
              subId: 'ss-1',
              authorKey: id == 'w-2' ? 'au-nk' : 'au-s',
              progressId: id,
            ),
            isFalse,
          );
        }
        expect(
          service.learn(
            eraId: 'm-tanzimat',
            subId: 'ss-1',
            authorKey: 'au-nk',
            progressId: 'nope',
          ),
          isFalse,
        );
        expect(service.totalMissing, 3);
      },
    );

    test('learning the same work twice counts it once', () {
      expect(learnIntibah(), isTrue);
      expect(learnIntibah(), isFalse);

      expect(eraMissing('m-tanzimat'), 1);
    });

    test(
      'two works each get their own window; the toast follows the last',
      () async {
        learnIntibah();
        service.learn(
          eraId: 'm-tanzimat',
          subId: 'ss-1',
          authorKey: 'au-nk',
          progressId: 'w-3',
        );

        expect(eraMissing('m-tanzimat'), 0);
        expect(
          toastText(harness.toast),
          'Vatan yahut Silistre bildiklerine eklendi.',
        );

        expect(pressToastUndo(harness.toast), isTrue);
        expect(
          eraMissing('m-tanzimat'),
          1,
          reason: 'only the last one is undone',
        );
        harness.timers.advance(const Duration(seconds: 6));
        await pumpEventQueue();
        expect(harness.backend.literature.learned, ['w-1']);
      },
    );

    test('a count that is zero is not pushed below zero', () {
      final eras = service.state.eras.data!;
      expect(eras.every((e) => (e.missing ?? 0) >= 0), isTrue);
      learnIntibah();
      service.learn(
        eraId: 'm-tanzimat',
        subId: 'ss-1',
        authorKey: 'au-nk',
        progressId: 'w-3',
      );
      expect(eraMissing('m-tanzimat'), 0);
      expect(subMissing('m-tanzimat', 'ss-1'), 0);
    });

    test('the other eras and accordions are untouched', () async {
      learnIntibah();

      expect(eraMissing('m-servet'), 1);
      expect(subMissing('m-tanzimat', 'ss-2'), isNull);
    });

    test('a waiting "Öğrendim" survives the lists being read again', () async {
      learnIntibah();

      await service.loadEras(force: true);
      await service.loadSubs('m-tanzimat', force: true);
      await service.loadAuthors('m-tanzimat', 'ss-1', force: true);

      expect(
        eraMissing('m-tanzimat'),
        1,
        reason: 'the server has not heard yet',
      );
      expect(subMissing('m-tanzimat', 'ss-1'), 1);
      expect(kemalMissing(), 1);
      expect(service.totalMissing, 2);
    });

    test('flush sends what waits at once', () async {
      learnIntibah();

      await service.flush();

      expect(harness.backend.literature.learned, ['w-1']);
    });
  });
}
