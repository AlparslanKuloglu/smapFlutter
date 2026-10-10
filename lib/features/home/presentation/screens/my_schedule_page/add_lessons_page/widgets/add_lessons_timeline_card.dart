import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_colors.dart';

class AddLessonsTimelineCard extends StatelessWidget {
  const AddLessonsTimelineCard({
    super.key,
    required this.time,
    required this.subjects,
    this.onTap,
    this.isPendingMode = false,
    this.allLessons,
    this.isEditingLocked = false, // 🔴 YENİ: Düzenleme kilitli mi kontrolü
  });

  final String time;
  final List<Map<String, dynamic>> subjects;
  final VoidCallback? onTap;
  final bool isPendingMode;
  final dynamic allLessons;
  final bool isEditingLocked; // 🔴 YENİ DEĞİŞKEN

  @override
  Widget build(BuildContext context) {
    final isFilled = subjects.isNotEmpty;
    final Map<String, Map<String, dynamic>> lessonLookup = {};
    if (allLessons is Iterable) {
      for (var element in allLessons) {
        if (element is Map && element['_id'] != null) {
          final id = element['_id'].toString();
          lessonLookup[id] = Map<String, dynamic>.from(element);
        }
      }
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sol taraftaki Saat Alanı
          SizedBox(
            width: 56,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.menuCardBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.textSecondary.withOpacity(0.1),
                ),
              ),
              child: Text(
                time,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Sağ taraftaki İçerik Alanı
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                // 🔴 Eğer kilitliyse tıklama aksiyonunu tamamen kapatıyoruz
                onTap: isEditingLocked ? null : onTap,
                // 🔴 Eğer kilitliyse tıklama efektini de kapatıyoruz
                splashColor: isEditingLocked ? Colors.transparent : null,
                highlightColor: isEditingLocked ? Colors.transparent : null,
                borderRadius: BorderRadius.circular(12),
                child: Ink(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.menuCardBackground,
                    borderRadius: BorderRadius.circular(12),
                    // Eğer bekleme modundaysak ve kilitli değilsek turuncu border yap
                    border: (isPendingMode && !isEditingLocked)
                        ? Border.all(
                            color: AppColors.primaryOrange.withOpacity(0.6),
                            width: 1.5,
                          )
                        : (isFilled
                              ? null
                              : Border.all(
                                  color: AppColors.textSecondary.withOpacity(
                                    0.15,
                                  ),
                                )),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: isFilled
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Ders Listesi Ana Kolonu
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(subjects?.length ?? 0, (
                                index,
                              ) {
                                final item = subjects[index];

                                if (item.isEmpty)
                                  return const SizedBox.shrink();

                                final lessonName =
                                    item['lesson']?['name']?.toString() ??
                                    'Bilinmeyen Ders';
                                final topicName =
                                    item['data']?['name']?.toString() ??
                                    'Bilinmeyen Konu';

                                final itemColor = item['lessonColor'] is Color
                                    ? item['lessonColor'] as Color
                                    : AppColors.primaryOrange;

                                final lesson = item['lesson'];
                                final lessonId = lesson?['_id']?.toString();

                                final Map<String, dynamic> selectedLesson =
                                    (lessonId != null
                                        ? lessonLookup[lessonId]
                                        : null) ??
                                    <String, dynamic>{};

                                Color finalColor = itemColor;

                                if (selectedLesson.isNotEmpty &&
                                    selectedLesson['lessonColor'] != null) {
                                  final lessonColorValue =
                                      selectedLesson['lessonColor'];
                                  if (lessonColorValue is Color) {
                                    finalColor = lessonColorValue;
                                  }
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Container(
                                            width: 4,
                                            decoration: BoxDecoration(
                                              color: finalColor,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  lessonName,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        AppColors.textPrimary,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  topicName,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (index < subjects.length - 1)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: Divider(
                                          height: 1,
                                          color: Color(0xFFE2E8F0),
                                        ),
                                      ),
                                  ],
                                );
                              }),
                            ),

                            // 🔴 Ekleme Daveti Alanı: Sadece düzenleme kilitli DEĞİLSE gösterilir
                            if (!isEditingLocked)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  left: 14,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isPendingMode
                                          ? Icons.add_circle
                                          : Icons.add,
                                      size: 14,
                                      color: AppColors.primaryOrange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isPendingMode
                                          ? "Buraya Ekle"
                                          : "Bir konu daha ekle",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.primaryOrange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        )
                      : Row(
                          children: [
                            // 🔴 Boş Kart Görünümü: Kilitliyse sadece boş yazı, açık ise artı ikonuyla davet
                            Icon(
                              isEditingLocked
                                  ? Icons.calendar_today_rounded
                                  : (isPendingMode
                                        ? Icons.add_circle
                                        : Icons.add_circle_outline_rounded),
                              size: 18,
                              color: (!isEditingLocked && isPendingMode)
                                  ? AppColors.primaryOrange
                                  : AppColors.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isEditingLocked
                                  ? 'Boş Saat'
                                  : (isPendingMode
                                        ? 'Buraya Ekle'
                                        : 'Konu Ekle'),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    (!isEditingLocked && isPendingMode) ||
                                        isEditingLocked
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: (!isEditingLocked && isPendingMode)
                                    ? AppColors.primaryOrange
                                    : AppColors.textSecondary.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
