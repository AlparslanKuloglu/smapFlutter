import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_focus_ring.dart';
import 'package:smap/shared/ui/buttons/app_icon_button.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';
import 'package:smap/shared/ui/pickers/calendar_math.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';

/// The month calendar for picking several days (C65 "Calendar"; Tur 6 G6;
/// pano 3.5 kare 1).
///
/// A card with 8 / 8 / 12 padding. The header holds the "Önceki ay" and
/// "Sonraki ay" buttons (48, CaretLeft / CaretRight 22) around the month name
/// (`headline` 17/24 · 700, "Ekim 2026"). Under it a Monday-first grid of 7
/// columns: a 24 high weekday row (13/20 `textSecondary`) and day cells 46 x
/// 46, radius 12, 16/24 · 600, 4 pt apart.
///
/// - **past** days (before [firstSelectable]) are `textDisabled` at 500 and
///   cannot be picked, but stay readable;
/// - **selected** days are `primary` with `onPrimary` text;
/// - **today** has a 2 pt `accentLine` ring inside the cell (also while it is
///   selected).
///
/// Several days are picked by tapping each one ([onToggle]); a range is not
/// required. Each tap plays `AppHaptics.selection()`. The previous-month
/// button is disabled on the first month that has a selectable day. The month
/// shown is the calendar's own state ([initialMonth]); [onMonthChanged]
/// reports a change. Cells read as "12 Ekim 2026 Pazartesi, bugün".
class AppCalendar extends StatefulWidget {
  const AppCalendar({
    required this.selected,
    required this.onToggle,
    required this.today,
    DateTime? firstSelectable,
    DateTime? initialMonth,
    this.onMonthChanged,
    super.key,
  }) : firstSelectable = firstSelectable ?? today,
       initialMonth = initialMonth ?? today;

  /// The picked days (calendar days; the time part is ignored).
  final Set<DateTime> selected;

  /// A selectable day was tapped.
  final ValueChanged<DateTime> onToggle;

  /// The day with the orange ring.
  final DateTime today;

  /// The first day that can be picked; every earlier day is past. Defaults to
  /// [today].
  final DateTime firstSelectable;

  /// The month shown first. Defaults to the month of [today].
  final DateTime initialMonth;

  /// The visible month changed (the first day of that month).
  final ValueChanged<DateTime>? onMonthChanged;

  /// Cell edge (C65).
  static const double cellSize = 46;

  /// Space between cells and rows (C65).
  static const double cellGap = AppSpacing.s4;

  /// Height of the weekday row (C65).
  static const double weekdayRowHeight = 24;

  /// Card padding: 8 at the sides and the top, 12 at the bottom (C65).
  static const EdgeInsets padding = EdgeInsets.fromLTRB(
    AppSpacing.s8,
    AppSpacing.s8,
    AppSpacing.s8,
    AppSpacing.s12,
  );

  @override
  State<AppCalendar> createState() => _AppCalendarState();
}

class _AppCalendarState extends State<AppCalendar> {
  late DateTime _month = CalendarMath.monthStart(widget.initialMonth);

  DateTime get _firstMonth => CalendarMath.monthStart(widget.firstSelectable);

  bool get _canGoBack => _month.isAfter(_firstMonth);

  void _move(int delta) {
    setState(() => _month = CalendarMath.addMonths(_month, delta));
    widget.onMonthChanged?.call(_month);
  }

  bool _isSelected(DateTime day) =>
      widget.selected.any((picked) => CalendarMath.sameDay(picked, day));

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final title = l10n.pickers_monthTitle(
      TrFormat.months[_month.month - 1],
      '${_month.year}',
    );

