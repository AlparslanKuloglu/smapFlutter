# SMAP Flutter (`smapFlutter`) — ekran, sheet ve bileşen envanteri (koddan doğrulanmış)

Kapsam: `.`, `lib/vendor` hariç 199 Dart dosyası. Salt okunur inceleme yapıldı; hiçbir dosya değiştirilmedi. `lib/vendor/flutter_document_scanner` üçüncü taraf bir kamera, kırpma ve düzenleme eklentisidir (take/crop/edit sayfaları, kendi dahili "No Camera" ve "NO IMAGE" metinleri vardır). Uygulama onu `OMDPreviewWidget` içinde yeniden giydirir.

Yol kısaltmaları, hepsi `lib/` altındadır:
- `home/` = `features/home/presentation/`
- `sched/` = `features/home/presentation/screens/my_schedule_page/`
- `ana/` = `features/analytics/presentation/`
- `auth/` = `features/auth/presentation/`
- `prof/` = `features/profile/presentation/screens/`
- `card/` = `features/my_card/presentation/screens/my_cards_page/`
- `root/` = `features/root/presentation/`
- `omd/` = `views/optic_mark_detection_view/`
- `kocS/` = `features/my_students/`
- `kocG/` = `features/my_interviews/`

---

## 0. Önce bilinmesi gerekenler

1. **Canlı ekranların hepsi native Flutter'dır; WebView yok.**
   - `views/main_webview/main_inapp_webview.dart` ve `main_webview.dart` hiçbir yerden çağrılmaz (ikincisi tamamen yorum satırı).
   - `views/auth/login_view.dart` baştan sona `/* … */` içindedir (464. satır).
   - `views/onboarding/onboarding_page.dart`, `features/onboarding/onboarding_page.dart` dosyasının ölü kopyasıdır.
   - Tek "web'e gönderme" mesajı metin olarak geçer: Matematik/Geometri "Kavram Haritan" diyaloğu, "smaptr.com'dan giriş yaparak" der (`home/widgets/lesson_navigation_helper.dart:36-39`).
2. **Roller ve alt bar:**
   - İki rol vardır: `student` ve `coach` (`UserModel.role`, `domain/models/user_model.dart:24`). Kayıtta `userType` 1 = öğrenci, 2 = koç (`auth/widgets/register_form.dart:202`).
   - Alt bar 4 sekme ve ortada kamera butonundan oluşur. Öğrenci: Anasayfa, Analizlerim, Derslerim, Hesap. Koç: Anasayfa, Öğrencilerim, Görüşmelerim, Hesap. Kamera butonu koçta da vardır.
   - `root/screens/root_screen.dart:135` içinde `userRole != 'teacher'` yazar. Oysa rol `'coach'`'tur, bu yüzden koçta da `myCardNav.resetToHub()` çalışır (zararsız ama hatalı).
