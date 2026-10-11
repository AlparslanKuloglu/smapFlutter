import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/lessons/presentation/widgets/subject_glyph.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_focus_ring.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';
import 'package:smap/shared/ui/surfaces/app_row_shell.dart';

/// Whether a program row is read or edited.
enum ProgramItemMode {
  /// Today's plan and the weekly view: the row opens the topic.
  view,

  /// Editing a day (screen 3.6): the time and a remove button are actions.
  edit,
}

/// One planned topic of a day (C30 "ProgramItemRow"; Tur 6; screens 3.1 to
/// 3.3 "Bugün", 3.6 "Günü düzenle").
///
/// Padding top 10, right 12, bottom 10, left 16; at least 64 high; 12 between
/// the parts. Left to right: the time 15/24 · 600 (`bodyStrong`, tabular, at
/// least 48 wide, "10:00"), the 36 pt [SubjectGlyph] (glyph 19), the text
/// column (the subject 13/20 `textSecondary` over the topic 16/24 · 600, which
/// wraps) and the end element. The rule between rows is drawn by the group.
///
/// **[ProgramItemMode.view]**: the end element is CaretRight 20 and the row
/// opens the topic. Read as "10:00, Türkçe, Fiilde Çatı".
///
/// **[ProgramItemMode.edit]**: the row is not a button. The time becomes an
/// underlined `textAction` text button that opens the time wheel ("Saat 10:00,
/// değiştir"); the end element is a remove button, a 32 pt `bgSunken` circle
/// with X 16 inside a 48 pt target ("Fiilde Çatı, programdan çıkar"). Removing
/// slides the row out (250 ms) and the screen shows the "Geri Al" toast.
class ProgramItemRow extends StatelessWidget {
  const ProgramItemRow({
    required this.hour,
    required this.minute,
    required this.subjectName,
    required this.topic,
    required this.subject,
    this.mode = ProgramItemMode.view,
    this.onTap,
    this.onTimeTap,
    this.onRemove,
    super.key,
  });

  /// 0 to 23.
  final int hour;

  /// 0 to 59.
  final int minute;

  /// "Türkçe".
  final String subjectName;

  /// "Fiilde Çatı".
  final String topic;

  /// The subject color; null draws a neutral tile.
  final SubjectKey? subject;
  final ProgramItemMode mode;

  /// View: opens the topic.
  final VoidCallback? onTap;

  /// Edit: opens the time wheel.
  final VoidCallback? onTimeTap;

  /// Edit: removes the item from the program.
  final VoidCallback? onRemove;

  bool get _editing => mode == ProgramItemMode.edit;

  /// Minimum height of the row.
  static const double minHeight = 64;

  /// Minimum width of the time.
  static const double _timeWidth = 48;

  /// Padding of the row: top 10, right 12, bottom 10, left 16.
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(
    AppSpacing.s16,
    10,
    AppSpacing.s12,
    10,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final time = TrFormat.saatParcali(hour, minute);
    final timeStyle = text.bodyStrong.copyWith(color: colors.textPrimary);

    final Widget timeWidget = _editing
        ? _TimeButton(time: time, onTap: onTimeTap)
        : ConstrainedBox(
            constraints: const BoxConstraints(minWidth: _timeWidth),
            child: Text(time, style: timeStyle),
          );
    final label = [time, subjectName, topic].join(', ');

    final row = AppRowShell(
      onTap: _editing ? null : onTap,
      padding: _padding,
      minHeight: minHeight,
      child: Row(
        children: [
          timeWidget,
          const SizedBox(width: AppSpacing.s12),
          SubjectGlyph(subject: subject, size: SubjectGlyphSize.program),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: ExcludeSemantics(
              excluding: !_editing,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subjectName,
                    style: text.caption.copyWith(color: colors.textSecondary),
                  ),
                  Text(
                    topic,
                    style: text.titleSm.copyWith(color: colors.textPrimary),
                  ),
                ],
              ),
            ),
          ),
          if (_editing)
            _RemoveButton(topic: topic, onTap: onRemove)
          else ...[
            const SizedBox(width: AppSpacing.s8),
            PhosphorIcon(
              PhosphorIconsRegular.caretRight,
              size: AppSize.iconInButton,
              color: colors.textSecondary,
            ),
          ],
        ],
      ),
    );

    if (_editing) return row;
    return Semantics(
      button: onTap != null,
      onTap: onTap,
      label: label,
      excludeSemantics: true,
      child: row,
    );
  }
}

/// The time of an item in edit mode: an underlined text button.
class _TimeButton extends StatelessWidget {
  const _TimeButton({required this.time, required this.onTap});

  final String time;
  final VoidCallback? onTap;

  static const double _minWidth = 48;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      button: true,
      onTap: onTap,
      label: AppLocalizations.of(context).schedule_changeTimeA11y(time),
      excludeSemantics: true,
      child: AppPressable(
        onTap: onTap,
        builder: (context, states) => AppFocusRing(
          focused: states.contains(WidgetState.focused),
          style: AppFocusRingStyle.flush,
          borderRadius: AppRadius.borderXs,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: _minWidth,
              minHeight: AppSize.touch,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                time,
                style: context.appText.bodyStrong.copyWith(
                  color: colors.textAction,
                  decoration: TextDecoration.underline,
                  decorationColor: colors.textAction,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The remove button of an item in edit mode: a 32 pt circle with X 16 in a
/// 48 pt target.
class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.topic, required this.onTap});

  final String topic;
  final VoidCallback? onTap;

  static const double _circle = 32;
  static const double _glyph = 16;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final label = AppLocalizations.of(context).schedule_removeA11y(topic);
    return Semantics(
      button: true,
      onTap: onTap,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        excludeFromSemantics: true,
        child: AppPressable(
          onTap: onTap,
          builder: (context, states) => SizedBox.square(
            dimension: AppSize.touch,
            child: Center(
              child: AppFocusRing(
                focused: states.contains(WidgetState.focused),
                borderRadius: AppRadius.borderFull,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: states.contains(WidgetState.pressed)
                        ? colors.borderSubtle
                        : colors.bgSunken,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox.square(
                    dimension: _circle,
                    child: Center(
                      child: PhosphorIcon(
                        PhosphorIconsRegular.x,
                        size: _glyph,
                        color: colors.textPrimary,
                      ),
                    ),
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
