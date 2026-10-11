// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String analytics_netChartA11y(
    String scope,
    String startDate,
    String startNet,
    String endDate,
    String endNet,
    int count,
  ) {
    return '$scope net grafiği, $startDate $startNet netten $endDate $endNet nete, $count deneme';
  }

  @override
  String analytics_netChartBalloonHead(String name, String date) {
    return '$name · $date';
  }

  @override
  String analytics_netChartBalloonNet(String net) {
    return '$net net';
  }

  @override
  String analytics_netChartFootnote(String scope, String max) {
    return 'net · $scope 0–$max · son nokta vurgulu';
  }

  @override
  String analytics_netChartPointA11y(String name, String date, String net) {
    return '$name, $date, $net net';
  }

  @override
  String analytics_netChartPointNoNameA11y(String date, String net) {
    return '$date, $net net';
  }

  @override
  String analytics_netChartRange(int count) {
    return 'Son $count deneme';
  }

  @override
  String analytics_netChartSingleA11y(String scope, String date, String net) {
    return '$scope net grafiği, $date $net net, 1 deneme';
  }

  @override
  String get analytics_netChartTitle => 'Net gelişimi';

  @override
  String get cards_favoriteAdd => 'Favorilere ekle';

  @override
  String get cards_favoriteRemove => 'Favorilerden çıkar';

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
  String exams_correctAnswer(String answer) {
    return 'Doğru $answer';
  }

  @override
  String exams_deltaVsPrevious(String type) {
    return 'önceki $type\'ye göre';
  }

  @override
  String exams_deltaVsPreviousMoment(String type) {
    return 'önceki $type denemene göre';
  }

  @override
  String exams_dybA11y(int correct, int wrong, int blank) {
    return '$correct doğru, $wrong yanlış, $blank boş';
  }

  @override
  String get exams_dybBlank => 'Boş';

  @override
  String get exams_dybCorrect => 'Doğru';

  @override
  String get exams_dybLetterBlank => 'B';

  @override
  String get exams_dybLetterCorrect => 'D';

  @override
  String get exams_dybLetterWrong => 'Y';

  @override
  String get exams_dybWordBlank => 'boş';

  @override
  String get exams_dybWordCorrect => 'doğru';

  @override
  String get exams_dybWordWrong => 'yanlış';

  @override
  String get exams_dybWrong => 'Yanlış';

  @override
  String exams_examRowA11y(String name, String type, String date, String net) {
    return '$name, $type, $date, $net net';
  }

  @override
  String get exams_favoriteAdd => 'Favorilere ekle';

  @override
  String get exams_favoriteRemove => 'Favorilerden çıkar';

  @override
  String get exams_fewQuestions => 'Az soru';

  @override
  String exams_formCheckBlankA11y(int number) {
    return '$number. soru, boş okundu, düzeltmek için dokun';
  }

  @override
  String exams_formCheckCorrectedA11y(int number, String marked) {
    return '$number. soru, düzeltildi: $marked';
  }

  @override
  String exams_formCheckReadA11y(int number, String marked) {
    return '$number. soru, okundu: $marked';
  }

  @override
  String exams_momentA11y(
    String name,
    String net,
    int correct,
    int wrong,
    int blank,
  ) {
    return '$name, $net net, $correct doğru, $wrong yanlış, $blank boş';
  }

  @override
  String exams_momentWithDeltaA11y(
    String name,
    String net,
    int correct,
    int wrong,
    int blank,
    String delta,
  ) {
    return '$name, $net net, $correct doğru, $wrong yanlış, $blank boş, önceki sınava göre $delta';
  }

  @override
  String get exams_netUnit => 'net';

  @override
  String get exams_placementScore => 'Yerleştirme puanı';

  @override
  String exams_questionBlankA11y(int number, String correctAnswer) {
    return 'Soru $number, boş, doğru cevap $correctAnswer';
  }

  @override
  String exams_questionBlankNoKeyA11y(int number) {
    return 'Soru $number, boş';
  }

  @override
  String exams_questionCorrectA11y(int number, String marked) {
    return 'Soru $number, doğru, işaretin $marked';
  }

  @override
  String exams_questionCount(int count) {
    return '$count soru';
  }

  @override
  String exams_questionWrongA11y(
    int number,
    String marked,
    String correctAnswer,
  ) {
    return 'Soru $number, yanlış, işaretin $marked, doğru cevap $correctAnswer';
  }

  @override
  String exams_questionWrongNoKeyA11y(int number, String marked) {
    return 'Soru $number, yanlış, işaretin $marked';
  }

  @override
  String get exams_rank => 'Sıra';

  @override
  String exams_scoreColumnA11y(String label, String value) {
    return '$label, $value';
  }

  @override
  String exams_stackedBarA11y(int total, int correct, int wrong, int blank) {
    return '$total sorudan $correct doğru, $wrong yanlış, $blank boş';
  }

  @override
  String get exams_summaryAnalyze => 'Analizi Gör';

  @override
  String get exams_summaryEmptyBody =>
      'Optik formunu okuttuğunda netin, doğru-yanlış dağılımın ve en çok kaçırdığın konu burada görünür.';

  @override
  String get exams_summaryEmptyTitle => 'Henüz deneme okutmadın.';

  @override
  String get exams_summaryScan => 'İlk Denemeni Okut';

  @override
  String get exams_summaryWeakestTopic => 'En çok kaçırdığın konu';

  @override
  String exams_testRowA11y(
    String name,
    String net,
    int total,
    int correct,
    int wrong,
    int blank,
  ) {
    return '$name, $net net, $total sorudan $correct doğru, $wrong yanlış, $blank boş';
  }

  @override
  String get kit2_a11ySelectHint => 'seçenekleri açar';

  @override
  String get kit2_a11yTimeWheelHour => 'Saat';

  @override
  String get kit2_a11yTimeWheelMinute => 'Dakika';

  @override
  String get kit2_a11yToastClose => 'Bildirimi kapat';

  @override
  String get kit2_comingSoonBody =>
      'Bu bölüm henüz hazır değil. Hazır olduğunda burada göreceksin.';

  @override
  String get kit2_comingSoonTitle => 'Yakında';

  @override
  String get kit2_connectedStrip => 'Bağlandın';

  @override
  String get kit2_offlineStrip =>
      'Çevrimdışısın. Son kaydedilen veriler gösteriliyor.';

  @override
  String get kit2_selectPlaceholder => 'Seç';

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

  @override
  String lessons_cardsKnown(int known, int total) {
    return '$known / $total kart biliniyor';
  }

  @override
  String lessons_missingCount(String count) {
    return '$count eksik';
  }

  @override
  String get lessons_missingItem => 'Eksik';

  @override
  String get lessons_noMissing => 'eksik yok';

  @override
  String get lessons_onWeb => 'Web\'de';

  @override
  String get lessons_opensOnWeb => 'web\'de açılır';

  @override
  String lessons_tileMissingA11y(String name, String count) {
    return '$name, $count eksik';
  }

  @override
  String lessons_tileWebA11y(String name) {
    return '$name, web\'de açılır';
  }

  @override
  String lessons_topicRowA11y(int number, String name) {
    return '$number. $name';
  }

  @override
  String nav_a11yTabPosition(int position) {
    return 'sekme, 5\'te $position';
  }

  @override
  String get nav_back => 'Geri';

  @override
  String get nav_barLabel => 'Ana gezinme';

  @override
  String get nav_cameraA11y => 'Okut: deneme formunu kamerayla okut';

  @override
  String get nav_cameraLabel => 'Okut';

  @override
  String nav_contextStripA11y(String title, String detail) {
    return '$title, $detail';
  }

  @override
  String nav_contextStripTitle(String name) {
    return '$name verileri';
  }

  @override
  String get nav_homeCoachNoStudents => 'Henüz öğrencin yok';

  @override
  String nav_homeCoachStudents(String students) {
    return '$students öğrenci';
  }

  @override
  String nav_homeCoachSummary(String students, String meetings) {
    return '$students öğrenci · önümüzdeki 7 günde $meetings görüşme';
  }

  @override
  String nav_homeCounterA11y(String days, String date) {
    return 'YKS\'ye $days gün kaldı. Sınav $date.';
  }

  @override
  String nav_homeCounterCompact(String days) {
    return 'YKS\'ye $days gün';
  }

  @override
  String nav_homeCounterExam(String date) {
    return 'YKS · $date';
  }

  @override
  String get nav_homeCounterUnit => 'gün kaldı';

  @override
  String nav_homeGreeting(String name) {
    return 'Merhaba, $name';
  }

  @override
  String get nav_tabAccount => 'Hesap';

  @override
  String get nav_tabAnalytics => 'Analizlerim';

  @override
  String get nav_tabHome => 'Anasayfa';

  @override
  String get nav_tabLessons => 'Derslerim';

  @override
  String get nav_tabMeetings => 'Görüşmelerim';

  @override
  String get nav_tabStudents => 'Öğrencilerim';

  @override
  String schedule_changeTimeA11y(String time) {
    return 'Saat $time, değiştir';
  }

  @override
  String schedule_removeA11y(String topic) {
    return '$topic, programdan çıkar';
  }

  @override
  String get startup_appIconLabel => 'SMAP uygulama ikonu';

  @override
  String get startup_bootFailedTitle => 'SMAP açılamadı';

  @override
  String get startup_forceUpdateAction => 'Güncelle';

  @override
  String get startup_forceUpdateBody =>
      'Bu sürüm artık desteklenmiyor. Devam etmek için SMAP\'i güncelle; verilerin hesabında duruyor.';

  @override
  String get startup_forceUpdateTitle => 'Yeni sürüm gerekli';

  @override
  String get startup_loadingLabel => 'SMAP açılıyor';

  @override
  String get startup_maintenanceBody =>
      'Kısa süre içinde geri döneceğiz. Verilerin güvende; bakım bitince kaldığın yerden devam edersin.';

  @override
  String get startup_maintenanceTitle => 'SMAP şu an bakımda';

  @override
  String get startup_registerSignInFailed =>
      'Hesabın açıldı ama giriş yapılamadı. Giriş ekranından giriş yaparak devam et.';

  @override
  String get startup_sessionExpiredAction => 'Giriş Yap';

  @override
  String get startup_sessionExpiredBody =>
      'Güvenliğin için yeniden giriş yapman gerekiyor. Okuttuğun denemeler hesabında duruyor.';

  @override
  String get startup_sessionExpiredTitle => 'Oturumun sona erdi';

  @override
  String get startup_unknownRoleBody =>
      'Hesap türün tanınmadı. Çıkış yapıp yeniden giriş yapmayı dene; sorun sürerse bize yaz.';

  @override
  String get startup_unknownRoleContact => 'Destek\'e Yaz';

  @override
  String get startup_unknownRoleReLogin => 'Yeniden Giriş Yap';

  @override
  String get startup_unknownRoleTitle => 'Hesabın açılamadı';
}
