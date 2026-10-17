# SMAP Ana Uygulama Planı — Mimari Hizalama + Tasarım Giydirme

Tarih: 2026-10-11 · Koordinatör: ana oturum (Claude) · Uygulayıcılar: Sonnet 5.5 (high) ajanları
Repo: `.` (git, `main`, remote `AlparslanKuloglu/smapFlutter`)

Bu belge "başla" denince doğrudan uygulanacak plandır. Her görev bir ajana verilecek kadar kendi içinde tamdır. Ayrıntı için aşağıdaki kaynaklara bağlanır, onları tekrar etmez.

---

## 0. Kaynaklar ve öncelik

| Belge | Ne için | Yol |
|---|---|---|
| **Flutter Spec** (tek parça) | Token, 86 bileşen (C01–C86), kabuk/route, ekranlar, backend tablosu, kararlar | `docs/spec/SMAP_Flutter_Spec.md` |
| Spec parçaları | Ajanlara dar bağlam vermek için | `docs/spec/01_tokenlar.md` … `06_kararlar_varsayimlar.md` |
| Ekran akışı | 181 ekranın geçiş grafiği | `docs/spec/00_akis.md` |
| UI Uygulama Rehberi | Ev mimarisi, klasör yapısı, widget bölme kuralları, Sepello sırası, servis haritası | `docs/SMAP_UI_Uygulama_Rehberi.md` |
| Rehber düzeltmeleri | Rehberdeki 27 hatanın doğrusu (**rehberle çelişirse bu kazanır**) | `docs/SMAP_UI_Rehberi_Duzeltmeler.md` |
| Geliştirme Planı | Güvenlik/yayın bulguları, servis ve endpoint envanteri | `docs/SMAP_Gelistirme_Plani.md` |
| Tasarım panoları | Metin, CSS ve PNG | `docs/design/panolar/SMAP-XX/<NN-pano>/{text.txt,board.html}`, `docs/design/panolar/png/SMAP-XX_<NN-pano>.png` |
| Referans uygulamalar | Kopyalanacak kalıplar | Sepello `Sepello (repo dışı referans uygulama)`, Memora `Memora (repo dışı referans uygulama)`, Sleepia `Sleepia (repo dışı referans uygulama)`, mihr_ui `mihr_ui paketi (pub)` |

**Çelişkide öncelik:** Bu plan (§1 kararları) > Rehber Düzeltmeleri > Flutter Spec > UI Rehberi > Geliştirme Planı. Tasarım değerlerinde: teslim panoları 11.12–11.16 > sonraki tur > kit panoları.

---

## 1. "Başla"dan önce onaylanacak kararlar

Her birinde **önerim** yazılı; "başla" dersen bunlar onaylanmış sayılır. Değiştirmek istediğini söyle.

