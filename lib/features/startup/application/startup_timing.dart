/// Time constants of the launch screen (pano 2.1 kare 1).
abstract final class StartupTiming {
  /// The spinner under the logo appears when opening takes longer than this
  /// ("1 sn'den uzun sürerse işaretin altında spinner").
  static const Duration spinnerDelay = Duration(seconds: 1);

  /// How long the native splash waits for `SessionManager.restore()` before it
  /// gives way to the launch screen (and its spinner).
  static const Duration nativeSplashPatience = spinnerDelay;
}
