import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_colors.dart';

class AnalyticsTabs extends StatelessWidget {
  const AnalyticsTabs({
    super.key,
    required this.selectedIndex,
    required this.tabs,
    required this.onTabTap,
    this.generalExpanded = false,
  });

  final int selectedIndex;
  final List<String> tabs;
  final ValueChanged<int> onTabTap;
  final bool generalExpanded;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: tabs.length,
        separatorBuilder: (_, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = selectedIndex == i;
          final isGeneral = i == 0;
          return InkWell(
            onTap: () => onTabTap(i),
            borderRadius: BorderRadius.circular(7),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryOrange
                    : const Color(0xFFE9ECEF),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tabs[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : const Color(0xFF68717D),
                    ),
                  ),
                  if (isGeneral) ...[
                    const SizedBox(width: 4),
                    Icon(
                      generalExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: selected ? Colors.white : const Color(0xFF68717D),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
