import 'package:flutter/material.dart';
import 'package:smap/features/shared/presentation/widgets/navy_header_band.dart';

/// Anasayfa [HomeLessonsCards] üstündeki lacivert bant — ölçüler birebir aynı.
class HomeNavyHeaderBand extends StatelessWidget {
  const HomeNavyHeaderBand({
    super.key,
    this.bottomRadius = defaultBottomRadius,
  });

  /// [HomeLessonsCards.rowHeight] ile aynı.
  static const double rowHeight = 120;

  /// Anasayfadaki bant yüksekliği (`rowHeight / 2`).
  static const double bandHeight = rowHeight / 2;

  static const double defaultBottomRadius = 32;

  final double bottomRadius;

  @override
  Widget build(BuildContext context) {
    return NavyHeaderBand(height: bandHeight, bottomRadius: bottomRadius);
  }
}
