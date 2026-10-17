# Ekran Grubu A: yolculuklar, açılış ve giriş, Anasayfa ve Programım, kamera (SMAP-00 · 02 · 03 · 04 · 11.14)

Bu kılavuz tasarım panolarından çıkarıldı. Kaynaklar her panonun `text.txt` ve `board.html` dosyaları; inline style ve sınıf kütüphanesi tek tek okundu. İkon adları SVG path imzalarından tespit edildi ve Phosphor adlarıyla yazıldı (stroke ikonlar, viewBox 256). Tüm ölçüler pt. Telefon karesi 402×874. Panoda değeri olmayan her şey **"belirtilmemiş"** olarak işaretli. Hiçbir dosya değiştirilmedi.

---

## 0. Ortak sözlük (bu gruptaki panoların CSS'inden)

**Kanvas ve metin**
- Açık tema: kanvas `#F2F4F7`, metin `#1B2232`, ikincil metin (`.mu`) `#556173`.
- Koyu tema: kanvas `#0A1424`, metin `#EDF1F6`, ikincil metin `#A9B5C6`.
- Kamera aşaması (`.cm`): zemin `#000000`, metin `#FFFFFF`.

**Tipografi** (Plus Jakarta Sans, `tabular-nums`)

| Ad | Boyut | Ağırlık | Harf aralığı |
|---|---|---|---|
| `display` (`.ot`) | 32/40 | 800 | -0.5 |
| `t24` | 24/32 | 700 | -0.3 |
| `t20` | 20/28 | 700 | -0.2 |
| `t17` | 17/24 | 700 | -0.1 |
| `b16` | 16/24 | — | — |
| `b15` | 15/24 | — | — |
| `c13` | 13/20 | — | — |
| `metric-lg` (`.nv`) | 40/48 | 800 | -1 |
| HomeBand sayacı (`.cdn`) | 40/48 | 800 | -1 |

**Button (1.9).** Hepsi 48 yükseklik, radius 12, 16/24 600.
- **primary** (`.bp`): `#0F294A` zemin, `#FFFFFF` metin. Koyu: `#C5D4E8` zemin, `#091A31` metin. Pasif: `#DCE2E9` / `#9AA5B4`; koyu pasif `#213049` / `#56657C`.
- **outline** (`.bo`): `#FFFFFF` zemin, `#0F294A` metin, inset 1.5 `#0F294A`. Koyu ve kamera: transparent zemin, `#C5D4E8` metin ve çerçeve. Pasif (4.7): metin `#9AA5B4`, çerçeve `#C3CBD6`.
- **quiet** (`.bq`): `#E8ECF1` / `#1B2232`. Koyu: `#213049` / `#EDF1F6`.
- **text** (`.bt`): padding 0 12, renk `#1A3357`. Koyu: `#9BB3D3`.
- **danger** (`.bdg`): `#C42D35` / `#FFFFFF`. Koyu: `#FF8F8F` / `#3B0A10`.
- **danger text** (`.bt.dn`): renk `#C42D35`, koyu `#FF8F8F`.
- **BarAction** (`.s2`): 40 yükseklik, padding 0 14, radius 12, `#FFFFFF` zemin, `#0F294A` metin, inset 1.5, 14/20 600. Pasif: `#DCE2E9` / `#9AA5B4`, çerçeve yok.
- **Odak halkası** (`.fr`): `0 0 0 2 #FFFFFF, 0 0 0 4 #36537C`. Koyu: `#18263D` / `#9BB3D3`.
- **Spinner (button içi)**: 20, iz `rgba(255,255,255,.3)`, yay `#FFFFFF`, stroke 3.
- mihr_ui'de yalnız button ve tema var. Eşleme önerisi (doğrulanmalı): primary → `MihrPrimaryButton`, outline → `MihrSecondaryButton`, quiet → `MihrTertiaryButton` / `MihrSoftPrimaryButton`, text → `MihrLinkButton`, danger → `MihrDestructiveButton`. BottomBar bulanıklığı için `FrostedContainer`.

**IconButton**
- `.ib`: 48×48, radius 12.
- `.ibc` (kamera üstü): 40 daire, `rgba(10,20,36,0.64)` zemin, `#FFFFFF` ikon.
- `.xi` (sheet kapat): 36 daire, `#E8ECF1` / `#1B2232`. Koyu: `#213049` / `#EDF1F6`.

**TextField (1.12)**
- Etiket (`.fl`): 14/20 600, alt boşluk 8.
- Alan (`.in`): 48 yükseklik, padding 0 16, radius 12, kenarlık 1 `#697586`, zemin `#FFFFFF`, metin 16/24.
- Placeholder: `#697586`. İmleç: 2×22 `#1A3357`.
- Odak (`.fo`): kenarlık `#1A3357` + inset 1 (toplam 2 pt).
- Hata: `.fe` kenarlık `#C42D35` + inset 1; ya da `.in.err` 2 pt `#C42D35` ve padding 0 15.
- Yardım (`.hp`): 13/20 `#556173`, üst boşluk 6.
- Hata satırı (`.er`): 13/20 600 `#C42D35`, aralık 6, üst boşluk 6, WarningCircle 16–18.
- Olumlu satır (`.ok`): 13/20 600 `#0B6E3E`.
- Şifre göster/gizle: sağda 48 IconButton, Eye 22, erişilebilir ad "Şifreyi göster" / "Şifreyi gizle".

**SelectField**: `.in` + CaretDown 20 (`.mu`). Pasif hâli: zemin `#F2F4F7`, kenarlık `#C3CBD6`, metin ve etiket `#9AA5B4`.

**CodeInput**: 6 kutu, her biri 48×56, radius 12, kenarlık 1 `#697586`, rakam 24/32 700, aralık 8.

**Segment (1.10)**
- Kap (`.seg`): padding 4, zemin `#E8ECF1`, radius 12, aralık 4.
- Düğme: min yükseklik 36, radius 8, 14/20 600 `#556173`. Seçili: `#0F294A` / `#FFFFFF`.
- Koyu: kap `#213049`; seçili `#C5D4E8` / `#091A31`.
- Sayaçlı (`.seg.cnt`): min yükseklik 48; üst satır `b` 14/20 700, alt satır `i` 13/20 500; seçili hâlde alt satır `#C5D4E8`.

**Chip (1.11)**
- Kare (`.sq`): 48×48 (2.2'de 56 genişlik, "Mezun" 88; 4.7'de "Boş" 64), radius 12, inset 1 `#697586`, 16/24 700. Seçili: `#0F294A`, çerçevesiz.
- Hap (`.ch`): 48 yükseklik, padding 0 18, radius 999, inset 1 `#697586`, 16/24 600. Seçili: `#0F294A`.
- Etiket (`.tg`): 24 yükseklik, padding 0 8, radius 8, `#E8ECF1` / `#1B2232`, 13/20 600. Koyu: `#213049` / `#EDF1F6`.
- EksikTag (`.ek`): 24 yükseklik, padding 0 8, radius 8, `#FCF1D9` / `#8A5A00`, 13/20 700, Flag 14 (sw 20). Koyu: `#33270F` / `#F2C46D`.

**RoleOption** (`.opt`): padding 16, radius 16, zemin `#FFFFFF`, inset 1 `#DCE2E9`, aralık 16. Seçili: inset 2 `#0F294A`.

**Radio** (`.rd`): 24, inset 2 `#697586`. Seçili: inset 7 `#0F294A`.

**Checkbox**
- Satır (`.cb`): min yükseklik 48, aralık 12, 15/24.
- Kutu (`.cbx`): 24, radius 4, inset 2 `#697586`. Koyu: `#6B7D97`.
- Seçili: `#0F294A` zemin, Check 16 (sw 28) beyaz. Hata: inset 2 `#C42D35`.

**InfoBox ve ErrorBox**
- InfoBox (`.inf`): `#E2EAF4` zemin, Info 20 `#36537C`.
- ErrorBox (`.al`): `#FCEAEA` zemin, WarningCircle 20 `#C42D35`.
- İkisi de: padding 12 14, radius 12, metin 15/22, aralık 10.

**Link** (`.lk`): `#1A3357` 700, altı çizili, offset 3.

**BottomSheet (1.20)**
- Kap: üst radius 24, zemin `#FFFFFF` (koyu `#18263D`).
- Tutamaç: 36×4, `#C3CBD6` (koyu `#34445F`), üst boşluk 8.
- Başlık bölgesi (`.shh`): padding 12 12 0 24. Alt bant (`.shf`): padding 16 24 42, aralık 12.
- Perde: `rgba(9,26,49,0.48)` + blur 8. Kamera üstünde: `rgba(2,6,14,0.64)`.

**ConfirmSheet (1.21)**
- 40'lık durum dairesi + `t20` başlık (üst boşluk 6) + `b15 mu` gövde (üst boşluk 12); alt bant üst boşluk 24.
- Normal hâl: eylemler primary + quiet.
- Tehlikeli hâl: daire `#FCEAEA` / `#C42D35`; eylemler danger + quiet; odak Vazgeç'te (`.fr`).

**Toast (1.22)**
- Min yükseklik 48, padding 12 16, radius 12, `#0F294A` zemin, `#FFFFFF` 15/24 metin.
- Gölge: `0 8 24 rgba(15,41,74,.16)`. Konum: sol/sağ 16, alttan 110.
- Eylem (ör. "Geri Al"): `#C5D4E8` 15/24 700, min yükseklik 48.

**Durum bileşenleri**
- OfflineStrip (`.off`): min yükseklik 40, padding 8 16, `#1B2232` zemin, `#FFFFFF` 13/20 600, aralık 10, WifiSlash 18.
- Skeleton (`.sk`): `#E8ECF1`, radius 8.

**BottomBar (1.19, öğrenci)**
- Kap: 102 yükseklik; zemin `rgba(255,255,255,.92)` + blur 20; üst radius 24; üst çizgi inset 1 `#DCE2E9`; satır yüksekliği 68.
- Öğe: 82.5 genişlik, üst padding 14, aralık 6, ikon 24, etiket 12/16.
- Aktif öğe: `#0F294A`, etiket 700, üstte 32×4 gösterge (radius 0 0 4 4) `#E05500`.
- Pasif öğe: `#556173`, etiket 600.
- Okut: 56×56, radius 16, `#FF6600` zemin, Camera 28 `#0F294A`; top -16; gölge `0 2 8 rgba(15,41,74,.08)`; etiket "Okut" 12/16 700 `#1B2232`, top 44. Erişilebilir ad: "Okut: deneme formunu kamerayla okut".
- Koyu: zemin `rgba(18,29,49,.92)`, çizgi `#26354D`, aktif `#EDF1F6`, gösterge `#FF8533`, pasif `#A9B5C6`, FAB gölgesi `rgba(0,0,0,.4)`.
- Sekmeler ve ikonlar: Anasayfa (House, dolgulu), Analizlerim (ChartLine), Okut (Camera), Derslerim (BookOpen), Hesap (UserCircle).

**DetailBar (1.18)**
- Geri: 48 IconButton, top 54, left 4, CaretLeft 24.
- Başlık içerikte: top 110, `t24` (2.x ekranlarında `display`).
- Kaydırınca: bar 102 yükseklik, zemin `#F2F4F7`, başlık `t17` bara iner.
- Sağdaki eylem: BarAction, top 58, right 16.

**Kenar boşluğu**: 2.x ekranları yatayda 24, 3.x ve 4.x ekranları 16. Alt düğmeler alttan 42.

**Ders renkleri ve glifleri (1.5).** GlyphTile `.gt` radius 12; satırda 36, karoda 40, ızgara bloğunda 14–20.

| Ders | Açık zemin / ön | Koyu zemin / ön | Glif |
|---|---|---|---|
| Türkçe | `#F6ECE6` / `#93573C` | `#2D211C` / `#E2A98D` | TextAa |
| Tarih | `#FBF1DA` / `#8C6106` | `#2C2513` / `#E3B651` | Bank |
| Coğrafya | `#E1EFFA` / `#1E6FAE` | `#12293C` / `#7DB9EC` | Globe |
| Fizik | `#DDF2F2` / `#08737A` | `#0E2B2D` / `#5FCBD0` | Atom |
| Biyoloji | `#E4F3E3` / `#2B7A35` | `#16291A` / `#80CC89` | Dna |
| Kimya | `#F7E8F7` / `#93359A` | `#271B33` / `#C89AE3` | Flask |
| Türk Dili ve Edebiyatı | `#F6E7EC` / `#8A2F4E` | `#301A27` / `#E494BE` | Feather |
| Matematik | `#FDE8E8` / `#C42A36` | `#341B1B` / `#F7847F` | MathOperations |
| Geometri | `#E7E9FB` / `#4450BE` | `#1D2144` / `#A3ABF4` | Angle |

**DybSmall (1.14)**
- Daire 16; ikon 10 (sw 32).
- Doğru: `#0B6E3E` + Check. Yanlış: `#D8333A` + X. Boş: `#7E8A9B` + Minus.
- Koyu: `#52CC8E` / `#F07575` / `#6E7C92`; koyuda ikon rengi `#0A1424`.
- Sayı 15/20 700; etiket 13 500 `#556173`; aralık 4 14. Erişilebilir grup adı: "86 doğru, 74 yanlış, 0 boş".

**Fark (delta)**: `.dg` `#36537C` (koyu `#9BB3D3`), 13/20 700, ArrowUp 14 (sw 24).

**Panolarda adı geçen token → hex karşılıkları**

| Token | Hex |
|---|---|
| navy-900 | `#0F294A` |
| navy-800 | `#1A3357` |
| navy-100 | `#E2EAF4` |
| orange-600 | `#E05500` |
| orange-500 | `#FF6600` |
| orange-400 | `#FF8533` |
| border-strong | `#C3CBD6` |
| text-disabled | `#9AA5B4` |
| info / info-bg | `#36537C` / `#E2EAF4` |
| error / error-bg | `#C42D35` / `#FCEAEA` |
| success / success-bg | `#0B6E3E` / `#E4F4EA` |
| warning / warning-bg | `#8A5A00` / `#FCF1D9` |
| bg-sunken | `#E8ECF1` (koyu `#213049`) |
| surface | `#FFFFFF` (koyu `#121D31`) |
| bg-canvas | `#F2F4F7` |
| ayraç | `#E8ECF1` (koyu `#26354D`) |
| koyu sheet | `#18263D` |

**Hareket token'ları** (panolarda geçen)
- standard / slow: 350 ms (sayfa ve sheet açılışı).
- exit: 250 ms (sheet kapanışı, geçişler).
- enter: 250 ms (öğe girişi).
- 150 ms: sallanma, kenar oturma, saydamlaşma. 100 ms: büyüteç, önizleme donması.
- loop: 1200 ms (iskelet parıltısı, çark).
- Toast 4 sn; Geri Al'lı toast 6 sn.
- Haptik: `selectionClick`, `mediumImpact`, `success`, `error`.
- Hareketi azalt açıkken: yalnız opaklık, sallanma yok, iskelet durağan.

---

## 1. Yolculuklar (SMAP-00)

**Lejant**

