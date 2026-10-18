import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/utils/turkish_text.dart';
import 'package:smap/features/account/application/coaching_logic.dart';
import 'package:smap/features/account/data/account_repository.dart';
import 'package:smap/features/account/domain/coach_code.dart';
import 'package:smap/features/account/presentation/coaching/coaching_dialogs.dart';
import 'package:smap/services/current_user_service.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

/// The state of the code field under "Koçun yok" (pano 9.5 kare 3).
enum CoachCodeProblem {
  /// "Bu kodla bir koç bulunamadı. Kodu koçundan yeniden iste."
  notFound,
}

/// The logic of "Koçluk" (pano 9.5 kare 1 to 4, Tur 12 F; spec §4.C 9.5).
///
/// - **Load:** `getStudentsCoach` under the 15 s skeleton limit. A coach is
///   [SectionState.ready] ("Koçun var"), none is [SectionState.empty]
///   ("Koçun yok"); a failed load is the error or offline state with "Tekrar
///   Dene".
/// - **Link** (no coach): the typed code goes out as `AAAA-0000` with one
///   `addCoach` call. "Bu kodla bir koç bulunamadı..." sits under the field;
///   success is the toast "Mehmet Özkan'a bağlandın." and the screen turns to
///   "Koçun var". "Koça Bağlan" is open only for a complete code.
/// - **Change** (Tur 12 F, pano 14.10): with a coach, "Koçu Değiştir" opens a
///   sheet that takes the new code and makes the same single `addCoach` call
///   the old screen made, not a `deleteCoach` first (T12.24, open question:
///   whether the server replaces the link by itself; the legacy app assumed
///   it did and so does this one). No second confirmation (T12.21). When the
///   sheet closes with the new coach the card shows it at once, the toast says
///   "Ayşe Demir'e bağlandın." with the success haptic, the focus moves to the
///   card ([cardFocus]) and `getStudentsCoach` refreshes the card in the
///   background (picture, code). Offline both actions are closed.
/// - **Unlink:** the dangerous confirmation, then `deleteCoach` with the
///   coach's id; the toast "Koç bağlantın kaldırıldı." and "Koçun yok".
///
/// After a link or an unlink the signed-in user is reloaded in the
/// background so Hesap's "Koçun: …" is not stale.
class CoachingViewModel extends BaseViewModel {
  CoachingViewModel({
    required AccountRepository account,
    required CurrentUserService currentUser,
    required CoachingDialogs dialogs,
    required ToastService toast,
    required ValueListenable<bool> online,
    Duration timeout = SmapDurations.skeletonTimeout,
  }) : _account = account,
       _currentUser = currentUser,
       _dialogs = dialogs,
       _toast = toast,
       _online = online,
       _timeout = timeout {
    _online.addListener(_onConnectivity);
  }

  final AccountRepository _account;
  final CurrentUserService _currentUser;
  final CoachingDialogs _dialogs;
  final ToastService _toast;
  final ValueListenable<bool> _online;
  final Duration _timeout;

  final ValueNotifier<bool> _codeComplete = ValueNotifier<bool>(false);

  /// Counts the moments the focus should move to the coach card: after a
  /// change succeeded (pano 14.10 kare 5).
  final ValueNotifier<int> cardFocus = ValueNotifier<int>(0);

  SectionState _state = SectionState.loading;
  CoachLink? _coach;
  CoachCodeProblem? _problem;
  bool _connecting = false;
  bool _unlinking = false;
  bool _changing = false;
  bool _disposed = false;

  /// Where the load stands: loading, ready ("Koçun var"), empty ("Koçun
  /// yok"), error or offline.
  SectionState get state => _state;

  /// The coach, in [SectionState.ready].
  CoachLink? get coach => _coach;

  /// The problem under the code field.
  CoachCodeProblem? get problem => _problem;

  /// A link, an unlink or a change is running: the buttons wait.
  bool get isWorking => _connecting || _unlinking || _changing;

  /// "Koça Bağlan" is the running action (its spinner).
  bool get isConnecting => _connecting;

  /// The device has a connection; "Koçunu Değiştir" needs it.
  bool get isOnline => _online.value;

  /// The typed code is complete (four letters, four digits): "Koça Bağlan"
  /// works. Changes with every keystroke, so it is a `ValueListenable`.
  ValueListenable<bool> get codeComplete => _codeComplete;

  // ----------------------------------------------------------------- load

  /// Loads the coach; the view calls it once when the screen is built.
  Future<void> init() => _load();

  /// "Tekrar Dene": back to the skeleton and the call again.
  Future<void> retry() {
    _state = SectionState.loading;
    notifyListeners();
    return _load();
  }

  Future<void> _load() async {
    final section = await AsyncSection.load(() async {
      final result = await _account.getMyCoach();
      return result.fold((failure) => throw failure, CoachLink.fromUser);
    }, timeout: _timeout);
    if (_disposed) return;
    _coach = section.data;
    _state = switch (section.state) {
      // A ready section holds a coach; `AsyncSection.of` never reads `null`
      // data as empty, so "no coach" is decided here.
      SectionState.ready when section.data == null => SectionState.empty,
      final other => other,
    };
    notifyListeners();
  }

  // ----------------------------------------------------------------- link

