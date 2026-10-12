import 'dart:ui' show Color;

import 'package:smap/core/theme/smap_colors.dart';

/// The translucent surfaces of the camera stages, derived from the dark
/// theme's roles (spec C67: "rgba(10,20,36,.64)" is `bgCanvas` of the dark
/// theme at 64 %, the dimmed outside of the guide is the dark `scrim`).
///
/// Use them only under `SmapTheme.dark()`: the camera stages force it
/// ("Kamera aşaması her temada koyudur", pano 4.3).
extension CameraTones on SmapColors {
  /// The page behind the preview and behind the camera failure screen: the
  /// darkest role at full strength.
  Color get cameraGround => scrim.withValues(alpha: 1);

  /// The dimmed outside of the guide frame (`rgba(0,0,0,.48)`).
  Color get cameraVeil => scrim.withValues(alpha: 0.48);

  /// The dimmed outside of the quadrilateral on the corner screen
  /// (`rgba(0,0,0,.55)`).
  Color get cameraVeilStrong => scrim.withValues(alpha: 0.55);

  /// The 40 pt buttons over the preview (`rgba(10,20,36,.64)`).
  Color get cameraChrome => bgCanvas.withValues(alpha: 0.64);

  /// The hint pill (`rgba(10,20,36,.80)`).
  Color get cameraPill => bgCanvas.withValues(alpha: 0.80);

  /// The band under the corner screen (`rgba(10,20,36,.92)`).
  Color get cameraBand => bgCanvas.withValues(alpha: 0.92);
}