3. **Dark mode yok.** Yalnızca `AppTheme.light` var (`main.dart:85`). `darkTheme`, `ThemeMode` ve `Brightness.dark` için 0 eşleşme çıktı. Tek locale `tr_TR`'dir (`main.dart:93-94`). Yerelleştirme yok (ARB ve `AppLocalizations` 0). Özel font yok (`fontFamily` 0, `google_fonts` yok).
4. **"Yakında" ve sahte ekranlar** (bölüm 2'de detay):
   - `AppDialogs.showUnderConstruction` diyaloğu 9 yerde kullanılır: SmapLab, Gelen Kutusu, SmapCoach, Analizler (koç), Müfredat, Kaynak Takibi (koç), "Analiz" sekmesi, "Harita" sekmesi, "Kavram Haritan".
   - Ödeme/paket, Kayıtlı Kartlar, Bildirimler ekranları tamamen sahte veridir. Şifre değiştirme de sahtedir, sadece snackbar gösterir.
   - Şifremi unuttum akışı sunucuya hiç gitmez (4 haneli herhangi bir kod geçer).
5. **Ders listelerinde (Derslerim ve ders detayı) her satır için sabit sahte sayılar gösterilir:** `%75`, `15/20 Konu tamamlandı`, `4 Alt Başlık`, `26 Madde`, `8 Bilgi Kartı` (`ana/screens/lesson_detail_page.dart:522-527`, `card/.../lesson_bar.dart:17-22`). Alt başlık kartlarında sabit `%60` vardır (`ana/screens/subject_detail_page.dart:291`).
6. **Genel sekmesindeki dört istatistik kartının altında, gerçek veride bile sabit `+18.2%  gecen ay` yazar.** `AnalyticsMetricCardData` varsayılanları `changeText='+18.2%'`, `periodText='gecen ay'` (`ana/models/analytics_general_data.dart:138-139`). `_mapToGeneralData` bunları hiç doldurmaz (`ana/provider/analytics_view_provider.dart:252-302`).
7. **Hazır ama ulaşılamayan bilgi kartı akışı:**
   - Swipe'lı kart ekranı (Eksiklerim / Bildiklerim / Favorilerim; Öğrendim, favori, Detay) kodda tamdır.
   - Ama `MyCardPage._openLessonDetail` hiçbir yerden çağrılmaz (`card/my_card_page/my_card_page.dart:116`).
   - Derslerim satırı bunun yerine `LessonNavigationHelper.showTypeSelection` açar (aynı dosya, 251. satır).
   - Dolayısıyla `MyCardLessonDetailPage`, `MyCardsDetailPage` ve `MyCardInfoCard` şu an kullanıcıya açık değildir.
8. **"Elmas / coin / seri":**
   - Yalnızca `UserModel.points` var; Anasayfa kişi kartında `assets/menuIcons/smapc.png` ikonunun yanında sayı olarak görünür (`home/widgets/home_person_card.dart:77-94`). İkon adı "smapc" (SMAP coin) olarak okunur.
   - Kazanma/harcama kodu yoktur. Seri/streak yoktur. `_diamond` rengi tanımlı ama kullanılmıyor (13. satır).
   - Premium/paket satın alma kodu yoktur (`in_app_purchase` bağımlılığı da yok).
9. **Backend adresi tutarsızdır.**
   - Dio: `https://www.smaptr.com` (`core/network/dio_client.dart:17`).
   - Görseller: `https://smaptr.com.tr/uploads/…` (`omd/omd_loading.dart:765`), `https://www.smaptr.com.tr/uploads/` (`views/…/omd_result_flow_view.dart:90`, `ana/screens/my_test_result_detail_screen.dart:252`), `https://smaptr.com/subjectIcons/`.
   - Optik okuma istekleri (`opticimage`, `answerArray`, `examrequest`) `RestApiHttpService`'e gider. Bu servisin tabanı `APIConstants.apiBaseUrl = 'https://wfdsvfsdg.com/'` ve "TODO" yorumu taşır (`core/constants/api_constants.dart:14`). Bu depodaki haliyle kamera akışının hedef sunucusu belirsizdir.
10. **Net hesabı istemcide yapılmaz.** Net, backend'den `net` alanı olarak gelir. "Doğru − yanlış/4" formülü kodda yoktur (`/4`, `0.25` araması 0 sonuç). Bkz. bölüm 5.

---

## 1. Navigasyon

### 1.1 Açılış zinciri
1. `main()` içinde `DioClient().init()` ve `initializeDateFormatting('tr_TR')` çalışır (`main.dart:30-36`).
2. **Splash ekranı yok.**
   - `AppStartNotifier` çözülene kadar, ortada `CircularProgressIndicator` olan boş beyaz bir Scaffold görünür (`main.dart:122-126`, ikinci kez `143-145`). İndikatör rengi lacivert `0F294A` (`core/theme/app_theme.dart:20-22`).
   - `flutter_native_splash` bağımlılıktır ama `pubspec.yaml`'da yapılandırma bölümü yok. `assets/splash/` içinde `splash_logo.png` ve `android_12_splash.png` var, Dart'tan referans verilmez.
3. Karar (`auth/domain/usecases/get_app_launch_destination_usecase.dart:10-15`):
   - `onboarding_completed` yoksa **Onboarding**.
   - Varsa `GET /ajax/checkUser` ile oturum doğrulanır: geçerliyse **Home (RootScreen)**, değilse **Login**.
   - Hata olursa Login (`auth/provider/app_start_provider.dart:17-19`).
4. Home'da `UserProvider.userRole == null` ise yine spinner gösterilir ve `loadUserData()` çağrılır (`main.dart:140-146`).

### 1.2 Rota listesi

| Rota / giriş | Hedef | Dosya | Not |
|---|---|---|---|
| `home:` (Consumer) | Onboarding / LoginView / RootScreen | `main.dart:119-155` | Asıl giriş |
| `/onboarding` | `OnboardingScreen` | `main.dart:98` | Hiçbir yerden `pushNamed` edilmiyor |
| `/login` | `LoginView` | `main.dart:99-102` | Onboarding bitişi, çıkış ve hesap silmeden sonra kullanılır |
| `/home` | `RootScreen` | `main.dart:103-117` | Kullanılmıyor; giriş `pushReplacement(MaterialPageRoute)` ile yapılır |
| Diğer her şey | Anonim `MaterialPageRoute` (63 `push` noktası) | — | `auto_route`/`go_router` yok |

Sekme içi sanal rotalar (Navigator değil, `IndexedStack` ve enum ile):
- `HomeRoute{hub, mySchedule}` (`home/provider/home_nav_provider.dart:3`).
- `AccountRoute{hub, account, payment, savedCards, contracts, notifications}` (`prof/../account_nav_provider.dart:3-10`).
- `MyCardNavNotifier.openLesson` hiç çağrılmıyor (ölü).

Sub-sayfa başlıkları (`Programım`, `Profilim`, `Ödeme Ayarlarım`, …) `*NavNotifier.title` içinde tanımlıdır, ama `CustomTopAppBar`'a verilen `title` yorum satırındadır (`root/screens/root_screen.dart:93-103`). Yani Hesap alt sayfalarının ve Programım'ın üst barında başlık görünmez; sadece geri oku, kullanıcı adı, rol ve avatar görünür.

### 1.3 Alt bar (`root/widgets/custom_bottom_nav_bar.dart`)
- Yükseklik `72 + alt inset`. Beyaz zemin, üst köşeler 20 radius, gölge. Üst kenarda 60×4 turuncu gösterge çubuğu (`navIndicator`), seçime 180 ms'de kayar (`:66-87`). Kamera slotu atlandığı için indeks 2+ ise +1 kaydırılır (`:50-52`).
- Sekmeler:

| Slot | Öğrenci | Koç | İkon |
|---|---|---|---|
| 1 | `Anasayfa` (`:97`) | `Anasayfa` | `assets/home.svg` |
| 2 | `Analizlerim` (`:114`) | `Öğrencilerim` (`:108`) | `assets/chart.svg` / `Icons.people_rounded` |
| 3 | Kamera | Kamera | `assets/icons/camera.svg` beyaz, 32 px |
| 4 | `Derslerim` (`:134`) | `Görüşmelerim` (`:128`) | `assets/cards.svg` / `Icons.chat` |
| 5 | `Hesap` (`:144`) | `Hesap` | `assets/profile.svg` |

- Etiket 12 px. Seçili: w700 turuncu + `navSelectedBg` (FFD4B3) 36×28 hap. Seçili değil: `navUnselected` (B2BAC6).
- **Ortadaki kamera butonu** (`:228-266`): 74×74, radius 20, turuncu `FF6600`, turuncu gölge, `-12` px yukarı taşar, etiketi yok. Alt barın sekme state'ini değiştirmez; `Navigator.push(OpticMarkDetectionView2)` ile tam ekran açar (`root_screen.dart:48-52`).
- Hit alanı: `GestureDetector`; `Semantics` veya tooltip yok.

### 1.4 Üst bar (`root/widgets/custom_top_app_bar.dart`, `header_user_section.dart`)
- Lacivert `0F294A`, içerik yüksekliği 50, `radius` opsiyonu ve `showBottomBorder` opsiyonu var (ikisi de root'ta kullanılmıyor).
- Soldaki logo (`assets/smaplogo.png`) veya geri oku (iOS stil, `arrow_back_ios_new_rounded`). Sağda iki satır: ad, ve altında turuncu rol/alan satırı: koçta `Öğrenci Koçu`, öğrencide `aimType` 2 → `Eşit Ağırlık`, 3 → `Sayısal`, 4 → `Sözel`, aksi halde boş (`header_user_section.dart:17-22`). Sağda `AppUserAvatar`.
- Kullanıcı yüklenmediyse ad yerine `Yükleniyor...` yazar (`:76`). Logo ve ad/avatar `onTap: () {}` ile boş tıklanır (`:47`, `:64`).
- Üst bar, Derslerim sekmesinde gizlenir (`isMyCardTab`, `root_screen.dart:75`, `:87`). O sekme kendi başlığını (`MyCardHeader`) çizer.

---

## 2. Ekran envanteri

### 2.1 Onboarding — `features/onboarding/onboarding_page.dart`
- **Bölümler:** `PageView` (5 sayfa) → sayfa göstergesi (aktif 35×4, pasif 20×4, `:214-228`) → ana buton → "Tanıtımı atla" alt çizgili metin butonu.
- **Sayfa içeriği** (`:19-48`). Görsel alanı `flex 4`; metinler 26 px bold lacivert başlık, 15 px gri açıklama:
  1. `ob1.png` + `ob2.png` yan yana. Başlık: "Sana Dair En Detaylı Analiz: Tüm Denemeler! \n Yayınevi farketmeksizin!" Açıklama: "Optik formunu okuttuğunda denemen otomatik saptanır ve 5 saniyede analizin hazırlanır!"
  2. `ob5.png`. "Smap Neyi Bilmediğini Belirler ve Eksiklerini Gidermeni Sağlar" / "Yapay zeka destekli analizlerimizle hangi konuya ne kadar çalışman gerektiğini sana söyleyelim."
  3. `ob3.png`. "Denemelerini Okut ve Sana Ait Kümülatif Birikimle İlerlemeni Adım Adım Takip Et!" / "Sınav maratonunda kendine hedefler koy ve bu hedeflere ne kadar yaklaştığını anlık olarak izle."
  4. `ob4.png`. "Güçlü ve Zayıf Yanların: Konularla Karşılaşma Sayıların ve Başarı Yüzdelerin" / "Anlamadığın soruların çözümlerine tek tıkla ulaş, eksik konu bırakmadan ilerle."
  5. `ob6.png`. "YKS'ye Son Teknoloji ile Hazırlan" / "Şimdi SMAP dünyasına katıl ve hayalindeki üniversite için en büyük adımı at!"
- **Butonlar:** son sayfaya kadar `Devam Et`, son sayfada `Hemen Başla` (`:125`). `Tanıtımı atla` (`:134`). İkisi de `CompleteOnboardingUseCase` ile `onboarding_completed=true` yazar ve `/login`'e `pushReplacement` yapar.
- **Durumlar:** yükleme, hata, boş durum kavramı yok (statik). Geri/swipe ile sayfa değişimi serbesttir. Bir "önceki" butonu yoktur.
- **Not:** Görsel ve metin yerleşimi açıklamalar için tek tip; 1. sayfa ikili görsel olduğu için farklı yerleşimdedir.

### 2.2 Giriş / Kayıt / Şifremi unuttum

**Giriş — `auth/screens/login_screen.dart` + `auth/widgets/login_card.dart`**
- **Yerleşim:** üst yarı lacivert `0D2744`, alt yarı `F0F4F8` (`login_screen.dart:137-158`). Ortada beyaz kart (radius 16, `maxWidth 520`). Dar ekran uyarlamaları: `<640` "small", `<520` "tiny" (`login_card.dart:50-83`).
- **Kart içeriği sırayla** (`login_card.dart:235-424`):
  - `assets/smaplogo.png`.
  - "SMAP'e hoş geldin!".
  - "Öğrenme yolculuğunuza başlamaya hazır mısınız?".
  - `assets/loginImage.png`.
  - "Kullanıcı Girişi".
  - İki alan: `hint: Kullanıcı adı` ve `hint: ••••••••` (şifre göz/gizle ikonu yok).
  - `Beni Hatırla` onay kutusu.
  - `Şifremi unuttum`.
  - "veya hesabınızla bağlanın" altında Apple ve Google yuvarlak ikonları.
  - 50 px lacivert `Giriş Yap`.
  - "Hesabın yok mu? **Kayıt ol**".
- Aynı kart `LoginCardContent{login, register, socialApple, socialGoogle}` ile içerik değiştirir (rota yok).
- **Veri:** `POST /student/login`; başarı `200` veya `302`; `response.data['user']` SharedPreferences `user_data`'ya yazılır.
- **Durumlar:**
  - Var: yüklenirken düğmede spinner (`:386-394`); hata SnackBar'ı: "Hata: Kullanıcı adı veya şifre yanlış." (`auth/provider/login_provider.dart:25`).
  - İstisna durumunda ham metin gösterilir: "🔴 Hata Oluştu! Mesaj: … 📍 Kaynak: …" (+ stack trace'in 3 satırı, `:32-41`). Metinde emoji vardır.
  - **Yok:** form doğrulaması (alanlarda `validator` yok, `:271-307`), çevrimdışı mesajı, `Beni Hatırla`'nın kalıcılığı (yalnızca yerel state, `login_screen.dart:22`).
- **Sahte/önceden dolu alanlar:** kullanıcı adı `student` ve sabit bir test şifresi controller içinde önceden yazılı gelir (`login_screen.dart:19-20`). Üretimde müşteriye görünür.
- **Apple/Google:** `SocialSignUpContent` (`auth/widgets/social_sign_up_content.dart`) açar: geri oku, sağlayıcı ikonu, "Kayıt için son bir adım!", "Son bir adım kaldı! Devam etmek için kendinizi tanımlayın.", `Öğrenci`/`Öğrenci Koçu` seçici, `Öğrenci Olarak Devam Et` / `Öğrenci Koçu Olarak Devam Et` düğmesi. **Düğme `onPressed: () {}`, hiçbir şey yapmaz** (`:98`). `GoogleAuthService` yazılmış ama hiçbir yerden çağrılmıyor.
- **Yönlendirme:** başarıda `RootScreen` `pushReplacement` (`:49-57`). Kayıt başarısında ek olarak "Kayıt başarılı! Giriş yapıldı." SnackBar'ı (`:89-91`).

**Kayıt — `auth/widgets/register_form.dart`** (aynı kartın içinde)
- **Bölümler:**
  - Başlık "Kayıt Ol" + geri oku.
  - Rol seçici `Öğrenci` / `Öğrenci Koçu` (`RoleToggleButton`).
  - Avatar seçici: ortada 45 yarıçaplı avatar, iki yanda ok ikonları; `AppColors.studentAvatars` içinde 7 avatar.
  - Alanlar: `Ad Soyad *`, `Kullanıcı adı *` (sağda spinner / yeşil tik / kırmızı hata ikonu), `E-posta *`, `Şifre *`, `Şifre yeniden *` (göz ikonları).
  - Yalnız öğrenci: `Sınıfınız` dropdown (`9. Sınıf`, `10. Sınıf`, `11. Sınıf`, `12. Sınıf`, `Mezun`) ve 11/12/Mezun seçilirse görünen `Alanınız` (`Sayısal`, `Eşit Ağırlık`, `Sözel`).
  - Yasal metin cümleleri: "Kayıt olarak **Kullanım Koşulları**'nı kabul etmiş olursunuz." ve "**KVKK Aydınlatma Metni** ve **Gizlilik Politikası**'nı inceleyebilirsiniz." (`:645-735`).
  - Hata kutusu, `Tamamla` düğmesi (52 px).
- **Veri:** `POST /student/register`. `userType` 1/2, `seasonType` (9..12, Mezun=13, koç=0), `aimType` (Sayısal=3, EA=2, Sözel=4). Yasal belge sürümleri eklenir (`acceptedTermsVersion`, `acceptedKvkkVersion`, `acceptedPrivacyVersion`; `auth/provider/register_provider.dart:54-66`). Yasal metinler `GET /ajax/getLegalDocuments`.
- **Durumlar:** düğme yükleniyor spinner'ı; sunucu hatası kırmızı kutuda; alan doğrulama mesajları: "Ad soyad gerekli", "Kullanıcı adı gerekli", "E-posta gerekli", "Geçerli bir e-posta girin", "Şifre gerekli", "Şifre tekrarı gerekli", "Şifreler eşleşmiyor", "Lütfen sınıfınızı seçin", "Lütfen alanınızı seçin". Yasal metin yoksa diyalog: "Sözleşme metni yüklenemedi veya bulunamadı."
- **Sahte:**
  - Kullanıcı adı müsaitlik kontrolü **simülasyondur**: 600 ms bekler, `admin` dışında her şey müsait çıkar; `TODO` yorumu vardır (`:100-102`). Oysa gerçek uç `CoachRepository.checkUsername` mevcut ve `AddStudentDialog` bunu kullanır.
  - Tüm alanlar test değerleriyle önceden dolu gelir: `Ad Soyad`, `usernametest`, `test@smap.tr` ve test şifresi (`:25-29`).
  - `_coachCodeController` tanımlı, formda hiç gösterilmez.
- **Yok:** şifre kuralı doğrulaması, e-posta/telefon doğrulama, 9-10. sınıf için alan açıklaması (alan sessizce gizlenir).

**Şifremi unuttum — `auth/screens/forgot_password_screen.dart`**
- 4 adımlı tam ekran akış (arka plan `F0F4F8`, geri oku sol üstte). Başlıklar: 1) "Şifremi Unuttum" ("Doğrulama kodu almak için telefon numaranızı girin."), 2) "Telefon Doğrulama" ("Doğrulama kodu şu numaraya gönderildi: ****1234"; 4 hane OTP kutusu, `Kodu Onayla`, 30 sn geri sayım, "Kodu almadınız mı? " / "Tekrar gönder (N sn)" / `Tekrar Gönder`), 3) "Yeni Şifre" ("Lütfen yeni şifrenizi girin."; `Şifre`, `Şifre tekrar`, `Şifreyi Onayla`; eşleşme yoksa buton pasif), 4) "Şifre Değiştirildi" ("Şifreniz başarıyla değiştirildi."; `Giriş Yap` → geri).
- **Tamamen istemci içidir, API çağrısı yok.** "Gerçek doğrulama burada yapılır; şimdilik her kod geçerli." (`:290`). Şifre değişmez.
- **Yok:** hata durumu, telefon formatı doğrulaması, gerçek SMS, tekrar gönderme isteği.

### 2.3 Anasayfa (sekme 0)

**Öğrenci Anasayfa — `home/screens/home_screen.dart`**
Sırayla:
1. **Ders kartı şeridi** (`home/widgets/home_lessons_cards.dart`): arkada yarım yükseklikte lacivert bant (`HomeNavyHeaderBand`), üstünde yatay kaydırmalı 90 px genişlikli beyaz kartlar. Her kart: 28 px ders ikonu (`assets${lesson.image}`, hata → `Icons.book_rounded`), ders adı 10 px (maks. 2 satır). Sağ altta taşan turuncu **toplam eksik** rozeti (`lesson.stats['total']`, `>0` ise; `:415-444`).
2. **`HomePersonCard`** (`home_person_card.dart`): lacivert kart, radius 12; solda `AppUserAvatar` (varsayılan yarıçap 24); sağda ad (15 px), `smapc.png` + `points` rozeti, 8 px turuncu ilerleme çubuğu (`user.progress`) ve `%N`.
3. **Menü gridi 3×2** (`home_menu_grid.dart`), kart: beyaz, 1 px gri çerçeve, radius 16, 52 px ikon, 12 px başlık. Öğrenci menüsü (`:13-45`):

