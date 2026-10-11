// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get analytics_boxAverageNet => 'Ortalama net';

  @override
  String get analytics_boxAveragePoint => 'Ortalama puan';

  @override
  String get analytics_boxAverageRank => 'Ortalama sıralama';

  @override
  String get analytics_boxExams => 'Çözülen deneme';

  @override
  String get analytics_dateAcademicYear => 'Bu eğitim yılı';

  @override
  String get analytics_dateAll => 'Tüm tarihler';

  @override
  String get analytics_dateLast30Days => 'Son 30 gün';

  @override
  String get analytics_dateLast3Months => 'Son 3 ay';

  @override
  String get analytics_deltaSuffix => 'son denemede';

  @override
  String get analytics_emptyAction => 'İlk Denemeni Okut';

  @override
  String get analytics_emptyMessage =>
      'İlk denemeni okuttuğunda sonuçların, netin ve eksik konuların burada görünür.';

  @override
  String get analytics_emptyTitle => 'Henüz deneme yok';

  @override
  String get analytics_errorMessage => 'Bağlantını kontrol edip tekrar dene.';

  @override
  String get analytics_errorTitle => 'Analizlerin yüklenemedi';

  @override
  String analytics_examCount(int count) {
    return '$count deneme';
  }

  @override
  String analytics_examUntitled(String type) {
    return '$type denemesi';
  }

  @override
  String get analytics_examsErrorTitle => 'Denemelerin yüklenemedi';

  @override
  String get analytics_fieldEqualWeight => 'Eşit Ağırlık';

  @override
  String get analytics_fieldNumeric => 'Sayısal';

  @override
  String get analytics_fieldVerbal => 'Sözel';

  @override
  String analytics_filterA11y(String label) {
    return 'Süzgeç: $label';
  }

  @override
  String get analytics_filterEmpty => 'Bu süzgeçte gösterilecek deneme yok.';

  @override
  String get analytics_filterGeneral => 'Genel';

  @override
  String analytics_filterLabel(String exam, String scope) {
    return '$exam · $scope';
  }

  @override
  String get analytics_filterReset => 'Süzgeci Sıfırla';

  @override
  String get analytics_loadingMoreA11y => 'Daha fazla deneme yükleniyor';

  @override
  String get analytics_moreError => 'Denemeler yüklenemedi.';

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
  String get analytics_sheetApply => 'Uygula';

  @override
  String get analytics_sheetDate => 'Tarih';

  @override
  String get analytics_sheetExam => 'Sınav';

  @override
  String get analytics_sheetExamA11y => 'Sınav türü';

  @override
  String get analytics_sheetField => 'Alan';

  @override
  String get analytics_sheetFieldA11y => 'Alan';

  @override
  String get analytics_sheetFieldHelp =>
      'Ders listesi alanına göre değişir. Profildeki alanın seçili gelir.';

  @override
  String get analytics_sheetFilterTitle => 'Süzgeç';

  @override
  String get analytics_sheetLesson => 'Ders';

  @override
  String get analytics_sheetSortTitle => 'Süz ve Sırala';

  @override
  String analytics_singleNameDate(String name, String date) {
    return '$name · $date';
  }

  @override
  String get analytics_singleNote =>
      'İkinci denemenden sonra gelişim grafiğin burada çizilir.';

  @override
  String get analytics_singleTitle => 'İlk denemen';

  @override
  String get analytics_sortAction => 'Süz ve Sırala';

  @override
  String analytics_summaryLine(String date) {
    return '$date · En yeni önce';
  }

  @override
  String get analytics_tabExams => 'Denemelerim';

  @override
  String get analytics_tabGeneral => 'Genel';

  @override
  String get analytics_tabsA11y => 'Analizlerim bölümleri';

  @override
  String get analytics_title => 'Analizlerim';

  @override
  String get analytics_typeA11y => 'Sınav türü';

  @override
  String get analytics_typeAll => 'Tümü';

  @override
  String cardSheet_confirmBody(String name) {
    return '\"$name\" eksiklerinden çıkıp Bildiklerim\'e geçecek.';
  }

  @override
  String get cardSheet_confirmTitle => 'Kartı Bildiklerim\'e taşıyalım mı?';

  @override
  String cardSheet_context(String lesson, String topic) {
    return '$lesson · $topic';
  }

  @override
  String get cardSheet_dontAsk => 'Bir daha sorma';

  @override
  String get cardSheet_learned => 'Öğrendim';

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
  String get forgotPassword_changeEmail => 'E-postayı Değiştir';

  @override
  String forgotPassword_codeBody(String email) {
    return 'Kodu $email adresine gönderdik. Gelen kutunda yoksa istenmeyen klasörüne bak.';
  }

  @override
  String get forgotPassword_codeLabel => 'Doğrulama kodu';

  @override
  String get forgotPassword_codeTitle => 'Kodu gir';

  @override
  String get forgotPassword_doneAction => 'Giriş Yap';

  @override
  String get forgotPassword_doneBody => 'Yeni şifrenle giriş yapabilirsin.';

  @override
  String get forgotPassword_doneTitle => 'Şifren güncellendi';

  @override
  String get forgotPassword_emailBody =>
      'Hesabındaki e-posta adresini yaz; 6 haneli bir kod gönderelim.';

  @override
  String get forgotPassword_emailLabel => 'E-posta';

  @override
  String get forgotPassword_emailTitle => 'Şifreni sıfırla';

  @override
  String get forgotPassword_errCode =>
      'Kod hatalı ya da süresi dolmuş. Yeni kod iste.';

  @override
  String get forgotPassword_errEmailFormat =>
      'E-posta adresi eksik görünüyor. Örn: ad@alan.com';

  @override
  String get forgotPassword_errMismatch => 'Şifreler aynı değil.';

  @override
  String get forgotPassword_errSendFailed =>
      'Gönderilemedi. Bağlantını kontrol edip tekrar dene.';

  @override
  String get forgotPassword_errTooMany =>
      'Çok fazla deneme yaptın. 10 dakika sonra tekrar dene.';

  @override
  String get forgotPassword_newPasswordLabel => 'Yeni şifre';

  @override
  String get forgotPassword_newPasswordRepeatLabel => 'Yeni şifre (tekrar)';

  @override
  String get forgotPassword_newTitle => 'Yeni şifreni belirle';

  @override
  String get forgotPassword_passwordRule => 'En az 8 karakter.';

  @override
  String get forgotPassword_resend => 'Kodu Tekrar Gönder';

  @override
  String forgotPassword_resendIn(String time) {
    return 'Kodu Tekrar Gönder ($time)';
  }

  @override
  String get forgotPassword_sendCode => 'Kod Gönder';

  @override
  String get forgotPassword_update => 'Şifreyi Güncelle';

  @override
  String home_examNameFallback(String type) {
    return '$type denemesi';
  }

  @override
  String get home_lastExam => 'Son denemen';

  @override
  String get home_lastExamError => 'Son deneme yüklenemedi.';

  @override
  String get home_literatureName => 'Türk Dili ve Edebiyatı';

  @override
  String home_mostMissedSentence(String topic, String total, String wrong) {
    return '$topic $total sorudan $wrong kaçırdın.';
  }

  @override
  String get home_myProgram => 'Programım';

  @override
  String get home_noProgram =>
      'Haftalık programın yok. Bir hafta kurduğunda günün konuları burada görünür.';

  @override
  String get home_setupProgram => 'Haftalık Programını Kur';

  @override
  String get home_subjects => 'Derslerin';

  @override
  String get home_subjectsError => 'Dersler yüklenemedi.';

  @override
  String get home_subjectsSub => 'Eksiği en çok olandan başlar';

  @override
  String get home_today => 'Bugün';

  @override
  String home_todayDate(String weekday, String day, String month) {
    return '$weekday, $day $month';
  }

  @override
  String get home_todayError => 'Bugünün programı yüklenemedi.';

  @override
  String home_todaySub(String date, String program) {
    return '$date · $program';
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
  String get lessonDetail_cards => 'Kartlarım';

  @override
  String lessonDetail_cardsProgress(String known, String total) {
    return 'Kartlarım · $known/$total';
  }

  @override
  String get lessonDetail_errorTitle => 'Konular yüklenemedi';

  @override
  String get lessonDetail_filterEmptyAction => 'Süzgeci Kapat';

  @override
  String lessonDetail_filterEmptyBody(String segment) {
    return '$segment\'de eksik konun yok. Tüm $segment konularını görmek için süzgeci kapat.';
  }

  @override
  String get lessonDetail_filterEmptyBodyAll =>
      'Eksik konun yok. Tüm konuları görmek için süzgeci kapat.';

  @override
  String get lessonDetail_filterEmptyTitle =>
      'Bu süzgeçte gösterilecek konu yok';

  @override
  String get lessonDetail_filterNote =>
      'Yalnız eksiği olan konular. Numaralar tam listedeki sırayı korur.';

  @override
  String lessonDetail_missingFilter(String count) {
    return 'Eksiklerim ($count)';
  }

  @override
  String get lessonDetail_noTopics => 'Bu dersin konuları hazırlanıyor.';

  @override
  String get lessonDetail_sectionAuthors => 'Yazar ve Eserler';

  @override
  String get lessonDetail_sectionTopics => 'Konular';

  @override
  String get lessonDetail_segmentAll => 'Tümü';

  @override
  String lessons_cardsKnown(int known, int total) {
    return '$known / $total kart biliniyor';
  }

  @override
  String get lessons_exampleLabel => 'Örnek';

  @override
  String get lessons_literatureName => 'Türk Dili ve Edebiyatı';

  @override
  String get lessons_loadErrorMessage => 'Bağlantını kontrol edip tekrar dene.';

  @override
  String get lessons_loadErrorTitle => 'Dersler yüklenemedi';

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
  String get lessons_sendFailed =>
      'Gönderilemedi. Bağlantını kontrol edip tekrar dene.';

  @override
  String lessons_sos2Name(String name) {
    return '$name-2';
  }

  @override
  String get lessons_testSocialSciences1 =>
      'Türk Dili ve Edebiyatı–Sosyal Bilimler 1 testi';

  @override
  String get lessons_testSocialSciences2 => 'Sosyal Bilimler 2 testi';

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
  String lessons_webSheetBody(String host) {
    return 'Matematik ve Geometri kavram haritan şimdilik $host\'da.';
  }

  @override
  String get lessons_webSheetOpen => 'Web\'de Aç';

  @override
  String get lessons_webSheetTitle => 'Kavram haritan web\'de';

  @override
  String get literature_about => 'Hakkında';

  @override
  String literature_authorA11y(String name, String era) {
    return '$name, $era';
  }

  @override
  String get literature_empty => 'Yazar listesi hazırlanıyor.';

  @override
  String get literature_errorTitle => 'Yazarlar yüklenemedi';

  @override
  String get literature_learned => 'Öğrendim';

  @override
  String get literature_otherType => 'Diğer';

  @override
  String literature_workMissingA11y(String title) {
    return '$title, eksik';
  }

  @override
  String get literature_works => 'Eserleri';

  @override
  String get login_apple => 'Apple ile Devam Et';

  @override
  String get login_errorInvalid =>
      'Kullanıcı adı ya da şifre hatalı. Tekrar dene ya da şifreni sıfırla.';

  @override
  String get login_errorInvalidNoReset =>
      'Kullanıcı adı ya da şifre hatalı. Tekrar dene.';

  @override
  String get login_errorNetwork =>
      'Bağlanamadık. Bağlantını kontrol edip tekrar dene.';

  @override
  String get login_forgot => 'Şifremi Unuttum';

  @override
  String get login_google => 'Google ile Devam Et';

  @override
  String get login_noAccount => 'Hesabın yok mu?';

  @override
  String get login_orUsername => 'ya da kullanıcı adınla';

  @override
  String get login_passwordLabel => 'Şifre';

  @override
  String get login_register => 'Kayıt Ol';

  @override
  String get login_submit => 'Giriş Yap';

  @override
  String get login_submitting => 'Giriş yapılıyor';

  @override
  String get login_title => 'Giriş yap';

  @override
  String get login_usernameLabel => 'Kullanıcı adı';

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
  String get onboarding_cameraAllow => 'Kameraya İzin Ver';

  @override
  String get onboarding_cameraBody =>
      'SMAP kamerayı yalnız optik formunu çekerken kullanır. Bir sonraki adımda telefonun izin isteyecek.';

  @override
  String get onboarding_cameraButtonA11y => 'Kamera düğmesi';

  @override
  String get onboarding_cameraDeniedBody =>
      'Formunu okutabilmek için Ayarlar\'da SMAP\'e kamera izni ver. Sonra buraya dön; kaldığın yerden devam edersin.';

  @override
  String get onboarding_cameraDeniedTitle => 'Kamera izni kapalı';

  @override
  String get onboarding_cameraLater => 'Sonra';

  @override
  String get onboarding_cameraTitle => 'Formunu okutmak için kamera gerekli';

  @override
  String onboarding_gradeA11y(String grade) {
    return '$grade. sınıf';
  }

  @override
  String get onboarding_gradeGraduate => 'Mezun';

  @override
  String get onboarding_gradeGroupA11y => 'Sınıf';

  @override
  String get onboarding_gradeNoFieldInfo =>
      '9. ve 10. sınıfta alan seçilmez; 11. sınıfa geçince Hesap\'tan eklersin.';

  @override
  String get onboarding_gradeTitle => 'Kaçıncı sınıftasın?';

  @override
  String get onboarding_intro1Body =>
      'Deneme bitince formunun fotoğrafını çek; cevapların sayılır, netin hesaplanır.';

  @override
  String get onboarding_intro1Title => 'Optik formunu kamerayla okut';

  @override
  String get onboarding_intro2Body =>
      'Her denemenin neti, doğru-yanlış dağılımı ve önceki denemene göre farkı tek ekranda.';

  @override
  String get onboarding_intro2Title => 'Netini ve gelişimini gör';

  @override
  String get onboarding_intro3Body =>
      'Kaçırdığın konular eksik listene girer; konu anlatımı ve bilgi kartlarıyla tamamlarsın.';

  @override
  String get onboarding_intro3Title => 'Eksiklerini konu konu kapat';

  @override
  String get onboarding_openSettings => 'Ayarları Aç';

  @override
  String get onboarding_roleCoach => 'Öğrenci Koçuyum';

  @override
  String get onboarding_roleCoachDesc =>
      'Öğrencilerinin gelişimini izle, görüşmelerini planla.';

  @override
  String get onboarding_roleGroupA11y => 'Rol';

  @override
  String get onboarding_roleStudent => 'Öğrenciyim';

  @override
  String get onboarding_roleStudentDesc =>
      'Denemelerini okut, eksiklerini kapat.';

  @override
  String get onboarding_roleSubtitle => 'Ekranların buna göre hazırlanır.';

  @override
  String get onboarding_roleTitle => 'SMAP\'i nasıl kullanacaksın?';

  @override
  String get onboarding_sampleCardAction => 'Öğrendim';

  @override
  String get onboarding_sampleCardBody =>
      'Haçlılarla Osmanlı Devleti\'nin imzaladığı ilk antlaşma.';

  @override
  String get onboarding_sampleCardKicker => 'Tarih · bilgi kartı';

  @override
  String get onboarding_sampleCardTitle => 'Edirne-Segedin Antlaşması (1444)';

  @override
  String get onboarding_sampleChartA11y =>
      'AYT net grafiği: 8 Mayıs 48,5 netten 5 Ekim 67,5 nete';

  @override
  String get onboarding_sampleExamTitle => 'AYT · Türkiye Geneli Deneme 6';

  @override
  String get onboarding_sampleSubjectName => 'Türkçe';

  @override
  String get onboarding_sampleTopic1 => 'Fiilde Çatı';

  @override
  String get onboarding_sampleTopic2 => 'Noktalama İşaretleri';

  @override
  String get onboarding_sampleTopic3 => 'Cümlenin Öğeleri';

  @override
  String get onboarding_scanVisualA11y =>
      'Optik form fotoğrafı: form bulundu, köşeler turuncu tutamaçlarla işaretli, altta kamera düğmesi';

  @override
  String get onboarding_skip => 'Geç';

  @override
  String get onboarding_start => 'Başla';

  @override
  String get onboarding_trackDil => 'Dil';

  @override
  String get onboarding_trackEsitAgirlik => 'Eşit Ağırlık';

  @override
  String get onboarding_trackGroupA11y => 'Alan';

  @override
  String get onboarding_trackRequired => 'Alanını seç.';

  @override
  String get onboarding_trackSayisal => 'Sayısal';

  @override
  String get onboarding_trackSozel => 'Sözel';

  @override
  String get onboarding_trackTitle => 'Alanın';

  @override
  String get onboarding_welcomeBody =>
      'Hesabın varsa giriş yap; yoksa birkaç adımda kaydol. Seçtiklerin kayıt formuna gelir.';

  @override
  String get onboarding_welcomeLogin => 'Giriş Yap';

  @override
  String get onboarding_welcomeRegister => 'Kayıt Ol';

  @override
  String get onboarding_welcomeTitle => 'SMAP\'e hoş geldin';

  @override
  String pickers_a11yDayChip(String weekday, String day, String month) {
    return '$weekday $day $month';
  }

  @override
  String get pickers_a11ySelected => 'seçili';

  @override
  String get pickers_a11yToday => 'bugün';

  @override
  String pickers_monthTitle(String month, String year) {
    return '$month $year';
  }

  @override
  String get pickers_nextMonth => 'Sonraki ay';

  @override
  String get pickers_prevMonth => 'Önceki ay';

  @override
  String get pickers_today => 'Bugün';

  @override
  String get register_avatarLabel => 'Avatarın';

  @override
  String get register_avatarPickerA11y => 'Avatar seçimi';

  @override
  String get register_coachCodeInfo =>
      'Kaydın tamamlanınca koçluk kodun oluşur. Öğrencilerin bu kodla sana bağlanır; kodun Hesap › Koçluk\'ta durur.';

  @override
  String get register_consentKvkk => 'KVKK Aydınlatma Metni';

  @override
  String get register_consentRequired =>
      'Kaydolmak için metinleri onaylaman gerekiyor.';

  @override
  String get register_consentTerms => 'Kullanım Koşulları';

  @override
  String register_consentText(String terms, String kvkk) {
    return '$terms\'nı ve $kvkk\'ni okudum, kabul ediyorum.';
  }

  @override
  String get register_fieldEmail => 'E-posta';

  @override
  String get register_fieldFullName => 'Ad Soyad';

  @override
  String get register_fieldGrade => 'Sınıf';

  @override
  String get register_fieldPassword => 'Şifre';

  @override
  String get register_fieldPasswordRepeat => 'Şifre (tekrar)';

  @override
  String get register_fieldTrack => 'Alan';

  @override
  String get register_fieldUsername => 'Kullanıcı adı';

  @override
  String get register_gradeGraduate => 'Mezun';

  @override
  String register_gradeValue(int grade) {
    return '$grade. Sınıf';
  }

  @override
  String get register_hasAccount => 'Hesabın var mı?';

  @override
  String get register_issueEmailInvalid =>
      'E-posta adresi eksik görünüyor. Örn: ad@alan.com';

  @override
  String get register_issueFullNameMissing => 'Adını ve soyadını yaz.';

  @override
  String get register_issueGradeMissing => 'Sınıfını seç.';

  @override
  String get register_issuePasswordMismatch => 'Şifreler aynı değil.';

  @override
  String get register_issuePasswordTooShort =>
      'Şifren en az 8 karakter olmalı.';

  @override
  String get register_issueTrackMissing => 'Alanını seç.';

  @override
  String get register_issueUsernameMissing => 'Bir kullanıcı adı yaz.';

  @override
  String get register_legalEmpty => 'Bu metin şu an gösterilemiyor.';

  @override
  String get register_legalLoadFailed =>
      'Sözleşme metinleri yüklenemedi. Kaydolmak için metinleri görebilmen gerekiyor.';

  @override
  String get register_legalLoading => 'Sözleşme metinleri yükleniyor';

  @override
  String get register_legalRegisterLocked =>
      'Metinler yüklenince kayıt açılır.';

  @override
  String register_legalVersion(String version) {
    return 'Sürüm $version';
  }

  @override
  String get register_loginLink => 'Giriş Yap';

  @override
  String get register_passwordHint => 'En az 8 karakter.';

  @override
  String get register_roleCoach => 'Öğrenci Koçu';

  @override
  String get register_roleStudent => 'Öğrenci';

  @override
  String get register_signInFailed =>
      'Hesabın oluşturuldu ama giriş yapılamadı. Kullanıcı adın ve şifrenle giriş yapabilirsin.';

  @override
  String get register_signInFailedAction => 'Giriş Yap';

  @override
  String get register_submit => 'Kayıt Ol';

  @override
  String get register_submitFailed =>
      'Kaydın tamamlanamadı. Bağlantını kontrol edip tekrar dene.';

  @override
  String get register_title => 'Kayıt ol';

  @override
  String get register_trackDil => 'Dil';

  @override
  String get register_trackEsitAgirlik => 'Eşit Ağırlık';

  @override
  String get register_trackNotSelectable => 'Seçilmez';

  @override
  String get register_trackNotSelectableReason =>
      '9. ve 10. sınıfta alan seçilmez.';

  @override
  String get register_trackSayisal => 'Sayısal';

  @override
  String get register_trackSozel => 'Sözel';

  @override
  String get register_usernameFree => 'Bu kullanıcı adı boşta.';

  @override
  String get register_usernameOffline => 'Bağlanınca kontrol edilecek.';

  @override
  String get register_usernameSuggest => 'Boşta olan:';

  @override
  String register_usernameSuggestA11y(String name) {
    return 'Boşta olan kullanıcı adı: $name. Yazmak için dokun.';
  }

  @override
  String get register_usernameTaken => 'Bu kullanıcı adı alınmış.';

  @override
  String get schedule_add => 'Ekle';

  @override
  String get schedule_addTopic => 'Konu Ekle';

  @override
  String get schedule_bagEmpty =>
      'Çantanda henüz konu yok. Denemelerinden çıkan eksik konular burada görünür.';

  @override
  String get schedule_bagHelp =>
      'Çantam: denemelerinden çıkan eksik konuların.';

  @override
  String get schedule_cancelProgram => 'Programı İptal Et';

  @override
  String get schedule_cancelProgramBody =>
      'Program listeden kalkar ve Anasayfa\'daki Bugün bölümü boşalır. Bu işlem geri alınamaz.';

  @override
  String schedule_cancelProgramTitle(String name) {
    return '$name iptal edilsin mi?';
  }

  @override
  String schedule_changeTimeA11y(String time) {
    return 'Saat $time, değiştir';
  }

  @override
  String get schedule_changeTimeTitle => 'Saati Değiştir';

  @override
  String get schedule_clearSearch => 'Aramayı Temizle';

  @override
  String get schedule_closeA11y => 'Vazgeç';

  @override
  String schedule_dayChipTopics(String count) {
    return '$count konu';
  }

  @override
  String schedule_dayTitle(String weekday, String day, String month) {
    return '$weekday, $day $month';
  }

  @override
  String get schedule_daysBody =>
      'Birden çok gün seçebilirsin; geçmiş günler seçilemez.';

  @override
  String schedule_daysSelected(String count) {
    return '$count gün seçildi';
  }

  @override
  String get schedule_daysTitle => 'Hangi günler çalışacaksın?';

  @override
  String schedule_defaultName(String month, String week) {
    return '$month $week. Hafta';
  }

  @override
  String get schedule_discardBody =>
      'Seçtiğin günler ve yerleştirdiğin konular kaybolur.';

  @override
  String get schedule_discardConfirm => 'Kaydetmeden Çık';

  @override
  String get schedule_discardTitle => 'Program kaydedilmesin mi?';

  @override
  String get schedule_done => 'Bitti';

  @override
  String get schedule_edit => 'Düzenle';

  @override
  String get schedule_emptyAction => 'Haftalık Programını Kur';

  @override
  String get schedule_emptyBody =>
      'Haftalık programını kurduğunda günün konuları burada ve Anasayfa\'da görünür.';

  @override
  String get schedule_emptyDay => 'Bu gün için çalışma yok.';

  @override
  String schedule_emptySlotA11y(String time) {
    return '$time, boş, konu ekle';
  }

  @override
  String get schedule_emptyTitle => 'Henüz programın yok';

  @override
  String get schedule_fieldMotto => 'Motto';

  @override
  String get schedule_fieldName => 'Program adı';

  @override
  String schedule_filledSlotA11y(String time, String lesson, String topic) {
    return '$time, $lesson, $topic';
  }

  @override
  String get schedule_gridBody =>
      'Boş bir saate dokun, konu seç. Izgara 06:00–23:00.';

  @override
  String get schedule_gridTitle => 'Konuları yerleştir';

  @override
  String schedule_inProgramAt(String day, String time) {
    return 'Programda: $day $time';
  }

  @override
  String get schedule_loadError => 'Programların yüklenemedi';

  @override
  String get schedule_loadErrorBody => 'Bağlantını kontrol edip tekrar dene.';

  @override
  String get schedule_mottoHelp => 'Program listesinde adın altında görünür.';

  @override
  String get schedule_nameRequired => 'Programına bir ad ver.';

  @override
  String get schedule_nameTitle => 'Programına ad ver';

  @override
  String get schedule_new => 'Yeni Program';

  @override
  String get schedule_offlineNote =>
      'Program kurmak ve düzenlemek için bağlantı gerekiyor. Kayıtlı programını görebilirsin.';

  @override
  String schedule_programRowA11y(String name, String motto, String range) {
    return '$name, $motto, $range';
  }

  @override
  String schedule_removeA11y(String topic) {
    return '$topic, programdan çıkar';
  }

  @override
  String schedule_removeSlotA11y(String topic) {
    return '$topic, çıkar';
  }

  @override
  String get schedule_resetDay => 'Günü Sıfırla';

  @override
  String schedule_resetDayBody(String date, String count) {
    return '$date $count çalışma programdan çıkar. Diğer günler değişmez.';
  }

  @override
  String schedule_resetDayTitle(String weekday) {
    return '$weekday sıfırlayalım mı?';
  }

  @override
  String get schedule_saveFailed =>
      'Kaydedilemedi. Bağlantını kontrol edip tekrar dene.';

  @override
  String get schedule_saveProgram => 'Programı Kaydet';

  @override
  String get schedule_searchHelp =>
      'Program adında ve mottosunda arar; büyük-küçük harf ve I/ı farkı gözetmez.';

  @override
  String get schedule_searchHint => 'Program ara';

  @override
  String schedule_searchNoMatch(String query) {
    return '“$query” ile eşleşen program yok';
  }

  @override
  String get schedule_srcBag => 'Çantam';

  @override
  String get schedule_srcLessons => 'Dersler';

  @override
  String schedule_stepOf(String step) {
    return 'Adım $step/3';
  }

  @override
  String schedule_studyCount(String count) {
    return '$count çalışma';
  }

  @override
  String get schedule_summaryDays => 'Günler';

  @override
  String schedule_summaryDaysValue(String range, String count) {
    return '$range · $count gün';
  }

  @override
  String schedule_summaryEmptyDays(String days) {
    return '$days henüz boş; kaydettikten sonra ekleyebilirsin.';
  }

  @override
  String get schedule_summaryStudies => 'Çalışmalar';

  @override
  String schedule_summaryStudiesOneDay(String count, String day) {
    return '$count çalışma, hepsi $day';
  }

  @override
  String schedule_summaryStudiesSpread(String count, String days) {
    return '$count çalışma, $days güne dağılmış';
  }

  @override
  String get schedule_thisWeek => 'Bu hafta';

  @override
  String get schedule_title => 'Programım';

  @override
  String schedule_toastDayReset(String weekday) {
    return '$weekday sıfırlandı.';
  }

  @override
  String get schedule_toastProgramCancelled => 'Program iptal edildi.';

  @override
  String get schedule_toastProgramSaved => 'Program kaydedildi.';

  @override
  String get schedule_toastTopicRemoved => 'Konu çıkarıldı.';

  @override
  String schedule_topicRowA11y(String topic, String lesson) {
    return '$topic, $lesson';
  }

  @override
  String get schedule_topicSheetA11y => 'Konu ekle';

  @override
  String schedule_topicSheetTitle(
    String weekday,
    String day,
    String month,
    String time,
  ) {
    return '$weekday $day $month · $time';
  }

  @override
  String get schedule_topicsLoadError => 'Konular yüklenemedi';

  @override
  String get schedule_viewDay => 'Gün';

  @override
  String get schedule_viewLabel => 'Görünüm';

  @override
  String get schedule_viewWeek => 'Hafta';

  @override
  String schedule_weekBlockA11y(
    String day,
    String time,
    String lesson,
    String topic,
  ) {
    return '$day $time, $lesson, $topic';
  }

  @override
  String schedule_weekGridA11y(String range) {
    return 'Haftalık program, $range';
  }

  @override
  String schedule_weekGridHiddenLeft(String days) {
    return '$days solda';
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

  @override
  String topicDetail_context(String lesson, int number) {
    return '$lesson · $number. konu';
  }

  @override
  String topicDetail_contextTrack(String lesson, String track, int number) {
    return '$lesson · $track · $number. konu';
  }

  @override
  String topicDetail_counts(String subTopics, String items) {
    return '$subTopics alt başlık · $items madde';
  }

  @override
  String get topicDetail_empty => 'Bu konunun içeriği hazırlanıyor.';

  @override
  String get topicDetail_errorTitle => 'Konu yüklenemedi';

  @override
  String topicDetail_itemCount(String count) {
    return '$count madde';
  }

  @override
  String get topicDetail_openCard => 'Kartı Aç';
}
