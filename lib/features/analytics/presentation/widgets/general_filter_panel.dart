import 'package:flutter/material.dart';
import 'package:studentmap/core/theme/app_colors.dart';
import 'package:studentmap/features/analytics/presentation/models/analytics_filters.dart';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';

/// Ders bilgilerini eşleştirmek için basit bir model
class AnalyticsLesson {
  final String id;
  final String name;

  const AnalyticsLesson({required this.id, required this.name});
}

class GeneralFilterPanel extends StatelessWidget {
  const GeneralFilterPanel({
    super.key,
    required this.examType,
    required this.aytGroup,
    required this.selectedLesson,
    required this.selectedLessonName,
    required this.onExamTypeChanged,
    required this.onAytGroupChanged,
    required this.onLessonChanged,
  });

  final ExamType examType;
  final AytGroup aytGroup;
  final String selectedLesson;
  final String selectedLessonName;
  final ValueChanged<ExamType> onExamTypeChanged;
  final ValueChanged<AytGroup> onAytGroupChanged;
  final void Function(String id, String name) onLessonChanged;

  // --- STATİK DERS LİSTELERİ ---
  static const List<AnalyticsLesson> _tytLessons = [
    AnalyticsLesson(id: 'geneltyt', name: 'Genel'),
    AnalyticsLesson(id: '663e37a24fb443839593141b', name: 'Türkçe'),
    AnalyticsLesson(id: '66214a6982ff212039ea3294', name: 'Tarih'),
    AnalyticsLesson(id: '6660eec58cf59b23d04006b4', name: 'Coğrafya'),
    AnalyticsLesson(id: '663e387c4fb443839593141c', name: 'Matematik'),
    AnalyticsLesson(id: '66bfb7a749ecda29c59f556b', name: 'Geometri'),
    AnalyticsLesson(id: '665c5e80dad9088c202c6c16', name: 'Fizik'),
    AnalyticsLesson(id: '66604f1b2676809673eb4736', name: 'Kimya'),
    AnalyticsLesson(id: '6654977e17046de7432ed446', name: 'Biyoloji'),
  ];

  static const Map<AytGroup, List<AnalyticsLesson>> _aytLessons = {
    AytGroup.esitAgirlik: [
      AnalyticsLesson(id: 'genelea', name: 'Genel'),
      AnalyticsLesson(id: '7', name: 'Türk Dili ve Ed.'),
      AnalyticsLesson(id: '2', name: 'Tarih'),
      AnalyticsLesson(id: '3', name: 'Coğrafya'),
    ],
    AytGroup.sayisal: [
      AnalyticsLesson(id: 'genelsay', name: 'Genel'),
      AnalyticsLesson(id: '8', name: 'Matematik'),
      AnalyticsLesson(id: '9', name: 'Geometri'),
      AnalyticsLesson(id: '4', name: 'Fizik'),
      AnalyticsLesson(id: '5', name: 'Kimya'),
      AnalyticsLesson(id: '6', name: 'Biyoloji'),
    ],
    AytGroup.sozel: [
      AnalyticsLesson(id: 'genelsoz', name: 'Genel'),
      AnalyticsLesson(id: '7', name: 'Türk Dili ve Ed.'),
      AnalyticsLesson(id: '2', name: 'Tarih'),
      AnalyticsLesson(id: '3', name: 'Coğrafya'),
      AnalyticsLesson(id: '10', name: 'Tarih-2'),
      AnalyticsLesson(id: '11', name: 'Coğrafya-2'),
    ],
  };

  List<AnalyticsLesson> get _visibleLessons {
    if (examType == ExamType.tyt) return _tytLessons;
    return _aytLessons[aytGroup] ??
        const [AnalyticsLesson(id: 'Genel', name: 'Genel')];
  }

