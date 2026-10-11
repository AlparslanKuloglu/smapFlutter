import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/lessons/application/lesson_category.dart';
import 'package:smap/features/lessons/application/topic_outline.dart';
import 'package:smap/features/lessons/presentation/lessons_navigator.dart';
import 'package:smap/features/lessons/presentation/topic_detail/topic_detail_viewmodel.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

import '../../application/lesson_samples.dart';
import '../lessons_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LessonsHarness harness;
  TopicDetailViewModel? viewModel;

  Future<TopicDetailViewModel> open({
    String lesson = 'Türkçe',
    String topicId = 't-1',
    String? focus = TopicFocus.firstMissing,
    LessonCat? cat = LessonCat.tyt,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final model = TopicDetailViewModel(
      lessonId: generalLesson(lesson).id,
      topicId: topicId,
      lessons: harness.lessons,
      content: harness.content,
      cards: harness.cards,
      preferences: harness.preferences,
      toast: harness.toast,
      focus: focus,
      cat: cat,
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

  test('starts on the skeleton', () {
    final model = TopicDetailViewModel(
      lessonId: generalLesson('Türkçe').id,
      topicId: 't-1',
      lessons: harness.lessons,
      content: harness.content,
      cards: harness.cards,
      preferences: harness.preferences,
      toast: harness.toast,
    );
    viewModel = model;
    expect(model.body.state, SectionState.loading);
    expect(model.header, isNull);
  });

  group('loading (pano 7.3 kare 1)', () {
    test('writes the line "Türkçe · TYT · 1. konu" and the counts', () async {
      final model = await open();

      final header = model.header!;
      expect(header.topicName, 'Sözcükte Anlam');
      expect(header.lessonName, 'Türkçe');
      expect(header.trackLabel, 'TYT');
      expect(header.number, 1);
      expect(header.subTopicCount, 1);
      expect(header.itemCount, 3);
      expect(model.title, 'Sözcükte Anlam');
    });

    test('a topic opened on "Tümü" has no track in its line', () async {
      final model = await open(cat: LessonCat.all);
      expect(model.header!.trackLabel, isNull);
    });

    test('numbers a later topic by its place in the lesson', () async {
      final model = await open(topicId: 't-9');
      expect(model.header!.number, 9);
      expect(model.header!.topicName, 'Fiilde Çatı');
    });

    test(
      'opens the sub-topic of the first missing item and its item',
      () async {
        final model = await open();

        expect(model.body.state, SectionState.ready);
        expect(model.body.subTopicIds, ['ss-1']);
        expect(model.opensInitially('ss-1'), isTrue);
        expect(model.initialOpenItem, 'ss-1:0');
        expect(
          model.focusRequest.value,
          const FocusTarget(subTopicId: 'ss-1', itemKey: 'ss-1:0'),
        );
      },
    );

    test(
      'without the focus the first sub-topic opens and nothing scrolls',
      () async {
        final model = await open(focus: null);

        expect(model.opensInitially('ss-1'), isTrue);
        expect(model.initialOpenItem, isNull);
        expect(model.focusRequest.value, isNull);
      },
    );

    test('reads the content under the category of the link', () async {
      await open(cat: LessonCat.ayt);

      expect(
        harness.backend.asked.where((a) => a.startsWith('/student/getItems')),
        ['/student/getItems?type=2'],
      );
    });

    test('the sub-topic and its items as the screen draws them', () async {
      final model = await open();

      final sub = model.subTopic('ss-1')!;
      expect(sub.name, 'Anlamı Yönünden Sözcükler');
      expect(sub.missingCount, 1);
      expect(sub.items.map((i) => (i.number, i.name, i.card)), [
        (1, 'Temel Anlam', ItemCardState.missing),
        (2, 'Yan Anlam', ItemCardState.learned),
        (3, 'Mecaz Anlam', ItemCardState.unknown),
      ]);
      expect(
        sub.items.first.text.examples.single.text,
        startsWith('Bazı insanlar'),
      );
      expect(model.subTopic('nope'), isNull);
    });
  });

  group('failures', () {
    test('a failing request shows the error state; retry reloads', () async {
      harness.backend.contentFail = true;
      final model = await open();
      expect(model.body.state, SectionState.error);
      expect(model.header, isNull);

      harness.backend.contentFail = false;
      await model.retry();

      expect(model.body.state, SectionState.ready);
    });

    test('a topic the lesson does not list is an error', () async {
      final model = await open(topicId: 'nope');
      expect(model.body.state, SectionState.error);
    });

    test('a topic whose sub-topics have no items is empty', () async {
      harness.backend.noItems = true;
      final model = await open();
      expect(model.body.state, SectionState.empty);
      expect(model.body.subTopicIds, isEmpty);
    });

    test('no answer in time shows the error state', () async {
      final slow = harness.backend.gate = _never();
      final model = await open(timeout: const Duration(milliseconds: 30));
      expect(model.body.state, SectionState.error);
      slow.complete();
    });
  });

  group('"Öğrendim"', () {
    test('turns the item learned at once and sends its record', () async {
      final model = await open();

      await model.learnItem('ss-1:0');

      expect(model.subTopic('ss-1')!.items.first.card, ItemCardState.learned);
      expect(model.subTopic('ss-1')!.missingCount, 0);
      expect(harness.backend.learned, ['p-1']);
    });

    test('is optimistic: the item is learned before the answer', () async {
      final model = await open();
      final gate = harness.backend.gate = _never();

      final sending = model.learnItem('ss-1:0');
      await pumpEventQueue();
      expect(model.subTopic('ss-1')!.items.first.card, ItemCardState.learned);

      gate.complete();
      await sending;
    });

    test('a failure puts the item back and says so', () async {
      final model = await open();
      harness.backend.learnFail = true;

      await model.learnItem('ss-1:0');

      expect(model.subTopic('ss-1')!.items.first.card, ItemCardState.missing);
      expect(
        toastText(harness.toast),
        'Gönderilemedi. Bağlantını kontrol edip tekrar dene.',
      );
    });

    test('an item that is not missing sends nothing', () async {
      final model = await open();

      await model.learnItem('ss-1:1');
      await model.learnItem('ss-1:2');
      await model.learnItem('nope');

      expect(harness.backend.learned, isEmpty);
    });

    test('the session counts are read again afterwards', () async {
      final model = await open();
      final asked = harness.backend.count('/student/getLessonsTotalMissing');

      await model.learnItem('ss-1:0');
      await pumpEventQueue();

      expect(
        harness.backend.count('/student/getLessonsTotalMissing'),
        greaterThan(asked),
      );
    });
  });

  group('the star', () {
    test('is sent and kept on the item', () async {
      final model = await open();

      final saved = await model.setFavorite('ss-1:0', true);

      expect(saved, isTrue);
      expect(model.subTopic('ss-1')!.items.first.isFavorite, isTrue);
      expect(harness.backend.favorited, ['i-1']);
    });

    test('a failure keeps the old star and says so', () async {
      final model = await open();
      harness.backend.favoriteFail = true;

      final saved = await model.setFavorite('ss-1:0', true);

      expect(saved, isFalse);
      expect(model.subTopic('ss-1')!.items.first.isFavorite, isFalse);
      expect(toastText(harness.toast), isNotNull);
    });

    test('the same value is not sent again (the endpoint toggles)', () async {
      final model = await open();

      final saved = await model.setFavorite('ss-1:0', false);

      expect(saved, isTrue);
      expect(harness.backend.favorited, isEmpty);
    });
  });
}

Completer<void> _never() => Completer<void>();
