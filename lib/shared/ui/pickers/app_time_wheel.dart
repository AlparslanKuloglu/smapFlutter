import 'package:flutter/material.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/pickers/time_wheel_math.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// The hour and minute wheels (C66 "TimeWheel"; board 9.6 "Sessiz saat"; UI
/// guide §5 #36).
///
/// Two looping columns, hours 0 to 23 and minutes in 5 steps, 48 pt apart with
/// a 24 · 700 ":" between them. Five rows are visible, each row 40 pt high
/// with 4 pt between rows. The picked row is 24/40 · 700 in `textPrimary`;
/// the others 20/40 · 500 in `textDisabled`. A 44 pt `bgSunken` band with
/// radius 12 runs behind the picked row, full width with 24 pt margins. A
/// notch plays `AppHaptics.selection()`.
///
/// For a screen reader each wheel is one adjustable element ("Saat",
/// "Dakika"); swiping up or down moves it by one notch (5 minutes on the
/// minute wheel, carrying into the hour). Use [AppTimeWheelSheet.show] to pick
/// a time in a sheet.
class AppTimeWheel extends StatefulWidget {
  const AppTimeWheel({
    required this.value,
    required this.onChanged,
    this.minuteStep = TimeWheelMath.minuteStep,
    super.key,
  });

  /// The shown time. A minute that is not on the step snaps down to it.
  final TimeOfDay value;
  final ValueChanged<TimeOfDay> onChanged;
  final int minuteStep;

  /// Row height and gap (C66).
  static const double rowHeight = 40;
  static const double rowGap = 4;

  /// Visible rows.
  static const int visibleRows = 5;

  /// Selection band height.
  static const double bandHeight = 44;

  /// Space between the columns.
  static const double columnGap = 48;

  @override
  State<AppTimeWheel> createState() => _AppTimeWheelState();
}

class _AppTimeWheelState extends State<AppTimeWheel> {
  late final FixedExtentScrollController _hours;
  late final FixedExtentScrollController _minutes;
  late int _hour;
  late int _minute;

  /// The looping lists start in the middle of a large range so both
  /// directions can scroll.
  static const int _loops = 100;

  @override
  void initState() {
    super.initState();
    _hour = TimeWheelMath.clampHour(widget.value.hour);
    _minute = TimeWheelMath.snapMinute(
      widget.value.minute,
      step: widget.minuteStep,
    );
    _hours = FixedExtentScrollController(
      initialItem: _loops * TimeWheelMath.hoursPerDay + _hour,
    );
    _minutes = FixedExtentScrollController(
      initialItem:
          _loops * TimeWheelMath.minuteCount(step: widget.minuteStep) +
          TimeWheelMath.minuteIndex(_minute, step: widget.minuteStep),
    );
  }

  @override
  void dispose() {
    _hours.dispose();
    _minutes.dispose();
    super.dispose();
  }

  void _emit() => widget.onChanged(TimeOfDay(hour: _hour, minute: _minute));

  void _hourChanged(int index) {
    final hour = TimeWheelMath.hourAt(index);
    if (hour == _hour) return;
    AppHaptics.selection();
    setState(() => _hour = hour);
    _emit();
  }

  void _minuteChanged(int index) {
    final minute = TimeWheelMath.minuteAt(index, step: widget.minuteStep);
    if (minute == _minute) return;
    AppHaptics.selection();
    setState(() => _minute = minute);
    _emit();
  }

  /// Screen reader increase / decrease: one notch on the wheel that was
  /// swiped; on the minute wheel it carries into the hour.
  void _nudge(int notches, {required bool onMinutes}) {
    if (!onMinutes) {
      _hours.jumpToItem(_hours.selectedItem + notches);
      return;
    }
    final next = TimeWheelMath.nudge(
      _hour,
      _minute,
      notches: notches,
      step: widget.minuteStep,
    );
    final hourMove = TimeWheelMath.shortestHourMove(_hour, next.hour);
    if (hourMove != 0) _hours.jumpToItem(_hours.selectedItem + hourMove);
    _minutes.jumpToItem(_minutes.selectedItem + notches);
  }

