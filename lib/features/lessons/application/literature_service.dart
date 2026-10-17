import 'dart:async';

import 'package:flutter/foundation.dart' show ValueListenable, immutable;
import 'package:stacked/stacked.dart';

import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/features/cards/application/pending_learns.dart';
import 'package:smap/features/lessons/application/literature_authors.dart';
import 'package:smap/features/lessons/application/literature_loader.dart';
import 'package:smap/features/lessons/application/literature_tree.dart';
import 'package:smap/features/lessons/application/topic_outline.dart';
import 'package:smap/features/lessons/data/lesson_content_repository.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

/// What [LiteratureService] holds: the eras, the sub-subjects of each era and
/// the authors of each sub-subject, every level in its own section so one
/// failure stays where it happened (pano 14.7).
@immutable
class LiteratureState {
  const LiteratureState({
    this.eras = const AsyncSection<List<LiteratureEra>>.loading(),
    this.subs = const {},
    this.authors = const {},
  });

  final AsyncSection<List<LiteratureEra>> eras;

  /// Sub-subjects by era id.
  final Map<String, AsyncSection<List<LiteratureSub>>> subs;

  /// Authors by sub-subject id.
  final Map<String, AsyncSection<List<AuthorView>>> authors;

  LiteratureState copyWith({
    AsyncSection<List<LiteratureEra>>? eras,
    Map<String, AsyncSection<List<LiteratureSub>>>? subs,
    Map<String, AsyncSection<List<AuthorView>>>? authors,
  }) => LiteratureState(
    eras: eras ?? this.eras,
    subs: subs ?? this.subs,
    authors: authors ?? this.authors,
  );
}

/// A work that was marked learned and whose request is waiting (or running).
@immutable
class PendingLearn {
  const PendingLearn({
    required this.eraId,
    required this.subId,
    required this.authorKey,
    required this.progressId,
    required this.title,
    required this.eraCounted,
    required this.subCounted,
  });

  final String eraId;
  final String subId;
  final String authorKey;
  final String progressId;
  final String title;

  /// The era's and the sub-subject's counters went down for this work, so
  /// undoing it puts exactly that back.
  final bool eraCounted;
  final bool subCounted;
}

/// The Yazar ve Eserler tree of the signed-in student, cached for the session,
/// and the one place where "Öğrendim" lands (pano 14.5 to 14.7; spec §4.F 7.4).
///
/// It lives in the `session` DI scope, so the next user starts with nothing.
/// Screens listen with `ListenableServiceMixin` and read [state].
///
/// - **Levels.** [loadEras], [loadSubs] and [loadAuthors] each read their
///   level; a level that is already here shows at once and is read again
///   without a skeleton (a failure then keeps what is shown). A level that
///   fails shows its own error and [retry]-style reloads (`force`) go back to
///   the skeleton.
/// - **One count, everywhere.** The segment counter, the era's tag, the
///   accordion's tag, the author row and the sheet are all read from this
///   state, so [learn] lowers them in the same frame (pano 14.6 kare 2).
/// - **"Öğrendim".** The work turns learned at once, success haptic, toast
///   "{Eser} bildiklerine eklendi." with "Geri Al". The server cannot take it
///   back, so `learnedItem` is held 6 s ([PendingLearns]): "Geri Al" within that
///   time means the request never goes out ([undo]). If the request fails the
///   work goes back to missing and the toast says nothing was saved. This is
///   the card deck's own hold ([PendingLearns], E13), keyed by the work's
///   progress id, so each "Öğrendim" has its window (one toast shows at a
///   time; the earlier ones go out when their time is up). Learning needs a connection; offline [learn] does nothing (the button is
///   off, pano 14.7 kare 3).
class LiteratureService with ListenableServiceMixin {
  LiteratureService({
    required LessonContentRepository repository,
    required ToastService toast,
    required ValueListenable<bool> online,
    Future<void> Function()? onSaved,
    Duration undoWindow = SmapDurations.undoToast,
    Duration timeout = SmapDurations.skeletonTimeout,
    TimerFactory? timerFactory,
  }) : _repository = repository,
       _loader = LiteratureLoader(repository),
       _toast = toast,
       _online = online,
       _onSaved = onSaved,
       _timeout = timeout {
    listenToReactiveValues([_state]);
    _hold = PendingLearns(
      delay: undoWindow,
      send: _commit,
      timerFactory: timerFactory,
    );
  }

  final LessonContentRepository _repository;
  final LiteratureLoader _loader;
  final ToastService _toast;
  final ValueListenable<bool> _online;
  final Future<void> Function()? _onSaved;
  final Duration _timeout;
  late final PendingLearns _hold;
  final Map<String, PendingLearn> _pending = {};

  final ReactiveValue<LiteratureState> _state = ReactiveValue<LiteratureState>(
    const LiteratureState(),
  );
  final Map<String, Future<void>> _inFlight = {};
  bool _disposed = false;

  LiteratureState get state => _state.value;

  /// The device has a link (learning is off without one).
  bool get isOnline => _online.value;

