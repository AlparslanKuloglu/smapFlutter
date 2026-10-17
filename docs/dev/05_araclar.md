# 05 · Araçlar ve süreç

Bu bölüm SMAP'ı yerelde kurmak, kod üretmek, denetlemek, test etmek, çalıştırmak ve yayına hazırlamak için gereken her şeyi tek yerde toplar: sürümler, komutlar, CI'nın baktığı şeyler, hata ayıklama tanımları, platform ayarları ve bilinen tuzaklar. Projeyi ilk kez açan bir geliştirici (ya da ajan) için sırayla okunacak yer [13. Yeni geliştirici ilk gün](#13-yeni-geliştirici-ilk-gün); gündelik kullanım için [12. Komut kopya kâğıdı](#12-komut-kopya-kâğıdı) yeterlidir.

Bu belgedeki her sürüm, komut ve yol repodaki dosyalara bakılarak yazıldı. Dosya tek kaynaktır; değiştiğinde buradaki ilgili satır da güncellenmelidir. Kodun yapısı için [01_mimari.md](01_mimari.md), veri katmanı için [02_veri.md](02_veri.md), ekran kuralları için [03_ekran.md](03_ekran.md), tasarım sistemi için [04_tasarim_sistemi.md](04_tasarim_sistemi.md), özellik envanteri için [06_ozellikler.md](06_ozellikler.md), kurallar için `../../AGENTS.md`, tarif ve rehber için [../DEVELOPING.md](../DEVELOPING.md), iş akışı (görev, inceleme, entegrasyon) için [../WORKFLOW.md](../WORKFLOW.md) belgelerine bakın. Bu bölüm WORKFLOW'daki süreci tekrar etmez; yalnız onun kullandığı araçları anlatır.

---

## 1. Araç zinciri ve sürümler

### 1.1 Flutter ve Dart

| Ne | Değer | Nerede yazılı |
|---|---|---|
| Flutter | **3.38.6** (stable) | `.github/workflows/ci.yml` → `FLUTTER_VERSION` |
| Dart | 3.10.7 (Flutter 3.38.6 ile gelir) | `pubspec.yaml` → `environment.sdk: ^3.10.7` |
| `pubspec.lock` SDK aralığı | `dart >=3.10.7 <4.0.0`, `flutter >=3.38.4` | `pubspec.lock` sonu |

- **Kural:** Yerel Flutter sürümü CI'daki (`FLUTTER_VERSION`) ile aynı olmalıdır. Sürüm yükseltmesi kendi PR'ında, `ci.yml`, `pubspec.yaml` ve bu belgeyle birlikte yapılır (bkz. [15. Tuzaklar](#15-tuzaklar) #1).
- Kurulum yöntemi serbesttir. Repoda `.puro.json` (`{ "env": "stable" }`) vardır; **puro** kullananlar için kolaylık sağlar, zorunlu değildir. FVM, elle kurulum ya da başka bir yönetici de olur; tek ölçüt `flutter --version` çıktısının 3.38.6 olmasıdır. `.fvmrc`, `.tool-versions` gibi başka bir sürüm sabitleme dosyası yoktur.
- `.puro.json` yalnızca "stable" ortamını adlandırır, sürümü **sabitlemez**; ortam stable kanalını izliyorsa yükseldiğinde 3.38.6'dan ayrılır. Her yeni makinede `flutter --version` ile doğrulayın.
- `android/local.properties` (Flutter SDK yolunu tutar) git'te yoktur; Flutter her makinede kendisi yazar, elle düzenlenmez.
- `.metadata` Flutter'ın ürettiği bir izdir, elle düzenlenmez.

### 1.2 Sabitlenmiş ve dikkat isteyen paketler

Sürüm numaraları `pubspec.yaml`'dandır; "lock" sütunu `pubspec.lock`'taki çözümlenmiş sürümdür.

| Paket | `pubspec.yaml` | lock | Neden |
|---|---|---|---|
| `auto_route` | `11.1.0` (**sabit**, `^` yok) | 11.1.0 | 11.2.0 `Viewport.scrollCacheExtent` kullanıyor (Flutter 3.41+); 3.38.6'da derlenmiyor. Flutter yükselince bu sabitleme kalkabilir. |
| `build_runner` | `2.13.1` (**sabit**) | 2.13.1 | 2.15 build betiğini AOT derliyor; build hook'u olan bir bağımlılık (`objective_c`) varken bu patlıyor. 2.13.x JIT yolunu kullanıyor. |
| `auto_route_generator` | `^10.5.0` | 10.5.0 | Üretici sürümü `auto_route` 11 ile aynı numarayı taşımaz. Dokunmadan önce `build_runner` çıktısını kontrol edin. |
| `mihr_ui` | `^0.1.0-dev.3` | 0.1.0-dev.3 | Tasarım sistemi paketi (bkz. [04_tasarim_sistemi.md](04_tasarim_sistemi.md)). Önizleme sürümü: düğmelerde `tapTargetSize: MaterialTapTargetSize.padded` her örnekte verilir (AGENTS "UI rules"). |
| `stacked` / `get_it` | `^3.5.0` / `^8.0.3` | 3.5.0 / 8.3.0 | MVVM ve DI iskeleti. |
| `dart_mappable` + `dart_mappable_builder` | `^4.7.0` / `^4.7.0` | 4.10.0 / 4.8.0 | DTO üretimi (bkz. [2.](#2-kod-üretimi-codegen)). |
| `flutter_gen_runner` | `^5.12.0` | 5.15.0 | `Assets.*` ve font erişimcileri. |
| `flutter_document_scanner` | `path: ./lib/vendor/flutter_document_scanner/flutter_document_scanner` | (yerel) | Vendor edilmiş üçüncü taraf kodu. Analizden ve build_runner'dan hariç; "olduğu gibi" tutulur, düzeltme yapılmaz. |
| `flutter_launcher_icons` (dev) / `flutter_native_splash` | `^0.14.4` / `^2.4.4` | 0.14.4 / 2.4.7 | İkon ve açılış üretimi (bkz. [8.3](#83-ikon-ve-açılış)). `flutter_native_splash` `dependencies` altındadır çünkü `lib/main_initializer.dart` `FlutterNativeSplash.preserve/remove` çağırır. |

- `flutter pub upgrade --major-versions` `auto_route` ve `build_runner` sabitlemelerini bozar; çalıştırmayın. Güncelleme yaparken `pubspec.lock` ile uyumsuzluk CI'da `pub get --enforce-lockfile` adımında kırmızı görünür.
- `pubspec.yaml`, `pubspec.lock`, `build.yaml`, `analysis_options.yaml`, `l10n.yaml` ve platform manifest'leri **ortak dosyalardır**: yeni paket ya da yapılandırma değişikliği koordinatör üzerinden gider (AGENTS "Shared files", [../WORKFLOW.md](../WORKFLOW.md)). Ajan ihtiyacını raporunda "Koordinatöre notlar" altında yazar.
- Ağ ve oturum için `dio` + `dio_cookie_manager` + `cookie_jar`, kamera için `camera` (0.10.x), izinler için `permission_handler`, grafikler için `fl_chart`, ikonlar için `phosphor_flutter`, sheet'ler için `smooth_sheets` kullanılır; ayrıntı pubspec'te.
- Mock kütüphanesi (`mocktail`, `mockito`) **yoktur** ve eklenmez (bkz. [6. Testler](#6-testler)).

---

## 2. Kod üretimi (codegen)

Tek komut üç üreticiyi çalıştırır:

```bash
dart run build_runner build -d      # -d = --delete-conflicting-outputs
```

| Üretici | Girdi | Çıktı |
|---|---|---|
| auto_route | `@RoutePage()`, `@AutoRouterConfig` | `lib/app/router/app_router.gr.dart` |
| dart_mappable | `@MappableClass` | `lib/<yol>/generated/<dosya>.mapper.dart` |
| flutter_gen (pubspec'teki `flutter_gen:` bloğu) | `assets/`, font tanımları | `lib/gen/assets.gen.dart`, `lib/gen/fonts.gen.dart` |

- `AppRouter` içinde `@AutoRouterConfig(replaceInRouteName: 'Page|Screen|View,Route')` vardır: `XxxView` sınıfı `XxxRoute` olur.
- `build.yaml` üç şey yapar: `lib/vendor/**`'ı build_runner kaynaklarından çıkarır; dart_mappable çıktısını `generated/` alt klasörüne yönlendirir (`build_extensions`); dart_mappable metot adlarını değiştirir:

```yaml
global_options:
  dart_mappable_builder:
    options:
      renameMethods:
        fromJson: fromJsonString
        toJson: toJsonString
        fromMap: fromJson
        toMap: toJson
```

- **Sonuç (dart_mappable alışkanlığının tersi):** bu projede `Dto.fromJson(map)` bir **Map** alır; JSON **metni** için `fromJsonString` / `toJsonString` kullanılır. Örnek: `test/services/session_harness.dart` içinde `UserDto.fromJson(studentJson(...))` bir Map verir.
- **Üretilen dosyalar commit edilir:** `*.gr.dart`, `*.mapper.dart`, `lib/gen/*`, `lib/l10n/app_localizations*.dart` git'te takiptedir. CI üretimi yeniden çalıştırır ve çalışma ağacı değişmişse kırılır ([5. CI](#5-ci)). Bir `@MappableClass`, `@RoutePage` ya da asset ekledikten sonra codegen çalıştırın ve çıktıyı aynı commit'e koyun.
- Geliştirirken `dart run build_runner watch -d` (VS Code görevi "Codegen: build_runner watch") kullanılabilir.

---

## 3. Yerelleştirme (l10n)

Tek dil: Türkçe (`tr`). Şablon dosya `lib/l10n/app_tr.arb`'dir ve **üretilir**: elle düzenlenmez, bir sonraki birleştirme ezer.

`l10n.yaml`:

```yaml
arb-dir: lib/l10n
template-arb-file: app_tr.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
nullable-getter: false
```

**Akış (sıra önemli):**

1. Metinler özelliğe ait parça dosyasına yazılır: `lib/l10n/arb/<ozellik>_tr.arb` (şu an 24 parça: `common_tr.arb`, `scan_tr.arb`, `exam_detail_tr.arb`, …).
2. `dart run tool/merge_arb.dart` bütün parçaları `lib/l10n/app_tr.arb` içine birleştirir.
3. `flutter gen-l10n` `AppLocalizations` sınıfını üretir (`lib/l10n/app_localizations*.dart`).
4. Kodda `final l10n = AppLocalizations.of(context);` ile okunur (`nullable-getter: false`: `!` gerekmez).

**`tool/merge_arb.dart` kuralları:**

- Tek `@@locale` kalır (alfabetik ilk parçanınki).
- Aynı anahtar iki parçada geçerse **hata** verir (çıkış kodu 1).
- Eşi olmayan `@anahtar` metadata'sı da hatadır.
- Anahtarlar alfabetik sıralanır; her `@anahtar` kendi anahtarının hemen arkasında kalır.
- Parça adı ile anahtar öneki her zaman aynı değildir (ör. `domain_tr.arb` içinde `exams_*`, `lessons_*`). Önek özelliği gösterir; dosya adı yalnız gruplama içindir.

**Adlandırma ve içerik** (AGENTS "UI rules"): anahtarlar `<feature>_<camelCase>`; ortak metinler `common_*`; yalnız ekran okuyucuya giden metinler `…A11y` ile biter. Her anahtarın `@anahtar` altında İngilizce bir `description` alanı vardır; yer tutucu varsa türü yazılır:

```json
"examDetail_questionCorrectNoMarkA11y": "Soru {number}, doğru",
"@examDetail_questionCorrectNoMarkA11y": {
  "description": "Question cell reading, right answer when the data does not say which option was marked …",
  "placeholders": { "number": { "type": "int" } }
}
```

**Metin kuralları:** "Vazgeç" (asla "İptal"), "Tamam", "Kapat" (yalnız a11y), "Geri Al" (yalnız toast); "sen" tonu; emoji yok; tamamı büyük harf yok. Sayı ve tarih yalnız `TrFormat` ile (`lib/core/utils/tr_format.dart`). Büyük/küçük harf için `TurkishText` (`lib/core/utils/turkish_text.dart`); Türkçe metinde `toUpperCase()` kullanılmaz. Yeni bir "Vazgeç" anahtarı açmayın: `common_cancel` vardır.

**Saf mantık l10n'den bağımsız tutulur:** testin içine `AppLocalizations` çekmemek için mantık tipleri (örn. `DeltaDirection`) ayrı dosyadadır. Metin gerektiren saf mantıkta testler `AppLocalizationsTr()` ile doğrudan örnekleme yapabilir.

---

## 4. Analiz ve kural denetimi

### 4.1 `analysis_options.yaml`

`flutter_lints` (`package:flutter_lints/flutter.yaml`) artı beş ek kural:

```yaml
linter:
  rules:
    prefer_const_literals_to_create_immutables: true
    avoid_print: true
    prefer_const_constructors: true
    prefer_const_declarations: true
    use_decorated_box: true
```

- `dead_null_aware_expression: ignore`: Dart 3.10 dil sürümünden beri analyzer aynı ölü `??` işlenenini iki kez bildiriyor; `dead_code` açık kalır.
- Analizden hariç: `*.g.dart`, `*.gr.dart`, `*.mapper.dart`, `*.init.dart`, `**/generated/**`, `lib/gen/**`, `lib/l10n/app_localizations*.dart`, `lib/vendor/**`.
- Klasör başına `analysis_options.yaml` yoktur; strict profil köktedir.
- `flutter analyze` CI'da **bilgi düzeyi dahil her sorunda** kırmızı olur. Hedef sıfır sorundur; şu an sıfırdır.
- Kodda `// ignore:` kullanımı çok azdır: `depend_on_referenced_packages` (çoğunlukla testlerde, geçişli bağımlılık importları için), bir yerde `one_member_abstracts`.

### 4.2 `tool/ui_rules.sh`

CI'da `flutter analyze`'dan sonra çalışır. Repo kökünden: `tool/ui_rules.sh`. `.dart` dosyalarını `grep` ile tarar; `.gr.dart` ve satır başı `//` yorumları atlanır. Çıkış kodu 0 ise temizdir; sorun varsa `::error::` başlıklı satırlar ve dosya:satır listesi basar.

**Yasak kalıplar** (`lib/features`, `lib/shared`, `lib/app` altında):

| Kalıp | Yerine |
|---|---|
| `Color(0x…` | `context.appColors` |
| `Colors.*` | `context.appColors` |
| `TextStyle(` | `context.appText` + `copyWith` |
| `fontSize:` | `context.appText` stili |
| `Icons.*`, `CupertinoIcons.*` | `phosphor_flutter` |
| `showDialog`, `AlertDialog`, `showModalBottomSheet`, `SnackBar(` | `AppSheet` / `ToastService` |
| `MaterialPageRoute`, `Navigator.push` | auto_route |
| `print(` | `AppLogger` |
| `Widget _build…` | `Widget _buildX()` yardımcıları yerine widget sınıfı |

**Yalnız sunum klasörlerinde** (`lib/features/*/presentation`, `lib/shared/ui`): ham `Duration(`: `AppMotion` / `SmapDurations` kullanın.

**Dosya boyu sınırları** (satır; üretilmiş kod ve `/debug/` galerileri sayılmaz):

| Dosya | Sınır |
|---|---|
| ekranın `*_view.dart` dosyası (`presentation/` altında) | 250 |
| `part of` dosyası | 300 |
| `*_viewmodel.dart` (`lib/` genelinde) | 500 |
| diğer sunum ve `shared/ui` dosyaları | 400 |

Betiğin kapsamadıkları (kod incelemesinde kontrol edilir): `lib/core` taranmaz; AGENTS'in yasakladığı "`Text` içinde string literal" ve `SharedPreferences.getInstance` için denetim yoktur. Satır başı olmayan sonda `// …` yorumu atlanmaz. **Betiğin yeşil olması kuralın tamamının geçtiği anlamına gelmez.**

### 4.3 `tool/unreachable_files.dart`

```bash
dart run tool/unreachable_files.dart
```

`lib/main.dart` ve `lib/main_gallery.dart`'tan başlayıp `import` / `export` / `part` zincirini izler ve hiçbir giriş noktasından erişilemeyen `lib/` dosyalarını listeler (üretilmiş kod ve `lib/vendor` hariç). Çıkış kodu her zaman 0'dır; çıktı listedir. Şu an çıktısı: "Every lib/ file is reachable from lib/main.dart, lib/main_gallery.dart."

- Koşullu import'ları çözmez.
- Listeyi silme **kararı değil, adayıdır**: silmeden önce yolu `test/` içinde ve `grep` ile arayın. AGENTS kuralı: çalışan bir özelliği silmeyin; yalnız ölü, erişilemeyen, mock ya da "yakında" kodu, grep kanıtıyla silinir.

---

## 5. CI

`.github/workflows/ci.yml`:

- **Tetikleyiciler:** `pull_request`, `main` ve `redesign/main` push'ları, `workflow_dispatch`. `docs/**` ve `**/*.md` değişiklikleri CI'yı tetiklemez. PR'larda aynı PR'ın eski çalıştırması iptal edilir.
- İzin yalnız `contents: read`; koşucu `ubuntu-24.04`; süre sınırı 20 dakika. Tek iş: "Flutter (l10n, codegen, analyze, test)". iOS/Android derlemesi CI'da **yoktur**.
- **Adımlar, sırayla:**
  1. `subosito/flutter-action@v2` ile Flutter `FLUTTER_VERSION`; pub önbelleği `pubspec.lock` hash'ine bağlı.
  2. `flutter pub get --enforce-lockfile`: lock dosyası pubspec ile uyumsuzsa kırılır.
  3. **l10n güncel mi:** `dart run tool/merge_arb.dart`, `flutter gen-l10n`; `git status --porcelain lib/l10n` boş değilse hata.
  4. **codegen güncel mi:** `dart run build_runner build --delete-conflicting-outputs`; `git status --porcelain` (**tüm çalışma ağacı**) boş değilse hata.
  5. `flutter analyze --no-pub`
  6. `tool/ui_rules.sh`
  7. `flutter test --no-pub`

Yerelde **aynı sırayı** çalıştırın ([12](#12-komut-kopya-kâğıdı)'deki "CI ile aynı sıra" bloğu). Adım 4 yalnız üretilmiş dosyalara değil tüm ağaca baktığı için, commit edilmemiş ya da `.gitignore`'a girmemiş herhangi bir dosya da CI'yı kırar. Hedef Flutter sürümü değiştiğinde (bkz. 1.1) bu dosyadaki `FLUTTER_VERSION` ilk güncellenen yerdir.

---

## 6. Testler

- **Yapı:** `test/` ağacı `lib/` ile aynalıdır: `test/app`, `test/core`, `test/dependency_injection`, `test/features/<f>/{application,data,domain,presentation}`, `test/services`, `test/shared/ui`. Yaklaşık 227 `*_test.dart` dosyası, 3.400'den fazla test; tam koşu bu makinede yaklaşık 2 dakika sürdü ve geçti.
- **Ne test edilir:** ViewModel, servis, repository, saf mantık, DTO eşlemesi, router. Sıra: önce veri + ViewModel testi, sonra görünüm (AGENTS "Definition of done").
- **Golden testi yazılmaz; widget testi yalnız ölçü ya da ekran okuyucu cümlesi için** (AGENTS "Definition of done"). Görünüm galeride ([7.1](#71-bileşen-galerisi)) ve simülatörde panoyla yan yana kontrol edilir; saf mantığı `application/` altına alıp orada test edin. Örnek ölçü testi: `test/features/exams/presentation/exam_score_card_height_test.dart` (puan kartı iskeletle aynı boyda, 163 pt). Böyle bir test kartı bir kaydırma görünümünün içine koyar (ekrandaki gibi), `SmapTheme.light()` ve `AppLocalizations` delegelerini verir.
- Testler `flutter test` ile Dart VM üstünde çalışır, cihaz gerekmez. Platform bağlantısı gereken testler `TestWidgetsFlutterBinding.ensureInitialized()` çağırır.
- **Mock kütüphanesi yok.** Her şey elle yazılmış sahtelerle yapılır; adlandırma kalıpları:
  - `*_harness.dart`: bir ekranın ya da servisin bağımlılıklarını toplayan yardımcı (`test/services/session_harness.dart`, `test/features/lessons/presentation/lessons_harness.dart`, `test/features/exams/presentation/exam_detail_harness.dart`).
  - `*_fakes.dart`, `fake_*.dart`: tek bir arayüzün sahtesi (`test/core/services/fake_connectivity.dart`, `test/features/scan/scan_fakes.dart`).
  - `Recording*`: çağrıları kaydeden navigator/eylem sahteleri (`RecordingNavigator`, `RecordingExamNavigator`).
- **Ağ:** `test/core/network/fake_adapter.dart` Dio'nun `HttpClientAdapter`'ını betikli taklit eder: `FakeAdapter(handler)`, `FakeAdapter.json(body, status: …)`, `FakeAdapter.failing((options) => DioException(…))`; yapılan istekler `requests` / `last` ile okunur.
- **Oturum:** `SessionHarness` (`test/services/session_harness.dart`) `SessionManager`'ı sahte backend, çerez kavanozu, sahte güvenli depo ve sahte bağlantıyla kurar; `dispose()` ile kapatılır.
- **Tipik ViewModel testi** (`test/features/auth/presentation/login/login_viewmodel_test.dart`): `setUp` içinde `SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty()`, sonra `SessionHarness()`, `AppRouter(session: () => harness.manager.state, preferences: await DevicePreferences.load())`, ardından ViewModel; `tearDown` içinde `viewModel.dispose()` ve `harness.dispose()`. Beklentiler `harness.backend.calls('/student/login')` gibi kaydedilen çağrılar üzerindendir.
- **`AppConfig`:** saf çözücü `AppConfig.resolve(...)` sayesinde `--dart-define` olmadan test edilir (`test/core/config/app_config_test.dart`).
- **DI bütünlüğü:** `test/dependency_injection/injection_container_test.dart` kayıtları sınar. Yeni kök servis eklenirse bu test de güncellenir.
- `shared_preferences_platform_interface` testlerde doğrudan import edilir (pubspec'te yok, geçişli bağımlılık); bu yüzden o satırların başında `// ignore: depend_on_referenced_packages` bulunur.
- **Saat dilimi:** CI UTC çalışır, geliştirici makinesi değil. Tarih içeren beklentiyi sabit bir saat dilimi varsayarak yazmayın.

---

## 7. Çalıştırma, galeri ve debug tanımları

### 7.1 Bileşen galerisi

```bash
flutter run -t lib/main_gallery.dart
```

Router'sız, oturumsuz, DI'sız bir `MaterialApp`: `SmapTheme.light()` / `.dark()`, yerel ayar `tr`. 13 sekme vardır (`lib/features/debug/gallery_registry.dart`). Üstteki üç anahtar: koyu tema, metin ölçeği 1,35, hareketi azalt. Yeni sekme: `lib/features/debug/pages/xxx_gallery.dart` dosyası + `galleryPages` listesine bir satır (listeyi koordinatör bağlar). Eksik bir paylaşılan bileşen `lib/shared/ui`'ya **ve aynı görevde** galeri sayfasına eklenir. Yeni bileşeni galeride koyu tema + büyük metin + "hareketi azalt" ile gezin.

### 7.2 Uygulamayı çalıştırmak

```bash
flutter run                                          # üretim backend'ine bakan varsayılanlar
flutter run --dart-define-from-file=config/dev.json  # yerel yapılandırma dosyası ile
```

`config/dev.json.example` kopyalanıp `config/dev.json` yapılır; `config/dev.json` `.gitignore`'dadır. Örnek içerik:

```json
{
  "API_BASE_URL": "https://www.smaptr.com",
  "OMR_BASE_URL": "https://www.smaptr.com",
  "CDN_BASE_URL": "https://smaptr.com.tr",
  "SUPPORT_EMAIL": "",
  "YKS_DATE": "2027-06-19",
  "APP_STORE_ID": "",
  "PLAY_PACKAGE": "com.studentmap.smap"
}
```

### 7.3 `AppConfig` kuralları (`lib/core/config/app_config.dart`)

- Tüm anahtarlar isteğe bağlıdır. Boş ya da eksik değer, uygulamanın bugün konuştuğu üretim değerine düşer; düz `flutter run` çalışır.
- **Biçimi bozuk değer** (şemasız URL, ISO olmayan tarih, geçersiz e-posta) debug'da `assert` ile patlar; release'te varsayılan kullanılır, çökmez.
- URL'lerin sonundaki `/` kırpılır.
- **Gizli bilgi buraya konmaz:** define değerleri yayınlanan ikilide okunabilir.

### 7.4 `--dart-define` ve çalışma zamanı değişkenleri

İki mekanizma vardır:

- **Derleme zamanı:** `--dart-define=ADI=değer` ya da `--dart-define-from-file=…`.
- **Çalışma zamanı:** `debugLaunchEnv(name)` (`lib/features/debug/launch_env.dart`) önce işlem ortamına (`SIMCTL_CHILD_<ADI>=… xcrun simctl launch …`), yoksa uygulamanın geçici dizinindeki `launch_env/<ADI>` dosyasına bakar. Yeniden derlemeden ekran görüntüsü almak içindir; yalnız debug araçlarında kullanılır.

| Anahtar | Okunduğu yer | Mekanizma | Ne yapar |
|---|---|---|---|
| `API_BASE_URL` | `AppConfig` | derleme | Backend kök adresi. Varsayılan `https://www.smaptr.com` |
| `OMR_BASE_URL` | `AppConfig` | derleme | Optik okuma sunucusu. Boşsa `API_BASE_URL`'e düşer (gerçek OMR sunucusu backend'de açık soru) |
| `CDN_BASE_URL` | `AppConfig` | derleme | Yüklenen görsellerin adresi. Varsayılan `https://smaptr.com.tr` |
| `SUPPORT_EMAIL` | `AppConfig` | derleme | Destek e-postası. Boşsa "Bize Yaz" satırı gizlenir, adres uydurulmaz |
| `YKS_DATE` | `AppConfig` | derleme | ISO-8601 gün. Varsayılan `2027-06-19` (örnek tarih) |
| `APP_STORE_ID` | `AppConfig` | derleme | Sayısal App Store kimliği. Boşsa mağaza bağlantısı gizlenir |
| `PLAY_PACKAGE` | `AppConfig` | derleme | Varsayılan `com.studentmap.smap` |
| `THEME_MODE` | `AppThemeMode` | derleme | `dark` / `light` / `system`. **Yalnız debug'da** işler |
| `SHELL_PREVIEW` | `ShellPreview` | derleme | `student` ya da `coach`: hesapsız kabuğu açar. Yalnız `kDebugMode` |
| `SHELL_PREVIEW_TAB` | `ShellPreview` | **yalnız çalışma zamanı** | 0–3 arası açılış sekmesi |
| `SCAN_GALLERY` | `ScanDebug` | derleme | `true`: simülatörde galeriden resim seçerek okut akışı. Yalnız debug |
| `GALLERY_DARK`, `GALLERY_LARGE_TEXT`, `GALLERY_REDUCE_MOTION` | `GallerySettings` | derleme veya çalışma zamanı | Galeri başlangıç anahtarları (`true`) |
| `GALLERY_PAGE` | `ComponentGalleryView` | derleme veya çalışma zamanı | Başlangıç sekmesi (0'dan) |
| `GALLERY_SEMANTICS`, `GALLERY_ACTION`, `GALLERY_SCROLL` | galeri | **yalnız çalışma zamanı** | Semantik katman, sheet/durum sayfalarında otomatik eylem, kaydırma ofseti |

Debug kalıpları hem `kDebugMode` hem tanım koşuluna bağlıdır; release derlemede `THEME_MODE`, `SHELL_PREVIEW` ve `SCAN_GALLERY` etkisizdir (`ScanDebug.galleryEnabled` bir `const` ve `kDebugMode && _define`). Yine de release komutuna bunları vermeyin.

Ek özellik bayrakları `lib/core/config/feature_flags.dart` içindedir (derleme zamanı sabitleri; kapalı bir özellik route listesine girmez ve giriş noktaları çizilmez). Hangi bayrağın hangi backend ucunu beklediği o dosyanın doc yorumlarında yazar; özellik düzeyindeki anlatım için [06_ozellikler.md](06_ozellikler.md).

### 7.5 VS Code yapılandırmaları (`.vscode/`)

Her iki dosya CI ile aynı komutları kullanır ve güncel tutulur.

- `launch.json`: "SMAP", "SMAP (config/dev.json)", öğrenci ve koç önizlemesi (`SHELL_PREVIEW`), koyu tema (`THEME_MODE=dark`), okutma galeriden (`SCAN_GALLERY=true`), "Bileşen galerisi" (`lib/main_gallery.dart`), profile ve release modları.
- `tasks.json`: "Codegen: build_runner", "Codegen: build_runner watch", "l10n: merge ARB + gen-l10n", "Check: format + analyze + UI rules", "Test", "Unreachable files", "iOS: pod install", "Brand: launcher icons + splash", "Flutter clean".

---

## 8. Platform yapılandırması

### 8.1 Uygulama kimliği ve imza

- **Android:** `namespace` ve `applicationId` = `com.studentmap.smap` (`android/app/build.gradle.kts`), `minSdk = 24`. Kotlin paketi `com.studentmap.smap` (`android/app/src/main/kotlin/com/studentmap/smap/MainActivity.kt`; haptik kanalı `smap/haptics` burada).
- **iOS:** `PRODUCT_BUNDLE_IDENTIFIER = com.studentmap.smap`, test hedefi `com.studentmap.smap.RunnerTests`; `CODE_SIGN_STYLE = Automatic`; `DEVELOPMENT_TEAM` Xcode projesinde (`ios/Runner.xcodeproj/project.pbxproj`) kayıtlıdır (değer bu belgeye yazılmadı). Kimlik, sahibin Ekim 2026'da eski uygulamayla mağazaya çıkardığı kimliktir; değiştirilmez.
- **Android release imzası:** `android/key.properties` (`keyAlias`, `keyPassword`, `storeFile`, `storePassword`) ve yükleme anahtarı varsa release derlemesi onunla imzalanır; ikisi de git'te değildir (`android/.gitignore`), sahibinde durur. Dosya yoksa release derlemesi debug anahtarıyla imzalanır (`flutter run --release` çalışsın diye); böyle bir `.aab`/`.apk` mağazaya yüklenemez.
- **Flavor yok:** `productFlavors` tanımlı değil; Xcode'da yalnız `Runner` şeması var. Ortam farkı `--dart-define` ile yönetilir.
- Sürüm: `pubspec.yaml` → `version: 1.0.0+3`. `1.0.0` Android `versionName` / iOS `CFBundleShortVersionString`, `+3` Android `versionCode` / iOS `CFBundleVersion` olur (`--build-name`, `--build-number` ile geçersiz kılınabilir). Eski uygulama aynı kimlikle `+1` ve `+2` yükledi; her yükleme mağazadaki son numaradan büyük olmalı.
- Kimlik, imza ve sürüm kararları sahibindedir: [14. Yayın öncesi kontrol listesi](#14-yayın-öncesi-kontrol-listesi).

### 8.2 Android ve iOS ayrıntıları

**Android** (`android/app/src/main/AndroidManifest.xml`, `android/app/build.gradle.kts`)

- İzinler: `INTERNET`, `CAMERA` (açıkça). `RECORD_AUDIO` **`tools:node="remove"`** ile çıkarılır: `camera` eklentisi birleşik manifest'e mikrofon izni getirir, ama kod kamerayı sessiz açıyor (`lib/features/scan/data/scan_camera.dart`, `enableAudio: false`); çıkarılmazsa mağaza beyanında gereksiz mikrofon izni görünür. Bu satırı ve manifest köküne `xmlns:tools` bildirimini silmeyin.
- `POST_NOTIFICATIONS` manifest'te **yok**. `FeatureFlags.notificationsEnabled = false` iken sorun yoktur; bildirimler açılırken eklenmesi gerekir (Android 13+). Cihazda doğrulanmadı.
- `compileSdk` (36), `targetSdk` (36), `minSdk` (24) ve `ndkVersion` Flutter 3.38.6'nın varsayılanlarıdır (`flutter.*`); Flutter yükseltmesi bunları da değiştirir.
- Java/Kotlin hedefi 11. Araçlar: AGP 8.9.1, Kotlin 2.1.0 (`settings.gradle.kts`), Gradle 8.12 (`gradle-wrapper.properties`).
- `MainActivity.kt` içinde `smap/haptics` kanalı vardır (iOS karşılığı `AppDelegate.swift`); `AppHaptics.success/error` buradan geçer (Flutter'ın `HapticFeedback`'inde başarı/hata yok).
- Uygulama adı `SMAP` (`android:label`). Bildirim küçük simgesi (`ic_stat_smap`) `res/drawable-*` altında hazırdır; manifest'te varsayılan bildirim ikonu tanımı yoktur (bildirimler kapalı).
- `android/.gitignore` `key.properties`, `*.keystore`, `*.jks`, `local.properties` dosyalarını dışlar.

**iOS** (`ios/Runner/Info.plist`, `ios/Podfile`)

- İzin metinleri (Türkçe): `NSCameraUsageDescription` ("Deneme optiğini okutmak için kameranı kullanıyoruz.") ve `NSPhotoLibraryUsageDescription` ("Optik form fotoğrafını galeriden seçebilmen için."). Bildirim için `Info.plist` anahtarı gerekmez.
- `permission_handler` yalnız açılan izinlerin kodunu derler (kullanılmayan izin kodu taşıyan ikili App Store incelemesinde reddedilebilir). `ios/Podfile`:

```ruby
PERMISSION_MACROS = [
  'PERMISSION_CAMERA=1',
  'PERMISSION_PHOTOS=1',
  'PERMISSION_NOTIFICATIONS=1',
].freeze
```

  Bir izin eklerken **üç yeri birden** güncelleyin: `Podfile` makrosu, `Info.plist` açıklaması, Dart kodu. Makro olmadan `permission_handler` iOS'ta sessizce `denied` döner.
- Kodda `permission_handler` kamera (`lib/features/onboarding/data/camera_permission_gateway.dart`) ve bildirim (`lib/features/account/data/notification_permission_gateway.dart`, bildirim ön izin ekranı) için çağrılır. `PERMISSION_PHOTOS` ve foto kütüphanesi metni yalnız galeriden seçme (`image_picker`, debug amaçlı `SCAN_GALLERY`) içindir; ürün galeri sunmaz (spec D-15). Bu ikisinin yayında gerekip gerekmediği açık sorudur ([14](#14-yayın-öncesi-kontrol-listesi)).
- iOS dağıtım hedefi 13.0 (`IPHONEOS_DEPLOYMENT_TARGET`); Podfile'da `platform` satırı yorumlu. `Podfile.lock` takiptedir (CocoaPods 1.16.2), `Pods/` takip edilmez.
- Uygulama adı `SMAP` (`CFBundleDisplayName`).
- `Info.plist` iPhone'da yatay yönelişlere de izin verir. Kodda yön kilidi yalnız Okut akışındadır (`scan_flow_view.dart`: `portraitUp`, çıkışta `DeviceOrientation.values`); genel kilit yoktur.

### 8.3 İkon ve açılış

- **İkon:** `pubspec.yaml` → `flutter_launcher_icons:` bloğu. Kaynaklar `assets/brand/icon/` altında (`app_icon.png`, `app_icon_dark.png`, `app_icon_tinted.png`, `adaptive_background.png`, `adaptive_foreground.png`; SVG karşılıkları yanında). iOS açık/koyu/tonlu varyant, Android adaptif katman; `remove_alpha_ios: true`; `adaptive_icon_foreground_inset: 0` (ön plan zaten 108 dp ızgarasına oturtulmuş). Yeniden üretmek için `dart run flutter_launcher_icons`.
- **Açılış:** `flutter_native_splash:` bloğu. Lacivert `#0F294A`, `assets/splash/smap_splash.png`, Android 12 için `smap_splash_android12.png`. Yeniden üretmek için `dart run flutter_native_splash:create`. Görsel `AppLockup(vertical, onNavy)` ile aynı olmalıdır ki geçişte dikiş görünmesin.
- `assets/brand/icon/` ve `assets/splash/` pubspec'te asset olarak **bağlı değildir** (`assets/brand/` özyinelemeli değil); yalnız üretim kaynağıdır, pakete girmez.
- İkon/açılış üretimi `ios/` ve `android/res` altındaki dosyaları yeniden yazar: üretip diff'i commit edin.

---

## 9. Asset yapısı

- `pubspec.yaml` içinde `assets:` altında klasörler **tek tek** sayılır: `assets/` (kök), `assets/icons/`, `assets/svgs/`, `assets/menuIcons/`, `assets/avatars/`, `assets/authors/` ve alt klasörleri, `assets/brand/`, `assets/illustrations/`. Flutter'da klasör girdisi **özyinelemeli değildir**: yalnız o klasörün doğrudan dosyalarını paketler; bu yüzden `assets/authors/` altındaki her alt klasör ayrı yazılıdır. Yeni bir alt klasör açtığınızda pubspec'e **o klasörü ayrıca** ekletin (koordinatör dosyası).
- `assets/tutorial/` ve `assets/splash/` listelenmediği için pakete girmez.
- **Yazı tipi:** `PlusJakartaSans` (400, 500, 600, 700, 800), `assets/fonts/plus_jakarta_sans/`.
- **İllüstrasyonlar:** `assets/illustrations/clay/*.png` (pano 1.25'in 11 kil görseli, 1x 140 px; 2x/3x asıllar gelince `clay/2.0x/` ve `clay/3.0x/` altına aynı adlarla; bkz. `AppClay`). Marka: `assets/brand/*.svg` (`AppLogo`/`AppLockup` bunları kullanır).
- **Avatarlar:** `assets/avatars/` (dosya adları `avatar_catalog.dart`, `avatar_asset.dart`, `student_avatars.dart` içinde string yol olarak da geçer).
- **Yazar fotoğrafları:** `assets/authors/<klasör>/…`; backend yazarın `/authors/a/namikkemal.png` gibi bir yolunu verir, uygulama bunu `assets` önekiyle yükler (`lib/features/lessons/presentation/widgets/author_row.dart`). Dosya pakette yoksa baş harfler çizilir. Not: diskte `assets/authors/cpm/` klasörü var ama pubspec'te **listelenmemiş**; o klasörün fotoğrafları pakete girmiyor (bilinçli mi, açık soru; bkz. [14](#14-yayın-öncesi-kontrol-listesi)).
- `flutter_gen` çıktısı `lib/gen/assets.gen.dart` ve `lib/gen/fonts.gen.dart`'tır; `flutter_gen: integrations: flutter_svg: true` açıktır (`.svg(...)`). Dart tarafında `Assets.*` yalnız `avatars`, `brand` ve `illustrations` için kullanılır.
- **Boyut:** `assets/` yaklaşık 68 MB; `authors` 38 MB, `avatars` 10 MB, `menuIcons` 4,6 MB. `assets/` **kök** dizininde eski uygulamadan kalma dosyalar da vardır (`logo*.png`, `ob1–6.png`, `optic1–4.png`, `llg*.png`, `ikonlar.zip` vb., toplam yaklaşık 14 MB). `assets/` girdisi kökteki dosyaları paketlediği için bunların hepsi pakete girer. `lib/` içinde bunlara ait string ya da `Assets.*` kullanımı **bulunamadı**; `assets/icons`, `assets/svgs` ve `assets/menuIcons` için de Dart'ta `Assets.*` kullanımı yok (string yol aramasıyla da kanıt çıkmadı). Silme adayları, ama silmeden önce `tool/unreachable_files.dart` (yalnız `.dart` dosyalarına bakar, asset'e bakmaz) yerine `grep` kanıtı gerekir; kaldırma listesi `docs/spec/SMAP_Flutter_Spec.md`'de ("Kaldırılacak varlıklar") yazılıdır. Yazar fotoğrafları **kalır**.
- Yeni asset'i kökte bırakmayın: kendi alt klasörüne koyun.

---

## 10. Tasarım dışa aktarım araçları

Tasarım panoları `docs/design/` altındadır (klasör düzeni ve öncelik sırası için `docs/design/README.md`). Yeni bir tur geldiğinde panolar iki araçtan biriyle üretilir; ikisi de repo kökünden çalışır ve `docs/design/panolar/` altına yazar.

- `tool/design/html_to_boards.py`: Claude Design'ın tek dosyalık HTML dışa aktarımını panolara çevirir. Python 3 (yalnız standart kütüphane) ve **Google Chrome** gerekir (başka yol için `CHROME` ortam değişkeni). Her pano için `panolar/png/SMAP-NN_<pano>.png`, `panolar/SMAP-NN/<pano>/board.html` ve `text.txt` üretir; `--only 14.8` ile tek pano yeniden çizilir. Pano JavaScript'i geçici bir Chrome profilinde çalışır; **yalnız güvendiğiniz (kendi Claude Design) dışa aktarımlarında** kullanın.
- `tool/design/pdf_to_boards.sh`: PDF dışa aktarımı (her sayfa bir pano) için; poppler gerekir (`pdftoppm`, `pdftotext`, `pdfinfo`). Sayfa başına PNG ve `text.txt` üretir. HTML varsa HTML'i tercih edin (ölçüler `board.html`'den okunur).

```bash
# HTML dışa aktarımından panolar (Chrome gerekir)
python3 tool/design/html_to_boards.py docs/design/kaynak/SMAP-15.html
```

```bash
# PDF dışa aktarımından panolar (poppler gerekir)
tool/design/pdf_to_boards.sh docs/design/kaynak/SMAP-15.pdf
```

Çıktı klasörleri git'te takiptedir; yeni tur sonrası `docs/DURUM.md`'ye hangi eski karelerin geçersiz kaldığı yazılır.

---

## 11. Dal, worktree ve simülatör süreci

Görev akışı, roller ve inceleme protokolü [../WORKFLOW.md](../WORKFLOW.md)'dedir; burada yalnız araç ayrıntıları var.

- **Dallar:** entegrasyon dalı `redesign/main`; `main` eski uygulamayı tutar ve geride kalmıştır. Commit'ler Conventional Commits biçiminde (Türkçe özet; `feat(scan): …`, `fix(a11y): …`). Ajan push etmez; birleştirmeyi koordinatör yapar.
- **Görev worktree'si:** `tool/wt.sh <görev-kimliği> [taban-dal]` repo yanında `../smapFlutter-wt/<görev-kimliği>` dizinini ve `task/<görev-kimliği>` dalını açar. Taban sırayla ikinci argüman, `WT_BASE` ortam değişkeni, `redesign/main`'dir. Dizin zaten varsa yeniden kullanır ve yolunu basar. Yeni worktree'de ilk iş `flutter pub get` ve codegen/l10n çalıştırmaktır ([13](#13-yeni-geliştirici-ilk-gün)); `build/`, `.dart_tool/` ve `ios/Pods/` worktree'ye özeldir ve repoda yoktur.
- **Simülatör kuralı:** geçici test simülatörleri **iOS 26.x** ile (ör. iPhone 17 Pro · iOS 26.2) açılır. İş bitince **hem simülatör silinir hem o worktree'nin Xcode DerivedData klasörü** silinir; aksi hâlde disk dolar (DerivedData onlarca GB'a çıkabilir). Worktree'yi kaldırmadan önce `build/` klasörünü de temizleyin.

```bash
# Kullanılabilir iOS 26 çalışma zamanlarını gör
xcrun simctl list runtimes
```

```bash
# Göreve özel geçici simülatör aç (UDID'yi değişkene al) ve başlat
udid=$(xcrun simctl create "smap-<görev>" com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro com.apple.CoreSimulator.SimRuntime.iOS-26-2)
xcrun simctl boot "$udid"
```

```bash
# İş bitince: simülatörü kapat ve sil
xcrun simctl shutdown "$udid"
xcrun simctl delete "$udid"
```

```bash
# Bu worktree'nin DerivedData klasörünü bul (WorkspacePath eşleşmesi), kontrol edip sil
for d in "$HOME"/Library/Developer/Xcode/DerivedData/Runner-*; do
  [ -f "$d/info.plist" ] || continue
  [ "$(/usr/libexec/PlistBuddy -c 'Print :WorkspacePath' "$d/info.plist")" = "$PWD/ios/Runner.xcworkspace" ] && echo "$d"
done
# Çıkan yolu inceledikten sonra: rm -rf <yol>
```

---

## 12. Komut kopya kâğıdı

Aksi belirtilmedikçe repo kökünden çalıştırın.

```bash
# Sürüm kontrolü: Flutter 3.38.6 / Dart 3.10.7 olmalı (ci.yml FLUTTER_VERSION ile aynı)
flutter --version
```

```bash
# Bağımlılıklar: CI ile aynı (lock dosyası pubspec ile uyumsuzsa kırılır)
flutter pub get --enforce-lockfile
```

```bash
# Yerel yapılandırma dosyası (isteğe bağlı; git'te yok)
cp config/dev.json.example config/dev.json
```

```bash
# Kod üretimi: auto_route, dart_mappable, flutter_gen
dart run build_runner build -d
```

```bash
# Kod üretimi, geliştirirken sürekli
dart run build_runner watch -d
```

```bash
# l10n: önce parçaları birleştir, sonra sınıfları üret (sıra önemli)
dart run tool/merge_arb.dart && flutter gen-l10n
```

```bash
# Biçimlendirme
dart format .
```

```bash
# Analiz: sıfır sorun hedefi (bilgi düzeyi dahil)
flutter analyze
```

```bash
# UI kuralları: yasak API'ler, dosya boyu sınırları
tool/ui_rules.sh
```

```bash
# Erişilemeyen dosya adayları (silmeden önce test/ ve grep ile doğrula)
dart run tool/unreachable_files.dart
```

```bash
# CI ile aynı sıra (yerelde son kontrol)
flutter pub get --enforce-lockfile \
  && dart run tool/merge_arb.dart && flutter gen-l10n \
  && dart run build_runner build --delete-conflicting-outputs \
  && git status --short \
  && flutter analyze --no-pub \
  && tool/ui_rules.sh \
  && flutter test --no-pub
# git status çıktısı boş olmalı (commit edilmemiş üretilmiş dosya = CI'da kırmızı)
```

```bash
# Tüm testler (yaklaşık 2 dakika)
flutter test
```

```bash
# Tek test dosyası
flutter test test/features/auth/presentation/login/login_viewmodel_test.dart
```

```bash
# Sadece hataları göster (uzun koşuda gürültüyü azaltır)
flutter test --reporter=failures-only
```

```bash
# Bileşen galerisi
flutter run -t lib/main_gallery.dart
```

```bash
# Galeri: koyu tema, dördüncü sekme
flutter run -t lib/main_gallery.dart --dart-define=GALLERY_DARK=true --dart-define=GALLERY_PAGE=3
```

```bash
# Uygulama: yerel yapılandırma ile
flutter run --dart-define-from-file=config/dev.json
```

```bash
# Hesapsız öğrenci kabuğu, koyu tema (yalnız debug)
flutter run --dart-define=SHELL_PREVIEW=student --dart-define=THEME_MODE=dark
```

```bash
# Hesapsız koç kabuğu (yalnız debug)
flutter run --dart-define=SHELL_PREVIEW=coach
```

```bash
# Simülatörde Okut akışı (galeriden resim seçerek; yalnız debug)
flutter run --dart-define=SCAN_GALLERY=true
```

```bash
# Yeniden derlemeden başka sekmede aç (simülatörde çalışma zamanı değişkeni)
SIMCTL_CHILD_SHELL_PREVIEW_TAB=2 xcrun simctl launch booted com.studentmap.smap
```

```bash
# İkon ve açılış görsellerini yeniden üret (ios/ ve android/res değişir)
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

```bash
# iOS pod'ları (pubspec/eklenti değişince)
cd ios && pod install
```

```bash
# Görev worktree'si aç (taban: redesign/main; ikinci argüman başka taban verir)
tool/wt.sh <görev-kimliği>
```

```bash
# Tasarım dışa aktarımı: HTML (Chrome) ve PDF (poppler)
python3 tool/design/html_to_boards.py docs/design/kaynak/SMAP-NN.html
tool/design/pdf_to_boards.sh docs/design/kaynak/SMAP-NN.pdf
```

```bash
# Yayın derlemesi (flavor yok; imza ve define değerleri sahibin kararına bağlı, bkz. 14)
flutter build appbundle --release --dart-define-from-file=<yayın-define-dosyası>
flutter build ipa --release --dart-define-from-file=<yayın-define-dosyası>
```

Yayın komutlarındaki `--dart-define-from-file` biçimi `AppConfig` yorumlarından türetilmiştir. Repoda release betiği ya da CI derleme adımı yoktur; komutlar bu repoda uçtan uca denenmemiştir.

---

## 13. Yeni geliştirici ilk gün

1. **Klonla.** Depoyu klonlayın ve çalışma dalına geçin: `git clone <depo-adresi> && cd smapFlutter && git switch redesign/main`. Yeni bir iş için `tool/wt.sh <görev-kimliği>` ile ayrı worktree açın ve komutları o dizinde çalıştırın.
2. **Sürüm.** Flutter 3.38.6'yı kurun (puro, FVM ya da elle) ve `flutter --version` ile doğrulayın; `ci.yml` içindeki `FLUTTER_VERSION` ile aynı olmalı. Xcode (iOS için), Android Studio ya da komut satırı SDK'sı (Android için) ve CocoaPods gerekir. `flutter doctor` yeşil olsun.
3. **`pub get`.** `flutter pub get --enforce-lockfile`. Lock uyumsuzluğu hatası alırsanız pubspec'e dokunmayın, koordinatöre sorun.
4. **Codegen.** `dart run build_runner build -d`. Sonuçta `git status` boş kalmalıdır (üretilmiş dosyalar zaten commit'li).
5. **l10n.** `dart run tool/merge_arb.dart && flutter gen-l10n`. `git status` yine boş kalmalıdır. Bu iki adım boş diff veriyorsa üretim hattınız CI ile aynı sonucu veriyor demektir.
6. **Çalıştır.** `flutter run` (simülatör ya da cihaz). Hesabınız yoksa debug'da `--dart-define=SHELL_PREVIEW=student` ya da `coach` ile hesapsız kabuğu açın; içindeki ekranlar boş/hata durumlarını gösterir. Gerçek backend'e bakan bir giriş için bir öğrenci hesabına ihtiyaç vardır (sahibinden isteyin; kimlik bilgilerini repoya yazmayın). Okut akışı gerçek kamera ister; simülatörde `SCAN_GALLERY=true`.
7. **Galeri.** `flutter run -t lib/main_gallery.dart`. Üstten koyu tema ve büyük metni açarak bileşenleri gezin; yeni bileşenler önce burada doğrulanır ([04_tasarim_sistemi.md](04_tasarim_sistemi.md)).
8. **Testler ve denetimler.** `flutter analyze`, `tool/ui_rules.sh`, `flutter test`. Üçü de temiz olmalıdır; tek bir test dosyası için 12'deki komutu kullanın.
9. **Oku.** `../../AGENTS.md` (kurallar), [../WORKFLOW.md](../WORKFLOW.md) (iş akışı), [01_mimari.md](01_mimari.md) (yapı), [03_ekran.md](03_ekran.md) (bir ekran nasıl yazılır). İlk değişikliği küçük tutun ve commit'ten önce 12'deki "CI ile aynı sıra" bloğunu çalıştırın.

---

## 14. Yayın öncesi kontrol listesi

Kararı sahibin vereceği maddeler **AÇIK SORU** olarak işaretlidir; karar gelmeden uygulanmaz. Kimlik bilgisi dosyalarını (`*.jks`, `*.keystore`, `key.properties`, `google-services*.json`, `GoogleService-Info.plist`, `.env*`, `*.p8`, `*adminsdk*.json`) hiçbir ajan açmaz ve değerini yazmaz; kontrol yalnız varlığı ve `.gitignore` durumu üzerindendir. Bu dosyalar repoda şu an **yoktur**; yayın öncesi bunları sahibi (ya da onun görevlendirdiği kişi) sağlar ve repoya koymaz.

- [x] **Uygulama kimliği:** `com.studentmap.smap` (sahibin kararı, eski uygulamada yayında). `AppConfig.defaultPlayPackage` ve `PLAY_PACKAGE` aynı değer.
- [ ] **Android imzası:** yapılandırma hazır (`key.properties` + `signingConfigs.release`). Yükleme anahtarı ve `android/key.properties` sahibinde; yayın derlemesini o yapar ya da CI gizli deposuna koyar. **AÇIK SORU:** Play App Signing kullanılıyor mu?
- [ ] **AÇIK SORU: iOS imzası.** Apple geliştirici ekibi (`DEVELOPMENT_TEAM`) doğru hesaba mı ait? Otomatik imza mı kalacak, elle profil mi? Dağıtım sertifikası ve App Store Connect erişimi kimde?
- [ ] **Sürüm numarası:** `1.0.0+3`. **AÇIK SORU:** mağazadaki son build numarası ve `1.0.0`'ın yayında olup olmadığı (yayındaysa yeni sürüm `1.0.1+N`); `+N` her yüklemede artar.
- [ ] **AÇIK SORU: Yayın define dosyası.** Üretim `--dart-define` değerleri nerede tutulacak? Yalnız `config/dev.json` `.gitignore`'dadır; yayın dosyası (örn. `config/prod.json`) commit edilecekse içinde gizli bilgi olmamalı (define değerleri ikilide okunur).
- [ ] **AÇIK SORU: Backend adresleri.** `API_BASE_URL`, `OMR_BASE_URL`, `CDN_BASE_URL` doğru ortama bakıyor mu? OMR sunucusu hâlâ API ile aynı varsayılıyor (backend'de açık soru).
- [ ] **AÇIK SORU: Destek ve mağaza bağlantıları.** `SUPPORT_EMAIL` ve `APP_STORE_ID` boş; boşken ilgili satırlar gizlenir. Gerçek değerleri sahibi verir. `PLAY_PACKAGE` kimlik kararına bağlı.
- [ ] **AÇIK SORU: Sınav tarihi.** `YKS_DATE` varsayılanı örnek tarih (`2027-06-19`). Gerçek tarihi sahibi onaylar.
- [ ] **İzinler.** Android birleşik manifest'te yalnız `INTERNET` ve `CAMERA` olmalı, `RECORD_AUDIO` bulunmamalı. **AÇIK SORU:** iOS `PERMISSION_PHOTOS` makrosu ve `NSPhotoLibraryUsageDescription`: ürün galeriyi göstermiyor; yayında kalsın mı kaldırılsın mı? **AÇIK SORU:** Bildirim izni (`POST_NOTIFICATIONS`, iOS `PERMISSION_NOTIFICATIONS`) bildirim özelliğiyle birlikte mi açılacak; kod şimdiden izin isteyen bir ön ekran içeriyor.
- [ ] **AÇIK SORU: Yazar fotoğrafı klasörü.** `assets/authors/cpm/` pubspec'te listeli değil; pakete alınacak mı?
- [ ] **AÇIK SORU: Kök asset temizliği.** `assets/` kökündeki eski dosyalar (~14 MB) ve kullanılmayan klasörler yayından önce kaldırılacak mı (grep kanıtıyla, bkz. 9)?
- [ ] **İkon / açılış.** `flutter_launcher_icons` ve `flutter_native_splash` çıktıları güncel mi? iOS ikonun alfa kanalı yok (`remove_alpha_ios: true`); koyu ve tonlu varyantlar `AppIcon.appiconset` içinde olmalı.
- [ ] **Özellik bayrakları.** `lib/core/config/feature_flags.dart` değerleri yayın niyetine uygun mu (forgot password, sosyal giriş, program silme, şifre değiştirme, bildirim, çevrimdışı kuyruk, dikkat listesi kapalı; `omrEnabled` ve `coachProgramWriteEnabled` açık)? Debug tanımları (`SHELL_PREVIEW`, `SCAN_GALLERY`, `THEME_MODE`) release'te etkisizdir ama release komutuna verilmez.
- [ ] **AÇIK SORU: Mağaza materyalleri.** Görseller (`docs/design/brifler/SMAP_Store_Screenshots_Prompt.md`, pano 12.x), açıklama metinleri, gizlilik beyanı (kamera kullanımı, çerez/oturum), yaş derecelendirmesi, iOS gizlilik etiketleri ve Play Veri güvenliği formu. Plan maddesi FIN5 bunlar için açıktır (`docs/DURUM.md`).
- [ ] **Son doğrulama.** CI yeşil (`pub get --enforce-lockfile`, l10n, codegen, analyze, `ui_rules.sh`, test). CI iOS/Android derlemesi yapmadığı için her iki platformda ayrıca bir `flutter build` release derlemesi (gerçek imzayla) ve gerçek cihazda duman testi yapılır.

---

## 15. Tuzaklar

1. **Flutter sürümü CI'dan kayabilir.** `.puro.json` "stable" der, sürümü sabitlemez; kanal yükselince yerel Flutter 3.38.6'dan ayrılır. Yükseltme kendi PR'ında `ci.yml` (`FLUTTER_VERSION`), `pubspec.yaml` ve bu belgeyle birlikte yapılır; `auto_route` sabitlemesi bu yüzden vardır.
2. **`build_runner` ve `auto_route` sabit, `^` yapmayın.** `build_runner` 2.15 `objective_c` build hook'uyla patlar; `auto_route` 11.2.0 Flutter 3.41+ gerektirir. `flutter pub upgrade --major-versions` bu iki satırı bozar.
3. **dart_mappable metot adları yer değiştirdi.** `build.yaml`'da `fromJson`/`toJson` **Map** ile, `fromJsonString`/`toJsonString` **metinle** çalışır; eski kod ve örnekler tersini varsayar.
4. **Üretilmiş dosyaları commit etmeyi unutmayın.** CI `git status --porcelain` ile tüm ağacı denetler: takip edilmeyen herhangi bir dosya da kırar. `lib/l10n/app_tr.arb` elle düzenlenirse bir sonraki `merge_arb` ezer; yalnız `lib/l10n/arb/<ozellik>_tr.arb` düzenlenir.
5. **ARB'de aynı anahtarı iki parçada tanımlamayın**, `@anahtar`'ı anahtarsız bırakmayın: `merge_arb` çıkış kodu 1 ile durur. `common_*` anahtarları varken (örn. `common_cancel`) yenisini açmayın.
6. **`ui_rules.sh` AGENTS'in tamamını kapsamaz.** `Text` içinde string literal ve `SharedPreferences.getInstance` taranmaz, `lib/core` taranmaz, sonda kalan `// …` yorumu atlanmaz. Yeşil çıktı, kuralın geçtiği anlamına gelmez; kod incelemesi sürer.
7. **Dosya boyu sınırı aşılınca davranışı değiştirmeden bölün.** Ekran `_view` ≤ 250, `part` ≤ 300, ViewModel ≤ 500, diğer sunum/kit ≤ 400 satır; aşıldığında `part` ya da `*_parts.dart` dosyasına ayırın. `tool/ui_rules.sh` aşımları CI'da kırmızı yapar.
8. **Görüntüyü widget testiyle doğrulamaya çalışmayın.** Görüntü doğrulaması galeride ve simülatörde yapılır; saf mantığı `application/` altına alıp VM/birim testi yazın. Widget testi yalnız ölçü (ör. iskelet yüksekliği) ya da ekran okuyucu cümlesi için.
9. **Zaman dilimi.** CI UTC çalışır. Tarih içeren beklentiyi makinenizin saat dilimine göre yazmayın.
10. **Mock kütüphanesi eklemeyin.** Sahteleri `*_harness.dart` / `fake_*.dart` kalıbıyla elle yazın. Yeni kök servis eklediğinizde `injection_container_test.dart`'ı güncelleyin.
11. **Ortak dosyalara dokunmayın.** `pubspec.yaml`, `pubspec.lock`, `build.yaml`, `analysis_options.yaml`, `l10n.yaml`, `app_router.dart`, `injection_container.dart`, `gallery_registry.dart` ve platform manifest'leri koordinatöre aittir; ihtiyacı raporda "Koordinatöre notlar" altında yazın.
12. **`RECORD_AUDIO` kaldırma satırını silmeyin.** `camera` eklentisi izni birleşik manifest'e geri getirir; `tools:node="remove"` kalkarsa Play beyanı gerekir.
13. **İzin eklerken üç yer.** `Podfile` makrosu + `Info.plist` metni + Dart kodu; makrosuz iOS'ta izin sessizce `denied` döner, kullanılmayan izin kodu da incelemede reddedilebilir.
14. **Anahtarsız release debug anahtarıyla imzalanır.** `android/key.properties` yoksa `flutter build appbundle --release` çalışır ama çıktı mağazaya yüklenemez; yayın derlemesini anahtarın sahibi yapar.
15. **`assets/` girdisi kökteki her dosyayı paketler.** Yeni asset'i kökte bırakmayın; kendi alt klasörüne koyup pubspec'e **o klasörü ayrıca** yazdırın (alt klasörler özyinelemeli değildir). `assets/brand/icon` ve `assets/splash` bilerek pakette değil.
16. **Silme kuralı.** "Çalışan bir özelliği silme": yalnız ölü, erişilemeyen, mock ya da "yakında" kodu, grep kanıtıyla silinir. `tool/unreachable_files.dart` liste verir, karar vermez; silmeden önce `test/`'te aynı yolu da arayın.
17. **Okut akışında Geri/Kapat dondurma hatası.** `RouterScanNavigator.close` `maybePop` yerine `pop` olmalıdır: her aşama `PopScope` ile Geri'yi tutar, `maybePop` aynı `PopScope`'a yeniden sorup sonsuz döngüye girerek uygulamayı kilitliyordu; regresyon testi var. Aynı `PopScope` + `close()` kalıbını başka akışta kullanırsanız hatırlayın.
18. **Koyu tema ve erişilebilirlik.** Sık düzeltmeler: metin ölçeği 1,3 (galeride 1,35) ile bozulmayan ızgara ve etiketler, kart için tek `Semantics` okuması, 48 dp hedef, `AppStatusView`'in kendi `Material`'ını getirmesi (dış sarmalayıcı koymayın). Yeni bileşeni galeride `GALLERY_DARK`, `GALLERY_LARGE_TEXT`, `GALLERY_REDUCE_MOTION` anahtarlarıyla gezin.
19. **Eski veri göçleri silinmez.** `LegacySessionMigration`, `LegacyOnboardingMigration` ve çerez kavanozu yolu duruyor; `kMirrorLegacyUserData = false`: düz metin `user_data` artık yazılmıyor, göç bir sonraki açılışta siliyor. Bunları "ölü kod" diye silmeyin.
20. **Kimlik dosyalarını açmayın.** Anahtar ve servis dosyaları hiçbir ajanın açmayacağı dosyalardır (AGENTS); sorun gidermede yalnız varlığına ve `.gitignore` durumuna bakın. Repoya hiçbir gizli bilgi, anahtar, parola ya da `.env` koymayın; `--dart-define` değerleri de gizli değildir.
21. **Simülatör ve DerivedData disk doldurur.** Geçici simülatörü ve o worktree'nin DerivedData'sını işiniz bitince silin ([11](#11-dal-worktree-ve-simülatör-süreci)).
22. **Geçmiş belgeler eski yer adları taşıyabilir.** `docs/history/` altındaki eski görev tanımları ve planlar o günkü yolları (`tasarim-html/…`, `unpacked/…`, repo dışı klasörler) anar; bunlar bu repoda yoktur. Geçerli konumlar: tasarım `docs/design/` (bkz. `docs/design/README.md`), kurallar `AGENTS.md`, süreç `docs/WORKFLOW.md`.

---

## 16. İlgili dosyalar

| Dosya | Ne için |
|---|---|
| `pubspec.yaml`, `pubspec.lock` | Bağımlılıklar, sürüm, asset ve font listesi, ikon/açılış/flutter_gen yapılandırması |
| `analysis_options.yaml` | Analiz ve lint kuralları |
| `build.yaml` | build_runner: vendor hariç, dart_mappable çıktı yolu ve metot adları |
| `l10n.yaml`, `lib/l10n/` | l10n yapılandırması, `arb/` parçaları, birleşik `app_tr.arb`, üretilen sınıflar |
| `.github/workflows/ci.yml` | CI adımları ve Flutter sürümü |
| `tool/merge_arb.dart` | ARB parçalarını birleştirir |
| `tool/ui_rules.sh` | Yasak API ve dosya boyu denetimi |
| `tool/unreachable_files.dart` | Erişilemeyen dosya adayları |
| `tool/wt.sh` | Görev worktree'si |
| `tool/design/html_to_boards.py`, `tool/design/pdf_to_boards.sh` | Tasarım dışa aktarımından pano üretimi |
| `.vscode/launch.json`, `.vscode/tasks.json` | Çalıştırma ve görev tanımları |
| `.puro.json` | puro ortam adı (isteğe bağlı) |
| `config/dev.json.example` | Yerel `--dart-define-from-file` örneği |
| `lib/main.dart`, `lib/main_initializer.dart`, `lib/main_gallery.dart` | Uygulama ve galeri giriş noktaları |
| `lib/core/config/app_config.dart`, `lib/core/config/feature_flags.dart` | Derleme zamanı yapılandırması ve özellik bayrakları |
| `lib/features/debug/` | Galeri, `launch_env.dart`, `gallery_registry.dart` |
| `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`, `android/settings.gradle.kts` | Android kimlik, imza, izin, araç sürümleri |
| `ios/Runner.xcodeproj/project.pbxproj`, `ios/Runner/Info.plist`, `ios/Podfile` | iOS kimlik, izin metinleri, izin makroları |
| `test/` (özellikle `test/services/session_harness.dart`, `test/core/network/fake_adapter.dart`) | Test yapısı ve ortak sahteler |
| `../../AGENTS.md` | Repo kuralları (tek kaynak) |
| [../WORKFLOW.md](../WORKFLOW.md), [../DEVELOPING.md](../DEVELOPING.md) | İş akışı; mimari ve tarifler |
| `../DURUM.md`, `../SMAP_Ana_Plan.md` | Görev durumu ve plan kararları (SDK kararı, yayın hazırlığı FIN5) |
| `../design/README.md` | Tasarım panoları düzeni |
