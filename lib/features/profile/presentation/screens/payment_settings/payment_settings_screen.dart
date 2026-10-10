import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_colors.dart';
import 'package:smap/features/profile/presentation/screens/payment_settings/data/payment_invoice_mock.dart';
import 'package:smap/features/profile/presentation/screens/payment_settings/widgets/current_plan_card.dart';
import 'package:smap/features/profile/presentation/screens/payment_settings/widgets/invoice_pagination.dart';
import 'package:smap/features/profile/presentation/screens/payment_settings/widgets/invoice_row.dart';
import 'package:smap/features/profile/presentation/screens/payment_settings/widgets/invoice_table_header.dart';

class PaymentSettingsScreen extends StatefulWidget {
  const PaymentSettingsScreen({super.key});

  @override
  State<PaymentSettingsScreen> createState() => _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends State<PaymentSettingsScreen> {
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    final invoices = PaymentInvoiceMock.page(_currentPage);

    return ColoredBox(
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CurrentPlanCard(),
            const SizedBox(height: 16),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8ECF0)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    children: [
                      const InvoiceTableHeader(),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: invoices.length,
                          itemBuilder: (_, index) =>
                              InvoiceRow(invoice: invoices[index]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            InvoicePagination(
              currentPage: _currentPage,
              totalPages: PaymentInvoiceMock.totalPages,
              onPageChanged: (page) => setState(() => _currentPage = page),
            ),
          ],
        ),
      ),
    );
  }
}
