import 'package:flutter/material.dart';
import 'package:studentmap/core/theme/app_colors.dart';

class AddLessonsDaySelector extends StatelessWidget {
  const AddLessonsDaySelector({
    super.key,
    required this.days,
    required this.selectedIndex,
    required this.onSelected,
    required this.onPrevious,
    required this.onNext,
  });

  final List<DateTime> days;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  static const _dayShort = ['Pt', 'Sal', 'Çar', 'Per', 'Cu', 'Cmt', 'Paz'];

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _ArrowButton(icon: Icons.chevron_left_rounded, onTap: onPrevious),
          const SizedBox(width: 8),
          Expanded(
            child: Center(
              // 1. ADIM: İçeriğin genişliğe göre ortalanmasını tetikler
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                // 2. ADIM: Elemanlar ekrandan azsa merkeze toplar, çoksa scroll başlatır
                physics: const ClampingScrollPhysics(),
                child: Row(
                  mainAxisSize: MainAxisSize
                      .min, // 3. ADIM: Row ekranı kaplamasın, sadece çipler kadar yer kaplasın
                  mainAxisAlignment:
                      MainAxisAlignment.center, // 4. ADIM: Elemanları ortala
                  children: [
                    for (var i = 0; i < days.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      _DayChip(
                        day: days[i].day,
                        weekday: _dayShort[days[i].weekday - 1],
                        selected: i == selectedIndex,
                        onTap: () => onSelected(i),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _ArrowButton(icon: Icons.chevron_right_rounded, onTap: onNext),
        ],
      ),
    );
  }
}

// _ArrowButton ve _DayChip sınıfların hiçbir değişiklik gerektirmeden aynen kalıyor...
class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.menuCardBackground,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 20, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.weekday,
    required this.selected,
    required this.onTap,
  });

  final int day;
  final String weekday;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.navSelectedBg : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$day',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? AppColors.primaryOrange
                      : AppColors.textPrimary,
                ),
              ),
              Text(
                weekday,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.primaryOrange
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
