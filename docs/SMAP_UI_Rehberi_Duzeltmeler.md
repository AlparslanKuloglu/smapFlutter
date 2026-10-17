> **Tarihçe notu (teslim, 2026-10-18):** Bu belge planlama döneminde yazıldı. İçindeki `SHP/`, `SLP/`, `MEM/` kısaltmaları ve Sepello, Memora, Sleepia adları repo dışındaki referans uygulamalardır; `TSR/`, `tasarim-html/` ve `unpacked/` o günkü tasarım klasörüdür. Bunlar ekibin elinde değildir ve gerekmez: kalıpların bu repoda uygulanmış hâli `docs/dev/` bölümlerinde, tasarım `docs/design/` altında, bağlayıcı kurallar `AGENTS.md`'dedir. Belgedeki kararlar (K1–K16) ve gerekçeler geçerlidir.

**SMAP UI Uygulama Rehberi incelemesi**

Rehberde atıf yapılan yolların çoğu var ve iddia edileni söylüyor. mihr_ui yayımlanmış dev.3 kopyasından kontrol edildi: `MihrThemeConfig` alanları (`materialOverrides` dahil), `MihrTypography.fromFontFamily`, `MihrButtonShadows.flat`, `MihrSpacing` ve `MihrRadius` değerleri, düğme boyları (md 40/14, xl 48/16) doğru. Sepello commit ve PR eşlemesi, SMAP satır atıfları ve uç adları da doğru. SMAP'teki eski dosyaların satır sayıları birebir tutuyor (2.652, 1.663, 829, 1.088). Aşağıdakiler düzeltilmeli.

**(a) Düzeltmeler (yanlış → doğru)**

1. **Pano sayısı:** "101 pano" yanlış. `TSR/unpacked` altında 108 pano var (3+26+7+8+10+10+4+6+2+7+6+16+3). Sayfa 12 mağaza görselleri (12.1–12.3); rehber bu sayfadan hiç söz etmiyor.
2. **Devir dokümanının yolu:** `SHP/Sepello_Gelistirme_Devir.md` yok. Doğrusu `SHP/.cursor/plans/arastirma/tasarim/Sepello_Gelistirme_Devir.md` (commit 19e21e2).
3. **PR #29 dosya sayısı:** "shared/ui altında 42 dosya" yanlış. Commit'te toplam 42 dosya var, bunların 27'si `lib/shared/ui/` altında (`git show --name-only 4498fb1`).
4. **Blur API'si:** `BackdropBlurStyle.custom(sigma: 10, blurPx: 20)` derlenmez. dev.3'te `lightOverlay` ve `darkOverlay` de zorunlu (`mihr_ui-0.1.0-dev.3/lib/core/theme/shadows/mihr_backdrop_blurs.dart:72-77`). Bu ikisine bgBar değerleri verilmeli. `FrostedContainer` köşe yarıçapını varsayılan olarak `MihrRadius.borderXl` alıyor (`core/widgets/frosted_container.dart`), alt çubuk için `BorderRadius.zero` geçilmeli.
5. **48 dp dokunma hedefi:** "AppButton bunu `MaterialTapTargetSize.padded` ile sağlar" yanlış. Mihr düğmeleri ThemeData'yı okumuyor; `ButtonStyle.tapTargetSize` değerine bakıyor, varsayılanı `shrinkWrap` (`mihr_button_base.dart:284-287`, `mihr_button_defaults.dart:60,85,133`). Değer örnek başına verilmeli; Sepello bunu `SHP/lib/shared/ui/buttons/app_button.dart:145`'te yapıyor.
6. **dev.3 hatası:** `styleBuilder` dev.3'te tema düzeyindeki override'ları atıyor; düzeltme dev.4'te (`MIHR/CHANGELOG.md`). AppButton ya `style` vermeli ya da tema override'ı kullanmamalı.
7. **Global tema riski:** dev.3'teki `MihrTheme`, stok TextButton/ElevatedButton/OutlinedButton'ı bozuyor: 48'in altında hedef, büyük metinde kesilen etiket (CHANGELOG dev.4 "Fixed"). T0'daki global tema değişimi eski ekranları bu yüzden de bozar.
8. **AppButtonSize eşlemesi:** `AppButtonSize.lg48`, `MihrButtonSize.xl`'e eşlenmeli. Mihr'de `lg` 44 (`mihr_button_sizes.dart:48-49`).
9. **OfflineStrip kaynağı:** `SHP/lib/core/services/connectivity_service.dart` Firestore'a bağlı (`config/flags` snapshot, satır 6-30), SMAP'e taşınamaz. Doğru kaynak `SLP/lib/services/connectivity_service.dart` (connectivity_plus). `SHP/.../toast_service.dart:1,62` de `cloud_firestore` kullanıyor; port ederken çıkarılmalı.
10. **Paket sürümleri:** "phosphor_flutter ve flutter_gen_runner sürümleri SHP/pubspec.lock'tan" yanlış. Bu iki paket üç referans uygulamanın hiçbirinin kilit dosyasında yok; sürüm ayrıca seçilmeli. `permission_handler`, `url_launcher`, `connectivity_plus`, `package_info_plus` da A6 listesinde eksik.
11. **K12 kalıbı:** "StackedView + reactive=false üç app'te ortak" yanlış. Memora (`credits_page.dart:37`) ve Sleepia (`home_tab_page.dart:60`) `ViewModelBuilder.nonReactive` kullanıyor; yalnız Sepello StackedView kullanıyor (`home_view.dart:68,72`).
12. **K4 route adı:** Sepello'daki gerçek değer `replaceInRouteName: 'Page|Screen|View,Route'` (`SHP/lib/app/router/app_router.dart:47`).
13. **Satır aralıkları:**
    - `SLP/lib/main.dart:67-262` → 75-283 (main 75, splash preserve 79, remove 283).
    - `register_form.dart:24-28` → 25-29.