  /// The connection state as a listenable, for the sheet.
  ValueListenable<bool> get online => _online;

  /// The era [id], `null` while the list is not here.
  LiteratureEra? eraOf(String id) {
    for (final era in state.eras.data ?? const <LiteratureEra>[]) {
      if (era.id == id) return era;
    }
    return null;
  }

  /// Missing works over all eras; `null` while unknown (no counter).
  int? get totalMissing =>
      sumMissing([for (final era in state.eras.data ?? const []) era.missing]);

  AsyncSection<List<LiteratureSub>> subsOf(String eraId) =>
      state.subs[eraId] ?? const AsyncSection<List<LiteratureSub>>.loading();

  AsyncSection<List<AuthorView>> authorsOf(String subId) =>
      state.authors[subId] ?? const AsyncSection<List<AuthorView>>.loading();

  /// The author [authorKey] of the sub-subject [subId], `null` for none.
  AuthorView? authorOf(String subId, String authorKey) {
    for (final author in state.authors[subId]?.data ?? const <AuthorView>[]) {
      if (author.key == authorKey) return author;
    }
    return null;
  }

  /// The "Öğrendim"s that wait for their 6 s.
  Iterable<PendingLearn> get pending => _pending.values;

  // ── Reading ──

  /// The era list. [force] goes back to the skeleton (the retry).
  Future<void> loadEras({bool force = false}) => _read<List<LiteratureEra>>(
    'eras',
    force: force,
    has: () => state.eras.isReady,
    fetch: _loader.eras,
    store: (section) => _emit(state.copyWith(eras: _withPendingEras(section))),
    show: () => _emit(
      state.copyWith(eras: const AsyncSection<List<LiteratureEra>>.loading()),
    ),
  );

  /// The sub-subjects of the era [eraId].
  Future<void> loadSubs(String eraId, {bool force = false}) =>
      _read<List<LiteratureSub>>(
        'subs:$eraId',
        force: force,
        has: () => state.subs[eraId]?.isReady ?? false,
        fetch: () => _loader.subs(eraId),
        store: (section) => _emit(
          state.copyWith(
            subs: {...state.subs, eraId: _withPendingSubs(eraId, section)},
          ),
        ),
        show: () => _emit(
          state.copyWith(
            subs: {
              ...state.subs,
              eraId: const AsyncSection<List<LiteratureSub>>.loading(),
            },
          ),
        ),
      );

  /// The authors of the sub-subject [subId] of the era [eraId]; the
  /// sub-subject must be loaded.
  Future<void> loadAuthors(String eraId, String subId, {bool force = false}) {
    final sub = _subOf(eraId, subId);
    if (sub == null) return Future.value();
    return _read<List<AuthorView>>(
      'authors:$subId',
      force: force,
      has: () => state.authors[subId]?.isReady ?? false,
      fetch: () => _loader.authors(sub),
      store: (section) => _emit(
        state.copyWith(
          authors: {
            ...state.authors,
            subId: _withPendingAuthors(subId, section),
          },
        ),
      ),
      show: () => _emit(
        state.copyWith(
          authors: {
            ...state.authors,
            subId: const AsyncSection<List<AuthorView>>.loading(),
          },
        ),
      ),
    );
  }

  /// One level's read, shared by calls that arrive while it runs. A level
  /// that is here keeps showing (no skeleton) and a failure then changes
  /// nothing; otherwise [show] puts the skeleton up first and a failure shows
  /// its error.
  Future<void> _read<T>(
    String key, {
    required bool force,
    required bool Function() has,
    required Future<AppResult<T>> Function() fetch,
    required void Function(AsyncSection<T> section) store,
    void Function()? show,
  }) {
    final running = _inFlight[key];
    if (running != null && !force) return running;
    final keep = has() && !force;
    if (!keep) show?.call();
    final future = () async {
      final section = await AsyncSection.load<T>(
        () async => (await fetch()).fold<T>(
          (AppException failure) => throw failure,
          (value) => value,
        ),
        timeout: _timeout,
      );
      if (_disposed) return;
      if (keep && (section.isError || section.isOffline)) return;
      store(section);
    }();
    _inFlight[key] = future;
    return future.whenComplete(() {
      if (identical(_inFlight[key], future)) _inFlight.remove(key);
    });
  }

  // ── "Öğrendim" ──

  /// Marks the work [progressId] of the author [authorKey] learned. Returns
  /// `false` when nothing happened: offline, or a work that is not missing.
  bool learn({
    required String eraId,
    required String subId,
    required String authorKey,
    required String progressId,
  }) {
    if (!isOnline) return false;
    final work = authorOf(subId, authorKey)?.workOf(progressId);
    if (work == null || !work.canLearn) return false;

    final eraCounted = (eraOf(eraId)?.missing ?? 0) > 0;
    final subCounted = (_subOf(eraId, subId)?.missing ?? 0) > 0;
    final item = PendingLearn(
      eraId: eraId,
      subId: subId,
      authorKey: authorKey,
      progressId: progressId,
      title: work.title,
      eraCounted: eraCounted,
      subCounted: subCounted,
    );
    _show(item, learned: true);
    _pending[progressId] = item;
    _hold.schedule(progressId);
    AppHaptics.success();
    _toast.undo(
      (l) => l.literature_learnedToast(work.title),
      onUndo: () => undo(progressId),
    );
    return true;
  }

