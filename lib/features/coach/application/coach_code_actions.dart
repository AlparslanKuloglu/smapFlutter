import 'dart:async';

import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/services/toast_service.dart';

/// Puts text on the clipboard.
typedef CopyText = Future<void> Function(String text);

/// Opens the system share sheet with [text]; [origin] is the rectangle of the
/// button that asked (an iPad anchors its popover there).
typedef ShareText = Future<void> Function(String text, {Rect? origin});

/// What the two buttons of the coaching code card do (C35 `CodeCard`; pano
/// 10.1 kare 3, 10.3, 14.11 kare 3): "Kopyala" copies the code, plays the
/// selection click and says "Kod kopyalandı." in a toast (a text only: no
/// success haptic); "Paylaş" opens the system share sheet with the code in a
/// sentence. Shared by the coach home, the add-student sheet and the code
/// sheet of Hesap, so they behave the same.
///
/// The ViewModels that own a code card hold one of these; tests inject the
/// clipboard and the sharer, the app uses [CoachCodeActions.system].
class CoachCodeActions {
  CoachCodeActions({
    required CopyText copyText,
    required ShareText shareText,
    required ToastService toast,
  }) : _copyText = copyText,
       _shareText = shareText,
       _toast = toast;

  /// The real clipboard and the system share sheet.
  CoachCodeActions.system({required ToastService toast})
    : this(
        copyText: (text) => Clipboard.setData(ClipboardData(text: text)),
        shareText: (text, {origin}) async {
          await SharePlus.instance.share(
            ShareParams(text: text, sharePositionOrigin: origin),
          );
        },
        toast: toast,
      );

  final CopyText _copyText;
  final ShareText _shareText;
  final ToastService _toast;

  /// "Kopyala": [code] on the clipboard, `selectionClick`, and the toast "Kod
  /// kopyalandı." (a live region; no success haptic).
  Future<void> copy(String code) async {
    await _copyText(code);
    AppHaptics.selection();
    _toast.success((l) => l.coachWidgets_codeCopied, haptic: false);
  }

  /// "Paylaş": the share sheet with [message] (the sentence that carries the
  /// code); [origin] anchors the iPad popover on the button.
  Future<void> share(String message, {Rect? origin}) =>
      _shareText(message, origin: origin);
}
