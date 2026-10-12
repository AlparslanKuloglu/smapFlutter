import 'package:flutter/widgets.dart';
import 'package:smap/features/debug/launch_env.dart';

/// The three switches at the top of the component gallery: light or dark
/// theme, text scale 1,0 or 1,3, reduce motion. The gallery app applies them
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

  /// A start value: the `--dart-define` one, or the process environment
  /// (`SIMCTL_CHILD_GALLERY_DARK=true xcrun simctl launch …` reaches the app
  /// as `GALLERY_DARK`), so a screenshot run needs no rebuild.
  static bool _flag(String name, bool defined) {
    final env = debugLaunchEnv(name);
    return env == null ? defined : env == 'true';
  }

  /// Dark theme on.
  bool get dark => _dark;

  /// Text scale 1,3 on (the accessibility limit of the design, spec §1.6).
  bool get largeText => _largeText;

  /// "Reduce motion" on: the same signal as the platform setting.
  bool get reduceMotion => _reduceMotion;

  /// The text scale factor the gallery applies.
  double get textScale => _largeText ? 1.3 : 1;

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
