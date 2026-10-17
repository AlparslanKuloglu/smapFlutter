# SMAP · Bileşen Teslim Spesifikasyonu (Flutter / mihr_ui)

## 0. Kaynaklar, öncelik sırası ve okuma notları

**Okunan kaynaklar**
- Teslim panoları: `SMAP-11/12-11-13-Teslim-Bileşen-Listesi` (asıl liste), `SMAP-11/13-11-14-Teslim-Ekran-Bileşen-Eşlemesi`
- Tur notları: 11.1–11.11, 11.12 token tablosu, 11.15 hareket/haptik tablosu
- Kit panoları: `SMAP-01` 1.9–1.26
- Tur'larda genişleyen bileşenlerin ölçüleri için ekran panolarının markup'ı: SMAP-02…10

**Değerler çelişirse öncelik sırası:**
1. 11.13 ve 11.14 teslim panoları
2. Tur notlarındaki "G" genişletme maddeleri
3. Sonraki turun ekran markup'ı
4. Tur 1 kit panosu

Kalan çelişkiler bileşenin içinde **ÇELİŞKİ** diye işaretli ve §5'te toplu olarak listeli.

**Okuma notları**
- **Birim:** pt = Flutter logical px. Tasarım karesi iPhone 16 Pro, 402 × 874; güvenli alan üstte 62, altta 34. Kodda sabit değil `MediaQuery.padding` kullanılır.
- **Renk yazımı:** "açık / koyu". Rol adları 1.2 / 11.12 ile aynı.
- Değer panoda yoksa **belirtilmemiş** yazılır.
- **Tur 1 widget önerisi:** 11.1'deki ad. Bazıları ön eksiz (ör. `DybChip`, `RootBand`); burada hepsine `Smap` ön eki verildi.

---

## 1. Bütün bileşenlerde geçerli ortak kurallar

### 1.1 Bileşenlerde kullanılan renk rolleri

Kaynak 1.2 ve 11.12. 11.12'de olmayan dört rol 1.2'den alındı: `primary-pressed`, `bg-bar`, `scrim`, `dybOn`.

| Rol | Açık | Koyu | Flutter |
|---|---|---|---|
| bg-canvas | #F2F4F7 | #0A1424 | surface |
| bg-surface | #FFFFFF | #121D31 | surfaceContainerLowest |
| bg-raised (sheet) | #FFFFFF | #18263D | surfaceContainerLow |
| bg-sunken | #E8ECF1 | #213049 | surfaceContainerHighest |
| bg-navy (bant) | #0F294A | #0F294A | ext.navyBand |
| bg-navy-raised | #1A3357 | #1A3357 | ext.navyBandRaised |
| bg-context | #F1F5FA | #1A2B45 | ext.contextStrip |
| bg-bar | #FFFFFF %92 | #121D31 %92 | ext.bar |
| scrim | #091A31 %48 | #02060E %64 | scrim |
| border-subtle | #DCE2E9 | #26354D | outlineVariant |
| border-strong | #C3CBD6 | #34445F | ext.borderStrong |
| border-control | #697586 | #6B7D97 | outline |
| text-primary | #1B2232 | #EDF1F6 | onSurface |
| text-secondary | #556173 | #A9B5C6 | onSurfaceVariant |
| text-placeholder | #697586 | #8B9AAF | ext.textPlaceholder |
| text-disabled | #9AA5B4 | #56657C | ext.textDisabled |
| text-on-navy / -2 | #FFFFFF / #C5D4E8 | aynı | ext.onNavyBand(Variant) |
| text-action | #1A3357 | #9BB3D3 | ext.textAction |
| primary / on-primary | #0F294A / #FFFFFF | #C5D4E8 / #091A31 | primary / onPrimary |
| primary-pressed | #091A31 | #9BB3D3 | ext.primaryPressed |
| accent / on-accent | #FF6600 / #0F294A | aynı | secondary / onSecondary |
| accent-line | #E05500 | #FF8533 | ext.accentLine |
| focus-ring | #36537C | #9BB3D3 | ext.focusRing |
| dyb-correct / wrong / blank | #0B6E3E / #D8333A / #7E8A9B | #52CC8E / #F07575 / #6E7C92 | ext.dyb* |
| dyb glif (dybOn) | #FFFFFF | #0A1424 | ext.dybOn |
| dyb-wrong-bg / blank-bg | #FCEAEA / #E8ECF1 | #3B1D22 / #213049 | ext |
| delta | #36537C | #9BB3D3 | ext.delta |
| eksik / eksik-bg | #8A5A00 / #FCF1D9 | #F2C46D / #33270F | ext.eksik* |
| error / error-bg | #C42D35 / #FCEAEA | #FF8F8F / #3B1D22 | error |
| success / success-bg | #0B6E3E / #E4F4EA | #52CC8E / #15301F | ext |
| warning / warning-bg | #8A5A00 / #FCF1D9 | #F2C46D / #33270F | ext |
| info / info-bg | #36537C / #E2EAF4 | #9BB3D3 / #1A2B45 | ext |
| chart-line / highlight / grid | #264066 / #E05500 / #DCE2E9 | #9BB3D3 / #FF8533 / #26354D | ext |

**Ders renkleri** (zemin · vurgu; Phosphor glifi):

| Ders | Açık | Koyu | Glif |
|---|---|---|---|
| Türkçe | #F6ECE6 · #93573C | #2D211C · #E2A98D | TextAa |
| Edebiyat | #F6E7EC · #8A2F4E | #301A27 · #E494BE | Feather |
| Tarih | #FBF1DA · #8C6106 | #2C2513 · #E3B651 | Bank |
| Coğrafya | #E1EFFA · #1E6FAE | #12293C · #7DB9EC | Globe |
| Matematik | #FDE8E8 · #C42A36 | #341B1B · #F7847F | MathOperations |
| Geometri | #E7E9FB · #4450BE | #1D2144 · #A3ABF4 | Angle |
| Fizik | #DDF2F2 · #08737A | #0E2B2D · #5FCBD0 | Atom |
| Kimya | #F7E8F7 · #93359A | #271B33 · #C89AE3 | Flask |
| Biyoloji | #E4F3E3 · #2B7A35 | #16291A · #80CC89 | Dna |

### 1.2 Tipografi

Font: Plus Jakarta Sans, uygulamaya gömülür. Bütün rakamlarda `FontFeature.tabularFigures()`. Satır yüksekliği ve harf aralığı pt cinsinden.

| Stil | Değer | Flutter |
|---|---|---|
| display | 32/40 · 800 · −0,5 | displaySmall |
| title-lg | 24/32 · 700 · −0,3 | headlineSmall |
| title-md | 20/28 · 700 · −0,2 | titleLarge |
| headline | 17/24 · 700 · −0,1 | titleMedium |
| title-sm | 16/24 · 600 | titleSmall |
| body-lg | 16/24, okumada 16/26 · 400 | bodyLarge |
| body | 15/24 · 400 | bodyMedium |
| body-strong | 15/24 · 600 | ext.bodyStrong |
| caption | 13/20 · 500 | bodySmall |
| label-lg / md / sm | 16/24 · 14/20 · 12/16, hepsi 600 | labelLarge / Medium / Small |
| metric-xl / lg / md / sm | 56/64 800 −1,5 · 40/48 800 −1 · 24/32 700 −0,4 · 17/24 700 | ext.metric* |

Bileşenlerde ölçek dışı birleşimler de geçiyor. Her birinin yeri ilgili bileşende yazılı.
- 13/20 · 600 ve 13/20 · 700 (etiket, "Örnek", EksikTag)
- 15/20 · 700 (küçük D/Y/B sayısı)
- 20/24 · 700 (soru hücresi işareti)
- 15/22 (bilgi kutusu metni)
- 13/16 · 600

### 1.3 Şekil, gölge, boşluk ve dokunma alanı

**Köşe yarıçapı.** İç içe yüzeyde iç yarıçap = dış yarıçap − aradaki boşluk.

| Token | Değer | mihr_ui karşılığı |
|---|---|---|
| radius-xs | 4 | MihrRadius.xs |
| radius-sm | 8 | MihrRadius.md |
| radius-md | 12 | MihrRadius.xl |
| radius-lg | 16 | MihrRadius.xxl |
| radius-xl | 24 | MihrRadius.xxxxl |
| radius-full | 999 | MihrRadius.full |

Adlar kayık olduğu için ayrı bir `SmapRadius` sabit sınıfı önerilir.

**Gölge.** Bir yüzeyde ya kenar ya gölge olur. Kartlar ikisini de kullanmaz.

| Token | Açık | Koyu | Nerede |
|---|---|---|---|
| shadow-raised | 0 2 8 · #0F294A %8 | #000 %40 | sürüklenen kart, kamera düğmesi, büyüteç |
| shadow-overlay | 0 8 24 · #0F294A %16 | #000 %56 | toast, balon |

**Boşluk.** 4 pt ızgara; ölçek 4, 8, 12, 16, 24, 32, 48, 64. Sayfa kenarı 16.

**Dokunma alanı:**
- En az 48 × 48.
- 40 pt'lik görsel öğede üst ve alttan 4 pt görünmez pay bırakılır (`MaterialTapTargetSize.padded`).
- Liste satırı tek satırda en az 56, iki satırda 72.

**Bulanıklık** yalnız iki yerde var:

| Yer | CSS | Flutter |
|---|---|---|
| Alt çubuk | blur(20px) | sigma 20 → `MihrBackdropBlurs.xl` |
| Sheet perdesi | blur(8px) | sigma 8 → `MihrBackdropBlurs.md` |

CSS'deki blur değeri standart sapma (sigma) kabul edildi. `FrostedContainer`'da `overlayColor` her zaman bg-bar ya da scrim ile ezilir; mihr'in %60 beyaz/siyah varsayılanı kullanılmaz.

### 1.4 Odak halkası

- Açık temada: `box-shadow: 0 0 0 2 <zemin>, 0 0 0 4 #36537C`, yani 2 pt boşluk + 2 pt halka.
- Koyu temada halka #9BB3D3, boşluk rengi zemin rengi (sheet'te #18263D).
- Metin düğmesinde boşluk yok: `0 0 0 2 #36537C`.
- Segment seçeneğinde içe çizilir: `inset 0 0 0 2 #36537C`.

### 1.5 Hareket token'ları

| Token | Değer |
|---|---|
| instant | 100 ms |
| fast | 150 ms |
| base | 250 ms |
| slow | 350 ms |
| loop | 1200 ms |
| ease-standard | Cubic(0.2, 0, 0, 1) |
| ease-enter | Cubic(0, 0, 0, 1) |
| ease-exit | Cubic(0.3, 0, 1, 1); süresi girişin %70'i |

**Haptik sözlüğü:**
- `selectionClick`: seçim değişti
- `mediumImpact`: deklanşör ve kamera düğmesi
- `success`, `error`: iOS'ta UINotificationFeedbackGenerator, Android'de CONFIRM / REJECT için platform köprüsü gerekir

**Hareketi azalt** (`MediaQuery.disableAnimations`): kaymalar 150 ms opaklık geçişine döner, iskelet parıltısı durur. Haptikler değişmez.

### 1.6 Genel erişilebilirlik

- AA kontrast.
- Metin %130'a büyüdüğünde düzen kırılmaz; sabit yükseklik yok, adlar kesilmez.
- İkon düğmelerinin her birinin adı var (tooltip + `semanticLabel`).
- Renk hiçbir yerde tek ipucu değildir: glif, kalınlık ya da metin eşlik eder.
- Süs görselleri `ExcludeSemantics` ile atlanır.

### 1.7 mihr_ui ile ilişki

mihr_ui'de bugün yalnız şunlar var: token'lar, buton ailesi (`MihrButtonBase` ve Primary / SoftPrimary / Secondary / Tertiary / Link / Destructive), `MihrButtonSize` (xxs–xxl), `FrostedContainer`, `MihrBackdropBlurs`, `MihrThemeConfig`.

- SMAP'ın renk ve metin eklentileri (`SmapColors`, `SmapText`, `SmapTokens`) `MihrThemeConfig.extraExtensions` ile eklenir.
- `fontFamily: 'PlusJakartaSans'` ayarlanır.
- SMAP rolleri sabit; mihr'in palet üretimi bu rollerde kullanılmaz.
- smapFlutter'da bugün `mihr_ui` ve `phosphor_flutter` bağımlılığı yok. `fl_chart`, `flutter_card_swiper` ve `appinio_swiper` var.

---

## 2. Bileşenler

Her bileşen için başlıklar aynı:
- Kit / Tur ve 11.13'teki örnek ekranlar
- Amaç ve anatomi
- Ölçüler ve tipografi
- Renk (durumlara göre), koyu tema
- Hareket ve haptik, erişilebilirlik
- Ekranlar (11.14 eşlemesinden), notlar

### A · Kontroller

#### C01 · Button → `SmapButton`
**Kit 1.9 · Örnek 2.x–10.x · Tur 1 adı: `SmapButton`**

**Amaç:** Tek birincil eylem ve ikincil eylemler.

