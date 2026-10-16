import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:studentmap/core/theme/app_colors.dart';
import 'package:studentmap/features/analytics/presentation/models/analytics_general_data.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key, required this.cards});

  final List<AnalyticsMetricCardData> cards;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: cards.length,
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.58,
      ),
      itemBuilder: (context, i) => _StatCard(data: cards[i]),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final AnalyticsMetricCardData data;

  static const double _offset = 3;

  @override
  Widget build(BuildContext context) {
    // Kartın gerçek genişliği: (ekran - padding - spacing) / 2
    final cardWidth = (MediaQuery.of(context).size.width - 32 - 10) / 2;
    // 160px referans genişlik — bu boyutta tasarım yapıldı
    final scale = (cardWidth / 160).clamp(0.85, 1.2);

    return Stack(
      children: [
        Positioned(
          top: _offset,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryOrange,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: _offset,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE8EAED), width: 1),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32 * scale,
                      height: 32 * scale,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1E4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildSvgIcon(scale),
                    ),
                    SizedBox(width: 8 * scale),
                    Expanded(
                      child: Text(
                        data.value,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20 * scale,
                          fontWeight: FontWeight.w700,
                          height: 1,
                          color: const Color(0xFF2B3A4A),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF5F6875),
                  ),
                ),
                SizedBox(height: 2 * scale),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: data.changeText,
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2B3A4A),
                        ),
                      ),
                      TextSpan(
                        text: '  ${data.periodText}',
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFB4BAC3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// SVG ikon çizen ve boş path durumunu kontrol eden yardımcı metod
  Widget _buildSvgIcon(double scale) {
    if (data.iconPath.isEmpty) {
      return Icon(
        Icons.bar_chart_rounded,
        size: 20 * scale,
        color: AppColors.primaryOrange,
      );
    }

    return SvgPicture.asset(
      data.iconPath,
      width: 20 * scale,
      height: 20 * scale,
      colorFilter: const ColorFilter.mode(
        AppColors.primaryOrange,
        BlendMode.srcIn,
      ),
    );
  }
}
