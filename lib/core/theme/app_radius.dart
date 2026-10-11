import 'package:flutter/painting.dart';

/// Corner radii (handoff 11.12; spec §1.12): five steps and a full pill.
///
/// The names come from the design: "radius-md" is 12. mihr_ui's
/// `MihrRadius.md` is 8, so screen code uses `AppRadius`, never
/// `MihrRadius` (spec §9.11), and never `BorderRadius.circular(n)`.
///
/// Nested surfaces: inner radius = outer radius minus the gap between them
/// ([inner]); a 16 card with an 8 gap has 8 inside.
abstract final class AppRadius {
  /// `radius-xs` 4: checkbox, chart bar end, search highlight.
  static const double xs = 4;

  /// `radius-sm` 8: segment thumb, question cell, tag, cover thumbnail,
  /// tooltip and chart balloon, skeleton block.
  static const double sm = 8;

  /// `radius-md` 12: button, input, segment track, glyph tile, banner,
  /// toast, status box.
  static const double md = 12;

  /// `radius-lg` 16: card, list group, stat box, camera button.
  static const double lg = 16;

  /// `radius-xl` 24: sheet top corners, band bottom corners, bottom bar top
  /// corners, info card.
  static const double xl = 24;

  /// `radius-full` 999: chip, badge, avatar, progress bar, switch, handle.
  static const double full = 999;

  static const Radius radiusXs = Radius.circular(xs);
  static const Radius radiusSm = Radius.circular(sm);
  static const Radius radiusMd = Radius.circular(md);
  static const Radius radiusLg = Radius.circular(lg);
  static const Radius radiusXl = Radius.circular(xl);
  static const Radius radiusFull = Radius.circular(full);

  static const BorderRadius borderXs = BorderRadius.all(radiusXs);
  static const BorderRadius borderSm = BorderRadius.all(radiusSm);
  static const BorderRadius borderMd = BorderRadius.all(radiusMd);
  static const BorderRadius borderLg = BorderRadius.all(radiusLg);
  static const BorderRadius borderXl = BorderRadius.all(radiusXl);
  static const BorderRadius borderFull = BorderRadius.all(radiusFull);

  /// Sheet: top corners `xl`, square bottom.
  static const BorderRadius sheetTop = BorderRadius.vertical(top: radiusXl);

  /// Root band: bottom corners `xl`, square top.
  static const BorderRadius bandBottom = BorderRadius.vertical(
    bottom: radiusXl,
  );

  /// Bottom bar: top corners `xl`, square bottom.
  static const BorderRadius barTop = BorderRadius.vertical(top: radiusXl);

  /// The radius of a surface nested [gap] inside a surface of radius
  /// [outer]: `outer - gap`, never below 0.
  static double inner(double outer, double gap) {
    final value = outer - gap;
    return value < 0 ? 0 : value;
  }
}
