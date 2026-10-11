import 'package:flutter/material.dart';

/// The clay "Harita" picture of the welcome screen (C61 `SmapIllustration`;
/// pano 2.2 kare 5 "Kil Harita L 160", board 1.25).
///
/// 160 x 160 with the tile's own rounded corners; nothing is drawn over it
/// (no edge, no shadow, no frame) and it does not change in the dark theme.
/// Decoration: hidden from the screen reader. Spec §1 asks for it as a 3x
/// asset (`illustrations/clay_map.webp`, `2.0x/`, `3.0x/`); the file that is
/// there now is the 140 px crop of the board, and the real one replaces it
/// under the same name. While no file exists nothing is drawn: no
/// placeholder picture stands in for it.
class ClayIllustration extends StatelessWidget {
  const ClayIllustration.map({super.key}) : _asset = mapAsset;

  final String _asset;

  /// The edge of the large clay picture (C61 "L 160").
  static const double large = 160;

  /// The asset of the map.
  static const String mapAsset = 'assets/illustrations/clay_map.webp';

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Image.asset(
        _asset,
        width: large,
        height: large,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) => const SizedBox.shrink(),
      ),
    );
  }
}
