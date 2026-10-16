import 'package:flutter/material.dart';
import 'package:studentmap/core/theme/app_colors.dart';
import 'package:studentmap/features/profile/presentation/screens/payment_settings/models/payment_invoice_item.dart';

class InvoiceRow extends StatelessWidget {
  const InvoiceRow({super.key, required this.invoice});

  final PaymentInvoiceItem invoice;

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String _formatDate(DateTime date) =>
      '${_months[date.month - 1]} ${date.day}, ${date.year}';

  @override
  Widget build(BuildContext context) {
    final dateText = _formatDate(invoice.date);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE8ECF0))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              invoice.number,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              dateText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
