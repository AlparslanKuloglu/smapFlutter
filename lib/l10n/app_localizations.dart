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
