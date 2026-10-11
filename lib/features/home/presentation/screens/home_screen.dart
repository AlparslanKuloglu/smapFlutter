import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smap/core/theme/app_colors.dart';
import 'package:smap/features/home/presentation/provider/home_provider.dart';
import 'package:smap/features/shared/presentation/provider/user_provider.dart'; // UserProvider'ı ekledik
import 'package:smap/features/home/presentation/widgets/home_menu_grid.dart';
import 'package:smap/features/home/presentation/widgets/home_month_calendar.dart';
import 'package:smap/features/home/presentation/widgets/home_person_card.dart';
import 'package:smap/features/home/presentation/widgets/home_students_cards.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Sayfa ilk açıldığında verileri çekiyoruz
    Future.microtask(() {
      if (!mounted) return;
      // Hem kullanıcı verisini hem de dersleri yüklüyoruz
      context.read<UserProvider>().loadUserData();
      context.read<HomeProvider>().fetchHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final homeProvider = context.watch<HomeProvider>();
    final String userRole = userProvider.userRole ?? 'student';
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The student's home is the new `HomeView` (E6); this hub is the
          // coach's until E15 replaces it.
          if (userRole == 'coach')
            HomeStudentsCards(students: homeProvider.coachStudents)
          else
            const SizedBox.shrink(), // Beklenmedik bir rol durumu için koruma
          Expanded(
            child: ColoredBox(
              color: AppColors.background,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: math.max(0, constraints.maxHeight - 24),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HomePersonCard(), // Artık veriyi içeriden (provider) alıyor
                          SizedBox(height: 12),
                          HomeMenuGrid(), // Artık rolü içeriden (provider) kontrol ediyor
                          SizedBox(height: 16),
                          HomeMonthCalendar(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
