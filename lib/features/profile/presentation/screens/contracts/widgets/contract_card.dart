import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_colors.dart';

class ContractCard extends StatelessWidget {
  const ContractCard({
    super.key,
    required this.title,
    required this.isApproved,
    required this.onApprovedChanged,
    this.onViewTap,
  });

  final String title;
  final bool isApproved;
  final ValueChanged<bool> onApprovedChanged;
  final VoidCallback? onViewTap;

  static const Color _checkedGreen = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8ECF0)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/contract_icon.png',
                width: 52,
                height: 52,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: onViewTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                icon: const Icon(
                  Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          /*
          Material(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => onApprovedChanged(!isApproved),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ApprovalCheckbox(value: isApproved),
                    const SizedBox(width: 10),
                    const Text(
                      'Okudum, onaylıyorum',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          */
        ],
      ),
    );
  }
}

class _ApprovalCheckbox extends StatelessWidget {
  const _ApprovalCheckbox({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: value ? ContractCard._checkedGreen : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: value
            ? null
            : Border.all(color: const Color(0xFFD1D5DB), width: 1.5),
      ),
      alignment: Alignment.center,
      child: value
          ? const Icon(Icons.check_rounded, color: AppColors.white, size: 16)
          : null,
    );
  }
}
