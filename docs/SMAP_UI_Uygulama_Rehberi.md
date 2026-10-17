# SMAP UI Uygulama Rehberi

> **Tarihçe notu (teslim, 2026-10-18):** Bu belge planlama döneminde yazıldı. İçindeki `SHP/`, `SLP/`, `MEM/` kısaltmaları ve Sepello, Memora, Sleepia adları repo dışındaki referans uygulamalardır; `TSR/`, `tasarim-html/` ve `unpacked/` o günkü tasarım klasörüdür. Bunlar ekibin elinde değildir ve gerekmez: kalıpların bu repoda uygulanmış hâli `docs/dev/` bölümlerinde, tasarım `docs/design/` altında, bağlayıcı kurallar `AGENTS.md`'dedir. Belgedeki kararlar (K1–K16) ve gerekçeler geçerlidir.

Tarih: 2026-10-11 · Kapsam: Claude Design yeniden tasarımının (Tur 1–11) `smapFlutter`'a uygulanması · Bu rehber `SMAP_Gelistirme_Plani.md`'yi tekrar etmez, onu UI tarafında ayrıntılandırır.

**Kısaltmalar**

| Kısaltma | Yol |
|---|---|
| `SMAP/` | . |
| `SHP/` | Sepello (repo dışı referans uygulama) (Sepello) |
| `SLP/` | Sleepia (repo dışı referans uygulama) |
| `MEM/` | Memora (repo dışı referans uygulama) (Memora) |
| `MIHR/` | mihr_ui paketi (pub) |
| `TSR/` | docs/design (Claude Design kanvas dışa aktarımı) |
| `PLAN` | docs/history/SMAP_Gelistirme_Plani.md |

**Pano okuma:** "pano 3.1" kanvastaki pano kodudur. Metni `TSR/unpacked/SMAP-03/00-3-1-Anasayfa-3-kare/text.txt` dosyasında, görseli `TSR/png/SMAP-03_00-3-1-Anasayfa-3-kare.png` dosyasında durur. Dosya adındaki sıra 0'dan başlar (`00-3-1`), pano kodu 1'den başlar (`3.1`). Sepello'daki gibi iki numaralama vardır; kodda her zaman pano kodu yazılır.

---

## 1. Özet

### 1.1 Sepello'da tasarım nasıl uygulandı (kanıt: `SHP/` git geçmişi)

| Sıra | Commit / PR | Ne yapıldı |
|---|---|---|
| 1 | 84fcf9f / PR #22 | Claude Design brifi (`SHP/.cursor/plans/arastirma/tasarim/claude-design-prompt.md`): 8 tur ve Ek A token eki. |
| 2 | 13b7816, 729cede, 7e2b36c / PR #24–26 | Tasarımcının sorularına verilen tur tur cevaplar. |
| 3 | 19e21e2 / PR #27 | Devir dokümanı (`Sepello_Gelistirme_Devir.md`): yüzey rolleri, 37 bileşen, hareket tablosu, 218 geliştirici notu. Kanvas `.gitignore`'a alındı. |
| 4 | c94602c / PR #28 | **Temeller:** `SHP/lib/core/theme/sepello_colors.dart`, `identity_tone.dart`, `app_motion.dart`, `SHP/lib/core/services/app_haptics.dart` (+ `SHP/ios/Runner/AppDelegate.swift` kanalı), `theme_service.dart` (varsayılan koyu), DI test satırı. |
| 5 | 4498fb1 / PR #29 | **Bileşen kiti:** `SHP/lib/shared/ui/` altında 42 dosya ve `SHP/lib/features/debug/component_gallery_view.dart`. SepelloColors, kanvas CSS değişken adlarıyla yeniden yazıldı (PR #28'deki rol adları atıldı). |
| 6 | 82bb83e (PR #29 içinde) | Uygulama planı (`SHP/.cursor/plans/yeniden-tasarim-uygulama.md`) ve araştırma raporları 01–07. |
| 7 | a8e8e7b / PR #30 | **Kabuk:** AppBottomNav, AppTopBar + ScrollReveal, AppFab, AppBottomBar. Eski kabuk widget'ları silindi. |
| 8 | PR #31–33 | Ekranlardan önce veri sözleşmeleri: sayaçlar, kurallar, istemci altyapısı. |
| 9 | e6c7cc2 / PR #34 | İlk ekran: Ana Sayfa. Bölümler part dosyası, her biri SelectorViewModelWidget. |
| 10 | PR #35–#115 | Çekirdek ekranlar, hesap (E PR-01..17), topluluk. Her PR bir ekran dilimi; kitteki eksik genel parça aynı PR'da `shared/ui`'a eklendi. |
| 11 | eb11067, e6f526c, 1a8f42b … | CI'ı kıran kullanılmayan importlar, hata eşleme ve native build sırası düzeltmeleri (ders olarak §9'da). |

Önemli fark: Sepello'da stacked, get_it, auto_route ve dart_mappable redesign'dan **önce** vardı; A–C aşamaları yalnız UI'dı. SMAP'te bu altyapı yok (PLAN §1–§2). Bu yüzden SMAP'te sıra bir adım uzar: **mimari ön koşullar → temeller → kit → kabuk → ekranlar (açılıştan ileri)**.

### 1.2 SMAP'te aynısı nasıl yapılacak

- **Tasarım kaynağı hazır.** `TSR/` 13 sayfa ve 101 pano içeriyor (Tur 1–11). Sepello'daki devir dokümanının karşılığı beş teslim panosu:
  - 11.12 Token Tablosu (son hâl)
  - 11.13 Bileşen Listesi
  - 11.14 Ekran–Bileşen Eşlemesi
  - 11.15 Hareket ve Haptik
  - 11.16 Bütün Varsayımlar (134 madde)

  Akış haritaları 0.1–0.3'te. Tur 1'in geliştirici notları (pano 11.1) ColorScheme, SmapColors ve TextTheme eşlemesini Dart olarak veriyor.
- **Sepello'dan farkı: kanvasta CSS değişkeni yok.** Her pano kendi satır içi stilini taşıyor (`TSR/unpacked/*/*/styles.css` dosyalarında `--` değişkeni bulunmadı). Token'ların tek kaynağı 11.12 tablosu ile onu tamamlayan 1.2 ve 1.4 panoları. Sepello'nun "alan adlarını CSS değişkeninden al" dersi burada "**alan adlarını 11.12'deki token adlarından al**" olarak uygulanır.
- **Tasarımcının önerdiği ilk iş Sepello sırasıyla aynı** (pano 11.10, "Uygulamada ilk iş"): önce SmapColors ve SmapText, sonra RootBand, DetailBar, BottomBar, BottomSheet, ConfirmSheet, Toast ve durum kalıpları; ekranlar bunların üstüne kurulur.
- **Yol (ayrıntısı §7):**
  1. Ön koşullar (§2) iki izde ilerler: UI izi (A1–A6) ve veri izi (B1–B8).
  2. T0 token'lar ve tema
  3. T1 kit-1 kontroller + bileşen galerisi
  4. T2 kit-2 katmanlar ve durum kalıpları
  5. T3 kabuk parçaları
  6. T4 SMAP alan bileşenleri (D/Y/B, ders, deneme)
  7. E1 açılış → E2 tanıtım/rol → E3 giriş → E4 kayıt → E5 kabuk ve kamera düğmesi → E6 Anasayfa → … → E20 kapanış

### 1.3 Mevcut uygulama: mimari ve servisler

Durumun tamamı PLAN §1–§3'te. UI'ı doğrudan etkileyen özet:
- Provider/ChangeNotifier ile 231 `setState` var. İki ayrı UserProvider örneği var.
- Navigasyon üç mekanizmayla (named route, inline `MaterialPageRoute`, enum nav notifier) yapılıyor; HTTP üç yığınla.
- Veri `Map<String,dynamic>` olarak dolaşıyor.
- God widget'lar var: `SMAP/lib/features/analytics/presentation/screens/edebiyat_lesson_detail_page.dart` 2.652 satır.
- Menü yönlendirmesi görünen etikete bağlı (`SMAP/lib/features/home/presentation/widgets/home_menu_grid.dart:139-158`). Tasarım etiketleri değiştirince navigasyon sessizce kırılır.

Servislerin hedef karşılıkları §2.3'te.

### 1.4 Onay bekleyen kararlar (varsayılanlarla)

AGENTS kuralı gereği kodlamadan önce Rasit onaylar.

