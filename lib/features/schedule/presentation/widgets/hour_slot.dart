import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/lessons/presentation/widgets/subject_icons.dart';
import 'package:smap/features/schedule/application/program_entry.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_focus_ring.dart';
import 'package:smap/shared/ui/buttons/app_icon_button.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';

/// One hour row of the grid step of a new program (C64 "HourSlot"; Tur 6;
/// pano 3.5 kare 2 "09:00 · 10:00 Türkçe Fiilde Çatı · 16:00 Konu Ekle").
///
/// A row at least 52 high, padding 2 / 12 / 2 / 16 (4 in the board; the empty
/// slot is 48 high instead of 44, a 48 pt target), 8 between its parts, with
/// a 1 pt rule under it. At the left the hour label (44 wide, 13/20 · 600
/// `textSecondary`, 12 from the top); next to it the slot:
///
/// - **empty** ([entries] empty): a transparent button, at least 48 high,
///   read as "09:00, boş, konu ekle". Tapping calls [onAdd]. With keyboard
///   focus it draws the "Konu Ekle" look: `infoBg` fill, a Plus 20 and the
///   label in `primary` (15/24 · 600) with the focus ring;
/// - **filled**: a tile in the lesson's tint (radius 12, padding 8 / 4 / 8 /
///   12, 10 between parts): the glyph 20, the lesson name 13 · 700 in the
///   lesson accent, the topic 15/22 · 600, and a remove button (X 18 in a
///   48 pt target, "{konu}, çıkar") when [onRemove] is given. A filled slot
///   appears over 250 ms (opacity only under "Reduce motion": 150 ms).
///
/// Several entries in one hour stack, 4 apart.
class HourSlot extends StatelessWidget {
  const HourSlot({
    required this.hour,
    this.entries = const [],
    this.onAdd,
    this.onRemove,
    this.showRule = true,
    super.key,
  });

  /// 0 to 23.
  final int hour;

  /// What is planned in this hour; empty makes an empty slot.
  final List<ProgramEntry> entries;

  /// An empty slot was tapped.
  final VoidCallback? onAdd;

  /// The remove button of a filled slot; null hides the button.
  final ValueChanged<ProgramEntry>? onRemove;

  /// The 1 pt rule under the row.
  final bool showRule;

  static const double _minHeight = 52;
  static const double _labelWidth = 44;
  static const double _labelTop = 14;

  /// The empty slot is a 48 pt target (the row keeps its 52: the padding
  /// above and below it is 2).
  static const double _emptyHeight = AppSize.touch;
  static const double _rowPadY = 2;
  static const double _glyph = 20;
  static const double _removeGlyph = 18;

  /// Between the glyph and the text of a filled slot (C64: 10) and between the
  /// Plus and the label of the focused empty slot (C64: 6).
  static const double _slotGap = 10;
  static const double _iconGap = 6;

  static const EdgeInsets _rowPadding = EdgeInsets.fromLTRB(
    AppSpacing.s16,
    _rowPadY,
    AppSpacing.s12,
    _rowPadY,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final dark = Theme.brightnessOf(context) == Brightness.dark;
    final time = TrFormat.saatParcali(hour);
    final rule = dark ? colors.borderSubtle : colors.bgSunken;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: showRule ? Border(bottom: BorderSide(color: rule)) : null,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _minHeight),
        child: Padding(
          padding: _rowPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                // The label column grows with the text, so "06:00" stays on
                // one line at large text sizes.
                width: MediaQuery.textScalerOf(context).scale(_labelWidth),
                child: Padding(
                  padding: const EdgeInsets.only(top: _labelTop),
                  child: ExcludeSemantics(
                    child: Text(
                      time,
                      maxLines: 1,
                      softWrap: false,
                      style: text.caption.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: entries.isEmpty
                    ? _EmptySlot(time: time, onAdd: onAdd)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final (i, entry) in entries.indexed) ...[
                            if (i > 0) const SizedBox(height: AppSpacing.s4),
                            _FilledSlot(
                              key: ValueKey<String>(entry.id),
                              time: time,
                              entry: entry,
                              onRemove: onRemove,
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.time, required this.onAdd});

  final String time;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      enabled: onAdd != null,
      label: l10n.schedule_emptySlotA11y(time),
      excludeSemantics: true,
      onTap: onAdd,
      child: AppPressable(
        onTap: onAdd,
        scale: 1,
        builder: (context, states) {
          final focused = states.contains(WidgetState.focused);
          final pressed = states.contains(WidgetState.pressed);
          return AppFocusRing(
            focused: focused,
            gapColor: colors.bgSurface,
            child: AnimatedContainer(
              duration: context.motion(
                AppMotion.instant,
                reduced: Duration.zero,
              ),
              constraints: const BoxConstraints(
                minHeight: HourSlot._emptyHeight,
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
              decoration: BoxDecoration(
                color: focused
                    ? colors.infoBg
                    : (pressed ? colors.bgCanvas : colors.bgSurface),
                borderRadius: AppRadius.borderMd,
              ),
              child: focused
                  ? Row(
                      children: [
                        PhosphorIcon(
                          PhosphorIconsRegular.plus,
                          size: AppSize.iconInButton,
                          color: colors.primary,
                        ),
                        const SizedBox(width: HourSlot._iconGap),
                        Text(
                          l10n.schedule_addTopic,
                          style: text.bodyStrong.copyWith(
                            color: colors.primary,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}

class _FilledSlot extends StatelessWidget {
  const _FilledSlot({
    required this.time,
    required this.entry,
    required this.onRemove,
    super.key,
  });

  final String time;
  final ProgramEntry entry;
  final ValueChanged<ProgramEntry>? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final subject = entry.subject;
    final SubjectTone? tone = subject == null
        ? null
        : context.appSubject(subject);
    final fill = tone?.bg ?? colors.bgSunken;
    final accent = tone?.fg ?? colors.textSecondary;
    final remove = onRemove;
    final reduced = context.reduceMotion;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: reduced ? AppMotion.reducedFade : AppMotion.base,
      curve: AppMotion.enter,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: reduced
            ? child
            : Transform.scale(scale: 0.96 + 0.04 * t, child: child),
      ),
      child: Semantics(
        container: true,
        label: l10n.schedule_filledSlotA11y(
          time,
          entry.lessonName,
          entry.title,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: AppRadius.borderMd,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s12,
              AppSpacing.s8,
              remove == null ? AppSpacing.s12 : AppSpacing.s4,
              AppSpacing.s8,
            ),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: PhosphorIcon(
                    subject == null
                        ? subjectFallbackIcon
                        : subjectIcons[subject]!,
                    size: HourSlot._glyph,
                    color: accent,
                  ),
                ),
                const SizedBox(width: HourSlot._slotGap),
                Expanded(
                  child: ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (entry.lessonName.isNotEmpty)
                          Text(
                            entry.lessonName,
                            style: text.caption.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w700,
                              height: 16 / 13,
                            ),
                          ),
                        Text(
                          entry.title,
                          style: text.bodyStrong.copyWith(
                            color: colors.textPrimary,
                            height: 22 / 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (remove != null)
                  AppIconButton(
                    icon: PhosphorIconsRegular.x,
                    iconSize: HourSlot._removeGlyph,
                    color: colors.textSecondary,
                    semanticLabel: l10n.schedule_removeSlotA11y(entry.title),
                    onPressed: () => remove(entry),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
