import 'package:smap/features/account/domain/coach_code.dart';

/// How the coach's own code is written and read (pano 14.11): pure text
/// helpers, unit-tested.
abstract final class CoachCodeText {
  /// The code as the design writes it, `MOZK-4821`; text of another shape is
  /// shown as it is; `null` for a missing or blank code.
  static String? shown(String? raw) {
    final text = raw?.trim();
    if (text == null || text.isEmpty) return null;
    return CoachCode.tryParse(text)?.display ?? text;
  }

  /// The code read letter by letter (pano 14.11 Erişilebilirlik: "M O Z K
  /// tire 4 8 2 1"): every character apart, the dash as [dash] ("tire").
  static String spoken(String code, {required String dash}) => [
    for (final unit in code.trim().split(''))
      if (unit == '-') dash else if (unit.trim().isNotEmpty) unit,
  ].join(' ');
}
