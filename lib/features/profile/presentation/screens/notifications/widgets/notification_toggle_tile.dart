import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_colors.dart';

class NotificationToggleTile extends StatelessWidget {
  const NotificationToggleTile({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  static const Color _activeGreen = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: AppColors.white,
                activeTrackColor: _activeGreen,
                inactiveThumbColor: AppColors.white,
                inactiveTrackColor: const Color(0xFFE5E7EB),
                trackOutlineColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.transparent;
                  }
                  return const Color(0xFFE5E7EB);
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFE8ECF0),
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}
