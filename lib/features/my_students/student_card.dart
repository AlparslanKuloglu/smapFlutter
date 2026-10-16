import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:studentmap/core/theme/app_colors.dart';
import '../../domain/models/student_model.dart';

class StudentCard extends StatelessWidget {
  final Student studentData;
  final VoidCallback onTap;

  final VoidCallback? onProfilTap;
  final VoidCallback? onProgramTap;
  final ValueChanged<int>? onAnalizTap;

  const StudentCard({
    super.key,
    required this.studentData,
    required this.onTap,
    this.onProfilTap,
    this.onProgramTap,
    this.onAnalizTap,
  });

  @override
  Widget build(BuildContext context) {
    final String name = studentData.name ?? 'İsimsiz Öğrenci';
    final String grade = studentData.seasonType?.toString() ?? "10.Sınıf";
    final String status = "Başarısız";
    final String? avatarPath = studentData.photo != null
        ? "assets/avatars/${studentData.photo}"
        : null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 12.0,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Kart genişliğine göre dinamik avatar boyutu hesaplama
                final double avatarRadius = math.min(
                  constraints.maxWidth * 0.22,
                  36.0,
                );

                return Column(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // İçerikleri karta dengeli dağıtır
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. Üst Bölüm: Profil & İsim
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: avatarRadius,
                          backgroundColor: AppColors.navSelectedBg,
                          backgroundImage: avatarPath != null
                              ? AssetImage(avatarPath)
                              : null,
                          child: avatarPath == null
                              ? Text(
                                  name
                                      .substring(0, math.min(2, name.length))
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: AppColors.primaryOrange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: avatarRadius * 0.6,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0D2744),
                          ),
                        ),
                      ],
                    ),

                    // 2. Orta Bölüm: Bilgi Satırları
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildInfoRow(
                            Icons.menu_book_rounded,
                            Colors.orange,
                            "$grade (Sınıf)",
                          ),
                          const SizedBox(height: 4),
                          _buildInfoRow(
                            Icons.star_rounded,
                            Colors.red,
                            "$status (Derece)",
                          ),
                        ],
                      ),
                    ),

                    // 3. Alt Bölüm: Responsive Buton Grubu (GridView yerine esnek Row düzeni)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                "Analiz",
                                onAnalizTap != null
                                    ? () => onAnalizTap!(0)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _buildActionButton(
                                "Denemeler",
                                onAnalizTap != null
                                    ? () => onAnalizTap!(1)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                "Kaynak Tkp.",
                                onAnalizTap != null
                                    ? () => onAnalizTap!(2)
                                    : null, // 0 nolu index'i pasladık
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _buildActionButton(
                                "Program",
                                onProgramTap,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Bilgi satırları için optimize edilmiş esnek yapı
  Widget _buildInfoRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0D2744),
            ),
          ),
        ),
      ],
    );
  }

  // Responsive buton yapısı
  // VoidCallback? yerine void Function()? yaptık ki dışarıdan
  // parametresi önceden doldurulmuş fonksiyonları da kabul edebilsin.
  Widget _buildActionButton(String title, void Function()? buttonOnTap) {
    return InkWell(
      onTap: buttonOnTap ?? () {},
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEAECEF),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5A6A85),
          ),
        ),
      ),
    );
  }
}
