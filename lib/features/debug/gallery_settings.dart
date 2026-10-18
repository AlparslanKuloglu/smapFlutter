import 'package:flutter/widgets.dart';
import 'package:smap/features/debug/launch_env.dart';

/// The three switches at the top of the component gallery: light or dark
/// theme, text scale 1,0 or 1,35, reduce motion. The gallery app applies them
/// to the theme mode and to `MediaQuery`; every page reads the same state.
///
/// The start values can be set with `--dart-define` so a screenshot run needs
/// no taps: `GALLERY_DARK=true`, `GALLERY_LARGE_TEXT=true`,
/// `GALLERY_REDUCE_MOTION=true` (and `GALLERY_PAGE=2` for the first tab, see
/// `ComponentGalleryView`).
class GallerySettings extends ChangeNotifier {
  bool _dark = _flag(
    'GALLERY_DARK',
    const bool.fromEnvironment('GALLERY_DARK'),
  );
  bool _largeText = _flag(
    'GALLERY_LARGE_TEXT',
    const bool.fromEnvironment('GALLERY_LARGE_TEXT'),
  );
  bool _reduceMotion = _flag(
    'GALLERY_REDUCE_MOTION',
    const bool.fromEnvironment('GALLERY_REDUCE_MOTION'),
  );

  /// A start value: the `--dart-define` one, or the launch value
  /// (`debugLaunchEnv`; on a simulator `tool/sim_env.sh booted
  /// GALLERY_DARK=true`), so a screenshot run needs no rebuild.
  static bool _flag(String name, bool defined) {
    final env = debugLaunchEnv(name);
    return env == null ? defined : env == 'true';
  }

  /// Dark theme on.
  bool get dark => _dark;

  /// Large text on: 1,35, a little past the design's 1,3 limit (spec §1.6)
  /// so the kit is checked with headroom (FIN14E).
  bool get largeText => _largeText;

  /// "Reduce motion" on: the same signal as the platform setting.
  bool get reduceMotion => _reduceMotion;

  /// The factor of the "Metin 1,35" switch.
  static const double largeTextScale = 1.35;

  /// The text scale factor the gallery applies.
  double get textScale => _largeText ? largeTextScale : 1;

  set dark(bool value) {
    if (_dark == value) return;
    _dark = value;
    notifyListeners();
  }

  set largeText(bool value) {
    if (_largeText == value) return;
    _largeText = value;
    notifyListeners();
  }

  set reduceMotion(bool value) {
    if (_reduceMotion == value) return;
    _reduceMotion = value;
    notifyListeners();
  }
}

/// Gives the pages of the gallery access to [GallerySettings].
class GalleryScope extends InheritedNotifier<GallerySettings> {
  const GalleryScope({
    required GallerySettings settings,
    required super.child,
    super.key,
  }) : super(notifier: settings);

  /// The settings of the nearest gallery; listens to changes.
  static GallerySettings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<GalleryScope>();
    assert(scope != null, 'No GalleryScope above this context');
    return scope!.notifier!;
  }
}