| # | Karar | Varsayılan | Gerekçe |
|---|---|---|---|
| K1 | mihr_ui `brand` | **Lacivert** (navy-900 #0F294A). Turuncu yalnız kamera, konum göstergesi, ilerleme, "bugün". | Pano 1.2 ve Tur 1 varsayım 1.6. PLAN 1.11'deki "turuncu CTA" notu ve mihr araştırmasındaki "orange = brand" önerisi tasarımın son hâliyle çelişiyor. |
| K2 | Token kaynağı | 11.12 + 1.2 + 1.4. Çelişkide 11.12 kazanır (§4.1). | `SMAP_Claude_Design_Prompt.md`'deki tablo (#F5F7F9, #64748B, kart 20, buton 14, sheet 28) brifti; kanvas onu değiştirdi. |
| K3 | Bileşen öneki | Genel kit `App*`; SMAP alan bileşenleri öneksiz (`DybCounter`, `QuestionCell`). Tasarımın `Smap*` önerisi doc yorumunda anılır. | Sepello ile aynı dil; genel parçalar ileride mihr_ui'ye taşınabilir. |
| K4 | Ekran sınıfı adı | `XxxView` + `XxxViewModel`; auto_route `replaceInRouteName: 'View,Route'`. | `SHP/lib/app/router/app_router.dart` ile aynı. |
| K5 | Tema modu | Göç boyunca `ThemeMode.light` sabit; E20'de `ThemeMode.system`. Görünüm sayfası yok. | Eski ekranlar yalnız açık tema. Pano 9.1'de tema satırı yok. Sepello aynı mantıkla koyuyu sabitlemişti (`SHP/lib/core/services/theme_service.dart:19-21`). |
| K6 | Dil | Yalnız `tr` (şablon `app_tr.arb`). | PLAN §7 P5 cevaplanana kadar. |
| K7 | UI testi | Ev kuralı: widget/golden testi yok; mantık testi ve galeri ile elle kontrol. | PLAN Faz 1.13, 2 ve 4.3 golden öneriyor; Sepello'daki Rasit kuralı ise "UI testi yok" (`SHP/.cursor/plans/arastirma/uygulama/04-bilesen-plani.md:53`). Rasit seçmeli. |
| K8 | mihr_ui sürümü | pub `^0.1.0-dev.3` (Sepello ile aynı). Path dependency yok; dev.4 yayımlanınca yükseltilir. | Path bağımlılığı CI'ı kırar (Sepello 03-mihr-ui §0). |
| K9 | Tabular rakam | Bütün SmapText stillerinde `tnum`. | Tur 1 notu "TextTheme eşlemesi · tabularFigures()" diyor; 1.6 yalnız rakam stillerini sayıyor. |
| K10 | Asset erişimi | `flutter_gen_runner` ile üretilen `Assets.*`. | Codegen zaten build_runner'da. Memora'nın VS Code eklentisi (`MEM/lib/assets.dart`) CI'da ve ajan oturumunda üretilemiyor. |
| K11 | Köşe şekli | Düz yuvarlak köşe (`RoundedRectangleBorder` / `ClipRRect`). | Tasarım CSS `border-radius` çiziyor. Sepello'nun "her dikdörtgen squircle" kuralı alınmaz. |
| K12 | Bağlama kalıbı | `StackedView` + `reactive => false` + bölüm başına `SelectorViewModelWidget`. | Sepello Home (`SHP/lib/features/home/presentation/home_view.dart`), Memora (`MEM/lib/features/credits/presentation/credits_page.dart`) ve Sleepia (`SLP/lib/features/home_tab/presentation/home_tab_page.dart`) ortak kalıbı. |

---

## 2. Ön koşullar (UI'dan önce bitmesi gereken minimal set)

PLAN Faz 0 ve Faz 1'in tamamı gerekmez. Aşağıdakiler gerekir. İki iz paralel yürür:
- **İz A** bitince T0 (temeller) başlar.
- **İz A ve İz B** bitince E1 (ilk ekran) başlar.

### 2.1 İz A: temellerden önce

| # | Ne | Neden şimdi | Taşınacak kaynak | PLAN | Bitti sayılır |
|---|---|---|---|---|---|
| A1 | Git hijyeni. Değişmiş 4 dosya (`ios/Podfile.lock`, `project.pbxproj`, `main_inapp_webview.dart`, `views/onboarding/onboarding_page.dart`) ve `.vscode/` için karar verilir. `main` + dilim branch modeli kurulur. | Repoda tek commit var. Sepello'da paralel oturumların commit edilmemiş kodu çakıştı (04 §11.1). | `SHP/.gitignore`, `SHP/AGENTS.md` (git akışı) | 0.1 | `git status` temiz; ilk PR akışı çalışıyor. |
| A2 | Ölü kod ve sahte giriş verisi. `lib/views/{auth,main_webview,onboarding}`, `optic_requests` kopyaları, `services/google_auth_service.dart` ve 30 stub dosya silinir. Login prefill'i (`SMAP/lib/features/auth/presentation/screens/login_screen.dart:19-20`) ve `register_form.dart:24-28` test verisi kaldırılır. Kullanılmayan paketler çıkarılır. | Çift onboarding dosyası yüzünden düzenleme yanlış dosyaya gider. Stub'lar klasör yapısını yalanlıyor. | – | 0.2, 0.3, 1.1 | `flutter analyze` temiz; çift dosya yok. |
| A3 | Klasör yapısı (§3) ve `SMAP/AGENTS.md` (§10). `CLAUDE.md` aynı içeriği gösterir. | Ajan oturumları kuralları buradan okuyacak. | `SHP/AGENTS.md`, `MEM/CLAUDE.md` | 1.1 | Dosyalar main'de. |
| A4 | Lint ve CI. very_good_analysis kademeli açılır; `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, `use_decorated_box`, `avoid_print` açık. GitHub Actions'ta analyze ve test çalışır. Kırık `widget_test.dart` yerine DI smoke testi gelir. | Sepello'da 3 düzeltme commit'i yalnız CI'ı kıran import içindi. | `SHP/analysis_options.yaml`, `SLP/analysis_options.yaml:24-30`, `SHP/.github/workflows/ci.yml` (flutter job), `SHP/test/dependency_inj/injection_container_test.dart` | 1.2 | CI yeşil. |
| A5 | l10n iskeleti: `l10n.yaml` (arb-dir `lib/l10n`, şablon `app_tr.arb`), `context.l10n` uzantısı, `ToastText` typedef. | Kitte bile metin var ("Vazgeç", erişilebilir adlar). Literal yasağı ilk bileşenden başlar. | `SHP/l10n.yaml`, `MEM/lib/core/extensions/context_extensions.dart` (`l10n` getter), `SHP/lib/core/services/toast_service.dart:13` | 1.12 | `context.l10n.common_cancel` derleniyor. |
| A6 | UI paketleri, font ve varlıklar. Sürümler `SHP/pubspec.lock`'tan: `mihr_ui ^0.1.0-dev.3`, `stacked`, `smooth_sheets`, `toastification`, `phosphor_flutter`, `flutter_gen_runner`. Plus Jakarta Sans TTF 400/500/600/700/800 ve OFL lisansı `assets/fonts/`'a gömülür (Tur 1 varsayım 1.30: indirme yok). Varlık diyeti: `ob1-6.png` (7,7 MB), `smapc.png`, `loginImage.png`, eski logo varyantları ve `assets/ikonlar.zip` silinir (pano 1.25 kararları). Avatarlar ve kil illüstrasyonlarının 3x kopyaları eklenir. | Token ve kit bu paketlere dayanıyor. | `SHP/pubspec.yaml` (fonts bloğu), `TSR/unpacked/SMAP-01/24-1-25-…/text.txt` | 0.3, 1.11 | Font ailesi adı (`PlusJakartaSans`) pubspec ile birebir; `tnum` ve ğ ş ı İ glifleri fonttools ile doğrulanmış. |

### 2.2 İz B: ilk ekrandan önce

| # | Ne | Neden | Taşınacak kaynak | PLAN | Bitti sayılır |
|---|---|---|---|---|---|
| B1 | AppConfig, yalnız Dart tarafı. `apiBaseUrl`, `omrBaseUrl`, `cdnBaseUrl`, `supportEmail` ve YKS tarihi `--dart-define-from-file` ile gelir. Native flavor sonra yapılabilir. | Görsel URL'leri iki TLD'ye dağılmış durumda. YKS sayacı (Anasayfa) ve "Bize Yaz" bu değerleri okuyor. | `SHP/lib/core/config/app_config.dart` (+ `SHP/test/core/config/app_config_test.dart`) | 1.3 (kısmi) | Test geçiyor. |
| B2 | Bootstrap ve native splash. MainInitializer ve runZonedGuarded kurulur. Native splash (lacivert zemin + S-rota) oturum geri yüklenene kadar `preserve` edilir. | Pano 2.1 kare 1: işaret ilk karede görünür, solma yok; uygulama hazır olunca 250 ms geçiş. | `SHP/lib/main_initializer.dart`, `MEM/lib/core/startup/post_frame_startup.dart`, `SLP/lib/main.dart:67-262` | 1.4 | Soğuk açılışta beyaz kare yok. |
| B3 | DI: fazlı get_it ve `session` scope. VM'ler kaydedilmez; constructor'a `locator<>()` ile servis verilir. | Repo'lar bugün widget içinde `new`leniyor. | `MEM/lib/dependency_injection/{injection_container,repository_registrations,session_scope_registration}.dart` | 1.5 | DI smoke testi geçiyor. |
| B4 | Hata modeli: AppException, AppErrorCode → l10n anahtarı, Either. | Tasarımda ayrı durumlar var: çevrimdışı şeridi, ErrorState, bakım, oturum bitti (1.22, 2.7). Sepello 633a0e2 dersi: offline ile sunucu hatası ayrılmalı. | `MEM/lib/core/errors/*`, `MEM/lib/core/extensions/dartz_extension.dart` | 1.6 | `SMAP/lib/core/extensions/dartz_extension.dart:4-5`'teki kontrolsüz cast'ler gitti. |
| B5 | Network çekirdeği: tek NetworkService, cookie oturumu, typed request sınıfları. 401 olunca "Oturumun sona erdi" sheet'i açılır (pano 2.7 kare 2). OMR multipart isteği E8'e kalır. | `validateStatus < 500` ve 302'yi başarı sayan login (`auth_repository_impl.dart:77`). | `MEM/lib/core/network/*`, `MEM/lib/core/extensions/api_extension.dart`, `MEM/lib/config/api/requests/base_request_model.dart` | 1.7 (kısmi) | Auth istekleri yeni yığında. |
| B6 | SessionManager, `UserRole` enum'u ve CurrentUserService. İki UserProvider ve AppStartNotifier kalkar. İyimser açılış: önbellekteki kullanıcıyla kabuğa geçilir. | Bugün çevrimdışı açılış login'e düşüyor (`auth_repository_impl.dart:59-63`). Rol bilgisi `'coach'`/`'teacher'` string'i. | `MEM/lib/services/session_manager.dart`, `SHP/lib/services/session_manager.dart` (sıralama, rollback) | 1.8 | Logout ve hesap silme bütün session scope'u temizliyor. |
| B7 | Router: auto_route ve guard zinciri (Onboarding > Auth > Role; Force sonra eklenir). Göç süresince eski ekranlar "legacy" route'larla sarılır; eski Provider'lar router'ın üstünde kalır. | Kabuk (E5) ve tam ekran akışlar (kamera, sonuç anı) bu yapıya dayanıyor. | `MEM/lib/config/router/app_router.dart`, `SHP/lib/app/router/guards/auth_guard.dart`, `SHP/lib/app/router/stack_router_x.dart` | 1.9 | Uygulama yeni router'la eskisi gibi çalışıyor. |
| B8 | dart_mappable ve `build.yaml`. İlk DTO'lar: UserDto, LoginResponse. Kalanı ekran PR'larında gelir. | Yeni UI `Map` üstüne yazılmaz (PLAN §4 ilkesi). | `SHP/build.yaml`, `SHP/lib/core/mappable/` | 1.10 | Codegen CI'da diff vermiyor. |

**UI için şart olmayanlar:** native flavor'lar, Firebase/Crashlytics (0.12 önerilir ama UI'ı bloklamaz), analytics, push, IAP, remote config. Remote config yalnız E1'deki zorunlu güncelleme ve bakım ekranları için gerekir; o ekranlar flag'le kapalı başlar.

### 2.3 Servis haritası (bugün → hedef)

| Bugün (`SMAP/lib/…`) | Sorun | Hedef | Ne zaman |
|---|---|---|---|
| `core/network/dio_client.dart` (DioClient) | 401 yok, `validateStatus < 500` | `core/network/network_service.dart` + auth interceptor | B5 |
| `http_service/rest_api_http_service.dart`, `repository/omd_repository/omd_repository.dart`, `core/constants/api_constants.dart:14` | Ayrı yığın, placeholder host | `features/scan/data/scan_repository.dart` (multipart, `MEM/lib/config/api/requests/photos_requests.dart` L60-80) | E8 |
| `package:http` (`views/optic_mark_detection_view/omd_result_flow_view.dart:219-260`) | Hiç yazılmayan `connect_sid` anahtarı | NetworkService üstünde `ExamRepository.totalInfoCard` | E9 |
| `features/auth/data/datasources/auth_remote_data_source.dart` + `auth_repository_impl.dart` | Map dönüyor, 302 başarı sayılıyor | `features/auth/data/auth_repository.dart` (Either) | B5, E3 |
| `features/auth/data/datasources/auth_local_data_source.dart` + dağınık prefs anahtarları | `user_data` 8 yerde decode ediliyor | `core/services/device_preferences.dart` (`SHP/lib/core/services/device_preferences.dart`) + SessionStore | B6 |
| `features/shared/presentation/provider/user_provider.dart` (×2) | Çift örnek, bayat veri | `services/session_manager.dart` + `CurrentUserService` (ListenableServiceMixin) | B6 |
| `features/auth/presentation/provider/app_start_provider.dart` | `home: Consumer` | Guard'lar + `SessionManager.restore()` | B7, E1 |
| `features/home/presentation/provider/home_provider.dart` | Uygulama geneli, logout'ta temizlenmiyor | `LessonsService` (ders + eksik sayıları, session) ve `CoachStudentsService` (session, yalnız koç) | E6, E16 |
| `repository/analysis_repository.dart` (12 metot, 9 yerde `new`) | Map, Exception string'i | `ExamRepository` (mock exams, mexam detay, soru), `AnalyticsRepository` (getTotal, lineChart), `LessonContentRepository` (mainSubjects, subSubjects, items, authors, learnedItem) | E10, E11, E12 |
| `repository/weekly_repository.dart` + prefs `bagItemsStr` | Her build'de yeniden kuruluyor, global prefs | `ScheduleRepository` + `ScheduleService` (session; studentId açık parametre) | E6, E7 |
| `repository/cards_repository.dart` | – | `CardRepository` | E13 |
| `repository/coach_repository.dart` | Her isteği print ediyor | `InterviewRepository` + `CoachStudentRepository` | E16, E18 |
| `repository/profile_repository.dart` | `deleteCoach` parametresi gitmiyor | `AccountRepository` | E14 |
| `features/analytics/presentation/provider/analytics_view_provider.dart` | BuildContext alıyor, dispose yok | `AnalyticsViewModel` | E11 |
| 4 nav notifier (root/home/account/my_card) | Enum navigasyon | auto_route | E5 |
| `features/home/presentation/widgets/app_dialog.dart` (`showUnderConstruction`) | Sahte "Kaydınız Alındı" | Menü kalemleri kaldırılır; ComingSoonSheet yalnız kitte (1.21) | E6 |

---

## 3. Hedef klasör yapısı

Ev stili ekran başına klasördür; `views/`, `viewmodels/` ve `widgets/` diye **türe göre ayrılmaz**. Üç referans app'te de view ve VM yan yana durur, `widgets/` view'ın part dosyalarıdır. Part dosyaları view'ın yanında olmak zorunda olduğu için türe göre bölme bu kalıpla çalışmaz.

```
lib/
  main.dart                          # yalnız MainInitializer.run()
  main_initializer.dart              # SHP/lib/main_initializer.dart
  app/
    app.dart                         # MaterialApp.router; SmapTheme.light/dark; ThemeService
    router/  app_router.dart (+.gr.dart), stack_router_x.dart,
             guards/{onboarding_guard,auth_guard,role_guard}.dart
  dependency_injection/              # MEM/lib/dependency_injection/*
  config/api/requests/               # MEM/lib/config/api/requests/* (PLAN §5)
  core/
    config/app_config.dart
    errors/  network/  mappable/
    extensions/  context_extensions.dart (l10n, mediaQuery), dartz_extension.dart, api_extension.dart
    services/  app_haptics.dart, app_logger.dart, connectivity_service.dart,
               device_preferences.dart, theme_service.dart, toast_service.dart
    theme/
      smap_palette.dart              # ColorScale: navy, orange, neutral (pano 1.1)
      smap_colors.dart               # SmapColors + context.appColors (11.12, 1.2, 1.4)
      subject_tone.dart              # SubjectHue + SubjectTone, 9 ders × 2 tema (1.5)
      smap_text.dart                 # SmapText + context.appText (1.6)
      app_radius.dart                # AppRadius, tasarım adlarıyla (1.7)
      app_motion.dart                # AppMotion, SmapDurations, context.motion (1.8, 11.15)
      smap_theme.dart                # MihrThemeConfig + ColorScheme + TextTheme (Tur 1 notu)
    utils/  tr_format.dart (net, puan, sıra, yüzde, tarih), turkish_text.dart
  shared/ui/                         # alan bilgisi taşımayan kit; App* öneki
    buttons/  controls/  inputs/  surfaces/  indicators/  text/  identity/
    feedback/  sheets/  pickers/  navigation/
  features/
    startup/       # açılış yönlendirmesi + genel ekranlar (2.7)
    onboarding/    # tanıtım, rol, sınıf/alan, kamera ön izni, hoş geldin (2.1–2.2)
    auth/          # login/, register/, forgot_password/ (2.3–2.6)
    shell/         # student_shell_view.dart, coach_shell_view.dart (1.19)
    home/          # öğrenci Anasayfa (3.1–3.3)
    schedule/      # Programım (3.4–3.8)
    scan/          # kamera ve OMR (4.x); bugünkü lib/views/optic_mark_detection_view buraya taşınır
    exams/         # result_moment/, exam_detail/, question_detail/, widgets/ (D/Y/B ailesi)
    analytics/     # Analizlerim (6.x), widgets/net_chart.dart
    lessons/       # lessons/, lesson_detail/, topic_detail/, literature/ (7.x), widgets/
    cards/         # kart destesi (8.x)
    account/       # account/, profile/, password/, deletion/, coaching/, notifications/, contracts/ (9.x)
    coach/         # coach_home/, students/, student_profile/, interviews/ (10.x)
    debug/component_gallery_view.dart
  l10n/  app_tr.arb, app_localizations*.dart (commit edilir)
packages/flutter_document_scanner/   # PLAN 0.10 (Memora fork'u)
```

Bir feature'ın içi (örnek `exams`). Veri katmanı PLAN §5'teki gibidir, burada tekrar edilmez.

```
features/exams/
  data/        exam_repository.dart
  domain/      models/ (dart_mappable DTO'lar), exam_repository_contract.dart
  application/ exam_detail_model.dart, net_math.dart     # saf mantık, unit test burada
  presentation/
    widgets/                       # feature içi PUBLIC, ekranlar ve feature'lar arası
      dyb_chip.dart  dyb_counter.dart  dyb_stacked_bar.dart
      question_cell.dart  topic_result_row.dart  exam_card.dart  exam_row.dart
    exam_detail/
      exam_detail_view.dart        # @RoutePage + part'lar
      exam_detail_viewmodel.dart
      widgets/                     # yalnız `part of '../exam_detail_view.dart'`, private sınıflar
      sheets/                      # VM'in açtığı sheet'ler, public
    question_detail/ …
```

---

## 4. Temeller: token katmanı

### 4.1 Kaynak ve karar tablosu (koddan önce)

Sepello'nun devir dokümanında 14 iç çelişki çıkmıştı (`SHP/.cursor/plans/arastirma/uygulama/04-bilesen-plani.md` §3). SMAP kanvasında da var; T0'dan önce bu tablo onaylanır.

| Konu | Pano A | Pano B | Karar |
|---|---|---|---|
| Boş D/Y/B adı | 1.4 `dyb-empty`, Tur 1 notu `dybEmpty` | 11.12 `dyb-blank` | `dybBlank` (11.12) |
| Koyu uyarı | 1.4 #EBC25B / #33280F | 11.12 #F2C46D / #33270F | 11.12 |
| Koyu başarı zemini | 1.4 #133325 | 11.12 #15301F | 11.12 (`successBg`). `dybCorrectBg` 1.4'teki #133325 olarak kalır. |
| `dyb-correct-bg`, glif rengi (beyaz / koyu #0A1424) | 1.4'te var | 11.12'de yok | Eklenir: `dybCorrectBg`, `onDyb` |
| `bg-bar`, `scrim`, `primary-pressed` | 1.2'de var | 11.12'de yok | Eklenir |
| `chartArea`, `chartSeries[4]` | Tur 1 notu | 11.12 (alan "%10, koyu %14" metinle) | `chartLine` + opaklık sabiti. Seri listesi ilk grafik ihtiyacında eklenir. |
| Yarıçap, boşluk ve süre için `SmapTokens` ThemeExtension | Tur 1 notu | Ev stili static const | Static const (`AppRadius`, `MihrSpacing`, `AppMotion`). Temaya göre değişmiyorlar. |
| Widget adları `SmapButton…` | Tur 1 notu | 11.13 adları (Button, Segment…) | K3: `AppButton…` |
| Düğme varyant adları | Tur 1: primary · secondary · quiet · danger · text | 11.13: primary, outline, quiet, text, danger | 11.13 |
| Hata sallanması | Sepello AppField sallanır | 1.8: "alan sarsılmaz"; yalnız kod kutuları sallanır (2.4) | 1.8 |

### 4.2 Renk rolleri: `SmapColors` (`lib/core/theme/smap_colors.dart`)

Alan adı token adının camelCase'idir. Değerler mümkün olduğunda `SmapPalette` adımıdır (1.1); skalada karşılığı olmayanlar hex yazılır.

| Alan | Token | Açık | Koyu | Kullanım |
|---|---|---|---|---|
| bgCanvas | bg-canvas | #F2F4F7 (n-50) | #0A1424 | Sayfa zemini |
| bgSurface | bg-surface | #FFFFFF | #121D31 | Kart, liste grubu, girdi |
| bgRaised | bg-raised | #FFFFFF | #18263D | Sheet |
| bgSunken | bg-sunken | #E8ECF1 | #213049 | Ray, iskelet, sessiz düğme |
| bgNavy | bg-navy | #0F294A | #0F294A | Kök bant; açık temada toast |
| bgNavyRaised | bg-navy-raised | #1A3357 | #1A3357 | Bant içi segment rayı |
| bgContext | bg-context | #F1F5FA | #1A2B45 | Koç bağlam şeridi |
| bgBar | bg-bar | #FFFFFF %92 | #121D31 %92 | Alt çubuk (20 pt blur) |
| scrim | scrim | #091A31 %48 | #02060E %64 | Sheet perdesi (8 pt blur) |
| borderSubtle | border-subtle | #DCE2E9 | #26354D | Ayraç (dekoratif) |
| borderStrong | border-strong | #C3CBD6 | #34445F | Pasif kontrol kenarı |
| borderControl | border-control | #697586 | #6B7D97 | Girdi, çip, onay kutusu |
| textPrimary | text-primary | #1B2232 | #EDF1F6 | Başlık, gövde, değer |
| textSecondary | text-secondary | #556173 | #A9B5C6 | Alt metin, etiket, eksen |
| textPlaceholder | text-placeholder | #697586 | #8B9AAF | Yalnız beyaz girdide "Örn: …" |
| textDisabled | text-disabled | #9AA5B4 | #56657C | Pasif metin |
| textOnNavy / textOnNavy2 | text-on-navy(-2) | #FFFFFF / #C5D4E8 | aynı | Bant başlığı / alt metni |
| textAction | text-action | #1A3357 | #9BB3D3 | Metin düğmesi, bağlantı |
| textAccent | text-accent | #B34400 | #FF9A57 | Turuncu metin (açıkta asla orange-500) |
| primary / onPrimary | primary | #0F294A / #FFFFFF | #C5D4E8 / #091A31 | Birincil düğme, seçili segment ve çip, açık anahtar |
| primaryPressed | primary-pressed | #091A31 | #9BB3D3 | Basılı birincil |
| accent / onAccent | accent | #FF6600 / #0F294A | aynı | Yalnız kamera düğmesi; ikon lacivert |
| accentLine | accent-line | #E05500 | #FF8533 | Gösterge, ilerleme, "bugün", grafikte seçili nokta |
| focusRing | focus-ring | #36537C | #9BB3D3 | 2 pt çizgi + 2 pt boşluk |
| dybCorrect / dybWrong / dybBlank | dyb-* | #0B6E3E / #D8333A / #7E8A9B | #52CC8E / #F07575 / #6E7C92 | Çip dolgusu; sayı metin renginde kalır |
| dybCorrectBg / dybWrongBg / dybBlankBg | | #E4F4EA / #FCEAEA / #E8ECF1 | #133325 / #3B1D22 / #213049 | Soru hücresi zemini |
| onDyb | | #FFFFFF | #0A1424 | Çip glifi (✓ ✕ –) |
| delta | delta | #36537C | #9BB3D3 | "+8,25" ve ok; yeşil yalnız Doğru'ya ait (Tur 10) |
| eksik / eksikBg | eksik | #8A5A00 / #FCF1D9 | #F2C46D / #33270F | EksikTag |
| error / errorBg / onError | error | #C42D35 / #FCEAEA / #FFFFFF | #FF8F8F / #3B1D22 / #3B0A10 | Hata metni, tehlikeli düğme |
| success / successBg | success | #0B6E3E / #E4F4EA | #52CC8E / #15301F | Başarı ikonu |
| warning / warningBg | warning | #8A5A00 / #FCF1D9 | #F2C46D / #33270F | Uyarı kutusu |
| info / infoBg | info | #36537C / #E2EAF4 | #9BB3D3 / #1A2B45 | Bilgi kutusu, ikon dairesi |
| chartLine / chartHighlight / chartGrid | chart-* | #264066 / #E05500 / #DCE2E9 | #9BB3D3 / #FF8533 / #26354D | Net grafiği |
| shadowRaised | shadow-raised | 0 2 8 · #0F294A %8 | #000 %40 | Sürüklenen kart, kamera düğmesi |
| shadowOverlay | shadow-overlay | 0 8 24 · #0F294A %16 | #000 %56 | Toast, balon |
| subjects | (1.5) | 9 × (zemin, vurgu) | 9 × (zemin, vurgu) | `SubjectTone` |

Ders renkleri (`lib/core/theme/subject_tone.dart`, pano 1.5 ve 11.12). Glif eşlemesi alan bilgisi olduğu için `features/lessons/presentation/widgets/subject_glyph.dart`'ta durur.

| SubjectHue | Açık zemin · vurgu | Koyu zemin · vurgu | Phosphor glifi |
|---|---|---|---|
| turkce | #F6ECE6 · #93573C | #2D211C · #E2A98D | TextAa |
| edebiyat | #F6E7EC · #8A2F4E | #301A27 · #E494BE | Feather |
| tarih | #FBF1DA · #8C6106 | #2C2513 · #E3B651 | Bank |
| cografya | #E1EFFA · #1E6FAE | #12293C · #7DB9EC | Globe |
| matematik | #FDE8E8 · #C42A36 | #341B1B · #F7847F | MathOperations |
| geometri | #E7E9FB · #4450BE | #1D2144 · #A3ABF4 | Angle |
| fizik | #DDF2F2 · #08737A | #0E2B2D · #5FCBD0 | Atom |
| kimya | #F7E8F7 · #93359A | #271B33 · #C89AE3 | Flask |
| biyoloji | #E4F3E3 · #2B7A35 | #16291A · #80CC89 | Dna |

### 4.3 Tipografi: `SmapText` (`lib/core/theme/smap_text.dart`)

Plus Jakarta Sans gömülüdür. Bütün stillerde `FontFeature.tabularFigures()` var (K9). Stiller renk taşımaz; renk çağrı yerinde `copyWith(color:)` ile verilir (Sleepia ve Memora kuralı).

| Alan | Token | Boyut/satır · ağırlık · aralık | TextTheme | Kullanım |
|---|---|---|---|---|
| display | display | 32/40 · 800 · −0,5 | displaySmall | Tanıtım, genel ekran, sonuç anı başlığı |
| titleLg | title-lg | 24/32 · 700 · −0,3 | headlineSmall | Kök bant ve sayfa başlığı |
| titleMd | title-md | 20/28 · 700 · −0,2 | titleLarge | Sheet başlığı, boş durum |
| headline | headline | 17/24 · 700 · −0,1 | titleMedium | Bölüm başlığı |
| titleSm | title-sm | 16/24 · 600 | titleSmall | Satır ve kart başlığı (kesilmez, sarar) |
| bodyLg | body-lg | 16/24 (okumada 16/26) · 400 | bodyLarge | Madde tanımı, bilgi kartı |
| body | body | 15/24 · 400 | bodyMedium | Gövde |
| bodyStrong | body-strong | 15/24 · 600 | – | Vurgu, program saati |
| caption | caption | 13/20 · 500 | bodySmall | Meta, yardım, eksen |
| labelLg / labelMd / labelSm | label-* | 16/24 · 14/20 · 12/16, hepsi 600 | labelLarge/Medium/Small | 48 pt düğme / 40 pt düğme, segment, çip / yalnız alt çubuk |
| metricXl / metricLg / metricMd / metricSm | metric-* | 56/64·800·−1,5 · 40/48·800·−1 · 24/32·700·−0,4 · 17/24·700 | – | Sonuç neti / Anasayfa neti, YKS sayacı / istatistik kutusu / D/Y/B sayaçları |

Kurallar:
- Gövde en az 15 pt, ikincil metin en az 13 pt. Tek istisna alt çubuk etiketi (12 pt).
- Büyük harfe çevirme yoktur. Gerekirse `toUpperCase()` değil, tr-duyarlı yardımcı kullanılır (`SHP/lib/core/utils/turkish_text.dart`).

### 4.4 Şekil, boşluk, gölge, blur

- **Yarıçap: `AppRadius` (`lib/core/theme/app_radius.dart`).** Adlar tasarımdan, değerler MihrRadius'tan gelir. Tasarımdaki "radius-md" 12'dir; `MihrRadius.md` ise 8'dir. Bu yüzden ekran kodu `MihrRadius` kullanmaz; yoksa panoda "md" okuyan biri yanlış değeri yazar.

  | Ad | Değer | MihrRadius karşılığı | Kullanım |
  |---|---|---|---|
  | xs | 4 | xs | Onay kutusu |
  | sm | 8 | md | Segment başparmağı, soru hücresi, etiket |
  | md | 12 | xl | Düğme, girdi, toast, glif kutusu |
  | lg | 16 | xxl | Kart, liste grubu, kamera düğmesi |
  | xl | 24 | xxxxl | Sheet üstü, bant altı, bilgi kartı |
  | full | – | full | Çip, avatar, anahtar, ilerleme |

  İç içe yüzeyde iç yarıçap = dış yarıçap − aradaki boşluk (1.7).
- **Boşluk: `MihrSpacing` doğrudan** (Sepello gibi). Tasarımdaki space-4…64 değerleri birebir var: 4 xs, 8 md, 12 lg, 16 xl, 24 x3l, 32 x4l, 48 x6l, 64 x7l. Sayfa kenarı 16, bölümler arası 24–32, dokunma hedefi 48.
- **Gölge:** yalnız `appColors.shadowRaised` ve `shadowOverlay`. Kartlarda kenar da gölge de yoktur; ayrımı kanvas ile yüzey arasındaki ton farkı yapar (1.7, Tur 1 varsayım 1.13).
- **Blur:** yalnız iki yerde.
  - Alt çubuk: 20 pt → `BackdropBlurStyle.custom(sigma: 10, blurPx: 20)`
  - Sheet perdesi: 8 pt → `MihrBackdropBlurs.sm`

  Başka yerde BackdropFilter yoktur. Sepello'nun AppGlass'ı alınmaz.
- **Sabit ölçüler (1.7):**
  - Dokunma hedefi 48×48
  - Satır en az 56 (iki satırlı 72)
  - Kök bant 134, segment ya da sekme varsa 178, küçülünce 110
  - Detay barı 110
  - Alt çubuk 68 + 34 güvenli alan
  - Kamera düğmesi 56×56, 16 pt yukarıda
  - Sheet tutamacı 36×4

### 4.5 Hareket ve haptik: `AppMotion` (`lib/core/theme/app_motion.dart`), `AppHaptics` (`lib/core/services/app_haptics.dart`)

**Süreler ve eğriler**

| Token | Değer | Kullanım |
|---|---|---|
| instant | 100 ms | Basılı durum (0,98 ölçek) |
| fast | 150 ms | Anahtar, çip, onay kutusu; hareketi azaltta opaklık |
| base | 250 ms | Segment, gösterge, akordeon, toast |
| slow | 350 ms | Sheet açılışı, sayfa geçişi |
| loop | 1200 ms | İskelet parıltısı |
| standard | `Cubic(0.2, 0, 0, 1)` | Yerinde değişim |
| enter | `Cubic(0, 0, 0, 1)` | Giren öğe |
| exit | `Cubic(0.3, 0, 1, 1)` | Çıkan öğe; süre girişin %70'i |

**Ürün süreleri (`SmapDurations`):**
- toast 4 sn; Geri Al'lı toast 6 sn
- iskelet zaman aşımı 15 sn (sonra hata durumu)
- "Bağlandın" 2 sn
- kod tekrar gönderme 30 sn
- gönderim 60 sn, okuma 30 sn (2.6)

**Hareketi azalt:** `context.reduceMotion` doğruysa kaymalar 150 ms opaklığa döner ve iskelet düz gri durur. Kalıp `SHP/lib/core/theme/app_motion.dart:52-59`'dan alınır.

**Haptik sözlüğü (1.8):** yalnız dört çağrı var.

| Çağrı | Ne zaman |
|---|---|
| `selection()` | Seçim değişti (segment, sekme, çip, anahtar, şık) |
| `medium()` | Deklanşör |
| `success()` | Sonuç hazır, talep alındı, cevaplar onaylandı |
| `error()` | Gönderim, okuma ya da form hatası |

Köprü `SHP/lib/core/services/app_haptics.dart` + `SHP/ios/Runner/AppDelegate.swift:47`'den kopyalanır; kanal adı `smap/haptics`. Sepello'dan farkı: Android tarafı da yazılır (`MainActivity`'de `HapticFeedbackConstants.CONFIRM/REJECT`, API 30 altında impact'e düşer).

### 4.6 mihr_ui marka katmanı: ne alınır, ne alınmaz

- `MihrThemeConfig(brand: SmapPalette.navy, gray: SmapPalette.neutral, typography: MihrTypography.fromFontFamily('PlusJakartaSans'), buttonTheme: MihrButtonThemeData(shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd), shadows: MihrButtonShadows.flat), extraExtensions: [SmapColors.light, SmapText.standard], materialOverrides: …)` (dev.3'te `materialOverrides` var).
- `materialOverrides` şunları yapar:
  - Tasarımın elle yazılmış ColorScheme'ini kurar (Tur 1 notu; seed yok).
  - `scaffoldBackgroundColor = bgCanvas`. Mihr açık temada scaffold'u beyaza sabitliyor.
  - `textTheme = SmapText.toTextTheme()`
  - `splashFactory = NoSplash.splashFactory`
  - `materialTapTargetSize = padded`
- **Alınanlar:**
  - Mihr düğmeleri, yalnız `AppButton`'ın içinde (boylar tutuyor: md 40/14, xl 48/16)
  - `MihrSpacing`
  - `MihrRadius` değerleri (`AppRadius` üzerinden)
  - `FrostedContainer` / `BackdropBlurStyle` (alt çubuk)
  - Material köprüsü
- **Alınmayanlar:** `context.textColors`, `bgColors`, `fgColors`, `borderColors` ve `context.typography`. Nedeni:
  - mihr `textColors.secondary` = gray700 (#3E4858), tasarımın text-secondary'si ise n-600 (#556173).
  - `brandSolid` = brand600 (#36537C), tasarımın birincil rengi ise navy-900.
  - Koyu temada birincil açık lacivert (#C5D4E8); mihr bunu üretmiyor.

  Sepello'da da mihr'in durum ve marka slotları tutmamıştı (04 §7.3). SMAP'te bütün renkler tek yoldan gelir.

### 4.7 Tek erişim yolu

| Aile | Yol | Yasak |
|---|---|---|
| Renk | `context.appColors.<rol>` | `Color(0x…)`, `Colors.*`, `Theme.of(context).colorScheme` (yalnız `smap_theme.dart`'ta), `context.textColors/bgColors`, `SmapPalette.*` (yalnız `core/theme`) |
| Yazı | `context.appText.<stil>.copyWith(color: …)` | `TextStyle(` (yalnız `core/theme`), `context.typography`, `fontSize:` |
| Boşluk | `MihrSpacing.*` | Sayısal `SizedBox`; tasarımın sabit ölçüleri (48, 56, 134) feature içinde adlı `const` olarak yazılır |
| Yarıçap | `AppRadius.*` | `MihrRadius.*`, `BorderRadius.circular(n)` |
| Süre ve eğri | `context.motion(AppMotion.x)`, `SmapDurations.*` | `Duration(milliseconds:` |
| Metin | `context.l10n.<anahtar>` | String literal (yalnız sembol: `·`, `×`, `%`) |
| İkon | `PhosphorIcons.x(PhosphorIconsStyle.regular)`; seçiliyse `fill` | `Icons.*`, `CupertinoIcons.*` |
| Biçim | `TrFormat.net/puan/sira/yuzde/kisaTarih` (`lib/core/utils/tr_format.dart`) | `toStringAsFixed`, elle "%" |

### 4.8 Kod iskeleti

```dart
// lib/core/theme/smap_palette.dart: pano 1.1. Ekran kodu buraya erişmez.
abstract final class SmapPalette {
  static const navy = ColorScale(
    shade25: Color(0xFFF8FAFD), // tasarımda yok; 50'ye yakın ara ton
    shade50: Color(0xFFF1F5FA), shade100: Color(0xFFE2EAF4), shade200: Color(0xFFC5D4E8),
    shade300: Color(0xFF9BB3D3), shade400: Color(0xFF6C8BB6), shade500: Color(0xFF4A6A97),
    shade600: Color(0xFF36537C), shade700: Color(0xFF264066), shade800: Color(0xFF1A3357),
    shade900: Color(0xFF0F294A), // marka laciverti
    shade950: Color(0xFF091A31),
  );
  static const orange = ColorScale(/* 50 #FFF4EC … 500 #FF6600, 600 #E05500, 700 #B34400 … 950 #3D1800 */);
  static const neutral = ColorScale(/* 25 = n-0 #FFFFFF, 50 #F2F4F7 … 600 #556173 … 900 #1B2232, 950 #0F1420 */);
}
```

```dart
// lib/core/theme/smap_colors.dart: pano 11.12 (son hâl), 1.2, 1.4; karar tablosu §4.1.
@immutable
class SmapColors extends ThemeExtension<SmapColors> {
  const SmapColors({
    required this.bgCanvas, required this.bgSurface, required this.bgRaised, required this.bgSunken,
    required this.bgNavy, /* … §4.2'deki bütün alanlar … */
    required this.subjects, required this.shadowRaised, required this.shadowOverlay,
  });

