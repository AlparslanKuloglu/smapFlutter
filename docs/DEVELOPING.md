# SMAP · Geliştirici rehberi

Bu belge projeye yeni katılan geliştiricinin (ya da yapay zekâ ajanının) ilk okuyacağı yerdir. Uygulamanın ne olduğunu, kodun nasıl düzenlendiğini, bir ekranın ya da bir ucun nasıl ekleneceğini ve hangi kuralların neden var olduğunu anlatır. Ayrıntılar `docs/dev/` altındaki bölümlerde; bağlayıcı kuralların kısa listesi `AGENTS.md`'de; işin nasıl bölünüp incelendiği `docs/WORKFLOW.md`'de.

---

## 1. Uygulama

**SMAP (Student Map)**, YKS'ye (TYT/AYT) hazırlanan lise öğrencileri ve öğrenci koçları için bir Flutter uygulamasıdır.

- **Öğrenci:** deneme optik formunu kamerayla okutur, sonucunu ve analizini görür (net, D/Y/B, konu bazında eksikler, puan ve sıra), derslerin konularını ve bilgi kartlarını çalışır, haftalık program kurar, koçun verdiği kodla bir koça bağlanır (koçunu sonradan değiştirebilir).
- **Koç:** öğrencilerini ekler ya da koçluk kodunu paylaşarak bağlar, her öğrencinin analizini, denemelerini ve programını görür ve düzenler, görüşme planlar, görüşme notu tutar. Koç hesabı uygulamada açılmaz: kayıt yalnız öğrenci içindir, koç yalnız giriş yapar (`FeatureFlags.coachSignUpEnabled = false`, sahibin kararı).
- **Backend:** mevcut SMAP sunucusu (`https://www.smaptr.com`, adres `config/dev.json` ya da `--dart-define` ile değişir). Bu depo yalnız mobil istemcidir. Sunucuda karşılığı olmayan ya da cevabı beklenen davranışlar `docs/Backend_Sorulari_Ek.md`'de, bayrakla kapalı tutulan özellikler `lib/core/config/feature_flags.dart`'tadır.
- **Tarihçe:** Uygulama 2026 Ekim'inde Claude Design'da hazırlanan tasarıma göre eski kod tabanından ekran ekran yeniden yazıldı (Tur 1–12). Eski kod tamamen silindi; yalnız eski cihaz verisinin göçü kaldı. Plan ve kararlar `docs/SMAP_Ana_Plan.md`'de, görev görev ilerleme `docs/DURUM.md`'de.

## 2. Hangi bilgi nerede

| Ne arıyorsunuz | Nereye bakın |
|---|---|
| Bağlayıcı kurallar (kısa) | `AGENTS.md` |
| Uygulamanın iskeleti: açılış, DI, router, guard'lar, kabuk | `docs/dev/01_mimari.md` |
| Veri katmanı: NetworkService, hata modeli, DTO, yeni uç tarifi, oturum, çevrimdışı | `docs/dev/02_veri.md` |
| Ekran kalıbı: View/ViewModel, seçiciler, durumlar, sheet, toast, Geri Al, **yeni ekran tarifi** | `docs/dev/03_ekran.md` |
| Tasarım sistemi: renk, yazı, boşluk, hareket, kit kataloğu, galeri, pano atıfları | `docs/dev/04_tasarim_sistemi.md` |
| Araçlar: sürümler, codegen, l10n, analiz, CI, test, debug tanımları, komutlar, yayın listesi | `docs/dev/05_araclar.md` |
| Özellik haritası, Tur 12 durumu, açık işler | `docs/dev/06_ozellikler.md` |
| Tasarım panoları ve görseller | `docs/design/README.md` |
| Çalışma modeli: görev, worktree, inceleme, entegrasyon | `docs/WORKFLOW.md`, şablon `docs/gorevler/_ortak.md` |
| Ürün kararları (K1–K16), spec, ekranlar, varsayımlar | `docs/SMAP_Ana_Plan.md`, `docs/spec/` |
| UI kuralları ve bölme örnekleri | `docs/SMAP_UI_Uygulama_Rehberi.md` + `docs/SMAP_UI_Rehberi_Duzeltmeler.md` |
| Durum, backend'e sorulanlar | `docs/DURUM.md`, `docs/Backend_Sorulari_Ek.md` |
| Geçmiş görev tanımları ve planlar | `docs/history/` |

