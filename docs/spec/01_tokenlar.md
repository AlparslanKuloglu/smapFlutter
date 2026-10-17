# SMAP Tasarım Token'ları: Flutter Teslim Spesifikasyonu

**Kaynak önceliği** (çelişki olursa üstteki geçerli):
1. **11.12 Teslim · Token Tablosu.** Son hâl, otoriter.
2. **11.15 Teslim · Hareket ve Haptik.** Hareket için son hâl.
3. **SMAP-01 1.1–1.8.** Ayrıntı, kontrast oranları ve gerekçeler.
4. **11.1 Tur 1 geliştirici notları.** `ColorScheme` kodu, `SmapColors`/`SmapTokens` alan listesi, `TextTheme` eşlemesi, biçimlendirme kodu.
5. **11.10 Tur 10.** `SmapText` adı ve delta kararı. Ek olarak 1.12, 1.20, 1.22–1.24 ve 2.4 panolarından token'a dokunan ölçüler alındı.

**Birim:** Panolar 402 pt'lik çerçevede 1 CSS px = 1 pt = 1 Flutter logical px olarak çizildi.

**Genel kural (11.12):** Ekran kodu yalnız rol adlarını kullanır, skala adımını kullanmaz. Tema değişince rolün değeri değişir.

---

## 1. Renk skalaları (1.1)

Koddaki 153 farklı renk kodu 3 skalaya indirildi. Oran sütunu, rengin beyaz zemine karşı WCAG kontrastıdır.

### 1.1 Lacivert · `navy` (marka: navy-900 = `#0F294A`)
| Adım | Hex | Beyaza karşı | 1.1'deki kullanım / türeyen roller |
|---|---|---|---|
| 50 | `#F1F5FA` | 1,09:1 | bağlam şeridi → `bg-context` (açık) |
| 100 | `#E2EAF4` | 1,21:1 | bilgi zemini → `info` bg (açık) |
| 200 | `#C5D4E8` | 1,50:1 | bant üstü metin → `text-on-navy-2`; koyu birincil → `primary` (koyu) |
| 300 | `#9BB3D3` | 2,15:1 | koyu: eylem, grafik → `text-action`, `focus-ring`, `primary-pressed`, `delta`, `info`, `chart-line` (koyu) |
| 400 | `#6C8BB6` | 3,50:1 | grafik serisi 3 |
| 500 | `#4A6A97` | 5,53:1 | belirtilmemiş |
| 600 | `#36537C` | 7,82:1 | odak halkası, bilgi → `focus-ring`, `info`, `delta` (açık) |
| 700 | `#264066` | 10,46:1 | grafik çizgisi → `chart-line` (açık) |
| 800 | `#1A3357` | 12,69:1 | bant üstü ray, metin düğmesi → `bg-navy-raised`, `text-action` (açık); girdi odak kenarı (açık) |
| 900 · marka | `#0F294A` | 14,62:1 | bant, birincil düğme → `bg-navy`, `primary` (açık), `on-accent` |
| 950 | `#091A31` | 17,45:1 | basılı birincil → `primary-pressed` (açık); `on-primary` (koyu); açık `scrim` tabanı |

**Eski değerler:**
- Bunlar navy-900, 800 ya da 700'e iner: `#0F294A` (66 yer), `#162A40` (23, kamera ve görüşme), `#0D2744` (16, giriş ve koç), `#1A365D`, `#10284A`, `#1E344A` (grafik), `#1F2937`, `#1A237E` (indigo, 11 yer). Hangi değerin hangi adıma ineceği tek tek belirtilmemiş.
- `#3D526D` (bir ekranda "Doğru") D/Y/B sözlüğüne geçer.
- Logodaki `#2D3A54` logo dosyasında kalır.

### 1.2 Turuncu · `orange` (marka: orange-500 = `#FF6600`)
| Adım | Hex | Beyaza karşı | Kullanım |
|---|---|---|---|
| 50 | `#FFF4EC` | 1,08:1 | belirtilmemiş |
| 100 | `#FFE6D4` | 1,20:1 | belirtilmemiş |
| 200 | `#FFCBA6` | 1,46:1 | belirtilmemiş |
| 300 | `#FFA76B` | 1,91:1 | belirtilmemiş |
| 400 | `#FF8533` | 2,43:1 | koyu: gösterge → `accent-line`, `chart-highlight` (koyu) |
| 500 · marka | `#FF6600` | 2,94:1 | kamera dolgusu → `accent` (iki tema). Üstüne beyaz metin yazılmaz. |
| 600 | `#E05500` | 3,84:1 | gösterge, ilerleme, "bugün" → `accent-line`, `chart-highlight` (açık). Beyaza karşı 3:1'i geçen ilk adım. |
| 700 | `#B34400` | 5,61:1 | turuncu metin → `text-accent` (açık) |
| 800 | `#8A3500` | 8,11:1 | belirtilmemiş |
| 900 | `#662800` | 11,24:1 | belirtilmemiş |
| 950 | `#3D1800` | 15,80:1 | belirtilmemiş |

**Kural:** Turuncu dolgu yüzeyde orange-500 olur. İnce göstergede, ilerleme dolgusunda ve "bugün"de orange-600 kullanılır. Metinde yalnız orange-700 kullanılır.

**Eski değerler:** `#FF6600` (96), `#FF7A00` (gösterge), `#FF8A00`, `#FF6D00`, `#FF6F00`, `#F97316`, `#F68A3F` (grafik), SVG'lerdeki `#FF6400` ve `Colors.orange` (29) bu kurala göre iner. Logodaki `#F16D38` logo dosyasında kalır.

### 1.3 Nötr · `neutral` (lacivert tonuna çekilmiş tek gri ailesi, ton 215°)
| Adım | Hex | Beyaza karşı | Kullanım |
|---|---|---|---|
| 0 | `#FFFFFF` | 1,00:1 | kart, sheet |
| 50 | `#F2F4F7` | 1,10:1 | kanvas |
| 100 | `#E8ECF1` | 1,19:1 | ray, iskelet |
| 200 | `#DCE2E9` | 1,30:1 | ayraç |
| 300 | `#C3CBD6` | 1,64:1 | pasif kenar |
| 400 | `#9AA5B4` | 2,50:1 | pasif metin |
| 500 | `#697586` | 4,68:1 | kontrol kenarı, placeholder |
| 600 | `#556173` | 6,28:1 | ikincil metin |
| 700 | `#3E4858` | 9,24:1 | belirtilmemiş |
| 800 | `#2A3241` | 12,88:1 | belirtilmemiş |
| 900 | `#1B2232` | 15,89:1 | birincil metin |
| 950 | `#0F1420` | 18,40:1 | belirtilmemiş |

**Eski değerler:**
- Başlık metni `#1C1F33` → 900.
- İkincil metin `#8A90A6` (3,17:1) → 600 (6,28:1).
- Pasif sekme `#B2BAC6` (1,96:1) → 600.
- Kanvas `#F5F7F9` → 50. Beyaz kartla ayrılsın diye bir ton koyulaştı.
- `#E2E8F0`, `#E8ECF0`, `#E8EAED` → 200.
- Tailwind slate/gray ve `Colors.grey` (158 yer) bu skalaya iner.

**Not:** Skalada 25 adımı yok, buna karşılık nötrde 0 adımı var.

### 1.4 Koyu tema yüzeyleri (skala dışı, ayrı set)
Koyu tema açık temanın tersi değildir: yüzeyler lacivert tonludur ve yükseldikçe açılır. Bant koyu temada da navy-900 kalır. Oranlar `#121D31` zeminine karşıdır.