  final Color bgCanvas, bgSurface, bgRaised, bgSunken, bgNavy /* , … */;
  final Map<SubjectHue, SubjectTone> subjects;
  final List<BoxShadow> shadowRaised, shadowOverlay;

  static final light = SmapColors(
    bgCanvas: SmapPalette.neutral.shade50,                 // #F2F4F7
    bgSurface: const Color(0xFFFFFFFF),                     // n-0
    primary: SmapPalette.navy.shade900,                     // #0F294A
    accentLine: SmapPalette.orange.shade600,                // #E05500
    dybWrongBg: const Color(0xFFFCEAEA),                    // skalada yok (1.4)
    subjects: SubjectTone.light,
    shadowRaised: const [BoxShadow(offset: Offset(0, 2), blurRadius: 8, color: Color(0x140F294A))],
    shadowOverlay: const [BoxShadow(offset: Offset(0, 8), blurRadius: 24, color: Color(0x290F294A))],
    // …
  );
  static final dark = SmapColors(/* … */);

  /// Stok Material widget'ları için (Tur 1 notu "ColorScheme"). Ekran kodu okumaz.
  ColorScheme toColorScheme(Brightness b) => ColorScheme(
        brightness: b,
        primary: primary, onPrimary: onPrimary,
        secondary: accent, onSecondary: onAccent,
        error: error, onError: onError,
        surface: bgCanvas, onSurface: textPrimary, onSurfaceVariant: textSecondary,
        outline: borderControl, outlineVariant: borderSubtle,
        surfaceContainerLowest: bgSurface, surfaceContainerLow: bgRaised,
        surfaceContainerHighest: bgSunken, scrim: scrim,
      );

