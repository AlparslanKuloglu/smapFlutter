import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/turkish_text.dart';
import 'package:smap/features/lessons/presentation/widgets/eksik_tag.dart';
import 'package:smap/features/lessons/application/topic_outline.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';

/// One work of an author in the author sheet (pano 14.6 kare 1 to 3, 14.7;
/// the stateful variant of the 7.4 work list, brief G).
///
/// The title 16/24 on the left, at least 52 high, padding 8 / 0. What is at
/// the right follows what the student knows:
///
/// - [ItemCardState.missing]: the amber [EksikTag] "Eksik" and the text button
///   "Öğrendim" (`textAction`; `textDisabled` while [onLearn] is null, which is
///   the offline state). With [offlineNote] the sentence "Öğrendim'i kaydetmek
///   için bağlantı gerekiyor." sits under the row, 13/20 `textSecondary`.
/// - [ItemCardState.learned]: a 16 pt check and "Biliyorsun" 13/20 · 700 in
///   `success`.
/// - [ItemCardState.unknown]: nothing but the title (T12.14; the old "?" icon
///   is gone).
///
/// When the state changes the right side cross-fades in 250 ms (150 ms under
/// "Reduce motion"). The row is read as one sentence: "İntibah, roman, eksik.
/// Öğrendim olarak işaretle." (the button's action), "Cezmi, roman, biliyorsun"
/// or just the title (and the type when it is known).
class WorkRow extends StatelessWidget {
  const WorkRow({
    required this.title,
    required this.state,
    this.typeName,
    this.onLearn,
    this.offlineNote = false,
    super.key,
  });

  final String title;
  final ItemCardState state;

  /// "Roman": read after the title; `null` for a type outside the table.
  final String? typeName;

  /// Marks the work learned; `null` disables the button.
  final VoidCallback? onLearn;

  /// Shows the offline sentence under the row (the first missing work only).
  final bool offlineNote;

  /// Minimum height of a row.
  static const double minHeight = 52;

  /// Edge of the check.
  static const double _check = 16;

  String _reading(AppLocalizations l10n) {
    final type = typeName == null ? null : TurkishText.lower(typeName!);
    return switch (state) {
      ItemCardState.missing =>
        type == null
            ? l10n.literature_workMissingNoTypeA11y(title)
            : l10n.literature_workMissingA11y(title, type),
      ItemCardState.learned =>
        type == null
            ? l10n.literature_workKnownNoTypeA11y(title)
            : l10n.literature_workKnownA11y(title, type),
      ItemCardState.unknown =>
        type == null ? title : l10n.literature_workUnknownA11y(title, type),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final fade = context.motion(AppMotion.base, reduced: AppMotion.reducedFade);
    final missing = state == ItemCardState.missing;
    return MergeSemantics(
      child: Semantics(
        label: _reading(l10n),
        button: missing && onLearn != null,
        onTap: missing ? onLearn : null,
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: minHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: text.bodyLg.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: fade,
                        switchInCurve: AppMotion.standard,
                        child: switch (state) {
                          ItemCardState.missing => _MissingEnd(
                            key: const ValueKey('missing'),
                            onLearn: onLearn,
                          ),
                          ItemCardState.learned => const _KnownEnd(
                            key: ValueKey('learned'),
                          ),
                          ItemCardState.unknown => const SizedBox.shrink(
                            key: ValueKey('unknown'),
                          ),
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (offlineNote && missing)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                  child: Text(
                    l10n.literature_offlineNote,
                    style: text.caption.copyWith(color: colors.textSecondary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The right side of a missing work: "Eksik" and the text button.
class _MissingEnd extends StatelessWidget {
  const _MissingEnd({required this.onLearn, super.key});

  final VoidCallback? onLearn;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: AppSpacing.s8),
        const EksikTag(),
        // The text button keeps its 12 pt side padding; the label itself
        // sits flush with the row's edge, like "Biliyorsun" (pano 14.6).
        Transform.translate(
          offset: const Offset(AppSpacing.s12, 0),
          child: AppButton(
            label: AppLocalizations.of(context).literature_learned,
            variant: AppButtonVariant.text,
            size: AppButtonSize.md40,
            onPressed: onLearn,
            focusGapColor: context.appColors.bgRaised,
          ),
        ),
      ],
    );
  }
}

/// The right side of a known work: the check and "Biliyorsun" in `success`.
class _KnownEnd extends StatelessWidget {
  const _KnownEnd({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: AppSpacing.s8),
        PhosphorIcon(
          PhosphorIconsBold.check,
          size: WorkRow._check,
          color: colors.success,
        ),
        const SizedBox(width: AppSpacing.s4),
        Text(
          AppLocalizations.of(context).literature_known,
          style: context.appText.caption.copyWith(
            color: colors.success,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
