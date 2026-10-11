import 'package:flutter_test/flutter_test.dart';
import 'package:smap/l10n/app_localizations_tr.dart';

void main() {
  final l10n = AppLocalizationsTr();

  group('D/Y/B reading (one sentence)', () {
    test('86 / 74 / 0 keeps the zero blank', () {
      expect(l10n.exams_dybA11y(86, 74, 0), '86 doğru, 74 yanlış, 0 boş');
    });

    test('80 / 21 / 19', () {
      expect(l10n.exams_dybA11y(80, 21, 19), '80 doğru, 21 yanlış, 19 boş');
    });
  });

  group('question cell reading', () {
    test('wrong with a key', () {
      expect(
        l10n.exams_questionWrongA11y(7, 'C', 'A'),
        'Soru 7, yanlış, işaretin C, doğru cevap A',
      );
    });

    test('blank with a key', () {
      expect(
        l10n.exams_questionBlankA11y(3, 'D'),
        'Soru 3, boş, doğru cevap D',
      );
    });

    test('form check', () {
      expect(
        l10n.exams_formCheckBlankA11y(12),
        '12. soru, boş okundu, düzeltmek için dokun',
      );
      expect(
        l10n.exams_formCheckCorrectedA11y(12, 'C'),
        '12. soru, düzeltildi: C',
      );
    });
  });
}