| Ad (1.1) | Hex | Oran |
|---|---|---|
| kanvas | `#0A1424` | belirtilmemiş |
| yüzey, kart | `#121D31` | belirtilmemiş |
| üst yüzey, sheet | `#18263D` | belirtilmemiş |
| ray, girdi | `#213049` | belirtilmemiş (girdi zemini için §9.7'ye bakın) |
| ayraç | `#26354D` | belirtilmemiş |
| kontrol kenarı | `#6B7D97` | 4,02:1 |
| ikincil metin | `#A9B5C6` | 8,12:1 |
| birincil metin | `#EDF1F6` | 14,86:1 |

1.1 panelinde olmayan diğer koyu literal'ler:
- `#34445F`: border-strong ve sheet tutamacı.
- `#8B9AAF`: placeholder.
- `#56657C`: disabled.
- `#1A2B45`: bg-context ve info bg.
- `#02060E`: scrim tabanı.
- `#FF9A57`: text-accent. Orange skalasında yok.
- `#3B0A10`: onError.
- `#0A1424`: D/Y/B glifi, kanvasla aynı değer.

### 1.5 smapFlutter'daki mevcut `AppColors` → yeni rol (göç)
| Mevcut | Değer | Yeni |
|---|---|---|
| `primaryOrange` | `#FF6600` | `accent` (yalnız kamera) |
| `background` | `#FFFFFF` | sayfa zemini artık `bg-canvas` `#F2F4F7`; beyaz = `bg-surface` |
| `menuCardBackground` | `#F5F7F9` | `bg-canvas` `#F2F4F7` |
| `textPrimary` | `#1C1F33` | `text-primary` `#1B2232` |
| `textSecondary` | `#8A90A6` | `text-secondary` `#556173` |
| `navUnselected` | `#B2BAC6` | `text-secondary` |
| `navIndicator` | `#FF7A00` | `accent-line` |
| `navSelectedBg` | `#FFD4B3` | karşılığı yok. Alt çubukta tek gösterge kalır (1.19, Tur 1). |
| `appBarBackground` | `#0F294A` | `ext.navyBand` |
| `unselectedGrey` | `#E2E8F0` | neutral-200 (`border-subtle`) |
| `accentOrange` | `#FF8A00` | turuncu kuralına göre 500/600/700 |
| `appBarBlueGrey` (seed) | `#7D858D` | kalkar ("seed yok; elle ColorScheme") |
| `shadowLight`/`shadowMedium`/`orangeShadow` | `0x14000000`/`0x16000000`/`0x33FF8A00` | `shadow-raised` / `shadow-overlay` |

---

## 2. Renk rolleri: açık + koyu, Flutter eşlemesi

"ext." ön eki `SmapColors` ThemeExtension'ı demektir. Kontrast sütunu 1.2'den alındı:
- Zeminlerde değer, birincil metne karşıdır.
- Metin ve kenarlarda değer, yüzeye karşıdır: açıkta `#FFFFFF`, koyuda `#121D31`.

| Rol | Açık (skala) | Koyu (skala) | Flutter | Kullanım | Kontrast açık · koyu | Kaynak |
|---|---|---|---|---|---|---|
| `bg-canvas` | `#F2F4F7` (n-50) | `#0A1424` | `surface` | Sayfa zemini, kartların arkası | 14,42 · 16,26 | 11.12 |
| `bg-surface` | `#FFFFFF` (n-0) | `#121D31` | `surfaceContainerLowest` | Kart, liste grubu, girdi zemini | 15,89 · 14,86 | 11.12 |
| `bg-raised` | `#FFFFFF` (n-0) | `#18263D` | `surfaceContainerLow` | Sheet; koyuda yüzeyden bir adım açık | 15,89 · 13,38 | 11.12 |
| `bg-sunken` | `#E8ECF1` (n-100) | `#213049` | `surfaceContainerHighest` | Segment ve ilerleme rayı, iskelet, sessiz düğme | 13,39 · 11,69 | 11.12 |
| `bg-navy` | `#0F294A` (navy-900) | `#0F294A` | `ext.navyBand` | Kök sekme bandı; açık temada toast | 14,62 · 14,62 (beyaz) | 11.12 |
| `bg-navy-raised` | `#1A3357` (navy-800) | `#1A3357` | `ext.navyBandRaised` | Bant üstündeki segment rayı | 12,69 · 12,69 (beyaz) | 11.12 |
| `bg-context` | `#F1F5FA` (navy-50) | `#1A2B45` | `ext.contextStrip` | Koç bağlam şeridi (Tur 9) | belirtilmemiş (hesaplanan: text-primary 14,52 · 12,55) | 11.12 (Tur 10 yeni) |
| `bg-bar` | `#FFFFFF` %92 | `#121D31` %92 | `ext.bar` | Alt çubuk, arkası 20 pt bulanık | 15,89 · 14,86 | **yalnız 1.2 + Tur 1** |
| `scrim` | `#091A31` %48 | `#02060E` %64 | `scrim` | Sheet perdesi, arkası 8 pt bulanık | metin taşımaz | **yalnız 1.2 + Tur 1** |
| `border-subtle` | `#DCE2E9` (n-200) | `#26354D` | `outlineVariant` | Ayraç, hücre ve kart kenarı (dekoratif) | dekoratif | 11.12 |
| `border-strong` | `#C3CBD6` (n-300) | `#34445F` | `ext.borderStrong` | Pasif kontrol kenarı, sheet tutamacı | pasif, muaf | 11.12 |
| `border-control` | `#697586` (n-500) | `#6B7D97` | `outline` | Girdi, çip, onay kutusu, kapalı anahtar | 4,68 · 4,02 | 11.12 |
| `text-primary` | `#1B2232` (n-900) | `#EDF1F6` | `onSurface` | Başlık, gövde, değer; birincil ikon | 15,89 · 14,86 | 11.12 |
| `text-secondary` | `#556173` (n-600) | `#A9B5C6` | `onSurfaceVariant` | Alt metin, etiket, eksen, pasif sekme; ikincil ikon | 6,28 · 8,12 | 11.12 |
| `text-placeholder` | `#697586` (n-500) | `#8B9AAF` | `ext.textPlaceholder` | Yalnız girdi içindeki "Örn: …" | 4,68 · 5,89 | 11.12 |
| `text-disabled` | `#9AA5B4` (n-400) | `#56657C` | `ext.textDisabled` | Pasif kontrol metni | muaf (2,50 · 2,85) | 11.12 |
| `text-on-navy` | `#FFFFFF` | `#FFFFFF` | `ext.onNavyBand` | Bant başlığı ve eylemi | 14,62 · 14,62 | 11.12 |
| `text-on-navy-2` | `#C5D4E8` (navy-200) | `#C5D4E8` | `ext.onNavyBandVariant` | Bant üstü alt metin, pasif segment etiketi | 9,72 · 9,72 | 11.12 |
| `text-action` | `#1A3357` (navy-800) | `#9BB3D3` (navy-300) | `ext.textAction` | Metin düğmesi, satır içi bağlantı (altı çizili) | 12,69 · 7,85 | 11.12 |
| `text-accent` | `#B34400` (orange-700) | `#FF9A57` | `ext.textAccent` | Gerekirse turuncu metin; açıkta asla orange-500 | 5,61 · 8,04 | 11.12 |
| `primary` | `#0F294A` (navy-900) | `#C5D4E8` (navy-200) | `primary` | Birincil düğme, seçili segment ve çip, açık anahtar | 14,62 · 11,59 | 11.12 |
| `on-primary` | `#FFFFFF` | `#091A31` (navy-950) | `onPrimary` | Birincil üstündeki metin ve ikon | 14,62 · 11,59 | 11.12 |
| `primary-pressed` | `#091A31` (navy-950) | `#9BB3D3` (navy-300) | `ext.primaryPressed` | Basılı birincil | 17,45 · 8,13 | **yalnız 1.2 + Tur 1** |
| `accent` | `#FF6600` (orange-500) | `#FF6600` | `secondary` | Yalnız kamera düğmesinin dolgusu | 4,98 · 4,98 (ikon) | 11.12 |
| `on-accent` | `#0F294A` (navy-900) | `#0F294A` | `onSecondary` | Kamera ikonu (beyaz değil) | 4,98 · 4,98 | 11.12 |
| `accent-line` | `#E05500` (orange-600) | `#FF8533` (orange-400) | `ext.accentLine` | Konum göstergesi, ilerleme dolgusu, "bugün", grafikte seçili nokta | 3,84 · 6,95 | 11.12 |
| `focus-ring` | `#36537C` (navy-600) | `#9BB3D3` (navy-300) | `ext.focusRing` | Odak halkası: 2 pt çizgi, 2 pt boşluk | 7,82 · 7,85 | 11.12 |
| (onError) | `#FFFFFF` | `#3B0A10` | `onError` | Tehlikeli düğme metni | açık 5,56 (1.9) · koyu 7,74 (1.23) | **yalnız Tur 1 kodu + 1.23/1.24** |

### 2.1 `ColorScheme` (Tur 1 geliştirici notu, birebir)
Seed yok, `ColorScheme` elle kurulur. Gri seed (`#7D858D`) kalkar.

```dart
// açık
ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF0F294A), onPrimary: Color(0xFFFFFFFF),
  secondary: Color(0xFFFF6600), onSecondary: Color(0xFF0F294A),
  error: Color(0xFFC42D35), onError: Color(0xFFFFFFFF),
  surface: Color(0xFFF2F4F7), onSurface: Color(0xFF1B2232),
  onSurfaceVariant: Color(0xFF556173),
  outline: Color(0xFF697586), outlineVariant: Color(0xFFDCE2E9),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFFFFFFF),
  surfaceContainerHighest: Color(0xFFE8ECF1),
  scrim: Color(0x7A091A31), // %48
)
// koyu
ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFC5D4E8), onPrimary: Color(0xFF091A31),
  secondary: Color(0xFFFF6600), onSecondary: Color(0xFF0F294A),
  error: Color(0xFFFF8F8F), onError: Color(0xFF3B0A10),
  surface: Color(0xFF0A1424), onSurface: Color(0xFFEDF1F6),
  onSurfaceVariant: Color(0xFFA9B5C6),
  outline: Color(0xFF6B7D97), outlineVariant: Color(0xFF26354D),
  surfaceContainerLowest: Color(0xFF121D31),
  surfaceContainerLow: Color(0xFF18263D),
  surfaceContainerHighest: Color(0xFF213049),
  scrim: Color(0xA302060E), // %64
)
```

Şu `ColorScheme` slotları için değer **belirtilmemiş**:
- `primaryContainer`, `onPrimaryContainer`
- `secondaryContainer`, `onSecondaryContainer`
- `tertiary*`
- `errorContainer`, `onErrorContainer`
- `surfaceDim`, `surfaceBright`
- `surfaceContainer`, `surfaceContainerHigh`
- `inverseSurface`, `onInverseSurface`, `inversePrimary`
- `shadow`, `surfaceTint`

`bg-bar` için hesaplanan alfa değerleri: %92 → `0xEB`, yani `Color(0xEBFFFFFF)` ve `Color(0xEB121D31)`. Tam değer için `withValues(alpha: 0.92)` tercih edilmeli.

### 2.2 Rol kuralları
- **Turuncunun yeri (1.2):** Turuncu yalnız dört işte kullanılır: kamera düğmesi, konum göstergesi (alt çubuk ve ekran içi sekme), ilerleme ve "bugün". Grafikte seçili ya da son nokta da `accent-line` ile çizilir. Segment, çip, düğme, anahtar ve onay kutusu seçimleri laciverttir.
- **Kenar ya da gölge:** Bir yüzeyde ikisinden yalnız biri olur. Kartlar kanvas üstünde kenarsız ve gölgesiz durur; ayrımı kanvas/yüzey farkı yapar.
- **Placeholder:** Kanvas üstünde 4,25:1'e düşer, bu yüzden yalnız beyaz girdi zemininde kullanılır. Etiket her zaman alanın üstündedir.
- **Ters yüzey (rolü yok, bileşen kuralı):**
  - Açık temada toast lacivert zemindedir (`bg-navy`, 14,62). İkonları koyu temanın durum renkleridir: info `#C5D4E8`, success `#52CC8E`, error `#FF8F8F`.
  - Koyu temada toast ve çevrimdışı şeridi ters yüzeydedir: zemin `#E8ECF1`, metin `#1B2232` (13,39). İkonlar açık temanın durum renkleridir.

---

## 3. Anlamsal renkler

### 3.1 D/Y/B tek sözlük (1.4 + 11.12)
Sıra her zaman Doğru → Yanlış → Boş. İkon şekli her ekranda aynıdır. Renk tek başına anlam taşımaz: çipin yanında her zaman etiket ya da harf (D, Y, B) bulunur. Sayılar renkli yazılmaz, renk yalnız çipte görünür.

| | Doğru · D | Yanlış · Y | Boş · B |
|---|---|---|---|
| Token (11.12) | `dyb-correct` → `dybCorrect` | `dyb-wrong` → `dybWrong` | `dyb-blank` → `dybBlank` (1.4 ve Tur 1'de adı `dyb-empty` → `dybEmpty`) |
| İkon (Phosphor) | Check ✓ | X ✕ | Minus – |
| Dolgu açık · koyu | `#0B6E3E` · `#52CC8E` | `#D8333A` · `#F07575` | `#7E8A9B` · `#6E7C92` |
| Zemin tonu açık · koyu | `#E4F4EA` · `#133325` (yalnız 1.4; 11.12'de token yok) | `dyb-wrong-bg` `#FCEAEA` · `#3B1D22` | `dyb-blank-bg` `#E8ECF1` · `#213049` |
| Glif | beyaz · koyu `#0A1424` | beyaz · koyu `#0A1424` | beyaz · koyu `#0A1424` |
| Glif/dolgu | 6,34 · 9,12 | 4,71 · 6,59 | 3,50 · 4,36 |
| Dolgu/yüzey | 6,34 · 8,34 | 4,71 · 6,03 | 3,50 · 3,98 |
| Metin olarak | Yalnız yanlış hücredeki doğru şık (`#0B6E3E` / `#FCEAEA` 5,46) | Kullanılmaz; hata metni `status-error` | Kullanılmaz; "Boş" etiketi `text-secondary` |
| 11.12 kullanımı | Doğru: çip, çubuk, doğru cevap metni | Yanlış | Boş; `dyb-wrong-bg` yanlış soru hücresi, `dyb-blank-bg` boş soru hücresi |

- **Açıklık farkı:** Açıkta bağıl parlaklık 0,12 · 0,17 · 0,25. Gri tonlamada `#606060` · `#747474` · `#898989` görünür. Koyuda sıra tersine döner: Doğru 0,47, Yanlış 0,33, Boş 0,20 (1.23).
- **Eski sözlükler:** Material + siyah (`#4CAF50`/`#F44336`/`#000000`), Tailwind (`#10B981`/`#EF4444`/`#94A3B8`), "Doğru lacivert" (`#3D526D`, 24 yer), iOS/kart SVG'leri (`#34C759`/`#FF383C`). Hepsi kalkar. "Boş" hiçbir yerde siyah değil.
- **Yığılmış D/Y/B çubuğu** dyb renklerini kullanır, parçalar arası 2 pt boşluk bırakılır (Tur 1 bileşen listesi).

### 3.2 Delta (Tur 10 yeni token)
| Token | Açık | Koyu | Kullanım |
|---|---|---|---|
| `delta` → `ext.delta` | `#36537C` (navy-600) | `#9BB3D3` (navy-300) | Değişim değeri ve oku ("+8,25") |

Yeşil yalnız Doğru'ya ayrıldı. Artış ve azalışı ok yönü ve işaret ayırır; renk anlam taşımaz (sıralamada düşüş iyidir).

### 3.3 Eksik (Tur 5)
| Token | Açık fg / bg | Koyu fg / bg | Kullanım |
|---|---|---|---|
| `eksik` / `eksikBg` | `#8A5A00` / `#FCF1D9` | `#F2C46D` / `#33270F` | `EksikTag`: bayrak + "3 eksik" |

`EksikTag` ölçüsü: bayrak 14 pt + metin 13/600 (Tur 5 G3). Değerler `warning` ile aynı. Kırmızı yanlış cevaba ayrıldığı için eksik işareti amber.

### 3.4 Durum renkleri (fg / bg)
| Token | Açık | Koyu (11.12) | Kontrast açık · koyu (1.4) | İkon (Phosphor) | Kullanım (11.12) |
|---|---|---|---|---|---|
| `error` / `errorBg` | `#C42D35` / `#FCEAEA` | `#FF8F8F` / `#3B1D22` | 4,80 · 6,92 | WarningCircle | Hata metni, tehlikeli düğme ve onay |
| `success` / `successBg` | `#0B6E3E` / `#E4F4EA` | `#52CC8E` / **`#15301F`** | 5,56 · 6,80 (1.4 eski koyu zeminde `#133325`); 11.12 koyu çifti için hesaplanan 7,04 | CheckCircle | Başarı ikonu (şifre güncellendi, hesap silindi) |
| `warning` / `warningBg` | `#8A5A00` / `#FCF1D9` | **`#F2C46D` / `#33270F`** | 5,28 · 8,54 (1.4 eski koyu `#EBC25B`/`#33280F`); 11.12 koyu çifti için hesaplanan 8,97 | Warning | Uyarı kutusu, dikkat rozeti |
| `info` / `infoBg` | `#36537C` / `#E2EAF4` | `#9BB3D3` / `#1A2B45` | 6,45 · 6,63 | Info | Bilgi kutusu, ikon daireleri |

Kontrast matrisinde (1.3) `status-error` ve `status-success` tek başına yüzeylere karşı da ölçüldü (§8).

**Kurallar (1.4):**
- Mesaj metni birincil metin rengindedir; durum rengi yalnız ikon ve kısa vurgularda kullanılır.
- Uyarı rengi koyu hardaldır, turuncuyla karışmaz.
- Sol kenar şeridi kullanılmaz.
- Durum kutusu ölçüleri: radius 12, padding 12/16, ikon 24, aralık 12, metin 15/24.

### 3.5 Grafik
| Token | Açık | Koyu | Not |
|---|---|---|---|
| `chart-line` → `chartLine` | `#264066` | `#9BB3D3` | Net çizgisi; 2,5 pt, düz (eğri değil, iki deneme arasında değer uydurmaz) |
| `chart-area` (yalnız 1.4 + Tur 1) | chartLine %10 | chartLine %14 | Çizgi altı alan. Hesaplanan alfa `0x1A` / `0x24`. 11.12 bunu chart-line notuna koymuş ("alan %10 (koyu %14)"). |
| `chart-highlight` → `chartHighlight` | `#E05500` | `#FF8533` | Son nokta / seçili nokta |
| `chart-grid` → `chartGrid` | `#DCE2E9` | `#26354D` | Izgara (1 pt) |
| Seri 1–4 (yalnız 1.4 + Tur 1 `chartSeries[4]`) | `#264066`, `#E05500`, `#6C8BB6`, `#7E8A9B` | belirtilmemiş | Karşılaştırma |

Grafik ayrıntıları (1.4 SVG):
- **Eksen metni:** `text-secondary`, 13 pt.
- **Noktalar:** r 4,5, kenar 2 pt chartLine, dolgu yüzey rengi (açık `#FFFFFF`, koyu `#121D31`).
- **Son nokta:** r 7, dolgu chartHighlight, kenar 2,5 pt yüzey rengi.
- **Balon:** radius 8. Açıkta zemin `#0F294A`, meta 13 pt `#C5D4E8`, değer 15/700 `#FFFFFF`. Koyuda zemin `#E8ECF1`, meta `#556173`, değer `#1B2232`.
- Ders serileri ders vurgusunu kullanır (1.5).
- Tur 4 uygulaması: fl_chart `LineChart`, `dotData` açık, `belowBarData` %10, `lineTouchData` balonu.

---

## 4. Ders renkleri (9 ders × 2 tema)

**Token adı (11.12):** `final Map<Subject, (Color bg, Color fg)> subject;` (`SmapColors` içinde). Tur 1'deki eski taslak `subjects: Map<Ders, (bg, accent)>` idi. `Subject` enum değer adları **belirtilmemiş**.

| Ders | Glif (Phosphor) | Açık zemin · vurgu (oran) | Koyu zemin · vurgu (oran) | Ton | Eski açık zemin / vurgu (oran) | Ne değişti |
|---|---|---|---|---|---|---|
| Türkçe | TextAa | `#F6ECE6` · `#93573C` (4,92) | `#2D211C` · `#E2A98D` (7,65) | belirtilmemiş | `#F7EDE4` / `#A67762` (3,35) | Kahve korundu, glif okunsun diye koyulaştı |
| Edebiyat | Feather | `#F6E7EC` · `#8A2F4E` (6,76) | `#301A27` · `#E494BE` (7,12) | 340° | `#F7F5E8` / `#D56C70` (3,09) | Mercandan şarap tonuna, en koyu kırmızımsı |
| Tarih | Bank | `#FBF1DA` · `#8C6106` (4,88) | `#2C2513` · `#E3B651` (8,02) | 41° | `#FFEED6` / `#EAA353` (1,87) | Kehribardan koyu hardala; turuncudan ayrıldı |
| Coğrafya | Globe | `#E1EFFA` · `#1E6FAE` (4,55) | `#12293C` · `#7DB9EC` (7,12) | 206° | `#D7EEFE` / `#3B97D3` (2,68) | Gök mavisi, koyulaştı |
| Matematik | MathOperations | `#FDE8E8` · `#C42A36` (4,79) | `#341B1B` · `#F7847F` (6,49) | 355° | `#FDE7E8` / `#FA4B56` (2,86) | Tek saf kırmızı ders |
| Geometri | Angle | `#E7E9FB` · `#4450BE` (5,56) | `#1D2144` · `#A3ABF4` (7,16) | 234° | `#CDE0FE` / `#3B69B0` (4,09) | Çivit mavisine kaydı; Coğrafya'dan ayrıldı |
| Fizik | Atom | `#DDF2F2` · `#08737A` (4,82) | `#0E2B2D` · `#5FCBD0` (7,80) | 184° | `#DBF4FF` / `#0276A4` (4,45) | Petrol mavisinden petrol yeşiline |
| Kimya | Flask | `#F7E8F7` · `#93359A` (5,55) | `#271B33` · `#C89AE3` (7,12) | 296° | `#FFE5EB` / `#DB5669` (3,18) | Gülden eflatuna; Matematik'ten 60° uzakta |
| Biyoloji | Dna | `#E4F3E3` · `#2B7A35` (4,63) | `#16291A` · `#80CC89` (7,99) | 128° | `#D5F1CB` / `#12A335` (2,73) | Yeşil korundu; "Doğru" yeşilinden (151°) ayrı |

**Kullanım (1.5):**
- **Glif kutusu:** 48 pt (liste) ya da 40 pt (şerit, SubjectRow ve SubjectTile), radius-md. Zemin açık ton, glif vurgu renginde, 24 pt.
- **Ders çipi:** 10 pt nokta.
- **İlerleme:** Dolgu vurgu rengi, ray `bg-sunken`. En düşük oran 4,49.
- Ders adı her zaman `text-primary`. Vurgu yalnız glif, nokta ve ilerlemede kullanılır, metin rengi olmaz.
- Ders rengi D/Y/B ya da durum anlamı taşımaz.
- Tarih-2 ve Coğrafya-2 ana dersin rengini kullanır, "SOS-2" etiketiyle ayrılır.
- Matematik ve Geometri satırında rengin yanında nötr "Web'de" etiketi durur.
- Çok renkli illüstrasyon kalktı, tek renk Phosphor glif kullanılır.

---

## 5. Tipografi: Plus Jakarta Sans

**Yazı tipi:**
- TTF varlık olarak pakete gömülür; `google_fonts` ile indirme yok (zayıf okul Wi-Fi'ı).
- Kullanılan ağırlıklar: 400, 500, 600, 700, 800.
- `pubspec` aile adı ve dosya listesi **belirtilmemiş**. Export'ta yalnız latin ve latin-ext woff2 dosyaları var.

12 metin stili + 4 rakam stili var. Satır yükseklikleri 4 pt ızgaradadır. Flutter `height` = satır / boyut (hesaplanan).

| Stil | Boyut/satır | Ağırlık | Harf aralığı | `height` | Flutter | Kullanım (11.12 → 1.6 ek) |
|---|---|---|---|---|---|---|
| `display` | 32/40 | 800 | −0,5 | 1.25 | `displaySmall` | Onboarding ve genel ekran başlığı, sonuç anı. En çok 2 satır. |
| `title-lg` | 24/32 | 700 | −0,3 | 1.3333 | `headlineSmall` | Kök bant başlığı, sayfa başlığı (detay ekranı) |
| `title-md` | 20/28 | 700 | −0,2 | 1.4 | `titleLarge` | Sheet başlığı, bölüm başlığı (Anasayfa), boş durum başlığı, deneme adı |
| `headline` | 17/24 | 700 | −0,1 | 1.4118 | `titleMedium` | Bölüm ve alt başlık (Türkçe başlık düzeninde) |
| `title-sm` | 16/24 | 600 | 0 | 1.5 | `titleSmall` | Satır ve kart başlığı. 2 satıra kadar sarılır, kesilmez. |
| `body-lg` | 16/24 (okumada 16/26) | 400 | 0 | 1.5 (1.625) | `bodyLarge` | Madde tanımı, örnek, bilgi kartı, sözleşme. Girdi değeri de 16/24 (iOS yakınlaştırmaz). |
| `body` | 15/24 | 400 | 0 | 1.6 | `bodyMedium` | Gövde, açıklama, sheet metni |
| `body-strong` | 15/24 | 600 | 0 | 1.6 | `ext.bodyStrong` | Gövde içi vurgu, liste değeri, program saati |
| `caption` | 13/20 | 500 | 0 | 1.5385 | `bodySmall` | Meta, alan yardımı, eksen, etiket, ikincil metin |
| `label-lg` | 16/24 | 600 | 0 | 1.5 | `labelLarge` | 48 pt düğme |
| `label-md` | 14/20 | 600 | 0 | 1.4286 | `labelMedium` | 40 pt düğme, segment, çip, sekme, girdi etiketi |
| `label-sm` | 12/16 | 600 | 0 | 1.3333 | `labelSmall` | Yalnız alt çubuk etiketi |
| `metric-xl` | 56/64 | 800 | −1,5 | 1.1429 | `ext.metricXl` | Sonuç anı neti |
| `metric-lg` | 40/48 | 800 | −1 | 1.2 | `ext.metricLg` | Deneme Detay ve Anasayfa neti, YKS sayacı |
| `metric-md` | 24/32 | 700 | −0,4 | 1.3333 | `ext.metricMd` | İstatistik kutusu, puan, koçluk kodu, tarih bloğu, sıralama |
| `metric-sm` | 17/24 | 700 | 0 | 1.4118 | `ext.metricSm` | D/Y/B sayaçları, ders neti |

- `ext.*` stiller Tur 10'a göre `SmapText` ThemeExtension'ındadır. 11.12 kod iskeletinde yalnız `SmapColors` gösterilmiş.
- **Birim eşlemesi (1.6 örneği):** "67,5" metric-xl + "net" 17/24/700; "412,63" metric-lg + "puan" 15/24/600; "48.215." metric-md + "sıra" 15/24/600. Sayı ile birim arasında `space-4`.
- **Tur 10 hizalaması** (ölçek dışı eski değerler kalktı): tanıtım ve genel ekran başlığı → display 32/40; Anasayfa neti → metric-lg; program saati → body-strong; tarih bloğu → metric-md. Kalkan eski değerler: 26/34 başlık, 32/40 rakam, 15/700 saat, 20/800 gün.

### 5.1 Boyut ve erişilebilirlik kuralları
- Gövde en az 15 pt, ikincil metin en az 13 pt. Tek istisna `label-sm` 12 pt ("Görüşmelerim" 13 pt'de 80 pt yuvaya sığmıyor). Bu etiket büyük metinde `FittedBox(scaleDown)` ile küçülür, uzun basışta büyük içerik balonu açılır.
- Metin %130'a kadar büyür. Satır sarılır, yükseklik içerikle büyür, hiçbir ad kesilmez, sabit yükseklik kullanılmaz.
- Büyük harf dönüşümü `tr` yerel ayarıyla yapılır (i → İ). Büyük harfli düğme ve harf aralıklı üst etiket yok.
- Türkçe glif testi: "İı Şş Ğğ Çç Öö Üü · İstanbul".

### 5.2 Tabular rakamlar
- `FontFeature.tabularFigures()` tüm rakam stillerinde kullanılır: metric-xl/lg/md/sm ve rakam taşıyan her stil. 11.12'nin ifadesi "tüm rakam stillerinde"; teslim panosunun kökünde `font-variant-numeric: tabular-nums` var.
- Gerekçe: liste ve tablolarda rakamlar alt alta hizalanır, sayaçlar değişirken satır oynamaz.

### 5.3 Türkçe sayı ve tarih biçimi (1.6 + Tur 1 kodu, birebir)
- Ondalık ayırıcı virgül, binlik ayırıcı nokta.
- Net çeyrek adımla gelir, sondaki sıfır yazılmaz: 68 · 67,5 · 74,75.
- Puan iki hanelidir: 412,63 · 381,40.
- Yüzde en yakın tam sayıya yuvarlanır ve işaret önde yazılır: %41,67 → %42.
- Sıra: "48.215. sıra".
- Değişim işaretli yazılır: "+8,25". Negatif işaret glifi (− ya da -) **belirtilmemiş**.
- Tarih: "15 Eylül 2026". Kısa tarih noktalı ay: "15 Eyl.", "5 Eki.", gerekiyorsa "5 Eki. 2026".
- Günler: Pzt Sal Çar Per Cum Cmt Paz.
- Saat örnekleri 24 saat biçiminde: "10:00", "16:00".

```dart
final net  = NumberFormat('#,##0.##', 'tr'); // 67,5 · 74,75 · 68
final puan = NumberFormat('#,##0.00', 'tr'); // 412,63 · 381,40
final sira = NumberFormat('#,##0', 'tr');    // 48.215 → "48.215. sıra"
String yuzde(int d, int toplam) => '%${(d * 100 / toplam).round()}'; // 5/12 → %42
String kisaTarih(DateTime t) => '${t.day} ${DateFormat('MMM', 'tr').format(t)}.'; // 5 Eki.
DateFormat('d MMMM y', 'tr') // 15 Eylül 2026
DateFormat('EEE', 'tr')      // Pzt Sal Çar Per Cum Cmt Paz
```

- **Arama katlama:** Tur 6'da tr-TR küçük harf (İ→i, I→ı). Tur 9'da `toLowerCase(tr)` sonra ı→i, ad ve soyad token'larında önek eşleşmesi.

---

## 6. Şekil, boşluk, yükselti, kenar, odak

### 6.1 Köşe yarıçapı (22 değer → 5 + tam)
| Token | Değer | Kullanım (11.12 + 1.7) |
|---|---|---|
| `radius-xs` | 4 | Onay kutusu, grafik çubuğu ucu |
| `radius-sm` | 8 | Segment başparmağı, soru hücresi, etiket (tag), kapak küçük resmi, ipucu balonu, grafik balonu |
| `radius-md` | 12 | Düğme, girdi, segment rayı, glif kutusu, banner, toast, durum kutusu |
| `radius-lg` | 16 | Kart, liste grubu, istatistik kutusu, kamera düğmesi |
| `radius-xl` | 24 | Sheet üst köşeleri, lacivert bant alt köşeleri, bilgi kartı |
| `radius-full` | 999 | Çip, rozet, avatar, ilerleme çubuğu, anahtar, sheet tutamacı |

- **Eski → yeni:** 2–5 → xs · 6–10 → sm · 12–15 → md · 16–20 → lg · 22–32 → xl · 99/100/999 → full.
- **İç içe yüzey:** iç yarıçap = dış yarıçap − aradaki boşluk. Örnek: 16'lık kartta 8 boşlukla iç köşe 8.

### 6.2 Boşluk (4 pt ızgara)
| Token | Değer | Kullanım |
|---|---|---|
| `space-4` | 4 | İkon–etiket, sayı–birim |
| `space-8` | 8 | Çipler arası, satır içi öğeler; ikon–etiket (düğmede) |
| `space-12` | 12 | Satır dikey dolgusu, başlıktan içeriğe |
| `space-16` | 16 | Sayfa kenarı (her ekranda), kart iç dolgusu |
| `space-24` | 24 | Bölüm içi gruplar, sheet iç dolgusu, form alanları arası |
| `space-32` | 32 | Bölümler arası |
| `space-48` | 48 | Dokunma hedefi, boş durum çevresi |
| `space-64` | 64 | Ekran düzeyi boş durumun üstü |

11.12 özeti: sayfa kenarı 16, bölümler arası 24–32, dokunma 48. 1.7 telefon örneği: başlıktan gruba 12, satır 72, satır içi 12/16. Eskiden 19 farklı ızgara dışı dikey boşluk vardı ve sayfa kenarı 16/20/24/40 arasında değişiyordu.

### 6.3 Sabit ölçüler (1.7 + Tur 1)
| Öğe | Değer |
|---|---|
| Çerçeve (iPhone 16 Pro) | 402 × 874 pt |
| Güvenli alan üst · alt | 62 · 34 pt |
| Dokunma hedefi | 48 × 48. Görseli 40 olanlarda 4 pt görünmez pay; `MaterialTapTargetSize.padded`. |
| Liste satırı, tek / iki satır | en az 56 / 72 |
| Kök bant, açık / küçülmüş (güvenli alan dahil) | 134 / 110. Bantta segment ya da sekme varsa 178 (Tur 1). |
| Detay üst barı (güvenli alan dahil) | 110 |
| Alt çubuk + güvenli alan | 68 + 34 |
| Kamera düğmesi | 56 × 56, radius-lg, 16 pt yukarı |
| Sheet tutamacı | 36 × 4, üstten 8 |
| Girdi | 48 yükseklik, radius-md, yanlarda 16. Etiket 8 pt üstte, yardım/hata metni 6 pt altta. |
| Çip | 36 görünür, 48 dokunma |
| İkon | 20 (düğme içinde), 24 (yalnız ikon), etiketten 8 |
| Klavye | 336 pt (yalnız şematik) |

### 6.4 Gölge (57 gölge → 2 token)
| Token | Açık | Koyu | Flutter (hesaplanan alfa) | Kullanım |
|---|---|---|---|---|
| `shadow-raised` | x 0, y 2, blur 8 · `#0F294A` %8 | `#000000` %40 | `BoxShadow(offset: Offset(0,2), blurRadius: 8, color: Color(0xFF0F294A).withValues(alpha: .08))`; koyu `.40` (≈`0x14…` / `0x66000000`) | Sürüklenen bilgi kartı, kamera düğmesi, büyüteç |
| `shadow-overlay` | x 0, y 8, blur 24 · `#0F294A` %16 | `#000000` %56 | `Offset(0,8)`, `blurRadius: 24`, alfa `.16`; koyu `.56` (≈`0x29…` / `0x8F000000`) | Toast, ipucu balonu, grafik balonu |

`spreadRadius` değeri panolarda yok; CSS karşılığı 0.

**Kurallar:**
- Bir yüzeyde kenar ya da gölge olur, ikisi birden olmaz. Kartlar ikisini de kullanmaz.
- Alt çubuk gölge yerine üst ayraç kullanır: 1 pt `border-subtle`.
- Sheet perdeyle ayrılır, gölgesi yoktur.
- Koyu temada yükselti, yüzeyin açılmasıyla anlatılır.

### 6.5 Bulanıklık (Tur 1 `blur`)
- Alt çubuk 20 (`bg-bar` arkası), perde 8 (`scrim` arkası). Başka yerde `BackdropFilter` yok.
- Panolardaki CSS: `backdrop-filter: blur(20px)` ve `blur(8px)`.
- Flutter `sigma` dönüşümü **belirtilmemiş**:
  - CSS'te değer standart sapmadır, birebir karşılığı sigma 20 / 8.
  - mihr_ui `BackdropBlurStyle` ise blurPx = 2 × sigma kuralını kullanıyor (blurPx 40 → sigma 20).
  - Hangisinin uygulanacağına karar verilmeli.

### 6.6 Kenarlar
| Öğe | Kalınlık · renk |
|---|---|
| Ayraç, hücre, kart kenarı (dekoratif) | 1 pt `border-subtle` |
| Girdi | 1 pt `border-control` |
| Girdi odak | 2 pt. Açıkta navy-800 `#1A3357`, koyuda navy-300 `#9BB3D3` (1.23). Değer `ext.textAction` ile aynı; ayrı rol adı yok. |
| Girdi hata | 2 pt `error` (`#C42D35`) |
| Girdi pasif | zemin `bg-canvas`, kenar `border-strong`, metin `text-disabled` |
| Girdi salt okunur | metin tam kontrastta kalır |
| Çip | 1 pt `border-control` (inset) |
| İkincil düğme | yüzey + 1,5 pt `primary` kenar |
| Sheet tutamacı | `border-strong` dolgu (açık `#C3CBD6`, koyu `#34445F`); meşgulken soluklaşır |
| Avatar yığını | 2 pt beyaz halka, 8 pt bindirme. Seçili avatar: 2 pt boşluk + 2 pt lacivert halka. |

### 6.7 Odak halkası
- `ext.focusRing`: açık `#36537C`, koyu `#9BB3D3`. 2 pt çizgi + 2 pt boşluk.
- Pano uygulaması: `box-shadow: 0 0 0 2px #FFFFFF, 0 0 0 4px #36537C`, yani boşluk açıkta beyaz yüzey renginde. Koyu temada boşluk rengi **belirtilmemiş**.
- Girdilerde ayrı halka çizilmez; odak kenar kalınlığı ve rengiyle gösterilir (§6.6).

---

## 7. Hareket ve haptik

### 7.1 Süre token'ları
| Token | Değer | Kullanım (11.12 + 1.8) |
|---|---|---|
| `duration-instant` | 100 ms | Basılı durum: renk ve 0,98 ölçek |
| `duration-fast` | 150 ms | Anahtar, çip, onay kutusu, ikon Regular → Fill; hareketi azaltta opaklık |
| `duration-base` | 250 ms | Segment başparmağı, gösterge, akordeon, toast, ekleme/çıkarma |
| `duration-slow` | 350 ms | Sheet açılışı, sayfa geçişi, ilk eksiğe kaydırma |
| `duration-loop` | 1200 ms | İskelet parıltısının bir turu |

### 7.2 Eğriler
| Token | Değer | Kullanım |
|---|---|---|
| `ease-standard` | `Cubic(0.2, 0, 0, 1)` | Yerinde değişim: segment, gösterge, akordeon |
| `ease-enter` | `Cubic(0, 0, 0, 1)` | Ekrana giren öğe: sheet, toast |
| `ease-exit` | `Cubic(0.3, 0, 1, 1)` | Çıkan öğe; süre girişin %70'i |
| `linear` | `Curves.linear` | İskelet parıltısı, gönderim yüzdesi, kaydırmaya bağlı küçülme |

### 7.3 Etkileşim tablosu (11.15 + 1.8 ayrıntısı)
| Etkileşim | Ne hareket eder | Süre | Eğri | Haptik | Hareketi azalt |
|---|---|---|---|---|---|
| Düğme basılı | Bir ton koyulaşır, 0,98'e küçülür | 100 ms | standard | — | aynı |
| Segment, sekme, alt çubuk | Lacivert başparmak kayar, etiket rengi çapraz geçer. Alt çubukta turuncu gösterge kayar, ikon Regular → Fill (150 ms). Sekmede alt çizgi kayar, içerik yatay geçer, seçili sekme görünür alana kaydırılır. | 250 ms (ikon 150) | standard | selectionClick | opaklık 150 ms |
| Çip, anahtar, onay kutusu, radyo | Dolgu ve işaret belirir, anahtar başı kayar | 150 ms | standard | selectionClick | aynı |
| Akordeon | Yükseklik açılır, ok 180° döner | 250 ms | standard | — | anında |
| Sheet açılış / kapanış | Alttan kayar, perde %0 → %48. Parmağı izler; %25'ten fazla iniş ya da hızlı fırlatma kapatır (hız eşiği belirtilmemiş). Meşgulken sürükleme kapalı. | 350 / 250 ms | enter / exit | — | opaklık 150 ms; perdeye bağlı olmadan belirir |
| Toast | Alt çubuğun 8 pt üstünde, 16 pt yukarı kayarak belirir. 4 sn kalır, "Geri Al" varsa 6 sn. Yukarı kaydırınca kapanır. Aynı anda tek toast. | 250 ms | enter / exit | hata türünde error | opaklık |
| Küçülen bant / bar | Başlık 24 → 17 pt, bant 134 → 110. Süre yok, kaydırmaya bağlı (56 pt). | kaydırmayla | linear | — | aynı |
| İskelet | Soldan sağa parıltı. 15 sn içinde veri gelmezse hata durumu; sonsuz iskelet yok. | 1200 ms döngü | linear | — | parıltı durur, düz gri kalır |
| Kamera deklanşörü (4.3) | 0,92'ye küçülüp geri gelir | 100 ms | standard | mediumImpact | ölçek yok |
| Okuma başarılı / sonuç anı (5.1) | Sayılar anında görünür; dönen sayaç ve konfeti yok | — | — | success, bir kez | aynı |
| Form ve giriş hatası | Kenar 150 ms'de kırmızıya döner, hata metni belirir, odak ilk hatalı alana gider. Alan sarsılmaz; yalnız kod kutuları (2.4) 150 ms sallanır (genlik belirtilmemiş). | 150 ms | standard | error | sallanma yok |
| İlk eksiğe kaydırma (7.3) | `Scrollable.ensureVisible` | 350 ms | standard | — | doğrudan konum (`jumpTo`) |
| Kart kaydırma (8.1) | Parmağı izler; eşik genişliğin %30'u ya da 800 px/sn | — | standard | — | çapraz geçiş |
| Öğrendim (8.1) | Sağa çıkış | 250 ms | exit | success | opaklık |
| Program bloğu ekleme / çıkarma (3.5–3.6) | — | 250 ms | enter / exit | selectionClick | opaklık |
| Günü Sıfırla (3.6) | Satırlar 150 ms aralıkla söner | 150 ms aralık | exit | selectionClick | anında |
| Çevrimdışı şeridi | İner; bağlanınca 2 sn "Bağlandın" | 250 ms | enter | — | opaklık |
| Sayfa geçişi | Platform varsayılanı: iOS sağdan kayma ve kenardan geri kaydırma, Android sistem geri hareketi | 350 ms | platform | — | opaklık |
| Hesabı Sil (9.4) | Tam ekran spinner, geri kapalı | — | linear | — | aynı |

**İskelet renkleri:**
- 1.8 gradyanı: `linear-gradient(90deg, #E8ECF1, #C3CBD6, #E8ECF1)`.
- 1.22 parıltı katmanı: `rgba(255,255,255,0 → 0.65 → 0)`.
- Koyu iskelet parıltısı **belirtilmemiş**; zemin `bg-sunken`.

**Diğer zamanlamalar (ekran notları):**
- Program araması: 150 ms gecikme (Tur 6).
- Kullanıcı adı kontrolü: 400 ms gecikme, istek iptal edilebilir (Tur 7).
- Geri Al toast'u: 6 sn.

### 7.4 Haptik sözlüğü
| Haptik | Ne zaman | Flutter / platform |
|---|---|---|
| `selectionClick` | Seçim değişti: segment, sekme, alt çubuk, çip, anahtar, onay kutusu, radyo, şık, köşe oturması (kamera), program bloğu ekle/çıkar, Günü Sıfırla | `HapticFeedback.selectionClick()` |
| `mediumImpact` | Deklanşör | `HapticFeedback.mediumImpact()` |
| `success` | Sonuç hazır / okuma başarılı (bir kez), talep alındı, cevaplar onaylandı, Öğrendim | Platform köprüsü: iOS `UINotificationFeedbackGenerator`, Android `HapticFeedbackConstants.CONFIRM` |
| `error` | Gönderim ya da okuma hatası, form/doğrulama hatası, form bulunamadı, kamera açılamadı, hatalı kod (2.4), hatalı gönderim (4.9), hata türündeki toast | Platform köprüsü: iOS `UINotificationFeedbackGenerator`, Android `HapticFeedbackConstants.REJECT` |

- Flutter'ın `HapticFeedback`'i bildirim haptiklerini içermediği için küçük bir platform kanalı gerekir. Kanal adı ve Android eski API yedeği **belirtilmemiş**.
- Haptik verilmeyen yerler: düğme basılı, akordeon, sheet, küçülen bar, iskelet, sayfa geçişi.

### 7.5 Hareketi azalt
- `MediaQuery.disableAnimations` açıksa bütün kaymalar 150 ms'lik opaklık geçişine döner.
- İskelet parıltısı durur ve düz gri kalır.
- Sheet perdeye bağlı olmadan belirir.
- Kaydırmalar `jumpTo` ile yapılır, sallanma olmaz.
- Haptikler değişmez. Hiçbir bilgi yalnız hareketle verilmez.
- Süs animasyonu, dönen sayaç, konfeti, parlama ve blob uygulamada yok; parlama yalnız mağaza görsellerinde serbest.

---

## 8. Kontrast kuralları ve yasak çiftler

**Eşikler (1.2/1.3):**
- Metin için en az 4,5:1.
- Büyük metin (24 pt ya da 19 pt kalın) için 3:1.
- Kontrol sınırı ve ikon için 3:1.
- Pasif metin/kenar ve dekoratif ayraç muaftır.
- 1.3'te "yalnız büyük metin" etiketli hücre yok; hücreler ya serbest ya da yasak.

### 8.1 Açık tema matrisi (metin \ zemin)
| Metin | surface `#FFFFFF` | canvas `#F2F4F7` | sunken `#E8ECF1` | navy `#0F294A` |
|---|---|---|---|---|
| text-primary `#1B2232` | 15,89 | 14,42 | 13,39 | 1,09 ✗ |
| text-secondary `#556173` | 6,28 | 5,70 | 5,29 | 2,33 ✗ |
| text-placeholder `#697586` | 4,68 | 4,25 ✗ (yalnız girdide) | 3,94 ✗ (yalnız girdide) | 3,13 ✗ |
| text-action `#1A3357` | 12,69 | 11,52 | 10,69 | 1,15 ✗ |
| text-accent `#B34400` | 5,61 | 5,09 | 4,73 | 2,61 ✗ |
| status-error `#C42D35` | 5,56 | 5,05 | 4,69 | 2,63 ✗ |
| status-success `#0B6E3E` | 6,34 | 5,75 | 5,34 | 2,31 ✗ |
| text-on-navy `#FFFFFF` | 1,00 ✗ | 1,10 ✗ | 1,19 ✗ | 14,62 |
| text-on-navy-2 `#C5D4E8` | 1,50 ✗ | 1,37 ✗ | 1,27 ✗ | 9,72 |

### 8.2 Koyu tema matrisi (bütün hücreler kullanılabilir)
| Metin | canvas `#0A1424` | surface `#121D31` | raised `#18263D` | sunken `#213049` | navy `#0F294A` |
|---|---|---|---|---|---|
| text-primary `#EDF1F6` | 16,26 | 14,86 | 13,38 | 11,69 | 12,89 |
| text-secondary `#A9B5C6` | 8,88 | 8,12 | 7,31 | 6,39 | 7,04 |
| text-placeholder `#8B9AAF` | 6,45 | 5,89 | 5,30 | 4,63 | 5,11 |
| text-action `#9BB3D3` | 8,59 | 7,85 | 7,07 | 6,18 | 6,81 |
| text-accent `#FF9A57` | 8,79 | 8,04 | 7,24 | 6,32 | 6,97 |
| status-error `#FF8F8F` | 8,41 | 7,69 | 6,92 | 6,05 | 6,67 |
| status-success `#52CC8E` | 9,12 | 8,34 | 7,51 | 6,56 | 7,23 |
| text-on-navy `#FFFFFF` | 18,45 | 16,86 | 15,18 | 13,26 | 14,62 |
| text-on-navy-2 `#C5D4E8` | 12,26 | 11,20 | 10,09 | 8,81 | 9,72 |

### 8.3 Bileşene özgü çiftler (1.3)
| Çift | Açık | Koyu |
|---|---|---|
| Birincil düğme: beyaz / navy-900 | 14,62 | 11,59 |
| Pasif segment: `#556173` / `#E8ECF1` | 5,29 | 6,39 |
| Bant üstü pasif segment: navy-200 / navy-800 | 8,43 | belirtilmemiş |
| Kamera ikonu: navy-900 / `#FF6600` (ikon, 3:1) | 4,98 | belirtilmemiş |
| D/Y/B çipi glifi: beyaz / `#0B6E3E` · `#D8333A` · `#7E8A9B` | 6,34 · 4,71 · 3,50 | belirtilmemiş |
| Yanlış hücrede doğru şık: `#0B6E3E` / `#FCEAEA` | 5,46 | belirtilmemiş |
| Tehlikeli düğme (koyu): `#3B0A10` / `#FF8F8F` | — | 7,74 |
| Koyu toast (ters yüzey): `#1B2232` / `#E8ECF1` | — | 13,39 |

### 8.4 Yasak çiftler ve renk kuralları
1. Turuncu (`#FF6600`) üstüne beyaz metin yasak (2,94). Turuncu düğme yoktur. Kamera ikonu navy-900 olur.
2. orange-500 metin olarak kullanılmaz. Turuncu metin açıkta yalnız `#B34400`, koyuda `#FF9A57`.
3. `text-placeholder` canvas, sunken ve navy üstünde kullanılmaz; yalnız beyaz girdi zemininde.
4. Açık temada navy üstünde text-primary, text-secondary, text-placeholder, text-action, text-accent, status-error ve status-success kullanılmaz (1,09–3,13). Navy üstünde yalnız `text-on-navy` ve `text-on-navy-2` kullanılır.
5. `text-on-navy` ve `text-on-navy-2` açık zeminlerde (surface, canvas, sunken) kullanılmaz.
6. `dyb-wrong` ve `dyb-blank` metin olarak kullanılmaz. `dyb-correct` metin olarak yalnız yanlış hücredeki doğru şıkta kullanılır.
7. Sayılar renkli yazılmaz: D/Y/B sayıları metin rengindedir. Değişim değerleri yeşil değil, `delta`.
8. Ders vurgusu metin rengi olamaz; ders adı `text-primary`.
9. Durum rengi mesaj metni olamaz (yalnız ikon ve kısa vurgu); sol kenar şeridi yok.
10. Renk tek başına anlam taşımaz: D/Y/B'de ikon + harf/etiket + sabit sıra; derste ad her zaman yazılır.
11. Seçim göstergesinde turuncu kullanılmaz (segment, çip, anahtar, onay kutusu ve düğmede lacivert). Beyaz segment başparmağı gri rayda 1,10:1 kaldığı için başparmak lacivert dolgudur.
12. Kartta kenar + gölge birlikte olmaz; kartta ikisi de yok.
13. Uyarı rengi turuncu olmaz (hardal `#8A5A00`).
14. Bulanıklık yalnız alt çubukta ve perdede.
15. Kalkan eski değerler: `#8A90A6` (3,17), `#B2BAC6`/`#B4B8C0` (1,96–1,99), `#9E9E9E` "Kapat" (2,68), `#9AA1AA` eksen (2,61), `#FFEB3B` sarı halka (1,22), kamera ikonu açık şeftali/turuncu (~1,8), `#FFA366` yarı saydam ikon (1,5), `#F9FAFB` satır zemini (1,05), `#22C55E` anahtar, `Colors.grey` ve Tailwind literal'leri.

---

## 9. Çelişkiler ve eksikler (karar gerektirenler)

1. **warning/eksik koyu değeri:** 1.4'te `#EBC25B`/`#33280F`, 11.12 ve Tur 5'te `#F2C46D`/`#33270F`. **11.12 geçerli.**
2. **success koyu zemini:** 1.4'te `#133325`, 11.12'de `#15301F`. **11.12 geçerli.** 1.4'teki "Doğru zemin tonu" (`#E4F4EA`/`#133325`) 11.12'de ayrı token değil.
3. **Boş token adı:** 1.4 ve Tur 1'de `dyb-empty`/`dybEmpty`, 11.12'de `dyb-blank`/`dybBlank`. **11.12 geçerli.**
4. **SmapColors alanları:** Tur 1 listesinde olup 11.12'de olmayanlar: `bar`, `primaryPressed`, `dybOn`, `dybCorrectBg`, `chartArea`, `chartSeries[4]`. 11.12'de yeni olanlar: `contextStrip`, `delta`, `eksik`, `eksikBg`, `error`. Ders haritası `subjects: Map<Ders,(bg, accent)>` iken `subject: Map<Subject,(Color bg, Color fg)>` oldu.
5. **Rolü tanımlı ama 11.12 tablosunda olmayanlar:** `bg-bar`, `scrim`, `primary-pressed` (1.2), `onError` (Tur 1, koyu `#3B0A10`). Bileşenlerde kullanılıyorlar.
6. **Rakam stili kullanımları:** 1.6'da Deneme Detay neti metric-xl, puan metric-lg. 11.12'de Deneme Detay neti metric-lg, puan metric-md. **11.12 geçerli.** `body-lg` "okumada 16/26" yalnız 11.12'de geçiyor; hangi ekranlarda uygulanacağı belirtilmemiş.
7. **Koyu girdi zemini:** 1.1 koyu panelinde `#213049` "ray · girdi" yazıyor; 1.2, 1.23 ve 11.12'de girdi zemini `bg-surface` (`#121D31`). **11.12 geçerli.**
8. **Form hatası sallanması:** 1.8'de "Alan sarsılmaz", 11.15'te "kod kutuları sallanır (2.4)". Yalnız kod kutuları 150 ms sallanır, genlik belirtilmemiş.
9. **Belirtilmemiş değerler:**
   - Grafik serileri koyu değerleri.
   - Ters yüzey (koyu toast `#E8ECF1`, koyu grafik balonu) için rol adı.
   - Odak halkası boşluğunun koyu rengi.
   - Sheet fırlatma hız eşiği.
   - Negatif delta işareti.
   - `Subject` enum değer adları.
   - Yazı tipi aile adı ve dosyaları.
   - Haptik kanal adı.
   - Blur sigma dönüşümü.
   - Koyu iskelet parıltısı.
10. **Skala dışı değerler:** Koyu yüzeyler, `#FF9A57`, `#8B9AAF`, `#56657C`, `#34445F`, `#1A2B45` ve bütün anlamsal/ders renkleri skala adımı değil, literal değer.
11. **mihr_ui uyumu:**
    - smapFlutter `pubspec`'te mihr_ui henüz yok.
    - `MihrRadius` adları SMAP'le çakışıyor (`MihrRadius.md` = 8, `xl` = 12; SMAP'te md 12, xl 24). SMAP ekranlarında `MihrRadius`/`MihrSpacing` adları kullanılmamalı.
    - `ColorScale` `shade25` istiyor; SMAP'te 25 adımı yok.
    - `MihrTheme`'in ürettiği `ColorScheme` SMAP'le uyuşmuyor (surface beyaz, secondary gri). `materialOverrides` ile tam SMAP `ColorScheme` verilmeli.
    - `MihrTypography` varsayılanı Inter; `fontFamily` Plus Jakarta Sans'a ayarlanmalı.

---

## 10. Önerilen Dart dosya yapısı (`lib/core/theme/`)

Handoff adları: `SmapColors` (11.12), `SmapText` (Tur 10), `SmapTokens` (Tur 1). Mevcut `app_colors.dart` ve `app_theme.dart` göç bitince kalkar.

| Dosya | İçerik |
|---|---|
| `smap_palette.dart` | `abstract final class SmapPalette`: `navy50…navy950`, `orange50…orange950`, `neutral0…neutral950` (§1). Yalnız tema katmanı kullanır, ekran kodu kullanmaz. |
| `smap_color_scheme.dart` | `smapLightColorScheme`, `smapDarkColorScheme` (§2.1 birebir) |
| `smap_colors.dart` | `class SmapColors extends ThemeExtension<SmapColors>` + `static const light`, `static const dark`, `copyWith`, `lerp` |
| `smap_subject.dart` | `enum Subject` (9 ders; değer adları karar bekliyor), glif eşlemesi TextAa, Feather, Bank, Globe, MathOperations, Angle, Atom, Flask, Dna (`phosphor_flutter`, Tur 1 paket listesi) |
| `smap_typography.dart` | `smapTextTheme(Color onSurface)` (§5 eşlemesi, `fontFeatures: [FontFeature.tabularFigures()]`) + `class SmapText extends ThemeExtension<SmapText>` |
| `smap_format.dart` | `net`, `puan`, `sira`, `yuzde`, `kisaTarih`, uzun tarih, gün kısaltması (§5.3 kodu) |
| `smap_spacing.dart` | `SmapSpace.s4 … s64`, `gutter = 16`, `touch = 48` + `SmapSize` (§6.3 sabit ölçüler) |
| `smap_radius.dart` | `SmapRadius.xs 4 · sm 8 · md 12 · lg 16 · xl 24 · full 999` + `BorderRadius` yardımcıları (`sheetTop` = üst xl, `bandBottom` = alt xl) |
| `smap_elevation.dart` | `SmapBlur.bar 20 · scrim 8`. Gölgeler temaya bağlı olduğu için `SmapTokens`'ta. |
| `smap_tokens.dart` | `class SmapTokens extends ThemeExtension<SmapTokens>`: `shadowRaised`, `shadowOverlay` (açık/koyu `List<BoxShadow>`) |
| `smap_motion.dart` | `SmapDuration.instant 100 · fast 150 · base 250 · slow 350 · loop 1200`; `SmapCurves.standard/enter/exit/linear`; `exitOf(d) = d * 0.7`; `SmapMotion.reduced(context)` (`MediaQuery.disableAnimations`) |
| `smap_haptics.dart` | `SmapHaptics.selection()`, `.medium()`, `.success()`, `.error()` + platform `MethodChannel` (iOS `UINotificationFeedbackGenerator`, Android CONFIRM/REJECT) |
| `smap_theme.dart` | `SmapTheme.light()` / `.dark()`. `ThemeData(colorScheme, textTheme, scaffoldBackgroundColor: bg-canvas, extensions: [SmapColors, SmapText, SmapTokens])`. mihr_ui kullanılırsa `MihrThemeConfig(fontFamily, extraExtensions, materialOverrides)` ile kurulur (§9.11). |
| `smap_theme_context.dart` | `extension on BuildContext { SmapColors get smapColors; SmapText get smapText; SmapTokens get smapTokens; }` |

### 10.1 `SmapColors` alanları: 11.12 listesi, birebir sırayla (31 renk + 1 harita)
| Alan | Açık | Koyu |
|---|---|---|
| `navyBand` | `#0F294A` | `#0F294A` |
| `navyBandRaised` | `#1A3357` | `#1A3357` |
| `contextStrip` | `#F1F5FA` | `#1A2B45` |
| `borderStrong` | `#C3CBD6` | `#34445F` |
| `textPlaceholder` | `#697586` | `#8B9AAF` |
| `textDisabled` | `#9AA5B4` | `#56657C` |
| `onNavyBand` | `#FFFFFF` | `#FFFFFF` |
| `onNavyBandVariant` | `#C5D4E8` | `#C5D4E8` |
| `textAction` | `#1A3357` | `#9BB3D3` |
| `textAccent` | `#B34400` | `#FF9A57` |
| `accentLine` | `#E05500` | `#FF8533` |
| `focusRing` | `#36537C` | `#9BB3D3` |
| `dybCorrect` | `#0B6E3E` | `#52CC8E` |
| `dybWrong` | `#D8333A` | `#F07575` |
| `dybBlank` | `#7E8A9B` | `#6E7C92` |
| `dybWrongBg` | `#FCEAEA` | `#3B1D22` |
| `dybBlankBg` | `#E8ECF1` | `#213049` |
| `delta` | `#36537C` | `#9BB3D3` |
| `eksik` / `eksikBg` | `#8A5A00` / `#FCF1D9` | `#F2C46D` / `#33270F` |
| `error` / `errorBg` | `#C42D35` / `#FCEAEA` | `#FF8F8F` / `#3B1D22` |
| `success` / `successBg` | `#0B6E3E` / `#E4F4EA` | `#52CC8E` / `#15301F` |
| `warning` / `warningBg` | `#8A5A00` / `#FCF1D9` | `#F2C46D` / `#33270F` |
| `info` / `infoBg` | `#36537C` / `#E2EAF4` | `#9BB3D3` / `#1A2B45` |
| `chartLine` | `#264066` | `#9BB3D3` |
| `chartHighlight` | `#E05500` | `#FF8533` |
| `chartGrid` | `#DCE2E9` | `#26354D` |
| `subject: Map<Subject, (Color bg, Color fg)>` | §4 açık sütunu | §4 koyu sütunu |

**Karar bekleyen ek alanlar** (Tur 1 ve 1.2/1.4'te tanımlı, 11.12 listesinde yok; bileşenler bunlara ihtiyaç duyuyor):

| Alan | Açık | Koyu |
|---|---|---|
| `bar` | `#FFFFFF` @0.92 | `#121D31` @0.92 |
| `primaryPressed` | `#091A31` | `#9BB3D3` |
| `dybOn` (D/Y/B glifi) | `#FFFFFF` | `#0A1424` |
| `dybCorrectBg` | `#E4F4EA` | `#133325` |
| `chartArea` | chartLine @0.10 | chartLine @0.14 |
| `chartSeries` | `[#264066, #E05500, #6C8BB6, #7E8A9B]` | belirtilmemiş |

`scrim` ve `onError` `ColorScheme`'de durur (§2.1).

### 10.2 `SmapText` alanları (11.12 `ext.*`)
`bodyStrong` (15/24/600) · `metricXl` (56/64/800/−1,5) · `metricLg` (40/48/800/−1) · `metricMd` (24/32/700/−0,4) · `metricSm` (17/24/700). Hepsinde `FontFeature.tabularFigures()` olur, renk verilmez (bağlamdan gelir).

`TextTheme` eşlemesi: `displaySmall`=display, `headlineSmall`=title-lg, `titleLarge`=title-md, `titleMedium`=headline, `titleSmall`=title-sm, `bodyLarge`=body-lg, `bodyMedium`=body, `bodySmall`=caption, `labelLarge`=label-lg, `labelMedium`=label-md, `labelSmall`=label-sm. Diğer `TextTheme` slotları **belirtilmemiş**.

### 10.3 `SmapTokens` (Tur 1 adı)
Tur 1'deki alanlar: `radius` (xs 4 · sm 8 · md 12 · lg 16 · xl 24 · full 999), `space` (4 · 8 · 12 · 16 · 24 · 32 · 48 · 64, gutter 16), `shadowRaised`, `shadowOverlay`, `duration` (100 · 150 · 250 · 350 · 1200), `curves` (standard, enter, exit), `blur` (bar 20, scrim 8).

Öneri: temadan bağımsız olanlar `static const` sınıflarında tutulur (`SmapRadius`, `SmapSpace`, `SmapDuration`, `SmapCurves`, `SmapBlur`). `SmapTokens` extension'ında yalnız temaya bağlı gölgeler kalır.