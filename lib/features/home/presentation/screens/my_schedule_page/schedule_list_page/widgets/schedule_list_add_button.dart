import 'package:flutter/material.dart';
import 'package:studentmap/core/theme/app_colors.dart';
import 'package:studentmap/features/home/presentation/screens/my_schedule_page/schedule_list_page/widgets/schedule_list_toolbar_row.dart';

class ScheduleListAddButton extends StatelessWidget {
  const ScheduleListAddButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ScheduleListToolbarSideButton(
      child: Material(
        color: AppColors.primaryOrange,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: const Center(
            child: Icon(Icons.add_rounded, color: AppColors.white),
          ),
        ),
      ),
    );
  }
}
