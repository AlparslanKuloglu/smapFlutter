import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_colors.dart';
import 'package:smap/features/analytics/presentation/screens/analytics_screen.dart';

class CoachAnalyticsDetailScreen extends StatelessWidget {
  final String studentName;
  final String studentId;
  final int initialTabIndex;
  final String studentImage;

  const CoachAnalyticsDetailScreen({
    super.key,
    required this.studentName,
    required this.studentId,
    required this.initialTabIndex,
    required this.studentImage,
  });

  @override
  Widget build(BuildContext context) {
    String fullImage = "assets/$studentImage";

    print(studentName);
    print(studentImage);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white24,
              backgroundImage: studentImage.isNotEmpty
                  ? AssetImage(fullImage)
                  : null,
              child: studentImage.isEmpty
                  ? Text(
                      studentName.isNotEmpty
                          ? studentName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "$studentName",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize:
                      16.0, // Text boyutunu buradan küçültebilirsiniz (varsayılan genelde 20'dir)
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: Colors.white,
        toolbarHeight: 70.0,
        elevation: 0,
      ),
      body: AnalyticsView(
        studentId: studentId,
        initialTabIndex: initialTabIndex,
      ),
    );
  }
}
