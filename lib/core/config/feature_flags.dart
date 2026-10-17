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

  /// The optical reading service is on ("okuma açık" flag; pano 4.10 kare 2,
  /// spec T2.16).
  ///
  /// Open (`true`) until the backend can tell the app when the reading is in
  /// maintenance (spec §6.3 #4 "Bakım bayrağı"; there is no such endpoint yet).
  /// When it is `false` "Okut" does not open the camera: it shows the sheet
  /// "Optik okuma şu an kapalı". Today a 503 from the reading host is the other
  /// way the same words appear (after the first upload).
  static const bool omrEnabled = true;

  /// Photos taken without a connection are kept on the phone and sent later
  /// (pano 4.10 kare 3 "Bağlantı yok · planlı"; spec T2.15).
  ///
  /// Closed because the queue does not exist: in v1 an upload that fails for
  /// want of a connection shows the failure of pano 4.5 kare 4 ("Formun
  /// gönderilemedi", "Tekrar Dene", "Yeni Fotoğraf") and keeps the photo on
  /// that screen. Opening it also needs the queue itself; the screen of
  /// pano 4.10 kare 3 is built and waits behind this flag.
  static const bool offlineQueueEnabled = false;

  /// "Dikkat gerektirenler" on the coach home (pano 10.1 kare 1 and 2).
  ///
  /// Closed because the backend has no endpoint that works out the two rules
  /// of D-27 (no exam read for 14 days, the net fell in the last two exams of
  /// a type) and sends the evidence (spec §6.3 #28, #29). While it is `false`
  /// the whole section, its skeleton and its empty card are not drawn: the
  /// board's empty card would claim that nobody needs attention, which nobody
  /// has checked. Opening it also needs an `AttentionRepository` registered in
  /// the locator.
  static const bool attentionListEnabled = false;

  /// A coach sets up and edits a student's program (Tur 12 A, pano 14.1 to
  /// 14.3; "Düzenle", "Yeni Program", "Program Kur" and the notice "Bu
  /// programı Alparslan da görür ve düzenleyebilir.").
  ///
  /// Open (`true`) on the assumption that the server writes what a coach
  /// sends with `?studentId=` into the student's own account (T12.8, an open
  /// question to the backend). Set it to `false` if it does not: the Program
  /// tab then goes back to the read-only behavior of pano 10.4 kare 3 (no
  /// "Düzenle", no "Yeni Program", no "Program Kur", no notice; the programs
  /// and the "Programlar" row stay) and `NewProgramRoute` is no longer
  /// reachable with a student. The two ViewModels take the value through a
  /// constructor argument (`coachWriteEnabled`), so both states are tested.
  static const bool coachProgramWriteEnabled = true;

  /// A coach can sign up in the app (pano 2.2 kare 1 "SMAP'i nasıl
  /// kullanacaksın?" and pano 2.5 kare 3 "Kayıt · koç").
  ///
  /// Closed because the owner took the "Öğrenci / Koç" choice out of the live
  /// app's sign-up form (origin/main, commit e615595, 2026-10-17): an account
  /// made there is always a student (`userType` 1), and coach accounts are
  /// opened outside the sign-up screen; coaches only use "Giriş Yap". While
  /// it is `false` the role step of the intro flow is not shown (the flow goes
  /// from the intro to the grade step with the student role, and a draft that
  /// holds a coach falls back to a student), and the sign-up screen draws no
  /// role segment and always sends a student. The welcome screen, "Giriş Yap"
  /// and the coach's sign-in stay as they are (the role is read from the
  /// account). Open it (`true`) to bring the role step and the coach sign-up
  /// of the boards back, as they were; the owner decides when. The
  /// ViewModels and the draft store take the value through a constructor
  /// argument (`coachSignUpEnabled`), so both states are tested.
  static const bool coachSignUpEnabled = false;
}