| Başlık | Aksiyon |
|---|---|
| Analiz | Kök sekme 1 (Analizlerim), `initialTabIndex: 0` |
| Denemelerim | Kök sekme 1, `initialTabIndex: 1` |
| Derslerim | Kök sekme 2 |
| Gelen Kutusu | "yakında" diyaloğu: "Şu anda yapım aşamasında." (rozet kodu yorum satırı) |
| SmapLab | "yakında" diyaloğu: "Kendi bilgi kartlarından sana özel quizler oluşturabileceğin veya genel kategorilerde online rekabet edebileceğin bir alan. / Şu anda yapım aşamasında." |
| Programım | `HomeRoute.mySchedule` |

4. **Aylık takvim** (`home_month_calendar.dart`): `Pt Sal Çar Per Cu Cmt Paz`, ay/yıl başlığı (`MMMM yyyy`, tr), önceki/sonraki ay okları, bugün turuncu çerçeveli dairede. **Salt görseldir:** gün hücrelerinde `onTap` yok, hiçbir etkinlik/program verisi çizilmez.

- **Veri:** `HomeProvider.fetchHomeData` → `/ajax/getGeneralLessons` + `/student/getLessonsTotalMissing` (`home/provider/home_provider.dart:59-105`). Kullanıcı bilgisi `SharedPreferences['user_data']`.
- **Durumlar:**
  - İskelet: ders listesi boşsa 6 iskelet kart çizilir (`home_lessons_cards.dart:31, 61`). **Hata ve "ders yok" durumu da aynı iskeleti sonsuza dek gösterir**; `HomeProvider.error` kurulur (`:98`) ama hiçbir yerde okunmaz.
  - `HomePersonCard` kullanıcı yoksa 80 px spinner çizer; spinner beyaz renkli ve beyaz zeminde görünmez (`:23-28`).
  - Pull-to-refresh yok.
- **Ders kartı dokunuşu** (`home/widgets/lesson_navigation_helper.dart:10-72`):
  - `Matematik`/`Geometri` → "Kavram Haritan" diyaloğu (`imagePath: ""` → varsayılan inşaat ikonu).
  - `tytAyt == 1` olan dersler (Tarih, Coğrafya, Fizik, Kimya, Biyoloji) → TYT/AYT(/SOS-2) seçim **diyaloğu** (sayısal rozetli düğmeler).
  - `Edebiyat` → `EdebiyatLessonDetailPage`.
  - Diğerleri (Türkçe) → `LessonDetailPage` (`defaultFilterValue: 9`).
  - Aynı mantığın kopyası `_LessonCard` içinde ölü kod olarak durur (`home_lessons_cards.dart:100-355`, `_showBottomPanel` dahil).

**Koç Anasayfa**
- Aynı iskelet; ders şeridi yerine **öğrenci kartı şeridi** (`home_students_cards.dart`: 100 px kart, 20 px yarıçaplı avatar, ad 10 px, sağ altta `student.totalMexam` turuncu rozet). Öğrenci listesi boşsa 4 iskelet kart sonsuza dek.
- Kart dokunuşu → **öğrenci diyaloğu** (`:119-330`): avatar, ad, "{seasonType}. Sınıf", `aimType` etiketi, 4 buton: `Analiz` (`CoachAnalyticsDetailScreen`, sekme 0), `Denemeler` (sekme 1), `Kaynak Takibi` (sekme 2 → **"Analiz yakinda" yer tutucusu**, bkz. 2.5), `Program` (`TeacherViewScheduleScreen`).
- Koç menüsü (`:48-81`): `SmapCoach` ("Öğrenci Koçunun Profili … Çok yakında."), `Öğrencilerim` (kök sekme 1), `Analizler` ("Öğrencilerinize Dair En Detaylı Analiz … Çok yakında."), `Müfredat` ("Henüz İşlenmedi Mi? … Çok yakında."), `Kaynak Takibi` ("Ne Çözüyoruz? Siz söyleyin. … Çok yakında."), `Görüşmelerim` (kök sekme 2).
- **"Yakında" diyaloğu davranışı** (`home/widgets/app_dialog.dart:7-194`): 72 px ikon, turuncu başlık (varsayılan "Çok Yakında!"), açıklama, detay (varsayılan: "Bu özellik henüz geliştirilme aşamasındadır. Yayınlandığında ilk sizin haberiniz olsun ister misiniz?"), tam genişlik düğme (`Yayınladığında Haber Ver` → tıklayınca yeşile döner, `Kaydınız Alındı`; `buttonType 2` → `Detaylı Bilgi Al` → `Talebiniz Alındı`), `Kapat` metin butonu. `onNotifyMe`/`onGetInfo` çağrı noktalarında **boş süslü parantezdir** (`home_menu_grid.dart:186, 206…`); kullanıcıya "Kaydınız Alındı" gösterilir ama hiçbir şey kaydedilmez.

### 2.4 Optik okuma akışı (kamera butonu)

Akış: `OpticMarkDetectionView2` → (tutorial overlay) → çekim → köşe kırpma → düzenleme → fotoğraf yönergesi diyaloğu → analiz bekleme → doğrulama/düzeltme → (deneme bulundu ise) sonuç akışı / (bulunamadıysa) talep formu.

1. **Çekim ekranı** (`omd/optic_mark_detection_view.dart`, `widgets/preview_widget.dart`)
   - Siyah zemin, `DocumentScanner` (çözünürlük `veryHigh`, vendor eklentisi). Üstte lacivert `162A40` çubuk: sol `Icons.close` (turuncu, çıkar), ortada logo + "SMAP", sağ `Icons.help_outline` (turuncu, öğreticiyi manuel açar). Altta turuncu 65 px yuvarlak deklanşör (beyaz çerçeveli) (`preview_widget.dart:181-266`).
   - İlk açılışta **tutorial overlay** (`omd/camera_tutorial.dart`, SharedPreferences `omd_tutorial_hidden`): `162A40` zemin, 40% yükseklikte `assets/optic4.png`, başlık "Noktaları Köşelere Getirin", açıklama "Ders isimlerinin yer aldığı yatay dikdörtgeni dahil etmeyin. Beyaz noktaları cevap kutusunun dört köşesiyle eşleştirin. Bu, doğru okuma için önemlidir.", sağ üstte `Kapat`, `Bir daha gösterme` onay kutusu (manuel açıldığında gizlenir), beyaz `ANLADIM` düğmesi (`_steps` tek elemanlı; `SONRAKİ` metni oluşmaz).
   - **Yok:** flaş (kodda yorum "Flaş ve Çekim Butonu" diyor ama sadece deklanşör var), galeriden seçme (`image_picker` bağımlılığı var, kullanılmıyor), kamera izni reddi UI'ı. `_PreviewTopInfoWidget` ("Optik Form Okuma / Görüntüyü cevapları kodladığınız alanın tamamını görecek şekilde üzerine getiriniz") tanımlı ama hiç kullanılmıyor.
2. **Köşe düzenleme (crop) ve düzenleme (edit) adımları**: vendor sayfaları, üstte `hideAppBarDefault`/`hideBottomBarDefault: true`; üstüne aynı lacivert çubuk binmiş: `Geri` (turuncu) – "SMAP" – `Icons.info_outline` (öğretici diyaloğu) + `Onayla` (turuncu). Kırpma onayı `cropPhoto()`, düzenleme onayı `savePhotoDocument()` çağırır (`preview_widget.dart:106-126`). `textButtonSave: 'TAMAM'` / `'ONAYLA'` tanımlı ama varsayılan çubuklar gizli.
3. **Fotoğraf yönergesi diyaloğu** (`omd/omd_warp_tutorial.dart`, `OMDPhotoGuidelineDialog`; `omd_mixin.dart:32-49`): `162A40` AlertDialog, başlık "Hatırlatma", "Görselinizin buna benzer göründüğünden, ders kutularının yer almadığından emin olun.", 220 px `assets/org1.jpg`, `Bir daha gösterme`, `GERİ` (kırmızı) / `GÖNDER` (turuncu). `omd_photo_guideline_hidden` kalıcılaştırılır. Kamerada `info` butonu bu diyaloğu da açabilir (`preview_widget.dart:94`). Burada "GÖNDER" metni teknik olarak yalnız "devam" demektir.
4. **Analiz bekleme** (`omd/omd_loading.dart`, `OmdAnalyzingView`, `:1009+`): beyaz sayfa, lacivert `1F2937` app bar (logo + "SMAP" + kullanıcı avatarı), "Denemeniz\nAnaliz Ediliyor!" (28 px bold), "İşlem birkaç saniye sürebilir.", 250×250 çekilen görselin önizlemesi, 56 px spinner. Görsel base64 + `user_data` ile `POST opticimage` gönderilir. Hata → SnackBar "Hata: …" ve sayfa kapanır.
5. **Doğrulama / düzeltme** (`OmdVerificationView`, `:23, :384-863`): lacivert zemin, app bar "Form Kontrol" + turuncu `Onayla` (✓) düğmesi. Ortada `InteractiveViewer` (5×) ile sunucunun okuduğu form görseli (`opticImageFileName`). Altta iki düğme: `Düzenleme Yap` (kalem) ve `Düzenlemeler (N)` (liste).
   - **Sheet 1 "Soru Düzenle"** (`:385-523`, `showModalBottomSheet`): kolon çipleri `Kolon 1…Kolon 4`, `Soru` numara alanı, şık çipleri `A B C D E Boş`, `LİSTEYE EKLE`.
   - **Sheet 2 "Yapılan Değişiklikler"** (`:601-668`): kolona göre gruplanmış `Soru N → şık` listesi; boşken "Henüz bir değişiklik yapılmadı."
   - **Diyalog "Onaylıyor musunuz?"** (`:669-725`): "Optik formu okutma işlemini onaylıyor musunuz?", `İptal` / `Onayla`.
   - Onay → `POST answerArray`. `mexamFound` bir Map ise `OmdResultFlowView`, değilse `ExamNotFoundView`. Gönderim sırasında görselin üstünde yarı saydam spinner. Hata durumu: SnackBar "Gönderim hatası 590: …" (iç kod numarası kullanıcıya görünür). Sunucu `Left` dönerse yalnızca spinner kapanır, mesaj yok (`:589-592`).
6. **Deneme bulunamadı** (`ExamNotFoundView`, `:39-345`): app bar "Deneme Bulunamadı"; `Icons.search_off_rounded` 100 px; "Denemen Henüz Sistemde Mevcut Değil"; "Üzgünüz, bu deneme henüz sistemimizde tanımlı değil. 72 saat içinde hazırlama sözü veriyoruz."; alanlar `Yayınevi İsmi` (hint "Örn: Bilgi Sarmal"), `Deneme Adı / Seri` (hint "Örn: TYT 5. Deneme"); `Analizimi Hazırlayın`. Diyalog "Bilgileri Onayla" ("Girdiğin bilgilerle talep oluşturulacak:" + Yayınevi/Deneme satırları, `Düzenle` / `Onayla ve Gönder`) → `POST examrequest` → başarı diyaloğu "Talebin Alındı!" ("Bilgiler sistemimize kaydedildi. Analizin en geç 72 saat içinde hazır olacak.", `Ana Sayfaya Dön` → `popUntil(first)`). Yan metot `_submitRequest` (SnackBar "Talebin alındı! 72 saat içinde hazır.") ölü kod. Boş alan doğrulaması yok.
7. **Sonuç akışı** (`omd/omd_result_flow_view.dart`, `OmdResultFlowView`, 3 adım): kavisli lacivert `0F172A` başlık "Deneme Analizi", geri oku, sağda avatar. **Avatar `NetworkImage(userData['photo'])` ile yüklenir, oysa `photo` yerel asset dosya adıdır** (`:409`); fotoğraf yüklenmez, çoğu zaman bozuk/boş avatar görünür. İlerleme alanı: `1/3` + 3 çubuk + `İlerle` (**tıklaması boş**, `:455-462`).
   - **Adım 1 (`:497`):** kitap kapağı (150×200, `https://www.smaptr.com.tr/uploads/{image}`), yayınevi (`publisherName`), deneme adı (`itemName`), AYT ise `Eşit Ağırlık / Sayısal / Sözel` sekmeleri (`aytNets`), üç kutu `Net Sayısı` / `Doğru Sayısı` / `Yanlış Sayısı`, TYT dışıysa turuncu şerit **"*TYT puanınız son çözdüğünüz denemeye göre hesaplanmıştır. OBP notunuz 85 olarak alınmıştır."** (OBP 85 sabit yazılmış, `:589`), hap şeklinde anahtar `Deneme Sonucu` / `Sıralama`, içerik: ders kartları (`Doğru Yanlış Boş` ×4) veya `Yerleştirme Puanı` + `Ham Puan` kartları (`Ana Değer`, `… Sıralaması`). `Devam Et`.
   - **Adım 2 (`:1152`):** "Toplam N bilgi kartı kazandın" (N yüklenene kadar mini spinner), ders kartları gridi (2 sütun, `Net / Doğru / Yanlış` + `{n} Bilgi Kartı`). **Kart dokunuşu boş** (`onTap` yorum; `isSelected` sabit false). Sayılar `GET https://www.smaptr.com/student/getTotalInfoCard` ile gelir; istek `http` paketiyle ve `SharedPreferences['connect_sid']` çerezi ile atılır (`:226-236`). Oturum artık `PersistCookieJar` ile yönetildiği için bu anahtar yazılmıyor olabilir; çağrı yetkisiz kalabilir (başarısızlık sessizdir, spinner süresiz kalır). `Devam Et`.
   - **Adım 3 (`:1590`):** yeşil onay ikonu, "Analizin Hazır!", "Şimdi eksikleri giderme vakti!", `Anasayfaya Git` → `popUntil(first)` + SnackBar "Denemeniz Başarıyla Kaydedildi!".
   - Kullanılmayan: `_buildSwiperCard` (sabit "Monosakkarit Yapı" örnek kartı, `Sil`/`Detay`), `_buildCircleButton`, `AppinioSwiperController`.
   - Hatalı durum: `mexamFound` null ise `build` içindeki `mexam['_id']` hata fırlatır (null kontrolü yok, `:329`).