14. **Stub sayısı:** "30 stub" → PLAN 1.1'de 31.
15. **"Memora 01 §3.3" atfı:** Doğrusu `SHP/.cursor/plans/arastirma/uygulama/01-memora-kaliplari.md §3.3`, ve orada Memora'nın kalıbı "ATLA" olarak işaretli. Ayrıca kural 15'in örnek gösterdiği `item_form_viewmodel.dart:72-75` VM içinde TextEditingController tutuyor, yani kural 9 ile çelişiyor. Ya istisna yazılmalı ya da başka örnek seçilmeli.
16. **Dosya boyutu kanıtı:** Sepello'nun presentation katmanında 30 dosya 400 satırı aşıyor; medyan 222, p90 564. "Medyan 160, p90 473" ve "11 `_buildX` metodu" doğrulanamadı (bulunan 2). Sınırlar Sepello'ya dayanmıyor; hedef olarak yazılmalı.
17. **Kontrast testi:** "1.3'teki her çift ≥ 4,5:1" testi kırılır. Matriste sarı (yalnız büyük metin, ≥3:1) ve gri (kullanılmaz) hücreler var (`TSR/unpacked/SMAP-01/02-1-3-.../text.txt:4`). text-disabled ve border-strong muaf (1.2). Test yalnız izin verilen çiftleri, uygun eşikle kontrol etmeli.
18. **`context.motion` davranışı:** `SHP/lib/core/theme/app_motion.dart:58`'de hareketi azalt açıkken varsayılan dönüş `Duration.zero`. 150 ms opaklık için çağrıda `reduced:` açıkça verilmeli.
19. **Brif adı:** K2 ve §9.1'de "brif" denen dosya aslında `tasarim-paketi/SMAP_Claude_Design_Brifi.md` (Ek A–D). Panolardaki D-4, D-14 ve Ek C atıfları bu dosyaya gidiyor (`:827`, `:917-953`). `SMAP_Claude_Design_Prompt.md` daha eski spec.
20. **Boş referans:** §8.2'deki "Envanter (§9'daki düzeltmelerle)" bir yere gitmiyor. Envanterde §9 yok, rehberin §9'u da envantere düzeltme içermiyor.
21. **Doc yorum dili çelişkisi:** §6 madde 20'deki örnek Türkçe doc yorumu; AGENTS taslağı ise "doc comments in English" diyor. Sepello İngilizce yazıp Türkçe metni alıntılıyor (`home_view.dart` doc yorumu).
22. **Sıralama sorunu:** T0–T2 yalnız A izine bağlı ama gerçekte B izine de bağlı:
    - ThemeService DI (B3) ister.
    - `app.dart` `MaterialApp.router` (B7) ister.
    - Galeri, router üzerinden `push` ile açılıyor (`SHP/lib/app/app.dart:37`).
    - ToastService constructor'da `AppRouter` alıyor (`toast_service.dart:24`).

    Çözüm: B3 ve B7 A izine alınsın, ya da T0'da tema mevcut `MaterialApp`'e bağlansın (`SMAP/lib/main.dart:85`) ve galeri ayrı bir giriş noktasıyla açılsın.
