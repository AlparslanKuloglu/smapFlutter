# SMAP: Kararlar, varsayımlar ve geliştirici notları (SMAP-11 ve SMAP-12)

## 0. Kaynaklar ve kodlar

- **Ana kaynak:** SMAP-11 panoları 00–10 (11.1–11.11, Tur 1–11 notları), 15 (11.16 "Bütün Varsayımlar", toplam 134 varsayım) ve SMAP-12 (12.1–12.3, mağaza görselleri).
- **Salt okunur çapraz kontroller:**
  - Brifteki Ek D tablosu: `docs/history/tasarim-paketi/SMAP_Claude_Design_Brifi.md`, satır 917–953. Panolardaki "D-n" atıflarının tam metni burada.
  - Ekran envanteri: `docs/history/tasarim-paketi/SMAP_Ekran_Envanteri.md`.
  - 11.15 hareket ve haptik tablosu ile 3.1/3.2 panolarındaki pull-to-refresh notu.
  - `smapFlutter/lib` için endpoint grep'i ve `pubspec.yaml`.
- **Kod biçimleri:**
  - `x.y`: pano numarası.
  - `T.n`: tur.sıra biçimindeki varsayım numarası (11.16).
  - `D-n`: brif Ek D kararı.
  - `G-n`: o turun bileşen genişletmesi.
  - "Ek C": örnek veri. "envanter §": ekran envanteri bölümü.
- Kaynakta değer yoksa "belirtilmemiş" yazdım.

---

## 1. Geliştirici notları (alana göre)

### 1.1 Tema, token'lar, tipografi, biçim (Tur 1, 11.1)

**ColorScheme, açık tema** (seed kullanılmaz, ColorScheme elle kurulur; gri seed `#7D858D` kalkıyor):
```
primary 0xFF0F294A · onPrimary 0xFFFFFFFF · secondary 0xFFFF6600 · onSecondary 0xFF0F294A
error 0xFFC42D35 · onError 0xFFFFFFFF · surface 0xFFF2F4F7 · onSurface 0xFF1B2232
onSurfaceVariant 0xFF556173 · outline 0xFF697586 · outlineVariant 0xFFDCE2E9
surfaceContainerLowest 0xFFFFFFFF · surfaceContainerLow 0xFFFFFFFF · surfaceContainerHighest 0xFFE8ECF1
scrim 0x7A091A31 (%48)
```

**ColorScheme, koyu tema:**
```
primary 0xFFC5D4E8 · onPrimary 0xFF091A31 · secondary 0xFFFF6600 · onSecondary 0xFF0F294A
error 0xFFFF8F8F · onError 0xFF3B0A10 · surface 0xFF0A1424 · onSurface 0xFFEDF1F6
onSurfaceVariant 0xFFA9B5C6 · outline 0xFF6B7D97 · outlineVariant 0xFF26354D
surfaceContainerLowest 0xFF121D31 · surfaceContainerLow 0xFF18263D · surfaceContainerHighest 0xFF213049
scrim 0xA302060E (%64)
```

**ThemeExtension `SmapColors`.** Açık ve koyu değerler 1.2, 1.4 ve 1.5 panolarında.
- Alanlar: `navyBand, navyBandRaised, onNavyBand, onNavyBandVariant, bar, borderStrong, textPlaceholder, textDisabled, textAction, textAccent, primaryPressed, accentLine, focusRing, dybCorrect, dybWrong, dybEmpty, dybOn, dybCorrectBg, dybWrongBg, dybEmptyBg, info, infoBg, success, successBg, warning, warningBg, errorBg, chartLine, chartArea, chartHighlight, chartGrid, chartSeries[4], subjects: Map<Ders,(bg, accent)>` (9 ders).
- Tur 10'da iki token eklendi:
  - `delta`: açık `#36537C`, koyu `#9BB3D3`.
  - `bg-context`: değeri bu panolarda belirtilmemiş, 11.12'de.

**ThemeExtension `SmapTokens`:**
```
radius: xs 4 · sm 8 · md 12 · lg 16 · xl 24 · full 999
space: 4 · 8 · 12 · 16 · 24 · 32 · 48 · 64 (gutter 16)
shadowRaised: BoxShadow(0, 2, blur 8, #0F294A @ .08)  // koyu #000 @ .40
shadowOverlay: BoxShadow(0, 8, blur 24, #0F294A @ .16) // koyu #000 @ .56
duration: instant 100 · fast 150 · base 250 · slow 350 · loop 1200
curves: standard Cubic(0.2,0,0,1) · enter Cubic(0,0,0,1) · exit Cubic(0.3,0,1,1)
blur: bar 20 · scrim 8   // başka yerde BackdropFilter yok
```
Tur 10, ilk iş olarak "SmapColors ve SmapText tema eklentileri (11.12)" diyor. Tur 1'deki adı `SmapTokens`.

**TextTheme eşlemesi.** Yazı tipi Plus Jakarta Sans, `FontFeature.tabularFigures()` ile:

| Flutter | Stil | Değer |
|---|---|---|
| displaySmall | display | 32/40 · 800 · −0,5 |
| headlineSmall | title-lg | 24/32 · 700 · −0,3 |
| titleLarge | title-md | 20/28 · 700 · −0,2 |
| titleMedium | headline | 17/24 · 700 · −0,1 |
| titleSmall | title-sm | 16/24 · 600 |
| bodyLarge / bodyMedium / bodySmall | body-lg / body / caption | 16/24 · 15/24 · 13/20 500 |
| labelLarge / labelMedium / labelSmall | label-lg / label-md / label-sm | 16/24 · 14/20 · 12/16 (label-sm yalnız alt çubukta), hepsi 600 |
| ext.metricXl / Lg / Md / Sm | metric | 56/64 800 −1,5 · 40/48 800 −1 · 24/32 700 −0,4 · 17/24 700 |
| ext.bodyStrong (11.12) | body-strong | 15/24 · 600 (program saati, vurgu) |

**Tur 10 ölçek hizalaması:**
- Tanıtım ve genel ekran başlığı display 32/40.
- Anasayfa neti metric-lg 40/48.
- Program saati body-strong.
- Tarih bloğu metric-md.
- Ölçek dışı kalan ve düzeltilen değerler: 26/34 başlık, 32/40 rakam, 15/700 saat, 20/800 gün.

**Biçimlendirme kodu** (Tur 1, birebir):
```dart
final net  = NumberFormat('#,##0.##', 'tr'); // 67,5 · 74,75 · 68
final puan = NumberFormat('#,##0.00', 'tr'); // 412,63 · 381,40
final sira = NumberFormat('#,##0', 'tr');    // 48.215 → "48.215. sıra"
String yuzde(int d, int toplam) => '%${(d * 100 / toplam).round()}'; // 5/12 → %42
String kisaTarih(DateTime t) => '${t.day} ${DateFormat('MMM', 'tr').format(t)}.'; // 5 Eki.
DateFormat('d MMMM y', 'tr') // 15 Eylül 2026
DateFormat('EEE', 'tr')      // Pzt Sal Çar Per Cum Cmt Paz
// Büyük harf gerekirse toUpperCase() değil, tr yerel ayarlı dönüşüm (i → İ).
```

**Sabit renk ve ölçü kararları:**
- D/Y/B: Doğru `#0B6E3E`, Yanlış `#D8333A`, Boş `#7E8A9B` (T1.14).
- İkincil metin `#556173` (6,28:1). Pasif sekme etiketi ve ikonu da `#556173`.
- Kanvas `#F2F4F7`. Başlık metni `#1B2232`.
- İnce turuncu öğeler orange-600, koyuda orange-400. Hex değerleri bu panolarda belirtilmemiş, 1.1 ve 11.12'de.
- EksikTag: warning `#8A5A00` / `#FCF1D9`, koyu `#F2C46D` / `#33270F`.
- Delta (info): `#36537C`, koyu `#9BB3D3`.
- Toast ve çevrimdışı şeridi koyu temada ters yüzey: `#E8ECF1` zemin (1.24).

**Paketler.**
- Tur 1:
  - `phosphor_flutter`.
  - `intl` (tr, zaten var).
  - Plus Jakarta Sans TTF varlık olarak (google_fonts ile indirme yok).
  - Bildirim haptikleri için küçük platform kanalı: iOS `UINotificationFeedbackGenerator`, Android `HapticFeedbackConstants.CONFIRM / REJECT`.
  - `cupertino_icons` kaldırılabilir.
