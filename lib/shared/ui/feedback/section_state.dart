import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/theme/app_motion.dart';

/// The five states every data section of a screen can be in (UI guide §6
/// rule 11; board 1.22 "Toast ve Durum Kalıpları": "Her ekranın dört durumu
/// var: ilk yükleme (iskelet), boş, hata (Tekrar Dene) ve çevrimdışı").
enum SectionState {
  /// First load: the skeleton is shown. Ends in at most 15 s
  /// ([SmapDurations.skeletonTimeout]).
  loading,

  /// Data arrived and there is something to show.
  ready,

  /// Data arrived and there is nothing in it: the empty state.
  empty,

  /// The load failed or timed out: the error state with "Tekrar Dene".
  error,

  /// The load failed because there is no connection and nothing saved to
  /// show: the offline state. (With saved data the section is [ready] and
  /// the offline strip tells the story.)
  offline,
}

/// A section's state with its data: the immutable value a
/// `SelectorViewModelWidget` selects on (C76 "Skeleton", plan KIT2
/// "AsyncSection").
///
/// Equality is by [state] and [data] (and the error text), so a selector
/// rebuilds only when something the section shows changed. Never invent
/// [data] to avoid a state: no data means [SectionState.empty] or
/// [SectionState.error], never a fake value (UI guide §6 rule 11).
///
/// ```dart
/// var _today = const AsyncSection<List<TodayItem>>.loading();
/// _today = await AsyncSection.load(() => _repo.today(), isEmpty: (l) => l.isEmpty);
/// ```
@immutable
class AsyncSection<T> {
  const AsyncSection._(this.state, this.data, this.error);

  /// First load, or a retry after an error ("Tekrar Dene" returns to the
  /// skeleton).
  const AsyncSection.loading() : this._(SectionState.loading, null, null);

  /// Data with something in it.
  const AsyncSection.ready(T data) : this._(SectionState.ready, data, null);

  /// Data that is empty.
  const AsyncSection.empty() : this._(SectionState.empty, null, null);

  /// A failed load. [error] is for logs; the screen never prints it.
  const AsyncSection.error([Object? error])
    : this._(SectionState.error, null, error);

  /// A failed load with no connection.
  const AsyncSection.offline() : this._(SectionState.offline, null, null);

  /// The state to draw.
  final SectionState state;

  /// The data; non-null only for [SectionState.ready].
  final T? data;

  /// What went wrong, for logs. Not part of equality beyond its text.
  final Object? error;

  bool get isLoading => state == SectionState.loading;
  bool get isReady => state == SectionState.ready;
  bool get isEmpty => state == SectionState.empty;
  bool get isError => state == SectionState.error;
  bool get isOffline => state == SectionState.offline;

  /// A section of [data], [SectionState.empty] when [isEmpty] says so.
  static AsyncSection<T> of<T>(T data, {bool Function(T data)? isEmpty}) =>
      isEmpty != null && isEmpty(data)
      ? AsyncSection<T>.empty()
      : AsyncSection<T>.ready(data);

  /// The state a failure maps to: no connection is [SectionState.offline],
  /// everything else (a server error, a timeout, a parse failure) is
  /// [SectionState.error].
  static AsyncSection<T> failed<T>(Object error) {
    final isOffline = error is AppException && error.isOffline;
    return isOffline ? AsyncSection<T>.offline() : AsyncSection<T>.error(error);
  }

  /// Runs [fetch] under the 15 s skeleton limit ([withSkeletonTimeout]) and
  /// turns the outcome into a section: data (or empty), offline, or error.
  /// Never throws.
  static Future<AsyncSection<T>> load<T>(
    Future<T> Function() fetch, {
    bool Function(T data)? isEmpty,
    Duration timeout = SmapDurations.skeletonTimeout,
  }) async {
    try {
      final data = await withSkeletonTimeout(fetch(), timeout: timeout);
      return of(data, isEmpty: isEmpty);
    } on Object catch (e) {
      return failed<T>(e);
    }
  }

  @override
  bool operator ==(Object other) =>
      other is AsyncSection<T> &&
      other.state == state &&
      other.data == data &&
      other.error?.toString() == error?.toString();

  @override
  int get hashCode => Object.hash(state, data, error?.toString());

  @override
  String toString() => 'AsyncSection<$T>(${state.name})';
}

/// Limits a first load: a [future] with no answer after [timeout] (15 s by
/// default, `SmapDurations.skeletonTimeout`) completes with a
/// [TimeoutException], so the section can show its error state; "sonsuz
/// iskelet yok" (C76).
///
/// The original request is not cancelled by this; cancel it with a Dio
/// `CancelToken` when the timeout matters to the server.
Future<T> withSkeletonTimeout<T>(
  Future<T> future, {
  Duration timeout = SmapDurations.skeletonTimeout,
}) => future.timeout(timeout);

/// A watchdog for a loading section that is driven by events rather than one
/// future (a stream of results, a listened service): call [start] when the
/// skeleton appears and [stop] when data arrives; if [stop] has not been
/// called after [timeout], [onTimeout] runs once.
class SkeletonWatchdog {
  SkeletonWatchdog({
    required this.onTimeout,
    this.timeout = SmapDurations.skeletonTimeout,
    Timer Function(Duration, void Function())? timerFactory,
  }) : _timerFactory = timerFactory ?? Timer.new;

  /// Called once when the limit passes.
  final VoidCallback onTimeout;
  final Duration timeout;
  final Timer Function(Duration, void Function()) _timerFactory;
  Timer? _timer;

  /// Whether the watchdog is counting.
  bool get running => _timer?.isActive ?? false;

  /// Starts (or restarts) counting.
  void start() {
    _timer?.cancel();
    _timer = _timerFactory(timeout, () {
      _timer = null;
      onTimeout();
    });
  }

  /// Data arrived (or the screen left): stops counting.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
