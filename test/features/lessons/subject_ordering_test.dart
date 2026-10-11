import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/lessons/application/subject_ordering.dart';

typedef _S = (String, int?, bool);

void main() {
  List<String> order(List<_S> items) => SubjectOrdering.tileOrder<_S>(
    items,
    missingOf: (s) => s.$2,
    isWebOnly: (s) => s.$3,
  ).map((s) => s.$1).toList();

  group('SubjectOrdering.tileOrder', () {
    test('most missing first, web-only subjects last (Ek C)', () {
      final items = <_S>[
        ('Türkçe', 31, false),
        ('Matematik', null, true),
        ('Tarih', 60, false),
        ('Coğrafya', 44, false),
        ('Geometri', null, true),
        ('Edebiyat', 3, false),
      ];
      expect(order(items), [
        'Tarih',
        'Coğrafya',
        'Türkçe',
        'Edebiyat',
        'Matematik',
        'Geometri',
      ]);
    });

    test('an unknown count counts as zero', () {
      final items = <_S>[('a', null, false), ('b', 1, false), ('c', 0, false)];
      expect(order(items), ['b', 'a', 'c']);
    });

    test('ties keep the given order and the input is not changed', () {
      final items = <_S>[('x', 5, false), ('y', 5, false), ('z', 5, false)];
      expect(order(items), ['x', 'y', 'z']);
      expect(items.first.$1, 'x');
    });
  });
}
