import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_shadows.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/smap_colors.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';
import 'package:smap/shared/ui/feedback/toast_slot.dart';

export 'package:smap/shared/ui/feedback/toast_slot.dart' show AppToastKind;

/// The toast body (C74 "Toast"; board 1.22 kare 1; 1.24 kare 5; UI guide §5
/// #27). Built by the toast host; use `ToastService`, not this widget.
///
/// An inverse surface (`inverseSurface`: navy in light, `#E8ECF1` in dark),
/// text 15/24 in `onInverseSurface`, minimum 48 high, 12/16 padding, radius
/// 12, the overlay shadow, a 20 pt Phosphor icon 12 before the text in the
/// kind's inverse color (info, success, error). With [onUndo] the toast holds
/// a "Geri Al" action: 48 high, 0/14 padding, 15 · 700, behind a hairline
/// (the toast's right padding is 4). While a screen reader is on
/// ([closeLabel] given) a 48 pt close button replaces the timer.
///
/// Announced as a live region ("Gönderilemedi. Bağlantını kontrol edip tekrar
/// dene.", "Kart Bildiklerim'e taşındı. Geri Al"). No emoji, no "Hata:"
/// prefix and no inner code in the text.
class AppToast extends StatelessWidget {
  const AppToast({
    required this.kind,
    required this.message,
    this.undoLabel,
    this.onUndo,
    this.closeLabel,
    this.onClose,
    super.key,
  });

  final AppToastKind kind;
  final String message;

  /// "Geri Al"; shown with [onUndo].
  final String? undoLabel;
  final VoidCallback? onUndo;

  /// Accessible name of the close button; non-null only while a screen
  /// reader is on.
  final String? closeLabel;
  final VoidCallback? onClose;

  /// Minimum height.
  static const double minHeight = 48;

  /// Icon edge.
  static const double iconSize = 20;

  Color _iconColor(SmapColors colors) => switch (kind) {
    AppToastKind.info => colors.inverseInfo,
    AppToastKind.success => colors.inverseSuccess,
    AppToastKind.error => colors.inverseError,
  };

  IconData get _icon => switch (kind) {
    AppToastKind.info => PhosphorIconsRegular.info,
    AppToastKind.success => PhosphorIconsRegular.checkCircle,
    AppToastKind.error => PhosphorIconsRegular.warningCircle,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final hasUndo = undoLabel != null && onUndo != null;
    final hasClose = closeLabel != null && onClose != null;
    return Semantics(
      container: true,
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.inverseSurface,
          borderRadius: AppRadius.borderMd,
          boxShadow: AppShadows.overlayOf(context),
        ),
        child: ClipRRect(
          borderRadius: AppRadius.borderMd,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: minHeight),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.s16,
                        AppSpacing.s12,
                        hasUndo || hasClose ? AppSpacing.s12 : AppSpacing.s16,
                        AppSpacing.s12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: ExcludeSemantics(
                              child: PhosphorIcon(
                                _icon,
                                size: iconSize,
                                color: _iconColor(colors),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          Expanded(
                            child: Text(
                              message,
                              style: text.body.copyWith(
                                color: colors.onInverseSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (hasUndo)
                    _UndoAction(label: undoLabel!, onPressed: onUndo!),
                  if (hasClose)
                    _CloseAction(label: closeLabel!, onPressed: onClose!),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Geri Al": the full-height action behind a hairline.
class _UndoAction extends StatelessWidget {
  const _UndoAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  /// Side padding of the action (C74: 14).
  static const double _side = 14;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: AppPressable(
        onTap: onPressed,
        scale: 1,
        builder: (context, states) => DecoratedBox(
          decoration: BoxDecoration(
            color: states.contains(WidgetState.pressed)
                ? colors.onInverseSurface.withValues(alpha: 0.12)
                : colors.inverseSurface.withValues(alpha: 0),
            border: Border(
              left: BorderSide(
                color: colors.onInverseSurface.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppToast.minHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _side),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  style: text.body.copyWith(
                    color: colors.onInverseSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The close button shown while a screen reader is on.
class _CloseAction extends StatelessWidget {
  const _CloseAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: AppPressable(
        onTap: onPressed,
        scale: 1,
        builder: (context, states) => SizedBox(
          width: AppSize.touch,
          child: Center(
            child: PhosphorIcon(
              PhosphorIconsRegular.x,
              size: AppToast.iconSize,
              color: colors.onInverseSurface,
            ),
          ),
        ),
      ),
    );
  }
}
