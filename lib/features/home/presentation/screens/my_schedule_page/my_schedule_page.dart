import 'package:flutter/material.dart';
import 'package:studentmap/core/theme/app_colors.dart';
import 'package:studentmap/features/home/presentation/screens/my_schedule_page/day_selection_page/day_selection_page.dart';
import 'package:studentmap/features/home/presentation/screens/my_schedule_page/schedule_list_page/schedule_list_page.dart';
import 'package:studentmap/repository/weekly_repository.dart';
import 'package:studentmap/core/constants/lesson_constants.dart';

class MySchedulePage extends StatelessWidget {
  String? studentId;
  MySchedulePage({super.key, this.studentId});

  @override
  Widget build(BuildContext context) {
    final weeklyRepository = WeeklyRepository(studentId: studentId);
    const List<Map<String, dynamic>> allLessons = AppLessons.allLessons;

    return ColoredBox(
      color: AppColors.background,
      child: ScheduleListPage(
        repository: weeklyRepository,
        allLessons: allLessons,
        onAddPressed: () {
          // open metodunu güncellediğimiz için artık bu çağrı hatasız çalışacak
          DaySelectionPage.open(
            context,
            repository: weeklyRepository,
            allLessons: allLessons,
          );
        },
      ),
    );
  }
}
