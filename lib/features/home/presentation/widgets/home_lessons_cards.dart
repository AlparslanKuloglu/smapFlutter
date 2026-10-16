import 'package:flutter/material.dart';
import 'package:studentmap/core/theme/app_colors.dart';
import 'package:studentmap/features/home/presentation/widgets/home_navy_header_band.dart';
import 'package:studentmap/domain/models/general_lessons.dart';
import 'package:studentmap/features/analytics/presentation/screens/lesson_detail_page.dart';
import 'package:studentmap/features/analytics/presentation/screens/edebiyat_lesson_detail_page.dart';
import 'package:studentmap/core/constants/lesson_constants.dart';
import 'package:studentmap/features/home/presentation/widgets/app_dialog.dart';
import 'package:studentmap/features/home/presentation/widgets/lesson_navigation_helper.dart';

/// Yatay kaydırılabilir ders kartları satırı
class HomeLessonsCards extends StatelessWidget {
  const HomeLessonsCards({
    super.key,
    required this.lessons,
    this.rowHeight = 110.0, // <-- 1. TÜM BİLEŞENİ YÖNETEN DİKEY YÜKSEKLİK
    this.cardWidth = 90.0, // <-- 2. KARTIN ENİ
    this.verticalPadding = 10.0, // <-- 3. LİSTE DİKEY İÇ BOŞLUĞU
    this.imageSize = 34.0, // <-- 1. PARAMETRE EKLENDİ (Varsayılan değer: 28)
  });

  final List<GeneralLesson> lessons;
  final double rowHeight;
  final double cardWidth;
  final double verticalPadding;
  final double imageSize; // <-- 2. ALAN TANIMLANDI

  @override
  Widget build(BuildContext context) {
    // Liste boşsa ekranın zıplamasını önlemek için alan rezerve edip yükleniyor basıyoruz
    final bool isLoading = lessons.isEmpty;
    final double netCardHeight = rowHeight - (verticalPadding * 2);

    return SizedBox(
      height: rowHeight,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
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
                    ? const NeverScrollableScrollPhysics() // Yüklenirken kaydırmayı kapat
                    : const BouncingScrollPhysics(),
                // Yüklenirken ekrana yan yana 4 tane sahte iskelet kart çiziyoruz
                itemCount: isLoading ? 6 : lessons.length,
                separatorBuilder: (context, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  if (isLoading) {
                    // --- ISKELET KART ---
                    return _SkeletonCard(
                      width: cardWidth,
                      height: netCardHeight,
                    );
                  }

                  // --- GERÇEK DERS KARTI ---
                  return _LessonCard(
                    lesson: lessons[index],
                    width: cardWidth,
                    height: netCardHeight,
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

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.lesson,
    required this.height,
    required this.width, // <-- 1. PARAMETRE EKLENDİ
  });

  final GeneralLesson lesson;
  final double height;
  final double width; // <-- 2. ALAN TANIMLANDI

  /// SEÇİM PANELİ TETİKLEYİCİSİ
  void _showTypeSelection(BuildContext context) {
    final selectedLesson = AppLessons.generalLessons.firstWhere(
      (generalLesson) => generalLesson['_id'] == lesson.id,
      orElse: () => {},
    );
    final int lessonIsEdebiyat = selectedLesson['edebiyat'] ?? 0;
    final int itsTytAyt = selectedLesson['tytAyt'] ?? 0;
    final String lessonName = selectedLesson['name'];
    final bool lessonIsMathOrGeo =
        lessonName == "Matematik" || lessonName == "Geometri";
    if (lessonIsMathOrGeo) {
      AppDialogs.showUnderConstruction(
        context,
        title: "Kavram Haritan",
        imagePath: "",
        desc:
            "Matematik ve Geometri'deki durumunu görsel olarak takip edebileceğin bu modül mobilde de çok yakında kullanılabilecek. \n\n Web kısmında ise şu anda hazır. smaptr.com'dan giriş yaparak kavram haritanı görebilirsin",
      );
      return;
    }

    if (itsTytAyt == 1) {
      _showMiddleDialog(context);
    } else if (lessonIsEdebiyat == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EdebiyatLessonDetailPage(lesson: lesson, examType: "noExamType"),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LessonDetailPage(
            lesson: lesson,
            examType: "noExamType",
            defaultFilterValue: 9,
            lessonFullName: lessonName,
          ),
        ),
      );
    }
  }

