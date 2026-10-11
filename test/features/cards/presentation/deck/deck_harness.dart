import 'dart:async';

import 'package:dio/dio.dart' show ResponseBody;
import 'package:flutter/foundation.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/features/cards/application/card_deck_loader.dart';
import 'package:smap/features/cards/application/deck_card.dart';
import 'package:smap/features/cards/application/deck_group.dart';
import 'package:smap/features/cards/data/card_repository.dart';
import 'package:smap/features/cards/domain/lesson_cards.dart';
import 'package:smap/features/cards/presentation/deck/card_deck_viewmodel.dart';
import 'package:smap/features/cards/presentation/deck/sheets/deck_prompts.dart';
import 'package:smap/features/exams/data/exam_repository.dart';
import 'package:smap/features/lessons/presentation/topic_detail/sheets/card_sheet.dart';
import 'package:smap/l10n/app_localizations_tr.dart';
import 'package:smap/shared/ui/feedback/toast_host.dart';
import 'package:smap/shared/ui/feedback/toast_slot.dart';
import 'package:smap/shared/ui/sheets/app_confirm_sheet.dart';

// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../../../core/network/fake_adapter.dart';
import '../../../exams/data/data_harness.dart';
import '../../application/deck_fixtures.dart';

/// A timer the test fires by hand.
class HeldTimer implements Timer {
  HeldTimer(this.duration, this._run);

  final Duration duration;
  final void Function() _run;
  bool cancelled = false;
  bool fired = false;

  void fire() {
    if (cancelled || fired) return;
    fired = true;
    _run();
  }

  @override
  void cancel() => cancelled = true;

  @override
  bool get isActive => !cancelled && !fired;

  @override
  int get tick => fired ? 1 : 0;
}

/// Answers the questions of the deck with what the test sets.
class FakePrompts implements CardDeckPrompts {
  /// What the confirmation answers.
  ConfirmResult confirmAnswer = const ConfirmResult(confirmed: true);

  /// What the card sheet returns.
  CardSheetResult? detailAnswer;

  final List<String> confirmed = [];
  final List<DeckCard> detailed = [];
  final List<bool> askedConfirm = [];
  Future<bool> Function(bool favorite)? sheetFavorite;

  @override
  Future<ConfirmResult> confirmLearn(String cardTitle) async {
    confirmed.add(cardTitle);
    return confirmAnswer;
  }

  @override
  Future<CardSheetResult?> showDetail({
    required DeckCard card,
    required String? lessonName,
    required bool askConfirm,
    required Future<bool> Function(bool favorite) onFavorite,
  }) async {
    detailed.add(card);
    askedConfirm.add(askConfirm);
    sheetFavorite = onFavorite;
    return detailAnswer;
  }
}

class _Presenter implements ToastPresenter {
  @override
  bool screenReaderOn = false;

  @override
  bool present(ToastSlot slot, ValueListenable<double?> barHeight) => true;
}

/// The server the deck talks to, scripted per test.
class DeckBackend {
  DeckBackend() {
    decks[tarihLesson] = tarihDecks();
  }

  /// The decks per exam lesson.
  final Map<String, LessonCardDecks> decks = {};

  /// `getTotalInfoCard` entries (`lesson` and `item`).
  List<Map<String, Object?>> earned = [];

  bool decksFail = false;
  bool decksOffline = false;
  bool learnFail = false;
  bool favoriteFail = false;
  bool earnedFail = false;

  /// While set, the learn and star requests wait for it.
  Completer<void>? gate;

  /// While set, the deck read waits for it.
  Completer<void>? decksGate;

  /// Every request: the path and its query.
  final List<String> asked = [];
  final List<String> learned = [];
  final List<String> favorited = [];

  int count(String path) => asked.where((a) => a.startsWith(path)).length;

  late final FakeAdapter adapter = FakeAdapter((options) async {
    final query = options.queryParameters;
    asked.add(
      '${options.path}${query.isEmpty ? '' : '?${query.entries.map((e) => '${e.key}=${e.value}').join('&')}'}',
    );
    ResponseBody failure() => jsonResponse({'success': false}, status: 500);
    switch (options.path) {
      case '/student/getLessonInfoCards':
        await decksGate?.future;
        if (decksFail) return failure();
        final lesson = query['lesson'] as String;
        return jsonResponse(
          decksAnswer(decks[lesson] ?? const LessonCardDecks()),
        );
      case '/student/learnedCard':
        await gate?.future;
        if (learnFail) return failure();
        learned.add(query['item'] as String);
        return jsonResponse({'success': true});
      case '/student/addFavoriteMobil':
        await gate?.future;
        if (favoriteFail) return failure();
        favorited.add(query['item'] as String);
        return jsonResponse({'success': true});
      case '/student/getTotalInfoCard':
        if (earnedFail) return failure();
        return jsonResponse({'success': true, 'data': earned});
    }
    return jsonResponse({'error': 'no route'}, status: 404);
  });
}

/// Everything the deck's ViewModel needs, over one [DeckBackend].
class DeckHarness {
  DeckHarness._(this.backend, this.preferences);

  static Future<DeckHarness> create({
    DeckBackend? backend,
    Map<String, Object> prefs = const {},
  }) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData(prefs);
    final harness = DeckHarness._(
      backend ?? DeckBackend(),
      await DevicePreferences.load(),
    );
    harness.network = networkOver(harness.backend.adapter);
    harness.cards = CardRepository(harness.network);
    harness.exams = ExamRepository(harness.network);
    return harness;
  }

  final DeckBackend backend;
  final DevicePreferences preferences;
  late NetworkService network;
  late CardRepository cards;
  late ExamRepository exams;
  final FakePrompts prompts = FakePrompts();
  final ToastService toast = ToastService(presenter: _Presenter());

  /// The timers the 6 s holds started, in order.
  final List<HeldTimer> timers = [];

  /// Fires every hold that is still waiting (the 6 s passed).
  void passUndoWindow() {
    for (final timer in List.of(timers)) {
      timer.fire();
    }
  }

  CardDeckViewModel viewModel({
    String? lessonId = tarihLesson,
    String? examId,
    DeckGroup? group,
    Duration timeout = const Duration(seconds: 15),
  }) => CardDeckViewModel(
    lessonId: lessonId,
    examId: examId,
    group: group,
    loader: CardDeckLoader(cards: cards, exams: exams),
    cards: cards,
    preferences: preferences,
    toast: toast,
    prompts: prompts,
    timeout: timeout,
    timerFactory: (duration, run) {
      final timer = HeldTimer(duration, run);
      timers.add(timer);
      return timer;
    },
  );

  /// The words of the toast on screen, `null` when none.
  String? get toastText =>
      toast.slot.current.value?.title(AppLocalizationsTr());

  /// Presses "Geri Al" on the toast on screen.
  bool pressUndo() {
    final entry = toast.slot.current.value;
    return entry != null && toast.slot.undo(entry.id);
  }

  Future<void> dispose() async {
    network.dispose();
    toast.dispose();
  }
}