  /// The time a swipe of [notches] would reach, for the screen reader.
  String _reading(int notches, {required bool onMinutes}) {
    if (!onMinutes) {
      return TrFormat.saatParcali(
        TimeWheelMath.hourAt(_hour + notches),
        _minute,
      );
    }
    final next = TimeWheelMath.nudge(
      _hour,
      _minute,
      notches: notches,
      step: widget.minuteStep,
    );
    return TrFormat.saatParcali(next.hour, next.minute);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    const rowExtent = AppTimeWheel.rowHeight + AppTimeWheel.rowGap;
    const height = rowExtent * AppTimeWheel.visibleRows;
    final minuteValues = TimeWheelMath.minutes(step: widget.minuteStep);

    Widget wheel({
      required FixedExtentScrollController controller,
      required List<int> values,
      required int selected,
      required ValueChanged<int> onChanged,
      required String label,
      required bool onMinutes,
    }) {
      return Expanded(
        child: Semantics(
          label: label,
          value: TrFormat.saatParcali(_hour, _minute),
          increasedValue: _reading(1, onMinutes: onMinutes),
          decreasedValue: _reading(-1, onMinutes: onMinutes),
          onIncrease: () => _nudge(1, onMinutes: onMinutes),
          onDecrease: () => _nudge(-1, onMinutes: onMinutes),
          excludeSemantics: true,
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: rowExtent,
            diameterRatio: 100,
            perspective: 0.0001,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildLoopingListDelegate(
              children: [
                for (final value in values)
                  Center(
                    child: Text(
                      value.toString().padLeft(2, '0'),
                      style: value == selected
                          ? text.metricMd.copyWith(
                              color: colors.textPrimary,
                              height:
                                  AppTimeWheel.rowHeight /
                                  text.metricMd.fontSize!,
                            )
                          : text.titleMd.copyWith(
                              color: colors.textDisabled,
                              fontWeight: FontWeight.w500,
                              height:
                                  AppTimeWheel.rowHeight /
                                  text.titleMd.fontSize!,
                            ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.bgSunken,
                borderRadius: AppRadius.borderMd,
              ),
              child: const SizedBox(
                width: double.infinity,
                height: AppTimeWheel.bandHeight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
            child: Row(
              children: [
                wheel(
                  controller: _hours,
                  values: [
                    for (var h = 0; h < TimeWheelMath.hoursPerDay; h++) h,
                  ],
                  selected: _hour,
                  onChanged: _hourChanged,
                  label: l10n.kit2_a11yTimeWheelHour,
                  onMinutes: false,
                ),
                SizedBox(
                  width: AppTimeWheel.columnGap,
                  child: ExcludeSemantics(
                    child: Center(
                      child: Text(
                        ':',
                        style: text.metricMd.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                wheel(
                  controller: _minutes,
                  values: minuteValues,
                  selected: _minute,
                  onChanged: _minuteChanged,
                  label: l10n.kit2_a11yTimeWheelMinute,
                  onMinutes: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A time picked in a sheet (C66 "Sheet"; board 9.6 "Sessiz saat
/// başlangıcı"): a title and "Kapat", the [AppTimeWheel], and the primary
/// "Kaydet". Completes with the chosen [TimeOfDay], or `null` when the sheet
/// was dismissed.
class AppTimeWheelSheet extends StatefulWidget {
  const AppTimeWheelSheet._({
    required this.title,
    required this.saveLabel,
    required this.initial,
    required this.minuteStep,
  });

  final String title;
  final String saveLabel;
  final TimeOfDay initial;
  final int minuteStep;

  /// Opens the sheet on [initial]. [title] is the setting's name ("Sessiz
  /// saat başlangıcı"), [saveLabel] the primary label ("Kaydet").
  static Future<TimeOfDay?> show({
    required String title,
    required String saveLabel,
    required TimeOfDay initial,
    BuildContext? context,
    int minuteStep = TimeWheelMath.minuteStep,
  }) => AppSheet.show<TimeOfDay>(
    context: context,
    builder: (_) => AppTimeWheelSheet._(
      title: title,
      saveLabel: saveLabel,
      initial: initial,
      minuteStep: minuteStep,
    ),
  );

  @override
  State<AppTimeWheelSheet> createState() => _AppTimeWheelSheetState();
}

class _AppTimeWheelSheetState extends State<AppTimeWheelSheet> {
  late TimeOfDay _picked = TimeOfDay(
    hour: widget.initial.hour,
    minute: TimeWheelMath.snapMinute(
      widget.initial.minute,
      step: widget.minuteStep,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AppSheetFrame(
      title: widget.title,
      bodyPadding: const EdgeInsets.only(top: AppSpacing.s16),
      body: AppTimeWheel(
        value: _picked,
        minuteStep: widget.minuteStep,
        onChanged: (value) => _picked = value,
      ),
      primary: AppSheetAction(
        label: widget.saveLabel,
        onPressed: () => Navigator.of(context).pop(_picked),
      ),
    );
  }
}
