import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:smap/core/utils/tr_format.dart';

void main() {
  group('net (67,5 · 68, no trailing zero)', () {
    final cases = <num, String>{
      68: '68',
      67.5: '67,5',
      74.75: '74,75',
      0: '0',
      0.25: '0,25',
      120: '120',
      160: '160',
      1234.5: '1.234,5',
      67.499999: '67,5',
      -1.25: '−1,25',
      -0.5: '−0,5',
      -0.001: '0',
    };
    cases.forEach((value, expected) {
      test('$value -> $expected', () => expect(TrFormat.net(value), expected));
    });

    test('an int and a double with the same value agree', () {
      expect(TrFormat.net(68), TrFormat.net(68.0));
    });
  });

  group('puan (412,63 · two decimals)', () {
    final cases = <num, String>{
      412.63: '412,63',
      381.4: '381,40',
      500: '500,00',
      0: '0,00',
      1234.5: '1.234,50',
      99.999: '100,00',
      -12.5: '−12,50',
      -0.001: '0,00',
    };
    cases.forEach((value, expected) {
      test('$value -> $expected', () => expect(TrFormat.puan(value), expected));
    });
  });

  group('sira (48.215)', () {
    const cases = <int, String>{
      1: '1',
      999: '999',
      1000: '1.000',
      48215: '48.215',
      1234567: '1.234.567',
      0: '0',
    };
    cases.forEach((value, expected) {
      test('$value -> $expected', () => expect(TrFormat.sira(value), expected));
    });

    test('siraOrdinal adds the dot of the rank tile', () {
      expect(TrFormat.siraOrdinal(48215), '48.215.');
      expect(TrFormat.siraOrdinal(3), '3.');
    });
  });

  group('yuzde (%42, nearest whole number, sign first)', () {
    const cases = <(int, int), String>{
      (5, 12): '%42', // 41.67 rounds up, not down to 41
      (0, 10): '%0',
      (10, 10): '%100',
      (1, 3): '%33',
      (2, 3): '%67',
      (1, 8): '%13', // 12.5 rounds half up
      (74, 160): '%46',
      (160, 160): '%100',
    };
    cases.forEach((value, expected) {
      test('${value.$1} of ${value.$2} -> $expected', () {
        expect(TrFormat.yuzde(value.$1, value.$2), expected);
      });
    });

    test('a zero total is a bug for yuzde and null for yuzdeOrNull', () {
      expect(() => TrFormat.yuzde(1, 0), throwsArgumentError);
      expect(TrFormat.yuzdeOrNull(1, 0), isNull);
      expect(TrFormat.yuzdeOrNull(5, 12), '%42');
    });
  });

  group('delta (+8,25 · real minus)', () {
    final cases = <num, String>{
      8.25: '+8,25',
      3: '+3',
      -1.5: '−1,5',
      -1.25: '−1,25',
      0: '0',
      0.001: '0',
      -0.001: '0',
      12.5: '+12,5',
      -1234.5: '−1.234,5',
    };
    cases.forEach((value, expected) {
      test(
        '$value -> $expected',
        () => expect(TrFormat.delta(value), expected),
      );
    });

    test('the minus is U+2212, never a hyphen', () {
      expect(TrFormat.minus.codeUnitAt(0), 0x2212);
      for (final text in [
        TrFormat.delta(-2),
        TrFormat.net(-2),
        TrFormat.puan(-2),
      ]) {
        expect(text.contains('-'), isFalse, reason: text);
        expect(text.startsWith('−'), isTrue, reason: text);
      }
    });
  });

  group('dates', () {
    test('kisaTarih has a dotted month', () {
      expect(TrFormat.kisaTarih(DateTime(2026, 10, 5)), '5 Eki.');
      expect(TrFormat.kisaTarih(DateTime(2026, 9, 15)), '15 Eyl.');
      expect(TrFormat.kisaTarih(DateTime(2026, 5, 1)), '1 May.');
      expect(TrFormat.kisaTarih(DateTime(2026, 6, 30)), '30 Haz.');
      expect(TrFormat.kisaTarih(DateTime(2026, 8, 8)), '8 Ağu.');
      expect(TrFormat.kisaTarih(DateTime(2026, 4, 2)), '2 Nis.');
      expect(TrFormat.kisaTarih(DateTime(2026, 12, 31)), '31 Ara.');
      expect(TrFormat.kisaTarih(DateTime(2026, 1, 1)), '1 Oca.');
    });

    test('kisaTarih with the year', () {
      expect(
        TrFormat.kisaTarih(DateTime(2026, 10, 5), withYear: true),
        '5 Eki. 2026',
      );
    });

    test('uzunTarih', () {
      expect(TrFormat.uzunTarih(DateTime(2026, 9, 15)), '15 Eylül 2026');
      expect(TrFormat.uzunTarih(DateTime(2026, 3, 1)), '1 Mart 2026');
      expect(TrFormat.uzunTarih(DateTime(2027, 6, 20)), '20 Haziran 2027');
    });

    test('uzunTarihGun is the coach meeting line of the spec', () {
      expect(
        TrFormat.uzunTarihGun(DateTime(2026, 10, 12)),
        '12 Ekim 2026 Pazartesi',
      );
    });

    test('weekday names, Monday first (5 Oct 2026 is a Monday)', () {
      final week = [for (var d = 5; d <= 11; d++) DateTime(2026, 10, d)];
      expect(week.map(TrFormat.gunKisa), [
        'Pzt',
        'Sal',
        'Çar',
        'Per',
        'Cum',
        'Cmt',
        'Paz',
      ]);
      expect(week.map(TrFormat.gunAdi), [
        'Pazartesi',
        'Salı',
        'Çarşamba',
        'Perşembe',
        'Cuma',
        'Cumartesi',
        'Pazar',
      ]);
    });

    test('all twelve months and seven days have a name', () {
      expect(TrFormat.months.length, 12);
      expect(TrFormat.monthsShort.length, 12);
      expect(TrFormat.weekdays.length, 7);
      expect(TrFormat.weekdaysShort.length, 7);
    });
  });

  group('time (24 hour)', () {
    test('saat', () {
      expect(TrFormat.saat(DateTime(2026, 10, 5, 16)), '16:00');
      expect(TrFormat.saat(DateTime(2026, 10, 5, 6, 5)), '06:05');
      expect(TrFormat.saat(DateTime(2026, 10, 5)), '00:00');
      expect(TrFormat.saat(DateTime(2026, 10, 5, 23, 59)), '23:59');
    });

    test('saatParcali', () {
      expect(TrFormat.saatParcali(6), '06:00');
      expect(TrFormat.saatParcali(10), '10:00');
      expect(TrFormat.saatParcali(23, 5), '23:05');
    });

    test('an hour outside the day is a bug', () {
      expect(() => TrFormat.saatParcali(24), throwsRangeError);
      expect(() => TrFormat.saatParcali(-1), throwsRangeError);
      expect(() => TrFormat.saatParcali(5, 60), throwsRangeError);
    });
  });

  group('the name tables equal intl tr data', () {
    setUpAll(() => initializeDateFormatting('tr'));

    test('months and weekdays', () {
      final short = DateFormat('MMM', 'tr');
      final long = DateFormat('MMMM', 'tr');
      for (var m = 1; m <= 12; m++) {
        final date = DateTime(2026, m, 15);
        expect(
          TrFormat.monthsShort[m - 1],
          short.format(date),
          reason: 'month $m short',
        );
        expect(TrFormat.months[m - 1], long.format(date), reason: 'month $m');
      }
      final shortDay = DateFormat('EEE', 'tr');
      final longDay = DateFormat('EEEE', 'tr');
      for (var d = 5; d <= 11; d++) {
        final date = DateTime(2026, 10, d);
        expect(
          TrFormat.gunKisa(date),
          shortDay.format(date),
          reason: 'day $d short',
        );
        expect(TrFormat.gunAdi(date), longDay.format(date), reason: 'day $d');
      }
    });

    test('the spec pattern "d MMMM y" gives the same long date', () {
      final date = DateTime(2026, 9, 15);
      expect(
        TrFormat.uzunTarih(date),
        DateFormat('d MMMM y', 'tr').format(date),
      );
    });
  });
}