23. **E20 ve E9 bağımlılığı:** E20 (`ThemeMode.system` ve `lib/views` silme), E8 [BLOKE] varken yapılamaz. OMR akışı `lib/views/optic_mark_detection_view` altında kalıyor. E9'un sonuç anı da ancak eski kamera akışının sonuna bağlanarak denenebilir; bu yazılmalı.
24. **Ad çakışması (karar tablosuna eklenmeli):** 1.2 ve 11.12'nin "Flutter" sütunu ext adları veriyor (`navyBand`, `onNavyBand`, `contextStrip`, `bar`, `dybOn`, `dybEmpty`). Rehberin camelCase adları (`bgNavy`, `textOnNavy`, `bgContext`, `bgBar`, `onDyb`) bunlarla çelişiyor.
25. **Sayaç çelişkisi:** 11.13 Segment "boş sayaç çizilmez" diyor, Tur 1 notu "sıfırsa 'eksik yok'" diyor. Rehber Tur 1'i seçmiş, bu da kendi "11.x kazanır" kuralına aykırı. §4.1 tablosuna eklenmeli.
26. **SDK sürümü:** SMAP `sdk: ^3.8.1`, Sepello `^3.10.7` ve CI'da Flutter 3.38.6 (`SHP/.github/workflows/ci.yml:20`). Port öncesi A4'te SDK eşitlenmeli ve `.puro.json` ile sabitlenmeli.
27. **TextTheme kaybı:** `copyWith(textTheme: SmapText.toTextTheme())` atanmamış slotları (displayLarge/Medium, headlineLarge/Medium) null bırakır. `base.textTheme.merge(...)` kullanılmalı.

**(b) Eklenmesi gerekenler**

- **Eksik bileşenler** (11.13 ve 11.14'te var, §5'te yok): RoleOption (2.2), OnboardingPage ve sayfa noktaları (2.1), ProfileSummary (9.1), ExampleBox (7.3), AuthorRow (7.4), SessionProgress (8.1), maskeli TextField (9.5), "Web'de Aç" sheet'i (7.1, D-5), Sözleşme okuma görünümü (9.7; flutter_html zaten var).
- **Uygulama ikonu:** 1.26 S-rota ve 2.7 "uygulama ikonu" için `flutter_launcher_icons` yeniden üretimi planlanmalı. Bugün `assets/logotext.png`'yi gösteriyor (`SMAP/pubspec.yaml:78-81`); PLAN 0.11 ikondaki alfanın kaldırılmasını da istiyor.
- **Mağaza görselleri:** Sayfa 12 (12.1–12.3) ve `SMAP_Store_Screenshots_Prompt.md` için ya bir adım eklenmeli ya da kapsam dışı olduğu yazılmalı.
- **Kapsam dışı listesi:** D-4'ün v1'den çıkardıkları açıkça yazılmalı: Gelen Kutusu, Analiz sekmesi, SmapLab, SmapCoach, Müfredat, Kaynak Takibi, Soru Bankam, soru fotoğrafı, paywall. PLAN 2.5 ("Analiz") ve 2.10 ("Gelen Kutusu") bu yüzden güncellenmeli. D-4, PLAN P7'yi de cevaplıyor.
- **Koyu tema eksikleri:**
  - Ters yüzey token'ı yok. Koyu temada toast ve çevrimdışı şeridi #E8ECF1 zemin üstünde koyu metin (`TSR/unpacked/SMAP-01/23-1-24-.../text.txt:73`).
  - Kamera akışının her temada koyu kalması için `Theme(data: SmapTheme.dark)` sarmalayıcısı yazılmalı.
  - Lacivert bant, açık detay barı ve kamera için ayrı `SystemUiOverlayStyle` (AnnotatedRegion) gerekiyor.
  - Android edge-to-edge ve gezinme çubuğu ele alınmalı.
  - `toColorScheme`'e `inverseSurface` eklenmeli.
