import 'package:flutter/painting.dart';

import 'package:smap/features/home/application/avatar_asset.dart';

/// The one rule that turns the avatar file name of a student (or of the coach)
/// into a picture on the coach screens: the 3D caricature set under
/// `assets/avatars/`, whether the server wrote `1avatarN3.png` or
/// `avatars/1avatarN3.png` (see [AvatarAsset]). `null` for no photo, so the
/// avatar draws the initials; nothing is invented.
abstract final class CoachAvatars {
  /// The picture of [photo], or `null` without one.
  static ImageProvider? imageOf(String? photo) {
    final path = AvatarAsset.pathOf(photo);
    return path == null ? null : AssetImage(path);
  }
}