  @override
  SmapColors copyWith() => this; // tema başına sabit örnek (Sepello gibi)

  @override
  SmapColors lerp(SmapColors? o, double t) => o == null
      ? this
      : SmapColors(
          bgCanvas: Color.lerp(bgCanvas, o.bgCanvas, t)!,
          // … her renk alanı
          subjects: t < .5 ? subjects : o.subjects,
          shadowRaised: BoxShadow.lerpList(shadowRaised, o.shadowRaised, t)!,
          shadowOverlay: BoxShadow.lerpList(shadowOverlay, o.shadowOverlay, t)!,
        );
}

extension SmapColorsContext on BuildContext {
  SmapColors get appColors => Theme.of(this).extension<SmapColors>()!;
}
```

```dart
// lib/core/theme/smap_text.dart: pano 1.6
@immutable
class SmapText extends ThemeExtension<SmapText> {
  const SmapText({required this.display, required this.titleLg, /* … */ required this.metricSm});
  final TextStyle display, titleLg, titleMd, headline, titleSm, bodyLg, body, bodyStrong,
      caption, labelLg, labelMd, labelSm, metricXl, metricLg, metricMd, metricSm;

  static const family = 'PlusJakartaSans';
  static TextStyle _s(double size, double line, FontWeight w, [double ls = 0]) => TextStyle(
        fontFamily: family, fontSize: size, height: line / size, fontWeight: w, letterSpacing: ls,
        leadingDistribution: TextLeadingDistribution.even, // İ noktası ve Ş/Ç çengeli kırpılmasın
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static final standard = SmapText(
    display: _s(32, 40, FontWeight.w800, -0.5),
    titleLg: _s(24, 32, FontWeight.w700, -0.3),
    body: _s(15, 24, FontWeight.w400),
    metricXl: _s(56, 64, FontWeight.w800, -1.5),
    // …
  );

  TextTheme toTextTheme() => TextTheme(
        displaySmall: display, headlineSmall: titleLg, titleLarge: titleMd, titleMedium: headline,
        titleSmall: titleSm, bodyLarge: bodyLg, bodyMedium: body, bodySmall: caption,
        labelLarge: labelLg, labelMedium: labelMd, labelSmall: labelSm,
      );
  // copyWith() => this; lerp: TextStyle.lerp alan alan
}

extension SmapTextContext on BuildContext {
  SmapText get appText => Theme.of(this).extension<SmapText>()!;
}
```

```dart
// lib/core/theme/smap_theme.dart: static final; closure'lı config build() içinde kurulmaz.
abstract final class SmapTheme {
  static final ThemeData light = _build(Brightness.light);
  static final ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final colors = b == Brightness.light ? SmapColors.light : SmapColors.dark;
    final config = MihrThemeConfig(
      brand: SmapPalette.navy,
      gray: SmapPalette.neutral,
      typography: MihrTypography.fromFontFamily(SmapText.family),
      buttonTheme: const MihrButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
        shadows: MihrButtonShadows.flat,
      ),
      extraExtensions: [colors, SmapText.standard],
      materialOverrides: (base) => base.copyWith(
        colorScheme: colors.toColorScheme(b),
        scaffoldBackgroundColor: colors.bgCanvas,
        textTheme: SmapText.standard.toTextTheme()
            .apply(bodyColor: colors.textPrimary, displayColor: colors.textPrimary),
        splashFactory: NoSplash.splashFactory,
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
    );
    return b == Brightness.light ? MihrTheme.light(config: config) : MihrTheme.dark(config: config);
  }
}
// app.dart: MaterialApp.router(theme: SmapTheme.light, darkTheme: SmapTheme.dark,
//   themeMode: _themeService.themeMode /* K5: göçte light */, locale: const Locale('tr'), …)
```

```dart
// Widget içinde kanonik kullanım (her build'in ilk satırları):
final l10n = context.l10n;
final colors = context.appColors;
final text = context.appText;
Text(l10n.home_lastExamNet(TrFormat.net(exam.net)),
    style: text.metricLg.copyWith(color: colors.textPrimary));
