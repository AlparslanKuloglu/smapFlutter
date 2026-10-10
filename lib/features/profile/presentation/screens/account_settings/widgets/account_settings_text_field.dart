import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_colors.dart';

class AccountSettingsTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool readOnly;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final String? hint;
  final Widget? suffixIcon; // <-- 1. Burayı ekle

  const AccountSettingsTextField({
    super.key,
    required this.label,
    required this.controller,
    this.readOnly = false,
    this.textInputAction,
    this.keyboardType,
    this.hint,
    this.suffixIcon, // <-- 2. Burayı ekle
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          // ÖNEMLİ: Tıklanabilir kalması için enabled yerine readOnly kullanıyoruz.
          // Eğer widget içinde 'enabled: !readOnly' varsa onu 'readOnly: readOnly' olarak değiştirin.
          readOnly: readOnly,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            hintText: hint,
            // Placeholder rengini daha gri ve soluk yapmak için burayı ekliyoruz:
            hintStyle: TextStyle(
              color: Colors
                  .grey
                  .shade400, // Daha soluk bir gri tonu (istiyorsan shade500 de yapabilirsin)
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE8ECF0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE8ECF0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE8ECF0)),
            ),
          ),
        ),
      ],
    );
  }
}
