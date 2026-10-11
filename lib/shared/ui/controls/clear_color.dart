import 'dart:ui' show Color;

/// A fully transparent version of a color.
///
/// The kit never writes a raw transparent literal; "no fill" is the
/// surrounding color at 0 % opacity, so a color animation between a fill and
/// "no fill" fades the fill instead of passing through gray.
extension ClearColor on Color {
  /// This color at 0 % opacity.
  Color get clear => withValues(alpha: 0);
}