```

`lib/core/utils/tr_format.dart` (Tur 1 notu "Biçimlendirme"):
- `NumberFormat('#,##0.##','tr')` → net (68 · 67,5 · 74,75)
- `NumberFormat('#,##0.00','tr')` → puan (412,63)
- `NumberFormat('#,##0','tr')` + "." → sıra ("48.215.")
- `'%${(d*100/t).round()}'` → yüzde (%42)
- `'${t.day} ${DateFormat('MMM','tr').format(t)}.'` → kısa tarih ("5 Eki.")
- `DateFormat('d MMMM y','tr')` → uzun tarih

Net hesabı (D − Y ÷ 4) alan bilgisidir; `features/exams/application/net_math.dart`'ta durur.

---

## 5. Bileşen kiti

**Kaynak sütunu:**
- **mihr**: mihr_ui bileşeni sarılır
- **port**: Sepello dosyası SMAP token'larına çevrilerek taşınır
- **yeni**: sıfırdan yazılır

Bütün genel parçalar `SMAP/lib/shared/ui/…` altındadır. Alan bileşenleri feature'ın `presentation/widgets/` klasöründe public durur.

| # | Tasarım (pano · 11.13 adı) | Widget | Kaynak | Dosya | Varyant ve durumlar | Ekranlar |
|---|---|---|---|---|---|---|
| 1 | 1.9 Button | `AppButton`, `AppButtonVariant{primary,outline,quiet,text,danger}`, `AppButtonSize{md40,lg48}` | mihr (Primary/Secondary/Tertiary/Link/Destructive, `styleBuilder` ile appColors'tan) + port `SHP/lib/shared/ui/buttons/app_button.dart` | `buttons/app_button.dart` | Basılı, odak, pasif + `disabledReason`, yükleniyor (genişlik sabit), leading/trailing ikon, `expand` | 2.x–10.x |
| 2 | 1.18 BarAction | `AppBarAction` | yeni (AppButton md üstüne) | `buttons/app_bar_action.dart` | Çerçeveli ("Düzenle"), dolu ("Kaydet") | 3.4, 9.2, 10.4 |
| 3 | İkon düğmesi | `AppIconButton` | port `SHP/lib/shared/ui/buttons/app_icon_button.dart` | `buttons/app_icon_button.dart` | 48 hedef; `semanticLabel` + tooltip zorunlu | Hepsi |
| 4 | 1.8 basılı ölçek | `PressScale` | port `SHP/lib/shared/ui/buttons/press_scale.dart` | `buttons/press_scale.dart` | `scale` 0,98 (varsayılan), 0,97 (hücre), 0,92 (deklanşör); hareketi azaltta kapalı | Hepsi |
| 5 | 1.10 Segment | `AppSegmented<T>` | port `SHP/lib/shared/ui/controls/app_segmented.dart` | `controls/app_segmented.dart` | Düz; sayaçlı ("28 eksik", sıfırsa "eksik yok"); `onNavy`; etiket sarılır | 2.5, 3.4, 5.4, 7.1, 7.2, 8.1 |
| 6 | 1.10 InScreenTabs | `AppTabBar` | yeni (TabBar) | `controls/app_tab_bar.dart` | Fixed / scrollable, accent-line alt çizgi, `onNavy`, seçili sekmeyi görünür alana kaydırır | 5.3, 6.1, 10.4 |
| 7 | 1.11 Chip | `AppChip` | port `SHP/lib/shared/ui/controls/app_chip.dart` | `controls/app_chip.dart` | filter / choice (hap), square (sınıf 56×48, şık), subject (nokta); seçim lacivert | 2.2, 6.1, 7.2, 10.5 |
| 8 | 1.11 Etiket | `AppTag` | port `SHP/lib/shared/ui/indicators/app_badge.dart` | `controls/app_tag.dart` | Dokunulmaz, nötr; "Web'de", "Koç" | 3.1, 7.1, 1.17 |
| 9 | 1.13 Checkbox, Radio, Switch | `AppCheckbox`, `AppRadio`, `AppSwitch` | port `SHP/lib/shared/ui/controls/app_switch.dart`; diğerleri yeni | `controls/` | Anahtar 52×32 onaylı başlı; radyo sheet içinde | 2.5, 3.5, 9.6 |
| 10 | 1.12 TextField | `AppTextField` | port `SHP/lib/shared/ui/inputs/app_field.dart` (sallanma çıkarılır) | `inputs/app_text_field.dart` | text, password (göster/gizle), readOnly (kilit), canlı kontrol, hata, multiline (TextArea); etiket üstte, "(isteğe bağlı)" | 2.3–2.6, 9.2–9.5, 10.3, 10.6 |
| 11 | 1.12 SearchField | `AppSearchField` | port `app_field.dart` + `SHP/lib/shared/ui/text/highlight_text.dart` + `SHP/lib/core/utils/turkish_text.dart` | `inputs/app_search_field.dart` | tr katlama (I/ı/İ/i), temizle, eşleşme vurgusu | 3.4, 10.2, 10.5 |
| 12 | 1.12 SelectField | `AppSelectField<T>` | yeni (AppTextField + AppSheet) | `inputs/app_select_field.dart` | Sheet açar; pasif ("Alan: Seçilmez") | 2.5, 9.2, 10.3, 10.5 |
| 13 | 1.12 CodeInput | `AppCodeInput` | yeni | `inputs/app_code_input.dart` | 6 kutu, yapıştırma; hatada sallanır + error haptiği | 2.4 |
| 14 | 1.13 SettingsRow, ListGroup | `AppRow`, `AppRowGroup` | port `SHP/lib/shared/ui/surfaces/app_rows.dart` (+ `SLP/lib/shared/widgets/settings_rows.dart`) | `surfaces/app_rows.dart` | Ok, değer, anahtar, dış bağlantı, etiket; tehlikeli satır ayrı grupta; en az 56/72 | 9.1, 9.6, 9.7 |
| 15 | 1.13 Accordion | `AppAccordion` | yeni | `surfaces/app_accordion.dart` | Açık ve kapalıda ayrı ok, 250 ms; açılan bölüm görünür alana kayar | 5.4, 7.3 |
| 16 | Kart yüzeyi | `AppCard` | port `SHP/lib/shared/ui/surfaces/app_card.dart` (kenar, gölge ve squircle çıkarılır) | `surfaces/app_card.dart` | bgSurface, radius lg, `onTap` | Çoğu |
| 17 | 1.4 Info/Warning/ErrorBox | `AppNotice` | port `SHP/lib/shared/ui/feedback/app_banner.dart` | `feedback/app_notice.dart` | info, success, warning, error; Phosphor Info / CheckCircle / Warning / WarningCircle; sol şerit yok; metin birincil renkte | 2.2, 2.3, 9.5, 9.6 |
| 18 | 1.15 İlerleme | `AppProgressBar`, `AppSuccessRing`, `AppSpinner` | port `SHP/lib/shared/ui/indicators/app_progress_bar.dart`, `SHP/lib/shared/ui/feedback/app_spinner.dart`; halka yeni | `indicators/`, `feedback/` | Veri yoksa çizilmez; halkada noData "Soru yok"; tek renk; doğru yuvarlama | 5.5, 7.x, 8.1 |
| 19 | 1.16 StatBox | `AppStatBox` | yeni | `indicators/app_stat_box.dart` | Değer (metricMd), etiket, delta satırı; delta yoksa çizilmez | 6.1, 10.4 |
| 20 | Değişim değeri | `DeltaText` | yeni | `text/delta_text.dart` | "+8,25" + ok, delta tonu; işaret ve ok yönü | 2.1, 3.1, 5.1, 6.1, 10.4 |
| 21 | Bölüm başlığı | `SectionHeader` | port `SHP/lib/shared/ui/text/section_header.dart` | `text/section_header.dart` | headline + isteğe bağlı alt satır ve eylem (her bölümde "Tümü ›" yok) | 3.1, 10.1 |
| 22 | 1.17 Avatar | `AppAvatar`, `AppAvatarStack`, `AvatarPicker` | port `SHP/lib/shared/ui/identity/app_avatar.dart`; seçici yeni | `identity/` | 24/32/40/56/96; baş harf yedeği; "Koç" kelime rozeti; yığında en çok 3 + "+N"; seçicide 7 avatar | 2.5, 3.1, 9.1, 9.2, 10.x |
| 23 | 1.26 Lockup | `SmapLockup` | yeni (SVG varlığı) | `identity/smap_lockup.dart` | İşaret / işaret + wordmark; açık ve lacivert zemin | 2.1, 2.3 |
| 24 | 1.20 BottomSheet | `AppSheet.show`, `AppSheetFrame`, `AppSheetRoute` | port `SHP/lib/shared/ui/sheets/{app_sheet,app_sheet_route}.dart` (smooth_sheets) | `sheets/` | small, medium, full; başlık + Kapat; alt düğme bandı; busy kilidi; %25 iniş ya da hızlı fırlatma kapatır; 350/250 ms; perde %48 / %64 + 8 blur | Her tur |
| 25 | 1.21 ConfirmSheet | `AppConfirmSheet` | port `SHP/lib/shared/ui/sheets/app_confirm_sheet.dart` (+ `SLP/lib/shared/sheets/sleepia_confirm_sheet.dart`) | `sheets/app_confirm_sheet.dart` | Normal (lacivert), tehlikeli (kırmızı); odak Vazgeç'te; soru başlığı cümle düzeninde | 3.6, 9.1, 9.4, 9.5, 10.6 |
| 26 | 1.21 Yakında | `ComingSoonSheet` | yeni | `sheets/coming_soon_sheet.dart` | Tek "Tamam"; "Haber ver" yok; yalnız kitte, menülerde kullanılmaz | – |
| 27 | 1.22 Toast | `ToastService` + `AppToast` | port `SHP/lib/core/services/toast_service.dart`, `SHP/lib/shared/ui/feedback/app_toast.dart` | `core/services/`, `feedback/app_toast.dart` | info, success, error; 4 sn, Geri Al ile 6 sn; alt çubuğun 8 pt üstünde; koyu temada ters yüzey; ekran okuyucuda kendiliğinden kapanmaz | 3.6, 8.1, 9.3, 10.6 |
| 28 | 1.22 Skeleton | `AppSkeleton`, `SkeletonBox` | port `SHP/lib/shared/ui/feedback/app_skeleton.dart` | `feedback/app_skeleton.dart` | 1200 ms parıltı; hareketi azaltta düz gri; 15 sn zaman aşımını VM uygular | Her ekran |
| 29 | 1.22 Empty / ErrorState | `AppStateBlock` (`.screen`, `.section`) | port `SHP/lib/shared/ui/feedback/app_state_block.dart` | `feedback/app_state_block.dart` | Ekran düzeyinde kil görsel (en çok bir), bölüm düzeyinde görselsiz; liveRegion | Her ekran |
| 30 | 2.7, 9.4 durum ekranı | `AppStatusView` | yeni | `feedback/app_status_view.dart` | 96 pt ikon dairesi, display başlık, tek cümle, en çok iki düğme; `canPop: false` varyantı | 2.7, 4.10, 9.4 |
| 31 | 1.22 OfflineStrip | `OfflineStrip` + `ConnectivityService` | port `SHP/lib/features/main/main_view.dart:159-213`, `SHP/lib/core/services/connectivity_service.dart` | `feedback/offline_strip.dart` | 250 ms iner; bağlanınca 2 sn "Bağlandın" | Kabuk |
| 32 | 1.18 RootBand, HomeBand | `AppRootBand` | yeni (pinned SliverPersistentHeader); referans `SHP/lib/shared/ui/navigation/app_top_bar.dart`, `status_bar_glass.dart` | `navigation/app_root_band.dart` | Başlık + en çok bir eylem; `bottom:` (segment ya da sekme, 178); `header:` (Anasayfa selamı); kaydırınca 134→110, başlık 24→17 | 3.1, 6.1, 7.1, 9.1, 10.x |
| 33 | 1.18 DetailBar | `AppDetailBar` + `LargeTitleSliver` | yeni (`SHP` ScrollReveal kalıbı) | `navigation/app_detail_bar.dart` | Geri + en çok bir eylem; başlık içerikte büyük, kaydırınca bara 15/20 iki satıra kadar iner; alt ayraç belirir | 2.x–10.x |
| 34 | 1.18 ContextStrip | `AppContextStrip` | yeni | `navigation/app_context_strip.dart` | 40 pt, avatar 24, "Ad Soyad'ın verileri"; barla birlikte sabit | 10.4 ve koçun öğrenci ekranları |
| 35 | 1.19 BottomBar | `AppBottomNav`, `AppNavTab`, `AppCameraButton` | port `SHP/lib/shared/ui/navigation/app_bottom_nav.dart` + `SHP/lib/shared/ui/buttons/app_fab.dart`; davranış spec'i `SMAP/lib/features/root/presentation/widgets/custom_bottom_nav_bar.dart` | `navigation/` | student / coach; tek gösterge (accent-line 32×4); Fill/Regular; "Okut" etiketi; FittedBox + uzun basış balonu; "Analizlerim, sekme, 5'te 2" | Kabuk |
| 36 | Tur 6–8 tarih seçiciler | `AppCalendar`, `AppDayChip`, `AppTimeWheel` | yeni (referans `SHP/lib/shared/ui/sheets/app_date_sheet.dart`); `SMAP/lib/features/home/presentation/widgets/home_month_calendar.dart` ile `day_selection_calendar.dart` birleşir | `pickers/` | Geçmiş gün seçilemez; "bugün" accent-line | 3.4–3.8, 9.6 |
| 37 | 1.14 D/Y/B | `DybChip`, `DybCounter(.large/.small)`, `DybStackedBar` | yeni | `features/exams/presentation/widgets/` | ✓ ✕ – + harf ya da kelime etiketi; sabit sıra; sayı metin renginde; çubukta 2 pt ayrım; tek Semantics okunuşu | 2.1, 3.1, 5.1, 5.3, 6.2, 10.4 |
| 38 | 1.14 QuestionCell | `QuestionCell` | yeni | `features/exams/presentation/widgets/question_cell.dart` | 76 pt, 5 sütun; numara, durum çipi, işaretin; yanlış ve boşta "Doğru A"; zemin doğru / yanlış / boş | 5.4, 4.7 |
| 39 | 1.15 TopicResultRow | `TopicResultRow` | yeni | `features/exams/presentation/widgets/` | Tek renk halka; "Az soru" etiketi | 5.5, 5.10 |
| 40 | 1.16 ExamRow, ExamCard | `ExamRow`, `ExamCard` | yeni | `features/exams/presentation/widgets/` | Kapak, ad, tür, tarih, yayınevi, küçük D/Y/B, net; veri yoksa alan çizilmez | 3.1, 6.2, 10.4, 2.1 |
| 41 | 1.4 NetChart | `NetChart` | yeni (fl_chart); eksen adımı kuralları `SMAP/lib/features/analytics/presentation/widgets/net_chart_card.dart` + `analytics_view_provider.dart:303-353` | `features/analytics/presentation/widgets/net_chart.dart` | TYT 0–120, AYT 0–160; son nokta vurgulu + balon; noktalar dokunulabilir | 2.1, 6.1, 10.4 |
| 42 | 1.16 SubjectRow, SubjectTile | `SubjectTile`, `SubjectRow`, `SubjectGlyph` | yeni | `features/lessons/presentation/widgets/` | Glif karosu (ders rengi), EksikTag ya da "Web'de"; kart ilerlemesi yalnız veri varsa | 3.1, 7.1 |
| 43 | 1.16 TopicRow | `TopicRow` | yeni | `features/lessons/presentation/widgets/` | Kesintisiz numara, iki satır ad, EksikTag | 7.2 |
| 44 | Tur 5 EksikTag | `EksikTag` | yeni | `features/lessons/presentation/widgets/eksik_tag.dart` | Bayrak + "N eksik", eksik tonları | 3.1, 3.5, 7.x |
| 45 | Tur 5 CardDeck, CardSheet | `CardDeck`, `InfoCardFace` | yeni (flutter_card_swiper) | `features/cards/presentation/widgets/` | Kaydırma yalnız sonraki karta; "Öğrendim" düğmeyle; Geri Al; eşik %30 ya da 800 px/sn | 8.1, 7.3, 5.6, 2.1 |
| 46 | ProgramItemRow, WeekGrid, HourSlot | `ProgramItemRow`, `WeekGrid`, `HourSlot` | yeni | `features/schedule/presentation/widgets/` | Görünüm / düzenleme modu | 3.1, 3.4–3.8 |
| 47 | Tur 9 koç | `StudentTile`, `StudentRow`, `AttentionRow`, `MeetingRow`, `CodeCard`, `CoachCard` | yeni | `features/coach/presentation/widgets/` (CoachCard `features/account/…`) | – | 9.5, 10.1–10.6 |
| 48 | Kamera | CameraOverlay, Handles, ProgressSheet, FormCheck | yeni (vendor overlay'leri) | `features/scan/presentation/…` (part) | Kamera her temada koyu (Tur 2 varsayım 2.1) | 4.x |
| 49 | Galeri | `ComponentGalleryView` | port `SHP/lib/features/debug/component_gallery_view.dart` | `features/debug/` | `--dart-define=GALLERY=true`; açık + koyu; metin ölçeği 1,3 anahtarı | – |

**Yapım sırası**

| Aşama | İçerik |
|---|---|
| T1 · Kit-1 (kontroller) | 1–22 ve 49 (galeri). Galeri aynı PR'da gelir: Sepello dersi, iki temanın panoyla tek kıyas yolu. |
| T2 · Kit-2 (katmanlar ve durumlar) | 24–31 |
| T3 · Kabuk parçaları | 32–35 (yalnız widget; yönlendirme E5'te) |
| T4 · SMAP alan bileşenleri | 37–42, 44, 45'in `InfoCardFace`'i ve 46'nın ProgramItemRow'u. Gerekçe: tanıtım ekranları (2.1 kare 2–4) "yeni arayüz parçalarından" kuruluyor, Anasayfa da aynı parçaları kullanıyor. |
| İlk kullanan ekranla | 13 AppCodeInput (E3b), 36 seçiciler (E7), 45 CardDeck (E13), 47 koç bileşenleri (E15–E18), 48 kamera parçaları (E8), 43 TopicRow (E12) |

Ekran PR'ında eksik çıkan **genel** parça aynı PR'da `shared/ui`'a ve galeriye eklenir. **Alan bilgisi taşıyan** parça feature'da kalır (Sepello kuralı, `SHP/.cursor/plans/arastirma/uygulama/04-bilesen-plani.md` §4).

---

## 6. Widget bölme kuralları

1. **Bir ekran bir kütüphanedir.**
   - `xxx_view.dart` içerir: `@RoutePage() class XxxView extends StackedView<XxxViewModel>`, bütün importlar, `part 'widgets/…';` satırları, en çok bir State'li `_XxxPage` ve view'a özel top-level yardımcılar.
   - VM yanındaki `xxx_viewmodel.dart`'tadır.
   - Örnekler: `SHP/lib/features/home/presentation/home_view.dart:56-61`, `SLP/lib/features/home_tab/presentation/home_tab_page.dart`, `MEM/lib/features/credits/presentation/credits_page.dart:17-24`.
2. **Part dosyası kuralı.**
   - `widgets/<önek>_<bölüm>.dart`, `part of '../xxx_view.dart';` ile bağlanır.
   - İçinde import yok, yalnız private (`_X`) sınıflar.
   - Önek ekrana göredir: `home_`, `exam_detail_`, `lessons_`.
   - Panodaki her bölüm bir part dosyasıdır.
3. **Boyut sınırları** (Sepello'da medyan 160, p90 473; Sleepia planında sayfa kabuğu tavanı 200):
   - view kabuğu ≤ 250 satır
   - part dosyası ≤ 300 satır
   - VM ≤ 500 satır; fazlası `application/` altında saf sınıfa
   - presentation'da hiçbir dosya > 400 satır olmaz
   - Aşan dosya daha çok part'a bölünür; tek uzun dosya kabul edilmez. SMAP'teki 1.000+ satırlık dosyalar bu kurala göre parçalanarak taşınır.
4. **Ne zaman ayırmalı.**
   - Panodaki her bölüm, durum (iskelet, boş, hata) ve satır tipi kendi sınıfıdır.
   - Build ~60 satırı ya da 3 iç içe Row/Column'u geçiyorsa ayrılır.
   - Aynı ekranda iki kez tekrarlanan parça → private sınıf.
   - Aynı feature'ın iki ekranında → `features/<f>/presentation/widgets/` (public, öneksiz).
   - İki feature'da ve alan bilgisi yoksa → `shared/ui/` (`App*`).
   - İki feature'da ve alan bilgisi varsa → sahibi feature'ın `widgets/` klasöründe public; diğerleri import eder (Sepello: home, `budget_hero_parts.dart`'ı import ediyor).
5. **Yalnız sınıf widget'ı.** `Widget _buildX()` yazılmaz (Sepello'da ~360 sınıfa karşı 11 metot). Küçük tekrar için build içinde yerel closure serbesttir (`SHP/lib/features/lists/presentation/list_detail/sheets/group_sheet.dart:80-89`).
6. **Adlandırma.**

   | Tür | Ad |
   |---|---|
   | Ekran | `XxxView` / `XxxViewModel` (route: `XxxRoute`) |
   | Sheet | `XxxSheet` (+ `static show`) |
   | Bölüm | `_XxxSection` |
   | Sliver döndüren bölüm | `_XxxSliver` |
   | Parçalar | `_XxxCard`, `_XxxRow`, `_XxxTile`, `_XxxHeader` |
   | Durumlar | `_XxxSkeleton`, `_XxxEmpty`, `_XxxError` |
   | Header delegate | `_XxxHeaderDelegate` |
   | Kit | `App*` |
   | Alan bileşeni | Öneksiz isim (`DybCounter`) |
   | Dosya | snake_case, ekran öneki (`home_today.dart`) |

7. **Private ve public.** Ekrana özel her şey `_Private`. Dışarıdan açılan (VM'in ya da başka ekranın açtığı) sheet, `<ekran>/sheets/` altında public dosyadır. Feature içi ortak parçalar `presentation/widgets/` altında public durur.
8. **const.** Bölüm sınıfları parametresiz ve `const`'tur. Sliver listesi `const [...]` ile kurulur. `DecoratedBox`, `Container`'a tercih edilir. Lint'ler §2 A4'te.
9. **Stateless varsayılan.** StatefulWidget yalnız UI'ın sahip olduğu controller için kullanılır: ScrollController, TabController, TextEditingController, FocusNode, AnimationController. Bunlar tek bir `_XxxPage`'de durur. VM controller tutmaz (Memora 01 §3.3).
10. **Rebuild kapsamı.**
    - Kök `reactive => false`.
    - Her veri bölümü `SelectorViewModelWidget<VM, (record)>`. İlk satırda kayıt açılır: `final (state, items) = data;`. Karmaşık kayıt için private `typedef`.
    - Seçiciye ham, değişken liste verilmez. VM, `==`'si olan değişmez türetilmiş model (dart_mappable ya da önbelleklenen `XxxSummary`) sunar ve önbelleği `notifyListeners()` override'ında temizler (`SHP/lib/features/home/presentation/home_viewmodel.dart:93-136`).
    - Öğe seçimi öğe başına seçiciyle yapılır (`MEM/lib/features/credits/presentation/widgets/pack_card.dart:9-11`).
    - Sık değişen değer (yükleme yüzdesi, kaydırma) VM'de `ValueNotifier` + `ValueListenableBuilder` ile tutulur.
    - Eylem: `getParentViewModel<VM>(context, listen: false).x()`.
11. **Durum.**
    - Her bölümün kendi `SectionState`'i var (loading / ready / empty / error / offline). Tasarım bölüm düzeyi durum istiyor (3.2, 5.8, 6.3, 7.5).
    - Ekran düzeyi switch: `AppSkeleton` (gerçek düzeni taklit eder) → `AppStateBlock.screen` → içerik.
    - İstekler `SmapDurations.skeletonTimeout` (15 sn) ile sınırlıdır; sonsuz iskelet yoktur.
    - Veri yoksa alan çizilmez. Sahte değer (+18.2%, %75, OBP 85) asla yazılmaz.
12. **Kaydırma.** Ekran başına tek `CustomScrollView`. Bant ve bar pinned sliver; grup başlığı `SliverMainAxisGroup` + pinned header. `NestedScrollView` ve `sliver_tools` kullanılmaz (Sepello planı, "Kaydırma").
13. **Güvenli alan.** Sekme ekranları alt çubuğun arkasına uzanır (`extendBody`); alt boşluk `MediaQuery.paddingOf(context).bottom` + çubuk yüksekliğiyle elle verilir (`SHP/lib/features/home/presentation/home_view.dart:116-133`).
14. **Sabit değer yasağı (§4.7).** Feature'da renk, TextStyle, sayısal boşluk, yarıçap, süre, ikon ailesi dışı ikon ya da string literal yazılmaz. Tasarımın sabit ölçüleri (56, 76, 134) feature içinde adlı `const` olarak durur ve yorumda pano kodu yazılır.
15. **Sheet ve dialog.**
    - `showDialog`, `AlertDialog` ve `showModalBottomSheet` yok; hepsi `AppSheet.show` (pano 1.20, Tur 1 #28).
    - Sheet aptal veri toplayıcıdır: `Navigator.pop(context, sonuç)` ile kayıt, enum ya da taslak döndürür. Yazma, toast ve geri alma çağıran VM'dedir (`SHP/lib/features/lists/presentation/list_detail/sheets/group_sheet.dart`).
    - Gerçek mantığı olan sheet kendi VM'ini alır: `ViewModelBuilder.reactive`, `SHP/lib/features/lists/presentation/item_form/item_form_sheet.dart:78-92`.
16. **VM bağlamsızdır.**
    - Navigasyon enjekte edilen `AppRouter` ile.
    - Toast `ToastText` lambda'sıyla: `_toast.success((l) => l.schedule_saved)`.
    - Sheet `XxxSheet.show()` ile.
    - Haptik sonuç anında VM'den ya da widget'tan.
    - Sleepia'daki "VM'e context geçirme" sapması tekrarlanmaz.
17. **l10n anahtarları.**
    - Biçim `<feature>_<camelCase>` (`home_todayTitle`, `examDetail_netRule`).
    - Ortak olanlar `common_*`: `common_cancel` = "Vazgeç", `common_ok` = "Tamam", `common_close` = "Kapat", `common_undo` = "Geri Al".
    - Yalnız ekran okuyucu için olanlar `…A11y` ile biter.
    - Sayılar placeholder'a `TrFormat` ile biçimlenmiş String olarak geçer.
18. **Metin kuralları (Tur 1 varsayımları 1.18–1.22):**
    - "İptal" kullanılmaz.
    - Soru biçimindeki onay başlığı cümle düzeninde; ekran ve sheet başlığı Türkçe başlık düzeninde.
    - "sen" dili; emoji, büyük harfli düğme ve iç kod yok.
    - Zorunlu alan yıldızı yok; isteğe bağlı alan "(isteğe bağlı)" ile biter.
19. **Erişilebilirlik.**
    - 48 dp hedef.
    - İkon düğmesinde `semanticLabel` + tooltip zorunlu.
    - D/Y/B tek okunuş: `Semantics(label: '86 doğru, 74 yanlış, 0 boş', excludeSemantics: true)`.
    - Soru hücresi: "Soru 7, yanlış, işaretin C, doğru cevap A".
    - Başlıklar `Semantics(header: true)`; durum değişimi `liveRegion`.
    - Metin ölçeği 1,3'te düzen kırılmaz; sabit yükseklik yok.
20. **İzlenebilirlik.** Her widget sınıfının `///` yorumu pano ve kareyi anar ve Türkçe arayüz metnini alıntılar: `/// Anasayfa "Son denemen" (pano 3.1 · kare 1; 11.13 ExamCard).`

