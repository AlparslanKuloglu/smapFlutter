import 'package:flutter/material.dart';
import 'package:studentmap/core/theme/app_colors.dart';

class ScheduleListSearchField extends StatelessWidget {
  const ScheduleListSearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.filterActive = false,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool filterActive;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: 'Program Ara',
        hintStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.white,
        isDense: true,
        border: _border(filterActive),
        enabledBorder: _border(filterActive),
        focusedBorder: _border(filterActive),
      ),
    );
  }

  static OutlineInputBorder _border(bool filterActive) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: filterActive ? AppColors.navSelectedBg : const Color(0xFFE8ECF0),
        width: filterActive ? 1.5 : 1,
      ),
    );
  }
}