- **Eksik tipografi stili:** Detay barının küçülmüş başlığı 15/20·600 (1.18), SmapText'te yok. Ayrıca kök bant küçülürken alt köşeler düzleşiyor ve segmentli bant küçülmüyor (1.18:24).
- **l10n:**
  - `flutter: generate: true` ekle (SMAP pubspec'te yok).
  - Testlerde `initializeDateFormatting('tr')` çağır.
  - CI'da gen-l10n diff kontrolü ekle (Sepello CI yalnız build_runner diff'ine bakıyor).
  - `supportedLocales` bugün `tr_TR` (`main.dart:93`), ARB ise `tr`; eşitle.
- **Testler:**
  - SessionManager offline restore, guard zinciri ve DI smoke testi.
  - Muafiyetleri bilen kontrast testi.
  - SmapColors light ve dark'ın aynı alan kümesine sahip olduğunu doğrulayan test.
  - K7 için seçenek: `meetsGuideline` (tap target, text contrast) testleri. Ucuz, ama widget testi sayılır.
- **Servis haritası (§2.3) eksikleri:** `repository/home_repository.dart` (getGeneralLessons, getLessonsTotalMissing, getMyStudents) haritada yok. E6 ve E15 buna dayanıyor. E4'ün silinecekler listesinde `register_provider.dart` eksik. `lib/domain/models/*` haritada yok.
- **B1 AppConfig:** ForceUpdate'teki "mağazayı aç" eylemi için `appStoreId` ve Play paket adı eklenmeli (PLAN 1.3).
- **iOS izin hazırlığı:** E2 başlamadan `permission_handler` iOS Podfile makroları ve `NSCameraUsageDescription` A izine alınmalı. Info.plist'te şu an bu anahtar yok.
- **Çelişki:** P4 yön kararı (yalnız dikey mi). Ayrıca §9.3'teki "yeni varlık eklenmez" kuralı ile A6'daki "avatar ve kil 3x eklenir" maddesi çelişiyor.
- **Tarayıcı fork'unun yeri:** Memora fork'u da `lib/vendor/flutter_document_scanner` altında duruyor, `packages/` altında değil. Taşınırsa pubspec yolu ve analyze exclude güncellenmeli.

**(c) Genel hüküm**

Rehber esas olarak sağlam ve uygulanabilir. Sepello sırası (temeller → kit → kabuk → ekranlar) kanıtla doğru taşınmış; token değerleri 1.1, 1.2, 1.4, 11.12 ve Tur 1 notlarıyla birebir tutuyor. Onaya sunulmadan önce şu düzeltilmeli:

- dev.3'e özgü üç API ve davranış hatası (blur `custom` imzası, dokunma hedefi, `styleBuilder`).
- Firestore'a bağlı iki port kaynağı (ConnectivityService ve ToastService).
- Başlıklar arası bağımlılık sırası (T0–T2'nin B3/B7'ye, E20'nin E8'e bağlılığı).
- Koyu tema için ters yüzey token'ı ve kamera ekranlarını koyu tutma yöntemi.
- 11.12 ad çakışması ve sayaç kuralının §4.1 karar tablosuna girmesi.
- Pano sayısı (108) ve brif yolu.

Bunlar düzeltilirse T0 başlatılabilir.