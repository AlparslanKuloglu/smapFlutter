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

  /// Screen reader sentence of one score card column (C26): "Sıra, 48.215.".
  ///
  /// In tr, this message translates to:
  /// **'{label}, {value}'**
  String exams_scoreColumnA11y(String label, String value);

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

  /// Card progress under a subject row (C20, C44).
  ///
  /// In tr, this message translates to:
  /// **'{known} / {total} kart biliniyor'**
  String lessons_cardsKnown(int known, int total);

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

  /// Program item time button in edit mode (C30): "Saat 10:00, değiştir".
  ///
  /// In tr, this message translates to:
  /// **'Saat {time}, değiştir'**
  String schedule_changeTimeA11y(String time);

  /// Program item remove button in edit mode (C30): "Fiilde Çatı, programdan çıkar".
  ///
  /// In tr, this message translates to:
  /// **'{topic}, programdan çıkar'**
  String schedule_removeA11y(String topic);

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

  /// Legacy registration bridge only: the account was created but the follow-up sign-in failed. Goes away with the new sign-up screen (E4).
  ///
  /// In tr, this message translates to:
  /// **'Hesabın açıldı ama giriş yapılamadı. Giriş ekranından giriş yaparak devam et.'**
  String get startup_registerSignInFailed;

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
