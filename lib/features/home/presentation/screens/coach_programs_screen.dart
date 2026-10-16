import 'package:flutter/material.dart';
import 'package:studentmap/core/theme/app_colors.dart';
import 'package:studentmap/features/home/presentation/screens/my_schedule_page/my_schedule_page.dart';

class TeacherViewScheduleScreen extends StatelessWidget {
  final String studentName;
  final String studentId;
  final String studentImage;

  const TeacherViewScheduleScreen({
    super.key,
    required this.studentName,
    required this.studentId,
    required this.studentImage,
  });

  @override
  Widget build(BuildContext context) {
    // "assets/" ön eki ile tam dosya yolu oluşturuluyor
    final String fullImage = "assets/avatars/$studentImage";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70.0,
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
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: MySchedulePage(studentId: studentId),
    );
  }
}
