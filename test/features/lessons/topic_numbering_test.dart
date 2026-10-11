import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/lessons/application/topic_numbering.dart';

void main() {
  const turkce = [
    'Sözcükte Anlam',
    'Cümlede Anlam',
    'Ses Bilgisi',
    'Yazım Kuralları',
    'Anlatım Yöntemleri',
    'Paragraf',
    'Söz Öbekleri',
    'Cümlenin Öğeleri',
    'Fiilde Çatı',
    'Cümle Türleri',
    'Anlatım Bozuklukları',
    'Noktalama İşaretleri',
  ];

  group('TopicNumbering', () {
    test('numbers run 1 to n without a gap, in the given order', () {
      final numbered = TopicNumbering.number(turkce);
      expect(numbered.map((t) => t.number), [for (var i = 1; i <= 12; i++) i]);
      expect(numbered[8].topic, 'Fiilde Çatı');
      expect(numbered[8].number, 9);
    });

    test('a filtered list keeps the numbers of the full list', () {
      final numbered = TopicNumbering.filter(
        turkce,
        (topic) => topic.startsWith('Cümle'),
      );
      expect(numbered.map((t) => t.number), [2, 8, 10]);
      expect(numbered.first, const NumberedTopic(2, 'Cümlede Anlam'));
    });

    test('an empty list has no numbers', () {
      expect(TopicNumbering.number(<String>[]), isEmpty);
      expect(TopicNumbering.filter(turkce, (_) => false), isEmpty);
    });
  });
}
