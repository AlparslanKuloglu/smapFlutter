import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryOrange = Color(0xFFFF6600);

  /// Uygulama / anasayfa gövde arka planı (beyaz).
  static const Color background = Color(0xFFFFFFFF);

  /// Anasayfa menü kartları ve takvim kartı arka planı.
  static const Color menuCardBackground = Color(0xFFF5F7F9);

  static const Color white = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1C1F33);
  static const Color textSecondary = Color(0xFF8A90A6);
  static const Color shadowLight = Color(0x14000000);
  static const Color shadowMedium = Color(0x16000000);
  static const Color orangeShadow = Color(0x33FF8A00);
  static const Color navUnselected = Color(0xFFB2BAC6);
  static const Color navSelectedBg = Color(0xFFFFD4B3);
  static const Color navIndicator = Color(0xFFFF7A00);
  static const Color appBarBackground = Color(0xFF0F294A);
  static const Color unselectedGrey = Color(0xFFE2E8F0);
  static const Color accentOrange = Color(0xFFFF8A00);
  static const Color appBarBlueGrey = Color(0xFF7D858D);

  static const List<String> studentAvatars = [
    'assets/avatars/1avatarN3.png',
    'assets/avatars/3avatarN3.png',
    'assets/avatars/4avatarN3.png',
    'assets/avatars/5avatarN3.png',
    'assets/avatars/6avatarN3.png',
    'assets/avatars/8avatarN3.png',
    'assets/avatars/9avatarN3.png',
  ];

  static Color hexToColor(
    String? hexString, {
    Color defaultColor = const Color.fromARGB(255, 232, 234, 235),
  }) {
    if (hexString == null || hexString.isEmpty) {
      return defaultColor;
    }

    try {
      // Baştaki # ve boşlukları temizle
      String formattedHex = hexString.replaceAll('#', '').trim();

      // 6 haneli ise başına tam opaklık için FF ekle
      if (formattedHex.length == 6) {
        formattedHex = 'FF$formattedHex';
      }

      return Color(int.parse(formattedHex, radix: 16));
    } catch (e) {
      // Hatalı veya geçersiz bir hex formatı gelirse patlamaması için fallback renk
      return defaultColor;
    }
  }
}