| Sınıf | Anlamı | Görünüm |
|---|---|---|
| k-def | Ekran (pano kodu) | Beyaz kutu, inset 1 `#C3CBD6` |
| k-tab | Kök sekme | `#0F294A` dolgu |
| k-cam | Kamera | Solda 5 pt `#FF6600` şerit |
| k-dec | Karar | `#FCF1D9` + 1.5 `#8A5A00` |
| k-sys | Sunucu | `#F2F4F7` |
| k-ext | Uygulama dışı ya da başka akış | `#F2F4F7` + 1.5 `#9AA5B4` |
| k-upd | Kendiliğinden güncellenir | — |

Kutular 300×104 ve radius 16. Oklar `#556173`, 1.75 pt; kesikli oklar `6 6`.

### 0.1 Uygulamanın Yolculuğu (Tur 10)

1. 2.1 Açılış ("Lacivert zemin, S-rota işareti")
2. 2.1 Tanıtım ("3 ekran: okut → analiz → eksikleri kapat")
3. 2.2 Rol ("Öğrenciyim ya da Öğrenci Koçuyum")
   - **Öğrenci** → 2.2 Sınıf ve alan ("Yalnız öğrenci; 9.–10. sınıfta alan yok") → 2.2 Kamera ön açıklaması
   - **Koç** → doğrudan 2.2 Kamera ön açıklaması ("İzin ver ya da Sonra")
4. 2.2 Hoş geldin ("Kayıt Ol ya da Giriş Yap")
   - **Kayıt Ol** → 2.5 · 2.6 Kayıt ("Rol, 7 avatar, kullanıcı adı, şifre, sınıf ve alan")
   - **Giriş Yap** → 2.3 Giriş ("Kullanıcı adı ve şifre; Apple ve Google varyantı") → 2.4 Şifremi Unuttum ("E-posta → 6 haneli kod → yeni şifre")
5. Kayıt ve Giriş, karar düğümü **Oturum**'a çıkar ("Rol hesaptan okunur · Öğrenci mi, koç mu?").
   - **Koç** → 10.1 Koç Anasayfa (k-ext, "Koçun yolculuğu: 0.3")
   - **Öğrenci** → "Alt çubuk · öğrenci" grubu
6. Kök sekmeler ve dalları:
   - 3.1 Anasayfa ("Bugün, Son denemen, Derslerin") → 3.4 Programım ("Liste, gün ve hafta görünümü") → 3.5 · 3.6 ("Günler → ızgara → ad ve motto; Günü Sıfırla")
   - 6.1 Analizlerim ("Genel · Denemelerim") → 6.2 Denemelerim → 5.3–5.6 Deneme Detay → 5.7 Soru Detay
   - 4.3 Okut (k-cam, "Kamera: denemenin yolculuğu 0.2") → 4.1–4.10 Çekim ve gönderim → 5.1 · 5.2 Sonuç anı; buradan **Detaylı Analiz** → 5.3–5.6
   - 7.1 Derslerim ("TYT/AYT, eksikler, kartlar") → 7.2 · 7.4 Ders detayı → 7.3 Konu detayı → 8.1 Kart destesi
   - 9.1 Hesap → 9.2–9.7 → 9.4 · 9.1 Hesabı Sil ya da Çıkış ("Onaylı; ardından Hoş geldin (2.2)")
7. 2.7 Genel ekranlar (k-ext, bağlantısız): "Zorunlu güncelleme, oturum sona erdi, bakım, bilinmeyen rol: her an".

### 0.2 Bir Denemenin Yolculuğu (Tur 10)

1. Kâğıt: Optik form (k-ext, "Deneme bitti; form elde")
2. 4.3 Okut (k-cam, "Alt çubuktaki kamera, her sekmede")
3. 4.1 Kamera izni ("Yalnız ilk sefer; reddedilirse Ayarlar")
4. 4.2 Öğretici ("Yalnız ilk sefer")
5. 4.3 Çekim ("Formu çerçeveye al, deklanşör")
   - Kısa yol: Okut → **Sonraki seferlerde** → doğrudan Çekim (4.1 ve 4.2 atlanır).
6. 4.4 Köşeler ("Dört köşe cevap alanına oturur")
7. 4.5 · 4.6 Gönderim ("Yükleniyor; bağlantı yoksa sırada")
8. Sunucu: Okuma ve net (k-sys, "Net = D − Y ÷ 4, sunucuda (D-1)")
9. 4.7 · 4.8 Form Kontrol ("Boş ve çift işaretleri düzelt; Cevapları Onayla")
10. Karar: "Deneme tanındı mı?"
    - **Evet** → 5.1 Sonuç anı ("Net, D/Y/B, fark, eklenen kartlar") → 5.2 Bildirim izni ("İlk başarılı okumada bir kez") → 5.3–5.6 Deneme Detay. Oradan 5.7 Soru Detay ("Hücreden; işaretin ve doğru cevap"), 7.3 Konu detayı ("Bu Konuyu Çalış; ilk eksik maddede"), 8.1 Kart destesi ("Kartları Çalış; Eksiklerim").
    - **Hayır** → 4.9 Deneme bulunamadı ("Listeden seç ya da talep gönder → Anasayfa")
11. 4.10 Hata ekranları (k-ext, bağlantısız): "Bakım, kamera açılamadı, form bulunamadı, bağlantı yok".
12. 5.1'den kesikli ok, "Okuma bitince kendiliğinden güncellenenler" (k-upd):
    - 3.1 Anasayfa ("Son denemen; Derslerin eksikleri")
    - 6.1 Analizlerim ("Grafikte yeni nokta, kutular")
    - 6.2 Denemelerim ("Listenin başında")
    - 7.1 Derslerim ("Eksik sayıları")
    - 10.1 Koç Anasayfa ("Dikkat kuralları yeniden hesaplanır")
    - 10.4 Öğrenci profili ("Koçun Denemeler sekmesi")

### 0.3 Koçun Yolculuğu (Tur 10)

1. 2.2 Rol: Öğrenci Koçuyum ("Sınıf ve alan sorulmaz")
2. 2.2 Kamera ön açıklaması ("Koç da form okutabilir")
3. 2.2 Hoş geldin
4. 2.5 Kayıt (koç) ("Koçluk kodu kayıttan sonra oluşur")
5. 10.1 Koç Anasayfa (k-tab, "Öğrenci yoksa: İlk öğrencini ekle"). Buradan:
   - **Okut** → 4.3 Okut (koç) (k-cam, "Öğrenci seçilir; sonuç onun hesabına")
   - **Öğrenci Ekle** → 10.3 Öğrenci Ekle ("Hesabı koç açar; giriş bilgileri bir kez") → 10.2 Öğrencilerim
   - **Kodunu Paylaş** → Kod (k-ext, "MOZK-4821; öğrenci 9.5'te girer") → 10.2 Öğrencilerim
6. 10.2 Öğrencilerim (k-tab, "Arama I/ı/İ/i; satırda son net") → 10.4 Öğrenci profili ("Bağlam şeridi; Anasayfa karosundan ve dikkat satırından da")
7. 10.4'ten:
   - 6.1 Analiz ("Öğrencinin grafiği ve kutuları")
   - 6.2 · 5.3 Denemeler ("Deneme Detay koç bağlamında")
   - 3.4 Program ("Salt okunur")
   - **Görüşme Planla** → 10.5 Yeni görüşme
8. 10.5 Görüşmelerim (k-tab, "Arama, Kiminle süzgeci") → **Yeni** → 10.5 Yeni görüşme ("Öğrenci, Öğrenci/Veli, tarih, saat") → 10.5 Görüşme detayı ("Tarih, saat, öğrencinin verileri")
   - **Not** → 10.6 Notlar ("Ekle, düzenle, onaylı sil, geri al")
   - Kesikli ok → 9.6 Öğrenciye bildirim (k-ext, "Görüşme planlandı")
9. 9.1 Hesap (koç) (k-tab, bağlantısız): "Koçluk kodu: Kopyala, Paylaş".

---

## 2. SMAP-02 · Açılış ve Giriş (Tur 7)

### 2.1 Açılış ve Tanıtım (4 kare)

Bileşenler: Lockup, OnboardingPage, Button.

**2.1-1 Açılış** · route `/splash`
- **Amaç:** Uygulama hazırlanırken marka ekranı.
- **Düzen:**
  - Tam ekran `#0F294A`, ortada dikey Lockup (aralık 20).
  - S-rota işareti: 78.6×104; alt kanca `#FF6600`, üst kanca `#FFFFFF`.
  - "SMAP" yazısı: 40, line-height 1, 800, -0.02em, `#FFFFFF`.
- **Durumlar:** 1 sn'den uzun sürerse işaretin altında spinner. Spinner ölçüsü çizilmemiş (belirtilmemiş).
- **Hareket:** İşaret ilk karede, solma yok. Uygulama hazır olunca 250 ms geçiş.
- **Navigasyon:** Hedef karar mantığı panoda yok. Mevcut koddaki `AppLaunchDestination` (onboarding / login / home) korunabilir. Sürüm desteklenmiyorsa 2.7-1, sunucu bakımdaysa 2.7-3.
- **Veri:** Min sürüm ve oturum bilgisi. Kaynak: oturum kontrolü olasılıkla `/ajax/checkUser`; min sürüm endpoint'i yok (belirtilmemiş).
- **Koyu:** Kare zaten lacivert; ayrı koyu varyant yok.
- **Eskiden:** 5 tanıtım ekranı, eski arayüzün ekran görüntüleri (7,7 MB), eski üçgen logo.

**2.1-2/3/4 Tanıtım 1–3** · route `/onboarding/intro` (3 sayfalık PageView)
- **Düzen (her sayfa):**
  - "Geç" text button: top 54, right 8. 1. ve 2. sayfada var, 3. sayfada yok.
  - Görsel alanı: top 112, yükseklik 380, ortalı.
  - Başlık `display` 32/40 800, en çok 2 satır: top 528, sol/sağ 24.
  - Gövde `b16` `#556173`, line-height 26, üst boşluk 12.
  - Alt bölüm (alttan 42, aralık 12): sayfa noktaları (aralık 6; geçerli 24×8 `#E05500`, diğerleri 8×8 `#C3CBD6`, erişilebilir ad "3 ekrandan N.") ve primary button (üst boşluk 12).
- **Sayfa görselleri:**
  - **1:** 250×330 telefon maketi; radius 28; gölge `0 12 32 rgba(15,41,74,.16)`. İçinde form, turuncu kesikli dörtgen ve köşe tutamaçları; altta 56'lık turuncu kamera düğmesi (radius 16, Camera 28).
  - **2:** 300 genişlikte ExamCard özeti (padding 16, gölge `0 12 32 rgba(15,41,74,.12)`). İçerik: "AYT · Türkiye Geneli Deneme 6", "67,5" `metric-lg` + "net" + "+8,25" (ArrowUp), DybSmall 86/74/0, 268×120 NetChart (eksen 40, 55, 70; tarih "8 May." – "5 Eki."; erişilebilir ad "AYT net grafiği: 8 Mayıs 48,5 netten 5 Ekim 67,5 nete").
  - **3:** 296 genişlikte konu kartı; satırlar padding 12 14, TextAa glif 32. Konular "Fiilde Çatı" (3 eksik), "Noktalama İşaretleri" (3 eksik), "Cümlenin Öğeleri" (2 eksik). Üstünde 236 genişlikte bilgi kartı (padding 14, gölge `0 16 32 rgba(15,41,74,.18)`): "Tarih · bilgi kartı" (Bank 24 glif), `t17` "Edirne-Segedin Antlaşması (1444)", `c13` "Haçlılarla Osmanlı Devleti'nin imzaladığı ilk antlaşma.", 40 yükseklikte primary "Öğrendim" (15 pt, radius 10).
- **Metinler:**
  - `onbSkip` = "Geç"
  - `onbIntro1Title` = "Optik formunu kamerayla okut"
  - `onbIntro1Body` = "Deneme bitince formunun fotoğrafını çek; cevapların sayılır, netin hesaplanır."
  - `onbIntro2Title` = "Netini ve gelişimini gör"
  - `onbIntro2Body` = "Her denemenin neti, doğru-yanlış dağılımı ve önceki denemene göre farkı tek ekranda."
  - `onbIntro3Title` = "Eksiklerini konu konu kapat"
  - `onbIntro3Body` = "Kaçırdığın konular eksik listene girer; konu anlatımı ve bilgi kartlarıyla tamamlarsın."
  - `commonContinue` = "Devam Et"
  - `onbStart` = "Başla"
  - `onbPageA11y` = "3 ekrandan {n}."
- **Etkileşim:**
  - Kaydırma ya da düğme ile geçiş; sayfa geçişi 350 ms (standard).
  - "Başla" rol seçimine (2.2-1) gider.
  - "Geç" hedefi belirtilmemiş (mantıken 2.2-1).
- **Hareket:** Görsel parçaları 250 ms gecikmeli belirir; hareketi azaltta yok.
- **Veri:** Statik.
- **Koyu:** Çizilmemiş.
- **Eskiden:** 3–4 satırlık başlıklar; "5 saniyede analizin hazırlanır" ve "yapay zeka destekli" vaatleri; Coin 5590, Oyunlar, Gelen Kutusu; altı çizili "Tanıtımı atla" bağlantısı.

### 2.2 Rol, Sınıf ve Alan, Kamera, Hoş Geldin (5 kare)

Bileşenler: RoleOption, Chip (kare, hap), InfoBox, Button, EmptyState görseli.

**Akış:** Tanıtım → Rol → (öğrenci) Sınıf ve alan → Kamera ön açıklaması → Hoş geldin → Kayıt ya da Giriş. Koç: Rol → Kamera → Hoş geldin. Geri her adımda çalışır ve seçimler korunur. Seçimler kayda kadar yalnız cihazda tutulur.

**2.2-1 Rol** · route `/onboarding/role`
- **Düzen:**
  - Geri (CaretLeft): top 54, left 4.
  - `display` "SMAP'i nasıl kullanacaksın?" (top 110, yatay 24) ve `b16 mu` "Ekranların buna göre hazırlanır." (üst boşluk 8).
  - radiogroup "Rol": top 240, aralık 12. İki RoleOption: 56'lık avatar, `t17` başlık, `b15 mu` açıklama (üst boşluk 2), Radio.
  - primary "Devam Et": alttan 42.
- **Metinler:**
  - `roleTitle` = "SMAP'i nasıl kullanacaksın?"
  - `roleSubtitle` = "Ekranların buna göre hazırlanır."
  - `roleStudent` = "Öğrenciyim"
  - `roleStudentDesc` = "Denemelerini okut, eksiklerini kapat."
  - `roleCoach` = "Öğrenci Koçuyum"
  - `roleCoachDesc` = "Öğrencilerinin gelişimini izle, görüşmelerini planla."
- **Davranış:** Seçim kayıt formuna taşınır. Giriş yapan kullanıcının rolü hesaptan gelir. Varsayılan seçim belirtilmemiş (panoda Öğrenciyim seçili çizili).
- **Navigasyon:** Öğrenci → 2.2-2; Koç → 2.2-4.
- **Veri:** Yerel state (`role`).
- **Koyu:** Yok.
- **Eskiden:** Rol seçimi kayıt formunun üstünde iki düğmeydi; rolün neyi değiştirdiği yazmıyordu.

