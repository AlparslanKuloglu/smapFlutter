import 'package:flutter/material.dart';
import 'package:studentmap/features/analytics/presentation/models/analytics_general_data.dart';
import 'package:studentmap/features/analytics/presentation/widgets/lesson_distribution_chart_card.dart';
import 'package:studentmap/features/analytics/presentation/widgets/net_chart_card.dart';
import 'package:studentmap/features/analytics/presentation/widgets/stats_grid.dart';

class GeneralTab extends StatelessWidget {
  const GeneralTab({super.key, required this.data});

  final AnalyticsGeneralData data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
      child: Column(
        children: [
          NetChartCard(data: data.chart),
          const SizedBox(height: 16),
          StatsGrid(cards: data.cards),
          const SizedBox(height: 16),
          //LessonDistributionChartCard(items: data.lessonDistributions),
        ],
      ),
    );
  }
}
