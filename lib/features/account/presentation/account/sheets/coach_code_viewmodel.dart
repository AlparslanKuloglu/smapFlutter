import 'dart:async';
import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/features/account/application/coach_code_text.dart';
import 'package:smap/features/coach/application/coach_code_actions.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/services/current_user_service.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

/// The logic of the coach's code sheet (pano 14.11 kare 2 to 6; T12.25,
/// T12.26).
///
/// - **The code** is the account's `refCode`: it comes with the session answer
///   and lives on the device (the session cache), so the sheet opens with it
///   at once, offline too (kare 6). Only when it is not there is there a
///   request: `CurrentUserService.refresh()` under the 15 s skeleton limit
///   (kare 4); no code after it, a failure or a timeout is the error with
///   "Tekrar Dene" (kare 5). There is no code renewal (T12.26).
/// - **Kopyala** puts the code on the clipboard, plays the selection click and
///   toasts "Kod kopyalandı." ([CoachCodeActions]); **Paylaş** opens the share
///   sheet with "SMAP koçluk kodum: MOZK-4821. Hesap › Koçluk'a girerek bana
///   bağlanabilirsin.". Both are off until the code is there.
/// - While offline with a code, the sheet adds "Kod cihazında saklı; ..." and
///   the offline strip stays above it ([isOnline]).
class CoachCodeViewModel extends BaseViewModel {
  CoachCodeViewModel({
    required CurrentUserService currentUser,
    required CoachCodeActions actions,
    required ValueListenable<bool> online,
    Duration timeout = SmapDurations.skeletonTimeout,
  }) : _currentUser = currentUser,
       _actions = actions,
       _online = online,
       _timeout = timeout {
    _online.addListener(_onConnectivity);
    _code = CoachCodeText.shown(_currentUser.user?.refCode);
    _state = _code == null ? SectionState.loading : SectionState.ready;
  }

  final CurrentUserService _currentUser;
  final CoachCodeActions _actions;
  final ValueListenable<bool> _online;
  final Duration _timeout;

  SectionState _state = SectionState.loading;
  String? _code;
  bool _disposed = false;

  /// Loading, ready or error (a missing code never reads as offline: the
  /// sheet has nothing saved to show, so it is the error with "Tekrar Dene").
  SectionState get state => _state;

  /// The code, `MOZK-4821`, once there.
  String? get code => _code;

  /// The device has a connection.
  bool get isOnline => _online.value;

  /// The code is shown from the device while there is no connection: the
  /// note "Kod cihazında saklı; ..." (kare 6).
  bool get showStoredNote => _state == SectionState.ready && !isOnline;

  /// Reads the code if it is not on the device yet; the sheet calls it once.
  Future<void> init() async {
    if (_state == SectionState.ready) return;
    await _load();
  }

  /// "Tekrar Dene": back to the skeleton and the request again.
  Future<void> retry() {
    _state = SectionState.loading;
    notifyListeners();
    return _load();
  }

  Future<void> _load() async {
    final section = await AsyncSection.load(() async {
      final result = await _currentUser.refresh();
      final user = result.fold((failure) => throw failure, (user) => user);
      return CoachCodeText.shown(user.refCode);
    }, timeout: _timeout);
    if (_disposed) return;
    final code = section.data;
    _code = code;
    _state = code == null ? SectionState.error : SectionState.ready;
    notifyListeners();
  }

  /// "Kopyala".
  Future<void> copy() async {
    final code = _code;
    if (code == null) return;
    await _actions.copy(code);
  }

  /// "Paylaş"; [origin] is the button's rectangle (an iPad popover).
  Future<void> share(AppLocalizations l10n, {Rect? origin}) async {
    final code = _code;
    if (code == null) return;
    await _actions.share(l10n.account_coachCodeShareText(code), origin: origin);
  }

  void _onConnectivity() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _online.removeListener(_onConnectivity);
    super.dispose();
  }
}
