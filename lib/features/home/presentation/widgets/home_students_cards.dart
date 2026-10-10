import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_colors.dart';
import 'package:smap/features/home/presentation/widgets/home_navy_header_band.dart';
import 'package:smap/domain/models/student_model.dart';
import 'package:smap/features/analytics/presentation/screens/coach_analytics_screen.dart';
import 'package:smap/features/home/presentation/screens/coach_programs_screen.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart'; // SVG ikonlar için

class HomeStudentsCards extends StatelessWidget {
  const HomeStudentsCards({super.key, required this.students});

  final List<Student> students;

  static const double rowHeight = HomeNavyHeaderBand.rowHeight;

  @override
  Widget build(BuildContext context) {
    final bool isLoading = students.isEmpty;

    return SizedBox(
      height: rowHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: HomeNavyHeaderBand.bandHeight,
            child: HomeNavyHeaderBand(),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              height: rowHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                physics: isLoading
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                itemCount: isLoading ? 4 : students.length,
                separatorBuilder: (context, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  if (isLoading) {
                    return Opacity(
                      opacity: 0.6,
                      child: Container(
                        width: 100,
                        height: rowHeight - 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade100,
                            width: 1,
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Color(0xfff0f0f0),
                              ),
                              SizedBox(height: 12),
                              SizedBox(
                                width: 50,
                                child: LinearProgressIndicator(
                                  backgroundColor: Color(0xfff0f0f0),
                                  color: AppColors.appBarBackground,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return _StudentCard(
                    student: students[index],
                    height: rowHeight - 20,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student, required this.height});

  final Student student;
  final double height;

  // aimType değerine göre alan adını döndüren yardımcı fonksiyon
  String? _getAimTypeName(int? aimType) {
    if (aimType == 2) return 'Eşit Ağırlık';
    if (aimType == 3) return 'Sayısal';
    if (aimType == 4) return 'Sözel';
    return null; // Diğer durumlarda boş döner
  }

  // Popup / Dialog Penceresini Gösteren Fonksiyon
  void _showStudentDetailsDialog(
    BuildContext context,
    String studentId,
    String studentName,
    String avatar,
  ) {
    final String grade = student.seasonType?.toString() ?? "10.Sınıf";
    final String? status = _getAimTypeName(student.aimType);
    final String? avatarPath = avatar.isNotEmpty ? "assets/$avatar" : null;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 24,
          ),
          child: Container(
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
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 12.0,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double avatarRadius = math.min(
                      constraints.maxWidth * 0.22,
                      36.0,
                    );

                    return Column(
                      mainAxisSize: MainAxisSize.min,
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
                                      _getInitials(studentName),
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
                              studentName,
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

                        // 2. Orta Bölüm: Bilgi Satırları (Ortalandı)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildInfoRow(
                                Icons.menu_book_rounded,
                                Colors.orange,
                                "$grade. Sınıf",
                              ),
                              if (status != null) ...[
                                const SizedBox(height: 4),
                                _buildInfoRow(
                                  Icons.star_rounded,
                                  Colors.red,
                                  status,
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // 3. Alt Bölüm: Solunda SVG İkon Bulunan Buton Grubu
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    title: 'Analiz',
                                    svgPath: "assets/svgs/analysis.svg",
                                    buttonOnTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CoachAnalyticsDetailScreen(
                                                studentName: studentName,
                                                studentImage: avatar,
                                                studentId: studentId,
                                                initialTabIndex: 0,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: _buildActionButton(
                                    title: 'Denemeler',
                                    svgPath: "assets/svgs/bookr212.svg",
                                    buttonOnTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CoachAnalyticsDetailScreen(
                                                studentName: studentName,
                                                studentImage: avatar,

                                                studentId: studentId,
                                                initialTabIndex: 1,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    title: 'Kaynak Takibi',
                                    svgPath: "assets/svgs/pen1.svg",
                                    buttonOnTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CoachAnalyticsDetailScreen(
                                                studentName: studentName,
                                                studentImage: avatar,
                                                studentId: studentId,
                                                initialTabIndex: 2,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: _buildActionButton(
                                    title: 'Program',
                                    svgPath: "assets/svgs/calendar1.svg",
                                    buttonOnTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TeacherViewScheduleScreen(
                                                studentName: student.name,
                                                studentId: student.id,
                                                studentImage: student.photo,
                                              ),
                                        ),
                                      );
                                    },
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
      },
    );
  }

  // Ortalanmış bilgi satırı
  Widget _buildInfoRow(IconData icon, Color color, String text) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center, // İkon ve metni kartta ortalar
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 4),
        Flexible(
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

  // Solunda SVG ikon bulunan buton yapısı
  Widget _buildActionButton({
    required String title,
    required String svgPath,
    void Function()? buttonOnTap,
  }) {
    return InkWell(
      onTap: buttonOnTap ?? () {},
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 22,
        ), // Yatay padding artırıldı
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 247, 245, 245),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start, // Sola hizalama sağlandı
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: SvgPicture.asset(
                svgPath,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  AppColors.primaryOrange,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ), // İkon ile yazı arası mesafe netleştirildi
            Expanded(
              // Flexible yerine Expanded kullanarak yazının kalan alanı doldurması sağlandı
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
          ],
        ),
      ),
    );
  }

  // Güvenli isim baş harfleri fonksiyonu
  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '??';

    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, math.min(2, parts[0].length)).toUpperCase();
    } else {
      return (parts[0][0] + parts.last[0]).toUpperCase();
    }
  }

  // Bilgi satırları için yardımcı widget
  Widget _buildDialogInfoRow(IconData icon, Color color, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0D2744),
            ),
          ),
        ),
      ],
    );
  }

  // Buton tasarımları için yardımcı widget
  Widget _buildDialogActionButton(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEAECEF),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5A6A85),
          ),
        ),
      ),
    );
  }

  // Grid Elemanlarını Oluşturan Yardımcı Widget
  Widget _buildGridItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.appBarBackground, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String studentName = student.name.isEmpty ? 'Öğrenci' : student.name;
    final String avatar = student.photo.isEmpty
        ? 'avatars/1avatarN3.png'
        : "avatars/${student.photo}";
    final int totalMissing = student.totalMexam;
    final String studentId = student.id;

    return Material(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          InkWell(
            onTap: () => _showStudentDetailsDialog(
              context,
              studentId,
              studentName,
              avatar,
            ),
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              width: 100,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.background,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/$avatar',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: 20,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Center(
                        child: Text(
                          studentName,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (totalMissing > 0)
            Positioned(
              right: -8,
              bottom: -8,
              child: Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  '$totalMissing',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
