import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_colors.dart';

class InterviewCard extends StatelessWidget {
  final Map<String, dynamic> interviewData;
  final VoidCallback onTap;

  const InterviewCard({
    super.key,
    required this.interviewData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF0D2744);

    final String studentName =
        interviewData['studentName'] ?? 'Bilinmeyen Öğrenci';
    final String topic = interviewData['topic'] ?? 'Görüşme';
    final String date = interviewData['date'] ?? '';
    // Asset imaj yolu (Örn: '')
    final String? avatarAsset =
        'assets/avatars/' + interviewData['studentImage'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 1. SOL ALAN: Öğrenci İmaj Asset / Avatarı
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.navSelectedBg,
                backgroundImage: avatarAsset != null
                    ? AssetImage(avatarAsset)
                    : null,
                child: avatarAsset == null
                    ? Text(
                        studentName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),

              // 2. ORTA ALAN: Öğrenci İsmi, Topic ve Tarih
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: darkBlue,
                      ),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                    const SizedBox(height: 2),

                    Text(
                      topic,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. SAĞ ALAN: Mavi Detay Butonu (Chevron)
              const Icon(
                Icons.chevron_right_rounded,
                color: darkBlue,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
