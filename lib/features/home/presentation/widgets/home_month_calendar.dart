import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:studentmap/core/theme/app_colors.dart';
import 'package:studentmap/features/home/presentation/provider/home_provider.dart';

const Color _kMutedCalendarDay = Color(0xFFB8C0CC);

/// Ders kartlarının altındaki aylık takvim; bugün vurgulanır.
class HomeMonthCalendar extends StatelessWidget {
  const HomeMonthCalendar({super.key});

  static const List<String> _dayShort = [
    'Pt',
    'Sal',
    'Çar',
    'Per',
    'Cu',
    'Cmt',
    'Paz',
  ];

  static const Color _gridLine = Color(0xFFEDEFF2);
  static const Color _headerBg = Color(0xFFF5F6F8);

  List<DateTime> _cellsForMonth(DateTime monthStart) {
    final y = monthStart.year;
    final m = monthStart.month;
    final first = DateTime(y, m, 1);
    final daysInMonth = DateTime(y, m + 1, 0).day;
    final daysInPrev = DateTime(y, m, 0).day;
    final leading = first.weekday - 1;

    final cells = <DateTime>[];
    for (var i = 0; i < leading; i++) {
      final d = daysInPrev - leading + i + 1;
      cells.add(DateTime(y, m - 1, d));
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(y, m, d));
    }
    var next = 1;
    while (cells.length % 7 != 0) {
      cells.add(DateTime(y, m + 1, next));
      next++;
    }
    return cells;
  }

  bool _sameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  bool _isToday(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, _) {
        final state = homeProvider.state;
        final focusedMonth = state.focusedMonth;
        final monthRaw = DateFormat('MMMM', 'tr_TR').format(focusedMonth);
        final monthTitle = monthRaw.isEmpty
            ? monthRaw
            : '${monthRaw[0].toUpperCase()}${monthRaw.substring(1)}';
        final cells = _cellsForMonth(focusedMonth);
        final rows = cells.length ~/ 7;
        final monthYearLabel = '$monthTitle ${focusedMonth.year}';

        return Container(
          decoration: BoxDecoration(
            color: AppColors.menuCardBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ChevronIconButton(
                        icon: Icons.chevron_left_rounded,
                        onTap: homeProvider.prevMonth,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          monthYearLabel,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      _ChevronIconButton(
                        icon: Icons.chevron_right_rounded,
                        onTap: homeProvider.nextMonth,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _gridLine),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Column(
                        children: [
                          Container(
                            color: _headerBg,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            child: Row(
                              children: _dayShort
                                  .map(
                                    (e) => Expanded(
                                      child: Text(
                                        e,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          Table(
                            border: TableBorder(
                              horizontalInside: BorderSide(color: _gridLine),
                              verticalInside: BorderSide(color: _gridLine),
                            ),
                            children: List.generate(rows, (r) {
                              return TableRow(
                                children: List.generate(7, (c) {
                                  final i = r * 7 + c;
                                  final d = cells[i];
                                  final inMonth = _sameMonth(d, focusedMonth);
                                  final today = _isToday(d);
                                  return _DateCell(
                                    day: d.day,
                                    muted: !inMonth,
                                    today: today,
                                  );
                                }),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChevronIconButton extends StatelessWidget {
  const _ChevronIconButton({required this.icon, required this.onTap});

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

/// Tüm satırlar aynı yükseklikte kalsın diye sabit; gün numarası üstte ortalanır.
const double _kDateCellHeight = 52;

class _DateCell extends StatelessWidget {
  const _DateCell({
    required this.day,
    required this.muted,
    required this.today,
  });

  final int day;
  final bool muted;
  final bool today;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      height: _kDateCellHeight,
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: today ? 4 : 8),
      child: today
          ? Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primaryOrange,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$day',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            )
          : Text(
              '$day',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: muted ? _kMutedCalendarDay : AppColors.textPrimary,
              ),
            ),
    );
  }
}
