import 'package:smap/core/theme/app_motion.dart';

/// Which way a card left the deck.
enum DeckExit {
  /// Dragged to the left.
  left,

  /// Dragged to the right; also where "Öğrendim" sends the card.
  right;

  /// The sign of the horizontal travel: -1 or 1.
  double get sign => this == left ? -1 : 1;
}

/// When a dragged card leaves and when it comes back (pano 8.1 "Hareket ve
/// haptik"; spec C52).
///
/// The card follows the finger; on release it leaves when it has been dragged
/// past [AppMotion.swipeCommitFraction] of its width (30 %) or is flung faster
/// than [AppMotion.swipeCommitVelocity] (800 px/s) in the direction it was
/// dragged, otherwise it springs back. Pure and unit-tested.
abstract final class DeckSwipe {
  /// The way the card leaves, or `null` when it comes back.
  ///
  /// [dx] is how far it was dragged from rest (negative to the left),
  /// [velocityX] its horizontal speed on release in px/s, [width] the card's
  /// width. A fling against the drag, or one with no drag at all, is a
  /// cancelled gesture.
  static DeckExit? verdict({
    required double dx,
    required double velocityX,
    required double width,
  }) {
    if (width <= 0 || dx == 0) return null;
    final exit = dx < 0 ? DeckExit.left : DeckExit.right;
    final far = dx.abs() >= width * AppMotion.swipeCommitFraction;
    final fast =
        velocityX.abs() >= AppMotion.swipeCommitVelocity &&
        velocityX.sign == dx.sign;
    return far || fast ? exit : null;
  }

  /// How far the next card has come forward while the top card is dragged
  /// [dx]: 0 at rest, 1 when the top card is a full card width away.
  static double reveal({required double dx, required double width}) =>
      width <= 0 ? 0 : (dx.abs() / width).clamp(0.0, 1.0);
}