### 6.1 Örnek ayrıştırma: Anasayfa (öğrenci, pano 3.1–3.3)

```
lib/features/home/
  application/
    home_summary.dart          # HomeSummary.of(schedule, exams, lessons): bugünün satırları,
                               # son deneme + aynı türün öncekine göre delta (6.2), en çok kaçırılan
                               # konu (3.6 kuralı), ders sırası (eksik azalan; Web'de sonda, 6.5); ==/hashCode
    yks_countdown.dart         # cihazda hesap; tarih AppConfig'ten (6.4)
  presentation/
    home_view.dart             # HomeView (StackedView, reactive=false) · part'lar ·
                               # _HomeScroll (State: ScrollController) · _HomeContent (ekran durumu switch) ·
                               # top-level _openTopic/_openExam/_openLesson
    home_viewmodel.dart        # ReactiveViewModel; listenableServices [schedule, exams, lessons, currentUser];
                               # bölüm başına SectionState; '// ── Bölüm ──' afişleri
    widgets/home_band.dart     # _HomeBand: AppRootBand(header: _Greeting + _YksCountdown)
                               #   selector: (String firstName, int daysLeft)
    widgets/home_today.dart    # _TodaySection: SectionHeader("Bugün", eylem "Programım") +
                               #   ProgramItemRow × N | _TodayEmpty | _TodayError
                               #   selector: (SectionState, List<TodayItem>)
    widgets/home_last_exam.dart# _LastExamSection: ExamCard(özet) + DybCounter.small + DeltaText +
                               #   _MostMissedTopic + AppButton.text("Analizi Gör")
                               #   selector: (SectionState, LastExamSummary?)
    widgets/home_subjects.dart # _SubjectsSection: SectionHeader("Derslerin", "Eksiği en çok olandan başlar")
                               #   + SubjectTile × 9 (EksikTag | AppTag "Web'de")
                               #   selector: (SectionState, List<SubjectSummary>)
    widgets/home_states.dart   # _HomeSkeleton (aynı düzende SkeletonBox'lar), ekran düzeyi _HomeError
```

### 6.2 Örnek ayrıştırma: Deneme Detay (pano 5.3–5.10)

```
lib/features/exams/
  application/exam_detail_model.dart  # testler, D/Y/B toplamları, net = D − Y ÷ 4, puan türüne göre net,
                                      # soru süzgeci (Tümü/Yanlışlar/Boşlar), konu sıralaması (3.5)
  presentation/
    widgets/  dyb_counter.dart, dyb_stacked_bar.dart, question_cell.dart, topic_result_row.dart  (public)
    exam_detail/
      exam_detail_view.dart        # ExamDetailView(examId, {StudentRef? student}) ·
                                   # _ExamDetailPage (State: ScrollController + TabController) ·
                                   # CustomScrollView[ AppDetailBar(compactTitle), _Header,
                                   #   PinnedHeaderSliver(AppTabBar: Genel·Sorular·Konular·Kartlar),
                                   #   seçili sekmenin SliverMainAxisGroup'u ]
      exam_detail_viewmodel.dart   # sekmeler tembel yüklenir; her sekmenin SectionState'i;
                                   # studentId repository'ye açık parametre
      widgets/exam_detail_header.dart     # _Header: kapak, yayınevi, ad, tür·tarih, metricXl net,
                                          #   DybCounter.large, _ScoreBlock (yalnız alan puanı varsa, 2.11)
      widgets/exam_detail_general.dart    # _GeneralTab: _TestBar × N (DybStackedBar, tam ad) +
                                          #   _NetRuleNote + _NetsByScoreType
      widgets/exam_detail_questions.dart  # _QuestionsTab: AppSegmented<QuestionFilter>(sayaçlı) +
                                          #   AppAccordion × test → _QuestionGrid (QuestionCell, 5 sütun) |
                                          #   _NoBlankState (bölüm düzeyi boş)
      widgets/exam_detail_topics.dart     # _TopicsTab: _MostMissedCard + TopicResultRow listesi
      widgets/exam_detail_cards.dart      # _CardsTab: InfoCardFace önizlemeleri → Kart Destesi
      widgets/exam_detail_states.dart     # _DetailSkeleton, _DetailError, sekme düzeyi boş durumlar
    question_detail/
      question_detail_view.dart (+ _viewmodel, widgets/question_detail_*.dart)   # pano 5.7
```

---

## 7. Ekran uygulama sırası (PR boyutunda adımlar)

**Etiketler:**
- **[HAZIR]** mevcut uçlarla yapılabilir
- **[KISMİ]** bir kısmı backend cevabı bekler; o kısım flag'le kapalı
- **[BLOKE]** backend olmadan başlanamaz

Soru kodları PLAN §7'den (S1–S12, P1–P8). Yeni sorular "S+" ile işaretli ve PLAN §7'ye eklenmeli. Her adımın ortak "bitti" tanımı §8'deki listedir; aşağıda yalnız adıma özel ölçütler var.

### Temeller

**T0 · Token'lar ve tema** [HAZIR] · branch `temel/t0-tokenlar`
- **Pano:** 1.1–1.8, 11.12, 11.15, 11.1 (geliştirici notları); karar tablosu §4.1.
- **İş:**
  - `smap_palette.dart`, `smap_colors.dart`, `subject_tone.dart`, `smap_text.dart`, `app_radius.dart`, `app_motion.dart`, `smap_theme.dart`
  - `AppHaptics` (iOS `AppDelegate.swift` + Android `MainActivity.kt`)
  - `ThemeService` + `DevicePreferences` (`SHP/lib/core/services/theme_service.dart`, `device_preferences.dart`); varsayılan light (K5)
  - `app.dart` bağlantısı
  - `tr_format.dart`
- **Test:**
  - `test/core/theme/contrast_test.dart`: pano 1.3 matrisindeki her metin/zemin çifti ≥ 4,5:1, kontrol ve ikon çifti ≥ 3:1. Saf fonksiyon olduğu için ev kuralına uyar.
  - `tr_format_test.dart`: 68 · 67,5 · 412,63 · 48.215. · %42 · 5 Eki.
- **Bitti:**
  - Galeride "Token'lar" sayfası iki temada 1.2 ile yan yana kıyaslanmış.
  - Eski ekranlar global tema değişiminden sonra elle gezilmiş (login ve OMR öncelikli).

**T1 · Kit-1: kontroller ve galeri** [HAZIR]
- **Pano:** 1.9–1.17.
- **Bileşenler:** §5 #1–22 ve #49.
- **Bitti:** Galeride her bileşen her durumda (basılı, odak, pasif, yükleniyor, hata) iki temada ve metin ölçeği 1,3'te; hareketi azalt açık ve kapalı.

**T2 · Kit-2: katmanlar ve durum kalıpları** [HAZIR]
- **Pano:** 1.20–1.22.
- **Bileşenler:** #24–31.
- **Bitti:**
  - Sheet sürükleme: %25 iniş ya da fırlatmada kapanır, busy'de kilitli.
  - Toast süreleri 4 ve 6 sn; ekran okuyucuda kendiliğinden kapanmıyor.
  - İskelet zaman aşımı örneği galeride.

**T3 · Kabuk parçaları** [HAZIR]
- **Pano:** 1.18, 1.19, 1.23, 1.24.
- **Bileşenler:** #32–35.
- **Bitti:**
  - Bant 134→110 kaydırmayı izliyor; segmentli bant 178.
  - Detay barında başlık bara iniyor, uzun ad kesilmiyor.
  - Alt çubukta "Görüşmelerim" 1,3 ölçekte FittedBox ile sığıyor.

**T4 · SMAP alan bileşenleri** [HAZIR]
- **Pano:** 1.14–1.16, 1.4 (grafik), Tur 3–5 eklemeleri.
- **Bileşenler:** #37–42, #44, `InfoCardFace`, `ProgramItemRow`; galeride sabit örnek veriyle (Ek C değerleri).
- **Bitti:** D/Y/B gri tonlamada ve renk körlüğü simülasyonunda ayrışıyor (glif + etiket); Semantics okunuşları doğru.

### Açılıştan ileri

