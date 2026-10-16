import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:studentmap/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:studentmap/features/home/presentation/provider/home_nav_provider.dart';
import 'package:studentmap/features/home/presentation/screens/home_flow_screen.dart';
import 'package:studentmap/features/my_card/presentation/provider/my_card_nav_provider.dart';
import 'package:studentmap/features/my_card/presentation/screens/my_card_screen.dart';
import 'package:studentmap/features/profile/presentation/provider/account_nav_provider.dart';
import 'package:studentmap/features/profile/presentation/screens/account/account_flow_screen.dart';
import 'package:studentmap/features/root/presentation/provider/root_nav_provider.dart';
import 'package:studentmap/features/root/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:studentmap/features/root/presentation/widgets/custom_top_app_bar.dart';
import 'package:studentmap/views/optic_mark_detection_view/optic_mark_detection_view.dart';
import 'package:studentmap/repository/profile_repository.dart';

import 'package:studentmap/features/my_students/my_students_screen.dart';
import 'package:studentmap/features/my_interviews/interviews_screen.dart';
import 'package:studentmap/repository/weekly_repository.dart';
import 'package:studentmap/repository/coach_repository.dart';

class RootScreen extends StatelessWidget {
  final ProfileRepository profileRepository;
  final String userRole; // Girişten veya main'den gelen rol kilitlendi

  const RootScreen({
    super.key,
    required this.profileRepository,
    required this.userRole,
  });

  // 1. ÖĞRENCİ SEKMELERİ (initialTabIndex eklendi)
  List<Widget> _getStudentPages({int? initialTabIndex}) => [
    const HomeFlowScreen(),
    AnalyticsView(initialTabIndex: initialTabIndex),
    const MyCardScreen(),
    AccountFlowScreen(profileRepository: profileRepository),
  ];

  // 2. ÖĞRETMEN SEKMELERİ (index: 0, 1, 2, 3)
  List<Widget> _getTeacherPages() => [
    const HomeFlowScreen(),
    MyStudentsScreen(coachRepository: CoachRepository()),
    GorusmeFlowScreen(),
    AccountFlowScreen(profileRepository: profileRepository),
  ];

  void _openCamera(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const OpticMarkDetectionView2()));
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RootNavNotifier()),
        ChangeNotifierProvider(create: (_) => HomeNavNotifier()),
        ChangeNotifierProvider(create: (_) => AccountNavNotifier()),
        ChangeNotifierProvider(create: (_) => MyCardNavNotifier()),
      ],
      child:
          Consumer4<
            RootNavNotifier,
            HomeNavNotifier,
            AccountNavNotifier,
            MyCardNavNotifier
          >(
            builder: (context, rootNav, homeNav, accountNav, myCardNav, _) {
              final selectedIndex = rootNav.selectedIndex;
              final isHomeTab = selectedIndex == 0;

              // Öğretmende 2. index Kartlarım değil, Görüşmelerim'dir.
              final isMyCardTab = selectedIndex == 2 && userRole != 'coach';
              final isProfileTab = selectedIndex == 3;
              // Rol durumuna göre sayfaları dinamik seçiyoruz
              final List<Widget> activePages = userRole == 'coach'
                  ? _getTeacherPages()
                  : _getStudentPages(initialTabIndex: rootNav.initialTabIndex);

              return Scaffold(
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!isMyCardTab)
                      AnnotatedRegion<SystemUiOverlayStyle>(
                        value: SystemUiOverlayStyle.light.copyWith(
                          statusBarColor: Colors.transparent,
                        ),
                        child: CustomTopAppBar(
                          /*
                          radius:
                              (isProfileTab &&
                                  accountNav.route != AccountRoute.account) ||
                              (isHomeTab && !homeNav.isHub),
                          title: isProfileTab
                              ? accountNav.title
                              : (isHomeTab && !homeNav.isHub
                                    ? homeNav.title
                                    : null),
                          */
                          showBackButton:
                              (isProfileTab && accountNav.showBackButton) ||
                              (isHomeTab && homeNav.showBackButton),
                          onBackPressed: () {
                            if (isProfileTab && accountNav.showBackButton) {
                              accountNav.backToHub();
                            } else if (isHomeTab && homeNav.showBackButton) {
                              homeNav.backToHub();
                            }
                          },
                        ),
                      ),
                    Expanded(
                      child: SafeArea(
                        top: false,
                        bottom: false,
                        child: IndexedStack(
                          index: selectedIndex,
                          children: activePages,
                        ),
                      ),
                    ),
                  ],
                ),
                bottomNavigationBar: CustomBottomNavBar(
                  selectedIndex: selectedIndex,
                  userRole: userRole,
                  onTabTap: (index) {
                    if (index != 0) {
                      homeNav.resetToHub();
                    }
                    if (index != 2 && userRole != 'teacher') {
                      myCardNav.resetToHub();
                    }
                    if (index != 3) {
                      accountNav.resetToHub();
                    }
                    rootNav.changeTab(index);
                  },
                  onCameraTap: () => _openCamera(context),
                ),
              );
            },
          ),
    );
  }
}
