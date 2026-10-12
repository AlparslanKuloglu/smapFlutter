import 'package:flutter/material.dart' show TimeOfDay;

import 'package:smap/features/account/application/notification_preferences.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/pickers/app_time_wheel.dart';

/// The one sheet of "Bildirimler": the quiet-hours time wheel (pano 9.6 kare
/// 3). A ViewModel asks this and gets plain minutes; tests give it answers.
abstract interface class NotificationsDialogs {
  /// Picks the quiet time at [bound], starting from [initialMinutes] (minutes
  /// after midnight). Completes with the saved minutes, or `null` when the
  /// sheet was dismissed.
  Future<int?> pickQuietTime({
    required QuietBound bound,
    required int initialMinutes,
  });
}

/// [NotificationsDialogs] as the app's time wheel sheet (UI guide §6 rule
/// 15): "Sessiz saat başlangıcı" (kare 3) and, for the other end, "Sessiz saat
/// bitişi" (the board does not draw that title; spec §4.C 9.6 "belirtilmemiş").
///
/// A ViewModel has no `BuildContext`, so the sheet opens on the root
/// navigator (`AppSheet.navigatorKey`); [l10n] gives the texts.
class SheetNotificationsDialogs implements NotificationsDialogs {
  const SheetNotificationsDialogs({required this.l10n});

  final AppLocalizations l10n;

  @override
  Future<int?> pickQuietTime({
    required QuietBound bound,
    required int initialMinutes,
  }) async {
    final picked = await AppTimeWheelSheet.show(
      title: bound == QuietBound.start
          ? l10n.notifications_quietStartTitle
          : l10n.notifications_quietEndTitle,
      saveLabel: l10n.common_save,
      initial: TimeOfDay(
        hour: initialMinutes ~/ 60,
        minute: initialMinutes % 60,
      ),
    );
    return picked == null ? null : picked.hour * 60 + picked.minute;
  }
}