| # | Karar | Öneri | Neden |
|---|---|---|---|
| K1 | Router | **auto_route** + guard zinciri. Spec'teki go_router önerisi alınmaz. | Ev standardı (Sepello, Memora); guard ve typed route kalıpları hazır. |
| K2 | State | **stacked MVVM**: `StackedView` + `reactive => false` + bölüm başına `SelectorViewModelWidget`. | Sepello Home kalıbı; rebuild kapsamı dar. |
| K3 | DI | **get_it**, fazlı kayıt + `session` scope. | Memora kalıbı. |
| K4 | Ağ / hata | Tek **Dio** NetworkService, `AppException` + `Either` (dartz), typed request sınıfları, **dart_mappable** DTO. | Memora `core/network`, `core/errors`. |
| K5 | Bileşen adlandırma | Genel kit **`App*`** (`lib/shared/ui/`), alan bileşenleri **öneksiz** (`DybCounter`, `QuestionCell`, feature `presentation/widgets/`). Spec'teki `SmapX` adı → genelse `AppX`, alan bileşeniyse `X`. Spec C-numarası doc yorumunda kalır. | Sepello ile aynı dil; genel parçalar ileride mihr_ui'ye taşınabilir. |
| K6 | Ekran adlandırma | `XxxView` + `XxxViewModel`, route `XxxRoute` (`replaceInRouteName: 'View,Route'`). | Sepello. |
| K7 | Tasarım sistemi | **mihr_ui `^0.1.0-dev.3`** (pub). Renkler yalnız `context.appColors`; mihr renk getter'ları yasak. Rehber Düzeltmeleri #4–#8'deki dev.3 sınırlarına uyulur. | Ev standardı; dev.3 hataları bilinçli olarak sarılır. |
| K8 | Font | **Plus Jakarta Sans** TTF (400–800) + OFL lisansı `assets/fonts/`'a gömülür. Kaynak: `github.com/google/fonts/ofl/plusjakartasans` (yaklaşık 200 KB). Tasarım dosyasındaki woff2'ler alt küme olduğu için kullanılmaz. | Tur 1: runtime indirme yok. |
| K9 | Tema modu | Göç boyunca **yalnız açık tema**; koyu tema token'ları ve galeride iki tema hazır olur. Son fazda `ThemeMode.system`. | Eski ekranlar yalnız açık. |
| K10 | Test | **Widget/golden testi yok** (ev kuralı). Saf mantık, VM, repository, DI smoke, kontrast ve `TrFormat` testleri zorunlu. | Sepello kuralı; görsel doğrulamayı ben simülatörde yapacağım. |
| K11 | Dil | Yalnız `tr`. Metinler **feature başına ARB parçasında**, bir betik `app_tr.arb`'yi birleştirir. | Paralel ajanların ARB çakışmasını önler. |
| K12 | Tasarımda olmayan özellikler | **Mevcut kodda gerçek backend'le çalışan özellik silinmez**; Claude Design'a "Tur 12" brifi gider (`docs/SMAP_Tasarim_Brifi_Tur12.md`), tasarım gelince ekran görevi olarak eklenir. Yalnız sahte veri gösteren, "yakında" olan ya da hiçbir yerden açılmayan kod (grep kanıtıyla) silinir. | Ürün sahibinin kararı (2026-10-11). |
| K13 | Backend'i bekleyen ekranlar | Ekran yapılır, eksik uç **feature flag'le kapalı** başlar (spec §6.4). Uç belirsizse repository arayüzü + `FakeXxxRepository` yazılır; **sahte veri hiçbir zaman UI'a gerçek veri gibi gitmez** (flag kapalıyken bölüm çizilmez). | İş durmaz, yalan veri de çıkmaz. |
| K14 | Git | Entegrasyon dalı `redesign/main` (yerel). Her görev kendi dalında ve **kendi worktree'sinde** (`../smapFlutter-wt/<görev>`). Ben inceleyip `redesign/main`'e merge ederim. **Remote'a push yok**; push/PR için ayrıca soracağım. | Paralel ajanlar birbirinin dosyasına dokunmaz. |
| K15 | Bugünkü 4 değişmiş dosya | `ios/Podfile.lock`, `project.pbxproj`, `main_inapp_webview.dart`, `views/onboarding/onboarding_page.dart` + `.vscode/`, `devtools_options.yaml` olduğu gibi **`main` üzerinde "chore: yerel değişiklikler" commit'i** olarak saklanır; sonra `redesign/main` açılır. | Hiçbir şey kaybolmaz. |
| K16 | SDK | Flutter **3.38.6** (makinede kurulu, Sepello CI ile aynı); `environment.sdk` buna göre yükseltilir, `.puro.json` eklenir. | Rehber Düzeltmeleri #26. |

---

## 2. Çalışma modeli

### 2.1 Roller
- **Koordinatör (ben):** görevleri dalgalar halinde dağıtır; worktree'leri açar; ajan dönünce **kendim inceler**, düzeltme isterse aynı ajana geri gönderir; `redesign/main`'e merge eder; ortak dosyaları (router listesi, DI modül listesi, galeri listesi, ARB birleştirme, pubspec) yalnız ben değiştiririm; `docs/DURUM.md`'yi güncellerim.
- **Uygulayıcı ajan (Sonnet 5.5, high):** yalnız kendisine verilen dalda ve kendisine ait dosyalarda çalışır. Ortak dosyaya ihtiyaç duyarsa dokunmaz, raporunda "koordinatöre not" olarak yazar. Commit eder, push etmez.