**Kurallar:**
- Bir ekranda bir birincil düğme olur; kamera düğmesi bu sayıma girmez.
- Pasif yerine doğrulama: form eksikken birincil dolu kalır, basınca ilk hatalı alana gidilir. Pasif durum yalnız işlem sürerken ya da sayaç bitmeden kullanılır.
- Turuncu düğme yok. Etiketler Türkçe başlık düzeninde; büyük harfle yazılmış düğme yok.
- İptal sözlüğü: "Vazgeç", "Tamam", "Kapat" (yalnız X'in adı), "Geri Al" (yalnız toast). "İptal" kullanılmaz.

**Anatomi:** isteğe bağlı baş ikon, etiket, isteğe bağlı son ikon. Yükleniyor durumunda etiketin yerine dönen gösterge gelir.

**Ölçüler:**
- **lg:** yükseklik 48, yan dolgu 20, radius 12.
  - Baş ikonlu: dolgu sol 16 / sağ 20.
  - Son ikonlu: dolgu sol 20 / sağ 16.
- **md:** yükseklik 40, yan dolgu 16; dokunma alanı 48.
- **text türü:** yan dolgu 12, iki boyda da.
- İkon 20 pt, etiketle arası 8.
- Yükleniyor: genişlik sabit kalır; gösterge 20 pt, çizgi 2,5, yuvarlak uç.
- Sheet'te tam genişlik.

**Tipografi:** lg için label-lg 16/24 · 600; md için label-md 14/20 · 600.

**Renk, açık tema:**

| Tür | Varsayılan | Basılı | Odak | Yükleniyor | Pasif |
|---|---|---|---|---|---|
| primary | #0F294A / #FFFFFF | #091A31 | §1.4 halkası | ray beyaz %32, yay #FFFFFF | #DCE2E9 / #9AA5B4 |
| secondary | #FFFFFF / #0F294A, 1,5 içe kenar #0F294A | #E2EAF4 + kenar | halka | ray #0F294A %20, yay #0F294A; kenar korunur | #FFFFFF / #9AA5B4, kenar 1,5 #C3CBD6 |
| quiet | #E8ECF1 / #1B2232 | #DCE2E9 | halka | ray #1B2232 %18, yay #1B2232 | #F2F4F7 / #9AA5B4 |
| danger | #C42D35 / #FFFFFF | #A3242B | halka | ray beyaz %32, yay #FFFFFF | #DCE2E9 / #9AA5B4 |
| text | zeminsiz / #1A3357 | #E2EAF4 zemin | 2 #36537C, boşluksuz | **yok** (metin düğmesi yüklenmez) | #9AA5B4 |
| text-danger (Tur 6 G7) | zeminsiz / #C42D35 | belirtilmemiş | halka | yok | belirtilmemiş |

**Koyu tema (1.23):**
- primary #C5D4E8 / #091A31; basılı #9BB3D3 (primary-pressed)
- secondary: zeminsiz / #C5D4E8, kenar 1,5 #C5D4E8
- quiet #213049 / #EDF1F6
- danger #FF8F8F / #3B0A10
- text #9BB3D3; text-danger #FF8F8F
- pasif #213049 / #56657C
- primary dışındaki türlerin koyu basılı rengi belirtilmemiş.

**Hareket:** basılıyken bir ton koyulaşır ve 0,98 ölçeğe iner; 100 ms, standard eğri, haptik yok.

**Erişilebilirlik:**
- Yükleniyorken erişilebilir ad "Yükleniyor"; çift dokunma engellenir.
- md boyda dokunma alanı 48.

**Sheet'te sıra:** birincil üstte, sessiz ya da ikincil altta. Tehlikeli onayda tehlikeli düğme üstte, "Vazgeç" altta.

**Ekranlar:** bütün panolar. Yükleniyor durumu 2.3'te.

**mihr_ui:**

| SMAP türü | mihr düğmesi |
|---|---|
| primary | `MihrPrimaryButton` |
| secondary | `MihrSecondaryButton` (kenar 1,5 #0F294A ile ezilir) |
| quiet | `MihrSoftPrimaryButton` (gri dolgu ile ezilir) |
| danger | `MihrDestructiveButton` (primary hiyerarşi) |
| text | `MihrLinkButton` |

- lg için `MihrButtonSize.xl` (48) kullanılır; yan dolgu 16 → 20, ikon 24 → 20 ezilir.
- md için `MihrButtonSize.md` (40) kullanılır; yan dolgu 12 → 16 ezilir.
- Yarıçap 12, gölge `MihrButtonShadows.flat`.

**Not:** 10.1'deki CodeCard düğmeleri 44 pt yüksek; ölçek dışı (§5).

#### C02 · Yalnız ikon düğmesi → `SmapIconButton`
**Kit 1.9 · Tur 1 adı yok · bütün ekranlarda**

**Ölçüler:**
- Dokunma alanı 48 × 48, radius 12.
- İkon 24 (Phosphor Regular).

**Varyantlar:**
- **plain:** geri ok renkleri #1B2232 / #EDF1F6. Düşük vurgulu favori 1.9'da #556173; 6.2, 7.3 ve 8.1'de #697586.
- **close (sheet):** 48 dokunma alanı içinde 36 pt daire, zemin #E8ECF1 / #213049, X ikonu 20 (çizgi 20) #1B2232 / #EDF1F6. Ekranlarda X 18. Sheet başlığında margin-top −8.
- **onNavy:** beyaz ikon. Kit örneğinde lacivert zeminli 4 pt dolgulu kap içinde.
- **cameraTranslucent:** 40 pt daire, zemin rgba(10,20,36,.64), beyaz ikon 20/22.
- **removeCircle:** Programı Düzenle'de 32 pt daire #E8ECF1 + X 16 (çizgi 20).
- **clearSmall:** arama temizleme; 40 dokunma alanı, 24 pt daire, X 12.

**Durumlar:** odak §1.4. Basılı rengi belirtilmemiş; genel kural "bir ton koyulaşır, 100 ms". Favori düğmesi aç/kapa: Star → Star Fill, `aria-pressed`.

**Erişilebilir adlar:** "Geri", "Kapat", "Filtrele", "Favorilere ekle" / "Favorilerden çıkar", "Şifreyi göster" / "Şifreyi gizle", "Aramayı temizle", "Yeni görüşme", "Öğrenci ekle", "Nasıl çekilir?", "Önceki ay" / "Sonraki ay".

#### C03 · BarAction → `SmapBarAction`
**Kit 1.18 / Tur 6 G7, Tur 8 G4 · Örnek 3.4, 9.2, 10.4 (11.14'e göre 10.3) · Tur 1 adı yok**

**Amaç:** Detay barının sağındaki tek eylem: "Düzenle", "Yeni Program", "Eksiklerim (31)", "Bitti", "Kaydet".

**Ölçüler:**
- Yükseklik 40, yan dolgu 14, radius 12, dokunma alanı 48.
- Baş ikon 20 (ör. Plus), ikon ile etiket arası 6.

**Tipografi:** 14/20 · 600.

**Renk:**

| Durum | Açık | Koyu |
|---|---|---|
| Çerçeveli (varsayılan) | #FFFFFF / #0F294A, 1,5 içe kenar #0F294A | zeminsiz / #C5D4E8, kenar 1,5 #C5D4E8 |
| Dolu ("Kaydet") | #0F294A / #FFFFFF, kenarsız | belirtilmemiş |
| Pasif | #DCE2E9 / #9AA5B4, kenarsız | belirtilmemiş |

**Alan yanındaki varyant (1.20, 10.3):** "Kontrol Et", "Oluştur". Yükseklik 48, yan dolgu 14, 14 · 600, çerçeveli; alanla arası 8.

**Not:** Kit 1.9'daki 40 boy düğmede yan dolgu 16; BarAction'da 14.

#### C04 · Segment → `SmapSegmented<T>`
**Kit 1.10 · Örnek 3.4, 7.1, 7.2, 8.1 · Tur 1 adı: `SmapSegmented`**

**Amaç:** Aynı listenin görünümünü değiştirir (TYT / AYT). İçerik tamamen değişiyorsa sekme kullanılır.

**Anatomi:** ray, 2–4 seçenek, seçili seçenekte başparmak; isteğe bağlı sayaç satırı.

**Ölçüler:**
- Ray: radius 12, iç dolgu 4, seçenekler arası 4.
- Başparmak: radius 8, yükseklik 36. Görünür yükseklik 44, dokunma 48.
- Seçenek genişliği etikete göre paylaşılır; örnekte flex 1 / 1,35 / 1 / 0,8. Hiçbir etiket kesilmez.

**Tipografi:** 14/20 · 600.

**Renk, açık:** ray #E8ECF1; seçili başparmak #0F294A + #FFFFFF metin; seçili olmayan metin #556173; odak `inset 0 0 0 2 #36537C`.

**Sayaçlı varyant (Tur 5 G2):**
- Seçenek min yükseklik 48, dolgu 4, iki satır.
- Başlık 14/20 · 700 (#1B2232; seçiliyken #FFFFFF).
- Sayaç 13/20 · 500 (#556173; seçiliyken #C5D4E8).
- İki seçenekte yer yetiyorsa tek satır: "TYT · 7 eksik", 14/20 · 600, yükseklik 36. 3–4 seçenekte iki satıra geçer.
- Sayı sıfırsa "eksik yok" / "boş yok" / "kart yok" yazar. Veri yoksa o seçeneğin sayaç satırı çizilmez. Rozet yok.
- Sayaç birimleri: eksik, kart, soru, yanlış, boş, deneme.

**onNavy varyantı:** ray #1A3357, başparmak #FFFFFF / #0F294A, seçili olmayan metin #C5D4E8 (8,43:1).

**Metin %130:** etiket sarılır; min yükseklik 44, dolgu 4/2, 18/24.

**Koyu:**
- Ray #213049; başparmak #C5D4E8 / #091A31; seçili olmayan #A9B5C6.
- Sayaçlı: seçili olmayan başlık #EDF1F6, sayaç #A9B5C6; seçili başlık #091A31, sayaç #1A3357.

**Hareket:** başparmak 250 ms standard eğriyle kayar, etiket rengi çapraz geçer; `selectionClick`. Hareketi azaltta 150 ms opaklık.

**Erişilebilirlik:** radyo grubu gibi okunur: "TYT, 28 eksik, seçili, 3 seçenekten 2."

**Ekranlar:** 2.5–2.6 (rol), 3.4 (Gün / Hafta), 3.5 (Çantam / Dersler), 4.7 (kolon, sayaçlı), 5.1 (puan türü), 5.4 (Tümü / Yanlışlar / Boşlar, sayaçlı), 6.1 süzgeç sheet'i (Sınav / Alan), 6.2 (tür, sayaçlı), 7.1 (bant içinde, onNavy), 7.2 ve 8.1 (sayaçlı), 7.4.

#### C05 · InScreenTabs → `SmapTabBar`
**Kit 1.10 · Örnek 5.3, 10.4 · Tur 1 adı: `SmapTabBar`**

**Amaç:** Aynı nesnenin bölümleri arasında gezinme. Konum bildirdiği için alt çubukla aynı dili kullanır: turuncu çizgi ve kalın etiket.

**Ölçüler:**
- Yükseklik 48, alt ayraç `inset 0 -1 0 #DCE2E9`.
- Gösterge: 3 pt, radius full; genişlik etiket kadar (Genel 46, Sorular 62, Konular 64, Kartlar 58, Denemelerim 98). Altta ortalı.
- Sabit varyant: sekmeler eşit flex.
- Kaydırılabilir varyant (sığmazsa kendiliğinden): baş ve son pay 16, sekmeler arası 24, sekme dolgusu 0/4, gösterge sekme genişliğinde. Devam eden kenarda 40 pt'lik beyazdan saydama solma. Seçili sekme görünür alana kaydırılır.
- %130 metin: 19,5/28, yükseklik 52.

**Tipografi:** 15/24. Seçili 700 #1B2232, seçili olmayan 600 #556173.

**Gösterge rengi:** #E05500 (accent-line).

**onNavy (kök bantta):**
- Ayraç yok. Seçili olmayan #C5D4E8 · 600; seçili #FFFFFF · 700.
- Gösterge #FF6600 (orange-500; lacivertte 4,98:1).
- Bantta alt boşluk 8 (6.1).

**Koyu:** ayraç #26354D; seçili olmayan #A9B5C6, seçili #EDF1F6; gösterge #FF8533. Bant üstünde gösterge yine #FF6600.

**Hareket:**
- Gösterge 250 ms standard eğriyle kayar.
- İçerik 1.8'e göre yatay geçer; 5.3'e göre 150 ms çapraz geçer.
- `selectionClick`.

**Erişilebilirlik:** tablist; seçilen sekme duyurulur; kaydırılabilir sekmede seçim değişince odak kaybolmaz.

**Ekranlar:**
- 5.3–5.10: 4 sekme, kısa barın altına yapışır (`SliverPersistentHeader`).
- 6.1–6.4: bantta 2 sekme.
- 10.4: 3 sekme (Analiz / Denemeler / Program).

#### C06 · Chip → `SmapChip`, `SmapChipGroup`, süzgeç hapı `SmapFilterPill`
**Kit 1.11 · Örnek 2.2, 6.1, 10.5 · Tur 1 adı: `SmapChip`**

**Amaç:** Dokunulur seçim. Tam yuvarlak ve kenarlıdır. Kategoriye göre renkli hap yok; renk yalnız ders noktasında.

**Hap çip, kit ölçüsü:**
- Yükseklik 36 (dokunma 48), yan dolgu 14, radius full, ikon ile etiket arası 6.
- Tipografi 14/20 · 600.
- Varsayılan: #FFFFFF / #1B2232, içe kenar 1 #697586 (4,68:1).
- Seçili: #0F294A / #FFFFFF, kenarsız, sol dolgu 10, baş ikon Check 16 (çizgi 24). Renk tek ipucu değildir.
- Odak: §1.4. Pasif: #9AA5B4, içe kenar 1 #C3CBD6; neden yanında yazar.

**Ders çipi:** ad + 10 pt nokta (ders vurgusu). Seçiliyken noktanın etrafında 2 pt #FFFFFF halka. "Genel" bir ders değil, noktası yok.

**Kare seçim çipi (şık):**
- 48 × 48, radius 12, içe kenar 1 #697586.
- Tipografi: kitte 17 · 700; ekranlarda 16/24 · 700.
- "Boş" seçeneği: kitte dolgu 0/16 · 15 · 700; 4.7'de 64 genişlik.
- Seçili #0F294A / #FFFFFF.
- Sınıf çipleri 56 × 48, "Mezun" 88 (Tur 7 G4).

**Ekran boyları:**
- **md:** yükseklik 40, dolgu 0/14, 15/20 · 600. 6.1 süzgeç sheet'i, 7.2, 10.5.
- **lg:** yükseklik 48, dolgu 0/18, 16/24 · 600. 2.2 alan seçimi.
- **ÇELİŞKİ:** ekran çiplerinde seçili durumda Check ikonu çizilmemiş; 6.1 sheet'inde ders noktası da yok.

**`SmapFilterPill` (6.1, 7.2):**
- 40 pt hap, md ölçü.
- 6.1: "TYT · Genel" + son ikon CaretDown 18 (çizgi 20); `aria-haspopup=dialog`; süzgeç sheet'ini açar.
- 7.2: "Eksiklerim (31)" + baş ikon Flag 16; aç/kapa (`aria-pressed`), seçiliyken lacivert dolgu.

**Koyu:** seçili olmayan zemin saydam, metin #EDF1F6, kenar 1 #6B7D97; seçili #C5D4E8 / #091A31; noktalar koyu ders vurgusunda.

**Hareket:** dolgu ve işaret 150 ms standard eğriyle; `selectionClick`.

**Erişilebilirlik:**
- Filtre çipi `aria-pressed`, çoklu seçim.
- Seçim çipi radyo grubu.
- Kare çip radyo grubu: "İşaretlenen şık".

**Ekranlar:** 2.2 (kare ve hap), 4.7 düzeltme sheet'i (kare), 6.1 (süzgeç), 7.2 (süzgeç hapı), 10.5 (Kiminle: Tümü / Öğrenci / Veli). 1.20 / 1.24 filtre sheet'i.

#### C07 · Etiket → `SmapTag`
**Kit 1.11 · Tur 1 adı: `SmapTag`**

**Amaç:** Yalnız bilgi verir, dokunulmaz. Köşeli, kenarsız, nötr.

**Ölçüler:** yükseklik 24, yan dolgu 8, radius 8, ikon ile metin arası 4. İsteğe bağlı baş ikon 14; "Web'de" etiketinde ArrowSquareOut (çizgi 20).

**Tipografi ve renk:**
- 13/20 · 600.
- Açık: #E8ECF1 / #1B2232 (13,39:1). Koyu: #213049 / #EDF1F6.

**Varyantlar:**
- Noktalı "Bu hafta" (3.4): 6 pt #E05500 nokta, sağ boşluk 6.
- %130 metin: yükseklik 30, 17 px.

**Kural:** sayı taşıyan etiket ne saydığını söyler ("31 eksik", "Az soru", "40 soru"); asla yalnız "31" yazmaz. "Deneme: N" etiketi hiç gösterilmez.

**Ekranlar:** sınav türü (AYT / TYT / SOS-2), "Az soru", "Web'de", "Eksiklerimde", "Öğrenci" / "Veli", "eksik yok".

#### C08 · EksikTag → `SmapEksikTag`
**Tur 5 G3 · Örnek 3.1, 3.5, 7.x**

**Amaç:** Tek eksik işareti: bayrak + "eksik" sözcüğü, amber. Kırmızı yanlış cevaba ayrılmıştır.

**Ölçüler:** yükseklik 24, yan dolgu 8, radius 8, ikon ile metin arası 4. Flag ikonu 14 (çizgi 20).

**Tipografi:** 13/20.
- **ÇELİŞKİ:** Tur 5 notu 600 diyor, ekran CSS'i (`.ek`) 700.

**Renk:** açık #FCF1D9 zemin / #8A5A00 metin (5,28:1); koyu #33270F / #F2C46D.

**Metin:** "N eksik"; madde düzeyinde "Eksik". Sıfırsa çizilmez; "0 eksik" yazılmaz.

**Erişilebilirlik:** "3 eksik" diye okunur.

**Ekranlar:** 3.1 ders karoları, 7.2 konu satırları, 7.3 alt başlık / madde / kart sheet'i, 8.1 kart.
- **ÇELİŞKİ:** 7.1 Derslerim'de ders satırının eksik sayısı nötr SmapTag ile çizilmiş; 11.13 SubjectRow için EksikTag diyor.

#### C09 · TextField → `SmapTextField`
**Kit 1.12 · Örnek 2.3–2.6, 9.2–9.5, 10.3 · Tur 1 adı: `SmapTextField`**

**Anatomi:** üstte etiket, alan (değer, isteğe bağlı son ikon), altta yardım ya da hata metni.

**Ölçüler:**
- Etiket alanın 8 üstünde.
- Alan: yükseklik 48, yan dolgu 16, radius 12, kenar 1.
- Yardım / hata metni alanın 6 altında. Alanlar arası 24.
- Son ikon kutusu 48 × 48; ikonlu alanda sağ dolgu 48.

**Tipografi:**
- Etiket 14/20 · 600 #1B2232. "(isteğe bağlı)" eki 500 #556173.
- Değer 16/24 · 400 (iOS yakınlaştırmaz).
- Yardım 13/20 #556173.

**Durumlar, açık:**

| Durum | Görünüm |
|---|---|
| Boş | kenar 1 #697586, zemin #FFFFFF. Placeholder yalnız "Örn: …" biçiminde, #697586 |
| Odak | kenar 2 #1A3357 (navy-800; 1 kenar + 1 içe gölge) |
| Hata | kenar 2 #C42D35; mesaj 13/20 · 600 #C42D35, baş ikon WarningCircle 16 (çizgi 20), arası 6. Mesaj çözüm söyler |
| Canlı kontrol, sürüyor | sağda dönen gösterge (2.5) |
| Canlı kontrol, başarılı | sağda CheckCircle 22 #0B6E3E; mesaj 13 · 600 #0B6E3E ("Bu kullanıcı adı boşta.") |
| Pasif | zemin #F2F4F7, kenar #C3CBD6, metin ve etiket #9AA5B4 |
| Salt okunur | zemin #E8ECF1, kenar saydam, metin tam kontrastta, sağda Lock 20 #556173 |

**Varyantlar:**
- **password:** sağda 48 pt ikon düğmesi, Eye / EyeSlash 24 #556173; ad "Şifreyi göster" / "Şifreyi gizle"; ipucu "En az 8 karakter.".
- **masked:** telefon "+90 5XX XXX XX XX" sayı klavyesiyle; koçluk kodu "MOZK-4821" (4 harf + 4 rakam, tire kendiliğinden).
- **inline action:** alan + SmapBarAction 48, arası 8.

**Koyu:** zemin #121D31, kenar #6B7D97 (4,02), metin #EDF1F6, placeholder #8B9AAF, odak #9BB3D3, hata #FF8F8F. Koyu pasif ve salt okunur belirtilmemiş.

**Doğrulama:**
- Alan bırakılınca ya da gönderince; ilk hatadan sonra yazarken güncellenir.
- Gönderimde odak ilk hatalı alana gider; 350 ms kaydırma, hareketi azaltta doğrudan.
- Kullanıcı adı kontrolü 400 ms gecikmeli. Çevrimdışıyken metin "Bağlanınca kontrol edilecek.".

**Hareket:** hata kenarı 150 ms + `error` haptiği; alan sarsılmaz.

**Klavye ve otomatik doldurma:** e-posta klavyesi; telefon ve kod için sayı klavyesi. AutofillHints: username, password, newPassword, oneTimeCode. Önceden dolu alan yok.

**Erişilebilirlik:** görünür etiket; hata mesajı alana bağlı (`errorText` + live region).

#### C10 · SearchField → `SmapSearchField`
**Kit 1.12 · Örnek 3.4, 10.2, 10.5**

**Ölçüler:** TextField çerçevesi (48 yükseklik, radius 12, kenar 1 #697586).

**Kit varyantı:**
- Sol dolgu 44; baş ikon MagnifyingGlass 20 (çizgi 18) #556173, 48 kutu içinde.
- Sağda 48 pt temizle düğmesi, X 20 #556173; ad "Aramayı temizle".

**Ekran varyantı (3.4, 10.2, 10.5):**
- İkon ile metin arası 10, büyüteç çizgisi 16.
- Temizle düğmesi 40 dokunma alanı, 24 pt daire #E8ECF1, X 12 (çizgi 24), sağ margin −12.
- ÇELİŞKİ: §5.

**Etiket:** görünmez ama okunur ("Öğrenci ara"). Placeholder "Program ara", "Öğrenci ara", "Görüşme ara".

**Arama davranışı:**
- tr-TR katlama: `toLowerCase(tr)` sonra ı→i (I/ı/İ/i doğru eşleşir).
- Ad ve soyad token'larında önek eşleşmesi; programda ad ve motto içinde.
- 150 ms gecikme. 50'den fazla öğrencide arama sunucuda.

**Eşleşme vurgusu:** `mark` zemini #FCF1D9, metin #1B2232, radius 4, yan dolgu 1.

**Sonuç yoksa (3.4):** kart, dolgu 24/16/12, ortalı:
- "“kasım” ile eşleşen program yok" 16 · 700
- açıklama 13 #556173
- metin düğmesi "Aramayı Temizle"

**Koyu:** belirtilmemiş (TextField koyu rolleri).

#### C11 · CodeInput → `SmapCodeInput`
**Kit 1.12 · Örnek 2.4**

**Ölçüler:**
- 6 kutu, her biri 48 × 56, radius 12, kenar 1 #697586, zemin #FFFFFF, kutular arası 8.
- Rakam 24/32 · 700 #1B2232, ortalı.
- Odaklı kutu: kenar 2 #1A3357.
- Grup etiketi "Doğrulama kodu" 14 · 600. Altında yardım metni 13 ("Kodu … adresine gönderdik.").
- Tekrar gönder: pasif metin düğmesi "Kodu Tekrar Gönder (0:24)"; kitte 15/24 · 600 #9AA5B4.

**Davranış:**
- Sayı klavyesi, tek kullanımlık kod doldurma; yapıştırınca 6 kutu birden dolar.
- Tekrar gönderme 30 sn sonra açılır; kod 10 dk geçerli (Tur 7).
- Hatada kutular 150 ms sallanır + `error` haptiği; hareketi azaltta sallanma yok.
- Hata durumunun görsel stili belirtilmemiş.

**Erişilebilirlik:** tek alan gibi okunur: "Doğrulama kodu, 6 hane". Kutuların adları "1. hane" … "6. hane".

**Koyu:** belirtilmemiş.

#### C12 · SelectField → `SmapSelectField`
**Kit 1.12 · Örnek 2.5, 9.2, 10.3, 10.5**

**Ölçüler:** TextField çerçevesi, düğme gibi davranır; değer 16/24; sonda CaretDown 20 (çizgi 18) #556173.

**Davranış:** yerinde liste açmaz; alttan BottomSheet açar. Sheet'te SmapRadio satırları (56); seçince sheet kapanır, ayrı onay yok.

**Pasif:** zemin #F2F4F7, kenar #C3CBD6, metin / etiket / ok #9AA5B4. Yardım metni nedeni söyler ("9. ve 10. sınıfta alan seçilmez.").

**Koyu:** belirtilmemiş.

#### C13 · TextArea → `SmapTextArea`
**Kit 1.12 / Tur 9 G7 · Örnek 10.5–10.6**

**Ölçüler:**
- Kit: yükseklik 104. 10.6: min yükseklik 120.
- Dolgu 12/16, radius 12, kenar 1 #697586, metin 16/24.
- Odak kenarı #1A3357.
- Karakter sayacı sağa hizalı, 13/20 #556173, "44/500"; üst sınır 500.

**Davranış:** kaydetme hatasında sheet açık kalır, metin korunur, toast çıkar.

#### C14 · Checkbox → `SmapCheckbox`
**Kit 1.13 · Örnek 2.5, 3.5, 9.6 · Tur 1 adı: `SmapCheckbox`**

**Ölçüler:**
- Kutu 24, radius 4, dokunma 48.
- Satır min yükseklik 48, kutu ile etiket arası 12; bütün satır dokunulabilir.
- Etiket 15/24 · 400 #1B2232. Etiketteki bağlantılar altı çizili, #1A3357 · 700, çizgi aralığı 3; metni sheet'te açar.

**Durumlar, açık:**
- Boş: içe kenar 2 #697586.
- Seçili: zemin #0F294A + Check 16 (çizgi 28) #FFFFFF.
- Pasif: içe kenar 2 #C3CBD6, etiket #9AA5B4.
- Odak: §1.4 (çizimi belirtilmemiş).

**Koyu:** boş kenar #6B7D97; seçili #C5D4E8 + Check #091A31.

**Hareket:** 150 ms standard; `selectionClick`.

#### C15 · Radio → `SmapRadio`, `SmapRadioListTile`
**Kit 1.13 · Örnek 2.5, 3.5**

**Kontrol:**
- 24 pt daire, içe kenar 2 #697586.
- Seçili: içe kenar 2 #0F294A + ortada 12 pt nokta #0F294A.
- **ÇELİŞKİ:** 2.2'deki RoleOption radyosunda seçili durum `inset 0 0 0 7px #0F294A` (7 pt halka) olarak çizilmiş.

**Sheet içi satır (kit):**
- Min yükseklik 56, yan dolgu 16, aralık 12.
- Etiket 16/24 · 600 solda (flex), kontrol sağda.
- Satırlar arası ayraç 1 #E8ECF1. Kap radius 16, içe kenar 1 #DCE2E9.

**Ekran satırı (3.5 konu sheet'i, `.ro`):** min yükseklik 56, dolgu 8/24, aralık 12. Grup başlığı 13 · 700 #556173, dolgu 12/24/0.

**Koyu:** kenar ve nokta #C5D4E8.

**Hareket:** 150 ms; `selectionClick`.

#### C16 · Switch → `SmapSwitch`
**Kit 1.13 · Örnek 9.6 · Tur 1 adı: `SmapSwitch`**

**Ölçüler:** 52 × 32, radius full, dokunma 48.

**Durumlar:**

| Durum | Ray | Baş | İşaret |
|---|---|---|---|
| Kapalı | saydam, içe kenar 2 #697586 | 16 pt #697586, sol üst 8,8 | yok |
| Açık | #0F294A | 24 pt #FFFFFF, sağdan ve üstten 4 | Check 14 (çizgi 28) #0F294A |
| Odak | açık durum + §1.4 halkası | | |
| Pasif, kapalı | içe kenar 2 #C3CBD6 | #C3CBD6 | yok |
| Pasif, açık (9.6, sistem izni kapalı) | #DCE2E9 | #FFFFFF | #9AA5B4; satır başlığı #697586 |
| Koyu, açık | #C5D4E8 | #091A31 | #C5D4E8 |
| Koyu, kapalı | içe kenar #6B7D97 | #6B7D97 | yok |

**Davranış:** değişiklik anında kaydedilir, ayrı "Kaydet" yok. Hata olursa anahtar geri döner ve toast çıkar.

**Hareket:** baş kayar ve büyür; 150 ms standard; `selectionClick`.

**Erişilebilirlik:** "Deneme sonucun hazır, açık, anahtar".

### B · Satırlar, kartlar, kutular

#### C17 · SettingsRow → `SmapSettingsRow`
**Kit 1.13 · Örnek 9.1, 9.6, 9.7 · Tur 1 adı: `SmapRow`**

**Ölçüler:**
- Min yükseklik 56 (iki satırda 72), dolgu 12/16, aralık 12.
- Baş ikon 24 #556173.
- Satır içi ayraç 1 #E8ECF1; metnin başladığı yerden başlar (soldan 52).

**Tipografi:**
- Başlık 16/24 · 600 #1B2232.
- Alt metin 13/20 #556173.
- Değer 15/24 #556173.

**Sağ öğe seçenekleri:**
- Ok: CaretRight 20. Kitte çizgi 18; ekranlarda çizgi 16, #556173.
- Değer + ok ("22:00–08:00").
- SmapSwitch.
- Dış bağlantı: ArrowSquareOut.
- SmapTag.

**Tehlikeli satır:**
- #C42D35 ikon (SignOut) ve başlık.
- Ok taşımaz; ayrı grupta durur; onay sheet'i açar.
- Erişilebilirlik: "Çıkış Yap, düğme, onay ister".

**Koyu:** zemin #121D31, ayraç #26354D, başlık #EDF1F6, ikon #A9B5C6, tehlikeli #FF8F8F.

**Basılı durum:** belirtilmemiş.

#### C18 · ListGroup → `SmapListGroup`
**Kit 1.13 · Örnek 9.1, 9.6, 9.7**

- Grup başlığı 13/20 · 600 #556173; margin alt 8, sol 4.
- Kap: zemin #FFFFFF / #121D31, radius 16, içerik kırpılır.
- Gruplar arası 20.

#### C19 · SectionHeader → `SmapSectionHeader`
**Tur 6 G2 · Eşleme 3.1–3.3, 10.1**

- Başlık 20/28 · 700 · −0,2 (title-md).
- İsteğe bağlı meta 13/20 #556173, başlığın 2 altında.
- Sağda en çok bir metin düğmesi: yükseklik 40, sağ margin −12 ("Programım", "Öğrenci Ekle" + Plus 20).
- Bölümler arası 28; başlıktan içeriğe 12.
- "kart + başlık + Tümü ›" kalıbı yok.

#### C20 · SubjectRow → `SmapSubjectRow`
**Kit 1.16 / Tur 5 G1 · Örnek 3.1, 7.1**

**Ölçüler:**
- Min yükseklik 72, dolgu 12/16, aralık 12.
- Glif karosu 40 (Tur 5), radius 12; ders zemini + ders vurgusu renginde glif 22.
- **ÇELİŞKİ:** kit 1.16'da glif karosu 48.

**Anatomi:**
- Ad 16/24 · 600, "TYT" öneki yok.
- İsteğe bağlı alt satır 13 #556173: test adı, ör. "Sosyal Bilimler 2 testi".
- Sağda EksikTag ya da "eksik yok" Tag, ya da "Web'de" Tag (ArrowSquareOut 14).
- Ok 20.

**Kart ilerlemesi** (yalnız verisi olan derste):
- Ray 8, ders vurgusu dolgu, satırın 8 altında.
- Metin "41 / 64 kart biliniyor" (1.16) ya da "41/64 kart" (7.1), 13 #556173.

**%130 metin:** ad 21/30 ile sarılır; etiket adın altına iner.

**Koyu:** koyu ders tonları, koyu etiketler.

**Erişilebilirlik:** "Matematik, web'de açılır".

**Davranış:** çevrimdışıyken Web'de dersleri listeden gizlenir.

#### C21 · SubjectTile → `SmapSubjectTile`
**Tur 6 G3 · Örnek 3.1**

**Ölçüler:**
- Genişlik 132, dolgu 16, radius 16, zemin #FFFFFF / #121D31.
- Dikey, sola hizalı, öğeler arası 12.
- Glif karosu 40, glif 22. Ad 16/24 · 600, sarılır. EksikTag ya da "Web'de" Tag adın 6 altında.

**Şerit:** yatay, karolar arası 8, yan dolgu 16. Eksiği çok olandan başlar; Matematik ve Geometri sonda.

**Davranış:** karo ders detayını açar (son TYT/AYT seçimiyle).

**Erişilebilirlik:** "Tarih, 60 eksik".

#### C22 · TopicRow → `SmapTopicRow`
**Kit 1.16 / Tur 5 · Örnek 7.2**

**Ölçüler (Tur 5, 7.2):**
- Min yükseklik 64, dolgu 12/16, aralık 12.
- Numara rozeti 28 pt daire, zemin #E8ECF1 / #213049, 13/28 · 700, ortalı.
- Ad 16/24 · 600, iki satıra kadar sarılır, kesilmez.
- EksikTag (eksik > 0 ise), ok 20.

**Kit 1.16 ilk hâli** (yerini Tur 5 aldı): numara sütunu 24 genişlik, sağa hizalı, 15/24 · 600 #556173; min yükseklik 56.

**Kural:** numara 1..n kesintisiz, istemcide üretilir; süzülmüş listede tam listedeki numara korunur.

#### C23 · TopicResultRow → `SmapTopicResultRow`
**Kit 1.15 / Tur 3 · Örnek 5.5, 5.10**

**Ölçüler:**
- Dolgu 12/16, min yükseklik 72, aralık 12.
- Ad 16/24 · 600, sarılır.
- Meta satırı adın 6 altında, öğeler arası 6/10: kelimeli küçük D/Y/B sayacı + "Az soru" Tag.
- Sağda SmapSuccessRing 48.

**Kurallar:**
- Sıralama yüzde artan; eşitlikte soru sayısı çok olan önce.
- Yüzde = `(d*100/n).round()`.
- "Az soru" n ≤ 2 olduğunda.

**Koyu (5.10):** kart #121D31, ayraç #26354D, halka #9BB3D3.

**Davranış:** satırın tamamı konu detayını açar.

**Üst kart "En çok kaçırdığın konu":**
- Kart dolgusu 16.
- Etiket 13 · 600 #556173; konu 17 · 700; cümle 15.
- Tek birincil "Bu Konuyu Çalış".

#### C24 · ExamRow → `SmapExamRow`
**Tur 4 G2 · Örnek 6.2, 10.4**

**Ölçüler:**
- Dolgu 12/16, öğeler üstten hizalı, aralık 12.
- Kapak 40 × 54, radius 6, zemin #DCE2E9. ÇELİŞKİ: §5'teki radius maddesi.

**Anatomi:**
- Ad 16/24 · 600.
- Meta satırı adın 4 altında, öğeler arası 4/8: Tag (tür) + kısa tarih 13 + "· yayınevi" 13.
- Harfli küçük D/Y/B, metnin 6 altında.
- Sağda net 24/32 · 700 · −0,4 + "net" 13 · 600 #556173, sağa hizalı.
- Favori düğmesi 48 dokunma alanı, Star 20. Kapalı #697586; açık Star Fill **#0F294A**. ÇELİŞKİ: §5.

**Liste:** sayfa başına 8 deneme; altta küçük dönen gösterge. Liste bitince "Hepsi bu kadar" yazılmaz.

#### C25 · ExamCard → `SmapExamCard`
**Kit 1.16 · Örnek 3.1 (özet), 6.2**

**Kart varyantı (1.16):**
- Dolgu üst 12, sağ 4, alt 12, sol 16; radius 16; aralık 12.
- Kapak 56 × 76, radius 8, zemin #E8ECF1 + içe kenar 1 #DCE2E9, yer tutucu ikon 22 #697586.
- Ad 16 · 600; yayınevi 13; Tag + tarih (arası 8).
- Küçük D/Y/B 8 altta, öğeler arası 10.
- Sağ sütun: favori 48 × 40 (ikon 20); net 24/32 + "net" 13; sağ dolgu 12.

**Özet varyantı ("Son denemen", 3.1):**
- Kart dolgusu 16.
- Ad 16/24 · 700; meta 13 "Örnek Yayınları · AYT · 5 Eki. 2026".
- Net satırı 12 altta: 40/48 · 800 · −1 + "net" 15/24 · 600 #556173.
- Delta: 13/20 · 700 #36537C + ArrowUp 14, ardından "önceki AYT'ye göre" 13 #556173.
- Kelimeli küçük D/Y/B 8 altta.
- Ayraç (margin 16/0/12).
- "En çok kaçırdığın konu" 13 · 700 #556173; cümle 15/24.
- Birincil "Analizi Gör" 16 altta, tam genişlik.
- Boş hâl: "Henüz deneme okutmadın." + bir cümle + birincil "İlk Denemeni Okut".

**Kural:** veri yoksa alan çizilmez. Ad ve yayınevi ayrı satırda; "(Test)" eki yok.

#### C26 · ExamHeader → `SmapExamHeader`
**Tur 3 G3 · 5.3; 5.1 sonuç anı varyantı**

**Deneme Detay başlığı (5.3):**
- Kapak 48 × 64; metinde radius-sm, markup'ta 6. Zemin #DCE2E9, ikon 22 #697586.
- Yayınevi 13 · 600 #556173; ad 20/28 · 700.
- Tag + tarih 13, 4 altta, arası 8.
- Net 40/48 · 800 · −1 + "net" 17/24 · 600 #556173, arası 8.
- Büyük D/Y/B.
- Puan kartı: surface, radius 16, dolgu 12/16.
  - Başlıkta alan adı 13 · 600.
  - İki sütun, arası 12: değer 24/32 · 700 · −0,4 + etiket 13 · 600 ("Yerleştirme puanı", "Sıra" — sıra "48.215." biçiminde).
  - Veri yoksa çizilmez.

**Sonuç anı varyantı (5.1):**
- Kapak 56 × 76, radius 8. Ad 17/24 · 700. Tag + tarih 6 altta.
- Net metric-xl 56/64 · 800 · −1,5.
- Delta 15/24: ok 18 (çizgi 20) #36537C, değer 700 #36537C, açıklama #556173.
- Bilgi satırı kartı: min yükseklik 64, dolgu 12/16; 40 pt daire #E2EAF4 / #36537C + Cards 22; metin 15 · 600; ok.

**Hareket:**
- 5.3: kaydırınca büyük başlık 250 ms'de kısa bara iner.
- 5.1: içerik 250 ms'de 8 pt yukarı kayarak belirir; `success` haptiği bir kez; dönen sayaç yok.

**Erişilebilirlik (5.1):** tek cümle okunur.

#### C27 · StatBox → `SmapStatBox`
**Kit 1.16 / Tur 4 G3, Tur 10 · Örnek 6.1, 10.4; 5.1 puan kutuları**

**Ölçüler:**
- Zemin #FFFFFF / #121D31, radius 16, dolgu 16, dikey aralık 2.
- Değer 24/32 · 700 · −0,4 (metric-md).
- Etiket 13/20 · 600 #556173 / #A9B5C6.
- Delta satırı 13/20 · 600 #36537C / #9BB3D3; ArrowUp ya da ArrowDown 14 (çizgi 24), arası 4: "+3,25 son denemede".
- Izgara 2 sütun, arası 8.

**Kurallar:**
- Delta yalnız aynı süzgeçteki son iki denemeden hesaplanır; iki deneme yoksa satır çizilmez.
- İşaret ve ok her zaman yazılır.
- Sıralamada düşen sayı iyidir; Tur 10'dan beri renk anlam taşımaz, yön oktan okunur.
- Verisi olmayan kutu çizilmez.

**ÇELİŞKİ:** 6.1, 6.4 ve 5.1 notları delta için "success" diyor; Tur 10 delta rolüne geçirdi. Uygulanacak değer delta.

#### C28 · AuthorRow → `SmapAuthorRow`
**Tur 5 · 7.4**

- Min yükseklik 72, dolgu 12/16, aralık 12.
- Fotoğraf 48 pt daire. Fotoğraf yoksa baş harf: Edebiyat tonları #F6E7EC / #8A2F4E, 15 · 700.
- Ad 16 · 600; dönem 13 #556173; ok.
- Uzun sheet açar: eserler tür başlığıyla gruplu (13 · 700), metin 16/26, "Öğrendim".

#### C29 · ProgramRow → `SmapProgramRow`
**Tur 6 · 3.4. 11.13'te yok; Tur 6 geliştirici notlarında `ProgramRow`.**

- Dolgu 16, aralık 12, üstten hizalı.
- Karo 40, radius 12, zemin #E2EAF4 / #36537C, ikon 22. İkon adı belirtilmemiş.
- Ad 16/24 · 700 + "Bu hafta" Tag (6 pt #E05500 nokta).
- Motto 15/24 #556173; tarih aralığı 13; ok (üst dolgu 8).

#### C30 · ProgramItemRow → `SmapProgramItemRow`
**Tur 6 · Eşleme 3.1–3.3, 3.6**

**Ölçüler:**
- Dolgu üst 10, sağ 12, alt 10, sol 16; min yükseklik 64; aralık 12.
- Saat 15/24 · 600 (body-strong), tabular, min genişlik 48.
- Glif karosu 36, radius 12, glif 19.
- Ders 13/20 #556173; konu 16/24 · 600; ok 20 #556173.
- Ayraç 1 #E8ECF1 / #26354D.

**Düzenleme modu (3.6):**
- Saat altı çizili metin düğmesine dönüşür (çizgi aralığı 4); TimeWheel sheet'ini açar. Ad "Saat 10:00, değiştir".
- Sağda çıkar düğmesi: 48 dokunma alanı + 32 pt daire #E8ECF1 + X 16. Ad "Fiilde Çatı, programdan çıkar".
- Altta tam genişlik ikincil "Konu Ekle" (Plus 20) ve tehlikeli metin düğmeleri: "Günü Sıfırla", "Programı İptal Et". Panoda ikonlar Reset / Trash diye geçiyor; Phosphor'da "Reset" adında ikon yok, karşılığı belirtilmemiş.

**Hareket:**
- Çıkarma: satır 250 ms exit ile kayar; toast "Konu çıkarıldı." + Geri Al.
- Sıfırlama: satırlar 150 ms aralıkla söner; `selectionClick` (silme kutlanmaz).

**Erişilebilirlik:** "10:00, Türkçe, Fiilde Çatı".

#### C31 · StudentRow → `SmapStudentRow`
**Tur 9 · 10.2**

- Dolgu 12/16, aralık 12. Min yükseklik: koç CSS'inde 64, metinde 72; ÇELİŞKİ.
- Avatar 40; ad 16 · 600; meta 13 "12. Sınıf · Eşit Ağırlık · 10 deneme".
- Sağda yalnız verisi olan bilgi: "67,5" 17/24 · 700 + "son net" 13.
- Ok. Arama eşleşmesi işaretli.
- Sıralama alfabetik (Türkçe karşılaştırma).

#### C32 · StudentTile → `SmapStudentTile`
**Tur 9 G3 · 10.1**

- Genişlik 108, dolgu 14, radius 16, zemin #FFFFFF; dikey, sola hizalı, aralık 8.
- Avatar 48; ad 15/20 · 600, iki satıra kadar; varsa "Son deneme 5 Eki." 13 #556173.
- Şerit aralığı 8, yan dolgu 16.

#### C33 · AttentionRow → `SmapAttentionRow`
**Tur 9 G4 · 10.1**

**Ölçüler:**
- Satır üstten hizalı, min yükseklik 64, dolgu 12/16.
- Avatar 40 + kural rozeti: 22 pt daire #FCF1D9 / #8A5A00, ikon Clock ya da TrendDown 14 (çizgi 24), 2 pt #FFFFFF halka; avatarın sağ altında, ofset −4/−4.
- Ad 16 · 600.
- Kural cümlesi 15/24, 2 altta ("45 gündür deneme okutmadı").
- Kanıt satırı 13 #556173 ("Son deneme 17 Haz. 2026 · TYT", "68 → 66,75 · 17 Haz. ve 4 Ağu.").
- Ok.

**Boş bölüm:** kart dolgusu 16; "Şu an dikkat gerektiren öğrenci yok." 15 · 600 + açıklama 13.

**Kurallar:** yalnız iki kural var: 14 gün ve üzeri deneme yok; aynı türde son iki denemede net düşüşü.

**Erişilebilirlik:** tek cümle okunur.

#### C34 · MeetingRow → `SmapMeetingRow`
**Kit 1.16 / Tur 9 G5 · 10.1, 10.5**

Satır: dolgu 12/16, aralık 12, min yükseklik 64.

**dateBlock varyantı (10.1):**
- Blok 44 genişlik, ortalı: gün 24/32 · 700 (metric-md), ay 13/20 · 600 #556173 ("Eki.").
- Avatar 36; ad 16 · 600; meta 13 "Pazartesi 16:00 · Öğrenci"; ok.

**list varyantı (10.5):**
- Avatar 40; ad; meta "12 Ekim 2026 Pazartesi · 16:00" (yıllı).
- Tag "Öğrenci" ya da "Veli"; ok.

**Erişilebilirlik:** "Alparslan Kuloğlu, 12 Ekim 2026 Pazartesi, 16:00, öğrenci görüşmesi".

#### C35 · CodeCard → `SmapCodeCard`
**Tur 9 G6 · 10.1, 10.3; 9.1 koç Hesap varyantı**

**Ölçüler:**
- Kart dolgusu 16, zemin #FFFFFF, radius 16 + içe kenar 1 #DCE2E9.
- Etiket "Koçluk kodun" 13/20 · 600 #556173.
- Kod 24/32 · 700, harf aralığı 1, 2 altta. ÇELİŞKİ: Tur 9 notu 24 · 800 diyor.
- Açıklama 13 #556173, 4 altta.
- Eylem satırı 12 altta, arası 8: iki ikincil düğme, flex 1, **yükseklik 44**; Copy 20 ve ShareNetwork 20.

**Davranış:** Kopyala → toast "Kod kopyalandı." (4 sn). Paylaş → sistem paylaşımı.

#### C36 · CoachCard → `SmapCoachCard`
**Tur 8 · 9.5**

- Kap radius 16, dolgu 16.
- Avatar 64, aralık 14; ad 17/24 · 700; "Koçun" 13.
- Ayraç (margin 16/0/12).
- "Sıradaki görüşme" 13 #556173; değer 16/24 · 600, 2 altta. Görüşme yoksa çizilmez.
- Altında NoticeBox (info) ve tehlikeli metin düğmesi "Bağlantıyı Kaldır" → tehlikeli ConfirmSheet.

#### C37 · ProfileSummary → `SmapProfileSummary`
**Tur 8 G2 · 9.1**

- Kök bandın içinde; bandın alt dolgusu 20.
- Tam genişlik tek dokunma alanı, dolgu üst 4 / yan 16 / alt 0, aralık 14.
- Avatar 56; ad 17/24 · 700 #FFFFFF.
- İki alt satır 13/20 #C5D4E8: "12. Sınıf · Eşit Ağırlık", "Koçun: Mehmet Özkan".
- Ok 20 #C5D4E8.
- Erişilebilirlik: "Profil: Alparslan Kuloğlu, 12. Sınıf, Eşit Ağırlık, koçun Mehmet Özkan".
- Koç varyantında sınıf ve alan yok.

#### C38 · RoleOption → `SmapRoleOption`
**Tur 7 G3 · 2.1, 2.2**

- Tam genişlik, dolgu 16, radius 16, zemin #FFFFFF; içe kenar 1 #DCE2E9. Seçili: içe kenar 2 #0F294A.
- Aralık 16. Avatar 56.
- Başlık 17/24 · 700 · −0,1; açıklama 15/24 #556173, 2 altta.
- Radyo 24; seçili 7 pt halka (§5).
- Seçenekler arası 12. Radyo grubu "Rol".

#### C39 · InfoBox / ErrorBox / WarningBox → `SmapNoticeBox(tone)`
**Tur 7 G5, Tur 8 · 2.2, 2.3, 2.5–2.6, 9.5, 9.6**

**Ölçüler:** yatay, aralık 10, üstten hizalı; dolgu 12/14; radius 12; metin 15/22 #1B2232; ikon 20 (üst dolgu 1).

**Tonlar:**

| Ton | Zemin | İkon |
|---|---|---|
| info | #E2EAF4 | Info, #36537C |
| error | #FCEAEA | 2.3 metni "Warning ikonu" diyor; #C42D35 |
| warning | #FCF1D9 | #8A5A00 |

**İsteğe bağlı satır içi metin düğmesi:** "Ayarları Aç"; margin üst 2, alt −10, sol −12.

**Erişilebilirlik:** error ve warning `role=alert`.

**Koyu:** panoda çizilmemiş. Token karşılıkları: info #9BB3D3 / #1A2B45, error #FF8F8F / #3B1D22, warning #F2C46D / #33270F; metin #EDF1F6.

### C · Veri bileşenleri (D/Y/B ailesi ve ilerleme)

#### C40 · D/Y/B çipi → `SmapDybGlyph`
**Kit 1.14 · Tur 1 adı: `DybChip`**

- Daire 16 (glif 10, çizgi 32) ya da 24 (glif 14, çizgi 28).
- Glifler: Doğru Check (✓), Yanlış X (✕), Boş Minus (–).
- Zemin: #0B6E3E / #D8333A / #7E8A9B; koyu #52CC8E / #F07575 / #6E7C92.
- Glif rengi #FFFFFF; koyu #0A1424.
- Tur 10'dan beri glif her yerde var (1.13'teki "glifsiz kalabilir" istisnası kalktı).

#### C41 · DybLarge / DybSmall → `SmapDybCounter(size: large|small, labels: letter|word)`
**Kit 1.14 · Örnek 5.1, 5.3, 3.1 · Tur 1 adı: `DybCounter`**

**large:**
- 3 sütun ızgara, arası 12.
- Her sütunda: çip 24 + etiket 15/24 · 600 #556173 (arası 8); altında değer 24/32 · 700 · −0,4 #1B2232, 4 altta.

**small:**
- Satır içi, öğeler arası 14 (sarınca dikey 4).
- Çip 16 + değer 15/20 · 700 + harf ("D", "Y", "B") ya da kelime ("doğru", "yanlış", "boş") 13 · 500 #556173; arası 4.
- Kelimeli varyantta öğeler arası 4/10.

**Kurallar:**
- Sıra her zaman Doğru, Yanlış, Boş.
- Boş sıfır da olsa görünür.
- Sayılar metin renginde; renk çipte.

**Kullanım:**
- Harfli: akordeon başlığı, deneme satırı.
- Kelimeli: yer olan konu satırı, Anasayfa son deneme.

**Erişilebilirlik:** tek grup, tek cümle: "86 doğru, 74 yanlış, 0 boş" (`excludeSemantics`).

**Koyu:** etiket #A9B5C6, değer #EDF1F6.

#### C42 · StackedBar → `SmapDybStackedBar` (+ `SmapTestBarRow`)
**Kit 1.14 · Örnek 5.3**

**Çubuk:**
- Yükseklik 12, radius full, içerik kırpılır.
- Parçalar arası 2 pt boşluk (renk görmeyen için sınır).
- Parça genişliği sayıyla orantılı (flex). Sıfır olan parça çizilmez, sayacı yine yazılır.

**Satır:**
- Dolgu 14–16 / 0. Ayraç 1 #E8ECF1.
- Üst satır, taban çizgisine hizalı, arası 16: test adı 16/24 · 600 + net 17/24 · 700 + "net" 13 · 500 #556173.
- Çubuk 10 altta.
- Sayaç satırı 8 altta: küçük harfli D/Y/B + sağda "40 soru" 13.

**Hareket:** ilk açılışta çubuklar 350 ms'de dolar; hareketi azaltta doğrudan son hâl.

**Erişilebilirlik:** `role=img`, "40 sorudan 23 doğru, 17 yanlış, 0 boş".

#### C43 · QuestionCell → `SmapQuestionCell(variant: result|formCheck)`
**Kit 1.14 / Tur 2 G2, Tur 3 G1 · Örnek 5.4, 5.7; 4.7**

**result varyantı:**
- Yükseklik 76, radius 8. Dolgu kitte 6/8, 5.4'te 6.
- Sol üst: numara 13/20 · 600 #556173.
- Sağ üst: durum çipi 16, köşeden 8/8.
- Orta: senin işaretin 20/24 · 700 #1B2232; boşsa "–" #556173.
- Alt: "Doğru A" 13/16 · 600 #0B6E3E. Yalnız yanlış ve boşta görünür; doğruda yükseklik korunur, metin gizli.
- Dar ızgarada (66) etiket "Doğru A"; iki nokta yalnız geniş ızgarada.

| Durum | Zemin |
|---|---|
| Doğru | #FFFFFF + içe kenar 1 #DCE2E9 |
| Yanlış | #FCEAEA |
| Boş | #E8ECF1 |
| Basılı (yanlış örneği) | #F6D7D7, 0,97 ölçek, 100 ms |
| Odak | §1.4 halkası |

- Koyu: doğru #121D31 + içe kenar #26354D; yanlış #3B1D22; boş #213049; doğru cevap metni #52CC8E; numara #A9B5C6.
- Izgara: 5 sütun, iç dolgu 0/8/8. Aralık notta 8, 5.4 markup'ında 6; ÇELİŞKİ.

**formCheck varyantı (4.7):**
- Notta 66 × 52; markup'ta yükseklik 52, radius 8, dolgu 4/8.
- Numara 13/16 · 600; işaret 20/24 · 700 ortada.
- Okundu: zemin #FFFFFF.
- "Boş okundu": zemin #FCF1D9 + 2 pt kesikli kenar #8A5A00 (dolgu 2/6); işaret "–" #556173.
- "Düzeltildi": zemin #E2EAF4 + içe kenar 2 #0F294A; işaret #0F294A; sağ üstte kalem ikonu 14 #0F294A.

**Erişilebilirlik:**
- "Soru 7, yanlış, işaretin C, doğru cevap A"
- "12. soru, boş okundu, düzeltmek için dokun"
- "12. soru, düzeltildi: C"

**Davranış:** result hücresi Soru Detay'ı (5.7) açar; formCheck hücresi düzeltme sheet'ini açar.

#### C44 · Ders / vurgu ilerlemesi → `SmapLinearProgress(style: subject|accent)`
**Kit 1.15 · Tur 1 adı: `SubjectProgress` / `SmapProgress`**

**subject:**
- Ray 8, #E8ECF1 / #213049, radius full; dolgu ders vurgusu.
- Etiket sayıyı söyler: "41 / 64 kart biliniyor" 13, 6 altta. Yüzde ayrıca yazılmaz.
- Toplam yoksa çizilmez.

**accent:**
- Dolgu #E05500 / #FF8533.
- Yükseklik: kitte "genel ilerleme" 4 pt; 4.5 gönderimde 8.
- Sayaç kitte 15/24 · 700 ("12/40").
- Değer gönderim yüzdesini anında izler (linear).

**Erişilebilirlik:** `progressbar` + "40 karttan 12'si".

#### C45 · SessionProgress → `SmapSessionProgress`
**Tur 5 G5 · 8.1, 8.2**

- Ray #E8ECF1, dolgu #E05500; koyu #213049 / #FF8533. Sağda "12/23".
- **ÇELİŞKİ:**
  - Yükseklik: Tur 5 G5 ve 1.15 "4 pt" diyor; 8.1 markup'ında 8 pt.
  - Sayaç: 1.15'te 15/24 · 700, 8.1'de 13/20 · 700.
- Başlık "Oturum", değer 12, üst sınır 23.

#### C46 · SuccessRing → `SmapSuccessRing`
**Kit 1.15 · 5.5, 5.10**

**Ölçüler:** 48 pt, çizgi 5, yarıçap 21.
- Ray #E8ECF1 / #213049; yay #264066 / #9BB3D3 (chart-line). Yuvarlak uç, tepeden başlar (−90°).
- Orta metin "%42" 13 · 700 #1B2232 / #EDF1F6.

**Durumlar:**
- %100: tam halka.
- %0: yalnız ray + "%0".
- Soru yok: halka çizilmez; 48 kutuda "Soru yok" 13/16 · 600 #556173.

**Kural:** tek renk, eşik renkleri yok. Yüzde en yakın tam sayıya yuvarlanır (5/12 → %42).

**Erişilebilirlik:** "Yüzde 42".

#### C47 · Spinner → `SmapSpinner`
**Kit 1.15 / 4.5, 9.4 · Tur 1 adı: `SmapSpinner`**

**Geometri:** 24 birimlik çerçevede r 9,5, çizgi 3; ray + 90° yay, yuvarlak uç.

**Boylar:** 24 (satır içi), 48 (tam ekran, 9.4), 20 (düğme içi, çizgi 2,5).

**Renk:**
- Kit: ray #E8ECF1, yay #264066.
- 4.5 / 9.4: ray #DCE2E9, yay #0F294A. ÇELİŞKİ.
- Lacivertte: ray beyaz %24, yay #FFFFFF.

**Hareket:** dönüş 1200 ms döngü, linear. Hareketi azaltta sabit yay + metin.

**Kural:** yalnız süresi bilinmeyen adımda ve her zaman ne beklendiğini söyleyen metinle kullanılır. Ekran yüklemesinde gösterge değil iskelet kullanılır.

#### C48 · NetChart → `SmapNetChart` (fl_chart `LineChart`)
**Kit 1.4 / Tur 4 G1 · Örnek 6.1, 10.4**

**Kart:**
- Dolgu 16.
- Başlık "Net gelişimi" 17 · 700 + sağda "Son 6 deneme" 13 · 600 #556173.
- Grafik 338 × 214 (370 genişlikte kartta).
- Alt yazı 13 #556173: "net · TYT 0–120 · son nokta vurgulu".

**Eksenler:**
- Y sabit: TYT 0–120 (çizgiler 0/30/60/90/120); AYT 0–160 (adımları belirtilmemiş).
- Y etiketleri 13 #556173, sağa hizalı.
- X etiketleri kısa ay noktalı ("22 Nis."), 13, ortalı.

**Çizim:**
- Izgara: yatay 1 pt #DCE2E9.
- Çizgi #264066, 2,5 pt, düz parçalar (eğri yok).
- Alan #264066 %10.
- Noktalar r 4,5, dolgu #FFFFFF, kenar 2 #264066.
- Son nokta r 7, #E05500, kenar 2,5 #FFFFFF.

**Balon:**
- Radius 8, zemin #0F294A; örnekte 196 × 48.
- 1. satır 13 #C5D4E8 ("TYT Genel Deneme 9 · 28 Eyl.").
- 2. satır 15 · 700 #FFFFFF ("74,75 net").
- Token'a göre shadow-overlay; markup'ta gölge çizilmemiş.

**Koyu:** çizgi #9BB3D3, alan %14, son nokta #FF8533, ızgara #26354D, eksen metni #A9B5C6. Balon açık yüzey #EDF1F6 üstünde koyu metin.

**Etkileşim:**
- Noktaya dokununca balon; dışına dokununca son noktaya döner.
- Hedef çizgisi yok.
- Süzgeç değişince grafik 350 ms'de yeniden çizilir; `selectionClick`.

**Erişilebilirlik:**
- Özet cümle: "TYT net grafiği, 22 Nisan 61,5 netten 28 Eylül 74,75 nete, 6 deneme".
- Her nokta odaklanabilir: "TYT Genel Deneme 9, 28 Eylül, 74,75 net".

#### C49 · Metrik ve delta metni → `SmapMetricText`, `SmapDeltaText`
**Eşleme 5.1–5.2: metric-xl, delta**

- Metrik: metric-xl / lg / md / sm stilleri, tabular.
- Delta: renk #36537C / #9BB3D3; ArrowUp / ArrowDown. İşaret her zaman yazılır ("+8,25"); açıklama #556173.
- Boylar:
  - 13/20 · 700, ok 14 (Anasayfa)
  - 13/20 · 600, ok 14 (StatBox)
  - 15/24 · 700, ok 18 (sonuç anı)

### D · İçerik

#### C50 · Accordion → `SmapAccordion` (+ `SmapAccordionHeader`)
**Kit 1.13 / Tur 3, Tur 5 G4 · Örnek 7.3; 5.4**

**Kit başlığı:**
- Dolgu 14/16, aralık 12, üstten hizalı.
- Başlık 16/24 · 600, sarılır.
- Altında 6 boşlukla küçük D/Y/B, öğeler arası 12.
- Sağda 32 pt daire: açıkken zemin #E8ECF1, renk #1B2232, CaretUp 18 (çizgi 20); kapalıyken zeminsiz, #556173, CaretDown 18.

**5.4 test başlığı:**
- Dolgu 12/12/12/16, aralık 8.
- Küçük D/Y/B + "40 soru" 13, öğeler arası 4/12.
- Ok 24 #556173, dairesiz.
- Gövdede soru ızgarası.

**7.3, 1. düzey (alt başlık kartı):**
- Kart radius 16; kartlar arası 8.
- Başlık dolgusu 14/12/14/16, aralık 8.
- Başlık 17/24 · 700.
- Meta: "4 madde" 13 + EksikTag, öğeler arası 4/8, 4 altta.
- Ok 22 #556173, margin-top 2.

**7.3, 2. düzey (madde):**
- Üst ayraç 1 #E8ECF1.
- Dolgu 12/8/12/16, min yükseklik 56, aralık 12.
- Numara rozeti 28; ad 16 · 600; EksikTag "Eksik"; ok 20.
- Açık gövde: dolgu 0/16/16/56.
  - Tanım 16/26.
  - ExampleBox, 12 altta.
  - "Kartı Aç" metin düğmesi (Cards 20).

**Hareket:**
- Yükseklik 250 ms standard ile açılır; ok 180° döner. Hareketi azaltta anında.
- Açılan bölüm görünür alana getirilir.
- 7.3 açılışında ilk eksik maddeye 350 ms kaydırılır (`Scrollable.ensureVisible`).

**Erişilebilirlik:** `expanded` semantiği. Dokunma alanı bütün başlık. Uzun ad sarılır, kesilmez.

#### C51 · ExampleBox → `SmapExampleBox`
**Tur 5 G4 · 7.3**

- Zemin #F2F4F7 / #18263D, radius 12, dolgu 12/16.
- "Örnek" 13/20 · 700 #556173.
- Örnek metni 16/26, 2 altta.
- Açıklama 13/20 #556173, 4 altta.

#### C52 · CardDeck → `SmapCardDeck` + `SmapStudyCard`
**Tur 5 G5 · Örnek 8.1; 7.3**

**Kart:**
- Zemin #FFFFFF / #121D31, radius 24, dolgu 24; örnekte min yükseklik 392.
- Üstteki kartın gölgesi yalnız sürüklenirken: shadow-overlay 0 8 24 #0F294A %16 (koyu #000 %40).
- Arkada iki kart kenarı: 12 ve 24 pt aşağıda, her yandan 12 / 24 içeride; opaklık 0,75 (shadow-raised) ve 0,5.

**Kart içeriği:**
- Üstte glif karosu 28 (glif 15) + ders adı 13 · 700, arası 8. Sağ üstte favori (Star 22 #697586).
- Başlık 20/28 · 700, 20 altta.
- Gövde 16/26, 12 altta.
- Sol altta EksikTag (kenarlardan 24 / 20).

**Eylemler (kartın altında, arası 12):**
- İkincil "Detay" (120 genişlik) + birincil "Öğrendim" (flex).
- Bildiklerim sekmesinde yalnız "Detay".

**Üst kısım:** sayaçlı segment (Eksiklerim / Bildiklerim / Favorilerim; "23 kart", boşsa "kart yok") + SessionProgress.

**Hareket:**
- Kart parmağı izler. Eşik genişliğin %30'u ya da 800 px/sn; geçince 250 ms'de çıkar, sıradaki ölçekle öne gelir.
- Kaydırma yalnız sonraki karta geçer; kart ancak "Öğrendim" ile taşınır.
- "Öğrendim": kart 250 ms exit ile sağa çıkar + `success` haptiği + 6 sn "Geri Al" toast'ı.
- İlk "Öğrendim"de ConfirmSheet ve "Bir daha sorma" (cihazda saklanır).
- Hareketi azaltta çapraz geçiş.
- İyimser güncelleme; hata olursa geri alınır + toast.

**Erişilebilirlik:** `customActions` ile "Sonraki kart" ve "Önceki kart".

**Boş metinler:**
- Eksiklerim: "Bu derste eksik kartın kalmadı."
- Bildiklerim: "Henüz öğrendiğin kart yok."
- Favorilerim: "Favoriye eklediğin kart yok."

**Paket:** `flutter_card_swiper` / `appinio_swiper` pubspec'te mevcut. Hangisinin kullanılacağı öneri; panoda belirtilmemiş.

#### C53 · CardSheet → `SmapCardSheet`
**Tur 5 G6 · 7.3**

- Uzun SmapBottomSheet.
- Başlık bölgesi: bağlam 13 · 600 #556173 ("Türkçe · Sözcükte Anlam") + başlık 20/28. Sağda favori ikon düğmesi (Star 22 #697586; Star / Star Fill) + Kapat.
- İçerik dolgusu 12/24/0: EksikTag, gövde 16/26 (12 altta), ExampleBox (12 altta).
- Alt bant: birincil "Öğrendim"; yalnız eksik kartta görünür. `success` haptiği.

#### C54 · CardPreview → `SmapCardPreview`
**Tur 3 · 5.6**

- Kart (düğme), dolgu 16.
- Başlık 16/24 · 600; açıklama 15/24 #556173, 4 altta; Tag "Eksiklerimde", 12 altta.
- Kartlar arası 8.
- Grup başlığı: glif karosu 32, **radius 10** (ölçek dışı), glif 20 + ders adı 17 · 700, arası 10.
- Bölüm başında bilgi kartı: 40 pt daire #E2EAF4 / #36537C + Cards 22 + "23 bilgi kartı eklendi" 17 · 700 + alt satır 13. Ardından birincil "Kartları Çalış".

### E · Kimlik, avatar, marka

#### C55 · Avatar → `SmapAvatar`
**Kit 1.17 · Tur 1 adı: `SmapAvatar`**

**Boylar ve kullanım yeri:**

| Boy | Nerede |
|---|---|
| 24 | bağlam şeridi |
| 32 | liste, küçülmüş HomeBand |
| 36 | görüşme satırı |
| 40 | kart ve satır, HomeBand |
| 48 | StudentTile |
| 56 | Hesap özeti, RoleOption |
| 64 | CoachCard |
| 72 | avatar sheet'i, boş durum |
| 96 | kitte "avatar seçimi" |

**Görünüm:** daire, görsel kaplar; yedek zemin #DCE2E9.

**Görsel yüklenemezse:** baş harfler; zemin #E2EAF4, renk #1A3357, 13 · 700 (32 pt örnekte "AK").

**Koç rozeti:**
- Hap, yükseklik 20, yan dolgu 6, zemin #0F294A, metin #FFFFFF 13/20 · 700, 2 pt #FFFFFF halka.
- 40 pt avatarın sağ altında, ofset −14 / −6.
- Bir kelime: "Koç". Öğrenci avatarı rozet taşımaz.
- Okunuş: "Mehmet Özkan, koç".

**Kural:** kullanıcı adı ve avatar yalnız Anasayfa'da ve Hesap'ta görünür; üst barda yok.

#### C56 · AvatarStack → `SmapAvatarStack`
**Kit 1.17**

- En çok 3 avatar + "+N" (32 pt daire #E8ECF1, 13 · 700).
- 2 pt #FFFFFF halka, 8 pt bindirme.
- Tek okunuş: "Elif Şahin, Kerem Aydın, Zeynep Kaya ve 2 öğrenci daha".
- Boş durum varyantı (10.1–10.2): 72 pt, bindirme 16, 4 pt #F2F4F7 halka.

#### C57 · AvatarPicker → `SmapAvatarPicker`
**Kit 1.17 / Tur 7–8 · Örnek 2.5, 9.1, 9.2**

**Ortak kurallar:** 7 avatar birden görünür ve sayısı yazılır ("7 avatar", 13 #556173). Seçili avatarda boşluk + 2 pt #0F294A halka.

**Üç yerde üç boy:**
- **Satır içi, kayıt (2.5):** 46 pt, iki yana yaslı; seçili: 2 pt boşluk (kanvas #F2F4F7) + 2 pt lacivert.
- **Kit:** 48 pt, arası 10, 2 pt boşluk #FFFFFF + 2 pt lacivert.
- **Sheet (9.2):**
  - 4 sütun × 72, satırlar arası 20, seçili: 3 pt #FFFFFF boşluk + 2 pt #0F294A.
  - Başlık "Avatarını seç" + "7 avatar".
  - Birincil "Bu Avatarı Kullan"; seçim Kaydet ile kalıcı olur.

**Erişilebilirlik:** "Avatar 3, seçili" (`aria-pressed`).

**ÇELİŞKİ:** kit boy listesinde "96 · avatar seçimi" yazıyor; ekranlarda 46 ve 72 kullanılmış.

#### C58 · Ders glif karosu → `SmapSubjectGlyph`
**Kit 1.5, 1.16**

- Kare, radius 12 (5.6'da 32 boyda radius 10). Ders zemini + ders vurgusu renginde Phosphor glifi.

| Karo | Glif | Nerede |
|---|---|---|
| 48 | 24 | kit |
| 40 | 22 | ders satırı ve karosu |
| 36 | 19 | program satırı |
| 32 | 20 | CardPreview |
| 28 | 15 | çalışma kartı |

- Glif boyu verilmeyen hâllerde 14 ve 20 pt glif (hafta ızgarası, saat slotu) karosuz kullanılıyor.
- Kural: ders satırında kil görsel değil glif kullanılır.

#### C59 · Lockup / logo → `SmapLogoMark`, `SmapLockup`
**Kit 1.26 / Tur 7 G1 · Örnek 2.1, 2.2**

**İşaret:** S-rota. Geometri ve renk varyantları §4.1'de.

**Yatay lockup (giriş, 2.3):** işaret yüksekliği 36 (27,2 genişlik), arası 12, "SMAP" 24 · 800, harf aralığı −0,02 em, #0F294A.

**Dikey lockup (açılış, 2.1):** işaret yüksekliği 104 (78,6 genişlik), arası 20, "SMAP" 40 · 800, −0,02 em, #FFFFFF; zemin #0F294A.

**Kit 1.26 örnekleri:**
- Yatay: işaret 64 + "SMAP" 44 (harf aralığı −1), arası 16.
- Dikey: işaret 88 + "SMAP" 32, arası 12.
- Kural: işaret yüksekliği büyük harf yüksekliğinin iki katı; üretimde yazı çizgiye dönüştürülür.

**Kurallar:**
- Boşluk alanı her yönde bir çizgi kalınlığı.
- Uygulama içinde en küçük boy 20 pt; 16 px'te tek renk siluet.
- Lacivert zeminde üst kanca beyaz.
- Logo uygulama içinde yalnız açılışta ve girişte; kök bantlarda yok.

**Erişilebilirlik:** "SMAP".

#### C60 · OnboardingPage → `SmapOnboardingPage`, `SmapPageDots`
**Tur 7 G2 · 2.1**

**Sayfa:**
- Sağ üstte "Geç" metin düğmesi.
- Görsel alanı 380 pt yükseklik, ortalı. Örnek kart 250 × 330, radius 28, gölge 0 12 32 #0F294A %16.
- Başlık display 32/40 · 800 · −0,5, en çok 2 satır.
- Gövde 16/26 #556173, 12 altta.
- Alt blok: kenarlardan 24, alttan 42. SmapPageDots + birincil "Devam Et" (12 altta).

**SmapPageDots:**
- Noktalar arası 6.
- Geçerli sayfa 24 × 8, radius full, #E05500. Diğerleri 8 × 8, #C3CBD6.
- Okunuş: "3 ekrandan 1.".

**Hareket:** sayfa geçişi 350 ms standard; görsel parçaları 250 ms gecikmeli belirir; hareketi azaltta animasyon yok.

**İçerik:** 3 sayfa: okut → analiz → eksikleri kapat.

#### C61 · İllüstrasyon → `SmapIllustration`
**Kit 1.25**

- Kil seti, iki boy: L 160 (onboarding, Hoş geldin), M 128 (ekran düzeyi boş durum).
- Ekranda en fazla bir tane.
- Süstür: `ExcludeSemantics`.
- Karonun kendi köşesi var (28/140); üstüne kenar, gölge ya da kap konmaz. Koyu temada değişmez.
- Ders satırında, çipte, sekmede, düğmede ve grafiğin yanında kullanılmaz.

### F · Program

#### C62 · DayChip → `SmapDayChip`
**Tur 6 G4 · Örnek 3.4, 3.5, 10.4**

**Ölçüler:**
- 48 × 64, radius 12, zemin #FFFFFF / #121D31.
- Gün kısaltması 13/20 · 600 #556173 ("Pzt"); tarih 17/24 · 700.

**Durumlar:**
- Seçili: zemin #0F294A, metin #FFFFFF, kısaltma #C5D4E8.
- Bugün: altta 6 pt nokta, alttan 5, #E05500. Seçiliyken #FF6600.

**Büyük varyant (3.5):** 56 × 76 + "2 konu" 13/16 · 600.

**Koyu:** zemin #121D31, kısaltma #A9B5C6; seçili #C5D4E8 / #091A31, kısaltma #1A3357; nokta #FF8533 (seçiliyken #E05500).

**Diğer:** 7 gün iki yana yaslı. `selectionClick`. Okunuş: "Cumartesi 10 Ekim, bugün, seçili" (`aria-pressed`).

#### C63 · WeekGrid → `SmapWeekGrid` (Stack + CustomPaint; fl_chart değil)
**Tur 6 G5 · 3.4, 3.7–3.8**

**Ölçüler:**
- Saat sütunu 44, gün sütunu 84, saat satırı 40, başlık satırı 44.
- Başlık: gün kısaltması 13/20 · 600 #556173 + tarih 15/20 · 700. Bugünün altında 32 × 3 #E05500 çizgi.
- Izgara çizgileri 1 pt #E8ECF1 / #26354D; saat etiketi 13/20 · 600 #556173 / #A9B5C6.
- Blok: radius 8, dolgu 4/6, aralık 2; örnekte 78 × 36. Ders zemini / vurgusu; glif 14 + ders adı 13/16 · 700. Konu adı yok; konu Gün görünümünde ve dokununca görünür.
- Aralık 06:00–23:00.

**Davranış:**
- Yatayda bugünün sütununa, dikeyde ilk çalışmaya konumlanır; hareketi azaltta animasyonsuz.
- Bloğa dokunmak konu detayını açar.

**Koyu (3.8):** "bugün çizgisi" #FF8533; açık tema karşılığı yalnız başlık göstergesi.

**Erişilebilirlik:** blok "Cumartesi 10:00, Türkçe, Fiilde Çatı".

#### C64 · HourSlot → `SmapHourSlot`
**Tur 6 · 3.5**

**Satır:** min yükseklik 52, dolgu 4/12/4/16, aralık 8; ayraç 1 #E8ECF1.

**Saat etiketi:** genişlik 44, 13/20 · 600 #556173, üst dolgu 12.

**Slot:** radius 12, dolgu 8/4/8/12, aralık 10.
- **Boş:** saydam düğme, min yükseklik 44; ad "09:00, boş, konu ekle".
- **"Konu Ekle":** zemin #E2EAF4, metin #0F294A, 15/24 · 600, Plus 20, arası 6; odak halkası.
- **Dolu:** ders zemini; glif 20; ders adı 13 · 700 vurgu renginde; konu 15/22 · 600.
- **Çıkar düğmesi:** 40 × 40, X 18 #556173. Not 48 diyor; §5.

**Hareket:** konu yerleşince blok 250 ms enter ile belirir; `selectionClick`.

**Konu sheet'i:** segment Çantam / Dersler, radyo satırları 56, grup başlığı 13 · 700.

#### C65 · Calendar → `SmapCalendar`
**Tur 6 G6 · 3.5**

**Kap:** kart, dolgu 8/8/12.

**Başlık:** önceki / sonraki ay ikon düğmeleri 48 (Caret 22) + ay adı 17/24 · 700.

**Izgara:** 7 × 46, aralık 4, ortalı, başlığın 4 altında.
- Gün adları satırı: yükseklik 24, 13/20 #556173.
- Gün hücresi: 46 × 46, radius 12, 16/24 · 600.

**Durumlar:**
- Geçmiş: #9AA5B4 · 500, devre dışı ama okunur.
- Seçili: #0F294A / #FFFFFF.
- Bugün: içe kenar 2 #E05500.
- Çoklu seçim.

**Lejant:** "Bugün" için 20 × 20, radius 6, içe kenar 2 #E05500 + 13 metin.

**Alt bant:**
- Zemin #FFFFFF, üst ayraç #DCE2E9, dolgu 12/24/42.
- "6 gün seçildi" 16 · 700 + aralık 13 + birincil düğme.

**Koyu:** belirtilmemiş.

#### C66 · TimeWheel → `SmapTimeWheel` (sheet içinde)
**Tur 8 G5 · 9.6; 3.6 saat seçici**

**Düzen:**
- Saat ve dakika sütunları, aralarında 48; ortada ":" 24 · 700.
- Görünür 5 öğe, satır yüksekliği 40, aralık 4.
- Seçili olmayan 20/40 · 500 #9AA5B4; seçili 24/40 · 700 #1B2232.
- Seçim bandı: yükseklik 44, radius 12, #E8ECF1, tam genişlik (margin 16/24).

**Sheet:** başlık ("Sessiz saat başlangıcı") + Kapat; birincil "Kaydet".

**Davranış:** dakika 5'er adım. Erişilebilirlikte ayarlanabilir öğe; yukarı / aşağı 5 dk.

**Koyu:** belirtilmemiş.

### G · Kamera (her temada koyu)

#### C67 · CameraOverlay → `SmapCameraOverlay`, `SmapCameraStatusPill`, `SmapShutterButton`
**Tur 2 G3 · 4.1–4.10**

**Üst bar:**
- Yükseklik 48, güvenli alanın altında.
- Kapat ve "?" düğmeleri: 48 dokunma alanı, 40 pt yarı saydam daire rgba(10,20,36,.64), beyaz ikon 20 / 22.
- Başlık "Optik Form" 15/24 · 600 #FFFFFF.

**Durum hapı:**
- Dolgu 8/16, radius 16, zemin rgba(10,20,36,.80).
- 15/24 · 600 #FFFFFF; ikon 20 (form bulununca #52CC8E).
- `role=status`; metin çapraz geçişle değişir.

**Kılavuz çerçeve:**
- 330 × 400 (oran 0,82). Dışı rgba(0,0,0,.48) ile karartılır.
- Köşe işaretleri 30 pt kollu, çizgi 5, beyaz, yuvarlak.
- Form bulununca köşe işaretleri beyaz %35'e iner.

**Bulunan kenar:**
- Dörtgen: çizgi 3 #FF6600, dolgu rgba(255,102,0,.10).
- Köşe noktaları r 7, #FF6600, kenar 3 #FFFFFF.
- Değişimler 150 ms.

**Deklanşör:**
- 76 pt daire: 4 pt beyaz halka + içte 60 pt #FF6600 disk.
- Basınca 0,92 ölçek, 100 ms, `mediumImpact`.
- Önizleme 100 ms donar; köşe ekranı 250 ms'de açılır.
- Ad "Fotoğraf çek".

**Diğer:** flaş ve galeri yok.

#### C68 · Handles → `SmapCornerHandles` + `SmapLoupe`
**Tur 2 · 4.4**

**Köşe noktası:**
- Görünür 18 (r 9), #FF6600, kenar 3 #FFFFFF. Sürüklerken 28 (r 14).
- Dokunma alanı 48.

**Büyüteç:** 116 pt daire, 3 pt beyaz halka (`RawMagnifier`). Açılış 100 ms ölçekle, kapanış 150 ms.

**Haptik:** nokta kenara oturunca `selectionClick`.

**Erişilebilirlik:** "Sol alt köşe" gibi adlar + dört yönlü ayar eylemi (`onIncrease` / `onDecrease`).

**Düğmeler:** "Tekrar Çek" ikincil, "Devam" birincil; koyu set.

#### C69 · ProgressSheet / adım listesi → `SmapStepList`, `SmapStepRow`
**Tur 2 G1 · 4.5–4.6**

**Satır:** not 56 pt diyor; markup dolgusu 16/0, aralık 12, üstten hizalı. Ayraç 1 #E8ECF1.

**Durum ikonu (24):**
- Bitti: #0F294A daire + onay; koyu #C5D4E8 + #091A31.
- Sürüyor: dönen gösterge (#DCE2E9 / #0F294A).
- Bekliyor: 2 pt #C3CBD6 halka.
- Hata: #C42D35 / #FF8F8F.

**Metin:** etiket 16/24 · 600 (bekleyen adım 400 #556173); sağda yüzde 16 · 700. Sürüyor satırında SmapLinearProgress 8 (#E05500).

**Fotoğraf kartı:** surface, dolgu 8, shadow-raised.

**Hareket:** adım değişimi 250 ms çapraz geçiş. Gösterge 1200 ms döngü.

**Erişilebilirlik:** `aria-live`.

#### C70 · FormCheck → `SmapFormCheckView`, `SmapAnswerFixSheet`
**Tur 2 · 4.7–4.8**

**Görüntü kartı:**
- surface, dolgu 12.
- Büyüt düğmesi: 48 dokunma alanı, 40 pt daire, shadow-raised.
- `InteractiveViewer` 1–5 kat; çift dokunuş 2,5 kat.

**Kolon seçimi:** sayaçlı segment ("1 boş" / "boş yok").

**Izgara:** formCheck soru hücreleri.

**Düzeltme sheet'i:** kare şık çipleri 48 ("Boş" 64). "Düzeltmeyi Ekle" ile satır listenin başına 250 ms'de kayarak girer.

**Haptik:** şık seçiminde `selectionClick`.

**Hata:** satır içi uyarı; error-bg, ikon 24, `role=alert`; 250 ms'de alttan açılır + `error` haptiği.

### H · Overlay

#### C71 · BottomSheet → `SmapBottomSheet`
**Kit 1.20 · "uzun boy her tur" · Tur 1 adı: `SmapSheet`**

**Anatomi:** tutamaç, başlık + alt başlık, Kapat, kaydırılan içerik, sabit eylem alanı.

**Ölçüler:**
- Üst köşeler 24.
- Tutamaç 36 × 4, radius full, #C3CBD6, üstten 8.
- Başlık bölgesi dolgusu üst 12, sağ 12, alt 0, sol 24; aralık 8.
- Başlık 20/28 · 700 · −0,2; alt başlık 15/24 #556173, 4 altta.
- Kapat: 48 dokunma alanı, 36 pt daire #E8ECF1, X 20 (çizgi 20); margin-top −8.
- İçerik dolgusu 16/24, öğeler arası 20.
- Eylem alanı dolgusu 16/24/50, düğmeler arası 12. Ekranlarda alt dolgu 42; ÇELİŞKİ.

**Boylar:**
- small: içeriğe göre.
- medium: ekranın yaklaşık üçte ikisi (874'te üst 300).
- full: üstte güvenli alan + 8 kalır (üst 70).

**Durumlar:**
- İçerik kaydırılınca eylem alanının üstünde `inset 0 1 0 #DCE2E9` ayracı belirir.
- Klavye açık: eylem alanı klavyenin hemen üstüne çıkar, alt dolgu 16'ya düşer; odaklanan alan görünür alana kaydırılır.
- **Meşgul:**
  - Kapat gizlenir; tutamaç #E8ECF1'e soluklaşır.
  - İçerik 0,6 opaklık, alanlar salt okunur.
  - Sürükleme ve perdeye dokunma kapatmaz; Android geri hareketi engellenir.
  - Birincil düğme yükleniyor; `aria-busy`.
  - Hata olursa sheet açık kalır, girilenler korunur.

**Perde:** scrim #091A31 %48 + 8 pt bulanıklık. Sheet'in gölgesi yok.

**Koyu:** zemin #18263D; tutamaç #34445F; Kapat zemini #213049, X #EDF1F6; perde #02060E %64.

**Hareket:**
- Açılış 350 ms enter; kapanış 250 ms exit; perde %0 → %48.
- Parmağı izler; %25'ten fazla iniş ya da hızlı fırlatma kapatır.
- Hareketi azaltta 150 ms opaklık.

**Erişilebilirlik:** `dialog`, `aria-modal`, başlıkla etiketli.

**Ekranlar:**
- 3.5 konu sheet'i, 4.1 izin, 5.1–5.2 bildirim izni, 6.1 süzgeç
- 7.1 Web'de, 7.4 yazar
- 9.2 avatar, 9.6 saat
- 10.3 Öğrenci Ekle (uzun), 10.5 yeni görüşme / not

#### C72 · ConfirmSheet → `SmapConfirmSheet(tone: normal|danger)`
**Kit 1.21 · Örnek 3.6, 9.1, 9.4, 9.5, 10.6**

**Gövde:** dolgu 20/24/0.
- Başlık 20/28 · 700, soru biçiminde, cümle düzeninde ("… kaldırılsın mı?").
- Gövde 15/24 #556173, 8 altta; ne olacağını söyler.
- İsteğe bağlı onay kutusu satırı "Bir daha sorma", 12 altta.

**Eylem alanı:** dolgu 24/24/50 (onay kutusu varsa üst 12), düğmeler arası 12.
- Birincil eylemin adı sorunun fiilidir ("Öğrendim", "Bağlantıyı Kaldır"); "Evet" yazılmaz.
- Altında quiet "Vazgeç".

**danger tonu:**
- Başlığın solunda 40 pt daire #FCEAEA / #C42D35, hata ikonu 22 (çizgi 18); başlık üst dolgu 6, arası 12.
- Gövde 12 altta.
- Düğme #C42D35 / #FFFFFF.
- Açılışta odak Vazgeç'te (halka görünür).
- Kelime yazdırma yok.
- Koyu: daire #3B1D22 / #FF8F8F; düğme #FF8F8F / #3B0A10; odak halkası 2 #18263D + 2 #9BB3D3.

**Kurallar:**
- Kırmızı yalnız tehlikeli onayda kullanılır. Çıkış onayı normal tondadır (lacivert).
- Perdeye dokunmak Vazgeç sayılır.

**Hareket:** 350 ms.

#### C73 · ComingSoonSheet → `SmapComingSoonSheet`
**Kit 1.21 · yalnız kitte, hiçbir ekranda kullanılmaz**

- Ortalı, üst dolgu 28.
- 64 pt daire #E2EAF4 / #36537C, Hourglass 32.
- Başlık "Yakında", 16 altta.
- Tek birincil "Tamam". "Haber ver" düğmesi yok.

#### C74 · Toast → `SmapToast` + `SmapToastController`
**Kit 1.22 · Örnek 3.6, 8.1, 9.3, 10.6 · Tur 1 adı: `SmapToast`**

**Konum:**
- Alt çubuğun 8 pt üstünde, yanlardan 16. Çubuğu örtmez.
- Çubuk gizliyse güvenli alan + 16.
- Aynı anda tek toast.

**Ölçüler:**
- Min yükseklik 48, dolgu 12/16, radius 12, aralık 12.
- Zemin #0F294A, metin 15/24 #FFFFFF (14,62:1).
- Gölge shadow-overlay 0 8 24 #0F294A %16.
- İkon 20 (çizgi 18): bilgi Info #C5D4E8, başarı CheckCircle #52CC8E, hata WarningCircle #FF8F8F.

**Geri Al eylemi:**
- Toast sağ dolgusu 4.
- Düğme yükseklik 48, dolgu 0/14, dikey margin −12; 15 · 700 #FFFFFF; sol ayraç `inset 1 0 0 beyaz %20`.

**Süre:** 4 sn; Geri Al varsa 6 sn.

**Hareket:** 16 pt yukarı kayarak 250 ms enter; kapanış exit. Yukarı kaydırınca kapanır. Hata türünde `error` haptiği.

**Erişilebilirlik:** bilgi ve başarı `role=status`; hata `role=alert`.

**Koyu (ters yüzey):**
- Zemin #E8ECF1, metin #1B2232 (13,39), gölge #000 %56.
- Eylem #1A3357 · 700, ayraç #C3CBD6.
- İkonlar açık temanın durum renkleri: başarı #0B6E3E. Bilgi ve hata ikonunun koyu rengi belirtilmemiş.

**Kurallar:**
- Hata toast'u yalnız geçici hatalar için; kalıcı hata ekranda durum olarak çizilir.
- Emoji, "Hata:" öneki ve iç kod yok.

### I · Durum kalıpları

#### C75 · OfflineStrip → `SmapOfflineStrip`
**Kit 1.22 · her tur**

- Barın hemen altında; içeriği iter, üstüne binmez. Bant köşeleri düzleşir.
- Min yükseklik 40, dolgu 8/16, aralık 10.
- Zemin #1B2232 (n-900), metin #FFFFFF 13/20 · 600 (15,89:1). WifiSlash 18.
- Metin: "Çevrimdışısın. Son kaydedilen veriler gösteriliyor."
- Koyu: ters yüzey, #E8ECF1 / #1B2232.

**Hareket:** 250 ms'de iner. Bağlantı gelince 2 sn mesaj gösterir, sonra kapanır.
- ÇELİŞKİ: mesaj 1.22'de "Bağlantı geri geldi", 11.15'te "Bağlandın".

**Davranış:** son veri gösterilir; gönderim gerektiren eylemler sırada bekler.

#### C76 · Skeleton → `SmapSkeleton`
**Kit 1.22**

- Bloklar #E8ECF1 (koyu #213049), radius 8; grafik bloğu 12. Gerçek düzenin şeklini taşır.
- Parıltı: 120 genişlikte beyaz %0 → %65 → %0 gradyan, soldan sağa, 1200 ms döngü, linear.
- Hareketi azaltta durağan gri.
- Bant ve sekmeler hemen gelir.
- 15 sn içinde veri gelmezse hata durumuna geçer; sonsuz iskelet yok.
- `aria-busy`, "Yükleniyor".
- Koyu parıltı rengi belirtilmemiş.

#### C77 · EmptyState → `SmapEmptyState(level: screen|section)`
**Kit 1.22 / 1.25**

**screen:**
- Dolgu üst 64 (1.22) / 88 (1.25), yan 32; ortalı.
- Görsel M 128.
- Başlık 20/28 · 700, görselin 24 altında.
- Tek cümle 15/24 #556173, 8 altta; 1.25'te max genişlik 310.
- Tek eylem, 24 altta; birincil, isteğe bağlı baş ikonla.
- Koç varyantı: görsel yerine üç avatar (72, bindirme 16, 4 pt #F2F4F7 halka).

**section:**
- Kart, dolgu 16, aralık 4.
- Tek cümle 15/24 #556173 + metin düğmesi 15/24 · 600 #1A3357 (yükseklik 48, dolgu 0, alt margin −12).

**Boş durum → görsel eşlemesi:**

| Boş durum | Görsel |
|---|---|
| Denemelerim | Harita |
| Programım | Ampul |
| Deste / ders, eksik kalmadı | dersin kil görseli |
| Öğrencilerim (koç) | üç avatar |
| Görüşmelerim (koç) | Hokka |

**Erişilebilirlik:** görsel atlanır; okuma başlıktan başlar.

#### C78 · ErrorState → `SmapErrorState(level: screen|section)`
**Kit 1.22**

**screen (sekme içinde):**
- Üst dolgu 120, ortalı.
- 64 pt daire #FCEAEA / #C42D35, ikon 32.
- Başlık 20/28 · 700, 20 altta; cümle 15/24 #556173, 8 altta.
- İkincil "Tekrar Dene" (ArrowClockwise 20; dolgu sol 16 / sağ 20), 24 altta.
- `role=alert`. Ham hata ya da iç kod yok.
- Tekrar Dene iskelete döner. Aynı hata tekrar gelirse metin değişmez.

**section:**
- Kart, dolgu 16, aralık 12.
- WarningCircle 24 (nokta #C42D35).
- Metin 15/24 · 600.
- Metin düğmesi "Tekrar Dene", ArrowClockwise 18, arası 6.
- Haptik yok.

#### C79 · Tam ekran durum → `SmapStatusView`
**2.7, 4.9–4.10, 9.4**

- İkon dairesi:
  - 96 (2.7, 9.4): başarı #E4F4EA / #0B6E3E, ikon 48. Zorunlu güncellemede uygulama ikonu 96, radius 21,5.
  - 80 rozet (4.9 / 4.10): başarı success-bg, ikon 40.
- Başlık: 2.7'de display 32/40 · 800; 9.4'te 24/32.
- Gövde 16/26 #556173.
- En çok iki düğme, alttan 42.
- Meşgul varyant (9.4): 48 pt spinner + "Hesabın siliniyor" 20/28 + "Uygulamayı kapatma."; geri kapalı.
- `error` haptiği yalnız kullanıcının yaptığı işlem başarısız olursa.

### J · Kabuk

#### C80 · RootBand → `SmapRootBand`
**Kit 1.18 · Örnek 3.1, 6.1, 7.1, 9.1, 10.x · Tur 1 adı: `RootBand`**

**Yapı:**
- Zemin #0F294A, iki temada da. Üst dolgu güvenli alan (62). Alt köşeler 24.
- Başlık satırı 56: dolgu 0/16; sağda eylem varsa 0/4/0/16.
- Başlık 24/32 · 700 · −0,3 #FFFFFF.
- Sağda en çok bir eylem: 48 pt ikon düğmesi, beyaz 24 ikon, erişilebilir adlı ("Yeni görüşme", "Öğrenci ekle").

**Bant altı:**
- Boşluk 16 → toplam 134.
- Bant içi segment (onNavy): dolgu 0/16/16 → 178.
- onNavy sekme: 48 + 8.

**Küçülme:**
- 56 pt kaydırmaya bağlı, linear.
- Bant 110'a (62 + 48) iner; başlık 24 → 17/24 · 700; alt köşeler düzleşir.
- Segment varsa bantta sabit kalır.
- Çevrimdışı şeridi çıkınca köşeler düzleşir.

**Durum çubuğu:** açık içerik.

**Kural:** bantta logo ve avatar yok; istisna HomeBand ve ProfileSummary.

**Koyu:** bant yine #0F294A (kanvasa 1,26:1, dekoratif).

#### C81 · HomeBand → `SmapHomeBand(role: student|coach)`
**Tur 6 G1 · 3.1–3.3, 10.1**

**student:**
- Dolgu 62/16/20, alt köşeler 24.
- Satır min yükseklik 56, aralık 12: avatar 40 + selam 20/28 · 700 · −0,2 #FFFFFF ("Merhaba, Alparslan").
- Sayaç satırı 8 altta, aralık 12, alta hizalı:
  - Sayı 40/48 · 800 · −1 #FFFFFF.
  - Yanında sütun (alt dolgu 4): "gün kaldı" 15/20 · 700 #FFFFFF + "YKS · 19 Haziran 2027 Cumartesi" 13/20 #C5D4E8.
- Tek okunuş: "YKS'ye 252 gün kaldı. Sınav 19 Haziran 2027 Cumartesi."
- Sayaç cihazda hesaplanır, gece yarısı yenilenir.

**Küçülmüş hâl (110):** satır 48, aralık 10; avatar 32; selam 17/24; sağda "YKS'ye 252 gün" 13/20 · 600 #C5D4E8.

**coach:** avatar 40 + selam + alt satır 13/20 #C5D4E8 ("5 öğrenci · önümüzdeki 7 günde 2 görüşme"); sayaç yok.

**%130 metin:** selam 26/34, sayaç 52/60.

**Diğer:** çekince yenilenir (`RefreshIndicator`). Eyebrow ve gri alt satır üçlüsü yok.

#### C82 · DetailBar → `SmapDetailBar`
**Kit 1.18 · Örnek 2.x–10.x · Tur 1 adı: `DetailBar`**

**Bar:**
- Zemin bg-canvas (#F2F4F7 / #0A1424). Üst dolgu 62.
- Satır 48: dolgu 0/4; BarAction varsa 0/12/0/4.
- Geri: CaretLeft 24 #1B2232 / #EDF1F6, 48 dokunma alanı. Geri her zaman CaretLeft; Android sistem geri hareketi de çalışır.
- Sağda en çok bir eylem: SmapIconButton 48 ya da SmapBarAction 40.

**Büyük başlık (içerikte):** 24/32 · 700 · −0,3; 3 satıra kadar sarılır; dolgu 8/16/0.

**Kaydırılmış hâl:**
- Barda `0 1 0 #DCE2E9` ayracı belirir.
- 1.18'e göre başlık 15/20 · 600, ortalı, en çok 2 satır, kesilmez.
- ÇELİŞKİ: 5.4 ve 3.4'te kısa barda başlık 17/24 · 700, sola hizalı.
- Deneme Detay'da altına yapışık TabBar girer.

**Durum çubuğu:** koyu içerik.

#### C83 · ContextStrip → `SmapContextStrip`
**Kit 1.18 / Tur 9 · 10.4**

- DetailBar'ın altında. Yükseklik 40; zemin #F1F5FA / #1A2B45.
- Üst ve alt `inset 1 #DCE2E9` (koyu karşılığı belirtilmemiş; border-subtle #26354D).
- Dolgu 0/16, aralık 8.
- Avatar 24; "Ad Soyad'ın verileri" 13/20 · 600; sağda "12. Sınıf · EA" 13 #556173.
- Kaydırınca barla birlikte sabit kalır; içerik 40 aşağı kayar.
- Ekran okuyucu önce bunu okur.

#### C84 · BottomBar → `SmapBottomBar(role: student|coach)` + `SmapCameraButton`
**Kit 1.19 · kök sekmeler · Tur 1 adı: `SmapBottomBar` / `CameraButton`**

**Çubuk:**
- Yükseklik 68 + 34 güvenli alan.
- Zemin bg-bar (#FFFFFF %92) + 20 bulanıklık. Üst köşeler 24. Üst ayraç `inset 0 1 0 #DCE2E9`; gölge yok.
- Yuvalar: 4 × 82,5 + kamera 72 (402 genişlikte; esnek).

**Sekme:**
- Üst dolgu 14, aralık 6. İkon 24; etiket 12/16 · 600 #556173 (Regular ikon).
- Seçili: Fill ikon #0F294A, etiket 700.
- Gösterge: 32 × 4, alt köşeler 4, #E05500, üst kenarda.
- Dokunma alanı yuvanın tam yüksekliği (≥ 48).

**Kamera düğmesi:**
- 56 × 56, radius 16, #FF6600; 16 pt yukarı taşar, yuvada ortalı.
- Camera ikonu 28 #0F294A (4,98:1). Gölge shadow-raised.
- Altında "Okut" 12/16 · 700 #1B2232, üst 44; `aria-hidden`.
- Düğmenin adı "Okut: deneme formunu kamerayla okut".
- Basınca 0,92 ölçek, 100 ms + `mediumImpact`.
- Sekme değildir; gösterge almaz, tam ekran akışı açar.

**Sekmeler:**
- Öğrenci: Anasayfa (House), Analizlerim (ChartLineUp), Okut, Derslerim (BookOpen), Hesap (UserCircle).
- Koç: Anasayfa, Öğrencilerim (Users), Okut, Görüşmelerim (Chats), Hesap.

**Etiket:** 12 pt, 13 pt kuralının tek istisnası. Büyük metinde `FittedBox(scaleDown)` ile küçülür, kesilmez. Uzun basışta büyük ikon ve adıyla balon açılır.

**Erişilebilirlik:** "Analizlerim, sekme, 5'te 2".

**Davranış:**
- Seçili sekmeye yeniden dokunmak köke döndürür ve başa kaydırır.
- Her sekmenin kendi gezinme yığını var.
- Yalnız tam ekran akışlarda gizlenir: kamera, sonuç anı, kart oturumu, onboarding, giriş.

**Hareket:** gösterge 250 ms standard ile kayar; ikon Regular → Fill 150 ms; `selectionClick`.

**Koyu:**
- Zemin rgba(18,29,49,.92), ayraç #26354D.
- Seçili olmayan #A9B5C6, seçili #EDF1F6. Gösterge #FF8533.
- Kamera gölgesi 0 2 8 #000 %40; "Okut" #EDF1F6.

**mihr_ui:** `FrostedContainer(blur: MihrBackdropBlurs.xl, overlayColor: bg-bar)`.

#### C85 · StudentScope → `SmapStudentScope` (InheritedWidget)
**Tur 9 geliştirici notu · 10.4**

- `coachView == true` ise ContextStrip eklenir.
- Düzenleme eylemleri ve öğrenciye özel öğeler gizlenir: favori, "Öğrendim", "Günü Sıfırla".
- Ekranlar aynen taşınır (6.1, 6.2, 3.4, 5.3).

#### C86 · Kabuk iskeleti → `SmapShell`
**Türetilmiş; 1.19 "Ne zaman görünür"**

- Sekme başına bir Navigator; BottomBar'ı gösterir ya da gizler.
- Toast ve OfflineStrip burada barındırılır.

---

## 3. İkon seti

**Kütüphane:** Phosphor. Normalde Regular, seçiliyken Fill. Paket `phosphor_flutter`. Panolardaki çizimler Phosphor'un elle çizilmiş yaklaşığı; uygulamada aynı adlı ikon kullanılır. Material ikonları ve PNG ikonlar kalkar.

**Boylar:**

| Boy | Nerede |
|---|---|
| 16 | çip |
| 20 | düğme içi, satır oku |
| 24 | varsayılan |
| 28 | kamera |

Ayrıca: D/Y/B glifi 10 ve 14, etiket ikonu 14.

**Çizgi:** 24 pt'de 1,5 pt (256 birimlik çerçevede 16).

**Renk:** birincil ikon text-primary, ikincil text-secondary (6,28:1), seçili lacivert Fill.

**Alt çubuk:** House, ChartLineUp, BookOpen, UserCircle, Users, Chats, Camera (28).

**Eylem ve durum ikonları (1.17):**
- Gezinme: CaretLeft (geri), X (kapat, yanlış), CaretRight (satıra git), CaretDown (kapalı, seçim), CaretUp (açık akordeon).
- Arama ve süzme: MagnifyingGlass, SlidersHorizontal (filtrele), Plus.
- D/Y/B ve durum: Check (doğru, seçili), Minus (boş), Info, CheckCircle (başarı), WarningCircle (hata), Warning (uyarı), WifiSlash, ArrowClockwise (tekrar dene).
- Hesap ve paylaşım: Eye, EyeSlash, Star (favori), Bell, Trash, SignOut, Copy, ArrowSquareOut (Web'de aç), ShareNetwork.
- İçerik: Cards (bilgi kartı), Question, Lock (salt okunur), Clock, CalendarBlank, PencilSimple, ArrowUp (artış).

**Turlarda eklenen ikonlar:**
- Kesin adıyla geçenler: Hourglass (Yakında), TrendDown (dikkat), ArrowDown (delta azalış).
- Çizimden çıkarılan: Flag (EksikTag; adı yazılmamış).
- "Reset" (Günü Sıfırla): Phosphor'da bu adla ikon yok; karşılığı belirtilmemiş.

**Ders glifleri:** TextAa, Feather, Bank, Globe, MathOperations, Angle, Atom, Flask, Dna.

---

## 4. Varlık envanteri

Önerilen yollar `assets/…` altında.

### 4.1 Logo · S-rota (1.26, Öneri A)

**Geometri:**
- 1080'lik ızgara. İşaret kırpımı `viewBox 240 143 600 794`.
- Çizgi 120; örgü boşluğu 30 (maske çizgisi 180). Köşe yarıçapları 40, 135, 225. Yuvarlak uç ve birleşim.
- İki kanca aynı biçim, merkez etrafında 180° döndürülmüş.
- Örgü: solda lacivert, sağda turuncu üstten geçer.
  - Turuncu yol, x < 540 yarısına kırpılmış lacivert yol maskesiyle (çizgi 180) kesilir.
  - Lacivert yol, x ≥ 540 yarısına kırpılmış turuncu yol maskesiyle kesilir.
- Panodan alınan yollar:
  - Üst kanca (navy / beyaz):
    `M 775 655 V 248 A 40 40 0 0 0 735 208 H 530 A 225 225 0 0 0 305 433 V 520 A 135 135 0 0 0 440 655 H 560`
  - Alt kanca (orange-500):
    `M 305 425 V 832 A 40 40 0 0 0 345 872 H 550 A 225 225 0 0 0 775 647 V 560 A 135 135 0 0 0 640 425 H 520`

**İkon kurgusu:** işaret 1024'lük karoda %70 (translate 134, scale 0,70).

**Pafta zemini:** üç dikey şerit, 342/1024 genişlikte, x = 0 / 341 / 682.
- Lacivert pafta: #0F294A / #163660 / #123056.
- Açık pafta: #FFFFFF / #F2F5F9 / #F7F9FC.
- Üç kat 40 pt altında kendiliğinden kaybolur, düz laciverte döner.

**Kurallar:**
- İkonda yazı yok.
- Gradyan, parlama, gölge, kontur, döndürme, eğme yok.
- Turuncu tek başına kullanılmaz.

**Üretilecek dosyalar:**

| Dosya | İçerik |
|---|---|
| `brand/smap_mark.svg` | üst #0F294A, alt #FF6600 (açık zemin) |
| `brand/smap_mark_on_navy.svg` | üst #FFFFFF, alt #FF6600 |
| `brand/smap_mark_mono_navy.svg`, `brand/smap_mark_mono_white.svg` | tek renk; örgü boşluğu kancaları ayırır |
| `brand/smap_lockup_horizontal.svg`, `brand/smap_lockup_horizontal_on_navy.svg` | işaret + "SMAP" Plus Jakarta Sans ExtraBold, −%2, çizgiye dönüştürülmüş |
| `brand/smap_lockup_vertical_on_navy.svg` | açılış |
| `app_icon/app_icon_1024.png` | varsayılan: lacivert pafta + beyaz üst kanca; iOS, saydamlıksız |
| `app_icon/app_icon_light_1024.png` | açık pafta, iOS alternatifi |
| `app_icon/app_icon_ios_dark_1024.png` | zemin #0A1424, üst kanca #6C8BB6 (navy-400) |
| `app_icon/app_icon_ios_tinted_1024.png` | gri tonlu kaynak; panoda zemin #111111 |
| `android/ic_launcher_foreground.png` (xxxhdpi 432 px) + `android/ic_launcher_background.png` | ön katman işaret, 66/108 güvenli alanda; arka katman pafta; daire maskede kesilmez |
| `android/ic_stat_smap.png` | bildirim; beyaz siluet, saydam zemin, 24 dp (mdpi 24 … xxxhdpi 96) |
| `splash/splash_mark.png` | `flutter_native_splash` için; zemin #0F294A, dikey lockup (işaret 104 + SMAP 40/800 beyaz) + Android 12 ikon katmanı |
| `store/play_icon_512.png`, `store/appstore_icon_1024.png` | mağaza ikonları |

**Aramada boy:** 64 px.

**Mevcut durum:** `pubspec`'teki `flutter_launcher_icons` bugün `assets/logotext.png` kullanıyor.

### 4.2 Kil illüstrasyon seti (1.25, 11 görsel)

**Teknik gereksinim:**
- Üretim için 3x (480 px) PNG ya da WebP gerekir. Panolardakiler 140 px'lik kırpım; asıl dosyalar kullanıcıdan istenmeli.
- Her görsel kendi pastel karosuyla gelir (köşe 28/140).
- Flutter'da çözünürlüğe duyarlı klasörler: `illustrations/clay_*.webp` (1x 160) + `2.0x/` (320) + `3.0x/` (480).

**Dosyalar:**

| Dosya | Görsel | Kullanım |
|---|---|---|
| `clay_book` | Kitap | Türkçe |
| `clay_inkwell` | Hokka | Edebiyat; koçta görüşme boş durumu |
| `clay_column` | Sütun | Tarih; mağaza |
| `clay_globe` | Küre | Coğrafya |
| `clay_operations` | İşlemler | Matematik; yalnız mağaza |
| `clay_pyramid` | Piramit | Geometri; yalnız mağaza |
| `clay_atom` | Atom | Fizik |
| `clay_flask` | Erlenmeyer | Kimya |
| `clay_leaf` | Yaprak | Biyoloji |
| `clay_bulb` | Ampul | Programım boş; mağaza |
| `clay_map` | Harita | Denemelerim boş, Hoş geldin (L 160), mağaza |

### 4.3 Avatarlar (1.17)

- Öğrenci ve koç aynı 7 avatarı kullanır.
- Kodda bugünkü liste (`lib/core/theme/app_colors.dart`, satır 29–35): `assets/avatars/1avatarN3.png`, `3avatarN3`, `4avatarN3`, `5avatarN3`, `6avatarN3`, `8avatarN3`, `9avatarN3`. Hepsi 256 px.
- Öneri: `avatars/avatar_01.png` … `avatar_07.png` olarak adlandırmak.
- **Varsayım:** panodaki av-1…av-7 ile bu sıranın eşleştiği; panoda dosya adı yok.
- **Eksik çözünürlük:** 96 pt × 3 = 288 px gerekir, mevcut 256 px yetmiyor. 72 pt için 216 px yeterli.
- Sabit örnek kişi eşlemesi: Alparslan 1, Mehmet Özkan 2, Kerem 3, Elif 4, Zeynep 5, Mert 2.

### 4.4 Diğer üretilecek ya da eklenecek varlıklar

- **Onboarding görselleri (2.1, 3 adet):** yeni arayüz parçalarından kurgu; kart 250 × 330, radius 28, gölge 0 12 32 #0F294A %16.
  - Önerilen adlar: `onboarding/onboarding_scan`, `onboarding_analysis`, `onboarding_gaps`.
  - Widget olarak kurulması ya da SVG çıkarılması önerilir. Panoda kesin görsel dosyası yok.
- **Kamera öğretici adım çizimleri (4.2, 3 adım):** "fotoğraf yerine çizim". Öneri: `omr/omr_tutorial_step_1..3.svg`. Detay ekran ajanına bırakılmalı.
- **Sosyal giriş:** Apple ve Google'ın resmî düğme varlıkları (Tur 7 / Tur 10 açık madde). Panoda yer tutucu var.
- **Font:** Plus Jakarta Sans TTF, ağırlıklar 400 / 500 / 600 / 700 / 800 → `fonts/PlusJakartaSans-*.ttf`. `google_fonts` ile indirme yok.
- **Deneme kapakları:** sunucudan gelir. Yer tutucu nötr kutu + ikon; ikon adı belirtilmemiş.

### 4.5 Kaldırılacak mevcut varlıklar

Kaynak: 1.25 kararları ve 11.1 "Koddan kalkacaklar". Dosya adları repo taramasından çıkarılmış aday listesidir; silmeden önce referans kontrolü gerekir.

- `ob1.png` … `ob6.png`: eski onboarding ekran görüntüleri (repoda yaklaşık 7,3 MB; panoda 7,7 MB yazıyor).
- `loginImage.png`: gezginler / harita vektörü.
- `menuIcons/smapc.png`: puan parası. `menuIcons/` altındaki stok menü illüstrasyonları da kalkar.
- Düz ders illüstrasyonları: `turkce.png`, `tarih.png`, `edebiyat.png`, `cografya.png`, `mat.png`, `physics.png`, `biological.png`, `fen.png`, `geometry1.png`, `icons/` altındaki ders PNG'leri.
- Logo varyantları (yaklaşık 40): `logo*.png`, `logos*`, `logosm*`, `logob*`, `logod*`, `logoy*`, `llg*`, `smaplogo.png`, `logoSmap.png`, `logotext.png`, eski üçgen logo (#FF6400).
- "Stundent map" taslağı.
- `cupertino_icons` paketi.

---

## 5. Çelişkiler ve açık kararlar

Her madde için yanında bir öneri var; nihai karar tasarımcıya ait.

1. **Çip boyu ve anatomisi.**
   - Kit 1.11: 36 pt, 14/20, seçiliyken Check ikonu.
   - Ekranlar: 40 pt ve 15/20 (6.1, 7.2, 10.5); 48 pt ve 16/24 (2.2). Check ikonu yok.
   - 6.1 süzgeç sheet'inde ders noktası da yok.
   - Öneri: `size: sm 36 / md 40 / lg 48`; Check kit kuralı gereği her zaman var ("renk tek ipucu değil").
2. **Tümü / Yanlışlar / Boşlar süzgeci:** kitte seçim çipi olarak çizilmiş, 5.4'te sayaçlı segment. Tur 3 sonrasında segment kullanılmış.
3. **EksikTag ağırlığı:** Tur 5 notunda 13/600, CSS'te 13/700.
4. **Derslerim'de eksik etiketi:** 11.13 SubjectRow için EksikTag diyor; 7.1 nötr Tag ile çizilmiş.
5. **Ders satırı glif karosu:** kit 1.16'da 48, Tur 5'te 40.
6. **Konu satırı:** kit 1.16'da numara sütunu 24 ve satır 56; Tur 5'te 28 pt rozet ve satır 64.
7. **SessionProgress:** spec 4 pt, 8.1 markup'ı 8 pt. Sayaç 15/700 ile 13/700 arasında.
8. **Radyo seçili hâli:** 1.13'te 2 pt halka + 12 nokta; 2.2'de 7 pt halka.
9. **Spinner renkleri:** 1.15'te #E8ECF1 / #264066; 4.5 ve 9.4'te #DCE2E9 / #0F294A.
10. **Favori seçili rengi:** 1.16'da #556173 Fill; 6.2'de "lacivert dolgu" #0F294A.
11. **Delta rengi:** 5.1, 6.1 ve 6.4 notlarında "success"; Tur 10 delta rolüne geçirdi. Delta uygulanmalı.
12. **Soru ızgarası aralığı ve hücre dolgusu:** notta 8, 5.4 markup'ında 6. Hücre dolgusu 6 ile 6/8 arasında.
13. **Kapak köşe yarıçapı:** notta radius-sm (8); 5.3 ve 6.2 markup'ında 6.
14. **Kısa detay barı başlığı:** 1.18'de 15/20 600, ortalı; 5.4 ve 3.4'te 17/24 700, sola hizalı.
15. **Sheet eylem alanı alt dolgusu:** kitte 50, ekranlarda 42.
16. **Çevrimdışı geri dönüş metni:** "Bağlantı geri geldi" (1.22) ile "Bağlandın" (11.15).
17. **Arama temizle düğmesi:** kitte 48 / X 20; ekranlarda 40 dokunma + 24 daire + X 12. 40, 48 minimumunun altında.
18. **CodeCard:** Tur 9 notu kod için 24/800 diyor, pano 24/32 · 700, harf aralığı 1. Düğmeler 44 pt; ölçek dışı.
19. **Saat slotu çıkar düğmesi:** 3.5'te 40 × 40; 3.6 notu 48 diyor.
20. **Akordeon sağ öğesi:** kitte 32 pt daire (açıkken dolu); 5.4 ve 7.3'te dairesiz ok (24 / 22 / 20).
21. **Lockup ölçüleri:** 1.26'da 64 + 44 ve 88 + 32; Tur 7 ekranlarında 36 + 24 ve 104 + 40.
22. **Tam ekran durum ikonu:** 64 (1.22), 80 (4.9 / 4.10), 96 (2.7 / 9.4).
23. **StudentRow yüksekliği:** metinde 72, koç CSS'inde 64.
24. **AvatarPicker boyu:** kit listesinde 96; ekranlarda 46 ve 72.
25. **Token adları:**
    - Tur 1'deki `dybEmpty`, 11.12'de `dyb-blank` (`dybBlank`).
    - 11.12 kod iskeletinde `primaryPressed`, `bar`, `dybOn`, `chartArea`, `chartSeries[4]` yok; bunlar 1.2 ve Tur 1'de var. SmapColors ikisinin birleşimi olmalı.
26. **Koyu temada çizilmemiş durumlar** (hepsi belirtilmemiş):
    - Pasif ve salt okunur alan, CodeInput, Calendar, TimeWheel.
    - NoticeBox, BarAction dolu, düğme basılı (primary hariç).
    - Toast'ta bilgi ve hata ikonu.
    - Skeleton parıltısı.

---

## 6. Bağımlılık sırasına göre yapım listesi

Okları "önce bu, sonra şu" diye okuyun. Her katman bir öncekine bağlıdır.

**Katman 0 · Altyapı.** Tur 10'daki "Uygulamada ilk iş" maddesi de bu sırayı veriyor.
- `pubspec` eklemeleri: `mihr_ui`, `phosphor_flutter`, Plus Jakarta Sans TTF.
- Tema eklentileri:
  - `SmapColors` (§1.1 tamamı, ders renkleri dahil)
  - `SmapText` (§1.2)
  - `SmapTokens` (radius, space, shadow, duration, curve, blur)
- `MihrThemeConfig(fontFamily, extraExtensions, buttonTheme)`; açık ve koyu `ColorScheme`'in elle kurulması (11.1).
- `SmapHaptics`: `selectionClick`, `mediumImpact`, `success` / `error` platform köprüsü.
- `SmapMotion`: hareketi azalt yardımcısı.
- Biçimlendiriciler: net, puan, sıra, yüzde, kısa tarih; tr-TR katlama.

**Katman 1 · Atomlar.** Hiçbiri başka bileşene bağlı değil.
- `SmapIcon` (Phosphor Regular / Fill)
- `SmapFocusRing`, `SmapPressable` (ölçek 0,98 / 0,97 / 0,92)
- `SmapSubjectGlyph`, `SmapAvatar` (+ rozet), `SmapDybGlyph`
- `SmapTag`, `SmapEksikTag`
- `SmapSpinner`, `SmapLinearProgress`, `SmapSuccessRing`, `SmapSkeleton`
- `SmapMetricText`, `SmapDeltaText`
- `SmapNoticeBox`, `SmapLogoMark`, `SmapIllustration`, `SmapPageDots`

**Katman 2 · Kontroller.** Katman 1'i kullanır.
- `SmapButton` (mihr_ui butonları üzerine), `SmapIconButton`, `SmapBarAction`
- `SmapCheckbox`, `SmapRadio`, `SmapSwitch`
- `SmapChip` / `SmapFilterPill` / `SmapChipGroup`
- `SmapSegmented`, `SmapTabBar`
- `SmapTextField` → `SmapSearchField`, `SmapTextArea`, `SmapCodeInput`
- `SmapSelectField` (sheet'i Katman 4'te bağlanır)

**Katman 3 · Bileşikler.**
- Liste: `SmapListGroup`, `SmapSettingsRow`, `SmapSectionHeader`, `SmapRadioListTile`
- D/Y/B ve veri: `SmapDybCounter`, `SmapDybStackedBar` / `SmapTestBarRow`, `SmapQuestionCell`, `SmapStatBox`, `SmapNetChart`
- Ders ve konu: `SmapSubjectRow`, `SmapSubjectTile`, `SmapTopicRow`, `SmapTopicResultRow`
- Deneme: `SmapExamRow`, `SmapExamCard`, `SmapExamHeader`
- İçerik: `SmapAccordion` / `SmapExampleBox`, `SmapCardPreview`, `SmapStudyCard`, `SmapSessionProgress`, `SmapAuthorRow`
- Kimlik: `SmapAvatarStack`, `SmapAvatarPicker` (satır içi), `SmapRoleOption`, `SmapProfileSummary`, `SmapCoachCard`, `SmapLockup`, `SmapOnboardingPage`
- Koç: `SmapStudentRow`, `SmapStudentTile`, `SmapAttentionRow`, `SmapMeetingRow`, `SmapCodeCard`
- Program: `SmapDayChip`, `SmapCalendar`, `SmapHourSlot`, `SmapWeekGrid`, `SmapProgramItemRow`, `SmapProgramRow`, `SmapTimeWheel`
- Kamera: `SmapCameraOverlay`, `SmapCameraStatusPill`, `SmapShutterButton`, `SmapCornerHandles` / `SmapLoupe`, `SmapStepRow` / `SmapStepList`, `SmapFormCheckView`

**Katman 4 · Overlay'ler.**
- `SmapBottomSheet` (boylar, klavye, meşgul) →
  - `SmapConfirmSheet`, `SmapComingSoonSheet`, `SmapCardSheet`
  - SelectField sheet'i, `SmapTimeWheel` sheet'i, AvatarPicker sheet'i, `SmapAnswerFixSheet`
- `SmapCardDeck` (StudyCard + swiper + ConfirmSheet + Toast)
- `SmapToast` + `SmapToastController`

**Katman 5 · Kabuk ve durum kalıpları.**
- Barlar: `SmapRootBand` (küçülme, bant içi segment ve sekme), `SmapHomeBand`, `SmapDetailBar` (büyük başlık → kısa bar), `SmapContextStrip`, `SmapOfflineStrip`
- Alt çubuk: `SmapBottomBar` + `SmapCameraButton`
- `SmapStudentScope`
- `SmapShell`: sekme başına Navigator, Toast ve OfflineStrip yuvaları
- Durum kalıpları: `SmapEmptyState`, `SmapErrorState`, `SmapStatusView` (bölüm ve ekran düzeyi; 15 sn kuralı)

**Katman 6 · Varlıklar.** Kod katmanlarından bağımsız, paralel yürür.
- §4.1 logo ve ikon üretimi; `flutter_launcher_icons` ve `flutter_native_splash` ayarları.
- §4.2 kil seti (asıl dosyalar gerekir), §4.3 avatar yeniden adlandırma ve çözünürlük.
- §4.5 temizlik.

**Kaynak klasörler:**
- `docs/design/panolar/SMAP-11/12-11-13-Teslim-Bileşen-Listesi`
- `docs/design/panolar/SMAP-11/13-11-14-Teslim-Ekran-Bileşen-Eşlemesi`
- `docs/design/panolar/SMAP-01/08…25`
- mihr_ui: `mihr_ui paketi (pub) — lib/components/buttons/`, `mihr_ui paketi (pub) — lib/core/widgets/frosted_container.dart`
- Avatar listesi: `lib/core/theme/app_colors.dart`