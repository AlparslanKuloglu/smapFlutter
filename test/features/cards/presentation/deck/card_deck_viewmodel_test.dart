import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/features/cards/application/deck_card.dart';
import 'package:smap/features/cards/application/deck_group.dart';
import 'package:smap/features/cards/application/deck_library.dart';
import 'package:smap/features/cards/application/deck_swipe.dart';
import 'package:smap/features/cards/domain/lesson_cards.dart';
import 'package:smap/features/cards/presentation/deck/card_deck_state.dart';
import 'package:smap/features/cards/presentation/deck/card_deck_viewmodel.dart';
import 'package:smap/features/lessons/presentation/topic_detail/sheets/card_sheet.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/illustrations/app_clay.dart';
import 'package:smap/shared/ui/sheets/app_confirm_sheet.dart';

import '../../application/deck_fixtures.dart';
import 'deck_harness.dart';

/// TYT Matematik, a lesson with no clay picture (web-only in v1).
const tytMatematik = '663e387c4fb443839593141c';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DeckHarness harness;
  CardDeckViewModel? viewModel;

  Future<CardDeckViewModel> open({
    String? lessonId = tarihLesson,
    String? examId,
    DeckGroup? group,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final model = harness.viewModel(
      lessonId: lessonId,
      examId: examId,
      group: group,
      timeout: timeout,
    );
    viewModel = model;
    await model.init();
    await pumpEventQueue();
    return model;
  }

  /// Swipes to the card at the 1-based [position] of the session.
  void swipeTo(CardDeckViewModel model, int position) {
    while (model.progress.position < position) {
      model.onSwiped(DeckExit.right);
    }
  }

  setUp(() async {
    harness = await DeckHarness.create();
  });

  tearDown(() async {
    viewModel?.dispose();
    viewModel = null;
    await pumpEventQueue();
    await harness.dispose();
  });

  group('loading (pano 8.1 kare 1)', () {
    test('starts on the skeleton, with the title already known', () {
      final model = harness.viewModel();
      viewModel = model;

      expect(model.stage.state, SectionState.loading);
      expect(model.segments.visible, isFalse);
      expect(model.progress.visible, isFalse);
      expect(model.header.lessonName, 'Tarih', reason: '"Tarih Kartları"');
      expect(model.header.isExam, isFalse);
    });

    test('shows the three counters and the session "1/23"', () async {
      final model = await open();

      expect(model.stage.state, SectionState.ready);
      expect(model.segments.visible, isTrue);
      expect(model.segments.group, DeckGroup.missing);
      expect(
        model.segments.counts,
        const DeckCounts(missing: 23, known: 41, favorite: 6),
      );
      expect(model.progress.position, 1);
      expect(model.progress.total, 23);
      expect(model.stage.front!.title, 'Edirne-Segedin Antlaşması (1444)');
      expect(model.stage.next!.title, 'Otlukbeli Savaşı (1473)');
      expect(model.stage.behind, 2);
      expect(model.stage.canSwipe, isTrue);
      expect(model.stage.empty, isNull);
      expect(harness.backend.asked, [
        '/student/getLessonInfoCards?lesson=$tarihLesson',
      ]);
    });

    test('a lesson outside the catalog gets no name', () async {
      harness.backend.decks['other'] = tarihDecks();
      final model = await open(lessonId: 'other');
      expect(model.header.lessonName, isNull);
      expect(model.stage.state, SectionState.ready);
    });

    test('opens on the group of the link', () async {
      final model = await open(group: DeckGroup.favorite);

      expect(model.segments.group, DeckGroup.favorite);
      expect(model.progress.total, 6);
      expect(model.stage.front!.title, 'Konu 5');
    });

    test('a lesson with no card anywhere is the empty state', () async {
      harness.backend.decks[tarihLesson] = const LessonCardDecks();

      final model = await open();

      expect(model.stage.state, SectionState.empty);
      expect(model.stage.empty, DeckEmptyKind.noCards);
      expect(model.segments.visible, isFalse);
      expect(model.progress.visible, isFalse);
    });

    test(
      'a failure is the error state, and "Tekrar Dene" asks again',
      () async {
        harness.backend.decksFail = true;
        final model = await open();

        expect(model.stage.state, SectionState.error);
        expect(model.segments.visible, isFalse);

        harness.backend.decksFail = false;
        final retry = model.retry();
        expect(model.stage.state, SectionState.loading);
        await retry;

        expect(model.stage.state, SectionState.ready);
        expect(harness.backend.count('/student/getLessonInfoCards'), 2);
      },
    );

    test('no answer in time is an error, not an endless skeleton', () async {
      harness.backend.decksGate = Completer<void>();
      final model = harness.viewModel(timeout: const Duration(milliseconds: 5));
      viewModel = model;

      await model.init();

      expect(model.stage.state, SectionState.error);
      harness.backend.decksGate!.complete();
    });

    test(
      'a deck opened with neither a lesson nor an exam is an error',
      () async {
        final model = await open(lessonId: null);
        expect(model.stage.state, SectionState.error);
      },
    );
  });

  group('swiping (pano 8.1 kare 1: "yanlışlıkla taşınmaz")', () {
    test('only goes on to the next card and sends nothing', () async {
      final model = await open();

      model.onSwiped(DeckExit.left);

      expect(model.progress.position, 2);
      expect(model.stage.front!.title, 'Otlukbeli Savaşı (1473)');
      expect(model.segments.counts.missing, 23, reason: 'nothing was learned');
      expect(harness.backend.count('/student/learnedCard'), 0);
      expect(harness.timers, isEmpty);
    });

    test('wraps past the last card', () async {
      final model = await open();
      swipeTo(model, 23);
      expect(model.stage.front!.key, 'm23');

      model.onSwiped(DeckExit.right);

      expect(model.progress.position, 1);
      expect(model.stage.front!.key, 'edirne');
    });

    test('"Sonraki kart" and "Önceki kart" move one card', () async {
      final model = await open();

      model.next();
      expect(model.progress.position, 2);
      model.previous();
      model.previous();
      expect(model.progress.position, 23);
    });

    test('switching the group starts that deck from its first card', () async {
      final model = await open();
      swipeTo(model, 5);

      model.selectGroup(DeckGroup.known);

      expect(model.segments.group, DeckGroup.known);
      expect(model.progress.position, 1);
      expect(model.progress.total, 41);
      expect(model.stage.front!.key, 'k1');
      expect(model.stage.front!.canLearn, isFalse);
    });

    test('choosing the same group changes nothing', () async {
      final model = await open();
      swipeTo(model, 5);
      model.selectGroup(DeckGroup.missing);
      expect(model.progress.position, 5);
    });
  });

  group('Öğrendim (pano 8.1 kare 2 and 3)', () {
    test('asks the first time and the card then moves: 22 · 42 · 6', () async {
      final model = await open();
      swipeTo(model, 12);
      expect(model.progress.position, 12);
      final learned = model.stage.front!;

      await model.requestLearn();

      expect(harness.prompts.confirmed, [learned.title]);
      expect(
        model.segments.counts,
        const DeckCounts(missing: 22, known: 42, favorite: 6),
      );
      expect(model.progress.position, 13, reason: '"13/23"');
      expect(model.progress.total, 23);
      expect(model.stage.front!.key, 'm13');
      expect(harness.toastText, "Kart Bildiklerim'e taşındı.");
      expect(harness.toast.slot.current.value!.hasUndo, isTrue);
    });

    test('the move shows the next card of the board', () async {
      final model = await open();

      await model.requestLearn();

      expect(model.stage.front!.title, 'Otlukbeli Savaşı (1473)');
      expect(model.progress.position, 2);
      expect(model.segments.counts.missing, 22);
    });

    test('holds the request for the 6 s and then sends it', () async {
      final model = await open();

      await model.requestLearn();
      await pumpEventQueue();

      expect(harness.backend.learned, isEmpty, reason: 'still held');
      expect(harness.timers.single.duration, const Duration(seconds: 6));

      harness.passUndoWindow();
      await pumpEventQueue();

      expect(harness.backend.learned, ['edirne']);
      expect(harness.backend.asked.last, '/student/learnedCard?item=edirne');
      expect(model.segments.counts.missing, 22);
    });

    test(
      '"Geri Al" puts the card back and the request never goes out',
      () async {
        final model = await open();
        swipeTo(model, 5);
        final key = model.stage.front!.key;
        await model.requestLearn();
        expect(model.segments.counts.missing, 22);

        expect(harness.pressUndo(), isTrue);

        expect(
          model.segments.counts,
          const DeckCounts(missing: 23, known: 41, favorite: 6),
        );
        expect(model.stage.front!.key, key, reason: 'the card is on top again');
        expect(model.progress.position, 5);
        harness.passUndoWindow();
        await pumpEventQueue();
        expect(harness.backend.learned, isEmpty);
        expect(harness.backend.count('/student/learnedCard'), 0);
      },
    );

    test('"Vazgeç" in the confirmation leaves everything as it was', () async {
      harness.prompts.confirmAnswer = ConfirmResult.cancelled;
      final model = await open();

      await model.requestLearn();

      expect(model.segments.counts.missing, 23);
      expect(model.stage.front!.key, 'edirne');
      expect(harness.toastText, isNull);
      expect(harness.timers, isEmpty);
    });

    test(
      '"Bir daha sorma" is kept on the device and stops the question',
      () async {
        harness.prompts.confirmAnswer = const ConfirmResult(
          confirmed: true,
          dontAskAgain: true,
        );
        final model = await open();

        await model.requestLearn();
        await pumpEventQueue();
        expect(
          harness.preferences.getBool(DevicePreferences.skipLearnedConfirmKey),
          isTrue,
        );

        await model.requestLearn();

        expect(harness.prompts.confirmed, hasLength(1), reason: 'asked once');
        expect(model.segments.counts.missing, 21);
      },
    );

    test('a device that was told not to ask learns at once', () async {
      await harness.dispose();
      harness = await DeckHarness.create(
        prefs: {DevicePreferences.skipLearnedConfirmKey: true},
      );
      final model = await open();

      await model.requestLearn();

      expect(harness.prompts.confirmed, isEmpty);
      expect(model.segments.counts.missing, 22);
    });

    test('a failed request puts the card back with an error toast', () async {
      harness.backend.learnFail = true;
      final model = await open();
      swipeTo(model, 3);
      await model.requestLearn();
      expect(model.segments.counts.missing, 22);

      harness.passUndoWindow();
      await pumpEventQueue();

      expect(model.segments.counts.missing, 23);
      expect(model.stage.front!.key, 'm3');
      expect(
        harness.toastText,
        'Gönderilemedi. Bağlantını kontrol edip tekrar dene.',
      );
    });

    test('leaving the screen sends what is still held', () async {
      final model = await open();
      await model.requestLearn();
      expect(harness.backend.learned, isEmpty);

      model.dispose();
      viewModel = null;
      await pumpEventQueue();

      expect(harness.backend.learned, ['edirne']);
    });

    test('Öğrendim is only on a missing card', () async {
      final model = await open(group: DeckGroup.known);
      await model.requestLearn();
      expect(harness.prompts.confirmed, isEmpty);
      expect(harness.timers, isEmpty);
    });

    test('a card without an id cannot be learned', () async {
      harness.backend.decks[tarihLesson] = const LessonCardDecks(
        missing: [
          InfoCard(name: 'Kimliksiz', descriptions: ['Metin.']),
        ],
      );
      final model = await open();

      expect(model.stage.front!.canLearn, isFalse);
      await model.requestLearn();
      expect(harness.prompts.confirmed, isEmpty);
    });

    test('a second press while the first is asking is ignored', () async {
      final model = await open();

      final first = model.requestLearn();
      final second = model.requestLearn();
      await Future.wait([first, second]);

      expect(harness.prompts.confirmed, hasLength(1));
      expect(model.segments.counts.missing, 22);
    });

    test('learning in Favorilerim keeps the card and drops its tag', () async {
      final model = await open(group: DeckGroup.favorite);
      expect(model.stage.front!.key, 'm5');
      expect(model.stage.front!.status, CardStatus.missing);

      await model.requestLearn();

      expect(model.stage.front!.key, 'm5', reason: 'still in Favorilerim');
      expect(model.stage.front!.status, CardStatus.known);
      expect(model.stage.front!.canLearn, isFalse);
      expect(
        model.segments.counts,
        const DeckCounts(missing: 22, known: 42, favorite: 6),
      );
      expect(model.progress.total, 6);
    });

    test(
      '"Geri Al" works after the user changed the group and came back',
      () async {
        final model = await open();
        await model.requestLearn();
        model.selectGroup(DeckGroup.known);
        model.selectGroup(DeckGroup.missing);
        expect(model.progress.total, 22);

        harness.pressUndo();

        expect(model.segments.counts.missing, 23);
        expect(model.stage.front!.key, 'edirne');
      },
    );

    test('the last missing card learned is the empty Eksiklerim', () async {
      harness.backend.decks[tarihLesson] = LessonCardDecks(
        missing: [card('only', 'Tek kart', text: 'Metin.')],
        known: knownCards(64),
        favorites: favoriteCards().skip(2).toList(),
      );
      final model = await open();
      expect(
        model.stage.canSwipe,
        isFalse,
        reason: 'a single card stays still',
      );
      expect(model.stage.behind, 0);

      await model.requestLearn();

      final stage = model.stage;
      expect(stage.empty, DeckEmptyKind.missingDone);
      expect(stage.front, isNull);
      expect(stage.knownCount, 65, reason: '"Bildiklerim\'deki 65 kartı..."');
      expect(model.segments.counts.missing, 0, reason: '"kart yok"');
      expect(model.progress.visible, isFalse);
      expect(
        stage.picture,
        ClayPicture.sutun,
        reason: 'a lesson deck draws its own lesson picture (board 1.25)',
      );
    });

    test('a lesson without a picture draws none (Matematik)', () async {
      harness.backend.decks[tytMatematik] = LessonCardDecks(
        missing: [card('only', 'Tek kart', text: 'Metin.')],
        known: knownCards(3),
      );
      final model = await open(lessonId: tytMatematik);
      await model.requestLearn();

      expect(model.stage.empty, DeckEmptyKind.missingDone);
      expect(model.stage.picture, isNull);
    });

    test('"Bildiklerime Geç" opens Bildiklerim', () async {
      harness.backend.decks[tarihLesson] = LessonCardDecks(
        missing: [card('only', 'Tek kart', text: 'Metin.')],
        known: knownCards(64),
      );
      final model = await open();
      await model.requestLearn();

      model.openKnown();

      expect(model.segments.group, DeckGroup.known);
      expect(model.progress.total, 65);
      expect(model.stage.front!.key, 'only', reason: 'newest learned first');
    });

    test('the other empty groups say what is missing', () async {
      harness.backend.decks[tarihLesson] = LessonCardDecks(
        missing: [card('a', 'A', text: 'x')],
      );
      final model = await open();

      model.selectGroup(DeckGroup.known);
      expect(model.stage.empty, DeckEmptyKind.known);
      model.selectGroup(DeckGroup.favorite);
      expect(model.stage.empty, DeckEmptyKind.favorite);
    });
  });

  group('the star', () {
    test('flips at once and is sent', () async {
      final model = await open();
      final key = model.stage.front!.key;
      expect(model.stage.front!.isFavorite, isFalse);

      final saved = model.toggleFavorite();
      expect(model.stage.front!.isFavorite, isTrue);
      expect(model.segments.counts.favorite, 7);
      await saved;

      expect(harness.backend.favorited, [key]);
      expect(model.stage.front!.isFavorite, isTrue);
    });

    test('flips back with a toast when the request fails', () async {
      harness.backend.favoriteFail = true;
      final model = await open();

      await model.toggleFavorite();

      expect(model.stage.front!.isFavorite, isFalse);
      expect(model.segments.counts.favorite, 6);
      expect(harness.toastText, startsWith('Gönderilemedi.'));
    });

    test('un-starring sends the toggle again', () async {
      final model = await open(group: DeckGroup.favorite);
      expect(model.stage.front!.isFavorite, isTrue);

      await model.toggleFavorite();

      expect(harness.backend.favorited, ['m5']);
      expect(model.segments.counts.favorite, 5);
      expect(model.stage.front!.key, 'm5', reason: 'the card stays this run');
      expect(model.stage.front!.isFavorite, isFalse);
    });

    test('a second press while the first is on its way is ignored', () async {
      harness.backend.gate = Completer<void>();
      final model = await open();

      final first = model.toggleFavorite();
      final second = model.toggleFavorite();
      await pumpEventQueue();
      harness.backend.gate!.complete();
      await Future.wait([first, second]);

      expect(harness.backend.favorited, hasLength(1));
      expect(model.stage.front!.isFavorite, isTrue);
    });

    test('the sheet star goes through the same request', () async {
      final model = await open();
      harness.prompts.detailAnswer = null;

      await model.openDetail();
      final saved = await harness.prompts.sheetFavorite!(true);

      expect(saved, isTrue);
      expect(harness.backend.favorited, ['edirne']);
      expect(model.segments.counts.favorite, 7);
    });
  });

  group('Detay (pano 7.3 kare 3)', () {
    test('opens the card sheet of the top card and asks to confirm', () async {
      final model = await open();

      await model.openDetail();

      expect(harness.prompts.detailed.single.key, 'edirne');
      expect(harness.prompts.askedConfirm, [true]);
      expect(harness.timers, isEmpty);
    });

    test('a closed sheet changes nothing', () async {
      final model = await open();
      await model.openDetail();
      expect(model.segments.counts.missing, 23);
    });

    test('"Öğrendim" in the sheet moves the card like the button', () async {
      harness.prompts.detailAnswer = const CardSheetResult(dontAskAgain: true);
      final model = await open();

      await model.openDetail();

      expect(harness.prompts.confirmed, isEmpty, reason: 'the sheet asked');
      expect(model.segments.counts.missing, 22);
      expect(model.stage.front!.key, 'otlukbeli');
      expect(harness.toastText, "Kart Bildiklerim'e taşındı.");
      expect(
        harness.preferences.getBool(DevicePreferences.skipLearnedConfirmKey),
        isTrue,
      );
      harness.pressUndo();
      expect(model.segments.counts.missing, 23);
    });

    test('a known card has Detay but no Öğrendim', () async {
      final model = await open(group: DeckGroup.known);
      await model.openDetail();
      expect(harness.prompts.detailed.single.canLearn, isFalse);
    });
  });

  group('the cards of an exam (pano 5.6 "Kartları Çalış")', () {
    const otherLesson = '663e37a24fb443839593141b';

    setUp(() {
      harness.backend.decks[otherLesson] = LessonCardDecks(
        missing: [card('t1', 'Türkçe kartı', text: 'Metin.')],
      );
      harness.backend.earned = [
        {'lesson': tarihLesson, 'item': 'edirne'},
        {'lesson': tarihLesson, 'item': 'm4'},
        {
          'lesson': otherLesson,
          'item': {'_id': 't1'},
        },
      ];
    });

    test('keeps the cards the exam earned, each under its lesson', () async {
      final model = await open(lessonId: null, examId: 'exam-1');

      expect(model.header.isExam, isTrue, reason: '"Deneme Kartları"');
      expect(model.stage.state, SectionState.ready);
      expect(model.segments.counts.missing, 3);
      expect(model.stage.picture, ClayPicture.harita, reason: 'exam deck: map');
      expect(model.progress.total, 3);
      expect(model.stage.front!.key, 'edirne');
      expect(model.stage.front!.lessonId, tarihLesson);
      model.next();
      model.next();
      expect(model.stage.front!.key, 't1');
      expect(model.stage.front!.lessonId, otherLesson);
      expect(
        harness.backend.asked.first,
        startsWith('/student/getTotalInfoCard'),
      );
    });

    test('narrowed to one lesson when the link has both', () async {
      final model = await open(examId: 'exam-1');
      expect(model.segments.counts.missing, 2);
      expect(model.header.lessonName, 'Tarih');
      expect(
        model.stage.picture,
        ClayPicture.harita,
        reason: 'an exam deck keeps the map even when narrowed to a lesson',
      );
    });

    test('an exam that earned no card is the empty state', () async {
      harness.backend.earned = [];
      final model = await open(lessonId: null, examId: 'exam-1');
      expect(model.stage.empty, DeckEmptyKind.noCards);
      expect(model.stage.isExam, isTrue);
    });

    test(
      'an answer that does not name the items is no deck, not a wrong one',
      () async {
        harness.backend.earned = [
          {'lesson': tarihLesson},
        ];
        final model = await open(lessonId: null, examId: 'exam-1');
        expect(model.stage.state, SectionState.error);
      },
    );

    test('a failed read is the error state', () async {
      harness.backend.earnedFail = true;
      final model = await open(lessonId: null, examId: 'exam-1');
      expect(model.stage.state, SectionState.error);
    });
  });

  group('the toast sits above the buttons', () {
    test(
      'lifts by the action row while the deck is up and puts it back',
      () async {
        harness.toast.bottomBarHeight.value = AppSize.bottomBar;
        final model = await open();

        expect(
          harness.toast.bottomBarHeight.value,
          AppSize.bottomBar + CardDeckViewModel.toastLift,
        );
        expect(CardDeckViewModel.toastLift, 64, reason: '16 gap + 48 buttons');

        model.dispose();
        viewModel = null;

        expect(harness.toast.bottomBarHeight.value, AppSize.bottomBar);
      },
    );

    test('follows the shell when it writes the bar height again', () async {
      harness.toast.bottomBarHeight.value = AppSize.bottomBar;
      await open();

      harness.toast.bottomBarHeight.value = AppSize.bottomBar;

      expect(
        harness.toast.bottomBarHeight.value,
        AppSize.bottomBar + CardDeckViewModel.toastLift,
      );
    });

    test('leaves a hidden bar alone', () async {
      harness.toast.bottomBarHeight.value = null;
      await open();
      expect(harness.toast.bottomBarHeight.value, isNull);
    });
  });
}
