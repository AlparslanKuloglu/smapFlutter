// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get common_cancel => 'Vazgeç';

  @override
  String get common_close => 'Kapat';

  @override
  String get common_continue => 'Devam Et';

  @override
  String get common_ok => 'Tamam';

  @override
  String get common_retry => 'Tekrar Dene';

  @override
  String get common_save => 'Kaydet';

  @override
  String get common_undo => 'Geri Al';

  @override
  String get errors_cancelled => 'İşlem durduruldu.';

  @override
  String get errors_forbidden => 'Bu işlem için yetkin yok.';

  @override
  String get errors_maintenance =>
      'SMAP şu an bakımda. Biraz sonra tekrar dene.';

  @override
  String get errors_network =>
      'Bağlantıda bir sorun oluştu. Biraz sonra tekrar dene.';

  @override
  String get errors_notFound => 'Aradığın içerik bulunamadı.';

  @override
  String get errors_offline =>
      'Bağlantı yok. Bağlantını kontrol edip tekrar dene.';

  @override
  String get errors_server =>
      'Sunucuda bir sorun oluştu. Biraz sonra tekrar dene.';

  @override
  String get errors_sessionExpired =>
      'Oturumun sona erdi. Yeniden giriş yapman gerekiyor.';

  @override
  String get errors_timeout => 'İstek çok uzun sürdü. Tekrar dene.';

  @override
  String get errors_unauthorized =>
      'Giriş bilgilerin doğru değil. Kontrol edip tekrar dene.';

  @override
  String get errors_unknown => 'Beklenmedik bir sorun oluştu. Tekrar dene.';

  @override
  String get errors_validation => 'Bilgilerini kontrol edip tekrar dene.';

  @override
  String get kit_a11yAsksConfirmation => 'onay ister';

  @override
  String kit_a11yAvatarOption(int index) {
    return 'Avatar $index';
  }

  @override
  String kit_a11yCoachAvatar(String name) {
    return '$name, koç';
  }

  @override
  String get kit_a11yDeltaDown => 'düşüş';

  @override
  String get kit_a11yDeltaFlat => 'değişim yok';

  @override
  String get kit_a11yDeltaUp => 'artış';

  @override
  String kit_a11yMoreStudents(int count) {
    return 've $count öğrenci daha';
  }

  @override
  String kit_a11yOptionOf(int total, int index) {
    return '$total seçenekten $index';
  }

  @override
  String get kit_a11ySelected => 'seçili';

  @override
  String kit_a11yTabOf(int total, int index) {
    return 'sekme, $total sekmeden $index';
  }

  @override
  String kit_avatarCount(int count) {
    return '$count avatar';
  }

  @override
  String get kit_checking => 'Kontrol ediliyor';

  @override
  String get kit_clearSearch => 'Aramayı temizle';

  @override
  String get kit_coachBadge => 'Koç';

  @override
  String kit_codeDigits(int count) {
    return '$count hane';
  }

  @override
  String get kit_hidePassword => 'Şifreyi gizle';

  @override
  String get kit_loading => 'Yükleniyor';

  @override
  String get kit_logoLabel => 'SMAP';

  @override
  String get kit_noQuestions => 'Soru yok';

  @override
  String get kit_optionalSuffix => '(isteğe bağlı)';

  @override
  String kit_pageDotsA11y(int count, int index) {
    return '$count ekrandan $index.';
  }

  @override
  String kit_percentA11y(int percent) {
    return 'Yüzde $percent';
  }

  @override
  String get kit_showPassword => 'Şifreyi göster';
}
