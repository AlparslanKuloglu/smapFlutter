# SCREENS GROUP C: Hesap ve Koç modu ekran spesifikasyonu

**Kaynaklar**
- 9.1–9.7 (Tur 8) ve 10.1–10.6 (Tur 9) panolarının `board.html`, `styles.css` ve `text.txt` dosyaları.
- 11.14 Ekran–Bileşen Eşlemesi.
- Çapraz doğrulama için okunan panolar:
  - 11.8 (Tur 8 notları) ve 11.9 (Tur 9 notları)
  - 11.10 (Tur 10 değişiklikleri), 11.12 (token), 11.13 (bileşen), 11.15 (hareket) ve 11.16 (varsayımlar)
  - 0.1 ve 0.3 (akış haritaları)
  - Kit: 1.18, 1.20, 1.21, 1.22, 1.23 ve 1.24 (koyu tema)

Hiçbir dosya değiştirilmedi.

---

## 0. Genel çerçeve

### Telefon karesi
- Boyut 402 × 874 pt. Kanvas (bg-canvas): açıkta #F2F4F7, koyuda #0A1424.
- Üst güvenli alan 62 pt.
- Alt çubuk (BottomBar) 102 pt: 68 pt slot ve güvenli alan payı.
- Sayfa yatay kenar boşluğu 16 pt. Sheet içinde yatay boşluk 24 pt.
- Font Plus Jakarta Sans, paketle birlikte gelir (google_fonts ile indirilmez). Bütün rakamlarda `tabularFigures` açık.
- İkonlar Phosphor'dur (`phosphor_flutter`). viewBox 256, çizgi 16. Bazı küçük ikonlarda çizgi 20, 22, 24 ya da 28; ilgili yerde belirtildi.

### Koyu tema
- 9.x ve 10.x panolarında koyu kare yok. D-14 koyu listesi şunlardır: 3.3, 4.3–4.4, 4.6, 5.1, 5.9, 5.10, 6.4, 7.6, 8.2, 3.8.
- Bu yüzden koyu değerler 11.12 rol tablosundan, `styles.css` içindeki `.dk` kurallarından ve 1.23/1.24 kitinden gelir.
- Tek istisna: 1.24 kare 4, 9.5'teki "Koç bağlantısı kaldırılsın mı?" onayının koyu çizimidir.

### Tur 10 düzeltmeleri bu gruba da uygulanır
- Değişim değerinin rengi `delta` oldu: açık #36537C, koyu #9BB3D3. Bu, 10.4'teki "+3,25" için geçerlidir. Yeşil yalnız Doğru'ya ayrıldı.
- Tarih bloğu `metric-md` 24/32 · 700 · −0,4 oldu (10.1).

### Mevcut Flutter durumu
- Routing: `MaterialApp` named routes (`/onboarding`, `/login`, `/home`).
- Hesap sekmesi içinde `AccountNavNotifier` + `AccountRoute` enum kullanılıyor: hub, account, payment, savedCards, contracts, notifications.
- Rol `userRole` string'inden okunuyor ('coach').
- mihr_ui'de yalnız tema token'ları ve düğmeler var: Primary, Secondary, Tertiary, Link, Destructive, SoftPrimary. Boy seçenekleri xxs 24, xs 32, sm 36, md 40, lg 44, xl 48, xxl 56. Sheet, TextField, Switch, Toast gibi diğer bileşenler yazılmalı.

---

## 1. Ödeme, paywall ve kayıtlı kart

Final tasarımda bu ekranlar **yok; v1 kapsamından kaldırıldı**.

Kanıtlar:
- 9.1 kare 2 notu: "Ödeme, paketler ve kayıtlı kartlar yok (D-4)."
- 9.1 "Eskiden" notu: "Ödeme ve Paketler, Kayıtlı Kartlarım menüde (31, 34, 35)."
- 11.8 Tur 8, değişiklik 3: "Ödeme ve Paketler, Kayıtlı Kartlarım kalktı (D-4). Plan, fatura listesi ve kayıtlı kartlar v1 kapsamı dışında."
- 11.8 denetimi: "✓ Ödeme, paket, coin, kayıtlı kart yok (D-3, D-4)."
- 11.11 ve 12.1: mağaza görsellerinde kaldırılan özellikler (coin, Oyunlar, Gelen Kutusu, SmapLab, ödeme) gösterilmez.
- 1.21: "Yakında" sheet'i kitte durur ama hiçbir ekranda kullanılmaz (D-4). Paywall ya da "yakında" yer tutucusu da yok.

Mevcut Flutter kodunda kaldırılacaklar:
- `lib/features/profile/presentation/screens/payment_settings/**` (`current_plan_card`, `invoice_*`, `payment_invoice_mock`)
- `lib/features/profile/presentation/screens/saved_cards/**`
- `AccountRoute.payment` ve `AccountRoute.savedCards`, başlıkları ('Ödeme Ayarlarım', 'Kayıtlı Kartlarım') ile birlikte
- `AccountFlowScreen` içindeki ilgili `case` satırları

---

## 2. Bu grupta kullanılan ortak bileşenler (ölçüler panoların CSS'inden)

### 2.1 BottomBar (1.19)

**İki ayrı sekme seti**
- Öğrenci: Anasayfa (House) · Analizlerim (ChartLine) · Okut · Derslerim (BookOpen) · Hesap (UserCircle).
- Koç (`nav_coach`, D-29): Anasayfa · Öğrencilerim (Users) · Okut · Görüşmelerim (Chats) · Hesap.

**Ölçüler**
- Yükseklik 102 pt. Üst köşeler 24 pt yuvarlak.
- Zemin açıkta rgba(255,255,255,0.92), koyuda rgba(18,29,49,0.92); iki temada da blur 20.
- Üst kenar inset 1 px: açıkta #DCE2E9, koyuda #26354D.
- Slot yüksekliği 68 pt. Sekme genişliği 82,5 pt, padding-top 14, ikon ile etiket arası 6.
- İkon 24 pt.
- Etiket 12/16, ağırlık 600. Renk açıkta #556173, koyuda #A9B5C6.

**Aktif sekme**
- Renk açıkta #0F294A, koyuda #EDF1F6. Etiket ağırlığı 700.
- Üstte 32 × 4 gösterge, alt köşeleri 4 pt yuvarlak. Renk açıkta #E05500, koyuda #FF8533.

**Okut (kamera) düğmesi**
- 56 × 56, köşe 16, zemin #FF6600, ikon Camera 28 pt #0F294A.
- Konum top −16, left 8. Slot genişliği 72.
- Gölge: açıkta 0 2 8 rgba(15,41,74,0.08), koyuda rgba(0,0,0,0.4).
- "Okut" etiketi top 44, 12/16, ağırlık 700. Renk açıkta #1B2232, koyuda #EDF1F6.
- aria: "Okut: deneme formunu kamerayla okut".

**Hareket:** sekme değişimi 250 ms, standard eğri, `selectionClick`.

### 2.2 RootBand (1.18 kök)

