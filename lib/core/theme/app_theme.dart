import 'package:flutter/material.dart';
import 'package:studentmap/core/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.appBarBlueGrey),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.background,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      // Tüm uygulamadaki yükleme ikonlarının rengini buradan belirliyoruz:
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.appBarBackground, // veya AppColors.primary vs.
      ),
    );
  }
}
