import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_colors.dart';

class AddLessonsCompleteButton extends StatelessWidget {
  const AddLessonsCompleteButton({
    super.key,
    required this.isInitialSchedule, // Dışarıdan bir program yüklenip yüklenmediği
    required this.isEditMode, // Düzenleme modunun aktif olup olmadığı
    this.onEditPressed, // "Programı Düzenle" buton aksiyonu
    this.onSavePressed, // "Değişiklikleri Kaydet" buton aksiyonu
    this.onCancelPressed, // "Değişiklikleri İptal Et" buton aksiyonu
    this.isLoading = false,
  });

  final bool isInitialSchedule;
  final bool isEditMode;
  final VoidCallback? onEditPressed;
  final ValueChanged<bool>?
  onSavePressed; // bool parametre alacak şekilde değiştirdik
  final VoidCallback? onCancelPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    // 1. DURUM: Dışarıdan yüklenen program var ama henüz "Düzenle" butonuna basılmadı
    if (isInitialSchedule && !isEditMode) {
      return _buildActionButton(
        text: 'Programı Düzenle',
        icon: Icons.edit_rounded,
        color: AppColors.primaryOrange,
        onTap: onEditPressed,
      );
    }

    // 2. DURUM: Düzenleme modu aktif (Kaydet ve İptal yan yana gelecek)
    if (isEditMode) {
      final effectiveOnSave = isLoading
          ? null
          : () => onSavePressed?.call(true); // true = Güncelleme (Update)
      final buttonColor = isLoading
          ? Colors.grey[400]
          : AppColors.primaryOrange;
      final shadowColor = isLoading
          ? Colors.transparent
          : AppColors.orangeShadow;

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔴 İPTAL ET / VAZGEÇ BUTONU (Sadece yüklenme bittiğinde görünür)
          if (!isLoading) ...[
            Material(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onCancelPressed,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          // 🟢 DEĞİŞİKLİKLERİ KAYDET BUTONU
          Material(
            color: buttonColor,
            borderRadius: BorderRadius.circular(12),
            elevation: isLoading ? 0 : 4,
            shadowColor: shadowColor,
            child: InkWell(
              onTap: effectiveOnSave,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isLoading ? Colors.transparent : AppColors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.published_with_changes_rounded,
                              size: 16,
                              color: AppColors.primaryOrange,
                            ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isLoading ? 'Kaydediliyor...' : 'Değişiklikleri Kaydet',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // 3. DURUM: Sıfırdan yeni program oluşturma modu (initialSchedule yok)
    return _buildActionButton(
      text: 'Programı Tamamla',
      icon: Icons.done_all_rounded,
      color: AppColors.primaryOrange,
      onTap: onSavePressed != null
          ? () => onSavePressed!(false)
          : null, // false = Yeni Kayıt (Create)
    );
  }

  // Ortak şık buton iskeleti
  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      shadowColor: AppColors.orangeShadow,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