  /// The code field changed: the problem goes away and the button follows
  /// the text.
  void codeEdited(String text) {
    _codeComplete.value = CoachCode.isValid(text);
    if (_problem == null) return;
    _problem = null;
    notifyListeners();
  }

  /// "Koça Bağlan".
  Future<void> connect(String text) async {
    final code = CoachCode.tryParse(text);
    if (code == null || isWorking) return;
    _connecting = true;
    _problem = null;
    notifyListeners();
    final result = await requestLink(code);
    if (_disposed) return;
    _connecting = false;
    final linked = result.coach;
    if (linked != null) {
      _commit(linked);
      return;
    }
    switch (result.failure) {
      case CoachLinkFailure.notFound:
        // The field plays the error haptic when its error appears.
        _problem = CoachCodeProblem.notFound;
      case CoachLinkFailure.sameCoach:
      case CoachLinkFailure.failed:
      case null:
        _toast.error((l10n) => l10n.accountSettings_sendFailed);
    }
    notifyListeners();
  }

  /// One `addCoach` call for [code], read as a [CoachLinkResult]. It changes
  /// nothing on the screen: the caller commits a success ([connect], or
  /// [changeCoach] once its sheet has closed).
  ///
  /// The code is sent as `AAAA-0000`. An answer that is the coach the student
  /// already has reads as [CoachLinkFailure.sameCoach] (Tur 12 F).
  Future<CoachLinkResult> requestLink(CoachCode code) async {
    if (CoachingRules.verdict(code.display, current: _coach) ==
        CoachCodeVerdict.currentCoach) {
      return const CoachLinkResult.failed(CoachLinkFailure.sameCoach);
    }
    final result = await _account.addCoach(code.display);
    final failure = result.leftOrNull;
    if (failure != null) {
      return CoachLinkResult.failed(
        failure.code == AppErrorCode.validation
            ? CoachLinkFailure.notFound
            : CoachLinkFailure.failed,
      );
    }
    final linked = CoachLink.fromUser(result.rightOrNull);
    if (linked == null) {
      // The server linked, but the answer has no coach to show: read it
      // again rather than draw an empty card.
      unawaited(_load());
      return const CoachLinkResult.failed(CoachLinkFailure.failed);
    }
    if (CoachingRules.isSameCoach(_coach, linked)) {
      return const CoachLinkResult.failed(CoachLinkFailure.sameCoach);
    }
    return CoachLinkResult.linked(linked);
  }

  void _commit(CoachLink linked) {
    _coach = linked;
    _state = SectionState.ready;
    _problem = null;
    _codeComplete.value = false;
    _toast.success(
      (l10n) => l10n.coaching_linked(TurkishSuffix.dative(linked.name)),
    );
    unawaited(_currentUser.refresh());
    notifyListeners();
  }

  /// Asks `getStudentsCoach` for the card after a change (pano 14.10 Veri):
  /// the picture and code the server holds replace what `addCoach` echoed.
  /// A failed call, no coach, or another coach than the one just linked
  /// changes nothing: the card stays as the change left it.
  Future<void> _refreshCard(CoachLink linked) async {
    final result = await _account.getMyCoach();
    if (_disposed) return;
    final fresh = CoachLink.fromUser(result.rightOrNull);
    if (fresh == null || fresh.id != linked.id || fresh == _coach) return;
    _coach = fresh;
    notifyListeners();
  }

  /// "Koçu Değiştir" (Tur 12 F): the sheet takes the new code; a link it
  /// returns is committed here, after the sheet has closed.
  Future<void> changeCoach() async {
    final current = _coach;
    if (current == null || isWorking || !isOnline) return;
    _changing = true;
    notifyListeners();
    final linked = await _dialogs.changeCoach(
      current: current,
      submit: requestLink,
    );
    if (_disposed) return;
    _changing = false;
    if (linked != null) {
      _commit(linked);
      cardFocus.value++;
      unawaited(_refreshCard(linked));
    } else {
      notifyListeners();
    }
  }

  // --------------------------------------------------------------- unlink

  /// "Bağlantıyı Kaldır": asks, then unlinks.
  Future<void> unlink() async {
    final current = _coach;
    if (current == null || isWorking || !isOnline) return;
    final confirmed = await _dialogs.confirmUnlink(coachName: current.name);
    if (!confirmed || _disposed) return;
    _unlinking = true;
    notifyListeners();
    final result = await _account.removeCoach(current.id);
    if (_disposed) return;
    _unlinking = false;
    if (result.leftOrNull != null) {
      _toast.error((l10n) => l10n.accountSettings_sendFailed);
      notifyListeners();
      return;
    }
    _coach = null;
    _state = SectionState.empty;
    _problem = null;
    _codeComplete.value = false;
    _toast.success((l10n) => l10n.coaching_unlinked);
    unawaited(_currentUser.refresh());
    notifyListeners();
  }

  // ----------------------------------------------------------------- sheet

  /// "Koçluk Kodu Nedir?".
  Future<void> showCodeInfo() => _dialogs.showCodeInfo();

  void _onConnectivity() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _online.removeListener(_onConnectivity);
    _codeComplete.dispose();
    cardFocus.dispose();
    super.dispose();
  }
}
