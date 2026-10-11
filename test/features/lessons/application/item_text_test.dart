import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/lessons/application/item_text.dart';

void main() {
  group('ItemTextParser', () {
    test('splits the definition from the example (pano 7.3 kare 1)', () {
      final text = ItemTextParser.parse(const [
        'Bir sözcüğün akla gelen ilk anlamıdır. Sözlük anlamı da denir.',
        'Örnek: Bazı insanlar karanlıktan korkar. (Cümledeki karanlık, '
            'ışıksız anlamında kullanılmıştır.)',
      ]);

      expect(text.definition, [
        'Bir sözcüğün akla gelen ilk anlamıdır. Sözlük anlamı da denir.',
      ]);
      expect(text.examples, [
        const ItemExample(
          text: 'Bazı insanlar karanlıktan korkar.',
          explanation: 'Cümledeki karanlık, ışıksız anlamında kullanılmıştır.',
        ),
      ]);
    });

    test(
      'an explanation whose closing parenthesis is missing still splits',
      () {
        final text = ItemTextParser.parse(const [
          'Örnek: Bazı insanlar karanlıktan korkar. (Cümledeki karanlık, '
              'ışıksız anlamında kullanılmıştır. \n',
        ]);
        expect(text.examples.single.text, 'Bazı insanlar karanlıktan korkar.');
        expect(
          text.examples.single.explanation,
          'Cümledeki karanlık, ışıksız anlamında kullanılmıştır.',
        );
      },
    );

    test('an example without a closing sentence has no explanation', () {
      final text = ItemTextParser.parse(const [
        'Örnek: Yorganın yüzü kirlenmiş.',
      ]);
      expect(text.examples.single.text, 'Yorganın yüzü kirlenmiş.');
      expect(text.examples.single.explanation, isNull);
    });

    test(
      'a date in parentheses is part of the example, not its explanation',
      () {
        final text = ItemTextParser.parse(const [
          'Örnek: Malazgirt Savaşı (1071)',
        ]);
        expect(text.examples.single.text, 'Malazgirt Savaşı (1071)');
        expect(text.examples.single.explanation, isNull);
      },
    );

    test('drops the bullet marks of the old text and blank paragraphs', () {
      final text = ItemTextParser.parse(const [
        '• Tanım.',
        '  ',
        '- Örnek 2: Bir.',
      ]);
      expect(text.definition, ['Tanım.']);
      expect(text.examples.single.text, 'Bir.');
    });

    test('keeps several examples in order', () {
      final text = ItemTextParser.parse(const [
        'Örnek 1: Birinci.',
        'Tanım.',
        'Örnek 2: İkinci.',
      ]);
      expect(text.examples.map((e) => e.text), ['Birinci.', 'İkinci.']);
      expect(text.definition, ['Tanım.']);
    });

    test('a paragraph that only starts with the word is a definition', () {
      final text = ItemTextParser.parse(const ['Örneklem, evrenden seçilir.']);
      expect(text.examples, isEmpty);
      expect(text.definition, ['Örneklem, evrenden seçilir.']);
    });

    test('an empty marker is dropped', () {
      final text = ItemTextParser.parse(const ['Örnek:']);
      expect(text.examples, isEmpty);
      expect(text.definition, ['Örnek:']);
    });

    test('nothing in, nothing out', () {
      expect(ItemTextParser.parse(const []).isEmpty, isTrue);
    });

    test('is equal by value', () {
      expect(
        ItemTextParser.parse(const ['A.', 'Örnek: B.']),
        ItemTextParser.parse(const ['A.', 'Örnek: B.']),
      );
    });
  });
}
