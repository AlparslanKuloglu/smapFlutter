import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_focus_ring.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';
import 'package:smap/shared/ui/controls/app_tag.dart';

/// One settings-style row (C17 "SettingsRow"; board 1.13 "Satır"; UI guide §5
/// #14; handoff 11.13 `SettingsRow`): leading icon, title, optional sub text,
/// and one right-hand element.
///
/// At least 56 high (72 with a [subtitle]), 12 / 16 padding, 12 between the
/// parts. The title is 16/24 · 600 `textPrimary`, the sub text 13/20
/// `textSecondary`, the value 15/24 `textSecondary`; the leading icon is 24
/// pt `textSecondary` (Phosphor Regular). The right-hand element is exactly
/// one of:
///
/// - a CaretRight 20 ([showArrow], the default of a tappable row);
/// - a [value] ("22:00–08:00"), with the arrow;
/// - a [trailing] widget (an `AppSwitch`, an `AppTag`); the row is then
///   usually toggled by [onTap] too;
/// - [external]: ArrowSquareOut 20 for a link that leaves the app;
/// - a [tag] text: an `AppTag` ("31 eksik"), with the arrow.
///
/// [danger] is the sign-out style row: `error` icon and title, no arrow, kept
/// in a group of its own, and read with "onay ister" because it opens a
/// confirmation. Pressed: a `bgSunken` wash over the row (the group clips
/// it). Read as one item: "Bildirimler, Deneme sonucu, koç, düğme".
class AppRow extends StatelessWidget {
  const AppRow({
    required this.title,
    this.subtitle,
    this.icon,
    this.leading,
    this.value,
    this.tag,
    this.trailing,
    this.onTap,
    this.showArrow,
    this.external = false,
    this.danger = false,
    super.key,
  });

  final String title;
  final String? subtitle;

  /// Leading Phosphor icon, 24 pt (`PhosphorIconsRegular.user`).
  final IconData? icon;

  /// A widget in place of [icon]: an avatar or a subject tile.
  final Widget? leading;

  /// The current value ("22:00–08:00").
  final String? value;

  /// An `AppTag` label ("31 eksik").
  final String? tag;

  /// A control or any widget at the right; replaces the arrow.
  final Widget? trailing;

  /// Null makes the row static (not a button).
  final VoidCallback? onTap;

  /// Forces the arrow on or off; by default a tappable row without a
  /// [trailing] widget, an [external] mark or [danger] shows it.
  final bool? showArrow;

  /// The link leaves the app: ArrowSquareOut instead of the arrow.
  final bool external;
  final bool danger;

  /// Whether the row starts with an icon or a leading widget; the group draws
  /// its rule from the text start only then.
  bool get hasLeading => icon != null || leading != null;

  /// Left of the text in a row with a leading element: 16 padding + 24 icon
  /// + 12 gap (C17 "soldan 52").
  static const double textInset = AppSpacing.s16 + 24 + AppSpacing.s12;

  bool get _arrow =>
      showArrow ?? (onTap != null && trailing == null && !external && !danger);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final ink = danger ? colors.error : colors.textPrimary;
    final soft = danger ? colors.error : colors.textSecondary;
    final enabled = onTap != null;

    final row = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: subtitle == null ? AppSize.rowMin : AppSize.rowMinTwoLine,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s12,
        ),
        child: Row(
          children: [
            if (leading case final lead?) ...[
              lead,
              const SizedBox(width: AppSpacing.s12),
            ] else if (icon case final glyph?) ...[
              PhosphorIcon(glyph, size: AppSize.icon, color: soft),
              const SizedBox(width: AppSpacing.s12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: text.titleSm.copyWith(color: ink)),
                  if (subtitle case final sub?)
                    Text(
                      sub,
                      style: text.caption.copyWith(color: colors.textSecondary),
                    ),
                ],
              ),
            ),
            if (value case final current?) ...[
              const SizedBox(width: AppSpacing.s12),
              Flexible(
                child: Text(
                  current,
                  textAlign: TextAlign.end,
                  style: text.body.copyWith(color: colors.textSecondary),
                ),
              ),
            ],
            if (tag case final label?) ...[
              const SizedBox(width: AppSpacing.s12),
              AppTag(label: label),
            ],
            if (trailing case final control?) ...[
              const SizedBox(width: AppSpacing.s12),
              control,
            ],
            if (external) ...[
              const SizedBox(width: AppSpacing.s12),
              PhosphorIcon(
                PhosphorIconsRegular.arrowSquareOut,
                size: AppSize.iconInButton,
                color: colors.textSecondary,
              ),
            ],
            if (_arrow) ...[
              const SizedBox(width: AppSpacing.s8),
              PhosphorIcon(
                PhosphorIconsRegular.caretRight,
                size: AppSize.iconInButton,
                color: colors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );

    return MergeSemantics(
      child: Semantics(
        button: enabled,
        hint: danger ? l10n.kit_a11yAsksConfirmation : null,
        child: enabled
            ? AppPressable(
                onTap: onTap,
                scale: 1,
                builder: (context, states) => AppFocusRing(
                  focused: states.contains(WidgetState.focused),
                  style: AppFocusRingStyle.inset,
                  borderRadius: BorderRadius.zero,
                  child: AnimatedContainer(
                    duration: context.motion(
                      AppMotion.instant,
                      reduced: Duration.zero,
                    ),
                    color: states.contains(WidgetState.pressed)
                        ? colors.bgSunken
                        : colors.bgSurface,
                    child: row,
                  ),
                ),
              )
            : row,
      ),
    );
  }
}
