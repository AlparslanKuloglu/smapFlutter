// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get accountSettings_loadErrorMessage =>
      'Bağlantını kontrol edip tekrar dene. Sorun sürerse biraz sonra yeniden açabilirsin.';

  @override
  String get accountSettings_sendFailed =>
      'Gönderilemedi. Bağlantını kontrol edip tekrar dene.';

  @override
  String account_a11yCoachCode(String code) {
    return 'koçluk kodu $code';
  }

  @override
  String account_a11yCoachOf(String name) {
    return 'koçun $name';
  }

  @override
  String get account_a11yCoachRole => 'öğrenci koçu';

  @override
  String get account_a11yOpensProfile => 'Profili açar';

  @override
  String account_a11yProfile(String details) {
    return 'Profil: $details';
  }

  @override
  String get account_avatarSelected => 'seçili';

  @override
  String get account_avatarTitle => 'Avatarını seç';

  @override
  String get account_avatarUse => 'Bu Avatarı Kullan';

  @override
  String get account_coachCodeCopied => 'Kod kopyalandı.';

  @override
  String get account_coachCodeCopy => 'Kodu kopyala';

  @override
  String get account_coachCodeShare => 'Kodu paylaş';

  @override
  String account_coachCodeShareText(String code) {
    return 'SMAP\'te koçluk kodum: $code';
  }

  @override
  String get account_coachCodeTitle => 'Koçluk kodun';

  @override
  String get account_contractKvkk => 'KVKK Aydınlatma Metni';

  @override
  String get account_contractPrivacy => 'Gizlilik Politikası';

  @override
  String get account_contractTerms => 'Kullanım Koşulları';

  @override
  String account_contractVersion(String version) {
    return 'Sürüm $version';
  }

  @override
  String get account_contractsEmptyMessage =>
      'Gösterilecek bir sözleşme metni bulunamadı.';

  @override
  String get account_contractsEmptyTitle => 'Sözleşme yok';

  @override
  String get account_contractsErrorTitle => 'Sözleşmeler yüklenemedi';

  @override
  String get account_contractsFooter =>
      'Kayıt olurken bu sürümleri onayladın. Bir metin değişirse uygulama açılışında yeni sürümü onaylaman istenir.';

  @override
  String get account_contractsTitle => 'Sözleşmeler';

  @override
  String get account_discardBody => 'Yaptığın değişiklikler silinecek.';

  @override
  String get account_discardConfirm => 'Kaydetmeden Çık';

  @override
  String get account_discardTitle => 'Değişiklikler kaydedilmesin mi?';

  @override
  String get account_fieldEmail => 'E-posta';

  @override
  String get account_fieldGrade => 'Sınıf';

  @override
  String get account_fieldName => 'Ad Soyad';

  @override
  String get account_fieldPhone => 'Telefon';

  @override
  String get account_fieldTrack => 'Alan';

  @override
  String get account_fieldUserName => 'Kullanıcı adı';

  @override
  String get account_gradeGraduate => 'Mezun';

  @override
  String get account_gradeNote =>
      '9. ya da 10. sınıfı seçersen alan kaldırılır.';

  @override
  String account_gradeValue(int grade) {
    return '$grade. Sınıf';
  }

  @override
  String get account_groupAccount => 'Hesap';

  @override
  String get account_groupCoaching => 'Koçluk';

  @override
  String get account_groupLegal => 'Yasal';

  @override
  String get account_groupNotifications => 'Bildirimler';

  @override
  String get account_groupSupport => 'Destek';

  @override
  String get account_issueEmailInvalid =>
      'E-posta adresi eksik görünüyor. Örn: ad@alan.com';

  @override
  String get account_issueNameMissing => 'Ad soyadını yaz.';

  @override
  String get account_issuePhoneInvalid =>
      'Telefon numaranı 5XX XXX XX XX biçiminde yaz.';

  @override
  String get account_loadErrorMessage => 'Bağlantını kontrol edip tekrar dene.';

  @override
  String get account_logoutConfirm => 'Çıkış Yap';

  @override
  String get account_logoutMessage =>
      'Tekrar girmek için kullanıcı adın ve şifren gerekecek. Okuttuğun denemeler hesabında kalır.';

  @override
  String account_logoutMessagePending(String count) {
    return 'Gönderilmeyi bekleyen $count form var; çıkarsan silinir.';
  }

  @override
  String get account_logoutTitle => 'Çıkış yapılsın mı?';

  @override
  String get account_phoneHint => '5XX XXX XX XX';

  @override
  String get account_profileChangeAvatar => 'Avatarı Değiştir';

  @override
  String get account_profileDelete => 'Hesabı Sil';

  @override
  String get account_profileEdit => 'Düzenle';

  @override
  String get account_profileErrorTitle => 'Profil açılamadı';

  @override
  String get account_profileSaveFailed =>
      'Kaydedilemedi. Bağlantını kontrol edip tekrar dene.';

  @override
  String get account_profileSaved => 'Profilin güncellendi.';

  @override
  String get account_profileTitle => 'Profil';

  @override
  String get account_readerEmpty => 'Bu metin şu an gösterilemiyor.';

  @override
  String get account_rowCoaching => 'Koçluk';

  @override
  String get account_rowCoachingNone => 'Koçunla bağlan';

  @override
  String get account_rowContracts => 'Sözleşmeler';

  @override
  String get account_rowContractsSub => 'Kullanım Koşulları, KVKK, Gizlilik';

  @override
  String get account_rowLogout => 'Çıkış Yap';

  @override
  String get account_rowNotifications => 'Bildirimler';

  @override
  String get account_rowNotificationsSub =>
      'Deneme sonucu, koç, görüşme, hatırlatıcı';

  @override
  String get account_rowPassword => 'Şifre';

  @override
  String get account_rowProfile => 'Profil';

  @override
  String get account_rowProfileCoachSub => 'Ad, e-posta ve telefon';

  @override
  String get account_rowProfileStudentSub =>
      'Ad, e-posta, telefon, sınıf ve alan';

  @override
  String get account_rowSupport => 'Bize Yaz';

  @override
  String get account_rowSupportSub => 'E-posta uygulaman açılır';

  @override
  String account_summaryCoach(String name) {
    return 'Koçun: $name';
  }

  @override
  String account_summaryCoachCode(String code) {
    return 'Koçluk kodun: $code';
  }

  @override
  String get account_summaryCoachRole => 'Öğrenci koçu';

  @override
  String account_summaryGradeTrack(String grade, String track) {
    return '$grade · $track';
  }

  @override
  String get account_supportMailFailed => 'E-posta uygulaması açılamadı.';

  @override
  String get account_supportMailSubject => 'SMAP · Destek';

  @override
  String account_supportMailSystem(String system) {
    return 'Sistem: $system';
  }

  @override
  String account_supportMailVersion(String version) {
    return 'Uygulama sürümü: $version';
  }

  @override
  String get account_title => 'Hesap';

  @override
  String get account_trackDil => 'Dil';

  @override
  String get account_trackDisabledHelper => '9. ve 10. sınıfta alan seçilmez.';

  @override
  String get account_trackDisabledValue => 'Seçilmez';

  @override
  String get account_trackEsitAgirlik => 'Eşit Ağırlık';

  @override
  String get account_trackSayisal => 'Sayısal';

  @override
  String get account_trackSozel => 'Sözel';

  @override
  String get account_userNameLocked => 'Kullanıcı adı değiştirilemez.';

  @override
  String account_version(String version, String build) {
    return 'Sürüm $version ($build)';
  }

  @override
  String get account_versionCopied => 'Sürüm kopyalandı.';

  @override
  String get account_versionCopyHint => 'Uzun basınca kopyalar';

  @override
  String account_versionNoBuild(String version) {
    return 'Sürüm $version';
  }

  @override
  String get addStudent_addedNote =>
      'Bu ekranı kapatınca şifre yeniden gösterilmez.';

  @override
  String get addStudent_addedSubtitle => 'Giriş bilgilerini öğrencine ilet.';

  @override
  String addStudent_addedTitle(String name) {
    return '$name eklendi';
  }

  @override
  String get addStudent_avatarLabel => 'Avatar';

  @override
  String get addStudent_avatarPickerA11y => 'Öğrencinin avatarı';

  @override
  String get addStudent_check => 'Kontrol Et';

  @override
  String get addStudent_codeHeading => 'Öğrencin kendi hesabıyla bağlansın';

  @override
  String addStudent_credentialsShareText(String userName, String password) {
    return 'SMAP giriş bilgilerin\nKullanıcı adı: $userName\nŞifre: $password';
  }

  @override
  String get addStudent_firstName => 'Ad';

  @override
  String get addStudent_generate => 'Oluştur';

  @override
  String get addStudent_grade => 'Sınıf';

  @override
  String get addStudent_issueFirstName => 'Öğrencinin adını yaz.';

  @override
  String get addStudent_issueGrade => 'Sınıfı seç.';

  @override
  String get addStudent_issueLastName => 'Öğrencinin soyadını yaz.';

  @override
  String get addStudent_issuePasswordMissing =>
      'Bir şifre yaz ya da Oluştur\'a dokun.';

  @override
  String get addStudent_issuePasswordShort => 'Şifre en az 8 karakter olmalı.';

  @override
  String get addStudent_issueTrack => 'Alanı seç.';

  @override
  String get addStudent_issueUsername => 'Bir kullanıcı adı yaz.';

  @override
  String get addStudent_lastName => 'Soyad';

  @override
  String get addStudent_or => 'ya da';

  @override
  String get addStudent_password => 'Şifre';

  @override
  String get addStudent_passwordHelp =>
      'Öğrencine ilet; ilk girişte değiştirmesi önerilir.';

  @override
  String get addStudent_save => 'Öğrenciyi Kaydet';

  @override
  String get addStudent_saveFailed =>
      'Öğrenci eklenemedi. Bağlantını kontrol edip tekrar dene.';

  @override
  String get addStudent_shareCredentials => 'Bilgileri Paylaş';

  @override
  String get addStudent_subtitle => 'Hesabını sen aç ya da kodunu paylaş.';

  @override
  String get addStudent_title => 'Öğrenci ekle';

  @override
  String get addStudent_track => 'Alan';

  @override
  String get addStudent_trackNotSelectable => 'Seçilmez';

  @override
  String get addStudent_trackNotSelectableReason =>
      '9. ve 10. sınıfta alan seçilmez.';

  @override
  String get addStudent_username => 'Kullanıcı adı';

  @override
  String get addStudent_usernameFree => 'Bu kullanıcı adı boşta.';

  @override
  String get addStudent_usernameOffline => 'Bağlanınca kontrol edilecek.';

  @override
  String get addStudent_usernameSuggest => 'Boşta olan:';

  @override
  String addStudent_usernameSuggestA11y(String name) {
    return 'Boşta olan kullanıcı adı: $name. Yazmak için dokun.';
  }

  @override
  String get addStudent_usernameTaken => 'Bu kullanıcı adı alınmış.';

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
  String cardDeck_count(String count) {
    return '$count kart';
  }

  @override
  String get cardDeck_countNone => 'kart yok';

  @override
  String get cardDeck_detail => 'Detay';

  @override
  String get cardDeck_errorMessage => 'Bağlantını kontrol edip tekrar dene.';

  @override
  String get cardDeck_errorTitle => 'Kartlar yüklenemedi';

  @override
  String get cardDeck_favoriteEmpty => 'Favoriye eklediğin kart yok.';

  @override
  String get cardDeck_goKnown => 'Bildiklerime Geç';

  @override
  String get cardDeck_groupFavorite => 'Favorilerim';

  @override
  String get cardDeck_groupKnown => 'Bildiklerim';

  @override
  String get cardDeck_groupMissing => 'Eksiklerim';

  @override
  String get cardDeck_knownEmpty => 'Henüz öğrendiğin kart yok.';

  @override
  String get cardDeck_learned => 'Öğrendim';

  @override
  String cardDeck_missingDoneMessage(String count) {
    return 'Bildiklerim\'deki $count kartı tekrar etmek istersen oradan devam edebilirsin.';
  }

  @override
  String get cardDeck_missingDoneTitle => 'Bu derste eksik kartın kalmadı.';

  @override
  String get cardDeck_missingDoneTitleExam =>
      'Bu denemede eksik kartın kalmadı.';

  @override
  String get cardDeck_moved => 'Kart Bildiklerim\'e taşındı.';

  @override
  String get cardDeck_nextA11y => 'Sonraki kart';

  @override
  String get cardDeck_noCardsMessage =>
      'Kartlar, denemelerde yanlış ve boş bıraktığın sorulardan eklenir.';

  @override
  String get cardDeck_noCardsTitle => 'Bu derste henüz kartın yok.';

  @override
  String get cardDeck_noCardsTitleExam => 'Bu denemeden kart eklenmedi.';

  @override
  String get cardDeck_previousA11y => 'Önceki kart';

  @override
  String cardDeck_progress(String current, String total) {
    return '$current/$total';
  }

  @override
  String cardDeck_progressA11y(String current, String total) {
    return 'Oturum, $total karttan $current. kart';
  }

  @override
  String get cardDeck_sendFailed =>
      'Gönderilemedi. Bağlantını kontrol edip tekrar dene.';

  @override
  String cardDeck_title(String lesson) {
    return '$lesson Kartları';
  }

  @override
  String get cardDeck_titleExam => 'Deneme Kartları';

  @override
  String get cardDeck_titleFallback => 'Bilgi Kartları';

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
  String get coachHome_addStudent => 'Öğrenci Ekle';

  @override
  String get coachHome_attention => 'Dikkat gerektirenler';

  @override
  String get coachHome_attentionEmptyBody =>
      '14 gündür deneme okutmayan ya da son iki denemesinde neti düşen öğrenci burada görünür.';

  @override
  String get coachHome_attentionEmptyTitle =>
      'Şu an dikkat gerektiren öğrenci yok.';

  @override
  String get coachHome_attentionError => 'Dikkat listesi yüklenemedi.';

  @override
  String get coachHome_emptyMessage =>
      'Öğrencin koçluk kodunla kendi hesabından bağlanabilir ya da hesabını sen açabilirsin.';

  @override
  String get coachHome_emptyTitle => 'İlk öğrencini ekle';

  @override
  String get coachHome_meetings => 'Yaklaşan görüşmeler';

  @override
  String get coachHome_meetingsError => 'Görüşmeler yüklenemedi.';

  @override
  String get coachHome_newMeeting => 'Yeni Görüşme';

  @override
  String get coachHome_noMeetings => 'Önümüzdeki 7 günde görüşme yok.';

  @override
  String get coachHome_students => 'Öğrencilerin';

  @override
  String get coachHome_studentsError => 'Öğrenciler yüklenemedi.';

  @override
  String get coachMeetings_a11yKindParent => 'veli görüşmesi';

  @override
  String get coachMeetings_a11yKindStudent => 'öğrenci görüşmesi';

  @override
  String get coachMeetings_clearSearch => 'Aramayı Temizle';

  @override
  String get coachMeetings_dateLabel => 'Tarih';

  @override
  String get coachMeetings_dateTitle => 'Tarih';

  @override
  String get coachMeetings_detailErrorTitle => 'Görüşme açılamadı';

  @override
  String get coachMeetings_detailKindParent => 'Veli görüşmesi';

  @override
  String get coachMeetings_detailKindStudent => 'Öğrenci görüşmesi';

  @override
  String get coachMeetings_detailMissingMessage =>
      'Bu görüşme silinmiş olabilir. Listeye dönüp yenileyebilirsin.';

  @override
  String get coachMeetings_detailMissingTitle => 'Görüşme bulunamadı';

  @override
  String get coachMeetings_emptyAction => 'Yeni Görüşme';

  @override
  String get coachMeetings_emptyMessage =>
      'Öğrencinle ya da velisiyle görüşme planladığında burada listelenir.';

  @override
  String get coachMeetings_emptyTitle => 'Henüz görüşme yok';

  @override
  String get coachMeetings_kindParent => 'Veli';

  @override
  String get coachMeetings_kindStudent => 'Öğrenci';

  @override
  String get coachMeetings_loadErrorMessage =>
      'Bağlantını kontrol edip tekrar dene. Sorun sürerse biraz sonra yeniden açabilirsin.';

  @override
  String get coachMeetings_loadErrorTitle => 'Görüşmelerin yüklenemedi';

  @override
  String get coachMeetings_loadingMore => 'Görüşmeler yükleniyor';

  @override
  String get coachMeetings_meetingFallback => 'Görüşme';

  @override
  String get coachMeetings_moreFailed => 'Daha fazla görüşme yüklenemedi.';

  @override
  String get coachMeetings_newA11y => 'Yeni görüşme';

  @override
  String get coachMeetings_newTitle => 'Yeni görüşme';

  @override
  String get coachMeetings_noKind =>
      'Bu süzgeçle görüşme yok. Başka bir seçenek deneyebilirsin.';

  @override
  String coachMeetings_noMatch(String query) {
    return '“$query” ile eşleşen görüşme yok. Öğrenci adında arar; büyük-küçük harf ve I/ı/İ/i farkı gözetmez.';
  }

  @override
  String get coachMeetings_noStudents =>
      'Görüşme planlamak için önce bir öğrenci eklemelisin.';

  @override
  String get coachMeetings_noteAdd => 'Not Ekle';

  @override
  String get coachMeetings_noteAddTitle => 'Not ekle';

  @override
  String get coachMeetings_noteAdded => 'Not eklendi.';

  @override
  String coachMeetings_noteContext(String date, String name) {
    return '$date · $name';
  }

  @override
  String get coachMeetings_noteDelete => 'Sil';

  @override
  String get coachMeetings_noteDeleteAction => 'Notu Sil';

  @override
  String coachMeetings_noteDeleteBody(String text) {
    return '“$text” notu silinecek.';
  }

  @override
  String get coachMeetings_noteDeleteFailed =>
      'Not silinemedi. Bağlantını kontrol edip tekrar dene.';

  @override
  String get coachMeetings_noteDeleteTitle => 'Not silinsin mi?';

  @override
  String get coachMeetings_noteDeleted => 'Not silindi.';

  @override
  String get coachMeetings_noteEdit => 'Düzenle';

  @override
  String get coachMeetings_noteEditTitle => 'Notu düzenle';

  @override
  String get coachMeetings_noteFieldA11y => 'Not';

  @override
  String get coachMeetings_noteHint =>
      'Örn: Deneme sonucunu birlikte inceleyeceğiz.';

  @override
  String get coachMeetings_noteLabel => 'Not';

  @override
  String get coachMeetings_noteSave => 'Notu Kaydet';

  @override
  String get coachMeetings_noteSaveFailed =>
      'Not kaydedilemedi. Bağlantını kontrol edip tekrar dene.';

  @override
  String get coachMeetings_noteUpdated => 'Not güncellendi.';

  @override
  String get coachMeetings_notesEmpty => 'Henüz not yok.';

  @override
  String get coachMeetings_notesLoadFailed => 'Notlar yüklenemedi.';

  @override
  String get coachMeetings_notesTitle => 'Notlar';

  @override
  String coachMeetings_past(String count) {
    return 'Geçmiş · $count';
  }

  @override
  String get coachMeetings_pickStudentNoMatch => 'Eşleşen öğrenci yok.';

  @override
  String get coachMeetings_pickStudentSearch => 'Öğrenci ara';

  @override
  String get coachMeetings_pickStudentTitle => 'Öğrenci seç';

  @override
  String get coachMeetings_refreshFailed =>
      'Liste yenilenemedi. Bağlantını kontrol edip tekrar dene.';

  @override
  String coachMeetings_rowWhen(String date, String time) {
    return '$date · $time';
  }

  @override
  String get coachMeetings_saveAction => 'Görüşmeyi Kaydet';

  @override
  String get coachMeetings_saveFailed =>
      'Görüşme kaydedilemedi. Bağlantını kontrol edip tekrar dene.';

  @override
  String get coachMeetings_saved => 'Görüşme kaydedildi.';

  @override
  String get coachMeetings_savedWithoutNote =>
      'Görüşme kaydedildi ama not eklenemedi.';

  @override
  String get coachMeetings_searchHint => 'Görüşme ara';

  @override
  String get coachMeetings_showAll => 'Tümünü Göster';

  @override
  String get coachMeetings_studentData => 'Öğrencinin verileri';

  @override
  String get coachMeetings_studentDataHint => 'Analiz, denemeler, program';

  @override
  String get coachMeetings_studentHint => 'Öğrenci seç';

  @override
  String get coachMeetings_studentLabel => 'Öğrenci';

  @override
  String get coachMeetings_studentMissing => 'Bir öğrenci seç.';

  @override
  String get coachMeetings_studentsFailed =>
      'Öğrenciler yüklenemedi. Bağlantını kontrol edip tekrar dene.';

  @override
  String get coachMeetings_timeLabel => 'Saat';

  @override
  String get coachMeetings_timeTitle => 'Saat';

  @override
  String coachMeetings_upcoming(String count) {
    return 'Yaklaşan · $count';
  }

  @override
  String get coachMeetings_withAll => 'Tümü';

  @override
  String get coachMeetings_withLabel => 'Kiminle';

  @override
  String coachStudentProfile_bagEmpty(String name) {
    return 'Çantada henüz konu yok. $name denemelerinden çıkan eksik konular burada görünür.';
  }

  @override
  String coachStudentProfile_bagHelp(String name) {
    return 'Çanta: $name denemelerinden çıkan eksik konular.';
  }

  @override
  String get coachStudentProfile_bagSegment => 'Çanta';

  @override
  String get coachStudentProfile_errorMessage =>
      'Bağlantını kontrol edip tekrar dene.';

  @override
  String get coachStudentProfile_errorTitle => 'Öğrenci yüklenemedi';

  @override
  String coachStudentProfile_examsEmptyMessage(String name) {
    return '$name bir deneme okuttuğunda sonuçları burada görünür.';
  }

  @override
  String get coachStudentProfile_examsOrder => 'En yeni önce';

  @override
  String coachStudentProfile_examsSummary(String count) {
    return '$count deneme · en yeni önce';
  }

  @override
  String coachStudentProfile_newDaysBody(String name) {
    return '$name için birden çok gün seçebilirsin; geçmiş günler seçilemez.';
  }

  @override
  String get coachStudentProfile_newDaysTitle => 'Hangi günler çalışacak?';

  @override
  String get coachStudentProfile_newNameTitle => 'Programa ad ver';

  @override
  String get coachStudentProfile_notFoundMessage =>
      'Bu öğrenci listende görünmüyor. Öğrencilerim\'e dönüp yeniden seçebilirsin.';

  @override
  String get coachStudentProfile_notFoundTitle => 'Öğrenci bulunamadı';

  @override
  String get coachStudentProfile_planMeeting => 'Görüşme Planla';

  @override
  String coachStudentProfile_programEditA11y(String name) {
    return '$name programını düzenle';
  }

  @override
  String coachStudentProfile_programEmptyBody(String name) {
    return 'Onun için bir hafta kurabilirsin; $name programı kendi Anasayfa\'sında görür.';
  }

  @override
  String coachStudentProfile_programEmptyBodyReadOnly(String name) {
    return '$name programını kurduğunda burada görünür.';
  }

  @override
  String coachStudentProfile_programEmptyTitle(String name) {
    return '$name programı yok';
  }

  @override
  String coachStudentProfile_programInfo(String name) {
    return 'Bu programı $name da görür ve düzenleyebilir. Yaptığın değişiklik onun programına hemen yansır.';
  }

  @override
  String get coachStudentProfile_programLoadErrorBody =>
      'Bağlantını kontrol edip tekrar dene.';

  @override
  String get coachStudentProfile_programLoadErrorTitle =>
      'Programlar yüklenemedi';

  @override
  String get coachStudentProfile_programOfflineNote =>
      'Program kurmak ve düzenlemek için bağlantı gerekiyor. Kayıtlı programı görebilirsin.';

  @override
  String get coachStudentProfile_programSaveFailed =>
      'Program kaydedilemedi. Bağlantını kontrol edip tekrar dene.';

  @override
  String coachStudentProfile_programSaved(String name) {
    return 'Program $name hesabına kaydedildi.';
  }

  @override
  String get coachStudentProfile_programSetUp => 'Program Kur';

  @override
  String coachStudentProfile_programsCount(String count) {
    return '$count program';
  }

  @override
  String get coachStudentProfile_programsRow => 'Programlar';

  @override
  String get coachStudentProfile_programsTitle => 'Programlar';

  @override
  String coachStudentProfile_stripDetail(String grade, String track) {
    return '$grade · $track';
  }

  @override
  String coachStudentProfile_stripDetailA11y(String grade, String track) {
    return '$grade, $track';
  }

  @override
  String get coachStudentProfile_summaryWho => 'Kimin için';

  @override
  String get coachStudentProfile_tabAnalysis => 'Analiz';

  @override
  String get coachStudentProfile_tabExams => 'Denemeler';

  @override
  String get coachStudentProfile_tabProgram => 'Program';

  @override
  String get coachStudentProfile_tabsA11y => 'Öğrenci verileri sekmeleri';

  @override
  String get coachStudentProfile_trackShortDil => 'DİL';

  @override
  String get coachStudentProfile_trackShortEsitAgirlik => 'EA';

  @override
  String get coachStudentProfile_trackShortSayisal => 'SAY';

  @override
  String get coachStudentProfile_trackShortSozel => 'SÖZ';

  @override
  String coachWidgets_attentionDates(String first, String second) {
    return '$first ve $second';
  }

  @override
  String coachWidgets_attentionInactive(String days) {
    return '$days gündür deneme okutmadı';
  }

  @override
  String coachWidgets_attentionInactiveEvidence(String date) {
    return 'Son deneme $date';
  }

  @override
  String coachWidgets_attentionInactiveEvidenceType(String date, String type) {
    return 'Son deneme $date · $type';
  }

  @override
  String coachWidgets_attentionLastExamA11y(String date) {
    return 'son deneme $date';
  }

  @override
  String coachWidgets_attentionNetDrop(String type) {
    return 'Son iki $type denemesinde net düştü';
  }

  @override
  String get coachWidgets_attentionNetDropPlain => 'Son iki denemede net düştü';

  @override
  String coachWidgets_attentionNetEvidence(
    String from,
    String to,
    String dates,
  ) {
    return '$from → $to · $dates';
  }

  @override
  String coachWidgets_attentionNetEvidenceNets(String from, String to) {
    return '$from → $to';
  }

  @override
  String coachWidgets_codeA11y(String code) {
    return 'Koçluk kodun $code';
  }

  @override
  String get coachWidgets_codeCopied => 'Kod kopyalandı.';

  @override
  String get coachWidgets_codeCopy => 'Kopyala';

  @override
  String get coachWidgets_codeHint =>
      'Öğrencin bu kodu Hesap › Koçluk\'a girince sana bağlanır.';

  @override
  String get coachWidgets_codeShare => 'Paylaş';

  @override
  String coachWidgets_codeShareText(String code) {
    return 'SMAP\'te koçluk kodum: $code';
  }

  @override
  String get coachWidgets_codeTitle => 'Koçluk kodun';

  @override
  String coachWidgets_meetingA11y(
    String name,
    String date,
    String time,
    String kind,
  ) {
    return '$name, $date, $time, $kind';
  }

  @override
  String coachWidgets_meetingA11yPlain(String name, String date, String time) {
    return '$name, $date, $time';
  }

  @override
  String get coachWidgets_meetingKindParentA11y => 'Veli görüşmesi';

  @override
  String get coachWidgets_meetingKindStudentA11y => 'Öğrenci görüşmesi';

  @override
  String coachWidgets_meetingListMeta(String date, String time) {
    return '$date · $time';
  }

  @override
  String coachWidgets_meetingMeta(String day, String time, String kind) {
    return '$day $time · $kind';
  }

  @override
  String coachWidgets_meetingMetaPlain(String day, String time) {
    return '$day $time';
  }

  @override
  String coachWidgets_meetingMonth(String month) {
    return '$month.';
  }

  @override
  String get coachWidgets_meetingParent => 'Veli';

  @override
  String get coachWidgets_meetingStudent => 'Öğrenci';

  @override
  String coachWidgets_tileA11y(String name) {
    return '$name, öğrenci';
  }

  @override
  String coachWidgets_tileA11yLastExam(String name, String date) {
    return '$name, son deneme $date';
  }

  @override
  String coachWidgets_tileLastExam(String date) {
    return 'Son deneme $date';
  }

  @override
  String get coachingChange_action => 'Koçu Değiştir';

  @override
  String get coachingChange_codeLabel => 'Yeni koçunun kodu';

  @override
  String coachingChange_errSameCoach(String name) {
    return 'Bu kod zaten koçun $name ait.';
  }

  @override
  String get coachingChange_offlineNote =>
      'Koçunu değiştirmek için bağlantı gerekiyor.';

  @override
  String get coachingChange_open => 'Koçunu Değiştir';

  @override
  String get coachingChange_title => 'Koçunu değiştir';

  @override
  String coachingChange_warning(String name) {
    return '$name ile bağlantın kalkacak. Yeni koçun denemelerini, analizlerini ve programını görebilecek.';
  }

  @override
  String get coachingInfo_body1 =>
      'Koçluk kodu, koçunun SMAP hesabına özel koddur; dört harf ve dört rakamdan oluşur.';

  @override
  String get coachingInfo_body2 =>
      'Kodu koçundan iste. Girdiğinde koçun denemelerini, analizlerini ve programını görebilir. Bağlantıyı istediğin an buradan kaldırabilirsin.';

  @override
  String get coachingInfo_coachBody1 =>
      'Öğrencin bu kodu kendi hesabında Hesap › Koçluk bölümüne girer; böylece hesabı seninkine bağlanır.';

  @override
  String get coachingInfo_coachBody2 =>
      'Bağlanan öğrenciler Öğrencilerim\'de listelenir; denemelerini, analizlerini ve programını görürsün. Hesabını senin açtığın öğrenciler zaten bağlı gelir.';

  @override
  String get coachingInfo_coachTitle => 'Koçluk kodu ne işe yarar?';

  @override
  String get coachingInfo_title => 'Koçluk kodu nedir?';

  @override
  String get coaching_coachLabel => 'Koçun';

  @override
  String get coaching_codeHelp =>
      '4 harf ve 4 rakam; tire kendiliğinden gelir.';

  @override
  String get coaching_codeHint => 'Örn: MOZK-4821';

  @override
  String get coaching_codeLabel => 'Koçluk kodu';

  @override
  String get coaching_connect => 'Koça Bağlan';

  @override
  String get coaching_errNotFound =>
      'Bu kodla bir koç bulunamadı. Kodu koçundan yeniden iste.';

  @override
  String get coaching_errorTitle => 'Koçluk yüklenemedi';

  @override
  String coaching_infoBox(String name) {
    return '$name denemelerini, analizlerini ve programını görebilir.';
  }

  @override
  String coaching_linked(String name) {
    return '$name bağlandın.';
  }

  @override
  String get coaching_title => 'Koçluk';

  @override
  String get coaching_unlinkAction => 'Bağlantıyı Kaldır';

  @override
  String coaching_unlinkBody(String name) {
    return '$name gelişimini artık göremeyecek. Yeniden bağlanmak için koçluk kodunu tekrar girmen gerekir.';
  }

  @override
  String get coaching_unlinkTitle => 'Koç bağlantısı kaldırılsın mı?';

  @override
  String get coaching_unlinked => 'Koç bağlantın kaldırıldı.';

  @override
  String get coaching_unlinkedIntro =>
      'Koçunun verdiği kodu gir; koçun denemelerini, analizlerini ve programını görebilsin.';

  @override
  String get coaching_whatIsCode => 'Koçluk Kodu Nedir?';

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
  String get deletion_confirmAction => 'Hesabımı Sil';

  @override
  String deletion_confirmBody(String name) {
    return '$name hesabı ve bütün verilerin kalıcı olarak silinecek. Bu işlem geri alınamaz.';
  }

  @override
  String get deletion_confirmBodyAnonymous =>
      'Hesabın ve bütün verilerin kalıcı olarak silinecek. Bu işlem geri alınamaz.';

  @override
  String get deletion_confirmTitle => 'Hesabın silinsin mi?';

  @override
  String get deletion_doneBody =>
      'Verilerin silindi. İstersen yeni bir hesapla yeniden başlayabilirsin.';

  @override
  String get deletion_doneTitle => 'Hesabın silindi';

  @override
  String get deletion_failed =>
      'Hesabın silinemedi. Bağlantını kontrol edip tekrar dene.';

  @override
  String deletion_lineCoach(String name) {
    return 'Koçun $name ile bağlantın kalkar.';
  }

  @override
  String get deletion_lineCoachAnonymous => 'Koçunla bağlantın kalkar.';

  @override
  String deletion_lineExams(String count) {
    return 'Okuttuğun $count deneme ve analizleri silinir.';
  }

  @override
  String get deletion_lineExamsAnonymous =>
      'Okuttuğun denemeler ve analizleri silinir.';

  @override
  String get deletion_lineIrreversible => 'Bu işlem geri alınamaz.';

  @override
  String get deletion_lineProgress =>
      'Eksik konuların, programların ve bilgi kartı ilerlemen silinir.';

  @override
  String get deletion_listHeading => 'Hesabını silersen:';

  @override
  String get deletion_pauseHint =>
      'Yalnız bir süre ara vermek istiyorsan çıkış yapman yeterli; verilerin hesabında kalır.';

  @override
  String get deletion_progressBody => 'Uygulamayı kapatma.';

  @override
  String get deletion_progressTitle => 'Hesabın siliniyor';

  @override
  String get deletion_title => 'Hesabını sil';

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
  String get examDetail_analysisEmpty => 'Bu soru için çözüm açıklaması yok.';

  @override
  String get examDetail_analysisTitle => 'Soru Analizi';

  @override
  String get examDetail_answerBlankSentence => 'Bu soruyu boş bıraktın.';

  @override
  String get examDetail_answerCorrect => 'Doğru cevap';

  @override
  String get examDetail_answerCorrectSentence => 'İşaretin doğru cevap.';

  @override
  String get examDetail_answerMarked => 'İşaretin';

  @override
  String get examDetail_answerWrongSentence => 'Bu soruyu yanlış işaretledin.';

  @override
  String examDetail_cardGroupA11y(String lesson, String count) {
    return '$lesson, $count kart';
  }

  @override
  String examDetail_cardGroupCount(String count) {
    return '$count kart';
  }

  @override
  String examDetail_cardsAdded(String count) {
    return '$count bilgi kartı eklendi';
  }

  @override
  String get examDetail_cardsAddedBody =>
      'Bu denemede yanlış ve boş bıraktığın sorulardan.';

  @override
  String get examDetail_cardsEmpty => 'Bu denemeden kart eklenmedi.';

  @override
  String get examDetail_cardsError => 'Kartlar yüklenemedi.';

  @override
  String get examDetail_copyrightNote =>
      'Sorunun fotoğrafı telif hakları nedeniyle paylaşılamıyor.';

  @override
  String examDetail_counterBlank(String count) {
    return '$count boş';
  }

  @override
  String get examDetail_counterNoBlank => 'boş yok';

  @override
  String get examDetail_counterNoWrong => 'yanlış yok';

  @override
  String examDetail_counterWrong(String count) {
    return '$count yanlış';
  }

  @override
  String get examDetail_errorMessage => 'Bağlantını kontrol edip tekrar dene.';

  @override
  String get examDetail_errorTitle => 'Deneme yüklenemedi';

  @override
  String get examDetail_filterA11y => 'Soru süzgeci';

  @override
  String get examDetail_filterAll => 'Tümü';

  @override
  String get examDetail_filterBlank => 'Boşlar';

  @override
  String get examDetail_filterWrong => 'Yanlışlar';

  @override
  String examDetail_lessonGroupA11y(String lesson, String total) {
    return '$lesson, zayıftan güçlüye, $total soru';
  }

  @override
  String get examDetail_mostMissedLabel => 'En çok kaçırdığın konu';

  @override
  String examDetail_mostMissedSentence(String total, String wrong) {
    return '$total sorudan $wrong kaçırdın.';
  }

  @override
  String get examDetail_netRule =>
      'Net = doğru − yanlış ÷ 4; boş neti etkilemez.';

  @override
  String examDetail_netsByScoreType(String list) {
    return 'Puan türüne göre net: $list.';
  }

  @override
  String examDetail_noBlankBody(String count) {
    return 'Bu denemedeki $count sorunun hepsini işaretledin.';
  }

  @override
  String get examDetail_noBlankTitle => 'Boş bıraktığın soru yok';

  @override
  String get examDetail_noBreakdownBody =>
      'Netin ve doğru, yanlış, boş sayıların hesaplandı; bu deneme için ders bazında sonuç gelmedi.';

  @override
  String get examDetail_noBreakdownTitle => 'Ders kırılımı yok';

  @override
  String examDetail_noWrongBody(String count) {
    return 'Bu denemedeki $count sorunun hiçbirini yanlış yapmadın.';
  }

  @override
  String get examDetail_noWrongTitle => 'Yanlış yaptığın soru yok';

  @override
  String examDetail_questionContext(String test, String lesson) {
    return '$test · $lesson';
  }

  @override
  String examDetail_questionCorrectNoMarkA11y(int number) {
    return 'Soru $number, doğru';
  }

  @override
  String get examDetail_questionErrorTitle => 'Soru yüklenemedi';

  @override
  String get examDetail_questionLoadError => 'Soru açıklaması yüklenemedi.';

  @override
  String examDetail_questionTitle(String number) {
    return '$number. soru';
  }

  @override
  String examDetail_questionWrongNoMarkA11y(int number) {
    return 'Soru $number, yanlış';
  }

  @override
  String get examDetail_questionsEmpty => 'Bu deneme için soru ayrıntısı yok.';

  @override
  String get examDetail_questionsError => 'Sorular yüklenemedi.';

  @override
  String get examDetail_rawScore => 'Ham puan';

  @override
  String get examDetail_relatedCards => 'İlgili kartlar';

  @override
  String examDetail_relatedCount(String count) {
    return '$count kart';
  }

  @override
  String examDetail_scoreTypeNet(String field, String net) {
    return '$field $net';
  }

  @override
  String get examDetail_showAllQuestions => 'Tüm Soruları Göster';

  @override
  String get examDetail_studyCards => 'Kartları Çalış';

  @override
  String get examDetail_studyTopic => 'Bu Konuyu Çalış';

  @override
  String get examDetail_tabCards => 'Kartlar';

  @override
  String get examDetail_tabGeneral => 'Genel';

  @override
  String get examDetail_tabQuestions => 'Sorular';

  @override
  String get examDetail_tabTopics => 'Konular';

  @override
  String get examDetail_tabsA11y => 'Deneme bölümleri';

  @override
  String get examDetail_testBasicMath => 'Temel Matematik';

  @override
  String get examDetail_testMath => 'Matematik';

  @override
  String examDetail_testNumbered(String number) {
    return '$number. Test';
  }

  @override
  String get examDetail_testSciences => 'Fen Bilimleri';

  @override
  String get examDetail_testSocial => 'Sosyal Bilimler';

  @override
  String get examDetail_testSocial2 => 'Sosyal Bilimler 2';

  @override
  String get examDetail_testSocialLiterature =>
      'Türk Dili ve Edebiyatı–Sosyal Bilimler 1';

  @override
  String get examDetail_testTurkish => 'Türkçe';

  @override
  String get examDetail_topicNotFound => 'Bu konu Derslerim\'de bulunamadı.';

  @override
  String get examDetail_topicsEmpty => 'Konu analizi henüz hazır değil.';

  @override
  String get examDetail_topicsError => 'Konu analizi yüklenemedi.';

  @override
  String get examDetail_weakToStrong => 'zayıftan güçlüye';

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
  String exams_scoreRowA11y(String label, String value, String rank) {
    return '$label $value, sıra $rank';
  }

  @override
  String exams_scoreRowPointsA11y(String label, String value) {
    return '$label $value';
  }

  @override
  String exams_scoreRowRankA11y(String label, String rank) {
    return '$label sırası $rank';
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
  String get kit_a11yAccordionCollapsed => 'daraltılmış';

  @override
  String get kit_a11yAccordionExpanded => 'genişletilmiş';

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
  String literature_authorRowA11y(String name, String works) {
    return '$name, $works';
  }

  @override
  String literature_authorRowMissingA11y(
    String name,
    String works,
    String missing,
  ) {
    return '$name, $works, $missing eksik';
  }

  @override
  String get literature_authorsErrorBody =>
      'Bağlantını kontrol edip tekrar dene.';

  @override
  String get literature_authorsErrorTitle => 'Yazarlar yüklenemedi.';

  @override
  String get literature_eraListError => 'Dönemler yüklenemedi.';

  @override
  String literature_eraMissing(String count) {
    return '$count eksik eser';
  }

  @override
  String literature_eraRowA11y(int number, String name, String count) {
    return '$number, $name, $count eksik eser';
  }

  @override
  String get literature_known => 'Biliyorsun';

  @override
  String get literature_learned => 'Öğrendim';

  @override
  String literature_learnedToast(String work) {
    return '$work bildiklerine eklendi.';
  }

  @override
  String get literature_noAuthors => 'Bu bölümde yazar yok.';

  @override
  String get literature_noWorks => 'Bu yazarın eser listesi henüz yok.';

  @override
  String get literature_offlineNote =>
      'Öğrendim\'i kaydetmek için bağlantı gerekiyor.';

  @override
  String get literature_otherType => 'Diğer';

  @override
  String get literature_saveFailed =>
      'Kaydedilemedi. Bağlantını kontrol edip tekrar dene.';

  @override
  String literature_sheetA11y(String name, String era) {
    return '$name, $era';
  }

  @override
  String literature_typeHeading(String type, String count) {
    return '$type · $count';
  }

  @override
  String literature_workCount(String count) {
    return '$count eser';
  }

  @override
  String literature_workKnownA11y(String title, String type) {
    return '$title, $type, biliyorsun';
  }

  @override
  String literature_workKnownNoTypeA11y(String title) {
    return '$title, biliyorsun';
  }

  @override
  String literature_workMissingA11y(String title, String type) {
    return '$title, $type, eksik. Öğrendim olarak işaretle.';
  }

  @override
  String literature_workMissingNoTypeA11y(String title) {
    return '$title, eksik. Öğrendim olarak işaretle.';
  }

  @override
  String literature_workUnknownA11y(String title, String type) {
    return '$title, $type';
  }

  @override
  String get literature_works => 'Eserleri';

  @override
  String literature_worksCounter(String count, String missing) {
    return '$count eser · $missing eksik';
  }

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
  String get nav_homeGreetingNoName => 'Merhaba';

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
  String get notificationPrimer_allow => 'Bildirimlere İzin Ver';

  @override
  String get notificationPrimer_body =>
      'Sistemde olmayan bir denemeyi okuttuğunda analizini hazırlayınca bildirim gönderelim. Hesap › Bildirimler\'den istediğin zaman kapatabilirsin.';

  @override
  String get notificationPrimer_later => 'Sonra';

  @override
  String get notificationPrimer_title =>
      'Sonucun hazır olunca haber verelim mi?';

  @override
  String get notifications_categoriesHeading => 'Kategoriler';

  @override
  String notifications_coachAssignedBody(String name) {
    return '$name yeni bir şey atadığında';
  }

  @override
  String get notifications_coachAssignedBodyAnonymous =>
      'Koçun yeni bir şey atadığında';

  @override
  String get notifications_coachAssignedTitle =>
      'Koçun deneme ya da ödev atadı';

  @override
  String get notifications_examReadyBody =>
      'Okuttuğun denemenin analizi bitince';

  @override
  String get notifications_examReadyTitle => 'Deneme sonucun hazır';

  @override
  String get notifications_meetingPlannedBody =>
      'Koçun bir görüşme planladığında';

  @override
  String get notifications_meetingPlannedTitle => 'Görüşme planlandı';

  @override
  String get notifications_openSettings => 'Ayarları Aç';

  @override
  String get notifications_permissionOff =>
      'Bildirim izni kapalı. Telefonunun ayarlarından SMAP\'e izin verirsen bu tercihler geçerli olur.';

  @override
  String get notifications_plannedNotice =>
      'Bildirimler planlı: tercihlerin şimdiden kaydedilir, bildirimler açıldığında bunlara göre gelir.';

  @override
  String get notifications_quietBody => 'Bu saatlerde bildirim gelmez';

  @override
  String get notifications_quietEnd => 'Bitiş';

  @override
  String get notifications_quietEndTitle => 'Sessiz saat bitişi';

  @override
  String get notifications_quietHeading => 'Sessiz saatler';

  @override
  String get notifications_quietStart => 'Başlangıç';

  @override
  String get notifications_quietStartTitle => 'Sessiz saat başlangıcı';

  @override
  String get notifications_quietTitle => 'Sessiz saatler';

  @override
  String get notifications_savedNote => 'Değişiklikler anında kaydedilir.';

  @override
  String get notifications_studyReminderBody =>
      'Programındaki çalışmanın saatinde';

  @override
  String get notifications_studyReminderTitle => 'Çalışma hatırlatıcısı';

  @override
  String get notifications_title => 'Bildirimler';

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
  String get password_currentLabel => 'Mevcut şifre';

  @override
  String get password_errMismatch => 'Şifreler aynı değil.';

  @override
  String get password_errSame => 'Yeni şifre eskisiyle aynı olamaz.';

  @override
  String get password_errWrongCurrent => 'Mevcut şifren doğru değil.';

  @override
  String get password_newLabel => 'Yeni şifre';

  @override
  String get password_newRule => 'En az 8 karakter.';

  @override
  String get password_repeatLabel => 'Yeni şifre (tekrar)';

  @override
  String get password_submit => 'Şifreyi Güncelle';

  @override
  String get password_title => 'Şifre';

  @override
  String get password_updated => 'Şifren güncellendi.';

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
  String resultMoment_cards(String count) {
    return 'Bu denemeden $count bilgi kartı eklendi';
  }

  @override
  String get resultMoment_detail => 'Detaylı Analiz';

  @override
  String get resultMoment_errorMessage =>
      'Bağlantını kontrol edip tekrar dene.';

  @override
  String get resultMoment_errorTitle => 'Sonuç yüklenemedi';

  @override
  String get resultMoment_fieldA11y => 'Puan türü';

  @override
  String resultMoment_fieldNet(String field, String net) {
    return '$field neti $net';
  }

  @override
  String resultMoment_fieldTests(String first, String second) {
    return '$first ve $second';
  }

  @override
  String get resultMoment_home => 'Anasayfa';

  @override
  String get scan_addCorrection => 'Düzeltmeyi Ekle';

  @override
  String get scan_answersOffline =>
      'Bağlantı yok. Bağlantı gelince tekrar dene.';

  @override
  String scan_answersRead(String n) {
    return '$n cevap okundu';
  }

  @override
  String get scan_answersSendFailed =>
      'Cevaplar gönderilemedi. Düzeltmelerin duruyor; tekrar dene.';

  @override
  String get scan_blank => 'Boş';

  @override
  String scan_blankCount(String n) {
    return '$n boş';
  }

  @override
  String get scan_cameraFailBody =>
      'Başka bir uygulama kamerayı kullanıyor olabilir. Onu kapatıp tekrar dene.';

  @override
  String get scan_cameraFailTitle => 'Kamera açılamadı';

  @override
  String get scan_cameraLoadingA11y => 'Kamera açılıyor';

  @override
  String scan_columnCaption(String n, String q) {
    return '$n. kolon · $q soru · düzeltmek için soruya dokun';
  }

  @override
  String scan_columnN(String n) {
    return '$n. kolon';
  }

  @override
  String get scan_confirmAnswers => 'Cevapları Onayla';

  @override
  String get scan_cornerBottomLeftA11y => 'Sol alt köşe';

  @override
  String get scan_cornerBottomRightA11y => 'Sağ alt köşe';

  @override
  String get scan_cornerMoveDownA11y => 'Aşağı taşı';

  @override
  String get scan_cornerMoveLeftA11y => 'Sola taşı';

  @override
  String get scan_cornerMoveRightA11y => 'Sağa taşı';

  @override
  String get scan_cornerMoveUpA11y => 'Yukarı taşı';

  @override
  String get scan_cornerTopLeftA11y => 'Sol üst köşe';

  @override
  String get scan_cornerTopRightA11y => 'Sağ üst köşe';

  @override
  String get scan_cornersHint => 'Noktaları cevap alanının köşelerine getir.';

  @override
  String get scan_cornersHintSub => 'Ders adları şeridi dışarıda kalsın.';

  @override
  String get scan_cornersTitle => 'Köşeleri Ayarla';

  @override
  String scan_correctionChange(String from, String to) {
    return '$from → $to';
  }

  @override
  String scan_correctionCount(String n) {
    return '$n düzeltme';
  }

  @override
  String scan_correctionRow(String col, String q) {
    return '$col. kolon · $q. soru';
  }

  @override
  String get scan_corrections => 'Düzeltmeler';

  @override
  String get scan_correctionsEmpty =>
      'Henüz düzeltme yok. Okunan cevap formundakinden farklıysa yukarıdan ekle.';

  @override
  String get scan_debugGalleryPick => 'Galeriden seç';

  @override
  String get scan_deniedBody =>
      'Formunu okutabilmek için Ayarlar\'da SMAP\'e kamera izni ver. Sonra buraya dön; kaldığın yerden devam edersin.';

  @override
  String get scan_deniedTitle => 'Kamera izni kapalı';

  @override
  String get scan_dontShowAgain => 'Bir daha gösterme';

  @override
  String get scan_enfBody =>
      'Yayınevini ve deneme adını yaz; analizini en geç 72 saat içinde hazırlayalım.';

  @override
  String get scan_enfConfirmNote =>
      'Analizin hazır olunca Analizlerim › Denemelerim\'de görünür.';

  @override
  String get scan_enfConfirmTitle => 'Talep oluşturulsun mu?';

  @override
  String get scan_enfDoneBody =>
      'En geç 72 saat içinde hazır. Hazır olunca Analizlerim › Denemelerim\'de görünecek.';

  @override
  String get scan_enfDoneTitle => 'Talebin alındı';

  @override
  String get scan_enfSaved =>
      'Cevapların kaydedildi. Yeniden okutman gerekmez.';

  @override
  String get scan_enfSubmit => 'Analizimi Hazırlayın';

  @override
  String get scan_enfTitle => 'Bu deneme henüz sistemde yok';

  @override
  String get scan_errExamNameRequired => 'Deneme adını yaz.';

  @override
  String get scan_errPublisherRequired => 'Yayınevini yaz.';

  @override
  String get scan_exitBody => 'Düzelttiğin cevaplar kaydedilmeyecek.';

  @override
  String get scan_exitConfirm => 'Çık';

  @override
  String get scan_exitTitle => 'Okutmadan çıkılsın mı?';

  @override
  String get scan_fieldColumn => 'Kolon';

  @override
  String get scan_fieldExamName => 'Deneme adı';

  @override
  String get scan_fieldExamNameHint => 'Örn: Türkiye Geneli Deneme 7';

  @override
  String get scan_fieldPublisher => 'Yayınevi';

  @override
  String get scan_fieldPublisherHint => 'Örn: Örnek Yayınları';

  @override
  String get scan_fieldQuestion => 'Soru';

  @override
  String get scan_fix => 'Düzelt';

  @override
  String get scan_fixSheetTitle => 'Cevap Düzelt';

  @override
  String get scan_formNotFoundBody =>
      'Fotoğrafta cevap alanı seçilemedi. Formun tamamı görünsün, ışık yansımasın, ders adları şeridi dışarıda kalsın.';

  @override
  String get scan_formNotFoundTitle => 'Formu bulamadık';

  @override
  String get scan_goHome => 'Anasayfa';

  @override
  String get scan_gotIt => 'Anladım';

  @override
  String get scan_hintReady => 'Hazır. Telefonu sabit tut ve çek.';

  @override
  String get scan_hintSearching =>
      'Cevap alanını çerçeveye al.\nDers adları şeridi dışarıda kalsın.';

  @override
  String get scan_howToShoot => 'Nasıl Çekilir?';

  @override
  String get scan_howToShootA11y => 'Nasıl çekilir?';

  @override
  String get scan_imageLoadFailed => 'Görüntü yüklenemedi';

  @override
  String get scan_imageLoading => 'Form görüntüsü yükleniyor';

  @override
  String get scan_inProgressA11y => 'Sürüyor';

  @override
  String get scan_newPhoto => 'Yeni Fotoğraf';

  @override
  String get scan_next => 'Devam';

  @override
  String get scan_nextQuestionA11y => 'Sonraki soru';

  @override
  String get scan_noBlank => 'boş yok';

  @override
  String get scan_noCorrection => 'Düzeltme yok';

  @override
  String get scan_offlineQueuedBody =>
      'Fotoğrafın telefonunda saklandı. Bağlantı gelince gönderilecek.';

  @override
  String get scan_offlineTitle => 'Bağlantı yok';

  @override
  String get scan_ok => 'Tamam';

  @override
  String get scan_omrClosedBody =>
      'Kısa bir bakım yapıyoruz. Birazdan tekrar dene.';

  @override
  String get scan_omrClosedTitle => 'Optik okuma şu an kapalı';

  @override
  String get scan_openSettings => 'Ayarları Aç';

  @override
  String scan_percent(String n) {
    return '%$n';
  }

  @override
  String get scan_pinchHint => 'İki parmakla yakınlaştırabilirsin.';

  @override
  String get scan_previousQuestionA11y => 'Önceki soru';

  @override
  String get scan_primerAllow => 'Kameraya İzin Ver';

  @override
  String get scan_primerBody =>
      'SMAP kamerayı yalnız optik formunu çekerken kullanır. Bir sonraki adımda telefonun izin isteyecek.';

  @override
  String get scan_primerLater => 'Sonra';

  @override
  String get scan_primerTitle => 'Formunu okutmak için kamera gerekli';

  @override
  String get scan_questionNumberA11y => 'Soru numarası';

  @override
  String get scan_readValue => 'Okunan';

  @override
  String scan_removeCorrectionA11y(String col, String q) {
    return 'Düzeltmeyi kaldır: $col. kolon, $q. soru';
  }

  @override
  String get scan_retake => 'Tekrar Çek';

  @override
  String get scan_retryNow => 'Şimdi Tekrar Dene';

  @override
  String get scan_reviewSub => 'Okunan cevapları formunla karşılaştır.';

  @override
  String get scan_reviewTitle => 'Form Kontrol';

  @override
  String get scan_sendRequest => 'Talebi Gönder';

  @override
  String get scan_sending => 'Gönderiliyor';

  @override
  String get scan_shutterA11y => 'Fotoğraf çek';

  @override
  String get scan_stepPrepared => 'Fotoğraf hazırlandı';

  @override
  String get scan_stepPreparing => 'Fotoğraf hazırlanıyor';

  @override
  String get scan_stepReading => 'Cevapların okunuyor';

  @override
  String get scan_stepSendFailed => 'Gönderilemedi';

  @override
  String get scan_stepSending => 'Gönderiliyor';

  @override
  String get scan_stepSent => 'Gönderildi';

  @override
  String get scan_stepToRead => 'Cevaplar okunacak';

  @override
  String get scan_stepToSend => 'Gönderilecek';

  @override
  String get scan_topTitle => 'Optik Form';

  @override
  String get scan_tutorialStep1 => 'Cevap alanını çerçeveye al.';

  @override
  String get scan_tutorialStep2 =>
      'Ders adlarının yazdığı yatay şeridi dışarıda bırak.';

  @override
  String get scan_tutorialStep3 =>
      'Turuncu noktaları cevap alanının dört köşesine getir.';

  @override
  String get scan_tutorialTitle => 'Formu böyle çek';

  @override
  String get scan_uploadFailBody =>
      'Bağlantı koptu. Fotoğrafın duruyor; tekrar gönderebilir ya da yeniden çekebilirsin.';

  @override
  String get scan_uploadFailTitle => 'Formun gönderilemedi';

  @override
  String get scan_uploadPhotoA11y =>
      'Okunan form görüntüsü: dört kolon, kırk satır';

  @override
  String get scan_uploadProgressA11y => 'Gönderim';

  @override
  String get scan_uploadSub => 'Birkaç saniye sürebilir.';

  @override
  String get scan_uploadTimeoutBody => 'Sunucu yanıt vermedi.';

  @override
  String get scan_uploadTitle => 'Formun okunuyor';

  @override
  String get scan_yourMark => 'Formdaki işaretin';

  @override
  String get scan_zoomFormA11y => 'Formu büyüt';

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
  String get schedule_thisWeekA11y => 'bu hafta';

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
  String get students_addA11y => 'Öğrenci ekle';

  @override
  String students_added(String name) {
    return '$name eklendi.';
  }

  @override
  String get students_clearSearch => 'Aramayı Temizle';

  @override
  String students_count(String count) {
    return '$count öğrenci';
  }

  @override
  String get students_emptyAdd => 'Öğrenci Ekle';

  @override
  String get students_emptyMessage =>
      'Öğrencinin hesabını sen aç ya da koçluk kodunu paylaş; bağlanan öğrenciler burada listelenir.';

  @override
  String get students_emptyShare => 'Kodunu Paylaş';

  @override
  String get students_emptyTitle => 'Henüz öğrencin yok';

  @override
  String students_examCount(String count) {
    return '$count deneme';
  }

  @override
  String get students_loadErrorMessage =>
      'Bağlantını kontrol edip tekrar dene. Sorun sürerse biraz sonra yeniden açabilirsin.';

  @override
  String get students_loadErrorTitle => 'Öğrenciler yüklenemedi';

  @override
  String students_metaJoin(String first, String second) {
    return '$first · $second';
  }

  @override
  String get students_noResultMessage =>
      'Ad ve soyadda arar; büyük-küçük harf ve I/ı/İ/i farkı gözetmez.';

  @override
  String students_noResultTitle(String query) {
    return '“$query” ile eşleşen öğrenci yok';
  }

  @override
  String students_rowA11y(String name, String details) {
    return '$name, $details';
  }

  @override
  String get students_searchHint => 'Öğrenci ara';

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
