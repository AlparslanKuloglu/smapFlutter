import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/lessons/application/lesson_category.dart';
import 'package:smap/features/lessons/application/topic_outline.dart';
import 'package:smap/features/lessons/presentation/lesson_detail/lesson_detail_viewmodel.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

import '../../application/lesson_samples.dart';
import '../lessons_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LessonsHarness harness;
  LessonDetailViewModel? viewModel;

  Future<LessonDetailViewModel> open(
    String lessonName, {
    LessonCat? cat,
    bool onlyMissing = false,
    LiteratureSection? section,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final model = LessonDetailViewModel(
      lessonId: generalLesson(lessonName).id,
      lessons: harness.lessons,
      content: harness.content,
      cards: harness.cards,
      preferences: harness.preferences,
      navigator: harness.navigator,
      toast: harness.toast,
      cat: cat,
      onlyMissing: onlyMissing,
      section: section,
      timeout: timeout,
    );
    viewModel = model;
    await model.init();
    await pumpEventQueue();
    return model;
  }

  setUp(() async {
    harness = await LessonsHarness.create();
  });

  tearDown(() async {
    viewModel?.dispose();
    viewModel = null;
    await harness.dispose();
  });

  group('Türkçe · TYT (pano 7.2 kare 1)', () {
    test('lists the twelve topics with the counts of TYT', () async {
      final model = await open('Türkçe', cat: LessonCat.tyt);

      final topics = model.topics;
      expect(topics.state, SectionState.ready);
      expect(topics.topics, hasLength(12));
      expect(
        topics.topics
            .where((t) => t.missing > 0)
            .map((t) => (t.number, t.missing)),
        [(8, 2), (9, 3), (12, 3)],
      );
      expect(topics.topics[7].name, 'Cümlenin Öğeleri');
    });

    test('the segment has the counters of the lesson, TYT selected', () async {
      final model = await open('Türkçe', cat: LessonCat.tyt);

      final bar = model.segmentBar;
      expect(bar.visible, isTrue);
      expect(bar.segments.map((s) => (s.label, s.missing)), [
        (null, 31),
        ('TYT', 28),
        ('AYT', 3),
      ]);
      expect(bar.selected, 1);
    });

    test(
      'the chip counts the whole lesson, the card button has no progress',
      () async {
        final model = await open('Türkçe', cat: LessonCat.tyt);

        final bar = model.filterBar;
        expect(bar.visible, isTrue);
        expect(bar.missingTotal, 31);
        expect(bar.onlyMissing, isFalse);
        expect(bar.cardsTotal, isNull);
      },
    );

    test('"Eksiklerim" keeps topics 8, 9 and 12 with their numbers', () async {
      final model = await open('Türkçe', cat: LessonCat.tyt);

      model.toggleOnlyMissing();

      expect(model.topics.topics.map((t) => t.number), [8, 9, 12]);
      expect(model.filterBar.onlyMissing, isTrue);
      model.closeFilter();
      expect(model.topics.topics, hasLength(12));
    });

    test('opens with the filter on when the link says so', () async {
      final model = await open('Türkçe', cat: LessonCat.tyt, onlyMissing: true);
      expect(model.topics.topics.map((t) => t.number), [8, 9, 12]);
    });

    test('without a category it opens on the device exam type', () async {
      harness.dispose();
      harness = await LessonsHarness.create(
        prefs: {DevicePreferences.lessonsExamTypeKey: 'ayt'},
      );
      final model = await open('Türkçe');
      expect(model.segmentBar.selected, 2);
    });

    test('"Tümü" counts every type', () async {
      final model = await open('Türkçe', cat: LessonCat.all);
      expect(model.segmentBar.selected, 9);
      expect(model.topics.isAllSegment, isTrue);
    });

    test(
      'a segment change changes the counts, not the topics or the request',
      () async {
        final model = await open('Türkçe', cat: LessonCat.tyt);
        final asked = harness.backend.count('/student/mainSubjects');

        await model.selectSegment(2);

        expect(model.segmentBar.selected, 2);
        expect(harness.backend.count('/student/mainSubjects'), asked);
        expect(model.topics.topics, hasLength(12));
        expect(model.topics.topics.every((t) => t.missing == 0), isTrue);
      },
    );
  });

  group('Tarih · tracks (pano 7.2 kare 3)', () {
    test('a link on SOS-2 opens SOS-2 and reads its lesson only', () async {
      final model = await open('Tarih', cat: LessonCat.sos2);

      final tarih = generalLesson('Tarih').ids;
      expect(model.segmentBar.segments.map((s) => s.label), [
        'TYT',
        'AYT',
        'SOS-2',
      ]);
      expect(model.segmentBar.selected, 4);
      expect(model.topics.topics.map((t) => t.number), [1, 2]);
      expect(
        harness.backend.asked.where(
          (a) => a.startsWith('/student/mainSubjects'),
        ),
        ['/student/mainSubjects?lessonId=${tarih.sos2}'],
      );
    });

    test(
      'the counters: TYT 60, AYT not counted, SOS-2 "eksik yok" (zero)',
      () async {
        final model = await open('Tarih', cat: LessonCat.sos2);
        expect(model.segmentBar.segments.map((s) => s.missing), [60, null, 0]);
      },
    );

    test(
      'the chip adds the tracks up and the button shows the deck progress',
      () async {
        final model = await open('Tarih', cat: LessonCat.tyt);

        expect(model.filterBar.missingTotal, 60);
        expect(
          (model.filterBar.cardsKnown, model.filterBar.cardsTotal),
          (41, 64),
        );
      },
    );

    test(
      'switching tracks reads the other lesson; coming back is instant',
      () async {
        final model = await open('Tarih', cat: LessonCat.sos2);

        await model.selectSegment(1);
        expect(model.topics.topics.map((t) => t.name), [
          'İslamiyet Öncesi',
          'Osmanlı',
        ]);
        final asked = harness.backend.count('/student/mainSubjects');

        await model.selectSegment(4);

        expect(model.topics.topics, hasLength(2));
        expect(harness.backend.count('/student/mainSubjects'), asked);
      },
    );

    test(
      'the filter with nothing missing leaves the empty card data',
      () async {
        final model = await open(
          'Tarih',
          cat: LessonCat.sos2,
          onlyMissing: true,
        );

        final topics = model.topics;
        expect(topics.state, SectionState.ready);
        expect(topics.topics, isEmpty);
        expect(topics.onlyMissing, isTrue);
        expect(topics.segmentLabel, 'SOS-2');
        model.closeFilter();
        expect(model.topics.topics, hasLength(2));
      },
    );

    test('"Kartlarım" opens the deck of the chosen track', () async {
      final model = await open('Tarih', cat: LessonCat.tyt);

      await model.openCards();

      expect(harness.navigator.calls, [
        'deck:${generalLesson('Tarih').ids.tyt}:Tarih',
      ]);
    });
  });

  group('opening a topic', () {
    test(
      'goes to Konu Detayı on the chosen category and reads the counts again',
      () async {
        final model = await open('Türkçe', cat: LessonCat.tyt);
        final asked = harness.backend.count('/student/mainSubjects');

        await model.openTopic(model.topics.topics[8]);

        expect(harness.navigator.calls, [
          'topic:${generalLesson('Türkçe').id}:t-9:tyt',
        ]);
        expect(harness.backend.count('/student/mainSubjects'), asked + 1);
      },
    );
  });

  group('failures', () {
    test('the topics failing show the error state; retry reloads', () async {
      harness.backend.subjectsFail = true;
      final model = await open('Türkçe', cat: LessonCat.tyt);
      expect(model.topics.state, SectionState.error);
      expect(model.filterBar.visible, isFalse);

      harness.backend.subjectsFail = false;
      await model.retryTopics();

      expect(model.topics.state, SectionState.ready);
    });

    test('an unknown lesson is an error', () async {
      final model = LessonDetailViewModel(
        lessonId: 'nope',
        lessons: harness.lessons,
        content: harness.content,
        cards: harness.cards,
        preferences: harness.preferences,
        navigator: harness.navigator,
        toast: harness.toast,
      );
      viewModel = model;
      await model.init();

      expect(model.topics.state, SectionState.error);
    });

    test('a lesson without topics is empty, not an error', () async {
      harness.backend.topics[generalLesson('Türkçe').ids.single!] = [];
      final model = await open('Türkçe', cat: LessonCat.tyt);
      expect(model.topics.state, SectionState.empty);
    });
  });

  group('Edebiyat (pano 7.4)', () {
    LiteratureBackendHooks hooks() => LiteratureBackendHooks(harness);

    test(
      'opens on the topics by default and does not read the authors',
      () async {
        final model = await open('Edebiyat', cat: LessonCat.ayt);

        expect(model.isLiterature, isTrue);
        expect(model.sectionData.section, LiteratureSection.topics);
        expect(model.showsAuthors, isFalse);
        expect(harness.backend.count('/student/yazarEserMainSubjects'), 0);
      },
    );

    test('a link to the authors, or the device choice, opens them', () async {
      hooks().install();
      final model = await open('Edebiyat', section: LiteratureSection.authors);

      expect(model.showsAuthors, isTrue);
      expect(model.authors.state, SectionState.ready);
      expect(model.authors.authors.authors.map((a) => a.name), [
        'Namık Kemal',
        'Şinasi',
      ]);
      expect(
        model.segmentBar.visible,
        isFalse,
        reason: 'no segment over authors',
      );
      expect(model.filterBar.visible, isFalse);
    });

    test(
      'the section choice is kept and loads the authors the first time',
      () async {
        hooks().install();
        final model = await open('Edebiyat', cat: LessonCat.ayt);

        await model.selectSection(LiteratureSection.authors);

        expect(model.authors.state, SectionState.ready);
        expect(
          harness.preferences.getString(
            DevicePreferences.lessonsLiteratureSectionKey,
          ),
          'authors',
        );
        final asked = harness.backend.count('/student/yazarEserMainSubjects');
        await model.selectSection(LiteratureSection.topics);
        await model.selectSection(LiteratureSection.authors);
        expect(
          harness.backend.count('/student/yazarEserMainSubjects'),
          asked,
          reason: 'the list is kept',
        );
      },
    );

    test('another lesson has no sections', () async {
      final model = await open('Türkçe', cat: LessonCat.tyt);
      expect(model.sectionData.section, isNull);
      await model.selectSection(LiteratureSection.authors);
      expect(model.showsAuthors, isFalse);
    });

    test(
      '"Öğrendim" marks the missing works learned and the list follows',
      () async {
        hooks().install();
        final model = await open(
          'Edebiyat',
          section: LiteratureSection.authors,
        );
        final kemal = model.authors.authors.authors.first;
        expect(kemal.missingCount, 2);

        await model.learnAuthor(kemal.key);

        expect(model.authors.authors.authors.first.missingCount, 0);
        expect(harness.backend.learned, unorderedEquals(['w-3', 'w-4']));
      },
    );

    test(
      'a work that was not sent goes back to missing, with a toast',
      () async {
        hooks().install();
        final model = await open(
          'Edebiyat',
          section: LiteratureSection.authors,
        );
        harness.backend.learnFail = true;
        final kemal = model.authors.authors.authors.first;

        await model.learnAuthor(kemal.key);

        expect(model.authors.authors.authors.first.missingCount, 2);
        expect(
          toastText(harness.toast),
          'Gönderilemedi. Bağlantını kontrol edip tekrar dene.',
        );
      },
    );

    test('the authors failing show the error state; retry reloads', () async {
      hooks().install();
      harness.backend.authorsFail = true;
      final model = await open('Edebiyat', section: LiteratureSection.authors);
      expect(model.authors.state, SectionState.error);

      harness.backend.authorsFail = false;
      await model.retryAuthors();

      expect(model.authors.state, SectionState.ready);
    });

    test('an author learned with nothing missing sends nothing', () async {
      hooks().install();
      final model = await open('Edebiyat', section: LiteratureSection.authors);
      final sinasi = model.authors.authors.authors[1];

      await model.learnAuthor(sinasi.key);

      expect(harness.backend.learned, isEmpty);
    });

    test('items are not confused: the card state of a missing work', () async {
      hooks().install();
      final model = await open('Edebiyat', section: LiteratureSection.authors);
      final kemal = model.authors.authors.authors.first;
      expect(
        kemal.groups
            .expand((g) => g.works)
            .where((w) => w.card == ItemCardState.missing),
        hasLength(2),
      );
    });
  });
}
