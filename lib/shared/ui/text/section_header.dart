import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';

/// The title of a screen section (C19 "SectionHeader"; Tur 6 G2; screens 3.1
/// to 3.3 and 10.1; UI guide §5 #21).
///
/// [title] is 20/28 · 700 · −0,2 (`titleMd`) and read as a heading. The
/// optional [meta] is 13/20 `textSecondary` 2 below it. At most one text
/// button sits on the right ([actionLabel], 40 high, pulled 12 to the edge so
/// its label meets the page margin: "Programım", or "Öğrenci Ekle" with
/// [actionIcon] Plus). There is no "card + title + Tümü ›" pattern: a section
/// does not get an "all" link just to have one.
///
/// Sections are 28 apart (the caller's gap) and the content starts 12 below the
/// header ([padding] bottom).
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.meta,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    this.padding = const EdgeInsets.only(bottom: AppSpacing.s12),
    super.key,
  });

  final String title;

  /// "3 sınav".
  final String? meta;

  /// The right-hand text button ("Programım").
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Leading Phosphor icon of the action (`PhosphorIconsRegular.plus`).
  final IconData? actionIcon;
  final EdgeInsetsGeometry padding;

  /// The action is pulled this far toward the edge so its label, not its
  /// padding, meets the margin (C19: -12).
  static const double actionBleed = 12;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: text.titleMd.copyWith(color: colors.textPrimary),
                  ),
                ),
                if (meta case final note?) ...[
                  const SizedBox(height: 2),
                  Text(
                    note,
                    style: text.caption.copyWith(color: colors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel case final label?)
            Transform.translate(
              offset: const Offset(actionBleed, 0),
              child: AppButton(
                label: label,
                onPressed: onAction,
                variant: AppButtonVariant.text,
                size: AppButtonSize.md40,
                icon: actionIcon,
              ),
            ),
        ],
      ),
    );
  }
}
