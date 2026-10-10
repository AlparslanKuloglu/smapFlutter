import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smap/features/home/presentation/provider/home_nav_provider.dart';
import 'package:smap/features/home/presentation/screens/home_screen.dart';
import 'package:smap/features/home/presentation/screens/my_schedule_page/my_schedule_page.dart';

class HomeFlowScreen extends StatelessWidget {
  const HomeFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final route = context.watch<HomeNavNotifier>().route;

    return PopScope(
      canPop: route == HomeRoute.hub,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        context.read<HomeNavNotifier>().backToHub();
      },
      child: switch (route) {
        HomeRoute.hub => const HomeScreen(),
        HomeRoute.mySchedule => MySchedulePage(),
      },
    );
  }
}