  String _svgPathForLesson(String lessonName) {
    switch (lessonName) {
      case 'Genel':
        return "assets/svgs/general.svg";
      case 'Türkçe':
      case 'Türk Dili ve Ed.':
        return "assets/svgs/language.svg";
      case 'Tarih':
      case 'Tarih-2':
        return "assets/svgs/history.svg";
      case 'Coğrafya':
      case 'Coğrafya-2':
        return "assets/svgs/geography.svg";
      case 'Matematik':
        return "assets/svgs/math.svg";
      case 'Geometri':
        return "assets/svgs/geometry.svg";
      case 'Fizik':
        return "assets/svgs/physics.svg";
      case 'Kimya':
        return "assets/svgs/chemistry.svg";
      case 'Biyoloji':
        return "assets/svgs/microscope.svg";
      default:
        return "assets/svgs/totalmexam.svg";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9EDF2)),
        boxShadow: [
          // Alt kısmı sağlam gösteren derinlik gölgeleri
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 22),
            spreadRadius: 5,
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TYT-AYT Ana Segment
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _SegmentButton(
                    label: 'TYT',
                    selected: examType == ExamType.tyt,
                    onTap: () => onExamTypeChanged(ExamType.tyt),
                  ),
                ),
                Expanded(
                  child: _SegmentButton(
                    label: 'AYT',
                    selected: examType == ExamType.ayt,
                    onTap: () => onExamTypeChanged(ExamType.ayt),
                  ),
                ),
              ],
            ),
          ),

          // AYT Alt Grupları (Sayısal, EA, Sözel)
          if (examType == ExamType.ayt) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                children: AytGroup.values.map((group) {
                  return Expanded(
                    child: _AytGroupButton(
                      label: group.label,
                      selected: aytGroup == group,
                      onTap: () => onAytGroupChanged(group),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          SizedBox(height: 16),
          const Text(
            'Ders Listesi',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              letterSpacing: -0.2,
            ),
          ),

          // GRIDVIEW BÖLÜMÜ
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _visibleLessons.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.2,
            ),
            itemBuilder: (context, index) {
              final lesson = _visibleLessons[index];
              return _LessonChip(
                label: lesson.name,
                svgPath: _svgPathForLesson(lesson.name),
                selected: lesson.id == selectedLesson,
                onTap: () => onLessonChanged(lesson.id, lesson.name),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // Yanıp sönme hatasını engellemek için hitTestBehavior ekledik
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // Saydamlıktan beyaza geçerken siyahlaşmayı önlemek için
          // seçili değilken arka plan rengiyle aynı yapıyoruz.
          color: selected ? Colors.white : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              // Gölge rengini animasyonla şeffaf yapıyoruz (Liste boşaltılmıyor)
              color: selected
                  ? Colors.black.withOpacity(0.05)
                  : Colors.transparent,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.bold : FontWeight.w600,
            color: selected ? AppColors.primaryOrange : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

class _AytGroupButton extends StatelessWidget {
  const _AytGroupButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 34,
        margin: const EdgeInsets.all(2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryOrange.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primaryOrange : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected ? AppColors.primaryOrange : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}

class _LessonChip extends StatelessWidget {
  const _LessonChip({
    super.key,
    required this.label,
    required this.svgPath,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String svgPath;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Renk tanımları
    final activeColor = AppColors.primaryOrange;
    final inactiveColor = const Color(0xFF94A3B8);
    const borderColor = Color(0xFFE2E8F0);

    // Kenarlık kalınlığı ve köşe yarıçapları
    const borderWidth = 1.4;
    const outerRadius = 12.0;
    // İç yarıçap = dış yarıçap - kenarlık kalınlığı (mükemmel hizalama için)
    const innerRadius = outerRadius - borderWidth;

    // En dış katman: Yuvarlatılmış köşeler ve kenarlık için Container
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Arka plan rengi
        borderRadius: BorderRadius.circular(
          outerRadius,
        ), // Dış yuvarlatılmış köşeler
        border: Border.all(
          color: selected ? activeColor : borderColor,
          width: borderWidth, // Kenarlık kalınlığı
        ),
      ),
      // Tıklama efektini ve içeriği kenarlıkların içinde hapsedecek ClipRRect
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          innerRadius,
        ), // İç yuvarlatılmış köşeler
        child: Material(
          color: Colors
              .transparent, // Arka plan rengini dış Container'dan alıyoruz
          child: InkWell(
            onTap: onTap,
            // Tıklama efektinin rengini özelleştirebilirsiniz (isteğe bağlı)
            splashColor: selected
                ? activeColor.withOpacity(0.1)
                : Colors.black.withOpacity(0.02),
            child: Padding(
              // İçerik için dolgu
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selected
                          ? activeColor.withOpacity(0.05)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SvgPicture.asset(
                      svgPath,
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        selected ? activeColor : inactiveColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected ? activeColor : const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderBox extends StatelessWidget {
  const _DashedBorderBox({
    required this.child,
    required this.borderRadius,
    required this.color,
    this.enabled = true,
  });
  final Widget child;
  final BorderRadius borderRadius;
  final Color color;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return CustomPaint(
      painter: _DashedBorderPainter(color: color, borderRadius: borderRadius),
      child: Padding(padding: const EdgeInsets.all(1.5), child: child),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.borderRadius});
  final Color color;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect).deflate(0.6);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        const dash = 4.0;
        const gap = 3.0;
        final next = distance + dash;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.borderRadius != borderRadius;
}

void showBlurredFilterDialog(BuildContext context, Widget filterPanel) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'FilterDialog',
    barrierColor: Colors.black.withOpacity(0.3), // Hafif karartma
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, anim1, anim2) {
      return ModalBarrier();
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 8 * anim1.value,
          sigmaY: 8 * anim1.value,
        ), // Canlı blur efekti
        child: FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
            ),
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              child: filterPanel,
            ),
          ),
        ),
      );
    },
  );
}