**2.2-2 Sınıf ve alan** · route `/onboarding/grade`
- **Düzen:**
  - Geri düğmesi.
  - `display` "Kaçıncı sınıftasın?" (top 110).
  - Sınıf radiogroup: top 170, aralık 8. Kare çipler 56×48: "9", "10", "11", "12"; "Mezun" 88.
  - `t20` "Alanın" (top 258).
  - Alan radiogroup: hap çipler, üst boşluk 12, aralık 8: "Sayısal", "Eşit Ağırlık", "Sözel", "Dil".
  - "Devam Et" düğmesi.
- **Kurallar:** Sınıflar D-20, alanlar D-19. Koç bu adımı görmez.
- **Durumlar:**
  - **2.2-3 (9.–10. sınıf):** Alan çipleri yerine InfoBox (Info 20 `#36537C`). Metin `gradeNoFieldInfo` = "9. ve 10. sınıfta alan seçilmez; 11. sınıfa geçince Hesap'tan eklersin." Devam Et hemen açık.
  - 11, 12 ve Mezun için Devam Et'in pasif kuralı belirtilmemiş.
- **Metinler:** `gradeTitle` = "Kaçıncı sınıftasın?", `fieldTitle` = "Alanın"; seçenek metinleri yukarıda.
- **Veri:** Yerel state (`grade`, `field`). Sonra `/student/register` payload'una girer.
- **Eskiden:** Sınıf açılır listeydi; alan sorulmuyordu.

**2.2-4 Kamera ön açıklaması** · route `/onboarding/camera`
- **Düzen:**
  - Top 150, ortalı: 96'lık daire `#E2EAF4`, Camera 48 `#36537C`.
  - `display` başlık (üst boşluk 28), `b16 mu` gövde (line-height 26, üst boşluk 12).
  - Altta primary "Kameraya İzin Ver" ve tam genişlik text button "Sonra".
  - Geri düğmesi çizilmemiş.
- **Metinler:**
  - `camPrimerTitle` = "Formunu okutmak için kamera gerekli"
  - `camPrimerBody` = "SMAP kamerayı yalnız optik formunu çekerken kullanır. Bir sonraki adımda telefonun izin isteyecek."
  - `camPrimerAllow` = "Kameraya İzin Ver"
  - `camPrimerLater` = "Sonra"
- **Davranış:** Söz 4.1 ile aynı. "Sonra" izinsiz geçer; ilk okutmada 4.1 sheet'i yeniden sorar. "İzin Ver" sistem iletişim kutusunu açar.
- **Navigasyon:** → 2.2-5.
- **Veri:** İzin durumu (`permission_handler` ya da kamera eklentisi).
- **Eskiden:** Kamera izni hiç açıklanmadan isteniyordu.

**2.2-5 Hoş geldin** · route `/welcome`
- **Düzen:**
  - Top 150: kil "Harita" illüstrasyonu 160×160 (1.25, eski gezginler çiziminin yerine).
  - `display` başlık (üst boşluk 28), `b16 mu` gövde.
  - primary "Kayıt Ol" + outline "Giriş Yap" (aralık 12, alttan 42).
  - Geri düğmesi çizilmemiş.
- **Metinler:**
  - `welcomeTitle` = "SMAP'e hoş geldin"
  - `welcomeBody` = "Hesabın varsa giriş yap; yoksa birkaç adımda kaydol. Seçtiklerin kayıt formuna gelir."
  - `authRegister` = "Kayıt Ol"
  - `authLogin` = "Giriş Yap"
- **Navigasyon:** Kayıt Ol → 2.5; Giriş Yap → 2.3. Hesabı Sil ya da Çıkış (9.4 · 9.1) sonrası da buraya dönülür.
- **Kurallar:** Ekranda en fazla bir illüstrasyon; illüstrasyon yalnız Hoş geldin'de.

### 2.3 Giriş (4 kare) · route `/auth/login` (mevcut `/login` korunabilir)

Bileşenler: DetailBar, Lockup, TextField (şifre), ErrorBox, Button (yükleniyor).

- **Düzen:**
  - Geri düğmesi.
  - Lockup: top 110, left 24. İşaret 27.2×36 + "SMAP" 24/1 800 `#0F294A`, aralık 12.
  - Form: top 174, sol/sağ 24, aralık 20.
    - `t24` "Giriş yap"
    - "Kullanıcı adı" alanı
    - "Şifre" alanı (göz düğmeli)
    - Sağa yaslı text button "Şifremi Unuttum" (üst boşluk -8)
    - primary "Giriş Yap"
  - Alt satır (alttan 34, aralık 2): `b15 mu` "Hesabın yok mu?" + text button "Kayıt Ol".
- **Metinler:**
  - `loginTitle` = "Giriş yap"
  - `fieldUsername` = "Kullanıcı adı"
  - `fieldPassword` = "Şifre"
  - `loginForgot` = "Şifremi Unuttum"
  - `loginSubmit` = "Giriş Yap"
  - `loginSubmitting` = "Giriş yapılıyor"
  - `loginNoAccount` = "Hesabın yok mu?"
  - `authRegister` = "Kayıt Ol"
  - `a11yShowPassword` = "Şifreyi göster"
  - `a11yHidePassword` = "Şifreyi gizle"
  - `loginErrorInvalid` = "Kullanıcı adı ya da şifre hatalı. Tekrar dene ya da şifreni sıfırla."
  - `loginApple` = "Apple ile Devam Et"
  - `loginGoogle` = "Google ile Devam Et"
  - `loginOrUsername` = "ya da kullanıcı adınla"
- **Kareler ve durumlar:**
  - **1 · Boş:** Etiketli alanlar boş gelir (test bilgileri koddan kalkar). Odak kullanıcı adında.
  - **2 · Gönderiliyor:** Button içinde 20'lik beyaz spinner ve "Giriş yapılıyor"; alanlar kilitlenir. 15 sn'de yanıt yoksa bağlantı hatası (metni belirtilmemiş).
  - **3 · Hatalı bilgi:** ErrorBox (`role=alert`) "Şifremi Unuttum" ile düğme arasında. Hangi alanın yanlış olduğu söylenmez (güvenlik). Şifre temizlenir, odak şifrede. Haptik `error`.
  - **4 · Apple/Google varyantı (D-17):** Başlığın altında iki eşit outline düğme (aralık 12, 20×20 logo yer tutucu, radius 6). Altında ayraç ve `c13` 600 "ya da kullanıcı adınla". Resmî logo varlıkları kullanılacak.