  // 1. SEÇENEK: TAM ORTADA (Dialog)
  void _showMiddleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          lesson.name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Dersin kategorisini seçin",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  // 3. SEÇENEK: AŞAĞIDAN (Standart Bottom Sheet)
  void _showBottomPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                lesson.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Lütfen sınav türü seçiniz",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Ortak Buton Yapısı
  Widget _buildActionButtons(BuildContext context) {
    final int tytCount = lesson.stats?['1'] ?? 0;
    final int aytCount = lesson.stats?['2'] ?? 0;
    final int sos2Count = lesson.stats?['3'] ?? 0;

    final String lessonName = lesson.name;
    final bool lessonHasSos2 =
        lessonName == "Tarih" || lessonName == "Coğrafya";
    final int aytFilterValue = lessonHasSos2 ? 3 : 2;

    final String lessonFullNameTyt = "TYT " + lessonName;
    final String lessonFullNameAyt = "AYT " + lessonName;
    String lessonFullNameSos2 = "SOS-2 " + lessonName;
    if (lessonName == "Coğrafya") {
      lessonFullNameSos2 = "AYT " + lessonName;
    }

    return Row(
      children: [
        Expanded(
          child: _buildSelectionButton(
            context: context,
            label: "TYT",
            count: tytCount,
            color: const Color(0xFF436C95), // bg-[#436C95]
            onTap: () =>
                _handleNavigation(context, "TYT", 1, lessonFullNameTyt),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSelectionButton(
            context: context,
            label: "AYT",
            count: aytCount,
            color: const Color(
              0xED162A3F,
            ), // bg-[#162a3fed] -> %93 opaklık (ED) + 162A3F
            onTap: () => _handleNavigation(
              context,
              "AYT",
              aytFilterValue,
              lessonFullNameAyt,
            ),
          ),
        ),
        if (lessonHasSos2) ...[
          const SizedBox(width: 16),
          Expanded(
            child: _buildSelectionButton(
              context: context,
              label: "SOS-2",
              count: sos2Count,
              color: const Color(0xFF88929D), // bg-[#88929D]
              onTap: () =>
                  _handleNavigation(context, "SOS2", 4, lessonFullNameSos2),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectionButton({
    required BuildContext context,
    required String label,
    required Color color,
    required int count,
    required VoidCallback onTap,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _handleNavigation(
    BuildContext context,
    String examType,
    int defaultFilterValue,
    String lessonFullName,
  ) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonDetailPage(
          lesson: lesson,
          examType: examType,
          defaultFilterValue: defaultFilterValue,
          lessonFullName: lessonFullName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalCount = lesson.stats?['total'] ?? 0;

    return Material(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          InkWell(
            onTap: () => LessonNavigationHelper.showTypeSelection(
              context,
              lesson.toJson(),
            ),
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              width: width, // <-- 3. SABİT DEĞER (90) YERİNE PARAMETRE BAĞLANDI
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: Image.asset(
                        'assets${lesson.image}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, _, __) => Icon(
                          Icons.book_rounded,
                          color: AppColors.appBarBackground,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lesson.name,
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
                  ],
                ),
              ),
            ),
          ),
          if (totalCount > 0)
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
                  '$totalCount',
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

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.6,
      child: Container(
        width: width, // Artık gerçek kart ile BİREBİR aynı en
        height: height, // Artık gerçek kart ile BİREBİR aynı boy
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100, width: 1),
        ),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(radius: 16, backgroundColor: Color(0xfff0f0f0)),
              SizedBox(height: 10),
              SizedBox(
                width: 40,
                child: LinearProgressIndicator(
                  backgroundColor: Color(0xfff0f0f0),
                  color: AppColors.appBarBackground,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
