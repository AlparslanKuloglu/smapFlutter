import 'package:smap/core/utils/tr_format.dart';

/// Pure layout and text rules of `AppSegmented` (C04), kept free of widgets
/// so they are unit-tested.
abstract final class SegmentLayout {
  /// Splits [available] pixels among segments in proportion to their
  /// [naturals] (the width each label needs), with [gap] between them.
  ///
  /// This is the design's "seçenek genişliği etikete göre paylaşılır": a
  /// long label gets more room than a short one, and when the labels do not
  /// fit at their natural width (text scale 1,3) each is narrowed in the
  /// same proportion and wraps instead of being cut. The returned slots are
  /// left to right, `left` measured from the first segment's edge.
  static List<({double left, double width})> slots(
    List<double> naturals,
    double available, {
    double gap = 0,
  }) {
    if (naturals.isEmpty) return const [];
    final inner = available - gap * (naturals.length - 1);
    final total = naturals.fold<double>(0, (sum, value) => sum + value);
    final slots = <({double left, double width})>[];
    var left = 0.0;
    for (final natural in naturals) {
      final share = total <= 0 ? 1 / naturals.length : natural / total;
      final width = inner <= 0 ? 0.0 : inner * share;
      slots.add((left: left, width: width));
      left += width + gap;
    }
    return slots;
  }

  /// Whether the counter goes on the title's line ("TYT · 7 eksik") instead
  /// of on a second line: only with at most two segments, and only when the
  /// longest one-line text fits in its half of the track (C04 "İki seçenekte
  /// yer yetiyorsa tek satır; 3–4 seçenekte iki satıra geçer").
  static bool counterInline({
    required int segmentCount,
    required List<double> inlineWidths,
    required double available,
    double gap = 0,
  }) {
    if (segmentCount > 2 || inlineWidths.isEmpty) return false;
    final slot = (available - gap * (segmentCount - 1)) / segmentCount;
    return inlineWidths.every((width) => width <= slot);
  }
}

/// The counter line of a segment ("28 eksik").
abstract final class SegmentCounter {
  /// `"28 eksik"` for [count] and [unit]; null when there is nothing to say:
  /// no count (no data) or a count of zero. An empty counter is not drawn
  /// (handoff 11.13 "boş sayaç çizilmez", Düzeltmeler #25); the earlier
  /// Tur 1 note "sıfırsa 'eksik yok'" is not followed. The counter always
  /// names what it counts; there is no bare number and no badge.
  ///
  /// [unit] is one of eksik, kart, soru, yanlış, boş, deneme (from l10n).
  static String? format({required int? count, required String unit}) {
    if (count == null || count <= 0) return null;
    return '${TrFormat.sira(count)} $unit';
  }
}
