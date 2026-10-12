import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/coach/domain/attention_item.dart';
import 'package:smap/features/coach/presentation/widgets/attention_copy.dart';
import 'package:smap/l10n/app_localizations_tr.dart';

void main() {
  final l10n = AppLocalizationsTr();

  group('the inactive rule', () {
    test(
      'writes the day count, the last exam and its type (Ek C, pano 10.1)',
      () {
        final copy = AttentionCopy.of(
          l10n,
          AttentionItem.inactive(
            studentId: 's1',
            name: 'Alparslan Kuloğlu',
            daysSinceLastExam: 45,
            lastExamAt: DateTime(2026, 6, 17),
            examType: 'TYT',
          ),
        );

        expect(copy.sentence, '45 gündür deneme okutmadı');
        expect(copy.evidence, 'Son deneme 17 Haz. 2026 · TYT');
        expect(
          copy.semanticLabel,
          'Alparslan Kuloğlu, 45 gündür deneme okutmadı, son deneme 17 Haziran',
        );
      },
    );

    test('leaves the type out when the server sent none', () {
      final copy = AttentionCopy.of(
        l10n,
        AttentionItem.inactive(
          studentId: 's1',
          name: 'Ali',
          daysSinceLastExam: 14,
          lastExamAt: DateTime(2026, 9, 26),
        ),
      );

      expect(copy.evidence, 'Son deneme 26 Eyl. 2026');
    });

    test('draws no evidence line without the date', () {
      final copy = AttentionCopy.of(
        l10n,
        const AttentionItem.inactive(
          studentId: 's1',
          name: 'Ali',
          daysSinceLastExam: 1200,
        ),
      );

      expect(copy.sentence, '1.200 gündür deneme okutmadı');
      expect(copy.evidence, isNull);
      expect(copy.semanticLabel, 'Ali, 1.200 gündür deneme okutmadı');
    });
  });

  group('the net-drop rule', () {
    test('writes the two nets and their dates (Ek C, pano 10.1)', () {
      final copy = AttentionCopy.of(
        l10n,
        AttentionItem.netDrop(
          studentId: 's1',
          name: 'Alparslan Kuloğlu',
          examType: 'TYT',
          previousNet: 68,
          latestNet: 66.75,
          previousExamAt: DateTime(2026, 6, 17),
          latestExamAt: DateTime(2026, 8, 4),
        ),
      );

      expect(copy.sentence, 'Son iki TYT denemesinde net düştü');
      expect(copy.evidence, '68 → 66,75 · 17 Haz. ve 4 Ağu.');
      expect(
        copy.semanticLabel,
        'Alparslan Kuloğlu, Son iki TYT denemesinde net düştü',
      );
    });

    test(
      'keeps what it has: nets without dates, a sentence without a type',
      () {
        final copy = AttentionCopy.of(
          l10n,
          const AttentionItem.netDrop(
            studentId: 's1',
            name: 'Ali',
            previousNet: 40.5,
            latestNet: 38,
          ),
        );

        expect(copy.sentence, 'Son iki denemede net düştü');
        expect(copy.evidence, '40,5 → 38');
      },
    );

    test('draws no evidence line without the nets', () {
      final copy = AttentionCopy.of(
        l10n,
        const AttentionItem.netDrop(
          studentId: 's1',
          name: 'Ali',
          examType: 'AYT',
        ),
      );

      expect(copy.evidence, isNull);
    });
  });

  test('items and copies have value equality', () {
    const item = AttentionItem.inactive(
      studentId: 's1',
      name: 'Ali',
      daysSinceLastExam: 20,
    );

    expect(
      item,
      const AttentionItem.inactive(
        studentId: 's1',
        name: 'Ali',
        daysSinceLastExam: 20,
      ),
    );
    expect(AttentionCopy.of(l10n, item), AttentionCopy.of(l10n, item));
    expect(item.rule, AttentionRule.inactive);
  });
}
