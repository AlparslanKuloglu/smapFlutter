import 'dart:async';

import 'package:stacked/stacked.dart';

import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/features/cards/application/card_deck_loader.dart';
import 'package:smap/features/cards/application/deck_card.dart';
import 'package:smap/features/cards/application/deck_group.dart';
import 'package:smap/features/cards/application/deck_lessons.dart';
import 'package:smap/features/cards/application/deck_library.dart';
import 'package:smap/features/cards/application/deck_session.dart';
import 'package:smap/features/cards/application/deck_swipe.dart';
import 'package:smap/features/cards/application/pending_learns.dart';
import 'package:smap/features/cards/data/card_repository.dart';
import 'package:smap/features/cards/presentation/deck/card_deck_state.dart';
import 'package:smap/features/cards/presentation/deck/sheets/deck_prompts.dart';
import 'package:smap/features/cards/presentation/widgets/card_deck.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

/// The logic of the card deck (pano 8.1 "Kart Destesi · 4 Kare", 8.2 koyu; spec
/// §4.G; route `/lessons/deck?lessonId=&examId=&group=`).
///
/// - **Loading.** The [CardDeckLoader] reads the decks of the lesson, or the
///   cards an exam earned; bounded by 15 s, then the error state shows. The
///   three counters and the session total come from the cards that arrived;
///   nothing is drawn that the server did not send.
/// - **Swiping** only goes on to the next card, never learns one (pano 8.1
///   kare 1: "yanlışlıkla taşınmaz"). The session wraps past the last card.
/// - **"Öğrendim"** (only on a missing card, only by the button or the card
///   sheet): the first time asks "Kartı Bildiklerim'e taşıyalım mı?" (the
///   "Bir daha sorma" box is kept on the device), then the card leaves to the
///   right, moves to Bildiklerim at once (counters 22 · 42 · 6, next card on
///   top), the success haptic plays and the toast "Kart Bildiklerim'e
///   taşındı." offers "Geri Al" for 6 s.
/// - **Undo has no endpoint** (spec §6.3 #24): the request is *held* on the
///   device for the 6 s ([PendingLearns]) and goes out when they pass; "Geri
///   Al" first means it never goes out. Leaving the screen sends what is still
///   held. If a held request fails, the card goes back to Eksiklerim with a
///   toast.
/// - **Star.** `addFavoriteMobil` is a toggle; the star flips at once and
///   flips back with a toast when the request fails.
class CardDeckViewModel extends BaseViewModel {
  CardDeckViewModel({
    required this.lessonId,
    required CardDeckLoader loader,
    required CardRepository cards,
    required DevicePreferences preferences,
    required ToastService toast,
    required CardDeckPrompts prompts,
    this.examId,
    DeckGroup? group,
    Duration timeout = SmapDurations.skeletonTimeout,
    Duration undoWindow = SmapDurations.undoToast,
    TimerFactory? timerFactory,
  }) : _loader = loader,
       _cards = cards,
       _preferences = preferences,
       _toast = toast,
       _prompts = prompts,
       _group = group ?? DeckGroup.missing,
       _timeout = timeout {
    _pending = PendingLearns(
      delay: undoWindow,
      send: _send,
      timerFactory: timerFactory,
    );
  }

  /// The exam lesson the deck was opened for ("Kartlarım" of Ders Detayı);
  /// with [examId] it narrows the exam's cards to that lesson.
  final String? lessonId;

  /// The exam the deck was opened from ("Kartları Çalış"); `null` for a lesson.
  final String? examId;

  final CardDeckLoader _loader;
  final CardRepository _cards;
  final DevicePreferences _preferences;
  final ToastService _toast;
  final CardDeckPrompts _prompts;
  final Duration _timeout;
  late final PendingLearns _pending;

  /// Moves the top card from outside (the view owns the deck widget).
  final CardDeckController deck = CardDeckController();

  SectionState _state = SectionState.loading;
  DeckLibrary _library = const DeckLibrary.empty();
  DeckGroup _group;
  DeckSession _session = DeckSession.empty;

  /// Where each held card stood in Eksiklerim, for "Geri Al".
  final Map<String, int> _removedAt = {};
  final Set<String> _starring = {};
  bool _started = false;
  bool _disposed = false;
  bool _busy = false;
  bool _liftedToast = false;

  /// The toast lifts by the height of the action row and its gap (16 + 48) so
  /// it sits 8 above the buttons and does not cover them (spec 8.1 kare 3:
  /// "Toast eylem satırının 8 üstünde").
  static const double toastLift = AppSpacing.s16 + AppSpacing.touch;

