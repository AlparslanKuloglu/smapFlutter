import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/exams/presentation/notification_primer/notification_primer.dart';
import 'package:smap/features/exams/presentation/notification_primer/notification_primer_permission.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// "Sonucun hazır olunca haber verelim mi?" (pano 5.2 kare 1; spec §4.D 5.2
/// `NotificationPrimerSheet`; Ek D-23).
///
/// A small sheet over the result moment: the handle, a centered block (28 / 24
/// / 0 padding) with a 64 pt `infoBg` circle holding a 32 pt Bell, the title
/// 20/28 · 700 (16 under the circle), "Sistemde olmayan bir denemeyi
/// okuttuğunda analizini hazırlayınca bildirim gönderelim. Hesap ›
/// Bildirimler'den istediğin zaman kapatabilirsin." 15/24 `textSecondary`
/// (8 under the title), and the two buttons: the primary "Bildirimlere İzin
/// Ver" and the quiet "Sonra". There is no close button and no haptic.
///
/// "Bildirimlere İzin Ver" opens the system dialog; the button shows its
/// spinner and the sheet stays (it cannot be dragged away) until the student
/// has answered the dialog, then the sheet closes (250 ms) and the caller goes
/// on. "Sonra", the scrim and the drag all just close it. The sheet returns
/// nothing: whatever the student chose, the flag that stops it from coming
/// back is the caller's (`NotificationPrimer`).
///
/// It is shown only while `FeatureFlags.notificationsEnabled` is on; until
/// the backend sends push the screen never opens it.
class NotificationPrimerSheet extends StatefulWidget {
  const NotificationPrimerSheet({required this.permission, super.key});

  /// The system dialog behind "Bildirimlere İzin Ver".
  final NotificationPrimerPermission permission;

  /// Opens the sheet and completes when it has closed. Without a
  /// [BuildContext] it opens on the router's root navigator.
  static Future<void> show({
    required NotificationPrimerPermission permission,
    BuildContext? context,
  }) => AppSheet.show<void>(
    context: context,
    builder: (_) => NotificationPrimerSheet(permission: permission),
  );

  /// The circle and the bell inside it (pano 5.2: 64 and 32).
  static const double _circle = 64;
  static const double _bell = 32;

  /// Padding above the block (pano 5.2 ".shh" 28 / 24 / 0).
  static const double _topPadding = 28;

  @override
  State<NotificationPrimerSheet> createState() =>
      _NotificationPrimerSheetState();
}

class _NotificationPrimerSheetState extends State<NotificationPrimerSheet> {
  bool _busy = false;

  Future<void> _allow() async {
    if (_busy) return;
    setState(() => _busy = true);
    await widget.permission.request();
    if (!mounted) return;
    // `pop`, not `maybePop`: while the dialog was open the frame was locked.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    return AppSheetFrame(
      semanticLabel: l10n.notificationPrimer_title,
      showClose: false,
      busy: _busy,
      bodyPadding: const EdgeInsets.fromLTRB(
        AppSpacing.s24,
        NotificationPrimerSheet._topPadding,
        AppSpacing.s24,
        0,
      ),
      body: Column(
        children: [
          ExcludeSemantics(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.infoBg,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: NotificationPrimerSheet._circle,
                child: Center(
                  child: PhosphorIcon(
                    PhosphorIconsRegular.bell,
                    size: NotificationPrimerSheet._bell,
                    color: colors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Semantics(
            header: true,
            child: Text(
              l10n.notificationPrimer_title,
              textAlign: TextAlign.center,
              style: text.titleMd.copyWith(color: colors.textPrimary),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            l10n.notificationPrimer_body,
            textAlign: TextAlign.center,
            style: text.body.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
      primary: AppSheetAction(
        label: l10n.notificationPrimer_allow,
        loading: _busy,
        onPressed: _allow,
      ),
      secondary: AppSheetAction(
        label: l10n.notificationPrimer_later,
        variant: AppButtonVariant.quiet,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
    );
  }
}

/// [NotificationPrimerPresenter] that opens the sheet on the root navigator
/// (the ViewModel has no context; `AppSheet.navigatorKey` is the router's).
class SheetNotificationPrimerPresenter implements NotificationPrimerPresenter {
  const SheetNotificationPrimerPresenter({
    this.permission = const PermissionHandlerPrimerPermission(),
  });

  final NotificationPrimerPermission permission;

  @override
  Future<void> show() => NotificationPrimerSheet.show(permission: permission);
}
