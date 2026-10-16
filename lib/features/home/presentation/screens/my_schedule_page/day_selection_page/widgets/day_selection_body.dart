import 'package:flutter/material.dart';
import 'package:studentmap/core/theme/app_colors.dart';
import 'package:studentmap/features/home/presentation/screens/my_schedule_page/day_selection_page/widgets/day_selection_calendar.dart';

class DaySelectionBody extends StatelessWidget {
  const DaySelectionBody({
    super.key,
    required this.selectedDays,
    required this.onDayToggled,
  });

  final Set<DateTime> selectedDays;
  final ValueChanged<DateTime> onDayToggled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(
            'Program oluşturmak istediğiniz günleri seçiniz',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: DaySelectionCalendar(
              selectedDays: selectedDays,
              onDayToggled: onDayToggled,
            ),
          ),
        ),
      ],
    );
  }
}