### 2.2 Ortak dosyalar (yalnız koordinatör değiştirir)
Bu dosyalar ajan görevlerinde **yasak**. Ajan ihtiyacını raporuna yazar, ben ekleyim:
- `pubspec.yaml`, `pubspec.lock`, `build.yaml`, `analysis_options.yaml`, `l10n.yaml`
- `lib/app/router/app_router.dart` (feature'lar kendi `xxx_routes.dart` listesini sunar, ben birleştiririm)
- `lib/dependency_injection/injection_container.dart` (feature'lar `xxx_module.dart` sunar)
- `lib/features/debug/gallery_registry.dart` (her alan kendi `xxx_gallery.dart` sayfasını sunar)
- `lib/l10n/app_tr.arb` (üretilir; ajanlar yalnız `lib/l10n/arb/<feature>_tr.arb` yazar)
- `ios/Runner/Info.plist`, `android/app/src/main/AndroidManifest.xml`, `android/app/build.gradle*` (yalnız ilgili görev açıkça sahiplenirse)

### 2.3 Ajan görev şablonu (her ajana bu iskelet gider)
```
Görev <ID> · <başlık>
Çalışma dizini: ../smapFlutter-wt/<id>  (dal: task/<id>)
Önce oku: smapFlutter/AGENTS.md, docs/SMAP_Ana_Plan.md §<görev>, <spec bölümleri>, <pano PNG + text.txt>
Sahip olduğun dosyalar: <liste/globlar>   — bunların dışına yazma.
Dokunma: §2.2 ortak dosyalar.
Yap: <iş maddeleri>
Bitti sayılır: <kriterler>
Bitince: dart format, flutter analyze (yeni uyarı yok), flutter test, commit (Conventional Commits, Türkçe özet).
Rapor: değişen dosyalar, kararlar/varsayımlar, koordinatöre notlar (ortak dosya ihtiyaçları, ARB/route/DI/galeri kayıtları), açık sorular.
```

### 2.4 Koordinatör inceleme protokolü (her görev için, ben yaparım)
1. **Kapsam:** `git diff redesign/main...task/<id> --stat` → yalnız sahip olunan dosyalar mı?
2. **Kodu okurum:** her dosyayı, özellikle mantık, VM, repository ve bileşen API'lerini.
3. **Kurallar grep'i** (presentation altında 0 olmalı): `Color(0x`, `Colors.`, `TextStyle(`, `fontSize:`, `Icons.`, `CupertinoIcons.`, `AlertDialog`, `showDialog`, `showModalBottomSheet`, `SnackBar`, `MaterialPageRoute`, `Navigator.push`, `SharedPreferences.getInstance`, `print(`, `BorderRadius.circular(` (token dışı), `Duration(milliseconds` (token dışı), Türkçe string literal.
4. **Boyut:** view ≤ 250, part ≤ 300, VM ≤ 500, presentation'da dosya ≤ 400 satır.
5. **Çalıştırırım:** `dart format --set-exit-if-changed`, `flutter analyze` (baseline 307'den artış yok, yeni dosyalarda 0), `flutter test`, codegen güncel mi (`build_runner`, gen-l10n diff yok).
6. **Görsel kontrol (UI görevleri):** iOS simülatörde ilgili ekranı/galeri sayfasını açar, ekran görüntüsünü pano PNG'siyle yan yana karşılaştırırım (açık + koyu galeride, metin ölçeği 1,3).
7. **Karar:** ✅ merge · 🔁 düzeltme listesiyle aynı ajana iade · ❌ geri al. İade en çok 2 tur; sonra işi ben bitiririm.
8. **Merge sonrası:** `redesign/main` üzerinde analyze + test + bir kez uygulama açılışı; `docs/DURUM.md` güncellenir.

### 2.5 Dalga kuralları
- Bir dalgadaki görevlerin **sahip olduğu dosyalar kesişmez**.
- Aynı anda en çok **4 ajan**. Dalga, son görevi merge edilince kapanır (bağımlılığı olmayan sonraki dalga görevleri erken başlayabilir).
- Her ekran görevi önce veri (DTO, repository, servis, saf mantık + test), sonra VM (+ test), sonra view yapar (Rehber §8).

---

## 3. Görevler

Etiketler: **[HAZIR]** mevcut uçlarla yapılabilir · **[KISMİ]** bir kısmı flag arkasında · **[BLOKE]** backend olmadan başlamaz. Boy: S ≤ 0,5 gün · M ≈ 1–2 gün · L ≈ 3–5 gün (ajan süresi değil, iş büyüklüğü).

### Faz 0 — Hazırlık (seri)

**G0 · Repo hazırlığı** — *koordinatör*, S
- K15 commit'i; `redesign/main` dalı; `.gitignore` (build, `.dart_tool`, worktree klasörü); worktree yardımcı betiği `tool/wt.sh <id>`.
- `smapFlutter/AGENTS.md` + `CLAUDE.md` (içerik: Rehber §10 taslağı + Düzeltmeler #21 + bu plandaki K1–K16 + §2.2 ortak dosya listesi + §2.4 grep listesi).
- Bitti: `git status` temiz, `redesign/main` var, AGENTS.md commit'li.

**G1 · Bağımlılık ve iskelet temeli** — *1 ajan*, M — sahip: `pubspec.yaml`, `pubspec.lock`, `build.yaml`, `analysis_options.yaml`, `l10n.yaml`, `.puro.json`, `assets/fonts/**`, `lib/l10n/**`, `tool/merge_arb.dart`, `.github/workflows/ci.yml`
- SDK 3.38.6 (K16).
- **Ekle:** `stacked`, `get_it`, `auto_route` (+ `auto_route_generator`), `dart_mappable` (+ builder), `build_runner`, `dartz` (var), `dio` (var), `dio_cookie_manager` + `cookie_jar` (oturum çerezi için; Memora karşılığı incelenip seçilir), `mihr_ui ^0.1.0-dev.3`, `smooth_sheets`, `toastification`, `phosphor_flutter`, `flutter_gen_runner`, `permission_handler`, `connectivity_plus`, `package_info_plus`, `url_launcher`, `share_plus`, `flutter_secure_storage`, `intl` (var), `fl_chart` (var), `flutter_card_swiper` (var), `logger` (ya da Memora'daki karşılığı). Sürümler: referans uygulamaların `pubspec.lock`'larından; orada yoksa pub'daki son kararlı.
- **Çıkar (yalnız kullanılmadığı grep ile kanıtlanırsa):** `http`, `rest_api_package`, `appinio_swiper`, `cupertino_icons`, `camera` ya da `camerawesome`'dan kullanılmayanı, `web_socket_channel` (kullanım yoksa). Kullanılıyorsa bırak, raporla.
- Plus Jakarta Sans TTF + OFL (K8), pubspec `fonts:` bloğu (aile adı `PlusJakartaSans`).
- `flutter: generate: true`, `l10n.yaml` (arb-dir `lib/l10n`, şablon `app_tr.arb`, sınıf `AppLocalizations`), `lib/l10n/arb/common_tr.arb` (`common_cancel` "Vazgeç", `common_ok` "Tamam", `common_close` "Kapat", `common_undo` "Geri Al", `common_retry` "Tekrar Dene"), `tool/merge_arb.dart` (arb/*.arb → app_tr.arb, çakışan anahtarda hata).
- `analysis_options.yaml`: Rehber A4 kuralları; mevcut 307 uyarıyı büyütmemek için legacy klasörler `exclude` değil, yeni kurallar yalnız `lib/shared/**`, `lib/core/**`, `lib/app/**` ve yeni feature klasörlerinde sıkı (gerekirse `// ignore_for_file` ile legacy dosyalara dokunulmaz).
- `build.yaml` (dart_mappable, auto_route, flutter_gen).
- CI: analyze + test + codegen diff + gen-l10n diff (push yok; dosya hazır dursun).
- Kırık `test/widget_test.dart` silinir.
- **Bitti:** `flutter pub get`, `dart run build_runner build`, `flutter gen-l10n` temiz; uygulama eskisi gibi açılıyor (simülatörde login görünüyor); analyze sayısı ≤ 307.

### Faz 1 — Altyapı ve temeller

**Dalga 1A** (G1'den sonra, 3 paralel ajan)

**INF1 · Çekirdek altyapı** — M — sahip: `lib/core/{config,errors,network,mappable,extensions}/**`, `lib/core/services/{app_logger,device_preferences,connectivity_service}.dart`, `lib/dependency_injection/**` (container dahil, bu görevde ilk kez kurulur), `test/core/**` (theme hariç), `test/dependency_injection/**`
- `AppConfig` (`--dart-define-from-file`, `config/dev.json` örneği; `apiBaseUrl`, `omrBaseUrl`, `cdnBaseUrl`, `supportEmail`, `yksDate`, `appStoreId`, `playPackage`) + test. Kaynak `SHP/lib/core/config/app_config.dart`.
- `AppException`, `AppErrorCode` (network, timeout, offline, unauthorized, server, maintenance, notFound, validation, unknown) → l10n anahtarı eşlemesi; `Either` uzantıları. Kaynak `MEM/lib/core/errors/*`, `MEM/lib/core/extensions/dartz_extension.dart`.
- `NetworkService` (tek Dio; cookie jar; `validateStatus` gerçek; 401/302 → `onSessionExpired` akışı; timeout'lar; typed `BaseRequest`). Kaynak `MEM/lib/core/network/*`, `MEM/lib/config/api/requests/base_request_model.dart`.
- `DevicePreferences` (allowList'li facade; `SHP/lib/core/services/device_preferences.dart`), `ConnectivityService` (**`SLP/lib/services/connectivity_service.dart`**, Firestore'suz — Düzeltme #9), `AppLogger` (release'te hassas veri yok).
- DI: `injection_container.dart` (fazlar: core → data → services; `session` scope), `xxx_module.dart` kayıt kalıbı, DI smoke testi.
- **Eski koda dokunma**; eski DioClient yerinde kalır (ekranlar taşındıkça emekli olur).
- Bitti: testler yeşil, DI smoke testi tüm kayıtları çözüyor.

**TOK · Token'lar ve tema** — M — sahip: `lib/core/theme/**`, `lib/core/utils/{tr_format,turkish_text}.dart`, `lib/core/services/app_haptics.dart`, `ios/Runner/AppDelegate.swift`, `android/app/src/main/kotlin/**/MainActivity.kt`, `test/core/theme/**`, `test/core/utils/**`
- Spec §1 (01_tokenlar.md) + Rehber §4 + Düzeltmeler #24, #25, #27, ters yüzey (inverseSurface) eki.
- Dosyalar: `smap_palette.dart`, `smap_colors.dart` (ThemeExtension, light/dark aynı alan kümesi, alan adları **11.12'deki adlar**), `subject_tone.dart` (9 ders × 2 tema), `smap_text.dart` (bütün stiller `tnum`; detay barı 15/20·600 stili dahil), `app_spacing.dart`, `app_radius.dart`, `app_shadows.dart`, `app_motion.dart` (+ `SmapDurations`, `context.motion`, hareketi azalt), `smap_theme.dart` (`MihrThemeConfig` + ColorScheme Tur 1 birebir + `base.textTheme.merge(...)`, `scaffoldBackgroundColor: bgCanvas`), `context` erişimcileri (`context.appColors`, `context.appText`).
- `AppHaptics` (4 çağrı; iOS kanal + Android CONFIRM/REJECT), `TrFormat` (net 67,5 · puan 412,63 · sıra 48.215 · %42 · "5 Eki." · gün adları), `TurkishText.fold` (I/ı/İ/i).
- Testler: kontrast (yalnız izin verilen çiftler, doğru eşikle — Düzeltme #17), light/dark alan eşitliği, `TrFormat`, `TurkishText`.
- **Tema henüz MaterialApp'e bağlanmaz** (RTR görevinde bağlanır).
- Bitti: testler yeşil; font aile adı pubspec ile birebir; `tnum` ve ğ ş ı İ glifleri kontrol edilmiş (fonttools yoksa render ile).

**CLN · Ölü kod ve sahte giriş verisi** — S — sahip: silinecek dosyalar + `lib/features/auth/presentation/screens/login_screen.dart` ve `register_form.dart`'ın yalnız prefill satırları
- Sil (yalnız grep ile ölü/erişilemez olduğu kanıtlananlar): `lib/views/{auth,main_webview,onboarding}`, `optic_requests` kopyaları, `services/google_auth_service.dart` (çağrılmıyorsa), Geliştirme Planı §1.1'deki 31 boş stub. **Çalışan hiçbir özellik silinmez (K12).**
- Login prefill (`login_screen.dart:19-20`) ve `register_form.dart` test verisi kaldırılır.
- **`lib/views/optic_mark_detection_view` silinmez** (OMR hâlâ orada).
- Her silmeden önce `grep` ile referans yokluğu kanıtlanır; rapora liste.
- Bitti: analyze ≤ önceki sayı, uygulama açılıyor, login boş alanlarla geliyor.

**Dalga 1B** (TOK merge olunca; INF1'i beklemez)

**KIT1 · Kit-1: kontroller + galeri** — L — sahip: `lib/shared/ui/{buttons,controls,inputs,surfaces,indicators,text,identity}/**`, `lib/features/debug/**` (registry hariç ilk sürümü bu görev yazar), `lib/main_gallery.dart`
- Rehber §5 #1–23 (Düzeltmeler #5, #6, #8 ile) = spec C01–C02, C04–C07, C09–C10, C12, C14–C19, C39, C44, C46–C47, C49, C55–C56, C59.
- Galeri: ayrı giriş `lib/main_gallery.dart` (router'sız; Düzeltme #22), açık/koyu anahtarı, metin ölçeği 1,3 anahtarı, hareketi azalt anahtarı; `gallery_registry.dart` + alan sayfaları (`buttons_gallery.dart` …).
- Bitti: galeride her bileşen her durumda (basılı, odak, pasif, yükleniyor, hata) iki temada; ben simülatörde 1.9–1.17 panolarıyla karşılaştırırım.

**Dalga 1C** (INF1 merge olunca)

**SES · Oturum, kullanıcı, auth verisi** — M — sahip: `lib/services/session_manager.dart`, `lib/services/current_user_service.dart`, `lib/core/domain/user_role.dart`, `lib/features/auth/data/**` (yeni dosyalar), `lib/features/auth/domain/**`, `lib/features/auth/auth_module.dart`, ilgili testler
- `SessionManager` (restore: önbellekteki kullanıcıyla iyimser açılış; logout/hesap silme → session scope temizliği), `CurrentUserService` (ListenableServiceMixin), `UserRole` (student, coach, unknown), `AuthRepository` (Either; `POST /student/login` yanıtı doğrulanır, 302 başarı sayılmaz; `/ajax/checkUser`, `/ajax/logout`), DTO'lar (`UserDto`, `LoginResponse`) dart_mappable.
- Token/çerez **secure storage**'da (`flutter_secure_storage`); eski düz prefs anahtarlarından bir kerelik göç.
- Eski `UserProvider`'lar bu görevde silinmez; RTR köprüler.
- Bitti: repository ve SessionManager testleri (başarılı giriş, hatalı bilgi, 401, çevrimdışı restore).

**KIT2 · Kit-2: katmanlar ve durum kalıpları** — M — sahip: `lib/shared/ui/{sheets,feedback}/**`, `lib/core/services/toast_service.dart`, `lib/features/debug/pages/{sheets,feedback}_gallery.dart`
- Rehber §5 #24–31 = C71–C79, C75 OfflineStrip (Connectivity INF1'den). ToastService **router'sız** overlay ile (Düzeltme #9: `cloud_firestore` yok; #22: AppRouter bağımlılığı yok).
- Bitti: sheet sürükleme %25/fırlatma, busy kilidi; toast 4/6 sn, ekran okuyucuda kalıcı; iskelet 15 sn zaman aşımı örneği.

**DOM · Alan bileşenleri** — L — sahip: `lib/features/exams/presentation/widgets/**`, `lib/features/lessons/presentation/widgets/**`, `lib/features/analytics/presentation/widgets/net_chart.dart`, `lib/features/schedule/presentation/widgets/program_item_row.dart`, `lib/features/cards/presentation/widgets/info_card_face.dart`, `lib/features/debug/pages/domain_gallery.dart`
- C08 EksikTag, C20–C27, C40–C43, C48 NetChart, C30 ProgramItemRow, C52'nin kart yüzü, C58 SubjectGlyph. Galeride sabit örnek veriyle (spec Ek C değerleri).
- **Eski widget dosyalarına dokunmaz** (aynı klasörde eski dosya varsa yeni adla yanına yazar).
- Bitti: D/Y/B gri tonlamada ayrışıyor (glif + etiket), Semantics okunuşları doğru, NetChart TYT 0–120 / AYT 0–160.

**Dalga 1D** (SES + KIT1 + KIT2 merge olunca)

**RTR · Router, bootstrap, tema bağlantısı** — L — sahip: `lib/main.dart`, `lib/main_initializer.dart`, `lib/app/**`, `lib/features/startup/**`, `lib/features/legacy/**` (sarmalayıcılar), `flutter_native_splash` ayarı (pubspec'e not), `ios/Runner/Info.plist` (yalnız `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`)
- auto_route `AppRouter`, guard'lar (Onboarding > Auth > Role; ForceUpdate sonra), `StudentShellRoute`/`CoachShellRoute` iskeleti (sekmeler şimdilik `Legacy…Route` sarmalayıcıları), eski Provider'lar router'ın üstünde kalır.
- `MaterialApp.router` + `SmapTheme.light` (K9) + `AppLocalizations` + `supportedLocales: [Locale('tr')]` (Düzeltme l10n).
- `MainInitializer` + `runZonedGuarded`; native splash (lacivert + S-rota) `preserve` → restore bitince kaldır (spec 2.1-1).
- 401 → `SessionExpiredSheet` kancası; genel ekranlar (2.7: zorunlu güncelleme, oturum bitti, bakım, bilinmeyen rol) `features/startup/` altında, tetikleyiciler flag'li.
- `home: Consumer`, `app_start_provider.dart` silinir.
- **Global tema değişimi eski ekranları etkiler:** login ve OMR akışı simülatörde elle gezilir, kırılan yer raporlanır (gerekirse eski ekranlar `Theme(data: LegacyTheme)` ile sarılır).
- Bitti: soğuk açılış, giriş, çıkış, rol yönlendirme eskisi gibi çalışıyor; çevrimdışı soğuk açılış önbellekteki kullanıcıyla kabuğa gidiyor; Info.plist kamera metni var.

**KIT3 · Kabuk parçaları** — M — (RTR ile paralel) sahip: `lib/shared/ui/navigation/**`, `lib/features/debug/pages/navigation_gallery.dart`
- C80 RootBand, C81 HomeBand, C82 DetailBar + LargeTitleSliver, C83 ContextStrip, C84 BottomBar + CameraButton (öğrenci/koç), C85 StudentScope (InheritedWidget). Yalnız widget; yönlendirme E5'te.
- Bitti: bant 134→110, segmentli bant 178; detay barında başlık iniyor; "Görüşmelerim" 1,3 ölçekte sığıyor; BottomBar blur'u Düzeltme #4'e göre.

### Faz 2 — Ekranlar (uygulamanın başından ileri)

Her ekran görevinin ortak "bitti" tanımı: Rehber §8'in 13 maddesi + §2.4 grep'i + pano ile simülatör karşılaştırması + **yerini aldığı eski dosyaların aynı görevde silinmesi**. Ekran görevleri kendi feature klasörlerine sahiptir; route listesi (`xxx_routes.dart`), DI modülü (`xxx_module.dart`), ARB parçası (`lib/l10n/arb/<feature>_tr.arb`) ve galeri sayfası feature içindedir; birleştirmeyi ben yaparım.

**Dalga 2A** (RTR + KIT3 + DOM merge olunca; 4 paralel)

| ID | Ekranlar | Pano | Sahip | Etiket | Boy |
|---|---|---|---|---|---|
| **E1** | Açılış + genel ekranlar (zorunlu güncelleme, bakım, oturum bitti, bilinmeyen rol) | 2.1·1, 2.7 | `features/startup/**` (RTR'nin iskeletini tamamlar) | KISMİ (public-config yok → flag) | S |
| **E2** | Tanıtım (3 sayfa), Rol, Sınıf ve alan, Kamera ön açıklaması, Hoş geldin | 2.1·2–4, 2.2 | `features/onboarding/**` | HAZIR | M |
| **E3** | Giriş (+ Apple/Google varyantı flag'li), Şifremi Unuttum akışı (flag kapalı, ekranlar hazır) | 2.3, 2.4 | `features/auth/presentation/login/**`, `…/forgot_password/**` | KISMİ | M |
| **E4** | Kayıt (öğrenci/koç, canlı kullanıcı adı, sözleşmeler, hata durumları) | 2.5, 2.6 | `features/auth/presentation/register/**` | KISMİ (KVKK sürüm alanları) | M |

**Dalga 2B** (E1–E4'ten bağımsız; RTR + KIT3 sonrası, 2A ile örtüşebilir)

| ID | Ekranlar | Pano | Sahip | Etiket | Boy |
|---|---|---|---|---|---|
| **E5** | Kabuk: öğrenci ve koç alt çubuğu, kamera düğmesi, sekme yığınları, OfflineStrip, toast konumu | 1.19, 1.23, 0.1 | `features/shell/**` | HAZIR | M |

**Dalga 2C** (E5 merge olunca; 4 paralel)

| ID | Ekranlar | Pano | Sahip | Etiket | Boy |
|---|---|---|---|---|---|
| **E6** | Anasayfa (öğrenci) + durumlar + koyu | 3.1–3.3 | `features/home/**` (yeni), `LessonsService`, `ExamsService`'in özet kısmı | KISMİ | L |
| **E7** | Programım: liste, gün/hafta, Yeni Program (günler→ızgara→konu→ad/motto), düzenle/sıfırla/iptal | 3.4–3.8 | `features/schedule/**` | KISMİ (silme/sıfırlama ucu) | L |
| **E11** | Analizlerim: Genel (grafik, süzgeç, kutular) + Denemelerim (süz/sırala) | 6.1–6.4 | `features/analytics/**` (yeni dosyalar) | KISMİ | L |
| **E12** | Derslerim, Ders Detayı (+Eksiklerim süzgeci), Konu Detayı (+kart sheet'i), Edebiyat Yazar ve Eserler | 7.1–7.6 | `features/lessons/**` | KISMİ | L |

**Dalga 2D** (4 paralel; E6/E11'in servislerine bağlı olanlar onlardan sonra)

| ID | Ekranlar | Pano | Sahip | Etiket | Boy |
|---|---|---|---|---|---|
| **E10** | Deneme Detay (Genel, Sorular, Konular, Kartlar) + Soru Detay | 5.3–5.10, 5.7 | `features/exams/presentation/{exam_detail,question_detail}/**`, `features/exams/{data,domain,application}/**` | KISMİ (soru şıkları #9) | L |
| **E13** | Kart Destesi (Eksiklerim/Bildiklerim/Favorilerim, Öğrendim + Geri Al) | 8.1–8.2 | `features/cards/**` | KISMİ (geri alma ucu) | M |
| **E14a** | Hesap, Profil (düzenle, avatar, sınıf), Sözleşmeler, Çıkış | 9.1, 9.2, 9.7 | `features/account/{account,profile,contracts}/**` | HAZIR | M |
| **E14b** | Şifre (flag), Hesabı Sil, Koçluk, Bildirimler (flag) | 9.3–9.6 | `features/account/{password,deletion,coaching,notifications}/**` | KISMİ | M |

**Dalga 2E** (kamera + sonuç; 2 paralel)

| ID | Ekranlar | Pano | Sahip | Etiket | Boy |
|---|---|---|---|---|---|
| **E8** | Kamera izni, öğretici, çekim, köşe düzenleme, gönderim (yüzde), okunuyor, Form Kontrol + cevap düzelt, Deneme Bulunamadı talebi, hata ekranları — kamera her temada koyu | 4.1–4.10 | `features/scan/**`, `lib/vendor/flutter_document_scanner/**` (yalnız overlay/tema), eski `lib/views/optic_mark_detection_view/**` silinir | **BLOKE** (OMR gerçek host #1, multipart #2) — UI ve akış yapılır, uçlar AppConfig'ten; host gelmeden yayın yok | L |
| **E9** | Sonuç anı (AYT/TYT, koyu) + bildirim izni sheet'i (flag) | 5.1–5.2 | `features/exams/presentation/result_moment/**` | KISMİ | M |

**Dalga 2F** (koç; 3 paralel)

| ID | Ekranlar | Pano | Sahip | Etiket | Boy |
|---|---|---|---|---|---|
| **E15** | Koç Anasayfa (dikkat listesi flag'li, öğrenci yok, iskelet) | 10.1 | `features/coach/presentation/coach_home/**`, `CoachStudentsService` | KISMİ | M |
| **E16** | Öğrencilerim (tr arama), Öğrenci Ekle (form, kod kartı) | 10.2–10.3 | `features/coach/presentation/{students,add_student}/**`, eski `features/my_students/**` silinir | KISMİ | M |
| **E18** | Görüşmelerim, Yeni görüşme, Görüşme detayı, Notlar (ekle/düzenle/sil) | 10.5–10.6 | `features/coach/presentation/meetings/**`, eski `features/my_interviews/**` silinir | KISMİ | M |

**Dalga 2G** (E10, E11, E7, E16 merge olunca)

| ID | Ekranlar | Pano | Sahip | Etiket | Boy |
|---|---|---|---|---|---|
| **E17** | Öğrenci Profili (koç bağlamı: Analiz, Denemeler, Program salt okunur, Deneme Detay koç bağlamı) + ContextStrip | 10.4 | `features/coach/presentation/student_profile/**`; E10/E11/E7 view'larına `student:` parametresi eklemek için o dosyalara **dar izin** | KISMİ (#33 studentId) | M |
| **E19** | Koç için Okut (öğrenci seçimi sheet'i) | Tur 9 · 9.9 | `features/scan/presentation/coach_pick/**` | **BLOKE** (#34) | S |

### Faz 3 — Kapanış

**FIN1 · Koyu tema ve sistem modu** — M — koyu karelerin denetimi (3.3, 3.8, 4.3–4.4, 4.6, 5.1·3, 5.9, 5.10, 6.4, 7.6, 8.2), `ThemeMode.system`, `SystemUiOverlayStyle` (lacivert bant, açık detay barı, kamera), Android edge-to-edge.
**FIN2 · Eskiyi silme** — M — `lib/views`, `lib/repository`, `lib/http_service`, `AppColors`/`AppTheme`, `provider` paketi, eski nav notifier'lar, kullanılmayan varlıklar (`ob1-6.png` 7,7 MB vb.); CI'a presentation altında `Color(0x` sayacı (hedef 0).
**FIN3 · Varlıklar** — S — S-rota logo SVG'leri, `flutter_launcher_icons` (alfasız 1024), native splash son hâl, avatar 3x.
**FIN4 · Erişilebilirlik turu** — S — VoiceOver/TalkBack bir tur, 1,3 metin ölçeği, hareketi azalt.
**FIN5 · Yayın hazırlığı** — S — Android release imzası ve uygulama kimliği (şablon `com.smap.smap` → sahibin kararı), sürüm numarası, mağaza görselleri (`SMAP_Store_Screenshots_Prompt.md` ve pano 12.x).

### Faz 4 — Kapsam dışı (ayrı karar)
**Tur 12 ekranları** (K12 denetiminde çalıştığı kanıtlanan, tasarımda olmayan özellikler; tasarım gelince Faz 2'ye görev olarak eklenir). Firebase Crashlytics/Analytics, push (FCM) + bildirim tercihlerinin sunucuya yazılması, remote config / public-config, IAP. Ekranlar flag'leriyle hazır bekler.

---

## 4. Dalga özeti ve kritik yol

```
G0 → G1 → ┬─ INF1 ─→ SES ─┐
          ├─ TOK ─→ KIT1 ─┼─→ RTR ─┬─→ E1 E2 E3 E4
          ├─ CLN          │        └─→ E5 ─→ E6 E7 E11 E12 ─→ E10 E13 E14a E14b ─→ E8 E9 ─→ E15 E16 E18 ─→ E17 E19 ─→ FIN1–5
          └─────────── KIT2, DOM (TOK+INF1 sonrası) ─┘   KIT3 (RTR ile paralel)
```
Görev sayısı: hazırlık 2 · altyapı/kit 8 · ekran 19 · kapanış 5 = **34 görev**, ~10 dalga, aynı anda en çok 4 ajan.

---

## 5. Backend'e gidecek sorular (uygulama sahibine)

Tam tablo: spec §6.3 (41 madde). Ekranları **bloke eden** ve önce cevap gereken 10 soru:
1. OMR (optik okuma) servisinin gerçek host'u ve tek API taban adresi (#1, #41 görseller).
2. Fotoğraf yükleme biçimi: multipart JPEG mi, base64 mi; boyut sınırı (#2).
3. Oturum düşünce sunucu ne döner (401 / 302); rol değer seti (#6).
4. Soru başına işaretlenen ve doğru şık alanı (Deneme Detay › Sorular buna bağlı) (#9).
5. Şifremi unuttum (6 haneli kod) ve şifre değiştirme uçları (#7, #8).
6. Alan/sınıf kodlarının tek resmî eşlemesi (Sayısal/EA/Sözel/Dil, Mezun) (#18).
7. Koç uçları `studentId` alıyor mu; koçun öğrenci verisine sahiplik kontrolü (#33, #34).
8. Program silme / günü sıfırlama ve kart "öğrendim"i geri alma uçları (#24, #25).
9. Koç dikkat listesi ve öğrenci listesinde son net/tarih (#28, #29).
10. KVKK sözleşme sürüm alanları kayıtta (#13) ve hesap silme davranışı (#14).

Ürün kararları: launcher ikonu (lacivert pafta / açık), kil illüstrasyonların asıl dosyaları, YKS tarihi kaynağı, destek e-postası, Android uygulama kimliği.

---

## 6. Durum takibi

`docs/DURUM.md` (koordinatör günceller): her görev için durum (⏳ bekliyor · 🔨 ajanda · 🔎 incelemede · 🔁 iade · ✅ merge), dal, ajan turu, inceleme notları, açık sorular. Her dalga sonunda sana kısa özet + simülatör ekran görüntüleri.