### 2.5 Analizlerim (öğrenci kök sekme 1) — `ana/screens/analytics_screen.dart`
- **Üst sekme şeridi** (`ana/widgets/analytics_tabs.dart`): `Genel` ▾/▴ · `Denemelerim` · `Analiz` · `Harita`. 32 px yükseklik, 7 radius dikdörtgen, aktif turuncu. `Genel` seçiliyken tekrar dokunmak filtre panelini açar/kapatır.
- `Analiz` (index 2) ve `Harita` (3) sekmesine dokununca **sekme değişmez**, "yakında" diyaloğu açılır:
  - Analiz: "Güçlü ve zayıf konularını takip edebileceğin ve karşılaşma ve doğru/yanlış/boş istatistiklerini görebileceğin analiz ekranı. Çok yakında hazır."
  - Harita: "Kavram Haritan" diyaloğu (Matematik/Geometri metni, web yönlendirmesi).
  - `IndexedStack`'te ayrıca `SectionPlaceholder(title)` bulunur ("**Analiz yakinda**" / "**Harita yakinda**", ASCII yazım), `ana/widgets/section_placeholder.dart`. Bu yer tutucuya yalnızca koç, "Kaynak Takibi" butonundan `initialTabIndex: 2` ile girerse ulaşılır.
- **Genel sekmesi** (`general_tab.dart`):
  1. `NetChartCard` (`net_chart_card.dart`): başlık "Deneme Net Grafiği", alt başlık `"{TYT|Eşit Ağırlık|Sayısal|Sözel} {ders adı}"`; 260 px `fl_chart` çizgisi (eğri, nokta yok, alt alan yok), Y ekseni etiketleri "{n} Net" (0..toplam soru, adım kuralı `analytics_view_provider.dart:333-353`), X ekseni gün/ay etiketleri (TR kısa ay, ilk/son dahil 6 etiket, kalanı turuncu nokta), dokunma balonu `"{x.x} Net"`. Veri yoksa tek nokta ve `Veri Yok` etiketi.
  2. `StatsGrid` (2 sütun, 4 kart): ikon, büyük değer, etiket, **sabit `+18.2%  gecen ay`**. "Genel" ders seçiliyken kartlar: `Çözülen Deneme`, `Ortalama Net`, `Ort. Sıralama`, `Ortalama Puan`; tek ders seçiliyken: `Toplam Doğru`, `Ortalama Net`, `Toplam Yanlış`, `Toplam Boş`.
  3. `LessonDistributionChartCard` ("Eksik Ders Konu Dagilimlari") yazılmış ama `GeneralTab` içinde yorum satırı (`general_tab.dart:22`).
