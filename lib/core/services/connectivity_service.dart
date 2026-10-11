import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'package:smap/core/services/app_logger.dart';

/// One connectivity reading for the whole app (`connectivity_plus`).
///
/// An unknown state (plugin missing, first check failed) reads as online:
/// requests fail fast on their own, while a wrong "offline" would stall
/// downloads and flash the offline strip. A link with no internet behind it
/// (captive Wi-Fi) also reads as online; `NetworkService` reports the actual
/// failure.
///
/// Listen with [online] (a `ValueListenable`, for ViewModels and the offline
/// strip) or [onlineChanges] (a stream of distinct values).
final class ConnectivityService {
  ConnectivityService({Connectivity? connectivity, AppLogger? logger})
    : _connectivity = connectivity ?? Connectivity(),
      _logger = logger ?? AppLogger.silent();

  final Connectivity _connectivity;
  final AppLogger _logger;
  final ValueNotifier<bool> _online = ValueNotifier<bool>(true);
  final StreamController<bool> _changes = StreamController<bool>.broadcast();

  List<ConnectivityResult>? _results;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _disposed = false;

  /// Last reading, `null` until the first check succeeded.
  List<ConnectivityResult>? get results => _results;

  /// Current state as a listenable.
  ValueListenable<bool> get online => _online;

  /// Whether the device has a link. See the class comment for "unknown".
  bool get isOnline => _online.value;

  /// Emits whenever [isOnline] flips (never the same value twice in a row).
  Stream<bool> get onlineChanges => _changes.stream;

  /// `true` unless the only link is cellular; VPN and other links pass. Use it
  /// before large uploads when the user asked for Wi-Fi only.
  bool get isNotCellular {
    final r = _results;
    if (r == null || r.isEmpty) return true;
    if (r.contains(ConnectivityResult.wifi) ||
        r.contains(ConnectivityResult.ethernet)) {
      return true;
    }
    return !r.contains(ConnectivityResult.mobile);
  }

  /// Reads the state once and starts listening. Safe to call twice.
  Future<void> initialize() async {
    if (_subscription != null || _disposed) return;
    await refresh();
    try {
      _subscription = _connectivity.onConnectivityChanged.listen(
        _apply,
        onError: (Object e) =>
            _logger.warning('stream error', name: 'Connectivity', error: e),
      );
    } on Object catch (e) {
      _logger.warning('stream unavailable', name: 'Connectivity', error: e);
    }
  }

  /// Reads the state now.
  Future<void> refresh() async {
    try {
      _apply(await _connectivity.checkConnectivity());
    } on Object catch (e) {
      _logger.warning('check failed', name: 'Connectivity', error: e);
      _results = null;
      _setOnline(true);
    }
  }

  void _apply(List<ConnectivityResult> results) {
    _results = results;
    _setOnline(
      results.isEmpty || results.any((c) => c != ConnectivityResult.none),
    );
  }

  void _setOnline(bool value) {
    if (_disposed || _online.value == value) return;
    _online.value = value;
    _changes.add(value);
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _subscription?.cancel();
    _subscription = null;
    await _changes.close();
    _online.dispose();
  }
}