Çelişki olursa öncelik: `docs/SMAP_Ana_Plan.md` → `docs/SMAP_UI_Rehberi_Duzeltmeler.md` → Tur 12 panoları (`SMAP-14` ve `SMAP-11`'deki Tur 12 ekleri; "Yerine geçtiği kare" etiketleriyle) → teslim panoları 11.12–11.16 → spec → UI rehberi → diğer panolar (panolar arası sıra: `docs/design/README.md` "Öncelik").

## 3. İlk gün

Gerekenler: Flutter **3.38.6** (stable; CI aynı sürümü kullanır, `.github/workflows/ci.yml`), Dart 3.10.x, Xcode (iOS) ve CocoaPods, Android SDK. Birden çok Flutter sürümüyle çalışıyorsanız `puro` ya da `fvm` ile bu sürümü sabitleyin.

```bash
flutter pub get
```

```bash
dart run build_runner build --delete-conflicting-outputs
```

```bash
dart run tool/merge_arb.dart && flutter gen-l10n
```

```bash
cp config/dev.json.example config/dev.json
```

```bash
flutter run --dart-define-from-file=config/dev.json
```

- Üretilen dosyalar (`*.gr.dart`, `generated/*.mapper.dart`, `lib/gen/`, `lib/l10n/app_localizations*.dart`, `lib/l10n/app_tr.arb`) depoda durur; CI güncel olduklarını denetler. Elle düzenlenmez.
- VS Code'da `.vscode/launch.json` hazır yapılandırmalar içerir: normal çalıştırma, `config/dev.json` ile, **öğrenci/koç önizlemesi (hesapsız)**, koyu tema, okutmayı galeriden deneme (simülatör), bileşen galerisi, profile ve release. `.vscode/tasks.json`: codegen, l10n, kontrol (format + analyze + UI kuralları), test, erişilemeyen dosyalar, pod install, ikon/splash.
- **Hesapsız çalışma:** `--dart-define=SHELL_PREVIEW=student` (ya da `coach`) uygulamayı oturum açmadan kabukla açar; veri çağrıları oturumsuz olduğundan iskelet, hata ve boş durumları görürsünüz. Veri dolu ekranı görmek için galeriyi (`flutter run -t lib/main_gallery.dart`) ya da geçici bir sahte repository'yi kullanın; canlı sunucuda test hesabıyla yazan işlem yapmayın.
- Diğer tanımlar: yalnız debug'da işleyenler `THEME_MODE=dark|light|system` ve `SCAN_GALLERY=true` (kamera yerine galeriden form fotoğrafı; simülatörde okutma akışı için); yapılandırma anahtarları (`config/dev.json`, release'te de geçerli) `OMR_BASE_URL` (optik okuma sunucusu; verilmezse `API_BASE_URL`) ve `CDN_BASE_URL`. Ayrıntı `docs/dev/05_araclar.md`.
- Simülatörde yeniden derlemeden başlangıç değeri (açılacak sekme, galeri sayfası, koyu tema): `tool/sim_env.sh booted SHELL_PREVIEW_TAB=2` ya da `tool/sim_env.sh booted GALLERY_PAGE=12 GALLERY_DARK=true`, sonra uygulamayı başlatın. iOS 26 simülatörlerinde `SIMCTL_CHILD_…` ortam değişkenleri uygulamaya ulaşmaz.

## 4. Kodun düzeni

```
lib/
  main.dart, main_initializer.dart   açılış (bootstrap, DI fazları, hata yakalama)
  main_gallery.dart                  bileşen galerisi (ayrı giriş noktası)
  app/                               uygulama kabuğu: router (+ guard'lar, rota listeleri), shell (alt çubuk), tema modu
  core/                              alana bağlı olmayan altyapı: config, network, errors, theme (token'lar), utils (TrFormat, TurkishText), services
  dependency_injection/              get_it kurulumu ve session kapsamı
  services/                          oturum (SessionManager) ve geçerli kullanıcı
  shared/ui/                         ortak kit (App* bileşenleri; galeride her biri görünür)
  features/<f>/                      özellik: data/ domain/ application/ presentation/ + <f>_routes.dart + <f>_module.dart
  l10n/                              arb/<f>_tr.arb parçaları → app_tr.arb → app_localizations*.dart
  gen/                               flutter_gen varlık erişimleri
  vendor/                            üçüncü taraf belge tarayıcı (dokunmayın)
```