- **Filtre paneli** (`general_filter_panel.dart`): sekmenin üstüne binen beyaz kart (radius 20, gölge). `TYT | AYT` segment; AYT seçilirse ikinci satır `Eşit Ağırlık / Sayısal / Sözel`; "Ders Listesi" 3 sütunlu çipler: TYT için `Genel, Türkçe, Tarih, Coğrafya, Matematik, Geometri, Fizik, Kimya, Biyoloji`; AYT-EA için `Genel, Türk Dili ve Ed., Tarih, Coğrafya`; Sayısal için `Genel, Matematik, Geometri, Fizik, Kimya, Biyoloji`; Sözel için `Genel, Türk Dili ve Ed., Tarih, Coğrafya, Tarih-2, Coğrafya-2` (ders ID'leri sabit gömülü, `:36-71`). Dışa dokunma kapatır.
- **Durumlar:**
  - **Yok:** yükleme göstergesi (Genel'in `loadAllData` hatası sadece `debugPrint`, `:59-61`), boş/hata durumu, pull-to-refresh (Genel'de). İlk yüklemede grafik boş/tek nokta çizer.
  - `setExamType` veriyi yenilemez, yalnızca `setAytGroup` ve `setLesson` yeniler (`:358-388`).
  - **AYT grubu sabitlenmiştir:** `final int aimType = 2; // todosmap, backend düzeltme` (`:42`), kullanıcının gerçek alanı yok sayılır.
  - Kök sekmeye Anasayfa'dan `initialTabIndex: 0` ile gelince, kullanıcı daha önce Denemelerim'deydiyse Genel'e dönülmez (`analytics_screen.dart:37-47`, sadece `!= 0` işlenir).
- **Denemelerim sekmesi** (`ana/widgets/my_test_results_tab.dart`):
  - 2 sütunlu kart gridi (`childAspectRatio 0.68`), sonsuz kaydırma (8'er; `perPage: 8`), `RefreshIndicator`, `AutomaticKeepAlive`.
  - Durumlar: ilk yükleme spinner; boş: "Henüz bir deneme sonucu bulunamadı." + `Yeniden Dene`; dipte `hasMore` ise küçük spinner.
  - **Kart** (`my_test_results_card.dart`): açık gri kart; üstte `"{net} net"` (ham string, biçimlendirme yok) ve `Deneme: {order}` rozeti; ortada kapak görseli (`https://smaptr.com.tr/uploads/{image}`, hata/boş → gri `Icons.image`), sağ üstte yıldız (yerel state, sunucuya yazılmaz; `:20, :107`), altında deneme adı (2 satır), sağ altta lacivert `Detay`.
  - **Filtre yok** (API `types/nets/dates` filtresini destekliyor ama UI sunmuyor).
- **Deneme Detay** — `ana/screens/my_test_result_detail_screen.dart`: kavisli lacivert başlık "Deneme Detay" + 4 sekmeli segment `Genel | Sorular | Konu Analizi | Bilgi Kartları` (`:138-157`). `IndexedStack`.
  - **Genel** (`:241-357`): kapak, `Deneme: {order}`, ad (`itemName`, yoksa "Smap Deneme Sınavı"), `Net Sayısı / Doğru Sayısı / Yanlış Sayısı`, TYT dışıysa yukarıdaki sabit OBP şeridi, `Deneme Sonucu | Sıralama` anahtarı. Sıralama: `Yerleştirme Puanı` + `Ham Puan` kartları (rank `formatNumber` ile nokta ayraçlı; akıştaki sürümde ayraç yok). AYT için Eşit Ağırlık/Sayısal/Sözel sekmeleri **statiktir**, `_currentType` her zaman 0 (`:264`). Ders kartları `lessonInfo` (JSON string) içinden; TYT: `Türkçe, Sosyal Bilimler, Matematik, Fen Bilimleri`; diğer: `Sosyal Bilimler - 1/2, Matematik, Fen Bilimleri` (aynı veri ve yanlış ikonlarla, `:433-462`). `lessonInfo` yoksa/eksikse bölüm sessizce boş.
  - **Sorular** (`my_test_results_detail_widgets.dart:553-717`): ders başına `ExpansionTile` (ilki açık), başlıkta yeşil/kırmızı/gri sayaç rozetleri, içinde 5 sütunlu soru kutuları (numara, ✓ / ✕ / ? ikon, alt satırda sabit `A`). Boş: "Soru verisi bulunamadı." Dokunma → Soru Detay.
  - **Konu Analizi** (`:799-1090`): `getMexamSubjectDetail`; ders başına `ExpansionTile`, içinde konu kartı (ad, `Doğru/Yanlış/Boş`, sağda 52 px dairesel yüzde: `<%20` kırmızı, `<%50` sarı (`Colors.yellow`), değilse yeşil; `:974-979`). Boş: "Analiz edilecek ders verisi bulunamadı." Hata: "Hata oluştu: …"; yüklenirken spinner.
  - **Bilgi Kartları** (`:1192-1495`): "Toplam N  bilgi kartı kazandın" şeridi + 2 sütun ders kartları (`Net`, `D`, `Y`, `N Bilgi Kartı`). Boş "Henüz veri bulunamadı.", hata "Bilgi kartları yüklenirken hata oluştu: …", yükleme spinner. **`D` (doğru) değeri `result['wrong']` ile doldurulur** (`:1234`: `lessonDetail['true'] = result['wrong']`). Ders adından ilk 4 karakter kesilir (`substring(4)`, "TYT " önekini silmek için, `:1387`). Kart dokunuşu boş (`:1354`).
- **Soru Detay** — `ana/screens/question_detail_page.dart`: lacivert başlık (ders adı + soru no) altında `TabBar` iki sekme: `Soru Analizi` (analitik ikon) ve `Soru Fotoğrafı` (görsel arama ikonu) (`:230, :240`).
  - **Analiz:** üstte beyaz açıklama kutusu (`description`, `page_info`), altta swipe'lı bilgi kartları (`CardSwiper`, `{i} / {n}` sayacı); her kartın `Detay` butonu bir diyalog açar (`:595-730`, ders içi diyaloğun aynısı), yıldız yalnızca yerel SnackBar verir ("Favorilere eklendi!" / "Favorilerden çıkarıldı!"). Boş: "Analiz kartı bulunamadı."; veri yok: "Soruya ait detay verisi bulunamadı."; hata: "Soru detayları yüklenirken bir hata oluştu:\n…" + `Tekrar Dene`. **`Tekrar Dene` gerçek isteği değil, sahte (mock) `_fetchMockRepositoryData`'yı çağırır** ve Osmanlı tarihi örnek kartlar gösterir (`:292`).
  - **Fotoğraf:** kutuda "Soruyu kaydederek **Soru Bankam** modülüne aktarırsın ve **PDF** çıktıları alabilirsin.", kamera ikonu, "Soru Fotoğrafı", "Sorunun fotoğrafı Smap'de mevcut ancak telif hakları sebebiyle sizinle paylaşamamaktayız.", turuncu `Fotoğraf Çek` butonu: **tıklaması yalnızca `print("Fotoğraf çekme başlatıldı")`** (`:546`). "Soru Bankam" uygulamada yok.

### 2.6 Derslerim (öğrenci kök sekme 2) ve ders hiyerarşisi

**Derslerim listesi — `card/my_card_page/my_card_page.dart`**
- Üst: `MyCardHeader` (`widgets/my_card_header.dart`): lacivert alan + kullanıcı barı, `title: ''` (başlık yok), yarısı taşan beyaz hap segment `TYT | AYT` (varsayılan TYT).
- Liste: `AppLessons.allLessons` içinden `type == 1/2` filtreli satırlar (`LessonBar`): sol renk şeridi (`barColor`), 64 px renkli ikon karesi (`lessonColor`), sıra rozeti, ders adı, ilerleme çubuğu, `%75`, "15/20 Konu tamamlandı", sağda `4 Alt Başlık / 26 Madde / 8 Bilgi Kartı`, ok. **Bu sayıların hepsi sabit** (`lesson_bar.dart:17-22`).
- `N Eksiğin var` kırmızı rozeti **hiçbir zaman çıkmaz:** koşul `totalCards+totalItems+totalMapItems > 0`, ama `lesson_constants.dart`'ta bu alanlar yok (0 eşleşme) ve `_processData` yalnızca `missCount/trueCount/favoriteCount` kopyalar (`my_card_page.dart:91-93, 107-111`).
- Durumlar: spinner (`_isLoading || homeProvider.isLoading`); boş "Henüz veri bulunamadı."; **hata UI'ı yok** (`print`). Pull-to-refresh yok.
- Satır dokunuşu: eşleşen genel ders (ad `contains` ile bulanık eşleşme, `:98-105`) için TYT/AYT diyaloğu yeniden sorulur (TYT sekmesindeyken bile), Matematik/Geometri "Kavram Haritan", Edebiyat/Türkçe doğrudan sayfa. Eşleşme yoksa `GeneralLesson.empty()` ile boş adlı sayfa açılır.

**Ders detayı — `ana/screens/lesson_detail_page.dart`** (Edebiyat dışı)
- Kavisli lacivert başlık: geri, ders adı (örn. "TYT Tarih"), sağda kırmızı kenarlı beyaz **Eksikler** düğmesi (kırmızı kart ikonu + sayı). Düğme **sadece `print("Eksikler butonuna basıldı!")`** (`:170`); `showOnlyMissing` sabit false.
- Başlığın altında taşan segment: API'den gelen `filterObjs` + başa eklenen `Tümü` (value 9, `:85`); her sekmenin altında eksik sayısı rozeti (`resultByType`).
- Gövde: konu (mainSubject) kartları (`_LessonsTopicCard`, `LessonBar`'ın birebir kopyası, sabit yer tutucu sayılar). Kırmızı `N Eksiğin var` rozeti burada gerçek (`resultByType`). Kart → `SubTopicDetailPage`.
- Durumlar: tam ekran spinner; boş: "Konu verisi bulunamadı."; hata sessiz (`_topicsData = null` → aynı boş mesaj).

**Edebiyat — `ana/screens/edebiyat_lesson_detail_page.dart`** (2.652 satır; `EdebiyatLessonDetailPage`)
- Aynı başlık yapısı, segment: `Yazar & Eserler | Konular` (`:365-366`); başlıktaki eksik düğmesi yine `print` (`:340`).
- `Yazar & Eserler` → ana konu listesi → dosyanın içindeki **ikinci `SubTopicDetailPage` sınıfı** (`:1070`) → yazar kartları (`AuthorCard`, `assets/authors/…` fotoğrafları) → yazar diyaloğu (`:1803`): fotoğraf, ad, "Hakkında" (biyografi, yoksa "Açıklama bulunamadı."), eserler tür başlıkları altında (`EserTypeHelper` 33 tür: Şiir, Roman, Öykü, …; bilinmeyen "Diğer"), eser satırı + durum kutusu; dokununca yeşil baloncuk **"Öğrendim"** (overlay, 1,6 sn). Eser yoksa "Kayıtlı eser bulunamadı." Öğrendim işlemi iyimser güncelleme yapar, `learnedItem` hatası **yutulur** (`catch (e) {}`, `:2350`).
- `Konular` → `subject_detail_page.dart` içindeki `SubTopicDetailPage`.

**Konu → alt başlık → madde → bilgi kartı — `ana/screens/subject_detail_page.dart`** (`SubTopicDetailPage`)
- Başlık: konu adı. Gövde: tek beyaz kart içinde **alt başlık** genişletilebilir satırları (`_MainTopicExpansionCard`): alt başlık adı (18 px; eksik içeriyorsa lacivert), `%60` sabit ilerleme, `{n} Madde`, üç sayaç (gri toplam kart, yeşil bilinen, kırmızı eksik; `information_card_*.svg`), sağda 82 px renkli konu görseli (`https://smaptr.com/subjectIcons/…`). İlk satır ve eksik içerenler açık gelir; sayfa ilk eksik satıra kayar (`_scrollToFirstAlertCard`).
- Açılınca **madde** satırları (`_SubTopicItemTile`): numara, ad (eksik varsa kırmızı), açıklama maddeleri (• 10 px), `itsIndependent != 1` ise bilgi kartı simgeleri (`information_card_with_border_red/green.svg`, 32 px). Simgeye dokunma → **bilgi kartı diyaloğu** (`:667-790`): başlık (kart adı), üst etiket (ana konu büyük harf), yıldız (yalnız yerel), kaydırılabilir içerik, `Kapat`.
- Durumlar: spinner; boş: "Bu konuya ait alt başlık bulunamadı."; hata sessiz.

**Bilgi kartları (Eksiklerim / Bildiklerim / Favorilerim)** — `card/my_card_lesson_detail_page/…` ve `card/my_cards_detail_page/…` — **kodda hazır, kullanıcıya açılmıyor** (bkz. madde 7)
- Başlık: ders adı + segment `Eksiklerim (n) | Bildiklerim (n) | Favorilerim (n)`.
- Kart: üstte kitap ikonu + konu adı, ortada alt başlık adı + yıldız, kaydırılabilir içerik (12 px), altta `Öğrendim` (yalnız eksikler sekmesinde, turuncu çerçeveli) ve lacivert `Detay`.
- Diyaloglar: "Öğrendim" onayı ("Bu kart 'Bildiklerim' kısmına kaydedilecektir ve eksiklerinizden kaldırılacaktır." + `Bir daha gösterme`, `Vazgeç` / `Tamam`), SnackBar "Kart, bildiklerin kısmına aktarıldı.", "Favori işlemi gerçekleştirilemedi.", `Detay` diyaloğu.
- Boş durumlar: "Bu kategoride bilgi kartınız bulunmamaktadır." / "Henüz başarılı kartınız bulunmuyor." / "Favoriye eklenmiş kartınız bulunmuyor." / "Görüntülenecek kart kalmadı."
- Ölü yardımcılar: `MyCardLessonGridItem` (`Eksik/Doğru/Favori`, `Detay`), `MyCardSummaryCard`, `my_card_dummy_data.dart` (sahte ders/kart verisi).

### 2.7 Program / Takvim (öğrenci: Anasayfa → Programım; koç: öğrenci diyaloğu veya Öğrencilerim → Program)

**Program listesi — `sched/my_schedule_page.dart`, `schedule_list_page/…`**
- Üstte araç satırı: sol turuncu filtre butonu, ortada `Program Ara` arama alanı, sağ turuncu `+` (`schedule_list_toolbar_row.dart`).
- Gövde: 2 sütun kart gridi (`childAspectRatio 0.75`); kart: üstte sabit `assets/icons/calendar.png`, program adı (`name`, yoksa "Başlık Yok", turuncu), `motto`, lacivert `Program Detayı` (`schedule_list_card.dart`).
- **Filtre paneli** ("Filtrele" / "Filtreleri Temizle", "Tarih aralığı": `Son 30 Gün`, `Son 3 Ay`, `Bu Dönem`, `Filtrele` düğmesi) yalnızca görseldir: `onApply` sadece kapatır, `onClear` boş, seçimler listeye uygulanmaz (`schedule_list_page.dart:193-196`). **Arama alanı da listeyi süzmez** (controller dinlenmiyor).
- Durumlar: yükleme spinner (turuncu); **boş ve hata durumu yok** (grid sessizce boş). `/student/getMyWeeklies` yanıtındaki `bagItems` SharedPreferences `bagItemsStr`'e yazılır.

**Gün seçimi — `sched/day_selection_page/day_selection_page.dart`**
- Lacivert kavisli çubuk "Gün Seçimi" + geri; ipucu "Program oluşturmak istediğiniz günleri seçiniz"; ay takvimi (çoklu seçim, `Pt Sal Çar Per Cu Cmt Paz`); sağ altta FAB `İleri ▸` (seçim yoksa %50 saydam ve pasif).
- Seçim olmadan ileri: diyalog "Takvimden gün veya günler Seçiniz" / "Takvimden gün veya günler seçimi yapınız." / `Tamam`.

**Program detayı / ders ekleme — `sched/add_lessons_page/…`**
- Başlık "Program Detayı" (`AddLessonsTopHeader`); altında segment `Çantam (n)` (`assets/icons/bag.svg`, eksik madde sayısı) ve `Dersler`. Bir konu seçildiğinde segment yerine turuncu "yerleştirme modu" şeridi (ders adı, konu adı, `Bitir`).
- `Çantam`/`Dersler` → **konu seçim diyaloğu** (`add_topic_popup.dart`, "Konu Seçimi Yapın", iki sekme, "Çantanızda konu bulunamadı.", "Bu derse ait konu bulunamadı.").
- Gün seçici (`<  Pt 12  …  >`), tarih başlığı ("{gün} {Ay}" veya "{a} - {b}", seçim yoksa "Gün seçilmedi"), sıfırla ikonu; **saat çizelgesi 06:00–23:00, saatlik** (`startHour 6, endHour 23, intervalMinutes 60`, `add_lessons_page.dart:19-21`). Satır boşsa "Konu Ekle" (yerleştirme modunda "Buraya Ekle", kilitliyken "Boş Saat"); doluysa konu çipleri + "Bir konu daha ekle".
- Ekran dışında kalan dersler için yüzen oklu rozetler: "↑ N Ders" / "↓ N Ders".
- Alt FAB: yeni programda `Programı Tamamla`; mevcut programda `Programı Düzenle` → `Değişiklikleri Kaydet` (yükleme: `Kaydediliyor...`) + iptal.
- Diyaloglar: "Günü Sıfırla" ("Bu güne eklediğiniz tüm dersler temizlenecektir. Onaylıyor musunuz?", `Vazgeç`/`Sıfırla`); "Programı Tamamla" ("Lütfen programınız için gerekli bilgileri girin.", `Program Adı *`, `Motivasyon Cümlesi`, `Vazgeç`/`Kaydet`); "Değişiklikleri İptal Et" ("Yaptığınız düzenlemeler silinecek ve orijinal programa geri dönülecektir.", `Vazgeç`/`Geri Al`).
- SnackBar'lar: "Sıfırlanacak ders girdisi bulunmuyor.", "Seçili günün programı sıfırlandı.", "Lütfen önce programınıza ders ekleyin.", "Program başarıyla kaydedildi!", "Kayıt sırasında bir hata oluştu."
- **Veri:** `POST /student/addNewProgram` / `/student/updateProgram` (koçta `studentId` eklenir). Görev nesnesi: `{id, day, hour, minute, lesson, lessonName, mainSubject, subject, item, title, category:"0", lessonColor, mapImage}` (`add_lessons_page.dart:~690`). **Yok:** çakışma kontrolü, aynı saate birden fazla konu limiti, program silme.
- **Koç görünümü:** `TeacherViewScheduleScreen` (`home/screens/coach_programs_screen.dart`): lacivert `AppBar` (avatar + öğrenci adı + geri) içinde aynı `MySchedulePage(studentId)`.

### 2.8 Hesap (kök sekme 3)

**Hesap hub — `prof/account/account_screen.dart`:** gri-beyaz satır kartları (radius 12, ikon + başlık + sağ ok): `Profilim ve Şifre`, `Ödeme ve Paketler`, `Kayıtlı Kartlarım`, `Sözleşmeler`, `Bildirimler`; ayraç; kırmızı `Çıkış Yap` (ok yok). Çıkış diyaloğu: ikonlu "Çıkış Yap?" / "Hesabınızdan çıkış yapmak istediğinize emin misiniz?" / `Vazgeç` / `Çıkış Yap` → `/ajax/logout`, çerezler ve `user_data` silinir, `/login`.

**Profilim ve Şifre — `prof/account_settings/account_settings_screen.dart`** (1.179 satır)
- Lacivert kavisli bant + taşan 88 px profil avatarı (`AccountSettingsNavyHeader`).
- **Hesap Bilgileri** (`:807`): `Ad Soyad`, `E-Mail Adresi`, `Telefon Numarası`, `Öğrenci Koçluğu` bölümü, `Ülke`, `Şehir`; üstte `Düzenle`/vazgeç, altta `Kaydet`. Düzenleme kapalıyken alanlar kilitli.
- **Öğrenci Koçluğu** üç hali: yüklenirken spinner kutusu; koç varken avatar + ad + (düzenlemede) `Değiştir` / `Sil`; koç yoksa "Bir Koça Bağlı Değilsiniz" ve kod alanı (`hint: Kod Giriniz`) + `?` bilgi ikonu. `Koçluk Kodu Nedir?` diyaloğu uzun açıklamayla (öğrenci / koç için ayrı metin). Koç rolünde alan kendi `refCode`'unu gösterir.
- **Şifre ve Güvenlik** (`:1045`): `Mevcut Şifre`, `Yeni Şifre`, `Yeni Şifre Tekrar` (göz ikonları), `Şifreyi Güncelle`. **İşlev sahte:** yalnızca iki yeni şifrenin eşleşmesine bakar ve "Şifreniz başarıyla değiştirildi." gösterir (`:749-772`); API çağrısı yok.
- **Hesabımı Sil** (kırmızı çöp ikonu, `:1144`): diyalog "Hesabınızı Silmek İstediğinize Emin Misiniz?" / "Bu işlem geri alınamaz. Hesabınız ve tüm kişisel verileriniz kalıcı olarak silinecektir." / `Vazgeç` / `Evet, Sil`; kırmızı spinner, başarıda yeşil SnackBar "Hesabınız başarıyla silindi.", `/login`. Hata: "Bağlantı hatası oluştu, lütfen tekrar deneyin."
- Diğer SnackBar'lar: "Herhangi bir değişiklik yapılmadı.", "Profil bilgileriniz güncellendi ve koçunuz eklendi.", "…fakat koç eklenemedi: …", "Koç bağlantısı başarıyla kaldırıldı." vb. `Bağlantıyı Kopar?` diyaloğu ("Mevcut öğrenci koçunuzla olan bağınızı koparmak istediğinize emin misiniz? Bu işlem sonucunda koçunuz gelişim takibinizi göremeyecektir.", `Vazgeç`/`Bağlantıyı Kopar`; sırasında "Bağlantı kesiliyor..."). `deleteCoach` repo çağrısı `coachId`'yi göndermez (`profile_repository.dart:35-41`).
- **Yok:** profil fotoğrafı/avatar değiştirme (avatar yalnız kayıtta seçilir), e-posta/telefon doğrulama, sınıf/alan düzenleme.

**Ödeme ve Paketler — `prof/payment_settings/payment_settings_screen.dart` — tamamen sahte**
- `CurrentPlanCard`: "Plan: Yıllık Avantaj - 12 Aylık", "249 ₺ / Aylık", turuncu `Planı Değiştir` (**`onPressed` verilmiyor → pasif**).
- Fatura tablosu: başlık `Fatura Numarası` ▾, `Kesilme Tarihi` ▾; satırlar `Invoice #1023 …` ve **İngilizce ay kısaltmalı** tarih (`May 15, 2022`), 68 sayfalık sahte sayfalama (`InvoicePagination`: `Geri`, `İleri`, `…`). Veri: `PaymentInvoiceMock`.

**Kayıtlı Kartlarım — `prof/saved_cards/saved_cards_screen.dart` — sahte:** 3 sabit kart (Mastercard 5678, Visa 1234 `Varsayılan` rozetli ve lacivert çerçeveli, Visa 7892), `**** **** **** 1234` biçimi, sağda `⋮` (tıklama yok), alt `Yeni Kart Ekle` (turuncu, `onPressed: () {}`, radius 6).

**Sözleşmeler — `prof/contracts/contracts_screen.dart` — gerçek:** `GET /ajax/getLegalDocuments` → kartlar (`contract_icon.png`, başlık 18 px, göz ikonu); kart tamamı dokununca `AlertDialog` (`Html` render, `Kapat`). Durumlar: spinner; hata "Sözleşmeler yüklenirken bir hata oluştu." + `Tekrar Deneyin`; boş "Gösterilecek sözleşme bulunamadı." "Okudum, onaylıyorum" onay kutusu yorum satırı; `isApproved`/`onApprovedChanged` kullanılmıyor, göz ikonunun `onViewTap`'ı verilmiyor.

**Bildirimler — `prof/notifications/notifications_screen.dart` — sahte:** 6 anahtar: `Aktif`, `Bildirimleri Aç`, `Kullanıcılar Görebilsin`, `Varsayılan Bildirim`, `Mobilde Göster`, `Otomatik Güncellemeleri Aç` (bir şablon panelinden kopyalanmış, öğrenci bağlamıyla ilgisiz etiketler); `Değişiklikleri Kaydet` (`onPressed: () {}`). Yalnızca yerel state; push bildirimi kodu yok.

### 2.9 Koç modu

**Öğrencilerim (kök sekme 1) — `kocS/my_students_screen.dart`**
- Üstte `Öğrenci ara` arama alanı (istemci tarafı ad süzgeci) ve turuncu `+`. Gövde: 2 sütun öğrenci kartı gridi; boş: "Öğrenci bulunamadı."
- **`StudentCard`:** avatar (yoksa baş harfler), ad, `"{seasonType} (Sınıf)"`, ve **her öğrenci için sabit `"Başarısız (Derece)"`** (`student_card.dart:27, 119`); 4 buton `Analiz`, `Denemeler`, `Kaynak Tkp.`, `Program`. `Kaynak Tkp.` → "Analiz yakinda" yer tutucusu. Kartın kendi `onTap`'ı sadece `debugPrint`.
- **`AddStudentDialog` (`kocS/add_student_dialog.dart`):** "Öğrenci Ekle"; avatar seçici; `Öğrenci Adı`/`Ad`, `Öğrenci Soyadı`/`Soyad`, `Kullanıcı Adı` + `Kontrol Et` (gerçek `/ajax/checkUsername`), `Şifre` + `Oluştur` (10 karakterlik rastgele şifre üretici) + göz ikonu, `Sınıf` (`9–12. Sınıf`, Mezun yok), `Alan Seçimi` (9–10 için gizli; `Sayısal, Eşit Ağırlık, Sözel, Dil`), `Öğrenciyi Kaydet`; "Bilgilendirme: Yeni oluşturulan öğrenci sistemi kullanarak kendi paneline giriş yapabilir ve ödevlerini/sınavlarını takip edebilir." Doğrulama mesajları "Ad alanı boş bırakılamaz" vb.
- Tüm ekranlarda öğrenci listesi `HomeProvider.coachStudents` paylaşımlıdır; yeni öğrenci `addStudentToLocalList` ile eklenir.

**Görüşmelerim (kök sekme 2) — `kocG/interviews_screen.dart`** (`GorusmeFlowScreen`)
- Üstte `Öğrenci ara` + turuncu `+`; liste `InterviewCard`: avatar (`assets/avatars/{photo}`), öğrenci adı, tarih (`d MMMM`, yıl yok, turuncu), tür (`Öğrenci Görüşmesi` / `Veli Görüşmesi`, soluk gri 11 px), sağda ok. Sayfalama 8'er, `RefreshIndicator`, sonsuz kaydırma. Boş: "Görüşme bulunamadı."; hata: SnackBar "Veriler yüklenirken bir hata oluştu: …".
- **Arama çalışmaz:** her tuş vuruşunda yenileme isteği atılır ama `_searchQuery` API'ye gönderilmez (`:132-139`).
- **`NewInterviewDialog` (`:422+`):** "Yeni Görüşme" + kapat; `Öğrenci` bölümü (`Görüşme Yapılacak Öğrenciyi Seçin` → "Öğrenci Seçiniz" listesi, "Kayıtlı öğrenci bulunamadı."; seçilince "Seçilen Öğrenci"), `Görüşme Türü` (`Öğrenci Görüşmesi` / `Veli Görüşmesi` çipleri), `Tarih` (`Tarih Seçiniz`, `showDatePicker`), `Saat` (`Saat Seçiniz`, `showTimePicker`), `Görüşmeyi Kaydet`. SnackBar'larda emoji: "Görüşme başarıyla eklendi! 🎉". İlk metot `_showStudentSelectionDialog` (`:184`) ölü kopya.
- **Görüşme Detayı — `kocG/interview_detail_screen.dart`:** app bar "Görüşme Detayı"; öğrenci avatarı, ad, tarih, tür; "Görüşme Notları" + `Not Ekle`; not kartları (saat ikonu + `d MMMM yyyy, HH:mm`, düzenle/sil ikonları); boş: "Henüz not girilmemiş." Diyaloglar: "Yeni Not Ekle" ("Bu görüşme için yeni bir not yazın:", hint "Yeni Görüşme notu", `İptal`/`Kaydet`), "Notu Düzenle" ("Görüşme notunu güncelleyin:", `Vazgeç`/`Güncelle`), "Notu Sil" ("Bu görüşme notunu silmek istediğinize emin misiniz? Bu işlem geri alınamaz.", `İptal`/`Sil`). SnackBar'lar emojili ("Not başarıyla eklendi! 🎉", "Not başarıyla güncellendi! 🎉").

### 2.10 Olmayan veya "yakında" olan ekranlar (aranan listeyle karşılaştırma)
- **Gelen Kutusu / inbox:** yalnızca "yapım aşamasında" diyaloğu (rozet kodu yorum satırı).
- **SmapLab:** yalnızca diyalog (varlıklar `assets/menuIcons/button.png` vb.).
- **Bildirim merkezi, push, Soru Bankam, Hata Kitapçığı/PDF, flashcard quiz:** yok.
- **Bilgi kartı swipe ekranı:** kodda var ama ulaşılamıyor (madde 0.7).
- **Premium/paket:** yalnızca sahte plan kartı.
- **Kavram Haritası (Matematik/Geometri):** mobilde yok, sadece web yönlendirme metni.

---

## 3. Sheet ve dialog envanteri

Canlı kodda yalnızca **2 bottom sheet** vardır (ikisi de optik doğrulama ekranında). Geri kalan 36 `showDialog` çağrısı (21 `AlertDialog`, 9 düz `Dialog`) ve 107 `SnackBar` bir arada, tek tip bir stil olmadan kullanılır.

| # | Amaç | Dosya:satır | Stil |
|---|---|---|---|
| S1 | Optik okuma: "Soru Düzenle" | `omd/omd_loading.dart:385` | Bottom sheet, `isScrollControlled`, üst köşe 20, tutamaç yok (tutamaç çubuğu elle çizilmiş) |
| S2 | Optik okuma: "Yapılan Değişiklikler" | `omd/omd_loading.dart:601` | Bottom sheet, üst köşe 20, sabit yükseklik |
| D1 | "Yakında / Çok Yakında!" | `home/widgets/app_dialog.dart:18` | `AlertDialog`, radius 20, beyaz, ikon + turuncu başlık + tam genişlik düğme + `Kapat` |
| D2 | TYT/AYT/SOS-2 ders türü seçimi | `home/widgets/lesson_navigation_helper.dart:81` | `AlertDialog`, radius 12, sayısal rozetli renkli düğmeler |
| D3 | Koç: öğrenci kartı diyaloğu | `home/widgets/home_students_cards.dart:129` | Saydam `Dialog`, radius 16 kart, 2×2 gri düğme |
| D4 | Çıkış onayı | `prof/account/account_screen.dart:14` | `AlertDialog`, radius 12, kırmızı ikonlu başlık |
| D5 | Hesap silme onayı | `account_settings_screen.dart:153` | `AlertDialog`, radius 12, kırmızı `Evet, Sil` |
| D5b | Hesap silinirken yükleniyor | `account_settings_screen.dart:205` | Modal, yalnızca kırmızı spinner |
| D6 | Koçluk kodu açıklaması | `account_settings_screen.dart:520` | `AlertDialog` |
| D7 | Koç bağlantısını kopar | `account_settings_screen.dart:590` | `AlertDialog` (içte "Bağlantı kesiliyor…" durumu) |
| D8 | Sözleşme içeriği (HTML) | `contracts_screen.dart:53`, `register_form.dart:214` | `AlertDialog` + `Html` (iki ayrı kopya) |
| D9 | Program: gün seçilmedi | `day_selection_empty_dialog.dart:5` | `Dialog`, radius 16, lacivert `Tamam` |
| D10 | Program: konu seç (Çantam/Dersler) | `day_selection_page.dart:88`, `add_lessons_page.dart:363` | `Dialog` (`AddTopicPopup`), iki sekmeli |
| D11 | Günü sıfırla / Programı tamamla / Değişiklikleri iptal et | `add_lessons_page.dart:311, 410, 932` | `AlertDialog`; "Programı Tamamla" formlu, `barrierDismissible: false` |
| D12 | Koç: yeni görüşme / öğrenci seç / not ekle-düzenle-sil | `interviews_screen.dart:147, 490`; `interview_detail_screen.dart:123, 239, 392` | `Dialog`/`AlertDialog` (barrier kapatılamaz, form) |
| D13 | Koç: öğrenci ekle | `kocS/my_students_screen.dart:102` | `Dialog` (`AddStudentDialog`), uzun form |
| D14 | Optik: yönerge "Hatırlatma" | `omd_mixin.dart:36`, `preview_widget.dart:18` | `AlertDialog`, koyu `162A40`, radius 16 |
| D15 | Optik: onay, yükleniyor, deneme bulunamadı onay ve başarı | `omd_loading.dart:70, 106, 165, 672` | `AlertDialog` radius 20; ayrıca tam ekran spinner diyaloğu |
| D16 | "Öğrendim" onayı | `card/my_cards_detail_page/widgets/my_card_info_card.dart:103` | `AlertDialog` (ulaşılamayan akışta) |
| D17 | Bilgi kartı detayı | `subject_detail_page.dart:672`, `question_detail_page.dart:595`, `card/my_cards_detail_page/my_cards_detail_page.dart:114`, `edebiyat…:1827` (yazar) | `Dialog`, radius 24, ekranın %70'i, `Kapat` (üç kopya) |
| D18 | Yazar kartı diyaloğu | `edebiyat_lesson_detail_page.dart:1827` | `Dialog` ("Hakkında" + eserler) |
| O1 | "Öğrendim" baloncuğu | `edebiyat_lesson_detail_page.dart:2243` | `OverlayEntry`, yeşil baloncuk + kuyruk, 1,6 sn |
| P1 | Tarih / saat seçici | `interviews_screen.dart:438, 463` | Sistem `showDatePicker`/`showTimePicker` (tr locale) |
| ölü | Ders türü bottom sheet | `home/widgets/home_lessons_cards.dart:176` | Standart sheet, radius 24 (**çağrılmıyor**) |
| ölü | Bulanık filtre diyaloğu | `ana/widgets/general_filter_panel.dart:468` | `showGeneralDialog` + `BackdropFilter` (**çağrılmıyor**) |

**Tutarsızlıklar:** diyalog köşe radiusu 12/16/20/24 arasında değişir; bazıları `surfaceTintColor` temizler (beyaz), bazıları temizlemez; kapat/vazgeç etiketleri `Vazgeç`/`İptal`/`Kapat`/`Geri Al`/`Tamam`; yıkıcı eylem rengi bazen `redAccent` bazen `Colors.red`. "Yakında" diyaloğunun varsayılan vurgu rengi `Colors.indigo`, çağrıların çoğunda lacivert `appBarBackground`.

SnackBar geri bildirimi: tema `floating` (`app_theme.dart:16-18`); mesajlarda emoji (🎉, 🔴, 📍) kullanımı, `Hata:` öneki, iç hata numaraları ("Gönderim hatası 590") ve ham `Exception` metinleri vardır.

---

## 4. Paylaşılan bileşenler ve tekrarlar

### 4.1 Paylaşılan (kullanılan)

| Bileşen | Dosya | Kullanım |
|---|---|---|
| `AppColors` | `core/theme/app_colors.dart` | 79 dosyada 479 referans |
| `AppTheme.light` | `core/theme/app_theme.dart` | Sadece scaffold rengi, AppBar teması, snackbar, progress rengi; metin/buton teması yok |
| `AppUserAvatar` (`.compact` varyantı ölü) | `features/shared/…/app_user_avatar.dart` | Üst bar, kişi kartı; `assets/avatars/{photo}`, hata → `person_rounded` |
| `NavyHeaderBand` / `HomeNavyHeaderBand` / `AccountSettingsNavyHeader` | `shared/…/navy_header_band.dart`, `home/widgets/…`, `prof/account_settings/widgets/…` | Lacivert bant (3 varyant) |
| `CustomTopAppBar` + `AppHeaderUserSection` | `root/widgets/…` | Kök ekran üst barı; `MyCardHeader` içinde de kullanılır |
| `AppDialogs.showUnderConstruction` | `home/widgets/app_dialog.dart` | 9 çağrı |
| `LessonNavigationHelper` | `home/widgets/lesson_navigation_helper.dart` | Ders kartı + Derslerim satırı |
| `LessonBar` | `ana/screens/lesson_bar.dart` (adı ve yeri tutarsız: analytics içinde, Derslerim'de kullanılıyor) | Derslerim satırı |
| `MyTestResultsDetailTopTabButton` | `ana/widgets/my_test_results_detail_widgets.dart:398` | Deneme Detay + Bilgi kartları başlığı |
| `ScheduleListAddButton` | `sched/schedule_list_page/widgets/schedule_list_add_button.dart` | Program listesi + Öğrencilerim |
| `RoleToggleButton`, `SocialProviderIcon` | `auth/widgets/` | Kayıt + sosyal kayıt |
| `AccountMenuTile`, `NotificationToggleTile`, `ContractCard`, `SavedCardWidget`, `Invoice*`, `AccountSettingsTextField/PasswordField` | `prof/…/widgets/` | Hesap alt ekranları |
| `PageContainer` | `shared/…/page_container.dart` | Kullanılmıyor |

### 4.2 Tekrarlar ve yarı-ölü kod
- **Yinelenen sınıf adı:** `SubTopicDetailPage` iki ayrı dosyada (`subject_detail_page.dart:?`, `edebiyat_lesson_detail_page.dart:1070`); `AnalyticsLesson` iki dosyada (`analytics_filters.dart:14`, `general_filter_panel.dart:8`).
- **Konu kartı 3 kopya:** `LessonBar` (`card/…/lesson_bar.dart`), `_LessonsTopicCard` (`lesson_detail_page.dart:510`), `_LessonsTopicCard` (`edebiyat…:700`). Bir de `my_test_results_detail_widgets.dart:952`'de aynı isimli, farklı bir kart.
- **Bilgi kartı detay diyaloğu 3-4 kopya** (bkz. D17).
- **Ders/eşleme tabloları:** `lessonNameAndPhoto` iki ayrı yerde (`omd/omd_result_flow_view.dart:8`, `my_test_results_detail_widgets.dart:1100`), bir üçüncüsü `my_card_dummy_data.dart:63`; ders ID tabloları `lesson_constants.dart`'ta ve `general_filter_panel.dart:36-71`'de ayrı ayrı.
- **Sonuç ekranı kopyası:** `OmdResultFlowView` ve `MyTestResultsDetail*` aynı kartların iki yazımıdır (`ScoreCard`, `SubjectCard`, `MainStatBox`, `TytInfoBanner`).
- **Üst başlık varyantları:** `CustomTopAppBar`, `NavyHeaderBand`, `MyCardHeader`, `MyCardLessonDetailHeader`, Deneme Detay başlığı, `_buildCustomHeader` (lesson/edebiyat/subject/question sayfalarında ayrı ayrı), `DaySelectionTopAppBar`, `AddLessonsTopHeader`, `AppBar` (koç sayfaları) — en az 9 farklı başlık yazımı.
- **Ölü/yarım kod:** `views/auth/login_view.dart`, `views/onboarding/onboarding_page.dart`, `views/main_webview/*`, `repository/optic_requests/*.dart` ile `requests/` altındaki aynı dosyalar (iki kopya), `PageContainer`, `MyTestResultsDetailTabPlaceholder`, `LessonDistributionChartCard`, `AnalyticsGeneralData.mock()`, `_buildGeneralData`, `MyCardLessonGridItem`, `MyCardSummaryCard`, `_PreviewTopInfoWidget`, `GoogleAuthService`, `SocketConstants` (LAN IP `ws://192.168.1.164:5000`, `web_socket_channel`), `_DashedBorderBox`, `showBlurredFilterDialog`.

---

## 5. Alan sözlüğü (modellerden)

- **Deneme (`mexam`)**
  - Tür: `mexam.type == 1` TYT, aksi AYT (`my_test_result_detail_screen.dart:254`). `ExamType` enum: `tyt=1`, `ayt=2`, `yks=3` (`yks` UI'da yok; `ana/models/analytics_filters.dart:1-12`).
  - Alanlar (map, tipli model yok): `mexam.order`, `mexam.image`, `itemName`, `publisherName`, `net`, `true`, `wrong`, `pass`, `points`, `pointsHam`, `ranks`, `ranksHam`, `lessonInfo` (JSON **string**: 4 elemanlı `{true, wrong, pass}` listesi), `questionsArrStr` (JSON string; `{order, type}` listeleri), `lessonmockexams` / `lessonMockExams` (ders başına `{lesson, net, true, wrong, pass}`; **iki farklı yazım**), `aytNets` (anahtar 2/3/4 → `{net, true, wrong, pass}`), `isStarred`.
  - Optik yanıt modelleri: `ImageResponseModel`, `AnswerResponseModel` (`mexamFound`, `answersArray`, `opticImageFileName`, `originalImageFileName`, `success`; `domain/models/*_model.dart`).
- **Net hesabı:** istemcide hesaplanmaz; backend `net` alanı gelir. İstemci yalnızca ortalama alır: `averageNet = Σnet / deneme sayısı` (`analytics_view_provider.dart:241`) ve backend'in `ortNet` değerini 2 ondalıkla gösterir (`:262`). Ondalık biçimi tutarsız: kartlar 2 hane, grafik balonu 1 hane, deneme kartı/detayı ham string. Doğru−yanlış/4 formülü kodda yok.
- **Soru durumu:** `type` 1 = doğru, 3 = yanlış, diğer (2) = boş (`my_test_results_detail_widgets.dart:594-601, 719-742`). Konu analizinde "başarı %" = `doğru / (doğru+yanlış+boş)`, net değil (`:968`). Konu verisinde `trueValue`, `wrongValue`, `passValue`, `netRate` gelir (`netRate` gösterilmez).
- **Toplam soru sayıları:** `allLessons.totalQuestion` — TYT: Türkçe 40, Tarih 5, Coğrafya 5, Matematik 30, Geometri 10, Fizik 7, Kimya 7, Biyoloji 6; AYT: Edebiyat 24, Tarih 10, Coğrafya 6, Tarih-2 11, Coğrafya-2 11, Matematik 30, Geometri 10, Fizik 14, Kimya 13, Biyoloji 13 (`core/constants/lesson_constants.dart`). Grafik Y ekseni varsayılanı TYT 120, diğer 80 (`analytics_view_provider.dart:155`); Y adım kuralları `{120:30, 80:20, 40:5, 30:5, 24:4, 5/6/7:1}`.
- **TYT / AYT / SOS-2:** ders türü seçimi `examType` ("TYT", "AYT", "SOS2") ile; `defaultFilterValue` 1 (TYT), 2 (AYT) veya 3 (AYT Tarih/Coğrafya), 4 (SOS-2), 9 (Tümü). `SOS-2` yalnızca Tarih ve Coğrafya için gösterilir (`lesson_navigation_helper.dart:122-131`).
- **Alan (`aimType`):** **tutarsız eşleme**:
  - Kayıt formu, üst bar, AYT grubu enum'u: `2 = Eşit Ağırlık`, `3 = Sayısal`, `4 = Sözel` (`register_form.dart:163-175`, `header_user_section.dart:17-22`, `analytics_filters.dart:21-25`).
  - Koç "Öğrenci Ekle": `Sayısal=1`, `Eşit Ağırlık=2`, `Sözel=3`, `Dil=4` (`kocS/add_student_dialog.dart:103-108`) — Sayısal/Sözel/Dil kodları diğer yerlerle çakışıyor; "Dil" başka hiçbir yerde yok.
  - Varsayılanlar: `UserModel.fromJson` `aimType ?? 2` (`user_model.dart:25`), Analizlerim `aimType = 2` (sabit, `:42`), sonuç akışı `aimType ?? 3` (`omd_result_flow_view.dart:128`).
  - 9-10. sınıf öğrencide alan yoktur (`null`).
- **Sınıf (`seasonType`):** 9, 10, 11, 12; `Mezun = 13` (kayıt), koçta 0. Gösterim tutarsız: `"{n}. Sınıf"` (öğrenci diyaloğu), `"{n} (Sınıf)"` (öğrenci kartı).
- **Ders / Konu / Alt başlık / Madde / Bilgi kartı hiyerarşisi:**
  1. **Ders** (`GeneralLesson`: `_id, name, image, order, tytAyt, mindMap, stats{ '1','2','3','total' }` — 9 genel ders: Türkçe, Tarih, Coğrafya, Edebiyat, Matematik, Geometri, Fizik, Kimya, Biyoloji; `allLessons` 18 satır: 8 TYT + 10 AYT).
  2. **Konu** = `mainSubject` (UI'da bazen "Konu", `getMainSubjects` → `subjects`).
  3. **Alt başlık** = `subSubject` (`getSubSubjects`), UI'da genişletilebilir kart başlığı (`_MainTopicExpansionCard.categoryTitle`).
  4. **Madde** = `item` (`name`, `desc[]`, `itemData{status, statusArray, prompts[], itsIndependent}`), UI'da numaralı satır; sayaç "{n} Madde".
  5. **Bilgi kartı** = `prompt` (`title`, `content`/`text`), simgesi madde altında; `statusArray` her kart için `0 = eksik/kırmızı`, `1 = biliyor/yeşil`.
  - Kart ekranlarında kategori adları: `failedCards` (Eksiklerim), `successCards` (Bildiklerim), `favoriteCards` (Favorilerim); sayaçlar `missCount/trueCount/favoriteCount`. Üçüncü toplam: `totalCards + totalItems + totalMapItems` ("kavram haritası maddesi").
  - **Eksik:** `status == 0` veya `statusArray` içinde 0 (`subject_detail_page.dart:84-100`). "Öğrendim" işlemi `learnedCard` / `learnedItem` ile durumu 1 yapar.
  - **Edebiyat** ek katman: yazar → eser (`type` → `EserTypeHelper`, 33 tür), `itemData.status` '0'/'1' (string).
- **Koç / öğrenci:** `Student` (`_id, name, userName, password, photo, schoolNo, totalMexam, status, seasonType, aimType, registerType, email, degreePoint, date, firstName, surname, phone, coach`) — **modelde `password` alanı vardır ve JSON'a geri yazılır** (`student_model.dart:8, 130`). Koçluk kodu `refCode`; öğrenci `addCoach?code=…`, `deleteCoach`, `getStudentsCoach`.
- **Görüşme:** `type` 1 = öğrenci görüşmesi, 2 = veli görüşmesi; `date` (ISO), `student`, `notesStr` (JSON string, `[{…tarih, metin}]`); uçlar `getInterviews` (sayfalı, `filter{types,dates}`), `addNewInterview`, `addNewNote`, `editNote`, `deleteNote`.
- **Program / görev:** bkz. 2.7 (`weeklies`: `name`, `motto`, `content`/`tasks`; `bagItems` = çanta). Saatlik 06:00–23:00.
- **Elmas / coin / seri:** `UserModel.points` (int, varsayılan 0) `smapc.png` ikonuyla gösterilir; `progress` (0–1 double) ilerleme çubuğu ve yüzdesi. Backend'in bu iki alanı gerçekten döndürdüğü kodla doğrulanamaz; dönmezse 0 / %0 görünür. Kazanma/harcama, seri/streak, rozet mantığı kodda yoktur (placeholder değil, hiç yok).
- **Premium / paket:** yalnızca statik `CurrentPlanCard` metni ve `PaymentInvoiceMock`; satın alma, kupon, deneme süresi, ücretsiz-ücretli ayrımı kodda yok.
- **Yasal belgeler:** `LegalDocument` (`name`: `kullanim_kosullari`, `kvkk_aydinlatma_metni`, `gizlilik_politikasi`; `title`, `version`, `content` (HTML), `isActive`).

---

## 6. Çapraz sorunlar

**Renk, tipografi, köşe (koddan sayılar, `lib/vendor` hariç)**
- `Color(0x…)` sabiti **424 yerde, 154 benzersiz değer**; `Colors.*` **1.147**, `AppColors.*` yalnızca 479; `withOpacity` 75 (kullanımdan kalkmış API).
- **Lacivert varyantları:** `162A40` (×23), `0D2744` (×16), `0F294A`/`appBarBackground` (7 + 66 kullanım), `1A365D` (×6), `1F2937` (×6), `0F172A` (×4), `1E344A`, `10284A`, `0D2344`, `1A237E` (×11), `2B3D54`, `3D526D`, `436C95`. Tek marka lacivertinin en az 10 farklı yazımı var.
- **Turuncu varyantları:** `FF6600` (primary), `FF7A00` (gösterge), `FF8A00` (accent), `FF6D00`, `FF6F00`, `F97316`.
- Gri/çerçeve: `E8ECF0`, `E2E8F0`, `E8EAED`, `F3F4F6`, `F1F5F9`, `F5F7F9`, `64748B`, `94A3B8` vb. aynı amaç için farklı değerler.
- `fontSize:` 429 yerde, 18 farklı değer (9, 10, 10.5, 11, 12, 12.5, 13, 14, 15, 16, 17, 18, 20, 22, 24, 26, 28, 32); `TextTheme` kullanımı yok, her metin elle biçimlendirilmiş.
- `BorderRadius.circular(n)`: 12 (×115), 16 (×55), 8 (×47), 10 (×44), 20, 6, 24, 4, 14, 15, 30, 99 — token yok.
- Kod içi Türkçe metin: `Text(` **581** çağrı, hepsi gömülü; ARB/gen_l10n yok.

**Erişilebilirlik**
- `Semantics*`: 0. `Tooltip`/`tooltip:`: 5 (yalnızca birkaç yerde). `textScaler`/`textScaleFactor`: 0 (yazı büyütmede taşma riski; birçok yerde sabit yükseklikler: alt bar 72, kartlar 100 px vb.).
- İkon-only düğmeler (`IconButton`, kamera, yıldız, `⋮`, göz, geri) semantik etiket taşımaz. Kamera butonu `GestureDetector`.
- Renkle anlam: yeşil/kırmızı/gri (doğru/yanlış/boş, eksik/biliyor) için yalnızca renk ve küçük ikon; 9–11 px yazılar çok.
- Dokunma hedefleri: birçok çip/düğme 22–32 px (örn. durum kutuları, `⋮`, göz).

**Durumlar**
- Yükleme/boş/hata durumlarının tablosu: dolu (Sözleşmeler, Denemelerim, Derslerim, Deneme Detay sekmeleri, Soru Detay, Görüşmeler); eksik (Genel sekmesi, Anasayfa, Program listesi, Ders detayı hata, Derslerim hata, Edebiyat hata). Çevrimdışı için ayrı bir durum/mesaj yoktur (bağlantı kontrolü paketi yok); hata mesajları ham `Exception` metni. 
- Pull-to-refresh yalnızca iki yerde (`RefreshIndicator` ×2: Denemelerim, Görüşmeler).
- Sonsuz yükleme riski: Anasayfa ders/öğrenci şeridi, sonuç akışı Adım 2'deki kart sayıları.

**Sahte başarı / ölü eylem listesi** (kullanıcıya olumlu geri bildirim verip bir şey yapmayanlar)
- "yakında" diyaloğu: "Kaydınız Alındı" / "Talebiniz Alındı" (boş callback).
- Şifre güncelle: "Şifreniz başarıyla değiştirildi." (API yok).
- Şifremi unuttum: her kod geçer, "Şifre Değiştirildi".
- Bildirimler: `Değişiklikleri Kaydet` (boş). Kayıtlı kartlar: `Yeni Kart Ekle` (boş). Planı Değiştir (pasif).
- Sosyal giriş devam düğmesi (boş). `Beni Hatırla` (kalıcı değil). `İlerle` (sonuç akışı, boş). `Fotoğraf Çek` (yalnız `print`). `Eksikler` düğmesi (yalnız `print`). Program filtre/arama (uygulanmıyor). Görüşme arama (gönderilmiyor).
- Yıldız/favori: Deneme kartı (yerel), Soru Detay (yerel), konu bilgi kartı diyaloğu (yerel).

**Veri/sunucu**
- Uç tabanı: `smaptr.com`, `smaptr.com.tr`, `www.smaptr.com.tr` ve placeholder `wfdsvfsdg.com` karışık. Optik okuma isteklerinin tabanı placeholder (bkz. madde 0.9).
- Bazı isteklerde çerez elle (`connect_sid`) ekleniyor (`omd_result_flow_view.dart:226-236`), geri kalanı `PersistCookieJar`.
- Güvenlik/hijyen (tasarımı etkilemez, ancak üretim öncesi temizlenmeli): giriş ve kayıt alanlarında gömülü test kimlik bilgileri; `Student` modelinde `password` alanı; `print(` 73 yerde ve `debugPrint` 57 yerde (ham API yanıtları, kullanıcı verisi yazdırılıyor).

**Navigasyon tutarsızlıkları**
- Anasayfa "Analiz" menüsü ile alt bar "Analizlerim" ve içindeki "Genel" sekmesi aynı yere gider; üç farklı ad.
- "Derslerim" alt barda ders listesi, ama Ders detayı `analytics` klasöründe; tüm "ders → konu → alt başlık → madde" sayfaları **Analizlerim** sekmesine değil **Derslerim/Anasayfa** girişine bağlıdır.
- İç içe "geri": alt bar sekmesi içinde sanal rota (Hesap alt sayfaları, Programım) için üst bar geri oku + `PopScope`; diğer her şey tam ekran `MaterialPageRoute`. İki farklı geri davranışı.
- Rol sabitleri `'student'`, `'coach'`, ve hatalı `'teacher'` (bir yerde).

**Yerelleştirme**
- Yalnızca `GlobalMaterial/Widgets/CupertinoLocalizations` ve `Locale('tr','TR')`; `DateFormat('MMMM', 'tr_TR')` kullanımı doğru; **istisnalar:** Fatura satırlarında İngilizce ay (`Jan, Feb…`), `Invoice #…`; kod içi ASCII yazımlar ("yakinda", "gecen ay", "Siralama", "Dogru", "Dagilimlari" — `analytics_general_data.dart`, `section_placeholder.dart`, `lesson_distribution_chart_card.dart`).

---

Bu belgedeki tüm iddialar `lib` altındaki dosyalardan doğrulanmıştır. Backend'in gerçek yanıt şekli (örneğin `points`/`progress` değerleri, `filterObjs` içindeki etiketler, `lessonInfo` içeriği) bu depodan doğrulanamaz; ilgili yerler "kodla doğrulanamaz" diye işaretlenmiştir.