**E1 · Açılış ve genel ekranlar** [KISMİ]
- **Pano:** 2.1 kare 1, 2.7 (4 kare), 0.1.
- **Bileşenler:** SmapLockup, AppSpinner, AppStatusView, AppSheet.
- **VM ve servis:**
  - `features/startup/`: guard'lar ile `SessionManager.restore()`
  - `ForceUpdateView`, `MaintenanceView`, `UnknownRoleView`
  - `SessionExpiredSheet` (NetworkService'in 401 kancası; perde ve sürükleme kapatmaz; girişten sonra aynı ekrana dönüş)
- **Uç:** `GET /ajax/checkUser`.
- **Bitti:**
  - Native splash → 1 sn'den uzun sürerse spinner → 250 ms geçiş.
  - Çevrimdışı soğuk açılış önbellekteki kullanıcıyla kabuğa gidiyor.
  - `main.dart`'taki `home: Consumer` ve `app_start_provider.dart` silindi.
- **Backend:**
  - Zorunlu güncelleme ve bakım için `/public-config` (S10); o zamana kadar ekranlar var, tetikleyici kapalı.
  - 401 ile 302 semantiği (S1).

**E2 · Tanıtım, rol, sınıf ve alan, kamera ön izni, hoş geldin** [HAZIR]
- **Pano:** 2.1 kare 2–4, 2.2 (5 kare).
- **Bileşenler:**
  - AppButton, AppChip (square, pill), AppNotice, sayfa noktaları (24×8 accent-line / 8×8 borderStrong)
  - T4 parçaları: ExamCard, DybCounter, NetChart, EksikTag, InfoCardFace (örnek verisi `onboarding/application/onboarding_samples.dart`, metinler ARB'de)
- **VM:**
  - `OnboardingViewModel`: adım enum'u; koç akışı Rol → Kamera → Hoş geldin. Referans `SLP/lib/features/onboarding/presentation/onboarding_viewmodel.dart`.
  - Seçimler kayda kadar `DevicePreferences`'ta taslak olarak durur (7.1).
  - Kamera izni `permission_handler` ile; "Sonra" izinsiz geçer.
- **Uç:** yok.
- **Bitti:**
  - Geri her adımda çalışıyor, seçimler korunuyor.
  - 9.–10. sınıfta alan bölümü yerine bilgi satırı çıkıyor.
  - `SMAP/lib/features/onboarding/onboarding_page.dart` ve `ob1-6.png` silindi.

**E3 · Giriş** [KISMİ]
- **Pano:** 2.3 (4 kare).
- **Bileşenler:** AppDetailBar, SmapLockup, AppTextField (password), AppNotice (error), AppButton (loading).
- **VM:** `LoginViewModel` + `AuthRepository` (Either). Test kalıbı `SHP/test/features/auth/presentation/login_viewmodel_test.dart`.
- **Uç:** `POST /student/login`; yanıt gövdesi doğrulanır, 302 başarı sayılmaz.
- **Bitti:**
  - Hata metni l10n'den (ham Exception, emoji ve stack yok).
  - Rol hesaptan okunuyor (7.2); "Beni Hatırla" yok (7.3).
  - `login_screen.dart`, `login_card.dart` ve `login_provider.dart` silindi.
- **Backend:** Apple ve Google varyantı P3 + resmî düğme varlıkları; o zamana kadar gizli.

**E3b · Şifremi Unuttum** [BLOKE]
- **Pano:** 2.4.
- **Bileşenler:** AppTextField, AppCodeInput.
- **Durum:** Uçlar yok (S7). Girişteki bağlantı gizli kalır. Bugünkü sahte akış (`SMAP/lib/features/auth/presentation/screens/forgot_password_screen.dart`) silinir.

**E4 · Kayıt** [KISMİ]
- **Pano:** 2.5–2.6.
- **Bileşenler:** AppSegmented (rol), AvatarPicker (7), AppTextField (canlı kontrol), AppSelectField, AppCheckbox, AppNotice.
- **VM:**
  - `RegisterViewModel`. `aimType` eşlemesi tek domain enum'unda (bugün `register_form.dart` ile `add_student_dialog.dart:103-108` çelişiyor).
  - Kullanıcı adı: harf, rakam, nokta, alt çizgi; küçük harfe çevrilir (7.4).
- **Uçlar:** `GET /ajax/checkUsername?name` (600 ms simülasyon yerine), `GET /ajax/getLegalDocuments`, `POST /student/register`.
- **Bitti:**
  - Yasal belgeler yüklenemezse kayıt kapalı (PLAN 0.5).
  - 829 satırlık `register_form.dart` silindi.
- **Backend:**
  - KVKK sürüm alanları (S6) gelmeden kayıt mağazaya çıkmaz.
  - Kanonik aimType değerleri (S+).

**E5 · Kabuk: alt çubuk ve kamera düğmesi** [HAZIR]
- **Pano:** 1.19, 1.23, 0.1, Tur 1 varsayım 1.9.
- **Bileşenler:** AppBottomNav, AppCameraButton, OfflineStrip, ToastService konumu.
- **Route yapısı:**
  - `StudentShellRoute`: Anasayfa, Analizlerim, (Okut), Derslerim, Hesap.
  - `CoachShellRoute`: Anasayfa, Öğrencilerim, (Okut), Görüşmelerim, Hesap.
  - Her sekme kendi yığınıyla AutoTabsRouter içinde.
  - Tam ekran akışlar (kamera, sonuç anı, kart oturumu, onboarding, giriş) kök router'da; bu yüzden çubuk kendiliğinden gizlenir.
  - Programım Anasayfa yığınında (6.10).
- **Geçiş:** Henüz taşınmamış sekmeler eski ekranı `Legacy…Route` sarmalayıcısıyla gösterir; eski Provider'lar router'ın üstünde kalır.
- **Bitti:**
  - Rol bazlı sekmeler; her sekmede geri davranışı doğru.
  - Ekran okuyucu "Analizlerim, sekme, 5'te 2" diyor.
  - `root_screen.dart`, `custom_bottom_nav_bar.dart`, `custom_top_app_bar.dart` ve 4 nav notifier silindi.

**E6 · Anasayfa (öğrenci)** [KISMİ]
- **Pano:** 3.1–3.3 (§6.1 ağacı).
- **Bileşenler:** AppRootBand (header), SectionHeader, ProgramItemRow, ExamCard, DybCounter.small, DeltaText, SubjectTile, EksikTag, AppTag.
- **Servisler:** `ScheduleService`, `ExamsService` (son denemeler), `LessonsService`.
- **Uçlar:**
  - `POST /student/getMyWeeklies` (Bugün)
  - `POST /student/getMyMockExams?page=1` (son deneme + aynı türün öncekisi)
  - `GET /student/getMexamSubjectDetail?mexamId` (en çok kaçırılan konu)
  - `GET /ajax/getGeneralLessons` + `GET /student/getLessonsTotalMissing` (Derslerin)
- **Bitti:**
  - Bölüm düzeyi durumlar (3.2) ve koyu kare (3.3).
  - Ders satırı tıklayınca son TYT/AYT seçimiyle ders detayı açılıyor (6.6).
  - Etikete bağlı yönlendirme (`home_menu_grid.dart`) ve `lesson_navigation_helper.dart` dialogu yerine typed route.
  - Kişi kartı, menü ızgarası ve takvim silindi; `HomeProvider`'ın öğrenci kısmı emekli.
- **Backend:**
  - Ders kataloğu ve "Web'de" bilgisi (S9); o zamana kadar `features/lessons/domain/lesson_catalog.dart`'ta (`SMAP/lib/core/constants/lesson_constants.dart`'tan taşınır).
  - N+1 çağrı yerine özet ucu isteğe bağlı (S+).

**E7 · Programım** [KISMİ]
- **Pano:** 3.4–3.8.
- **Bileşenler:** AppDetailBar, AppBarAction, AppSearchField, AppSegmented, AppDayChip, WeekGrid, AppCalendar, HourSlot, AppRadio, AppTextField, AppConfirmSheet (danger), Toast (Geri Al).
- **VM:** `ScheduleViewModel`, `NewScheduleSheet` (kendi VM'i). `bagItemsStr` yerine session scope'ta ScheduleService.
- **Uçlar:** `getMyWeeklies`, `addNewProgram`, `updateProgram`, `getAllMainSubjects`.
- **Bitti:**
  - Düzenleme anında kaydediliyor; "Bitti" yalnız modu kapatıyor (6.9).
  - Arama ve süzgeç gerçekten çalışıyor.
  - Geçmiş gün seçilemiyor.
  - Eski `my_schedule_page/` ağacı silindi.
- **Backend:** Program silme, iptal ve "Günü Sıfırla" ucu (S+).

**E8 · Kamera ve optik okuma** [BLOKE]
- **Pano:** 4.1–4.10, 0.2.
- **Bileşenler:** AppSheet (izin, öğretici), CameraOverlay, Handles, ProgressSheet, FormCheck, AppStatusView, AppStateBlock; deklanşör `PressScale(0.92)` + `medium()`.
- **VM:**
  - `ScanFlowViewModel` + `ScanJobService` (sıkıştır → yükle → oku → doğrula). Kalıp `MEM/lib/services/generation_service.dart`.
  - `ImageCompressor`: `Isolate.run`, uzun kenar 2400 px, JPEG %85 (2.5; PLAN'daki ~2000 px yerine tasarım).
  - Kırpmadan sonraki düzenleme adımı yok (2.4).
  - Kamera ekranları her temada koyu.
- **Uçlar:** `opticimage`, `answerArray`, `examrequest` (bugün placeholder host).
- **Ön koşul:** PLAN 0.3 (`NSCameraUsageDescription`), 0.9, 0.10 (scanner fork), 1.7 (multipart).
- **Backend:** S2, S3; "okuma açık" bayrağı (2.16, S10).

**E9 · Sonuç anı** [KISMİ]
- **Pano:** 5.1–5.2.
- **Bileşenler:** DybCounter.large, `metricXl`, DeltaText, AppSheet.
- **Davranış:**
  - `success()` bir kez; dönen sayaç ve konfeti yok.
  - "Detaya Git" kamera akışını kapatır, Deneme Detay'ı Analizlerim yığınına yerleştirir (3.1).
  - Bildirim izni sheet'i push gelene kadar kapalı (2.17, PLAN 3.5).
- **Uç:** `GET /student/getTotalInfoCard?mexamId` (NetworkService'e taşınır).
- **Bitti:** `omd_result_flow_view.dart` (1.663 satır) silindi.

**E10 · Deneme Detay ve Soru Detay** [KISMİ]
- **Pano:** 5.3–5.10 (§6.2 ağacı), 5.7.
- **Bileşenler:** AppTabBar, DybStackedBar, AppAccordion, QuestionCell, TopicResultRow, InfoCardFace.
- **VM ve veri:**
  - `ExamDto` (bugün ham Map), `getMexamSubjectDetail`, `getMexamItemDetail`, `POST /student/getQuestion`.
  - Koçta `studentId` açık parametre (bugün `my_test_result_detail_screen.dart:37`'de düşüyor).
- **Bitti:**
  - "D" değeri doğru alandan okunuyor (bugün `my_test_results_detail_widgets.dart:1234`'te wrong'dan).
  - Ders adı kesilmiyor (`:1387` substring).
  - Sabit "OBP 85" yok.
  - Soru Detay'da önceki/sonraki gezinmesi yok (3.9).
- **Backend:**
  - id ile tek deneme ucu (S+). Bugün detay, listeden gelen Map'le açılıyor; derin bağlantı için gerekir.
  - Puan ve sıra alanları (`aytNets`, 2.10–2.11).
  - Koç sahiplik kontrolü (S5).

**E11 · Analizlerim: Genel ve Denemelerim** [KISMİ]
- **Pano:** 6.1–6.4.
- **Bileşenler:** AppRootBand (`bottom: AppTabBar`), AppChip süzgeç, NetChart, AppStatBox, ExamRow; sayfalama ve keep-alive kalıbı `SMAP/lib/features/analytics/presentation/widgets/my_test_results_tab.dart`'tan.
- **Uçlar:** `getTotal`, `getLineChartData`, `getMyMockExams` (types ve hazır tarih aralıkları, 4.7).
- **Bitti:**
  - Delta yalnız son iki denemeden.
  - AYT için `aimType=2` zorlaması kalktı.
  - Favori yalnız cihazda (4.8).
  - Harita sekmesi yok.
- **Backend:** Ortalama puan ve sıralama yoksa kutular çizilmez (4.3); ders bazında geçmiş (S8).

**E12 · Derslerim, Ders Detayı, Konu Detayı, Edebiyat** [KISMİ]
- **Pano:** 7.1–7.6.
- **Bileşenler:** AppRootBand (segmentli), SubjectRow, AppChip, AppSegmented (sayaçlı), TopicRow, EksikTag, AppAccordion, ExampleBox, AuthorRow.
- **VM:** PLAN 2.6'daki birleştirme: `edebiyat_lesson_detail_page.dart`, `lesson_detail_page.dart`, `subject_detail_page.dart` ve `lesson_bar.dart`, `LessonDetailView` + `TopicDetailView` + `LiteratureAuthorsView`'a iner. EserTypeHelper (`edebiyat_lesson_detail_page.dart:12`) `lessons/application/`'a taşınır.
- **Uçlar:** `mainSubjects`, `getSubSubjects`, `getItems`, `yazarEserMainSubjects`, `getSubjectAuthors`, `learnedItem`, `getInfoCardsInfo`.
- **Bitti:**
  - TYT/AYT seçimi cihazda hatırlanıyor (5.8).
  - Çevrimdışıyken "Web'de" dersler gizli (5.9).
  - İlk eksiğe 350 ms kaydırma.
  - Sahte %75 ve 0.6 ilerleme yok.
- **Backend:** S9 (katalog), S8 (alt başlık, madde, kart sayıları; ders başına TYT/AYT eksik ayrımı).

**E13 · Kart Destesi** [KISMİ]
- **Pano:** 8.1–8.2 (+ 7.3 CardSheet, 5.6).
- **Bileşenler:** AppSegmented (sayaçlı), SessionProgress, CardDeck, AppConfirmSheet, Toast (Geri Al 6 sn).
- **Davranış:**
  - "Öğrendim" onayı ilk seferde; "Bir daha sorma" cihazda.
  - Bugün erişilemeyen akış (`my_card_page.dart:116`) Derslerim, Konu Detayı ve Deneme "Kartlar" sekmesinden açılır.
  - `appinio_swiper` kaldırılır.
- **Uçlar:** `getLessonInfoCards`, `learnedCard`, `addFavoriteMobil`.
- **Backend:** Öğrenmeyi geri alma ucu (S+).

**E14a · Hesap, Profil, Sözleşmeler, Çıkış** [HAZIR]
- **Pano:** 9.1, 9.2, 9.7.
- **Bileşenler:** AppRootBand + ProfileSummary, AppRowGroup/AppRow, AppTextField (salt okunur ve düzenleme), AvatarPicker, AppSelectField, AppConfirmSheet (çıkış onayı normal lacivert, 8.9).
- **Uçlar:** `updateStudent`, `getLegalDocuments`, `/ajax/logout` (SessionManager üzerinden). Async durum kalıbı `SMAP/lib/features/profile/presentation/screens/contracts/contracts_screen.dart`'tan.
- **Bitti:**
  - Profil güncellemesi CurrentUserService'i yeniliyor (bugün header bayat kalıyor).
  - Ödeme, Kartlar ve eski Bildirimler mock'ları silindi (D-4).
  - "Bize Yaz" sürüm ve cihaz bilgisiyle e-posta taslağı açıyor (destek adresi AppConfig'ten).

**E14b · Şifre, Hesabı Sil, Koçluk, Bildirimler** [KISMİ]
- **Pano:** 9.3–9.6.
- **Hesabı Sil:** Tam ekran spinner, geri kapalı; `GET /ajax/deleteAccount` + tam temizlik; PLAN 2.9'daki `SHP/lib/features/account/deletion/` kalıbı.
- **Koçluk:** `getStudentsCoach`, `addCoach` (4 harf + 4 rakam maske), `deleteCoach` (parametre düzeltilir).
- **Bildirimler:** Tercihler cihazda (8.4–8.5); sessiz saatte AppTimeWheel.
- **Backend:**
  - Şifre değiştirme S7 → [BLOKE]; satır gizli.
  - Bildirim tercihlerinin sunucuya yazılması S10 (`/devices`).

**E15 · Koç Anasayfa** [KISMİ]
- **Pano:** 10.1.
- **Bileşenler:** AppRootBand (header), StudentTile, AttentionRow, MeetingRow, CodeCard.
- **Uçlar:** `POST /coach/getMyStudents`, `POST /coach/getInterviews` (yaklaşan).
- **Backend:**
  - Dikkat kuralları için öğrenci başına son deneme ve eğilim verisi (S+, bugün N+1).
  - Koçluk kodunun kaynağı (S+).
  - Öğrenci listesindeki `password` alanı (S4).

**E16 · Öğrencilerim ve Öğrenci Ekle** [KISMİ]
- **Pano:** 10.2–10.3.
- **Bileşenler:** AppRootBand, AppSearchField (tr katlama), StudentRow, AppStateBlock (üç avatar), uzun AppSheet, AppSelectField, CodeCard.
- **Uçlar:** `getMyStudents`, `checkUsername`, `addNewStudent`.
- **Bitti:**
  - Türkçe alfabetik sıralama (9.3).
  - Sahte "Başarısız (Derece)" yok.
  - Avatar yolu tek kurala bağlı (bugün üç farklı konvansiyon var).
  - `features/my_students/` katmanlara ayrıldı.
- **Backend:** S4.

**E17 · Öğrenci Profili (koç bağlamı)** [KISMİ]
- **Pano:** 10.4.
- **Bileşenler:** AppContextStrip, AppTabBar, NetChart, AppStatBox, ExamRow, AppDayChip.
- **VM:** `StudentRef` route parametresi. E10, E11 ve E7'nin view'ları `student:` parametresiyle yeniden kullanılır (11.14: "StudentScope"); program koçta salt okunur (9.6).
- **Bitti:** Koçun açtığı her öğrenci ekranında bağlam şeridi var; drill-down'da studentId düşmüyor.
- **Backend:** S5 (sahiplik).

**E18 · Görüşmelerim ve Görüşme Notları** [KISMİ]
- **Pano:** 10.5–10.6.
- **Bileşenler:** AppRootBand, AppSearchField, AppChip, MeetingRow, AppSheet, AppTextField (multiline), AppConfirmSheet, Toast.
- **Uçlar:** `getInterviews`, `addNewInterview`, `addNewNote`, `editNote`, `deleteNote`.
- **Bitti:** `interviews_screen.dart` (1.088 satır) ve `interview_detail_screen.dart` silindi.
- **Backend:**
  - Arama parametresi (bugün sorgu hiç gönderilmiyor).
  - Görüşmeden 1 saat önce hatırlatma için push (PLAN 3.5).

**E19 · Koç için Okut** [BLOKE]
- **Pano:** Tur 9 varsayım 9.9.
- **İş:** Kamera akışının başına öğrenci seçimi sheet'i.
- **Backend:** OMR'nin studentId kabul etmesi (S2, S5).

**E20 · Kapanış** [HAZIR]
- D-14 koyu listesi denetlenir: 3.3, 3.8, 4.3–4.4, 4.6, 5.1 kare 3, 5.9, 5.10, 6.4, 7.6, 8.2.
- `ThemeMode.system` açılır (K5).
- `lib/views`, `lib/repository`, `lib/http_service`, `AppColors`/`AppTheme` ve `provider` paketi silinir.
- CI'a `core/theme` dışında `Color(0x` sayacı (hedef 0) eklenir (PLAN 4.4).
- Erişilebilirlik denetimi yapılır (PLAN 4.8).

---

## 8. Ekran başına tekrarlanan iş akışı (her PR'ın kontrol listesi)

1. **Branch.** `main`'den `ekran/eN-<ad>` (temeller için `temel/tN-<ad>`). Çalışma ağacı temiz; başka oturumun commit edilmemiş kodu yok.
2. **Spec'i oku.**
   - Panonun PNG'si ve `text.txt`'si (her kare)
   - 11.14'teki satırı (bileşenler), 11.15'teki satırları (hareket ve haptik)
   - 11.16'da o turun varsayımları
   - Mevcut kodun durumu: `tasarim-paketi/SMAP_Ekran_Envanteri.md` (§9'daki düzeltmelerle)
   - PLAN Faz 2'deki satır
3. **Önce veri.**
   - dart_mappable DTO, typed request, `Either` dönen repository, servis.
   - Saf mantık `application/` altında ve unit test'li: net, delta, sıralama, süzgeç, Türkçe arama katlama.
   - Ham `Map` UI'a ulaşmaz.
4. **VM.**
   - Bağlamsız; `locator<>()` ile constructor injection; bölüm başına `SectionState`; 15 sn zaman aşımı.
   - İşlem bazında busy key (`static const saveKey`; `SHP/lib/features/sharing/presentation/invite_sheet_viewmodel.dart` kalıbı).
   - VM testi yazılır.
5. **View.**
   - `StackedView` + `reactive => false`, tek `CustomScrollView`, part dosyaları (§6).
   - Her bölüm `SelectorViewModelWidget`; iskelet, boş, hata ve çevrimdışı durumları var.
6. **Yalnız kitle kur.** Eksik genel parça → `shared/ui` + galeri, aynı PR'da. Alan parçası → feature `widgets/`.
7. **Metin.**
   - Her string `app_tr.arb`'ye feature önekiyle girer; üretilen `app_localizations*.dart` aynı commit'tedir.
   - Biçimler `TrFormat` ile.
   - Metin kuralları: İptal sözlüğü, başlık düzeni, "sen" dili.
8. **Erişilebilirlik.** 48 dp, adlı ikon düğmeleri, D/Y/B tek okunuş, metin ölçeği 1,3, hareketi azalt, VoiceOver ve TalkBack'te bir tur.
9. **İki tema.** Açık ve koyu (varsayılan light olsa bile); panonun koyu karesi varsa yan yana kıyas.
10. **Eskiyi sil.** Ekranın yerini aldığı dosyalar, Provider'lar, repository metotları ve varlıklar aynı PR'da gider. Göç grep'i (presentation altında sıfır olmalı):

    ```
    Color(0x · Colors. · TextStyle( · fontSize: · Icons. · CupertinoIcons. ·
    CircularProgressIndicator · AlertDialog · showDialog · SnackBar · MaterialPageRoute ·
    Navigator.push · SharedPreferences.getInstance · print( · BorderRadius.circular ·
    Duration(milliseconds · Text('…' literal
    ```
11. **Doğrula.** `dart format .`, `flutter analyze`, `flutter test`, codegen güncel (gen-l10n, build_runner). Yeni root servis eklendiyse DI testi güncellendi.
12. **İz bırak.**
    - Widget doc yorumunda pano ve kare kodu.
    - PR açıklamasında pano ve uygulama ekran görüntüsü çiftleri (iki tema).
    - §7'deki satıra ✓ ve PR numarası; PLAN Faz 2 tablosu güncellendi.
13. **PR → inceleme → squash merge → branch silinir.**

---

## 9. Riskler ve dikkat edilecekler

### 9.1 Sepello geçmişinden dersler

| Ders | Sepello kanıtı | SMAP'te ne yapılır |
|---|---|---|
| Yanlış kaynaktan port etme | Kök `app-design.html` eski prototipti; ondan yapılan SepelloAppTheme c94602c'de silindi. | Hedef `TSR/`'dir. Hedef olmayanlar: `tasarim-paketi/ekranlar/` (eski uygulamanın görüntüleri), `SMAP_Gorsel_Dil.md` (eski dilin denetimi), `SMAP_Claude_Design_Prompt.md`'deki token tablosu (brif). mihr araştırmasındaki "turuncu brand, kart 20, buton 14, sheet 28, Display 34/40, gövde 15/22" önerileri brife dayanıyor; kanvas bunları değiştirdi (K1, K2). |
| Adları tasarımın kendi adlarından al | PR #28 rol adlarıyla yazıldı, PR #29 CSS adlarıyla yeniden yazıldı. | Alan adları ilk günden 11.12 token adları (§4.2). |
| Önce karar tablosu | Devir dokümanında 14 çelişki çıktı (04 §3). | §4.1 tablosu T0'dan önce onaylanır. |
| Tasarım sistemi slotları tutmuyor | mihr bg/text durum ve marka slotları AA'yı geçemedi. | Bütün renkler `context.appColors`'tan; mihr renk getter'ları yasak (§4.6). |
| Scaffold beyaz kalıyor | `SHP/lib/app/app.dart:47,56` | `scaffoldBackgroundColor: bgCanvas`, `materialOverrides` içinde. |
| Galeri kit PR'ında olmalı | 4498fb1 | T1. |
| Kit ekran PR'larında büyür | SectionHeader, MoneyField, HighlightText… | §5 "İlk kullanan ekranla" satırı. |
| Format ve analyze | a8e8e7b'deki gürültülü diff; eb11067, e6f526c ve 1a8f42b yalnız import düzeltmesiydi. | §8 madde 11 ve CI. |
| Root servis DI testini kırar | c94602c, f08e1bd | Her yeni root servis için DI testi güncellenir. |
| Çevrimdışı ile sunucu hatası ayrılmalı | 633a0e2 | AppErrorCode'da ayrı kategori: OfflineStrip, ErrorState, Bakım ve Oturum ayrı ekranlar (1.22, 2.7). |
| Native build sırası auth'u kırabilir | 9bfff7a | Kamera ve Firebase plist değişikliklerinde iOS build sırası elle kontrol edilir. |
| Paralel oturumlar | 04 §0 durum notu | Dilime başlamadan çalışma ağacı commit edilir. |
| İzlenebilirlik | Doc yorumlarında "board 5-01" | Doc yorumlarında "pano 3.1 · kare 2"; iki numaralama düzeni (dosya `00-3-1` ile pano `3.1`) karıştırılmaz. |

### 9.2 Sepello'dan kopyalarken değişmesi gerekenler

| Konu | Sepello | SMAP (pano) |
|---|---|---|
| Köşe | `RoundedSuperellipseBorder` her yerde | Düz yuvarlak köşe (K11) |
| Dokunma hedefi | 44 pt | 48 dp (1.7) |
| İkonlar | HugeIcons `List<List<dynamic>>` | Phosphor `IconData`; Regular, seçiliyken Fill (1.17) |
| Basılı ölçek | 0,97 | 0,98; hücre 0,97; deklanşör 0,92 (1.8, 5.4) |
| Sheet | 320/240 ms, σ4 | 350/250 ms, %48/%64 perde + 8 pt blur (1.8, 1.20) |
| Blur | AppGlass, ekran başına 2 | Yalnız alt çubuk ve perde (1.7) |
| Girdi hatası | Sallanma + haptik | Sallanma yok (yalnız kod kutuları), error haptiği (1.8) |
| Rozet | AppBadge radius 6, renkli tonlar | AppTag nötr; renkli hap yok (1.11) |
| Haptik | 7 çağrı, Android'de impact | 4 çağrı; Android CONFIRM/REJECT köprüsü (1.8) |
| Tema varsayılanı | Koyu | Açık, sonra sistem (K5) |
| Toast | 4 / 5 / 6 sn | 4 sn, Geri Al'lı 6 sn (1.22) |
| İskelet | Sürekli | 15 sn sonra hata (1.22) |
| Kimlik renkleri | IdentityTone 17 ColorScale | SubjectTone 9 ders (1.5) |
| FAB | AppFab | Alt çubuktaki kamera düğmesi (1.19) |

### 9.3 SMAP'e özgü engeller

- **Strangler zorunlu.** Global tema değişimi (T0) eski ekranların varsayılan renklerini değiştirir. Eski Provider'lar (HomeProvider, iki UserProvider) her ekran PR'ında yeni servise devredilmeli. Yeni ekranlar eski Provider okumaz.
- **Görünen etikete bağlı navigasyon.**
  - `home_menu_grid.dart:139-158, 176-226` ve `lesson_navigation_helper.dart:19-41` Türkçe ders ve menü adlarıyla yönleniyor.
  - Tasarım etiketleri değiştiriyor; önce typed route'a geçilmeden metin değiştirilmez.
  - `AppLessons`'taki sabit ObjectId'ler S9'a kadar `lessons/domain`'de tek yerde tutulur.
- **Ham Map veri.** Deneme detayı `Map` ile açılıyor (`my_test_result_detail_screen.dart`); OMR sonucu `mexamFound` null olabiliyor (`omd_result_flow_view.dart:323`). E10 ve E9'dan önce DTO şart.
- **Sahte veri tasarımla çelişir.** Tasarım "veri yoksa alan çizilmez" diyor. +18.2%, %75, 15/20, "Başarısız (Derece)", OBP 85 ve sahte şifre başarısı hiçbir yeni ekrana taşınmaz (PLAN 0.4).
- **Backend blokajları.** E3b, E8, E14b şifre kısmı ve E19 [BLOKE]; diğerlerinde flag'li kısımlar var (§7). Yeni sorular PLAN §7'ye eklenmeli:
  - program silme/sıfırlama
  - id ile deneme
  - öğrenmeyi geri alma
  - koç dikkat verisi
  - koçluk kodu kaynağı
  - görüşme arama parametresi
  - kanonik aimType
- **Font.** Plus Jakarta Sans'ın `tnum` desteği ve Türkçe glifleri fonttools ile doğrulanmadan T0 bitmez. `PlusJakartaSans` aile adı pubspec ile birebir olmalı; yoksa Flutter sessizce sistem fontuna düşer. 32/40 ve 24/32 satır yüksekliğinde İ noktası ve Ş/Ç çengeli kontrol edilir.
- **Varlık boyutu.** `assets/authors` 38 MB; CDN'e taşınana kadar (PLAN 4.6) dokunulmaz ama yeni varlık eklenmez. Kil illüstrasyon ekranda en çok bir tane ve yalnız onboarding ile boş durumlarda (1.25).
- **Mağaza politikası.** Ödeme, kart ve fatura ekranları tasarımda yok (D-4); PLAN P1/P2 kararı gelene kadar kod da yok.
- **Test kuralı çelişkisi (K7).** PLAN golden testi istiyor, ev kuralı UI testi istemiyor. Rasit karar verene kadar §8 ev kuralına göre yazıldı; golden seçilirse Faz 4.3'te toplu eklenir.
- **mihr_ui dev.3 sınırları.** Klavye odak halkası ve mobil 48×48 hedef dev.4'te. AppButton bunları kendisi sağlar (`MaterialTapTargetSize.padded`, focusRing). Path bağımlılığı eklenmez.
- **Kamera izni.** `NSCameraUsageDescription` olmadan ilk okutmada çöküş (PLAN 0.3). E2'deki ön izin ekranı bu düzeltmeden önce yayınlanmaz.

---

## 10. Ek: SMAP için önerilen AGENTS.md taslağı

```markdown
# SMAP – Agent Rules

## Working with Rasit
- Respond in Turkish; code, identifiers and doc comments in English (UI copy quoted in Turkish).
- Plans are reviewed and approved before implementation. Do not start coding right after a plan.
- Before deciding architecture, look at the reference apps: Sepello (Sepello (repo dışı referans uygulama)),
  Memora (Memora (repo dışı referans uygulama)), Sleepia (Sleepia (repo dışı referans uygulama)).

## Sources of truth
- Design: docs/design (board text in unpacked/SMAP-NN/*/text.txt, PNG in png/).
  Handoff boards: 11.12 tokens, 11.13 components, 11.14 screen-component map, 11.15 motion/haptics, 11.16 assumptions.
  Board 11.12 wins over earlier boards; earlier briefs and old-app screenshots are NOT targets.
- Roadmap: docs/history/SMAP_Gelistirme_Plani.md. UI guide: "SMAP UI Uygulama Rehberi".

## Architecture
- Feature-first MVVM with stacked; get_it manual registration with a session scope; auto_route (View → Route);
  dart_mappable DTOs; repositories return Either<AppException, T>; one NetworkService. No new Provider/ChangeNotifier screens.
- Screen = lib/features/<f>/presentation/<screen>/{<screen>_view.dart, <screen>_viewmodel.dart, widgets/ (part files), sheets/}.
- Pure logic lives in features/<f>/application/. Domain constants stay in their feature, never in core/.
- ViewModels are context-free: navigation via injected AppRouter, toasts via ToastText lambdas, sheets via XSheet.show().
  VMs are never registered in get_it; services are injected from locator in viewModelBuilder.

## UI rules
- Colors only via context.appColors (SmapColors); text only via context.appText (SmapText) + copyWith(color:);
  spacing via MihrSpacing; radius via AppRadius; motion via context.motion(AppMotion.x) / SmapDurations; icons via phosphor_flutter.
- Forbidden in features: Color(0x…), Colors.*, TextStyle(, fontSize:, context.textColors/bgColors/typography, MihrRadius,
  Icons.*, Duration literals, string literals in Text, showDialog/AlertDialog/SnackBar, MaterialPageRoute, Navigator.push.
- Orange is only for the camera button, position indicator, progress and "today". Selection is navy. No white text on orange.
- Cards have no border and no shadow. Blur only on the bottom bar and sheet scrim. Plain rounded corners (no squircle).
- Build from lib/shared/ui (App*) and feature widgets. Add a missing generic piece to shared/ui + the component gallery in the same PR;
  domain-aware pieces stay public in the owning feature's presentation/widgets/.
- Class widgets only (no Widget _buildX methods). Private _Widgets in part files, const constructors, one section per part file.
  Limits: view shell ≤ 250 lines, part ≤ 300, VM ≤ 500, no presentation file > 400.
- Root view is StackedView with reactive => false; each data section is a SelectorViewModelWidget with a record selector over
  immutable values; actions via getParentViewModel(context, listen: false); hot values via ValueNotifier.
- One CustomScrollView per screen (PinnedHeaderSliver, SliverMainAxisGroup). No NestedScrollView, no sliver_tools.
- Every section has loading (skeleton mirroring layout, 15 s timeout), empty, error and offline states. Never render fake data;
  if data is missing, do not draw the field.
- All dialogs are AppSheet sheets returning a typed result; the calling VM writes, toasts and undoes.
- Copy: "Vazgeç" (never "İptal"), "Tamam", "Kapat" (a11y name only), "Geri Al" (toast only); "sen" tone; no emoji, no ALL CAPS;
  question titles in sentence case, screen/sheet titles in Turkish title case. Numbers/dates via TrFormat (67,5 · 412,63 · 48.215. · %42 · 5 Eki.).
- l10n: gen-l10n, template lib/l10n/app_tr.arb, keys <feature>_<camelCase>, shared common_*, screen-reader-only …A11y.
  Commit generated files in the same commit. Turkish-aware case folding for search; no String.toUpperCase on Turkish text.
- Accessibility: 48 dp targets, required semanticLabel + tooltip on icon buttons, single Semantics reading for D/Y/B and
  question cells, header semantics on titles, liveRegion for status, text scale 1.3 without layout breaks, reduce motion → 150 ms fades.
- Haptics: AppHaptics.selection / medium / success / error only, on outcomes (never on scroll or every tap).
- Every widget's doc comment cites its board and frame ("pano 3.1 · kare 2") and quotes the Turkish copy.

## Process
- Branch per slice from main (temel/tN-…, ekran/eN-…) → PR → squash merge → delete branch. Prod releases need Rasit's OK.
- Per PR: data + VM tests first, then view; delete the legacy files the screen replaces in the same PR;
  run dart format, flutter analyze, flutter test, codegen; check light and dark, text scale 1.3, VoiceOver/TalkBack.
- Tests: unit tests for VMs, services, repositories and pure logic (incl. token contrast test). No widget/golden tests unless
  Rasit decides otherwise. UI is verified in ComponentGalleryView (--dart-define=GALLERY=true).
- Update the guide's step table (✓ + PR number) and the roadmap row in the same PR.
```