- Tur 2:
  - DocumentScanner (vendor).
  - `permission_handler`.
  - `dio` (bugünkü `http` yerine, `onSendProgress` ile).
  - `image` (isolate'te küçültme).
  - `shared_preferences`.
- Pubspec kontrolüm:
  - Yok: `phosphor_flutter`, `permission_handler`, `mihr_ui`.
  - Var: `http ^0.13.3`, `dio`, `image`, `shared_preferences`, `fl_chart ^1.2.0`, `intl ^0.20.2`.

**Önerilen widget adları (Tur 1 bileşen listesi).** Parantezdeki kod kit panosu.
- `SmapButton` (1.9): primary · secondary · quiet · danger · text; lg 48 · md 40; loading; leading/trailing ikon.
- `SmapSegmented` (1.10): 2–4 seçenek; counterLabel ("28 eksik", sıfırsa "eksik yok"); onNavy; etiket sarılır.
- `SmapTabBar` (1.10): fixed · scrollable (sığmazsa kendiliğinden); onNavy; seçili sekmeyi görünür alana kaydırır.
- `SmapChip` / `SmapTag` (1.11): chip türleri filter · choice · subject (nokta) · square (şık). Tag dokunulmaz bilgi etiketi.
- `SmapTextField` (1.12):
  - Türler: text · password · search · select (sheet açar) · code (6 hane) · multiline.
  - Durumlar: odak · hata · pasif · salt okunur · canlı kontrol.
- `SmapRow`, `SmapSwitch`, `SmapCheckbox`, `SmapRadio` (1.13): trailing chevron · value · switch · tag; danger; accordion header (expanded).
- `DybChip`, `DybCounter`, `DybStackedBar`, `QuestionCell` (1.14): counter large · small (harfli/kelimeli); bar parçaları arasında 2 pt boşluk.
- `SubjectProgress`, `SmapProgress`, `SuccessRing`, `SmapSpinner` (1.15): ring value · noData ("Soru yok").
- `SubjectRow`, `TopicRow`, `ExamCard`, `StatBox` (1.16): veri yoksa alan çizilmez; değişim yalnız gerçekse gösterilir.
- `SmapAvatar`, `AvatarStack`, `AvatarPicker` (1.17): 24/32/40/56/96; baş harf yedeği; "Koç" rozeti.
- `RootBand`, `DetailBar`, `ContextStrip` (1.18).
- `SmapBottomBar`, `CameraButton` (1.19): role student · coach.
- `SmapSheet`, `ConfirmSheet`, `ComingSoonSheet` (1.20, 1.21): sheet boyları small · medium · full; header, footer, busy. Confirm türleri normal · danger. ComingSoon yalnız kitte durur.
- `SmapToast`, `Skeleton`, `EmptyState`, `ErrorState`, `OfflineStrip` (1.22): toast info · success · error, action; empty/error hem ekran hem bölüm düzeyinde.

**Koddan kalkacaklar (Tur 1):**
- Giriş ve kayıttaki önceden dolu test kullanıcı adı ve şifresi.
- Sabit "OBP notunuz 85".
- "+18.2% gecen ay" varsayılanları ve "Deneme: N" etiketi.
- SnackBar'lardaki emoji ve "Hata:" öneki; iç hata kodları ve ham Exception metinleri.
- `#22C55E` yeşil Switch ve indigo dialog düğmesi.
- 6 segment ve 9 üst bar kopyası.
- Çok renkli ders PNG'leri ve stok menü illüstrasyonları.
- AppTheme'deki gri seed; `Colors.grey` ve Tailwind literal'leri (yerine SmapColors).
- Puan parası (`smapc.png`); eski üçgen logo ve yaklaşık 40 logo varyantı.
- `ob1-6.png` (7,7 MB) ve `loginImage.png`.

### 1.2 Kabuk ve navigasyon

**Üst bar 9 türden 2 türe iniyor:**
- **RootBand:** lacivert kök bant. Yüksekliği 134 pt; bantta segment ya da sekme varsa 178 pt; kaydırınca 110 pt (T1.12). İçeriği: title, action, bottom (segment/sekme), küçülme. Küçülme kaydırmaya bağlı (56 pt), eğrisi linear (11.15).
- **DetailBar:** açık zeminli. Geri, en çok bir eylem, compactTitle en çok 2 satır. Başlık içerikte büyük durur, kaydırınca bara iner (T1.4, D-9).

**Bant varyantları:**
- **HomeBand** (Tur 6 G1): avatar 40, selam title-md, sayaç 40/800. Kaydırınca 110 pt, tek satır.
- **ProfileSummary** (Tur 8 G2): avatar 56, ad 17/700, iki alt satır, tek dokunma alanı.
- **ContextStrip** (Tur 9 G2): 40 pt, navy-50, avatar 24, "Ad Soyad'ın verileri", sınıf · alan.

**Ad, avatar ve logo:** ad ve avatar yalnız Anasayfa ile Hesap'ta görünür; logo yalnız açılış ve girişte. Kök bantlarda logo yok, başlık var.

**Alt çubuk:**
- Öğrenci sekmeleri: Anasayfa · Analizlerim · Okut · Derslerim · Hesap.
- Koç sekmeleri: Anasayfa · Öğrencilerim · Okut · Görüşmelerim · Hesap. Users ve Chats ikonları (D-29, Tur 8 G6, Tur 9 G1).
- Tek gösterge. Etiket 12 pt; `FittedBox(scaleDown)` ile küçülür, uzun basışta balon açılır (T1.8).
- Sekme içindeki bütün ekranlarda kalır. Gizlendiği tam ekran akışlar: kamera, sonuç anı, kart oturumu, onboarding, giriş (T1.9).

**CameraButton:**
- 56 × 56, radius-lg, 16 pt yukarı (eskiden 74 × 74, 12 pt).
- Turuncu dolgu, lacivert ikon, altında "Okut" etiketi (D-8, T1.11). Gölge taşıyan sayılı yüzeylerden biri.

**Yığın kuralları:**
- Deneme Detay alt çubuklu açılır, Analizlerim seçili kalır. Sonuç anından açılınca kamera akışı kapanır ve ekran Analizlerim yığınına yerleşir (T3.1).
- Programım Anasayfa'dan açılır; alt çubukta Anasayfa seçili kalır (T6.10).

**Sheet ve dialog:**
- Seçim ve onaylar alttan sheet olarak açılır. Ortadaki dialoglar kalkar.
- Sheet açılış 350 ms (enter), kapanış 250 ms (exit).
- Sayfa geçişi 350 ms, platform eğrisi (11.15).

**Rol kapsamı (Tur 9):** öğrenci ekranları bir `StudentScope` ile sarılır.
- `coachView` true ise ContextStrip eklenir.
- Düzenleme eylemleri ve öğrenciye özel öğeler (favori, "Öğrendim", Günü Sıfırla) gizlenir.
- Aynı widget'lar iki rolde kullanılır.

**Güvenli alan:** iPhone 16 Pro'da üst 62, alt 34 pt. Klavye 336 pt ve yalnız şematik (T1.10).

**Uygulamada ilk iş (Tur 10):** önce SmapColors ve SmapText (11.12). Sonra RootBand, DetailBar, BottomBar, BottomSheet, ConfirmSheet, Toast ve durum kalıpları (1.18–1.22). Ekranlar bunların üstüne kurulur.

**Teslim okuma sırası:** 11.12 → 11.13 → 11.14 → 11.15 → 11.16. Akış haritası 0.1–0.3.

**mihr_ui eşlemesi** bu panolarda yok.

### 1.3 Açılış, tanıtım, giriş, kayıt (Tur 7)

**Ekranlar:**
- `SplashScreen`
- `OnboardingPager` (3 sayfa, bir kez gösterilir)
- `RolePickerScreen`
- `GradeFieldScreen`
- `CameraPrimerScreen`
- `WelcomeScreen`
- `LoginScreen` (sosyal varyant bayrakla)
- `ForgotPasswordFlow` (Email → Code → NewPassword → Done)
- `SignupScreen`
- `ForceUpdateScreen`
- `SessionExpiredSheet`
- `MaintenanceScreen`
- `UnknownRoleScreen`

**Durum:**
- Tanıtım seçimleri SharedPreferences'ta tutulur, kayıt başarılı olunca silinir.
- Kullanıcı adı kontrolü 400 ms gecikmeli ve iptal edilebilir.
- Çevrimdışıyken kontrol yapılmaz; alt metin "Bağlanınca kontrol edilecek." olur.

**Sözleşmeler:** kayıt açılırken sözleşme sürümleri çekilir. Gelmezse onay satırı hata kutusuna döner ve Kayıt Ol pasif kalır. Onay sürüm numarasıyla kaydedilir.

**Güvenlik:**
- Test kullanıcı adı ve şifresi koddan silinir.
- Giriş hatası hangi alanın yanlış olduğunu söylemez.
- AutofillHints: username, password, newPassword, oneTimeCode.

**Akış kararları:**
- Tanıtım 5 ekrandan 3'e iner: okut → analiz → eksikleri kapat. Görseller yeni arayüz parçalarından. Başlık en çok 2 satır. Atlama "Geç" metin düğmesi.
- Sayfa noktası: geçerli olan 24 × 8 orange-600, diğerleri 8 × 8 border-strong (2.1).
- Rol seçimi ayrı ekran. Sınıf 9, 10, 11, 12, Mezun. Alan Sayısal, Eşit Ağırlık, Sözel, Dil. 9–10. sınıfta alan sorulmaz, nedeni tek satırla yazılır. Koç bu adımı görmez.
- Kamera ön açıklaması "Sonra" ile ertelenebilir.
- Hoş geldin: kil Harita L 160. Kayıt Ol birincil, Giriş Yap ikincil.
- Giriş: etiketli ve boş alanlar, şifre göster/gizle, Şifremi Unuttum, tek birincil düğme. Hata çözüm söyleyen tek kutuda.
- Sosyal giriş ayrı varyant: Apple ve Google aynı boy ve stilde (D-17).
- Şifremi Unuttum: e-posta → 6 haneli kod → yeni şifre → bitti (D-18).
- Kayıt:
  - 7 avatar tek satırda ve sayıyla.
  - Canlı kullanıcı adı kontrolü.
  - Şifre kuralı baştan görünür.
  - Tek satır onay kutusu; bağlantılar metni sheet'te açar.
  - Koç kaydında koçluk kodunun ne işe yaradığını söyleyen satır var. Düğme iki rolde de "Kayıt Ol".
- Kayıt sonrası öğrenci yeni kullanıcı Anasayfa'sına (3.1 kare 3), koç Koç Anasayfa'ya gider.
- Genel ekranlar: zorunlu güncelleme, oturum sona erdi, bakım, bilinmeyen rol.

**Bileşen genişletmeleri:**
- G1 Lockup: yatay (girişte; işaret 36 + SMAP 24/800) ve dikey (açılışta; işaret 104 + SMAP 40/800). Lacivert zeminde üst kanca beyaz.
- G2 OnboardingPage: 380 pt görsel alanı, başlık 32/40 800, gövde 16/26, sayfa noktaları, tek birincil düğme.
- G3 RoleOption: avatar 56, başlık 17/700, açıklama 15, radyo. Seçiliyken 2 pt navy-900 çerçeve.
- G4 Çipler: sınıf kare çipi 56 × 48, Mezun 88 genişlik; alan hap çipi 48 pt.
- G5 Form içi kutular: hata kutusu error-bg, bilgi kutusu info-bg.
- G6 Kod kutuları ve canlı kontrol 1.12'deki gibi. Açılır seçim alttan sheet.

**Erişilebilirlik:**
- Sayfa noktaları "3 ekrandan 1." diye okunur.
- Rol seçenekleri radyo grubu.
- Avatar düğmesi "Avatar 3, seçili".
- Kod kutuları tek alan gibi okunur: "Doğrulama kodu, 6 hane".
- İşaret "SMAP" olarak okunur.

**Hareket:** form ve giriş hatasında 150 ms kenar vurgusu, kod kutuları sallanır (2.4), error haptiği. Hareketi azalt açıksa sallanma yok.

### 1.4 Anasayfa (Tur 6)

**Yapı:** `HomeScreen` bir CustomScrollView: HomeBand (SliverPersistentHeader) + TodaySection + LastExamSection + SubjectStrip.

**Veri:**
- Üç bağımsız istek: bugünün programı, son deneme özeti, ders eksikleri.
- Her bölüm kendi yükleme, boş ve hata durumunu taşır; biri düşerse diğerleri çalışır.
- Sayaç ve ad cihazdan gelir.

**Bölümler:**
- **Bant:** yalın selam ("Merhaba, Alparslan"), YKS sayacı ("252 gün kaldı · YKS · 19 Haziran 2027 Cumartesi").
- **Sayaç:** cihaz saatinden hesaplanır, gece yarısı yenilenir, ağ gerekmez (3.1).
- **Bugün:** bugünün çalışmaları saat, ders ve konuyla. Tamamlama işareti yok. Sağda tek metin düğmesi "Programım". Bugün satırı konu detayını ilk eksik maddede açar.
- **Son denemen:** ad ve yayınevi ayrı satırda; net metric-lg 40/48; fark info rengi ve okla; küçük D/Y/B; en çok kaçırılan konu cümlesi; "Analizi Gör".
- **Derslerin:** SubjectTile karoları (132 pt, glif 40). Etiketli eksik ("60 eksik"), eksiği çok olandan başlar. Matematik ve Geometri sonda, "Web'de" etiketiyle. Karo doğrudan ders detayını açar.

**Kaydırma ve yenileme:** kaydırınca bant küçülür. Aşağı çekince yenilenir (`RefreshIndicator`, 3.1). Bırakınca selectionClick (3.2).

**Durumlar (3.2):**
- Bölüm düzeyinde metinler: "Bugünün programı yüklenemedi.", "Henüz deneme okutmadın.", "Dersler yüklenemedi."
- Tekrar Dene yalnız o bölümü yeniler. Bant her zaman çizilir.
- Çevrimdışında son kaydedilen program ve deneme gösterilir.
- %130 metin karesi: satırlar uzar, ad ve konu kesilmez.

**Erişilebilirlik:**
- Sayaç tek öğe olarak okunur: "YKS'ye 252 gün kaldı. Sınav 19 Haziran 2027 Cumartesi."
- Gün düğmesi: "Cumartesi 10 Ekim, bugün, seçili".
- Program bloğu: "Cumartesi 10:00, Türkçe, Fiilde Çatı".
- Takvimde geçmiş günler devre dışı ama okunur.

### 1.5 Programım (Tur 6)

**Ekranlar:**
- `ProgramListScreen` (SearchField + ProgramRow): ad, motto, tarih aralığı; bu haftanın programı "Bu hafta" etiketli.
- `ProgramDetailScreen`: Gün/Hafta segmenti + DayStrip + ProgramItemRow, ya da WeekGrid.
- `NewProgramFlow`: DayPicker → HourGrid + TopicSheet → NameForm. Üç adım:
  1. Çoklu gün seçimi.
  2. 06:00–23:00 saat ızgarası; konu Çantam/Dersler sheet'inden seçilir.
  3. Ad ve motto.
- Düzenleme aynı ekranda `editMode` ile: saat değiştir, çıkar, ekle. "Günü Sıfırla" ve "Programı İptal Et" tehlikeli onayla.

**Arama:** istemcide, ad ve motto içinde. tr-TR küçük harfe çevrilir (İ→i, I→ı), 150 ms gecikmeli.

**Hafta ızgarası:**
- `Stack` + `CustomPaint` ile çizilir, fl_chart değil.
- Yatay ScrollController bugünün sütununa, dikey ilk çalışmaya konumlanır. Hareketi azalt açıksa animasyonsuz.
- Bloklar yalnız ders adını taşır; konu Gün görünümünde ve dokununca görünür (açık madde).

**Bileşenler:**
- G4 DayChip: 48 × 64; yeni programda 56 × 76 ve konu sayılı. Bugün noktası 6 pt orange-600.
- G5 WeekGrid ve HourSlot: saat sütunu 40 pt, gün sütunu 84 pt; bloklar ders tonlarında.
- G6 Calendar çoklu seçim: gün 46 pt; seçili, bugün ve geçmiş (devre dışı) durumları.
- G7 40 pt ikincil bar düğmesi: "Yeni Program", "Düzenle", "Bitti". Tehlikeli metin düğmesi (error) yeni varyant.

**Kaydetme:** düzenlemeler anında kaydedilir; "Bitti" yalnız modu kapatır (T6.9). Günü Sıfırla sonrası 6 sn "Geri Al" çıkar. Boş gün: tek cümle + "Konu Ekle" (D-31, 3.6).

**Durumlar (3.7):**
- Boş durum: kil Ampul. Ayrıca iskelet, hata ve çevrimdışı.
- Çevrimdışıyken kayıtlı program okunur. Kurma ve düzenleme bağlantı ister: düğme pasif, nedeni yazılı.
- Bağlantı gelince şerit "Bağlandın" der, 2 sn sonra kalkar.

**Hareket (11.15):**
- Blok ekleme/çıkarma: 250 ms, enter/exit, selectionClick.
- Günü Sıfırla: satırlar 150 ms aralıkla söner, selectionClick.

### 1.6 Kamera ve optik okuma (Tur 2)

**Ekranlar:**
- `CameraPermissionSheet`
- `OmrTutorialSheet`
- `OmrCaptureScreen`
- `OmrCornerScreen`
- `OmrUploadScreen`
- `FormCheckScreen`
- `AnswerFixSheet`
- `ExamRequestScreen`
- `OmrErrorView`
- `ResultMomentScreen`
- `NotificationPrimerSheet`

**Durum makinesi:** `preparing → uploading(progress) → reading → formCheck | notDetected | error(network, timeout, server, maintenance)`.
- Fotoğraf yolu (geçici dizin) her durumda taşınır ve başarıya kadar silinmez.
- Mesajlar hata türünden üretilir; iç kod gösterilmez.

**Uç noktalar:**
- Akış `opticimage`, `answerArray`, `examrequest` uçlarını kullanır.
- Taban adres bugün placeholder; düzeltilmeden akış çalışmaz.
- Kodda doğruladım: `lib/core/constants/api_constants.dart:14` → `apiBaseUrl = 'https://wfdsvfsdg.com/'`.

**Çekim:**
- Kılavuz çerçeve; kenar bulununca turuncu dörtgen.
- Üst çubuktaki logo ve "SMAP" yazısı kalkar.
- Kenar algılama DocumentScanner'ın bulduğu kontura dayanır. Deklanşör algılama olmadan da çalışır. Otomatik çekim, flaş ve galeri yok (T2.3, D-15).
- Kamera kromu (G3): 40 pt yarı saydam daire düğmeler, durum hapı, 76 pt deklanşör, kılavuz çerçeve.
- Deklanşör: 100 ms, 0,92 ölçek, mediumImpact. Hareketi azalt açıksa ölçek yok.

**Köşeler:** kırpma tek adım; eklentinin düzenleme adımı kalkar. Büyüteç ve tek satır ipucu.

**Fotoğraf hazırlama:** telefonda uzun kenar 2400 px, JPEG %85 (T2.5).

**Gönderim:**
- Üç gerçek adım ve yüzde: hazırlanıyor → gönderiliyor % → okunuyor (D-16). StepRow (G1) dört durum taşır: bitti, sürüyor, bekliyor, hata. Sürüyor satırı 1.15 ilerleme çubuğunu gösterir.
- Zaman aşımı: gönderim 60 sn, okuma 30 sn (T2.6). Bugün dio'da global connect/receive 10 sn var.
- Hata ve zaman aşımında fotoğraf saklanır; seçenekler "Tekrar Dene" ve "Yeni Fotoğraf".

**Form Kontrol:**
- Okunan cevapların özeti. Sayaçlı kolon segmenti: "1 boş / boş yok".
- Kolonlar "3. kolon" gibi sıra numarasıyla; her kolon 40 satır.
- Görüntü: `InteractiveViewer` (minScale 1, maxScale 5, çift dokunuş 2,5).
- Düzeltmeler `Map<(kolon, soru), şık>` olarak tutulur ve answerArray'e gönderilirken uygulanır.
- Tek düzeltme sheet'i; liste aynı yerde, sayı hep görünür.
- "Cevapları Onayla" ayrıca onay sormaz. Kapat (X) düzeltme varsa "Okutmadan çıkılsın mı?" sheet'ini açar.
- QuestionCell'e iki yeni durum (G2):
  - Boş okundu: warning-bg + 2 pt kesikli warning çerçeve.
  - Düzeltildi: navy-100 + 2 pt navy-900 çerçeve + kalem.

**Gönderim hatası (4.8):**
- Satır içinde gösterilir (role=alert, error-bg, 24 pt ikon). Düzeltmeler kaybolmaz; birincil düğme "Tekrar Dene"ye döner.
- Çevrimdışı metni: "Bağlantı yok. Bağlantı gelince tekrar dene."

**Deneme bulunamadı:** zorunlu alanlar, doğrulama, onay sheet'i. Talep sonrası bildirim sözü verilmez.

**Hata ekranları:**
- Ekranlar: form bulunamadı, bakım, çevrimdışı (planlı), kamera açılamadı.
- Rozet renkleri: hata error-bg, bilgi info-bg, çevrimdışı bg-sunken.
- Bakım ve çevrimdışı haptiksizdir; kullanıcının hatası değil.

**Bakım bayrağı:** kamera açılmadan sunucudan okunur ("okuma açık" bayrağı). Bayrak yoksa aynı metin ilk gönderimde gösterilir (T2.16).

**Çevrimdışı kuyruk:** planlı. v1'de çevrimdışı gönderim 4.5'teki hata kalıbını kullanır (T2.15).

**Koç kamerası:** okutulan form seçilen öğrenciye yazılır. Öğrenci seçimi sheet'i akışın başına eklenir (T9.9).

**SharedPreferences anahtarları:** `omd_tutorial_hidden`, `omd_corner_hint_hidden`, `notif_primer_shown`.

**Haptik:**
- mediumImpact: deklanşör.
- selectionClick: şık seçimi, köşe oturması.
- success: sonuç, talep.
- error: gönderim, doğrulama, form bulunamadı, kamera açılamadı.

**Erişilebilirlik:**
- Kamera ipucu role=status; gönderim aria-live.
- Hücre okunuşu: "12. soru, boş okundu, düzeltmek için dokun".
- Köşe noktaları sesli etiketli ("Sol alt köşe") ve dört yönlü ayar eylemi taşır (`Semantics onIncrease/onDecrease`). Büyüteç yalnız görsel.

### 1.7 Sonuç anı ve Deneme Detay (Tur 2 #12–15, Tur 3)

**Sonuç anı:**
- Tek ekran; avatar yok (eski NetworkImage hatası ortadan kalkar). Ekran tek istekten beslenir.
- Kart sayısı yanıtta yoksa satır çizilmez.
- `getTotalInfoCard` çağrısı PersistCookieJar kullanan istemciye taşınır.
- Sabit OBP şeridi kalkar. Puan ve sıra yalnız öğrencinin alanı için ve yalnız varsa gösterilir (EA 412,63 · 48.215.).
- Alan netleri `aytNets` alanından gelir.
- Okuma başarılı olunca "anında" gösterilir: sayaç dönmez, yalnız bir kez success haptiği.
- Değişim rengi delta (info). Önceki "+8,25 yeşili" sorunu Tur 10'da çözüldü.

**Bildirim izni (5.2, D-23):** yalnız ilk başarılı okumada, kullanıcı sonuç anından "Anasayfa" ya da "Detaylı Analiz" ile ayrılırken bir kez sorulur. Sheet, bildirim gönderimi devreye girene kadar kapalı (T2.17).

**Deneme Detay ekranları:**
- `ExamDetailScreen`: SliverAppBar + SliverPersistentHeader ile yapışkan sekmeler.
- `ExamHeader`, `TestBarList`, `QuestionGrid` (SliverGrid, 5 sütun), `TopicList`, `ExamCardList`, `QuestionDetailScreen`.

**Veri:**
- Başlık ve test kırılımı tek istekten gelir (`lessonInfo` JSON string → model).
- Sorular, Konular (`getMexamSubjectDetail`) ve Kartlar ayrı ve tembel yüklenir; her biri kendi durumunu taşır.
- Eski `true = result['wrong']` hatası düzeltilir.

**Hesap:**
- Yüzde `(d * 100 / n).round()`. "Az soru" n ≤ 2.
- Test neti sunucudan gelir; istemci hesaplamaz.
- Puan yoksa blok çizilmez.

**Sekmeler:**
- Genel, Sorular, Konular, Kartlar. Tek sekme çubuğu, yapışkan; alt çubuk görünür.
- Sorular: Tümü / Yanlışlar / Boşlar süzgeci. Akordeonda açık ve kapalı için ayrı ok.
- Konular: zayıftan güçlüye sıralı; eşitlik soru sayısıyla bozulur. "En çok kaçırdığın konu" yanlış sayısına göre seçilir, eşitlikte yüzdesi düşük olan.

**Birincil eylemler:** Konular'da "Bu Konuyu Çalış", Kartlar'da ve Soru Detay'da "Kartları Çalış".

**Soru Detay:** tek ekran, telif notu tek satır. Önceki/sonraki soru gezinmesi yok; geri ızgaraya döner.

**Bileşenler:**
- G1 QuestionCell: dar ızgarada (66 pt hücre) etiket "Doğru A".
- G3 ExamHeader: kapak 48 × 64, ad title-md, tür etiketi + tarih, net metric-lg, büyük D/Y/B, puan bloğu.
- G4 DetailBar: kısa hâlde deneme adıyla, altında yapışkan sekmeler.

**Durumlar:** iskelet, ders verisi yok, hata, çevrimdışı. Çevrimdışıyken önbellekteki deneme gösterilir (5.8).

**Erişilebilirlik:**
- Hücre: "Soru 7, yanlış, işaretin C, doğru cevap A".
- Akordeon expanded semantiği taşır.
- Çubuk tek okunuş: "40 sorudan 23 doğru, 17 yanlış, 0 boş".

### 1.8 Analizlerim (Tur 4)

**Ekranlar:**
- `AnalyticsScreen`: RootBand + TabBar (Genel, Denemelerim). Analiz ve Harita sekmeleri kalkar.
- `FilterSheet`: sınav, alan, ders.
- `NetChart`: fl_chart LineChart. `dotData` açık, `belowBarData` %10, `lineTouchData` balon.
- `StatGrid`.
- `ExamList`: PagedListView, 8'er kayıt.

**Grafik (G1):**
- Değişken nokta sayısı. Y ekseni TYT 0–120, AYT 0–160.
- Son nokta vurgulu, dokununca balon. Hedef çizgisi yok.

**Satır ve kutu bileşenleri:**
- G2 ExamRow: kapak 40 × 54, ad, tür + tarih + yayınevi, küçük D/Y/B, sağda net, favori.
- G3 StatBox değişim satırı: ok ikonu + "+3,25 son denemede".

**Veri:**
- Süzgeç durumu: sınav, alan (profilden), ders. Değişince grafik ve kutular aynı istekten güncellenir.
- Sabit `aimType = 2` kaldırılır; kullanıcının alanı kullanılır.
- Denemelerim: `types/nets/dates` parametreleri ve `sort=newest|net`.

**Hesap:**
- Değişim = son − sondan bir önceki (aynı süzgeçte). İki deneme yoksa satır çizilmez.
- Ortalama sunucudan gelir.

**Süzgeç ve favori:**
- Tarih süzgeci hazır aralıklar: Tüm tarihler, Son 30 gün, Son 3 ay, Bu eğitim yılı. Özel aralık yok.
- Favori yalnız cihazda; favoriye göre süzme yok.

**Durumlar (6.3):**
- Boş, tek deneme, hata, çevrimdışı.
- Çevrimdışıyken son kaydedilen veri gösterilir; süzgeç yalnız önbellekteki türlerle çalışır. Hata ve çevrimdışı haptiksiz.

**Erişilebilirlik:**
- Grafik tek okunuş: "TYT net grafiği, 22 Nisan 61,5 netten 28 Eylül 74,75 nete, 6 deneme".
- Noktalar odaklanabilir: "TYT Genel Deneme 9, 28 Eylül, 74,75 net".

### 1.9 Derslerim, ders detayı, konu detayı (Tur 5)

**Ekranlar:**
- `LessonsScreen`: RootBand + TYT/AYT segmenti + SubjectRow listesi.
- `LessonDetailScreen`: SubjectHeader + EksikFilterChip ("Eksiklerim (31)") + sayaçlı segment + TopicRow.
- `TopicDetailScreen`: Accordion<SubTopic> → Accordion<Item> + ExampleBox.
- `CardSheet`, `CardDeckScreen`, `AuthorList` / `AuthorSheet`, `WebOnlySheet`.

**Veri:**
- Eksik sayıları ders ve kategori bazında sunucudan gelir.
- Kart ilerlemesi (öğrenilen / toplam) yoksa satırda çizilmez.
- Konu numarası sunucu sırasından istemcide 1..n üretilir; süzgeçte tam listedeki numara korunur.

**Kaydırma ve hareket:**
- TopicDetail açılışında ilk eksik maddeye `Scrollable.ensureVisible` (350 ms, standard). Hareketi azalt açıksa `jumpTo`.
- Akordeon 250 ms.

**Kurallar:**
- Adlarda "TYT/AYT" öneki yok. Eksik etiketli ("28 eksik").
- AYT'de Tarih-2 ve Coğrafya-2 ayrı satır; altında test adı ("Sosyal Bilimler 2 testi").
- TYT/AYT/SOS-2 diyaloğu kalkar; kategori ders detayında segment olur.
- Matematik ve Geometri: "Web'de" etiketi + ArrowSquareOut + açıklayan sheet. "Haber ver" yok.
- Tek eksik işareti: bayrak + "eksik" sözcüğü, amber. Kırmızı yanlış cevaba ayrıldı.
- Konu detayında madde = numara, ad, tanım ve ayrı "Örnek" kutusu; gövde 16 pt.
- Maddenin kartı "Kartı Aç" ile sheet'te açılır: başlık, içerik, örnek, favori, eksikse "Öğrendim".
- Edebiyat segmenti: Konular / Yazar ve Eserler. Yazar sheet'inde hakkında, türe göre eserler ve "Öğrendim".

**Bileşenler:**
- G1 SubjectRow: 40 pt glif karosu, isteğe bağlı kart ilerlemesi (8 pt ray), "Web'de" varyantı.
- G2 Segment: bir seçeneğin verisi yoksa yalnız onun sayaç satırı çizilmez. Koyu sayaç renkleri eklendi.
- G3 EksikTag: bayrak 14 pt + metin 13/600.
- G4 Accordion iki düzey; ExampleBox bg-canvas, "Örnek" 13/700.
- G6 Uzun sheet: başlıkta favori (Star / Star Fill).

**Durumlar (7.5):**
- İskelet, süzgeç boş, hata + "Tekrar Dene", çevrimdışı.
- Web'deki dersler çevrimdışıyken gizlenir.

**Erişilebilirlik:**
- Destede kaydırmaya alternatif "Sonraki kart" / "Önceki kart" eylemleri (`customActions`).
- "3 eksik"; segment "TYT, 28 eksik"; "Matematik, web'de açılır".

**Açık madde:** madde başına kart durumu sunucuda varsa alt başlığa "4 kartın 3'ü öğrenildi" satırı eklenebilir.

### 1.10 Bilgi kartları (Tur 5, 8.1–8.2)

**Deste:**
- Sekmeler: Eksiklerim · Bildiklerim · Favorilerim, sayaçlı.
- Oturum sayacı açılıştaki eksik kart sayısıyla başlar (12/23).
- "Öğrendim" yalnız eksik kartta görünür.

**Bileşen (G5 CardDeck):**
- Kart köşesi 24 pt. Sürüklenen kartta shadow-overlay. Arkada iki kart kenarı.
- SessionProgress: 4 pt ilerleme çubuğu.

**Etkileşim:**
- Sürükleme eşiği %30 genişlik ya da 800 px/sn. Kaydırma yalnız sonraki karta geçer; öğrenme yalnız "Öğrendim" düğmesiyle.
- "Öğrendim" iyimser güncellenir; hata olursa geri alınır ve toast çıkar.
- Onay ilk seferde sorulur; "Bir daha sorma" cihazda saklanır.
- Her taşımada 6 sn "Geri Al".

**Hareket (11.15):**
- Kart kaydırma parmağı izler. Hareketi azalt açıksa çapraz geçiş.
- Öğrendim: 250 ms sağa çıkış, exit, success.

**Boş durum:** sekme başına boş metin (Ek C) ve tek eylem.

### 1.11 Hesap (Tur 8)

**Ekranlar:**
- `AccountScreen`: RootBand + ProfileSummary + 5 × SettingsGroup + LogoutRow + VersionText.
- `ProfileScreen` (view/edit), `AvatarSheet`, `GradeSheet`, `PasswordScreen`.
- `DeleteAccountFlow`: Info → DangerSheet → Progress → Done.
- `CoachingScreen` (linked / unlinked).
- `NotificationsScreen`, `TimeWheelSheet`, `AgreementsScreen`, `AgreementReader`.

**Veri:**
- Profil PATCH yalnız değişen alanlarla gönderilir.
- E-posta değişimi doğrulama kodu ister.
- Bildirim tercihleri anahtar başına anında PUT edilir; hata olursa yerel durum geri alınır.
- Sistem bildirim izni `permission_handler` ile okunur; uygulama öne gelince yeniden okunur.

**Güvenlik:**
- Şifre değişince diğer oturumlar kapanır.
- Hesap silme yeniden kimlik doğrulama istemez (D-28) ama onay sheet'i zorunlu; istek idempotent.

**Ana ekran ve gruplar:**
- Gruplar: Hesap, Koçluk, Bildirimler, Yasal, Destek. Satırlar beyaz yüzeyde.
- Çıkış Yap ayrı grupta, kırmızı, oksuz. Onayı normal (lacivert). Altta sürüm satırı.
- Koç varyantı: Koçluk grubunda kod, Kopyala ve Paylaş. Profilde Sınıf ve Alan yok.

**Profil:**
- Görüntüleme ve düzenleme modları; kullanıcı adı kilitli.
- Telefon +90 maskeli. Sınıf ve alan profilden değişir. Avatar seçimi 7'si birden.
- Hesabı Sil, Profil'in en altında.

**Diğer ekranlar:**
- **Şifre:** etiketli üç alan, kural baştan görünür, hata alanda.
- **Koçluk (9.5):**
  - Koç kartı: avatar 64, ad 17/700, "Koçun", sıradaki görüşme (yoksa satır çizilmez).
  - Kod alanı maskesi `AAAA-0000`, büyük harfe çevirir, tireyi kendisi koyar.
  - Hata: "Bu kodla bir koç bulunamadı. Kodu koçundan yeniden iste."
  - Toast'lar: "… bağlandın." ve "Koç bağlantın kaldırıldı."
- **Bildirimler (9.6):**
  - Dört kategori: "Deneme sonucun hazır", "Koçun deneme ya da ödev atadı", "Görüşme planlandı", "Çalışma hatırlatıcısı".
  - Sessiz saatler 22:00–08:00. Anahtarlar anında kaydeder; Kaydet düğmesi yok.
  - Sistem izni kapalıyken uyarı ve "Ayarları Aç".
  - TimeWheel (G5): 5 dk adımlı, alttan sheet.
- **Sözleşmeler:** ad, sürüm, tarih; uygulama tipografisiyle okuma ekranı.
- **Bize Yaz:** destek adresine sürüm ve cihaz bilgisiyle taslak açar.

**Hesabı Sil:** silinirken tam ekran spinner, geri kapalı (11.15).

**Bileşenler:**
- G1 SettingsRow: sağ öğe ok, değer, anahtar ya da dış bağlantı. Tehlikeli satır kırmızı ve oksuz.
- G3 Salt okunur alan; kilit ikonu yalnız değişmeyen alanda.
- G4 Bar düğmesi: "Düzenle" çerçeveli, "Kaydet" dolu.

**Erişilebilirlik:**
- Anahtar: "Deneme sonucun hazır, açık, anahtar".
- Tehlikeli satır: "Çıkış Yap, düğme, onay ister".
- Saat çarkı ayarlanabilir öğe; yukarı/aşağı 5 dk.

### 1.12 Koç (Tur 9)

**Ekranlar:**
- `CoachHomeScreen`: HomeBand + StudentStrip + AttentionSection + MeetingsSection.
- `StudentsScreen`: RootBand + SearchField + StudentRow.
- `AddStudentSheet` (+ `CredentialsSheet`).
- `StudentProfileScreen`: ContextStrip + TabBar (Analiz / Denemeler / Program); öğrenci ekranları readOnly.
- `MeetingsScreen`, `NewMeetingSheet`, `MeetingDetailScreen`, `NoteSheet`.

**Dikkat kuralları:**
- Sunucuda hesaplanır: `last_exam_at ≤ now − 14 gün`, ya da aynı türde son iki denemenin neti azalmışsa.
- Her satır kanıt alanlarıyla gelir: gün sayısı, iki net, tarihler.

**Arama:** tr-TR katlama: önce `toLowerCase(tr)`, sonra ı→i. Ad ve soyad token'larında önek eşleşmesi. Vurgulama özgün metin aralığında yapılır.

**Kurallar:**
- Öğrenci sıralaması alfabetik (Türkçe karşılaştırma).
- Öğrenci Ekle alanları: ad, soyad, kullanıcı adı (Kontrol Et), şifre (Oluştur + göster), sınıf, alan; altında kod kartı.
- Giriş bilgileri kayıttan sonra bir kez gösterilir ve paylaşılır.
- Koç öğrencinin programını yalnız görüntüler.
- Görüşme notları yalnız koça görünür.
- Görüşmeden 1 saat önce koça hatırlatma.
- Görüşmelerim: arama, "Kiminle" süzgeci, yıllı tarih, Öğrenci/Veli etiketi.
- Notlar: ekle, düzenle, onaylı sil, 6 sn geri al.
- Görüşme yok boş durumu: kil Hokka M 128.
- Öğrencisi olmayan koç: üç avatar, "İlk öğrencini ekle", kod kartı.

**Bileşenler:**
- G3 StudentTile: 108 pt, avatar 48, ad 2 satıra kadar.
- G4 AttentionRow: Clock / TrendDown ikonu (warning rengi), kural cümlesi, kanıt satırı.
- G5 MeetingRow: tarih bloğu ya da avatar.
- G6 CodeCard: kod 24/800, Kopyala ve Paylaş eşit.
- G7 Çok satırlı alan + karakter sayacı.

**Erişilebilirlik:**
- Şerit ilk okunur: "Alparslan Kuloğlu'nun verileri".
- Dikkat satırı: "…, 45 gündür deneme okutmadı, son deneme 17 Haziran".
- Görüşme satırı: "…, 12 Ekim 2026 Pazartesi, 16:00, öğrenci görüşmesi".

### 1.13 Global davranışlar

**Pull-to-refresh:**
- Yalnız Anasayfa'da yazılı: `RefreshIndicator`, bırakınca selectionClick (3.1, 3.2).
- Diğer ekranlar için bu panolarda belirtilmemiş. Bugünkü kodda yalnız Denemelerim ve Görüşmeler'de var (envanter §6).

**Durum kalıpları:**
- Her ekranın dört durumu var: iskelet, boş, hata (Tekrar Dene), çevrimdışı (1.22).
- İskelet 15 sn içinde veri alamazsa hata durumuna geçer (T1.24). Parıltı döngüsü 1200 ms, linear; hareketi azaltta durağan gri.
- Durumlar bölüm düzeyinde de olabilir. Hata ve çevrimdışı haptiksizdir.

**Çevrimdışı:**
- Şerit barın hemen altına iner, içeriği iter, bant köşeleri düzleşir. Metin: "Son kaydedilen veriler gösteriliyor."
- 250 ms'de iner. Bağlanınca 2 sn "Bağlandın" gösterir.
- Koyu temada ters yüzey.
- Bu, istemcide yerel önbellek gerektirir. Önbelleği kullanan ekranlar: Anasayfa, Programım, Deneme Detay, Analizlerim, Derslerim.

**Toast:**
- Alt çubuğun 8 pt üstünde çıkar, çubuğu örtmez. Çubuk gizliyse güvenli alan + 16 pt yukarıda.
- 4 sn kalır; "Geri Al" varsa 6 sn. Giriş/çıkış 250 ms.
- Hata türünde error haptiği.
- Eylem beyaz kalın metin. Emoji ve iç kod yok.

**Metin dili:**
- "Sen" dili.
- İptal sözlüğü:
  - Vazgeç: eylemsiz kapatır.
  - Tamam: bilgi sheet'inde tek düğme.
  - Kapat: yalnız X'in erişilebilir adı.
  - Geri Al: yalnız toast'ta.
  - Sonra: izin ön açıklamasında erteleme.
  - "İptal" kullanılmaz.
- Onay başlıkları cümle düzeninde; ekran, sheet ve bölüm başlıkları Türkçe başlık düzeninde. Düğme "Evet" değil, eylemin adı.

**Form kuralları:**
- Zorunlu alan yıldızı yok; isteğe bağlı alan "(isteğe bağlı)" ile biter.
- Placeholder "Örn:" ile başlar ve yalnız beyaz zeminde kullanılır.
- Önceden dolu alan yok.

**Sayı ve tarih:**
- 67,5 · 74,75 · 68 · 412,63 · 381,40 · "48.215." · %42 · +8,25.
- "15 Eylül 2026" / "15 Eyl." / "5 Eki." / "5 Eki. 2026".
- Pzt Sal Çar Per Cum Cmt Paz.
- Yüzde en yakın tam sayıya yuvarlanır.

**Haptik sözlüğü:** selectionClick, mediumImpact, success, error.

**Hareket ve haptik tablosu (11.15):**

| Etkileşim | Süre | Eğri | Haptik | Hareketi azalt |
|---|---|---|---|---|
| Düğme basılı | 100 ms | standard | — | aynı |
| Segment, sekme, alt çubuk | 250 ms | standard | selectionClick | opaklık 150 ms |
| Çip, anahtar, onay kutusu, radyo | 150 ms | standard | selectionClick | aynı |
| Akordeon | 250 ms | standard | — | anında |
| Sheet açılış/kapanış | 350 / 250 ms | enter / exit | — | opaklık 150 ms |
| Toast | 250 ms; 4 sn, Geri Al ile 6 sn | enter / exit | hata türünde error | opaklık |
| Küçülen bant/bar | kaydırmaya bağlı (56 pt) | linear | — | aynı |
| İskelet | 1200 ms döngü; 15 sn sonra hata | linear | — | durağan gri |
| Deklanşör | 100 ms, 0,92 ölçek | standard | mediumImpact | ölçek yok |
| Sonuç anı | anında, sayaç dönmez | — | success, bir kez | aynı |
| Form/giriş hatası | 150 ms kenar; kod kutuları sallanır | standard | error | sallanma yok |
| İlk eksiğe kaydırma | 350 ms | standard | — | doğrudan konum |
| Kart kaydırma | parmağı izler; eşik %30 ya da 800 px/sn | standard | — | çapraz geçiş |
| Öğrendim | 250 ms sağa çıkış | exit | success | opaklık |
| Program bloğu ekle/çıkar | 250 ms | enter / exit | selectionClick | opaklık |
| Günü Sıfırla | satırlar 150 ms aralıkla söner | exit | selectionClick | anında |
| Çevrimdışı şeridi | 250 ms iner; bağlanınca 2 sn "Bağlandın" | enter | — | opaklık |
| Sayfa geçişi | 350 ms | platform | platform | opaklık |
| Hesabı Sil | tam ekran spinner; geri kapalı | linear | — | aynı |

**Hareketi azalt:** `MediaQuery.disableAnimations` açıksa opaklık geçişi kullanılır.

**Erişilebilirlik:**
- Dokunma hedefi 48: `MaterialTapTargetSize.padded`; 40'lık düğmede pay bırakılır.
- Metin ölçeği 1,3'e kadar düzen kırılmaz; sabit yükseklik yok.
- İkon düğmeleri tooltip ve semanticLabel taşır: 'Geri', 'Kapat', 'Filtrele', 'Favorilere ekle', 'Şifreyi göster'.
- D/Y/B tek okunuş: `Semantics(label: '86 doğru, 74 yanlış, 0 boş', excludeSemantics: true)`.

**İkon ve görsel:**
- Phosphor; normalde Regular, seçiliyken Fill.
- Kil illüstrasyon yalnız onboarding, ekran düzeyi boş durum ve mağazada; ekranda en fazla bir tane.
- Avatarlar ve kil görseller üretimde asıl dosyaların 3x kopyasıyla kullanılır.

### 1.14 Mağaza (Tur 11 ve SMAP-12): uygulama için anlamı

**Telefonlarda kullanılan koyu ekranlar.** Bu ekranlar uygulamada koyu temada birebir doğru olmalı:

| Kare | Ekran |
|---|---|
| 1 | 3.3 kare 1 |
| 2 | 4.3 kare 2 |
| 3 | 5.1 kare 3 |
| 4 | 5.9 kare 2 |
| 5 | 6.4 kare 1 |
| 6 | 7.6 kare 1 ve 8.2 kare 1 |
| 7 | 3.8 kare 1 |

- Son dışa aktarmada ekranlar ×3 alınmalı: 1206 × 2622.
- Bir ekran değişirse yalnız o telefonun görüntüsü yeniden alınır; kurgu, rota ve kesimler aynı kalır.

**Dışa aktarma:**
- Panorama ×3 ölçekte 9030 × 2796 alınır; x = 0, 1290, 2580… noktalarından 7 dilime kesilir.
- App Store: `appstore-01…07.png`. 1320 × 2868 için her dilim %2,6 büyütülür, yanlardan toplam 3 px kırpılır. 1290 × 2796 aynı kaynaktan.
- Play: her dilimin üstteki 1290 × 2293'lük kısmı 1080 × 1920'ye küçültülür (`play-phone-01…07.png`).
- Öne çıkan görsel 1024 × 500 (`play-feature.png`).
- Hepsi RGB, saydamlıksız PNG.

**Metinler:**
- Kare 1: "Denemeni okut, eksiğini kapat" / "YKS'ye hazırlanırken her denemenden ders çıkar."
- Kare 2: "Optik formunu kamerayla okut" / "Köşeleri oturt, gönder; cevapların sayılır."
- Kare 3: "Netin ve D/Y/B'n tek ekranda" / "Önceki denemene göre farkını da görürsün."
- Kare 4: "Her soruda ne olduğunu gör" / "İşaretin, doğru cevap ve kaçırdığın konu."
- Kare 5: "Gelişimini grafikte izle" / "Her deneme grafiğe yeni bir nokta ekler."
- Kare 6: "Eksiklerini konu konu kapat" / "Konu anlatımı ve bilgi kartlarıyla tekrar et."
- Kare 7: "Haftanı planla, bugüne odaklan" / "Eksik konularından haftalık program kur."
- Öne çıkan görsel: "SMAP Denemeni okut, eksiğini kapat" + "Net, D/Y/B, konu analizi ve bilgi kartları tek uygulamada."
- Arama sonucu alt başlığı "Deneme okut, eksiğini kapat" ve kategori "Eğitim" örnek değer.

**Kesim kuralları:**
- Başlık ve alt satır karenin üst %35'inde durur.
- Gerçek boyda başlık 114 px, alt satır 51 px. Küçük boyda (104 px) başlıklar iki satır.
- Telefonlar kesim çizgisine gerçek boyda 40 px'ten fazla yaklaşmaz.

**Mağaza bileşenleri:**
- G1 StoreDevice: ekran 804 × 1748, kenar genişliğin %3'ü, köşe %16, gölge 0 30 60 %50 siyah.
- G2 StorePanel: 430 × 932; başlık 38/44 800; alt satır 17/24 500; dengeli satır kırma.
- G3 Rota: 14 px orange-500 çizgi, 44 px %22 hale, beyaz kesikli orta çizgi.
- G4 Zemin: navy-900 → `#0A1424`; parlamalar turuncu %20 ve info `#36537C` %55.
- G5 Kil: 92–104 px (gerçek 276–312), en çok 3 nesne.
- G6 Uygulama ikonu: lacivert pafta, arama sonucunda 64 px.

**Uygulamaya yansıyan sonuçlar:**
- v1'in vitrindeki özellikleri: optik okuma, net ve D/Y/B, soru ayrıntısı, net grafiği, konu ve bilgi kartları, haftalık program.
- Koç özellikleri mağaza setinde yok.
- Uygulama adı yalnız "SMAP".
- Launcher ikonu 1.26'daki pafta ikonuna geçmeli. Bugün `flutter_launcher_icons.image_path: "assets/logotext.png"`.

---

## 2. Varsayımlar ve kodun ya da backend'in desteklemesi gerekenler

### 2.1 Brif Ek D kararları (D-1…D-33)

| ID | Karar | Kod / backend gereği |
|---|---|---|
| D-1 | Net = D − Y ÷ 4, sunucu hesaplar; çeyrek adım, virgüllü | İstemci net hesaplamaz (bugün de hesaplamıyor). Biçim `NumberFormat('#,##0.##','tr')`. |
| D-2 | Gösterilecek gerçek veriler: deneme (net, D/Y/B, yerleştirme ve ham puan, sıralama, test bazında D/Y/B, soru durumu ve işaretlenen şık, konu bazında D/Y/B ve yüzde); eksikler (ders, TYT/AYT/SOS-2 ve konu başına); içerik (alt başlık madde sayısı, madde ve kart durumu, eksik/bilinen/favori sayıları); analiz (liste, tarih, sayı, ortalama net, puan, sıra); program, görüşme, notlar, koçun öğrenci listesi (sınıf, alan, toplam deneme) | Hepsi sunucudan gelmeli. Kritik eksik: soru başına işaretlenen ve doğru şık (Bölüm 3, #9). |
| D-3 | Gösterilmeyecekler: geçen aya göre değişim, konu tamamlama %, "N/20 konu", ders başına alt başlık/madde/kart toplamı, "%60", elmas/coin/puan/seri/rozet, hedef net, "Başarısız (Derece)", sabit OBP, görev tamamlama | Varsayılanlar, sahte sabitler ve `UserModel.points` gösterimi silinir. |
| D-4 | v1'de yok: SmapLab, Gelen Kutusu, SmapCoach, Müfredat, Kaynak Takibi, Analiz sekmesi, Harita, Ödeme ve Paketler, Kayıtlı Kartlarım, faturalar, paywall, Soru Bankam, soru fotoğrafı, oyunlar. "Yakında" sheet'i yalnız kitte | Rotalar, menüler ve `showUnderConstruction` çağrıları kaldırılır. |
| D-5 | Matematik ve Geometri satırında "Web'de" etiketi; dokununca sheet ve "Web'de Aç" | Hedef web URL'si gerekir (belirtilmemiş). |
| D-6 | Birincil düğme lacivert dolgu, beyaz metin | `SmapButton.primary`. |
| D-7 | Turuncu: kamera, seçili/konum, ilerleme, "bugün". Metin olarak yalnız koyu turuncu ya da 18 pt üstü kalın | Tur 1'de seçim lacivert yapıldı (T1.6). Turuncu yalnız göstergede. |
| D-8 | Kamera düğmesi turuncu dolgu, lacivert ikon, "Okut" | `CameraButton`. |
| D-9 | Kök sekmede lacivert bant; ad ve avatar yalnız Anasayfa ve Hesap'ta; detay barı türü Tur 1'de seçilecek | Açık zeminli DetailBar seçildi (T1.4). |
| D-10 / D-11 / D-12 | Plus Jakarta Sans · Phosphor Regular/Fill · ders ikonu tek renk glif | TTF varlık, `phosphor_flutter`, `SmapColors.subjects`. |
| D-13 | Mevcut 3D avatar seti, öğrenci ve koçta ortak | 7 avatar; sunucuda dosya adı (`photo`) olarak tutulur. |
| D-14 | Koyu çizilecek ekranlar. Tur 10'daki son liste: Anasayfa 3.3 · Kamera 4.3–4.4 (her temada koyu) ve 4.6 · Sonuç anı 5.1 kare 3 · Deneme Detay Genel ve Sorular 5.9, Konular 5.10 · Analizlerim Genel 6.4 · Konu detayı 7.6 · Kart destesi 8.2 · Programım haftalık 3.8 | Koyu ColorScheme; kamera ekranlarında zorla koyu tema. Mağaza bu ekranlardan yapılır. |
| D-15 | Flaş ve galeri yok | Galeriden seçme yok (`image_picker` var ama kullanılmıyor). |
| D-16 | Yalnız gerçek gönderim adımları: hazırlanıyor, gönderiliyor %, okunuyor | dio `onSendProgress`. |
| D-17 | Sosyal giriş yalnız ayrı varyant karesi | Bayrakla açılan LoginScreen varyantı. Sunucu ucu belirsiz (Bölüm 3, #17). |
| D-18 | Şifremi unuttum: e-posta + 6 haneli kod. **Sunucu ucu yoksa akış gizlenir** | Bugün uç yok, akış tamamen istemcide. Feature flag gerekir. |
| D-19 / D-20 | Alanlar Sayısal, EA, Sözel, Dil; 9–10'da alan yok · Sınıflar 9, 10, 11, 12, Mezun | `aimType` eşlemesi kodda tutarsız. Kayıtta "Dil" yok; koç dialogunda Mezun yok (Bölüm 3, #18). |
| D-21 | YKS tarihi örnek olarak 19 Haziran 2027; geri sayım cihazda | Tarihin kaynağı belirtilmemiş: sabit mi, uzaktan mı? |
| D-22 | Dokunma hedefi 48 dp | `MaterialTapTargetSize.padded`. |
| D-23 | Bildirim izni ilk başarılı okumadan sonra | NotificationPrimerSheet + `notif_primer_shown`. Bildirim gönderimi açılana kadar kapalı (T2.17). |
| D-24 | Sessiz saatler varsayılan 22:00–08:00 | Tercih uç noktası ve sunucu tarafı uygulama. |
| D-25 | Deneme favorisi yalnız cihazda, düşük vurguyla | SharedPreferences'ta deneme id seti. Koç görünümünde yıldız yok. |
| D-26 | Programda tamamlama yok | Görev modelinde tamamlama alanı kullanılmaz. |
| D-27 | Koçta "dikkat" yalnız iki kural: 14 gündür deneme yok, son iki denemede net düştü | Sunucuda hesaplanır, kanıt alanlarıyla döner (bugün uç yok). |
| D-28 | Hesap silme iki adım: açıklama → tehlikeli onay; kelime yazdırma yok | `/ajax/deleteAccount` var. İdempotentlik doğrulanmalı. |
| D-29 | Öğrenci ve koç sekmeleri | `SmapBottomBar(role)`. |
| D-30 | Yalnız Türkçe | `tr` yerel ayarı; ARB zorunlu değil. |
| D-31 | Toast alt çubuğun hemen üstünde; 4 sn, "Geri Al" varsa 6 sn | `SmapToast`. Geri Al için geri alma uçları gerekir (Bölüm 3, #24). |
| D-32 | "(Test)" gibi ekler yok; yayınevi ve ad ayrı satırda | `publisherName` ve `itemName` ayrı. |
| D-33 | "Deneme: N" gösterilmez; denemeler tarihle ayrılır | `mexam.order` gösterimi kalkar. |

### 2.2 Tur varsayımları (11.16, toplam 134)

#### Tur 1 (35)

| ID | Varsayım | Kod / backend |
|---|---|---|
| 1.1 | Hesaptaki "Design System" artifact'ı kullanılmadı | Süreç notu; kod etkisi yok. |
| 1.2 | 42 ekran görüntüsü sonradan geldi; piksel ölçümüyle doğrulandı; tariften gelen 5 yanlış düzeltildi | Süreç notu. |
| 1.3 | Kanvas `#F5F7F9` → `#F2F4F7`; başlık `#1C1F33` → `#1B2232` | `surface` ve `onSurface`. |
| 1.4 | Detay barı açık zeminli; başlık içerikte büyük, kaydırınca bara en çok 2 satır iner | DetailBar ScrollController / SliverAppBar ile. |
| 1.5 | İnce turuncu öğeler orange-600 (`#FF6600` beyazda 3:1 tutmuyor); koyuda orange-400 | `SmapColors.accentLine`. |
| 1.6 | Seçim lacivert; turuncu yalnız konum, ilerleme, "bugün" ve kamerada | Switch, Chip ve Checkbox temaları primary rengini kullanır. |
| 1.7 | Segment başparmağı lacivert dolgu (beyaz başparmak 1,10:1 veriyordu) | `SmapSegmented`. |
| 1.8 | Alt çubuk etiketi 12 pt, tek istisna; FittedBox ve uzun basış balonu | `labelSmall`. |
| 1.9 | Alt çubuk sekme içinde kalır; tam ekran akışlarda gizlenir | Sekme başına navigator + root navigator. |
| 1.10 | Güvenli alan 62/34 pt; klavye 336 pt şematik | `MediaQuery` kullanılır, sabit değer yazılmaz. |
| 1.11 | Kamera düğmesi 56 × 56, radius-lg, 16 pt yukarı | `CameraButton`. |
| 1.12 | Kök bant 134 / 178 / 110 pt | RootBand header extents. |
| 1.13 | Kartlar kenarsız ve gölgesiz; gölge yalnız sürüklenen kart, kamera düğmesi, toast ve balonda | Kart teması elevation 0. |
| 1.14 | D/Y/B `#0B6E3E` / `#D8333A` / `#7E8A9B`; sayı metin renginde, renk çipte; koyuda açıklık sırası ters | `SmapColors.dyb*`. |
| 1.15 | Ders glifleri TextAa, Feather, Bank, Globe, MathOperations, Angle, Atom, Flask, Dna; Kimya 296°, Edebiyat 340° | Hangi glifin hangi derse ait olduğu bu panolarda açık yazılmamış; 1.5'ten alınmalı. |
| 1.16 | Başarı halkası tek renk; yuvarlanır; soru yoksa "Soru yok" | `SuccessRing.noData`. |
| 1.17 | Net sondaki sıfırsız; puan 2 hane; kısa tarih "5 Eki." | Biçim yardımcıları. |
| 1.18 | İptal sözlüğü; "İptal" kullanılmaz | Metin sabitleri. |
| 1.19 | Onay başlıkları cümle düzeninde; diğer başlıklar Türkçe başlık düzeninde | Metin kuralı. |
| 1.20 | Zorunlu yıldız yok; "(isteğe bağlı)" | `SmapTextField`. |
| 1.21 | Şifre ipucu "En az 8 karakter."; kodda kural yok | **Backend:** şifre kuralı netleşmeli. |
| 1.22 | Placeholder yalnız beyaz girdi zemininde (kanvasta 4,25:1) | Girdi dolgusu beyaz. |
| 1.23 | Toast eylemi beyaz kalın; koyuda toast ve şerit ters yüzey | Toast teması. |
| 1.24 | İskelet 15 sn'de hataya geçer | İstek zaman aşımı ve durum geçişi. |
| 1.25 | Koç rozeti "Koç" kelimesi | `SmapAvatar` rozeti. |
| 1.26 | Avatar 190 px, kil 140 px kırpıldı; üretimde 3x; kapak görselleri hâlâ yer tutucu | Varlık hattı. Kapaklar sunucudan. |
| 1.27 | Panolardaki ikonlar yaklaşık; uygulamada `phosphor_flutter` | Paket eklenmeli. |
| 1.28 | Örnek şıklar, kullanıcı adı ve sheet alt başlıkları | Örnek veri. |
| 1.29 | Ders bazında kart toplamı yalnız Tarih için var (41 / 64) | **Backend:** ders başına öğrenilen/toplam kart alanı. Yoksa çizilmez. |
| 1.30 | Yazı tipi gömülü, çalışma anında indirilmez | TTF varlık. |
| 1.31 | Örnek kişilere avatar atamaları; Mert ve koçu aynı avatarda | Örnek veri. |
| 1.32 | Kil seti yeni ikon seti sayılmaz | Kullanım kuralı. |
| 1.33 | Ders satırında kil değil glif | SubjectRow. |
| 1.34 | Logo örgülü S; varsayılan ikon lacivert pafta, açık sürüm alternatif; karar kullanıcıda | Launcher ikonu kararı bekliyor. |
| 1.35 | Wordmark Plus Jakarta Sans ExtraBold | Lockup. |

#### Tur 2 (17)

| ID | Varsayım | Kod / backend |
|---|---|---|
| 2.1 | Kamera aşaması (çekim, köşeler, kamera hatası) her temada koyu; gönderim ve sonuç anı açık ve koyu | Koyu tema zorlaması. |
| 2.2 | Öğretici açık sheet; koyu karşılığı çizilmedi | Koyu değerleri belirtilmemiş. |
| 2.3 | Kenar algılama DocumentScanner konturuna dayanır; otomatik çekim yok | Vendor eklenti. |
| 2.4 | Eklentinin düzenleme adımı kalktı | Kırpmadan sonra doğrudan gönderime geçilir. |
| 2.5 | 2400 px uzun kenar, JPEG %85 | `image` paketi isolate'te. **Backend:** kabul edilen boyut ve format. |
| 2.6 | Zaman aşımı gönderim 60 sn, okuma 30 sn | İstek başına timeout. |
| 2.7 | Kolonlar sıra numarasıyla; kolon başına 40 satır | **Backend:** `answersArray` kolon ve soru indeksli olmalı. |
| 2.8 | Örnek okumada 2 boş okundu ve düzeltildi | Örnek veri. |
| 2.9 | "Cevapları Onayla" ayrıca onay sormaz; X + düzeltme → çıkış onayı | PopScope + ConfirmSheet. |
| 2.10 | Alan netleri `aytNets`'ten | `aytNets` anahtarları 2/3/4; `aimType` eşlemesi doğrulanmalı. |
| 2.11 | Puan ve sıra yalnız öğrencinin alanı için | Kullanıcının alanı. |
| 2.12 | TYT örneğinde yayınevi, puan ve kart sayısı yok | Null alanlar çizilmez. |
| 2.13 | "Türkiye Geneli Deneme 7" kullanıcı girdisi örneği | Örnek veri. |
| 2.14 | Talep sonrası bildirim sözü yok | Metin. |
| 2.15 | Çevrimdışı kuyruk planlı; v1 hata kalıbını kullanır | Bağlantı kontrolü; kuyruk yok. |
| 2.16 | Bakım bilgisi kamera açılmadan sunucudan okunur; bayrak yoksa ilk gönderimde | **Backend:** "okuma açık" bayrağı. |
| 2.17 | Bildirim izni sheet'i, gönderim devreye girene kadar kapalı | Feature flag. |

#### Tur 3 (10)

| ID | Varsayım | Kod / backend |
|---|---|---|
| 3.1 | Deneme Detay alt çubuklu, Analizlerim seçili; sonuç anından açılınca kamera akışı kapanır | Navigasyon geçişi. |
| 3.2 | Puan bloğu yalnız öğrencinin alanı; ham puan Ek C'de yok, çizilmedi | `points/pointsHam/ranks/ranksHam` alanları var (envanter §5). Ham puanın gösterimi belirtilmemiş. |
| 3.3 | Doğru/yanlış dizilimi 26–27'den; şıklar örnek | **Backend:** soru başına işaretlenen ve doğru şık gerekir. `questionsArrStr` yalnız `{order,type}` taşıyor. |
| 3.4 | Ders sayaçları 12 / 12 / 0 (görüntü 28) | Örnek. |
| 3.5 | Konu sıralamasında eşitlik soru sayısıyla bozulur; "Az soru" 1–2 | İstemcide sıralama. |
| 3.6 | "En çok kaçırdığın konu" yanlış sayısıyla; eşitlikte düşük yüzde | İstemci ya da sunucu; kaynak belirtilmemiş. |
| 3.7 | Kartlar sekmesinde ders başına sayı yok; yalnız iki Tarih kartı | **Backend:** deneme başına ders ve kart listesi. |
| 3.8 | Soru Detay açıklaması kart metninden; AYT sırası Tarih-1 = 25–34 | `getQuestion`. |
| 3.9 | Önceki/sonraki soru gezinmesi yok | — |
| 3.10 | Konular koyu Tur 10'da | 5.10'da çizildi. |

#### Tur 4 (9)

| ID | Varsayım | Kod / backend |
|---|---|---|
| 4.1 | "AYT · Genel" bütün AYT testlerinin toplam neti; alan yalnız ders listesini değiştirir | **Backend:** grafik ve toplam istekleri buna uygun parametre almalı. |
| 4.2 | AYT ortalama 57,56, TYT 67,79 | Ortalama sunucudan. |
| 4.3 | Tek ders kutularındaki değerler sunucudan | `getTotal` ders süzgeci. |
| 4.4 | EA ders listesine Matematik eklendi | Ders ID'leri bugün koda gömülü; sunucudan alınmalı. |
| 4.5 | Adı olmayan denemenin başlığı tür + "denemesi" | `itemName` yedeği. |
| 4.6 | Liste seçildi, ızgara değil | ExamRow. |
| 4.7 | Tarih süzgeci hazır aralıklar | `dates` eşlemesi. "Bu eğitim yılı" sınırı belirtilmemiş. |
| 4.8 | Favori yalnız cihazda; favoriye göre süzme yok | SharedPreferences. |
| 4.9 | Tek deneme durumu örneği | — |

#### Tur 5 (10)

| ID | Varsayım | Kod / backend |
|---|---|---|
| 5.1 | Eksik dağılımı Ek C'den; AYT payı yoksa etiket yok | `resultByType` null ise çizilmez. |
| 5.2 | Türkçe toplamı 31 (28 + 3); konu bazında yalnız 8; fark sunucudan | **Backend:** ders toplamıyla konu toplamının tutarlılığı. |
| 5.3 | Sözcükte Anlam: 5 alt başlık, 25 madde | Örnek. |
| 5.4 | Oturum sayacı 12/23; sekme sayaçları 22 · 42 olur | İstemci durumu. |
| 5.5 | Kaydırma yalnız sonraki karta; öğrenme yalnız düğmeyle | Deste hareketleri. |
| 5.6 | Onay ilk sefer; "Bir daha sorma" cihazda; 6 sn Geri Al | **Backend:** öğrenmeyi geri alma ucu yok. Alternatif gecikmeli kayıt. |
| 5.7 | Yazar listesi örnek; fotoğraf yoksa baş harf | Yazar fotoğrafı null olabilir. |
| 5.8 | TYT/AYT seçimi cihazda; Tarih-2 → Tarih SOS-2 seçili açılır | SharedPreferences; `defaultFilterValue` 4. |
| 5.9 | Çevrimdışıyken Web'de dersler gizlenir | Bağlantı durumu. |
| 5.10 | Matematik EA AYT listesinde; Geometri de "Web'de" | Ders listesi. |

#### Tur 6 (10)

| ID | Varsayım | Kod / backend |
|---|---|---|
| 6.1 | "Ekim 2. Hafta" = 5–11 Ekim 2026 (ayın ilk tam haftası) | Program adı ve hafta hesabı kuralı. |
| 6.2 | Son denemen en son okunan; fark aynı türün bir öncekine göre | **Backend:** önceki aynı tür deneme ya da fark alanı. |
| 6.3 | Selam saatten bağımsız, profilin ilk adı | `firstName`. |
| 6.4 | YKS 19 Haziran 2027; 10 Ekim 2026'dan 252 gün | Cihazda hesap. |
| 6.5 | Ders şeridi eksik azalan; Matematik ve Geometri sonda | İstemcide sıralama. |
| 6.6 | Anasayfa'dan açılan ders detayı Derslerim'deki son TYT/AYT seçimiyle; ilk açılışta TYT | Ortak durum. |
| 6.7 | Yeni program örneği gelecek hafta; geçmiş gün seçilemez | Takvim geçmişi kapatır. |
| 6.8 | Çantam = eksik konular | `bagItems`. |
| 6.9 | Düzenlemeler anında kaydedilir; "Bitti" yalnız modu kapatır | **Backend:** düzenleme başına `updateProgram`. |
| 6.10 | Programım alt çubukta değil | Anasayfa yığını. |

#### Tur 7 (10)

| ID | Varsayım | Kod / backend |
|---|---|---|
| 7.1 | Tanıtım 3 ekran; rol, sınıf ve alan kayda kadar cihazda | SharedPreferences; kayıtta silinir. |
| 7.2 | Girişte rol sorulmaz, hesaptan gelir | Giriş yanıtındaki `role`. |
| 7.3 | "Beni Hatırla" kalktı; oturum açık kalır | PersistCookieJar. **Backend:** oturum süresi. |
| 7.4 | Kullanıcı adı: harf, rakam, nokta, alt çizgi; küçük harfe çevrilir | **Backend:** aynı kural. |
| 7.5 | Şifre en az 8 karakter | **Backend.** |
| 7.6 | Hoş geldin'de Kayıt Ol birincil | — |
| 7.7 | Sosyal girişte resmî Apple ve Google varlıkları | Apple girişi paketi pubspec'te yok. |
| 7.8 | Sıfırlamada kayıtsız e-postaya da aynı yanıt; kod 10 dk; tekrar 30 sn | **Backend:** uç yok. |
| 7.9 | Koç kaydında alanlar boş çizildi | Örnek. |
| 7.10 | Bakım ve bilinmeyen rolde süre ve adres yok; "Destek'e Yaz" taslak | Destek adresi gerekir. |

#### Tur 8 (10)

| ID | Varsayım | Kod / backend |
|---|---|---|
| 8.1 | Sürüm satırı örnek ("Sürüm 3.0.0 (300)") | Derlemeden okunur; paket belirtilmemiş. |
| 8.2 | Sözleşme sürüm ve tarihleri örnek, sunucudan | `LegalDocument`'te tarih alanı yok (envanter §5). |
| 8.3 | Destek adresi Ek C'de yok; taslak sürüm ve cihaz bilgisiyle | Adres ve cihaz bilgisi gerekir. |
| 8.4 | Bildirim altyapısı kapalı; tercihler şimdiden kaydedilir | **Backend:** tercih uç noktası. |
| 8.5 | Kategoriler ve sessiz saatler varsayılan açık | Sunucu varsayılanları. |
| 8.6 | Hesabı Sil Profil'in en altında | — |
| 8.7 | Silinecek deneme sayısı 10 | **Backend:** deneme sayısı. |
| 8.8 | Koçluk kodu 4 harf + 4 rakam | `refCode` biçimi doğrulanmalı. |
| 8.9 | Çıkış onayı normal (lacivert) | — |
| 8.10 | Koçun Hesap'ı aynı yapıda; Sınıf ve Alan yok | Rol koşulu. |

#### Tur 9 (9)

| ID | Varsayım | Kod / backend |
|---|---|---|
| 9.1 | Ek C'de dikkat kuralları tetiklenmiyor; kare 2 örnek | **Backend:** kural ucu. |
| 9.2 | Diğer öğrencilerin deneme verisi yok, çizilmedi | Null-safe. |
| 9.3 | Öğrenciler alfabetik, Türkçe karşılaştırma | Türkçe sıralama gerekir. |
| 9.4 | Öğrenci Ekle örneği Zeynep Kaya (12, EA) | Örnek. |
| 9.5 | Mert'in avatarı av-2 | Örnek. |
| 9.6 | Koç programı yalnız görüntüler | readOnly. |
| 9.7 | Görüşme notları yalnız koça | **Backend** ACL. |
| 9.8 | Görüşmeden 1 saat önce hatırlatma | **Backend:** push zamanlama. |
| 9.9 | Koçta da kamera; form seçilen öğrenciye yazılır | **Backend:** okuma isteklerinde `studentId`. |

#### Tur 10 (5)

| ID | Varsayım | Kod / backend |
|---|---|---|
| 10.1 | Değişim rengi delta; yeşil yalnız Doğru; yön ok ve işaretle | `SmapColors.delta`. |
| 10.2 | Koç panoları kod sırasıyla dizildi | — |
| 10.3 | Akış haritasındaki kodlar pano numarası | — |
| 10.4 | Ekran–bileşen eşlemesi pano düzeyinde | — |
| 10.5 | Mağaza görselleri bu token'ları kullanır; parlama ve kil yalnız orada | — |

#### Tur 11 (9)

| ID | Varsayım | Kod / backend |
|---|---|---|
| 11.1 | Cihaz çerçevesi ve logo dosyaları gelmedi | Mağaza varlığı. |
| 11.2 | Boyutlar doğrulanmadı: 1320 × 2868 / 1290 × 2796; Play 9:16, 2–8 görsel; 1024 × 500 | Yüklemeden önce doğrulanmalı. |
| 11.3 | Başlıklar öneri; alt başlık ve kategori örnek | Mağaza metadatası. |
| 11.4 | Koç ekranları mağazada yok | — |
| 11.5 | Kil: Harita, Sütun, Ampul | — |
| 11.6 | Mağaza arayüzleri markasız | — |
| 11.7 | 5.9 segment sayaçlarının koyu rengi düzeltildi | Koyu sayaç renkleri kodda. |
| 11.8 | Play = App Store karelerinin üst %82'si | — |
| 11.9 | Kare sırası: ne yapar, nasıl, ne alırım, ayrıntılar | — |

---

## 3. Backend soruları ve bağımlılıklar

"Bugünkü kod" sütunu `smapFlutter/lib` endpoint grep'ine ve envantere dayanıyor.

| # | Konu | Tasarımın beklediği | Bugünkü kod | Soru |
|---|---|---|---|---|
| 1 | Optik okuma tabanı | `opticimage`, `answerArray`, `examrequest` gerçek host'ta | `apiBaseUrl = 'https://wfdsvfsdg.com/'` (placeholder). Dio `https://www.smaptr.com`. Görseller smaptr.com.tr / www.smaptr.com.tr / smaptr.com | Gerçek host ne? Tek taban adres var mı? |
| 2 | Fotoğraf yükleme | 2400 px, JPEG %85; yüzdeli ilerleme; 60/30 sn zaman aşımı | base64 + `user_data` ile POST | Sunucu multipart JPEG kabul ediyor mu? Boyut sınırı ne? |
| 3 | Hata türleri | network, timeout, server, maintenance; form bulunamadı ↔ deneme bulunamadı | `mexamFound` Map değilse "bulunamadı"; Left dönerse mesaj yok | Yapılandırılmış hata kodu var mı? |
| 4 | Bakım bayrağı | Kamera açılmadan "okuma açık" bayrağı | Yok | Yeni uç gerekli. |
| 5 | Zorunlu güncelleme | ForceUpdateScreen | Yok | Minimum sürüm ucu ya da config. |
| 6 | Oturum sona erdi / bilinmeyen rol | SessionExpiredSheet, UnknownRoleScreen | `validateStatus < 500`, `followRedirects: false`; rol `student`/`coach` | Oturum düşünce sunucu ne döner (401/302)? Rol değer seti ne? |
| 7 | Şifremi unuttum | E-posta → 6 hane kod (10 dk, tekrar 30 sn) → yeni şifre | Tamamen istemcide, uç yok | Uç gelmezse D-18 gereği akış gizlenir. |
| 8 | Şifre değiştirme | Gerçek değişiklik; diğer oturumlar kapanır | Sahte (yalnız SnackBar) | Yeni uç. |
| 9 | Soru başına şık | "işaretin C, doğru cevap A" | `questionsArrStr` yalnız `{order, type}` | İşaretlenen ve doğru şık alanları var mı? |
| 10 | E-posta değişimi | Doğrulama koduyla | Yok | Yeni uç. |
| 11 | Profil güncelleme | Yalnız değişen alanlar (PATCH); avatar, sınıf, alan, telefon (+90) değişir | POST `/student/updateStudent` | Kısmi güncelleme var mı? Bu alanlar destekleniyor mu? |
| 12 | Kullanıcı adı kontrolü | Canlı, 400 ms, iptal edilebilir | `/ajax/checkUsername` var (koç kullanıyor); kayıt simüle ediyor | Kural sunucuda da aynı mı (harf, rakam, nokta, alt çizgi; küçük harf)? |
| 13 | Sözleşmeler | Ad, sürüm, tarih; onay sürümle kaydedilir; gelmezse kayıt kapalı | `/ajax/getLegalDocuments` (name, title, version, content, isActive); kayıt `accepted*Version` gönderiyor | Tarih alanı eklenebilir mi? |
| 14 | Hesap silme | İdempotent; silinecek deneme sayısı gösterilir | `/ajax/deleteAccount` var | İdempotent mi? Sayı nereden gelecek? |
| 15 | Koç bağlantısı | Kodla bağlan, kaldır; kod `AAAA-0000`; öğrenci "sıradaki görüşme"yi görür | `addCoach`, `deleteCoach` (coachId göndermiyor), `getStudentsCoach` | Öğrencinin sıradaki görüşmesi için uç yok. `deleteCoach` parametresi düzeltilmeli. |
| 16 | Bildirim tercihleri ve push | 4 kategori, sessiz saatler, anahtar başına PUT, cihaz token'ı | Yok; push paketi yok | Tercih ve token uçları, gönderim altyapısı. |
| 17 | Sosyal giriş | Apple ve Google | `google_sign_in` var ama çağrılmıyor; Apple paketi yok | Sunucu tarafında sosyal giriş ucu var mı? |
| 18 | Alan ve sınıf kodları | Sayısal, EA, Sözel, Dil; Mezun | Kayıt 2/3/4 (Dil yok), koç dialogu 1/2/3/4; Mezun = 13; koç dialogunda Mezun yok | Tek resmi eşleme ne? |
| 19 | Anasayfa "Bugün" | Bugünün çalışmaları (saat, ders, konu) | `/student/getMyWeeklies` | Bugün için ayrı uç mu, istemcide süzme mi? Programın tarih aralığı alanı var mı? |
| 20 | Anasayfa "Son denemen" | Net, D/Y/B, aynı türün önceki denemesine fark, en çok kaçırılan konu | Tek uç yok; `getMyMockExams` + `getMexamSubjectDetail` | Özet ucu mu, istemcide birleştirme mi? |
| 21 | Ders eksikleri | Ders ve TYT/AYT/SOS-2 kırılımı | `/student/getLessonsTotalMissing`, `resultByType` | Ders toplamı ile konu toplamı farkı (T5.2) nasıl açıklanacak? |
| 22 | Kart ilerlemesi | Ders başına öğrenilen/toplam; madde başına kart durumu | Yalnız Tarih 41/64 örnekte var | Alan mevcut mu? |
| 23 | Sonuç anı | Tek istek; kart sayısı varsa satır | `answerArray` yanıtı + ayrı `getTotalInfoCard` (elle çerez) | Kart sayısı `answerArray` yanıtına eklenebilir mi? |
| 24 | Geri Al | Öğrendim (6 sn), Günü Sıfırla, not silme | `learnedCard`/`learnedItem` var; geri alma ucu yok; `deleteNote` var | Geri alma ucu mu, istemcide gecikmeli kayıt mı? |
| 25 | Program iptali ve anında kayıt | "Programı İptal Et"; düzenleme başına kayıt | `addNewProgram`, `updateProgram`; silme yok | Silme/iptal ucu. Parçalı güncelleme var mı? |
| 26 | Analizlerim | Kullanıcının alanı; AYT toplam neti; grafik ve kutular aynı istekten | `getLineChartData` + `getTotal` ayrı; `aimType = 2` sabit | Birleşik uç mu, paralel iki istek mi? |
| 27 | Denemelerim sıralama | `sort=newest\|net`; hazır tarih aralıkları | Yalnız `filter{types,nets,dates}`, `page`, `perPage: 8` | `sort` parametresi ekli mi? "Bu eğitim yılı" sınırı ne? |
| 28 | Koç dikkat listesi | Sunucuda iki kural + kanıt alanları | Yok | Yeni uç. |
| 29 | Koç öğrenci listesi | Deneme sayısı ve "son net" | `getMyStudents`; `Student.totalMexam` var, son net yok | Son net alanı eklenebilir mi? |
| 30 | Öğrenci Ekle | Mezun dahil sınıf, alan, kimlik bilgilerini paylaşma | `/coach/addNewStudent` | `seasonType 13` kabul ediliyor mu? |
| 31 | Görüşmeler | Sunucuda arama, "Kiminle" süzgeci, yıllı tarih | `getInterviews` (sayfalı, `filter{types,dates}`); arama gönderilmiyor | Arama parametresi var mı? |
| 32 | Koç hatırlatması | Görüşmeden 1 saat önce | Yok | Zamanlanmış push. |
| 33 | Koç bağlamında öğrenci | Analiz, Denemeler, Program salt okunur | Koç analiz ekranı var | Bütün uçlar `studentId` alıyor mu? |
| 34 | Koç kamerası | Form seçilen öğrenciye yazılır | Yok | Okuma isteklerine `studentId`. |
| 35 | Bildirim kategorisi çelişkisi | "Koçun deneme ya da ödev atadı" kategorisi | T9.6: koç v1'de atama yapamıyor | v1'de bu kategori kalacak mı? |
| 36 | "Deneme sonucun hazır" | Talep edilen denemenin analizi bitince bildirim | `examrequest` var | Asenkron analiz için olay ya da durum alanı var mı? |
| 37 | Web'de dersler | "Web'de Aç" | Hedef URL kodda yok, yalnız "smaptr.com'dan giriş" metni | URL ne? |
| 38 | YKS tarihi | 19 Haziran 2027 (örnek) | Yok | Sabit mi, uzaktan config mi? |
| 39 | Sürüm, destek adresi, sözleşme tarihleri | Derlemeden ve sunucudan | Yok | Destek adresi ne? |
| 40 | Deneme favorisi | Yalnız cihazda | Modelde `isStarred` var ama yazılmıyor | Sunucudaki `isStarred` yok sayılacak mı? |
| 41 | Kapak görselleri | Sunucudan | `/uploads/{image}` farklı host'larda | Tek host ne? |

---

## 4. Kaldırılan ve eklenen özellikler

### 4.1 Eski uygulamaya göre kaldırılanlar

**Özellik ve menü düzeyinde:**
- Coin ve puan parası: `smapc.png`, `UserModel.points` gösterimi, kişi kartındaki %0 çubuğu.
- Anasayfa kişi kartı.
- Anasayfa menü ızgarası: Analiz, Denemelerim, Derslerim, Gelen Kutusu, SmapLab, Programım.
- Aylık takvim (salt görseldi).
- Koç menüsü: SmapCoach, Analizler, Müfredat, Kaynak Takibi. Koç öğrenci diyaloğunun 4 düğmesi yerine StudentProfileScreen geldi.
- Ders girişindeki TYT/AYT/SOS-2 diyaloğu.
- "Yakında" diyalogları, "Yayınladığında Haber Ver", "Kaydınız Alındı" / "Talebiniz Alındı".
- Analizlerim'deki Analiz ve Harita sekmeleri, "Genel ▾" açılır filtre-sekmesi.
- Ödeme ve Paketler, Kayıtlı Kartlarım, İngilizce fatura satırları.
- Soru Bankam, "Fotoğraf Çek" ve sahte veri çağıran "Tekrar Dene" (Soru Detay).
- Oyunlar.
- "Beni Hatırla".
- Profil ile şifrenin tek sayfada olması; kalem ikonlu karışık düzenleme.
- Bildirimlerdeki geliştirici anahtarları ("Aktif", "Kullanıcılar Görebilsin", "Mobilde Göster" …) ve "Değişiklikleri Kaydet".
- Koç kartındaki "Başarısız (Derece)".

**Optik okuma akışında:**
- Üst çubuktaki logo ve "SMAP".
- Eklentinin düzenleme adımı.
- "Hatırlatma" yönerge diyaloğu.
- İki ayrı düzeltme sheet'i ve "Onaylıyor musunuz?" diyaloğu.
- Sonuç akışının 3 adımı ve boş "İlerle".
- Sonuç ekranındaki avatar.
- "Gönderim hatası 590" gibi iç kodlar.
- Ölü `_submitRequest`.

**Sahte ya da sabit veriler:**
- Sabit "OBP notunuz 85".
- "+18.2% gecen ay".
- "Deneme: N" ve "(Test)" eki.
- Her derste "%75 · 15/20 · 4 Alt Başlık · 26 Madde · 8 Bilgi Kartı".
- Alt başlıklarda sabit "%60".
- Sarı/eşik renkli halka.
- Etiketsiz rozetler (31, 60, 44, 3).
- Önceden dolu test kullanıcıları.

**Tanıtım ve görseller:**
- Tanıtım 5 ekrandan 3'e indi.
- Eski arayüz görselleri `ob1-6.png` (7,7 MB) ve `loginImage.png`.
- "5 saniyede", "yapay zeka destekli" vaatleri.
- Eski üçgen logo ve yaklaşık 40 varyant.
- "Stundent map" taslağı.
- Çok renkli ders PNG'leri ve stok menü illüstrasyonları.

**Görsel ve sistem düzeyinde:**
- 12'den fazla lacivert ve 9 turuncu ton.
- 5 gri ailesi.
- `#22C55E` anahtar ve indigo dialog düğmesi.
- 9 üst bar türü ve 6 segment kopyası.
- 22 köşe yarıçapı ve 57 gölge.
- Ortada açılan dialoglar.
- Büyük harfli düğmeler ("ANLADIM", "GÖNDER", "LİSTEYE EKLE", "TAMAM").
- Emojili SnackBar'lar ve "Hata:" öneki.
- `cupertino_icons` (kaldırılabilir).

### 4.2 Eklenenler (yeni ekranlar, akışlar, davranışlar)

**Temel:**
- Koyu tema (token düzeyinde ve D-14 ekranları).
- Durum kalıpları: iskelet → 15 sn → hata, bölüm hatası, çevrimdışı şeridi ve önbellek.
- Geri Al'lı toast.
- Akış haritası (0.1–0.3).

**Açılış ve giriş:**
- SplashScreen, 3 sayfalık OnboardingPager.
- RolePickerScreen, GradeFieldScreen, CameraPrimerScreen, WelcomeScreen.
- Sosyal giriş varyantı.
- Gerçek ForgotPasswordFlow (e-posta + 6 hane).
- Canlı kullanıcı adı kontrolü ve sözleşme onay kutusu.
- ForceUpdateScreen, SessionExpiredSheet, MaintenanceScreen, UnknownRoleScreen.

**Optik okuma:**
- CameraPermissionSheet ("Ayarları Aç").
- 3 adımlı OmrTutorialSheet.
- Kılavuzlu çekim, büyüteçli köşe ekranı.
- Yüzdeli gönderim (StepRow).
- Fotoğrafı koruyan hata ve tekrar deneme.
- FormCheckScreen (özet, sayaçlı kolonlar, boş okunan işaretli) ve AnswerFixSheet.
- Doğrulamalı ExamRequestScreen.
- OmrErrorView: form bulunamadı, bakım, çevrimdışı, kamera açılamadı.
- Tek ekran ResultMomentScreen ve NotificationPrimerSheet.
- Koç için öğrenci seçimi sheet'i.

**Deneme:**
- Yapışkan 4 sekme (Genel, Sorular, Konular, Kartlar).
- Tümü / Yanlışlar / Boşlar süzgeci.
- "Az soru" etiketi, "Bu Konuyu Çalış", "Kartları Çalış".

**Analizlerim:**
- FilterSheet (sınav, alan, ders).
- Eksenli NetChart.
- Delta satırlı StatBox.
- Süzülüp sıralanan Denemelerim listesi.

**Dersler ve kartlar:**
- Eksik süzgeci ve sayaçlı segment.
- Akordeonlu TopicDetail ve ExampleBox; ilk eksiğe kaydırma.
- CardSheet ("Kartı Aç").
- CardDeckScreen: eskiden ulaşılamıyordu, artık ortak deste.
- AuthorSheet ve WebOnlySheet.

**Anasayfa ve Program:**
- YKS sayacı, Bugün, Son denemen, Derslerin.
- Gün ve Hafta görünümü (WeekGrid).
- 3 adımlı NewProgramFlow ve editMode.
- Çalışan arama, onaylı ve geri alınabilir Günü Sıfırla, Programı İptal Et.

**Hesap:**
- Gruplu AccountScreen ve sürüm satırı.
- ProfileScreen view/edit. Avatar, sınıf ve alan değişimi yeni.
- Gerçek PasswordScreen.
- DeleteAccountFlow.
- CoachingScreen (bağlı / bağlı değil, kod maskesi).
- Gerçek kategorili NotificationsScreen, sessiz saatler ve TimeWheel.
- AgreementsScreen ve AgreementReader.
- Bize Yaz.

**Koç:**
- CoachHome: öğrenci şeridi, dikkat gerektirenler (iki kural), yaklaşan görüşmeler.
- Türkçe vurgulu arama.
- AddStudentSheet ve CredentialsSheet.
- ContextStrip'li StudentProfileScreen.
- MeetingsScreen ("Kiminle" süzgeci).
- NewMeetingSheet, MeetingDetail ve NoteSheet (onaylı silme, geri al).
- Koçun Hesap'ında kod kartı.

**Mağaza:** 7 karelik panorama, App Store ve Play kesimleri, öne çıkan görsel.

---

## 5. Denetimlerden "yapma" kuralları (Bölüm 6, Tur 1–11)

**Genel görünüm:**
1. Emoji yok: selamda, toast'ta, SnackBar'da hiçbir yerde.
2. Gradyanlı hero + cam istatistik kartı + ilerleme halkası üçlüsü yok. Uygulamadaki tek gradyanlar iskelet parıltısı ve kaydırma solması.
3. Elmas, coin, seri ve rozet yok; verisi olmayan oyunlaştırma yok.
4. Eksensiz grafik yok; noktalar dokunulabilir. Hedef çizgisi yok.
5. Kategori başına renkli hap ya da kart şeridi yok. Renk yalnız ders glif karosunda.
6. Üstü çizili tamamlanmış görev, tamamlama yüzdesi ve tamamlama işareti yok (D-3, D-26).
7. Parıltı, bulanık renk lekesi ve konfeti yok. Bulanıklık yalnız alt çubukta ve sheet perdesinde; başka yerde `BackdropFilter` yok.
8. Her bölüme "kart + başlık + Tümü ›" yok; yalnız Bugün'de "Programım" var.
9. Büyük harfli, harf aralıklı üst etiket yok. "Eyebrow + selam + gri alt satır" üçlüsü yok.
10. Koyu tema, açık temanın ters çevrilmiş hâli değil.

**Renk:**
11. Turuncu yalnız kamera (deklanşör, kenar dörtgeni, köşe noktaları), konum göstergesi (sekme, alt çubuk, sayfa noktası), ilerleme, "bugün", grafikte seçili ya da son nokta ve logonun alt kancası.
12. Turuncu üstüne beyaz metin yok. Turuncu düğme yok.
13. Kırmızı yalnız Çıkış satırında, tehlikeli metin düğmelerinde, tehlikeli onayda (Hesabı Sil, koç bağlantısını kaldırma, not silme) ve yanlış cevapta. Eksik işareti amber.
14. Değişim değerleri yeşil değil, delta tonunda (Tur 10).

**Tipografi ve metin:**
15. 13 pt altı metin yok; tek istisna 12 pt alt çubuk etiketi. Gövde en az 15 pt.
16. Büyük harfli düğme yok. Büyük harf gerekirse `toUpperCase()` değil, tr dönüşümü.
17. İç kod ("D-", "Ek C", "Tur"), "Hata:" öneki ve ham Exception metni yok.
18. "İptal" yok; düğmede "Evet" yerine eylemin adı.
19. Zorunlu alan yıldızı yok. Kanvas zemininde placeholder yok.
20. Uzun adlar kesilmez; en çok 2 satır.

**Veri:**
21. Ek C dışındaki her değer varsayım olarak işaretlenir.
22. Veri yoksa alan hiç çizilmez: boş kutu, "0" ya da tire yok.
23. Sayılar bağlamsız gösterilmez; etiketsiz rozet yok.
24. "Geçen ay" hiçbir yerde yok.
25. Sabit OBP, "Deneme: N" ve "(Test)" yok.

**Etkileşim:**
26. Her ekranda tek birincil eylem; kamera ve deklanşör hariç.
27. Sonuç anında konfeti, dönen sayaç ya da parlama yok; yalnız success haptiği.
28. Önceden dolu alan yok.
29. "Yakında" sheet'i ekranlarda kullanılmaz; "Haber ver" yok.
30. Ödeme, paket, coin ve kayıtlı kart yok.
31. Kaydet düğmesi yalnız Profil düzenlemede; anahtarlar anında kaydeder.
32. Hesap silmede kelime yazdırma ve yeniden kimlik doğrulama yok. Odak Vazgeç'te açılır.
33. Kart öğrenme kaydırmayla olmaz, yalnız düğmeyle.
34. Otomatik çekim, flaş ve galeri yok.
35. Bildirim izni bağlamsız istenmez; ilk başarılı okumadan sonra sorulur.
36. Koç görünümünde düzenleme ve öğrenciye özel eylemler (favori, Öğrendim, Günü Sıfırla) yok.
37. Dikkat listesinde iki kural dışında sinyal yok: puan, hedef, tamamlama yok.

**Görsel varlıklar:**
38. Kil illüstrasyon yalnız onboarding, ekran düzeyi boş durum ve mağazada; ekranda en fazla bir. Ders satırında kil yok.
39. Logo ikonunda parlama ve gradyan yok. Ad ve avatar yalnız Anasayfa ve Hesap'ta; logo yalnız açılış ve girişte.
40. Yazı tipi çalışma anında indirilmez.

**Tanıtım ve mağaza:**
41. Süre, sıralama, puan ve "yapay zeka" vaadi yok.
42. Ad yalnız "SMAP"; "Stundent map" kullanılmaz.
43. Kaldırılan özellikler (coin, Oyunlar, Gelen Kutusu, SmapLab, ödeme) görünmez.
44. Puan, yorum ve indirme sayısı çizilmez. Turuncu metin yok.
45. Kil nesneler ekran metninin üstüne binmez; en çok 3 nesne.
46. Telefonlar kesim çizgisine 40 px'ten fazla yaklaşmaz.
47. Parlama, rota ve kil yalnız mağaza görsellerinde; uygulama ekranlarına girmez.

**Denetim yöntemi (Tur 10):**
- Telefon karelerinin içinde taranan maddeler: emoji, büyük harfli metin, iç kod, üstü çizili metin, turuncu üstünde beyaz, alt çubuk ve perde dışında bulanıklık.
- Lint: 13 pt altı metin, görsel alt metni, SVG erişilebilirliği, ikon düğmesi adı.
- Elle kontrol: D/Y/B dili, yazı ölçeği, turuncunun yeri, koyu tema listesi.

---

## 6. Açık kalan maddeler ("!" notları)

- **Sosyal giriş logoları:** resmî Apple ve Google varlıkları uygulama aşamasında eklenecek (Tur 7, Tur 10).
- **Sürüm ve sözleşme tarihleri:** panolarda örnek değer; derlemeden ve sunucudan okunacak (Tur 10).
- **Mağaza varlıkları:** gerçek cihaz çerçevesi ve onaylı logo dosyaları gelince 12.1–12.3'teki bu katmanlar değişecek. Boyutlar App Store Connect ve Play Console'da doğrulanmalı (Tur 11).
- **Logo kararı:** lacivert pafta mı açık sürüm mü, karar kullanıcıda (T1.34). Kapak görselleri hâlâ yer tutucu (T1.26).
- **Alt başlıkta kart durumu:** madde başına kart durumu sunucuda varsa "4 kartın 3'ü öğrenildi" satırı eklenebilir (Tur 5).
- **Hafta ızgarası:** bloklar yalnız ders adını taşıyor (Tur 6).
- **Tur 10'da kapananlar:**
  - "+8,25" yeşilinin Doğru yeşiliyle aynı olması (Tur 2, Tur 6).
  - Kitteki ikonsuz küçük D/Y/B sayaçları (Tur 3).