    return AppCard(
      padding: AppCalendar.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              AppIconButton(
                icon: PhosphorIconsRegular.caretLeft,
                iconSize: 22,
                semanticLabel: l10n.pickers_prevMonth,
                onPressed: _canGoBack ? () => _move(-1) : null,
              ),
              Expanded(
                child: Semantics(
                  header: true,
                  liveRegion: true,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: text.headline.copyWith(color: colors.textPrimary),
                  ),
                ),
              ),
              AppIconButton(
                icon: PhosphorIconsRegular.caretRight,
                iconSize: 22,
                semanticLabel: l10n.pickers_nextMonth,
                onPressed: () => _move(1),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          ExcludeSemantics(
            child: SizedBox(
              height: AppCalendar.weekdayRowHeight,
              child: Row(
                children: [
                  for (final name in TrFormat.weekdaysShort)
                    Expanded(
                      child: Center(
                        child: Text(
                          name,
                          maxLines: 1,
                          style: text.caption.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          for (var row = 0; row < CalendarMath.rowCount(_month); row++) ...[
            const SizedBox(height: AppCalendar.cellGap),
            Row(
              children: [
                for (var column = 0; column < 7; column++)
                  Expanded(
                    child: _DayCell(
                      day: CalendarMath.cellDay(_month, row, column),
                      today: widget.today,
                      selected: _isDaySelected(row, column),
                      past: _isPast(row, column),
                      onTap: widget.onToggle,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  bool _isDaySelected(int row, int column) {
    final day = CalendarMath.cellDay(_month, row, column);
    return day != null && _isSelected(day);
  }

  bool _isPast(int row, int column) {
    final day = CalendarMath.cellDay(_month, row, column);
    return day != null && CalendarMath.isBeforeDay(day, widget.firstSelectable);
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.today,
    required this.selected,
    required this.past,
    required this.onTap,
  });

  final DateTime? day;
  final DateTime today;
  final bool selected;
  final bool past;
  final ValueChanged<DateTime> onTap;

  /// The ring of today (C65: inset 2).
  static const double _ring = 2;

  @override
  Widget build(BuildContext context) {
    final date = day;
    if (date == null) {
      return const SizedBox(height: AppCalendar.cellSize);
    }
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final isToday = CalendarMath.sameDay(date, today);
    final enabled = !past;
    final ink = selected
        ? colors.onPrimary
        : (past ? colors.textDisabled : colors.textPrimary);
    final label = [
      TrFormat.uzunTarihGun(date),
      if (isToday) l10n.pickers_a11yToday,
    ].join(', ');

    return Center(
      child: Semantics(
        button: true,
        enabled: enabled,
        selected: selected,
        label: label,
        excludeSemantics: true,
        onTap: enabled ? () => onTap(date) : null,
        child: AppPressable(
          onTap: enabled ? () => onTap(date) : null,
          haptic: true,
          builder: (context, states) {
            final pressed = states.contains(WidgetState.pressed);
            final Color fill;
            if (selected) {
              fill = pressed ? colors.primaryPressed : colors.primary;
            } else {
              fill = pressed ? colors.bgSunken : colors.bgSurface;
            }
            return AppFocusRing(
              focused: states.contains(WidgetState.focused),
              child: AnimatedContainer(
                duration: context.motion(
                  AppMotion.instant,
                  reduced: Duration.zero,
                ),
                width: AppCalendar.cellSize,
                height: AppCalendar.cellSize,
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: AppRadius.borderMd,
                ),
                foregroundDecoration: isToday
                    ? BoxDecoration(
                        borderRadius: AppRadius.borderMd,
                        border: Border.all(
                          color: colors.accentLine,
                          width: _ring,
                        ),
                      )
                    : null,
                alignment: Alignment.center,
                child: Text(
                  '${date.day}',
                  maxLines: 1,
                  style: text.bodyLg.copyWith(
                    color: ink,
                    fontWeight: past ? FontWeight.w500 : FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The legend under the calendar (C65 "Lejant"; pano 3.5 kare 1): a 20 x 20
/// swatch, radius 6, with the 2 pt orange ring of today, and "Bugün" 13/20.
class AppCalendarLegend extends StatelessWidget {
  const AppCalendarLegend({super.key});

  /// Swatch edge, its radius and its ring (C65).
  static const double swatch = 20;
  static const double _swatchRadius = 6;
  static const double _ring = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(_swatchRadius),
              ),
              border: Border.all(color: colors.accentLine, width: _ring),
            ),
            child: const SizedBox.square(dimension: swatch),
          ),
          const SizedBox(width: AppSpacing.s8),
          Text(
            AppLocalizations.of(context).pickers_today,
            style: context.appText.caption.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
