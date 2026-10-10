import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_colors.dart';

class PageContainer extends StatelessWidget {
  const PageContainer({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