Özellikler: `startup`, `onboarding`, `auth`, `home`, `schedule`, `scan`, `exams`, `analytics`, `lessons`, `cards`, `account`, `coach`, `shell`, `debug` (galeri sayfaları). Her birinin içeriği `docs/dev/06_ozellikler.md`'de.

## 5. Mimarinin özü

- **MVVM (stacked)**, özellik öncelikli klasörler. Ekran = `presentation/<ekran>/<ekran>_view.dart` + `<ekran>_viewmodel.dart` + `widgets/` (part dosyaları) + `sheets/`.
- **View** `StackedView` ve `reactive => false`: kök yeniden çizilmez. Her veri bölümü `SelectorViewModelWidget` ile yalnız kendi değişmez değerini (record) dinler.
- **ViewModel context'siz:** gezinme enjekte edilen navigator/`AppRouter` ile, sheet'ler `*Dialogs` arayüzüyle, toast'lar `ToastText` lambda'larıyla. ViewModel get_it'e kaydedilmez; servisler `viewModelBuilder` içinde `locator`'dan verilir. Bu sayede her ViewModel saf unit testle sınanır.
- **Saf mantık** `application/` altında ve testli; **veri** `data/` (repository + DTO) ve `domain/` (model) altında. Repository'ler `Either<AppException, T>` döner, tek `NetworkService` (Dio) kullanılır.
- **DI:** get_it, oturum açılınca `session` kapsamı kurulur, çıkışta atılır; kullanıcıya özel her servis bu kapsamdadır. Oturum bitince (çıkış, hesap silme) `SessionManager` cihazda kişiye ait tercihleri de siler (`DevicePreferences.clearAccount`: kayıt taslağı, yıldızlı denemeler, bildirim seçimleri, "Bir daha sorma"); aynı cihazdaki sonraki hesap temiz başlar.
- **Router:** auto_route 11.1.0 (sürüm sabit), guard zinciri (tanıtım, oturum, rol: `OnboardingGuard` → `AuthGuard` → `RoleGuard`; açılış ekranının guard'ı yoktur, hedefi kendisi seçer). Öğrenci ve koç ayrı kabuklarda.
- **Durumlar:** her bölümün iskelet (15 sn zaman aşımı), boş, hata ve çevrimdışı hâli vardır; veri yoksa alan çizilmez, sahte veri gösterilmez.

Ayrıntı ve gerekçeler: `docs/dev/01_mimari.md`, `docs/dev/03_ekran.md`.

## 6. En sık yapılan işler

| İş | Tarif |
|---|---|
| Yeni ekran | `docs/dev/03_ekran.md` "Yeni ekran tarifi": klasör, View, ViewModel, part'lar, seçiciler, durumlar, ARB, rota, DI, galeri, test, kontrol listesi |
| Yeni uç (endpoint) | `docs/dev/02_veri.md` "Yeni uç nasıl eklenir": DTO (dart_mappable), repository metodu, hata eşlemesi, test |
| Yeni metin | `lib/l10n/arb/<f>_tr.arb`'e anahtar (`<f>_camelCase`, ekran okuyucu metni `…A11y`), sonra `dart run tool/merge_arb.dart && flutter gen-l10n` |
| Yeni genel bileşen | `lib/shared/ui/<grup>/app_<ad>.dart` + galeri sayfasında örnek (`lib/features/debug/pages/`); doc yorumunda pano ve C numarası |
| Yeni rota | `lib/features/<f>/<f>_routes.dart` listesine ekle, `app_router.dart`'a View importu, `dart run build_runner build -d` |
| Bayrakla kapalı özellik | `lib/core/config/feature_flags.dart`'a belgelenmiş `static const bool`; kapalı hâl de testli |
| Yeni tasarım turu | `docs/design/README.md` "Yeni bir tur geldiğinde" ve `docs/WORKFLOW.md` §10 |

## 7. Kalite kapıları

Her değişiklikte, birleştirmeden önce:

```bash
tool/format.sh
```

```bash
flutter analyze
```

```bash
tool/ui_rules.sh
```

```bash
flutter test
```

- `tool/format.sh`: `lib/vendor` dışında git'te izlenen bütün Dart dosyalarını biçimler (`dart format .` üçüncü taraf `lib/vendor`'u da yeniden biçimler, kullanmayın); yeni dosyayı önce `git add` edin, yoksa biçimlenmez. CI aynı betikle denetler (`--output=none --set-exit-if-changed`).
- `flutter analyze`: **0 sorun** (bilgi düzeyi dahil; CI'da ölümcül).
- `tool/ui_rules.sh`: ham renk, `TextStyle(`, `fontSize:`, Material ikon, diyalog/snack bar, `Navigator.push`, `print(`, `Widget _build…`, sunumda ham `Duration(` ve dosya boyları (ekran 250, part 300, ViewModel 500, diğer sunum/kit 400 satır).
- `flutter test`: ViewModel, servis, repository ve saf mantık testleri (3.400'ü aşkın). Görsel doğrulama galeride ve simülatörde panoyla yan yana yapılır.
- CI (`.github/workflows/ci.yml`): kilit dosyasıyla `pub get`, l10n ve codegen güncelliği, biçim, analiz, UI kuralları, testler.

## 8. Tasarımla çalışmak

Tek görsel hedef `docs/design/panolar/` altındaki panolardır. Kod panoya "pano 14.8 kare 2" diye atıf yapar; o atıfın görüntüsü `panolar/png/SMAP-14_07-14-8-….png`, metni ve kuralları `panolar/SMAP-14/07-14-8-…/text.txt`, kesin ölçüleri `board.html`'dedir.

- Ekrandaki Türkçe metinler panodakinin **birebir** aynısıdır.
- Renk, yazı, boşluk, yarıçap ve süre **asla** ham değer olarak yazılmaz; panodaki hex/pt değerinin token karşılığı kullanılır (`context.appColors`, `context.appText`, `AppSpacing`, `AppRadius`, `SmapDurations`). Eksik rol varsa tasarım sistemine eklenir.
- Panodaki örnek veriler (Alparslan Kuloğlu, 67,5 net, MOZK-4821…) tasarımın "Ek C" örnek setidir: testlerde kullanılır, uygulamada gösterilmez.
- Kil görseller (`AppClay`, `assets/illustrations/clay/`; pano 1.25) yalnız tanıtımda, ekran düzeyi boş durumlarda ve mağaza görsellerinde; ekranda en çok bir tane. Satırda, çipte, sekmede, düğmede, grafik yanında ve bölüm düzeyi boş durumda yok.

## 9. Tuzaklar (en çok can yakanlar)

1. **`PopScope` içinden kapatırken `maybePop()` kullanmak** uygulamayı dondurur (aynı `PopScope`'a yeniden sorar). `router.pop()` kullanın.
2. **Alt çubuk boşluğunu elle hesaplamak:** son satır çubuğun altında kalır. Her zaman `AppBottomBar.heightOf(context)`.
3. **Saat dilimi:** görüşme saatleri sunucuya dilimsiz yerel saat olarak gider ve tek kuralla okunur (`MeetingMoment.wallClock`); `toLocal()` eklemeyin.
4. **Türkçe büyük/küçük harf:** `toUpperCase()`/`toLowerCase()` "i/İ, ı/I"yi bozar; `TurkishText` kullanın. Ekler (`'e/'a`, `'ın/'in`) `TurkishSuffix` ile.
5. **Sayı ve tarih biçimi:** `TrFormat` dışında biçimlemeyin (67,5 · 48.215 · %42 · 5 Eki.).
6. **Kökü dinleyen View:** `reactive => true` ya da bütün ViewModel'i dinleyen bölüm, her değişiklikte ekranı baştan çizer. Seçiciler değişmez record döndürmeli.
7. **Sahte veri:** eksik alanı "0" ya da örnek değerle doldurmayın; alanı çizmeyin. Sunucu alanı gelmiyorsa `docs/Backend_Sorulari_Ek.md`'ye yazın.
8. **Ortak dosyalara paralel commit:** `app_tr.arb`, `app_router.dart`, DI, `pubspec.yaml` çakışır; yalnız koordinatör yazar.
9. **Canlı sunucuda deneme:** test hesabıyla bile yazan istek (kayıt, silme, koç bağlama, program kaydetme) gerçek veriyi değiştirir. Sahte repository ve galeri kullanın.
10. **auto_route ve build_runner sürümleri sabittir** (11.1.0 ve 2.13.1): auto_route 11.2+ Flutter 3.38.6'da derlenmiyor (`Viewport.scrollCacheExtent`, Flutter 3.41+); build_runner 2.15+ build betiğini AOT derlediğinden `objective_c` build hook'uyla kırılıyor (2.13.x JIT yolunu kullanır). Yükseltmeden önce deneyin.
11. **Simülatör ve disk:** her çalışma ağacı ayrı bir Xcode DerivedData üretir (birkaç GB). Görev bitince simülatörü ve o DerivedData'yı silin (`docs/WORKFLOW.md` §8).
12. **6 sn "Geri Al":** istek toast süresi dolunca gider (`PendingLearns`, `NoteDeleteHold`); ekran kapanırsa bekleyen işlem hemen uygulanır. Yeni bir geri alınabilir işlem aynı kalıpla yazılır.
13. **Metin alanlı `small` sheet klavyenin altında kalır.** `AppSheetRoute` yalnız `medium` ve `full` sheet'leri klavyenin üstüne kaldırır; form içeren sheet'i bu boylardan biriyle açın (ör. `ChangeCoachSheet` `full`).

## 10. Sözlük

| Terim | Anlamı |
|---|---|
| Pano, kare | Claude Design'daki tek tasarım panosu (ör. 14.8, `SMAP-14` sayfasında) ve içindeki tek telefon görüntüsü (kare 2) |
| Tur | Tasarım turu (Tur 1–12); SMAP-NN sayfaları turlara karşılık gelir |
| Ek C, D-n | Tasarım brifindeki örnek veri seti ve karar maddeleri (`docs/design/tasarim-paketi/SMAP_Claude_Design_Brifi.md`) |
| K1–K16 | Proje kararları (`docs/SMAP_Ana_Plan.md`) |
| T12.n | Tur 12 varsayımları (pano 11.16 ek) |
| C01–C86 | Spec'teki bileşen numaraları (`docs/spec/02_bilesenler.md`) |
| Deneme, net, D/Y/B | Deneme sınavı; net = doğru − yanlış/4; doğru/yanlış/boş |
| TYT, AYT, alan (EA/SAY/SÖZ) | Sınav oturumları ve puan türleri |
| Çanta | Öğrencinin denemelerinden çıkan eksik konular |
| Okutma, optik (OMR) | Optik formun kamerayla okunması |
| Koç, bağlam şeridi | Öğrenci koçu; koç bir öğrencinin ekranındayken üstte öğrenci adını taşıyan şerit |
| Koordinatör, uygulayıcı | İşi bölen ve inceleyen kişi/ajan; tek görevi yapan kişi/ajan (`docs/WORKFLOW.md`) |
| Önizleme (SHELL_PREVIEW) | Oturumsuz kabukla açılan debug modu |

## 11. Açık işler ve sahibine kalan kararlar

Güncel liste `docs/DURUM.md` ve `docs/dev/06_ozellikler.md` "Açık işler" bölümündedir. Özetle: backend'den beklenen cevaplar (`docs/Backend_Sorulari_Ek.md`), bayrakla kapalı özellikler (şifremi unuttum, sosyal giriş, koç kaydı, bildirimler, çevrimdışı kuyruk vb.), kil görsellerin 2x/3x asılları, yayın hazırlığı. Kimlik (`com.studentmap.smap`), Android release imzası (`android/key.properties`; anahtar sahibinde, git'te yok) ve sürüm (`1.0.0+3`) eski uygulamadan taşındı; kalanlar (yayın derlemesi, iOS imzası, mağazadaki son build numarası, mağaza metin ve görselleri) `docs/dev/05_araclar.md` "Yayın öncesi kontrol listesi"ndedir.
