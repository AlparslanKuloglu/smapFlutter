import 'package:studentmap/features/profile/presentation/screens/payment_settings/models/payment_invoice_item.dart';

class PaymentInvoiceMock {
  PaymentInvoiceMock._();

  static const int pageSize = 10;
  static const int totalPages = 68;

  static List<PaymentInvoiceItem> page(int page) {
    final startIndex = (page - 1) * pageSize;
    return List.generate(pageSize, (i) {
      final index = startIndex + i;
      return PaymentInvoiceItem(
        number: 'Invoice #${1023 + index}',
        date: DateTime(2022, 5, 15).subtract(Duration(days: 28 * index)),
      );
    });
  }
}