  /// "Geri Al": the request never goes out and the work is missing again.
  void undo(String progressId) {
    if (!_hold.cancel(progressId)) return;
    final item = _pending.remove(progressId);
    if (item != null) _show(item, learned: false);
  }

  Future<void> _commit(String progressId) async {
    final item = _pending.remove(progressId);
    if (item == null) return;
    final answer = await _repository.markItemLearned(itemId: item.progressId);
    if (_disposed) return;
    if (answer.isLeft()) {
      _show(item, learned: false);
      _toast.error((l) => l.literature_saveFailed);
      return;
    }
    final saved = _onSaved;
    if (saved != null) unawaited(saved().catchError((Object _) {}));
  }

  /// Draws [item] learned (or missing again) in every level at once.
  void _show(PendingLearn item, {required bool learned}) {
    final delta = learned ? -1 : 1;
    final current = state;

    final authors = current.authors[item.subId];
    final authorList = authors?.data;
    final nextAuthors = authorList == null
        ? current.authors
        : {
            ...current.authors,
            item.subId: AsyncSection<List<AuthorView>>.ready([
              for (final author in authorList)
                author.key == item.authorKey
                    ? author.withWorkCard(
                        item.progressId,
                        learned ? ItemCardState.learned : ItemCardState.missing,
                      )
                    : author,
            ]),
          };

    final eras = current.eras.data;
    final nextEras = eras == null || !item.eraCounted
        ? current.eras
        : AsyncSection<List<LiteratureEra>>.ready([
            for (final era in eras)
              era.id == item.eraId
                  ? era.withMissing(_moved(era.missing, delta))
                  : era,
          ]);

    final subs = current.subs[item.eraId]?.data;
    final nextSubs = subs == null || !item.subCounted
        ? current.subs
        : {
            ...current.subs,
            item.eraId: AsyncSection<List<LiteratureSub>>.ready([
              for (final sub in subs)
                sub.id == item.subId
                    ? sub.withMissing(_moved(sub.missing, delta))
                    : sub,
            ]),
          };

    _emit(
      LiteratureState(eras: nextEras, subs: nextSubs, authors: nextAuthors),
    );
  }

  static int? _moved(int? count, int delta) =>
      count == null ? null : (count + delta).clamp(0, 1 << 30);

  // ── Waiting "Öğrendim" over fresh data ──

  AsyncSection<List<LiteratureEra>> _withPendingEras(
    AsyncSection<List<LiteratureEra>> section,
  ) {
    final eras = section.data;
    if (eras == null || _pending.isEmpty) return section;
    return AsyncSection<List<LiteratureEra>>.ready([
      for (final era in eras)
        era.withMissing(
          _moved(
            era.missing,
            -pending.where((p) => p.eraCounted && p.eraId == era.id).length,
          ),
        ),
    ]);
  }

  AsyncSection<List<LiteratureSub>> _withPendingSubs(
    String eraId,
    AsyncSection<List<LiteratureSub>> section,
  ) {
    final subs = section.data;
    if (subs == null || _pending.isEmpty) return section;
    return AsyncSection<List<LiteratureSub>>.ready([
      for (final sub in subs)
        sub.withMissing(
          _moved(
            sub.missing,
            -pending
                .where(
                  (p) => p.subCounted && p.eraId == eraId && p.subId == sub.id,
                )
                .length,
          ),
        ),
    ]);
  }

  AsyncSection<List<AuthorView>> _withPendingAuthors(
    String subId,
    AsyncSection<List<AuthorView>> section,
  ) {
    final authors = section.data;
    if (authors == null || _pending.isEmpty) return section;
    final mine = pending.where((p) => p.subId == subId).toList();
    if (mine.isEmpty) return section;
    return AsyncSection<List<AuthorView>>.ready([
      for (final author in authors)
        mine
            .where((p) => p.authorKey == author.key)
            .fold(
              author,
              (view, p) =>
                  view.withWorkCard(p.progressId, ItemCardState.learned),
            ),
    ]);
  }

  // ── State ──

  LiteratureSub? _subOf(String eraId, String subId) {
    for (final sub in state.subs[eraId]?.data ?? const <LiteratureSub>[]) {
      if (sub.id == subId) return sub;
    }
    return null;
  }

  void _emit(LiteratureState next) {
    if (_disposed) return;
    _state.value = next;
  }

  /// Sends the waiting requests now.
  Future<void> flush() => _hold.flush();

  /// Stops delivering results of reads that are still running; a waiting
  /// request is dropped.
  void dispose() {
    _disposed = true;
    _hold.dispose();
    _pending.clear();
  }
}