  // ── Selectors ──

  /// The title block.
  DeckHeaderData get header => DeckHeaderData(
    lessonName: DeckLessons.nameOf(lessonId),
    isExam: examId != null,
  );

  /// The segment and its counters.
  DeckSegmentData get segments =>
      DeckSegmentData(state: _state, group: _group, counts: _library.counts);

  /// The session progress; none while there is no card on top.
  DeckProgressData get progress => _state == SectionState.ready
      ? DeckProgressData(position: _session.position, total: _session.total)
      : DeckProgressData.none;

  /// The deck area.
  DeckStageData get stage {
    if (_state != SectionState.ready) {
      return DeckStageData(
        state: _state,
        group: _group,
        isExam: examId != null,
        empty: _state == SectionState.empty ? DeckEmptyKind.noCards : null,
      );
    }
    final front = _cardAt(0);
    return DeckStageData(
      state: _state,
      group: _group,
      front: front,
      next: _cardAt(1),
      behind: _session.behind,
      canSwipe: _session.canMove,
      empty: front == null ? _emptyKind : null,
      knownCount: _library.counts.known,
      isExam: examId != null,
    );
  }

  DeckEmptyKind get _emptyKind => switch (_group) {
    DeckGroup.missing => DeckEmptyKind.missingDone,
    DeckGroup.known => DeckEmptyKind.known,
    DeckGroup.favorite => DeckEmptyKind.favorite,
  };

  DeckCard? _cardAt(int offset) {
    final key = _session.peek(offset);
    return key == null ? null : _library.cardOf(key);
  }

  /// The card on top.
  DeckCard? get front => _cardAt(0);

  // ── Loading ──

  /// Loads the cards and puts the toast above the buttons; the view calls it
  /// once.
  Future<void> init() async {
    if (_started) return;
    _started = true;
    _toast.bottomBarHeight.addListener(_liftToast);
    _liftToast();
    await _load();
  }

  /// "Tekrar Dene": back to the skeleton and ask again.
  Future<void> retry() async {
    _state = SectionState.loading;
    notifyListeners();
    await _load();
  }

  Future<void> _load() async {
    final section = await AsyncSection.load<DeckLibrary>(() async {
      final answer = await _loader.load(lessonId: lessonId, examId: examId);
      return answer.fold((failure) => throw failure, (library) => library);
    }, timeout: _timeout);
    if (_disposed) return;
    final library = section.data;
    if (library == null) {
      _state = section.isOffline ? SectionState.offline : SectionState.error;
    } else {
      _library = library;
      _state = library.isEmpty ? SectionState.empty : SectionState.ready;
      _session = _sessionOf(_group);
    }
    notifyListeners();
  }

  DeckSession _sessionOf(DeckGroup group) =>
      DeckSession.start(_library.keysOf(group));

  // ── Moving through the deck ──

  /// A segment option was chosen.
  void selectGroup(DeckGroup group) {
    if (group == _group || _state != SectionState.ready) return;
    _group = group;
    _session = _sessionOf(group);
    notifyListeners();
  }

  /// "Bildiklerime Geç" of the empty Eksiklerim.
  void openKnown() => selectGroup(DeckGroup.known);

  /// The top card was swiped away: on to the next card.
  void onSwiped(DeckExit exit) {
    _session = _session.next();
    notifyListeners();
  }

  /// "Sonraki kart" for a screen reader.
  void next() {
    _session = _session.next();
    notifyListeners();
  }

  /// "Önceki kart" for a screen reader.
  void previous() {
    _session = _session.previous();
    notifyListeners();
  }

  // ── Öğrendim ──

  /// "Öğrendim" under the deck.
  Future<void> requestLearn() async {
    final card = front;
    if (card == null || !card.canLearn || _busy) return;
    _busy = true;
    try {
      if (!await _confirmed(card.title)) return;
      await _commitLearn(card.key);
    } finally {
      _busy = false;
    }
  }

  /// Whether to go on: asks once, unless the device was told not to.
  Future<bool> _confirmed(String title) async {
    if (_skipConfirm) return true;
    final answer = await _prompts.confirmLearn(title);
    if (_disposed || !answer.confirmed) return false;
    if (answer.dontAskAgain) _rememberSkip();
    return true;
  }

  bool get _skipConfirm =>
      _preferences.getBool(DevicePreferences.skipLearnedConfirmKey) ?? false;

