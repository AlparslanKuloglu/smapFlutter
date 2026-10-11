import 'dart:math' as math;

/// Where one tab and its accent line sit inside an `AppTabBar` (C05).
typedef TabSlot = ({
  /// Left edge of the tappable tab box.
  double left,

  /// Width of the tab box.
  double width,

  /// Left edge of the label (and of the accent line under it).
  double labelLeft,

  /// Width of the label; the accent line is this wide.
  double labelWidth,
});

/// Pure geometry of `AppTabBar` (C05; board 1.10 "Ekran içi sekme"), kept
/// free of widgets so it is unit-tested.
abstract final class TabBarLayout {
  /// Side padding of the scrollable variant, at both ends (C05: 16).
  static const double edge = 16;

  /// Space between tabs of the scrollable variant (C05: 24).
  static const double gap = 24;

  /// Horizontal padding inside a scrollable tab (C05: "0/4").
  static const double tabPad = 4;

  /// The smallest air a label keeps inside its equal share in the fixed
  /// variant, per side; below it the bar scrolls instead.
  static const double minShareAir = 8;

  /// Whether [labelWidths] can sit in equal shares of [available] without
  /// touching: otherwise the bar becomes scrollable by itself (C05 "sığmazsa
  /// kendiliğinden").
  static bool fitsFixed(List<double> labelWidths, double available) {
    if (labelWidths.isEmpty) return true;
    final share = available / labelWidths.length;
    return labelWidths.every((w) => w + 2 * minShareAir <= share);
  }

  /// Equal flex shares, each label centered in its own.
  static List<TabSlot> fixedSlots(List<double> labelWidths, double available) {
    if (labelWidths.isEmpty) return const [];
    final share = available / labelWidths.length;
    return [
      for (final (i, w) in labelWidths.indexed)
        (
          left: i * share,
          width: share,
          labelLeft: i * share + (share - w) / 2,
          labelWidth: w,
        ),
    ];
  }

  /// Tabs in a row, [edge] at both ends and [gap] between boxes, each box
  /// its label plus [tabPad] on both sides.
  static List<TabSlot> scrollSlots(List<double> labelWidths) {
    final slots = <TabSlot>[];
    var left = edge;
    for (final w in labelWidths) {
      slots.add((
        left: left,
        width: w + 2 * tabPad,
        labelLeft: left + tabPad,
        labelWidth: w,
      ));
      left += w + 2 * tabPad + gap;
    }
    return slots;
  }

  /// Total width of the scrollable row.
  static double scrollExtent(List<TabSlot> slots) =>
      slots.isEmpty ? 0 : slots.last.left + slots.last.width + edge;

  /// The scroll offset that brings [slot] into view in a [viewport] wide
  /// window: centered when there is room, never past either end. Returns
  /// [current] unchanged when the whole tab is already inside, so a
  /// selection does not move a bar that needs no move.
  static double scrollTarget({
    required TabSlot slot,
    required double viewport,
    required double extent,
    required double current,
  }) {
    final max = math.max(0.0, extent - viewport);
    final inside =
        slot.left - edge / 2 >= current &&
        slot.left + slot.width + edge / 2 <= current + viewport;
    if (inside) return current.clamp(0.0, max);
    final centered = slot.left + slot.width / 2 - viewport / 2;
    return centered.clamp(0.0, max);
  }
}
