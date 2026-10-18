import 'package:flutter/material.dart';
import 'package:studentmap/core/theme/app_colors.dart';
import 'package:studentmap/domain/models/general_lessons.dart';
import 'package:studentmap/core/constants/lesson_constants.dart';
import 'package:studentmap/features/analytics/presentation/screens/lesson_detail_page.dart';
import 'package:studentmap/features/analytics/presentation/screens/edebiyat_lesson_detail_page.dart';
import 'package:studentmap/features/home/presentation/widgets/app_dialog.dart';

class LessonNavigationHelper {
  /// Map<String, dynamic> alarak çalışan ana tetikleyici metot
  /// [selectedExamType]: 'TYT' veya 'AYT' verilirse (Derslerim sayfası)
  /// TYT/AYT seçimi o sınav tipine göre yapılır; null ise dialog açılır.
  static void showTypeSelection(
    BuildContext context,
    Map<String, dynamic> lesson, {
    String? selectedExamType,
  }) {
    // Map içinden id ve name değerlerini güvenle alıyoruz
    final String lessonId =
        lesson['_id']?.toString() ?? lesson['id']?.toString() ?? '';
    final String lessonName = lesson['name']?.toString() ?? '';
    print("showTypeSelection");
    final selectedLesson = AppLessons.generalLessons.firstWhere(
      (generalLesson) => generalLesson['_id']?.toString() == lessonId,
      orElse: () => {},
    );

    final int lessonIsEdebiyat =
        (selectedLesson['edebiyat'] as num?)?.toInt() ?? 0;
    final int itsTytAyt = (selectedLesson['tytAyt'] as num?)?.toInt() ?? 0;
    final String finalLessonName =
        selectedLesson['name']?.toString() ?? lessonName;

    final bool lessonIsMathOrGeo =
        finalLessonName == "Matematik" || finalLessonName == "Geometri";

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
      final String name = lesson['name']?.toString() ?? '';

      if (selectedExamType == 'TYT') {
        _pushLessonDetail(context, lesson, "TYT", 1, "TYT $name");
      } else if (selectedExamType == 'AYT') {
        // SOS-2'si olan derslerde AYT / SOS-2 seçimi, diğerlerinde direkt AYT
        if (_lessonHasSos2(name)) {
          showMiddleDialog(context, lesson, showTyt: false);
        } else {
          _pushLessonDetail(context, lesson, "AYT", 2, "AYT $name");
        }
      } else {
        showMiddleDialog(context, lesson);
      }
    } else if (lessonIsEdebiyat == 1) {
      // Eğer hedef sayfa nesne bekliyorsa Map'ten nesneye dönüştürebilirsiniz
      final lessonModel = GeneralLesson.fromJson(lesson);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EdebiyatLessonDetailPage(
            lesson: lessonModel,
            examType: "noExamType",
          ),
        ),
      );
    } else {
      final lessonModel = GeneralLesson.fromJson(lesson);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LessonDetailPage(
            lesson: lessonModel,
            examType: "noExamType",
            defaultFilterValue: 9,
            lessonFullName: finalLessonName,
          ),
        ),
      );
    }
  }

  /// Ortada Açılan Dialog
  static void showMiddleDialog(
    BuildContext context,
    Map<String, dynamic> lesson, {
    bool showTyt = true,
  }) {
    final String lessonName = lesson['name']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          lessonName,
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
            _buildActionButtons(context, lesson, showTyt: showTyt),
          ],
        ),
      ),
    );
  }

  /// Ortak Buton Yapısı
  static Widget _buildActionButtons(
    BuildContext context,
    Map<String, dynamic> lesson, {
    bool showTyt = true,
  }) {
    // Map içerisindeki 'stats' verisini güvenle çekiyoruz
    final Map<String, dynamic>? stats = lesson['stats'] is Map<String, dynamic>
        ? lesson['stats'] as Map<String, dynamic>
        : null;

    final int tytCount = (stats?['1'] as num?)?.toInt() ?? 0;
    final int aytCount = (stats?['2'] as num?)?.toInt() ?? 0;
    final int sos2Count = (stats?['3'] as num?)?.toInt() ?? 0;

    final String lessonName = lesson['name']?.toString() ?? '';
    final bool lessonHasSos2 = _lessonHasSos2(lessonName);
    final int aytFilterValue = lessonHasSos2 ? 3 : 2;

    final String lessonFullNameTyt = "TYT $lessonName";
    final String lessonFullNameAyt = "AYT $lessonName";
    String lessonFullNameSos2 = "SOS-2 $lessonName";
    if (lessonName == "Coğrafya") {
      lessonFullNameSos2 = "AYT $lessonName";
    }

    return Row(
      children: [
        if (showTyt) ...[
          Expanded(
            child: _buildSelectionButton(
              context: context,
              label: "TYT",
              count: tytCount,
              color: const Color(0xFF436C95),
              onTap: () => _handleNavigation(
                context,
                lesson,
                "TYT",
                1,
                lessonFullNameTyt,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: _buildSelectionButton(
            context: context,
            label: "AYT",
            count: aytCount,
            color: const Color(0xED162A3F),
            onTap: () => _handleNavigation(
              context,
              lesson,
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
              color: const Color(0xFF88929D),
              onTap: () => _handleNavigation(
                context,
                lesson,
                "SOS2",
                4,
                lessonFullNameSos2,
              ),
            ),
          ),
        ],
      ],
    );
  }

  static void _handleNavigation(
    BuildContext context,
    Map<String, dynamic> lesson,
    String examType,
    int defaultFilterValue,
    String lessonFullName,
  ) {
    Navigator.pop(context);
    _pushLessonDetail(
      context,
      lesson,
      examType,
      defaultFilterValue,
      lessonFullName,
    );
  }

  static bool _lessonHasSos2(String lessonName) =>
      lessonName == "Tarih" || lessonName == "Coğrafya";

  static void _pushLessonDetail(
    BuildContext context,
    Map<String, dynamic> lesson,
    String examType,
    int defaultFilterValue,
    String lessonFullName,
  ) {
    final lessonModel = GeneralLesson.fromJson(lesson);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonDetailPage(
          lesson: lessonModel,
          examType: examType,
          defaultFilterValue: defaultFilterValue,
          lessonFullName: lessonFullName,
        ),
      ),
    );
  }

  static Widget _buildSelectionButton({
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
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE8ECF1), width: 1),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryOrange,
                  height: 1,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