- **Davranış:**
  - Klavye: kullanıcı adında "ileri", şifrede "git" (Giriş Yap'ı çalıştırır).
  - Kullanıcı adında büyük harf ve boşluk kırpılır; şifre olduğu gibi gönderilir.
  - "Beni Hatırla" yok: oturum açık kalır, çıkış Hesap'ta.
  - Başarılı girişte rol hesaptan okunur: öğrenci → 3.1, koç → 10.1, bilinmeyen rol → 2.7-4.
- **Navigasyon:** Şifremi Unuttum → 2.4; Kayıt Ol → 2.5.
- **Veri:** `username`, `password` → `/student/login` (mevcut). Apple ve Google akışı: `google_sign_in` mevcut, Apple yok (belirtilmemiş).
- **Koyu:** Yok.
- **Eskiden:** Etiketsiz alanlar "student" ve şifreyle dolu; 40'lık yuvarlak sosyal ikonlar; "veya hesabınızla bağlanın"; gezginler çizimi; klavye açılınca düğme kayboluyordu.

### 2.4 Şifremi Unuttum (4 kare) · route `/auth/forgot-password` (adımlar `/email`, `/code`, `/new`, `/done` ya da tek route içinde stepper)

Bileşenler: TextField, CodeInput, Button.

**Ortak düzen:** Geri düğmesi; içerik top 110, sol/sağ 24, aralık 20; başlık `t24`, açıklama `b15 mu` (üst boşluk 6).

**Kareler**
- **1 · E-posta:**
  - "Şifreni sıfırla" + "Hesabındaki e-posta adresini yaz; 6 haneli bir kod gönderelim."
  - "E-posta" alanı (odaklı); primary "Kod Gönder".
  - E-posta klavyesi.
  - Kayıtlı olmasa da aynı yanıt verilir (hesabın varlığı sızdırılmaz).
- **2 · Kod:**
  - "Kodu gir" + "Kodu {email} adresine gönderdik. Gelen kutunda yoksa istenmeyen klasörüne bak."
  - "Doğrulama kodu" etiketi; 6 kutu (erişilebilir ad "N. hane").
  - Pasif text button "Kodu Tekrar Gönder (0:24)" (`#556173`, `aria-disabled`); text button "E-postayı Değiştir".
  - Kod otomatik dolar (tek kullanımlık kod); yapıştırınca 6 kutu birden dolar; 6. hanede kendiliğinden doğrular.
  - Tekrar gönderme 30 sn sonra açılır.
- **3 · Yeni şifre:**
  - "Yeni şifreni belirle".
  - "Yeni şifre" (yardım metni "En az 8 karakter.") ve "Yeni şifre (tekrar)" (odaklı).
  - primary "Şifreyi Güncelle".
  - Eşleşmezse "Şifreler aynı değil."
- **4 · Bitti** (`role=status`, top 200):
  - 96'lık daire `#E4F4EA`, CheckCircle 48 `#0B6E3E`.
  - `display` "Şifren güncellendi" (üst boşluk 28) + `b16 mu` "Yeni şifrenle giriş yapabilirsin." (üst boşluk 12).
  - primary "Giriş Yap": kullanıcı adını hazır getirir. Haptik `success`.

**Metinler**
- `fpTitle` = "Şifreni sıfırla"
- `fpBody` = "Hesabındaki e-posta adresini yaz; 6 haneli bir kod gönderelim."
- `fieldEmail` = "E-posta"
- `fpSendCode` = "Kod Gönder"
- `fpCodeTitle` = "Kodu gir"
- `fpCodeBody` = "Kodu {email} adresine gönderdik. Gelen kutunda yoksa istenmeyen klasörüne bak."
- `fpCodeLabel` = "Doğrulama kodu"
- `fpResendIn` = "Kodu Tekrar Gönder ({m}:{ss})"
- `fpResend` = "Kodu Tekrar Gönder" (sayaçsız hâli çizilmemiş)
- `fpChangeEmail` = "E-postayı Değiştir"
- `fpNewTitle` = "Yeni şifreni belirle"
- `fieldNewPassword` = "Yeni şifre"
- `fieldNewPasswordRepeat` = "Yeni şifre (tekrar)"
- `pwRule` = "En az 8 karakter."
- `fpUpdate` = "Şifreyi Güncelle"
- `fpDoneTitle` = "Şifren güncellendi"
- `fpDoneBody` = "Yeni şifrenle giriş yapabilirsin."
- Hatalar:
  - `fpErrCode` = "Kod hatalı ya da süresi dolmuş. Yeni kod iste."
  - `fpErrTooMany` = "Çok fazla deneme yaptın. 10 dakika sonra tekrar dene."
  - `errEmailFormat` = "E-posta adresi eksik görünüyor. Örn: ad@alan.com"
  - `pwMismatch` = "Şifreler aynı değil."
  - Toast `errSendFailed` = "Gönderilemedi. Bağlantını kontrol edip tekrar dene."

**Hareket:** Adımlar arası 350 ms yatay geçiş. Kod hatalıysa kutular 150 ms sallanır (hareketi azaltta yok) ve haptik `error`. Bitti: `success`.

**Neden:** D-18 e-posta + 6 haneli kod: kullanıcı uygulamadan çıkmadan biter. Her adımda tek iş ve tek birincil düğme.

**Veri:** `email`, `code`, `newPassword`. Backend: **mevcut kodda endpoint yok** (kod gönderme, doğrulama, şifre güncelleme). Kod süresi belirtilmemiş.

**Koyu:** Yok.

### 2.5 Kayıt (3 kare) + 2.6 Kayıt · Durumlar (4 kare) · route `/auth/register?role=student|coach`

Bileşenler: Segment, AvatarPicker, TextField (canlı kontrol), SelectField, Checkbox, ErrorBox, InfoBox.

**Düzen (üst, kare 1)**
- Geri düğmesi; içerik top 110, sol/sağ 24, aralık 20.
- `t24` "Kayıt ol".
- Rol segmenti: "Öğrenci" | "Öğrenci Koçu".
- AvatarPicker:
  - Başlık satırı: `.fl` "Avatarın" + `c13 mu` "7 avatar".
  - 7 adet 46'lık daire tek satırda (space-between, üst boşluk 10).
  - Seçili halka: `0 0 0 2 #F2F4F7, 0 0 0 4 #0F294A`.
  - Erişilebilir ad: "Avatar N" / "Avatar 1, seçili".
- "Ad Soyad" alanı.
- "Kullanıcı adı" alanı: canlı kontrol; olumluysa sağda CheckCircle 22 `#0B6E3E` + `.ok` "Bu kullanıcı adı boşta.".
- "E-posta" alanı.

**Düzen (alt, kaydırılmış)**
- Bar küçülür: 102 yükseklik, `#F2F4F7`, `t17` "Kayıt ol".
- Rol segmenti sabit kalır: top 102, padding 0 24 12, alt çizgi `0 1 0 #DCE2E9`.
- İçerik top 174, aralık 20:
  - "Şifre" (yardım "En az 8 karakter.") ve "Şifre (tekrar)".
  - Öğrenci: "Sınıf" SelectField ("12. Sınıf") ve "Alan" SelectField ("Eşit Ağırlık"); ikisi de alttan sheet açar.
  - Koç (kare 3): Sınıf ve Alan yerine InfoBox "Kaydın tamamlanınca koçluk kodun oluşur. Öğrencilerin bu kodla sana bağlanır; kodun Hesap › Koçluk'ta durur."
  - Onay Checkbox: "[Kullanım Koşulları]'nı ve [KVKK Aydınlatma Metni]'ni okudum, kabul ediyorum." Köşeli parantezdekiler link; bağlantılar metni sheet'te açar.
  - primary "Kayıt Ol"; altında `b15 mu` "Hesabın var mı?" + text button "Giriş Yap" (üst boşluk -8).

**Alan kuralları**
- Alanlar: Rol, Avatar (7), Ad Soyad, Kullanıcı adı, E-posta, Şifre, Şifre (tekrar), öğrenciye Sınıf ve Alan, koça kod bilgisi, Onay, Kayıt Ol.
- Önceden dolu alan yok. Zorunlu alan yıldızsız; isteğe bağlı alan yok.
- Rol ve seçimler 2.2'den gelir ve değiştirilebilir. Koçun Ad Soyad örneği: "Mehmet Özkan" (koç üst karesi çizilmemiş).

**Durumlar (2.6)**
1. **Alan hataları:**
   - Kullanıcı adı alınmışsa: alan `.fe` + `.er` "Bu kullanıcı adı alınmış.". Altında `c13 mu` "Boşta olan:" + öneri hap çipi (40 yükseklik, 15 pt) "alparslan.k". Çipe dokununca alan dolar ve kontrol yeniden çalışır; haptik `selectionClick`.
   - E-posta hatası: "E-posta adresi eksik görünüyor. Örn: ad@alan.com".
2. **Gönderimde:**
   - "Şifre (tekrar)" `.fe` + "Şifreler aynı değil.".
   - Onay kutusu inset 2 `#C42D35` + "Kaydolmak için metinleri onaylaman gerekiyor.".
   - Odak ilk hatalı alana gider; haptik `error` bir kez.
3. **Metinler yüklenemedi:**
   - Onay satırı yerine ErrorBox: "Sözleşme metinleri yüklenemedi. Kaydolmak için metinleri görebilmen gerekiyor." + text button "Tekrar Dene".
   - "Kayıt Ol" pasif (`.bp.off`); altında `.hp` ortalı "Metinler yüklenince kayıt açılır.".
   - Metinler yüklenince kutu 250 ms'de onay satırına döner.
4. **10. sınıf** (örnek Mert Yıldız): "Sınıf" = "10. Sınıf"; "Alan" pasif "Seçilmez" + `.hp` "9. ve 10. sınıfta alan seçilmez.".

**Metinler (ek)**
- `registerTitle` = "Kayıt ol"
- `roleSegStudent` = "Öğrenci"
- `roleSegCoach` = "Öğrenci Koçu"
- `avatarLabel` = "Avatarın"
- `avatarCount` = "{n} avatar"
- `fieldFullName` = "Ad Soyad"
- `usernameFree` = "Bu kullanıcı adı boşta."
- `usernameTaken` = "Bu kullanıcı adı alınmış."
- `usernameSuggest` = "Boşta olan:"
- `fieldPasswordRepeat` = "Şifre (tekrar)"
- `fieldGrade` = "Sınıf"
- `gradeValue` = "{n}. Sınıf"
- `fieldField` = "Alan"
- `fieldNotSelectable` = "Seçilmez"
- `fieldNotSelectableReason` = "9. ve 10. sınıfta alan seçilmez."
- `coachCodeInfo` = (yukarıdaki InfoBox metni)
- `consentText` = "{terms}'nı ve {kvkk}'ni okudum, kabul ediyorum."; `terms` = "Kullanım Koşulları", `kvkk` = "KVKK Aydınlatma Metni"
- `consentRequired` = "Kaydolmak için metinleri onaylaman gerekiyor."
- `legalLoadFailed` = "Sözleşme metinleri yüklenemedi. Kaydolmak için metinleri görebilmen gerekiyor."
- `legalRegisterLocked` = "Metinler yüklenince kayıt açılır."
- `commonRetry` = "Tekrar Dene"
- `hasAccount` = "Hesabın var mı?"

**Davranış**
- Kullanıcı adı: yazmayı bırakınca 400 ms sonra kontrol; spinner alanın sağında (çizilmemiş).
- Gönderimde odak ilk hatalı alana gider; hatalı alana 350 ms kaydırma (hareketi azaltta doğrudan).
- Kayıt sonrası öğrenci yeni kullanıcı Anasayfa'sına (3.1-3), koç 10.1'e gider.
- Bildirim izni ilk okutmadan sonra sorulur (D-23).

**Veri ve backend:** `role`, `avatarId` (1–7), `fullName`, `username`, `email`, `password`, `grade` (9/10/11/12/Mezun), `field` (Sayısal/EA/Sözel/Dil/null), `consent`.
- Kayıt: `/student/register` (mevcut; koç kaydı aynı endpoint mi belirtilmemiş).
- Kullanıcı adı kontrolü: `/ajax/checkUsername`. Öneri alanı yanıtta var mı belirtilmemiş.
- Sözleşme metinleri: `/ajax/getLegalDocuments`.

**Koyu:** Yok.

**Neden:** Hukuk metni okunamıyorsa onay alınamaz, kayıt kapatılır. Hata çözüm söyler, iç kod göstermez (1.22).

**Eskiden:** "usernametest", "test@smap.tr" ve şifreler dolu geliyordu; avatarlar okla tek tek seçiliyordu; iki satırlık hukuk metni onay kutusuzdu; koç formunda "Tamamla" düğmesi vardı.

### 2.7 Genel Ekranlar (4 kare)

Bileşenler: ErrorState (ekran), ConfirmSheet, uygulama ikonu.

**Ortak kalıp:** Top 190, ortalı. 96'lık ikon dairesi (durum rengi), `display` 32/40 başlık (üst boşluk 28), tek cümle `b16 mu` (line-height 26, üst boşluk 12), en çok iki düğme (alttan 42). İllüstrasyon yok. "Sen" dili, iç kod yok.

| Kare | Route | Görsel | Metinler | Eylemler ve davranış |
|---|---|---|---|---|
| 1 Zorunlu güncelleme | `/blocking/force-update` | Uygulama ikonu 96, radius 21.5 (1.26 lacivert pafta) | `forceUpdateTitle` = "Yeni sürüm gerekli"; `forceUpdateBody` = "Bu sürüm artık desteklenmiyor. Devam etmek için SMAP'i güncelle; verilerin hesabında duruyor." | primary `update` = "Güncelle" mağazayı açar. Kapatılamaz; geri hareketi ve sistem geri tuşu çalışmaz. Açılışta tetiklenir. Mağaza URL'si ve min sürüm kaynağı belirtilmemiş. |
| 2 Oturum sona erdi | Route yok: global sheet (`role=alertdialog`) | Herhangi bir ekranın üstünde. 40'lık daire `#E2EAF4`, Clock 22 `#36537C`. Sheet içeriği padding 20 24 0, alt bant üst boşluk 24 | `sessionExpiredTitle` = "Oturumun sona erdi"; `sessionExpiredBody` = "Güvenliğin için yeniden giriş yapman gerekiyor. Okuttuğun denemeler hesabında duruyor." | primary "Giriş Yap". Perde ve sürükleme kapatmaz. İstekte 401 gelirse açılır; bekleyen gönderimler sırada kalır ve girişten sonra sürer; aynı ekrana dönülür. |
| 3 Bakım | `/blocking/maintenance` | 96 daire `#E2EAF4`, Wrench 48 `#36537C` | `maintenanceTitle` = "SMAP şu an bakımda"; `maintenanceBody` = "Kısa süre içinde geri döneceğiz. Verilerin güvende; bakım bitince kaldığın yerden devam edersin." | quiet (ikincil) "Tekrar Dene". Sunucu bakım yanıtı verirse açılır. Süre vaadi yok. Uygulama öne gelince kendiliğinden yeniden dener. |
| 4 Bilinmeyen rol | `/blocking/unknown-role` | 96 daire `#FCEAEA`, WarningCircle 48 `#C42D35` | `unknownRoleTitle` = "Hesabın açılamadı"; `unknownRoleBody` = "Hesap türün tanınmadı. Çıkış yapıp yeniden giriş yapmayı dene; sorun sürerse bize yaz." | primary `reLogin` = "Yeniden Giriş Yap" + text button `contactSupport` = "Destek'e Yaz" (e-posta taslağı açar; adres belirtilmemiş). Rol öğrenci ya da koç değilse açılır. Ham hata ya da kod gösterilmez. |

- Oturum sheet'inin arka planında: Anasayfa bandı iskeleti ve BottomBar.
- **Eskiden:** Bu durumların ekranı yoktu; hatalar ham metinle ya da sessizce geçiyordu.
- **Koyu:** Yok.

---

## 3. SMAP-03 · Anasayfa ve Programım (Tur 6)

### 3.1 Anasayfa (3 kare) · route `/home` (StatefulShellRoute dal 0)

Bileşenler: HomeBand, SectionHeader, ProgramItemRow, ExamCard özeti, DybSmall, SubjectTile, EksikTag, BottomBar.

**Amaç:** Tek soruyu cevaplar: "Bugün ne yapmalıyım?" En çok 4 bölüm: bant, Bugün, Son denemen, Derslerin.

**Düzen (kare 1 · Açılış)**
- **(a) HomeBand:**
  - Zemin `#0F294A`, padding 62 16 20, radius 0 0 24 24.
  - Satır (min yükseklik 56, aralık 12): avatar 40 + `hg` 20/28 700 `#FFFFFF` "Merhaba, {ad}".
  - Sayaç (üst boşluk 8, aralık 12, alta hizalı): "252" `cdn` 40/48 800 + sütun (alt padding 4): "gün kaldı" 15/20 700 `#FFFFFF`, "YKS · 19 Haziran 2027 Cumartesi" 13/20 `#C5D4E8`.
  - Eyebrow ve gri alt satır üçlüsü yok.
- **Sayfa gövdesi** (`.pg`): padding 24 16 140, bölümler arası aralık 28, bölüm içi 12.
- **(b) Bugün:**
  - Başlık `t20` "Bugün" + `c13 mu` "Cumartesi, 10 Ekim · Ekim 2. Hafta" ({gün}, {tarih} · {program adı}).
  - Sağda text button "Programım" (40 yükseklik): bölümün tek bağlantısı.
  - Kart (radius 16) içinde ProgramItemRow'lar:
    - Satır: min yükseklik 64, padding 10 12 10 16, aralık 12; ayraç 1 `#E8ECF1`.
    - Saat `.tt` 15/24 600, tabular, min genişlik 48.
    - GlyphTile 36 (ikon 19).
    - Ders `.tm` 13/20 `#556173`; konu `.tn` 16/24 600.
    - Sağda CaretRight 20.
  - Örnek satırlar: 10:00 Türkçe "Fiilde Çatı"; 14:00 Tarih "Kurtuluş Savaşı Hazırlık Dönemi"; 20:00 Coğrafya "İklim Bilgisi".
  - Tamamlama işareti yok (D-26).
- **(c) Son denemen:** `t20` başlık; kart padding 16:
  - Ad `.tn` 700 "Türkiye Geneli Deneme 6"; meta `.tm` "Örnek Yayınları · AYT · 5 Eki. 2026". Ad ve yayınevi ayrı satır (D-32).
  - Satır (üst boşluk 12): "67,5" `metric-lg` + `b15 mu` 600 "net" + fark `.dg` (sol boşluk 8, ArrowUp 14) "+8,25" + `c13 mu` "önceki AYT'ye göre".
  - DybSmall (üst boşluk 8): 86 doğru, 74 yanlış, 0 boş.
  - Ayraç (margin 16 0 12); `c13 mu` 700 "En çok kaçırdığın konu"; `b15` "Kurtuluş Savaşı Hazırlık Dönemi'nde 13 sorudan 9'unu kaçırdın.".
  - primary "Analizi Gör" (üst boşluk 16): tek birincil eylem.
- **(d) Derslerin:**
  - `t20` başlık + `c13 mu` "Eksiği en çok olandan başlar".
  - Yatay şerit: aralık 8, yatay padding 16.
  - SubjectTile: 132 genişlik, padding 16, radius 16, aralık 12. GlyphTile 40 (ikon 22), ad `.tn`, EksikTag (üst boşluk 6).
  - Sıra: Tarih 60, Coğrafya 44, Türkçe 31, Fizik 14, Biyoloji 11, Kimya 9, Türk Dili ve Edebiyatı 3. Matematik ve Geometri `.tg` "Web'de".
  - Erişilebilir ad: "Tarih, 60 eksik"; "Matematik, web'de açılır".
- **BottomBar:** Anasayfa aktif.

**Kare 2 · Kaydırılmış**
- Bant 110'a iner: padding 62 16 0, satır 48, aralık 10, avatar 32, selam 17/24.
- Sağda `.cds` 600 "YKS'ye 252 gün".
- Diğer bölümler aynı.

**Kare 3 · Yeni kullanıcı (program ve deneme yok)**
- Bugün: alt başlık yalnız "Cumartesi, 10 Ekim"; "Programım" bağlantısı yok.
  - Kart (padding 16 16 8): `b15` "Haftalık programın yok. Bir hafta kurduğunda günün konuları burada görünür." + text button "Haftalık Programını Kur" (sol boşluk -12).
- Son denemen: `.tn` 700 "Henüz deneme okutmadın." + `b15 mu` (üst boşluk 4) "Optik formunu okuttuğunda netin, doğru-yanlış dağılımın ve en çok kaçırdığın konu burada görünür." + primary (Camera 20) "İlk Denemeni Okut".
- Derslerin: alt başlık yok; karolarda yalnız glif ve ad. Eksik etiketi ve "Web'de" etiketi yok.

**Metinler**
- `homeGreeting` = "Merhaba, {firstName}"
- `homeDaysLeftLabel` = "gün kaldı"
- `homeExamDate` = "YKS · {date}"
- `homeDaysLeftShort` = "YKS'ye {n} gün"
- `a11yCountdown` = "YKS'ye {n} gün kaldı. Sınav {date}."
- `homeToday` = "Bugün"
- `homeTodaySub` = "{weekday}, {d} {month} · {programName}"
- `homeMyProgram` = "Programım"
- `a11yProgramRow` = "{time}, {subject}, {topic}"
- `homeLastExam` = "Son denemen"
- `examMeta` = "{publisher} · {type} · {date}"
- `netLabel` = "net"
- `deltaVsPrev` = "önceki {type}'ye göre"
- `dybCorrect` = "doğru", `dybWrong` = "yanlış", `dybBlank` = "boş"
- `homeMostMissed` = "En çok kaçırdığın konu"
- `homeMostMissedSentence` = "{topic}'nde {total} sorudan {wrong}'unu kaçırdın."
- `homeSeeAnalysis` = "Analizi Gör"
- `homeSubjects` = "Derslerin"
- `homeSubjectsSub` = "Eksiği en çok olandan başlar"
- `eksikCount` = "{n} eksik"
- `onWeb` = "Web'de"
- `homeNoProgram` = "Haftalık programın yok. Bir hafta kurduğunda günün konuları burada görünür."
- `setupWeeklyProgram` = "Haftalık Programını Kur"
- `homeNoExamTitle` = "Henüz deneme okutmadın."
- `homeNoExamBody` = (yukarıdaki metin)
- `scanFirstExam` = "İlk Denemeni Okut"
- Alt çubuk: `tabHome` = "Anasayfa", `tabAnalysis` = "Analizlerim", `tabScan` = "Okut", `tabLessons` = "Derslerim", `tabAccount` = "Hesap"; `a11yScan` = "Okut: deneme formunu kamerayla okut".

**Etkileşim**
- Bugün satırı → 7.3 Konu detayı, ilk eksik maddede.
- "Programım" → 3.4.
- "Analizi Gör" → hedef panoda açık yazmıyor; mantıken son denemenin 5.3 Deneme Detay ekranı (belirtilmemiş).
- Ders karosu → 7.2 Ders detayı, Derslerim'deki son TYT/AYT seçimiyle. Eski TYT/AYT/SOS-2 diyaloğu yok.
- Mat/Geo "Web'de" karosu: web görünümü (7.1 BottomSheet ile, belirtilmemiş).
- "Haftalık Programını Kur" → 3.5. "İlk Denemeni Okut" → Okut akışı (4.x).
- Kaydırınca bant 1.18 kare 3 gibi küçülür. Çekip yenileme (RefreshIndicator); bırakınca `selectionClick`.

**Davranış:** Sayaç cihaz saatinden hesaplanır (D-21), gece yarısı yenilenir, ağ gerekmez. Sınav tarihinin kaynağı belirtilmemiş (sabit ya da ayar).

**Veri ve backend**
- Kullanıcı: `firstName`, `avatarId` → oturum / profil (mevcut `UserModel`: name, photo).
- Bugünün programı: tarih, saat, ders, konu, programAdı → `/student/getMyWeeklies`.
- Son deneme: ad, yayınevi, tür, tarih, net, fark, önceki tür, D/Y/B, en çok kaçırılan konu (toplam, yanlış) → olası `/student/getMyMockExams` + `/student/getMexamSubjectDetail`. Fark ve en çok kaçırılan konunun hazır alanı var mı belirtilmemiş.
- Dersler ve eksik sayısı (azalan sıralı), webOnly bayrağı → `/ajax/getGeneralLessons` + `/student/getLessonsTotalMissing`.

**Koyu:** 3.3'te var.

**Eskiden:** Kişi kartında coin "0" ve %0 çubuğu; menü ızgarası (Analiz, Denemelerim, Derslerim, Gelen Kutusu, SmapLab, Programım) alt çubukla aynı işi yapıyordu; içeriksiz ay takvimi; ders kartlarında etiketsiz yüzen rozetler.

### 3.2 Anasayfa · Durumlar (4 kare)

Bölümler kendi durumunu taşır; ekranın geri kalanı çalışır.

1. **İskelet:**
   - Bant hemen gelir (ad ve sayaç cihazda).
   - Bugün iskeleti: 80×24 başlık, 170×14 alt satır; 3 satır (64 yükseklik). Her satırda 44×18, 36×36 (radius 12), 60×12, 90/180/110×16 bloklar.
   - Son denemen iskeleti: 140×24 başlık; kart padding 16, aralık 10 (200×18, 120×14, 130×36, 220×16, 100%×48 radius 12).
   - Parıltı 1200 ms; hareketi azaltta durağan. 15 sn'de veri yoksa bölüm hatası.
2. **Bölüm hatası (Bugün):**
   - Kart `role=alert`, padding 16 16 8, aralık 12; WarningCircle 22 `#C42D35`.
   - `b15` "Bugünün programı yüklenemedi." + text button "Tekrar Dene": yalnız o bölümü yeniler.
   - Son denemen ve Derslerin çalışmaya devam eder (1.22 kare 4).
3. **Çevrimdışı:**
   - OfflineStrip (`role=status`, WifiSlash 18) bandın altında, içeriği iter; bant köşeleri düzleşir (radius 0).
   - Metin `offlineCached` = "Çevrimdışısın. Son kaydedilen veriler gösteriliyor."
   - Son kaydedilen program ve deneme gösterilir. Şerit 250 ms'de iner; haptik yok.
4. **Metin %130:** `.x13` ölçekleri:

| Öğe | Boyut |
|---|---|
| hg | 26/34 |
| cdn | 52/60 |
| cdl | 19.5/26 |
| cds, c13, tm | 17/26 |
| t20 | 26/36 |
| tn | 21/30 |
| tt, b15 | 19.5/30 |
| nv | 52/62 |
| bt, bp | 20.8/28 |
| sm | 19.5/26 |
| sm i | 17 |

   - Satırlar uzar; ad ve konu kesilmez. Alt çubuk etiketi 1.19'daki gibi sığdırılır (çizimde 12/16).

**Durum metinleri**
- `homeTodayError` = "Bugünün programı yüklenemedi."
- `homeSubjectsError` = "Dersler yüklenemedi." (karesi çizilmemiş)
- Program yok ve deneme yok metinleri 3.1'de.

**Erişilebilirlik:** Sayaç tek öğe; Bugün satırı "10:00, Türkçe, Fiilde Çatı"; şerit karosu "Tarih, 60 eksik"; yatay liste kaydırma eylemleriyle.

### 3.3 Anasayfa · Koyu (1 kare)

- Yapı açık temayla aynı. Bant yine `#0F294A` (navy-900, 1.24).
- Kartlar `#121D31`, ayraç `#26354D`.
- Fark rengi `#9BB3D3` (info). D/Y/B: `#52CC8E` / `#F07575` / `#6E7C92`.
- Ders karoları koyu ders tonlarında (tablo §0). Eksik etiketi `#F2C46D` / `#33270F`.
- Birincil düğme `#C5D4E8` zemin, `#091A31` metin. BottomBar koyu değerleri §0'da.
- **Neden:** Ek D-14 koyu listesinde: akşam çalışmasında ilk açılan ekran.

### 3.4 Programım (4 kare) · routes `/home/program` (liste), `/home/program/:programId?view=day|week&date=`

Bileşenler: DetailBar, BarAction, SearchField, Segment, DayChip, WeekGrid.

Anasayfa'daki "Programım"dan açılır. Alt çubuk görünür, Anasayfa sekmesi aktif.

**Kare 1 · Liste**
- Geri düğmesi; `t24` "Programım" (top 110, yatay 16).
- BarAction (Plus 20) "Yeni Program": top 58, right 16; sağ üstte tek eylem.
- SearchField: top 158, aralık 10, MagnifyingGlass 20, placeholder "Program ara".
- Kart (top 222) içinde satır (padding 16, aralık 12, üste hizalı):
  - GlyphTile 40 `#E2EAF4` / `#36537C`, Calendar 22.
  - Ad `.tn` 700 "Ekim 2. Hafta" + `.tg` "Bu hafta" (6×6 `#E05500` nokta, sağ boşluk 6; turuncu nokta = bugün, D-7).
  - `b15 mu` motto "Her gün biraz daha"; `.tm` "5–11 Ekim 2026".
  - CaretRight 20 (üst padding 8).

**Kare 2 · Arama, sonuç yok**
- Alanda "kasım" + temizle düğmesi (40×40; içinde 24'lük `.xi`, X 12; erişilebilir ad "Aramayı temizle").
- Kart `role=status`, padding 24 16 12, ortalı:
  - `.tn` 700 "“kasım” ile eşleşen program yok"
  - `c13 mu` "Program adında ve mottosunda arar; büyük-küçük harf ve I/ı farkı gözetmez."
  - text button "Aramayı Temizle"
- Arama ad ve mottoda yapılır, harf duyarsızdır (I/ı/İ/i, tr-TR katlama).

**Kare 3 · Gün**
- BarAction "Düzenle" (top 58).
- Başlık: `t24` program adı, `b15 mu` motto, `.tm` tarih aralığı.
- Segment "Gün" | "Hafta": top 206, radiogroup "Görünüm".
- DayChip şeridi: top 262, space-between, 7 gün.
  - Çip 48×64, radius 12, zemin `#FFFFFF`; gün `i` 13/20 600 `#556173`; sayı `b` 17/24 700.
  - Seçili: `#0F294A` (gün etiketi `#C5D4E8`).
  - Bugün noktası 6×6 `#E05500`, alttan 5; seçili çipte `#FF6600`.
  - Erişilebilir ad: "Cumartesi 10 Ekim, bugün, seçili".
- `t17` "Cumartesi, 10 Ekim" + `.tm` "3 çalışma" (top 342).
- Kart içinde ProgramItemRow'lar (top 380, aralık 16).
- Danger text button (ArrowCounterClockwise 20) "Günü Sıfırla": sonda, onaylı (3.6).
- Tamamlama yok (D-26).

**Kare 4 · Hafta**
- Başlık bara inmiş: 102 yükseklik `#F2F4F7`, `t17` program adı + "Düzenle".
- Segment top 110.
- WeekGrid (`role=grid`, erişilebilir ad "Haftalık program, 06:00–23:00; Pazartesi–Çarşamba solda"): top 166, yükseklik 604, yatay kayar.
  - Başlık satırı 44 yükseklik; gün sütunu 84; saat sütunu 44; saat satırı 40.
  - Çizgiler `#E8ECF1`; saat etiketi `.wh` 13/20 600 `#556173`.
  - Bugün başlığının altında 32×3 `#E05500` çizgi.
  - Blok: 78×36, radius 8, padding 4 6, ders tonu, ikon 14, ders 13/16 700. Blokta yalnız ders; konu dokununca görünür.
  - Solda 12 genişlikte `#F2F4F7` → transparent kaydırma gölgesi.
  - Açılışta bugünün sütunu ve ilk çalışma görünür.

**Metinler**
- `programTitle` = "Programım"
- `newProgram` = "Yeni Program"
- `programSearchHint` = "Program ara"
- `thisWeek` = "Bu hafta"
- `programDateRange` = "{start}–{end} {month} {year}"
- `searchNoMatch` = "“{q}” ile eşleşen program yok"
- `programSearchHelp` = "Program adında ve mottosunda arar; büyük-küçük harf ve I/ı farkı gözetmez."
- `clearSearch` = "Aramayı Temizle"
- `a11yClearSearch` = "Aramayı temizle"
- `edit` = "Düzenle"
- `viewDay` = "Gün", `viewWeek` = "Hafta"
- Gün kısaltmaları: "Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"
- `studyCount` = "{n} çalışma"
- `resetDay` = "Günü Sıfırla"

**Davranış**
- Program satırı Gün görünümünde bugünü açar; bugün aralıkta değilse ilk günü.
- Gün / Hafta seçimi cihazda hatırlanır.
- Bloğa ya da satıra dokununca konu detayı (7.3). Uzun basınca saat değiştirme (yalnız düzenleme modunda).

**Veri ve backend:** Programlar (id, ad, motto, başlangıç, bitiş, günler → maddeler: tarih, saat, dersId, konuId, konu adı) → `/student/getMyWeeklies`. Koçta salt okunur (0.3).

**Koyu:** Hafta görünümü için 3.8; Gün ve Liste için çizilmemiş.

**Eskiden:** Arama alanı vardı ama doğru süzmüyordu; program yalnız liste olarak vardı, gün ve hafta görünümü yoktu.

### 3.5 Yeni Program (4 kare) · route `/home/program/new` (root navigator, tam ekran, alt çubuk yok; adımlar `days` → `grid` → `name`)

Bileşenler: Calendar, DayChip, HourSlot, BottomSheet, Radio, TextField.

**Akış:** Programım › Yeni Program → Günler → Izgara → Ad ve motto → Programım (toast "Program kaydedildi.", 4 sn). Geri her adımda seçimleri korur.

**Ortak üst bölüm:** Adım 1'de X (erişilebilir ad "Vazgeç"), adım 2–3'te CaretLeft "Geri"; sağda `c13 mu` 600 "Adım N/3". Başlık `t24` top 110 + `b15 mu` (üst boşluk 4).

**Ortak alt bant:** Zemin `#FFFFFF`, üst çizgi `0 -1 0 #DCE2E9`, padding 12 24 42; tek primary düğme.

**Kare 1 · Günler**
- "Hangi günler çalışacaksın?" / "Birden çok gün seçebilirsin; geçmiş günler seçilemez."
- Calendar kartı (top 206, padding 8 8 12):
  - Ay başlığı: `.ib` CaretLeft 22 "Önceki ay" + `t17` "Ekim 2026" + CaretRight "Sonraki ay".
  - Izgara 7×46, aralık 4. Hafta günleri 24 yükseklik, 13/20 `#556173`. Gün hücresi 46 yükseklik, radius 12, 16/24 600.
  - Geçmiş günler `#9AA5B4` 500, pasif. Seçili `#0F294A`. Bugün: inset 2 `#E05500` halka.
- Lejant (top 572): 20×20 radius 6, 2 pt turuncu halka + "Bugün".
- Alt bantta özet `.tn` 700 "6 gün seçildi" + `.tm` "12–17 Ekim" (alt boşluk 12) + "Devam Et".
- Çoklu seçim: günlere tek tek dokunulur, aralık şart değil. Haptik `selectionClick`.

**Kare 2 · Izgara**
- "Konuları yerleştir" / "Boş bir saate dokun, konu seç. Izgara 06:00–23:00."
- Seçilen günler üstte: DayChip 56×76, top 186; seçili günde ek satır 13/16 600 "2 konu".
- HourSlot kartı (top 278):
  - Satır min yükseklik 52, padding 4 12 4 16, aralık 8, ayraç `#E8ECF1`.
  - Saat etiketi 44 genişlik, 13/20 600, üst padding 12.
  - Boş slot: min yükseklik 44 (erişilebilir ad "09:00, boş, konu ekle").
  - Dolu slot: ders zemini, radius 12, padding 8 4 8 12, glif 20, ders 13 700 (ders rengi), konu 15/22 600; çıkar düğmesi 40×40, X 18 `#556173` (erişilebilir ad "{konu}, çıkar").
  - Odaklı slot: `#E2EAF4` / `#0F294A`, 15/24 600, Plus 20 "Konu Ekle", odak halkası `.fr`.
- Boş saate dokununca konu sheet'i açılır. Konu yerleşince blok 250 ms (enter) ile belirir.

**Kare 3 · Konu seç (BottomSheet, `role=dialog` "Konu ekle")**
- Başlık `t20` "{Gün} {d} {Ay} · {saat}" (ör. "Pazartesi 12 Ekim · 16:00") + kapat `.xi`.
- Segment "Çantam" | "Dersler" + `c13 mu` "Çantam: denemelerinden çıkan eksik konuların."
- Radyo satırları (`.ro`): min yükseklik 56, padding 8 24, aralık 12. Grup başlığı 13/20 700 `#556173` (padding 12 24 0).
- Satırın sağında EksikTag; alt satırda `.tm` "Programda: Pzt 10:00" ya da "Son denemede 13 sorudan 9'u yanlış · Programda: Pzt 14:00".
- primary "Ekle".
- Çantam = eksik konular, derse göre gruplu. Programdaki konu işaretli ama yeniden eklenebilir. Dersler sekmesi tüm konuları listeler.

**Kare 4 · Ad ve motto**
- "Programına ad ver".
- "Program adı" (zorunlu) ve "Motto (isteğe bağlı)" (etiket üst boşluk 20; "(isteğe bağlı)" 500 `#556173`) + `.hp` "Program listesinde adın altında görünür.".
- Özet kartı (top 378, padding 4 16):
  - "Günler" → "12–17 Ekim 2026 · 6 gün"
  - "Çalışmalar" → "3 çalışma, hepsi Pazartesi" + `c13 mu` "Salı–Cumartesi henüz boş; kaydettikten sonra ekleyebilirsin."
- primary "Programı Kaydet". Kaydedince listeye "Program kaydedildi." toast'ıyla döner. Haptik `success`. Hata olursa toast çıkar ve form korunur (hata metni belirtilmemiş).

**Metinler**
- `stepOf` = "Adım {n}/3"
- `npDaysTitle` = "Hangi günler çalışacaksın?"
- `npDaysBody` = "Birden çok gün seçebilirsin; geçmiş günler seçilemez."
- `prevMonth` = "Önceki ay", `nextMonth` = "Sonraki ay"
- `today` = "Bugün"
- `daysSelected` = "{n} gün seçildi"
- `npGridTitle` = "Konuları yerleştir"
- `npGridBody` = "Boş bir saate dokun, konu seç. Izgara 06:00–23:00."
- `topicCount` = "{n} konu"
- `addTopic` = "Konu Ekle"
- `a11yEmptySlot` = "{time}, boş, konu ekle"
- `a11yRemoveTopic` = "{topic}, çıkar"
- `srcBag` = "Çantam", `srcLessons` = "Dersler"
- `bagHelp` = "Çantam: denemelerinden çıkan eksik konuların."
- `inProgramAt` = "Programda: {day} {time}"
- `lastExamWrong` = "Son denemede {total} sorudan {wrong}'u yanlış"
- `add` = "Ekle"
- `npNameTitle` = "Programına ad ver"
- `fieldProgramName` = "Program adı"
- `fieldMotto` = "Motto"
- `optional` = "(isteğe bağlı)"
- `mottoHelp` = "Program listesinde adın altında görünür."
- `summaryDays` = "Günler"
- `summaryStudies` = "Çalışmalar"
- `saveProgram` = "Programı Kaydet"
- `toastProgramSaved` = "Program kaydedildi."
- `discardConfirm` = "Program kaydedilmesin mi?" (normal onay; düğme metinleri ve gövdesi belirtilmemiş)

**Etkileşim:** Vazgeç (X) değişiklik varsa onay sorar.

**Veri ve backend**
- Ders ve konu ağacı → `/student/getAllMainSubjects`.
- Çantam (eksik konular + eksik sayısı + son deneme bağlamı) → olası `/student/getLessonsTotalMissing` ya da `getSubSubjects`; tam kaynak belirtilmemiş.
- Kaydet: `{name, motto?, dates[], items[{date, hour, subjectId, topicId}]}` → `/student/addNewProgram`.

**Koyu:** Yok.

### 3.6 Program · Düzenle, Sıfırla, İptal (4 kare) · route: `/home/program/:id` içinde edit modu (ayrı route önerilmez)

Bileşenler: ProgramItemRow (edit), ConfirmSheet (tehlikeli), Toast.

**Kare 1 · Düzenleme modu**
- Bar: geri gizli (`visibility: hidden`), sağda BarAction "Bitti". Değişiklikler anında kaydedilir; geri alınabilenler toast'la duyurulur.
- Satır:
  - Altı çizili saat düğmesi (offset 4; erişilebilir ad "Saat 10:00, değiştir"): saat seçici sheet açar (çizilmemiş).
  - Glif, ders, konu.
  - Çıkar düğmesi: 48 hedef, içinde 32'lik `.xi` + X 16. Erişilebilir ad "Fiilde Çatı, programdan çıkar".
- Listenin altında outline (Plus 20) "Konu Ekle": ızgara sheet'ini açar.
- En altta (space-between) danger text button'lar: "Günü Sıfırla" (ArrowCounterClockwise) ve "Programı İptal Et" (Trash).

**Kare 2 · Günü sıfırla onayı (tehlikeli ConfirmSheet)**
- Başlık: "Cumartesi'yi sıfırlayalım mı?"
- Gövde: "10 Ekim'deki 3 çalışma programdan çıkar. Diğer günler değişmez."
- Düğmeler: danger "Günü Sıfırla" + quiet "Vazgeç" (odak burada).

**Kare 3 · Sıfırlandı**
- Boş gün kartı (padding 20 16 8, ortalı): `b15 mu` "Bu gün için çalışma yok." + text button (Plus) "Konu Ekle".
- Toast "Cumartesi sıfırlandı." + "Geri Al": 6 sn (D-31).

**Kare 4 · Programı iptal onayı**
- Başlık: "Ekim 2. Hafta iptal edilsin mi?"
- Gövde: "Program listeden kalkar ve Anasayfa'daki Bugün bölümü boşalır. Bu işlem geri alınamaz."
- Düğmeler: danger "Programı İptal Et" + quiet "Vazgeç".
- Onaydan sonra Programım listesi + toast "Program iptal edildi.".

**Metinler**
- `done` = "Bitti"
- `a11yChangeTime` = "Saat {time}, değiştir"
- `a11yRemoveFromProgram` = "{topic}, programdan çıkar"
- `cancelProgram` = "Programı İptal Et"
- `resetDayTitle` = "{weekday}'yi sıfırlayalım mı?" (gün adına göre ek uyumu gerekli: "Cumartesi'yi")
- `resetDayBody` = "{date}'deki {n} çalışma programdan çıkar. Diğer günler değişmez."
- `cancel` = "Vazgeç"
- `emptyDay` = "Bu gün için çalışma yok."
- `toastDayReset` = "{weekday} sıfırlandı."
- `undo` = "Geri Al"
- `cancelProgramTitle` = "{programName} iptal edilsin mi?"
- `cancelProgramBody` = "Program listeden kalkar ve Anasayfa'daki Bugün bölümü boşalır. Bu işlem geri alınamaz."
- `toastProgramCancelled` = "Program iptal edildi."
- `toastTopicRemoved` = "Konu çıkarıldı."

**Hareket:**
- Çıkar: satır 250 ms (exit) kayar; toast + Geri Al.
- Sıfırla: satırlar 150 ms arayla söner; `success` yerine `selectionClick` (silme kutlanmaz).
- Onay sheet'i 350 ms; perdeye dokunmak Vazgeç sayılır.

**Neden:** Gün sıfırlamak ve programı iptal etmek tek dokunuşla olmamalı; ikisi de onaylı, biri geri alınabilir. D-26: tamamlama işareti yok; düzenleme yalnız plan içindir.

**Veri ve backend:** Güncellemeler → `/student/updateProgram`. Programı silme endpoint'i mevcut kodda yok (belirtilmemiş).

**Koyu:** Yok.

### 3.7 Programım · Durumlar (4 kare)

1. **Boş:**
   - Geri + `t24` "Programım"; arama ve Yeni Program yok.
   - Top 220, sol/sağ 32, ortalı: kil "Ampul" 128 (1.25), `t20` "Henüz programın yok" (üst boşluk 24), `b15 mu` (üst boşluk 8) "Haftalık programını kurduğunda günün konuları burada ve Anasayfa'da görünür.", primary "Haftalık Programını Kur" (üst boşluk 24).
2. **İskelet:**
   - Başlık ve arama hemen gelir. Satır iskeleti: 40×40 (radius 12), 140×18, 170×14, 100×14.
   - Parıltı 1200 ms. 15 sn'de veri yoksa hata.
3. **Hata** (ekran düzeyi, `role=alert`):
   - Top 240: 80'lik daire `#FCEAEA`, WarningCircle 40.
   - `t20` "Programların yüklenemedi" (üst boşluk 20) + `b15 mu` "Bağlantını kontrol edip tekrar dene." (üst boşluk 6).
   - quiet "Tekrar Dene" (üst boşluk 20) iskelete döner.
   - Bu karede "Programım" başlığı çizilmemiş.
4. **Çevrimdışı:**
   - OfflineStrip top 102.
   - BarAction "Yeni Program" pasif (`.s2.off`, `aria-disabled`).
   - Başlık top 158, arama 206, liste 270.
   - `c13 mu` (top 398) "Program kurmak ve düzenlemek için bağlantı gerekiyor. Kayıtlı programını görebilirsin."
   - Bağlantı gelince şerit "Bağlandın" der ve 2 sn sonra kalkar. Hata ve çevrimdışı hâllerde haptik yok.

**Metinler**
- `programEmptyTitle` = "Henüz programın yok"
- `programEmptyBody` = "Haftalık programını kurduğunda günün konuları burada ve Anasayfa'da görünür."
- `programsLoadError` = "Programların yüklenemedi"
- `checkConnectionRetry` = "Bağlantını kontrol edip tekrar dene."
- `programOfflineNote` = "Program kurmak ve düzenlemek için bağlantı gerekiyor. Kayıtlı programını görebilirsin."
- `connected` = "Bağlandın"

**Eskiden:** Yükleme, boş ve hata durumları yoktu; hata yalnız konsola yazılıyordu.

### 3.8 Programım · Hafta · Koyu (1 kare)

- Yapı 3.4 kare 4 ile aynı.
- Bar zemini `#0A1424`. Izgara çizgileri `#26354D`. Saat etiketi `#A9B5C6`.
- Bloklar koyu ders tonlarında (Türkçe `#2D211C` / `#E2A98D`, Tarih `#2C2513` / `#E3B651`, Coğrafya `#12293C` / `#7DB9EC`).
- Bugün çizgisi `#FF8533`. Segment koyu: `#213049`, seçili `#C5D4E8`. Kenar gölgesi `#0A1424` → transparent.
- **Neden:** D-14: gece planlama.

---

## 4. SMAP-04 · Kamera ve Optik Okuma (Tur 2)

Bileşenler: BottomSheet (izin), CameraOverlay, Handles, ProgressSheet, FormCheck, ErrorState.

**Route önerisi**
- Root navigator, tam ekran: `/scan` (çekim), `/scan/corners`, `/scan/upload`, `/scan/review` (Form Kontrol), `/scan/exam-not-found`, `/scan/error?type=formNotFound|offline|cameraUnavailable`.
- Sheet olarak (route yok): 4.1, 4.2, 4.10-2.
- Sonuç: `/scan/result/:examId` (5.1, bu grubun dışında).

### 4.1 Kamera İzni (2 kare): sheet, Anasayfa üstünde

**Ortak:** Sheet orta boy (1.20); perde scrim %48. Düğmeler primary + quiet (48, aralık 12). Haptik yok: izin bir hata değil.

**Kare 1 · İzin öncesi** (Okut düğmesine ilk dokunuşta, sistem izni sorulmadan önce)
- İçerik padding 24 24 0, ortalı.
- İşlevli görsel 160×170 (form ve çerçeve; neyin çekileceğini gösterir).
- `t20` başlık (üst boşluk 20) + `b15 mu` gövde (üst boşluk 8).
- Düğmeler: primary "Kameraya İzin Ver" + quiet "Sonra".
- Metinler 2.2-4 ile aynı (`camPrimerTitle`, `camPrimerBody`, `camPrimerAllow`, `camPrimerLater`).
- "Sonra" sheet'i kapatır, Anasayfa'da kalınır. "Kameraya İzin Ver" sistem kutusunu açar; sheet arkada kapanır.

**Kare 2 · İzin reddedildi** (kamera yerine bu açılır)
- 40'lık daire `#FCEAEA`, CameraSlash 22 (sw 18) `#C42D35`.
- `camDeniedTitle` = "Kamera izni kapalı"
- `camDeniedBody` = "Formunu okutabilmek için Ayarlar'da SMAP'e kamera izni ver. Sonra buraya dön; kaldığın yerden devam edersin."
- Düğmeler: primary `openSettings` = "Ayarları Aç" + quiet "Vazgeç".
- "Ayarları Aç" uygulamanın ayar sayfasına gider. Dönüşte izin kontrol edilir; verilmişse kamera 250 ms opaklık geçişiyle doğrudan açılır.

**Hareket:** Açılış 350 ms (duration-slow, enter); kapanış 250 ms (exit).

**Eskiden:** İzin ekranı yoktu; izin reddedilince kamera boş kalıyordu.

### 4.2 Öğretici (1 kare): uzun sheet, kamera üstünde

- **Arka plan:** Kamera karesi. Üst bar (top 54, yatay 8, 48 yükseklik): Kapat (`.ibc` X 20), ortada 15/24 600 `#FFFFFF` "Optik Form", "?" (`.ibc` Question 22, erişilebilir ad "Nasıl çekilir?").
- **Perde:** scrim koyu %64 (`rgba(2,6,14,.64)`).
- **Sheet:**
  - `t20` "Formu böyle çek" (kapat düğmesi yok).
  - Çizim kutusu: `#F2F4F7`, radius 16, padding 12, 330×250. Cevap alanı turuncu kesikli çerçevede (dash 10 7, `#E05500` / `#FF6600`); ders adları şeridi kırmızı taralı (`#C42D35`); numaralı rozetler.
  - Adım listesi (üst boşluk 12): satır padding 8 0, aralık 12; 28'lik numara dairesi `#E2EAF4` (navy-100), rakam `#0F294A` 15/28 700; metin `b16`.
  - Checkbox "Bir daha gösterme" + primary "Anladım".
- **Metinler:**
  - `tutTitle` = "Formu böyle çek"
  - `tutStep1` = "Cevap alanını çerçeveye al."
  - `tutStep2` = "Ders adlarının yazdığı yatay şeridi dışarıda bırak."
  - `tutStep3` = "Turuncu noktaları cevap alanının dört köşesine getir."
  - `dontShowAgain` = "Bir daha gösterme"
  - `gotIt` = "Anladım" (büyük harf yok)
  - `scanTopTitle` = "Optik Form"
  - `a11yHowToShoot` = "Nasıl çekilir?"
  - `close` = "Kapat"
- **Davranış:**
  - Kamera ilk açıldığında bir kez; kapanınca 4.3 aynen kalır.
  - "?" ile her zaman yeniden açılır; o zaman "Bir daha gösterme" görünmez (tek fark bu).
  - İlk açılışta kamera hazır olunca 350 ms'de gelir. "Anladım" ile 250 ms'de iner; önizleme kesilmez. Onay kutusunda `selectionClick`.
- **Veri:** Yerel bayrak (`tutorialSeen`).
- **Eskiden:** Tek sayfalık "sayfa göstergesi", büyük harfli "ANLADIM", rengi tutmayan "beyaz noktalar" metni (noktalar aslında turuncuydu).

### 4.3 Çekim (2 kare) · `/scan`

Kamera aşaması her temada koyudur; koyu kopyası ayrıca yok.

- **Üst bar:** Kapat ve "?" (48 hedef, 40 daire `rgba(10,20,36,.64)`), ortada "Optik Form". Eski logo ve "SMAP" yazısı kalktı.
- **CameraOverlay:**
  - Kılavuz çerçeve x 36–366, y 200–600 (330×400, oran 0,82).
  - Dışı karartılır: `rgba(0,0,0,.48)`.
  - Köşe işaretleri: 30'luk kollar, 5 pt `#FFFFFF`, round. Form bulununca `rgba(255,255,255,.35)`.
- **İpucu hapı** (`role=status`): top 112, padding 8 16, radius 16, `rgba(10,20,36,.80)`, `#FFFFFF` 15/24 600, ortalı.
- **Deklanşör:** top 726, 76×76; 4 pt beyaz halka içinde 60'lık `#FF6600` disk (orange-500). Erişilebilir ad "Fotoğraf çek". Her zaman çalışır: algılama bir öneri, zorunluluk değil.
- Flaş ve galeri yok (D-15).
- **Kare 1 · Aranıyor:** `scanHintSearching` = "Cevap alanını çerçeveye al.\nDers adları şeridi dışarıda kalsın."
- **Kare 2 · Form bulundu:**
  - Eklentinin bulduğu kenar turuncu dörtgen: dolgu `rgba(255,102,0,.10)`, çizgi `#FF6600` 3.
  - Köşe noktaları r 7 (14 pt), `#FF6600`, 3 pt beyaz kenar. Aynı noktalar 4.4'e taşınır.
  - İpucu: Check 20 `#52CC8E` + `scanHintReady` = "Hazır. Telefonu sabit tut ve çek."
- **Hareket:**
  - Kenar bulununca çerçeve köşeleri 150 ms'de saydamlaşır, dörtgen 150 ms'de belirir; ipucu çapraz geçişle değişir.
  - Deklanşörde `mediumImpact`; önizleme 100 ms donar; köşe ekranı 250 ms'de açılır.
  - Hareketi azaltta yalnız opaklık. İpucu `role=status` ile okunur.
- **Navigasyon:** Kapat → hedef belirtilmemiş (önceki sekme). "?" → 4.2. Deklanşör → 4.4. Okut "sonraki seferlerde" doğrudan buraya açılır (0.2).
- **Koç bağlamı:** Okutmadan önce öğrenci seçilir, sonuç onun hesabına yazılır (0.3). Seçim ekranı bu grupta çizilmemiş.
- **Veri:** Yerel kamera (mevcut `camerawesome` / `camera` / vendor `flutter_document_scanner`).

### 4.4 Köşe Düzenleme (2 kare) · `/scan/corners`

- **Üst bar:** Kapat + "Köşeleri Ayarla" (sağda 48 boşluk; "?" yok).
- **İpucu kartı (yalnız ilk kez):**
  - Top 110, yatay 16, `#18263D`, radius 16, padding 12, aralık 12, metin `#EDF1F6`.
  - Beyaz mini örnek 44×64 (radius 8, padding 4).
  - `b15` 600 `cornersHint` = "Noktaları cevap alanının köşelerine getir." + `c13 mu` `cornersHintSub` = "Ders adları şeridi dışarıda kalsın." + text button (40 yükseklik) "Bir daha gösterme".
  - Eski "Hatırlatma" diyaloğunun yerine geldi. "Bir daha gösterme" ipucunu kalıcı gizler; öğretici "?" ile her zaman açılır.
- **Handles:**
  - Dörtgen dışı `rgba(0,0,0,.55)`; kenar `#FF6600` 3.
  - Nokta 18 görünür (r 9), 48 dokunma alanı; sürüklerken 28 (r 14). Beyaz 3 pt kenar.
- **Kare 2 · Köşe sürükleniyor:**
  - Büyüteç `RawMagnifier`: 116 daire, 2,6 kat, 3 pt beyaz halka. Artı işareti `#FF6600` 2 pt, 20 uzunluk.
  - Parmağın üstünde açılır (çizimde noktaya göre +70 x, −150 y). İpucu sürüklerken gizlenir.
- **Alt bant:** 132 yükseklik, `rgba(10,20,36,.92)`, padding 16 16 0, aralık 12. Kamera düğme seti: outline "Tekrar Çek" (150 genişlik) + primary "Devam" (flex).
- **Metinler:** `cornersTitle` = "Köşeleri Ayarla", `retake` = "Tekrar Çek", `next` = "Devam".
- **Hareket:**
  - Büyüteç 100 ms'de ölçekle açılır, bırakınca 150 ms'de kapanır.
  - Nokta bir kenara oturunca `selectionClick`.
  - "Devam" ile fotoğraf kırpılır, gönderim ekranı 250 ms'de açılır.
  - "Tekrar Çek" kameraya döner; öğretici yeniden açılmaz.
- Kırpma ve düzenleme tek adımda; eklentinin ikinci "düzenleme" sayfası kalktı.
- **Eskiden:** İki ayrı sayfa, ardından kırmızı "GERİ" ve turuncu "GÖNDER" diyaloğu ("GÖNDER" yalnız devam demekti).

### 4.5 Gönderim (4 kare) + 4.6 Koyu (2 kare) · `/scan/upload`

**Düzen**
- Başlık bölgesi (`role=status`, `aria-live=polite`): top 78, yatay 16. `t24` başlık + `b15 mu` (üst boşluk 4).
- Fotoğraf kartı: top 168, left 95, 212 genişlik, padding 8, radius 16. Görüntü 196×238; erişilebilir ad "Okunan form görüntüsü: dört kolon, kırk satır". Gölge `0 2 8 rgba(15,41,74,.08)`, koyuda `rgba(0,0,0,.4)`.
- Adım listesi (ProgressSheet): kart top 450, yatay 16, padding 0 16.
  - Satır padding 16 0 (toplam 56), aralık 12, ayraç `#E8ECF1` (koyu `#26354D`).
  - Durum ikonu 24:
    - Bitti: `#0F294A` daire + Check 14 beyaz (koyu `#C5D4E8` + `#091A31`).
    - Sürüyor: spinner (iz `#DCE2E9`, yay `#0F294A`, stroke 3; koyu `#34445F` / `#C5D4E8`).
    - Bekliyor: inset 2 `#C3CBD6` halka (koyu `#34445F`).
    - Hata: WarningCircle `#C42D35` (koyu `#FF8F8F`).
  - Etiket `b16`: sürüyor 600; bekliyor `#556173` (koyu `#A9B5C6`); hata 600 + hata rengi. Sağda değer `b16` 700.
  - İlerleme çubuğu (üst boşluk 8): 8 yükseklik, radius 999. Ray `#E8ECF1` (koyu `#213049`), dolgu `#E05500` (koyu `#FF8533`, rayda 4,9:1).
- "Vazgeç" text button: top 774, ortalı.

**Kareler**
1. **Hazırlanıyor:** "Fotoğraf hazırlanıyor" (spinner) · "Gönderilecek" · "Cevaplar okunacak". Fotoğraf telefonda küçültülüp sıkıştırılır. Süre yazılmaz; yalnız gerçek adım gösterilir.
2. **Gönderiliyor:** "Fotoğraf hazırlandı" ✓ · "Gönderiliyor" + "%64" + çubuk (gerçek yükleme yüzdesi) · "Cevaplar okunacak". Bitmiş adım geçmiş zamanla yazılır.
3. **Okunuyor:** ✓ "Fotoğraf hazırlandı" · ✓ "Gönderildi" · spinner "Cevapların okunuyor" (belirsiz gösterge). 30 sn içinde yanıt yoksa kare 4.
4. **Gönderilemedi:**
   - Başlık "Formun gönderilemedi" + "Bağlantı koptu. Fotoğrafın duruyor; tekrar gönderebilir ya da yeniden çekebilirsin."
   - 2. adım "Gönderilemedi" (hata).
   - Düğmeler (top 704, aralık 12): primary "Tekrar Dene" + quiet "Yeni Fotoğraf".
   - Sayfa kapanmaz, fotoğraf kaybolmaz. Zaman aşımında aynı kalıp, gövde "Sunucu yanıt vermedi.".

**Metinler**
- `uploadTitle` = "Formun okunuyor"
- `uploadSub` = "Birkaç saniye sürebilir."
- `stepPreparing` = "Fotoğraf hazırlanıyor", `stepPrepared` = "Fotoğraf hazırlandı"
- `stepToSend` = "Gönderilecek", `stepSending` = "Gönderiliyor", `stepSent` = "Gönderildi", `stepSendFailed` = "Gönderilemedi"
- `stepToRead` = "Cevaplar okunacak", `stepReading` = "Cevapların okunuyor"
- `percent` = "%{n}"
- `uploadFailTitle` = "Formun gönderilemedi"
- `uploadFailBody` = "Bağlantı koptu. Fotoğrafın duruyor; tekrar gönderebilir ya da yeniden çekebilirsin."
- `uploadTimeoutBody` = "Sunucu yanıt vermedi."
- `newPhoto` = "Yeni Fotoğraf"
- `a11yInProgress` = "Sürüyor"
- `a11yUploadProgress` = "Gönderim"

**Etkileşim:** "Vazgeç" gönderimi durdurur ve fotoğrafla 4.4'e döner. Başarıda → Form Kontrol (4.7), sunucu okuma ve net sonrası (0.2).

**Hareket:**
- Adım değişimi 250 ms çapraz geçiş (standard); ilerleme çubuğu değeri anında izler.
- Çark 1200 ms; hareketi azaltta sabit yay + metin.
- Hata gelince `error` haptiği. Başarı haptiği burada değil, sonuç anında (5.1).
- Erişilebilirlik: adım değişince okunur; yüzde her %10'da bir duyurulur.

**4.6 Koyu farklar**
- Kanvas `#0A1424`, metin `#EDF1F6`, ikincil `#A9B5C6`.
- Kart `#121D31`; ray `#213049`; dolgu `#FF8533`; hata `#FF8F8F`.
- Birincil düğme `#C5D4E8` zemin, koyu metin.
- Gölge yerine ton farkı; fotoğraf kartında koyu gölge %40.
- **Neden:** D-14; kameradan hemen sonra beyaz ekran sıçraması olmasın. Akış ve metinler 4.5 ile birebir aynı.

**Veri ve backend**
- Görüntü yükleme: `opticimage` (`OmdRepository.sendOMImageToServer`). Yanıtta `answersArray`, `opticImageFileName`, `originalImageFileName`, `mexamFound`, `success`.
- Gerçek yüzde için upload progress callback gerekir. Mevcut `rest_api_package` desteği belirtilmemiş; Dio `onSendProgress` önerilir.

**Eskiden:** Yalnız "Denemeniz Analiz Ediliyor!" ve çark vardı; hata SnackBar'da "Hata: …" yazıp sayfayı kapatıyor, fotoğraf kayboluyordu.

### 4.7 Form Kontrol (4 kare) + 4.8 Durumlar (2 kare) · `/scan/review`

Akışın çekirdeği. Bileşenler: FormCheck, Segment (sayaçlı), QuestionCell düzeni, BottomSheet, Chip (kare).

**Düzen**
- Kapat (X 24, top 54, left 4). Kapatmak düzeltmeleri silmeden önce onay sheet'i açar: `exitScanConfirm` = "Okutmadan çıkılsın mı?" (düğmeler çizilmemiş).
- `t24` "Form Kontrol" (top 102) + `b15 mu` "Okunan cevapları formunla karşılaştır."
- Görüntü kartı (top 172, left 16, 370 genişlik, padding 12):
  - Sunucunun okuduğu görüntü 346×212.
  - "Formu büyüt" düğmesi: 48 hedef, 40 daire `rgba(255,255,255,.94)`, gölge `0 2 8 rgba(15,41,74,.16)`, MagnifyingGlassPlus 20 `#0F294A`.
  - `InteractiveViewer` 1–5 kat; çift dokunuş 2,5 kat.
- `c13 mu` (top 412) "İki parmakla yakınlaştırabilirsin."
- Özet satırı (top 444, aralık 16): `b16` 700 "160 cevap okundu" + 20'lik `#7E8A9B` daire (Minus 12) "2 boş". Düzeltme varsa ayrıca `#0F294A` PencilSimple 18 "2 düzeltme".
- Sayaçlı kolon segmenti (top 480): "1. kolon" … "4. kolon"; alt satır "boş yok" ya da "N boş". Kolon adı yerine sıra numarası kullanılır, çünkü deneme bu adımda henüz tanınmadı.
- `c13 mu` 600 (top 548) "3. kolon · 40 soru · düzeltmek için soruya dokun".
- Soru ızgarası (top 574, left 20): 5 sütun × 66, aralık 8.
  - Hücre 52 yükseklik, radius 8, padding 4 8, zemin `#FFFFFF`. Numara 13/16 600 `#556173`; harf 20/24 700 ortalı.
  - **Boş okunan:** `#FCF1D9` + 2 pt kesikli `#8A5A00` (padding 2 6); "–" `#556173`. Erişilebilir ad "12. soru, boş okundu, düzeltmek için dokun".
  - **Düzeltilen:** `#E2EAF4` + inset 2 `#0F294A`; harf `#0F294A`; sağ üstte PencilSimple 14. Erişilebilir ad "12. soru, düzeltildi: C".
  - Normal hücre erişilebilir adı: "1. soru, okunan B".
- Alt bant (114 yükseklik, `#FFFFFF`, üst çizgi `#DCE2E9`, padding 16 16 0, aralık 12): outline "Düzelt" (120 genişlik, PencilSimple 20) + primary "Cevapları Onayla" (flex).

**Cevap Düzelt sheet'i** (`role=dialog`; kolon → soru → şık)
- Başlık `t20` "Cevap Düzelt" + `c13 mu` 600 sayaç ("Düzeltme yok" ya da "N düzeltme"; başlıkta hep görünür) + kapat `.xi`.
- Gövde (padding 12 24 0, aralık 16):
  - "Kolon" + düz segment.
  - "Soru" + adım düğmeleri: quiet 48 Minus ("Önceki soru"), 88 genişlikte alan (`role=spinbutton`, ortalı 700), quiet 48 Plus ("Sonraki soru"). Yanında `c13 mu` "Okunan" + `b15` 600 değer (gri daire + "Boş").
  - "Formdaki işaretin" + kare çipler 48×48 A–E + "Boş" 64. Seçili lacivert dolgu.
  - primary "Düzeltmeyi Ekle": şık seçilmeden pasif.
  - Ayraç; `t17` "Düzeltmeler" (alt boşluk 8).
    - Boşken `b15 mu` "Henüz düzeltme yok. Okunan cevap formundakinden farklıysa yukarıdan ekle."
    - Liste satırı: min yükseklik 56, üst çizgi `#E8ECF1`. `b15` 600 "3. kolon · 12. soru" + `b15` "Boş → C" + IconButton X 20 (erişilebilir ad "Düzeltmeyi kaldır: 3. kolon, 12. soru").
- Alt boşluk 42.
- Soruya dokununca kolon ve soru dolu gelir; yalnız şık seçilir. Sheet 350 ms'de gelir; açılışta seçili soruya odak.

**Kareler**
1. Okunan form ve özet.
2. Sheet, boş liste (Soru 12, seçili C).
3. Sheet, iki düzeltme ("3. kolon · 12. soru Boş → C", "4. kolon · 31. soru Boş → A"); Soru 31 için şık seçilmemiş, Ekle pasif.
4. **Düzeltildi, gönderiliyor:** Özet "0 boş" + "2 düzeltme"; tüm kolonlar "boş yok". "Düzelt" pasif; primary spinner + "Gönderiliyor" (meşgul). "Cevapları Onayla" ayrıca soru sormaz.

**4.8 Durumlar**
1. **Görüntü yükleniyor:**
   - Görüntü yerine 346×212 iskelet (`bg-sunken`, parıltı 1200 ms) + `c13 mu` 600 "Form görüntüsü yükleniyor".
   - Izgara hemen çalışır, çünkü cevaplar yanıtla geldi.
   - 15 sn'de gelmezse kartta "Görüntü yüklenemedi · Tekrar Dene" (karesi çizilmemiş).
2. **Gönderilemedi:**
   - Satır içi uyarı (`role=alert`): top 684, yatay 16, `#FCEAEA`, radius 12, padding 12 16, aralık 12; WarningCircle 24 `#C42D35`; `b15` "Cevaplar gönderilemedi. Düzeltmelerin duruyor; tekrar dene."
   - Birincil düğme "Tekrar Dene" olur. Düzeltmeler kaybolmaz.
   - Çevrimdışıysa metin "Bağlantı yok. Bağlantı gelince tekrar dene."
   - Uyarı 250 ms'de aşağıdan açılır; haptik `error`. "Tekrar Dene" uyarıyı kapatır ve düğme meşgul olur.
- Boş durum yok: okunan form her zaman bir şey gösterir.

**Metinler**
- `reviewTitle` = "Form Kontrol"
- `reviewSub` = "Okunan cevapları formunla karşılaştır."
- `a11yZoomForm` = "Formu büyüt"
- `pinchHint` = "İki parmakla yakınlaştırabilirsin."
- `answersRead` = "{n} cevap okundu"
- `blankCount` = "{n} boş"
- `correctionCount` = "{n} düzeltme"
- `noCorrection` = "Düzeltme yok"
- `columnN` = "{n}. kolon"
- `noBlank` = "boş yok"
- `columnCaption` = "{n}. kolon · {q} soru · düzeltmek için soruya dokun"
- `fix` = "Düzelt"
- `confirmAnswers` = "Cevapları Onayla"
- `sending` = "Gönderiliyor"
- `fixSheetTitle` = "Cevap Düzelt"
- `fieldColumn` = "Kolon"
- `fieldQuestion` = "Soru"
- `readValue` = "Okunan"
- `blank` = "Boş"
- `yourMark` = "Formdaki işaretin"
- `addCorrection` = "Düzeltmeyi Ekle"
- `corrections` = "Düzeltmeler"
- `correctionsEmpty` = "Henüz düzeltme yok. Okunan cevap formundakinden farklıysa yukarıdan ekle."
- `correctionRow` = "{col}. kolon · {q}. soru"
- `correctionChange` = "{from} → {to}"
- `imageLoading` = "Form görüntüsü yükleniyor"
- `imageLoadFailed` = "Görüntü yüklenemedi"
- `answersSendFailed` = "Cevaplar gönderilemedi. Düzeltmelerin duruyor; tekrar dene."
- `answersOffline` = "Bağlantı yok. Bağlantı gelince tekrar dene."
- Erişilebilirlik: "Önceki soru", "Sonraki soru", "Soru numarası", "{n}. soru, okunan {x}", "{n}. soru, boş okundu, düzeltmek için dokun", "{n}. soru, düzeltildi: {x}", "Düzeltmeyi kaldır: {col}. kolon, {q}. soru"

**Hareket:** Şık seçiminde `selectionClick`. "Düzeltmeyi Ekle"de satır listenin başına 250 ms'de kayarak girer ve sayaç güncellenir. Başarı `success` sonuç anında (5.1); hata 4.8'de `error`.

**Navigasyon:** Onay → Karar "Deneme tanındı mı?": Evet → 5.1; Hayır → 4.9.

**Veri ve backend**
- Giriş: `answersArray` (4 kolon × 40 soru, örnek 160 cevap), `opticImageFileName` (görüntü URL'si).
- Gönderim: düzeltilmiş cevaplar → `answerArray` (`sendAnswerArrayToServer`) → `mexamFound`, `success`.
- Örnek veri (Ek C): 2 boş (3. kolon 12, 4. kolon 31); düzeltmeyle 0 boş; sonuç 86 D · 74 Y · 0 B.

**Koyu:** Yok.

**Eskiden:** "Düzenleme Yap", "Düzenlemeler (N)", "LİSTEYE EKLE", "Onaylıyor musunuz?"; iki ayrı sheet ve onay diyaloğu; iç kodlu SnackBar ("Gönderim hatası 590: …") ya da sunucu Left dönünce hiç mesaj yok.

### 4.9 Deneme Bulunamadı (4 kare) · `/scan/exam-not-found`

**Düzen**
- Kapat (X).
- `t24` başlık (top 102) + `b15 mu` gövde (üst boşluk 8).
- Bilgi kartı (üst boşluk 20, padding 12 16, aralık 12): Clock 24 `#36537C` (info) + `b15` metin.
- Alanlar (üst boşluk 28, aralık 20): "Yayınevi" ve "Deneme adı"; ikisi zorunlu; etiket üstte, örnek placeholder'da.
- primary "Analizimi Hazırlayın": top 784; klavye açıkken klavyenin üstünde kalır.

**Kareler**
1. **Boş form.**
2. **Doğrulama:** Alanlar 2 pt `#C42D35` + `.er` (WarningCircle 16): "Yayınevini yaz." / "Deneme adını yaz.". Odak ilk hatalı alana gider. Haptik `error`; alan 150 ms'de kırmızıya döner, sallanma yok.
3. **Onay (normal ConfirmSheet):**
   - `t20` "Talep oluşturulsun mu?".
   - Özet kutusu: `#F2F4F7`, radius 12, padding 4 16. Satırlar padding 12 0, ayraç `#DCE2E9`; dt `c13 mu` 600, dd `b16` 600 (üst boşluk 2).
   - `b15 mu` "Analizin hazır olunca Analizlerim › Denemelerim'de görünür."
   - Düğmeler: primary "Talebi Gönder" + quiet "Vazgeç".
4. **Talep alındı** (`role=status`, top 220, yatay 32):
   - 80'lik daire `#E4F4EA`, CheckCircle 40 `#0B6E3E`.
   - `t24` "Talebin alındı" (üst boşluk 24) + `b15 mu` (üst boşluk 8).
   - Tek düğme primary "Anasayfa".
   - Haptik `success`; ekran 250 ms çapraz geçişle değişir. Bildirim sözü verilmez (bildirimler planlı).

**Metinler**
- `enfTitle` = "Bu deneme henüz sistemde yok"
- `enfBody` = "Yayınevini ve deneme adını yaz; analizini en geç 72 saat içinde hazırlayalım."
- `enfSaved` = "Cevapların kaydedildi. Yeniden okutman gerekmez."
- `fieldPublisher` = "Yayınevi", `fieldPublisherHint` = "Örn: Örnek Yayınları"
- `fieldExamName` = "Deneme adı", `fieldExamNameHint` = "Örn: Türkiye Geneli Deneme 7"
- `enfSubmit` = "Analizimi Hazırlayın"
- `errPublisherRequired` = "Yayınevini yaz."
- `errExamNameRequired` = "Deneme adını yaz."
- `enfConfirmTitle` = "Talep oluşturulsun mu?"
- `enfConfirmNote` = "Analizin hazır olunca Analizlerim › Denemelerim'de görünür."
- `sendRequest` = "Talebi Gönder"
- `enfDoneTitle` = "Talebin alındı"
- `enfDoneBody` = "En geç 72 saat içinde hazır. Hazır olunca Analizlerim › Denemelerim'de görünecek."
- `goHome` = "Anasayfa"

**Veri ve backend:** `publisher`, `examName` + kayıtlı cevaplar → `examrequest` (`sendExamDetailToServer` → `success`).

**Koyu:** Yok.

**Eskiden:** "Denemen Henüz Sistemde Mevcut Değil", "Üzgünüz…"; doğrulama yoktu; ölü kalmış ikinci gönderim yöntemi.

### 4.10 Hata Ekranları (4 kare)

**Kalıp (tam ekran hata)**
- 80'lik rozet, başlık, tek cümle (neden + ne yapmalı), en fazla iki düğme. İç kod, "Hata:" öneki ve ham Exception metni yok.
- Rozet renkleri: hata `#FCEAEA` / `#C42D35`; bilgi `#E2EAF4` / `#36537C`; çevrimdışı `#E8ECF1` / `#3E4858`.
- Ekran 250 ms çapraz geçişle gelir. Odak birincil düğmede; Kapat her zaman sol üstte.
- Hata metni `role=alert`, bilgi metni `role=status` ile açılışta okunur.

**Kareler**
1. **Form bulunamadı** (`/scan/error?type=formNotFound`; sunucu cevap alanını seçemezse):
   - Rozet hata, WarningCircle 40. Kap top 200, yatay 32; `t24` (üst boşluk 24); `b15 mu` (üst boşluk 8).
   - Düğmeler (top 724): primary "Yeni Fotoğraf" + quiet "Nasıl Çekilir?" (4.2'yi açar). Haptik `error`.
2. **Optik okuma geçici olarak kapalı** (bilgi sheet'i, Anasayfa üstünde; kamera düğmesine basınca, kamera açılmadan):
   - 40'lık daire `#E2EAF4`, Wrench 22 + `t20` + `b15 mu`; tek düğme primary "Tamam".
   - Tahmini süre sunucu verirse eklenir; uydurulmaz. Haptik yok.
3. **Bağlantı yok (planlı):**
   - Rozet çevrimdışı, WifiSlash 40. Düğmeler: primary "Tamam" + quiet "Şimdi Tekrar Dene".
   - v1'de kuyruk yok; v1'de çevrimdışıyken 4.5'teki hata kalıbı açılır. Bu ekran kuyruk gelince kullanılır. Haptik yok.
4. **Kamera açılamadı** (kamera aşamasında olduğu için koyu, `.cm`):
   - Kapat `.ibc`. Rozet `#18263D` / `#EDF1F6`, CameraSlash 36. Kap top 260; başlık `t20`.
   - primary (kamera seti `#C5D4E8`) "Tekrar Dene" (top 784). Haptik `error`. Eklentinin kendi "No Camera" metni gösterilmez.

**Metinler**
- `formNotFoundTitle` = "Formu bulamadık"
- `formNotFoundBody` = "Fotoğrafta cevap alanı seçilemedi. Formun tamamı görünsün, ışık yansımasın, ders adları şeridi dışarıda kalsın."
- `howToShoot` = "Nasıl Çekilir?"
- `omrClosedTitle` = "Optik okuma şu an kapalı"
- `omrClosedBody` = "Kısa bir bakım yapıyoruz. Birazdan tekrar dene."
- `ok` = "Tamam"
- `offlineTitle` = "Bağlantı yok"
- `offlineQueuedBody` = "Fotoğrafın telefonunda saklandı. Bağlantı gelince gönderilecek."
- `retryNow` = "Şimdi Tekrar Dene"
- `cameraFailTitle` = "Kamera açılamadı"
- `cameraFailBody` = "Başka bir uygulama kamerayı kullanıyor olabilir. Onu kapatıp tekrar dene."

---

## 5. 11.14 Ekran–Bileşen Eşlemesi (bu gruba düşen satırlar)

| Pano | Bileşenler |
|---|---|
| 2.1 | Lockup, OnboardingPage, Button |
| 2.2 | RoleOption, Chip (kare, hap), InfoBox, Button, EmptyState görseli |
| 2.3 | DetailBar, Lockup, TextField (şifre), ErrorBox, Button (yükleniyor) |
| 2.4 | TextField, CodeInput, Button |
| 2.5–2.6 | Segment, AvatarPicker, TextField (canlı kontrol), SelectField, Checkbox, ErrorBox, InfoBox |
| 2.7 | ErrorState (ekran), ConfirmSheet, uygulama ikonu |
| 3.1–3.3 | HomeBand, SectionHeader, ProgramItemRow, ExamCard özeti, DybSmall, SubjectTile, EksikTag, BottomBar |
| 3.4 | DetailBar, BarAction, SearchField, Segment, DayChip, WeekGrid |
| 3.5 | Calendar, DayChip, HourSlot, BottomSheet, Radio, TextField |
| 3.6 | ProgramItemRow (edit), ConfirmSheet (tehlikeli), Toast |
| 3.7–3.8 | EmptyState (Ampul), Skeleton, ErrorState, OfflineStrip, WeekGrid |
| 4.1–4.10 | BottomSheet (izin), CameraOverlay, Handles, ProgressSheet, FormCheck, ErrorState |

Not: Koç ekranları öğrenci ekranlarını `StudentScope` ile yeniden kullanır (10.4). Koçta 3.4 salt okunur.

---

## 6. Tutarsızlıklar, belirtilmemiş değerler ve açık sorular

**Tutarsızlıklar**
1. **"Sonra" düğmesi:** 2.2-4'te text button, 4.1-1'de quiet button.
2. **Ekran düzeyi hata kalıbı:** 2.7'de 96'lık daire ve `display` 32/40; 4.10'da 80'lik rozet ve `t24` (kamera karesinde `t20`); 3.7'de 80 ve `t20`. Tek bir ErrorState spec'i seçilmeli.
3. **0.2 ile 4.9:** Yolculuk "Listeden seç ya da talep gönder" diyor; 4.9 panosunda listeden seçme yok, yalnız talep formu var.
4. **0.2 ile 4.10-3:** Yolculuk "bağlantı yoksa sırada" diyor; 4.10-3 "v1'de kuyruk yok, 4.5 hata kalıbı" diyor.
5. **shadow-raised:** 4.5 fotoğraf kartı `0 2 8 rgba(15,41,74,.08)` ile çizili; 4.7 büyüt düğmesi `0 2 8 rgba(15,41,74,.16)`. Token değeri belirtilmemiş.
6. **3.1-3 yeni kullanıcı:** Matematik ve Geometri karolarında "Web'de" etiketi de yok. Kasıtlı olup olmadığı belirtilmemiş.

**Belirtilmemiş değerler**
- Açılış spinner'ının ölçüsü.
- Splash'tan sonraki yönlendirme mantığı.
- "Geç" düğmesinin hedefi.
- Rol ekranında varsayılan seçim.
- 11, 12 ve Mezun için Devam Et'in pasif kuralı.
- Hoş geldin ve Kamera ön açıklamasında geri düğmesi (çizilmemiş).
- Giriş zaman aşımı hata metni.
- Şifremi Unuttum backend'i ve kod süresi.
- Kullanıcı adı kontrol spinner görseli.
- Sınav tarihinin kaynağı.
- "Analizi Gör" hedefi.
- Saat seçici sheet'i.
- "Program kaydedilmesin mi?" ve "Okutmadan çıkılsın mı?" onaylarının gövde ve düğme metinleri.
- Kayıt hatası toast metni.
- Program silme endpoint'i.
- Görüntü yüklenemedi kart çizimi.
- 4.3 Kapat hedefi.
- Koç için öğrenci seçici (Okut).
- Mağaza URL'si ve min sürüm kaynağı.
- "Destek'e Yaz" e-posta adresi.
- Upload progress desteği.

**l10n notu:** Türkçe ek uyumu gereken şablonlar var: "{topic}'nde", "{wrong}'unu", "{weekday}'yi", "{type}'ye". Ek seçimi için yardımcı fonksiyon ya da sunucudan hazır cümle gerekli.

**Mevcut backend'de karşılığı olanlar:** `/student/login`, `/student/register`, `/ajax/checkUser`, `/ajax/checkUsername`, `/ajax/getLegalDocuments`, `/ajax/logout`, `/ajax/getGeneralLessons`, `/student/getLessonsTotalMissing`, `/student/getMyWeeklies`, `/student/addNewProgram`, `/student/updateProgram`, `/student/getAllMainSubjects`, `/student/getMyMockExams`, `/student/getMexamSubjectDetail`, optik `opticimage`, `answerArray`, `examrequest`.

**Mevcut route'lar:** Kodda Navigator named routes `/onboarding`, `/login`, `/home` var. Yukarıdaki route önerileri bunları alias olarak koruyabilir.

---

Kaynak klasörler:
- docs/design/panolar/SMAP-00
- docs/design/panolar/SMAP-02
- docs/design/panolar/SMAP-03
- docs/design/panolar/SMAP-04
- docs/design/panolar/SMAP-11/13-11-14-Ekran-Bileşen-Eşlemesi
- Flutter mevcut kod: lib/main.dart, lib/repository/, lib/features/auth/data/datasources/auth_remote_data_source.dart

İkon adları ve sheet içerikleri işaretlenmiş, sadeleştirilmiş markup ağaçları (bu oturumun scratchpad klasöründe, geçici):
/private/tmp/claude-501/-Users-rasityilmaz-Desktop-WORK-smap/b90975f6-b800-481f-9352-bfe5ae28f159/scratchpad/out/t_SMAP-0*.txt