import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_colors.dart';

class ScheduleListCard extends StatelessWidget {
  const ScheduleListCard({
    super.key,
    required this.schedule, // JSON verisini temsil eden ham Map nesnesi
    this.onPressed, // Butona tıklandığında çalışacak fonksiyon
  });

  final Map<String, dynamic> schedule;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    // JSON'dan gelen verileri güvenli bir şekilde değişkenlere atıyoruz
    final String title = schedule['name'] ?? 'Başlık Yok';
    final String subtitle = schedule['motto'] ?? '';

    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.menuCardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Üst Kısım: Sabit Asset Görsel Alanı
          Expanded(
            flex: 5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(
                  8.0,
                ), // Görsel kenarlara sıfır yapışmasın diye hafif boşluk
                child: Image.asset(
                  'assets/icons/calendar.png', // 🔴 Sabit asset image yolu
                  fit:
                      BoxFit.contain, // Görseli bozmadan kutunun içine sığdırır
                ),
              ),
            ),
          ),

          // Orta Kısım: Başlık ve Alt Başlık Metinleri
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                  // Eğer motto/alt başlık boş değilse araya boşluk at ve göster
                  if (subtitle.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Alt Kısım: Detay Butonu
          FilledButton(
            onPressed: onPressed ?? () {},
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.appBarBackground,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Program Detayı',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
