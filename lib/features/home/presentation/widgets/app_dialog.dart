import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_colors.dart';

abstract class AppDialogs {
  /// Uygulama genelinde kullanılabilir sade duyuru, ön kayıt ve bilgi pop-up'ı
  /// [buttonType]: 1 -> Yayınlandığında Haber Ver (Default), 2 -> Detaylı Bilgi Al
  static void showUnderConstruction(
    BuildContext context, {
    String? title,
    String? desc,
    String? detailDesc,
    String? imagePath,
    Color accentColor = Colors.indigo,
    int buttonType = 1,
    VoidCallback? onNotifyMe, // Tip 1 için
    VoidCallback? onGetInfo, // Tip 2 için
  }) {
    showDialog(
      context: context,
      builder: (context) {
        bool isSubmitted = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: const EdgeInsets.all(24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // İkon / Görsel Alanı
                  Container(
                    width: 72,
                    height: 72,
                    padding: const EdgeInsets.all(16),
                    child: imagePath != null && imagePath.isNotEmpty
                        ? Image.asset(imagePath, fit: BoxFit.contain)
                        : Icon(
                            Icons.construction_rounded,
                            color: accentColor,
                            size: 36,
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Başlık
                  Text(
                    title ?? "Çok Yakında!",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.primaryOrange,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Ana Açıklama Metni
                  if (desc != null && desc.isNotEmpty) ...[
                    Text(
                      desc,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF334155),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Detay Metni
                  Text(
                    detailDesc ??
                        (buttonType == 2
                            ? "Bu modül hakkında detaylı bilgi almak veya taleplerinizi iletmek için bizimle iletişime geçebilirsiniz."
                            : "Bu özellik henüz geliştirilme aşamasındadır. Yayınlandığında ilk sizin haberiniz olsun ister misiniz?"),
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Tip 2: Detaylı Bilgi Al
                  if (buttonType == 2)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSubmitted
                              ? Colors.green
                              : accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (!isSubmitted) {
                            setState(() {
                              isSubmitted = true;
                            });
                            if (onGetInfo != null) onGetInfo();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        icon: Icon(
                          isSubmitted
                              ? Icons.check_circle_rounded
                              : Icons.notifications_active_rounded,
                          size: 18,
                        ),
                        label: Text(
                          isSubmitted ? "Talebiniz Alındı" : "Detaylı Bilgi Al",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  // Tip 1: Yayınlandığında Haber Ver (Default)
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSubmitted
                              ? Colors.green
                              : accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (!isSubmitted) {
                            setState(() {
                              isSubmitted = true;
                            });
                            if (onNotifyMe != null) onNotifyMe();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        icon: Icon(
                          isSubmitted
                              ? Icons.check_circle_rounded
                              : Icons.notifications_active_rounded,
                          size: 18,
                        ),
                        label: Text(
                          isSubmitted
                              ? "Kaydınız Alındı"
                              : "Yayınlandığında Haber Ver",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Kapatma Bağlantısı
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Kapat",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
