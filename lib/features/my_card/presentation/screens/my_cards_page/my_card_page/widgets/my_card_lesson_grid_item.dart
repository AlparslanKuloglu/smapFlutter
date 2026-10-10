import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smap/core/theme/app_colors.dart';
import 'package:smap/features/my_card/presentation/screens/my_cards_page/my_card_page/widgets/my_card_lesson_stat_column.dart';

class MyCardLessonGridItem extends StatelessWidget {
  const MyCardLessonGridItem({
    super.key,
    required this.lesson,
    required this.cardCount,
    required this.onTap,
    required this.isLoading,
  });

  final Map<String, dynamic> lesson;
  final int cardCount;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final lessonName = lesson['name'].toString();

    return Material(
      color: Colors.transparent, // InkWell taşmaması için transparent
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Ders Görseli ve Adı
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets${lesson['lessonImage']}',
                      height: 28,
                      width: 28,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.book, color: Colors.blue, size: 28),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        lessonName.length > 4
                            ? lessonName.substring(4)
                            : lessonName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.appBarBackground,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                // İstatistik Alanı
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        label: 'Eksik',
                        value: lesson['missCount'].toString(),
                        color: AppColors.primaryOrange,
                      ),
                      _buildStatItem(
                        label: 'Doğru',
                        value: lesson['trueCount'].toString(),
                        color: AppColors.appBarBackground,
                      ),
                      _buildStatItem(
                        label: 'Favori',
                        value: lesson['favoriteCount'].toString(),
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),

                // Detay Buton Görünümlü Alan
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/cards.svg',
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF1A237E),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Detay',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    if (isLoading) {
      return Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          const SizedBox(
            height: 14,
            width: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.appBarBackground,
            ),
          ),
        ],
      );
    }

    return MyCardLessonStatColumn(label: label, value: value, color: color);
  }
}
