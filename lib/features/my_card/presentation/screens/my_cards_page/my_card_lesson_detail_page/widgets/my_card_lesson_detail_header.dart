import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_colors.dart';
import 'package:smap/features/analytics/presentation/widgets/my_test_results_detail_widgets.dart';

class MyCardLessonDetailHeader extends StatelessWidget {
  const MyCardLessonDetailHeader({
    super.key,
    required this.lessonName,
    required this.selectedTabIndex,
    required this.onTabSelected,
    required this.onBack,
    required this.countObj,
  });

  final String lessonName;
  final int selectedTabIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onBack;
  final dynamic countObj;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 10,
        bottom: 20,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.appBarBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: onBack,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    lessonName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const Opacity(
                opacity: 0,
                child: IconButton(
                  onPressed: null,
                  icon: Icon(Icons.arrow_back_ios),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 42,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFF2B3D54),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                MyTestResultsDetailTopTabButton(
                  label: 'Eksiklerim',
                  isSelected: selectedTabIndex == 0,
                  onTap: () => onTabSelected(0),
                  tabCount: countObj['missCount'],
                ),
                MyTestResultsDetailTopTabButton(
                  label: 'Bildiklerim',
                  isSelected: selectedTabIndex == 1,
                  onTap: () => onTabSelected(1),
                  tabCount: countObj['trueCount'],
                ),
                MyTestResultsDetailTopTabButton(
                  label: 'Favorilerim',
                  isSelected: selectedTabIndex == 2,
                  onTap: () => onTabSelected(2),
                  tabCount: countObj['favoriteCount'],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
