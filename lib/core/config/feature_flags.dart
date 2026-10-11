/// Features that wait for the backend (spec §6.4 "Feature flag'ler").
///
/// A flag is a compile-time constant: a closed feature is not built into the
/// route list and its entry points are not drawn. Flip one to `true` in the
/// same change that lands the endpoint it waits for.
///
/// Only the flags that are in use today are listed here; a task that needs
/// another one from spec §6.4 adds it with its own doc comment.
abstract final class FeatureFlags {
  /// "Şifremi Unuttum" (pano 2.3 kare 1 and the whole of pano 2.4).
  ///
  /// Closed because the backend has no endpoint to send a reset code, check
  /// it or set the new password (spec §6.3 #7, D-18). While it is `false` the
  /// link on the sign-in screen is not drawn and `ForgotPasswordRoute` is not
  /// in the router's route list. Opening it also needs a
  /// `ForgotPasswordRepository` registered in the locator.
  static const bool forgotPasswordEnabled = false;

  /// "Apple ile Devam Et" / "Google ile Devam Et" (pano 2.3 kare 4, D-17).
  ///
  /// Closed because the official Apple and Google button assets, the Apple
  /// package and the server endpoint do not exist yet (spec §6.3 #17).
  static const bool socialLoginEnabled = false;
}