  void _rememberSkip() => unawaited(
    _preferences.setBool(DevicePreferences.skipLearnedConfirmKey, true),
  );

  Future<void> _commitLearn(String key) async {
    final card = _library.cardOf(key);
    if (card == null || !card.canLearn) return;
    // In Eksiklerim the card leaves the deck; elsewhere it stays and only
    // loses its tag and its button.
    final leaves = _group == DeckGroup.missing && _session.front == key;
    if (leaves) await deck.exitFront(DeckExit.right);
    if (_disposed) return;
    _removedAt[key] = _library.missingIndexOf(key);
    _library = _library.learned(key);
    if (leaves) _session = _session.without(key);
    notifyListeners();
    AppHaptics.success();
    // The toast first, then the hold: both last 6 s, so the toast is gone
    // before the request can leave.
    _toast.undo((l) => l.cardDeck_moved, onUndo: () => _undo(key));
    _pending.schedule(key);
  }

  /// "Geri Al": the card goes back where it was, and its request never goes
  /// out. Too late (the request is out) changes nothing.
  void _undo(String key) {
    if (_disposed || !_pending.cancel(key)) return;
    _putBack(key);
  }

  void _putBack(String key) {
    _library = _library.unlearned(key, index: _removedAt.remove(key));
    if (_group == DeckGroup.missing) {
      _session = _session.has(key)
          ? _session.restored(key)
          : _sessionOf(DeckGroup.missing);
    }
    notifyListeners();
  }

  /// The hold of [key] is over: the request goes out. A failure puts the card
  /// back.
  Future<void> _send(String key) async {
    final id = _library.cardOf(key)?.card.itemId;
    if (id == null) return;
    final answer = await _cards.markLearned(itemId: id);
    if (_disposed) return;
    if (answer.isLeft()) {
      _putBack(key);
      _toast.error((l) => l.cardDeck_sendFailed);
      return;
    }
    _removedAt.remove(key);
  }

  // ── Detail and star ──

  /// "Detay": the card sheet of the top card; its "Öğrendim" learns the card.
  Future<void> openDetail() async {
    final card = front;
    if (card == null || _busy) return;
    _busy = true;
    try {
      final result = await _prompts.showDetail(
        card: card,
        lessonName: DeckLessons.nameOf(card.lessonId ?? lessonId),
        askConfirm: !_skipConfirm,
        onFavorite: (favorite) => setFavorite(card.key, favorite: favorite),
      );
      if (_disposed || result == null || !result.learned) return;
      if (result.dontAskAgain) _rememberSkip();
      await _commitLearn(card.key);
    } finally {
      _busy = false;
    }
  }

  /// The star of the top card.
  Future<void> toggleFavorite() {
    final card = front;
    if (card == null) return Future.value();
    return setFavorite(card.key, favorite: !card.isFavorite);
  }

  /// Sets the star of [key]: flips at once, flips back with a toast when the
  /// request fails. Answers whether it was saved. A second press while the
  /// first is on its way is ignored.
  Future<bool> setFavorite(String key, {required bool favorite}) async {
    final card = _library.cardOf(key);
    if (card == null || !card.canFavorite) return false;
    if (card.isFavorite == favorite) return true;
    if (!_starring.add(key)) return false;
    _library = _library.withFavorite(key, value: favorite);
    notifyListeners();
    final answer = await _cards.toggleFavorite(itemId: card.card.itemId!);
    _starring.remove(key);
    if (_disposed) return answer.isRight();
    if (answer.isLeft()) {
      _library = _library.withFavorite(key, value: !favorite);
      notifyListeners();
      _toast.error((l) => l.cardDeck_sendFailed);
      return false;
    }
    return true;
  }

  // ── The toast above the buttons ──

  /// Keeps the toast's offset 64 higher than the shell's while the deck is
  /// up. The shell writes the plain bar height; this raises that one value.
  void _liftToast() {
    if (_toast.bottomBarHeight.value == AppSize.bottomBar) {
      _liftedToast = true;
      _toast.bottomBarHeight.value = AppSize.bottomBar + toastLift;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _toast.bottomBarHeight.removeListener(_liftToast);
    if (_liftedToast &&
        _toast.bottomBarHeight.value == AppSize.bottomBar + toastLift) {
      _toast.bottomBarHeight.value = AppSize.bottomBar;
    }
    // What is still held goes out now: a learned card is not lost by leaving.
    unawaited(_pending.flush());
    super.dispose();
  }
}
