import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('tr')];

  /// Sentence of the screen-level error state of Koçluk (pano 2.18 'Ekran hatası metni').
  ///
  /// In tr, this message translates to:
  /// **'Bağlantını kontrol edip tekrar dene. Sorun sürerse biraz sonra yeniden açabilirsin.'**
  String get accountSettings_loadErrorMessage;

  /// Toast and inline text when a change of the account settings (password, coach link, unlink) could not be sent (pano 1.22 kare 1 error toast wording).
  ///
  /// In tr, this message translates to:
  /// **'Gönderilemedi. Bağlantını kontrol edip tekrar dene.'**
  String get accountSettings_sendFailed;

  /// Part of the profile summary reading of a coach (pano 9.1 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'koçluk kodu {code}'**
  String account_a11yCoachCode(String code);

  /// Part of the profile summary reading: the student's coach (pano 9.1 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'koçun {name}'**
  String account_a11yCoachOf(String name);

  /// Part of the profile summary reading of a coach (pano 9.1 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'öğrenci koçu'**
  String get account_a11yCoachRole;

  /// Hint of the profile summary button (pano 9.1: "tek dokunma alanı, Profil'i açar").
  ///
  /// In tr, this message translates to:
  /// **'Profili açar'**
  String get account_a11yOpensProfile;

  /// Reading of the profile summary (C37, pano 9.1): "Profil: Alparslan Kuloğlu, 12. Sınıf, Eşit Ağırlık, koçun Mehmet Özkan".
  ///
  /// In tr, this message translates to:
  /// **'Profil: {details}'**
  String account_a11yProfile(String details);

  /// Reading of the chosen avatar of the sheet.
  ///
  /// In tr, this message translates to:
  /// **'seçili'**
  String get account_avatarSelected;

  /// Title of the avatar sheet (pano 9.2 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Avatarını seç'**
  String get account_avatarTitle;

  /// Primary button of the avatar sheet (pano 9.2 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Bu Avatarı Kullan'**
  String get account_avatarUse;

  /// Reading hint of the coach's "Koçluk kodun" row: "Koçluk kodun, MOZK-4821, aç" (pano 14.11 Erişilebilirlik).
  ///
  /// In tr, this message translates to:
  /// **'Aç'**
  String get account_coachCodeRowHint;

  /// Text the system share sheet carries (pano 14.11 Veri).
  ///
  /// In tr, this message translates to:
  /// **'SMAP koçluk kodum: {code}. Hesap › Koçluk\'a girerek bana bağlanabilirsin.'**
  String account_coachCodeShareText(String code);

  /// Title of the coach's code row (pano 9.1 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Koçluk kodun'**
  String get account_coachCodeTitle;

  /// First paragraph of the coach's code sheet (pano 14.11 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Öğrencin bu kodu Hesap › Koçluk\'a girince sana bağlanır; denemelerini, analizlerini ve programını görürsün.'**
  String get account_codeSheetBody1;

  /// Second paragraph of the coach's code sheet (pano 14.11 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Bağlantıyı öğrencin istediği an kaldırabilir. Öğrenci hesabını sen açmak istersen: Öğrencilerim › +.'**
  String get account_codeSheetBody2;

  /// Reading of the code, letter by letter: "Koçluk kodun M O Z K tire 4 8 2 1" (pano 14.11 Erişilebilirlik).
  ///
  /// In tr, this message translates to:
  /// **'Koçluk kodun {spelled}'**
  String account_codeSheetCodeA11y(String spelled);

  /// The spoken word for the dash of the code in the letter-by-letter reading (pano 14.11).
  ///
  /// In tr, this message translates to:
  /// **'tire'**
  String get account_codeSheetDash;

  /// Message of the section error inside the code card (pano 14.11 kare 5).
  ///
  /// In tr, this message translates to:
  /// **'Bağlantını kontrol edip tekrar dene.'**
  String get account_codeSheetErrorMessage;

  /// Title of the section error inside the code card (pano 14.11 kare 5).
  ///
  /// In tr, this message translates to:
  /// **'Kodun yüklenemedi.'**
  String get account_codeSheetErrorTitle;

  /// Reading of the code skeleton (pano 14.11 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Kod yükleniyor'**
  String get account_codeSheetLoading;

  /// Note under the paragraphs of the code sheet while offline (pano 14.11 kare 6).
  ///
  /// In tr, this message translates to:
  /// **'Kod cihazında saklı; çevrimdışında da kopyalayıp paylaşabilirsin.'**
  String get account_codeSheetOfflineNote;

  /// Title of the KVKK notice when the server sent none.
  ///
  /// In tr, this message translates to:
  /// **'KVKK Aydınlatma Metni'**
  String get account_contractKvkk;

  /// Title of the privacy policy when the server sent none.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get account_contractPrivacy;

  /// Title of the terms of use when the server sent none.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Koşulları'**
  String get account_contractTerms;

  /// Sub text of a contract: its version (pano 9.7 kare 1; the date of the design is not sent).
  ///
  /// In tr, this message translates to:
  /// **'Sürüm {version}'**
  String account_contractVersion(String version);

  /// Sentence of the empty contracts list.
  ///
  /// In tr, this message translates to:
  /// **'Gösterilecek bir sözleşme metni bulunamadı.'**
  String get account_contractsEmptyMessage;

  /// Title of the empty contracts list (a decision: pano 9.7 draws none).
  ///
  /// In tr, this message translates to:
  /// **'Sözleşme yok'**
  String get account_contractsEmptyTitle;

  /// Title of the error state of the contracts list (pano 1.22 wording).
  ///
  /// In tr, this message translates to:
  /// **'Sözleşmeler yüklenemedi'**
  String get account_contractsErrorTitle;

  /// Note under the list of contracts (pano 9.7 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Kayıt olurken bu sürümleri onayladın. Bir metin değişirse uygulama açılışında yeni sürümü onaylaman istenir.'**
  String get account_contractsFooter;

  /// Title of the contracts screen (pano 9.7 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Sözleşmeler'**
  String get account_contractsTitle;

  /// Body of that confirmation (spec 9.2, a decision).
  ///
  /// In tr, this message translates to:
  /// **'Yaptığın değişiklikler silinecek.'**
  String get account_discardBody;

  /// Primary button of that confirmation (spec 9.2, a decision).
  ///
  /// In tr, this message translates to:
  /// **'Kaydetmeden Çık'**
  String get account_discardConfirm;

  /// Title of the confirmation when leaving edit mode with changes (pano 9.2).
  ///
  /// In tr, this message translates to:
  /// **'Değişiklikler kaydedilmesin mi?'**
  String get account_discardTitle;

  /// Help line under the e-mail field while editing; there is no verification code (pano 14.9 kare 1, T12.19).
  ///
  /// In tr, this message translates to:
  /// **'Kaydedince hemen değişir; doğru yazdığından emin ol.'**
  String get account_emailHelp;

  /// Field label (pano 9.2).
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get account_fieldEmail;

  /// Field label and sheet title (pano 9.2 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Sınıf'**
  String get account_fieldGrade;

  /// Field label (pano 9.2).
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad'**
  String get account_fieldName;

  /// Field label (pano 9.2).
  ///
  /// In tr, this message translates to:
  /// **'Telefon'**
  String get account_fieldPhone;

  /// Field label and sheet title (pano 9.2).
  ///
  /// In tr, this message translates to:
  /// **'Alan'**
  String get account_fieldTrack;

  /// Field label (pano 9.2).
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı'**
  String get account_fieldUserName;

  /// The graduate option of the grade (pano 9.2 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Mezun'**
  String get account_gradeGraduate;

  /// Note under the grade options (pano 9.2 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'9. ya da 10. sınıfı seçersen alan kaldırılır.'**
  String get account_gradeNote;

  /// A school year: "12. Sınıf" (pano 9.2 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'{grade}. Sınıf'**
  String account_gradeValue(int grade);

  /// Group heading: profile and password (pano 9.1).
  ///
  /// In tr, this message translates to:
  /// **'Hesap'**
  String get account_groupAccount;

  /// Group heading: the coaching row (pano 9.1).
  ///
  /// In tr, this message translates to:
  /// **'Koçluk'**
  String get account_groupCoaching;

  /// Group heading of the contracts row (pano 9.1).
  ///
  /// In tr, this message translates to:
  /// **'Yasal'**
  String get account_groupLegal;

  /// Group heading of the notifications row (pano 9.1).
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get account_groupNotifications;

  /// Group heading of the "Bize Yaz" row (pano 9.1 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Destek'**
  String get account_groupSupport;

  /// Field error of the e-mail, under the field, on blur or "Kaydet" (pano 14.9 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta adresi gir.'**
  String get account_issueEmailInvalid;

  /// Field error of the name (a decision: pano 9.2 draws none).
  ///
  /// In tr, this message translates to:
  /// **'Ad soyadını yaz.'**
  String get account_issueNameMissing;

  /// Field error of the phone number (a decision: pano 9.2 draws none).
  ///
  /// In tr, this message translates to:
  /// **'Telefon numaranı 5XX XXX XX XX biçiminde yaz.'**
  String get account_issuePhoneInvalid;

  /// Sentence of the error states of the account screens.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantını kontrol edip tekrar dene.'**
  String get account_loadErrorMessage;

  /// Primary button of the sign-out confirmation (pano 9.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get account_logoutConfirm;

  /// Body of the sign-out confirmation (pano 9.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Tekrar girmek için kullanıcı adın ve şifren gerekecek. Okuttuğun denemeler hesabında kalır.'**
  String get account_logoutMessage;

  /// Body of the sign-out confirmation while forms wait to be sent (pano 9.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Gönderilmeyi bekleyen {count} form var; çıkarsan silinir.'**
  String account_logoutMessagePending(String count);

  /// Title of the sign-out confirmation (pano 9.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yapılsın mı?'**
  String get account_logoutTitle;

  /// Example in the empty phone field after the +90 prefix (pano 9.2 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'5XX XXX XX XX'**
  String get account_phoneHint;

  /// Text button next to the avatar (pano 9.2 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Avatarı Değiştir'**
  String get account_profileChangeAvatar;

  /// Danger link at the bottom of the profile (pano 9.2, 9.4 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Hesabı Sil'**
  String get account_profileDelete;

  /// Bar action that starts editing (pano 9.2 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get account_profileEdit;

  /// Title of the profile screen when the account is not available.
  ///
  /// In tr, this message translates to:
  /// **'Profil açılamadı'**
  String get account_profileErrorTitle;

  /// Line under the title of the open profile form while offline (pano 14.9 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Kaydetmek için bağlantı gerekiyor; girdiklerin korunuyor.'**
  String get account_profileOfflineNote;

  /// Error toast when saving failed (pano 9.2 Davranış).
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilemedi. Bağlantını kontrol edip tekrar dene.'**
  String get account_profileSaveFailed;

  /// Success toast after saving (pano 9.2 Davranış).
  ///
  /// In tr, this message translates to:
  /// **'Profilin güncellendi.'**
  String get account_profileSaved;

  /// Title of the profile screen (pano 9.2).
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get account_profileTitle;

  /// Reading screen when the document has no text.
  ///
  /// In tr, this message translates to:
  /// **'Bu metin şu an gösterilemiyor.'**
  String get account_readerEmpty;

  /// Row title of the student's coaching row (pano 9.1 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Koçluk'**
  String get account_rowCoaching;

  /// Sub text of the Koçluk row of a student without a coach (spec 9.1, a decision: the design draws none).
  ///
  /// In tr, this message translates to:
  /// **'Koçunla bağlan'**
  String get account_rowCoachingNone;

  /// Row title (pano 9.1).
  ///
  /// In tr, this message translates to:
  /// **'Sözleşmeler'**
  String get account_rowContracts;

  /// Sub text of the Sözleşmeler row (pano 9.1).
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Koşulları, KVKK, Gizlilik'**
  String get account_rowContractsSub;

  /// The sign-out row, in its own red group (pano 9.1 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get account_rowLogout;

  /// Row title (pano 9.1).
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get account_rowNotifications;

  /// Sub text of the Bildirimler row (pano 9.1).
  ///
  /// In tr, this message translates to:
  /// **'Deneme sonucu, koç, görüşme, hatırlatıcı'**
  String get account_rowNotificationsSub;

  /// Row title (pano 9.1).
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get account_rowPassword;

  /// Row title (pano 9.1).
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get account_rowProfile;

  /// Sub text of the Profil row of a coach, who has no grade or track (spec 9.1 Ç-46).
  ///
  /// In tr, this message translates to:
  /// **'Ad, e-posta ve telefon'**
  String get account_rowProfileCoachSub;

  /// Sub text of the Profil row of a student (pano 9.1 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Ad, e-posta, telefon, sınıf ve alan'**
  String get account_rowProfileStudentSub;

  /// Row title that opens a mail draft (pano 9.1 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Bize Yaz'**
  String get account_rowSupport;

  /// Sub text of the "Bize Yaz" row (pano 9.1 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'E-posta uygulaman açılır'**
  String get account_rowSupportSub;

  /// Third line of the profile summary of a student with a coach (pano 9.1 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Koçun: {name}'**
  String account_summaryCoach(String name);

  /// Third line of the profile summary of a coach (pano 9.1 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Koçluk kodun: {code}'**
  String account_summaryCoachCode(String code);

  /// Second line of the profile summary of a coach (pano 9.1 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Öğrenci koçu'**
  String get account_summaryCoachRole;

  /// Second line of the profile summary of a student with both: "12. Sınıf · Eşit Ağırlık" (pano 9.1 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'{grade} · {track}'**
  String account_summaryGradeTrack(String grade, String track);

  /// Toast when the mail app could not be opened.
  ///
  /// In tr, this message translates to:
  /// **'E-posta uygulaması açılamadı.'**
  String get account_supportMailFailed;

  /// Subject of the support mail draft (pano 9.1: the design gives none).
  ///
  /// In tr, this message translates to:
  /// **'SMAP · Destek'**
  String get account_supportMailSubject;

  /// Line of the support mail draft with the operating system.
  ///
  /// In tr, this message translates to:
  /// **'Sistem: {system}'**
  String account_supportMailSystem(String system);

  /// Line of the support mail draft with the app version.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama sürümü: {version}'**
  String account_supportMailVersion(String version);

  /// Title of the Hesap tab root band (pano 9.1 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Hesap'**
  String get account_title;

  /// Study track.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get account_trackDil;

  /// Help line of the disabled track field.
  ///
  /// In tr, this message translates to:
  /// **'9. ve 10. sınıfta alan seçilmez.'**
  String get account_trackDisabledHelper;

  /// What the disabled track field reads in the 9th and 10th grade (pano 9.2, spec 9.2).
  ///
  /// In tr, this message translates to:
  /// **'Seçilmez'**
  String get account_trackDisabledValue;

  /// Study track.
  ///
  /// In tr, this message translates to:
  /// **'Eşit Ağırlık'**
  String get account_trackEsitAgirlik;

  /// Study track.
  ///
  /// In tr, this message translates to:
  /// **'Sayısal'**
  String get account_trackSayisal;

  /// Study track.
  ///
  /// In tr, this message translates to:
  /// **'Sözel'**
  String get account_trackSozel;

  /// Help line under the user name in edit mode (pano 9.2 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı değiştirilemez.'**
  String get account_userNameLocked;

  /// The version line at the bottom of Hesap (pano 9.1 kare 2): "Sürüm 3.0.0 (300)".
  ///
  /// In tr, this message translates to:
  /// **'Sürüm {version} ({build})'**
  String account_version(String version, String build);

  /// Toast after a long press on the version line copied it (pano 9.1 Davranış, a decision for the wording).
  ///
  /// In tr, this message translates to:
  /// **'Sürüm kopyalandı.'**
  String get account_versionCopied;

  /// Hint of the version line.
  ///
  /// In tr, this message translates to:
  /// **'Uzun basınca kopyalar'**
  String get account_versionCopyHint;

  /// The version line when the platform gives no build number.
  ///
  /// In tr, this message translates to:
  /// **'Sürüm {version}'**
  String account_versionNoBuild(String version);

  /// Help line under the password of the credentials sheet (pano 10.3 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Bu ekranı kapatınca şifre yeniden gösterilmez.'**
  String get addStudent_addedNote;

  /// Subtitle of the credentials sheet (pano 10.3 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Giriş bilgilerini öğrencine ilet.'**
  String get addStudent_addedSubtitle;

  /// Title of the credentials sheet (pano 10.3 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'{name} eklendi'**
  String addStudent_addedTitle(String name);

  /// Counter at the right of the 'Avatar' label: chosen position over the total (pano 14.8 kare 1: '4 / 7').
  ///
  /// In tr, this message translates to:
  /// **'{index} / {total}'**
  String addStudent_avatarCounter(int index, int total);

  /// Screen reader name of the avatar radio group (pano 14.8: 'Avatar, 7 seçenek').
  ///
  /// In tr, this message translates to:
  /// **'Avatar, {total} seçenek'**
  String addStudent_avatarGroupA11y(int total);

  /// Label above the seven avatars of the form (Tur 12 D, brief 14.8 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Avatar'**
  String get addStudent_avatarLabel;

  /// Screen reader name of one avatar radio; the picker adds ', seçili' for the chosen one (pano 14.8: 'Avatar 4 / 7, seçili').
  ///
  /// In tr, this message translates to:
  /// **'Avatar {index} / {total}'**
  String addStudent_avatarOptionA11y(int index, int total);

  /// Action beside the user name: asks the server now (pano 10.3 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Kontrol Et'**
  String get addStudent_check;

  /// Heading above the coaching code card in the sheet (pano 10.3 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Öğrencin kendi hesabıyla bağlansın'**
  String get addStudent_codeHeading;

  /// The text the share sheet carries from the credentials sheet.
  ///
  /// In tr, this message translates to:
  /// **'SMAP giriş bilgilerin\nKullanıcı adı: {userName}\nŞifre: {password}'**
  String addStudent_credentialsShareText(String userName, String password);

  /// First name field label (pano 10.3 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Ad'**
  String get addStudent_firstName;

  /// Action beside the password: makes a readable 10-character password (pano 10.3 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Oluştur'**
  String get addStudent_generate;

  /// Grade select label and its sheet title (pano 10.3 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Sınıf'**
  String get addStudent_grade;

  /// First name left empty.
  ///
  /// In tr, this message translates to:
  /// **'Öğrencinin adını yaz.'**
  String get addStudent_issueFirstName;

  /// Grade not chosen.
  ///
  /// In tr, this message translates to:
  /// **'Sınıfı seç.'**
  String get addStudent_issueGrade;

  /// Surname left empty.
  ///
  /// In tr, this message translates to:
  /// **'Öğrencinin soyadını yaz.'**
  String get addStudent_issueLastName;

  /// Password left empty.
  ///
  /// In tr, this message translates to:
  /// **'Bir şifre yaz ya da Oluştur\'a dokun.'**
  String get addStudent_issuePasswordMissing;

  /// Password shorter than 8 characters (decision 7.5).
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az 8 karakter olmalı.'**
  String get addStudent_issuePasswordShort;

  /// Track not chosen for a student of 11th grade or above.
  ///
  /// In tr, this message translates to:
  /// **'Alanı seç.'**
  String get addStudent_issueTrack;

  /// User name left empty.
  ///
  /// In tr, this message translates to:
  /// **'Bir kullanıcı adı yaz.'**
  String get addStudent_issueUsername;

  /// Surname field label (pano 10.3 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Soyad'**
  String get addStudent_lastName;

  /// Word between two rules that separates the form from the coaching code (pano 10.3 kare 1 and 2).
  ///
  /// In tr, this message translates to:
  /// **'ya da'**
  String get addStudent_or;

  /// Password field label (pano 10.3 kare 1 and 3).
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get addStudent_password;

  /// Help line under the password (pano 10.3 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Öğrencine ilet; ilk girişte değiştirmesi önerilir.'**
  String get addStudent_passwordHelp;

  /// Primary button of the form (pano 10.3 kare 1 and 2).
  ///
  /// In tr, this message translates to:
  /// **'Öğrenciyi Kaydet'**
  String get addStudent_save;

  /// Error toast when the save failed for a reason with no text of its own (pano 14.8 kare 5); the sheet stays open and keeps what was typed, the avatar included.
  ///
  /// In tr, this message translates to:
  /// **'Öğrenci kaydedilemedi. Bağlantını kontrol edip tekrar dene.'**
  String get addStudent_saveFailed;

  /// Under the passive 'Öğrenciyi Kaydet' while the device is offline (pano 14.8 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Öğrenci eklemek için bağlantı gerekiyor. Kod kartı çevrimdışında da çalışır.'**
  String get addStudent_saveOfflineReason;

  /// Primary button of the credentials sheet; opens the system share sheet (pano 10.3 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Bilgileri Paylaş'**
  String get addStudent_shareCredentials;

  /// Subtitle of the add-student sheet (pano 10.3 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Hesabını sen aç ya da kodunu paylaş.'**
  String get addStudent_subtitle;

  /// Title of the add-student sheet (pano 10.3 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Öğrenci ekle'**
  String get addStudent_title;

  /// Study track select label and its sheet title (pano 10.3 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Alan'**
  String get addStudent_track;

  /// Value of the passive track field for grade 9 and 10 (pano 10.3 "Sınıf ve Alan 1.12; 9.–10. sınıfta Alan pasif").
  ///
  /// In tr, this message translates to:
  /// **'Seçilmez'**
  String get addStudent_trackNotSelectable;

  /// Help line under the passive track field.
  ///
  /// In tr, this message translates to:
  /// **'9. ve 10. sınıfta alan seçilmez.'**
  String get addStudent_trackNotSelectableReason;

  /// User name field label (pano 10.3 kare 1 and 3).
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı'**
  String get addStudent_username;

  /// Live check passed (pano 10.3 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Bu kullanıcı adı boşta.'**
  String get addStudent_usernameFree;

  /// Help line under the user name while the device is offline.
  ///
  /// In tr, this message translates to:
  /// **'Bağlanınca kontrol edilecek.'**
  String get addStudent_usernameOffline;

  /// Label before the free-name chip under a taken user name.
  ///
  /// In tr, this message translates to:
  /// **'Boşta olan:'**
  String get addStudent_usernameSuggest;

  /// Screen reader reading of the free-name chip.
  ///
  /// In tr, this message translates to:
  /// **'Boşta olan kullanıcı adı: {name}. Yazmak için dokun.'**
  String addStudent_usernameSuggestA11y(String name);

  /// Live check or save: the user name is in use (spec 10.3 "Alınmış").
  ///
  /// In tr, this message translates to:
  /// **'Bu kullanıcı adı alınmış.'**
  String get addStudent_usernameTaken;

  /// Stat box label (pano 6.1).
  ///
  /// In tr, this message translates to:
  /// **'Ortalama net'**
  String get analytics_boxAverageNet;

  /// Stat box label; drawn only when the exams have points (pano 6.1).
  ///
  /// In tr, this message translates to:
  /// **'Ortalama puan'**
  String get analytics_boxAveragePoint;

  /// Stat box label; drawn only when the exams have ranks (pano 6.1).
  ///
  /// In tr, this message translates to:
  /// **'Ortalama sıralama'**
  String get analytics_boxAverageRank;

  /// Stat box label (pano 6.1).
  ///
  /// In tr, this message translates to:
  /// **'Çözülen deneme'**
  String get analytics_boxExams;

  /// Date range: since 1 September (pano 6.2 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Bu eğitim yılı'**
  String get analytics_dateAcademicYear;

  /// Date range: no limit (pano 6.2 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Tüm tarihler'**
  String get analytics_dateAll;

  /// Date range (pano 6.2 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Son 30 gün'**
  String get analytics_dateLast30Days;

  /// Date range (pano 6.2 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Son 3 ay'**
  String get analytics_dateLast3Months;

  /// Tail of the change line of the average net box: '+3,25 son denemede' (pano 6.1).
  ///
  /// In tr, this message translates to:
  /// **'son denemede'**
  String get analytics_deltaSuffix;

  /// Empty state action: opens the camera (pano 6.2 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'İlk Denemeni Okut'**
  String get analytics_emptyAction;

  /// Empty state message of both tabs (pano 6.2 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'İlk denemeni okuttuğunda sonuçların, netin ve eksik konuların burada görünür.'**
  String get analytics_emptyMessage;

  /// Empty state title of both tabs (pano 6.2 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Henüz deneme yok'**
  String get analytics_emptyTitle;

  /// Genel and Denemelerim error message (pano 6.3 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Bağlantını kontrol edip tekrar dene.'**
  String get analytics_errorMessage;

  /// Genel tab error title (pano 6.3 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Analizlerin yüklenemedi'**
  String get analytics_errorTitle;

  /// How many exams: '6 deneme' (pano 6.1, 6.2 counters).
  ///
  /// In tr, this message translates to:
  /// **'{count} deneme'**
  String analytics_examCount(int count);

  /// Title of an exam the server did not name: 'TYT denemesi' (pano 6.2 'Ad yoksa başlık tür + denemesi olur').
  ///
  /// In tr, this message translates to:
  /// **'{type} denemesi'**
  String analytics_examUntitled(String type);

  /// Denemelerim error title (same pattern as pano 6.3 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Denemelerin yüklenemedi'**
  String get analytics_examsErrorTitle;

  /// AYT field: Eşit Ağırlık (pano 6.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Eşit Ağırlık'**
  String get analytics_fieldEqualWeight;

  /// AYT field: Sayısal (pano 6.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Sayısal'**
  String get analytics_fieldNumeric;

  /// AYT field: Sözel (pano 6.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Sözel'**
  String get analytics_fieldVerbal;

  /// Screen reader name of the filter pill (pano 6.1).
  ///
  /// In tr, this message translates to:
  /// **'Süzgeç: {label}'**
  String analytics_filterA11y(String label);

  /// Section empty state when a filter leaves no exam (not in the boards; follows the 'Bu süzgeçte gösterilecek konu yok' pattern of 7.5).
  ///
  /// In tr, this message translates to:
  /// **'Bu süzgeçte gösterilecek deneme yok.'**
  String get analytics_filterEmpty;

  /// Filter scope: the whole exam, not one lesson.
  ///
  /// In tr, this message translates to:
  /// **'Genel'**
  String get analytics_filterGeneral;

  /// Filter pill: 'TYT · Genel' (pano 6.1).
  ///
  /// In tr, this message translates to:
  /// **'{exam} · {scope}'**
  String analytics_filterLabel(String exam, String scope);

  /// Action of the filtered-empty state (not in the boards).
  ///
  /// In tr, this message translates to:
  /// **'Süzgeci Sıfırla'**
  String get analytics_filterReset;

  /// Screen reader name of the spinner under the list (pano 6.2).
  ///
  /// In tr, this message translates to:
  /// **'Daha fazla deneme yükleniyor'**
  String get analytics_loadingMoreA11y;

  /// Section error under the list when the next page failed (pano 1.22 section error).
  ///
  /// In tr, this message translates to:
  /// **'Denemeler yüklenemedi.'**
  String get analytics_moreError;

  /// Screen reader summary of the net chart (C48).
  ///
  /// In tr, this message translates to:
  /// **'{scope} net grafiği, {startDate} {startNet} netten {endDate} {endNet} nete, {count} deneme'**
  String analytics_netChartA11y(
    String scope,
    String startDate,
    String startNet,
    String endDate,
    String endNet,
    int count,
  );

  /// Chart balloon first line (C48): "TYT Genel Deneme 9 · 28 Eyl.".
  ///
  /// In tr, this message translates to:
  /// **'{name} · {date}'**
  String analytics_netChartBalloonHead(String name, String date);

  /// Chart balloon second line (C48): "74,75 net".
  ///
  /// In tr, this message translates to:
  /// **'{net} net'**
  String analytics_netChartBalloonNet(String net);

  /// Net chart card footnote (C48): "net · TYT 0–120 · son nokta vurgulu".
  ///
  /// In tr, this message translates to:
  /// **'net · {scope} 0–{max} · son nokta vurgulu'**
  String analytics_netChartFootnote(String scope, String max);

  /// Screen reader name of one chart point (C48): "TYT Genel Deneme 9, 28 Eylül, 74,75 net".
  ///
  /// In tr, this message translates to:
  /// **'{name}, {date}, {net} net'**
  String analytics_netChartPointA11y(String name, String date, String net);

  /// Screen reader name of one chart point of an exam without a name (C48).
  ///
  /// In tr, this message translates to:
  /// **'{date}, {net} net'**
  String analytics_netChartPointNoNameA11y(String date, String net);

  /// Net chart card: how many exams the chart shows (C48).
  ///
  /// In tr, this message translates to:
  /// **'Son {count} deneme'**
  String analytics_netChartRange(int count);

  /// Screen reader summary of a net chart with one exam (C48).
  ///
  /// In tr, this message translates to:
  /// **'{scope} net grafiği, {date} {net} net, 1 deneme'**
  String analytics_netChartSingleA11y(String scope, String date, String net);

  /// Net chart card title (C48).
  ///
  /// In tr, this message translates to:
  /// **'Net gelişimi'**
  String get analytics_netChartTitle;

  /// Primary button of both filter sheets (pano 6.1 kare 3, 6.2 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Uygula'**
  String get analytics_sheetApply;

  /// Field label of the date chips (pano 6.2 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get analytics_sheetDate;

  /// Field label of the filter sheet: TYT or AYT (pano 6.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Sınav'**
  String get analytics_sheetExam;

  /// Screen reader name of the exam segment (pano 6.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Sınav türü'**
  String get analytics_sheetExamA11y;

  /// Field label of the filter sheet: the AYT field (pano 6.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Alan'**
  String get analytics_sheetField;

  /// Screen reader name of the field segment.
  ///
  /// In tr, this message translates to:
  /// **'Alan'**
  String get analytics_sheetFieldA11y;

  /// Help under the field segment (pano 6.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Ders listesi alanına göre değişir. Profildeki alanın seçili gelir.'**
  String get analytics_sheetFieldHelp;

  /// Title of the Genel filter sheet (pano 6.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Süzgeç'**
  String get analytics_sheetFilterTitle;

  /// Field label of the filter sheet: the lesson chips (pano 6.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Ders'**
  String get analytics_sheetLesson;

  /// Title of the Denemelerim sheet (pano 6.2 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Süz ve Sırala'**
  String get analytics_sheetSortTitle;

  /// One-exam card: exam name and long date (pano 6.3 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'{name} · {date}'**
  String analytics_singleNameDate(String name, String date);

  /// One-exam card note (pano 6.3 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'İkinci denemenden sonra gelişim grafiğin burada çizilir.'**
  String get analytics_singleNote;

  /// One-exam card heading (pano 6.3 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'İlk denemen'**
  String get analytics_singleTitle;

  /// Text button that opens the sort and filter sheet (pano 6.2 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Süz ve Sırala'**
  String get analytics_sortAction;

  /// Summary line over the list: date range and order (pano 6.2 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'{date} · En yeni önce'**
  String analytics_summaryLine(String date);

  /// Root band tab: the list of exams (pano 6.2).
  ///
  /// In tr, this message translates to:
  /// **'Denemelerim'**
  String get analytics_tabExams;

  /// Root band tab: the net chart and four boxes (pano 6.1).
  ///
  /// In tr, this message translates to:
  /// **'Genel'**
  String get analytics_tabGeneral;

  /// Screen reader name of the root band's tab row (pano 6.1).
  ///
  /// In tr, this message translates to:
  /// **'Analizlerim bölümleri'**
  String get analytics_tabsA11y;

  /// Root band title of the Analizlerim tab (pano 6.1).
  ///
  /// In tr, this message translates to:
  /// **'Analizlerim'**
  String get analytics_title;

  /// Screen reader name of the exam type segment (pano 6.2).
  ///
  /// In tr, this message translates to:
  /// **'Sınav türü'**
  String get analytics_typeA11y;

  /// Exam type segment: all exams (pano 6.2 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get analytics_typeAll;

  /// Counter line of a segment option (pano 8.1): "23 kart".
  ///
  /// In tr, this message translates to:
  /// **'{count} kart'**
  String cardDeck_count(String count);

  /// Counter line of an empty segment option (pano 8.1 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'kart yok'**
  String get cardDeck_countNone;

  /// Secondary button under the deck; opens the card sheet (pano 8.1).
  ///
  /// In tr, this message translates to:
  /// **'Detay'**
  String get cardDeck_detail;

  /// Sentence of the error state of the card deck.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantını kontrol edip tekrar dene.'**
  String get cardDeck_errorMessage;

  /// Title of the screen-level error state of the card deck.
  ///
  /// In tr, this message translates to:
  /// **'Kartlar yüklenemedi'**
  String get cardDeck_errorTitle;

  /// Empty state of Favorilerim (pano 8.1 "Boş metinler", Ek C).
  ///
  /// In tr, this message translates to:
  /// **'Favoriye eklediğin kart yok.'**
  String get cardDeck_favoriteEmpty;

  /// Text button of the empty Eksiklerim; opens Bildiklerim (pano 8.1 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Bildiklerime Geç'**
  String get cardDeck_goKnown;

  /// Third option of the deck's segment (pano 8.1).
  ///
  /// In tr, this message translates to:
  /// **'Favorilerim'**
  String get cardDeck_groupFavorite;

  /// Second option of the deck's segment (pano 8.1).
  ///
  /// In tr, this message translates to:
  /// **'Bildiklerim'**
  String get cardDeck_groupKnown;

  /// First option of the deck's segment (pano 8.1).
  ///
  /// In tr, this message translates to:
  /// **'Eksiklerim'**
  String get cardDeck_groupMissing;

  /// Empty state of Bildiklerim (pano 8.1 "Boş metinler", Ek C).
  ///
  /// In tr, this message translates to:
  /// **'Henüz öğrendiğin kart yok.'**
  String get cardDeck_knownEmpty;

  /// Primary button under the deck, only on a missing card (pano 8.1).
  ///
  /// In tr, this message translates to:
  /// **'Öğrendim'**
  String get cardDeck_learned;

  /// Sentence under the title of the empty Eksiklerim (pano 8.1 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Bildiklerim\'deki {count} kartı tekrar etmek istersen oradan devam edebilirsin.'**
  String cardDeck_missingDoneMessage(String count);

  /// Empty state of Eksiklerim once every card is learned (pano 8.1 kare 4; Ek C).
  ///
  /// In tr, this message translates to:
  /// **'Bu derste eksik kartın kalmadı.'**
  String get cardDeck_missingDoneTitle;

  /// Same, in the deck opened from an exam (assumption: the pano has the lesson wording only).
  ///
  /// In tr, this message translates to:
  /// **'Bu denemede eksik kartın kalmadı.'**
  String get cardDeck_missingDoneTitleExam;

  /// Toast after "Öğrendim", with "Geri Al" for 6 s (pano 8.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Kart Bildiklerim\'e taşındı.'**
  String get cardDeck_moved;

  /// Screen reader action of the top card (spec C52 customActions).
  ///
  /// In tr, this message translates to:
  /// **'Sonraki kart'**
  String get cardDeck_nextA11y;

  /// Sentence under the no-cards title (assumption; wording of pano 5.6: "yanlış ve boş bıraktığın sorulardan").
  ///
  /// In tr, this message translates to:
  /// **'Kartlar, denemelerde yanlış ve boş bıraktığın sorulardan eklenir.'**
  String get cardDeck_noCardsMessage;

  /// Empty state of a lesson with no card in any group (assumption: the pano does not draw this case).
  ///
  /// In tr, this message translates to:
  /// **'Bu derste henüz kartın yok.'**
  String get cardDeck_noCardsTitle;

  /// Empty state of an exam that earned no cards (assumption).
  ///
  /// In tr, this message translates to:
  /// **'Bu denemeden kart eklenmedi.'**
  String get cardDeck_noCardsTitleExam;

  /// Screen reader action of the top card (spec C52 customActions).
  ///
  /// In tr, this message translates to:
  /// **'Önceki kart'**
  String get cardDeck_previousA11y;

  /// Session progress next to the bar (pano 8.1): "12/23".
  ///
  /// In tr, this message translates to:
  /// **'{current}/{total}'**
  String cardDeck_progress(String current, String total);

  /// Screen reader sentence of the session progress (pano 8.1: aria "Oturum").
  ///
  /// In tr, this message translates to:
  /// **'Oturum, {total} karttan {current}. kart'**
  String cardDeck_progressA11y(String current, String total);

  /// Toast when "Öğrendim" or the star could not be sent; the card goes back (spec C52: hata olursa geri alınır).
  ///
  /// In tr, this message translates to:
  /// **'Gönderilemedi. Bağlantını kontrol edip tekrar dene.'**
  String get cardDeck_sendFailed;

  /// Large title of the card deck of a lesson (pano 8.1): "Tarih Kartları".
  ///
  /// In tr, this message translates to:
  /// **'{lesson} Kartları'**
  String cardDeck_title(String lesson);

  /// Large title of the card deck opened from an exam ("Kartları Çalış"; spec 8.1 [Karar]).
  ///
  /// In tr, this message translates to:
  /// **'Deneme Kartları'**
  String get cardDeck_titleExam;

  /// Large title of the card deck of a lesson that is not in the catalog.
  ///
  /// In tr, this message translates to:
  /// **'Bilgi Kartları'**
  String get cardDeck_titleFallback;

  /// Sentence of the confirmation of "Öğrendim" (pano 8.1 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'\"{name}\" eksiklerinden çıkıp Bildiklerim\'e geçecek.'**
  String cardSheet_confirmBody(String name);

  /// Question of the one-time confirmation of "Öğrendim" (pano 8.1 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Kartı Bildiklerim\'e taşıyalım mı?'**
  String get cardSheet_confirmTitle;

  /// Small line over the card title in the card sheet (pano 7.3 kare 3): "Türkçe · Sözcükte Anlam".
  ///
  /// In tr, this message translates to:
  /// **'{lesson} · {topic}'**
  String cardSheet_context(String lesson, String topic);

  /// Checkbox of the confirmation of "Öğrendim"; kept on the device (pano 8.1 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Bir daha sorma'**
  String get cardSheet_dontAsk;

  /// Primary button of the card sheet, only on a missing card (pano 7.3 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Öğrendim'**
  String get cardSheet_learned;

  /// Study card favorite star, not yet a favorite (C52).
  ///
  /// In tr, this message translates to:
  /// **'Favorilere ekle'**
  String get cards_favoriteAdd;

  /// Study card favorite star, already a favorite (C52).
  ///
  /// In tr, this message translates to:
  /// **'Favorilerden çıkar'**
  String get cards_favoriteRemove;

  /// The one link of the student section and the primary button of the empty page (pano 10.1 kare 1 and 3); opens the add-student sheet (10.3).
  ///
  /// In tr, this message translates to:
  /// **'Öğrenci Ekle'**
  String get coachHome_addStudent;

  /// Section title of the attention list (pano 10.1 kare 1 and 2); drawn only with FeatureFlags.attentionListEnabled.
  ///
  /// In tr, this message translates to:
  /// **'Dikkat gerektirenler'**
  String get coachHome_attention;

  /// Empty card of the attention list, explanation of the two rules (pano 10.1 kare 1, D-27).
  ///
  /// In tr, this message translates to:
  /// **'14 gündür deneme okutmayan ya da son iki denemesinde neti düşen öğrenci burada görünür.'**
  String get coachHome_attentionEmptyBody;

  /// Empty card of the attention list, first line (pano 10.1 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Şu an dikkat gerektiren öğrenci yok.'**
  String get coachHome_attentionEmptyTitle;

  /// Section error card of the attention list; no board copy.
  ///
  /// In tr, this message translates to:
  /// **'Dikkat listesi yüklenemedi.'**
  String get coachHome_attentionError;

  /// Message of the page of a coach with no student (pano 10.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Öğrencin koçluk kodunla kendi hesabından bağlanabilir ya da hesabını sen açabilirsin.'**
  String get coachHome_emptyMessage;

  /// Title of the page of a coach with no student (pano 10.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'İlk öğrencini ekle'**
  String get coachHome_emptyTitle;

  /// Section title of the upcoming meetings (pano 10.1 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşan görüşmeler'**
  String get coachHome_meetings;

  /// Section error card of the upcoming meetings; no board copy.
  ///
  /// In tr, this message translates to:
  /// **'Görüşmeler yüklenemedi.'**
  String get coachHome_meetingsError;

  /// Text button of the empty meetings card; opens the new-meeting sheet (10.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Yeni Görüşme'**
  String get coachHome_newMeeting;

  /// Empty card of the upcoming meetings (spec Flutter §4 10.1 [Karar]).
  ///
  /// In tr, this message translates to:
  /// **'Önümüzdeki 7 günde görüşme yok.'**
  String get coachHome_noMeetings;

  /// Section title of the student strip (pano 10.1 kare 1, SectionHeader).
  ///
  /// In tr, this message translates to:
  /// **'Öğrencilerin'**
  String get coachHome_students;

  /// Section error card of the student strip; the board has no copy, written after "Dersler yüklenemedi." (pano 3.2 pattern).
  ///
  /// In tr, this message translates to:
  /// **'Öğrenciler yüklenemedi.'**
  String get coachHome_studentsError;

  /// End of the screen reader sentence of a row for a parent meeting.
  ///
  /// In tr, this message translates to:
  /// **'veli görüşmesi'**
  String get coachMeetings_a11yKindParent;

  /// End of the screen reader sentence of a row: "Alparslan Kuloğlu, 12 Ekim 2026 Pazartesi, 16:00, öğrenci görüşmesi" (Tur 9 erişilebilirlik).
  ///
  /// In tr, this message translates to:
  /// **'öğrenci görüşmesi'**
  String get coachMeetings_a11yKindStudent;

  /// Action of the no-result card of a search (follows pano 10.2 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Aramayı Temizle'**
  String get coachMeetings_clearSearch;

  /// Label of the day field (pano 10.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get coachMeetings_dateLabel;

  /// Title of the day picker sheet. The board draws no picker; built from the kit calendar. Assumption.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get coachMeetings_dateTitle;

  /// Error state title of the detail when the meeting could not be loaded.
  ///
  /// In tr, this message translates to:
  /// **'Görüşme açılamadı'**
  String get coachMeetings_detailErrorTitle;

  /// Same line for a parent meeting. The board draws only the student one; spec 10.5 notes the legacy "Veli Görüşmesi".
  ///
  /// In tr, this message translates to:
  /// **'Veli görüşmesi'**
  String get coachMeetings_detailKindParent;

  /// Line under the student name on the detail screen (pano 10.5 kare 3); also the row title when the server named no student.
  ///
  /// In tr, this message translates to:
  /// **'Öğrenci görüşmesi'**
  String get coachMeetings_detailKindStudent;

  /// Error state sentence when the meeting is not in the server list any more.
  ///
  /// In tr, this message translates to:
  /// **'Bu görüşme silinmiş olabilir. Listeye dönüp yenileyebilirsin.'**
  String get coachMeetings_detailMissingMessage;

  /// Error state title when the meeting is not in the server list any more.
  ///
  /// In tr, this message translates to:
  /// **'Görüşme bulunamadı'**
  String get coachMeetings_detailMissingTitle;

  /// Empty state primary action (pano 10.5 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Yeni Görüşme'**
  String get coachMeetings_emptyAction;

  /// Empty state sentence (pano 10.5 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Öğrencinle ya da velisiyle görüşme planladığında burada listelenir.'**
  String get coachMeetings_emptyMessage;

  /// Empty state title (pano 10.5 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Henüz görüşme yok'**
  String get coachMeetings_emptyTitle;

  /// "Kiminle" chip, segment option and row tag: a meeting with the parent (pano 10.5).
  ///
  /// In tr, this message translates to:
  /// **'Veli'**
  String get coachMeetings_kindParent;

  /// "Kiminle" chip, segment option and row tag: a meeting with the student (pano 10.5).
  ///
  /// In tr, this message translates to:
  /// **'Öğrenci'**
  String get coachMeetings_kindStudent;

  /// Error state sentence of the list and of the detail (1.22 pattern).
  ///
  /// In tr, this message translates to:
  /// **'Bağlantını kontrol edip tekrar dene. Sorun sürerse biraz sonra yeniden açabilirsin.'**
  String get coachMeetings_loadErrorMessage;

  /// Error state title of the list (1.22 pattern).
  ///
  /// In tr, this message translates to:
  /// **'Görüşmelerin yüklenemedi'**
  String get coachMeetings_loadErrorTitle;

  /// Screen reader name of the spinner under the list.
  ///
  /// In tr, this message translates to:
  /// **'Görüşmeler yükleniyor'**
  String get coachMeetings_loadingMore;

  /// Row title and bar title of a meeting with no student name and an unknown kind. Assumption.
  ///
  /// In tr, this message translates to:
  /// **'Görüşme'**
  String get coachMeetings_meetingFallback;

  /// Section error under the list when the next page failed.
  ///
  /// In tr, this message translates to:
  /// **'Daha fazla görüşme yüklenemedi.'**
  String get coachMeetings_moreFailed;

  /// Accessible name of the Plus in the band of Görüşmelerim (pano 10.5 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Yeni görüşme'**
  String get coachMeetings_newA11y;

  /// Title of the new-meeting sheet (pano 10.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Yeni görüşme'**
  String get coachMeetings_newTitle;

  /// No result of the "Kiminle" choice (not drawn on the board). Assumption.
  ///
  /// In tr, this message translates to:
  /// **'Bu süzgeçle görüşme yok. Başka bir seçenek deneyebilirsin.'**
  String get coachMeetings_noKind;

  /// No result of a search (the board draws none; follows "Sonuç yok" of pano 10.2 kare 3). Assumption.
  ///
  /// In tr, this message translates to:
  /// **'“{query}” ile eşleşen görüşme yok. Öğrenci adında arar; büyük-küçük harf ve I/ı/İ/i farkı gözetmez.'**
  String coachMeetings_noMatch(String query);

  /// Toast when the coach has no student to plan a meeting with.
  ///
  /// In tr, this message translates to:
  /// **'Görüşme planlamak için önce bir öğrenci eklemelisin.'**
  String get coachMeetings_noStudents;

  /// Text button next to "Notlar" (pano 10.5 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Not Ekle'**
  String get coachMeetings_noteAdd;

  /// Title of the note sheet for a new note (pano 10.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Not ekle'**
  String get coachMeetings_noteAddTitle;

  /// Toast after adding a note. The board draws none. Assumption.
  ///
  /// In tr, this message translates to:
  /// **'Not eklendi.'**
  String get coachMeetings_noteAdded;

  /// Sub title of the note sheet: "12 Ekim 2026 · Alparslan Kuloğlu" (pano 10.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'{date} · {name}'**
  String coachMeetings_noteContext(String date, String name);

  /// Text button of a note card, in the error color (pano 10.6 "Not kartı").
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get coachMeetings_noteDelete;

  /// Danger action of the confirmation (pano 10.6 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Notu Sil'**
  String get coachMeetings_noteDeleteAction;

  /// Body of the confirmation; it quotes the note (pano 10.6 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'“{text}” notu silinecek.'**
  String coachMeetings_noteDeleteBody(String text);

  /// Toast when the held deletion of a note failed; the note comes back.
  ///
  /// In tr, this message translates to:
  /// **'Not silinemedi. Bağlantını kontrol edip tekrar dene.'**
  String get coachMeetings_noteDeleteFailed;

  /// Title of the danger confirmation (pano 10.6 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Not silinsin mi?'**
  String get coachMeetings_noteDeleteTitle;

  /// Toast with "Geri Al" after deleting a note, 6 s (pano 10.6 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Not silindi.'**
  String get coachMeetings_noteDeleted;

  /// Text button of a note card (pano 10.6 "Not kartı").
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get coachMeetings_noteEdit;

  /// Title of the note sheet for an existing note (pano 10.6 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Notu düzenle'**
  String get coachMeetings_noteEditTitle;

  /// Accessible name of the note sheet's field, which has no visible label.
  ///
  /// In tr, this message translates to:
  /// **'Not'**
  String get coachMeetings_noteFieldA11y;

  /// Placeholder of the note fields (pano 10.5 kare 2, 10.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Örn: Deneme sonucunu birlikte inceleyeceğiz.'**
  String get coachMeetings_noteHint;

  /// Label of the note field; the kit adds "(isteğe bağlı)" (pano 10.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Not'**
  String get coachMeetings_noteLabel;

  /// Primary action of the sheet for a new note (pano 10.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Notu Kaydet'**
  String get coachMeetings_noteSave;

  /// Toast when saving a note failed; the sheet stays open with the text (pano 10.6 Davranış).
  ///
  /// In tr, this message translates to:
  /// **'Not kaydedilemedi. Bağlantını kontrol edip tekrar dene.'**
  String get coachMeetings_noteSaveFailed;

  /// Toast after editing a note. The board draws none. Assumption.
  ///
  /// In tr, this message translates to:
  /// **'Not güncellendi.'**
  String get coachMeetings_noteUpdated;

  /// The notes card when there is no note (pano 10.6 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Henüz not yok.'**
  String get coachMeetings_notesEmpty;

  /// Section error of the notes (1.22 pattern).
  ///
  /// In tr, this message translates to:
  /// **'Notlar yüklenemedi.'**
  String get coachMeetings_notesLoadFailed;

  /// Section title of the notes (pano 10.5 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Notlar'**
  String get coachMeetings_notesTitle;

  /// Group title of the meetings that have passed. The board gives no text ("O başlığın metni belirtilmemiş"); this follows "Yaklaşan · 2". Assumption.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş · {count}'**
  String coachMeetings_past(String count);

  /// Student list sheet when the search keeps nobody.
  ///
  /// In tr, this message translates to:
  /// **'Eşleşen öğrenci yok.'**
  String get coachMeetings_pickStudentNoMatch;

  /// Search field of the student list sheet (same text as pano 10.2).
  ///
  /// In tr, this message translates to:
  /// **'Öğrenci ara'**
  String get coachMeetings_pickStudentSearch;

  /// Title of the student list sheet (pano 10.5 kare 2: "Alttan öğrenci listesi").
  ///
  /// In tr, this message translates to:
  /// **'Öğrenci seç'**
  String get coachMeetings_pickStudentTitle;

  /// Toast when a pull to refresh failed and the list stays.
  ///
  /// In tr, this message translates to:
  /// **'Liste yenilenemedi. Bağlantını kontrol edip tekrar dene.'**
  String get coachMeetings_refreshFailed;

  /// Second line of a meeting row: "12 Ekim 2026 Pazartesi · 16:00" (pano 10.5 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'{date} · {time}'**
  String coachMeetings_rowWhen(String date, String time);

  /// Primary action of the new-meeting sheet (pano 10.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Görüşmeyi Kaydet'**
  String get coachMeetings_saveAction;

  /// Toast when saving a meeting failed; the sheet stays open (kit rule, pano 10.6 Davranış).
  ///
  /// In tr, this message translates to:
  /// **'Görüşme kaydedilemedi. Bağlantını kontrol edip tekrar dene.'**
  String get coachMeetings_saveFailed;

  /// Toast after "Görüşmeyi Kaydet" (pano 10.5 Davranış).
  ///
  /// In tr, this message translates to:
  /// **'Görüşme kaydedildi.'**
  String get coachMeetings_saved;

  /// Toast when the meeting was saved and its note was not (the note goes in a second call).
  ///
  /// In tr, this message translates to:
  /// **'Görüşme kaydedildi ama not eklenemedi.'**
  String get coachMeetings_savedWithoutNote;

  /// Search field placeholder and accessible name (pano 10.5 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Görüşme ara'**
  String get coachMeetings_searchHint;

  /// Action of the no-result card of the "Kiminle" choice: back to "Tümü".
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Göster'**
  String get coachMeetings_showAll;

  /// Detail row title (pano 10.5 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Öğrencinin verileri'**
  String get coachMeetings_studentData;

  /// Detail row sub text (pano 10.5 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Analiz, denemeler, program'**
  String get coachMeetings_studentDataHint;

  /// Placeholder of the student field while none is chosen. Assumption.
  ///
  /// In tr, this message translates to:
  /// **'Öğrenci seç'**
  String get coachMeetings_studentHint;

  /// Label of the student field (pano 10.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Öğrenci'**
  String get coachMeetings_studentLabel;

  /// Error under the student field when "Görüşmeyi Kaydet" is pressed without one. Assumption.
  ///
  /// In tr, this message translates to:
  /// **'Bir öğrenci seç.'**
  String get coachMeetings_studentMissing;

  /// Toast when the student list for the new-meeting sheet could not be loaded.
  ///
  /// In tr, this message translates to:
  /// **'Öğrenciler yüklenemedi. Bağlantını kontrol edip tekrar dene.'**
  String get coachMeetings_studentsFailed;

  /// Label of the time field (pano 10.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Saat'**
  String get coachMeetings_timeLabel;

  /// Title of the time picker sheet. The board draws no picker; built from the kit time wheel. Assumption.
  ///
  /// In tr, this message translates to:
  /// **'Saat'**
  String get coachMeetings_timeTitle;

  /// Group title of the meetings from now on (pano 10.5 kare 1: "Yaklaşan · 2").
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşan · {count}'**
  String coachMeetings_upcoming(String count);

  /// "Kiminle" chip: every kind (pano 10.5 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get coachMeetings_withAll;

  /// Accessible name of the "Kiminle" chips and the label of the kind segment in the new-meeting sheet (pano 10.5 kare 1 and 2).
  ///
  /// In tr, this message translates to:
  /// **'Kiminle'**
  String get coachMeetings_withLabel;

  /// Empty bag sentence of the topic sheet in a coach's view; {name} carries its genitive suffix. Not in a board.
  ///
  /// In tr, this message translates to:
  /// **'Çantada henüz konu yok. {name} denemelerinden çıkan eksik konular burada görünür.'**
  String coachStudentProfile_bagEmpty(String name);

  /// Help under the topic sheet segment in a coach's view; {name} carries its genitive suffix: "Çanta: Alparslan'ın denemelerinden çıkan eksik konular." (brief 14.2 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Çanta: {name} denemelerinden çıkan eksik konular.'**
  String coachStudentProfile_bagHelp(String name);

  /// Topic sheet segment in a coach's view (brief 14.2 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Çanta'**
  String get coachStudentProfile_bagSegment;

  /// Sentence under the screen error title; no inner code.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantını kontrol edip tekrar dene.'**
  String get coachStudentProfile_errorMessage;

  /// Title of the screen error when the student could not be read (pano 1.22 kare 4 pattern; brief 14.3).
  ///
  /// In tr, this message translates to:
  /// **'Öğrenci yüklenemedi'**
  String get coachStudentProfile_errorTitle;

  /// Sentence of the empty Analiz and Denemeler tabs of a coach's view; {name} is the student's first name.
  ///
  /// In tr, this message translates to:
  /// **'{name} bir deneme okuttuğunda sonuçları burada görünür.'**
  String coachStudentProfile_examsEmptyMessage(String name);

  /// Summary line of the Denemeler tab when the exam count is not known.
  ///
  /// In tr, this message translates to:
  /// **'En yeni önce'**
  String get coachStudentProfile_examsOrder;

  /// Summary line of the Denemeler tab (pano 10.4 kare 2): "10 deneme · en yeni önce".
  ///
  /// In tr, this message translates to:
  /// **'{count} deneme · en yeni önce'**
  String coachStudentProfile_examsSummary(String count);

  /// Step 1 sentence of a coach's new program flow (brief 14.2 kare 1); {name} is the first name.
  ///
  /// In tr, this message translates to:
  /// **'{name} için birden çok gün seçebilirsin; geçmiş günler seçilemez.'**
  String coachStudentProfile_newDaysBody(String name);

  /// Step 1 title of a coach's new program flow (brief 14.2 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Hangi günler çalışacak?'**
  String get coachStudentProfile_newDaysTitle;

  /// Step 3 title of a coach's new program flow (brief 14.2 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Programa ad ver'**
  String get coachStudentProfile_newNameTitle;

  /// Sentence under the not-found title.
  ///
  /// In tr, this message translates to:
  /// **'Bu öğrenci listende görünmüyor. Öğrencilerim\'e dönüp yeniden seçebilirsin.'**
  String get coachStudentProfile_notFoundMessage;

  /// Title shown when the student id is not in the coach's list (a stale link).
  ///
  /// In tr, this message translates to:
  /// **'Öğrenci bulunamadı'**
  String get coachStudentProfile_notFoundTitle;

  /// Bar action of Öğrenci Profili; opens the new meeting sheet with the student chosen (pano 10.4 kare 1 to 3).
  ///
  /// In tr, this message translates to:
  /// **'Görüşme Planla'**
  String get coachStudentProfile_planMeeting;

  /// Reading of the inline "Düzenle" of the Program tab (brief 14.1 "Okunuş"); {name} carries its genitive suffix.
  ///
  /// In tr, this message translates to:
  /// **'{name} programını düzenle'**
  String coachStudentProfile_programEditA11y(String name);

  /// Sentence of the empty Program tab / list (brief 14.1 kare 4); {name} is the first name.
  ///
  /// In tr, this message translates to:
  /// **'Onun için bir hafta kurabilirsin; {name} programı kendi Anasayfa\'sında görür.'**
  String coachStudentProfile_programEmptyBody(String name);

  /// Sentence of the empty Program tab while `FeatureFlags.coachProgramWriteEnabled` is off (pano 10.4 kare 3 read-only behavior); {name} is the first name. Not in a board: the read-only tab has no empty state.
  ///
  /// In tr, this message translates to:
  /// **'{name} programını kurduğunda burada görünür.'**
  String coachStudentProfile_programEmptyBodyReadOnly(String name);

  /// Title of the empty Program tab / list (brief 14.1 kare 4); {name} carries its genitive suffix: "Alparslan'ın programı yok".
  ///
  /// In tr, this message translates to:
  /// **'{name} programı yok'**
  String coachStudentProfile_programEmptyTitle(String name);

  /// InfoBox under the Program tab (brief 14.1 kare 1); {name} is the first name.
  ///
  /// In tr, this message translates to:
  /// **'Bu programı {name} da görür ve düzenleyebilir. Yaptığın değişiklik onun programına hemen yansır.'**
  String coachStudentProfile_programInfo(String name);

  /// Sentence under the section error title; no inner code (brief 14.3 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Bağlantını kontrol edip tekrar dene.'**
  String get coachStudentProfile_programLoadErrorBody;

  /// Title of the section error of the Program tab and of the coach's program list (brief 14.3 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Programlar yüklenemedi'**
  String get coachStudentProfile_programLoadErrorTitle;

  /// Note while offline in a coach's program screens (brief 14.3 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Program kurmak ve düzenlemek için bağlantı gerekiyor. Kayıtlı programı görebilirsin.'**
  String get coachStudentProfile_programOfflineNote;

  /// Error toast when a coach's program could not be saved, new program or edit (brief 14.2 "Akış", 14.3 "Durum metinleri"); the form and the changes are kept.
  ///
  /// In tr, this message translates to:
  /// **'Program kaydedilemedi. Bağlantını kontrol edip tekrar dene.'**
  String get coachStudentProfile_programSaveFailed;

  /// Toast after a coach saved a new program; {name} carries its genitive suffix: "Program Alparslan'ın hesabına kaydedildi." (brief 14.2 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Program {name} hesabına kaydedildi.'**
  String coachStudentProfile_programSaved(String name);

  /// Primary action of the empty Program tab / list (brief 14.1 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Program Kur'**
  String get coachStudentProfile_programSetUp;

  /// Value line of the "Programlar" row: "3 program".
  ///
  /// In tr, this message translates to:
  /// **'{count} program'**
  String coachStudentProfile_programsCount(String count);

  /// Settings row that opens the student's program list (brief 14.1 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Programlar'**
  String get coachStudentProfile_programsRow;

  /// Title of the program list in a coach's view (brief 14.1 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Programlar'**
  String get coachStudentProfile_programsTitle;

  /// Right side of the context strip: the class and the field short form, "12. Sınıf · EA" (pano 10.4).
  ///
  /// In tr, this message translates to:
  /// **'{grade} · {track}'**
  String coachStudentProfile_stripDetail(String grade, String track);

  /// Spoken form of the context strip's class and field: "12. Sınıf, Eşit Ağırlık".
  ///
  /// In tr, this message translates to:
  /// **'{grade}, {track}'**
  String coachStudentProfile_stripDetailA11y(String grade, String track);

  /// First row label of the new program summary card in a coach's flow; the value is the student's full name (brief 14.2 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Kimin için'**
  String get coachStudentProfile_summaryWho;

  /// First in-screen tab of Öğrenci Profili (pano 10.4).
  ///
  /// In tr, this message translates to:
  /// **'Analiz'**
  String get coachStudentProfile_tabAnalysis;

  /// Second in-screen tab of Öğrenci Profili (pano 10.4).
  ///
  /// In tr, this message translates to:
  /// **'Denemeler'**
  String get coachStudentProfile_tabExams;

  /// Third in-screen tab of Öğrenci Profili (pano 10.4).
  ///
  /// In tr, this message translates to:
  /// **'Program'**
  String get coachStudentProfile_tabProgram;

  /// Accessible name of the Analiz, Denemeler and Program tabs (pano 10.4, "tablist").
  ///
  /// In tr, this message translates to:
  /// **'Öğrenci verileri sekmeleri'**
  String get coachStudentProfile_tabsA11y;

  /// Short form of the Dil field in the context strip (pano 10.4).
  ///
  /// In tr, this message translates to:
  /// **'DİL'**
  String get coachStudentProfile_trackShortDil;

  /// Short form of the Eşit Ağırlık field in the context strip: "12. Sınıf · EA" (pano 10.4).
  ///
  /// In tr, this message translates to:
  /// **'EA'**
  String get coachStudentProfile_trackShortEsitAgirlik;

  /// Short form of the Sayısal field in the context strip's "12. Sınıf · SAY" (pano 10.4).
  ///
  /// In tr, this message translates to:
  /// **'SAY'**
  String get coachStudentProfile_trackShortSayisal;

  /// Short form of the Sözel field in the context strip (pano 10.4).
  ///
  /// In tr, this message translates to:
  /// **'SÖZ'**
  String get coachStudentProfile_trackShortSozel;

  /// The two exam dates of the net-drop evidence: '17 Haz. ve 4 Ağu.' (C33).
  ///
  /// In tr, this message translates to:
  /// **'{first} ve {second}'**
  String coachWidgets_attentionDates(String first, String second);

  /// Sentence of the inactive rule: '45 gündür deneme okutmadı' (C33; pano 10.1 kare 2, D-27).
  ///
  /// In tr, this message translates to:
  /// **'{days} gündür deneme okutmadı'**
  String coachWidgets_attentionInactive(String days);

  /// Evidence line of the inactive rule: 'Son deneme 17 Haz. 2026' (C33).
  ///
  /// In tr, this message translates to:
  /// **'Son deneme {date}'**
  String coachWidgets_attentionInactiveEvidence(String date);

  /// Evidence line of the inactive rule with the exam type: 'Son deneme 17 Haz. 2026 · TYT' (C33).
  ///
  /// In tr, this message translates to:
  /// **'Son deneme {date} · {type}'**
  String coachWidgets_attentionInactiveEvidenceType(String date, String type);

  /// Screen-reader tail of the inactive rule: 'son deneme 17 Haziran' (C33).
  ///
  /// In tr, this message translates to:
  /// **'son deneme {date}'**
  String coachWidgets_attentionLastExamA11y(String date);

  /// Sentence of the net-drop rule: 'Son iki TYT denemesinde net düştü' (C33; pano 10.1 kare 2, D-27).
  ///
  /// In tr, this message translates to:
  /// **'Son iki {type} denemesinde net düştü'**
  String coachWidgets_attentionNetDrop(String type);

  /// Sentence of the net-drop rule without the exam type (C33).
  ///
  /// In tr, this message translates to:
  /// **'Son iki denemede net düştü'**
  String get coachWidgets_attentionNetDropPlain;

  /// Evidence line of the net-drop rule: '68 → 66,75 · 17 Haz. ve 4 Ağu.' (C33).
  ///
  /// In tr, this message translates to:
  /// **'{from} → {to} · {dates}'**
  String coachWidgets_attentionNetEvidence(
    String from,
    String to,
    String dates,
  );

  /// Evidence line of the net-drop rule without the dates (C33).
  ///
  /// In tr, this message translates to:
  /// **'{from} → {to}'**
  String coachWidgets_attentionNetEvidenceNets(String from, String to);

  /// Screen-reader reading of the code (C35).
  ///
  /// In tr, this message translates to:
  /// **'Koçluk kodun {code}'**
  String coachWidgets_codeA11y(String code);

  /// Toast after the code is copied (C35, 4 s).
  ///
  /// In tr, this message translates to:
  /// **'Kod kopyalandı.'**
  String get coachWidgets_codeCopied;

  /// Button of the coaching code card that copies the code (C35).
  ///
  /// In tr, this message translates to:
  /// **'Kopyala'**
  String get coachWidgets_codeCopy;

  /// Help line of the coaching code card (C35).
  ///
  /// In tr, this message translates to:
  /// **'Öğrencin bu kodu Hesap › Koçluk\'a girince sana bağlanır.'**
  String get coachWidgets_codeHint;

  /// Button of the coaching code card that opens the share sheet (C35).
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get coachWidgets_codeShare;

  /// The sentence the share sheet carries.
  ///
  /// In tr, this message translates to:
  /// **'SMAP\'te koçluk kodum: {code}'**
  String coachWidgets_codeShareText(String code);

  /// Label of the coaching code card (C35; pano 10.1 kare 3, 10.3 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Koçluk kodun'**
  String get coachWidgets_codeTitle;

  /// Screen-reader reading of a meeting row: 'Alparslan Kuloğlu, 12 Ekim 2026 Pazartesi, 16:00, Öğrenci görüşmesi' (C34).
  ///
  /// In tr, this message translates to:
  /// **'{name}, {date}, {time}, {kind}'**
  String coachWidgets_meetingA11y(
    String name,
    String date,
    String time,
    String kind,
  );

  /// Screen-reader reading of a meeting row of unknown kind (C34).
  ///
  /// In tr, this message translates to:
  /// **'{name}, {date}, {time}'**
  String coachWidgets_meetingA11yPlain(String name, String date, String time);

  /// Meeting kind in the screen-reader reading (C34).
  ///
  /// In tr, this message translates to:
  /// **'Veli görüşmesi'**
  String get coachWidgets_meetingKindParentA11y;

  /// Meeting kind in the screen-reader reading (C34).
  ///
  /// In tr, this message translates to:
  /// **'Öğrenci görüşmesi'**
  String get coachWidgets_meetingKindStudentA11y;

  /// Meta of the list meeting row: '12 Ekim 2026 Pazartesi · 16:00' (C34; pano 10.5).
  ///
  /// In tr, this message translates to:
  /// **'{date} · {time}'**
  String coachWidgets_meetingListMeta(String date, String time);

  /// Meta of the date-block meeting row: 'Pazartesi 16:00 · Öğrenci' (C34; pano 10.1).
  ///
  /// In tr, this message translates to:
  /// **'{day} {time} · {kind}'**
  String coachWidgets_meetingMeta(String day, String time, String kind);

  /// Meta of the date-block meeting row when the kind is unknown (C34).
  ///
  /// In tr, this message translates to:
  /// **'{day} {time}'**
  String coachWidgets_meetingMetaPlain(String day, String time);

  /// Month under the day of the meeting's date block: 'Eki.' (C34; pano 10.1).
  ///
  /// In tr, this message translates to:
  /// **'{month}.'**
  String coachWidgets_meetingMonth(String month);

  /// Meeting kind tag/meta: with the parent (C34; pano 10.1, 10.5).
  ///
  /// In tr, this message translates to:
  /// **'Veli'**
  String get coachWidgets_meetingParent;

  /// Meeting kind tag/meta: with the student (C34; pano 10.1, 10.5).
  ///
  /// In tr, this message translates to:
  /// **'Öğrenci'**
  String get coachWidgets_meetingStudent;

  /// Screen-reader reading of a student tile (C32).
  ///
  /// In tr, this message translates to:
  /// **'{name}, öğrenci'**
  String coachWidgets_tileA11y(String name);

  /// Screen-reader reading of a student tile with a last exam date (C32).
  ///
  /// In tr, this message translates to:
  /// **'{name}, son deneme {date}'**
  String coachWidgets_tileA11yLastExam(String name, String date);

  /// Second line of a student tile with a last exam date: 'Son deneme 5 Eki.' (C32; pano 10.1 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Son deneme {date}'**
  String coachWidgets_tileLastExam(String date);

  /// Primary button of the change sheet (Tur 12 F).
  ///
  /// In tr, this message translates to:
  /// **'Koçu Değiştir'**
  String get coachingChange_action;

  /// Reading of the code field of the change sheet (pano 14.10 Erişilebilirlik).
  ///
  /// In tr, this message translates to:
  /// **'Koçluk kodu, 4 harf ve 4 rakam'**
  String get coachingChange_codeA11y;

  /// Error under the code field when the code is the current coach's (Tur 12 F, 14.10 kare 3); the name arrives with its dative suffix: "Mehmet Özkan'a".
  ///
  /// In tr, this message translates to:
  /// **'Bu kod zaten koçun {name} ait.'**
  String coachingChange_errSameCoach(String name);

  /// Info box of the change sheet; the old coach's name arrives with its "ile" suffix: "Mehmet Özkan'la" (pano 14.10 kare 2, T12.21).
  ///
  /// In tr, this message translates to:
  /// **'{oldWith} bağlantın kalkar; gelişimini artık göremez. Yeni koçun denemelerini, analizlerini ve programını görür.'**
  String coachingChange_notice(String oldWith);

  /// One line under the two disabled actions while offline (pano 14.10 kare 6).
  ///
  /// In tr, this message translates to:
  /// **'Koçunu değiştirmek ya da bağlantıyı kaldırmak için bağlantı gerekiyor.'**
  String get coachingChange_offlineNote;

  /// Outlined button under the coach card that opens the change sheet (pano 14.10 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Koçu Değiştir'**
  String get coachingChange_open;

  /// Subtitle of the change sheet (pano 14.10 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Yeni koçunun verdiği kodu gir.'**
  String get coachingChange_subtitle;

  /// Title of the change sheet (Tur 12 F, 14.10 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Koçunu değiştir'**
  String get coachingChange_title;

  /// First paragraph of the explanation sheet (pano 9.5 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Koçluk kodu, koçunun SMAP hesabına özel koddur; dört harf ve dört rakamdan oluşur.'**
  String get coachingInfo_body1;

  /// Second paragraph of the explanation sheet (pano 9.5 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Kodu koçundan iste. Girdiğinde koçun denemelerini, analizlerini ve programını görebilir. Bağlantıyı istediğin an buradan kaldırabilirsin.'**
  String get coachingInfo_body2;

  /// Title of the explanation sheet (pano 9.5 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Koçluk kodu nedir?'**
  String get coachingInfo_title;

  /// Small line under the coach's name on the coach card (pano 9.5 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Koçun'**
  String get coaching_coachLabel;

  /// Help line under the coaching code field (pano 9.5 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'4 harf ve 4 rakam; tire kendiliğinden gelir.'**
  String get coaching_codeHelp;

  /// Example in the empty coaching code field (pano 9.5 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Örn: MOZK-4821'**
  String get coaching_codeHint;

  /// Label of the coaching code field (pano 9.5 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Koçluk kodu'**
  String get coaching_codeLabel;

  /// Primary button of the unlinked state (pano 9.5 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Koça Bağlan'**
  String get coaching_connect;

  /// Error under the code field when no coach has the code (pano 9.5 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Bu kodla bir koç bulunamadı. Kodu koçundan yeniden iste.'**
  String get coaching_errNotFound;

  /// Title of the screen-level error state of Koçluk (pano 1.22 kare 4 wording).
  ///
  /// In tr, this message translates to:
  /// **'Koçluk yüklenemedi'**
  String get coaching_errorTitle;

  /// Info box under the coach card (pano 9.5 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'{name} denemelerini, analizlerini ve programını görebilir.'**
  String coaching_infoBox(String name);

  /// Toast after linking to a coach (pano 9.5 kare 3); the name arrives with its dative suffix: "Mehmet Özkan'a".
  ///
  /// In tr, this message translates to:
  /// **'{name} bağlandın.'**
  String coaching_linked(String name);

  /// Title of the coaching screen (pano 9.5).
  ///
  /// In tr, this message translates to:
  /// **'Koçluk'**
  String get coaching_title;

  /// Red text button and the danger button of its confirm sheet (pano 9.5 kare 1 and 2).
  ///
  /// In tr, this message translates to:
  /// **'Bağlantıyı Kaldır'**
  String get coaching_unlinkAction;

  /// Body of the unlink confirm sheet (pano 9.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'{name} gelişimini artık göremeyecek. Yeniden bağlanmak için koçluk kodunu tekrar girmen gerekir.'**
  String coaching_unlinkBody(String name);

  /// Title of the unlink confirm sheet (pano 9.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Koç bağlantısı kaldırılsın mı?'**
  String get coaching_unlinkTitle;

  /// Toast after the coach was unlinked (pano 9.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Koç bağlantın kaldırıldı.'**
  String get coaching_unlinked;

  /// Sentence above the code field when the student has no coach (pano 9.5 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Koçunun verdiği kodu gir; koçun denemelerini, analizlerini ve programını görebilsin.'**
  String get coaching_unlinkedIntro;

  /// Text button that opens the explanation sheet (pano 9.5 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Koçluk Kodu Nedir?'**
  String get coaching_whatIsCode;

  /// Dismiss button of dialogs and sheets. Never use 'İptal'.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get common_cancel;

  /// Close action. Accessibility labels only.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get common_close;

  /// Generic continue button.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get common_continue;

  /// Acknowledge button.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get common_ok;

  /// Retry action of error states.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get common_retry;

  /// Generic save button.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get common_save;

  /// Undo action. Toast action only.
  ///
  /// In tr, this message translates to:
  /// **'Geri Al'**
  String get common_undo;

  /// The danger button of the explanation and of the confirm sheet (pano 9.4 kare 2 and 3).
  ///
  /// In tr, this message translates to:
  /// **'Hesabımı Sil'**
  String get deletion_confirmAction;

  /// Body of the dangerous confirm sheet (pano 9.4 kare 3); the name is the user's full name.
  ///
  /// In tr, this message translates to:
  /// **'{name} hesabı ve bütün verilerin kalıcı olarak silinecek. Bu işlem geri alınamaz.'**
  String deletion_confirmBody(String name);

  /// Body of the confirm sheet when the account has no name to show.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın ve bütün verilerin kalıcı olarak silinecek. Bu işlem geri alınamaz.'**
  String get deletion_confirmBodyAnonymous;

  /// Title of the dangerous confirm sheet (pano 9.4 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Hesabın silinsin mi?'**
  String get deletion_confirmTitle;

  /// Sentence under the end title (pano 9.4 kare 5).
  ///
  /// In tr, this message translates to:
  /// **'Verilerin silindi. İstersen yeni bir hesapla yeniden başlayabilirsin.'**
  String get deletion_doneBody;

  /// Title of the end screen (pano 9.4 kare 5).
  ///
  /// In tr, this message translates to:
  /// **'Hesabın silindi'**
  String get deletion_doneTitle;

  /// Error box on the explanation after the deletion failed (pano 9.4 kare 4 note).
  ///
  /// In tr, this message translates to:
  /// **'Hesabın silinemedi. Bağlantını kontrol edip tekrar dene.'**
  String get deletion_failed;

  /// Third line of the list, for a student who has a coach (pano 9.4 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Koçun {name} ile bağlantın kalkar.'**
  String deletion_lineCoach(String name);

  /// Third line while the coach's name is not known yet (it is loaded in the background).
  ///
  /// In tr, this message translates to:
  /// **'Koçunla bağlantın kalkar.'**
  String get deletion_lineCoachAnonymous;

  /// First line of the list (pano 9.4 kare 2); the count is the number of exams the student has read.
  ///
  /// In tr, this message translates to:
  /// **'Okuttuğun {count} deneme ve analizleri silinir.'**
  String deletion_lineExams(String count);

  /// First line of the list when the account does not say how many exams were read (no number is made up).
  ///
  /// In tr, this message translates to:
  /// **'Okuttuğun denemeler ve analizleri silinir.'**
  String get deletion_lineExamsAnonymous;

  /// Last line of the list (pano 9.4 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem geri alınamaz.'**
  String get deletion_lineIrreversible;

  /// Second line of the list (pano 9.4 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Eksik konuların, programların ve bilgi kartı ilerlemen silinir.'**
  String get deletion_lineProgress;

  /// Heading of the list of what is lost (pano 9.4 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Hesabını silersen:'**
  String get deletion_listHeading;

  /// Closing note under the list: signing out is enough for a pause (pano 9.4 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Yalnız bir süre ara vermek istiyorsan çıkış yapman yeterli; verilerin hesabında kalır.'**
  String get deletion_pauseHint;

  /// Sentence under the progress title (pano 9.4 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Uygulamayı kapatma.'**
  String get deletion_progressBody;

  /// Title of the full-screen progress (pano 9.4 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Hesabın siliniyor'**
  String get deletion_progressTitle;

  /// Title of the account deletion explanation (pano 9.4 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Hesabını sil'**
  String get deletion_title;

  /// AppErrorCode.cancelled. Normally not shown. Never say 'iptal'.
  ///
  /// In tr, this message translates to:
  /// **'İşlem durduruldu.'**
  String get errors_cancelled;

  /// AppErrorCode.forbidden.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem için yetkin yok.'**
  String get errors_forbidden;

  /// AppErrorCode.maintenance (503). No time promise.
  ///
  /// In tr, this message translates to:
  /// **'SMAP şu an bakımda. Biraz sonra tekrar dene.'**
  String get errors_maintenance;

  /// AppErrorCode.network: the connection broke or was refused.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantıda bir sorun oluştu. Biraz sonra tekrar dene.'**
  String get errors_network;

  /// AppErrorCode.notFound.
  ///
  /// In tr, this message translates to:
  /// **'Aradığın içerik bulunamadı.'**
  String get errors_notFound;

  /// AppErrorCode.offline: the device has no route to the server.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı yok. Bağlantını kontrol edip tekrar dene.'**
  String get errors_offline;

  /// AppErrorCode.server: 5xx other than maintenance.
  ///
  /// In tr, this message translates to:
  /// **'Sunucuda bir sorun oluştu. Biraz sonra tekrar dene.'**
  String get errors_server;

  /// AppErrorCode.sessionExpired: the session cookie is no longer valid.
  ///
  /// In tr, this message translates to:
  /// **'Oturumun sona erdi. Yeniden giriş yapman gerekiyor.'**
  String get errors_sessionExpired;

  /// AppErrorCode.timeout: a connect, send or receive deadline passed.
  ///
  /// In tr, this message translates to:
  /// **'İstek çok uzun sürdü. Tekrar dene.'**
  String get errors_timeout;

  /// AppErrorCode.unauthorized: credentials rejected.
  ///
  /// In tr, this message translates to:
  /// **'Giriş bilgilerin doğru değil. Kontrol edip tekrar dene.'**
  String get errors_unauthorized;

  /// AppErrorCode.unknown.
  ///
  /// In tr, this message translates to:
  /// **'Beklenmedik bir sorun oluştu. Tekrar dene.'**
  String get errors_unknown;

  /// AppErrorCode.validation: the server rejected the input. A server-written message may replace this text.
  ///
  /// In tr, this message translates to:
  /// **'Bilgilerini kontrol edip tekrar dene.'**
  String get errors_validation;

  /// Text when the question has no explanation (pano 5.7 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Bu soru için çözüm açıklaması yok.'**
  String get examDetail_analysisEmpty;

  /// Section title of Soru Detay (pano 5.7).
  ///
  /// In tr, this message translates to:
  /// **'Soru Analizi'**
  String get examDetail_analysisTitle;

  /// Answer card sentence of a blank question when the letters are not in the data (no pano text).
  ///
  /// In tr, this message translates to:
  /// **'Bu soruyu boş bıraktın.'**
  String get examDetail_answerBlankSentence;

  /// Label of the answer card (pano 5.7).
  ///
  /// In tr, this message translates to:
  /// **'Doğru cevap'**
  String get examDetail_answerCorrect;

  /// Answer card sentence of a right question (pano 5.7 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'İşaretin doğru cevap.'**
  String get examDetail_answerCorrectSentence;

  /// Label of the answer card (pano 5.7).
  ///
  /// In tr, this message translates to:
  /// **'İşaretin'**
  String get examDetail_answerMarked;

  /// Answer card sentence of a wrong question when the letters are not in the data (no pano text: the board always shows the letters).
  ///
  /// In tr, this message translates to:
  /// **'Bu soruyu yanlış işaretledin.'**
  String get examDetail_answerWrongSentence;

  /// Screen reader reading of a lesson row of the Kartlar tab; it opens the lesson's deck.
  ///
  /// In tr, this message translates to:
  /// **'{lesson}, {count} kart'**
  String examDetail_cardGroupA11y(String lesson, String count);

  /// Count at the right of a lesson group of the Kartlar tab.
  ///
  /// In tr, this message translates to:
  /// **'{count} kart'**
  String examDetail_cardGroupCount(String count);

  /// Title of the info card of the Kartlar tab (pano 5.6).
  ///
  /// In tr, this message translates to:
  /// **'{count} bilgi kartı eklendi'**
  String examDetail_cardsAdded(String count);

  /// Body of the info card of the Kartlar tab (pano 5.6).
  ///
  /// In tr, this message translates to:
  /// **'Bu denemede yanlış ve boş bıraktığın sorulardan.'**
  String get examDetail_cardsAddedBody;

  /// Section empty text of the Kartlar tab (pano 5.8 'Boş metinleri').
  ///
  /// In tr, this message translates to:
  /// **'Bu denemeden kart eklenmedi.'**
  String get examDetail_cardsEmpty;

  /// Section error text of the Kartlar tab.
  ///
  /// In tr, this message translates to:
  /// **'Kartlar yüklenemedi.'**
  String get examDetail_cardsError;

  /// Note at the end of Soru Detay (pano 5.7).
  ///
  /// In tr, this message translates to:
  /// **'Sorunun fotoğrafı telif hakları nedeniyle paylaşılamıyor.'**
  String get examDetail_copyrightNote;

  /// Counter of the 'Boşlar' option (pano 5.4).
  ///
  /// In tr, this message translates to:
  /// **'{count} boş'**
  String examDetail_counterBlank(String count);

  /// Counter of the 'Boşlar' option when there is no blank question (pano 5.4).
  ///
  /// In tr, this message translates to:
  /// **'boş yok'**
  String get examDetail_counterNoBlank;

  /// Counter of the 'Yanlışlar' option when there is no wrong question.
  ///
  /// In tr, this message translates to:
  /// **'yanlış yok'**
  String get examDetail_counterNoWrong;

  /// Counter of the 'Yanlışlar' option (pano 5.4: '74 yanlış').
  ///
  /// In tr, this message translates to:
  /// **'{count} yanlış'**
  String examDetail_counterWrong(String count);

  /// Screen error message (pano 5.8 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Bağlantını kontrol edip tekrar dene.'**
  String get examDetail_errorMessage;

  /// Screen error title (pano 5.8 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Deneme yüklenemedi'**
  String get examDetail_errorTitle;

  /// Screen reader name of the question filter segment (pano 5.4).
  ///
  /// In tr, this message translates to:
  /// **'Soru süzgeci'**
  String get examDetail_filterA11y;

  /// Question filter option (pano 5.4).
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get examDetail_filterAll;

  /// Question filter option (pano 5.4).
  ///
  /// In tr, this message translates to:
  /// **'Boşlar'**
  String get examDetail_filterBlank;

  /// Question filter option (pano 5.4).
  ///
  /// In tr, this message translates to:
  /// **'Yanlışlar'**
  String get examDetail_filterWrong;

  /// Screen reader reading of a lesson heading of the Konular tab.
  ///
  /// In tr, this message translates to:
  /// **'{lesson}, zayıftan güçlüye, {total} soru'**
  String examDetail_lessonGroupA11y(String lesson, String total);

  /// Caption of the most missed topic card (pano 5.5).
  ///
  /// In tr, this message translates to:
  /// **'En çok kaçırdığın konu'**
  String get examDetail_mostMissedLabel;

  /// Sentence of the most missed topic card (pano 5.5). {wrong} arrives with its suffix from TurkishSuffix.possessiveAccusative ('7'sini').
  ///
  /// In tr, this message translates to:
  /// **'{total} sorudan {wrong} kaçırdın.'**
  String examDetail_mostMissedSentence(String total, String wrong);

  /// Footnote of the Genel tab (pano 5.3 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Net = doğru − yanlış ÷ 4; boş neti etkilemez.'**
  String get examDetail_netRule;

  /// Footnote of the Genel tab (pano 5.3 kare 2); {list} is the 'Eşit Ağırlık 40 · Sayısal 37,5 · Sözel 30' text.
  ///
  /// In tr, this message translates to:
  /// **'Puan türüne göre net: {list}.'**
  String examDetail_netsByScoreType(String list);

  /// Body of the empty card of the 'Boşlar' filter (pano 5.4 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Bu denemedeki {count} sorunun hepsini işaretledin.'**
  String examDetail_noBlankBody(String count);

  /// Title of the empty card of the 'Boşlar' filter (pano 5.4 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Boş bıraktığın soru yok'**
  String get examDetail_noBlankTitle;

  /// Body of the section empty card of the Genel tab (pano 5.8 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Netin ve doğru, yanlış, boş sayıların hesaplandı; bu deneme için ders bazında sonuç gelmedi.'**
  String get examDetail_noBreakdownBody;

  /// Title of the section empty card of the Genel tab (pano 5.8 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Ders kırılımı yok'**
  String get examDetail_noBreakdownTitle;

  /// Body of the empty card of the 'Yanlışlar' filter.
  ///
  /// In tr, this message translates to:
  /// **'Bu denemedeki {count} sorunun hiçbirini yanlış yapmadın.'**
  String examDetail_noWrongBody(String count);

  /// Title of the empty card of the 'Yanlışlar' filter (same pattern as pano 5.4 kare 3; the board draws only the blank one).
  ///
  /// In tr, this message translates to:
  /// **'Yanlış yaptığın soru yok'**
  String get examDetail_noWrongTitle;

  /// Line under the Soru Detay title (pano 5.7).
  ///
  /// In tr, this message translates to:
  /// **'{test} · {lesson}'**
  String examDetail_questionContext(String test, String lesson);

  /// Question cell reading, right answer when the data does not say which option was marked (the backend sends the outcome only, spec 6.3 #9): the reading never ends in an empty "işaretin".
  ///
  /// In tr, this message translates to:
  /// **'Soru {number}, doğru'**
  String examDetail_questionCorrectNoMarkA11y(int number);

  /// Screen error title of Soru Detay.
  ///
  /// In tr, this message translates to:
  /// **'Soru yüklenemedi'**
  String get examDetail_questionErrorTitle;

  /// Section error text of Soru Detay (the explanation and cards did not load; the answer card stays).
  ///
  /// In tr, this message translates to:
  /// **'Soru açıklaması yüklenemedi.'**
  String get examDetail_questionLoadError;

  /// Title of Soru Detay (pano 5.7: '31. soru').
  ///
  /// In tr, this message translates to:
  /// **'{number}. soru'**
  String examDetail_questionTitle(String number);

  /// Question cell reading, wrong answer when the data does not say which option was marked.
  ///
  /// In tr, this message translates to:
  /// **'Soru {number}, yanlış'**
  String examDetail_questionWrongNoMarkA11y(int number);

  /// Section empty text of the Sorular tab (pano 5.8 'Boş metinleri').
  ///
  /// In tr, this message translates to:
  /// **'Bu deneme için soru ayrıntısı yok.'**
  String get examDetail_questionsEmpty;

  /// Section error text of the Sorular tab.
  ///
  /// In tr, this message translates to:
  /// **'Sorular yüklenemedi.'**
  String get examDetail_questionsError;

  /// Label under the raw points of the score card (Tur 12 B, 14.4).
  ///
  /// In tr, this message translates to:
  /// **'Ham puan'**
  String get examDetail_rawScore;

  /// Section title of Soru Detay (pano 5.7).
  ///
  /// In tr, this message translates to:
  /// **'İlgili kartlar'**
  String get examDetail_relatedCards;

  /// Count next to the section title (pano 5.7: '2 kart').
  ///
  /// In tr, this message translates to:
  /// **'{count} kart'**
  String examDetail_relatedCount(String count);

  /// One score type of the footnote: 'Eşit Ağırlık 40'.
  ///
  /// In tr, this message translates to:
  /// **'{field} {net}'**
  String examDetail_scoreTypeNet(String field, String net);

  /// Text button of the filter empty card (pano 5.4 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Tüm Soruları Göster'**
  String get examDetail_showAllQuestions;

  /// Primary button of the Kartlar tab and of Soru Detay (pano 5.6, 5.7).
  ///
  /// In tr, this message translates to:
  /// **'Kartları Çalış'**
  String get examDetail_studyCards;

  /// Primary button of the most missed topic card (pano 5.5).
  ///
  /// In tr, this message translates to:
  /// **'Bu Konuyu Çalış'**
  String get examDetail_studyTopic;

  /// In-screen tab (pano 5.6).
  ///
  /// In tr, this message translates to:
  /// **'Kartlar'**
  String get examDetail_tabCards;

  /// In-screen tab (pano 5.3).
  ///
  /// In tr, this message translates to:
  /// **'Genel'**
  String get examDetail_tabGeneral;

  /// In-screen tab (pano 5.4).
  ///
  /// In tr, this message translates to:
  /// **'Sorular'**
  String get examDetail_tabQuestions;

  /// In-screen tab (pano 5.5).
  ///
  /// In tr, this message translates to:
  /// **'Konular'**
  String get examDetail_tabTopics;

  /// Screen reader name of the in-screen tab row (pano 5.3 'aria: Deneme bölümleri').
  ///
  /// In tr, this message translates to:
  /// **'Deneme bölümleri'**
  String get examDetail_tabsA11y;

  /// Test name, TYT mathematics (pano 5.3 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Temel Matematik'**
  String get examDetail_testBasicMath;

  /// Test name, AYT mathematics (pano 5.3 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Matematik'**
  String get examDetail_testMath;

  /// Name of a test the app has no name for.
  ///
  /// In tr, this message translates to:
  /// **'{number}. Test'**
  String examDetail_testNumbered(String number);

  /// Test name, fourth test of both exams (pano 5.3).
  ///
  /// In tr, this message translates to:
  /// **'Fen Bilimleri'**
  String get examDetail_testSciences;

  /// Test name, TYT second test (pano 5.3 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Sosyal Bilimler'**
  String get examDetail_testSocial;

  /// Test name, AYT second test (pano 5.3 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Sosyal Bilimler 2'**
  String get examDetail_testSocial2;

  /// Test name, AYT first test (pano 5.3 kare 1). The dash is an en dash.
  ///
  /// In tr, this message translates to:
  /// **'Türk Dili ve Edebiyatı–Sosyal Bilimler 1'**
  String get examDetail_testSocialLiterature;

  /// Test name, TYT first test (pano 5.3 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get examDetail_testTurkish;

  /// Toast when a topic of the analysis is not among the lesson's topics; the lesson opens instead.
  ///
  /// In tr, this message translates to:
  /// **'Bu konu Derslerim\'de bulunamadı.'**
  String get examDetail_topicNotFound;

  /// Section empty text of the Konular tab (pano 5.8 'Boş metinleri').
  ///
  /// In tr, this message translates to:
  /// **'Konu analizi henüz hazır değil.'**
  String get examDetail_topicsEmpty;

  /// Section error text of the Konular tab.
  ///
  /// In tr, this message translates to:
  /// **'Konu analizi yüklenemedi.'**
  String get examDetail_topicsError;

  /// Sort note at the right of a lesson heading (pano 5.5).
  ///
  /// In tr, this message translates to:
  /// **'zayıftan güçlüye'**
  String get examDetail_weakToStrong;

  /// Question cell (C43): the right option under a wrong or blank question, "Doğru A".
  ///
  /// In tr, this message translates to:
  /// **'Doğru {answer}'**
  String exams_correctAnswer(String answer);

  /// Last-exam card: what the net change is measured against (C25). {type} is TYT or AYT, both take "ye".
  ///
  /// In tr, this message translates to:
  /// **'önceki {type}\'ye göre'**
  String exams_deltaVsPrevious(String type);

  /// Result moment: what the net change is measured against (C26, screen 5.1).
  ///
  /// In tr, this message translates to:
  /// **'önceki {type} denemene göre'**
  String exams_deltaVsPreviousMoment(String type);

  /// Screen reader sentence of a D/Y/B counter (C41): "86 doğru, 74 yanlış, 0 boş".
  ///
  /// In tr, this message translates to:
  /// **'{correct} doğru, {wrong} yanlış, {blank} boş'**
  String exams_dybA11y(int correct, int wrong, int blank);

  /// D/Y/B counter, large: the word beside the blank chip (C41).
  ///
  /// In tr, this message translates to:
  /// **'Boş'**
  String get exams_dybBlank;

  /// D/Y/B counter, large: the word under the correct chip (C41).
  ///
  /// In tr, this message translates to:
  /// **'Doğru'**
  String get exams_dybCorrect;

  /// D/Y/B counter, small with letters: blank (C41).
  ///
  /// In tr, this message translates to:
  /// **'B'**
  String get exams_dybLetterBlank;

  /// D/Y/B counter, small with letters: correct (C41).
  ///
  /// In tr, this message translates to:
  /// **'D'**
  String get exams_dybLetterCorrect;

  /// D/Y/B counter, small with letters: wrong (C41).
  ///
  /// In tr, this message translates to:
  /// **'Y'**
  String get exams_dybLetterWrong;

  /// D/Y/B counter, small with words: blank (C41).
  ///
  /// In tr, this message translates to:
  /// **'boş'**
  String get exams_dybWordBlank;

  /// D/Y/B counter, small with words: correct (C41).
  ///
  /// In tr, this message translates to:
  /// **'doğru'**
  String get exams_dybWordCorrect;

  /// D/Y/B counter, small with words: wrong (C41).
  ///
  /// In tr, this message translates to:
  /// **'yanlış'**
  String get exams_dybWordWrong;

  /// D/Y/B counter, large: the word beside the wrong chip (C41).
  ///
  /// In tr, this message translates to:
  /// **'Yanlış'**
  String get exams_dybWrong;

  /// Screen reader sentence of an exam row (C24).
  ///
  /// In tr, this message translates to:
  /// **'{name}, {type}, {date}, {net} net'**
  String exams_examRowA11y(String name, String type, String date, String net);

  /// Exam favorite star, not yet a favorite: tooltip and screen reader name (C24).
  ///
  /// In tr, this message translates to:
  /// **'Favorilere ekle'**
  String get exams_favoriteAdd;

  /// Exam favorite star, already a favorite: tooltip and screen reader name (C24).
  ///
  /// In tr, this message translates to:
  /// **'Favorilerden çıkar'**
  String get exams_favoriteRemove;

  /// Tag on a topic with one or two questions (C23).
  ///
  /// In tr, this message translates to:
  /// **'Az soru'**
  String get exams_fewQuestions;

  /// Form check cell reading, nothing read (C43, screen 4.7).
  ///
  /// In tr, this message translates to:
  /// **'{number}. soru, boş okundu, düzeltmek için dokun'**
  String exams_formCheckBlankA11y(int number);

  /// Form check cell reading, corrected by the student (C43, screen 4.7).
  ///
  /// In tr, this message translates to:
  /// **'{number}. soru, düzeltildi: {marked}'**
  String exams_formCheckCorrectedA11y(int number, String marked);

  /// Form check cell reading, read mark (C43, screen 4.7).
  ///
  /// In tr, this message translates to:
  /// **'{number}. soru, okundu: {marked}'**
  String exams_formCheckReadA11y(int number, String marked);

  /// Screen reader sentence of the result moment without a change (C26, screen 5.1).
  ///
  /// In tr, this message translates to:
  /// **'{name}, {net} net, {correct} doğru, {wrong} yanlış, {blank} boş'**
  String exams_momentA11y(
    String name,
    String net,
    int correct,
    int wrong,
    int blank,
  );

  /// Screen reader sentence of the result moment with the net change (C26, screen 5.1).
  ///
  /// In tr, this message translates to:
  /// **'{name}, {net} net, {correct} doğru, {wrong} yanlış, {blank} boş, önceki sınava göre {delta}'**
  String exams_momentWithDeltaA11y(
    String name,
    String net,
    int correct,
    int wrong,
    int blank,
    String delta,
  );

  /// The unit written after a net figure ("67,5 net").
  ///
  /// In tr, this message translates to:
  /// **'net'**
  String get exams_netUnit;

  /// Exam header score card: label under the score (C26).
  ///
  /// In tr, this message translates to:
  /// **'Yerleştirme puanı'**
  String get exams_placementScore;

  /// Question cell reading, blank question (C43).
  ///
  /// In tr, this message translates to:
  /// **'Soru {number}, boş, doğru cevap {correctAnswer}'**
  String exams_questionBlankA11y(int number, String correctAnswer);

  /// Question cell reading, blank question when the data has no answer key (C43).
  ///
  /// In tr, this message translates to:
  /// **'Soru {number}, boş'**
  String exams_questionBlankNoKeyA11y(int number);

  /// Question cell reading, right answer (C43).
  ///
  /// In tr, this message translates to:
  /// **'Soru {number}, doğru, işaretin {marked}'**
  String exams_questionCorrectA11y(int number, String marked);

  /// Question count of a test row (C42): "40 soru".
  ///
  /// In tr, this message translates to:
  /// **'{count} soru'**
  String exams_questionCount(int count);

  /// Question cell reading, wrong answer (C43): "Soru 7, yanlış, işaretin C, doğru cevap A".
  ///
  /// In tr, this message translates to:
  /// **'Soru {number}, yanlış, işaretin {marked}, doğru cevap {correctAnswer}'**
  String exams_questionWrongA11y(
    int number,
    String marked,
    String correctAnswer,
  );

  /// Question cell reading, wrong answer when the data has no answer key (C43).
  ///
  /// In tr, this message translates to:
  /// **'Soru {number}, yanlış, işaretin {marked}'**
  String exams_questionWrongNoKeyA11y(int number, String marked);

  /// Exam header score card: label under the rank (C26).
  ///
  /// In tr, this message translates to:
  /// **'Sıra'**
  String get exams_rank;

  /// Screen reader sentence of one score card row (Tur 12 B, 14.4): "Yerleştirme puanı 412,63, sıra 48.215". The rank has no ordinal dot.
  ///
  /// In tr, this message translates to:
  /// **'{label} {value}, sıra {rank}'**
  String exams_scoreRowA11y(String label, String value, String rank);

  /// Score card row with points but no rank: "Ham puan 398,12".
  ///
  /// In tr, this message translates to:
  /// **'{label} {value}'**
  String exams_scoreRowPointsA11y(String label, String value);

  /// Score card row with a rank but no points: "Ham puan sırası 52.904".
  ///
  /// In tr, this message translates to:
  /// **'{label} sırası {rank}'**
  String exams_scoreRowRankA11y(String label, String rank);

  /// Screen reader sentence of a stacked D/Y/B bar (C42): "40 sorudan 23 doğru, 17 yanlış, 0 boş".
  ///
  /// In tr, this message translates to:
  /// **'{total} sorudan {correct} doğru, {wrong} yanlış, {blank} boş'**
  String exams_stackedBarA11y(int total, int correct, int wrong, int blank);

  /// Last-exam card: the primary button (C25).
  ///
  /// In tr, this message translates to:
  /// **'Analizi Gör'**
  String get exams_summaryAnalyze;

  /// Last-exam card with no exam: explanation (C25, screen 3.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Optik formunu okuttuğunda netin, doğru-yanlış dağılımın ve en çok kaçırdığın konu burada görünür.'**
  String get exams_summaryEmptyBody;

  /// Last-exam card with no exam: title (C25, screen 3.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Henüz deneme okutmadın.'**
  String get exams_summaryEmptyTitle;

  /// Last-exam card with no exam: the primary button (C25).
  ///
  /// In tr, this message translates to:
  /// **'İlk Denemeni Okut'**
  String get exams_summaryScan;

  /// Last-exam card: label above the weakest-topic sentence (C25).
  ///
  /// In tr, this message translates to:
  /// **'En çok kaçırdığın konu'**
  String get exams_summaryWeakestTopic;

  /// Screen reader sentence of a test row with its bar (C42).
  ///
  /// In tr, this message translates to:
  /// **'{name}, {net} net, {total} sorudan {correct} doğru, {wrong} yanlış, {blank} boş'**
  String exams_testRowA11y(
    String name,
    String net,
    int total,
    int correct,
    int wrong,
    int blank,
  );

  /// Text button of the code step that goes back to the e-mail step (pano 2.4 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'E-postayı Değiştir'**
  String get forgotPassword_changeEmail;

  /// Sentence under the title of the code step (pano 2.4 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Kodu {email} adresine gönderdik. Gelen kutunda yoksa istenmeyen klasörüne bak.'**
  String forgotPassword_codeBody(String email);

  /// Label of the six boxes (pano 2.4 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama kodu'**
  String get forgotPassword_codeLabel;

  /// Title of the second reset step (pano 2.4 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Kodu gir'**
  String get forgotPassword_codeTitle;

  /// Primary button of the last reset screen; goes back to the sign-in screen (pano 2.4 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get forgotPassword_doneAction;

  /// Sentence of the last reset screen (pano 2.4 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifrenle giriş yapabilirsin.'**
  String get forgotPassword_doneBody;

  /// Title of the last reset screen (pano 2.4 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Şifren güncellendi'**
  String get forgotPassword_doneTitle;

  /// Sentence under the title of the first reset step (pano 2.4 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Hesabındaki e-posta adresini yaz; 6 haneli bir kod gönderelim.'**
  String get forgotPassword_emailBody;

  /// Label of the e-mail field (pano 2.4 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get forgotPassword_emailLabel;

  /// Title of the first reset step (pano 2.4 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Şifreni sıfırla'**
  String get forgotPassword_emailTitle;

  /// Error under the code boxes for a wrong or expired code (pano 2.4 'Hata metinleri').
  ///
  /// In tr, this message translates to:
  /// **'Kod hatalı ya da süresi dolmuş. Yeni kod iste.'**
  String get forgotPassword_errCode;

  /// Error under the e-mail field for an address that does not look like one (pano 2.4 'Hata metinleri', board 1.12).
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresi eksik görünüyor. Örn: ad@alan.com'**
  String get forgotPassword_errEmailFormat;

  /// Error under the repeat field when the two passwords differ (pano 2.4 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Şifreler aynı değil.'**
  String get forgotPassword_errMismatch;

  /// Toast when a reset call could not reach the server (pano 2.4 'Hata metinleri').
  ///
  /// In tr, this message translates to:
  /// **'Gönderilemedi. Bağlantını kontrol edip tekrar dene.'**
  String get forgotPassword_errSendFailed;

  /// Error under the code boxes when the server says too many tries (pano 2.4 'Hata metinleri').
  ///
  /// In tr, this message translates to:
  /// **'Çok fazla deneme yaptın. 10 dakika sonra tekrar dene.'**
  String get forgotPassword_errTooMany;

  /// Label of the first new password field (pano 2.4 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre'**
  String get forgotPassword_newPasswordLabel;

  /// Label of the second new password field (pano 2.4 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre (tekrar)'**
  String get forgotPassword_newPasswordRepeatLabel;

  /// Title of the third reset step (pano 2.4 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifreni belirle'**
  String get forgotPassword_newTitle;

  /// Help line under the first new password field; also its error when the password is too short (pano 2.4 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'En az 8 karakter.'**
  String get forgotPassword_passwordRule;

  /// Resend button once the wait is over (spec §4.A 2.4 fpResend). Not drawn on the board.
  ///
  /// In tr, this message translates to:
  /// **'Kodu Tekrar Gönder'**
  String get forgotPassword_resend;

  /// Closed resend button with the time left, 'Kodu Tekrar Gönder (0:24)' (pano 2.4 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Kodu Tekrar Gönder ({time})'**
  String forgotPassword_resendIn(String time);

  /// Primary button of the first reset step (pano 2.4 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Kod Gönder'**
  String get forgotPassword_sendCode;

  /// Primary button of the third reset step (pano 2.4 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi Güncelle'**
  String get forgotPassword_update;

  /// Name of a result the server sent without one (board 6.2): 'AYT denemesi'.
  ///
  /// In tr, this message translates to:
  /// **'{type} denemesi'**
  String home_examNameFallback(String type);

  /// Section title of the last exam (pano 3.1 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Son denemen'**
  String get home_lastExam;

  /// Section error of "Son denemen" (not drawn in the boards; written like "Dersler yüklenemedi.", pano 3.2).
  ///
  /// In tr, this message translates to:
  /// **'Son deneme yüklenemedi.'**
  String get home_lastExamError;

  /// Name of the literature lesson on its tile (pano 3.1 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Türk Dili ve Edebiyatı'**
  String get home_literatureName;

  /// The weakest-topic sentence (pano 3.1). {topic} arrives with its suffix from TurkishSuffix.locative ('Kurtuluş Savaşı Hazırlık Dönemi'nde'), {wrong} from TurkishSuffix.possessiveAccusative ('9'unu').
  ///
  /// In tr, this message translates to:
  /// **'{topic} {total} sorudan {wrong} kaçırdın.'**
  String home_mostMissedSentence(String topic, String total, String wrong);

  /// The one text button of "Bugün" (pano 3.1 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Programım'**
  String get home_myProgram;

  /// "Bugün" card when the student has no program (pano 3.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Haftalık programın yok. Bir hafta kurduğunda günün konuları burada görünür.'**
  String get home_noProgram;

  /// Text button under the no-program sentence (pano 3.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Haftalık Programını Kur'**
  String get home_setupProgram;

  /// Section title of the subject strip (pano 3.1 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Derslerin'**
  String get home_subjects;

  /// Section error of "Derslerin" (pano 3.2, spec 1.22).
  ///
  /// In tr, this message translates to:
  /// **'Dersler yüklenemedi.'**
  String get home_subjectsError;

  /// Meta of the subject strip (pano 3.1 kare 1); not drawn without missing items (kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Eksiği en çok olandan başlar'**
  String get home_subjectsSub;

  /// Section title of the planned topics of the day (pano 3.1 kare 1, SectionHeader).
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get home_today;

  /// The day line of "Bugün": 'Cumartesi, 10 Ekim' (pano 3.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'{weekday}, {day} {month}'**
  String home_todayDate(String weekday, String day, String month);

  /// Section error of "Bugün" (pano 3.2 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Bugünün programı yüklenemedi.'**
  String get home_todayError;

  /// The meta of "Bugün" with the program of the day: 'Cumartesi, 10 Ekim · Ekim 2. Hafta' (pano 3.1 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'{date} · {program}'**
  String home_todaySub(String date, String program);

  /// Hint of a SelectField (C12).
  ///
  /// In tr, this message translates to:
  /// **'seçenekleri açar'**
  String get kit2_a11ySelectHint;

  /// Screen reader name of the hour wheel (C66).
  ///
  /// In tr, this message translates to:
  /// **'Saat'**
  String get kit2_a11yTimeWheelHour;

  /// Screen reader name of the minute wheel (C66).
  ///
  /// In tr, this message translates to:
  /// **'Dakika'**
  String get kit2_a11yTimeWheelMinute;

  /// Accessible name of the toast close button, shown only while a screen reader is on (C74).
  ///
  /// In tr, this message translates to:
  /// **'Bildirimi kapat'**
  String get kit2_a11yToastClose;

  /// ComingSoonSheet sentence (C73).
  ///
  /// In tr, this message translates to:
  /// **'Bu bölüm henüz hazır değil. Hazır olduğunda burada göreceksin.'**
  String get kit2_comingSoonBody;

  /// ComingSoonSheet title (C73). Kit and gallery only.
  ///
  /// In tr, this message translates to:
  /// **'Yakında'**
  String get kit2_comingSoonTitle;

  /// Offline strip message for 2 s after the connection returns (C75, handoff 11.15).
  ///
  /// In tr, this message translates to:
  /// **'Bağlandın'**
  String get kit2_connectedStrip;

  /// Offline strip message (C75, board 1.22 kare 6).
  ///
  /// In tr, this message translates to:
  /// **'Çevrimdışısın. Son kaydedilen veriler gösteriliyor.'**
  String get kit2_offlineStrip;

  /// Value shown by an empty SelectField (C12).
  ///
  /// In tr, this message translates to:
  /// **'Seç'**
  String get kit2_selectPlaceholder;

  /// State word read after the header of a closed accordion (C50): 'Konu başlığı, 4 madde, daraltılmış'.
  ///
  /// In tr, this message translates to:
  /// **'daraltılmış'**
  String get kit_a11yAccordionCollapsed;

  /// State word read after the header of an open accordion (C50): 'Konu başlığı, 4 madde, genişletilmiş'.
  ///
  /// In tr, this message translates to:
  /// **'genişletilmiş'**
  String get kit_a11yAccordionExpanded;

  /// Hint of a dangerous row that opens a confirmation (C17).
  ///
  /// In tr, this message translates to:
  /// **'onay ister'**
  String get kit_a11yAsksConfirmation;

  /// Screen reader name of an avatar choice (C57); 'Avatar 3, seçili'.
  ///
  /// In tr, this message translates to:
  /// **'Avatar {index}'**
  String kit_a11yAvatarOption(int index);

  /// Screen reader name of a coach avatar (C55).
  ///
  /// In tr, this message translates to:
  /// **'{name}, koç'**
  String kit_a11yCoachAvatar(String name);

  /// Screen reader word before a falling change (C49).
  ///
  /// In tr, this message translates to:
  /// **'düşüş'**
  String get kit_a11yDeltaDown;

  /// Screen reader word for an unchanged value (C49).
  ///
  /// In tr, this message translates to:
  /// **'değişim yok'**
  String get kit_a11yDeltaFlat;

  /// Screen reader word before a rising change (C49).
  ///
  /// In tr, this message translates to:
  /// **'artış'**
  String get kit_a11yDeltaUp;

  /// Tail of the avatar stack reading (C56): 'Elif Şahin, Kerem Aydın ve 2 öğrenci daha'.
  ///
  /// In tr, this message translates to:
  /// **'ve {count} öğrenci daha'**
  String kit_a11yMoreStudents(int count);

  /// Screen reader position of a segment option (C04): '3 seçenekten 2'.
  ///
  /// In tr, this message translates to:
  /// **'{total} seçenekten {index}'**
  String kit_a11yOptionOf(int total, int index);

  /// Screen reader word for a selected segment, tab or avatar.
  ///
  /// In tr, this message translates to:
  /// **'seçili'**
  String get kit_a11ySelected;

  /// Screen reader position of a tab (C05): 'Genel, sekme, 4 sekmeden 1'.
  ///
  /// In tr, this message translates to:
  /// **'sekme, {total} sekmeden {index}'**
  String kit_a11yTabOf(int total, int index);

  /// Count line under the avatar picker (C57): '7 avatar'.
  ///
  /// In tr, this message translates to:
  /// **'{count} avatar'**
  String kit_avatarCount(int count);

  /// Screen reader label of the live-check spinner in a field (C09).
  ///
  /// In tr, this message translates to:
  /// **'Kontrol ediliyor'**
  String get kit_checking;

  /// Accessible name of the search clear button (C10).
  ///
  /// In tr, this message translates to:
  /// **'Aramayı temizle'**
  String get kit_clearSearch;

  /// The word badge on a coach avatar (C55). A word, not an icon.
  ///
  /// In tr, this message translates to:
  /// **'Koç'**
  String get kit_coachBadge;

  /// Screen reader size of the code input (C11): 'Doğrulama kodu, 6 hane'.
  ///
  /// In tr, this message translates to:
  /// **'{count} hane'**
  String kit_codeDigits(int count);

  /// Accessible name of the hide-password button (C02, C09).
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi gizle'**
  String get kit_hidePassword;

  /// AppButton: accessible name while the button is loading (C01).
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor'**
  String get kit_loading;

  /// Screen reader name of the logo mark and lockup (C59).
  ///
  /// In tr, this message translates to:
  /// **'SMAP'**
  String get kit_logoLabel;

  /// Success ring with no questions at all (C46): no ring, this text.
  ///
  /// In tr, this message translates to:
  /// **'Soru yok'**
  String get kit_noQuestions;

  /// Tail of an optional field label (C09). No star on required fields.
  ///
  /// In tr, this message translates to:
  /// **'(isteğe bağlı)'**
  String get kit_optionalSuffix;

  /// Screen reader reading of the onboarding page dots (C60): '3 ekrandan 1.'
  ///
  /// In tr, this message translates to:
  /// **'{count} ekrandan {index}.'**
  String kit_pageDotsA11y(int count, int index);

  /// Screen reader reading of the success ring (C46).
  ///
  /// In tr, this message translates to:
  /// **'Yüzde {percent}'**
  String kit_percentA11y(int percent);

  /// Accessible name of the show-password button (C02, C09).
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi göster'**
  String get kit_showPassword;

  /// Text button of Ders Detayı that opens the lesson's card deck (pano 7.2).
  ///
  /// In tr, this message translates to:
  /// **'Kartlarım'**
  String get lessonDetail_cards;

  /// The same button with the deck's progress (pano 7.2 kare 3); only with real card counts.
  ///
  /// In tr, this message translates to:
  /// **'Kartlarım · {known}/{total}'**
  String lessonDetail_cardsProgress(String known, String total);

  /// Title of the error state of Ders Detayı (pano 7.5 kare 3 wording).
  ///
  /// In tr, this message translates to:
  /// **'Konular yüklenemedi'**
  String get lessonDetail_errorTitle;

  /// Text button of the empty filter card (pano 7.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Süzgeci Kapat'**
  String get lessonDetail_filterEmptyAction;

  /// Sentence of the empty filter card for a named segment (pano 7.5 kare 2): "SOS-2'de eksik konun yok. …".
  ///
  /// In tr, this message translates to:
  /// **'{segment}\'de eksik konun yok. Tüm {segment} konularını görmek için süzgeci kapat.'**
  String lessonDetail_filterEmptyBody(String segment);

  /// Sentence of the empty filter card on the "Tümü" segment.
  ///
  /// In tr, this message translates to:
  /// **'Eksik konun yok. Tüm konuları görmek için süzgeci kapat.'**
  String get lessonDetail_filterEmptyBodyAll;

  /// Title of the empty card when the missing filter hides every topic (pano 7.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Bu süzgeçte gösterilecek konu yok'**
  String get lessonDetail_filterEmptyTitle;

  /// Footnote under the topic card while the missing filter is on (pano 7.2 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Yalnız eksiği olan konular. Numaralar tam listedeki sırayı korur.'**
  String get lessonDetail_filterNote;

  /// Filter chip of Ders Detayı (pano 7.2 kare 1): the lesson's missing items, all tracks.
  ///
  /// In tr, this message translates to:
  /// **'Eksiklerim ({count})'**
  String lessonDetail_missingFilter(String count);

  /// Empty state of a lesson the server lists no topic for (same wording as pano 7.5 "Boş metinler").
  ///
  /// In tr, this message translates to:
  /// **'Bu dersin konuları hazırlanıyor.'**
  String get lessonDetail_noTopics;

  /// Second option of the Edebiyat section segment (pano 7.4).
  ///
  /// In tr, this message translates to:
  /// **'Yazar ve Eserler'**
  String get lessonDetail_sectionAuthors;

  /// First option of the Edebiyat section segment (pano 7.4).
  ///
  /// In tr, this message translates to:
  /// **'Konular'**
  String get lessonDetail_sectionTopics;

  /// First option of the category segment of a lesson without tracks (pano 7.2 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get lessonDetail_segmentAll;

  /// Card progress under a subject row (C20, C44).
  ///
  /// In tr, this message translates to:
  /// **'{known} / {total} kart biliniyor'**
  String lessons_cardsKnown(int known, int total);

  /// Small heading of the example box (C51, pano 7.3).
  ///
  /// In tr, this message translates to:
  /// **'Örnek'**
  String get lessons_exampleLabel;

  /// Name of the literature lesson in the Derslerim list, the detail title and the sheets (pano 7.1 kare 2, 7.4). The server calls it Edebiyat.
  ///
  /// In tr, this message translates to:
  /// **'Türk Dili ve Edebiyatı'**
  String get lessons_literatureName;

  /// Sentence of the error states of Derslerim, Ders Detayı and Konu Detayı (pano 7.5 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Bağlantını kontrol edip tekrar dene.'**
  String get lessons_loadErrorMessage;

  /// Title of the error state of the Derslerim list (pano 1.22 kare 4 wording).
  ///
  /// In tr, this message translates to:
  /// **'Dersler yüklenemedi'**
  String get lessons_loadErrorTitle;

  /// EksikTag and its reading (C08): "31 eksik".
  ///
  /// In tr, this message translates to:
  /// **'{count} eksik'**
  String lessons_missingCount(String count);

  /// EksikTag at item level, no count (C08, card face).
  ///
  /// In tr, this message translates to:
  /// **'Eksik'**
  String get lessons_missingItem;

  /// Neutral tag of a subject with no missing item (C20, screen 7.1).
  ///
  /// In tr, this message translates to:
  /// **'eksik yok'**
  String get lessons_noMissing;

  /// Tag of a subject that opens on the web (C20, C21).
  ///
  /// In tr, this message translates to:
  /// **'Web\'de'**
  String get lessons_onWeb;

  /// Screen reader part of a web-only subject row (C20): "Matematik, web'de açılır".
  ///
  /// In tr, this message translates to:
  /// **'web\'de açılır'**
  String get lessons_opensOnWeb;

  /// Toast when "Öğrendim" could not be sent (pano 1.22 kare 1 error toast).
  ///
  /// In tr, this message translates to:
  /// **'Gönderilemedi. Bağlantını kontrol edip tekrar dene.'**
  String get lessons_sendFailed;

  /// Name of the SOS-2 row of a lesson (pano 7.1 kare 2): "Tarih-2", "Coğrafya-2".
  ///
  /// In tr, this message translates to:
  /// **'{name}-2'**
  String lessons_sos2Name(String name);

  /// Test line of the AYT row of Tarih and Coğrafya (pano 7.1 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Türk Dili ve Edebiyatı–Sosyal Bilimler 1 testi'**
  String get lessons_testSocialSciences1;

  /// Test line of the SOS-2 row of Tarih and Coğrafya (pano 7.1 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Sosyal Bilimler 2 testi'**
  String get lessons_testSocialSciences2;

  /// Screen reader sentence of a subject tile with missing items (C21): "Tarih, 60 eksik".
  ///
  /// In tr, this message translates to:
  /// **'{name}, {count} eksik'**
  String lessons_tileMissingA11y(String name, String count);

  /// Screen reader sentence of a web-only subject tile (C21).
  ///
  /// In tr, this message translates to:
  /// **'{name}, web\'de açılır'**
  String lessons_tileWebA11y(String name);

  /// Screen reader start of a topic row (C22): "9. Fiilde Çatı".
  ///
  /// In tr, this message translates to:
  /// **'{number}. {name}'**
  String lessons_topicRowA11y(int number, String name);

  /// Sentence of the "Web'de" sheet (pano 7.1 kare 3); the host is the site's address, "smaptr.com".
  ///
  /// In tr, this message translates to:
  /// **'Matematik ve Geometri kavram haritan şimdilik {host}\'da.'**
  String lessons_webSheetBody(String host);

  /// Primary button of the "Web'de" sheet: opens the browser (pano 7.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Web\'de Aç'**
  String get lessons_webSheetOpen;

  /// Title of the "Web'de" sheet (pano 7.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Kavram haritan web\'de'**
  String get lessons_webSheetTitle;

  /// Heading of the biography in the author sheet (pano 7.4 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get literature_about;

  /// Screen reader sentence of an author row without missing works (pano 14.5 kare 2): "Şinasi, 3 eser".
  ///
  /// In tr, this message translates to:
  /// **'{name}, {works}'**
  String literature_authorRowA11y(String name, String works);

  /// Screen reader sentence of an author row with missing works (pano 14.5 kare 2): "Namık Kemal, 8 eser, 2 eksik".
  ///
  /// In tr, this message translates to:
  /// **'{name}, {works}, {missing} eksik'**
  String literature_authorRowMissingA11y(
    String name,
    String works,
    String missing,
  );

  /// Second line of the error inside an accordion (pano 14.7 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Bağlantını kontrol edip tekrar dene.'**
  String get literature_authorsErrorBody;

  /// Title of the error inside an accordion whose authors did not load (pano 14.7 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Yazarlar yüklenemedi.'**
  String get literature_authorsErrorTitle;

  /// Section error under the segment when the era list did not load (pano 14.7, 14.3 kare 2 layout).
  ///
  /// In tr, this message translates to:
  /// **'Dönemler yüklenemedi.'**
  String get literature_eraListError;

  /// EksikTag of an era row and of the era detail title (pano 14.5 kare 1 and 2): "2 eksik eser". The count is formatted with thousands dots.
  ///
  /// In tr, this message translates to:
  /// **'{count} eksik eser'**
  String literature_eraMissing(String count);

  /// Screen reader sentence of an era row with missing works (pano 14.5 kare 1): "1, Tanzimat Dönemi, 2 eksik eser".
  ///
  /// In tr, this message translates to:
  /// **'{number}, {name}, {count} eksik eser'**
  String literature_eraRowA11y(int number, String name, String count);

  /// Check and word of a work the student knows (pano 14.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Biliyorsun'**
  String get literature_known;

  /// Text button of a missing work in the author sheet (pano 14.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Öğrendim'**
  String get literature_learned;

  /// Toast after "Öğrendim" with "Geri Al" (pano 14.6 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'{work} bildiklerine eklendi.'**
  String literature_learnedToast(String work);

  /// Empty text inside an accordion without authors (pano 14.7).
  ///
  /// In tr, this message translates to:
  /// **'Bu bölümde yazar yok.'**
  String get literature_noAuthors;

  /// Empty text of the author sheet when the author has no works (pano 14.6 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Bu yazarın eser listesi henüz yok.'**
  String get literature_noWorks;

  /// Note under the first missing work while the device is offline (pano 14.7 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Öğrendim\'i kaydetmek için bağlantı gerekiyor.'**
  String get literature_offlineNote;

  /// Heading of the works whose type the app does not know.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get literature_otherType;

  /// Toast when the held "Öğrendim" request failed and the work is missing again (pano 14.7, "kaydetme hatası").
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilemedi. Bağlantını kontrol edip tekrar dene.'**
  String get literature_saveFailed;

  /// Accessible name of the author sheet.
  ///
  /// In tr, this message translates to:
  /// **'{name}, {era}'**
  String literature_sheetA11y(String name, String era);

  /// Heading of a work type in the author sheet (pano 14.6 kare 1): "Roman · 2".
  ///
  /// In tr, this message translates to:
  /// **'{type} · {count}'**
  String literature_typeHeading(String type, String count);

  /// Work count of an author row and of the sheet heading when nothing is missing (pano 14.5 kare 2): "8 eser".
  ///
  /// In tr, this message translates to:
  /// **'{count} eser'**
  String literature_workCount(String count);

  /// Screen reader reading of a known work (pano 14.6): "Cezmi, roman, biliyorsun".
  ///
  /// In tr, this message translates to:
  /// **'{title}, {type}, biliyorsun'**
  String literature_workKnownA11y(String title, String type);

  /// Screen reader reading of a known work of an unknown type.
  ///
  /// In tr, this message translates to:
  /// **'{title}, biliyorsun'**
  String literature_workKnownNoTypeA11y(String title);

  /// Screen reader reading of a missing work whose type is known (pano 14.6): "İntibah, roman, eksik. Öğrendim olarak işaretle."
  ///
  /// In tr, this message translates to:
  /// **'{title}, {type}, eksik. Öğrendim olarak işaretle.'**
  String literature_workMissingA11y(String title, String type);

  /// Screen reader reading of a missing work of an unknown type.
  ///
  /// In tr, this message translates to:
  /// **'{title}, eksik. Öğrendim olarak işaretle.'**
  String literature_workMissingNoTypeA11y(String title);

  /// Screen reader reading of a work with no status (pano 14.6 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'{title}, {type}'**
  String literature_workUnknownA11y(String title, String type);

  /// Heading of the works in the author sheet (pano 7.4 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Eserleri'**
  String get literature_works;

  /// Counter at the right of "Eserleri" in the author sheet (pano 14.6 kare 1): "8 eser · 2 eksik".
  ///
  /// In tr, this message translates to:
  /// **'{count} eser · {missing} eksik'**
  String literature_worksCounter(String count, String missing);

  /// Apple sign-in button, shown only while social sign-in is open (pano 2.3 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Apple ile Devam Et'**
  String get login_apple;

  /// Error box for wrong credentials; it never says which field is wrong (pano 2.3 kare 3). Used while the reset flow is open.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı ya da şifre hatalı. Tekrar dene ya da şifreni sıfırla.'**
  String get login_errorInvalid;

  /// Same error box without the pointer to the reset link, used while the reset flow is closed and the link is not drawn. Not on the board; derived from pano 2.3 kare 3.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı ya da şifre hatalı. Tekrar dene.'**
  String get login_errorInvalidNoReset;

  /// Error box when the sign-in got no answer in time or the connection broke (spec §4.A 2.3, errNetwork).
  ///
  /// In tr, this message translates to:
  /// **'Bağlanamadık. Bağlantını kontrol edip tekrar dene.'**
  String get login_errorNetwork;

  /// Text button under the password field; shown only while the reset flow is open (pano 2.3 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Şifremi Unuttum'**
  String get login_forgot;

  /// Google sign-in button, shown only while social sign-in is open (pano 2.3 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Google ile Devam Et'**
  String get login_google;

  /// Line above the sign-up link at the bottom (pano 2.3 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu?'**
  String get login_noAccount;

  /// Divider text under the Apple and Google buttons (pano 2.3 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'ya da kullanıcı adınla'**
  String get login_orUsername;

  /// Label of the password field (pano 2.3).
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get login_passwordLabel;

  /// Text button at the bottom that opens the sign-up screen (pano 2.3 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get login_register;

  /// Primary button of the sign-in screen (pano 2.3 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get login_submit;

  /// Label of the primary button while the sign-in runs (pano 2.3 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Giriş yapılıyor'**
  String get login_submitting;

  /// Sign-in screen title, the large title under the logo (pano 2.3).
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap'**
  String get login_title;

  /// Label of the user name field (pano 2.3).
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı'**
  String get login_usernameLabel;

  /// Screen reader position of a bottom bar tab (C84): 'Analizlerim, sekme, 5'te 2'. The bar has five slots (the camera button holds the third), so the total is always 5 and the suffix is fixed.
  ///
  /// In tr, this message translates to:
  /// **'sekme, 5\'te {position}'**
  String nav_a11yTabPosition(int position);

  /// Accessible name and tooltip of the detail bar back button (C82; pano 1.18).
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get nav_back;

  /// Screen reader name of the bottom bar (C84; pano 1.19).
  ///
  /// In tr, this message translates to:
  /// **'Ana gezinme'**
  String get nav_barLabel;

  /// Accessible name of the camera button (C84).
  ///
  /// In tr, this message translates to:
  /// **'Okut: deneme formunu kamerayla okut'**
  String get nav_cameraA11y;

  /// Visible label under the camera button (C84). Hidden from screen readers; the button has its own name.
  ///
  /// In tr, this message translates to:
  /// **'Okut'**
  String get nav_cameraLabel;

  /// Single screen reader reading of the context strip (C83): 'Alparslan Kuloğlu'nun verileri, 12. sınıf, Eşit Ağırlık'.
  ///
  /// In tr, this message translates to:
  /// **'{title}, {detail}'**
  String nav_contextStripA11y(String title, String detail);

  /// Context strip title (C83; pano 1.18 kare 6, 10.4). The name arrives with its genitive suffix from TurkishSuffix.genitive: 'Alparslan Kuloğlu'nun verileri'.
  ///
  /// In tr, this message translates to:
  /// **'{name} verileri'**
  String nav_contextStripTitle(String name);

  /// Sub line of the coach home band without students (C81; pano 10.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Henüz öğrencin yok'**
  String get nav_homeCoachNoStudents;

  /// Sub line of the coach home band when no meeting count is known or it is zero (C81). The design gives no copy for zero meetings, so the meeting part is left out.
  ///
  /// In tr, this message translates to:
  /// **'{students} öğrenci'**
  String nav_homeCoachStudents(String students);

  /// Sub line of the coach home band (C81; pano 10.1).
  ///
  /// In tr, this message translates to:
  /// **'{students} öğrenci · önümüzdeki 7 günde {meetings} görüşme'**
  String nav_homeCoachSummary(String students, String meetings);

  /// Single screen reader reading of the counter (C81): 'YKS'ye 252 gün kaldı. Sınav 19 Haziran 2027 Cumartesi.'
  ///
  /// In tr, this message translates to:
  /// **'YKS\'ye {days} gün kaldı. Sınav {date}.'**
  String nav_homeCounterA11y(String days, String date);

  /// One-line counter of the shrunken home band (C81).
  ///
  /// In tr, this message translates to:
  /// **'YKS\'ye {days} gün'**
  String nav_homeCounterCompact(String days);

  /// Exam line under the unit, the date from TrFormat.uzunTarihGun: 'YKS · 19 Haziran 2027 Cumartesi' (C81).
  ///
  /// In tr, this message translates to:
  /// **'YKS · {date}'**
  String nav_homeCounterExam(String date);

  /// Unit next to the big exam counter in the student home band (C81).
  ///
  /// In tr, this message translates to:
  /// **'gün kaldı'**
  String get nav_homeCounterUnit;

  /// Greeting in the home band (C81; pano 3.1, 10.1).
  ///
  /// In tr, this message translates to:
  /// **'Merhaba, {name}'**
  String nav_homeGreeting(String name);

  /// The band greeting when the user has no name to show (no comma).
  ///
  /// In tr, this message translates to:
  /// **'Merhaba'**
  String get nav_homeGreetingNoName;

  /// Bottom bar tab, student and coach (C84).
  ///
  /// In tr, this message translates to:
  /// **'Hesap'**
  String get nav_tabAccount;

  /// Bottom bar tab, student only (C84).
  ///
  /// In tr, this message translates to:
  /// **'Analizlerim'**
  String get nav_tabAnalytics;

  /// Bottom bar tab, student and coach (C84).
  ///
  /// In tr, this message translates to:
  /// **'Anasayfa'**
  String get nav_tabHome;

  /// Bottom bar tab, student only (C84).
  ///
  /// In tr, this message translates to:
  /// **'Derslerim'**
  String get nav_tabLessons;

  /// Bottom bar tab, coach only (C84). The longest label; it must fit the 82,5 pt slot at text scale 1,3 (FittedBox).
  ///
  /// In tr, this message translates to:
  /// **'Görüşmelerim'**
  String get nav_tabMeetings;

  /// Bottom bar tab, coach only (C84).
  ///
  /// In tr, this message translates to:
  /// **'Öğrencilerim'**
  String get nav_tabStudents;

  /// Primary button of the notification permission sheet (pano 5.2); opens the system dialog.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimlere İzin Ver'**
  String get notificationPrimer_allow;

  /// Body of the notification permission sheet (pano 5.2).
  ///
  /// In tr, this message translates to:
  /// **'Sistemde olmayan bir denemeyi okuttuğunda analizini hazırlayınca bildirim gönderelim. Hesap › Bildirimler\'den istediğin zaman kapatabilirsin.'**
  String get notificationPrimer_body;

  /// Quiet button of the notification permission sheet (pano 5.2); never asks again.
  ///
  /// In tr, this message translates to:
  /// **'Sonra'**
  String get notificationPrimer_later;

  /// Title of the notification permission sheet (pano 5.2).
  ///
  /// In tr, this message translates to:
  /// **'Sonucun hazır olunca haber verelim mi?'**
  String get notificationPrimer_title;

  /// Heading of the group of category switches (pano 9.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Kategoriler'**
  String get notifications_categoriesHeading;

  /// Category line with the coach's name (pano 9.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'{name} yeni bir şey atadığında'**
  String notifications_coachAssignedBody(String name);

  /// Category line while the coach's name is not known.
  ///
  /// In tr, this message translates to:
  /// **'Koçun yeni bir şey atadığında'**
  String get notifications_coachAssignedBodyAnonymous;

  /// Category title (pano 9.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Koçun deneme ya da ödev atadı'**
  String get notifications_coachAssignedTitle;

  /// Category line (pano 9.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Okuttuğun denemenin analizi bitince'**
  String get notifications_examReadyBody;

  /// Category title (pano 9.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Deneme sonucun hazır'**
  String get notifications_examReadyTitle;

  /// Category line (pano 9.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Koçun bir görüşme planladığında'**
  String get notifications_meetingPlannedBody;

  /// Category title (pano 9.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Görüşme planlandı'**
  String get notifications_meetingPlannedTitle;

  /// Text button of the warning box; opens the system settings (pano 9.6 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Ayarları Aç'**
  String get notifications_openSettings;

  /// Warning box when the system permission is off (pano 9.6 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Bildirim izni kapalı. Telefonunun ayarlarından SMAP\'e izin verirsen bu tercihler geçerli olur.'**
  String get notifications_permissionOff;

  /// Info box while notifications are not sent yet (pano 9.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler planlı: tercihlerin şimdiden kaydedilir, bildirimler açıldığında bunlara göre gelir.'**
  String get notifications_plannedNotice;

  /// Line of the quiet hours switch row (pano 9.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Bu saatlerde bildirim gelmez'**
  String get notifications_quietBody;

  /// Row that sets the end of the quiet hours (pano 9.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Bitiş'**
  String get notifications_quietEnd;

  /// Title of the time wheel sheet for the end (assumed; the board draws only the start, spec 9.6 'belirtilmemiş').
  ///
  /// In tr, this message translates to:
  /// **'Sessiz saat bitişi'**
  String get notifications_quietEndTitle;

  /// Heading of the quiet hours group (pano 9.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Sessiz saatler'**
  String get notifications_quietHeading;

  /// Row that sets the start of the quiet hours (pano 9.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç'**
  String get notifications_quietStart;

  /// Title of the time wheel sheet for the start (pano 9.6 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Sessiz saat başlangıcı'**
  String get notifications_quietStartTitle;

  /// Title of the quiet hours switch row (pano 9.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Sessiz saatler'**
  String get notifications_quietTitle;

  /// Note under the quiet hours group; there is no Save button (pano 9.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Değişiklikler anında kaydedilir.'**
  String get notifications_savedNote;

  /// Category line (pano 9.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Programındaki çalışmanın saatinde'**
  String get notifications_studyReminderBody;

  /// Category title (pano 9.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Çalışma hatırlatıcısı'**
  String get notifications_studyReminderTitle;

  /// Title of the notifications screen (pano 9.6).
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications_title;

  /// Camera primer primary button; opens the system dialog (pano 2.2 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Kameraya İzin Ver'**
  String get onboarding_cameraAllow;

  /// Camera primer sentence (pano 2.2 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'SMAP kamerayı yalnız optik formunu çekerken kullanır. Bir sonraki adımda telefonun izin isteyecek.'**
  String get onboarding_cameraBody;

  /// Name of the camera button drawn inside the phone mock-up (decoration).
  ///
  /// In tr, this message translates to:
  /// **'Kamera düğmesi'**
  String get onboarding_cameraButtonA11y;

  /// Camera primer sentence when the permission was refused (pano 4.1 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Formunu okutabilmek için Ayarlar\'da SMAP\'e kamera izni ver. Sonra buraya dön; kaldığın yerden devam edersin.'**
  String get onboarding_cameraDeniedBody;

  /// Camera primer title when the permission was refused (pano 4.1 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Kamera izni kapalı'**
  String get onboarding_cameraDeniedTitle;

  /// Camera primer text button; moves on without the permission (pano 2.2 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Sonra'**
  String get onboarding_cameraLater;

  /// Camera primer title (pano 2.2 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Formunu okutmak için kamera gerekli'**
  String get onboarding_cameraTitle;

  /// Screen reader name of a numbered grade chip, e.g. "12. sınıf" (pano 2.2 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'{grade}. sınıf'**
  String onboarding_gradeA11y(String grade);

  /// Label of the "graduate" grade chip (pano 2.2 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Mezun'**
  String get onboarding_gradeGraduate;

  /// Name of the radio group of the grade chips (pano 2.2 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Sınıf'**
  String get onboarding_gradeGroupA11y;

  /// Info line shown instead of the track chips for grades 9 and 10 (pano 2.2 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'9. ve 10. sınıfta alan seçilmez; 11. sınıfa geçince Hesap\'tan eklersin.'**
  String get onboarding_gradeNoFieldInfo;

  /// Grade screen title (pano 2.2 kare 2 and 3).
  ///
  /// In tr, this message translates to:
  /// **'Kaçıncı sınıftasın?'**
  String get onboarding_gradeTitle;

  /// Intro page 1 sentence (pano 2.1 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Deneme bitince formunun fotoğrafını çek; cevapların sayılır, netin hesaplanır.'**
  String get onboarding_intro1Body;

  /// Intro page 1 title (pano 2.1 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Optik formunu kamerayla okut'**
  String get onboarding_intro1Title;

  /// Intro page 2 sentence (pano 2.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Her denemenin neti, doğru-yanlış dağılımı ve önceki denemene göre farkı tek ekranda.'**
  String get onboarding_intro2Body;

  /// Intro page 2 title (pano 2.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Netini ve gelişimini gör'**
  String get onboarding_intro2Title;

  /// Intro page 3 sentence (pano 2.1 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Kaçırdığın konular eksik listene girer; konu anlatımı ve bilgi kartlarıyla tamamlarsın.'**
  String get onboarding_intro3Body;

  /// Intro page 3 title (pano 2.1 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Eksiklerini konu konu kapat'**
  String get onboarding_intro3Title;

  /// Camera primer primary button when the permission was refused; opens the app's system settings (pano 4.1 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Ayarları Aç'**
  String get onboarding_openSettings;

  /// Role option title (pano 2.2 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Öğrenci Koçuyum'**
  String get onboarding_roleCoach;

  /// Role option sentence of the coach (pano 2.2 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Öğrencilerinin gelişimini izle, görüşmelerini planla.'**
  String get onboarding_roleCoachDesc;

  /// Name of the radio group of the two role options (pano 2.2 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Rol'**
  String get onboarding_roleGroupA11y;

  /// Role option title (pano 2.2 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Öğrenciyim'**
  String get onboarding_roleStudent;

  /// Role option sentence of the student (pano 2.2 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Denemelerini okut, eksiklerini kapat.'**
  String get onboarding_roleStudentDesc;

  /// Role screen sentence under the title (pano 2.2 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Ekranların buna göre hazırlanır.'**
  String get onboarding_roleSubtitle;

  /// Role screen title (pano 2.2 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'SMAP\'i nasıl kullanacaksın?'**
  String get onboarding_roleTitle;

  /// Button of the example info card on intro page 3 (pano 2.1 kare 4); decoration.
  ///
  /// In tr, this message translates to:
  /// **'Öğrendim'**
  String get onboarding_sampleCardAction;

  /// Body of the example info card on intro page 3 (pano 2.1 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Haçlılarla Osmanlı Devleti\'nin imzaladığı ilk antlaşma.'**
  String get onboarding_sampleCardBody;

  /// Small heading of the example info card on intro page 3 (pano 2.1 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Tarih · bilgi kartı'**
  String get onboarding_sampleCardKicker;

  /// Title of the example info card on intro page 3 (pano 2.1 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Edirne-Segedin Antlaşması (1444)'**
  String get onboarding_sampleCardTitle;

  /// Screen reader name of the example net chart (pano 2.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'AYT net grafiği: 8 Mayıs 48,5 netten 5 Ekim 67,5 nete'**
  String get onboarding_sampleChartA11y;

  /// Example exam title above the net on intro page 2 (pano 2.1 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'AYT · Türkiye Geneli Deneme 6'**
  String get onboarding_sampleExamTitle;

  /// Subject name of the example topic rows on intro page 3 (pano 2.1 kare 4); decoration.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get onboarding_sampleSubjectName;

  /// First example topic of intro page 3 (pano 2.1 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Fiilde Çatı'**
  String get onboarding_sampleTopic1;

  /// Second example topic of intro page 3 (pano 2.1 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Noktalama İşaretleri'**
  String get onboarding_sampleTopic2;

  /// Third example topic of intro page 3 (pano 2.1 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Cümlenin Öğeleri'**
  String get onboarding_sampleTopic3;

  /// Screen reader description of the phone mock-up of intro page 1 (pano 2.1 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Optik form fotoğrafı: form bulundu, köşeler turuncu tutamaçlarla işaretli, altta kamera düğmesi'**
  String get onboarding_scanVisualA11y;

  /// Text button at the top right of the first two intro pages; goes to the role question (pano 2.1 kare 2 and 3). The board says "Geç".
  ///
  /// In tr, this message translates to:
  /// **'Geç'**
  String get onboarding_skip;

  /// Primary button of the last intro page; goes to the role question (pano 2.1 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Başla'**
  String get onboarding_start;

  /// Study track chip (pano 2.2 kare 2); not selectable while the backend has no code for it.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get onboarding_trackDil;

  /// Study track chip (pano 2.2 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Eşit Ağırlık'**
  String get onboarding_trackEsitAgirlik;

  /// Name of the radio group of the track chips (pano 2.2 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Alan'**
  String get onboarding_trackGroupA11y;

  /// Error under the track chips when Devam Et is pressed for 11, 12 or Mezun without a track (spec 4.A 2.2-2 [Karar]).
  ///
  /// In tr, this message translates to:
  /// **'Alanını seç.'**
  String get onboarding_trackRequired;

  /// Study track chip (pano 2.2 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Sayısal'**
  String get onboarding_trackSayisal;

  /// Study track chip (pano 2.2 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Sözel'**
  String get onboarding_trackSozel;

  /// Heading of the study track choice (pano 2.2 kare 2 and 3).
  ///
  /// In tr, this message translates to:
  /// **'Alanın'**
  String get onboarding_trackTitle;

  /// Welcome screen sentence (pano 2.2 kare 5).
  ///
  /// In tr, this message translates to:
  /// **'Hesabın varsa giriş yap; yoksa birkaç adımda kaydol. Seçtiklerin kayıt formuna gelir.'**
  String get onboarding_welcomeBody;

  /// Welcome screen secondary button; opens the sign-in screen (pano 2.2 kare 5).
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get onboarding_welcomeLogin;

  /// Welcome screen primary button; opens the sign-up form with the picks (pano 2.2 kare 5).
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get onboarding_welcomeRegister;

  /// Welcome screen title (pano 2.2 kare 5).
  ///
  /// In tr, this message translates to:
  /// **'SMAP\'e hoş geldin'**
  String get onboarding_welcomeTitle;

  /// Label of the first field (pano 9.3 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Mevcut şifre'**
  String get password_currentLabel;

  /// Error under the repeat field when the two new passwords differ (pano 9.3 'Kurallar ve hata metinleri').
  ///
  /// In tr, this message translates to:
  /// **'Şifreler aynı değil.'**
  String get password_errMismatch;

  /// Error under the new password when it equals the current one (pano 9.3 'Kurallar ve hata metinleri').
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre eskisiyle aynı olamaz.'**
  String get password_errSame;

  /// Error under the current password when the server refuses it (pano 9.3 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Mevcut şifren doğru değil.'**
  String get password_errWrongCurrent;

  /// Label of the second field (pano 9.3 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre'**
  String get password_newLabel;

  /// Rule line under the new password; turns red when it is too short (pano 9.3 kare 1, spec 1.12).
  ///
  /// In tr, this message translates to:
  /// **'En az 8 karakter.'**
  String get password_newRule;

  /// Label of the third field (pano 9.3 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre (tekrar)'**
  String get password_repeatLabel;

  /// The single primary button of the password screen (pano 9.3 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi Güncelle'**
  String get password_submit;

  /// Title of the password screen (pano 9.3 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password_title;

  /// Toast on Hesap after the password was changed (pano 9.3 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Şifren güncellendi.'**
  String get password_updated;

  /// Day chip reading without the state words (C62): "Cumartesi 10 Ekim".
  ///
  /// In tr, this message translates to:
  /// **'{weekday} {day} {month}'**
  String pickers_a11yDayChip(String weekday, String day, String month);

  /// Day chip reading: the day is selected (C62): "Cumartesi 10 Ekim, bugün, seçili".
  ///
  /// In tr, this message translates to:
  /// **'seçili'**
  String get pickers_a11ySelected;

  /// Day chip and calendar cell reading: the day is today (C62, C65).
  ///
  /// In tr, this message translates to:
  /// **'bugün'**
  String get pickers_a11yToday;

  /// Calendar month title (C65): "Ekim 2026".
  ///
  /// In tr, this message translates to:
  /// **'{month} {year}'**
  String pickers_monthTitle(String month, String year);

  /// Calendar next month button, accessible name (C65, pano 3.5 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Sonraki ay'**
  String get pickers_nextMonth;

  /// Calendar previous month button, accessible name (C65, pano 3.5 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Önceki ay'**
  String get pickers_prevMonth;

  /// Calendar legend of the orange ring (C65, pano 3.5 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get pickers_today;

  /// Label above the seven avatars (pano 2.5 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Avatarın'**
  String get register_avatarLabel;

  /// Screen reader name of the avatar group.
  ///
  /// In tr, this message translates to:
  /// **'Avatar seçimi'**
  String get register_avatarPickerA11y;

  /// Info box of a coach sign-up, in place of the grade and track fields (pano 2.5 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Kaydın tamamlanınca koçluk kodun oluşur. Öğrencilerin bu kodla sana bağlanır; kodun Hesap › Koçluk\'ta durur.'**
  String get register_coachCodeInfo;

  /// Link text of the KVKK notice; fallback title of its reading sheet (pano 2.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'KVKK Aydınlatma Metni'**
  String get register_consentKvkk;

  /// Error line under the consent row when Kayıt Ol is pressed unchecked (pano 2.6 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Kaydolmak için metinleri onaylaman gerekiyor.'**
  String get register_consentRequired;

  /// Link text of the terms of use; fallback title of its reading sheet (pano 2.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Koşulları'**
  String get register_consentTerms;

  /// The one consent sentence; the two placeholders become links that open the texts (pano 2.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'{terms}\'nı ve {kvkk}\'ni okudum, kabul ediyorum.'**
  String register_consentText(String terms, String kvkk);

  /// E-mail field label (pano 2.5 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get register_fieldEmail;

  /// Full name field label (pano 2.5 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad'**
  String get register_fieldFullName;

  /// Grade select field label and its sheet title (pano 2.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Sınıf'**
  String get register_fieldGrade;

  /// Password field label (pano 2.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get register_fieldPassword;

  /// Repeat password field label (pano 2.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Şifre (tekrar)'**
  String get register_fieldPasswordRepeat;

  /// Study track select field label and its sheet title (pano 2.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Alan'**
  String get register_fieldTrack;

  /// User name field label (pano 2.5 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı'**
  String get register_fieldUsername;

  /// The graduate option of the grade select.
  ///
  /// In tr, this message translates to:
  /// **'Mezun'**
  String get register_gradeGraduate;

  /// A school year as the select shows it: "12. Sınıf" (pano 2.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'{grade}. Sınıf'**
  String register_gradeValue(int grade);

  /// Sentence before the sign-in link under the button (pano 2.5).
  ///
  /// In tr, this message translates to:
  /// **'Hesabın var mı?'**
  String get register_hasAccount;

  /// Field error: e-mail empty or malformed (pano 2.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresi eksik görünüyor. Örn: ad@alan.com'**
  String get register_issueEmailInvalid;

  /// Field error: full name empty. Not drawn in the boards.
  ///
  /// In tr, this message translates to:
  /// **'Adını ve soyadını yaz.'**
  String get register_issueFullNameMissing;

  /// Field error: no grade chosen. Not drawn in the boards.
  ///
  /// In tr, this message translates to:
  /// **'Sınıfını seç.'**
  String get register_issueGradeMissing;

  /// Field error under the repeat password (pano 2.6 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Şifreler aynı değil.'**
  String get register_issuePasswordMismatch;

  /// Field error: password shorter than 8. Not drawn in the boards.
  ///
  /// In tr, this message translates to:
  /// **'Şifren en az 8 karakter olmalı.'**
  String get register_issuePasswordTooShort;

  /// Field error: no track chosen for grade 11 and up. Not drawn in the boards.
  ///
  /// In tr, this message translates to:
  /// **'Alanını seç.'**
  String get register_issueTrackMissing;

  /// Field error: user name empty. Not drawn in the boards.
  ///
  /// In tr, this message translates to:
  /// **'Bir kullanıcı adı yaz.'**
  String get register_issueUsernameMissing;

  /// Sheet body when a legal text arrived without content (not expected: such a text is not offered).
  ///
  /// In tr, this message translates to:
  /// **'Bu metin şu an gösterilemiyor.'**
  String get register_legalEmpty;

  /// Error box in place of the consent row when the legal texts did not load (pano 2.6 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Sözleşme metinleri yüklenemedi. Kaydolmak için metinleri görebilmen gerekiyor.'**
  String get register_legalLoadFailed;

  /// Screen reader name of the consent row skeleton while the legal texts load.
  ///
  /// In tr, this message translates to:
  /// **'Sözleşme metinleri yükleniyor'**
  String get register_legalLoading;

  /// Reason under the disabled Kayıt Ol button while the legal texts are missing (pano 2.6 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Metinler yüklenince kayıt açılır.'**
  String get register_legalRegisterLocked;

  /// Version line at the top of a legal text sheet.
  ///
  /// In tr, this message translates to:
  /// **'Sürüm {version}'**
  String register_legalVersion(String version);

  /// Text button under Kayıt Ol; goes to the sign-in screen (pano 2.5).
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get register_loginLink;

  /// Help line under the password field (pano 2.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'En az 8 karakter.'**
  String get register_passwordHint;

  /// Role segment, second option (pano 2.5).
  ///
  /// In tr, this message translates to:
  /// **'Öğrenci Koçu'**
  String get register_roleCoach;

  /// Role segment, first option (pano 2.5).
  ///
  /// In tr, this message translates to:
  /// **'Öğrenci'**
  String get register_roleStudent;

  /// Notice above Kayıt Ol when the account was created but the automatic sign-in failed. Not drawn in the boards.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın oluşturuldu ama giriş yapılamadı. Kullanıcı adın ve şifrenle giriş yapabilirsin.'**
  String get register_signInFailed;

  /// Inline button of the signInFailed notice; goes to the sign-in screen.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get register_signInFailedAction;

  /// Primary button of the sign-up screen (pano 2.5).
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get register_submit;

  /// Notice above Kayıt Ol when the register call failed for a reason without a better sentence (spec 4.A errRegisterFailed).
  ///
  /// In tr, this message translates to:
  /// **'Kaydın tamamlanamadı. Bağlantını kontrol edip tekrar dene.'**
  String get register_submitFailed;

  /// Sign-up screen title, large and in the bar (pano 2.5).
  ///
  /// In tr, this message translates to:
  /// **'Kayıt ol'**
  String get register_title;

  /// Study track option. The design offers it; it is not selectable until the backend names a code.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get register_trackDil;

  /// Study track option (pano 2.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Eşit Ağırlık'**
  String get register_trackEsitAgirlik;

  /// Value of the disabled track field for grade 9 and 10 (pano 2.6 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Seçilmez'**
  String get register_trackNotSelectable;

  /// Help line under the disabled track field (pano 2.6 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'9. ve 10. sınıfta alan seçilmez.'**
  String get register_trackNotSelectableReason;

  /// Study track option.
  ///
  /// In tr, this message translates to:
  /// **'Sayısal'**
  String get register_trackSayisal;

  /// Study track option.
  ///
  /// In tr, this message translates to:
  /// **'Sözel'**
  String get register_trackSozel;

  /// Live check passed: the user name is free (pano 2.5 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Bu kullanıcı adı boşta.'**
  String get register_usernameFree;

  /// Help line under the user name while the device is offline (spec 4.A 2.5-2.6 Davranış).
  ///
  /// In tr, this message translates to:
  /// **'Bağlanınca kontrol edilecek.'**
  String get register_usernameOffline;

  /// Label before the free-name chip under a taken user name (pano 2.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Boşta olan:'**
  String get register_usernameSuggest;

  /// Screen reader reading of the free-name chip.
  ///
  /// In tr, this message translates to:
  /// **'Boşta olan kullanıcı adı: {name}. Yazmak için dokun.'**
  String register_usernameSuggestA11y(String name);

  /// Live check or register call: the user name is in use (pano 2.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Bu kullanıcı adı alınmış.'**
  String get register_usernameTaken;

  /// Cards row of the result moment (pano 5.1 kare 1); {count} is formatted with TrFormat.
  ///
  /// In tr, this message translates to:
  /// **'Bu denemeden {count} bilgi kartı eklendi'**
  String resultMoment_cards(String count);

  /// The primary button of the result moment (pano 5.1); opens Deneme Detay.
  ///
  /// In tr, this message translates to:
  /// **'Detaylı Analiz'**
  String get resultMoment_detail;

  /// Message of the screen error of the result moment (the pano 5.8 kare 3 sentence).
  ///
  /// In tr, this message translates to:
  /// **'Bağlantını kontrol edip tekrar dene.'**
  String get resultMoment_errorMessage;

  /// Title of the screen error of the result moment (not on the board; the pano 5.8 kare 3 pattern).
  ///
  /// In tr, this message translates to:
  /// **'Sonuç yüklenemedi'**
  String get resultMoment_errorTitle;

  /// Screen reader name of the score type segment of the result moment (pano 5.1 'aria: Puan türü').
  ///
  /// In tr, this message translates to:
  /// **'Puan türü'**
  String get resultMoment_fieldA11y;

  /// Net of the chosen AYT score type under the score boxes (pano 5.1 kare 1: 'Eşit Ağırlık neti 40').
  ///
  /// In tr, this message translates to:
  /// **'{field} neti {net}'**
  String resultMoment_fieldNet(String field, String net);

  /// The two tests a score type is made of (pano 5.1 kare 1: 'Türk Dili ve Edebiyatı–Sosyal Bilimler 1 ve Matematik').
  ///
  /// In tr, this message translates to:
  /// **'{first} ve {second}'**
  String resultMoment_fieldTests(String first, String second);

  /// Quiet button of the result moment (pano 5.1).
  ///
  /// In tr, this message translates to:
  /// **'Anasayfa'**
  String get resultMoment_home;

  /// Primary button of the fix sheet (pano 4.7 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Düzeltmeyi Ekle'**
  String get scan_addCorrection;

  /// Inline alert when the device is offline (pano 4.8 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı yok. Bağlantı gelince tekrar dene.'**
  String get scan_answersOffline;

  /// Summary line (pano 4.7): '160 cevap okundu'.
  ///
  /// In tr, this message translates to:
  /// **'{n} cevap okundu'**
  String scan_answersRead(String n);

  /// Inline alert after the answers could not be sent (pano 4.8 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Cevaplar gönderilemedi. Düzeltmelerin duruyor; tekrar dene.'**
  String get scan_answersSendFailed;

  /// Name of a blank answer: the chip and the read value (pano 4.7 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Boş'**
  String get scan_blank;

  /// Blank count in the summary and in the column segment (pano 4.7): '2 boş'.
  ///
  /// In tr, this message translates to:
  /// **'{n} boş'**
  String scan_blankCount(String n);

  /// Body of the camera failure screen (pano 4.10 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Başka bir uygulama kamerayı kullanıyor olabilir. Onu kapatıp tekrar dene.'**
  String get scan_cameraFailBody;

  /// Title of the camera failure screen (pano 4.10 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Kamera açılamadı'**
  String get scan_cameraFailTitle;

  /// Screen-reader name of the spinner shown while the camera starts (not drawn in the boards).
  ///
  /// In tr, this message translates to:
  /// **'Kamera açılıyor'**
  String get scan_cameraLoadingA11y;

  /// Caption over the answer grid (pano 4.7).
  ///
  /// In tr, this message translates to:
  /// **'{n}. kolon · {q} soru · düzeltmek için soruya dokun'**
  String scan_columnCaption(String n, String q);

  /// Column name by its number (pano 4.7): '3. kolon'.
  ///
  /// In tr, this message translates to:
  /// **'{n}. kolon'**
  String scan_columnN(String n);

  /// Primary button of the answer check (pano 4.7).
  ///
  /// In tr, this message translates to:
  /// **'Cevapları Onayla'**
  String get scan_confirmAnswers;

  /// Accessible name of the bottom left handle (spec C68).
  ///
  /// In tr, this message translates to:
  /// **'Sol alt köşe'**
  String get scan_cornerBottomLeftA11y;

  /// Accessible name of the bottom right handle (spec C68).
  ///
  /// In tr, this message translates to:
  /// **'Sağ alt köşe'**
  String get scan_cornerBottomRightA11y;

  /// Screen-reader action that moves a handle down (spec C68).
  ///
  /// In tr, this message translates to:
  /// **'Aşağı taşı'**
  String get scan_cornerMoveDownA11y;

  /// Screen-reader action that moves a handle left (spec C68).
  ///
  /// In tr, this message translates to:
  /// **'Sola taşı'**
  String get scan_cornerMoveLeftA11y;

  /// Screen-reader action that moves a handle right (spec C68).
  ///
  /// In tr, this message translates to:
  /// **'Sağa taşı'**
  String get scan_cornerMoveRightA11y;

  /// Screen-reader action that moves a handle up (spec C68).
  ///
  /// In tr, this message translates to:
  /// **'Yukarı taşı'**
  String get scan_cornerMoveUpA11y;

  /// Accessible name of the top left handle (spec C68).
  ///
  /// In tr, this message translates to:
  /// **'Sol üst köşe'**
  String get scan_cornerTopLeftA11y;

  /// Accessible name of the top right handle (spec C68).
  ///
  /// In tr, this message translates to:
  /// **'Sağ üst köşe'**
  String get scan_cornerTopRightA11y;

  /// Corner hint card, first line (pano 4.4 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Noktaları cevap alanının köşelerine getir.'**
  String get scan_cornersHint;

  /// Corner hint card, second line (pano 4.4 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Ders adları şeridi dışarıda kalsın.'**
  String get scan_cornersHintSub;

  /// Title of the corner screen (pano 4.4).
  ///
  /// In tr, this message translates to:
  /// **'Köşeleri Ayarla'**
  String get scan_cornersTitle;

  /// What a correction changed (pano 4.7 kare 3): 'Boş → C'.
  ///
  /// In tr, this message translates to:
  /// **'{from} → {to}'**
  String scan_correctionChange(String from, String to);

  /// Correction count in the summary and the fix sheet (pano 4.7): '2 düzeltme'.
  ///
  /// In tr, this message translates to:
  /// **'{n} düzeltme'**
  String scan_correctionCount(String n);

  /// One correction row (pano 4.7 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'{col}. kolon · {q}. soru'**
  String scan_correctionRow(String col, String q);

  /// Heading of the corrections list (pano 4.7 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Düzeltmeler'**
  String get scan_corrections;

  /// Empty corrections list (pano 4.7 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Henüz düzeltme yok. Okunan cevap formundakinden farklıysa yukarıdan ekle.'**
  String get scan_correctionsEmpty;

  /// Debug-only button of the camera failure screen (SCAN_GALLERY define; never in release).
  ///
  /// In tr, this message translates to:
  /// **'Galeriden seç'**
  String get scan_debugGalleryPick;

  /// Body of the refused-permission sheet (pano 4.1 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Formunu okutabilmek için Ayarlar\'da SMAP\'e kamera izni ver. Sonra buraya dön; kaldığın yerden devam edersin.'**
  String get scan_deniedBody;

  /// Title of the sheet shown when the camera permission was refused (pano 4.1 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Kamera izni kapalı'**
  String get scan_deniedTitle;

  /// Checkbox of the how-to-shoot sheet and text button of the corner hint (pano 4.2, 4.4 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Bir daha gösterme'**
  String get scan_dontShowAgain;

  /// Sub-line of the exam request screen (pano 4.9).
  ///
  /// In tr, this message translates to:
  /// **'Yayınevini ve deneme adını yaz; analizini en geç 72 saat içinde hazırlayalım.'**
  String get scan_enfBody;

  /// Note of the request confirmation sheet (pano 4.9 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Analizin hazır olunca Analizlerim › Denemelerim\'de görünür.'**
  String get scan_enfConfirmNote;

  /// Title of the request confirmation sheet (pano 4.9 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Talep oluşturulsun mu?'**
  String get scan_enfConfirmTitle;

  /// Body after the request was sent (pano 4.9 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'En geç 72 saat içinde hazır. Hazır olunca Analizlerim › Denemelerim\'de görünecek.'**
  String get scan_enfDoneBody;

  /// Title after the request was sent (pano 4.9 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Talebin alındı'**
  String get scan_enfDoneTitle;

  /// Info card of the exam request screen (pano 4.9).
  ///
  /// In tr, this message translates to:
  /// **'Cevapların kaydedildi. Yeniden okutman gerekmez.'**
  String get scan_enfSaved;

  /// Primary button of the exam request screen (pano 4.9).
  ///
  /// In tr, this message translates to:
  /// **'Analizimi Hazırlayın'**
  String get scan_enfSubmit;

  /// Title of the exam request screen (pano 4.9).
  ///
  /// In tr, this message translates to:
  /// **'Bu deneme henüz sistemde yok'**
  String get scan_enfTitle;

  /// Error of the empty exam name field (pano 4.9 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Deneme adını yaz.'**
  String get scan_errExamNameRequired;

  /// Error of the empty publisher field (pano 4.9 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Yayınevini yaz.'**
  String get scan_errPublisherRequired;

  /// Body of the exit confirmation (spec decision, board draws no body).
  ///
  /// In tr, this message translates to:
  /// **'Düzelttiğin cevaplar kaydedilmeyecek.'**
  String get scan_exitBody;

  /// Confirm button of the exit confirmation (spec decision).
  ///
  /// In tr, this message translates to:
  /// **'Çık'**
  String get scan_exitConfirm;

  /// Confirmation when closing the answer check with corrections (pano 4.7; spec exitScanConfirm).
  ///
  /// In tr, this message translates to:
  /// **'Okutmadan çıkılsın mı?'**
  String get scan_exitTitle;

  /// Label of the column segment in the fix sheet (pano 4.7 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Kolon'**
  String get scan_fieldColumn;

  /// Label of the exam name field (pano 4.9).
  ///
  /// In tr, this message translates to:
  /// **'Deneme adı'**
  String get scan_fieldExamName;

  /// Example in the exam name field (pano 4.9).
  ///
  /// In tr, this message translates to:
  /// **'Örn: Türkiye Geneli Deneme 7'**
  String get scan_fieldExamNameHint;

  /// Label of the publisher field (pano 4.9).
  ///
  /// In tr, this message translates to:
  /// **'Yayınevi'**
  String get scan_fieldPublisher;

  /// Example in the publisher field (pano 4.9).
  ///
  /// In tr, this message translates to:
  /// **'Örn: Örnek Yayınları'**
  String get scan_fieldPublisherHint;

  /// Label of the question stepper in the fix sheet (pano 4.7 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Soru'**
  String get scan_fieldQuestion;

  /// Outline button that opens the fix sheet (pano 4.7).
  ///
  /// In tr, this message translates to:
  /// **'Düzelt'**
  String get scan_fix;

  /// Title of the fix sheet (pano 4.7 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Cevap Düzelt'**
  String get scan_fixSheetTitle;

  /// Body of the form-not-found screen (pano 4.10 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Fotoğrafta cevap alanı seçilemedi. Formun tamamı görünsün, ışık yansımasın, ders adları şeridi dışarıda kalsın.'**
  String get scan_formNotFoundBody;

  /// Title of the form-not-found screen (pano 4.10 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Formu bulamadık'**
  String get scan_formNotFoundTitle;

  /// Primary button after the request was sent (pano 4.9 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Anasayfa'**
  String get scan_goHome;

  /// Primary button of the how-to-shoot sheet (pano 4.2).
  ///
  /// In tr, this message translates to:
  /// **'Anladım'**
  String get scan_gotIt;

  /// Hint pill once the form is found (pano 4.3 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Hazır. Telefonu sabit tut ve çek.'**
  String get scan_hintReady;

  /// Hint pill while the form is being looked for (pano 4.3 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Cevap alanını çerçeveye al.\nDers adları şeridi dışarıda kalsın.'**
  String get scan_hintSearching;

  /// Quiet button of the form-not-found screen; opens the how-to-shoot sheet (pano 4.10 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Nasıl Çekilir?'**
  String get scan_howToShoot;

  /// Accessible name of the question-mark button in the camera top bar (pano 4.2, 4.3).
  ///
  /// In tr, this message translates to:
  /// **'Nasıl çekilir?'**
  String get scan_howToShootA11y;

  /// Message of the image card after it failed to load (pano 4.8 kare 1 note).
  ///
  /// In tr, this message translates to:
  /// **'Görüntü yüklenemedi'**
  String get scan_imageLoadFailed;

  /// Caption of the image skeleton (pano 4.8 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Form görüntüsü yükleniyor'**
  String get scan_imageLoading;

  /// Screen-reader state of the running step (pano 4.5).
  ///
  /// In tr, this message translates to:
  /// **'Sürüyor'**
  String get scan_inProgressA11y;

  /// Quiet button after a failure; back to the camera (pano 4.5 kare 4, 4.10 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Yeni Fotoğraf'**
  String get scan_newPhoto;

  /// Primary button of the corner screen (pano 4.4).
  ///
  /// In tr, this message translates to:
  /// **'Devam'**
  String get scan_next;

  /// Accessible name of the plus button of the question stepper (pano 4.7).
  ///
  /// In tr, this message translates to:
  /// **'Sonraki soru'**
  String get scan_nextQuestionA11y;

  /// Counter line of a column with no blank answer (pano 4.7).
  ///
  /// In tr, this message translates to:
  /// **'boş yok'**
  String get scan_noBlank;

  /// Correction counter of the fix sheet while there is none (pano 4.7 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Düzeltme yok'**
  String get scan_noCorrection;

  /// Body of the planned offline screen; used only when the offline queue exists (pano 4.10 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Fotoğrafın telefonunda saklandı. Bağlantı gelince gönderilecek.'**
  String get scan_offlineQueuedBody;

  /// Title of the planned offline screen (pano 4.10 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı yok'**
  String get scan_offlineTitle;

  /// Button of the maintenance sheet and the offline screen (pano 4.10 kare 2, 3).
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get scan_ok;

  /// Body of the maintenance sheet (pano 4.10 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Kısa bir bakım yapıyoruz. Birazdan tekrar dene.'**
  String get scan_omrClosedBody;

  /// Title of the maintenance sheet (pano 4.10 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Optik okuma şu an kapalı'**
  String get scan_omrClosedTitle;

  /// Primary button of the refused-permission sheet; opens the app's system settings (pano 4.1 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Ayarları Aç'**
  String get scan_openSettings;

  /// Upload percentage next to "Gönderiliyor" (pano 4.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'%{n}'**
  String scan_percent(String n);

  /// Hint under the form image (pano 4.7).
  ///
  /// In tr, this message translates to:
  /// **'İki parmakla yakınlaştırabilirsin.'**
  String get scan_pinchHint;

  /// Accessible name of the minus button of the question stepper (pano 4.7).
  ///
  /// In tr, this message translates to:
  /// **'Önceki soru'**
  String get scan_previousQuestionA11y;

  /// Primary button of the permission sheet (pano 4.1 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Kameraya İzin Ver'**
  String get scan_primerAllow;

  /// Camera permission sheet, body (pano 4.1 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'SMAP kamerayı yalnız optik formunu çekerken kullanır. Bir sonraki adımda telefonun izin isteyecek.'**
  String get scan_primerBody;

  /// Quiet button of the permission sheet; closes it and stays where you were (pano 4.1 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Sonra'**
  String get scan_primerLater;

  /// Camera permission sheet before the system dialog, title (pano 4.1 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Formunu okutmak için kamera gerekli'**
  String get scan_primerTitle;

  /// Accessible name of the question number (pano 4.7).
  ///
  /// In tr, this message translates to:
  /// **'Soru numarası'**
  String get scan_questionNumberA11y;

  /// Label of the read value next to the stepper (pano 4.7 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Okunan'**
  String get scan_readValue;

  /// Accessible name of the remove button of a correction (pano 4.7 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Düzeltmeyi kaldır: {col}. kolon, {q}. soru'**
  String scan_removeCorrectionA11y(String col, String q);

  /// Outline button of the corner screen; back to the camera (pano 4.4).
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Çek'**
  String get scan_retake;

  /// Quiet button of the planned offline screen (pano 4.10 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Şimdi Tekrar Dene'**
  String get scan_retryNow;

  /// Sub-line of the answer check (pano 4.7).
  ///
  /// In tr, this message translates to:
  /// **'Okunan cevapları formunla karşılaştır.'**
  String get scan_reviewSub;

  /// Title of the answer check (pano 4.7).
  ///
  /// In tr, this message translates to:
  /// **'Form Kontrol'**
  String get scan_reviewTitle;

  /// Primary button of the request confirmation sheet (pano 4.9 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Talebi Gönder'**
  String get scan_sendRequest;

  /// Label of the busy primary button (pano 4.7 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Gönderiliyor'**
  String get scan_sending;

  /// Accessible name of the shutter button (pano 4.3).
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf çek'**
  String get scan_shutterA11y;

  /// Step 1 when done (pano 4.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf hazırlandı'**
  String get scan_stepPrepared;

  /// Step 1 while it runs (pano 4.5 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf hazırlanıyor'**
  String get scan_stepPreparing;

  /// Step 3 while it runs (pano 4.5 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Cevapların okunuyor'**
  String get scan_stepReading;

  /// Step 2 after a failure (pano 4.5 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Gönderilemedi'**
  String get scan_stepSendFailed;

  /// Step 2 while it runs, with the percentage (pano 4.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Gönderiliyor'**
  String get scan_stepSending;

  /// Step 2 when done (pano 4.5 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Gönderildi'**
  String get scan_stepSent;

  /// Step 3 while waiting (pano 4.5 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Cevaplar okunacak'**
  String get scan_stepToRead;

  /// Step 2 while waiting (pano 4.5 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Gönderilecek'**
  String get scan_stepToSend;

  /// Title in the top bar of the camera (pano 4.2, 4.3).
  ///
  /// In tr, this message translates to:
  /// **'Optik Form'**
  String get scan_topTitle;

  /// Step 1 of the how-to-shoot sheet (pano 4.2).
  ///
  /// In tr, this message translates to:
  /// **'Cevap alanını çerçeveye al.'**
  String get scan_tutorialStep1;

  /// Step 2 of the how-to-shoot sheet (pano 4.2).
  ///
  /// In tr, this message translates to:
  /// **'Ders adlarının yazdığı yatay şeridi dışarıda bırak.'**
  String get scan_tutorialStep2;

  /// Step 3 of the how-to-shoot sheet (pano 4.2).
  ///
  /// In tr, this message translates to:
  /// **'Turuncu noktaları cevap alanının dört köşesine getir.'**
  String get scan_tutorialStep3;

  /// Title of the how-to-shoot sheet (pano 4.2).
  ///
  /// In tr, this message translates to:
  /// **'Formu böyle çek'**
  String get scan_tutorialTitle;

  /// Sub-line after the upload failed (pano 4.5 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı koptu. Fotoğrafın duruyor; tekrar gönderebilir ya da yeniden çekebilirsin.'**
  String get scan_uploadFailBody;

  /// Title after the upload failed (pano 4.5 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Formun gönderilemedi'**
  String get scan_uploadFailTitle;

  /// Screen-reader name of the photo card (pano 4.5).
  ///
  /// In tr, this message translates to:
  /// **'Okunan form görüntüsü: dört kolon, kırk satır'**
  String get scan_uploadPhotoA11y;

  /// Screen-reader name of the upload progress bar (pano 4.5).
  ///
  /// In tr, this message translates to:
  /// **'Gönderim'**
  String get scan_uploadProgressA11y;

  /// Sub-line of the upload screen (pano 4.5).
  ///
  /// In tr, this message translates to:
  /// **'Birkaç saniye sürebilir.'**
  String get scan_uploadSub;

  /// Sub-line after a timeout (pano 4.5 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Sunucu yanıt vermedi.'**
  String get scan_uploadTimeoutBody;

  /// Title of the upload screen (pano 4.5).
  ///
  /// In tr, this message translates to:
  /// **'Formun okunuyor'**
  String get scan_uploadTitle;

  /// Label of the option chips in the fix sheet (pano 4.7 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Formdaki işaretin'**
  String get scan_yourMark;

  /// Accessible name of the magnify button on the form image (pano 4.7).
  ///
  /// In tr, this message translates to:
  /// **'Formu büyüt'**
  String get scan_zoomFormA11y;

  /// Topic sheet primary button (pano 3.5 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get schedule_add;

  /// Outline button and empty-day action that opens the hour grid (pano 3.6 kare 1, 3); also the focused empty slot (pano 3.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Konu Ekle'**
  String get schedule_addTopic;

  /// Topic sheet, empty bag (not in the board; written here).
  ///
  /// In tr, this message translates to:
  /// **'Çantanda henüz konu yok. Denemelerinden çıkan eksik konular burada görünür.'**
  String get schedule_bagEmpty;

  /// Topic sheet help under the segment (pano 3.5 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Çantam: denemelerinden çıkan eksik konuların.'**
  String get schedule_bagHelp;

  /// Danger text button of edit mode (pano 3.6 kare 1); only drawn while FeatureFlags.programDeleteEnabled.
  ///
  /// In tr, this message translates to:
  /// **'Programı İptal Et'**
  String get schedule_cancelProgram;

  /// Cancel program confirmation text (pano 3.6 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Program listeden kalkar ve Anasayfa\'daki Bugün bölümü boşalır. Bu işlem geri alınamaz.'**
  String get schedule_cancelProgramBody;

  /// Cancel program confirmation title (pano 3.6 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'{name} iptal edilsin mi?'**
  String schedule_cancelProgramTitle(String name);

  /// Program item time button in edit mode (C30): "Saat 10:00, değiştir".
  ///
  /// In tr, this message translates to:
  /// **'Saat {time}, değiştir'**
  String schedule_changeTimeA11y(String time);

  /// Title of the time wheel sheet opened from an item time (pano 3.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Saati Değiştir'**
  String get schedule_changeTimeTitle;

  /// Search with no result, text button (pano 3.4 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Aramayı Temizle'**
  String get schedule_clearSearch;

  /// Accessible name of the X of the first step (pano 3.5 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get schedule_closeA11y;

  /// Count line under a day chip of the grid step (pano 3.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'{count} konu'**
  String schedule_dayChipTopics(String count);

  /// Heading of the selected day (pano 3.4 kare 3): "Cumartesi, 10 Ekim".
  ///
  /// In tr, this message translates to:
  /// **'{weekday}, {day} {month}'**
  String schedule_dayTitle(String weekday, String day, String month);

  /// Step 1 sentence (pano 3.5 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Birden çok gün seçebilirsin; geçmiş günler seçilemez.'**
  String get schedule_daysBody;

  /// Step 1 summary above "Devam Et" (pano 3.5 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'{count} gün seçildi'**
  String schedule_daysSelected(String count);

  /// Step 1 title (pano 3.5 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Hangi günler çalışacaksın?'**
  String get schedule_daysTitle;

  /// Suggested name of a new program (pano 3.5 kare 4): "Ekim 3. Hafta".
  ///
  /// In tr, this message translates to:
  /// **'{month} {week}. Hafta'**
  String schedule_defaultName(String month, String week);

  /// Text of the leave confirmation (not in the board; written here).
  ///
  /// In tr, this message translates to:
  /// **'Seçtiğin günler ve yerleştirdiğin konular kaybolur.'**
  String get schedule_discardBody;

  /// Primary button of the leave confirmation (not in the board; written here).
  ///
  /// In tr, this message translates to:
  /// **'Kaydetmeden Çık'**
  String get schedule_discardConfirm;

  /// Confirmation when leaving the flow with changes (pano 3.5 "Vazgeç (X)").
  ///
  /// In tr, this message translates to:
  /// **'Program kaydedilmesin mi?'**
  String get schedule_discardTitle;

  /// Bar action that turns edit mode off; changes are already saved (pano 3.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Bitti'**
  String get schedule_done;

  /// Bar action that turns edit mode on (pano 3.4 kare 3, 4).
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get schedule_edit;

  /// Empty program list, primary action (pano 3.7 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Haftalık Programını Kur'**
  String get schedule_emptyAction;

  /// Empty program list, sentence (pano 3.7 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Haftalık programını kurduğunda günün konuları burada ve Anasayfa\'da görünür.'**
  String get schedule_emptyBody;

  /// Empty day (pano 3.6 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Bu gün için çalışma yok.'**
  String get schedule_emptyDay;

  /// Empty hour slot reading (C64, pano 3.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'{time}, boş, konu ekle'**
  String schedule_emptySlotA11y(String time);

  /// Empty program list, title (pano 3.7 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Henüz programın yok'**
  String get schedule_emptyTitle;

  /// Step 3 motto field label; the field is marked optional by the field (pano 3.5 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Motto'**
  String get schedule_fieldMotto;

  /// Step 3 name field label (pano 3.5 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Program adı'**
  String get schedule_fieldName;

  /// Filled hour slot reading (C64).
  ///
  /// In tr, this message translates to:
  /// **'{time}, {lesson}, {topic}'**
  String schedule_filledSlotA11y(String time, String lesson, String topic);

  /// Step 2 sentence (pano 3.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Boş bir saate dokun, konu seç. Izgara 06:00–23:00.'**
  String get schedule_gridBody;

  /// Step 2 title (pano 3.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Konuları yerleştir'**
  String get schedule_gridTitle;

  /// Under a topic already in the program (pano 3.5 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Programda: {day} {time}'**
  String schedule_inProgramAt(String day, String time);

  /// Program list failed to load, title (pano 3.7 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Programların yüklenemedi'**
  String get schedule_loadError;

  /// Program list failed to load, sentence (pano 3.7 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Bağlantını kontrol edip tekrar dene.'**
  String get schedule_loadErrorBody;

  /// Step 3 motto help (pano 3.5 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Program listesinde adın altında görünür.'**
  String get schedule_mottoHelp;

  /// Step 3 error under an empty name.
  ///
  /// In tr, this message translates to:
  /// **'Programına bir ad ver.'**
  String get schedule_nameRequired;

  /// Step 3 title (pano 3.5 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Programına ad ver'**
  String get schedule_nameTitle;

  /// Bar action that starts the new program flow (pano 3.4 kare 1, 3.7 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Yeni Program'**
  String get schedule_new;

  /// Note under the list while offline (pano 3.7 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Program kurmak ve düzenlemek için bağlantı gerekiyor. Kayıtlı programını görebilirsin.'**
  String get schedule_offlineNote;

  /// Program row reading without the tag (C29).
  ///
  /// In tr, this message translates to:
  /// **'{name}, {motto}, {range}'**
  String schedule_programRowA11y(String name, String motto, String range);

  /// Program item remove button in edit mode (C30): "Fiilde Çatı, programdan çıkar".
  ///
  /// In tr, this message translates to:
  /// **'{topic}, programdan çıkar'**
  String schedule_removeA11y(String topic);

  /// Remove button of a filled hour slot (C64, pano 3.5 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'{topic}, çıkar'**
  String schedule_removeSlotA11y(String topic);

  /// Danger text button under the day list (pano 3.4 kare 3, 3.6 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Günü Sıfırla'**
  String get schedule_resetDay;

  /// Reset day confirmation text (pano 3.6 kare 2): "10 Ekim'deki 3 çalışma ...". The date arrives with its locative suffix and "ki".
  ///
  /// In tr, this message translates to:
  /// **'{date} {count} çalışma programdan çıkar. Diğer günler değişmez.'**
  String schedule_resetDayBody(String date, String count);

  /// Reset day confirmation title (pano 3.6 kare 2): "Cumartesi'yi sıfırlayalım mı?". The weekday arrives with its accusative suffix.
  ///
  /// In tr, this message translates to:
  /// **'{weekday} sıfırlayalım mı?'**
  String schedule_resetDayTitle(String weekday);

  /// Toast when an instant save failed; the screen goes back to the saved state.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilemedi. Bağlantını kontrol edip tekrar dene.'**
  String get schedule_saveFailed;

  /// Step 3 primary button (pano 3.5 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Programı Kaydet'**
  String get schedule_saveProgram;

  /// Search with no result, explanation (pano 3.4 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Program adında ve mottosunda arar; büyük-küçük harf ve I/ı farkı gözetmez.'**
  String get schedule_searchHelp;

  /// Search field placeholder and accessible name (pano 3.4 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Program ara'**
  String get schedule_searchHint;

  /// Search with no result, title (pano 3.4 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'“{query}” ile eşleşen program yok'**
  String schedule_searchNoMatch(String query);

  /// Topic sheet segment (pano 3.5 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Çantam'**
  String get schedule_srcBag;

  /// Topic sheet segment (pano 3.5 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Dersler'**
  String get schedule_srcLessons;

  /// Step counter of the new program flow (pano 3.5).
  ///
  /// In tr, this message translates to:
  /// **'Adım {step}/3'**
  String schedule_stepOf(String step);

  /// Number of topics planned on the day (pano 3.4 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'{count} çalışma'**
  String schedule_studyCount(String count);

  /// Step 3 summary label (pano 3.5 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Günler'**
  String get schedule_summaryDays;

  /// Step 3 summary: "12–17 Ekim 2026 · 6 gün".
  ///
  /// In tr, this message translates to:
  /// **'{range} · {count} gün'**
  String schedule_summaryDaysValue(String range, String count);

  /// Step 3 note listing the days with no topic (pano 3.5 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'{days} henüz boş; kaydettikten sonra ekleyebilirsin.'**
  String schedule_summaryEmptyDays(String days);

  /// Step 3 summary label (pano 3.5 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Çalışmalar'**
  String get schedule_summaryStudies;

  /// Step 3 summary when every topic is on one day (pano 3.5 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'{count} çalışma, hepsi {day}'**
  String schedule_summaryStudiesOneDay(String count, String day);

  /// Step 3 summary when the topics are on several days.
  ///
  /// In tr, this message translates to:
  /// **'{count} çalışma, {days} güne dağılmış'**
  String schedule_summaryStudiesSpread(String count, String days);

  /// Tag of the program of the current week (pano 3.4 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta'**
  String get schedule_thisWeek;

  /// Last word of a program row's reading: "Ekim 2. Hafta, Her gün biraz daha, 5–11 Ekim 2026, bu hafta" (brief 14.1 "Erişilebilirlik").
  ///
  /// In tr, this message translates to:
  /// **'bu hafta'**
  String get schedule_thisWeekA11y;

  /// Screen title of the program list (pano 3.4 kare 1, 3.7).
  ///
  /// In tr, this message translates to:
  /// **'Programım'**
  String get schedule_title;

  /// Toast after "Günü Sıfırla", with "Geri Al" (pano 3.6 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'{weekday} sıfırlandı.'**
  String schedule_toastDayReset(String weekday);

  /// Toast after the program was cancelled (pano 3.6 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Program iptal edildi.'**
  String get schedule_toastProgramCancelled;

  /// Toast after a new program was saved (pano 3.5 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Program kaydedildi.'**
  String get schedule_toastProgramSaved;

  /// Toast after removing a topic, with "Geri Al" (pano 3.6).
  ///
  /// In tr, this message translates to:
  /// **'Konu çıkarıldı.'**
  String get schedule_toastTopicRemoved;

  /// Reading of a topic row of the topic sheet.
  ///
  /// In tr, this message translates to:
  /// **'{topic}, {lesson}'**
  String schedule_topicRowA11y(String topic, String lesson);

  /// Accessible name of the topic sheet (pano 3.5 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Konu ekle'**
  String get schedule_topicSheetA11y;

  /// Topic sheet title (pano 3.5 kare 3): "Pazartesi 12 Ekim · 16:00".
  ///
  /// In tr, this message translates to:
  /// **'{weekday} {day} {month} · {time}'**
  String schedule_topicSheetTitle(
    String weekday,
    String day,
    String month,
    String time,
  );

  /// Topic sheet, the lessons failed to load (not in the board; written here).
  ///
  /// In tr, this message translates to:
  /// **'Konular yüklenemedi'**
  String get schedule_topicsLoadError;

  /// Segment: day view (pano 3.4 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Gün'**
  String get schedule_viewDay;

  /// Accessible name of the Gün / Hafta segment (pano 3.4 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Görünüm'**
  String get schedule_viewLabel;

  /// Segment: week view (pano 3.4 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Hafta'**
  String get schedule_viewWeek;

  /// Reading of a week grid block (C63): "Cumartesi 10:00, Türkçe, Fiilde Çatı".
  ///
  /// In tr, this message translates to:
  /// **'{day} {time}, {lesson}, {topic}'**
  String schedule_weekBlockA11y(
    String day,
    String time,
    String lesson,
    String topic,
  );

  /// Accessible name of the week grid (C63): "Haftalık program, 06:00–23:00".
  ///
  /// In tr, this message translates to:
  /// **'Haftalık program, {range}'**
  String schedule_weekGridA11y(String range);

  /// Appended to the week grid reading: the columns scrolled out at the left (C63).
  ///
  /// In tr, this message translates to:
  /// **'{days} solda'**
  String schedule_weekGridHiddenLeft(String days);

  /// Screen reader name of the 96 pt app icon on the forced update screen (pano 2.7 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'SMAP uygulama ikonu'**
  String get startup_appIconLabel;

  /// Title of the screen shown when the app's start-up itself failed (service container, preferences); its sentence is errors_unknown and its button common_retry.
  ///
  /// In tr, this message translates to:
  /// **'SMAP açılamadı'**
  String get startup_bootFailedTitle;

  /// Forced update screen primary button; opens the store page (pano 2.7 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Güncelle'**
  String get startup_forceUpdateAction;

  /// Forced update screen sentence (pano 2.7 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Bu sürüm artık desteklenmiyor. Devam etmek için SMAP\'i güncelle; verilerin hesabında duruyor.'**
  String get startup_forceUpdateBody;

  /// Forced update screen title (pano 2.7 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Yeni sürüm gerekli'**
  String get startup_forceUpdateTitle;

  /// Screen reader name of the spinner under the logo on the launch screen when opening takes longer than a second (pano 2.1 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'SMAP açılıyor'**
  String get startup_loadingLabel;

  /// Maintenance screen sentence (pano 2.7 kare 3). No time promise.
  ///
  /// In tr, this message translates to:
  /// **'Kısa süre içinde geri döneceğiz. Verilerin güvende; bakım bitince kaldığın yerden devam edersin.'**
  String get startup_maintenanceBody;

  /// Maintenance screen title (pano 2.7 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'SMAP şu an bakımda'**
  String get startup_maintenanceTitle;

  /// Session expired sheet primary button; opens the sign-in screen and returns to the same screen afterwards (pano 2.7 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get startup_sessionExpiredAction;

  /// Session expired sheet sentence (pano 2.7 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Güvenliğin için yeniden giriş yapman gerekiyor. Okuttuğun denemeler hesabında duruyor.'**
  String get startup_sessionExpiredBody;

  /// Session expired sheet title (pano 2.7 kare 2).
  ///
  /// In tr, this message translates to:
  /// **'Oturumun sona erdi'**
  String get startup_sessionExpiredTitle;

  /// Unknown role screen sentence (pano 2.7 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Hesap türün tanınmadı. Çıkış yapıp yeniden giriş yapmayı dene; sorun sürerse bize yaz.'**
  String get startup_unknownRoleBody;

  /// Unknown role screen text button: opens a mail draft to support; hidden while no support address is configured (pano 2.7 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Destek\'e Yaz'**
  String get startup_unknownRoleContact;

  /// Unknown role screen primary button: signs out and goes to the welcome screen (pano 2.7 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Yeniden Giriş Yap'**
  String get startup_unknownRoleReLogin;

  /// Unknown role screen title (pano 2.7 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Hesabın açılamadı'**
  String get startup_unknownRoleTitle;

  /// Accessible name and tooltip of the Plus action of the navy band (pano 10.2 kare 1, "aria Öğrenci ekle").
  ///
  /// In tr, this message translates to:
  /// **'Öğrenci ekle'**
  String get students_addA11y;

  /// Toast after the credentials sheet closed with "Tamam" (pano 10.3 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'{name} eklendi.'**
  String students_added(String name);

  /// Text button of the no-match card; empties the search (pano 10.2 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Aramayı Temizle'**
  String get students_clearSearch;

  /// The counter under the search field (pano 10.2 kare 1 and 2): "5 öğrenci", "1 öğrenci".
  ///
  /// In tr, this message translates to:
  /// **'{count} öğrenci'**
  String students_count(String count);

  /// Primary button of the empty list; opens the add-student sheet (pano 10.2 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Öğrenci Ekle'**
  String get students_emptyAdd;

  /// Sentence of the empty list (pano 10.2 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Öğrencinin hesabını sen aç ya da koçluk kodunu paylaş; bağlanan öğrenciler burada listelenir.'**
  String get students_emptyMessage;

  /// Secondary button of the empty list; opens the system share sheet with the coaching code (pano 10.2 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Kodunu Paylaş'**
  String get students_emptyShare;

  /// Title of the empty list (pano 10.2 kare 4).
  ///
  /// In tr, this message translates to:
  /// **'Henüz öğrencin yok'**
  String get students_emptyTitle;

  /// The exam count in the meta line of a student row (pano 10.2 kare 1): "12. Sınıf · Eşit Ağırlık · 10 deneme". Written only when the student has read an exam.
  ///
  /// In tr, this message translates to:
  /// **'{count} deneme'**
  String students_examCount(String count);

  /// Sentence of the screen-level error state (spec 2.18 "Ekran hatası metni").
  ///
  /// In tr, this message translates to:
  /// **'Bağlantını kontrol edip tekrar dene. Sorun sürerse biraz sonra yeniden açabilirsin.'**
  String get students_loadErrorMessage;

  /// Title of the error state of the student list (pano 1.22 kare 4 wording; pano 10.2 has no drawn error).
  ///
  /// In tr, this message translates to:
  /// **'Öğrenciler yüklenemedi'**
  String get students_loadErrorTitle;

  /// Two parts of the meta line of a student row, joined by a middle dot (pano 10.2 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'{first} · {second}'**
  String students_metaJoin(String first, String second);

  /// How the search works, under the no-match title (pano 10.2 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Ad ve soyadda arar; büyük-küçük harf ve I/ı/İ/i farkı gözetmez.'**
  String get students_noResultMessage;

  /// Title of the no-match card of the search (pano 10.2 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'“{query}” ile eşleşen öğrenci yok'**
  String students_noResultTitle(String query);

  /// Screen reader reading of a student row: the name and the meta line (pano 10.2 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'{name}, {details}'**
  String students_rowA11y(String name, String details);

  /// Placeholder and accessible name of the search field (pano 10.2 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Öğrenci ara'**
  String get students_searchHint;

  /// The same line for a lesson opened on "Tümü", which has no track name.
  ///
  /// In tr, this message translates to:
  /// **'{lesson} · {number}. konu'**
  String topicDetail_context(String lesson, int number);

  /// Line under the topic title (pano 7.3 kare 1): "Türkçe · TYT · 1. konu".
  ///
  /// In tr, this message translates to:
  /// **'{lesson} · {track} · {number}. konu'**
  String topicDetail_contextTrack(String lesson, String track, int number);

  /// Second line under the topic title (pano 7.3 kare 1): "5 alt başlık · 25 madde".
  ///
  /// In tr, this message translates to:
  /// **'{subTopics} alt başlık · {items} madde'**
  String topicDetail_counts(String subTopics, String items);

  /// Empty state of a topic without sub-topics (pano 7.5 "Boş metinler").
  ///
  /// In tr, this message translates to:
  /// **'Bu konunun içeriği hazırlanıyor.'**
  String get topicDetail_empty;

  /// Title of the error state of Konu Detayı (pano 7.5 kare 3).
  ///
  /// In tr, this message translates to:
  /// **'Konu yüklenemedi'**
  String get topicDetail_errorTitle;

  /// Item count in the meta line of a sub-topic card (pano 7.3 kare 1): "4 madde".
  ///
  /// In tr, this message translates to:
  /// **'{count} madde'**
  String topicDetail_itemCount(String count);

  /// Text button under an open item: opens its card in a sheet (pano 7.3 kare 1).
  ///
  /// In tr, this message translates to:
  /// **'Kartı Aç'**
  String get topicDetail_openCard;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
