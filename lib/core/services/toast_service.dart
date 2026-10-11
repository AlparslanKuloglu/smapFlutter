import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/shared/ui/feedback/toast_host.dart';
import 'package:smap/shared/ui/feedback/toast_slot.dart';

export 'package:smap/shared/ui/feedback/toast_slot.dart'
    show AppToastKind, ToastText;

/// App-wide toasts (C74 "Toast"; board 1.22 kare 1; UI guide §5 #27), for
/// ViewModels and services that have no `BuildContext`:
///
/// ```dart
/// _toast.success((l) => l.schedule_saved);
/// _toast.undo((l) => l.cards_movedToKnown, onUndo: _undoMove);
/// ```
///
/// One toast at a time: a new one replaces the one on screen. It stays 4 s,
/// or 6 s with "Geri Al"; with a screen reader on it stays until the user
/// closes it. It sits 8 pt above the bottom bar ([bottomBarHeight], set by
/// the shell that owns the bar; `null` without a bar means the bottom safe
/// area plus 16) and swipes away upward. Colors come from the theme's
/// inverse surface, so it flips in dark theme.
///
/// Haptics (`haptic`, on by default): an error toast plays
/// `AppHaptics.error()`, a success toast `AppHaptics.success()`; pass
/// `haptic: false` when the action that raised the toast already played its
/// own. Messages are short sentences in the "sen" tone with no emoji, no
/// "Hata:" prefix and no inner code; use a toast only for transient failures
/// (a permanent one is drawn on the screen).
///
/// It draws in the root navigator's overlay, so no router is involved
/// (Düzeltmeler #9, #22). Register it once in the locator:
/// `ToastService.navigator(router.navigatorKey)`.
class ToastService {
  ToastService({
    required ToastPresenter presenter,
    ToastSlot? slot,
    ValueNotifier<double?>? bottomBarHeight,
  }) : _presenter = presenter,
       _slot = slot ?? ToastSlot(),
       bottomBarHeight = bottomBarHeight ?? ValueNotifier<double?>(null);

  /// Draws in the overlay of [navigatorKey]'s navigator.
  ToastService.navigator(
    GlobalKey<NavigatorState> navigatorKey, {
    ToastTimerFactory? timerFactory,
  }) : this(
         presenter: OverlayToastPresenter.navigator(navigatorKey),
         slot: ToastSlot(timerFactory: timerFactory),
       );

  final ToastPresenter _presenter;
  final ToastSlot _slot;

  /// The bottom bar's height without the safe area (`AppSize.bottomBar`),
  /// or `null` while the bar is hidden. The shell sets it.
  final ValueNotifier<double?> bottomBarHeight;

  /// The slot, for tests.
  @visibleForTesting
  ToastSlot get slot => _slot;

  /// Whether a toast is on screen.
  late final ValueListenable<bool> visible = _Visible(_slot);

  /// A neutral note ("Sonucun hazır olunca bildirim gelecek.").
  void info(ToastText title) => _show(AppToastKind.info, title);

  /// Something worked ("Program kaydedildi."). Plays the success haptic
  /// unless [haptic] is false.
  void success(ToastText title, {bool haptic = true}) =>
      _show(AppToastKind.success, title, haptic: haptic);

  /// A transient failure ("Gönderilemedi. Bağlantını kontrol edip tekrar
  /// dene."). Plays the error haptic unless [haptic] is false.
  void error(ToastText title, {bool haptic = true}) =>
      _show(AppToastKind.error, title, haptic: haptic);

  /// A done action that can be taken back ("Kart Bildiklerim'e taşındı."
  /// with "Geri Al"); stays 6 s. [onUndo] runs once.
  void undo(ToastText title, {required VoidCallback onUndo}) =>
      _show(AppToastKind.success, title, onUndo: onUndo, haptic: false);

  /// Closes the toast on screen, if any.
  void dismiss() => _slot.dismiss();

  void _show(
    AppToastKind kind,
    ToastText title, {
    VoidCallback? onUndo,
    bool haptic = false,
  }) {
    if (haptic) {
      switch (kind) {
        case AppToastKind.error:
          AppHaptics.error();
        case AppToastKind.success:
          AppHaptics.success();
        case AppToastKind.info:
          break;
      }
    }
    _slot.show(
      kind: kind,
      title: title,
      onUndo: onUndo,
      persistent: _presenter.screenReaderOn,
    );
    if (!_presenter.present(_slot, bottomBarHeight)) _slot.dismiss();
  }

  void dispose() {
    _slot.dispose();
    bottomBarHeight.dispose();
  }
}

/// `true` while the slot holds a toast, as a listenable.
class _Visible extends ValueListenable<bool> {
  _Visible(this._slot);

  final ToastSlot _slot;

  @override
  bool get value => _slot.isShowing;

  @override
  void addListener(VoidCallback listener) =>
      _slot.current.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _slot.current.removeListener(listener);
}
