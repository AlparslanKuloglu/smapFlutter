import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

export 'package:connectivity_plus/connectivity_plus.dart'
    show ConnectivityResult;

/// A scriptable stand-in for the `connectivity_plus` plugin.
class FakeConnectivity implements Connectivity {
  FakeConnectivity({
    List<ConnectivityResult> initial = const [ConnectivityResult.wifi],
  }) : current = initial;

  List<ConnectivityResult> current;
  bool failChecks = false;
  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    if (failChecks) throw StateError('plugin missing');
    return current;
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  /// Pushes a new reading, as the platform would.
  void emit(List<ConnectivityResult> results) {
    current = results;
    _controller.add(results);
  }

  Future<void> close() => _controller.close();
}
