import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:smap/core/theme/app_motion.dart';

/// What the offline strip shows (C75).
enum OfflineStripPhase {
  /// Online: no strip.
  hidden,

  /// No connection: "Çevrimdışısın. Son kaydedilen veriler gösteriliyor."
  offline,

  /// The connection came back: "Bağlandın" for 2 s, then the strip goes.
  connected,
}

/// The phase machine behind the offline strip, apart from the widget so it
/// can be tested with fake timers (C75; handoff 11.15 "Çevrimdışı şeridi").
///
/// It follows an `online` listenable (`ConnectivityService.online`):
///
/// - online to offline: [OfflineStripPhase.offline] at once, no delay (a
///   flaky link already settles in `ConnectivityService`);
/// - offline to online: [OfflineStripPhase.connected] for
///   [SmapDurations.connectedNotice] (2 s), then [OfflineStripPhase.hidden];
/// - going offline again during the notice cancels the countdown;
/// - starting online shows nothing; starting offline shows the strip.
class OfflineStripController {
  OfflineStripController({
    required ValueListenable<bool> online,
    Duration notice = SmapDurations.connectedNotice,
    Timer Function(Duration, void Function())? timerFactory,
  }) : _online = online,
       _notice = notice,
       _timerFactory = timerFactory ?? Timer.new,
       _phase = ValueNotifier<OfflineStripPhase>(
         online.value ? OfflineStripPhase.hidden : OfflineStripPhase.offline,
       ) {
    _online.addListener(_onChange);
  }

  final ValueListenable<bool> _online;
  final Duration _notice;
  final Timer Function(Duration, void Function()) _timerFactory;
  final ValueNotifier<OfflineStripPhase> _phase;
  Timer? _timer;

  /// The phase to draw.
  ValueListenable<OfflineStripPhase> get phase => _phase;

  void _onChange() {
    _timer?.cancel();
    _timer = null;
    if (!_online.value) {
      _phase.value = OfflineStripPhase.offline;
      return;
    }
    // Back online: only a strip that was showing has anything to announce.
    if (_phase.value == OfflineStripPhase.hidden) return;
    _phase.value = OfflineStripPhase.connected;
    _timer = _timerFactory(_notice, () {
      _timer = null;
      _phase.value = OfflineStripPhase.hidden;
    });
  }

  void dispose() {
    _online.removeListener(_onChange);
    _timer?.cancel();
    _phase.dispose();
  }
}
