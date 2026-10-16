import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider paketini ekledik
import 'package:studentmap/core/theme/app_colors.dart';
import 'package:studentmap/features/shared/presentation/widgets/app_user_avatar.dart';
import 'package:studentmap/features/shared/presentation/provider/user_provider.dart'; // UserProvider'ın yolu

/// Anasayfa üst bölümünde gösterilen kullanıcı özeti kartı.
class HomePersonCard extends StatelessWidget {
  const HomePersonCard({super.key});

  // Stil sabitlerini koruyoruz
  static const Color _badgeFill = Color(0x22FFFFFF);
  static const Color _diamond = Color(0xFFFFD54F);
  static const Color _mutedOnNavy = Color(0xCCFFFFFF);

  @override
  Widget build(BuildContext context) {
    // UserProvider'daki kullanıcıyı dinliyoruz
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    // Veri henüz yüklenmediyse (null ise) boş bir kutu veya iskelet (shimmer) dönebiliriz.
    if (user == null) {
      return const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final int percent = (user.progress * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const AppUserAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        user.name, // SharedPreferences'tan gelen isim
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _badgeFill,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/menuIcons/smapc.png', // Görselinin kendi dosya yolunu buraya yaz
                            width: 22,
                            height: 22,
                            // Eğer PNG resminin rengini kod içerisinden değiştirmek istersen:
                            // color: _diamond,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${user.points}', // SharedPreferences'tan gelen puan
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          // User modelindeki progress değerini kullanıyoruz
                          value: user.progress.clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: AppColors.white,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primaryOrange,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        color: _mutedOnNavy,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