**Açık hâl**
- Zemin #0F294A (koyuda da aynı). padding-top 62. Alt köşeler 24 pt yuvarlak.
- Başlık satırı 56 pt, padding 0 16 (10.x'te 0 4 0 16 ve iki uç arası yaslı). Başlık 24/32 · 700 · −0,3, #FFFFFF.
- Sağda en çok bir ikon eylemi: 48 × 48, renk #FFFFFF, erişilebilir adı zorunlu.
- 10.x'te altta 16 pt boşluk → toplam yükseklik 134 pt.

**Kaydırınca küçülme** (9.1 kare 2–3)
- 56 pt kaydırmayı izler; süre yok, linear.
- Yükseklik 110 pt, padding 62 16 0. Başlık satırı 48 pt, başlık 17/24 · 700.
- Alt köşeler düzleşir.

**ProfileSummary** (9.1, RootBand içinde)
- Tek dokunma alanıdır, Profil'i açar.
- padding 4 16 0, öğeler arası 14.
- Avatar 56. Ad 17/24 · 700, #FFFFFF.
- İki alt satır 13/20, #C5D4E8.
- Sağda CaretRight 20, #C5D4E8.
- Bant padding-bottom 20 → toplam ~206 pt. İçerik top 222'den başlar.

### 2.3 HomeBand (koç, 10.1)
- Zemin #0F294A, padding 62 16 20, alt köşeler 24 pt yuvarlak.
- Satır min-height 56, öğeler arası 12.
- Avatar 40.
- Selam 20/28 · 700 · −0,2, #FFFFFF.
- Alt satır 13/20, #C5D4E8.
- İçerik top 182'den başlar.

### 2.4 DetailBar (1.18 detay)

**Başta**
- Zemin bg-canvas.
- Geri düğmesi: CaretLeft 24, 48 × 48 dokunma alanı, top 54, left 4.
- Sağ eylem (BarAction) top 58, right 16.
- Başlık içerikte: `title-lg` 24/32 · 700 · −0,3, top 110.

**Kaydırınca** (9.4 kare 1, 9.7 kare 2)
- Üstte 102 pt opak #F2F4F7 şerit.
- Geri ve başlık aynı satırda (gap 4). Başlık 17/24 · 700, sola yaslı.

**BarAction `.s2`**
- 40 pt yükseklik, padding 0 14, köşe 12.
- Zemin #FFFFFF, metin #0F294A, inset 1,5 px #0F294A çerçeve.
- Yazı 14/20 · 600. İkon 18, ikon ile metin arası 6.
- Dolu varyant `.s2.p`: zemin #0F294A, metin #FFFFFF, gölge yok.
- mihr_ui karşılığı: `MihrSecondaryButton` / `MihrPrimaryButton`, `size: md` (40 pt).

### 2.5 ContextStrip (1.18 kare 6, 10.4)
- 40 pt, top 102 (barın hemen altı).
- Zemin `bg-context`: açıkta #F1F5FA, koyuda #1A2B45.
- Üst ve alt inset 1 px #DCE2E9. Koyu değer belirtilmemiş; role göre `border-subtle` #26354D.
- padding 0 16, öğeler arası 8.
- Avatar 24. "Ad Soyad'ın verileri" 13/20 · 600.
- Sağda sınıf · alan kısaltması, 13/20, #556173.
- Kaydırınca barla birlikte sabit kalır. Ekran okuyucuda ilk okunan öğedir.

### 2.6 ListGroup ve SettingsRow (9.x, 1.13)

**Grup**
- Grup başlığı `.gh`: 13/20 · 600, #556173, margin 0 0 8 4.
- Grup yüzeyi: #FFFFFF (koyu #121D31), köşe 16, `overflow: hidden`.
- Gruplar arası 20.

**Satır `.rw`**
- min-height 56, padding 12 16, öğeler arası 12.
- Ayraç: soldan 52 pt içeriden başlar, 1 px #E8ECF1 (koyu #26354D).
- Sol ikon 24, #556173 (koyu #A9B5C6).
- Başlık 16/24 · 600, #1B2232.
- Alt metin 13/20, #556173.
- Değer 15/24, #556173.
- Sağ öğe: CaretRight 20, değer, Switch ya da ArrowSquareOut.

**Tehlikeli satır**
- Renk #C42D35 (koyu #FF8F8F). Ok yok, ayrı grupta durur.

### 2.7 Liste satırları (10.x)

`.rw` 10.x varyantı:
- min-height 64, padding 12 16, öğeler arası 12.
- Ayraç tam genişlikte, border-top 1 px #E8ECF1.
- `.tn` 16/24 · 600; `.su` 13/20 #556173.
- Sağda CaretRight 20, #556173.

`.pr` (ProgramItemRow):
- padding 10 12 10 16, min-height 64.

### 2.8 TextField (1.12)

**Etiket `.fl`:** 14/20 · 600, alt boşluk 8.

**Alan `.in`**
- Yükseklik 48, padding 0 16, köşe 12.
- Kenar 1 px #697586. Zemin #FFFFFF. Metin 16/24, #1B2232.
- Koyu (1.23): zemin #121D31, kenar #6B7D97, metin #EDF1F6, placeholder #8B9AAF.

**Durumlar**

| Durum | Açık | Koyu |
|---|---|---|
| Placeholder `.ph-t` | #697586 | #8B9AAF |
| Salt okunur `.ro` | zemin #E8ECF1, kenar yok, tam kontrast metin | `bg-sunken` #213049 (rol eşlemesi) |
| Odak `.fo` | kenar #1A3357 + inset 1 px #1A3357 (2 px görünüm) | #9BB3D3 (1.23) |
| Hata `.fe` | kenar #C42D35 + inset 1 px | #FF8F8F |

**Hata ve yardım metinleri**
- Hata satırı `.er`: 13/20 · 600, #C42D35. WarningCircle 18 (çizgi 20), ikon ile metin arası 6, margin-top 6.
- Yardım `.hp`: 13/20, #556173, margin-top 6.
- Başarı `.ok` (canlı kontrol): 13/20 · 600, #0B6E3E. CheckCircle 18 (çizgi 20), ikon ile metin arası 6, margin-top 6.

**Alan varyantları**
- Şifre: göz düğmesi Eye 22, 48 dokunma alanı, sağda. aria "Şifreyi göster". Alanın padding-right'ı 48.
- Kilitli alan: Lock 20, #556173, sağda; ekran okuyucudan gizli (`aria-hidden`).
- SelectField: sağda CaretDown 20, `aria-haspopup="dialog"`, alttan sheet açar.

**TextArea `.ta`**
- min-height 120 (10.5 sheet'inde 88), padding 12 16, köşe 12, kenar 1 px #697586, 16/24.

### 2.9 SearchField (1.12)
- `.in` + `role=search`, öğeler arası 10.
- Solda MagnifyingGlass 20, #556173.
- Temizle düğmesi: 40 × 40 dokunma alanı, margin-right −12. İçinde 24 pt daire, zemin #E8ECF1, X 12 (çizgi 24). aria "Aramayı temizle".
- Eşleşme vurgusu `.mk`: zemin #FCF1D9, metin #1B2232, köşe 4, padding 0 1. Koyuda `warning-bg` #33270F; metin rengi belirtilmemiş.
- Katlama: tr-TR; `toLowerCase(tr)` sonra ı→i.
- Ad ve soyad token'larında önek eşleşmesi; birlikte arama da var ("kerem a").
- Debounce 150 ms, istemcide. 50'den fazla öğrencide arama sunucuda.

### 2.10 Düğmeler (1.9) ve mihr_ui eşlemesi

| Tür | Ölçü | Açık | Koyu | mihr_ui |
|---|---|---|---|---|
| Primary `.bp` | 48 pt, köşe 12, 16/24 · 600, ikon ile metin arası 8 | #0F294A / #FFFFFF | #C5D4E8 / #091A31 | `MihrPrimaryButton(size: xl)` |
| Primary pasif `.bp.off` | 48 pt | #DCE2E9 / #9AA5B4 | #213049 / #56657C | — |
| Outline `.bo` | 48 pt; CodeCard'da 44 | #FFFFFF, metin #0F294A, inset 1,5 #0F294A | şeffaf, #C5D4E8, inset 1,5 #C5D4E8 | `MihrSecondaryButton(size: xl/lg)` |
| Quiet `.bq` | 48 pt | #E8ECF1 / #1B2232 | #213049 / #EDF1F6 | `MihrTertiaryButton`; ghost, dolgu tema ile verilmeli |
| Text `.bt` | 48 pt, padding 0 12, ikon ile metin arası 6 | #1A3357 | #9BB3D3 | `MihrLinkButton` |
| Text tehlikeli `.bt.dn` | 48 pt | #C42D35 | #FF8F8F | — |
| Danger `.bdg` | 48 pt | #C42D35 / #FFFFFF (kontrast 5,4:1) | #FF8F8F / #3B0A10 | `MihrDestructiveButton(size: xl)` |
| İkon düğmesi `.ib` | 48 × 48, köşe 12 | — | — | — |

**Odak halkası `.fr`**
- Açık: 0 0 0 2px #FFFFFF, 0 0 0 4px #36537C.
- Koyu: 0 0 0 2px #18263D, 0 0 0 4px #9BB3D3.

### 2.11 Switch (1.13)
- Boyut 52 × 32, tam yuvarlak.

| Durum | Açık | Koyu |
|---|---|---|
| Açık | zemin #0F294A; başparmak 24, top 4 / right 4, #FFFFFF; içinde Check 14 (çizgi 28), #0F294A | zemin #C5D4E8; başparmak #091A31; check #C5D4E8 |
| Kapalı | inset 2 px #697586; başparmak 16, top 8 / left 8, #697586 | inset 2 px #6B7D97; başparmak #6B7D97 |
| Pasif + açık (9.6) | zemin #DCE2E9; başparmak beyaz, check #9AA5B4; satır başlığı #697586 | belirtilmemiş |
| Pasif + kapalı | kenar ve başparmak #C3CBD6 | belirtilmemiş |

- Hareket 150 ms, `selectionClick`.
- Ekran okuyucu: "Deneme sonucun hazır, açık, anahtar".

### 2.12 Radio (1.13)
- 24 pt daire.
- Kapalı: inset 2 px #697586.
- Seçili: inset 7 px #0F294A.
- Koyu seçili (1.23): halka 2 px #C5D4E8 ve 12 pt iç nokta #C5D4E8.

### 2.13 Segment (1.10)
- Ray: padding 4, zemin #E8ECF1 (koyu #213049), köşe 12, düğmeler arası 4.
- Düğme: min-height 36, köşe 8, 14/20 · 600, metin #556173.
- Seçili: zemin #0F294A, metin #FFFFFF. Koyuda #C5D4E8 / #091A31.

### 2.14 Chip ve etiket (1.11)

**Hap çip `.ch`**
- 40 pt, padding 0 14, tam yuvarlak.
- Zemin #FFFFFF, metin #1B2232, inset 1 px #697586. Yazı 15/20 · 600.
- Seçili: zemin #0F294A, metin #FFFFFF, kenar yok.
- Koyu (1.23): inset #6B7D97, metin #EDF1F6; seçili #C5D4E8 / #091A31.

**Etiket `.tg`**
- 24 pt, padding 0 8, köşe 8.
- Zemin #E8ECF1, metin #1B2232, 13/20 · 600. Koyuda #213049 / #EDF1F6.

### 2.15 InfoBox ve WarningBox

**InfoBox `.inf`**
- padding 12 14, köşe 12, ikon ile metin arası 10.
- Zemin #E2EAF4, metin 15/22 #1B2232.
- İkon Info 20, #36537C.
- Koyu: zemin #1A2B45, ikon #9BB3D3.

**WarningBox `.wrn`**
- Ölçüler InfoBox ile aynı.
- Zemin #FCF1D9, ikon WarningCircle 20, #8A5A00.
- Koyu: zemin #33270F, ikon #F2C46D.

### 2.16 BottomSheet (1.20) ve ConfirmSheet (1.21)

**Perde**
- Açık: rgba(9,26,49,0.48) + blur 8.
- Koyu: rgba(2,6,14,0.64) + blur 8.

**Sheet gövdesi**
- Zemin: açıkta `bg-raised` #FFFFFF, koyuda #18263D. Üst köşeler 24.
- Tutamaç: 36 × 4, #C3CBD6 (koyu #34445F), üst boşluk 8.
- Başlık alanı: padding 12 12 0 24, öğeler arası 8. Başlık 20/28 · 700 · −0,2, padding-top 8. İsteğe bağlı alt başlık 13/20 #556173.
- Kapat düğmesi: 48 dokunma alanı içinde 36 pt daire, zemin #E8ECF1 (koyu #213049), X 18 (çizgi 20).
- Alt eylem alanı `.shf`: padding 16 24 42, düğmeler arası 12. Kit'te alt pay "50 pt dahil"; koyu 1.24'te padding 24 24 50.

**ConfirmSheet**
- Kapat düğmesi yok. İçerik padding 20 24 0.
- Normal onay: ikon yok. Başlık 20/28; gövde 15/24 #556173, margin-top 8. Birincil düğme `.bp` lacivert.
- Tehlikeli onay:
  - Solda 40 pt ikon dairesi: zemin #FCEAEA, ikon #C42D35, WarningCircle 22. Koyuda #3B1D22 / #FF8F8F.
  - Başlık padding-top 6. Gövde margin-top 12.
  - Düğmeler `.bdg` + `.bq.fr`; açılışta odak Vazgeç'te.
- Perdeye dokunmak Vazgeç sayılır.
- Kelime yazdırma yok (D-28).

**Uzun form sheet'i**
- Üstte güvenli alan + 8 pt kalır (1.20). 10.3 panosunda sheet top değeri 90.

**Meşgul durum (1.20 kare 5)**
- Kapat gizlenir, tutamaç soluklaşır.
- Sürükleme ve perdeye dokunma sheet'i kapatmaz; Android geri hareketi engellenir.
- Alanlar salt okunur olur. Hata olursa sheet açık kalır ve girilenler korunur.

**Hareket:** açılış 350 ms `ease-enter` Cubic(0,0,0,1); kapanış 250 ms `ease-exit` Cubic(0.3,0,1,1). Hareketi azalt açıkken opaklık 150 ms.

### 2.17 Toast (1.22)

**Ölçüler**
- min-height 48, padding 12 16, köşe 12, öğeler arası 12.
- Zemin #0F294A, metin #FFFFFF 15/24.
- Gölge 0 8 24 rgba(15,41,74,0.16).
- Konum: left/right 16, bottom 110 (alt çubuğun 8 pt üstü).

**"Geri Al" eylemi (10.6)**
- Metin #C5D4E8, 15/24 · 700, padding 0 4, min-height 48.

**Koyu tema (1.24): ters yüzey**
- Zemin #E8ECF1, metin #1B2232, gölge rgba(0,0,0,0.56).
- Eylem metni #1A3357. Eylem solunda inset 1 px #C3CBD6 ayraç, padding 0 4 0 16.

**Süreler ve davranış**
- 4 sn; Geri Al varsa 6 sn (D-31).
- Giriş/çıkış 250 ms.
- Aynı anda tek toast. Yukarı kaydırınca kapanır.
- Hata toast'unda `error` haptiği.

### 2.18 Skeleton ve durum kalıpları (1.22)
- İskelet blok `.sk`: zemin #E8ECF1 (koyu #213049), köşe 8.
- Parıltı 1200 ms döngü; hareketi azalt açıkken durur.
- 15 sn içinde veri gelmezse hata durumuna geçilir.
- Bölüm hatası (3.2 kalıbı): "<Bölüm> yüklenemedi." + "Tekrar Dene"; yalnız o bölüm yenilenir.
- Ekran hatası metni: "Bağlantını kontrol edip tekrar dene. Sorun sürerse biraz sonra yeniden açabilirsin."
- Çevrimdışı şeridi:
  - Açık: zemin #1B2232, metin beyaz, 13/20 · 600, min-height 40.
  - Koyu: zemin #E8ECF1, metin #1B2232.
  - Metin: "Çevrimdışısın. Son kaydedilen veriler gösteriliyor."

### 2.19 Diğer bileşenler

**Avatar**
- Tam yuvarlak; yer tutucu zemin #DCE2E9.
- Bu panolardaki atamalar: Alparslan av-1, Mehmet av-2, Kerem av-3, Elif av-4, Zeynep av-5, Mert av-2 (koçla aynı görsel; varsayım 9.5).

**Spinner (9.4)**
- 48 pt, viewBox 24.
- İz: r 9,5, #DCE2E9, çizgi 3.
- Yay: #0F294A, çizgi 3, yuvarlak uç. Linear dönüş.
- aria "Sürüyor".

---

## 3. Ekranlar

### 9.1 · Hesap (4 kare, Tur 8)

**Kimlik**
- id: 9.1
- Sınıf: `AccountScreen` (RootBand + ProfileSummary + SettingsGroup × 5 + LogoutRow + VersionText)
- Route önerisi: `/account`. `AccountRoute.hub` iki rolde de kök sekmedir.

**Amaç:** Hesap kök sekmesi. Profil özeti, gruplu ayar menüsü, onaylı çıkış ve sürüm bilgisi.

**Kare 1: Hesap, üst (öğrenci)**

RootBand:
- Başlık "Hesap".
- ProfileSummary: av-1 56, "Alparslan Kuloğlu", "12. Sınıf · Eşit Ağırlık", "Koçun: Mehmet Özkan", sağda CaretRight.
- aria: "Profil: Alparslan Kuloğlu, 12. Sınıf, Eşit Ağırlık, koçun Mehmet Özkan".

İçerik (top 222, gruplar arası 20):
- Grup "Hesap":
  - [UserCircle] "Profil" / "Ad, e-posta, telefon, sınıf ve alan" ›
  - [Lock] "Şifre" ›
- Grup "Koçluk": [Users] "Koçluk" / "Mehmet Özkan" ›
- Grup "Bildirimler": [Bell] "Bildirimler" / "Deneme sonucu, koç, görüşme, hatırlatıcı" ›
- Grup "Yasal": [FileText] "Sözleşmeler" / "Kullanım Koşulları, KVKK, Gizlilik" ›

BottomBar: öğrenci seti, aktif sekme Hesap.

**Kare 2: Hesap, alt (kaydırılmış)**
- Bant 110 pt'ye küçülmüş, başlık "Hesap" 17/24 · 700.
- İçerik top 126:
  - "Bildirimler" ve "Yasal" grupları.
  - Grup "Destek": [Envelope] "Bize Yaz" / "E-posta uygulaman açılır", sağda ArrowSquareOut 20.
  - Başlıksız grup: [SignOut] "Çıkış Yap" (#C42D35, ok yok).
  - En altta 13/20, #556173, ortalı: "Sürüm 3.0.0 (300)".

**Kare 3: Çıkış onayı**
- Normal ConfirmSheet: lacivert birincil düğme, ikon yok.
- Başlık: "Çıkış yapılsın mı?"
- Gövde: "Tekrar girmek için kullanıcı adın ve şifren gerekecek. Okuttuğun denemeler hesabında kalır."
- Düğmeler: "Çıkış Yap" (`.bp`), "Vazgeç" (`.bq`).
- Bekleyen gönderim varsa gövde şöyle olur: "Gönderilmeyi bekleyen 1 form var; çıkarsan silinir."

**Kare 4: Koç · Hesap**
- ProfileSummary: av-2, "Mehmet Özkan", "Öğrenci koçu", "Koçluk kodun: MOZK-4821".
- aria: "Profil: Mehmet Özkan, öğrenci koçu, koçluk kodu MOZK-4821".
- Grup "Hesap": Profil, Şifre (öğrenciyle aynı satırlar; Profil alt metni de aynı, bkz. Tutarsızlıklar).
- Grup "Koçluk": dokunulamayan satır.
  - [Users] "Koçluk kodun".
  - Kod 15/24 · 700, #1B2232, harf aralığı 0,5: "MOZK-4821".
  - Sağda iki 48 pt ikon düğmesi: Copy 22 (aria "Kodu kopyala") ve ShareNetwork 22 (aria "Kodu paylaş", margin-right −12).
- Bildirimler ve Yasal grupları.
- Kaydırınca görülen Destek, Çıkış Yap ve sürüm koç karesinde çizilmemiş. Varsayım 8.10 "Koçun Hesap'ı öğrencininkiyle aynı yapıda" der; öğrenciyle aynı kabul edilir.
- BottomBar: koç seti, aktif sekme Hesap.

**Durumlar**
- Çizilenler: üst, kaydırılmış, çıkış onayı, koç.
- Yükleme ve hata: belirtilmemiş. Profil verisi oturumdan gelir.
- Koçu olmayan öğrenci: ProfileSummary'nin 3. satırı ve "Koçluk" satırının alt metni belirtilmemiş.

**Etkileşim ve gezinme**
- ProfileSummary → 9.2.
- Profil → 9.2; Şifre → 9.3; Koçluk → 9.5 (öğrenci); Bildirimler → 9.6; Sözleşmeler → 9.7.
- Bize Yaz: e-posta uygulaması açılır; taslak sürüm ve cihaz bilgisiyle dolar. Destek adresi Ek C'de yok (varsayım 8.3).
- Çıkış Yap → onay → Hoş geldin (2.2 kare 5).
- Kopyala → toast "Kod kopyalandı." (4 sn).
- Paylaş → sistem paylaşım sheet'i.
- Sürüm satırına uzun basınca sürüm kopyalanır (destek için).
- Ekran okuyucu: "Çıkış Yap, düğme, onay ister".

**Veri ve backend**
- Ad, avatar, sınıf, alan, koç adı: profil ve oturum (`UserProvider`); koç adı `/student/getStudentsCoach`.
- Koçluk kodu: koç profilinden gelir. Alan adı belirtilmemiş; "kayıttan sonra oluşur" (0.3).
- Sürüm: derlemeden okunur (`package_info`); "Sürüm 3.0.0 (300)" örnek değerdir (varsayım 8.1).
- Çıkış: `/ajax/logout`.
- Bekleyen form sayısı: yerel gönderim kuyruğu.

**Rol farkı**
- Öğrenci: Koçluk satırı 9.5'e gider.
- Koç: Koçluk grubu kodu ve Kopyala/Paylaş'ı taşır, bir ekrana gitmez. Alt çubuk koç setidir.

**Koyu tema:** çizilmemiş.
- Bant #0F294A kalır.
- Gruplar #121D31, kanvas #0A1424, ayraç #26354D, ikon ve alt metin #A9B5C6.
- Çıkış satırı #FF8F8F (1.23).

**Notlar**
- Kırmızı yalnız Çıkış satırında; Çıkış onay düğmesi kırmızı değil, lacivert (varsayım 8.9).
- Hesabı Sil bu listede yok; Profil'in altında (varsayım 8.6).
- Eskiden: satırlar zeminle aynı tondaydı (1,05:1); renkli emoji benzeri ikonlar vardı; koçluk ve destek yoktu; sürüm numarası yoktu; Çıkış diğer satırlarla aynı biçimde ve onaysızdı.

---

### 9.2 · Profil (4 kare)

**Kimlik**
- Sınıflar: `ProfileScreen` (view/edit), `AvatarSheet`, `GradeSheet`; Alan için `FieldSheet` (adı önerimdir).
- Route önerisi: `/account/profile`. Mod state ile değişir, ayrı route değildir. Sheet'ler modaldır, route değildir.

**Amaç:** Profili görüntüleme ve düzenleme; avatar ve sınıf/alan değişimi.

**Kare 1: Görüntüleme**

DetailBar:
- Geri.
- Sağda BarAction `.s2` çerçeveli: [PencilSimple 18] "Düzenle".

İçerik:
- Başlık "Profil" (24/32), top 110.
- Form top 158, satırlar arası 16:
  - av-1 72 + `.bt` "Avatarı Değiştir" (margin-left −12, aralık 16).
  - Salt okunur alanlar (`.ro`):
    - "Ad Soyad" = "Alparslan Kuloğlu"
    - "Kullanıcı adı" = "alparslan.k" + Lock 20
    - "E-posta" = "alparslan@ornek.com"
    - "Telefon" = "+90 5XX XXX XX XX"
    - "Sınıf" = "12. Sınıf"
    - "Alan" = "Eşit Ağırlık"
- En altta (9.4 kare 1): `.sep` ayraç (margin-top 8) + [Trash 20] "Hesabı Sil" (`.bt.dn`).

**Kare 2: Düzenleme**

DetailBar:
- Solda `.bt` "Vazgeç" (top 54, left 4).
- Sağda dolu `.s2.p` "Kaydet".

Alanlar:
- Ad Soyad, E-posta: normal `.in`.
- Kullanıcı adı: `.ro` + kilit kalır, altında yardım metni "Kullanıcı adı değiştirilemez."
- Telefon: odakta (`.fo`). Maske "+90 5XX XXX XX XX", sayı klavyesi.
- Sınıf, Alan: SelectField (CaretDown 20); alttan sheet açar.

**Kare 3: Avatar sheet'i**
- Başlık "Avatarını seç", alt başlık "7 avatar", Kapat.
- Izgara: 4 sütun × 72 pt, sütunlar arası `space-between`, satırlar arası 20, padding 20 24 0.
- Seçili avatar halkası: 0 0 0 3px #FFFFFF, 0 0 0 5px #0F294A. Halka 2 pt, araya 3 pt beyaz boşluk (1.17).
- aria: "Avatar 1, seçili" / "Avatar N" (`aria-pressed`).
- Alt düğme: `.bp` "Bu Avatarı Kullan".
- Seçim yalnız Kaydet'le kalıcı olur.

**Kare 4: Sınıf sheet'i**
- Başlık "Sınıf", Kapat.
- Radiogroup satırları (padding 12 24): "9. Sınıf", "10. Sınıf", "11. Sınıf", "12. Sınıf" (seçili), "Mezun".
- Altında 13/20, #556173, padding 8 24 0: "9. ya da 10. sınıfı seçersen alan kaldırılır."
- Alt boşluk 42.
- Seçince sheet kapanır; ayrı onay yok.
- Alan sheet'i çizilmemiş. Seçenekler 2.2'den: Sayısal, Eşit Ağırlık, Sözel, Dil (D-19). Sınıf seçenekleri 9, 10, 11, 12, Mezun (D-20). 9.–10. sınıfta Alan pasif ("Seçilmez").

**Davranış**
- Kaydet: değişen alan yoksa pasif. Pasif `.s2.p` görünümü çizilmemiş.
- Başarılı kayıt → görüntüleme moduna dönülür, toast "Profilin güncellendi." (4 sn).
- Vazgeç: değişiklik varsa normal onay "Değişiklikler kaydedilmesin mi?". Gövde ve düğme metinleri belirtilmemiş.
- Kaydetme hatası: form korunur, toast "Kaydedilemedi. Bağlantını kontrol edip tekrar dene."
- E-posta değişirse yeni adrese 6 haneli kod gider (2.4 CodeInput kutuları); doğrulanana kadar eski adres geçerli. Bu doğrulama ekranı bu panoda çizilmemiş.

**Veri ve backend**
- PATCH yalnız değişen alanlarla. Bugün `/student/updateStudent` (POST) kullanılıyor.
- E-posta doğrulama ucu yok; yeni uç gerekiyor (belirtilmemiş).
- Avatar 7 sabit varlık; avatar id.

**Rol farkı:** koçta Sınıf ve Alan alanları yok (varsayım 8.10).

**Koyu tema:** çizilmemiş.
- Girdi zemini #121D31, kenar #6B7D97.
- `.ro` alan #213049.
- Odak #9BB3D3.
- Sheet #18263D.
- Seçili avatar halkası koyu değeri belirtilmemiş; role göre beyaz boşluk yerine #18263D, halka #C5D4E8.

**Notlar**
- Ad ve avatar yalnız Hesap'ta ve Anasayfa'da görünür (D-9).
- Eskiden: profil ve şifre tek sayfadaydı; kalemle düzenleniyordu; telefon maskesizdi; sınıf ve alan değiştirilemiyordu; ad ve avatar üst barda ve sayfada iki kez vardı.

---

### 9.3 · Şifre (3 kare)

**Kimlik**
- Sınıf: `PasswordScreen`.
- Route önerisi: `/account/password`.

**Amaç:** Şifre değiştirme: mevcut şifre, yeni şifre ve tekrarı.

**Kare 1: Form**
- DetailBar: geri. Başlık "Şifre".
- Form top 166, alanlar arası 20. Üç şifre alanı, her biri Eye 22 göster/gizle düğmeli:
  - "Mevcut şifre"
  - "Yeni şifre" + yardım "En az 8 karakter."
  - "Yeni şifre (tekrar)" (karede odakta)
- Tek birincil düğme: "Şifreyi Güncelle".

**Kare 2: Mevcut şifre hatalı**
- "Mevcut şifre" alanı `.fe`; altında hata: "Mevcut şifren doğru değil."
- Odak mevcut şifrede kalır; yeni şifre alanları korunur.

**Kare 3: Güncellendi**
- Hesap ekranına (9.1 kare 1) dönülür, toast "Şifren güncellendi." (4 sn).
- Toast ikonsuz çizilmiş (bkz. Tutarsızlıklar).

**Kurallar ve hata metinleri**
- Yeni şifre en az 8 karakter (1.12); ek şart yok (varsayım 7.5).
- Yeni şifre mevcutla aynıysa: "Yeni şifre eskisiyle aynı olamaz."
- Yeni şifre ile tekrarı eşleşmezse: "Şifreler aynı değil."

**Davranış**
- Düğme yalnız alanlar doluyken çalışır; boşken `.bp.off`.
- Gönderirken düğmede spinner (Button "yükleniyor" varyantı, 1.9).
- Başarıda bu cihazın oturumu açık kalır, diğer cihazlardakiler kapanır.
- Bu ekranda "Şifremi unuttum" bağlantısı yok; sıfırlama girişten (2.4) yapılır.

**Veri ve backend:** mevcut kodda şifre değiştirme ucu yok; yeni uç gerekiyor (belirtilmemiş). Sunucu diğer oturumları kapatır.

**Rol farkı:** yok.

**Koyu tema:** çizilmemiş. Hata kenarı ve metni #FF8F8F, odak #9BB3D3.

**Notlar**
- Eskiden "Şifre ve Güvenlik" profilin altındaydı ve kalemle açılıyordu.
- Alanlar yalnız placeholder ile etiketliydi.

---

### 9.4 · Hesabı Sil (5 kare): yıkıcı akış

**Kimlik**
- Sınıf: `DeleteAccountFlow` (Info → DangerSheet → Progress → Done).
- Route önerisi:
  - `/account/delete` (açıklama)
  - `/account/delete/progress` ve `/account/delete/done` (tam ekran, sekme kabuğunun dışında)

**Kare 1: Giriş noktası (Profil, kaydırılmış)**
- Bar opak #F2F4F7 (102 pt); geri + "Profil" 17/24 · 700; sağda "Düzenle" durur.
- Profil formunun altı: Telefon, Sınıf, Alan (salt okunur); `.sep` (margin-top 8); [Trash 20] "Hesabı Sil" (`.bt.dn`, margin-left −12).
- Hesap ana listesinde bu giriş yok; yanlışlıkla dokunulmasın diye.

**Kare 2: Açıklama ekranı**
- DetailBar: geri. Alt çubuk görünür.
- Başlık "Hesabını sil" (24/32).
- 16/24 · 600, margin-top 16: "Hesabını silersen:"
- Liste (margin-top 12, maddeler arası 12, 16/24). Her madde: X 18 (çizgi 22, #C42D35, padding-top 2) + 10 pt aralık + metin:
  1. "Okuttuğun 10 deneme ve analizleri silinir."
  2. "Eksik konuların, programların ve bilgi kartı ilerlemen silinir."
  3. "Koçun Mehmet Özkan ile bağlantın kalkar."
  4. "Bu işlem geri alınamaz."
- 15/24, #556173, margin-top 20: "Yalnız bir süre ara vermek istiyorsan çıkış yapman yeterli; verilerin hesabında kalır."
- Düğmeler alta sabit (bottom 118, left/right 16, aralık 12): "Hesabımı Sil" (`.bdg`), "Vazgeç" (`.bq`).

**Kare 3: Tehlikeli onay**
- ConfirmSheet, tehlikeli varyant. Kare 2'nin üstünde, perdeyle.
- İkon dairesi #FCEAEA / #C42D35.
- Başlık: "Hesabın silinsin mi?"
- Gövde: "Alparslan Kuloğlu hesabı ve bütün verilerin kalıcı olarak silinecek. Bu işlem geri alınamaz."
- Düğmeler: "Hesabımı Sil" (`.bdg` #C42D35, beyaz metin, 5,4:1) ve "Vazgeç" (`.bq` + odak halkası `.fr`).
- Kelime yazdırma ve yeniden kimlik doğrulama yok (D-28). Açılışta odak Vazgeç'te.

**Kare 4: Siliniyor**
- Tam ekran; alt çubuk ve geri düğmesi yok; geri hareketi kapalı.
- top 300, ortalı:
  - Spinner 48
  - "Hesabın siliniyor" (20/28, margin-top 24)
  - "Uygulamayı kapatma." (15/24, #556173, margin-top 6)
- `role=status`, `aria-live=polite`.
- Hata olursa açıklama ekranına (kare 2) dönülür, metin: "Hesabın silinemedi. Bağlantını kontrol edip tekrar dene." Toast mu satır içi mi olacağı belirtilmemiş.

**Kare 5: Silindi**
- Tam ekran, alt çubuk yok.
- top 220, ortalı:
  - 96 pt daire: zemin #E4F4EA, CheckCircle 48 #0B6E3E.
  - "Hesabın silindi" (24/32, margin-top 28).
  - "Verilerin silindi. İstersen yeni bir hesapla yeniden başlayabilirsin." (16/24, #556173, margin-top 10).
- Altta `.bp` "Tamam" (bottom 42, left/right 24).
- Oturum kapanır. Tamam → Hoş geldin (2.2 kare 5). Haptik yok.

**Davranış ve backend**
- `/ajax/deleteAccount`; istek idempotent.
- İstek gönderilince bekleyen form kuyruğu temizlenir.
- Koça bildirim gitmez; öğrenci koçun listesinden düşer.
- Yasal saklama gereken kayıtlar sunucu kuralına göre tutulur. Metin bunu vaat etmez, Sözleşmeler'e bağlanır.
- Hareket (11.15): tam ekran spinner, linear, geri kapalı; hareketi azalt açıkken de aynı.

**Veri**
- Deneme sayısı: 6 TYT + 4 AYT = 10 (varsayım 8.7).
- Koç adı ve kullanıcının adı soyadı.
- Koç yoksa 3. maddenin gizlenip gizlenmeyeceği belirtilmemiş.

**Rol farkı:** koç için Hesabı Sil akışı ve madde metinleri belirtilmemiş. Koç Profili'nin altında giriş olup olmadığı da belirtilmemiş.

**Koyu tema:** çizilmemiş.
- Danger düğme #FF8F8F / #3B0A10.
- İkon dairesi #3B1D22 / #FF8F8F.
- X ikonları #FF8F8F.
- Başarı dairesi #15301F / #52CC8E.
- Spinner izi ve yayı belirtilmemiş; role göre iz #213049, yay #C5D4E8.

**Notlar:** eskiden "Hesabımı Sil" profilin altında onaysız görünen kırmızı bir bağlantıydı.

---

### 9.5 · Koçluk (4 kare, yalnız öğrenci)

**Kimlik**
- Sınıf: `CoachingScreen` (linked / unlinked).
- Route önerisi: `/account/coaching`.

**Kare 1: Koçu var**
- DetailBar: geri. Başlık "Koçluk". İçerik top 158, bölümler arası 16.
- CoachCard (`.grp`, padding 16):
  - av-2 64 + 14 pt aralık + "Mehmet Özkan" (17/24 · 700) + "Koçun" (13/20).
  - `.sep` (margin 16 0 12).
  - "Sıradaki görüşme" (13/20, #556173).
  - "12 Ekim 2026 Pazartesi, 16:00" (16/24 · 600, margin-top 2).
- InfoBox: "Mehmet Özkan denemelerini, analizlerini ve programını görebilir."
- `.bt.dn` "Bağlantıyı Kaldır" (ikonsuz, margin-left −12).
- Görüşme yoksa ayraç ve görüşme satırı çizilmez.

**Kare 2: Bağlantıyı kaldır onayı**
- Tehlikeli ConfirmSheet.
- Başlık: "Koç bağlantısı kaldırılsın mı?"
- Gövde: "Mehmet Özkan gelişimini artık göremeyecek. Yeniden bağlanmak için koçluk kodunu tekrar girmen gerekir."
- Düğmeler: "Bağlantıyı Kaldır" (`.bdg`) ve "Vazgeç" (`.bq.fr`).
- Başarıda toast "Koç bağlantın kaldırıldı." Ekranın sonradan kare 3'e geçtiği varsayılır; panoda yazılı değil.

**Kare 3: Koçu yok**
- İçerik aralığı 20.
- 16/24, #556173: "Koçunun verdiği kodu gir; koçun denemelerini, analizlerini ve programını görebilsin."
- Alan "Koçluk kodu" (odakta, örnek "MOZK-4821"); yardım: "4 harf ve 4 rakam; tire kendiliğinden gelir."
- `.bp` "Koça Bağlan".
- `.bt` [Question 20] "Koçluk Kodu Nedir?" (margin −8 0 0 −12).
- Maske `AAAA-0000`; büyük harfe çevirir, tireyi kendisi koyar.
- Hata: "Bu kodla bir koç bulunamadı. Kodu koçundan yeniden iste."
- Başarı: toast "Mehmet Özkan'a bağlandın." ve kare 1'e geçiş.

**Kare 4: "Koçluk kodu nedir?" sheet'i**
- Kapat ve ikon yok. İçerik padding 20 24 0.
- Başlık "Koçluk kodu nedir?"
- İki paragraf (16/26, margin-top 10):
  - "Koçluk kodu, koçunun SMAP hesabına özel koddur; dört harf ve dört rakamdan oluşur."
  - "Kodu koçundan iste. Girdiğinde koçun denemelerini, analizlerini ve programını görebilir. Bağlantıyı istediğin an buradan kaldırabilirsin."
- `.bp` "Tamam".

**Veri ve backend**
- Koç bilgisi: `/student/getStudentsCoach`.
- Bağlanma: `/student/addCoach?code=`.
- Kaldırma: `/student/deleteCoach`. Mevcut kodda `queryParams` hazırlanıyor ama istekte gönderilmiyor; kontrol edilmeli.
- Sıradaki görüşme: kaynağı belirtilmemiş (koç görüşmelerinden).
- Koç tarafında bağlantı kalkınca öğrenci koçun listesinden düşer.

**Rol farkı:** yalnız öğrencide var. Koçta Koçluk grubu yalnız kodu gösterir (9.1 kare 4).

**Koyu tema:** 1.24 kare 4 çizili.
- Sheet #18263D.
- İkon dairesi #3B1D22 / #FF8F8F (ikon çizgisi 18).
- Gövde metni #A9B5C6.
- Danger düğme #FF8F8F / #3B0A10 (7,74:1).
- Vazgeç #213049 / #EDF1F6, odak halkası 2px #18263D + 4px #9BB3D3.
- Eylem alanı padding 24 24 50.
- O karedeki koç kartı: `.rw` min-height 72, avatar 40.

**Notlar:** eskiden koç profilde yalnız bir "Öğrenci Koçluğu" satırıydı; bağlanma ve kaldırma yolu yoktu.

---

### 9.6 · Bildirimler (3 kare)

**Kimlik**
- Sınıflar: `NotificationsScreen`, `TimeWheelSheet`.
- Route önerisi: `/account/notifications`.

**Kare 1: Ayarlar**
- DetailBar: geri. Başlık "Bildirimler". İçerik top 158, bölümler arası 20.
- InfoBox: "Bildirimler planlı: tercihlerin şimdiden kaydedilir, bildirimler açıldığında bunlara göre gelir."
- Grup "Kategoriler" (satırlarda sol ikon yok; her satırda Switch, karede hepsi açık):
  1. "Deneme sonucun hazır" / "Okuttuğun denemenin analizi bitince"
  2. "Koçun deneme ya da ödev atadı" / "Mehmet Özkan yeni bir şey atadığında"
  3. "Görüşme planlandı" / "Koçun bir görüşme planladığında"
  4. "Çalışma hatırlatıcısı" / "Programındaki çalışmanın saatinde"
- Grup "Sessiz saatler":
  - [Clock 24] "Sessiz saatler" / "Bu saatlerde bildirim gelmez" + Switch (açık).
  - "Başlangıç" — "22:00" ›
  - "Bitiş" — "08:00" ›
  - Bu iki satırın soldaki ikonu `visibility: hidden` ile hizalama boşluğu olarak duruyor.
- 13/20, #556173, margin −8 4 0: "Değişiklikler anında kaydedilir."
- Kaydet düğmesi yok.

**Kare 2: Sistem izni kapalı**
- InfoBox yerine WarningBox (`role=alert`):
  - Metin: "Bildirim izni kapalı. Telefonunun ayarlarından SMAP'e izin verirsen bu tercihler geçerli olur."
  - Altında `.bt` "Ayarları Aç" (margin 2 0 −10 −12).
- Bütün anahtarlar pasif (#DCE2E9) ama tercih görünür kalır. Başlıklar #697586.
- Başlangıç ve Bitiş satırları normal renkte çizilmiş.

**Kare 3: Saat seçici sheet'i**
- Başlık "Sessiz saat başlangıcı", Kapat.
- Çark: margin 16 24 0, padding 8 0, sütunlar arası 48.
  - Seçim bandı: top 96, yükseklik 44, köşe 12, zemin #E8ECF1.
  - Saat sütunu: 20 · 21 · **22** · 23 · 00.
  - ":" 24/40 · 700.
  - Dakika sütunu: 50 · 55 · **00** · 05 · 10.
  - Seçili olmayan değer 20/40 · 500, #9AA5B4. Seçili değer 24/40 · 700, #1B2232.
- `.bp` "Kaydet" sheet'i kapatır.
- aria "Saat seçici, 22:00". Ayarlanabilir öğe; yukarı/aşağı kaydırma 5 dakikalık adım.
- Bitiş sheet'inin başlığı belirtilmemiş.

**Davranış**
- Varsayılanlar: bütün kategoriler açık; sessiz saatler açık, 22:00–08:00 (D-24).
- Anahtar değişince değer anında sunucuya yazılır (anahtar başına PUT). Hata olursa anahtar geri döner ve toast gösterilir; metni belirtilmemiş.
- Sessiz saatler kapalıysa Başlangıç ve Bitiş satırları gizlenir.
- İzin `permission_handler` ile okunur; uygulama öne gelince yeniden okunur. "Ayarları Aç" → `openAppSettings`.
- İzin istemi burada değil, ilk başarılı okutmadan sonra (D-23, 5.2).

**Veri ve backend:** bildirim tercihi ucu mevcut kodda yok; yeni uç gerekiyor (belirtilmemiş). Kategori 2'nin alt metni koç adını kullanır.

**Rol farkı**
- Koçun bildirim kategorileri çizilmemiş.
- Varsayım 9.8: "Görüşmeden 1 saat önce koça hatırlatma; koçun bildirim tercihine bağlı."
- Koçun 9.1'deki Bildirimler satırının alt metni öğrenciyle aynı çizilmiş.

**Koyu tema:** çizilmemiş.
- Switch açık #C5D4E8 + başparmak #091A31 (1.23).
- WarningBox #33270F, ikon #F2C46D.
- Çark bandı #213049 (role göre).

**Notlar**
- Bildirim altyapısı henüz açık değil (varsayım 8.4).
- Eskiden: "Aktif", "Kullanıcılar Görebilsin", "Varsayılan Bildirim", "Mobilde Göster", "Otomatik Güncellemeleri Aç" gibi geliştirici anahtarları; Tailwind yeşili anahtarlar; turuncu "Değişiklikleri Kaydet" düğmesi. Mevcut `notification_toggle_tile.dart` buna göre yeniden yazılmalı.

---

### 9.7 · Sözleşmeler (2 kare)

**Kimlik**
- Sınıflar: `AgreementsScreen`, `AgreementReader`.
- Route önerisi: `/account/agreements` ve `/account/agreements/:docId`.

**Kare 1: Liste**
- DetailBar: geri. Başlık "Sözleşmeler". İçerik top 158, aralık 12.
- Tek grup, her satırda FileText 24 ve CaretRight:
  - "Kullanım Koşulları" / "Sürüm 1.2 · 1 Eylül 2026"
  - "KVKK Aydınlatma Metni" / "Sürüm 1.1 · 1 Eylül 2026"
  - "Gizlilik Politikası" / "Sürüm 1.1 · 1 Eylül 2026"
- 13/20, #556173, margin 0 4: "Kayıt olurken bu sürümleri onayladın. Bir metin değişirse uygulama açılışında yeni sürümü onaylaman istenir."

**Kare 2: Okuma ekranı**
- Bar kaydırılmış hâlde: #F2F4F7 zemin, geri + "Kullanım Koşulları" 17/24 · 700.
- Gövde top 118:
  - 13/20, #556173: "Sürüm 1.2 · Yürürlük 1 Eylül 2026"
  - Bölüm başlıkları 17/24 · 700, margin 20 0 6.
  - Paragraflar `body-lg` 16/26, margin 0 0 10.
- Örnek metin:
  - "1. Taraflar ve konu": "Bu koşullar, SMAP uygulamasını kullanan öğrenci ve koçlar için geçerlidir. Uygulamayı kullanarak bu koşulları kabul etmiş olursun."
  - "2. Hesabın": "Hesabının güvenliğinden sen sorumlusun. Kullanıcı adını ve şifreni kimseyle paylaşma; paylaşıldığını düşünürsen şifreni değiştir."
  - "3. Okutulan formlar": "Okuttuğun optik formların görüntüsü yalnız sonucunu hesaplamak için işlenir. Ayrıntılar KVKK Aydınlatma Metni'nde."
- Metin sunucudan gelir ve uygulama tipografisiyle gösterilir (web görünümü değil).

**Veri ve backend:** `/ajax/getLegalDocuments`. Gereken alanlar: ad, sürüm, yürürlük tarihi, gövde (başlık ve paragraf yapısı). Sürüm ve tarihler örnektir (varsayım 8.2).

**Durumlar:** yükleme ve hata belirtilmemiş; 1.22 kalıbı uygulanır.

**Rol farkı:** yok.

**Koyu tema:** çizilmemiş.

**Notlar**
- Yeni sürüm onayı uygulama açılışında istenir; o akış bu grupta değil.
- Eskiden: sarı belge ve göz ikonları; sürüm ve tarih yoktu; metin web görünümünde açılıyordu.
- Mevcut `contract_card.dart` buna göre değişmeli.

---

### 10.1 · Koç Anasayfa (4 kare, Tur 9)

**Kimlik**
- Sınıf: `CoachHomeScreen` (HomeBand + StudentStrip + AttentionSection + MeetingsSection).
- Route önerisi: `/coach/home` (koç kök sekmesi "Anasayfa").

**Kare 1: Normal**

HomeBand:
- av-2 40 + "Merhaba, Mehmet" + "5 öğrenci · önümüzdeki 7 günde 2 görüşme".

İçerik (top 182, bölümler arası 28):

1. **Öğrencilerin**
   - Başlık 20/28. Sağda `.bt` [Plus 20] "Öğrenci Ekle" (40 pt, margin-right −12). Bölümün tek bağlantısı budur.
   - Yatay şerit (sayfa kenarına taşar, padding 0 16, aralık 8, yatay kaydırma).
   - StudentTile `.stt`: 108 pt genişlik, padding 14, köşe 16, zemin #FFFFFF, aralık 8. Avatar 48. Ad 15/20 · 600, iki satıra kadar.
   - Karolar: "Alparslan Kuloğlu" + "Son deneme 5 Eki." · "Elif Şahin" · "Kerem Aydın" · "Mert Yıldız" · "Zeynep Kaya".
   - Son deneme tarihi yalnız verisi olanda yazılır.
2. **Dikkat gerektirenler**
   - Boş kart (padding 16):
     - 15/24 · 600: "Şu an dikkat gerektiren öğrenci yok."
     - 13/20, #556173: "14 gündür deneme okutmayan ya da son iki denemesinde neti düşen öğrenci burada görünür."
3. **Yaklaşan görüşmeler**
   - Kart içinde MeetingRow:
     - Tarih bloğu (44 pt genişlik): gün `metric-md` 24/32 · 700 ("12"), ay 13/20 · 600 #556173 ("Eki.").
     - Avatar 36.
     - "Alparslan Kuloğlu" / "Pazartesi 16:00 · Öğrenci" ›
     - "15 / Eki." "Elif Şahin" / "Perşembe 19:30 · Veli" ›
   - aria: "Alparslan Kuloğlu, 12 Ekim 2026 Pazartesi, 16:00, Öğrenci görüşmesi".

BottomBar: koç seti, aktif sekme Anasayfa.

**Kare 2: Dikkat gerektirenler örneği**
- AttentionRow (`.rw`, `align-items: flex-start`):
  - Avatar 40 ve sağ altında (−4/−4) kural rozeti: 22 pt daire, zemin #FCF1D9, ikon #8A5A00, 2 px beyaz halka, ikon 14 (çizgi 24).
  - Ad (16/24 · 600), kural cümlesi (15/24, margin-top 2), kanıt satırı (13/20).
- Satır 1 [Clock]: "Alparslan Kuloğlu" / "45 gündür deneme okutmadı" / "Son deneme 17 Haz. 2026 · TYT"
- Satır 2 [TrendDown]: "Alparslan Kuloğlu" / "Son iki TYT denemesinde net düştü" / "68 → 66,75 · 17 Haz. ve 4 Ağu."
- Bu iki satır iki ayrı günün görünümüdür (1 ve 5 Ağustos). Bugünkü Ek C verisinde kural tetiklenmiyor (varsayım 9.1).
- aria: "Alparslan Kuloğlu, 45 gündür deneme okutmadı, son deneme 17 Haziran".

**Kare 3: Öğrencisi yok**
- Bandın alt satırı: "Henüz öğrencin yok".
- İçerik top 190, aralık 16:
  - Üç avatar 72 (av-1, av-4, av-3), −16 üst üste bindirme, her birinde 4 px #F2F4F7 halka.
  - "İlk öğrencini ekle" (20/28, margin-top 20).
  - "Öğrencin koçluk kodunla kendi hesabından bağlanabilir ya da hesabını sen açabilirsin." (15/24, #556173, margin-top 6).
  - `.bp` [Plus] "Öğrenci Ekle".
  - CodeCard:
    - Kart padding 16, inset 1 px #DCE2E9.
    - "Koçluk kodun" (13/20 · 600, #556173).
    - "MOZK-4821" (24/32 · 700, harf aralığı 1).
    - "Öğrencin bu kodu Hesap › Koçluk'a girince sana bağlanır." (13/20, #556173, margin-top 4).
    - İki `.bo` 44 pt düğme, eşit ağırlık, aralık 8, margin-top 12: [Copy] "Kopyala" ve [ShareNetwork] "Paylaş".

**Kare 4: İskelet**
- Bant hemen gelir.
- Bloklar: 140 × 24 başlık; üç `.stt` (48 pt daire + 70 × 14 çubuk); 190 × 24 başlık; 88 pt kart; 180 × 24 başlık; 128 pt kart. Aralık 14.
- Bölüm hataları kendi yerinde gösterilir (3.2 kalıbı). Metinleri belirtilmemiş.

**Kurallar (D-27)**
- Yalnız iki kural var:
  - 14 gün ve üzeri deneme okutmadı: "N gündür deneme okutmadı" + son deneme tarihi.
  - Aynı sınav türünde son iki denemede net düştü: "Son iki TYT denemesinde net düştü" + iki net ve tarihleri.
- Hedef, ödev tamamlama, giriş sıklığı gösterilmez (D-3).
- Hesaplama sunucuda, her gece ve her deneme okununca yapılır: `last_exam_at ≤ now − 14 gün`. Her satır kanıt alanlarıyla gelir.

**Gezinme**
- Öğrenci karosu ve dikkat satırı → 10.4.
- Görüşme satırı → görüşme detayı (10.5 kare 3).
- "Öğrenci Ekle" → 10.3 sheet'i.
- Kopyala → toast "Kod kopyalandı."
- Paylaş → sistem paylaşımı.

**Veri ve backend**
- `/coach/getMyStudents` mevcut. `Student` modelinde `totalMexam` var; son deneme tarihi ve son net yok, eklenmeli.
- Dikkat listesi için yeni sunucu ucu gerekiyor.
- Görüşmeler: `/coach/getInterviews` (`filter.dates`, sayfalama).
- Bant sayaçları: öğrenci sayısı ve önümüzdeki 7 gündeki görüşme sayısı.

**Koyu tema:** çizilmemiş. Bant #0F294A; karolar ve kartlar #121D31; rozet #33270F / #F2C46D.

**Notlar**
- Turuncu yalnız alt çubukta, kamerada, sekme göstergesinde ve "bugün" noktasında.
- Eskiden koçun ilk ekranı öğrencininkinden farklı bir dille ve görevsiz bir panoyla açılıyordu (envanter §2.3).

---

### 10.2 · Öğrencilerim (4 kare)

**Kimlik**
- Sınıf: `StudentsScreen` (RootBand + SearchField + StudentRow).
- Route önerisi: `/coach/students` (koç kök sekmesi).

**Kare 1: Liste**
- RootBand "Öğrencilerim" + Plus ikon eylemi (aria "Öğrenci ekle"); bant 134 pt.
- SearchField top 150, placeholder "Öğrenci ara".
- Sayaç top 210: "5 öğrenci" (13/20 · 600, #556173, left 20).
- Kart top 238. StudentRow (avatar 40, ad, `sınıf · alan`, verisi olanda deneme sayısı):
  - "Alparslan Kuloğlu" / "12. Sınıf · Eşit Ağırlık · 10 deneme" — sağda "67,5" (17/24 · 700) ve "son net" (13/20)
  - "Elif Şahin" / "11. Sınıf · Sayısal"
  - "Kerem Aydın" / "Mezun · Sözel"
  - "Mert Yıldız" / "10. Sınıf" (10. sınıfta alan yok)
  - "Zeynep Kaya" / "12. Sınıf · Eşit Ağırlık"
- Sıralama alfabetik, Türkçe karşılaştırma.

**Kare 2: Arama**
- Sorgu "aydin" → "1 öğrenci" → "Kerem **Aydın**" (`.mk` vurgusu), "Mezun · Sözel".
- "AYDIN" ve "aydın" da aynı sonucu verir. Temizle düğmesi görünür.

**Kare 3: Sonuç yok**
- Kart top 214, padding 24 16 12, ortalı:
  - 16/24 · 700: "“selin” ile eşleşen öğrenci yok"
  - 13/20, #556173: "Ad ve soyadda arar; büyük-küçük harf ve I/ı/İ/i farkı gözetmez."
  - `.bt` "Aramayı Temizle"

**Kare 4: Öğrenci yok**
- İçerik top 200, yatay 24:
  - Üç avatar.
  - "Henüz öğrencin yok" (20/28, margin-top 24).
  - "Öğrencinin hesabını sen aç ya da koçluk kodunu paylaş; bağlanan öğrenciler burada listelenir." (15/24, margin-top 8).
  - Düğmeler (aralık 12, margin-top 24): `.bp` [Plus] "Öğrenci Ekle" ve `.bo` [ShareNetwork] "Kodunu Paylaş".

**Gezinme**
- Satır → 10.4.
- Plus ve "Öğrenci Ekle" → 10.3.
- "Kodunu Paylaş" → sistem paylaşımı.

**Veri:** `/coach/getMyStudents`. Gereken alanlar: ad, soyad, avatar, sınıf, alan, deneme sayısı, son net.

**Durumlar:** yükleme ve hata çizilmemiş; 1.22 kalıbı uygulanır.

**Koyu tema:** çizilmemiş.

**Notlar**
- Arama vurgusu özgün metnin aralığında yapılır.
- Eskiden Türkçe harflerde (I/ı/İ/i) arama eşleşmiyordu; satırda son net ve deneme sayısı yoktu.

---

### 10.3 · Öğrenci Ekle (3 kare)

**Kimlik**
- Sınıflar: `AddStudentSheet` ve `CredentialsSheet`.
- Uzun BottomSheet; route değil (deep link önerisi: `/coach/students/new`). Arkada 10.2 listesi durur.

**Kare 1: Form**
- Sheet top 90.
- Başlık "Öğrenci ekle", alt başlık "Hesabını sen aç ya da kodunu paylaş.", Kapat.
- İçerik padding 12 24 0, satırlar arası 16:
  - İki sütun (aralık 12): "Ad" = "Zeynep", "Soyad" = "Kaya".
  - "Kullanıcı adı" = "zeynep.kaya" + `.s2` "Kontrol Et" (48 pt, aralık 8). Sonuç `.ok`: "Bu kullanıcı adı boşta."
  - "Şifre" (maskeli, Eye düğmeli) + `.s2` "Oluştur" (48 pt). Yardım: "Öğrencine ilet; ilk girişte değiştirmesi önerilir."
  - İki sütun SelectField: "Sınıf" = "12. Sınıf", "Alan" = "Eşit Ağırlık".
  - `.bp` "Öğrenciyi Kaydet".
- Ayraç bölümü (padding 20 24 0): iki çizgi arasında "ya da" (13/20 · 600, #556173).
- 16/24 · 600, margin 16 0 8: "Öğrencin kendi hesabıyla bağlansın".
- CodeCard (10.1'deki ile aynı).
- Alt boşluk 42.

**Kare 2: Kod kartı (sheet kaydırılmış)**
- Sheet top 300. Sınıf/Alan, "Öğrenciyi Kaydet", "ya da" ve CodeCard görünür.
- Kopyala ve Paylaş eşit ağırlıkta.

**Kare 3: Eklendi (CredentialsSheet)**
- Başlık "Zeynep Kaya eklendi", alt başlık "Giriş bilgilerini öğrencine ilet.", Kapat.
- İçerik padding 16 24 0, aralık 16:
  - "Kullanıcı adı" = "zeynep.kaya"
  - "Şifre" maskeli + Eye
  - Yardım: "Bu ekranı kapatınca şifre yeniden gösterilmez."
- Düğmeler: `.bp` [ShareNetwork] "Bilgileri Paylaş" ve `.bq` "Tamam".
- Tamam → listeye dönülür, toast "Zeynep Kaya eklendi."

**Alan kuralları**
- Ad ve Soyad ayrı alanlar (soyadla sıralama yapılabilsin diye).
- Kullanıcı adı: "Kontrol Et" ya da yazmadan 400 ms sonra canlı kontrol. Sonuç 1.12 dilinde.
  - Kural: harf, rakam, nokta ve alt çizgi; küçük harfe çevrilir (varsayım 7.4).
  - "Alınmış" hata metni bu panoda belirtilmemiş. 2.5'te: "Kullanıcı adı alınmış: boşta olan öneri tek dokunuşla yazılır".
- Şifre: "Oluştur" 10 karakterlik okunur şifre üretir; karışan harfler (I, l, 0, O) kullanılmaz. Göster/gizle var.
- Sınıf ve Alan: 9.–10. sınıfta Alan pasif.
- "Öğrenciyi Kaydet" zorunlu alanlar dolunca çalışır; hata alanın altında gösterilir.
- Kayıt sonrası öğrenci koça bağlı gelir; öğrencinin ilk girişinde 2.3 kullanılır.
- Kod kartındaki Kopyala → toast "Kod kopyalandı."
- Gönderim sırasında 1.20 meşgul durumu uygulanır.

**Backend**
- `/ajax/checkUsername?name=`
- `/coach/addNewStudent`
- Kod paylaşımı: sistem paylaşım sheet'i.

**Koyu tema:** çizilmemiş. Sheet #18263D; `.ok` #52CC8E.

**Notlar**
- Şifreyi bir kez göstermek, ekran görüntüsüyle dolaşan şifreyi azaltır.
- Eskiden hesap açma ve kodla bağlanma ayrı yerlerdeydi; mevcut `add_student_dialog.dart` bu sheet ile değişmeli.

---

### 10.4 · Öğrenci Profili, koç bağlamında (4 kare)

**Kimlik**
- Sınıf: `StudentProfileScreen` (ContextStrip + TabBar: Analiz / Denemeler / Program). Öğrenci ekranları `StudentScope(coachView: true)` ile sarılır.
- Route önerisi:
  - `/coach/students/:studentId?tab=analysis|exams|program`
  - Deneme detayı: `/coach/students/:studentId/exams/:examId` (5.3–5.7 aynen yeniden kullanılır).

**Ortak üst kısım**
- DetailBar: geri ve BarAction `.s2` [CalendarBlank 18] "Görüşme Planla".
- ContextStrip (top 102): av-1 24, "Alparslan Kuloğlu'nun verileri", sağda "12. Sınıf · EA".
- Başlık (top 154): "Alparslan Kuloğlu" (24/32). Meta: "alparslan.k · 10 deneme · son 5 Eki. 2026".
- InScreenTabs `.tabs3` (top 214, 48 pt, alt inset 1 px #DCE2E9):
  - "Analiz" · "Denemeler" · "Program".
  - Metin 15/24 · 600 #556173; seçili sekme 700, #1B2232.
  - Gösterge 3 pt, #E05500, metin genişliğinde (52 / 84 / 70).
  - `tablist`; seçili sekme ekran okuyucuya bildirilir.

**Kare 1: Analiz (6.1'in aynısı)**
- Süzgeç çipi `.ch` "TYT · Genel" + CaretDown 18. Sağda "6 deneme".
- Grafik kartı (top 330, padding 16):
  - "Net gelişimi" (17/24) ve "Son 6 deneme".
  - NetChart 338 × 200:
    - Izgara 1 px #DCE2E9.
    - Y ekseni 0–120 (120 · 90 · 60 · 30 · 0), 13 pt #556173.
    - Çizgi #264066, 2,5 pt; alan %10.
    - Noktalar r 4,5, beyaz dolgu, 2 pt #264066 çizgi.
    - Son nokta r 7, #E05500, 2,5 pt beyaz çizgi.
    - X etiketleri: 22 Nis. · 17 Haz. · 15 Eyl. · 28 Eyl.
    - aria: "TYT net grafiği: 22 Nisan 61,5 netten 28 Eylül 74,75 nete, 6 deneme".
- StatBox ızgarası (2×2, aralık 8, top 618). Kutu: zemin #FFFFFF, köşe 16, padding 16. Değer 24/32 · 700 · −0,4; etiket 13/20 · 600.
  - "6" — "Çözülen deneme"
  - "67,79" — "Ortalama net" — [ArrowUp 14] "+3,25 son denemede" (#36537C)
  - "381,40" — "Ortalama puan"
  - "182.430" — "Ortalama sıralama"

**Kare 2: Denemeler (6.2 satırları)**
- Üstte "10 deneme · en yeni önce".
- ExamRow `.tr`:
  - min-height 72, padding 12 16.
  - Kapak 40 × 54, köşe 6, #DCE2E9.
  - Ad; `.tg` tür etiketi; tarih ve yayınevi.
  - Küçük D/Y/B: 16 pt daire, çipte ✓ ✕ –. Renkler #0B6E3E / #D8333A / #7E8A9B.
  - Sağda net 24/32 · 700 ve "net".
- Satırlar:
  - "Türkiye Geneli Deneme 6" · AYT · 5 Eki. 2026 · Örnek Yayınları · 86 D 74 Y 0 B · 67,5
  - "TYT Genel Deneme 9" · TYT · 28 Eyl. 2026 · 80 D 21 Y 19 B · 74,75
  - "AYT denemesi" · AYT · 21 Eyl. 2026 · 59,25
  - "TYT denemesi" · TYT · 15 Eyl. 2026 · 71,5
  - "TYT denemesi" · TYT · 4 Ağu. 2026 · 66,75
- Favori yıldızı yok (öğrencinin cihazına özel, D-25).
- Satır → Deneme Detay.

**Kare 3: Program (3.4 gün görünümü, salt okunur)**
- "Ekim 2. Hafta" (17/24) / "Her gün biraz daha · 5–11 Ekim 2026".
- DayChip `.dc` 48 × 64, köşe 12:
  - Gün adı 13/20 · 600, rakam 17/24 · 700.
  - Günler: Pzt 5 · Sal 6 · Çar 7 · Per 8 · Cum 9 · **Cmt 10** · Paz 11.
  - Seçili gün: zemin #0F294A, metin #FFFFFF, gün adı #C5D4E8, bugün noktası 6 pt #FF6600. aria "10 Ekim, bugün".
- ProgramItemRow (her biri ders glif karosuyla, karo 36 pt köşe 12):
  - "10:00" [TextAa, #F6ECE6/#93573C] "Türkçe" / "Fiilde Çatı"
  - "14:00" [Bank, #FBF1DA/#8C6106] "Tarih" / "Kurtuluş Savaşı Hazırlık Dönemi"
  - "20:00" [Globe, #E1EFFA/#1E6FAE] "Coğrafya" / "İklim Bilgisi"
- InfoBox: "Programı Alparslan düzenler; sen görüntülersin."
- "Günü Sıfırla" ve "Düzenle" yok.

**Kare 4: Deneme Detay (5.3 aynen)**
- ContextStrip barın altına girer; içerik 40 pt aşağı kayar. Bu karede bar eylemi yok.
- Başlık bölümü:
  - Kapak 48 × 64 ve Image ikonu.
  - "Örnek Yayınları" / "Türkiye Geneli Deneme 6" (20/28) / AYT etiketi · "5 Ekim 2026".
- Net: "67,5" 40/48 · 800 · −1 ve "net".
- D/Y/B büyük: "Doğru 86", "Yanlış 74", "Boş 0".
- Puan kartı: "Eşit Ağırlık" — "412,63" "Yerleştirme puanı" — "48.215." "Sıra".
- Sekmeler: Genel / Sorular / Konular / Kartlar.
- Test satırları (StackedBar 12 pt, segmentler arası 2):
  - "Türk Dili ve Edebiyatı–Sosyal Bilimler 1" 18,75 net · 23 D 17 Y 0 B · 40 soru
  - "Sosyal Bilimler 2" 11,25 net · 17 D 23 Y 0 B · 40 soru

**Taşıma kuralı**
- Eşlemeler: 6.1 → Analiz, 6.2 → Denemeler, 3.4 → Program, 5.3–5.7 → deneme ve soru detayı.
- Koç görünümündeki farklar yalnız bunlar:
  - bağlam şeridi;
  - düzenleme eylemlerinin olmaması;
  - öğrenciye özel öğelerin gizlenmesi (favori, kart "Öğrendim", Günü Sıfırla).

**Gezinme**
- "Görüşme Planla" → yeni görüşme sheet'i (10.5 kare 2), öğrenci seçili açılır.
- Kamera koçta da var: okutulan form seçilen öğrenciye yazılır (öğrenci seçim sheet'i, Tur 2 akışının başı). Bu sheet burada çizilmemiş.

**Backend:** öğrenci uçları (`/student/getLineChartData`, `getMyMockExams`, `getMyWeeklies`, `getMexamItemDetail` vb.) koç adına `studentId` parametresiyle çağrılmalı. Mevcut uçların bunu destekleyip desteklemediği belirtilmemiş.

**Koyu tema:** çizilmemiş.
- ContextStrip #1A2B45.
- Sekme göstergesi #FF8533.
- Grafik çizgisi #9BB3D3, alan %14, son nokta #FF8533, ızgara #26354D.
- Delta #9BB3D3.
- D/Y/B: #52CC8E / #F07575 / #6E7C92; glifler #0A1424.
- Ders renkleri koyu: Türkçe #2D211C / #E2A98D; Tarih #2C2513 / #E3B651; Coğrafya #12293C / #7DB9EC.

**Notlar**
- Alan kısaltması yalnız "EA" için örneklenmiş. Sayısal, Sözel, Dil kısaltmaları belirtilmemiş.
- Ekran okuyucu: "Alparslan Kuloğlu'nun verileri, 12. sınıf, Eşit Ağırlık".

---

### 10.5 · Görüşmelerim (4 kare)

**Kimlik**
- Sınıflar: `MeetingsScreen`, `NewMeetingSheet`, `MeetingDetailScreen`.
- Route önerisi: `/coach/meetings` (koç kök sekmesi), `/coach/meetings/:meetingId`. Sheet: `/coach/meetings/new`.

**Kare 1: Liste**
- RootBand "Görüşmelerim" + Plus (aria "Yeni görüşme").
- SearchField "Görüşme ara" (top 150). Öğrenci adında arar, 10.2 ile aynı Türkçe katlama.
- Süzgeç (radiogroup "Kiminle", top 210, aralık 8, hap çipler, tek seçim): "Tümü" (seçili) · "Öğrenci" · "Veli".
- Bölüm başlığı "Yaklaşan · 2" (top 266).
- MeetingRow (avatar 40):
  - "Alparslan Kuloğlu" / "12 Ekim 2026 Pazartesi · 16:00" + `.tg` "Öğrenci" ›
  - "Elif Şahin" / "15 Ekim 2026 Perşembe · 19:30" + `.tg` "Veli" ›
- Geçmiş görüşmeler ayrı başlık altında, en yeni önce. O başlığın metni belirtilmemiş.

**Kare 2: Yeni görüşme sheet'i**
- Başlık "Yeni görüşme", Kapat. İçerik padding 12 24 0, aralık 16.
- "Öğrenci": SelectField (avatar 28 + "Alparslan Kuloğlu" + CaretDown). Alttan öğrenci listesi açar.
- "Kiminle": Segment "Öğrenci" (seçili) / "Veli".
- İki sütun (1,4fr / 1fr, aralık 12): "Tarih" = "12 Ekim 2026 Pzt", "Saat" = "16:00". Seçiciler çizilmemiş; TimeWheel ya da Calendar kullanılabilir (belirtilmemiş).
- "Not (isteğe bağlı)": "(isteğe bağlı)" kısmı 500 ağırlık, #556173. TextArea min-height 88, placeholder "Örn: Deneme sonucunu birlikte inceleyeceğiz."
- `.bp` "Görüşmeyi Kaydet". Pasiflik kuralı belirtilmemiş.

**Kare 3: Görüşme detayı**
- DetailBar: geri ve `.s2` [PencilSimple] "Düzenle".
- Başlık (top 110, aralık 20): avatar 56 + "Alparslan Kuloğlu" (24/32) + "Öğrenci görüşmesi".
- Kart:
  - [CalendarBlank 24] "12 Ekim 2026 Pazartesi" / "16:00" (min-height 56, dokunulamaz).
  - [ChartLine 24] "Öğrencinin verileri" / "Analiz, denemeler, program" › → 10.4.
- "Notlar" (20/28) + `.bt` [Plus] "Not Ekle".
- Not kartı (padding 16):
  - "Tarih eksikleri için haftada 3 saat ayrıldı." (16/26)
  - `.bt` [PencilSimple] "Düzenle" ve `.bt.dn` [Trash] "Sil" (40 pt, aralık 4).

**Kare 4: Görüşme yok**
- Kil "Hokka" görseli, M 128 pt (1.25; webp gömülü, süs öğesi, alt metni boş).
- "Henüz görüşme yok" / "Öğrencinle ya da velisiyle görüşme planladığında burada listelenir."
- `.bp` [Plus] "Yeni Görüşme".

**Davranış**
- Kaydedince listeye dönülür, toast "Görüşme kaydedildi."
- Öğrenciye "Görüşme planlandı" bildirimi gider (9.6).
- Görüşmeden 1 saat önce koça bildirim (koçun tercihine bağlı).
- Görüşmeyi düzenleme ve silme akışı çizilmemiş.

**Backend**
- `/coach/getInterviews` (`filter.types`, `filter.dates`, `page`, `limit`).
- `/coach/addNewInterview`.
- Mevcut kodda `type == 1` → Öğrenci, aksi Veli.

**Koyu tema:** çizilmemiş.

**Notlar**
- Eskiden tarihlerde yıl yazmıyordu; arama ve süzgeç yoktu.
- Veli görüşmesinde detay alt satırı belirtilmemiş; mevcut kodda 'Veli Görüşmesi'.

---

### 10.6 · Görüşme Notları (4 kare)

**Kimlik**
- Sınıf: `NoteSheet` (ekleme ve düzenleme). Görüşme detayının üstünde modal; route değil.

**Kare 1: Not ekle**
- Başlık "Not ekle", alt başlık "12 Ekim 2026 · Alparslan Kuloğlu", Kapat.
- TextArea odakta (kenar #1A3357, imleç 2 × 20 #1A3357), placeholder "Örn: Deneme sonucunu birlikte inceleyeceğiz."
- Sağ altta sayaç "0/500" (`.hp`, sağa yaslı).
- `.bp.off` "Notu Kaydet" (`aria-disabled`). Metin yokken pasif.

**Kare 2: Notu düzenle**
- Başlık "Notu düzenle" (alt başlık yok).
- Metin dolu: "Tarih eksikleri için haftada 3 saat ayrıldı." Sayaç "44/500".
- `.bp` "Kaydet". Yalnız değişiklik varsa çalışır.

**Kare 3: Not silme onayı**
- Tehlikeli ConfirmSheet. Eylem alanı padding-top 24.
- Başlık: "Not silinsin mi?"
- Gövde: "“Tarih eksikleri için haftada 3 saat ayrıldı.” notu silinecek."
- Düğmeler: "Notu Sil" (`.bdg`) ve "Vazgeç" (`.bq.fr`); odak Vazgeç'te.

**Kare 4: Silindi**
- Notlar kartı: "Henüz not yok." (15/24, #556173).
- Toast: "Not silindi." + "Geri Al" (6 sn, D-31; `z-index` 6).
- 6 sn içinde geri alınabilir; sonra silme kalıcı olur.

**Davranış**
- Notlar yalnız koça görünür (varsayım 9.7).
- Kaydetme hatası: sheet açık kalır, metin korunur, toast gösterilir (metni belirtilmemiş).

**Backend**
- `/coach/addNewNote`, `/coach/editNote`, `/coach/deleteNote`.
- Geri Al için iki yol var: silme isteği 6 sn bekletilir ya da geri alınca yeniden oluşturulur. Hangisi olacağı belirtilmemiş.

**Koyu tema:** çizilmemiş. Toast ters yüzeyde (#E8ECF1); "Geri Al" #1A3357, solunda ayraç.

**Notlar**
- Not koçun çalışma kaydıdır; yanlışlıkla silmeye karşı onay ve geri alma ile iki kez korunur.
- Eskiden not silme onaysızdı.

---

## 4. Rol farkları

| Konu | Öğrenci | Koç |
|---|---|---|
| Alt çubuk | Anasayfa · Analizlerim · Okut · Derslerim · Hesap | Anasayfa · Öğrencilerim · Okut · Görüşmelerim · Hesap (D-29) |
| Hesap: ProfileSummary | sınıf · alan, "Koçun: …" | "Öğrenci koçu", "Koçluk kodun: …" |
| Koçluk grubu | 9.5 ekranına gider | kod + Kopyala/Paylaş, ekrana gitmez |
| Profil | Sınıf ve Alan var | Sınıf ve Alan yok |
| 9.5 Koçluk | var | yok |
| Bildirim kategorileri | 4 kategori çizili | çizilmemiş; görüşmeden 1 saat önce hatırlatma var |
| Kamera | kendi hesabına | öğrenci seçilir, sonuç onun hesabına |
| Öğrenci verisi | düzenleyebilir | salt okunur + ContextStrip; favori, "Öğrendim", Günü Sıfırla gizli |
| Görüşme notları | göremez | yalnız koç görür |

---

## 5. Hareket ve haptik (11.15, bu grupla ilgili satırlar)

| Etkileşim | Süre / eğri | Haptik | Hareketi azalt |
|---|---|---|---|
| Düğme basılı | 100 ms | — | — |
| Segment, sekme, alt çubuk | 250 ms, standard Cubic(0.2,0,0,1) | `selectionClick` | opaklık 150 ms |
| Çip, anahtar, onay kutusu, radyo | 150 ms | `selectionClick` | — |
| Sheet | açılış 350 ms enter, kapanış 250 ms exit | — | opaklık 150 ms |
| Toast | 250 ms; 4 sn ya da Geri Al ile 6 sn | hata türünde `error` | opaklık |
| Bant küçülmesi | kaydırmaya bağlı (56 pt), linear | — | — |
| İskelet | 1200 ms döngü; 15 sn sonra hata | — | durağan gri |
| Form hatası | 150 ms kenar | `error` | sallanma yok |
| Sayfa geçişi | 350 ms, platform | — | opaklık |
| Hesabı Sil | tam ekran spinner, geri kapalı, linear | yok (9.4 kare 5) | — |

---

## 6. Tutarsızlıklar ve belirtilmemiş noktalar

1. **9.1 koç, Profil satırının alt metni** öğrencideki gibi "Ad, e-posta, telefon, sınıf ve alan" çizilmiş. Oysa koçun profilinde Sınıf ve Alan yok (9.2 notu, varsayım 8.10).
2. **9.1 koç** karesinde Bildirimler satırının alt metni öğrenciyle aynı; Destek, Çıkış ve sürüm çizilmemiş.
3. **9.6** "Koçun deneme ya da ödev atadı" kategorisi var, ama varsayım 9.6'ya göre koçun atama ve düzenleme yetkisi v1'de yok.
4. **Görüşme tarihinin ayırıcısı** iki ekranda farklı: 9.5'te "12 Ekim 2026 Pazartesi, 16:00" (virgül), 10.5'te "… · 16:00" (orta nokta).
5. **10.2 satır yüksekliği:** not "Satır 72 pt" diyor; CSS `.rw` min-height 64, içerikle ~68 pt.
6. **CodeCard kod stili:** CSS 24/32 · 700, harf aralığı 1. Tur 9 G6 "24/800" diyor. 11.12 `metric-md` 24/32 · 700 · −0,4.
7. **Kaydırılmış DetailBar başlığı:** 1.18 kare 5 "15/20 600, ortalı, iki satır, alt ayraç" der. 9.4 ve 9.7'de 17/24 · 700, sola yaslı ve ayraçsız çizilmiş.
8. **Toast ikonu:** 1.22 "ikon durum renginde" der; 9.3'teki "Şifren güncellendi." toast'u ikonsuz çizilmiş.
9. **Uzun sheet üst boşluğu:** 1.20 "güvenli alan + 8" (≈70) der; 10.3 panosunda sheet top 90.
10. **Çizilmemiş ekran ve durumlar:**
    - Alan sheet'i, e-posta doğrulama ekranı, profil "Vazgeç" onayının gövde ve düğmeleri, pasif Kaydet görünümü.
    - Koçu olmayan öğrencide 9.1 metinleri.
    - Bitiş saati sheet başlığı; görüşme tarih ve saat seçicileri; görüşme düzenleme ve silme.
    - Geçmiş görüşmeler başlığı.
    - Koç bildirim kategorileri; koç için Hesabı Sil.
    - Bölüm hata metinleri; koyu toast "Geri Al" dışındaki koyu varyantlar.
    - Alan kısaltmaları (yalnız EA örneklenmiş).
11. **Hesabı Sil hata metni** ("Hesabın silinemedi…") toast mı satır içi mi olacak, belirtilmemiş.
12. **Örnek değerler** sunucudan ya da derlemeden okunacak: sürüm "3.0.0 (300)", sözleşme sürümleri ve tarihleri, "zeynep.kaya", "MOZK-4821".
13. **Mevcut kod:** `ProfileRepository.deleteCoach` `queryParams`'ı isteğe eklemiyor.
14. **Eksik backend uçları:** şifre değiştirme, bildirim tercihleri ve dikkat listesi için mevcut kodda uç yok.