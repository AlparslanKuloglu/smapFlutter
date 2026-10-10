import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_colors.dart';

class InvoiceTableHeader extends StatelessWidget {
  const InvoiceTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE8ECF0)),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: _HeaderCell(label: 'Fatura Numarası'),
          ),
          Expanded(
            flex: 2,
            child: _HeaderCell(label: 'Kesilme Tarihi'),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 18,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }
}
