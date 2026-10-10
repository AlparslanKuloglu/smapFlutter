import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smap/core/theme/app_colors.dart';

class AddLessonsDateHeader extends StatelessWidget {
  const AddLessonsDateHeader({
    super.key,
    required this.selectedDays,
    required this.onReset, // Sıfırla butonuna basıldığında çalışacak fonksiyon
    this.isEditingLocked = false, // 🔴 YENİ: Düzenleme kilitli mi kontrolü
  });

  final List<DateTime> selectedDays;
  final VoidCallback onReset;
  final bool isEditingLocked; // 🔴 YENİ DEĞİŞKEN

  String _formatDay(DateTime date) {
    final month = DateFormat('MMMM', 'tr_TR').format(date);
    final monthTitle = month.isEmpty
        ? month
        : '${month[0].toUpperCase()}${month.substring(1)}';
    return '${date.day} $monthTitle';
  }

  @override
  Widget build(BuildContext context) {
    final sorted = List<DateTime>.from(selectedDays)..sort();
    final label = sorted.isEmpty
        ? 'Gün seçilmedi'
        : sorted.length == 1
        ? _formatDay(sorted.first)
        : '${_formatDay(sorted.first)} - ${_formatDay(sorted.last)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          // Tarih Etiketi
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.appBarBackground,
              ),
            ),
          ),

          // Sadece gün seçilmişse İkonlu "Sıfırla" butonu görünür
          if (selectedDays.isNotEmpty && !isEditingLocked)
            IconButton(
              onPressed: onReset,
              padding:
                  EdgeInsets.zero, // İkonun etrafındaki dahili boşluğu sıfırlar
              constraints:
                  const BoxConstraints(), // Genişlik sınırını kaldırarak Row içinde sağa yapışmasını sağlar
              icon: const Icon(
                Icons.refresh_rounded,
                size:
                    22, // Sadece ikon olduğu için basması kolay olsun diye hafifçe büyüttük
                color: Colors.grey, // İstediğin gri renk
              ),
            ),
        ],
      ),
    );
  }
}
