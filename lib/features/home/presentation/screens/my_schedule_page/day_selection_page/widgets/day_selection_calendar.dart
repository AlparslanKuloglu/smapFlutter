import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smap/core/theme/app_colors.dart';

class DaySelectionCalendar extends StatefulWidget {
  const DaySelectionCalendar({
    super.key,
    required this.selectedDays,
    required this.onDayToggled,
  });

  final Set<DateTime> selectedDays;
  final ValueChanged<DateTime> onDayToggled;

  @override
  State<DaySelectionCalendar> createState() => _DaySelectionCalendarState();
}

class _DaySelectionCalendarState extends State<DaySelectionCalendar> {
  static const _dayShort = ['Pt', 'Sal', 'Çar', 'Per', 'Cu', 'Cmt', 'Paz'];
  static const _rowHeight = 72.0;
  static const _rowGap = 8.0;

  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  DateTime _dateKey(DateTime date) => DateTime(date.year, date.month, date.day);

  List<DateTime> _cellsForMonth(DateTime monthStart) {
    final y = monthStart.year;
    final m = monthStart.month;
    final first = DateTime(y, m, 1);
    final daysInMonth = DateTime(y, m + 1, 0).day;
    final daysInPrev = DateTime(y, m, 0).day;
    final leading = first.weekday - 1;

    final cells = <DateTime>[];
    for (var i = 0; i < leading; i++) {
      cells.add(DateTime(y, m - 1, daysInPrev - leading + i + 1));
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(y, m, d));
    }
    var next = 1;
    while (cells.length % 7 != 0) {
      cells.add(DateTime(y, m + 1, next++));
    }
    return cells;
  }

  void _toggleDay(DateTime day) => widget.onDayToggled(_dateKey(day));

  @override
  Widget build(BuildContext context) {
    final monthRaw = DateFormat('MMMM', 'tr_TR').format(_focusedMonth);
    final monthTitle = monthRaw.isEmpty
        ? monthRaw
        : '${monthRaw[0].toUpperCase()}${monthRaw.substring(1)}';
    final cells = _cellsForMonth(_focusedMonth);
    final rows = cells.length ~/ 7;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MonthArrow(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => setState(() {
                    _focusedMonth = DateTime(
                      _focusedMonth.year,
                      _focusedMonth.month - 1,
                    );
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '$monthTitle ${_focusedMonth.year}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _MonthArrow(
                  icon: Icons.chevron_right_rounded,
                  onTap: () => setState(() {
                    _focusedMonth = DateTime(
                      _focusedMonth.year,
                      _focusedMonth.month + 1,
                    );
                  }),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: Column(
              children: [
                Row(
                  children: _dayShort
                      .map(
                        (day) => Expanded(
                          child: Text(
                            day,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                for (var row = 0; row < rows; row++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: row < rows - 1 ? _rowGap : 0,
                    ),
                    child: SizedBox(
                      height: _rowHeight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(7, (col) {
                          final date = cells[row * 7 + col];
                          final inMonth = date.month == _focusedMonth.month;
                          final selected = widget.selectedDays.contains(
                            _dateKey(date),
                          );

                          return Expanded(
                            child: _CalendarDayCell(
                              day: date.day,
                              inMonth: inMonth,
                              selected: selected,
                              onTap: inMonth ? () => _toggleDay(date) : null,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.day,
    required this.inMonth,
    required this.selected,
    this.onTap,
  });

  final int day;
  final bool inMonth;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? AppColors.navSelectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: selected
                    ? DecoratedBox(
                        decoration: const BoxDecoration(
                          color: AppColors.primaryOrange,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: inMonth
                                ? AppColors.textPrimary
                                : const Color(0xFFB8C0CC),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 22,
                child: selected
                    ? const Icon(
                        Icons.add_rounded,
                        size: 22,
                        color: AppColors.primaryOrange,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthArrow extends StatelessWidget {
  const _MonthArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 22, color: AppColors.textPrimary),
      ),
    );
  }
}
