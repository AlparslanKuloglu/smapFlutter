import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LessonBar extends StatelessWidget {
  final String topicId; // Sayfa geçişi için ID ekledik
  final String topicName;
  final int order; // Konu sırası (Örn: 1, 2, 3)
  final int itemDataCount; // Gelen item veri sayısı
  final VoidCallback onTap; // Tıklama aksiyonunu dışarıdan alacağız
  final String subjectImage;
  final Color barColor;
  final Color imageColor;

  static const String _imageBaseUrl = 'https://smaptr.com/subjectIcons/';

  static const double _placeholderProgress = 0.75;
  static const int _placeholderCompleted = 15;
  static const int _placeholderTotal = 20;
  static const int _placeholderSubTopics = 4;
  static const int _placeholderItems = 26;
  static const int _placeholderCards = 8;

  const LessonBar({
    required this.topicId,
    required this.topicName,
    required this.order,
    required this.itemDataCount,
    required this.onTap, // Constructor'a ekledik
    required this.subjectImage,
    required this.barColor,
    required this.imageColor,
  });

  @override
  Widget build(BuildContext context) {
    final int progressPercent = (_placeholderProgress * 100).round();

    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      decoration: BoxDecoration(
        color: barColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 10, 10),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: _buildThumbnail(subjectImage, imageColor),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: _buildMainInfo(progressPercent)),
                            const SizedBox(width: 6),
                            Align(
                              alignment: Alignment.center,
                              child: _buildStatsColumn(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Align(
                      alignment: Alignment.center,
                      child: _buildArrowButton(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(String? subjectImage, Color? imageColor) {
    final String imagePath = (subjectImage != null && subjectImage.isNotEmpty)
        ? 'assets$subjectImage' // 👈 'imagePath' yerine 'subjectImage' olmalı
        : 'assets/icons/subjecticon.png';

    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: imageColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Image.asset(
        imagePath,
        width: 36,
        height: 36,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Belirtilen asset yolu bulunamazsa yedek varsayılan icon yüklenir
          return Image.asset(
            'assets/icons/subjecticon.png',
            width: 36,
            height: 36,
            fit: BoxFit.contain,
          );
        },
      ),
    );
  }

  Widget _buildMainInfo(int progressPercent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment:
          MainAxisAlignment.center, // 3 elemanı grup olarak dikeyde ortalar
      children: [
        // 1. ELEMAN: Konu başlığı
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 16,
              height: 16,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.navSelectedBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$order',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                topicName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF10284A),
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 2. ELEMAN: Progress bar
        FractionallySizedBox(
          widthFactor: 0.8,
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: SizedBox(
                    height: 8,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const ColoredBox(color: AppColors.unselectedGrey),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: _placeholderProgress,
                            heightFactor: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    barColor,
                                    barColor.withValues(alpha: 0.45),
                                  ],
                                  stops: const [0.1, 1.0],
                                ),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(24),
                                  bottomRight: Radius.circular(24),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '%$progressPercent',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // 3. ELEMAN: Konu tamamlandı metni
        Text(
          '$_placeholderCompleted/$_placeholderTotal Konu tamamlandı',
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildWarningBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        '$count Eksiğin var',
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: Color(0xFFEF4444),
        ),
      ),
    );
  }

  Widget _buildStatsColumn() {
    return SizedBox(
      width: 90,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (itemDataCount > 0) ...[
            _buildWarningBadge(itemDataCount),
            const SizedBox(height: 6),
          ],
          _buildStatRow(
            iconWidget: SvgPicture.asset(
              'assets/icons/subheading_card.svg',
              width: 12,
              height: 12,
            ),
            text: '$_placeholderSubTopics Alt Başlık',
            textColor: AppColors.textSecondary,
          ),
          const SizedBox(height: 3),
          _buildStatRow(
            iconWidget: SvgPicture.asset(
              'assets/icons/matter_card.svg',
              width: 12,
              height: 12,
            ),
            text: '$_placeholderItems Madde',
            textColor: AppColors.textSecondary,
          ),
          const SizedBox(height: 3),
          _buildStatRow(
            iconWidget: SvgPicture.asset(
              'assets/icons/information_card.svg',
              width: 12,
              height: 12,
            ),
            text: '$_placeholderCards Bilgi Kartı',
            textColor: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    IconData? icon,
    Widget? iconWidget,
    Color? iconColor,
    required String text,
    required Color textColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child:
              iconWidget ??
              Icon(icon, size: 12, color: iconColor ?? AppColors.textSecondary),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: textColor,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArrowButton() {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: AppColors.menuCardBackground,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.arrow_forward_rounded,
        size: 13,
        color: AppColors.primaryOrange,
      ),
    );
  }
}
