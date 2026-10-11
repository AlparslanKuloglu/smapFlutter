import 'package:intl/intl.dart';

/// Turkish number, date and time formatting (handoff 11.1 "Biçimlendirme";
/// spec §1.11). Every number and date the UI shows goes through here, never
/// `toStringAsFixed`, a hand-written "%" or `DateFormat` in a widget.
///
/// | call | result |
/// |---|---|
/// | `net(67.5)` · `net(68)` · `net(74.75)` | `67,5` · `68` · `74,75` |
/// | `puan(412.63)` · `puan(381.4)` | `412,63` · `381,40` |
/// | `sira(48215)` · `siraOrdinal(48215)` | `48.215` · `48.215.` |
/// | `yuzde(5, 12)` | `%42` |
/// | `delta(8.25)` · `delta(-1.5)` | `+8,25` · `−1,5` |
/// | `kisaTarih(DateTime(2026, 10, 5))` | `5 Eki.` |
/// | `uzunTarih(DateTime(2026, 9, 15))` | `15 Eylül 2026` |
///
/// Numbers use intl's `tr` symbols (decimal comma, thousands dot), which
/// need no initialization. Day and month names are fixed tables here instead
/// of `DateFormat`: `DateFormat('MMM', 'tr')` throws until
/// `initializeDateFormatting('tr')` has run, and the short month needs a
/// trailing dot that intl does not give. The tables equal intl's `tr` data
/// (a test checks that).
///
/// Negative numbers use the real minus sign U+2212 (spec Ç-53), never the
/// hyphen. A value that rounds to zero is written without a sign.
abstract final class TrFormat {
  /// The real minus sign U+2212.
  static const String minus = '−';

  static final NumberFormat _net = NumberFormat('#,##0.##', 'tr');
  static final NumberFormat _puan = NumberFormat('#,##0.00', 'tr');
  static final NumberFormat _sira = NumberFormat('#,##0', 'tr');

  /// Short month names without the dot, January first.
  static const List<String> monthsShort = [
    'Oca',
    'Şub',
    'Mar',
    'Nis',
    'May',
    'Haz',
    'Tem',
    'Ağu',
    'Eyl',
    'Eki',
    'Kas',
    'Ara',
  ];

  /// Full month names, January first.
  static const List<String> months = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  /// Short day names, Monday first (index = `DateTime.weekday - 1`).
  static const List<String> weekdaysShort = [
    'Pzt',
    'Sal',
    'Çar',
    'Per',
    'Cum',
    'Cmt',
    'Paz',
  ];

  /// Full day names, Monday first (index = `DateTime.weekday - 1`).
  static const List<String> weekdays = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  /// Net, at most two decimals, no trailing zero: `68`, `67,5`, `74,75`.
  /// Nets move in quarter steps (D − Y/4).
  static String net(num value) => _signed(_net, value);

  /// Score, always two decimals: `412,63`, `381,40`.
  static String puan(num value) => _signed(_puan, value);

  /// Rank with thousands dots: `48.215`. Add the unit yourself ("sıra"); to
  /// show the number as a rank tile ("48.215.") use [siraOrdinal].
  static String sira(int value) => _signed(_sira, value);

  /// Rank with the ordinal dot, as the rank tile and "48.215. sıra" show it.
  static String siraOrdinal(int value) => '${sira(value)}.';

  /// Percentage of [part] in [total], rounded to the nearest whole number,
  /// sign first: `%42` for 5 of 12 (41.67 rounds up).
  ///
  /// [total] must be positive: with no questions the ring is not drawn and
  /// "Soru yok" is shown instead, so a caller that reaches here with zero is
  /// a bug. Use [yuzdeOrNull] where the total can be zero.
  static String yuzde(int part, int total) {
    if (total <= 0) {
      throw ArgumentError.value(total, 'total', 'must be positive');
    }
    return '%${(part * 100 / total).round()}';
  }

  /// [yuzde], or null when [total] is not positive (no data, nothing to
  /// draw).
  static String? yuzdeOrNull(int part, int total) =>
      total > 0 ? yuzde(part, total) : null;

  /// A signed change: `+8,25`, `−1,5`, and `0` for no change. Same decimals
  /// as [net], so it also serves score changes. The sign is the real minus
  /// U+2212. Green is not used for a rise: the arrow and the sign say it.
  static String delta(num value) {
    final body = net(value.abs());
    if (_isZero(body)) return '0';
    return value < 0 ? '$minus$body' : '+$body';
  }

  /// Short date with a dotted month: `5 Eki.`; with [withYear] `5 Eki. 2026`.
  /// The dot is always there, including `May.` and `Haz.`.
  static String kisaTarih(DateTime date, {bool withYear = false}) {
    final base = '${date.day} ${monthsShort[date.month - 1]}.';
    return withYear ? '$base ${date.year}' : base;
  }

  /// Long date: `15 Eylül 2026`.
  static String uzunTarih(DateTime date) =>
      '${date.day} ${months[date.month - 1]} ${date.year}';

  /// Long date with the weekday name: `12 Ekim 2026 Pazartesi`.
  static String uzunTarihGun(DateTime date) =>
      '${uzunTarih(date)} ${gunAdi(date)}';

  /// Short weekday: `Pzt`, `Sal`, `Çar`, `Per`, `Cum`, `Cmt`, `Paz`.
  static String gunKisa(DateTime date) => weekdaysShort[date.weekday - 1];

  /// Full weekday: `Pazartesi` … `Pazar`.
  static String gunAdi(DateTime date) => weekdays[date.weekday - 1];

  /// 24-hour time `16:00` from a date's time of day.
  static String saat(DateTime time) => saatParcali(time.hour, time.minute);

  /// 24-hour time `06:00` from [hour] (0 to 23) and [minute] (0 to 59).
  static String saatParcali(int hour, [int minute = 0]) {
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw RangeError('Not a time of day: $hour:$minute');
    }
    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }

  /// Formats `abs(value)` and puts U+2212 in front when the result is not
  /// zero, so `-0.001` is `0,00` and not `−0,00`.
  static String _signed(NumberFormat format, num value) {
    assert(value.isFinite, 'Cannot format $value');
    final body = format.format(value.abs());
    if (value < 0 && !_isZero(body)) return '$minus$body';
    return body;
  }

  static bool _isZero(String formatted) => !formatted.contains(RegExp('[1-9]'));
}
