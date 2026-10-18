# 04 · Tasarım sistemi: token'lar, tema, kit ve galeri

Bu bölüm SMAP'in görsel katmanını anlatır: renk, yazı, boşluk, hareket ve haptik token'ları, tema ve koyu tema, sayı ve Türkçe metin yardımcıları, `lib/shared/ui` kit kataloğu, alan bileşenleri, bileşen galerisi ve tasarım panolarına atıf biçimi. Projeyi ilk kez açan deneyimli bir Flutter geliştiricisi (ve AI ajanları) içindir. Ekran kodunun bu katmanı nasıl kullandığı (ViewModel, seçici, durumlar, sheet) [03_ekran.md](03_ekran.md)'dedir.

Komşu bölümler: mimari [01_mimari.md](01_mimari.md), veri [02_veri.md](02_veri.md), araçlar ve komutlar [05_araclar.md](05_araclar.md), özellik haritası [06_ozellikler.md](06_ozellikler.md), giriş [../DEVELOPING.md](../DEVELOPING.md). Bu bölüm `lib/core/theme/**`, `lib/core/utils`, `lib/core/services/app_haptics.dart`, `lib/shared/ui/**`, alan bileşenleri ve `lib/features/debug/**` galerisini kapsar.

## 1. Temel ilke

Ekran kodu ham renk, ham yazı stili, ham süre veya sayı literali kullanmaz. Hepsi aşağıdaki erişimlerden gelir:

| İhtiyaç | Kaynak | Dosya |
|---|---|---|
| Renk | `context.appColors` (`SmapColors`) | `lib/core/theme/smap_colors.dart` |
| Yazı | `context.appText` (`SmapText`) ve `copyWith(color:)` | `lib/core/theme/smap_text.dart` |
| Boşluk ve sabit ölçüler | `AppSpacing`, `AppSize` | `lib/core/theme/app_spacing.dart` |
| Köşe yarıçapı | `AppRadius` | `lib/core/theme/app_radius.dart` |
| Hareket | `AppMotion`, `SmapDurations`, `context.motion(...)` | `lib/core/theme/app_motion.dart` |
| Gölge ve bulanıklık | `AppShadows`, `AppBlur` | `lib/core/theme/app_shadows.dart` |
| Ders rengi | `context.appSubject(SubjectKey)` | `lib/core/theme/subject_tone.dart` |
| İkon | `phosphor_flutter` (`PhosphorIconsRegular.*`) | `pubspec.yaml` |

Token adları ve değerleri tasarım teslim panolarından gelir: 1.1–1.8 ve özellikle 11.12 "Token Tablosu" (bölüm 11). Alan adı 11.12 "Rol" sütununun camelCase halidir: `bg-canvas` `bgCanvas` olur. 11.12'nin "Flutter" sütunundaki ext adları (`navyBand`, `contextStrip`, `bar`, `dybEmpty`) kullanılmaz; `bgNavy`, `bgContext`, `bgBar`, `dybBlank` seçildi (`smap_colors.dart` sınıf doc'u, `docs/SMAP_UI_Rehberi_Duzeltmeler.md` #24).

`lib/core/theme/theme_context.dart` erişimcileri tanımlar. Kod doc'undan:

```dart
final colors = context.appColors;
final text = context.appText;
Text(value, style: text.metricLg.copyWith(color: colors.textPrimary));
```

`appColors` ve `appText`, tema `SmapTheme` değilse `FlutterError` fırlatır. Bu bilinçli bir tercihtir: başka temada widget sessizce yanlış renk gösterirdi. `context.appSubject(key)` `appColors.subjects[key]!` döndürür.

## 2. Renkler: `SmapColors` ve `SmapPalette`

- **`SmapPalette`** (`smap_palette.dart`) ham skalalardır: `navy25…950`, `orange25…950` ve `neutral0…950`. Yalnız tema katmanı okur; ekran kodu palet adımı kullanmaz. Navy-25, orange-25 ve neutral-25 tasarımda tanımlı değildir, mihr_ui'nin `ColorScale` şekli için varsayılmıştır: navy-25 ve orange-25 50 adımından bir tık açık bir tondur, nötr skalanın 25 yuvasına `neutral0` (`#FFFFFF`) verilir (`smap_palette.dart` sınıf doc'u); hiçbir rol bu adımları kullanmaz.
- **`SmapColors`** `ThemeExtension<SmapColors>`'tır. `SmapColors.light` ve `SmapColors.dark` aynı alan kümesini sunar. Ekran kodu temaya göre dallanmaz.
- Koyu set açığın tersi değildir: yüzeyler navy tonlu olup yükseldikçe açılır. Örnek: `bgCanvas` `0xFF0A1424`, `bgSurface` `0xFF121D31`, `bgRaised` `0xFF18263D`, `bgSunken` `0xFF213049`.
- Her alanın doc yorumu, 11.12 "Flutter" sütunundaki karşılığını yazar (`ColorScheme.surface` gibi, ya da `ext.<ad>`).

Rol aileleri:

| Aile | Alanlar |
|---|---|
| Zemin | `bgCanvas` (sayfa), `bgSurface` (kart, girdi dolgusu), `bgRaised` (sheet), `bgSunken` (segment ve ilerleme izi, iskelet, sessiz düğme), `bgNavy`, `bgNavyRaised`, `bgContext` (koç bağlam şeridi), `bgBar` (alt çubuk, %92 opak), `scrim` |
| Kenar | `borderSubtle` (ayraç, dekoratif), `borderStrong` (pasif kenar, sheet tutacağı), `borderControl` (girdi, çip ve onay kutusu kenarı, 3:1) |
| Metin | `textPrimary`, `textSecondary`, `textPlaceholder`, `textDisabled`, `textOnNavy`, `textOnNavy2`, `textAction`, `textAccent` |
| Marka | `primary`, `onPrimary`, `primaryPressed`, `accent` (yalnız kamera düğmesi), `onAccent`, `accentLine` (konum göstergesi, ilerleme dolgusu, "bugün"), `focusRing` |
| D/Y/B | `dybCorrect`, `dybWrong`, `dybBlank`, `dybOn`, `dybCorrectBg`, `dybWrongBg`, `dybBlankBg` |
| Anlamsal | `delta`, `eksik`, `eksikBg`, `error`, `onError`, `errorBg`, `success`, `successBg`, `warning`, `warningBg`, `info`, `infoBg` |
| Grafik | `chartLine`, `chartArea`, `chartHighlight`, `chartGrid`, `chartSeries` (4 renk, çok çizgili grafik) |
| Ters yüzey | `inverseSurface`, `onInverseSurface`, `inverseInfo`, `inverseSuccess`, `inverseError`. Toast ve çevrimdışı şerit içindir. Açıkta lacivert, koyuda `#E8ECF1` olur. |
| Ders | `subjects: Map<SubjectKey, SubjectTone>` |

Ek bilgiler:

- `SmapColors.toColorScheme(brightness)` stok Material widget'ları için `ColorScheme` üretir, seed kullanmaz. `surfaceTint` şeffaftır. Ekran kodu `Theme.of(context).colorScheme` okumaz.
- `SmapColors.of(brightness)` değerleri brightness'a göre seçer.
- `colors` getter'ı her renk alanını sırayla listeler (`chartSeries` ve `subjects` hariç). Testler kullanır; `lerp` alanları tek tek yazar. Yeni alan eklerken `copyWith`, `lerp` ve `colors` listesine de eklenmelidir. `test/core/theme/smap_colors_test.dart` içindeki `field set` grubu eksiği yakalar.
- Kontrast testi `test/core/theme/smap_contrast_test.dart` içindedir. Yalnız tasarımda izin verilen çiftleri sınar. Metin 4,5:1, büyük metin ve kontrol kenarı 3:1 eşiğine bakar. `textDisabled` ve `borderStrong` muaftır (`docs/SMAP_UI_Rehberi_Duzeltmeler.md` #17).

Renk kullanım kuralları (`AGENTS.md` UI kuralları ve doc yorumları):

- Turuncu yalnız kamera düğmesi, konum göstergesi, ilerleme ve "bugün" içindir. Seçim lacivertir. Turuncu üstüne beyaz metin yoktur.
- Yeşil yalnız "Doğru" anlamındadır. Artış göstergesi `delta` rengindedir (navy). `dybWrong` ve `dybBlank` hiçbir zaman metin rengi olmaz.
- Ders rengi (`SubjectTone.fg`) metin boyamaz. Tek istisna program bloğundaki 13/700 ders adıdır (`subject_tone.dart` doc'u). Ders rengi doğru ya da yanlış anlamı taşımaz.
- "Boş renk" gerektiğinde ham şeffaf literal yazılmaz. `lib/shared/ui/controls/clear_color.dart` içindeki `color.clear` (alfa 0) kullanılır. Böylece renk animasyonu gri üzerinden geçmez.
- Sabit açık palet gerektiğinde (basılı kâğıt gibi) ham renk yazılmaz. Açık set doğrudan seçilir: `const paper = SmapColors.light;` (`lib/features/scan/presentation/widgets/omr_form_art.dart`), `SmapColors.light.bgSurface` (`corners_hint.dart`), `static const SmapColors photo = SmapColors.light;` (`onboarding_scan_visual.dart`).

## 3. Yazı: `SmapText`

Yazı tipi Plus Jakarta Sans'tır. `pubspec.yaml` `PlusJakartaSans` ailesini 400, 500, 600, 700 ve 800 ağırlıklarıyla tanımlar (`assets/fonts/plus_jakarta_sans/`). `SmapText.family` değeri `lib/gen/fonts.gen.dart`'tan gelir (flutter_gen). Tüm stillerde `FontFeature.tabularFigures()` açıktır. `leadingDistribution: even`, "İ" noktasının ve "Ş", "Ç" çengelinin sıkı satırlarda kesilmemesi içindir (`smap_text.dart` doc'u). Stiller renksizdir, renk çağrı yerinde verilir.

| Alan | Boyut/satır · ağırlık | Kullanım |
|---|---|---|
| `display` | 32/40 · 800 | Tanıtım ve giriş/kayıt ekran başlığı |
| `titleLg` | 24/32 · 700 | Kök bant ve detay sayfa başlığı |
| `titleMd` | 20/28 · 700 | Sheet, bölüm ve boş durum başlığı |
| `headline` | 17/24 · 700 | Bölüm ve alt başlık |
| `titleSm` | 16/24 · 600 | Satır ve kart başlığı (iki satıra kırılır, kesilmez) |
| `bodyLg` | 16/24 · 400 | Girdi değeri (16, iOS yakınlaştırmasın diye) |
| `bodyReading` | 16/26 · 400 | Okuma metni |
| `body` / `bodyStrong` | 15/24 · 400 / 600 | Gövde ve vurgu |
| `caption` | 13/20 · 500 | Meta, yardım, eksen |
| `labelLg` / `labelMd` / `labelSm` | 16/24, 14/20, 12/16 · 600 | 48 dp düğme, 40 dp düğme ve çip, alt çubuk etiketi |
| `metricXl/Lg/Md/Sm` | 56/64, 40/48 · 800; 24/32, 17/24 · 700 | Sayı ve net gösterimleri |
| `barTitle` / `barTitleCompact` | 17/24 · 700 / 15/20 · 600 | Detay çubuğu başlığı |

`toTextTheme()` yalnız on bir `TextTheme` yuvasını doldurur. `SmapTheme` onu `base.textTheme.merge(...)` ile birleştirir. Atamak (`copyWith(textTheme: …)`) `displayLarge`, `displayMedium`, `headlineLarge`, `headlineMedium` yuvalarını null bırakırdı (`docs/SMAP_UI_Rehberi_Duzeltmeler.md` #27).

## 4. Boşluk, ölçü, yarıçap, gölge

- `AppSpacing`: `s4`, `s8`, `s12`, `s16`, `s24`, `s32`, `s48`, `s64`. `gutter` = 16 (ekran kenarı), `gutterAuth` = 24 (giriş ve kayıt, 2.x panoları), `touch` = 48.
- `AppSize` (aynı dosya) yalnız her ekranda aynı olan ölçüleri tutar: `rowMin` 56, `rowMinTwoLine` 72, `bandExpanded` 134, `bandWithTabs` 178, `bandCollapsed` 110, `detailBar` 110, `bottomBar` 68, `cameraButton` 56 (+ `cameraButtonLift` 16), `input` 48, çip yükseklikleri `chipSm/Md/Lg` 36/40/48, `touchVisible` 40, `iconInButton` 20, `icon` 24, sheet tutacağı `sheetHandleWidth/Height/Top` 36/4/8, referans çerçeve 402×874 (+ güvenli alan 62/34). Tek bileşene ait ölçü o bileşende adlandırılmış sabit olarak kalır.
- `AppRadius`: `xs` 4, `sm` 8, `md` 12, `lg` 16, `xl` 24, `full` 999. Hazır `radiusXx`/`borderXx` çiftleri, `sheetTop`, `bandBottom`, `barTop` ve `inner(outer, gap)` vardır. mihr_ui'de `MihrRadius.md` 8'dir ama tasarımdaki "radius-md" 12'dir. Bu yüzden ekran kodu `MihrRadius` ve `BorderRadius.circular(n)` kullanmaz (`app_radius.dart` doc'u). Kart: kenar yok, gölge yok, düz yuvarlak köşe.
- `AppShadows`: yalnız iki gölge vardır, `raised` (sürüklenen kart, kamera düğmesi, büyüteç) ve `overlay` (toast, ipucu, grafik balonu). Her biri açık ve koyu varyantlıdır (`raised(brightness)`, `raisedOf(context)`). Yüzeyin kenarı ya da gölgesi olur, ikisi birden olmaz. `AppBlur.bar` = 20, `AppBlur.scrim` = 8 sigma. `BackdropFilter` yalnız alt çubukta ve sheet perdesinde bulunur. Gölgeler rol olmadığı için `SmapColors` alanı değildir.

## 5. Hareket ve haptik

`AppMotion` süreleri:

| Ad | Süre | Kullanım |
|---|---|---|
| `instant` | 100 ms | Basılı durum |
| `fast` | 150 ms | Switch, çip, ikon geçişi, `reducedFade` |
| `base` | 250 ms | Segment, gösterge, akordiyon, toast, `sheetClose` |
| `slow` | 350 ms | Sheet açılışı, sayfa geçişi |
| `loop` | 1200 ms | İskelet ve spinner turu |

Eğriler `standard`, `enter`, `exit` ve `linear` adlarıyla tanımlıdır. `exitOf(entrance)` çıkış süresini girişin %70'i olarak verir. `pressedScale` 0,98, `shutterScale` 0,92, `sheetDismissFraction` 0,25, `sheetFlingVelocity` 700, `swipeCommitFraction` 0,30, `swipeCommitVelocity` 800 ve `shakeAmplitude` 6 (`shakeCycles` 3) sabitleri de buradadır.

`SmapDurations` ürün zamanlamalarını tutar: `toast` 4 s, `undoToast` 6 s, `skeletonTimeout` 15 s, `connectedNotice` 2 s, `codeResend` 30 s, `submitTimeout` 60 s, `readTimeout` 30 s, `searchDebounce` 150 ms, `usernameDebounce` 400 ms, `resetDayStagger` 150 ms.

`context.motion(duration, reduced:)` (`MotionContext`) "Hareketi azalt" açıkken `reduced` süresini döndürür. `reduced` zorunludur. Önceki bir yardımcı varsayılan olarak `Duration.zero` döndürüyordu ve opaklık geçişi sıçramaya dönüşüyordu (`docs/SMAP_UI_Rehberi_Duzeltmeler.md` #18). Kayma ya da ölçek 150 ms opaklık geçişine dönüşecekse `AppMotion.reducedFade` verilir. Anında olması gereken değişiklikte `Duration.zero` verilir. Repodan iki örnek:

```dart
// lib/features/auth/presentation/forgot_password/forgot_password_view.dart
duration: context.motion(
  AppMotion.slow,
  reduced: AppMotion.reducedFade,
),
// lib/features/auth/presentation/register/register_view.dart (kaydırma)
duration: context.motion(AppMotion.slow, reduced: Duration.zero),
```

`context.reduceMotion`, `MediaQuery.disableAnimations` değerini okur.

`AppHaptics` (`lib/core/services/app_haptics.dart`) tam dört çağrıdır ve yalnız sonuç anlarında kullanılır:

| Çağrı | Ne zaman |
|---|---|
| `selection()` | Seçim değişti: segment, sekme, çip, switch, onay kutusu, radyo, alt çubuk, köşe tutturma, program bloğu ekleme/çıkarma |
| `medium()` | Deklanşör (ve kamera düğmesi) |
| `success()` | Sonuç hazır, istek alındı, cevaplar onaylandı, "Öğrendim" |
| `error()` | Gönderme ya da okuma başarısız, doğrulama hatası, yanlış kod, kamera açılamadı, hata toast'u |

`selection` ve `medium` Flutter'ın `HapticFeedback`'idir. `success` ve `error` `smap/haptics` method channel'ı üzerinden gider; karşılıkları `ios/Runner/AppDelegate.swift` (`UINotificationFeedbackGenerator`) ve `android/app/src/main/kotlin/com/studentmap/smap/MainActivity.kt` (`CONFIRM`/`REJECT`, API 30 altında yedek) dosyalarındadır. Çağrılar ateşle-unut ve en iyi çabadır. Kanal yoksa (test, masaüstü) hata fırlatmaz. `AppHaptics.enabled = false` hepsini susturur. "Hareketi azalt" haptiği susturmaz (`docs/spec/SMAP_Flutter_Spec.md` §1.13). Haptik yalnız bu dört çağrıyla verilir, doğrudan `HapticFeedback` çağrılmaz.

Toast haptiği `ToastService` içindedir: `success` `AppHaptics.success()`, `error` `AppHaptics.error()` çalar (`haptic: true` varsayılan). Eylem kendi haptiğini zaten çaldıysa ya da pano başarı haptiği istemiyorsa `haptic: false` verilir. Örnekler: "Kopyala" `selection()` çalar ve "Kod kopyalandı." toast'unu haptiksiz gösterir (`lib/features/coach/application/coach_code_actions.dart`); profil kaydındaki "Profilin güncellendi." yalnız metindir (pano 14.9 kare 3, `profile_viewmodel.dart`). Alan hatası haptiği `AppFieldFrame` kendisi bir kez çalar.

## 6. Ders renkleri: `SubjectKey` ve `SubjectTone`

`SubjectKey` dokuz değerlidir: `turkce`, `edebiyat`, `tarih`, `cografya`, `matematik`, `geometri`, `fizik`, `kimya`, `biyoloji`. Her ders için iki tema renk çifti `SubjectTone(bg, fg)` tutulur (`SubjectTone.light` ve `SubjectTone.dark`, pano 1.5). `bg` ikon karosu ve tonu, `fg` ikon, 10 pt nokta ve ilerleme dolgusudur. `fg` kendi `bg`'si üzerinde en az 4,49:1 kontrast verir (`subject_tone.dart` doc'u).

Sunucudaki ders id'sini `SubjectKey`'e eşleme ve glif seçimi ders verisidir. `lib/features/lessons` altında yaşar: id eşlemesi `application/lesson_catalog.dart` (`LessonCatalog.byId`), ada göre yedeği `application/subject_resolver.dart` (`SubjectResolver.fromLessonName`), ikisini `domain/general_lesson.dart`'taki `subject` getter'ı birleştirir; glif tablosu (`subjectIcons`, `subjectFallbackIcon`) `presentation/widgets/subject_icons.dart`'ta, `SubjectGlyph` bileşeni `presentation/widgets/subject_glyph.dart`'tadır. Alan sabitleri `core/` içine girmez.

## 7. `SmapTheme` ve koyu tema

`lib/core/theme/smap_theme.dart`:

- `SmapTheme.light()` ve `SmapTheme.dark()` bir kez üretilir ve önbelleğe alınır. `SmapTheme.of(brightness)` da vardır.
- Temel `MihrTheme`'dir. `MihrThemeConfig` ile `brand: SmapPalette.navy`, `gray: SmapPalette.neutral`, Plus Jakarta Sans tipografisi, düz 12 yarıçaplı düğme teması (`MihrButtonShadows.flat`) verilir.
- `materialOverrides` şunları ayarlar: `colorScheme` (SmapColors'tan), `scaffoldBackgroundColor` (`bgCanvas`), birleştirilmiş `textTheme` (`textPrimary` ile renkli), `splashFactory: NoSplash` ve `materialTapTargetSize: padded`. Basılı durum ripple ile değil ton ve 0,98 ölçekle gösterilir.
- `extraExtensions: [colors, text]` ile `SmapColors` ve `SmapText` temaya eklenir.

Tema `lib/app/app.dart` içinde `MaterialApp.router`'a `theme: SmapTheme.light()`, `darkTheme: SmapTheme.dark()` ve `themeMode: AppThemeMode.current` olarak verilir. `lib/app/app_theme_mode.dart`:

```dart
static ThemeMode get current {
  if (kDebugMode) {
    final forced = of(_define);
    if (forced != null) return forced;
  }
  return ThemeMode.system;
}
```

- Varsayılan `ThemeMode.system`'dir (karar K9). Uygulama içinde tema seçici yoktur.
- `THEME_MODE` yalnız debug derlemede etkilidir, release tanımı yok sayar. `flutter run --dart-define=THEME_MODE=dark` (`dark`, `light` ya da `system`) ile zorlanır. Tanınmayan değer `null` döndürür ve sistem modu kalır.
- Git geçmişi: `af77873` `THEME_MODE`'u ekledi, varsayılan açıktı. `d4aec97` koyu tema denetimi (FIN1) bitince varsayılanı `ThemeMode.system` yaptı.
- Galeri tema modunu `THEME_MODE` ile değil kendi anahtarıyla seçer (bölüm 12).

Koyu temada bilinen davranışlar:

- Lacivert bant (`bgNavy`) iki temada da aynıdır, üstündeki ikonlar her zaman açıktır.
- `AppLogoMark` ve `AppLockup` koyu temada otomatik `onNavy` tonunu (beyaz kanca ve yazı) seçer (`lib/shared/ui/identity/app_logo.dart`).
- Alt çubuk seçili sekme ikonu koyuda `textPrimary` olur. Lacivert koyu zeminde kontrast vermez (`app_nav_tab.dart` doc'u).

## 8. Sistem çubuğu: `AppSystemOverlayRegion`

`lib/shared/ui/navigation/app_system_overlay.dart` üç yüzey türü tanımlar (`AppSystemOverlayKind`):

| Tür | Durum çubuğu ikonları |
|---|---|
| `band` | Her iki temada açık ikon (lacivert bant) |
| `bar` | Açıkta koyu, koyuda açık ikon (detay çubuğu, canvas üstünde) |
| `camera` | Her iki temada açık ikon |

`AppSystemOverlay.of(kind, brightness)` `SystemUiOverlayStyle` üretir. Durum çubuğu ve Android gezinme çubuğu şeffaftır. `AppSystemOverlayRegion(kind:, child:)` çocuğunu `AnnotatedRegion<SystemUiOverlayStyle>` ile sarar. En üst kenardaki en üstteki bölge kazanır. Kök ve detay çubukları kendi bölgelerini kendileri koyar (`app_root_band.dart`, `app_home_band.dart`, `app_detail_bar.dart`). Bant ve çubuk kullanmayan ekranlar (kamera akışı, açılış, durum ve hata ekranları, hesap silme sonu) bölgeyi kendileri sarar. Örnekler: `lib/features/scan/presentation/capture/scan_capture_view.dart`, `lib/features/startup/presentation/startup/startup_view.dart`.

## 9. `lib/core/utils`

**`TrFormat`** (`tr_format.dart`) tüm sayı ve tarih biçimlerinin tek kapısıdır. Widget içinde `toStringAsFixed`, elle yazılmış "%" ya da `DateFormat` kullanılmaz.

| Çağrı | Sonuç |
|---|---|
| `net(67.5)`, `net(68)`, `net(74.75)` | `67,5`, `68`, `74,75` |
| `puan(412.63)`, `puan(381.4)` | `412,63`, `381,40` |
| `sira(48215)`, `siraOrdinal(48215)` | `48.215`, `48.215.` |
| `yuzde(5, 12)` | `%42` |
| `delta(8.25)`, `delta(-1.5)` | `+8,25`, `−1,5` |
| `kisaTarih(DateTime(2026, 10, 5))` | `5 Eki.` |
| `uzunTarih(DateTime(2026, 9, 15))` | `15 Eylül 2026` |

Diğer üyeler: `yuzdeOrNull`, `kisaTarih(withYear:)`, `uzunTarihGun`, `gunKisa`, `gunAdi`, `saat`, `saatParcali` ve `monthsShort`, `months`, `weekdaysShort`, `weekdays` tabloları.

Kurallar kodda zorlanır:

- Negatif sayı gerçek eksi işaretiyle (U+2212) yazılır, tire kullanılmaz. Sıfıra yuvarlanan değer işaretsizdir (`puan(-0.001)` → `0,00`).
- `yuzde` toplam ≤ 0 ise `ArgumentError` fırlatır. Toplam sıfır olabiliyorsa `yuzdeOrNull` kullanılır. Soru yoksa halka çizilmez ve "Soru yok" yazılır.
- Gün ve ay adları sabit tablodur. `DateFormat('MMM', 'tr')` `initializeDateFormatting('tr')` çalışana kadar hata verir ve kısa ay için gereken sondaki noktayı vermez. Tablolar intl `tr` verisine eşittir, bunu `test/core/utils/tr_format_test.dart` ("the name tables equal intl tr data") doğrular.

**`TurkishText`** (`turkish_text.dart`) UTF-16 birimi birimi çalışır. `lower`, `upper` ve `fold` uzunluğu korur. Bu nedenle katlanmış metinde bulunan ofset orijinalde de geçerlidir (arama vurgusu bunu kullanır).

- `lower` ve `upper`: "I" ile "İ" ve "ı" ile "i" eşlemesi doğru yapılır. `upper` ürün için değil, kod ve sıralama anahtarı gibi veri içindir. Arayüzde büyük harf metin yoktur.
- `capitalize`, `titleCase` ("MEHMET ÖZKAN" → "Mehmet Özkan").
- `fold`, `contains`: "cay", "Çay"ı bulur.
- `matchesTokens` ve `matchRanges`: "mehmet oz", "Mehmet Özkan"ı bulur. Vurgu aralıklarını verir (`HighlightText` kullanır).
- `collationKey` ve `compare`: Türk alfabesi sırası. "Çay", "Cam" ile "Dolap" arasına girer.

**`TurkishSuffix`** (aynı dosya) çalışma zamanında üretilen metinlere ek uyumu getirir: `dative`, `accusative`, `genitive`, `locative`, `ablative`, `possessive`, `possessiveAccusative`. Ek, kelimenin yazılışına göre değil okunuşuna göre seçilir: "9" "dokuz" diye okunur, "TYT" harf harf okunur. Örnekler: `possessive('9')` → `9'u`, `dative('TYT')` → `TYT'ye`, `genitive('Mehmet Özkan')` → `Mehmet Özkan'ın`. Bilinçli sınırlar: kesme işaretli kelime özel ad sayılır, ünsüz yumuşaması yapılmaz ("Çiçek'e"). `saat`, `kalp` gibi uyumu bozan kelimeler özel ele alınmaz. Kullanım yerleri: `AppContextStrip` (isim + genitif), `LastExamSummary.wrongAccusative`, program ve konu seçici durumları.

## 10. Türkçe metin kuralları (`AGENTS.md` "Copy" ve kod)

- Vazgeçme düğmesi "Vazgeç"tir, "İptal" yazılmaz. ARB'de `common_cancel` bunun için vardır ve açıklaması "Never use 'İptal'" der. "Tamam" onay içindir. "Kapat" yalnız erişilebilirlik etiketinde kullanılır (`common_close`). "Geri Al" yalnız toast eylemidir (`common_undo`). "Tekrar Dene" (`common_retry`) hata durumu eylemidir. Not: `lib/l10n/arb/schedule_tr.arb` içindeki `schedule_cancelProgram` "Programı İptal Et" bir program iptali eylemidir, vazgeçme düğmesi değildir. Kural vazgeçme düğmesi içindir.
- "Sen" tonu kullanılır, emoji yoktur, hepsi büyük harf metin yoktur. Soru başlıkları cümle düzeninde ("Kartı Bildiklerim'e taşıyalım mı?"), ekran ve sheet başlıkları Türkçe başlık düzeninde yazılır ("Detaylı Analiz"). Düğme etiketi de başlık düzenindedir.
- Sayı ve tarih yalnız `TrFormat` üzerinden yazılır (`67,5`, `412,63`, `48.215`, `%42`, `5 Eki.`).
- l10n anahtarı `<feature>_<camelCase>` biçimindedir. Ortak olanlar `common_*`, yalnız ekran okuyucuya özgü olanlar `…A11y` ile biter (`kit_percentA11y`, `kit_pageDotsA11y`). Her feature kendi `lib/l10n/arb/<feature>_tr.arb` dosyasına yazar (kit için `kit_tr.arb`, `kit2_tr.arb`; ortak için `common_tr.arb`). Her anahtarın `@key.description` alanı, metnin nerede ve ne için kullanıldığını İngilizce anlatır. Ekran metinlerinde çoğunlukla panoyu ve kareyi de anar (`pano 10.4 kare 2`, `brief 14.1 kare 4`). Ortak (`common_*`) ve panoda karşılığı olmayan metinlerde pano atfı yoktur. `lib/l10n/app_tr.arb` `dart run tool/merge_arb.dart` ile üretilen dosyadır, elle düzenlenmez; aynı anahtar iki parçada varsa script hata verir. Sonra `flutter gen-l10n` çalışır. CI bayat çıktıyı reddeder (`.github/workflows/ci.yml`).
- Türkçe metinde `toUpperCase()` kullanılmaz, `TurkishText` kullanılır. `toUpperCase` kodda yalnız Türkçe olmayan veride durur (`schedule_wire.dart` hex renk, `coach_code.dart` kod, `answer_grid.dart` seçenek harfi).
- Çalışma zamanında üretilen cümlede ek uyumu `TurkishSuffix` ile yapılır.
- ViewModel'ler `BuildContext`'siz olduğu için toast metnini `ToastText` lambda'sı ile verir: `_toast.success((l) => l.schedule_toastProgramCancelled);` (`program_detail_viewmodel.dart`). Metin toast'un çizildiği yerde çözülür ([03_ekran.md](03_ekran.md) §4.3).
- Doc yorumları ve tanımlayıcılar İngilizcedir, arayüz metni Türkçe alıntılanır. Doc yorumu panoyu ve kareyi ve Türkçe metni alıntılar (`AGENTS.md` "UI rules" son maddesi).

## 11. Pano atıfları ve `docs/design`

Tasarım panoları repoda `docs/design/` altındadır; klasör haritası ve "yeni tur geldiğinde" adımları `docs/design/README.md`'dedir. Özet:

| Yol | İçerik |
|---|---|
| `docs/design/kaynak/SMAP-00.html` … `SMAP-14.html` | Tasarım aracının tur tur dışa aktardığı asıl dosyalar. |
| `docs/design/panolar/png/SMAP-NN_<pano>.png` | Her panonun görüntüsü. Ekran yazarken yanında açık tutulur. |
| `docs/design/panolar/SMAP-NN/<pano>/text.txt` | Panonun bütün metni: kare açıklamaları, Bileşenler, Kural, Veri, Varsayımlar, Erişilebilirlik. Metinler birebir buradan alınır. |
| `docs/design/panolar/SMAP-NN/<pano>/board.html` | Çizilmiş HTML ve CSS: kesin ölçü, renk, boşluk. |
| `docs/design/panolar/AKIS.md` | 13.x akış panolarının metni: ekranlar arası geçişler. |
| `docs/design/kil/`, `magaza/`, `tasarim-paketi/`, `brifler/` | Kil görselleri (pano 1.25), mağaza görselleri, tasarıma gönderilen paket ("D-n" ve "Ek C" atıflarının metni), ilk promptlar. |

Yeni bir tur geldiğinde `kaynak/` altına dosya konur ve `python3 tool/design/html_to_boards.py docs/design/kaynak/SMAP-NN.html` ile panolara çevrilir (Chrome gerekir; ayrıntı README'de ve [05_araclar.md](05_araclar.md)'de).

Doc yorumlarındaki "pano X.Y · kare N" şu anlama gelir:

- Pano X.Y, `docs/design/panolar/SMAP-<X, iki haneli>/` (ör. `SMAP-01`, `SMAP-11`) altındaki `NN-X-Y-<başlık>` klasörüdür (NN klasördeki sıra numarasıdır; istisna: Tur 12 akışları 13.13 ve 13.14 `SMAP-14` altındadır). Örnek: **pano 1.9**, `docs/design/panolar/SMAP-01/08-1-9-Düğmeler-5-tür-2-boy/` (içinde `text.txt`, `board.html`, `styles.css`); görseli `docs/design/panolar/png/SMAP-01_08-1-9-Düğmeler-5-tür-2-boy.png`.
- "kare N" aynı panodaki N. çerçevedir (soldan sağa). Örnek: **pano 3.1 kare 2**, Anasayfa panosunda kaydırılmış bant. `lib/features/home/presentation/home/home_view.dart` doc'u "pano 3.1 kare 1 to 3, 3.2 kare 1 to 4, 3.3" der.
- 11.x panoları teslim notlarıdır (`SMAP-11`). 11.12 Token Tablosu, 11.13 Bileşen Listesi, 11.14 Ekran-Bileşen Eşlemesi, 11.15 Hareket ve Haptik, 11.16 Varsayımlar ve Tur 12 ekleri (11.13 ek, 11.14 ek, 11.16 ek: T12.1–T12.30) önceki panoların önüne geçer (`AGENTS.md` "Sources of truth").
- **Tur 12 panoları `SMAP-14`'tür** (14.1–14.12; sonunda akışlar 13.13 ve 13.14 de aynı `SMAP-14` sayfasındadır: `panolar/SMAP-14/12-13-13-…`, `13-13-14-…`; `SMAP-13/` yalnız 13.1–13.12'yi içerir). "Yerine geçtiği kare: 10.4·3" gibi etiketlerle eski kareleri geçersiz kılarlar. Çelişki sırası `docs/design/README.md` "Öncelik" bölümündedir: proje kararları (`docs/SMAP_Ana_Plan.md` K1–K16 ve `docs/SMAP_UI_Rehberi_Duzeltmeler.md`), Tur 12, teslim panoları 11.12–11.16, diğer panolar.
- Spec C-numaraları (C01–C86), `docs/spec/02_bilesenler.md` ve `docs/spec/SMAP_Flutter_Spec.md` içindeki bileşen kimlikleridir. UI rehberi kısaltması "§5 #N" `docs/SMAP_UI_Uygulama_Rehberi.md`'ye gider. Düzeltmeler "Düzeltmeler #N" `docs/SMAP_UI_Rehberi_Duzeltmeler.md` içindedir ve rehberin önüne geçer.

Doc yorumu örneği (`lib/shared/ui/buttons/app_button.dart`):

```dart
/// The text button of the app (C01 "Button"; board 1.9 "Düğmeler · 5 tür ·
/// 2 boy"; UI guide §5 #1).
```

Spec adı `SmapX` ise kodda genel bileşen `AppX`, alan bileşeni `X` olur: `SmapNetChart` → `NetChart`, `SmapBottomBar` → `AppBottomBar`, `SmapContextStrip` → `AppContextStrip`. Yeni bileşende C-numarası doc yorumunda korunur. Her widget'ın doc'u panosunu ve karesini verir ve Türkçe metni alıntılar. Panoyu açarken `text.txt` ölçüler ve kurallar için, `board.html` kesin CSS için kullanılır. Panodaki örnek veriler ("Ek C" veri seti) testlerde aynen kullanılır; uygulamada sahte veri gösterilmez.

## 12. Bileşen galerisi

Galeri, kit ve alan bileşenlerini iki temada, her durumuyla (normal, basılı, odak, pasif, yükleniyor, hata) gösteren debug aracıdır. UI galeride ve simülatörde doğrulanır (`AGENTS.md`: golden testi yazılmaz; widget testi yalnız ölçülen boy ya da ekran okuyucu cümlesi içindir, ör. `test/features/exams/presentation/exam_score_card_height_test.dart`).

**Çalıştırma** (`lib/main_gallery.dart`):

```
flutter run -t lib/main_gallery.dart
flutter run -t lib/main_gallery.dart --dart-define=GALLERY_DARK=true --dart-define=GALLERY_PAGE=7
```

- Router'sız ve DI'sız çalışır. Düz `MaterialApp`, `SmapTheme` açık ve koyu, `AppLocalizations` (tr) ve ana sayfa olarak `ComponentGalleryView`. `locator`, oturum ve router'a dokunmaz (`docs/SMAP_UI_Rehberi_Duzeltmeler.md` #22).
- `FocusHighlightStrategy.alwaysTraditional` ile klavye odak halkaları hep görünür (Tab ile denenir).
- `ComponentGalleryView` (`lib/features/debug/component_gallery_view.dart`) üstte üç çip içerir: "Koyu tema", "Metin 1,35" ve "Hareketi azalt". Altında `AppTabBar` (kaydırılabilir) ve seçilen sayfa vardır; sayfa `GalleryPageFrame` içinde kaydırılır.
- Çipler `GallerySettings` (`gallery_settings.dart`) üzerinden `ThemeMode`, `MediaQuery.textScaler` (1,35, tasarımın 1,3 sınırının biraz üstü, `GallerySettings.largeTextScale`) ve `MediaQuery.disableAnimations` değerlerini uygular.

**Başlangıç değişkenleri.** Bir kısmı `--dart-define` ile, bir kısmı yalnız süreç ortamı ya da dosya ile okunur:

| Ad | Etki | Nasıl verilir |
|---|---|---|
| `GALLERY_DARK` | Koyu tema başlangıcı (`true`) | launch env, yoksa `--dart-define` |
| `GALLERY_LARGE_TEXT` | Metin 1,35 | launch env, yoksa `--dart-define` |
| `GALLERY_REDUCE_MOTION` | Hareketi azalt | launch env, yoksa `--dart-define` |
| `GALLERY_PAGE` | İlk sekme indeksi (0 tabanlı) | launch env, yoksa `--dart-define` |
| `GALLERY_SCROLL` | Sayfa başlangıç kaydırması (piksel) | **yalnız** launch env |
| `GALLERY_ACTION` | Sayfa açılışında bir sheet/toast/şerit gösterir | **yalnız** launch env |
| `GALLERY_SEMANTICS` | `true` ise anlamsal ağaç hata ayıklayıcısı çizilir | **yalnız** launch env |

Launch env, `lib/features/debug/launch_env.dart` içindeki `debugLaunchEnv(name)` ile okunur. Önce `Platform.environment[name]`, yoksa `<systemTemp>/launch_env/<name>` dosyası okunur. iOS 26 simülatörlerinde `SIMCTL_CHILD_GALLERY_DARK=true xcrun simctl launch …` uygulamaya ulaşmaz; değeri yeniden derlemeden vermenin yolu dosyadır: `tool/sim_env.sh booted GALLERY_PAGE=12 GALLERY_DARK=true` dosyaları uygulamanın veri klasörüne yazar, sonra uygulama başlatılır (`tool/sim_env.sh booted --clear` siler). Aynı değişken hem env'de hem `--dart-define`'da varsa env kazanır. `GALLERY_SCROLL`, `GALLERY_ACTION` ve `GALLERY_SEMANTICS` yalnız `debugLaunchEnv` okuduğu için `--dart-define` ile verilirse etkisizdir. `debugLaunchEnv` `dart:io` kullanır; galeri web için tasarlanmamıştır. Aynı mekanizmayı kabuk önizlemesi de kullanır: `SHELL_PREVIEW=student|coach` (`--dart-define`, yalnız `kDebugMode`) ve `SHELL_PREVIEW_TAB` (launch env), `lib/app/shell/shell_preview.dart`.

`GALLERY_ACTION` değerleri:

- Sheet sayfası (`sheets_gallery.dart`): `small`, `medium`, `full`, `confirm`, `confirmDanger`, `time`, `soon`.
- Durum sayfası (`feedback_gallery.dart`): `toastInfo`, `toastSuccess`, `toastError`, `toastUndo`, `offline`.

**Sayfa kaydı.** `lib/features/debug/gallery_registry.dart` `galleryPages` listesini tutar. Her kayıt `GalleryPage(title:, builder:)`'dır. Sıra sekme sırasıdır, yani `GALLERY_PAGE` indeksidir:

| İndeks | Başlık | Sayfa sınıfı |
|---|---|---|
| 0 | Düğmeler | `ButtonsGallery` |
| 1 | Segment ve Sekme | `ControlsGallery` |
| 2 | Çipler ve Seçimler | `ChoicesGallery` |
| 3 | Girdiler | `InputsGallery` |
| 4 | Yüzeyler | `SurfacesGallery` |
| 5 | Göstergeler | `IndicatorsGallery` |
| 6 | Kimlik | `IdentityGallery` |
| 7 | Sheet | `SheetsGallery` |
| 8 | Durum | `FeedbackGallery` |
| 9 | Kabuk | `NavigationGallery` |
| 10 | Alan | `DomainGallery` |
| 11 | Program | `PickersGallery` |
| 12 | Koç | `CoachGallery` |

**Sayfa ekleme.** Sayfa dosyası `lib/features/debug/pages/<ad>_gallery.dart` altındadır. Düz bir widget'tır (çoğunlukla `Column` of `GallerySection`); `GalleryPageFrame` kaydırma alanını ve 16 pt kenarı `ComponentGalleryView` verir. Tema, ölçek ve hareket ayarlarını çevreden alır. `gallery_widgets.dart` yardımcıları: `GalleryPageFrame`, `GallerySection(title:, note:, children:)` (başlıkta "AppButton · C01 · pano 1.9" biçimi), `GalleryState` (etiketli demo), `GalleryWrap`, `GalleryPanel(tone: GalleryTone.canvas|surface|raised|navy)`, `GalleryNote`, `GalleryLabel`, `GalleryOnNavyLabel`, `GalleryLargeText` (o demoyu 1,35 ölçekte gösterir). Başlık ve notlar Türkçe literaldir ve galeri ARB kullanmaz. Gerçek örnek (`controls_gallery.dart` biçiminde):

```dart
GallerySection(
  title: 'AppSegmented · C04 · pano 1.10',
  note: 'Başparmak 250 ms kayar; seçenek genişliği etikete göre. ...',
  children: [
    GalleryState(
      label: '2 seçenek',
      child: AppSegmented<String>(
        segments: const [
          AppSegment(value: 'TYT', label: 'TYT'),
          AppSegment(value: 'AYT', label: 'AYT'),
        ],
        value: _two,
        onChanged: (v) => setState(() => _two = v),
      ),
    ),
```

Sonra `gallery_registry.dart`'a `import` ve `GalleryPage(title: '...', builder: (_) => const XGallery())` satırı eklenir. Bu dosya paylaşılan dosyadır (`../WORKFLOW.md` §5): paralel çalışırken tek elden düzenlenir. Eksik genel bileşen `shared/ui`'a ve aynı değişiklikte galeri sayfasına girer (`AGENTS.md` "Build from `lib/shared/ui`"). `lib/features/debug` de `tool/ui_rules.sh` kapsamındadır; galeri kodunda da ham renk ya da `TextStyle(` yazılamaz (dosya boyu sınırı galerilere uygulanmaz).

## 13. `tool/ui_rules.sh`

CI'da biçim denetiminden (`tool/format.sh --output=none --set-exit-if-changed`; git'te izlenen bütün Dart dosyaları, `lib/vendor` hariç) ve `flutter analyze --no-pub`'tan sonra çalışır (`.github/workflows/ci.yml`). `lib/features`, `lib/shared` ve `lib/app` altındaki `*.dart` dosyalarını `grep -E` ile tarar. `.gr.dart` dosyalarını ve satır `//` ile başlayan satırları (doc yorumları dahil) atlar. Çıkış kodu 0 değilse CI düşer. Bu belge yazılırken betik 0 ile çıkıyordu.

| Yasak kalıp | Sebep |
|---|---|
| `Color\(0x` | Renk yalnız rol olarak `context.appColors`'tan gelir. Tema değişince değer rolün arkasında değişir (11.12: "Ekran kodu yalnız rol adlarını kullanır"). |
| `Colors.` | Aynı sebep. Kalıp `SmapColors.` ve `.Colors`'u yakalamaz. |
| `TextStyle(` | Yazı yalnız `context.appText` ve `copyWith(color:)`. |
| `fontSize:` | Boyut yalnız `SmapText` stilinden gelir. |
| `Icons.` ve `CupertinoIcons.` | İkonlar yalnız Phosphor. Kalıp `PhosphorIcons.`'ı yakalamaz. |
| `showDialog`, `AlertDialog`, `showModalBottomSheet`, `SnackBar(` | Tüm diyaloglar `AppSheet`, toast `ToastService`. |
| `MaterialPageRoute`, `Navigator.push` | Gezinme auto_route ile. |
| `print(` | `AppLogger` kullanılır. Kalıp `debugPrint(`'i yakalamaz. |
| `Widget _build` | `Widget _buildX()` yardımcıları yerine sınıf widget'ı. |
| `Duration(` | Sunumda (`lib/features/*/presentation`, `lib/shared/ui`) süre `AppMotion`/`SmapDurations`'tan. `Duration.zero` yakalanmaz. Data ve application katmanında ham `Duration` meşrudur (örnek `auth_requests.dart`). |
| Dosya boyu | `part of` dosyası 300, `*_viewmodel.dart` 500, `presentation/*_view.dart` 250, `lib/features/*/presentation` ve `lib/shared/ui` altındaki diğer dosya 400 satır. Üretilen kod ve `/debug/` galerileri sayılmaz. |

**Betiğin denetlemediği kurallar.** `AGENTS.md` bunları da yasaklar ama betikte kalıbı yoktur, inceleme ve analyze ile tutulur: mihr renk ve tipografi getter'ları, `Text`'te string literal, `SharedPreferences.getInstance` (tercihler `DevicePreferences` üzerinden), `toUpperCase`. Taranan dizinler `lib/core`'u içermez; ham renk literalleri yalnız orada, token dosyalarında bulunur (`smap_palette.dart`, `smap_colors.dart`, `subject_tone.dart`, `app_shadows.dart`; `lib/vendor`'daki üçüncü taraf tarayıcı paketi hariç). `analysis_options.yaml` `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, `prefer_const_declarations`, `use_decorated_box` ve `avoid_print` kurallarını açar. CI `flutter analyze`'ın sıfır sorun vermesini şart koşar.

## 14. `lib/shared/ui` kit kataloğu

Tablolar klasör klasördür. "Pano" sütunu doc yorumundaki atıftır; "Ne zaman" sütunu kullanım yerini ve önemli parametreleri verir. C-no, doc yorumundan alınmıştır, yoksa yazılmamıştır. Kitin saf mantık dosyaları (`*_math.dart`, `*_layout.dart`, `*_logic.dart`) widget'tan ayrıdır ve birim testlidir (`test/shared/ui/**`). Tam parametre listesi için dosyanın kurucusuna bakın.

### 14.1 `buttons/`

| Bileşen | Dosya | Ne zaman | Pano |
|---|---|---|---|
| `AppButton` (C01) | `app_button.dart` | Her metin düğmesi. `variant`: `primary`, `outline`, `quiet`, `danger`, `text`, `textDanger`; `size`: `lg48`, `md40`; `icon`, `trailingIcon`, `loading`, `expand`, `disabledReason`. mihr_ui düğme ailesinin üstüne kuruludur (bölüm 16). | 1.9 |
| `AppButtonStyles`, `AppButtonVariant`, `AppButtonSize` | `app_button_style.dart` | `ButtonStyle` çözümleyici. Ekran kodu doğrudan çağırmaz. | 1.9 |
| `AppIconButton` (C02) | `app_icon_button.dart` | Yalnız ikon düğme, 48×48 hedef. `semanticLabel` zorunlu (tooltip de olur); `variant` (`onNavy` dahil), `selected`, `selectedIcon`. | 1.9 |
| `AppBarAction` (C03) | `app_bar_action.dart` | Detay çubuğunun sağ eylemi ("Düzenle", "Yeni Program"), 40 yüksek; `field` ile girdi yanındaki 48'lik hali. | 1.18 |
| `AppFocusRing` | `app_focus_ring.dart` | Klavye odak halkası. `focused`, `style` (`gapped`, `flush`, `inset`), `gapColor`, `borderRadius`. | 1.9, spec §1.4 |
| `AppPressable` | `app_pressable.dart` | Özel çizimli kontrollerin etkileşim kabuğu (basılı, odak, Enter/Space, 0,98 ölçek, haptik). `builder`, `onTap`, `onLongPress`, `scale`, `haptic`. | |
| `PressScale` | `press_scale.dart` | Basılıyken çocuğu küçültür (0,98 düğme, 0,97 hücre, 0,92 deklanşör). | 1.8 |

### 14.2 `controls/`

| Bileşen | Dosya | Ne zaman | Pano |
|---|---|---|---|
| `AppSegmented<T>` + `AppSegment` (C04) | `app_segmented.dart` | Aynı listenin görünümünü değiştirir. `segments`, `value`, `onChanged`, `onNavy`. Sayaçlı seçenek iki satırlıdır. Görsel 44, dokunma 48. | 1.10 |
| `AppTabBar` (C05) | `app_tab_bar.dart` | İçeriği tamamen değişen ekran içi sekme. `labels`, `selectedIndex`, `onChanged`, `scrollable` (null ise otomatik), `onNavy`. | 1.10 |
| `AppChip` (C06) | `app_chip.dart` | Seçilebilir hap çip. `label`, `onTap`, `selected`, `size` (`AppChipSize` sm36, md40, lg48), `icon`, `dotColor` (ders çipi), `AppChip.square`. | 1.11 |
| `AppChipGroup<T>` + `AppChipItem` (C06) | `app_chip_group.dart` | Sarmalanan çip kümesi. `items`, `selected`, `onChanged`, `exclusive`. | 1.11 |
| `AppFilterPill` (C06) | `app_chip_group.dart` | 40 pt süzgeç hapı. `label`, `onTap`, `selected`, `icon`, `opensSheet`. | 1.11 |
| `AppTag` (C07) | `app_tag.dart` | Tıklanamaz nötr etiket. `label`, `icon`, `dot` ("Bu hafta"). | 1.11 |
| `AppCheckbox` (C14) | `app_checkbox.dart` | Onay kutusu satırı. `value`, `onChanged`, `label` ya da `labelChild`, `semanticLabel`. | 1.13 |
| `AppRadio<T>`, `AppRadioListTile<T>`, `AppRadioGroup<T>` (C15) | `app_radio.dart` | Radyo işareti, sheet satırı ve grup kabı. Tile: `value`, `groupValue`, `onChanged`, `title`, `horizontalPadding`. | 1.13 |
| `AppSwitch` (C16) | `app_switch.dart` | Açma kapama. `value`, `onChanged`, `semanticLabel`. | 1.13 |
| Yardımcılar | `clear_color.dart`, `segment_layout.dart`, `tab_layout.dart` | `color.clear`; segment ve sekme yerleşim mantığı. | |

### 14.3 `inputs/`

| Bileşen | Dosya | Ne zaman | Pano |
|---|---|---|---|
| `AppFieldFrame`, `AppFieldMessage` (C09) | `app_field_frame.dart` | Tüm girdilerin ortak kabuğu (etiket, kutu, yardım ve hata satırı). | 1.12 |
| `AppTextField` (C09) | `app_text_field.dart` | Tek satır girdi. `label` zorunlu; `controller`, `hintText`, `helperText`, `errorText`, `successText`, `checking`, `password`, `optional`, `keyboardType`, `inputFormatters`, `autofillHints`, `maxLength`, `onChanged`. `readOnly` kilit ikonu ve salt okunur görünüm verir; `readOnlyLock` (varsayılan `true`) `false` ise kilit çizilmez (gönderirken kısa süre kilitlenen alan, pano 14.10 kare 4). `semanticLabel` ekran okuyucuda etiketin yerine okunur ("Koçluk kodu, 4 harf ve 4 rakam"). | 1.12 |
| `AppSearchField` (C10) | `app_search_field.dart` | Arama alanı. `semanticLabel`, `hintText`, `onQueryChanged`, `debounce`. | 1.12 |
| `AppCodeInput` (C11) | `app_code_input.dart` | 6 haneli kod, tek gizli alan, yapıştırma ve otomatik doldurma. `label`, `controller`, `errorText`, `errorShake`, `onCompleted`. | 1.12 |
| `AppSelectField<T>` + `AppSelectOption` (C12) | `app_select_field.dart` | Değeri sheet'te seçtiren alan. `label`, `options`, `value`, `onChanged`, `sheetTitle`, `hintText`, `errorText`. | 1.12, 1.20 |
| `AppTextArea` (C13) | `app_text_area.dart` | Çok satırlı girdi. `label`, `maxLength` (sayaç), `minHeight`. | 1.12 |
| `AppInputMasks` (C09 "masked") | `input_masks.dart` | `phone` (`+90 5XX XXX XX XX`) ve `coachCode` (`MOZK-4821`: 4 harf, ilk rakamla gelen tire, 4 rakam; `AAAA-0000` biçimi, Koçluk ekranı ve "Koçu Değiştir" sheet'i) biçimleyicileri. | 1.12 |
| Yardımcılar | `code_input_logic.dart` | Kod girdisi mantığı. | |

### 14.4 `feedback/`

| Bileşen | Dosya | Ne zaman | Pano |
|---|---|---|---|
| `AppToast` (C74) | `app_toast.dart` | Toast gövdesi. Doğrudan değil `ToastService` ile kullanılır. `ToastHost`, `OverlayToastPresenter` (`toast_host.dart`), `ToastSlot`, `ToastPlacement`, `AppToastKind` (`info`, `success`, `error`), `ToastText` (`toast_slot.dart`) çizim ve zamanlama parçalarıdır. | 1.22 kare 1 |
| `AppOfflineStrip` (C75) | `app_offline_strip.dart` | Çevrimdışı şerit, yerleşimde yer kaplar. `online`; `AppOfflineStrip.service(...)`. Kabuk çizer (`lib/app/shell/widgets/shell_offline_strip.dart`); sheet üstünde `AppSheet.show(online:)` ile. Faz makinesi `OfflineStripController` (`offline_strip_logic.dart`) ayrıdır. | 1.22 kare 6 |
| `AppSkeleton` + `SkeletonBox` (C76) | `app_skeleton.dart` | Tek shimmer ile iskelet. `SkeletonBox`: `width`, `height`, `radius`, `circle`, `SkeletonBox.chart`. | 1.22 kare 2 |
| `AppEmptyState` (C77) | `app_empty_state.dart` | Boş durum. `.screen`: `title`, `message`, `actionLabel`, `onAction`, `actionIcon`, `illustration` (128 pt kil, en çok bir), `topPadding`. `.section`: kart; `message`, isteğe bağlı `title` (kalın ilk satır), `actionLabel`/`onAction`; `primaryAction: true` ile eylem metin düğmesi yerine tam genişlik birincil düğme olur. | 1.22 kare 3–4, 14.1 kare 4 |
| `AppClay` (C61) | `illustrations/app_clay.dart` | Kil görseli (pano 1.25): `AppClay.medium(ClayPicture.ampul)` boş durumda (M 128), `AppClay.large(...)` tanıtımda (L 160); ders eşlemesi `ClayPicture.forSubject`. Salt süs, temaya bakmaz. | 1.25, 11.18, 2.2 kare 5 |
| `AppErrorState` (C78) | `app_error_state.dart` | Hata durumu, "Tekrar Dene" ile. `.screen`: `title`, `message`, `onRetry`, `retryLabel`, `topPadding`. `.section`: kart; `message`, `onRetry`, isteğe bağlı `title` (başlık 15/24 · 600, ileti altında sade cümle). Hiçbir düzeyde haptik yok. | 1.22 kare 4–5, 14.3 kare 2 |
| `AppStateLevel`, `AlignedTextAction` (C77 "dolgu 0") | `app_state_level.dart` | Durum düzeyi (`screen`, `section`); metin düğmesini yan dolgusuz çizer. | |
| `AppStatusView` (C79) | `app_status_view.dart` | Tam ekran durum (açılış, bakım, hesap silme). Kendi `Material`'ını verir. `title`, `message`, `tone` (`AppStatusTone`), `icon`/`leading`, `size` (`AppStatusSize`), `primary`/`secondary` (`AppStatusAction`), `blocking`, `onClose`; `AppStatusView.busy` bekleme ekranı. | 2.7, 4.10, 9.4 |
| `SectionState`, `AsyncSection<T>`, `SkeletonWatchdog` | `section_state.dart` | Bölüm durumu (`loading`, `ready`, `empty`, `error`, `offline`) için değişmez değer. `AsyncSection.load(fetch, isEmpty:)` 15 sn iskelet sınırıyla çalışır ve asla fırlatmaz ([03_ekran.md](03_ekran.md) §6). | 1.22 |

### 14.5 `identity/`

| Bileşen | Dosya | Ne zaman | Pano |
|---|---|---|---|
| `AppAvatar` (C55) | `app_avatar.dart` | Kişi avatarı, görsel yoksa baş harfler. `name`, `image`, `size` (`AppAvatarSize`), `coach` ("Koç" rozeti), `decorative`. | 1.17 |
| `AppAvatarStack` (C56) | `app_avatar_stack.dart` | Üst üste avatarlar ve "+N". `people`, `maxShown`, `AppAvatarStack.large`. | 1.17 |
| `AppAvatarPicker` (C57) | `app_avatar_picker.dart` | Yedi avatarın hepsini gösteren seçici. `avatars`, `selectedIndex`, `onChanged`, `size`, `showCount`, `gapColor`. Radyo hâli: `groupLabel` ("Avatar, 7 seçenek") ve `optionLabelOf` ("Avatar 4 / 7") verilince radyo grubu olarak okunur; sayaç ("4 / 7") formun etiket satırına geçer, çağıran `showCount: false` verir (koçun öğrenci eklemesi). | 1.17, 14.8 kare 1 |
| `AppLogoMark`, `AppLockup` (C59) | `app_logo.dart` | S-rota logosu ve SMAP kilit yapısı. `height`, `tone`, `layout`, `onNavy` (null ise koyu temada otomatik). | 1.26 |
| Yardımcılar | `avatar_initials.dart` | `AvatarInitials` | |

### 14.6 `indicators/`

| Bileşen | Dosya | Ne zaman | Pano |
|---|---|---|---|
| `AppLinearProgress` (C44) | `app_linear_progress.dart` | Doğrusal ilerleme. `value`, `total`, `style` (`subject`, `accent`), `color`. Toplam null ya da 0 ise hiçbir şey çizilmez (boş iz de çizilmez). | 1.15 |
| `AppSessionProgress` (C45) | `app_linear_progress.dart` | Bar ve "12/23" sayacı. `value`, `total`, `counter`. | 8.1 |
| `AppPageDots` (C60) | `app_page_dots.dart` | Tanıtım sayfa noktaları. `count`, `index`. | 2.1 |
| `AppSpinner` (C47) | `app_spinner.dart` | Belirsiz bekleme. `size`, `color`, `semanticLabel`. Her zaman bir metinle birlikte. | 1.15 |
| `AppStatBox` (C27) | `app_stat_box.dart` | İstatistik kutusu. `label`, `value` (önceden `TrFormat` ile biçimli), `delta`, `deltaSuffix`. Değer yoksa hiç çizilmez. | 1.16 |
| `AppSuccessRing` (C46) | `app_success_ring.dart` | Yüzde halkası, tek renk. `correct`, `total`, `noDataLabel`. Toplam 0 ise "Soru yok". | 1.15 |
| Yardımcılar | `progress_math.dart` | `ProgressMath` | |

### 14.7 `navigation/`

| Bileşen | Dosya | Ne zaman | Pano |
|---|---|---|---|
| `AppRootBand` (C80) | `app_root_band.dart` | Kök sekme ekranının lacivert bandı, ilk sliver. `title`, `action`, `bottom` (`AppRootBandBottom.segment` ya da `.tabs`, bant küçülmez), `squareCorners`. | 1.18 |
| `AppHomeBand` (C81) | `app_home_band.dart` | Anasayfa selam bandı. `AppHomeBand.student` (`name`, `avatar`, `counter`: `AppHomeCounter`) ve `.coach` (`studentCount`, `upcomingMeetings`). Satırları `app_home_band_rows.dart` part'ındadır. | 3.1, 10.1 |
| `AppDetailBar` (C82) + `LargeTitleSliver` | `app_detail_bar.dart`, `large_title_sliver.dart` | Detay çubuğu ve içerikteki büyük başlık. Aynı `title` iki yere de verilir. `action`, `leading` (`AppDetailBarLeading`), `onLeading`, `compactTitle`, `display`, `gutter`. | 1.18, 1.24 |
| `AppContextStrip` (C83) | `app_context_strip.dart` | Koç öğrenci ekranlarında "X'in verileri" şeridi. `student`, `detail`. | 1.18 kare 6, 10.4 |
| `AppBottomBar` (C84) + `AppNavTab` + `AppCameraButton` | `app_bottom_bar.dart`, `app_nav_tab.dart`, `app_camera_button.dart` | Beş yuvalı alt çubuk. `role` (`AppBottomBarRole.student\|coach`), `selectedIndex` (yalnız sekmeler, 0–3, null ise gösterge yok), `onTap`, `onCamera`. `AppBottomBar.heightOf(context)` kaydırılan ekranların alt dolgusudur. | 1.19, 1.24 |
| `StudentScope` + `StudentRef` (C85) | `student_scope.dart` | Koç görünümü için `InheritedWidget`. Kapsam varsa ekran bağlam şeridini gösterir, düzenleme eylemlerini ve öğrenciye özel öğeleri gizler, repository çağrılarına öğrenci id'si geçer (`studentOf`, `isCoachView`). | 10.4 |
| `AppSystemOverlayRegion` | `app_system_overlay.dart` | Bkz. bölüm 8. | 1.18 |
| Yardımcılar | `band_math.dart`, `band_text.dart`, `home_band_measure.dart`, `bottom_bar_tabs.dart` | `BandMath` (`RootBandMetrics`, `HomeBandMetrics`, `DetailBarMetrics`, `LargeTitleMetrics`), `BandText`, `AppBottomBarTabs`, `AppNavDestination`. | |

### 14.8 `pickers/`

| Bileşen | Dosya | Ne zaman | Pano |
|---|---|---|---|
| `AppCalendar` + `AppCalendarLegend` (C65) | `app_calendar.dart` | Çok gün seçimli ay takvimi. `selected`, `onToggle`, `today`, `onMonthChanged`. | 3.5 |
| `AppDayChip` (C62) | `app_day_chip.dart` | Gün şeridi karosu. `date`, `onTap`, `selected`, `today`, `size`, `caption`. | 3.4, 3.5 |
| `AppTimeWheel` + `AppTimeWheelSheet` (C66) | `app_time_wheel.dart` | Saat ve dakika çarkı ve sheet'i. `value`, `onChanged`, `minuteStep`. `AppTimeWheelSheet.show` `TimeOfDay?` döndürür. | 9.6 |
| Yardımcılar | `calendar_math.dart`, `time_wheel_math.dart` | `CalendarMath`, `TimeWheelMath` | |

### 14.9 `sheets/`

| Bileşen | Dosya | Ne zaman | Pano |
|---|---|---|---|
| `AppSheet` (C71) | `app_sheet.dart` | Sheet açıcı. `AppSheet.show<T>(builder:, context:, size:, dismissible:, online:)` ve `showForOutcome`. `context` verilmezse `AppSheet.navigatorKey` kullanılır. `online` verilirse sheet'in üstünde `AppOfflineStrip` gösterilir (sheet kabuğun şeridini örter). | 1.20, 14.7 kare 3 |
| `AppSheetFrame` (C71) | `app_sheet_frame.dart` | Tek sheet çerçevesi. `body`, `title`, `subtitle`, `header`, `showClose`, `primary`, `secondary` (`AppSheetAction`), `busy`, `onCloseAttempt`, `bodyPadding`, `footerTopPadding`, `semanticLabel`. Başlık satırı ve alt düğme bandı `app_sheet_frame_parts.dart` part dosyasındadır (`_Header`, `_Footer`). Alt bant alt boşluğu (inset) yok sayar (`ignoreBottomInset`), çünkü görüş alanı klavyenin üstünde zaten biter; bant altta güvenli alan + 8, klavye açıkken 16 boşluk bırakır (`SheetLayoutMath.footerBottom`). | 1.20 |
| `AppSheetRoute` | `app_sheet_route.dart` | `smooth_sheets`'in `ModalSheetRoute`'una dayanan route: 350 ms açılış, 250 ms kapanış, perde ve bulanıklık, reduce motion'da fade. Klavye açıkken `medium` ve `full` sheet klavyenin üstüne kalkar (`_SheetViewportFrame` görüş alanını klavye boyu kadar kısaltır); `small` kaldırılmaz, bu yüzden metin alanı olan sheet `medium` ya da `full` açılır ("Koçu Değiştir" `full`'dür). | 1.20, 11.15 |
| `AppConfirmSheet` (C72) | `app_confirm_sheet.dart` | Onay sheet'i. `title`, `confirmLabel`, `message`, `cancelLabel`, `danger`, `dontAskAgainLabel`. Sonuç `ConfirmResult` (`confirmed`, `dontAskAgain`). | 1.21 |
| `ComingSoonSheet` (C73) | `coming_soon_sheet.dart` | "Yakında". Yalnız kitte ve galeride yaşar, hiçbir ekran açmaz (Ek D-4). | 1.21 kare 3 |
| `SheetOutcome<T>` | `sheet_outcome.dart` | `SheetSubmitted` ya da `SheetDismissed`. "Hiçbir şey seçmedi" ile "değer seçti" ayrımı için. | |
| Yardımcılar | `sheet_layout.dart` | `AppSheetSize` (`small`, `medium`, `full`), `SheetLayoutMath`, `AppSheetScope`. | |

### 14.10 `surfaces/`

| Bileşen | Dosya | Ne zaman | Pano |
|---|---|---|---|
| `AppCard` | `app_card.dart` | Kart yüzeyi (kenar yok, gölge yok). `child`, `padding`, `onTap`, `semanticLabel`, `radius`, `clip`, `color`. | 1.16 |
| `AppRow` (C17) | `app_row.dart` | Ayar satırı. `title`, `subtitle`, `icon`, `leading`, `value`, `tag`, `trailing`, `onTap`, `showArrow`, `external`, `danger`. `value` satırın en çok yarısını alır ve ok yanında sağ kenara yaslanır, başlık ne kadar uzun olursa olsun. | 1.13 |
| `AppRowGroup` (C18) | `app_row_group.dart` | Başlıklı satır grubu. `children`, `title`, `footer`. | 1.13 |
| `AppRowShell` | `app_row_shell.dart` | Kendi içeriği olan satırın dokunulabilir kabuğu (ders, konu, deneme, program satırları). `child`, `onTap`, `padding`, `minHeight`. | 1.15, 1.16 |
| `AppAccordion` (C50) | `app_accordion.dart` | Açılır bölüm. `title`, `child`, `summary`, `summaryLabel`, `expanded`, `onChanged`, `indicator`, `card`. | 1.13 |
| `AppNoticeBox` (C39) | `app_notice_box.dart` | Satır içi bildirim (info, error, warning, success). `message`, `tone`, `actionLabel`, `onAction`. | 1.4 |

### 14.11 `text/`

| Bileşen | Dosya | Ne zaman | Pano |
|---|---|---|---|
| `SectionHeader` (C19) | `section_header.dart` | Bölüm başlığı. `title`, `meta`, `actionLabel`, `onAction`, `actionIcon`. | 3.1–3.3, 10.1 |
| `MetricText` (C49) | `metric_text.dart` | Önceden biçimlenmiş sayıyı metrik boyutta gösterir. `value`, `size` (`MetricSize`), `unit`. Kendisi sayı biçimlemez. | 1.16 |
| `DeltaText` (C49) | `delta_text.dart` | İşaretli değişim ve ok. `value`, `suffix`, `size`. `DeltaDirection` saf dosyadadır. | 1.16 |
| `HighlightText` (C10) | `highlight_text.dart` | Arama eşleşmesini vurgular (`TurkishText.matchRanges`). `text`, `query`, `style`. | |

## 15. Alan bileşenleri özet kataloğu

Alan bileşenleri `lib/features/<f>/presentation/widgets/` içinde yaşar. Genel kit değildir, o feature'ın alan bilgisini taşır ve başka feature'dan yeniden kullanılabilir (ör. `SubjectGlyph` dersler, program ve ana sayfada). Her birinin doc yorumu pano ve kareyi ve Türkçe metni verir; C-numaraları `docs/spec/02_bilesenler.md`'de. Galeride `Alan` (`DomainGallery`), `Program` (`PickersGallery`: `ProgramRow`, `WeekGrid`, `HourSlot`) ve `Koç` (`CoachGallery`) sayfalarında gösterilir.

| Feature | Bileşenler |
|---|---|
| exams | `DybGlyph` (C40, D/Y/B çipi), `DybCounter` (C41, büyük ve küçük sayaç), `DybStackedBar` (C42), `TestBarRow` (C42), `QuestionCell` (C43, `.result` ve form kontrol yüzü), `ExamRow` (C24), `ExamSummaryCard` (C25, "Son denemen"), `ExamHeader` (C26, `.detail` ve `.moment`), `ExamScoreCard` (C26, puan kartı, pano 14.4), `ExamInfoRow` (C26), `ExamCover`, `examTestName` (`exam_test_name.dart`; test adını çözen fonksiyon, widget değil), `TopicResultRow` (C23) |
| lessons | `SubjectGlyph` (C58, `SubjectTone` ile ders karosu), `SubjectRow` (C20), `SubjectTile` (C21), `TopicRow` (C22), `EksikTag` (C08), `AuthorRow` (C28), `WorkRow` (Edebiyat yazar sheet'inde eser satırı, pano 14.6), `ExampleBox` (C51) |
| schedule | `ProgramRow` (C29), `ProgramItemRow` (C30), `WeekGrid` (C63, ölçüleri `week_grid_parts.dart`'ta), `HourSlot` (C64), `ProgramSectionSkeleton` (pano 14.3, sekme içi program iskeleti) |
| coach | `StudentRow` (C31), `StudentTile` (C32), `AttentionRow` (C33), `MeetingRow` (C34), `CodeCard` (C35), `CodeCardSheetBody` (C35 sheet hâli, `code_card_sheet.dart`, pano 14.11: hazır, yükleniyor ve hata hâlleri; Hesap'taki kod satırının açtığı `CoachCodeSheet` bunu çizer), `CoachAvatars` (avatar dosya adından asset kuralı) |
| analytics | `NetChart` (C48, y ekseni deneme türüne sabit, TYT 0–120, AYT 0–160) |
| cards | `CardDeck` + `CardDeckController`, `InfoCardFace` (C52) |
| account | `ProfileSummary` (C37) |
| onboarding | `RoleOption` (C38; rol adımı `FeatureFlags.coachSignUpEnabled` kapalıyken gösterilmez, bayrak şu an kapalıdır), tanıtım görselleri (`OnboardingScanVisual`, `OnboardingAnalysisVisual`, `OnboardingGapsVisual`, `OnboardingNetChart`) ve `OnboardingShadows`. Tanıtım görselleri panonun örnek verisini kullanan resimlerdir, gerçek bileşen değildir. |
| scan | `CameraChromeButton` ve `CameraTopBar` (C67, yalnız koyu tema), `OmrFormArt` (basılı kâğıt gibi açık roller) |

Kil görselleri (pano 1.25; dosyalar `assets/illustrations/clay/<ad>.png`, tasarımcının teslimi `docs/design/kil/1x/`) tek bileşenden çizilir: `AppClay` (`lib/shared/ui/illustrations/app_clay.dart`, C61). `ClayPicture` 11 görseli sayar (`kitap` Türkçe, `hokka` Edebiyat ve koçta "Henüz görüşme yok", `sutun` Tarih, `kure` Coğrafya, `atom` Fizik, `erlenmeyer` Kimya, `yaprak` Biyoloji, `ampul` Programım boş, `harita` Denemelerim boş, hoş geldin ve deneme destesi; `islemler` ve `piramit` yalnız mağaza). Ders eşlemesi `ClayPicture.forSubject(SubjectKey?)` (desteler için `DeckLessons.pictureOf`). Boylar `AppClay.large` (L 160, tanıtım) ve `AppClay.medium` (M 128, `AppEmptyState.screen(illustration:)`). Kurallar: yalnız tanıtım, ekran düzeyi boş durum ve mağaza; ekranda en çok bir; satır, çip, sekme, düğmede yok; bölüm düzeyi boş durum yalnız metin; salt süs (`ExcludeSemantics`); koyu temada karo değişmez; dosya yoksa hiçbir şey çizilmez. Şu an yalnız 1x (140 px) var; 480 px asıllar gelince aynı adlarla `clay/2.0x/` ve `clay/3.0x/` altına konur, kod değişmez.

## 16. `mihr_ui` bağımlılığı

`pubspec.yaml` `mihr_ui: ^0.1.0-dev.3` ister; `pubspec.lock` pub.dev'den `0.1.0-dev.3` sürümünü sabitler. Kullanıldığı yerler yalnızca şunlardır:

| Dosya | Ne için |
|---|---|
| `lib/core/theme/smap_theme.dart` | `MihrTheme.light/dark`, `MihrThemeConfig`, `MihrTypography.fromFontFamily`, `MihrButtonThemeData`, `MihrButtonShadows.flat` |
| `lib/core/theme/smap_palette.dart` | `ColorScale` (navy ve neutral skalaları) |
| `lib/shared/ui/buttons/app_button.dart` | `MihrPrimaryButton`, `MihrSecondaryButton`, `MihrSoftPrimaryButton`, `MihrDestructiveButton`, `MihrTertiaryButton` ve `MihrButtonData` |
| `lib/shared/ui/buttons/app_button_style.dart` | `MihrButtonSize` eşlemesi |
| `lib/shared/ui/navigation/app_bottom_bar.dart` | `FrostedContainer`, `BackdropBlurStyle.custom` |

Kodda başka yerde `Mihr*` yoktur. Ekran kodu mihr'e doğrudan dokunmaz, her şey `App*` sarmalayıcılarından geçer. Boşluk `AppSpacing`'dedir (`MihrSpacing` kullanılmaz).

Kısıtlar (kod yorumları ve `docs/SMAP_UI_Rehberi_Duzeltmeler.md`):

- **dev.3 `styleBuilder` hatası** tema düzeyindeki override'ları atar. Bu yüzden `AppButton` tam bir örnek başına `ButtonStyle` verir, tema override'ına güvenmez (#6). Tema düzeyinde düğme `styleBuilder` override'ı yazılmaz.
- **48 dp hedef.** mihr düğmeleri tema `materialTapTargetSize`'ını okumaz, `ButtonStyle.tapTargetSize`'a bakar (varsayılan `shrinkWrap`). `AppButtonStyles.of` bunu `tapTargetSize: MaterialTapTargetSize.padded` ile örnek başına verir (`app_button_style.dart`). `AppButton` kullanan kod bunu zaten alır. Ham mihr düğmesi kullanmayın.
- **Boyut eşlemesi.** `AppButtonSize.lg48` mihr'in `xl` boyutuna eşlenir, çünkü mihr `lg` 44'tür (#8).
- **Yarıçap.** `MihrRadius.md` 8, tasarım 12'dir. `AppRadius` kullanılır.
- **Blur.** `BackdropBlurStyle.custom` dev.3'te `lightOverlay` ve `darkOverlay` ister (`app_bottom_bar.dart` ikisine her temanın `bgBar`'ını verir) (#4). mihr'in `blurPx` değeri sigma'nın iki katıdır, `AppBlur.bar` sigma'dır (`app_shadows.dart` doc'u).
- **Stok Material düğmeleri.** Düzeltmeler #7'ye göre dev.3 `MihrTheme` stok `TextButton`, `ElevatedButton` ve `OutlinedButton`'ı bozar (48'in altında hedef, büyük metinde kesik etiket). Bu yüzden her yerde `AppButton` kullanılır. Bu madde dış belgeden alınmıştır, kodda ayrıca doğrulanmadı.
- mihr'in renk ve tipografi getter'ları ekran kodunda yasaktır. Roller `SmapColors`'tan, stiller `SmapText`'ten gelir.

## 17. Tuzaklar

1. **`context.motion` ve `reduced:`.** `reduced` bilerek zorunludur. Kayma ya da ölçek için `AppMotion.reducedFade` verilir, `Duration.zero` opaklık geçişini sıçramaya çevirir (#18). `Duration.zero` yalnız kaydırma gibi anında olabilecek şeylerde uygundur (`shell_frame.dart`, `register_view.dart`).
2. **`toTextTheme()`'i `ThemeData.textTheme`'e atamak** dört yuvayı null bırakır. `merge` kullanılır (#27). `SmapTheme` bunu doğru yapar, kopyala-yapıştır yapan yanlış yapar.
3. **Mihr yarıçapı 8, tasarım 12.** `MihrRadius` ve `BorderRadius.circular(n)` yazma, `AppRadius` kullan.
4. **48 dp hedef.** Ham mihr düğmesi ya da `tapTargetSize` unutulmuş bir `ButtonStyle` 48'in altına düşer (#5). `AppButton`'a yönel. Segment görsel 44 ama dokunma alanı 48'dir (`07c93b8`).
5. **Odak halkası yalnız klavye odağında çizilir.** `a210c0d` öncesi autofocus'lu düğme (sheet'in ilk eylemi) dokunmatikte de halka çiziyordu. Düzeltme `FocusManager.instance.highlightMode == traditional` kontrolüdür (`app_button.dart`). Yeni odak halkalı bileşende aynı kontrolü yap. Galeri `alwaysTraditional` ile bunu gizler, gerçek cihazda halka görünmeyebilir.
6. **Büyük metin (1,3 sınırı, galeride 1,35).** FIN14A–E turlarının çoğu, sabit genişlik ve yükseklikli yerleşimlerin metin ölçeğiyle taşmasıydı: `AppHomeBand` selamı iki satıra kırılır ve bant ölçülen metinle büyür, alt çubuk beş etiket için ortak küçülme ölçeği kullanır, `WeekGridMetrics` ölçüleri ölçekle büyütür (tavan 1,5), Anasayfa düğmesi `MediaQuery.textScalerOf(context).scale(...)` ile büyür (`result_moment_actions.dart`). Yeni genişlik sabitleri `TextScaler` ile ölçeklenmeli ve 1,35'te galeride (`GalleryLargeText`) denenmeli.
7. **`MediaQuery.viewPaddingOf` ve alt güvenli alan.** Kabukta alt boşluk `padding` yerine `viewPadding.bottom`'dan alınır (`shell_frame.dart`, `app_bottom_bar.dart`). Hesap ekranlarında alt çubuk payı 34 pt eksik kalmıştı (`33e7e1b`). Kaydırılan ekranın alt dolgusu `AppBottomBar.heightOf(context)` olur (`2dd31bc`'te eski `account_bar_clearance.dart` bunun için silindi).
8. **`AppStatusView` kendi `Material`'ını verir.** Başka ata Material yoksa metinler sarı çift alt çizgiyle çizilirdi (`07c93b8`). Açılış, bakım ve güncelleme ekranlarındaki dış sarmalayıcılar bu yüzden kaldırıldı (`ebe65a2`). Aynı sebeple Material'sız yerde ham `Text` çizme (sheet üstü şerit bu yüzden `Material(type: transparency)` içindedir).
9. **Tek okunuş (semantics).** `AppCard` `semanticLabel` alırsa tek düğüm olur (aksi halde adsız "button", `07c93b8`). `AppAccordion` başlık, özet ve durumu tek okunuşta, gövdeyi ayrı düğümde verir (`summaryLabel`). `QuestionCell`, `InfoCardFace` ve D/Y/B sayacı tek cümle okunur. Yeni kart ya da hücre yazarken sırayla `Semantics` ve `ExcludeSemantics` düşün.
10. **Koyu temada ham logo ya da fotoğraf.** Lacivert logo koyu zeminde görünmez olurdu (`33e7e1b`). `AppLogoMark` bunu otomatik çözer, onboarding telefon içi fotoğraf sabit açık rollerle çizilir (`SmapColors.light`).
11. **Dosya boyu sınırı CI'da.** Görünüm kabuğu ≤ 250, part ≤ 300, VM ≤ 500, diğer ≤ 400 satır; `tool/ui_rules.sh` aşanı reddeder. Geçmişte sınıra takılınca parçalandı: `week_grid_parts.dart` (`213a9e1`), `app_home_band_rows.dart` (`d8da851`), `app_sheet_frame_parts.dart` (`2f90369`), `LessonDetailViewModel` (`34bfe33`). Widget'ı `part` dosyasına böl, `_buildX()` metodu ile değil.
12. **`ui_rules.sh` her şeyi yakalamaz.** `Text('literal')`, mihr getter'ları, `toUpperCase` ve `SharedPreferences.getInstance` inceleme işidir (bkz. bölüm 13). Yalnız bir satırın başındaki `//` yorumu muaftır, `kod(); // Colors.red` gibi satır sonu yorum takılır.
13. **Galeri değişkenlerinin hepsi `--dart-define` ile çalışmaz.** `GALLERY_ACTION`, `GALLERY_SCROLL` ve `GALLERY_SEMANTICS` yalnız `debugLaunchEnv` okur, yani süreç ortamı ya da `launch_env/` dosyası gerekir. Aynı değişkenlerde launch env `--dart-define`'ı geçersiz kılar.
14. **`TrFormat`'ı atlamak.** `toStringAsFixed` ya da elle "%" yazmak ondalık virgülü, binlik noktayı ve U+2212 eksiyi bozar. `yuzde` toplam 0'da fırlatır, veri yok ihtimalinde `yuzdeOrNull` kullan.
15. **Sahte veri yok.** Veri yoksa alan çizilmez. Boş `AppLinearProgress` çizilmez, `AppStatBox` değersizse tamamen çizilmez. "0 eksik" yazılmaz. Boş bir sayı sıfır ya da "-" ile doldurulmaz. Bölümde veri yoksa `AsyncSection.empty()` ya da `AsyncSection.error()` kullanılır, uydurma değer asla verilmez (`section_state.dart`).
16. **Ek uyumu.** Çalışma zamanı metninde "{name}'a" gibi eki elle birleştirme, `TurkishSuffix` kullan. Sayı ve kısaltmalar okunuşa göre ek alır (`9'u`, `TYT'ye`).
17. **Sheet ve toast için bağlam yok.** ViewModel `BuildContext` taşımaz. `AppSheet.navigatorKey` ve `ToastService` kökte bir kez kurulur (`lib/app/app_module.dart`). `AppSheet.show` bağlamsız çağrıldığında router anahtarı yoksa sessizce `null` döner ve sheet açılmaz; galeri uygulamasında sheet'ler bağlamla açılır.
18. **Sheet üstünde şerit.** Çevrimdışıyken sheet'in üstünde şerit görünmesi gerekiyorsa `AppSheet.show(online: ...)` vermeyi unutmayın; verilmezse sheet kabuğun şeridini örter ve kullanıcı bağlantı durumunu görmez.
19. **Bölüm kartı mı, ekran mı.** Bir sekmenin tamamı boş/hatalıysa `AppEmptyState.screen`/`AppErrorState.screen`; sayfa çalışıyor ve yalnız bir bölüm düştüyse `.section`. `.section` kartında `title` verirseniz kalın ilk satır başlık olur ve ileti ikincil metne iner; vermezseniz hata kartında ileti kalın tek satırdır, boş kartta düz gövde metnidir.
20. **Metin alanlı sheet ve klavye.** `AppSheetRoute` klavye açılınca yalnız `medium` ve `full` sheet'i klavyenin üstüne kaldırır; `small` (`AppSheet.show`'un varsayılanı) kalkmaz ve form klavyenin arkasında kalır. Girdi taşıyan sheet'i `medium` ya da `full` açın. Alt bant boşluğunu kendiniz eklemeyin, `AppSheetFrame` klavye ve güvenli alan payını kendisi verir.

## 18. İlgili dosyalar

- Token'lar: `lib/core/theme/` (`smap_colors.dart`, `smap_palette.dart`, `smap_text.dart`, `smap_theme.dart`, `app_spacing.dart`, `app_radius.dart`, `app_shadows.dart`, `app_motion.dart`, `subject_tone.dart`, `theme_context.dart`), `lib/app/app_theme_mode.dart`.
- Yardımcılar: `lib/core/utils/tr_format.dart`, `lib/core/utils/turkish_text.dart`, `lib/core/services/app_haptics.dart`, `lib/core/services/toast_service.dart`.
- Kit: `lib/shared/ui/` (klasör klasör bölüm 14), alan bileşenleri `lib/features/<f>/presentation/widgets/`.
- Galeri: `lib/main_gallery.dart`, `lib/features/debug/` (`component_gallery_view.dart`, `gallery_registry.dart`, `gallery_settings.dart`, `gallery_widgets.dart`, `launch_env.dart`, `pages/`).
- Denetim: `tool/ui_rules.sh`, `analysis_options.yaml`, `.github/workflows/ci.yml`.
- Testler: `test/core/theme/`, `test/core/utils/`, `test/shared/ui/`.
- Tasarım kaynağı: `docs/design/README.md`, `docs/design/panolar/`, `docs/spec/01_tokenlar.md`, `docs/spec/02_bilesenler.md`, `docs/SMAP_UI_Uygulama_Rehberi.md`, `docs/SMAP_UI_Rehberi_Duzeltmeler.md`.
- Kurallar: `AGENTS.md`, `../WORKFLOW.md`, [03_ekran.md](03_ekran.md).
