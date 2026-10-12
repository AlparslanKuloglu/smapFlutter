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

  /// "Programı İptal Et" (pano 3.6 kare 1 and 4) and the screen's delete.
  ///
  /// Closed because the backend has no endpoint that deletes or cancels a
  /// program (spec §6.3 #25). While it is `false` the danger button is not
  /// drawn. Opening it also needs a delete call given to
  /// `ProgramDetailViewModel.deleteProgram`.
  static const bool programDeleteEnabled = false;

  /// "Şifre" (pano 9.3, all three frames) and its row in Hesap.
  ///
  /// Closed because the backend has no endpoint that changes the password
  /// (spec §6.3 #8, S7; the legacy screen only showed a success message). While
  /// it is `false` the row is not drawn and `PasswordRoute` is not in the
  /// router's route list. Opening it also needs a `PasswordRepository`
  /// registered in the locator.
  static const bool passwordChangeEnabled = false;

  /// Push notifications behind "Bildirimler" (pano 9.6).
  ///
  /// Closed because the backend has no preferences endpoint and no push
  /// delivery (spec D-23, T2.17, 8.4; S10). The screen is open anyway: the
  /// choices are kept on the device, and while this is `false` an info box
  /// says that notifications are planned. Opening it also means writing the
  /// choices to the server (`PUT /devices`).
  static const bool notificationsEnabled = false;
}
