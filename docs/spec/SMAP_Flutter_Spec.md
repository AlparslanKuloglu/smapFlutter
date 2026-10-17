# SMAP Flutter Yeniden Tasarım: Uygulama Spesifikasyonu (v1)

Derleme: 11 Ekim 2026. Kaynak: SMAP-00…SMAP-12 panoları ve altı çıkarım raporu (tokens, components, screens-A/B/C, decisions). Bu belge tek doğruluk kaynağıdır; pano ile çelişirse §0.2 kuralı ve §6.1 kararları geçerlidir.

---

## 0. Kaynaklar ve nasıl okunur

### 0.1 Klasör ve dosya yolları

- **Pano kökü:** `docs/design/panolar/SMAP-NN/<sıra>-<pano-adı>/`. Her klasörde `board.html` (satır içi stiller, asıl ölçü kaynağı), `styles.css` (sınıf kütüphanesi), `text.txt` (metinler ve pano notları), `res/` (woff2 fontlar, js). Aynı adlı tek dosya sürümü: `unpacked/SMAP-NN/<sıra>-<pano-adı>.html`.
- **PNG:** `docs/design/panolar/png/SMAP-NN_<sıra>-<pano-adı>.png` (108 adet, pano başına bir). Örnek: `png/SMAP-05_00-5-1-Sonuç-Anı-3-kare.png`.
- **Grup tek dosyası:** `docs/design/SMAP-NN.html`.
- **Brif ve envanter (salt okunur):** `docs/design/tasarim-paketi/SMAP_Claude_Design_Brifi.md` (Ek D kararları satır 917–953), `.../tasarim-paketi/SMAP_Ekran_Envanteri.md`, `SMAP_Gorsel_Dil.md`, `SMAP_Ekran_Goruntuleri.md`, `ekranlar/`, `magaza/`.
- **Kod:** `` (`lib/`, `pubspec.yaml`); mihr_ui `mihr_ui paketi (pub) — lib/` (`components/buttons/`, `core/widgets/frosted_container.dart`, `core/theme/shadows/mihr_backdrop_blurs.dart`).
- **Geçici markup ağaçları (ikon adları işaretli):** `/private/tmp/claude-501/-Users-rasityilmaz-Desktop-WORK-smap/b90975f6-b800-481f-9352-bfe5ae28f159/scratchpad/out/t_SMAP-0*.txt`.

**Pano klasörleri (pano kodu → klasör adı; PNG adı `SMAP-NN_` + klasör adı):**

| Grup | Klasörler |
|---|---|
| SMAP-00 Akış | `00-0-1-Uygulamanın-Yolculuğu`, `01-0-2-Bir-Denemenin-Yolculuğu`, `02-0-3-Koçun-Yolculuğu` |
| SMAP-01 Kit | `00-1-1-Renk-Skalaları-lacivert-turuncu-nötr`, `01-1-2-Renk-Rolleri-açık-ve-koyu-tema`, `02-1-3-Kontrast-Matrisi-metin-zemin-çiftleri`, `03-1-4-Anlamsal-Renkler-D-Y-B-durum-grafik`, `04-1-5-Ders-Renkleri-9-ders-iki-tema`, `05-1-6-Tipografi-Plus-Jakarta-Sans`, `06-1-7-Şekil-Gölge-Boşluk`, `07-1-8-Hareket-ve-Haptik`, `08-1-9-Düğmeler-5-tür-2-boy`, `09-1-10-Segment-ve-Ekran-İçi-Sekme`, `10-1-11-Çipler-ve-Etiketler`, `11-1-12-Girdiler-6-tür-5-durum`, `12-1-13-Satır-ve-Seçim-Kontrolleri`, `13-1-14-D-Y-B-Ailesi`, `14-1-15-İlerleme`, `15-1-16-Kartlar-ve-Satırlar`, `16-1-17-Avatar-ve-İkonlar`, `17-1-18-Üst-Bar-Ailesi-6-kare`, `18-1-19-Alt-Çubuk-öğrenci-ve-koç-4-kare`, `19-1-20-Sheet-Çerçevesi-5-kare`, `20-1-21-Onay-ve-Yakında-Sheet-leri-3-kare`, `21-1-22-Toast-ve-Durum-Kalıpları-6-kare`, `22-1-23-Bileşen-Kiti-Koyu`, `23-1-24-Kabuk-ve-Yüzeyler-Koyu-5-kare`, `24-1-25-İllüstrasyon-Seti-ve-Mevcut-Varlıklar`, `25-1-26-Logo-Çalışması-S-rota` |
| SMAP-02 Açılış ve giriş | `00-2-1-Açılış-ve-Tanıtım-4-kare`, `01-2-2-Rol-Sınıf-ve-Alan-Kamera-Hoş-Geldin-5-kare`, `02-2-3-Giriş-4-kare`, `03-2-4-Şifremi-Unuttum-4-kare`, `04-2-5-Kayıt-3-kare`, `05-2-6-Kayıt-Durumlar-4-kare`, `06-2-7-Genel-Ekranlar-4-kare` |
| SMAP-03 Anasayfa ve program | `00-3-1-Anasayfa-3-kare`, `01-3-2-Anasayfa-Durumlar-4-kare`, `02-3-3-Anasayfa-Koyu-1-kare`, `03-3-4-Programım-4-kare`, `04-3-5-Yeni-Program-4-kare`, `05-3-6-Program-Düzenle-Sıfırla-İptal-4-kare`, `06-3-7-Programım-Durumlar-4-kare`, `07-3-8-Programım-Hafta-Koyu-1-kare` |
| SMAP-04 Kamera | `00-4-1-Kamera-İzni-2-kare`, `01-4-2-Öğretici-1-kare`, `02-4-3-Çekim-2-kare`, `03-4-4-Köşe-Düzenleme-2-kare`, `04-4-5-Gönderim-4-kare`, `05-4-6-Gönderim-Koyu-2-kare`, `06-4-7-Form-Kontrol-4-kare`, `07-4-8-Form-Kontrol-Durumlar-2-kare`, `08-4-9-Deneme-Bulunamadı-4-kare`, `09-4-10-Hata-Ekranları-4-kare` |
| SMAP-05 Deneme | `00-5-1-Sonuç-Anı-3-kare`, `01-5-2-Bildirim-İzni-1-kare`, `02-5-3-Deneme-Detay-Genel-3-kare`, `03-5-4-Deneme-Detay-Sorular-3-kare`, `04-5-5-Deneme-Detay-Konular-1-kare`, `05-5-6-Deneme-Detay-Kartlar-1-kare`, `06-5-7-Soru-Detay-2-kare`, `07-5-8-Deneme-Detay-Durumlar-4-kare`, `08-5-9-Deneme-Detay-Koyu-2-kare`, `09-5-10-Deneme-Detay-Konular-Koyu-1-kare` |
| SMAP-06 Analizlerim | `00-6-1-Analizlerim-Genel-3-kare`, `01-6-2-Denemelerim-3-kare`, `02-6-3-Analizlerim-Durumlar-4-kare`, `03-6-4-Analizlerim-Genel-Koyu-1-kare` |
| SMAP-07 Dersler | `00-7-1-Derslerim-3-kare`, `01-7-2-Ders-Detayı-3-kare`, `02-7-3-Konu-Detayı-3-kare`, `03-7-4-Edebiyat-Yazar-ve-Eserler-2-kare`, `04-7-5-Derslerim-ve-Konular-Durumlar-4-kare`, `05-7-6-Konu-Detayı-Koyu-1-kare` |
| SMAP-08 Kartlar | `00-8-1-Kart-Destesi-4-kare`, `01-8-2-Kart-Destesi-Koyu-1-kare` |
| SMAP-09 Hesap | `00-9-1-Hesap-4-kare`, `01-9-2-Profil-4-kare`, `02-9-3-Şifre-3-kare`, `03-9-4-Hesabı-Sil-5-kare`, `04-9-5-Koçluk-4-kare`, `05-9-6-Bildirimler-3-kare`, `06-9-7-Sözleşmeler-2-kare` |
| SMAP-10 Koç | `00-10-1-Koç-Anasayfa-4-kare`, `01-10-2-Öğrencilerim-4-kare`, `02-10-3-Öğrenci-Ekle-3-kare`, `03-10-4-Öğrenci-Profili-Koç-Bağlamında-4-kare`, `04-10-5-Görüşmelerim-4-kare`, `05-10-6-Görüşme-Notları-4-kare` |
| SMAP-11 Teslim | `00`…`10-11-N-Tur-N-…` (Tur 1–11 notları), `11-11-12-Token-Tablosu-Son-Hâl`, `12-11-13-Bileşen-Listesi`, `13-11-14-Ekran-Bileşen-Eşlemesi`, `14-11-15-Hareket-ve-Haptik-Tablosu`, `15-11-16-Bütün-Varsayımlar`, `16-11-17-Ek-Ekran-Akışı-ve-Onarımlar`, `17-11-18-Tur-12-Geri-Gelen-Özellikler`, `18-11-13-ek-…`, `19-11-14-ek-…`, `20-11-16-ek-Varsayımlar-Tur-12-Eki` (Tur 12 ekleri, T12.1–T12.30) |
| SMAP-12 Mağaza | `00-12-1-Panorama-7-kare`, `01-12-2-Kesimler-ve-Formatlar-App-Store-ve-Play`, `02-12-3-Önizleme-Şeridi-2-kare` |
| SMAP-13 Akışlar | `00-13-1-İlk-Açılış-ve-Kayıt` … `11-13-12-Genel-Ekranlar` (ekranlar arası geçişler; metni `panolar/AKIS.md`) |
| SMAP-14 Tur 12 | `00-14-1-…` … `11-14-12-Koyu-Kareler-D-G-4-Kare`, akışlar `12-13-13-…` (A–C) ve `13-13-14-…` (D–G). "Yerine geçtiği kare" etiketiyle eski kareleri geçersiz kılar |

### 0.2 Öncelik kuralı (çelişkide üstteki geçerli)

1. **Teslim panoları:** 11.12 Token Tablosu, 11.13 Bileşen Listesi, 11.14 Ekran–Bileşen Eşlemesi, 11.15 Hareket ve Haptik, 11.16 Bütün Varsayımlar.
2. Daha sonraki turun notlarındaki **G (genişletme) maddeleri** (Tur 10 > Tur 9 > … > Tur 1).
3. Daha sonraki turun **ekran markup'ı**.
4. SMAP-01 **kit panoları** (Tur 1).

Bu belgede çözülen çelişkiler `[Ç-n]` ile işaretli; tam liste ve gerekçe §6.1. Panoda olmayan ama bu derlemede verilen geliştirici kararları `[Karar]` ile işaretli.

### 0.3 Notasyon

- **Birim:** pt = Flutter logical px = pano px. Tasarım karesi iPhone 16 Pro, 402 × 874, telefon köşesi 56. Güvenli alan üst 62, alt 34; kodda her zaman `MediaQuery.padding` kullanılır, sabit değer yazılmaz.
- **Renk:** "açık / koyu". `ext.X` = `SmapColors` ya da `SmapText` ThemeExtension alanı.
- **Tipografi:** "boyut/satır · ağırlık · harf aralığı(pt)". Örn. `24/32 · 700 · −0,3`.
- **Dolgu:** CSS sırası (üst sağ alt sol). "12/16" = dikey 12, yatay 16.
- **y=**: 402 × 874 karede üstten mutlak konum; yalnız referans. Kod akış düzeniyle (Column/Sliver) kurulur.
- **belirtilmemiş:** panoda değer yok.
- **Kod kısaltmaları:** `x.y` pano; `T.n` varsayım (11.16); `D-n` brif Ek D kararı; `G-n` tur genişletmesi; "Ek C" örnek veri.
- **Örnek veri:** Alparslan Kuloğlu (öğrenci, 12. sınıf, EA), Mehmet Özkan (koç, kod MOZK-4821), 10 Ekim 2026 Cumartesi "bugün". Ekranlardaki sayılar örnek; hepsi sunucudan gelir.

### 0.4 Teslim okuma ve yapım sırası

- Okuma: 11.12 → 11.13 → 11.14 → 11.15 → 11.16; akış haritası 0.1–0.3.
- Yapım (Tur 10 "Uygulamada ilk iş"): önce `SmapColors` + `SmapText` (+ `SmapTokens`) → RootBand, DetailBar, BottomBar, BottomSheet, ConfirmSheet, Toast ve durum kalıpları (1.18–1.22) → ekranlar. Ayrıntılı katman sırası §2.Z.

---

## 1. Token'lar

**Genel kural (11.12):** Ekran kodu yalnız **rol adlarını** kullanır, skala adımını kullanmaz. Tema değişince rolün değeri değişir. Skala (`SmapPalette`) yalnız tema katmanında kullanılır.

### 1.1 Renk skalaları (1.1)

Koddaki 153 farklı renk kodu 3 skalaya indirildi. Oran = beyaz zemine karşı WCAG kontrastı.

**Lacivert `navy` (marka navy-900 = `#0F294A`)**

| Adım | Hex | Beyaza karşı | Türeyen roller |
|---|---|---|---|
| 50 | `#F1F5FA` | 1,09 | `bg-context` (açık) |
| 100 | `#E2EAF4` | 1,21 | `info-bg` (açık) |
| 200 | `#C5D4E8` | 1,50 | `text-on-navy-2`; `primary` (koyu) |
| 300 | `#9BB3D3` | 2,15 | koyu: `text-action`, `focus-ring`, `primary-pressed`, `delta`, `info`, `chart-line` |
| 400 | `#6C8BB6` | 3,50 | grafik serisi 3; iOS koyu ikon üst kanca |
| 500 | `#4A6A97` | 5,53 | belirtilmemiş |
| 600 | `#36537C` | 7,82 | `focus-ring`, `info`, `delta` (açık) |
| 700 | `#264066` | 10,46 | `chart-line` (açık) |
| 800 | `#1A3357` | 12,69 | `bg-navy-raised`, `text-action` (açık), girdi odak kenarı (açık) |
| 900 · marka | `#0F294A` | 14,62 | `bg-navy`, `primary` (açık), `on-accent` |
| 950 | `#091A31` | 17,45 | `primary-pressed` (açık), `on-primary` (koyu), açık `scrim` tabanı |

Eski değerler navy-900/800/700'e iner: `#0F294A` (66 yer), `#162A40` (23, kamera ve görüşme), `#0D2744` (16, giriş ve koç), `#1A365D`, `#10284A`, `#1E344A` (grafik), `#1F2937`, `#1A237E` (indigo, 11 yer). `#3D526D` ("Doğru" lacivert, 24 yer) D/Y/B sözlüğüne geçer. Logodaki `#2D3A54` yalnız logo dosyasında kalır.

**Turuncu `orange` (marka orange-500 = `#FF6600`)**

| Adım | Hex | Beyaza karşı | Kullanım |
|---|---|---|---|
| 50 | `#FFF4EC` | 1,08 | — |
| 100 | `#FFE6D4` | 1,20 | — |
| 200 | `#FFCBA6` | 1,46 | — |
| 300 | `#FFA76B` | 1,91 | — |
| 400 | `#FF8533` | 2,43 | koyu: `accent-line`, `chart-highlight` |
| 500 · marka | `#FF6600` | 2,94 | `accent` (kamera dolgusu, iki tema). Üstüne beyaz metin yazılmaz |
| 600 | `#E05500` | 3,84 | `accent-line`, `chart-highlight` (açık); beyaza karşı 3:1'i geçen ilk adım |
| 700 | `#B34400` | 5,61 | `text-accent` (açık) |
| 800 | `#8A3500` | 8,11 | — |
| 900 | `#662800` | 11,24 | — |
| 950 | `#3D1800` | 15,80 | — |

Kural: turuncu **dolgu** yüzeyde orange-500; ince gösterge, ilerleme dolgusu ve "bugün" orange-600; **metin** yalnız orange-700. Eski değerler bu kurala göre iner: `#FF6600` (96), `#FF7A00`, `#FF8A00`, `#FF6D00`, `#FF6F00`, `#F97316`, `#F68A3F`, SVG `#FF6400`, `Colors.orange` (29). Logodaki `#F16D38` logo dosyasında kalır.

**Nötr `neutral` (lacivert tonlu tek gri ailesi, ton 215°; 25 adımı yok, 0 adımı var)**

| Adım | Hex | Beyaza karşı | Kullanım |
|---|---|---|---|
| 0 | `#FFFFFF` | 1,00 | kart, sheet |
| 50 | `#F2F4F7` | 1,10 | kanvas |
| 100 | `#E8ECF1` | 1,19 | ray, iskelet |
| 200 | `#DCE2E9` | 1,30 | ayraç |
| 300 | `#C3CBD6` | 1,64 | pasif kenar |
| 400 | `#9AA5B4` | 2,50 | pasif metin |
| 500 | `#697586` | 4,68 | kontrol kenarı, placeholder |
| 600 | `#556173` | 6,28 | ikincil metin |
| 700 | `#3E4858` | 9,24 | çevrimdışı rozet ikonu (4.10) |
| 800 | `#2A3241` | 12,88 | — |
| 900 | `#1B2232` | 15,89 | birincil metin |
| 950 | `#0F1420` | 18,40 | — |

Eski → yeni: başlık `#1C1F33` → 900; ikincil `#8A90A6` (3,17) → 600; pasif sekme `#B2BAC6` (1,96) → 600; kanvas `#F5F7F9` → 50; `#E2E8F0`, `#E8ECF0`, `#E8EAED` → 200; Tailwind slate/gray ve `Colors.grey` (158 yer) bu skalaya iner.

### 1.2 Koyu tema yüzeyleri (skala dışı literal set)

Koyu tema açığın tersi değildir: yüzeyler lacivert tonlu ve yükseldikçe açılır; bant koyuda da navy-900 kalır. Oran `#121D31`'e karşı.

| Ad | Hex | Not |
|---|---|---|
| kanvas | `#0A1424` | aynı değer D/Y/B glifi |
| yüzey, kart, **girdi zemini** | `#121D31` | [Ç-6] girdi zemini `#121D31` (11.12) |
| üst yüzey, sheet | `#18263D` | |
| ray (sunken) | `#213049` | |
| ayraç | `#26354D` | |
| kontrol kenarı | `#6B7D97` | 4,02 |
| ikincil metin | `#A9B5C6` | 8,12 |
| birincil metin | `#EDF1F6` | 14,86 |
| border-strong, sheet tutamacı | `#34445F` | |
| placeholder | `#8B9AAF` | |
| disabled | `#56657C` | |
| bg-context, info-bg | `#1A2B45` | |
| scrim tabanı | `#02060E` | |
| text-accent | `#FF9A57` | orange skalasında yok |
| onError | `#3B0A10` | |

### 1.3 Renk rolleri (açık + koyu + Flutter)

Kontrast: zeminlerde birincil metne karşı; metin ve kenarlarda yüzeye karşı (açık `#FFFFFF`, koyu `#121D31`).

| Rol | Açık | Koyu | Flutter | Kullanım | Kontrast açık · koyu |
|---|---|---|---|---|---|
| `bg-canvas` | `#F2F4F7` | `#0A1424` | `surface` | Sayfa zemini, kartların arkası | 14,42 · 16,26 |
| `bg-surface` | `#FFFFFF` | `#121D31` | `surfaceContainerLowest` | Kart, liste grubu, girdi zemini | 15,89 · 14,86 |
| `bg-raised` | `#FFFFFF` | `#18263D` | `surfaceContainerLow` | Sheet | 15,89 · 13,38 |
| `bg-sunken` | `#E8ECF1` | `#213049` | `surfaceContainerHighest` | Segment ve ilerleme rayı, iskelet, sessiz düğme | 13,39 · 11,69 |
| `bg-navy` | `#0F294A` | `#0F294A` | `ext.navyBand` | Kök bant; açık temada toast | 14,62 (beyaz) |
| `bg-navy-raised` | `#1A3357` | `#1A3357` | `ext.navyBandRaised` | Bant üstü segment rayı | 12,69 (beyaz) |
| `bg-context` | `#F1F5FA` | `#1A2B45` | `ext.contextStrip` | Koç bağlam şeridi (Tur 10 yeni) | hesaplanan 14,52 · 12,55 |
| `bg-bar` | `#FFFFFF` %92 | `#121D31` %92 | `ext.bar` | Alt çubuk, arkası 20 bulanık | 15,89 · 14,86 |
| `scrim` | `#091A31` %48 | `#02060E` %64 | `scrim` | Sheet perdesi, arkası 8 bulanık | — |
| `border-subtle` | `#DCE2E9` | `#26354D` | `outlineVariant` | Ayraç, hücre ve kart kenarı (dekoratif) | — |
| `border-strong` | `#C3CBD6` | `#34445F` | `ext.borderStrong` | Pasif kontrol kenarı, sheet tutamacı | muaf |
| `border-control` | `#697586` | `#6B7D97` | `outline` | Girdi, çip, onay kutusu, kapalı anahtar | 4,68 · 4,02 |
| `text-primary` | `#1B2232` | `#EDF1F6` | `onSurface` | Başlık, gövde, değer; birincil ikon | 15,89 · 14,86 |
| `text-secondary` | `#556173` | `#A9B5C6` | `onSurfaceVariant` | Alt metin, etiket, eksen, pasif sekme; ikincil ikon | 6,28 · 8,12 |
| `text-placeholder` | `#697586` | `#8B9AAF` | `ext.textPlaceholder` | Yalnız girdi içi "Örn: …" | 4,68 · 5,89 |
| `text-disabled` | `#9AA5B4` | `#56657C` | `ext.textDisabled` | Pasif kontrol metni | muaf |
| `text-on-navy` | `#FFFFFF` | `#FFFFFF` | `ext.onNavyBand` | Bant başlığı ve eylemi | 14,62 |
| `text-on-navy-2` | `#C5D4E8` | `#C5D4E8` | `ext.onNavyBandVariant` | Bant alt metni, pasif bant segmenti | 9,72 |
| `text-action` | `#1A3357` | `#9BB3D3` | `ext.textAction` | Metin düğmesi, satır içi bağlantı (altı çizili) | 12,69 · 7,85 |
| `text-accent` | `#B34400` | `#FF9A57` | `ext.textAccent` | Gerekirse turuncu metin; açıkta asla orange-500 | 5,61 · 8,04 |
| `primary` | `#0F294A` | `#C5D4E8` | `primary` | Birincil düğme, seçili segment/çip, açık anahtar | 14,62 · 11,59 |
| `on-primary` | `#FFFFFF` | `#091A31` | `onPrimary` | Birincil üstü metin ve ikon | 14,62 · 11,59 |
| `primary-pressed` | `#091A31` | `#9BB3D3` | `ext.primaryPressed` | Basılı birincil | 17,45 · 8,13 |
| `accent` | `#FF6600` | `#FF6600` | `secondary` | Yalnız kamera düğmesi ve deklanşör dolgusu | 4,98 (ikon) |
| `on-accent` | `#0F294A` | `#0F294A` | `onSecondary` | Kamera ikonu (beyaz değil) | 4,98 |
| `accent-line` | `#E05500` | `#FF8533` | `ext.accentLine` | Konum göstergesi, ilerleme dolgusu, "bugün", grafik seçili nokta | 3,84 · 6,95 |
| `focus-ring` | `#36537C` | `#9BB3D3` | `ext.focusRing` | Odak halkası: 2 çizgi + 2 boşluk | 7,82 · 7,85 |
| `error` / `on-error` | `#C42D35` / `#FFFFFF` | `#FF8F8F` / `#3B0A10` | `error` / `onError` | Tehlikeli düğme | 5,56 · 7,74 |

### 1.4 `ColorScheme` (Tur 1, birebir; seed yok, gri seed `#7D858D` kalkar)

```dart
// açık
const smapLightColorScheme = ColorScheme(
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
);
// koyu
const smapDarkColorScheme = ColorScheme(
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
);
```

Değeri belirtilmemiş slotlar: `primaryContainer/onPrimaryContainer`, `secondaryContainer/on…`, `tertiary*`, `errorContainer/on…`, `surfaceDim`, `surfaceBright`, `surfaceContainer`, `surfaceContainerHigh`, `inverseSurface/onInverseSurface/inversePrimary`, `shadow`, `surfaceTint`. **[Karar]** `surfaceTint: Colors.transparent` (M3 tonal tint kapalı), `surfaceContainer`/`surfaceContainerHigh` = `bg-sunken`, `inverseSurface` = ters yüzey (açık `#0F294A`, koyu `#E8ECF1`), `onInverseSurface` = (açık `#FFFFFF`, koyu `#1B2232`). Kalanları Material varsayılanına bırak; ekran kodunda kullanılmaz.

`bg-bar` alfa: `Color(0xFFFFFFFF).withValues(alpha: .92)` / `Color(0xFF121D31).withValues(alpha: .92)` (≈ `0xEB…`).

### 1.5 Rol kuralları

- **Turuncunun yeri (1.2, Tur 10):** yalnız kamera düğmesi ve deklanşör (dolgu, kenar dörtgeni, köşe noktaları), konum göstergesi (alt çubuk, ekran içi sekme, sayfa noktası), ilerleme, "bugün", grafikte seçili/son nokta, logonun alt kancası. Segment, çip, düğme, anahtar, onay kutusu seçimleri **laciverttir**.
- **Kenar ya da gölge:** bir yüzeyde ikisinden yalnız biri. Kartlar kanvas üstünde kenarsız ve gölgesiz; ayrımı kanvas/yüzey farkı yapar.
- **Placeholder** kanvasta 4,25'e düşer; yalnız beyaz girdi zemininde. Etiket her zaman alanın üstünde.
- **Ters yüzey (rol adı yok, bileşen kuralı):** açık temada toast `bg-navy` zeminde (ikonlar koyu temanın durum renkleri: info `#C5D4E8`, success `#52CC8E`, error `#FF8F8F`). Koyu temada toast ve çevrimdışı şeridi `#E8ECF1` zemin + `#1B2232` metin (13,39); ikonlar açık temanın durum renkleri. **[Karar]** `SmapColors.inverseSurface/onInverseSurface` alanı olarak eklenir (§1.15).

### 1.6 D/Y/B tek sözlük (1.4 + 11.12)

Sıra her zaman Doğru → Yanlış → Boş. İkon şekli her ekranda aynı. Renk tek başına anlam taşımaz: çipin yanında her zaman etiket ya da harf (D, Y, B). Sayılar renkli yazılmaz, renk yalnız çipte. "Boş" hiçbir yerde siyah değil.

| | Doğru · D | Yanlış · Y | Boş · B |
|---|---|---|---|
| Token | `dyb-correct` → `dybCorrect` | `dyb-wrong` → `dybWrong` | `dyb-blank` → `dybBlank` [Ç-3] |
| Phosphor ikon | Check | X | Minus |
| Dolgu açık · koyu | `#0B6E3E` · `#52CC8E` | `#D8333A` · `#F07575` | `#7E8A9B` · `#6E7C92` |
| Hücre zemini açık · koyu | `dybCorrectBg` `#E4F4EA` · `#133325` (yalnız 1.4) | `dybWrongBg` `#FCEAEA` · `#3B1D22` | `dybBlankBg` `#E8ECF1` · `#213049` |
| Glif (`dybOn`) | `#FFFFFF` · `#0A1424` | aynı | aynı |
| Glif/dolgu kontrast | 6,34 · 9,12 | 4,71 · 6,59 | 3,50 · 4,36 |
| Metin olarak | Yalnız yanlış hücredeki doğru şık (`#0B6E3E` / `#FCEAEA` 5,46; koyu `#52CC8E`) | Kullanılmaz (hata metni `error`) | Kullanılmaz ("Boş" etiketi `text-secondary`) |

- Gri tonlamada açık `#606060` · `#747474` · `#898989`; koyuda açıklık sırası ters (D 0,47 · Y 0,33 · B 0,20).
- Yığılmış çubukta parçalar arası 2 pt boşluk.
- Kalkan eski sözlükler: Material+siyah (`#4CAF50/#F44336/#000000`), Tailwind (`#10B981/#EF4444/#94A3B8`), "Doğru lacivert" `#3D526D`, iOS (`#34C759/#FF383C`).

### 1.7 Delta, Eksik, Durum renkleri

| Token | Açık fg / bg | Koyu fg / bg | Kontrast | İkon | Kullanım |
|---|---|---|---|---|---|
| `delta` (Tur 10) | `#36537C` | `#9BB3D3` | — | ArrowUp / ArrowDown | Değişim değeri ve oku ("+8,25"). Yeşil yalnız Doğru'ya ayrıldı; yön ok ve işaretle okunur (sıralamada düşüş iyidir) [Ç-8] |
| `eksik` / `eksikBg` (Tur 5) | `#8A5A00` / `#FCF1D9` | `#F2C46D` / `#33270F` | 5,28 | Flag | EksikTag; kırmızı yanlış cevaba ayrıldı |
| `error` / `errorBg` | `#C42D35` / `#FCEAEA` | `#FF8F8F` / `#3B1D22` | 4,80 · 6,92 | WarningCircle | Hata metni, tehlikeli düğme ve onay |
| `success` / `successBg` | `#0B6E3E` / `#E4F4EA` | `#52CC8E` / `#15301F` [Ç-2] | 5,56 · 7,04 | CheckCircle | Başarı ikonu (şifre güncellendi, hesap silindi) |
| `warning` / `warningBg` | `#8A5A00` / `#FCF1D9` | `#F2C46D` / `#33270F` [Ç-1] | 5,28 · 8,97 | Warning | Uyarı kutusu, dikkat rozeti |
| `info` / `infoBg` | `#36537C` / `#E2EAF4` | `#9BB3D3` / `#1A2B45` | 6,45 · 6,63 | Info | Bilgi kutusu, ikon daireleri |

Kurallar (1.4): mesaj metni `text-primary`; durum rengi yalnız ikon ve kısa vurguda. Uyarı rengi koyu hardal, turuncuyla karışmaz. Sol kenar şeridi yok. Durum kutusu kit ölçüsü: radius 12, dolgu 12/16, ikon 24, aralık 12, metin 15/24 (ekranlardaki `SmapNoticeBox` ölçüsü §2 C39).

### 1.8 Grafik

| Token | Açık | Koyu | Not |
|---|---|---|---|
| `chartLine` | `#264066` | `#9BB3D3` | Net çizgisi 2,5 pt, düz parçalar (eğri yok) |
| `chartArea` | chartLine %10 | chartLine %14 | Çizgi altı alan |
| `chartHighlight` | `#E05500` | `#FF8533` | Son/seçili nokta |
| `chartGrid` | `#DCE2E9` | `#26354D` | Yatay ızgara 1 pt |
| `chartSeries[4]` | `#264066`, `#E05500`, `#6C8BB6`, `#7E8A9B` | belirtilmemiş ([Karar] `#9BB3D3`, `#FF8533`, `#6C8BB6`, `#6E7C92`) | Karşılaştırma |

Eksen metni `text-secondary` 13. Noktalar r 4,5, kenar 2 chartLine, dolgu yüzey rengi (açık `#FFFFFF`, koyu `#121D31`). Son nokta r 7, dolgu chartHighlight, kenar 2,5 yüzey rengi. Balon radius 8: açık zemin `#0F294A`, meta 13 `#C5D4E8`, değer 15/700 `#FFFFFF`; koyu zemin `#E8ECF1` (6.4'te `#EDF1F6`), meta `#556173` (6.4'te `#36537C`), değer `#1B2232` (6.4'te `#0A1424`) — [Ç-54] 6.4 markup değerleri (son pano). Ders serileri ders vurgusunu kullanır.

### 1.9 Ders renkleri (9 ders × 2 tema)

`SmapColors.subject: Map<Subject, (Color bg, Color fg)>`. **[Karar]** `enum Subject { turkce, edebiyat, tarih, cografya, matematik, geometri, fizik, kimya, biyoloji }`; sunucu ders kimliği → enum eşlemesi `lesson_constants.dart` üzerinden.

| Ders | Phosphor glif | Açık zemin · vurgu (oran) | Koyu zemin · vurgu (oran) | Eski açık (kalkar) |
|---|---|---|---|---|
| Türkçe | TextAa | `#F6ECE6` · `#93573C` (4,92) | `#2D211C` · `#E2A98D` (7,65) | `#F7EDE4` / `#A67762` |
| Edebiyat (Türk Dili ve Edebiyatı) | Feather | `#F6E7EC` · `#8A2F4E` (6,76) | `#301A27` · `#E494BE` (7,12) | `#F7F5E8` / `#D56C70` |
| Tarih | Bank | `#FBF1DA` · `#8C6106` (4,88) | `#2C2513` · `#E3B651` (8,02) | `#FFEED6` / `#EAA353` |
| Coğrafya | Globe | `#E1EFFA` · `#1E6FAE` (4,55) | `#12293C` · `#7DB9EC` (7,12) | `#D7EEFE` / `#3B97D3` |
| Matematik | MathOperations | `#FDE8E8` · `#C42A36` (4,79) | `#341B1B` · `#F7847F` (6,49) | `#FDE7E8` / `#FA4B56` |
| Geometri | Angle | `#E7E9FB` · `#4450BE` (5,56) | `#1D2144` · `#A3ABF4` (7,16) | `#CDE0FE` / `#3B69B0` |
| Fizik | Atom | `#DDF2F2` · `#08737A` (4,82) | `#0E2B2D` · `#5FCBD0` (7,80) | `#DBF4FF` / `#0276A4` |
| Kimya | Flask | `#F7E8F7` · `#93359A` (5,55) | `#271B33` · `#C89AE3` (7,12) | `#FFE5EB` / `#DB5669` |
| Biyoloji | Dna | `#E4F3E3` · `#2B7A35` (4,63) | `#16291A` · `#80CC89` (7,99) | `#D5F1CB` / `#12A335` |

Kurallar: ders adı her zaman `text-primary`; vurgu yalnız glif, nokta ve ilerlemede (metin rengi olmaz, tek istisna WeekGrid/HourSlot bloğundaki 13·700 ders adı). Ders rengi D/Y/B ya da durum anlamı taşımaz. Tarih-2 ve Coğrafya-2 ana dersin rengini kullanır, "Sosyal Bilimler 2 testi" alt satırıyla ayrılır. Matematik ve Geometri satırında rengin yanında nötr "Web'de" etiketi. Çok renkli illüstrasyon yerine tek renk Phosphor glif. Ders çipi noktası 10 pt; ilerleme dolgusu ders vurgusu, ray `bg-sunken` (en düşük oran 4,49).

### 1.10 Mevcut `AppColors` göçü (`lib/core/theme/app_colors.dart`)

| Mevcut | Değer | Yeni |
|---|---|---|
| `primaryOrange` | `#FF6600` | `accent` (yalnız kamera) |
| `background` | `#FFFFFF` | sayfa zemini `bg-canvas` `#F2F4F7`; beyaz = `bg-surface` |
| `menuCardBackground` | `#F5F7F9` | `bg-canvas` |
| `textPrimary` | `#1C1F33` | `text-primary` `#1B2232` |
| `textSecondary` | `#8A90A6` | `text-secondary` `#556173` |
| `navUnselected` | `#B2BAC6` | `text-secondary` |
| `navIndicator` | `#FF7A00` | `accent-line` |
| `navSelectedBg` | `#FFD4B3` | kalkar (alt çubukta tek gösterge) |
| `appBarBackground` | `#0F294A` | `ext.navyBand` |
| `unselectedGrey` | `#E2E8F0` | `border-subtle` |
| `accentOrange` | `#FF8A00` | turuncu kuralına göre 500/600/700 |
| `appBarBlueGrey` (seed) | `#7D858D` | kalkar |
| `shadowLight`/`shadowMedium`/`orangeShadow` | `0x14000000`/`0x16000000`/`0x33FF8A00` | `shadowRaised` / `shadowOverlay` |

`app_colors.dart` ve `app_theme.dart` göç bitince kalkar (avatar listesi satır 29–35 `avatars.dart`'a taşınır, §2.Y).

### 1.11 Tipografi (Plus Jakarta Sans)

- TTF varlık olarak gömülür (`assets/fonts/PlusJakartaSans-{Regular,Medium,SemiBold,Bold,ExtraBold}.ttf`, ağırlık 400/500/600/700/800); `google_fonts` ile indirme yok. **[Karar]** `pubspec` aile adı `PlusJakartaSans`. Pano `res/` içinde yalnız latin ve latin-ext woff2 var; TTF Google Fonts'tan (OFL) alınır.
- Satır yükseklikleri 4 pt ızgarada; Flutter `height` = satır/boyut. Bütün rakam taşıyan stillerde `FontFeature.tabularFigures()`.

| Stil | Boyut/satır | Ağırlık | Harf ar. | `height` | Flutter | Kullanım |
|---|---|---|---|---|---|---|
| `display` | 32/40 | 800 | −0,5 | 1.25 | `displaySmall` | Tanıtım ve genel ekran başlığı, 2.x başlıkları, sonuç başlığı; en çok 2 satır |
| `title-lg` | 24/32 | 700 | −0,3 | 1.3333 | `headlineSmall` | Kök bant başlığı, detay sayfası başlığı |
| `title-md` | 20/28 | 700 | −0,2 | 1.4 | `titleLarge` | Sheet başlığı, bölüm başlığı, boş durum başlığı, deneme adı |
| `headline` | 17/24 | 700 | −0,1 | 1.4118 | `titleMedium` | Alt başlık, kısa bar başlığı |
| `title-sm` | 16/24 | 600 | 0 | 1.5 | `titleSmall` | Satır ve kart başlığı; 2 satıra kadar sarılır |
| `body-lg` | 16/24 | 400 | 0 | 1.5 | `bodyLarge` | Girdi değeri, madde metni |
| `body-lg-reading` [Ç-50] | 16/26 | 400 | 0 | 1.625 | `ext.bodyReading` | Okuma metni: tanıtım gövdesi, konu tanımı, örnek, sözleşme, yazar, kart gövdesi, boş/durum gövdesi |
| `body` | 15/24 | 400 | 0 | 1.6 | `bodyMedium` | Gövde, açıklama, sheet metni |
| `body-strong` | 15/24 | 600 | 0 | 1.6 | `ext.bodyStrong` | Gövde vurgusu, liste değeri, program saati |
| `caption` | 13/20 | 500 | 0 | 1.5385 | `bodySmall` | Meta, yardım, eksen, etiket |
| `label-lg` | 16/24 | 600 | 0 | 1.5 | `labelLarge` | 48 pt düğme |
| `label-md` | 14/20 | 600 | 0 | 1.4286 | `labelMedium` | 40 pt düğme, segment, girdi etiketi |
| `label-sm` | 12/16 | 600 | 0 | 1.3333 | `labelSmall` | Yalnız alt çubuk etiketi |
| `metric-xl` | 56/64 | 800 | −1,5 | 1.1429 | `ext.metricXl` | Sonuç anı neti |
| `metric-lg` | 40/48 | 800 | −1 | 1.2 | `ext.metricLg` | Deneme Detay ve Anasayfa neti, YKS sayacı |
| `metric-md` | 24/32 | 700 | −0,4 | 1.3333 | `ext.metricMd` | StatBox, puan, koçluk kodu, tarih bloğu, sıra, DybLarge değeri, ExamRow neti |
| `metric-sm` | 17/24 | 700 | 0 | 1.4118 | `ext.metricSm` | Test (ders) neti, öğrenci "son net" |

Ölçek dışı ama bileşende onaylı birleşimler (yalnız ilgili bileşende): 13/20·600 ve 13/20·700 (etiket, "Örnek", EksikTag, sayaç), 15/20·700 (küçük D/Y/B sayısı), 20/24·700 (soru hücresi işareti), 15/22 (NoticeBox metni), 13/16·600 (hücre doğru cevabı, DayChip "2 konu"), 15/20·600 (StudentTile adı), 14/20·700 (sayaçlı segment başlığı), 20/40·500 ve 24/40·700 (TimeWheel), 32/40·800 (Soru Detay şıkkı).

**Birim eşlemesi (1.6):** "67,5" metric-xl + "net" 17/24/600; "412,63" metric-md + etiket; sayı ile birim arası `space-4`…8. **Tur 10 hizalaması:** tanıtım/genel ekran başlığı display; Anasayfa neti metric-lg; program saati body-strong; tarih bloğu metric-md. Kalkan değerler: 26/34 başlık, 32/40 rakam, 15/700 saat, 20/800 gün. Deneme Detay neti metric-lg, puan metric-md [Ç-5].

**Boyut ve erişilebilirlik (1.6):**
- Gövde ≥ 15 pt, ikincil ≥ 13 pt. Tek istisna `label-sm` 12 (alt çubuk); büyük metinde `FittedBox(scaleDown)` ile küçülür, uzun basışta büyük ikon+ad balonu açılır.
- Metin %130'a kadar büyür; satır sarılır, yükseklik içerikle büyür, ad kesilmez, sabit yükseklik yok.
- Büyük harf yalnız `tr` dönüşümüyle (i → İ), `toUpperCase()` değil. Büyük harfli düğme ve harf aralıklı üst etiket yok.
- Glif testi: "İı Şş Ğğ Çç Öö Üü · İstanbul".

**Sayı ve tarih biçimi (Tur 1 kodu, birebir):**

```dart
final net  = NumberFormat('#,##0.##', 'tr'); // 67,5 · 74,75 · 68
final puan = NumberFormat('#,##0.00', 'tr'); // 412,63 · 381,40
final sira = NumberFormat('#,##0', 'tr');    // 48.215 → "48.215. sıra"
String yuzde(int d, int toplam) => '%${(d * 100 / toplam).round()}'; // 5/12 → %42
String kisaTarih(DateTime t) => '${t.day} ${DateFormat('MMM', 'tr').format(t)}.'; // 5 Eki.
DateFormat('d MMMM y', 'tr') // 15 Eylül 2026
DateFormat('EEE', 'tr')      // Pzt Sal Çar Per Cum Cmt Paz
```

- Net çeyrek adım, sondaki sıfır yok (68 · 67,5 · 74,75). Puan 2 hane. Yüzde yuvarlanır, işaret önde (%42). Sıra "48.215." + "Sıra"/"sıra".
- Değişim işaretli: "+8,25". **[Karar]** [Ç-53] negatif işaret U+2212 "−" ("−1,25"); ok yönü ArrowDown.
- Uzun tarih "15 Eylül 2026"; yıllı gün "12 Ekim 2026 Pazartesi"; kısa "5 Eki.", gerekirse "5 Eki. 2026". Saat 24 saat "16:00".
- `DateFormat('MMM','tr')` çıktısı noktasız olmalı ("Eki"); noktayı yardımcı ekler. Mayıs/Haziran kısaltmaları panoda "May." ve "Haz.", Ağustos "Ağu.", Eylül "Eyl.", Nisan "Nis.".
- **Ek uyumu** gereken şablonlar: "{topic}'nde", "{wrong}'unu", "{weekday}'yi", "{type}'ye", "{name}'ın verileri", "{name}'a bağlandın". **[Karar]** `smap_format.dart` içinde `TurkishSuffix` yardımcısı (son ünlü/ünsüz uyumu + rakam okunuşu: 9 → "dokuz" → 'unu') yazılır.
- **Arama katlama:** `s.toLowerCase()` yerine tr-TR: İ→i, I→ı; ardından ı→i; ad/soyad token'larında önek eşleşmesi; vurgulama özgün metin aralığında.

### 1.12 Şekil, boşluk, ölçü, yükselti, kenar, odak

**Köşe yarıçapı (22 değer → 6 token)**

| Token | Değer | Kullanım |
|---|---|---|
| `radius-xs` | 4 | Onay kutusu, grafik çubuğu ucu, arama vurgusu |
| `radius-sm` | 8 | Segment başparmağı, soru hücresi, etiket, **kapak küçük resmi** [Ç-20], ipucu/grafik balonu, iskelet bloğu |
| `radius-md` | 12 | Düğme, girdi, segment rayı, glif karosu, banner, toast, durum kutusu, DayChip |
| `radius-lg` | 16 | Kart, liste grubu, istatistik kutusu, kamera düğmesi |
| `radius-xl` | 24 | Sheet üst köşeleri, kök bant alt köşeleri, alt çubuk üst köşeleri, çalışma kartı |
| `radius-full` | 999 | Çip, rozet, avatar, ilerleme çubuğu, anahtar, tutamaç |

Eski → yeni: 2–5 → xs · 6–10 → sm · 12–15 → md · 16–20 → lg · 22–32 → xl · 99/100/999 → full. İç içe yüzeyde iç = dış − aradaki boşluk (16'lık kartta 8 boşlukla iç 8). İstisnalar: CardPreview glif karosu 32'de radius 10 (5.6), Calendar lejant karesi radius 6, OnboardingPage görsel kartı 28, kil karosu kendi köşesi 28/140, app ikon 96'da 21,5.

**Boşluk (4 pt ızgara):** `space-4` (ikon–etiket, sayı–birim) · `8` (çipler arası, düğmede ikon–etiket) · `12` (satır dikey dolgusu, başlıktan içeriğe) · `16` (sayfa kenarı, kart dolgusu) · `24` (bölüm içi grup, sheet yatay dolgusu, form alanları arası) · `32` (bölümler arası) · `48` (dokunma, boş durum çevresi) · `64` (ekran düzeyi boş durum üstü). Sayfa kenarı: 3.x–10.x ekranları 16; 2.x (giriş/kayıt) ekranları 24. Eskiden kenar 16/20/24/40 arasında değişiyordu.

**Sabit ölçüler (1.7 + Tur 1)**

| Öğe | Değer |
|---|---|
| Dokunma hedefi | 48 × 48; görseli 40 olanlarda 4 pt görünmez pay (`MaterialTapTargetSize.padded`) |
| Liste satırı | tek satır ≥ 56, iki satır ≥ 72 |
| Kök bant (güvenli alan dahil) | 134 açık · bantta segment ya da sekme varsa 174–178 · küçülmüş 110 |
| Detay barı kısa hâli (güvenli alan dahil) | 102–110 (62 + 48 satır) |
| Alt çubuk | 68 + 34 güvenli alan = 102 |
| Kamera düğmesi | 56 × 56, radius-lg, 16 yukarı |
| Sheet tutamacı | 36 × 4, üstten 8 |
| Girdi | 48 yükseklik, radius-md, yanlarda 16; etiket 8 üstte, yardım/hata 6 altta |
| Çip | 36/40/48 görünür, 48 dokunma |
| İkon | 20 (düğmede), 24 (yalnız ikon), etiketten 8 (düğme) / 6 (çip, bar düğmesi) |
| Klavye | 336 (yalnız şematik) |

**Gölge (57 → 2 token)**

| Token | Açık | Koyu | Kullanım |
|---|---|---|---|
| `shadowRaised` | `BoxShadow(offset: Offset(0,2), blurRadius: 8, color: Color(0xFF0F294A).withValues(alpha: .08))` | `Colors.black.withValues(alpha: .40)` | Kamera düğmesi, büyüteç, büyüt düğmesi [Ç-45], gönderim fotoğraf kartı, arka deste kartı |
| `shadowOverlay` | `Offset(0,8)`, `blurRadius: 24`, `#0F294A` %16 | `#000` %56 | Toast, grafik balonu, sürüklenen çalışma kartı |

`spreadRadius` 0. Kurallar: bir yüzeyde kenar ya da gölge; kartlarda ikisi de yok; alt çubuk gölge yerine üst ayraç (1 pt `border-subtle`); sheet perdeyle ayrılır, gölgesi yok; koyu temada yükselti yüzey açılmasıyla. OnboardingPage görselleri kendi gölgesini taşır (`0 12 32 #0F294A %16`; ExamCard özeti %12; bilgi kartı `0 16 32 %18`) — yalnız tanıtım görselinde.

**Bulanıklık [Ç-51]:** yalnız alt çubuk (σ 20) ve sheet perdesi (σ 8); başka yerde `BackdropFilter` yok. CSS `blur()` değeri σ kabul edilir: `ImageFilter.blur(sigmaX: 20, sigmaY: 20)` / `(8, 8)`; mihr_ui `MihrBackdropBlurs.xl` (σ20) / `.md` (σ8). `FrostedContainer.overlayColor` her zaman `bg-bar` ya da `scrim` ile ezilir (mihr'in %60 beyaz/siyah varsayılanı kullanılmaz).

**Kenarlar**

| Öğe | Değer |
|---|---|
| Ayraç, hücre, kart kenarı (dekoratif) | 1 `border-subtle` |
| Girdi | 1 `border-control` |
| Girdi odak | 2 (1 kenar + 1 iç gölge), açık `#1A3357`, koyu `#9BB3D3` (= `textAction`) |
| Girdi hata | 2 `error` |
| Girdi pasif | zemin `bg-canvas`, kenar `border-strong`, metin/etiket `text-disabled` |
| Girdi salt okunur | zemin `bg-sunken`, kenar saydam, metin tam kontrast, Lock 20 `text-secondary` |
| Çip | 1 `border-control` (içe) |
| İkincil düğme | yüzey + 1,5 `primary` (içe) |
| Sheet tutamacı | `border-strong`; meşgulken `bg-sunken` |
| Avatar yığını | 2 beyaz halka, 8 bindirme; seçili avatar boşluk + 2 lacivert halka |

**Odak halkası [Ç-52]:** 2 boşluk + 2 halka: `box-shadow: 0 0 0 2 <altta kalan yüzey rengi>, 0 0 0 4 focusRing`. Açık `#36537C`, koyu `#9BB3D3`; koyuda boşluk rengi altta kalan yüzey (sheet'te `#18263D`). Metin düğmesinde boşluksuz `0 0 0 2`. Segmentte içe `inset 0 0 0 2`. Girdilerde ayrı halka yok, kenarla gösterilir.

### 1.13 Hareket ve haptik (11.15 son hâl)

**Süre:** `instant` 100 (basılı durum: renk + 0,98 ölçek) · `fast` 150 (anahtar, çip, onay kutusu, ikon Regular→Fill; hareketi azaltta opaklık) · `base` 250 (segment başparmağı, gösterge, akordeon, toast, ekleme/çıkarma) · `slow` 350 (sheet açılış, sayfa geçişi, ilk eksiğe kaydırma) · `loop` 1200 (iskelet parıltısı, spinner turu).

**Eğri:** `standard` `Cubic(0.2, 0, 0, 1)` (yerinde değişim) · `enter` `Cubic(0, 0, 0, 1)` (giren öğe) · `exit` `Cubic(0.3, 0, 1, 1)` (çıkan öğe; süre girişin %70'i) · `linear` (iskelet, gönderim yüzdesi, kaydırmaya bağlı küçülme).

| Etkileşim | Ne hareket eder | Süre | Eğri | Haptik | Hareketi azalt |
|---|---|---|---|---|---|
| Düğme basılı | Bir ton koyulaşır, 0,98'e küçülür | 100 | standard | — | aynı |
| Segment, sekme, alt çubuk | Başparmak/gösterge kayar, etiket rengi çapraz geçer; alt çubukta ikon Regular→Fill 150; sekmede içerik 150 ms çapraz geçiş [Karar: 5.3 değeri], seçili sekme görünür alana kaydırılır | 250 | standard | selectionClick | opaklık 150 |
| Çip, anahtar, onay kutusu, radyo | Dolgu ve işaret belirir, anahtar başı kayar | 150 | standard | selectionClick | aynı |
| Akordeon | Yükseklik açılır, ok 180° döner; açılan bölüm görünür alana gelir | 250 | standard | — | anında |
| Sheet açılış/kapanış | Alttan kayar, perde %0→%48; parmağı izler; %25'ten fazla iniş ya da fırlatma kapatır ([Karar] hız eşiği 700 px/sn); meşgulken sürükleme kapalı | 350 / 250 | enter / exit | — | opaklık 150 |
| Toast | Alt çubuğun 8 üstünde, 16 yukarı kayarak; 4 sn, Geri Al'lı 6 sn; yukarı kaydırınca kapanır; tek toast | 250 | enter / exit | hata türünde error | opaklık |
| Küçülen bant/bar | Başlık 24→17, bant 134→110 | kaydırmaya bağlı (56) | linear | — | aynı |
| İskelet | Soldan sağa parıltı; 15 sn'de veri yoksa hata | 1200 döngü | linear | — | parıltı durur |
| Deklanşör / kamera düğmesi | 0,92'ye küçülüp döner | 100 | standard | mediumImpact | ölçek yok |
| Sonuç anı / okuma başarılı | Sayılar anında; içerik 250 ms'de 8 pt yukarı kayarak belirir; dönen sayaç ve konfeti yok | 250 | enter | success (bir kez) | yalnız opaklık |
| Form/giriş hatası | Kenar 150'de kırmızı, hata metni belirir, odak ilk hatalı alana; alan sarsılmaz; yalnız kod kutuları sallanır [Ç-7] ([Karar] genlik ±6 pt, 3 salınım) | 150 | standard | error | sallanma yok |
| İlk eksiğe / hatalı alana kaydırma | `Scrollable.ensureVisible` | 350 | standard | — | `jumpTo` |
| Kart kaydırma (8.1) | Parmağı izler; eşik genişliğin %30'u ya da 800 px/sn | 250 çıkış | standard | — | çapraz geçiş |
| Öğrendim (8.1) | Kart sağa çıkar | 250 | exit | success | opaklık |
| Program bloğu ekle/çıkar (3.5–3.6) | Blok belirir/kayar | 250 | enter/exit | selectionClick | opaklık |
| Günü Sıfırla (3.6) | Satırlar 150 aralıkla söner | 150 aralık | exit | selectionClick | anında |
| Çevrimdışı şeridi | İner; bağlanınca 2 sn "Bağlandın" [Ç-23] | 250 | enter | — | opaklık |
| Sayfa geçişi | Platform: iOS sağdan kayma + kenardan geri, Android sistem geri | 350 | platform | — | opaklık |
| Grafik süzgeç değişimi | Yeniden çizilir | 350 | standard | selectionClick | anında |
| StackedBar ilk açılış | Çubuklar dolar | 350 | standard | — | son hâl |
| Hesabı Sil | Tam ekran spinner, geri kapalı | — | linear | — | aynı |

Diğer zamanlamalar: program araması 150 ms gecikme; öğrenci/görüşme araması 150 ms; kullanıcı adı kontrolü 400 ms gecikme, istek iptal edilebilir; Geri Al toast'u 6 sn.

**İskelet renkleri:** blok `bg-sunken` (açık `#E8ECF1`, koyu `#213049`), radius 8 (grafik bloğu 12). Parıltı: 120 genişlikte `rgba(255,255,255, 0 → .65 → 0)` (1.22); kit gradyanı `linear-gradient(90deg, #E8ECF1, #C3CBD6, #E8ECF1)`. **[Karar]** koyu parıltı `rgba(255,255,255, 0 → .06 → 0)`.

**Haptik sözlüğü**

| Haptik | Ne zaman | Uygulama |
|---|---|---|
| `selectionClick` | Seçim değişti: segment, sekme, alt çubuk, çip, anahtar, onay kutusu, radyo, şık, köşe oturması, program bloğu ekle/çıkar, Günü Sıfırla, pull-to-refresh bırakma, öneri çipi | `HapticFeedback.selectionClick()` |
| `mediumImpact` | Deklanşör, kamera düğmesi | `HapticFeedback.mediumImpact()` |
| `success` | Sonuç hazır (bir kez), talep alındı, şifre güncellendi, Öğrendim, program kaydedildi | platform kanalı: iOS `UINotificationFeedbackGenerator.success`, Android `HapticFeedbackConstants.CONFIRM` |
| `error` | Gönderim/okuma hatası, form doğrulama, form bulunamadı, kamera açılamadı, hatalı kod (2.4), hatalı giriş, hata türü toast, "Tekrar Dene" başarısız | iOS `.error`, Android `REJECT` |

**[Karar]** kanal adı `smap/haptics`, metotlar `success`/`error`; Android API < 30'da `CONFIRM/REJECT` yoksa `HapticFeedbackConstants.LONG_PRESS`/`VIRTUAL_KEY` yedeği. Haptik verilmeyen yerler: düğme basılı, akordeon, sheet, küçülen bar, iskelet, sayfa geçişi, izin sheet'leri, bakım/çevrimdışı, ekran düzeyi hata gelişi.

**Hareketi azalt (`MediaQuery.disableAnimations`):** bütün kaymalar 150 ms opaklığa döner; iskelet düz gri; sheet perdeye bağlı olmadan belirir; kaydırmalar `jumpTo`; sallanma yok; haptikler değişmez. Hiçbir bilgi yalnız hareketle verilmez. Süs animasyonu, dönen sayaç, konfeti, parlama, blob uygulamada yok (yalnız mağaza görsellerinde).

### 1.14 Kontrast kuralları ve yasak çiftler (1.2/1.3)

Eşikler: metin 4,5:1; büyük metin (24 pt ya da 19 pt kalın) 3:1; kontrol sınırı ve ikon 3:1; pasif metin/kenar ve dekoratif ayraç muaf.

**Açık tema (metin \ zemin):**

| Metin | surface `#FFFFFF` | canvas `#F2F4F7` | sunken `#E8ECF1` | navy `#0F294A` |
|---|---|---|---|---|
| text-primary | 15,89 | 14,42 | 13,39 | 1,09 ✗ |
| text-secondary | 6,28 | 5,70 | 5,29 | 2,33 ✗ |
| text-placeholder | 4,68 | 4,25 ✗ | 3,94 ✗ | 3,13 ✗ |
| text-action | 12,69 | 11,52 | 10,69 | 1,15 ✗ |
| text-accent | 5,61 | 5,09 | 4,73 | 2,61 ✗ |
| error | 5,56 | 5,05 | 4,69 | 2,63 ✗ |
| success | 6,34 | 5,75 | 5,34 | 2,31 ✗ |
| text-on-navy | 1,00 ✗ | 1,10 ✗ | 1,19 ✗ | 14,62 |
| text-on-navy-2 | 1,50 ✗ | 1,37 ✗ | 1,27 ✗ | 9,72 |

**Koyu tema (bütün hücreler kullanılabilir):**

| Metin | canvas `#0A1424` | surface `#121D31` | raised `#18263D` | sunken `#213049` | navy |
|---|---|---|---|---|---|
| text-primary `#EDF1F6` | 16,26 | 14,86 | 13,38 | 11,69 | 12,89 |
| text-secondary `#A9B5C6` | 8,88 | 8,12 | 7,31 | 6,39 | 7,04 |
| text-placeholder `#8B9AAF` | 6,45 | 5,89 | 5,30 | 4,63 | 5,11 |
| text-action `#9BB3D3` | 8,59 | 7,85 | 7,07 | 6,18 | 6,81 |
| text-accent `#FF9A57` | 8,79 | 8,04 | 7,24 | 6,32 | 6,97 |
| error `#FF8F8F` | 8,41 | 7,69 | 6,92 | 6,05 | 6,67 |
| success `#52CC8E` | 9,12 | 8,34 | 7,51 | 6,56 | 7,23 |
| text-on-navy | 18,45 | 16,86 | 15,18 | 13,26 | 14,62 |
| text-on-navy-2 | 12,26 | 11,20 | 10,09 | 8,81 | 9,72 |

**Bileşen çiftleri:** birincil düğme 14,62 / 11,59; pasif segment `#556173`/`#E8ECF1` 5,29 (koyu 6,39); bant pasif segmenti navy-200/navy-800 8,43; kamera ikonu navy-900/`#FF6600` 4,98; D/Y/B glif 6,34 · 4,71 · 3,50; yanlış hücrede doğru şık 5,46; koyu tehlikeli düğme `#3B0A10`/`#FF8F8F` 7,74; koyu toast 13,39.

**Yasaklar:**
1. Turuncu (`#FF6600`) üstüne beyaz metin (2,94); turuncu düğme yok; kamera ikonu navy-900.
2. orange-500 metin olarak kullanılmaz; turuncu metin açıkta `#B34400`, koyuda `#FF9A57`.
3. `text-placeholder` canvas/sunken/navy üstünde yok.
4. Açık temada navy üstünde yalnız `text-on-navy` ve `text-on-navy-2`.
5. `text-on-navy(-2)` açık zeminlerde yok.
6. `dybWrong` ve `dybBlank` metin olarak yok; `dybCorrect` metin yalnız yanlış hücredeki doğru şıkta.
7. Sayılar renkli yazılmaz; değişim `delta`, yeşil değil.
8. Ders vurgusu metin rengi olamaz (WeekGrid/HourSlot istisnası §1.9).
9. Durum rengi mesaj metni olamaz; sol kenar şeridi yok.
10. Renk tek başına anlam taşımaz.
11. Seçimde turuncu yok; segment başparmağı lacivert dolgu (beyaz başparmak 1,10).
12. Kartta kenar + gölge birlikte yok; kartta ikisi de yok.
13. Uyarı turuncu olmaz (hardal `#8A5A00`).
14. Bulanıklık yalnız alt çubukta ve perdede.
15. Kalkan değerler: `#8A90A6`, `#B2BAC6`/`#B4B8C0`, `#9E9E9E` "Kapat", `#9AA1AA` eksen, `#FFEB3B` sarı halka, açık şeftali kamera ikonu, `#FFA366`, `#F9FAFB` satır zemini, `#22C55E` anahtar, indigo dialog düğmesi, `Colors.grey` ve Tailwind literal'leri.

### 1.15 Dart dosya yapısı (`lib/core/theme/`)

| Dosya | İçerik |
|---|---|
| `smap_palette.dart` | `abstract final class SmapPalette`: `navy50…navy950`, `orange50…orange950`, `neutral0…neutral950` (§1.1). Yalnız tema katmanı kullanır |
| `smap_color_scheme.dart` | `smapLightColorScheme`, `smapDarkColorScheme` (§1.4) |
| `smap_colors.dart` | `class SmapColors extends ThemeExtension<SmapColors>` + `static const light/dark`, `copyWith`, `lerp` |
| `smap_subject.dart` | `enum Subject` + glif eşlemesi (`PhosphorIconsRegular.textAa` …) + `Subject.fromLessonId()` |
| `smap_typography.dart` | `smapTextTheme(Color onSurface)` + `class SmapText extends ThemeExtension<SmapText>` |
| `smap_format.dart` | `net`, `puan`, `sira`, `yuzde`, `kisaTarih`, uzun tarih, gün kısaltması, `delta(double)` ("+8,25"/"−1,25"), `TurkishSuffix`, `trFold()` |
| `smap_spacing.dart` | `SmapSpace.s4 … s64`, `gutter = 16`, `touch = 48`; `SmapSize` (§1.12 sabitleri) |
| `smap_radius.dart` | `SmapRadius.xs 4 · sm 8 · md 12 · lg 16 · xl 24 · full 999` + `BorderRadius` yardımcıları (`sheetTop`, `bandBottom`, `barTop`) |
| `smap_elevation.dart` | `SmapBlur.bar 20 · scrim 8` |
| `smap_tokens.dart` | `class SmapTokens extends ThemeExtension<SmapTokens>`: `shadowRaised`, `shadowOverlay` (`List<BoxShadow>` açık/koyu) |
| `smap_motion.dart` | `SmapDuration.instant 100 · fast 150 · base 250 · slow 350 · loop 1200`; `SmapCurves.standard/enter/exit/linear`; `exitOf(d) = d * 0.7`; `SmapMotion.reduced(context)` |
| `smap_haptics.dart` | `SmapHaptics.selection()`, `.medium()`, `.success()`, `.error()` + `MethodChannel('smap/haptics')` (iOS Swift + Android Kotlin tarafı) |
| `smap_theme.dart` | `SmapTheme.light()` / `.dark()`: `ThemeData(useMaterial3: true, colorScheme, textTheme, fontFamily: 'PlusJakartaSans', scaffoldBackgroundColor: bg-canvas, materialTapTargetSize: padded, splashFactory: NoSplash.splashFactory [Karar: basılı durum ripple değil, bir ton koyulaşma + 0,98 ölçek], extensions: [SmapColors, SmapText, SmapTokens])`. mihr_ui kullanılırsa `MihrThemeConfig(fontFamily, extraExtensions, materialOverrides)` |
| `smap_theme_context.dart` | `extension SmapThemeX on BuildContext { SmapColors get smapColors; SmapText get smapText; SmapTokens get smapTokens; ColorScheme get cs; }` |

**`SmapColors` alanları (11.12 listesi + Tur 1/1.2 ekleri birleşimi) [Ç-4]:**

| Alan | Açık | Koyu |
|---|---|---|
| `navyBand` | `#0F294A` | `#0F294A` |
| `navyBandRaised` | `#1A3357` | `#1A3357` |
| `contextStrip` | `#F1F5FA` | `#1A2B45` |
| `bar` | `#FFFFFF` @.92 | `#121D31` @.92 |
| `borderStrong` | `#C3CBD6` | `#34445F` |
| `textPlaceholder` | `#697586` | `#8B9AAF` |
| `textDisabled` | `#9AA5B4` | `#56657C` |
| `onNavyBand` | `#FFFFFF` | `#FFFFFF` |
| `onNavyBandVariant` | `#C5D4E8` | `#C5D4E8` |
| `textAction` | `#1A3357` | `#9BB3D3` |
| `textAccent` | `#B34400` | `#FF9A57` |
| `primaryPressed` | `#091A31` | `#9BB3D3` |
| `accentLine` | `#E05500` | `#FF8533` |
| `focusRing` | `#36537C` | `#9BB3D3` |
| `dybCorrect` / `dybWrong` / `dybBlank` | `#0B6E3E` / `#D8333A` / `#7E8A9B` | `#52CC8E` / `#F07575` / `#6E7C92` |
| `dybOn` | `#FFFFFF` | `#0A1424` |
| `dybCorrectBg` / `dybWrongBg` / `dybBlankBg` | `#E4F4EA` / `#FCEAEA` / `#E8ECF1` | `#133325` / `#3B1D22` / `#213049` |
| `delta` | `#36537C` | `#9BB3D3` |
| `eksik` / `eksikBg` | `#8A5A00` / `#FCF1D9` | `#F2C46D` / `#33270F` |
| `error` / `errorBg` | `#C42D35` / `#FCEAEA` | `#FF8F8F` / `#3B1D22` |
| `success` / `successBg` | `#0B6E3E` / `#E4F4EA` | `#52CC8E` / `#15301F` |
| `warning` / `warningBg` | `#8A5A00` / `#FCF1D9` | `#F2C46D` / `#33270F` |
| `info` / `infoBg` | `#36537C` / `#E2EAF4` | `#9BB3D3` / `#1A2B45` |
| `chartLine` / `chartArea` | `#264066` / chartLine @.10 | `#9BB3D3` / chartLine @.14 |
| `chartHighlight` / `chartGrid` | `#E05500` / `#DCE2E9` | `#FF8533` / `#26354D` |
| `chartSeries` (4) | `#264066, #E05500, #6C8BB6, #7E8A9B` | [Karar] `#9BB3D3, #FF8533, #6C8BB6, #6E7C92` |
| `inverseSurface` / `onInverseSurface` [Karar] | `#0F294A` / `#FFFFFF` | `#E8ECF1` / `#1B2232` |
| `subject: Map<Subject,(Color bg, Color fg)>` | §1.9 açık | §1.9 koyu |

`scrim`, `error`, `onError` ayrıca `ColorScheme`'de.

**`SmapText` alanları:** `bodyStrong` (15/24/600), `bodyReading` (16/26/400) [Karar], `metricXl` (56/64/800/−1,5), `metricLg` (40/48/800/−1), `metricMd` (24/32/700/−0,4), `metricSm` (17/24/700). Hepsinde `tabularFigures`; renk verilmez (bağlamdan). `TextTheme`: displaySmall=display, headlineSmall=title-lg, titleLarge=title-md, titleMedium=headline, titleSmall=title-sm, bodyLarge=body-lg, bodyMedium=body, bodySmall=caption, labelLarge/Medium/Small=label-lg/md/sm.

**`SmapTokens`:** yalnız temaya bağlı gölgeler. Temadan bağımsızlar `static const` sınıflarda (`SmapRadius`, `SmapSpace`, `SmapDuration`, `SmapCurves`, `SmapBlur`).

**mihr_ui uyumu (§9.11):** smapFlutter `pubspec`'te `mihr_ui` yok (eklenecekse `path: ../../mihr_ui`). `MihrRadius` adları çakışıyor (`MihrRadius.md` = 8, `xl` = 12; SMAP md 12, xl 24) → SMAP ekranlarında `MihrRadius`/`MihrSpacing` kullanılmaz. `ColorScale` `shade25` istiyor; SMAP'te yok. `MihrTheme` `ColorScheme`'i SMAP'le uyuşmaz → `materialOverrides` ile tam SMAP `ColorScheme`. `MihrTypography` varsayılanı Inter → `fontFamily: 'PlusJakartaSans'`.


---

## 2. Bileşenler

**Konum [Karar]:** `lib/core/ui/` altında katman klasörleri: `controls/`, `rows/`, `data/`, `content/`, `identity/`, `program/`, `camera/`, `overlay/`, `states/`, `shell/`; her bileşen kendi dosyasında (`smap_button.dart` …). Her bileşen açık ve koyu temada, metin ölçeği 1,0 ve 1,3'te çalışmalı. **[Karar]** Doğrulama için `lib/dev/component_gallery.dart` (yalnız debug, route `/dev/gallery`): her bileşenin bütün varyant ve durumlarını açık/koyu yan yana gösterir; koordinatör incelemesi bu ekrandan yapılır.

**Ortak kurallar (her bileşen):**
- Renk yalnız `ColorScheme` + `SmapColors` rolünden; literal hex yok.
- Dokunma alanı ≥ 48; 40'lık görselde görünmez pay.
- İkon düğmesinin erişilebilir adı (tooltip + `semanticLabel`) zorunlu.
- Renk tek ipucu değil: glif, kalınlık ya da metin eşlik eder.
- Süs görselleri `ExcludeSemantics`.
- Basılı durum: bir ton koyulaşma + 0,98 ölçek, 100 ms, standard, haptiksiz (`SmapPressable`).
- Hareketi azalt: §1.13.
- **[Karar] koyu basılı durum** (yalnız primary tanımlı: `#9BB3D3`): diğerlerinde zemin üstüne `onSurface` %8 katmanı.

### A · Kontroller

#### C01 · `SmapButton` (Kit 1.9; bütün ekranlar)
- **Varyant:** `primary`, `secondary` (panolarda "outline" `.bo`), `quiet`, `danger`, `text`, `textDanger` (Tur 6 G7). **Boy:** `lg` 48, `md` 40 (dokunma 48). **Seçenek:** `leadingIcon`, `trailingIcon`, `loading`, `expand` (tam genişlik; sheet'te varsayılan).
- **Ölçü:** lg yükseklik 48, yan dolgu 20 (baş ikonlu sol 16 / sağ 20; son ikonlu sol 20 / sağ 16), radius 12. md yükseklik 40, yan dolgu 16. text türü yan dolgu 12 (iki boyda). İkon 20, etiketle arası 8 (text türünde 6). Yükleniyorken genişlik sabit, etiket yerine 20 pt spinner (çizgi 2,5, yuvarlak uç).
- **Tipografi:** lg `label-lg` 16/24·600; md `label-md` 14/20·600.
- **Renk açık:**

| Tür | Varsayılan | Basılı | Yükleniyor | Pasif |
|---|---|---|---|---|
| primary | `#0F294A` / `#FFFFFF` | `#091A31` | ray beyaz %32, yay `#FFFFFF` | `#DCE2E9` / `#9AA5B4` |
| secondary | `#FFFFFF` / `#0F294A`, içe 1,5 `#0F294A` | `#E2EAF4` + kenar | ray `#0F294A` %20, yay `#0F294A` | `#FFFFFF` / `#9AA5B4`, kenar 1,5 `#C3CBD6` |
| quiet | `#E8ECF1` / `#1B2232` | `#DCE2E9` | ray `#1B2232` %18, yay `#1B2232` | `#F2F4F7` / `#9AA5B4` |
| danger | `#C42D35` / `#FFFFFF` | `#A3242B` | ray beyaz %32 | `#DCE2E9` / `#9AA5B4` |
| text | zeminsiz / `#1A3357` | `#E2EAF4` zemin | yok | `#9AA5B4` |
| textDanger | zeminsiz / `#C42D35` | [Karar] `#FCEAEA` zemin | yok | `#9AA5B4` |

- **Renk koyu (1.23):** primary `#C5D4E8` / `#091A31`, basılı `#9BB3D3`; secondary zeminsiz / `#C5D4E8`, kenar 1,5 `#C5D4E8`; quiet `#213049` / `#EDF1F6`; danger `#FF8F8F` / `#3B0A10`; text `#9BB3D3`; textDanger `#FF8F8F`; pasif `#213049` / `#56657C`.
- **Odak:** §1.12 halkası; text türünde boşluksuz 2 pt.
- **Kurallar:** ekranda tek birincil (kamera hariç). Pasif yerine doğrulama: form eksikken birincil dolu kalır, basınca ilk hatalı alana gidilir; pasif yalnız işlem sürerken, sayaç bitmeden ya da önkoşul yokken (metinler yüklenemedi, şık seçilmedi, değişiklik yok, not boş). Turuncu düğme yok. Etiket Türkçe başlık düzeninde, büyük harfli değil. İptal sözlüğü: "Vazgeç", "Tamam", "Kapat" (yalnız X'in adı), "Geri Al" (yalnız toast), "Sonra" (izin ertelemesi); "İptal" ve "Evet" yok.
- **Sheet'te sıra:** birincil üstte, quiet/secondary altta. Tehlikeli onayda danger üstte, "Vazgeç" altta.
- **Erişilebilirlik:** yükleniyorken ad "Yükleniyor", çift dokunma engellenir.
- **mihr_ui:** primary → `MihrPrimaryButton`; secondary → `MihrSecondaryButton` (kenar 1,5 `primary` ile ezilir); quiet → karşılığı yok, `MihrSoftPrimaryButton` gri override ya da kendi çizimi; danger → `MihrDestructiveButton`; text → `MihrLinkButton`. lg = `MihrButtonSize.xl` (48; yan dolgu 16→20, ikon 24→20 ezilir); md = `MihrButtonSize.md` (40; yan dolgu 12→16). Radius 12, gölge `MihrButtonShadows.flat`. **[Karar]** mihr_ui eklenmezse `SmapButton` kendi `SmapPressable` tabanıyla çizilir; API aynı kalır.

#### C02 · `SmapIconButton` (Kit 1.9)
- Dokunma 48 × 48, radius 12, ikon 24 (Phosphor Regular).
- **Varyantlar:**
  - `plain`: geri ok `#1B2232` / `#EDF1F6`.
  - `favorite`: Star 20 (satır) / 22 (kart), kapalı `#697586` (koyu `#6B7D97`), açık **Star Fill `#0F294A`** (koyu [Karar] `#C5D4E8`) [Ç-18]; `Semantics(toggled)`; adlar "Favorilere ekle" / "Favorilerden çıkar".
  - `close` (sheet): 48 alan içinde 36 daire `#E8ECF1` / `#213049`, X **18** (çizgi 20) `#1B2232` / `#EDF1F6` [Ç-57]; sheet başlığında margin-top −8.
  - `onNavy`: beyaz 24 ikon (RootBand eylemi).
  - `cameraTranslucent`: 40 daire `rgba(10,20,36,.64)`, beyaz ikon 20 (X) / 22 (Question).
  - `removeCircle`: 32 daire `#E8ECF1` (koyu `#213049`) + X 16 (çizgi 20), dokunma 48.
  - `clearSmall` (arama): 24 daire `#E8ECF1` + X 12 (çizgi 24), **dokunma 48** [Ç-24].
- Erişilebilir adlar: "Geri", "Kapat", "Filtrele", "Favorilere ekle"/"Favorilerden çıkar", "Şifreyi göster"/"Şifreyi gizle", "Aramayı temizle", "Yeni görüşme", "Öğrenci ekle", "Nasıl çekilir?", "Önceki ay"/"Sonraki ay", "Formu büyüt", "Kodu kopyala", "Kodu paylaş", "Önceki soru"/"Sonraki soru".

#### C03 · `SmapBarAction` (1.18 / Tur 6 G7, Tur 8 G4)
- DetailBar'ın sağındaki tek eylem: "Düzenle", "Yeni Program", "Bitti", "Kaydet", "Görüşme Planla".
- Yükseklik 40, yan dolgu 14, radius 12, dokunma 48; baş ikon 20 [Ç-49], arası 6; 14/20·600.
- **Durumlar:** çerçeveli (varsayılan) `#FFFFFF` / `#0F294A`, içe 1,5 `#0F294A` (koyu zeminsiz / `#C5D4E8`, kenar `#C5D4E8`); dolu ("Kaydet") `#0F294A` / `#FFFFFF` kenarsız (koyu [Karar] `#C5D4E8` / `#091A31`); pasif `#DCE2E9` / `#9AA5B4` kenarsız (koyu [Karar] `#213049` / `#56657C`).
- **`inline` varyantı** (alan yanında: "Kontrol Et", "Oluştur"): yükseklik 48, yan dolgu 14, çerçeveli; alanla arası 8.

#### C04 · `SmapSegmented<T>` (Kit 1.10)
- Aynı listenin görünümünü değiştirir; içerik tamamen değişiyorsa sekme kullanılır. 2–4 seçenek.
- **Ölçü:** ray radius 12, iç dolgu 4, seçenekler arası 4, zemin `#E8ECF1` / `#213049`. Başparmak radius 8, yükseklik 36 (görünür ray 44, dokunma 48), lacivert dolgu. Seçenek genişliği etikete göre paylaşılır (örnek flex 1 / 1,35 / 1 / 0,8); etiket kesilmez.
- **Tipografi:** 14/20·600. Seçili `#FFFFFF` (koyu başparmak `#C5D4E8` / metin `#091A31`); seçili olmayan `#556173` (koyu `#A9B5C6`). Odak `inset 0 0 0 2 focusRing`.
- **`counter` varyantı (Tur 5 G2):** seçenek min 48, dolgu 4, iki satır: başlık 14/20·700 `#1B2232` (seçili `#FFFFFF`), sayaç 13/20·500 `#556173` (seçili `#C5D4E8`). Koyu: başlık `#EDF1F6`, sayaç `#A9B5C6`; seçili başlık `#091A31`, sayaç `#1A3357`. Sayı sıfırsa "eksik yok" / "boş yok" / "kart yok"; veri yoksa o seçeneğin sayaç satırı çizilmez; rozet yok. Birimler: eksik, kart, soru, yanlış, boş, deneme. **[Karar]** iki seçenekte yer yetiyorsa tek satır "TYT · 7 eksik" (14/20·600, 36) varyantı v1'de kullanılmaz; panolar hep iki satır.
- **`onNavy` varyantı:** ray `#1A3357`, başparmak `#FFFFFF` / metin `#0F294A`, seçili olmayan `#C5D4E8` (8,43); koyuda aynı. Sarmalayıcı dolgu 0/16/16.
- **%130 metin:** etiket sarılır; min 44, dolgu 4/2, 18/24.
- **Hareket:** başparmak 250 standard kayar, etiket rengi çapraz geçer; `selectionClick`.
- **Erişilebilirlik:** radyo grubu: "TYT, 28 eksik, seçili, 3 seçenekten 2."

#### C05 · `SmapTabBar` (Kit 1.10)
- Aynı nesnenin bölümleri arasında; konum bildirdiği için turuncu çizgi + kalın etiket.
- **Ölçü:** yükseklik 48, alt ayraç `inset 0 -1 0 border-subtle`. Gösterge 3 pt, radius full, genişlik etiket kadar (Genel 46, Sorular 62, Konular 64, Kartlar 58, Denemelerim 98; 10.4'te Analiz 52, Denemeler 84, Program 70), altta ortalı. Sabit varyant: eşit flex. Kaydırılabilir (sığmazsa kendiliğinden): baş/son pay 16, sekmeler arası 24, sekme dolgusu 0/4, devam eden kenarda 40 pt yüzeyden saydama solma; seçili sekme görünür alana kaydırılır. %130: 19,5/28, yükseklik 52.
- **Tipografi:** 15/24; seçili 700 `#1B2232`, seçili olmayan 600 `#556173`. Gösterge `accentLine` `#E05500` [Ç-32].
- **`onNavy` (kök bantta):** ayraç yok; seçili olmayan `#C5D4E8`·600, seçili `#FFFFFF`·700; gösterge **`#FF6600`** (lacivertte 4,98; iki temada); bant alt boşluğu 8.
- **Koyu:** ayraç `#26354D`; seçili olmayan `#A9B5C6`, seçili `#EDF1F6`; gösterge `#FF8533`.
- **Hareket:** gösterge 250 standard; içerik 150 ms çapraz geçiş [Ç-55]; `selectionClick`.
- **Erişilebilirlik:** tablist; seçilen sekme duyurulur; seçim değişince odak kaybolmaz.

#### C06 · `SmapChip`, `SmapChipGroup`, `SmapFilterPill` (Kit 1.11)
- Tam yuvarlak, kenarlı, dokunulur seçim; kategoriye göre renkli hap yok.
- **Boylar [Ç-9]:** `sm` 36 (14/20·600, dolgu 0/14; yalnız kit), `md` 40 (15/20·600, dolgu 0/14; 6.1, 7.2, 10.5, 2.6 öneri çipi), `lg` 48 (16/24·600, dolgu 0/18; 2.2 alan seçimi). Dokunma 48. İkon–etiket 6.
- **Renk:** varsayılan `#FFFFFF` / `#1B2232`, içe 1 `#697586`; seçili `#0F294A` / `#FFFFFF`, kenarsız; pasif `#9AA5B4`, içe 1 `#C3CBD6` (neden yanında yazar). Koyu: varsayılan saydam / `#EDF1F6`, kenar `#6B7D97`; seçili `#C5D4E8` / `#091A31`.
- **Seçili işaret [Ç-9]:** ekranlardaki gibi Check ikonu çizilmez; seçim dolgu + `Semantics(selected: true)` ile verilir. 6.1 sheet'inde ders noktası yok.
- **`square` (şık / sınıf) varyantı:** 48 × 48, radius 12, içe 1 `#697586`, 16/24·700; seçili `#0F294A` / `#FFFFFF`. "Boş" 64 genişlik (4.7). Sınıf çipleri 56 × 48, "Mezun" 88 (Tur 7 G4).
- **`SmapFilterPill`:** md hap. (a) 6.1: "TYT · Genel" + son ikon CaretDown 18 (çizgi 20); `aria-haspopup=dialog`; süzgeç sheet'ini açar. (b) 7.2: "Eksiklerim (31)" + baş ikon Flag 16 (çizgi 20); aç/kapa (`toggled`), seçiliyken lacivert dolgu.
- **Hareket:** 150 standard; `selectionClick`.
- **Erişilebilirlik:** filtre çipi toggled + çoklu seçim; seçim çipi ve kare çip radyo grubu ("İşaretlenen şık").

#### C07 · `SmapTag` (Kit 1.11)
- Dokunulmaz bilgi; köşeli, kenarsız, nötr. Yükseklik 24, yan dolgu 8, radius 8, ikon–metin 4; isteğe bağlı baş ikon 14 ("Web'de" ArrowSquareOut, çizgi 20).
- 13/20·600; açık `#E8ECF1` / `#1B2232` (13,39); koyu `#213049` / `#EDF1F6`.
- **`dot` varyantı** ("Bu hafta", 3.4): 6 pt `#E05500` nokta, sağ boşluk 6.
- %130: yükseklik 30, 17 pt.
- **Kural:** sayı taşıyan etiket ne saydığını söyler ("31 eksik", "Az soru", "40 soru"); "Deneme: N" hiç yok.
- Kullanım: sınav türü (AYT/TYT), "Az soru", "Web'de", "Eksiklerimde", "Öğrenci"/"Veli", "eksik yok", "Bu hafta".

#### C08 · `SmapEksikTag` (Tur 5 G3)
- Tek eksik işareti: Flag 14 (çizgi 20) + metin; yükseklik 24, yan dolgu 8, radius 8, aralık 4.
- **13/20·600** [Ç-11]; açık `#FCF1D9` / `#8A5A00` (5,28), koyu `#33270F` / `#F2C46D`.
- Metin "N eksik"; madde düzeyinde "Eksik". Sıfırsa çizilmez ("0 eksik" yok; yerine gerekirse nötr Tag "eksik yok").
- Okunuş "3 eksik".
- Kullanım: 3.1 ders karoları, 3.5 konu sheet'i, 7.1 ders satırları [Ç-12], 7.2 konu satırları, 7.3 alt başlık/madde/kart sheet'i, 8.1 kart.

#### C09 · `SmapTextField` (Kit 1.12)
- **Anatomi:** üstte etiket (8 üstte), alan, altta yardım ya da hata (6 altta). Alanlar arası 20–24 (formda 20).
- **Ölçü:** yükseklik 48, yan dolgu 16, radius 12, kenar 1 `#697586`, zemin `#FFFFFF`. Son ikon kutusu 48 × 48 (ikonlu alanda sağ dolgu 48). İmleç 2 × 22 `#1A3357`.
- **Tipografi:** etiket 14/20·600 `#1B2232` ("(isteğe bağlı)" eki 500 `#556173`); değer 16/24·400; yardım 13/20 `#556173`; placeholder yalnız "Örn: …" `#697586`.
- **Durumlar:**

| Durum | Açık | Koyu |
|---|---|---|
| Boş | kenar 1 `#697586`, zemin `#FFFFFF` | zemin `#121D31`, kenar `#6B7D97`, metin `#EDF1F6`, placeholder `#8B9AAF` |
| Odak | kenar 2 `#1A3357` (1 + 1 içe) | `#9BB3D3` |
| Hata | kenar 2 `#C42D35`; mesaj 13/20·600 `#C42D35` + WarningCircle 16 (çizgi 20), arası 6; mesaj çözüm söyler | `#FF8F8F` |
| Canlı kontrol sürüyor | sağda 20 spinner | aynı |
| Canlı kontrol başarılı | sağda CheckCircle 22 `#0B6E3E`; mesaj 13/20·600 `#0B6E3E` + CheckCircle 18 | `#52CC8E` |
| Pasif | zemin `#F2F4F7`, kenar `#C3CBD6`, metin ve etiket `#9AA5B4` | [Karar] zemin `#0A1424`, kenar `#34445F`, metin `#56657C` |
| Salt okunur | zemin `#E8ECF1`, kenar yok, metin tam kontrast, sağda Lock 20 `#556173` (`aria-hidden`) | [Karar] zemin `#213049`, Lock `#A9B5C6` |

- **Varyantlar:** `password` (sağda 48 ikon düğmesi, Eye/EyeSlash 22–24 `#556173`, "Şifreyi göster"/"Şifreyi gizle"; yardım "En az 8 karakter."); `masked` (telefon "+90 5XX XXX XX XX", sayı klavyesi; koçluk kodu `AAAA-0000`, büyük harfe çevirir, tireyi kendisi koyar); `inlineAction` (alan + `SmapBarAction.inline` 48, arası 8).
- **Doğrulama:** alan bırakılınca ya da gönderince; ilk hatadan sonra yazarken güncellenir. Gönderimde odak ilk hatalı alana, 350 ms kaydırma. Kullanıcı adı kontrolü 400 ms gecikmeli, iptal edilebilir; çevrimdışında yardım metni "Bağlanınca kontrol edilecek.".
- **Hareket:** hata kenarı 150 + `error` haptiği; alan sarsılmaz.
- **Klavye/otomatik doldurma:** e-posta klavyesi; telefon ve kod için sayı klavyesi. `AutofillHints`: username, password, newPassword, oneTimeCode. Önceden dolu alan yok. Kullanıcı adında baş/son boşluk kırpılır ve küçük harfe çevrilir; şifre olduğu gibi.
- **Erişilebilirlik:** görünür etiket; hata `errorText` + live region.

#### C10 · `SmapSearchField` (Kit 1.12; ekran varyantı 3.4, 10.2, 10.5)
- TextField çerçevesi + `role=search`; baş ikon MagnifyingGlass 20 `#556173`, ikon–metin 10. Temizle: `SmapIconButton.clearSmall` (24 daire, X 12, dokunma 48, sağ margin −12) [Ç-24].
- Etiket görünmez ama okunur ("Program ara", "Öğrenci ara", "Görüşme ara"); placeholder aynı metin.
- **Davranış:** tr-TR katlama (§1.11), ad/soyad token'larında önek eşleşmesi (programda ad ve motto içinde), 150 ms gecikme, istemcide; 50'den fazla öğrencide sunucuda.
- **Vurgu:** eşleşen aralık zemin `#FCF1D9`, metin `#1B2232`, radius 4, yan dolgu 1. Koyu [Karar]: zemin `#33270F`, metin `#EDF1F6`.
- **Sonuç yok kartı (3.4/10.2):** kart dolgu 24/16/12, ortalı: başlık 16/24·700 ("“kasım” ile eşleşen program yok"), açıklama 13/20 `#556173`, `text` düğme "Aramayı Temizle".
- **Koyu:** TextField koyu rolleri; temizle dairesi `#213049`, X `#EDF1F6`.

#### C11 · `SmapCodeInput` (Kit 1.12; 2.4)
- 6 kutu, her biri 48 × 56, radius 12, kenar 1 `#697586`, zemin `#FFFFFF`, arası 8; rakam 24/32·700 `#1B2232` ortalı; odaklı kutu kenar 2 `#1A3357`.
- Grup etiketi "Doğrulama kodu" 14/20·600; altında yardım 13/20.
- Tekrar gönder: `text` düğme "Kodu Tekrar Gönder (0:24)" sayaç bitene kadar pasif, metin `#556173` [Karar: sayaç okunur kalsın diye 2.4 değeri], `aria-disabled`; 30 sn sonra açılır ("Kodu Tekrar Gönder").
- **Davranış:** sayı klavyesi, `oneTimeCode` doldurma; yapıştırınca 6 kutu dolar; 6. hanede kendiliğinden doğrular. Kod 10 dk geçerli.
- **Hata [Karar]:** bütün kutular kenar 2 `error`; altında hata satırı; kutular 150 ms sallanır (±6 pt) + `error`; hareketi azaltta sallanma yok.
- **Erişilebilirlik:** tek alan gibi: "Doğrulama kodu, 6 hane"; kutular "1. hane" … "6. hane".
- **Koyu [Karar]:** TextField koyu rolleri.

#### C12 · `SmapSelectField` (Kit 1.12)
- TextField çerçevesi, düğme gibi davranır; değer 16/24; sonda CaretDown 20 (çizgi 18) `#556173`; `aria-haspopup=dialog`. İsteğe bağlı baş avatar 28 (10.5 öğrenci seçimi).
- Yerinde liste açmaz; alttan `SmapBottomSheet` + `SmapRadioListTile` satırları (56); seçince sheet kapanır, ayrı onay yok.
- Pasif: zemin `#F2F4F7`, kenar `#C3CBD6`, metin/etiket/ok `#9AA5B4`; yardım nedeni söyler ("9. ve 10. sınıfta alan seçilmez."); değer "Seçilmez".

#### C13 · `SmapTextArea` (Tur 9 G7)
- Dolgu 12/16, radius 12, kenar 1 `#697586`, 16/24; odak kenarı 2 `#1A3357`. Min yükseklik 120 (10.6 not sheet'i), 88 (10.5 yeni görüşme sheet'i). İmleç 2 × 20.
- Karakter sayacı sağa hizalı 13/20 `#556173` ("44/500"); üst sınır 500.
- Kaydetme hatasında sheet açık kalır, metin korunur, toast çıkar.

#### C14 · `SmapCheckbox` (Kit 1.13)
- Kutu 24, radius 4, dokunma 48. Satır min 48, kutu–etiket 12, bütün satır dokunulur. Etiket 15/24·400 `#1B2232`; etiketteki bağlantılar altı çizili `#1A3357`·700, çizgi aralığı 3, metni sheet'te açar.
- Boş: içe 2 `#697586` (koyu `#6B7D97`). Seçili: zemin `#0F294A` + Check 16 (çizgi 28) `#FFFFFF` (koyu `#C5D4E8` + `#091A31`). Pasif: içe 2 `#C3CBD6`, etiket `#9AA5B4`. Hata: içe 2 `#C42D35` + altta hata satırı.
- 150 standard; `selectionClick`.

#### C15 · `SmapRadio`, `SmapRadioListTile` (Kit 1.13)
- 24 daire. Kapalı: içe 2 `#697586`. **Seçili: içe 7 `#0F294A`** [Ç-16] (ortada 10 pt zemin rengi delik); koyu `#C5D4E8`.
- **Sheet satırı:** min 56, dolgu 8/24 (ekran) ya da 12/16 (kit liste kabı), aralık 12; etiket 16/24·600 solda (flex), kontrol sağda; isteğe bağlı alt satır 13/20 `#556173` ve sağda EksikTag. Grup başlığı 13/20·700 `#556173`, dolgu 12/24/0. Ayraç 1 `#E8ECF1`.
- 150; `selectionClick`.

#### C16 · `SmapSwitch` (Kit 1.13)
- 52 × 32, radius full, dokunma 48.

| Durum | Ray | Baş | İşaret |
|---|---|---|---|
| Kapalı | saydam, içe 2 `#697586` | 16 `#697586`, sol-üst 8,8 | — |
| Açık | `#0F294A` | 24 `#FFFFFF`, sağ/üst 4 | Check 14 (çizgi 28) `#0F294A` |
| Pasif kapalı | içe 2 `#C3CBD6` | `#C3CBD6` | — |
| Pasif açık (9.6 izin kapalı) | `#DCE2E9` | `#FFFFFF` | `#9AA5B4`; satır başlığı `#697586` |
| Koyu açık | `#C5D4E8` | `#091A31` | `#C5D4E8` |
| Koyu kapalı | içe 2 `#6B7D97` | `#6B7D97` | — |
| Koyu pasif [Karar] | `#213049` | `#56657C` | — |

- Değişiklik anında kaydedilir; hata olursa geri döner + toast. 150 standard, baş kayar ve büyür; `selectionClick`. Okunuş "Deneme sonucun hazır, açık, anahtar".

### B · Satırlar, kartlar, kutular

#### C17 · `SmapSettingsRow` (Kit 1.13; 9.1, 9.6, 9.7)
- Min 56 (iki satırda 72), dolgu 12/16, aralık 12. Baş ikon 24 `#556173` (koyu `#A9B5C6`); ikonsuz satır da var (9.6 kategoriler); hizalama için gizli ikon yeri (9.6 Başlangıç/Bitiş).
- Başlık 16/24·600 `#1B2232`; alt metin 13/20 `#556173`; değer 15/24 `#556173`.
- Sağ öğe: CaretRight 20 (çizgi 16) `#556173` · değer + ok · `SmapSwitch` · ArrowSquareOut 20 · `SmapTag` · özel (CodeCard satırı: kod + iki ikon düğmesi).
- Ayraç 1 `#E8ECF1` / `#26354D`, metnin başladığı yerden (soldan 52).
- `danger`: ikon ve başlık `#C42D35` / `#FF8F8F`, ok yok, ayrı grupta, onay açar; okunuş "Çıkış Yap, düğme, onay ister".
- Basılı [Karar]: zemin `#F2F4F7` / `#18263D`, 100 ms.

#### C18 · `SmapListGroup`
- Başlık 13/20·600 `#556173`, margin alt 8 sol 4. Kap `#FFFFFF` / `#121D31`, radius 16, `clipBehavior`. Gruplar arası 20. İsteğe bağlı altbilgi 13/20 `#556173` (margin −8 4 0).

#### C19 · `SmapSectionHeader` (Tur 6 G2)
- Başlık 20/28·700·−0,2; isteğe bağlı meta 13/20 `#556173` (2 altta). Sağda en çok bir `text` düğme, yükseklik 40, sağ margin −12 ("Programım"; "Öğrenci Ekle" + Plus 20). Bölümler arası 28; başlıktan içeriğe 12. "kart + başlık + Tümü ›" kalıbı yok.

#### C20 · `SmapSubjectRow` (Kit 1.16 / Tur 5 G1; 7.1)
- Min 72, dolgu 12/16, aralık 12. Glif karosu **40** [Ç-13], radius 12, ders zemini + vurgu glifi 22.
- Ad 16/24·600 (TYT/AYT öneksiz); isteğe bağlı alt satır 13/20 `#556173` (test adı "Sosyal Bilimler 2 testi").
- Sağda **`SmapEksikTag`** [Ç-12] ya da nötr "eksik yok" Tag ya da "Web'de" Tag (ArrowSquareOut 14); veri yoksa etiket yok. Ok CaretRight 20; Web'de satırında ok yerine ArrowSquareOut 20.
- Kart ilerlemesi (yalnız gerçek veri varsa): ray 8, radius full, `bg-sunken`, dolgu ders vurgusu; yanında "41/64 kart" 13/20·600 `#556173`, arası 8, üst boşluk 6 [Ç-63].
- %130: ad 21/30 sarılır, etiket adın altına iner. Okunuş "Matematik, web'de açılır". Çevrimdışıyken Web'de dersleri listeden gizlenir.

#### C21 · `SmapSubjectTile` (Tur 6 G3; 3.1)
- Genişlik 132, dolgu 16, radius 16, `#FFFFFF` / `#121D31`, dikey sola hizalı, aralık 12. Glif 40 / 22. Ad 16/24·600 sarılır. EksikTag ya da "Web'de" Tag (6 altta). Yeni kullanıcıda yalnız glif + ad.
- Şerit: yatay, aralık 8, yan dolgu 16; eksiği çok olandan; Matematik ve Geometri sonda.
- Okunuş "Tarih, 60 eksik". Dokunma ders detayını açar (son TYT/AYT seçimiyle).

#### C22 · `SmapTopicRow` (Tur 5; 7.2) [Ç-14]
- Min 64, dolgu 12/16, aralık 12. Numara rozeti 28 daire `#E8ECF1` / `#213049`, 13/28·700 ortalı. Ad 16/24·600, 2 satıra kadar. EksikTag (eksik > 0), ok 20.
- Numara 1..n istemcide, sunucu sırasından; süzülmüş listede tam listedeki numara korunur.

#### C23 · `SmapTopicResultRow` (Kit 1.15 / Tur 3; 5.5, 5.10)
- Dolgu 12/16, min 72, aralık 12, ayraç 1 `#E8ECF1`. Ad 16/24·600 sarılır. Meta satırı (6 altta, aralık 6/10): kelimeli `SmapDybCounter.small` + "Az soru" Tag. Sağda `SmapSuccessRing` 48.
- Sıralama yüzde artan; eşitlikte soru sayısı çok olan önce. Yüzde `(d*100/n).round()`. "Az soru" n ≤ 2. Satırın tamamı konu detayını açar.
- **Öne çıkan kart "En çok kaçırdığın konu"** (`SmapMostMissedCard`): dolgu 16; etiket 13/20·600 `#556173`; konu 17/24·700 (2 altta); cümle 15/24 (2 altta); `primary` "Bu Konuyu Çalış" (12 altta). Seçim: en çok yanlış; eşitlikte düşük yüzde.

#### C24 · `SmapExamRow` (Tur 4 G2; 6.2, 10.4)
- Dolgu 12/16, üstten hizalı, aralık 12, min 72. Kapak 40 × 54, **radius 8** [Ç-20], `#DCE2E9` (koyu `#213049`), ikonsuz.
- Ad 16/24·600, 2 satıra kadar. Meta (4 altta, aralık 4/8): tür Tag + kısa tarih 13 `#556173` + "· yayınevi" 13. Harfli küçük D/Y/B (6 altta).
- Sağda net 24/32·700·−0,4 + "net" 13/20·600 `#556173`, sağa hizalı.
- Favori `SmapIconButton.favorite` (Star 20, margin −6 −12 0 0); koç görünümünde yok.
- Ad yoksa başlık "{tür} denemesi"; yayınevi ve D/Y/B çizilmez.
- Liste: sayfa başına 8, altta 24 spinner; "Hepsi bu kadar" yok.

#### C25 · `SmapExamSummaryCard` ("Son denemen", 3.1)
- Kart dolgu 16. Ad 16/24·700; meta 13/20 `#556173` "Örnek Yayınları · AYT · 5 Eki. 2026" (ad ve yayınevi ayrı satır, "(Test)" yok).
- Net satırı (12 altta): metric-lg 40/48·800·−1 + "net" 15/24·600 `#556173` + `SmapDeltaText` (sol 8; 13/20·700 + ArrowUp 14) + "önceki AYT'ye göre" 13 `#556173`.
- Kelimeli küçük D/Y/B (8 altta). Ayraç (margin 16/0/12). "En çok kaçırdığın konu" 13/20·700 `#556173`; cümle 15/24. `primary` "Analizi Gör" (16 altta, tam genişlik).
- Boş hâl: "Henüz deneme okutmadın." 16/24·700 + gövde 15/24 `#556173` (4 altta) + `primary` (Camera 20) "İlk Denemeni Okut".
- Veri yoksa alan çizilmez. Kit 1.16 "kart varyantı" (56 × 76 kapaklı) v1'de kullanılmaz [Ç-48].

#### C26 · `SmapExamHeader` (Tur 3 G3; 5.3; `moment` varyantı 5.1)
- **detail (5.3):** kapak 48 × 64, radius 8 [Ç-20], `#DCE2E9` + Image 22 `#697586` ("Deneme kapağı"), aralık 12. Yayınevi 13/20·600 `#556173`; ad 20/28·700 (2 altta); tür Tag + tarih 13 (4 altta, arası 8). Net (y≈182) metric-lg + "net" 17/24·600 `#556173`, arası 8. `SmapDybCounter.large`. Puan kartı (`SmapScoreCard`): surface, radius 16, dolgu 12/16; başlık alan adı 13/20·600 `#556173`; iki sütun aralık 12: değer metric-md + etiket 13/20·600 ("Yerleştirme puanı", "Sıra"; sıra "48.215."). Veri yoksa kart çizilmez.
- **moment (5.1):** kapak 56 × 76, radius 8, Image 24; ad 17/24·700; Tag + tarih 6 altta; net metric-xl + "net" 17/24·600; delta 15/24 (ok 18 çizgi 20, değer 700 `delta`, açıklama `#556173`), aralık 6.
- **Hareket:** 5.3'te kaydırınca büyük başlık 250 ms'de kısa bara iner; 5.1'de içerik 250 ms 8 pt yukarı + `success` bir kez.

#### C27 · `SmapStatBox` (Tur 4 G3, Tur 10; 6.1, 10.4, 5.1)
- `#FFFFFF` / `#121D31`, radius 16, dolgu 16, dikey aralık 2. Değer metric-md; etiket 13/20·600 `#556173` / `#A9B5C6`. Delta satırı 13/20·600 `delta` + ArrowUp/ArrowDown 14 (çizgi 24), arası 4: "+3,25 son denemede" [Ç-8].
- Izgara 2 sütun, aralık 8. Verisi olmayan kutu çizilmez; delta yalnız aynı süzgeçteki son iki denemeden, iki deneme yoksa satır yok. İşaret ve ok her zaman.

#### C28 · `SmapAuthorRow` (Tur 5; 7.4)
- Min 72, dolgu 12/16, aralık 12. Fotoğraf 48 daire; yoksa baş harf: `#F6E7EC` / `#8A2F4E`, 15/20·700 (koyu `#301A27` / `#E494BE`). Ad 16/24·600; dönem 13/20 `#556173`; ok.

#### C29 · `SmapProgramRow` (Tur 6; 3.4)
- Dolgu 16, aralık 12, üstten hizalı. Karo 40, radius 12, `#E2EAF4` / `#36537C` (koyu `#1A2B45` / `#9BB3D3`), Calendar 22.
- Ad 16/24·700 + "Bu hafta" `SmapTag.dot`; motto 15/24 `#556173`; tarih aralığı 13/20 `#556173`; CaretRight 20 (üst dolgu 8).

#### C30 · `SmapProgramItemRow` (Tur 6; 3.1, 3.4, 3.6, 10.4)
- Dolgu 10/12/10/16, min 64, aralık 12, ayraç 1 `#E8ECF1` / `#26354D`. Saat body-strong 15/24·600 tabular [Ç-62], min genişlik 48. Glif karosu 36, radius 12, glif 19. Ders 13/20 `#556173`; konu 16/24·600; CaretRight 20 `#556173`.
- **edit modu (3.6):** saat altı çizili metin düğmesi (çizgi aralığı 4), TimeWheel sheet'ini açar ("Saat 10:00, değiştir"); sağda `removeCircle` ("Fiilde Çatı, programdan çıkar"). Liste altında tam genişlik `secondary` (Plus 20) "Konu Ekle"; en altta iki uçta `textDanger` "Günü Sıfırla" (**ArrowCounterClockwise** 20) ve "Programı İptal Et" (Trash 20).
- **Hareket:** çıkarma 250 exit + toast "Konu çıkarıldı." + Geri Al; sıfırlama satırları 150 aralıkla söner, `selectionClick`.
- Okunuş "10:00, Türkçe, Fiilde Çatı". Tamamlama işareti yok (D-26).

#### C31 · `SmapStudentRow` (Tur 9; 10.2)
- Dolgu 12/16, aralık 12, **min 72** [Ç-30]. Avatar 40; ad 16/24·600; meta 13/20 "12. Sınıf · Eşit Ağırlık · 10 deneme" (alan ya da deneme yoksa o parça yazılmaz). Sağda yalnız verisi olan: "67,5" metric-sm 17/24·700 + "son net" 13/20. Ok. Arama eşleşmesi vurgulu. Sıralama alfabetik (Türkçe `Collator`/[Karar] `trCompare`).

#### C32 · `SmapStudentTile` (Tur 9 G3; 10.1)
- Genişlik 108, dolgu 14, radius 16, `#FFFFFF` / `#121D31`; dikey sola hizalı, aralık 8. Avatar 48; ad 15/20·600, 2 satıra kadar; varsa "Son deneme 5 Eki." 13/20 `#556173`. Şerit aralığı 8, yan dolgu 16, yatay kaydırma.

#### C33 · `SmapAttentionRow` (Tur 9 G4; 10.1)
- Üstten hizalı, min 64, dolgu 12/16. Avatar 40 + kural rozeti: 22 daire `#FCF1D9` / `#8A5A00` (koyu `#33270F` / `#F2C46D`), Clock ya da TrendDown 14 (çizgi 24), 2 pt yüzey rengi halka, sağ alt ofset −4/−4.
- Ad 16/24·600; kural cümlesi 15/24 (2 altta) "45 gündür deneme okutmadı"; kanıt 13/20 `#556173` "Son deneme 17 Haz. 2026 · TYT" / "68 → 66,75 · 17 Haz. ve 4 Ağu."; ok.
- Boş bölüm kartı: dolgu 16; "Şu an dikkat gerektiren öğrenci yok." 15/24·600 + açıklama 13/20 `#556173` "14 gündür deneme okutmayan ya da son iki denemesinde neti düşen öğrenci burada görünür."
- Yalnız iki kural (D-27). Okunuş tek cümle.

#### C34 · `SmapMeetingRow` (Tur 9 G5; 10.1, 10.5)
- Satır dolgu 12/16, aralık 12, min 64.
- `dateBlock` (10.1): blok 44 genişlik, gün metric-md ("12"), ay 13/20·600 `#556173` ("Eki."); avatar 36; ad 16/24·600; meta 13/20 "Pazartesi 16:00 · Öğrenci"; ok.
- `list` (10.5): avatar 40; ad; meta "12 Ekim 2026 Pazartesi · 16:00" (yıllı) [Ç-41]; Tag "Öğrenci"/"Veli"; ok.
- Okunuş "Alparslan Kuloğlu, 12 Ekim 2026 Pazartesi, 16:00, öğrenci görüşmesi".

#### C35 · `SmapCodeCard` (Tur 9 G6; 10.1, 10.3)
- Kart dolgu 16, `#FFFFFF`, radius 16 + içe 1 `#DCE2E9` (bu kartta kenar istisnası; koyu `#121D31` + `#26354D`).
- "Koçluk kodun" 13/20·600 `#556173`; kod **metric-md 24/32·700, harf aralığı 1** [Ç-25] (2 altta); açıklama 13/20 `#556173` (4 altta) "Öğrencin bu kodu Hesap › Koçluk'a girince sana bağlanır.".
- Eylem satırı 12 altta, arası 8: iki `secondary` **md (40)** [Ç-25], flex 1: Copy 20 "Kopyala", ShareNetwork 20 "Paylaş".
- Kopyala → toast "Kod kopyalandı." (4 sn). Paylaş → sistem paylaşımı ([Karar] `share_plus` eklenir).

#### C36 · `SmapCoachCard` (Tur 8; 9.5)
- Kap radius 16, dolgu 16. Avatar 64, aralık 14; ad 17/24·700; "Koçun" 13/20. Ayraç (margin 16/0/12). "Sıradaki görüşme" 13/20 `#556173`; değer 16/24·600 (2 altta). Görüşme yoksa ayraç ve satır çizilmez.

#### C37 · `SmapProfileSummary` (Tur 8 G2; 9.1)
- Kök bant içinde (bant alt dolgusu 20); tam genişlik tek dokunma alanı, dolgu 4/16/0, aralık 14. Avatar 56; ad 17/24·700 `#FFFFFF`; iki alt satır 13/20 `#C5D4E8`; ok 20 `#C5D4E8`.
- Öğrenci: "12. Sınıf · Eşit Ağırlık", "Koçun: Mehmet Özkan" (koç yoksa [Karar] 2. satır çizilmez). Koç: "Öğrenci koçu", "Koçluk kodun: MOZK-4821".
- Okunuş "Profil: Alparslan Kuloğlu, 12. Sınıf, Eşit Ağırlık, koçun Mehmet Özkan".

#### C38 · `SmapRoleOption` (Tur 7 G3; 2.2)
- Tam genişlik, dolgu 16, radius 16, `#FFFFFF`, içe 1 `#DCE2E9`; seçili içe 2 `#0F294A`. Aralık 16. Avatar 56. Başlık 17/24·700·−0,1; açıklama 15/24 `#556173` (2 altta). Radyo 24 (içe 7) [Ç-16]. Seçenekler arası 12. Radyo grubu "Rol".

#### C39 · `SmapNoticeBox(tone: info|error|warning)` (Tur 7 G5, Tur 8)
- Yatay, aralık 10, üstten hizalı; dolgu 12/14; radius 12; metin 15/22 `#1B2232`; ikon 20 (üst dolgu 1).
- info `#E2EAF4` + Info `#36537C`; error `#FCEAEA` + **WarningCircle** `#C42D35` [Ç-59]; warning `#FCF1D9` + WarningCircle `#8A5A00`.
- Koyu: info `#1A2B45` / `#9BB3D3`, error `#3B1D22` / `#FF8F8F`, warning `#33270F` / `#F2C46D`; metin `#EDF1F6`.
- İsteğe bağlı satır içi `text` düğme ("Ayarları Aç", "Tekrar Dene"): margin üst 2, alt −10, sol −12.
- error ve warning `liveRegion` (`role=alert`).

### C · Veri bileşenleri

#### C40 · `SmapDybGlyph` (Kit 1.14)
- Daire 16 (glif 10, çizgi 32) ya da 24 (glif 14, çizgi 28); 32 (glif 18, boş durum kartı). Check / X / Minus; zemin dyb rengi; glif `dybOn`. Glif her yerde (Tur 10).

#### C41 · `SmapDybCounter(size: large|small, labels: letter|word)` (Kit 1.14)
- **large:** 3 sütun, aralık 12; her sütunda çip 24 + etiket 15/24·600 `#556173` ("Doğru"/"Yanlış"/"Boş", arası 8); değer **metric-md 24/32·700·−0,4** [Ç-33] `#1B2232`, 4 altta.
- **small:** satır içi, öğeler arası 14 (kelimeli 10; sarınca dikey 4). Çip 16 + değer 15/20·700 + harf ("D","Y","B") ya da kelime ("doğru","yanlış","boş") 13·500 `#556173`, arası 4.
- Sıra D, Y, B; Boş sıfır da görünür; sayılar metin renginde. Harfli: akordeon başlığı, deneme satırı, test satırı. Kelimeli: konu satırı, Anasayfa son deneme.
- Okunuş tek cümle "86 doğru, 74 yanlış, 0 boş" (`excludeSemantics`). Koyu etiket `#A9B5C6`, değer `#EDF1F6`.

#### C42 · `SmapDybStackedBar` + `SmapTestBarRow` (Kit 1.14; 5.3)
- Çubuk 12, radius full, kırpılır; parçalar arası 2; genişlik sayıyla orantılı (flex); sıfır parça çizilmez (sayacı yazılır).
- Satır: dolgu 14/0, ayraç 1 `#E8ECF1`. Üst satır (taban çizgisine hizalı, arası 16): test adı 16/24·600 (sarar) + net metric-sm + "net" 13·500 `#556173`. Çubuk 10 altta. Sayaç satırı 8 altta: harfli küçük D/Y/B + sağda "40 soru" 13.
- 350 ms dolma (ilk açılış). Okunuş "40 sorudan 23 doğru, 17 yanlış, 0 boş".

#### C43 · `SmapQuestionCell(variant: result|formCheck)` (Tur 2 G2, Tur 3 G1)
- **result:** yükseklik 76, radius 8, dolgu 6, space-between. Sol üst numara 13/20·600 `#556173`; sağ üst durum çipi 16 (köşeden 8/8); orta işaret 20/24·700 (boşsa "–" `#556173`); alt "Doğru A" 13/16·600 `#0B6E3E` (yalnız yanlış ve boşta; doğruda yükseklik korunur, metin gizli).
  - Zemin: doğru `#FFFFFF` + içe 1 `#DCE2E9`; yanlış `#FCEAEA`; boş `#E8ECF1`; basılı (yanlış) `#F6D7D7` + 0,97 ölçek, 100 ms. Koyu: doğru `#121D31` + `#26354D`; yanlış `#3B1D22`; boş `#213049`; doğru cevap `#52CC8E`; numara `#A9B5C6`.
  - Izgara: 5 sütun, iç dolgu 0/8/8, **aralık 6** (hücre ~66) [Ç-19].
  - Okunuş "Soru 7, yanlış, işaretin C, doğru cevap A"; "Soru 6, doğru, işaretin B". Dokunma 5.7'yi açar.
- **formCheck (4.7):** 66 × 52, radius 8, dolgu 4/8; numara 13/16·600; işaret 20/24·700 ortada; okundu zemin `#FFFFFF`. "Boş okundu": `#FCF1D9` + 2 pt kesikli `#8A5A00` (dolgu 2/6), "–" `#556173`. "Düzeltildi": `#E2EAF4` + içe 2 `#0F294A`, harf `#0F294A`, sağ üstte PencilSimple 14. Izgara 5 × 66, aralık 8.
  - Okunuş "1. soru, okunan B"; "12. soru, boş okundu, düzeltmek için dokun"; "12. soru, düzeltildi: C". Dokunma düzeltme sheet'ini açar.

#### C44 · `SmapLinearProgress(style: subject|accent)` (Kit 1.15)
- subject: ray 8 `#E8ECF1` / `#213049`, radius full, dolgu ders vurgusu; etiket sayıyı söyler (yüzde ayrıca yazılmaz); toplam yoksa çizilmez.
- accent: dolgu `#E05500` / `#FF8533`; 8 (4.5 gönderim); değer yüzdeyi anında izler (linear).
- `progressbar` + "40 karttan 12'si".

#### C45 · `SmapSessionProgress` (Tur 5 G5; 8.1)
- Ray **4** [Ç-15] `#E8ECF1` / `#213049`, dolgu `#E05500` / `#FF8533`, radius full; sağda "12/23" **13/20·700** [Ç-15], aralık 12. Okunuş: "Oturum", değer 12, üst sınır 23.

#### C46 · `SmapSuccessRing` (Kit 1.15; 5.5)
- 48, çizgi 5, r 21; ray `#E8ECF1` / `#213049`; yay `chartLine` `#264066` / `#9BB3D3`, yuvarlak uç, −90°'den; dasharray = oran × 131,9. Orta "%42" 13·700 `#1B2232` / `#EDF1F6`.
- %0: yalnız ray + "%0"; soru yok: halka yok, "Soru yok" 13/16·600 `#556173`. Tek renk, eşik yok. Okunuş "Yüzde 42".

#### C47 · `SmapSpinner` (Kit 1.15; 4.5, 9.4)
- 24 birim çerçevede r 9,5, çizgi 3; ray + 90° yay, yuvarlak uç. Boylar 24 (satır içi), 48 (tam ekran), 20 (düğme içi, çizgi 2,5).
- Renk [Ç-17]: ray `#DCE2E9`, yay `#0F294A`; koyu ray `#34445F`, yay `#C5D4E8`; lacivert/dolgu üstünde ray beyaz %24–32, yay `#FFFFFF`.
- 1200 ms döngü linear; hareketi azaltta sabit yay + metin. Yalnız süresi bilinmeyen adımda ve ne beklendiğini söyleyen metinle; ekran yüklemesinde iskelet.

#### C48 · `SmapNetChart` (fl_chart `LineChart`; Tur 4 G1; 6.1, 10.4)
- Kart dolgu 16. Başlık "Net gelişimi" 17/24·700 + sağda "Son 6 deneme" 13/20·600 `#556173`. Grafik 338 × 214 (10.4'te 338 × 200), 12 altta. Alt yazı 13/20 `#556173` "net · TYT 0–120 · son nokta vurgulu" (4 altta).
- Çizim alanı x 34–328, y 10–184; 5 yatay ızgara (aralık 43,5) `chartGrid` 1 pt. Y sabit: TYT 0/30/60/90/120; AYT 0/40/80/120/160; etiketler x=28 sağa yaslı 13 `#556173`. X: noktalar **eşit aralıklı (indeks)**, x 48→314; etiketler y=206 ortalı 13, kısa tarih.
- Çizgi `chartLine` 2,5, round join, düz parçalar (`isCurved: false`); alan `chartArea` (`belowBarData`); noktalar r 4,5 dolgu yüzey, kenar 2 chartLine; son nokta r 7 `chartHighlight`, kenar 2,5 yüzey.
- Balon: radius 8, `#0F294A` (koyu ters yüzey `#EDF1F6`), örnek 196 × 48; sağ kenarı x=328'e yaslı, noktanın 66 üstünde; 1. satır 13 `#C5D4E8` (koyu `#36537C`) "TYT Genel Deneme 9 · 28 Eyl."; 2. satır 15·700 `#FFFFFF` (koyu `#0A1424`) "74,75 net". Gölge `shadowOverlay`.
- Etkileşim: noktaya dokununca balon (ad yoksa yalnız tarih ve net); dışına dokununca son noktaya döner; hedef çizgisi yok; süzgeç değişince 350 ms yeniden çizilir + `selectionClick`.
- Grafik iki denemeden itibaren çizilir. Okunuş: "TYT net grafiği: 22 Nisan 61,5 netten 28 Eylül 74,75 nete, 6 deneme"; her nokta odaklanır "TYT Genel Deneme 9, 28 Eylül, 74,75 net".

#### C49 · `SmapMetricText`, `SmapDeltaText`
- Metrik: metric-xl/lg/md/sm, tabular; birim etiketi ayrı stil (17/24·600 ya da 15/24·600 ya da 13/20·600 `#556173`), arası 8 (5.x) / 4.
- Delta: `delta` rengi + ArrowUp/ArrowDown; işaret her zaman ("+8,25", "−1,25"); açıklama `#556173`. Boylar: 13/20·700 ok 14 (Anasayfa); 13/20·600 ok 14 (StatBox); 15/24·700 ok 18 çizgi 20 (sonuç anı).

### D · İçerik

#### C50 · `SmapAccordion` + `SmapAccordionHeader` (Tur 3, Tur 5 G4)
- Ok dairesiz [Ç-27]: CaretUp (açık) / CaretDown (kapalı), `#556173`.
- **test başlığı (5.4):** dolgu 12/12/12/16, aralık 8; ad 16/24·600 sarar; sayaç satırı (4 altta, aralık 4/12): harfli D/Y/B + "40 soru" 13; ok 24. Gövde soru ızgarası.
- **alt başlık kartı (7.3, 1. düzey):** kart radius 16, kartlar arası 8; başlık dolgu 14/12/14/16, aralık 8; başlık 17/24·700; meta (4 altta, 4/8) "4 madde" 13 + EksikTag; ok 22 (margin-top 2).
- **madde (7.3, 2. düzey):** üst ayraç 1 `#E8ECF1`; dolgu 12/8/12/16, min 56, aralık 12; numara rozeti 28; ad 16/24·600; EksikTag "Eksik"; ok 20. Açık gövde dolgu 0/16/16/56: tanım `bodyReading` 16/26; ExampleBox (12 altta); `text` "Kartı Aç" (Cards 20, margin 8 0 −8 −12).
- **Hareket:** 250 standard, ok 180°; açılan bölüm görünür alana; 7.3 açılışında ilk eksik maddeye 350 ms `ensureVisible`.
- `expanded` semantiği; dokunma bütün başlık; uzun ad sarılır.

#### C51 · `SmapExampleBox` (Tur 5 G4)
- Zemin `#F2F4F7` / `#18263D`, radius 12, dolgu 12/16. "Örnek" 13/20·700 `#556173`; örnek `bodyReading` (2 altta); açıklama 13/20 `#556173` (4 altta).

#### C52 · `SmapCardDeck` + `SmapStudyCard` (Tur 5 G5; 8.1)
- **Kart:** `#FFFFFF` / `#121D31`, **radius 24** [Ç-37], dolgu 24, min 392. Üstteki kartın gölgesi **yalnız sürüklenirken** `shadowOverlay` (koyu `#000` %56) [Ç-38]. Arkada iki kart kenarı: 12 ve 24 aşağıda, her yandan 12 ve 24 içeride; opaklık 0,75 (+ `shadowRaised`) ve 0,5.
- **İçerik:** üstte glif karosu 28 (glif 15) + ders adı 13/20·700, arası 8; sağ üstte favori (Star 22, margin −10 −12 0 0). Başlık 20/28·700 (20 altta); gövde `bodyReading` (12 altta); sol altta EksikTag "Eksik" (kenarlardan 24 / alttan 20).
- **Eylemler** (kartın 16 altında, arası 12): `secondary` "Detay" (120 genişlik) + `primary` "Öğrendim" (flex); Bildiklerim'de yalnız "Detay". "Detay" → `SmapCardSheet` [Karar].
- **Hareket:** kart parmağı izler; eşik %30 genişlik ya da 800 px/sn; geçince 250 ms'de çıkar, sıradaki ölçekle öne gelir. Kaydırma yalnız sonraki karta geçer; öğrenme yalnız "Öğrendim" ile (250 exit sağa + `success` + 6 sn "Geri Al" toast). İlk "Öğrendim"de ConfirmSheet + "Bir daha sorma" (cihazda). İyimser güncelleme; hata olursa geri alınır + toast. Hareketi azaltta çapraz geçiş.
- `customActions`: "Sonraki kart", "Önceki kart".
- **Paket [Karar]:** `flutter_card_swiper` (^7.2.0, mevcut); `appinio_swiper` kaldırılır.

#### C53 · `SmapCardSheet` (Tur 5 G6; 7.3)
- Uzun `SmapBottomSheet`. Başlık bölgesi: bağlam 13/20·600 `#556173` ("Türkçe · Sözcükte Anlam") + başlık 20/28 (2 altta); sağda favori (Star 22) + Kapat.
- İçerik dolgu 12/24/0: EksikTag; gövde `bodyReading` (12 altta); ExampleBox (12 altta).
- Alt bant: `primary` "Öğrendim" yalnız eksik kartta; `success` haptiği. İlk seferde 8.1 ConfirmSheet'i.

#### C54 · `SmapCardPreview` (Tur 3; 5.6)
- Kart (düğme) dolgu 16: başlık 16/24·600; açıklama 15/24 `#556173` (4 altta); Tag "Eksiklerimde" (12 altta). Kartlar arası 8.
- Grup başlığı: glif karosu 32, radius 10, glif 20 + ders adı 17/24·700, arası 10.
- Bölüm başı bilgi kartı (`SmapInfoHeaderCard`): dolgu 16, aralık 12; 40 daire `#E2EAF4` / `#36537C` (koyu `#1A2B45` / `#9BB3D3`) + Cards 22; "23 bilgi kartı eklendi" 17/24·700 + alt satır 13/20 `#556173`. Ardından `primary` "Kartları Çalış".

### E · Kimlik ve marka

#### C55 · `SmapAvatar`
- Boylar: 24 (bağlam şeridi), 28 (seçim alanı), 32 (küçülmüş HomeBand), 36 (görüşme satırı dateBlock), 40 (satır, HomeBand), 46 (kayıt satır içi seçici), 48 (StudentTile, AuthorRow), 56 (Hesap özeti, RoleOption, görüşme detayı), 64 (CoachCard), 72 (avatar sheet'i, boş durum).
- Daire, görsel kaplar; yedek zemin `#DCE2E9`. Görsel yoksa baş harf: `#E2EAF4` / `#1A3357`, 13/20·700 (boya göre ölçeklenir).
- Koç rozeti (yalnız koç listede gösterilirken): hap 20, yan dolgu 6, `#0F294A` / `#FFFFFF` 13/20·700, 2 pt `#FFFFFF` halka; 40'lık avatarın sağ altında ofset −14/−6; metin "Koç". Okunuş "Mehmet Özkan, koç".
- Ad ve avatar yalnız Anasayfa ve Hesap'ta (üst barda yok); istisna: koç bağlamındaki öğrenci ekranları, görüşme, öğrenci listeleri.

#### C56 · `SmapAvatarStack`
- En çok 3 + "+N" (32 daire `#E8ECF1`, 13·700); 2 pt beyaz halka, 8 bindirme. Okunuş "Elif Şahin, Kerem Aydın, Zeynep Kaya ve 2 öğrenci daha".
- Boş durum varyantı (10.1–10.2): 72, bindirme 16, 4 pt `#F2F4F7` (koyu `#0A1424`) halka.

#### C57 · `SmapAvatarPicker` [Ç-31]
- 7 avatar birden + sayı ("7 avatar" 13/20 `#556173`). Seçili avatarda boşluk + 2 pt `#0F294A` halka. Okunuş "Avatar 3, seçili" (toggled).
- **inline (2.5):** 46 pt, iki yana yaslı (space-between), 10 üstte; seçili `0 0 0 2 #F2F4F7, 0 0 0 4 #0F294A`.
- **sheet (9.2):** 4 sütun × 72, satırlar arası 20, dolgu 20/24/0; seçili `0 0 0 3 #FFFFFF, 0 0 0 5 #0F294A` (koyu [Karar] `#18263D` boşluk + `#C5D4E8` halka); başlık "Avatarını seç" + alt "7 avatar"; `primary` "Bu Avatarı Kullan"; seçim Kaydet ile kalıcı.

#### C58 · `SmapSubjectGlyph`
- Kare, radius 12 (32'de 10); ders zemini + vurgu Phosphor glifi.

| Karo | Glif | Nerede |
|---|---|---|
| 40 | 22 | ders satırı, ders karosu, sheet başlığı (7.1) |
| 36 | 19 | program satırı |
| 32 | 20 | CardPreview grup başlığı |
| 28 | 15 | çalışma kartı |
| karosuz | 14 / 20 | WeekGrid bloğu / HourSlot dolu slot |

#### C59 · `SmapLogoMark`, `SmapLockup` (Kit 1.26 / Tur 7 G1) [Ç-28]
- **horizontal (giriş 2.3):** işaret yüksekliği 36 (27,2 genişlik), arası 12, "SMAP" 24·800, harf aralığı −0,02 em, `#0F294A`.
- **vertical (açılış 2.1):** işaret 104 (78,6 genişlik), arası 20, "SMAP" 40·800, −0,02 em, `#FFFFFF`, zemin `#0F294A`.
- Boşluk alanı her yönde bir çizgi kalınlığı; uygulamada en küçük 20 pt; lacivert zeminde üst kanca beyaz. Logo yalnız açılış ve girişte. Okunuş "SMAP". SVG varlıkları §2.Y.

#### C60 · `SmapOnboardingPage`, `SmapPageDots` (Tur 7 G2; 2.1)
- Sağ üstte `text` "Geç" (top 54, right 8; son sayfada yok). Görsel alanı 380 yükseklik, ortalı (top 112). Başlık display (top 528, yatay 24), en çok 2 satır. Gövde `bodyReading` `#556173` (12 altta). Alt blok: kenarlardan 24, alttan 42, aralık 12: PageDots + `primary` "Devam Et"/"Başla".
- **PageDots:** aralık 6; geçerli 24 × 8, radius full, `#E05500`; diğerleri 8 × 8 `#C3CBD6`. Okunuş "3 ekrandan 1.".
- Sayfa geçişi 350 standard; görsel parçaları 250 ms gecikmeli belirir; hareketi azaltta yok.

#### C61 · `SmapIllustration`
- Kil seti: L 160 (Hoş geldin), M 128 (ekran düzeyi boş durum). Ekranda en fazla bir; `ExcludeSemantics`; karonun kendi köşesi (28/140); üstüne kenar/gölge/kap yok; koyu temada değişmez. Ders satırında, çipte, sekmede, düğmede, grafik yanında yok.

### F · Program

#### C62 · `SmapDayChip` (Tur 6 G4; 3.4, 3.5, 10.4)
- 48 × 64, radius 12, `#FFFFFF` / `#121D31`. Gün kısaltması 13/20·600 `#556173` ("Pzt"); tarih 17/24·700.
- Seçili: `#0F294A`, metin `#FFFFFF`, kısaltma `#C5D4E8`. Bugün: altta 6 pt nokta (alttan 5) `#E05500`; seçiliyken `#FF6600`.
- **large (3.5):** 56 × 76 + "2 konu" 13/16·600.
- Koyu: kısaltma `#A9B5C6`; seçili `#C5D4E8` / `#091A31`, kısaltma `#1A3357`; nokta `#FF8533` (seçiliyken `#E05500`).
- 7 gün space-between; `selectionClick`; okunuş "Cumartesi 10 Ekim, bugün, seçili" (toggled).

#### C63 · `SmapWeekGrid` (Stack + CustomPaint; Tur 6 G5; 3.4, 3.8)
- Saat sütunu **44** [Ç-34], gün sütunu 84, saat satırı 40, başlık satırı 44. Aralık 06:00–23:00.
- Başlık: kısaltma 13/20·600 `#556173` + tarih 15/20·700; bugünün altında 32 × 3 `accentLine` çizgi.
- Izgara çizgileri 1 `#E8ECF1` / `#26354D`; saat etiketi 13/20·600 `#556173` / `#A9B5C6`.
- Blok: radius 8, dolgu 4/6, aralık 2, örnek 78 × 36; ders zemini/vurgusu; glif 14 + ders adı 13/16·700 (vurgu renginde). Konu yok (dokununca konu detayı).
- Solda 12 genişlik kanvas→saydam kaydırma gölgesi.
- Açılışta yatay bugünün sütunu, dikey ilk çalışma (hareketi azaltta animasyonsuz).
- `role=grid`, ad "Haftalık program, 06:00–23:00; Pazartesi–Çarşamba solda"; blok "Cumartesi 10:00, Türkçe, Fiilde Çatı".

#### C64 · `SmapHourSlot` (Tur 6; 3.5)
- Satır min 52, dolgu 4/12/4/16, aralık 8, ayraç 1 `#E8ECF1`. Saat etiketi 44 genişlik, 13/20·600 `#556173`, üst dolgu 12.
- Slot radius 12, dolgu 8/4/8/12, aralık 10:
  - boş: saydam düğme, min 44; "09:00, boş, konu ekle".
  - odaklı/"Konu Ekle": `#E2EAF4` / `#0F294A`, 15/24·600, Plus 20, arası 6, odak halkası.
  - dolu: ders zemini; glif 20; ders adı 13/20·700 vurgu renginde; konu 15/22·600; çıkar düğmesi görsel 40 (X 18 `#556173`), dokunma 48 [Ç-26]; "{konu}, çıkar".
- Konu yerleşince blok 250 enter; `selectionClick`.

#### C65 · `SmapCalendar` (Tur 6 G6; 3.5)
- Kart dolgu 8/8/12. Başlık: önceki/sonraki ay ikon düğmeleri 48 (Caret 22) + ay adı 17/24·700 ("Ekim 2026").
- Izgara 7 × 46, aralık 4, ortalı, 4 altta. Gün adları satırı 24, 13/20 `#556173`. Gün hücresi 46 × 46, radius 12, 16/24·600.
- Geçmiş `#9AA5B4`·500, devre dışı ama okunur; seçili `#0F294A` / `#FFFFFF`; bugün içe 2 `#E05500`; çoklu seçim.
- Lejant: 20 × 20, radius 6, içe 2 `#E05500` + "Bugün" 13.
- Koyu [Karar]: kart `#121D31`, geçmiş `#56657C`, seçili `#C5D4E8` / `#091A31`, bugün `#FF8533`.

#### C66 · `SmapTimeWheel` (sheet içinde; Tur 8 G5; 9.6, 3.6)
- Saat ve dakika sütunları, arası 48; ortada ":" 24/40·700. Görünür 5 öğe, satır 40, aralık 4. Seçili olmayan 20/40·500 `#9AA5B4`; seçili 24/40·700 `#1B2232`. Seçim bandı 44, radius 12, `#E8ECF1`, margin 16/24, dolgu 8/0.
- Dakika 5'er adım. Ayarlanabilir öğe (yukarı/aşağı 5 dk); okunuş "Saat seçici, 22:00".
- Sheet: başlık + Kapat; `primary` "Kaydet".
- Koyu [Karar]: bant `#213049`, seçili `#EDF1F6`, seçili olmayan `#56657C`.
- **[Karar]** `ListWheelScrollView.useDelegate` (sonsuz döngü) ile kurulur.

### G · Kamera (her temada koyu)

#### C67 · `SmapCameraOverlay`, `SmapCameraStatusPill`, `SmapShutterButton` (Tur 2 G3; 4.1–4.4)
- Zemin `#000000`, metin `#FFFFFF`; tema ne olursa olsun koyu.
- **Üst bar:** 48 yükseklik, güvenli alanın altında (top 54, yatay 8). Kapat (X 20) ve "?" (Question 22): `cameraTranslucent` 40 daire, dokunma 48. Başlık "Optik Form" 15/24·600 `#FFFFFF`.
- **Durum hapı:** dolgu 8/16, radius 16, `rgba(10,20,36,.80)`, 15/24·600 `#FFFFFF`, ortalı, top 112; ikon 20 (form bulununca Check `#52CC8E`); `role=status`; metin çapraz geçişle değişir.
- **Kılavuz çerçeve:** 330 × 400 (x 36–366, y 200–600, oran 0,82); dışı `rgba(0,0,0,.48)`; köşe işaretleri 30 kol, 5 pt beyaz, yuvarlak; form bulununca köşeler beyaz %35.
- **Bulunan kenar:** dörtgen çizgi 3 `#FF6600`, dolgu `rgba(255,102,0,.10)`; köşe noktaları r 7 `#FF6600`, kenar 3 `#FFFFFF`; değişimler 150 ms.
- **Deklanşör:** 76 daire, 4 pt beyaz halka + 60 `#FF6600` disk; top 726. Basınca 0,92, 100 ms, `mediumImpact`; önizleme 100 ms donar; köşe ekranı 250 ms'de açılır. Ad "Fotoğraf çek". Her zaman çalışır (algılama öneri). Flaş ve galeri yok.

#### C68 · `SmapCornerHandles` + `SmapLoupe` (Tur 2; 4.4)
- Köşe noktası görünür 18 (r 9) `#FF6600`, kenar 3 `#FFFFFF`; sürüklerken 28 (r 14); dokunma 48. Dörtgen dışı `rgba(0,0,0,.55)`, kenar `#FF6600` 3.
- Büyüteç `RawMagnifier`: 116 daire, 2,6 kat, 3 pt beyaz halka, artı `#FF6600` 2 pt 20 uzunluk; parmağın üstünde (nokta +70 x, −150 y); açılış 100 ms ölçek, kapanış 150; gölge `shadowRaised`.
- Nokta kenara oturunca `selectionClick`. Adlar "Sol üst köşe", "Sağ üst köşe", "Sol alt köşe", "Sağ alt köşe" + `onIncrease/onDecrease` dört yönlü ayar.

#### C69 · `SmapStepList`, `SmapStepRow` (Tur 2 G1; 4.5–4.6)
- Kart yatay dolgu 16; satır dolgu 16/0 (≈56), aralık 12, üstten hizalı, ayraç 1 `#E8ECF1` / `#26354D`.
- Durum ikonu 24: bitti `#0F294A` daire + Check 14 beyaz (koyu `#C5D4E8` + `#091A31`); sürüyor `SmapSpinner` 24; bekliyor içe 2 `#C3CBD6` (koyu `#34445F`); hata WarningCircle `#C42D35` / `#FF8F8F`.
- Etiket 16/24: sürüyor 600; bekliyor 400 `#556173` / `#A9B5C6`; hata 600 hata rengi. Sağda değer 16/24·700 ("%64"). Sürüyor satırında `SmapLinearProgress.accent` 8 (8 altta).
- Adım değişimi 250 çapraz geçiş; `aria-live`; yüzde her %10'da bir duyurulur.

#### C70 · `SmapFormCheckView`, `SmapAnswerFixSheet` (Tur 2; 4.7–4.8)
- Görüntü kartı surface, dolgu 12, görüntü 346 × 212; "Formu büyüt" 48 alan, 40 daire `rgba(255,255,255,.94)` + `shadowRaised` [Ç-45], MagnifyingGlassPlus 20 `#0F294A`; `InteractiveViewer` minScale 1, maxScale 5, çift dokunuş 2,5.
- Kolon seçimi: `SmapSegmented.counter` ("1. kolon"… alt "boş yok"/"N boş"). Izgara: formCheck hücreleri. Ayrıntı §4 ekran 4.7.

### H · Overlay

#### C71 · `SmapBottomSheet` (Kit 1.20)
- **Anatomi:** tutamaç, başlık + alt başlık, Kapat, kaydırılan içerik, sabit eylem alanı.
- **Ölçü:** üst köşeler 24; tutamaç 36 × 4 radius full `#C3CBD6` / `#34445F`, üstten 8. Başlık bölgesi dolgu 12/12/0/24, aralık 8; başlık 20/28·700·−0,2 (padding-top 8); alt başlık 13/20 ya da 15/24 `#556173` (4 altta). Kapat `SmapIconButton.close` (margin-top −8). İçerik dolgu 16/24 (ekran sheet'lerinde 12/24/0), öğeler arası 16–20. Eylem alanı dolgu 16/24/**(güvenli alan + 8 ≈ 42)** [Ç-22], düğmeler arası 12.
- **Boylar:** `small` içeriğe göre; `medium` ≈ ekranın 2/3'ü (874'te üst 300); `full` üstte güvenli alan + 8 kalır [Ç-39].
- **Durumlar:** içerik kaydırılınca eylem alanı üstünde `inset 0 1 0 border-subtle` ayracı belirir. Klavye açık: eylem alanı klavyenin hemen üstünde, alt dolgu 16; odaklanan alan görünür alana. **Meşgul:** Kapat gizlenir, tutamaç `#E8ECF1`'e soluklaşır, içerik 0,6 opaklık + salt okunur, sürükleme/perde/Android geri kapatmaz, birincil düğme yükleniyor, `aria-busy`; hata olursa açık kalır, girilenler korunur.
- **Zemin:** `bg-raised` (`#FFFFFF` / `#18263D`); gölgesi yok. Perde `scrim` + σ 8 bulanıklık. Kamera üstünde perde koyu `rgba(2,6,14,.64)`.
- **Hareket:** açılış 350 enter, kapanış 250 exit, perde %0→%48; parmağı izler; %25 iniş ya da fırlatma kapatır; hareketi azaltta 150 opaklık.
- `dialog`, modal, başlıkla etiketli.
- **[Karar]** `showSmapSheet<T>(context, builder, {size, isDismissible, busy})` yardımcı fonksiyonu; root navigator'da açılır (alt çubuğun üstünde).

#### C72 · `SmapConfirmSheet(tone: normal|danger)` (Kit 1.21)
- Kapat yok. Gövde dolgu 20/24/0. Başlık 20/28·700 soru biçiminde, cümle düzeninde ("… kaldırılsın mı?"); gövde 15/24 `#556173` (8 altta; danger'da 12) ne olacağını söyler; isteğe bağlı `SmapCheckbox` "Bir daha sorma" (8–12 altta).
- Eylem alanı dolgu 24/24/güvenli+8 (onay kutusu varsa üst 12), arası 12: birincil = sorunun fiili ("Öğrendim", "Bağlantıyı Kaldır", "Çıkış Yap"); altında `quiet` "Vazgeç". "Evet" yok.
- **danger:** başlığın solunda 40 daire `#FCEAEA` / `#C42D35` + WarningCircle 22 (çizgi 18), başlık üst dolgu 6, arası 12; düğme `danger`; açılışta odak Vazgeç'te (halka görünür); kelime yazdırma yok. Koyu: daire `#3B1D22` / `#FF8F8F`, düğme `#FF8F8F` / `#3B0A10`, halka 2 `#18263D` + 2 `#9BB3D3`.
- Kırmızı yalnız tehlikeli onayda (çıkış onayı normal ton). Perdeye dokunmak Vazgeç. 350 ms.
- `Future<bool> showSmapConfirm({title, body, confirmLabel, tone, dontAskAgainKey})`.

#### C73 · `SmapComingSoonSheet`
- Yalnız kitte; hiçbir ekranda kullanılmaz (D-4). **Yapılmaz.**

#### C74 · `SmapToast` + `SmapToastController` (Kit 1.22)
- **Konum:** alt çubuğun 8 üstünde (bottom 110), yanlardan 16; çubuğu örtmez; çubuk gizliyse güvenli alan + 16. Aynı anda tek toast. **[Karar]** ekran `toastBottomInset` verebilir (8.1 kart destesinde eylem satırının 8 üstü) [Ç-36].
- **Ölçü:** min 48, dolgu 12/16, radius 12, aralık 12; `#0F294A`, metin 15/24 `#FFFFFF`; `shadowOverlay`. İkon 20 (çizgi 18): info Info `#C5D4E8`, success CheckCircle `#52CC8E`, error WarningCircle `#FF8F8F` [Ç-40].
- **Geri Al:** toast sağ dolgu 4; düğme 48, dolgu 0/14, dikey margin −12; 15/24·700 `#FFFFFF` [Ç-56]; sol ayraç `inset 1 0 0 rgba(255,255,255,.20)`.
- **Koyu (ters yüzey):** `#E8ECF1` / `#1B2232`, gölge `#000` %56; eylem `#1A3357`·700, ayraç `#C3CBD6` (dolgu 0/4/0/16); ikonlar açık durum renkleri (success `#0B6E3E`, [Karar] info `#36537C`, error `#C42D35`).
- **Süre:** 4 sn; Geri Al'lı 6 sn. 16 pt yukarı kayarak 250 enter; exit; yukarı kaydırınca kapanır; hata türünde `error`.
- info/success `role=status`, error `role=alert`. Emoji, "Hata:" öneki, iç kod yok. Kalıcı hata ekranda durum olarak çizilir; toast yalnız geçici.
- `SmapToast.show(context, message, {type, actionLabel, onAction})`; shell seviyesinde `Overlay` ile barındırılır.

### I · Durum kalıpları

#### C75 · `SmapOfflineStrip` (Kit 1.22)
- Barın hemen altında; içeriği iter; bant köşeleri düzleşir. Min 40, dolgu 8/16, aralık 10; `#1B2232` / `#FFFFFF` 13/20·600 (15,89); WifiSlash 18. Koyu ters yüzey `#E8ECF1` / `#1B2232`.
- Metin "Çevrimdışısın. Son kaydedilen veriler gösteriliyor."; bağlantı gelince 2 sn "Bağlandın" [Ç-23] ([Karar] ikon WifiHigh 18), sonra 250 ms'de kalkar. `role=status`; haptik yok.
- Son veri gösterilir; gönderim gerektiren eylemler pasif ve nedeni yazılı (v1'de kuyruk yok).
- **[Karar]** bağlantı durumu `connectivity_plus` + isteğin ağ hatası; `ConnectivityNotifier` shell'de.

#### C76 · `SmapSkeleton`
- Bloklar `bg-sunken`, radius 8 (grafik 12); gerçek düzenin şeklini taşır; bant ve sekmeler hemen gelir. Parıltı §1.13. 15 sn'de veri yoksa hata; sonsuz iskelet yok. `aria-busy`, "Yükleniyor".

#### C77 · `SmapEmptyState(level: screen|section)`
- **screen:** ortalı, yan 32, gövde başlangıcından 64 aşağıda (panolarda y≈200–260). Görsel M 128 (ya da üç avatar 72); başlık 20/28·700 (24 altta); tek cümle 15/24 `#556173` (8 altta, max 310); tek eylem `primary` (24 altta, isteğe bağlı baş ikon, otomatik genişlik dolgu 0/20).
- **section:** kart dolgu 16 (5.x bölüm boşlarında 24 ya da 28/24, ortalı), aralık 4; başlık 16/24·700 (opsiyonel) + cümle 15/24 ya da 13/20 `#556173` + `text` düğme (yükseklik 48, alt margin −12). 5.4 "Boşlar" boşunda 32 pt Boş glif çipi.
- Görsel eşlemesi: Denemelerim/Analizlerim → Harita; Programım → Ampul; Deste/ders eksik kalmadı → dersin kil görseli (Tarih Sütun …); Öğrencilerim/Koç Anasayfa → üç avatar; Görüşmelerim → Hokka.
- Görsel atlanır; okuma başlıktan başlar.

#### C78 · `SmapErrorState(level: screen|section)` [Ç-29]
- **screen (sekme içi):** ortalı, yan 32; 80 daire `#FCEAEA` / `#3B1D22` + WarningCircle 40 `#C42D35` / `#FF8F8F`; başlık 20/28·700 (20 altta); cümle 15/24 `#556173` (6 altta) "Bağlantını kontrol edip tekrar dene."; `quiet` tam genişlik "Tekrar Dene" (20 altta). `role=alert`. Tekrar Dene iskelete döner; aynı hata tekrar gelirse metin değişmez; ham hata/kod yok.
- **section:** kart dolgu 16 (16/16/8), aralık 12; WarningCircle 22–24 `#C42D35`; metin 15/24 ("Bugünün programı yüklenemedi."); `text` "Tekrar Dene" (ArrowClockwise 18, arası 6). Yalnız o bölümü yeniler. Haptik yok.

#### C79 · `SmapStatusView` (tam ekran durum; 2.4, 2.7, 4.9, 4.10, 9.4)
- `size: blocking` (2.7, 2.4 bitti, 9.4 silindi): 96 daire (ikon 48); başlık display 32/40 (9.4'te 24/32) 28 altta; gövde `bodyReading` `#556173` (10–12 altta); en çok iki düğme, alttan 42; ortalı, top ≈190–220, yan 24–32.
- `size: flow` (4.9 talep alındı, 4.10 hatalar): 80 rozet (ikon 40); başlık 24/32 (kamera karesinde 20/28) 24 altta; gövde 15/24 (8 altta).
- Rozet tonları: success `#E4F4EA` / `#0B6E3E`; error `#FCEAEA` / `#C42D35`; info `#E2EAF4` / `#36537C`; offline `#E8ECF1` / `#3E4858`; kamera koyu `#18263D` / `#EDF1F6`. Zorunlu güncellemede uygulama ikonu 96, radius 21,5.
- `busy` varyantı (9.4): 48 spinner + başlık 20/28 (24 altta) + 15/24 `#556173` (6 altta); geri kapalı.
- Odak birincil düğmede; hata `role=alert`, bilgi `role=status`. `error` haptiği yalnız kullanıcı işlemi başarısızsa.

### J · Kabuk

#### C80 · `SmapRootBand` (Kit 1.18)
- Zemin `#0F294A` (iki temada). Üst dolgu güvenli alan (62). Alt köşeler 24.
- Başlık satırı 56: dolgu 0/16 (eylem varsa 0/4/0/16, iki uç); başlık 24/32·700·−0,3 `#FFFFFF`. Sağda en çok bir eylem: `SmapIconButton.onNavy` 48, adlı ("Yeni görüşme", "Öğrenci ekle").
- Bant altı: boşluk 16 → 134. Bant içi segment (`SmapSegmented.onNavy`, dolgu 0/16/16) → 178. Bant içi sekme (`SmapTabBar.onNavy` 48 + 8) → 174.
- **Küçülme:** 56 pt kaydırmaya bağlı, linear; bant 110 (62 + 48); başlık 24→17/24·700; alt köşeler düzleşir. Segment/sekme varsa bantta sabit kalır. Çevrimdışı şeridi çıkınca köşeler düzleşir.
- Durum çubuğu açık içerik (`SystemUiOverlayStyle.light`). Bantta logo ve avatar yok (istisna HomeBand ve ProfileSummary). Koyuda bant yine `#0F294A` (kanvasa 1,26:1, dekoratif).
- **[Karar]** `SliverPersistentHeader` + `SmapRootBandDelegate(minExtent: 62+48, maxExtent: 134|174|178)`.

#### C81 · `SmapHomeBand(role: student|coach)` (Tur 6 G1; 3.1, 10.1)
- Dolgu 62/16/20, alt köşeler 24.
- **student:** satır min 56, aralık 12: avatar 40 + selam 20/28·700·−0,2 `#FFFFFF` "Merhaba, Alparslan". Sayaç satırı (8 altta, aralık 12, alta hizalı): sayı metric-lg `#FFFFFF` "252" + sütun (alt dolgu 4): "gün kaldı" 15/20·700 `#FFFFFF` + "YKS · 19 Haziran 2027 Cumartesi" 13/20 `#C5D4E8`. Tek okunuş "YKS'ye 252 gün kaldı. Sınav 19 Haziran 2027 Cumartesi." Sayaç cihazda, gece yarısı yenilenir.
- **Küçülmüş (110):** dolgu 62/16/0, satır 48, aralık 10; avatar 32; selam 17/24; sağda "YKS'ye 252 gün" 13/20·600 `#C5D4E8`.
- **coach:** avatar 40 + selam "Merhaba, Mehmet" + alt satır 13/20 `#C5D4E8` "5 öğrenci · önümüzdeki 7 günde 2 görüşme" (öğrenci yoksa "Henüz öğrencin yok"); sayaç yok.
- %130: selam 26/34, sayaç 52/60. Çekince yenilenir (`RefreshIndicator`, bırakınca `selectionClick`). Eyebrow ve gri alt satır üçlüsü yok.

#### C82 · `SmapDetailBar` (Kit 1.18)
- Zemin `bg-canvas`. Üst dolgu 62 (geri düğmesi top 54, left 4). Satır 48: dolgu 0/4 (BarAction varsa 0/12/0/4 → BarAction top 58, right 16).
- Geri: CaretLeft 24 `#1B2232` / `#EDF1F6`, 48 alan; Android sistem geri de çalışır. Alternatif sol öğe: `text` "Vazgeç" (9.2 düzenleme), X (tam ekran akış adım 1 ve kamera sonrası ekranlar), gizli (3.6 düzenleme modu).
- Sağda en çok bir eylem: `SmapIconButton` 48 ya da `SmapBarAction` 40.
- **Büyük başlık (içerikte):** 24/32·700·−0,3 (2.x giriş/kayıt ekranlarında display ya da 24), 3 satıra kadar, dolgu 8/16/0 (top 110).
- **Kaydırılmış hâl:** bar 102–110, opak kanvas; başlık bara iner: **17/24·700, sola hizalı, en çok 2 satır** [Ç-21]; altta `0 1 0 border-subtle` ayracı belirir. Deneme Detay'da altına yapışık TabBar girer.
- Durum çubuğu koyu içerik.

#### C83 · `SmapContextStrip` (Kit 1.18 / Tur 9; 10.4)
- DetailBar'ın altında (top 102), 40 yükseklik, `#F1F5FA` / `#1A2B45`, üst ve alt `inset 1 border-subtle` (koyu `#26354D`). Dolgu 0/16, aralık 8. Avatar 24; "{Ad Soyad}'ın verileri" 13/20·600; sağda "12. Sınıf · EA" 13/20 `#556173`.
- Kaydırınca barla birlikte sabit; içerik 40 aşağı kayar. Ekran okuyucuda ilk okunan: "Alparslan Kuloğlu'nun verileri, 12. sınıf, Eşit Ağırlık". Alan kısaltmaları [Karar]: Sayısal "SAY", Eşit Ağırlık "EA", Sözel "SÖZ", Dil "DİL".

#### C84 · `SmapBottomBar(role: student|coach)` + `SmapCameraButton` (Kit 1.19)
- **Çubuk:** 68 + güvenli alan (34) = 102; zemin `bg-bar` + σ 20 bulanıklık; üst köşeler 24; üst ayraç `inset 0 1 0 #DCE2E9` / `#26354D`; gölge yok. Yuvalar 4 × 82,5 + kamera 72 (esnek).
- **Sekme:** üst dolgu 14, aralık 6; ikon 24; etiket 12/16·600 `#556173` / `#A9B5C6` (Regular ikon). Seçili: Fill ikon `#0F294A` / `#EDF1F6`, etiket 700. Gösterge 32 × 4, alt köşeler 4, `accentLine`, üst kenarda. Dokunma yuvanın tam yüksekliği.
- **Kamera düğmesi:** 56 × 56, radius 16, `#FF6600`; 16 yukarı taşar (top −16, left 8), yuvada ortalı; Camera 28 `#0F294A`; `shadowRaised` (koyu `#000` %40). Altında "Okut" 12/16·700 `#1B2232` / `#EDF1F6` (top 44, `aria-hidden`). Ad "Okut: deneme formunu kamerayla okut". Basınca 0,92, 100 ms + `mediumImpact`. Sekme değildir; gösterge almaz; tam ekran kamera akışını açar.
- **Sekmeler:** öğrenci Anasayfa (House) · Analizlerim (**ChartLineUp** [Ç-60]) · Okut · Derslerim (BookOpen) · Hesap (UserCircle). Koç Anasayfa (House) · Öğrencilerim (Users) · Okut · Görüşmelerim (Chats) · Hesap (UserCircle).
- Etiket 12 pt tek istisna; `FittedBox(scaleDown)`, uzun basışta büyük ikon+ad balonu.
- Okunuş "Analizlerim, sekme, 5'te 2".
- **Davranış:** seçili sekmeye yeniden dokunmak o dalın köküne döndürür ve başa kaydırır; her sekmenin kendi yığını; yalnız tam ekran akışlarda gizlenir (kamera ve gönderim/form kontrol, sonuç anı, onboarding, giriş/kayıt, yeni program akışı, hesap silme ilerleme/bitti).
- **Hareket:** gösterge 250 standard kayar; ikon Regular→Fill 150; `selectionClick`.
- **mihr_ui:** `FrostedContainer(blur: MihrBackdropBlurs.xl, overlayColor: bg-bar)`.

#### C85 · `SmapStudentScope` (InheritedWidget; Tur 9)
- `SmapStudentScope({required String? studentId, required bool coachView, StudentSummary? student})`.
- `coachView == true`: ContextStrip eklenir; düzenleme eylemleri ve öğrenciye özel öğeler gizlenir: favori yıldızı, "Öğrendim", "Günü Sıfırla", "Düzenle", "Yeni Program", "Bu Konuyu Çalış"/"Kartları Çalış" [Karar: koç için kart öğrenme yok; konu/kart görüntüleme açık]; Program salt okunur + InfoBox.
- Repository çağrıları `studentId`'yi parametre olarak taşır.

#### C86 · `SmapShell`
- Rol başına `StatefulShellRoute.indexedStack` (§3); BottomBar'ı gösterir; Toast `Overlay`'i ve OfflineStrip durumunu barındırır.

### 2.X İkon seti (Phosphor, `phosphor_flutter`)

- Normalde Regular, seçiliyken Fill. Panolardaki çizimler yaklaşık; uygulamada aynı adlı Phosphor ikonu. Material ikonları ve PNG ikonlar kalkar; `cupertino_icons` kaldırılır.
- Boylar: 16 (çip), 20 (düğme içi, satır oku), 24 (varsayılan), 28 (kamera); D/Y/B glifi 10/14; etiket ikonu 14. Çizgi 24 pt'de 1,5 (256 birimde 16). Renk: birincil `text-primary`, ikincil `text-secondary`, seçili lacivert Fill.
- **Alt çubuk:** House, ChartLineUp, BookOpen, UserCircle, Users, Chats, Camera.
- **Gezinme:** CaretLeft, CaretRight, CaretDown, CaretUp, X.
- **Arama/süzme:** MagnifyingGlass, MagnifyingGlassPlus, SlidersHorizontal ("Süz ve Sırala"; 6.2'deki dikey "Sliders" çizimi yerine [Karar]), Plus, Minus.
- **D/Y/B ve durum:** Check, X, Minus, Info, CheckCircle, WarningCircle, Warning, WifiSlash, WifiHigh [Karar], ArrowClockwise, Clock, TrendDown, Hourglass (kullanılmaz).
- **Hesap/paylaşım:** Eye, EyeSlash, Star (Fill), Bell, Trash, SignOut, Copy, ArrowSquareOut, ShareNetwork, Lock, FileText, Envelope, UserCircle, Users, Question.
- **İçerik/program:** Cards, Flag, Image, Camera, CameraSlash, Wrench, PencilSimple, Calendar, CalendarBlank, ArrowUp, ArrowDown, ArrowCounterClockwise (Günü Sıfırla), ChartLine (görüşme detayı "Öğrencinin verileri").
- **Ders glifleri:** TextAa, Feather, Bank, Globe, MathOperations, Angle, Atom, Flask, Dna.

### 2.Y Varlık envanteri (`assets/`)

**Logo (1.26, S-rota, Öneri A):** 1080 ızgara; işaret kırpımı `viewBox 240 143 600 794`; çizgi 120; örgü boşluğu 30 (maske çizgisi 180); köşe yarıçapları 40, 135, 225; yuvarlak uç ve birleşim. İki kanca aynı biçim, merkez etrafında 180°. Örgü: solda lacivert, sağda turuncu üstten geçer (turuncu yol, x < 540 yarısına kırpılmış lacivert yol maskesiyle kesilir; lacivert yol x ≥ 540 turuncu maskesiyle).
- Üst kanca (navy/beyaz): `M 775 655 V 248 A 40 40 0 0 0 735 208 H 530 A 225 225 0 0 0 305 433 V 520 A 135 135 0 0 0 440 655 H 560`
- Alt kanca (orange-500): `M 305 425 V 832 A 40 40 0 0 0 345 872 H 550 A 225 225 0 0 0 775 647 V 560 A 135 135 0 0 0 640 425 H 520`
- İkon kurgusu: işaret 1024 karoda %70 (translate 134, scale 0,70). Pafta zemini üç dikey şerit 342/1024 genişlik, x = 0/341/682: lacivert `#0F294A`/`#163660`/`#123056`; açık `#FFFFFF`/`#F2F5F9`/`#F7F9FC`; 40 pt altında düz lacivert. Yazı, gradyan, parlama, gölge, kontur, döndürme yok; turuncu tek başına kullanılmaz.

| Dosya | İçerik |
|---|---|
| `brand/smap_mark.svg` | üst `#0F294A`, alt `#FF6600` |
| `brand/smap_mark_on_navy.svg` | üst `#FFFFFF`, alt `#FF6600` |
| `brand/smap_mark_mono_navy.svg`, `brand/smap_mark_mono_white.svg` | tek renk |
| `brand/smap_lockup_horizontal.svg`, `brand/smap_lockup_horizontal_on_navy.svg` | işaret + "SMAP" Plus Jakarta Sans ExtraBold, −%2, çizgiye dönüştürülmüş |
| `brand/smap_lockup_vertical_on_navy.svg` | açılış |
| `app_icon/app_icon_1024.png` | varsayılan: lacivert pafta + beyaz üst kanca; iOS, saydamlıksız |
| `app_icon/app_icon_light_1024.png` | açık pafta (alternatif; karar kullanıcıda T1.34) |
| `app_icon/app_icon_ios_dark_1024.png` | zemin `#0A1424`, üst kanca `#6C8BB6` |
| `app_icon/app_icon_ios_tinted_1024.png` | gri tonlu kaynak (zemin `#111111`) |
| `android/ic_launcher_foreground.png` (432 px) + `ic_launcher_background.png` | ön katman işaret 66/108 güvenli alanda; arka pafta |
| `android/ic_stat_smap.png` | bildirim, beyaz siluet, 24 dp (mdpi 24 … xxxhdpi 96) |
| `splash/splash_mark.png` | `flutter_native_splash`: zemin `#0F294A`, dikey lockup + Android 12 ikon katmanı |
| `store/play_icon_512.png`, `store/appstore_icon_1024.png` | mağaza |

`flutter_launcher_icons.image_path` bugün `assets/logotext.png` → `app_icon/app_icon_1024.png`. Logo SVG'leri **[Karar]** yukarıdaki path verileriyle elle üretilir (`flutter_svg` mevcut) ya da `CustomPainter` (`SmapLogoMark`).

**Kil illüstrasyon (1.25, 11 görsel):** 3x (480 px) PNG/WebP gerekir; panolardakiler 140 px kırpım — asıl dosyalar kullanıcıdan istenir. Klasör `illustrations/clay_*.webp` + `2.0x/` + `3.0x/`. Dosyalar: `clay_book` (Türkçe), `clay_inkwell` (Edebiyat; Görüşmelerim boş), `clay_column` (Tarih), `clay_globe` (Coğrafya), `clay_operations` (Matematik; yalnız mağaza), `clay_pyramid` (Geometri; yalnız mağaza), `clay_atom` (Fizik), `clay_flask` (Kimya), `clay_leaf` (Biyoloji), `clay_bulb` (Programım boş), `clay_map` (Denemelerim boş, Hoş geldin L 160).

**Avatarlar (1.17):** öğrenci ve koç aynı 7 avatar. Bugün `assets/avatars/1avatarN3.png`, `3avatarN3`, `4avatarN3`, `5avatarN3`, `6avatarN3`, `8avatarN3`, `9avatarN3` (256 px; `app_colors.dart` satır 29–35). Öneri `avatars/avatar_01…07.png`; varsayım: av-1…av-7 bu sırayla eşleşir. Sunucuda dosya adı (`photo`) tutulur → [Karar] eşleme tablosu `avatarIdToAsset` + geriye dönük eski ad desteği. 72 pt × 3 = 216 px yeterli.

**Diğer:** onboarding görselleri 3 adet → widget olarak kurulur (`OnboardingScanVisual`, `OnboardingAnalysisVisual`, `OnboardingGapsVisual`; §4 2.1). Kamera öğretici çizimi → widget/`CustomPainter` (`OmrTutorialIllustration`). Sosyal giriş: Apple ve Google resmî düğme varlıkları (açık madde). Font TTF (§1.11). Deneme kapakları sunucudan; yer tutucu nötr kutu + Image ikonu.

**Kaldırılacak varlıklar (silmeden önce referans kontrolü):** `ob1.png`…`ob6.png` (≈7,3 MB), `loginImage.png`, `menuIcons/smapc.png` ve `menuIcons/` stok illüstrasyonları, düz ders PNG'leri (`turkce.png`, `tarih.png`, `edebiyat.png`, `cografya.png`, `mat.png`, `physics.png`, `biological.png`, `fen.png`, `geometry1.png`, `icons/` ders PNG'leri), ≈40 logo varyantı (`logo*.png`, `logos*`, `logosm*`, `logob*`, `logod*`, `logoy*`, `llg*`, `smaplogo.png`, `logoSmap.png`, `logotext.png`, eski üçgen logo `#FF6400`), "Stundent map" taslağı. Yazar fotoğrafları `assets/authors` (38 MB) **kalır**.

### 2.Z Yapım sırası (bağımlılık katmanları)

| Katman | İçerik | Bağımlılık |
|---|---|---|
| **K0 Altyapı** | `pubspec` (phosphor_flutter, permission_handler, go_router, share_plus, connectivity_plus, package_info_plus, url_launcher, TTF; isteğe bağlı mihr_ui), `lib/core/theme/*` (§1.15), `SmapHaptics` + platform kanalı, `SmapMotion`, biçimlendiriciler + tr katlama + ek uyumu, `component_gallery` iskeleti | — |
| **K1 Atomlar** | `SmapPressable`, `SmapFocusRing`, `SmapIcon`, `SmapSubjectGlyph`, `SmapAvatar`, `SmapDybGlyph`, `SmapTag`, `SmapEksikTag`, `SmapSpinner`, `SmapLinearProgress`, `SmapSessionProgress`, `SmapSuccessRing`, `SmapSkeleton`, `SmapMetricText`, `SmapDeltaText`, `SmapNoticeBox`, `SmapLogoMark`/`SmapLockup`, `SmapIllustration`, `SmapPageDots` | K0 |
| **K2 Kontroller** | `SmapButton`, `SmapIconButton`, `SmapBarAction`, `SmapCheckbox`, `SmapRadio`, `SmapSwitch`, `SmapChip`/`SmapFilterPill`/`SmapChipGroup`, `SmapSegmented`, `SmapTabBar`, `SmapTextField` → `SmapSearchField`, `SmapTextArea`, `SmapCodeInput`, `SmapSelectField` (sheet K4'te bağlanır) | K1 |
| **K3 Bileşikler** | Liste: `SmapListGroup`, `SmapSettingsRow`, `SmapSectionHeader`, `SmapRadioListTile`. Veri: `SmapDybCounter`, `SmapDybStackedBar`/`SmapTestBarRow`, `SmapQuestionCell`, `SmapStatBox`, `SmapNetChart`. Ders/konu: `SmapSubjectRow`, `SmapSubjectTile`, `SmapTopicRow`, `SmapTopicResultRow`, `SmapMostMissedCard`. Deneme: `SmapExamRow`, `SmapExamSummaryCard`, `SmapExamHeader`, `SmapScoreCard`. İçerik: `SmapAccordion`, `SmapExampleBox`, `SmapCardPreview`, `SmapInfoHeaderCard`, `SmapStudyCard`, `SmapAuthorRow`. Kimlik: `SmapAvatarStack`, `SmapAvatarPicker`, `SmapRoleOption`, `SmapProfileSummary`, `SmapCoachCard`, `SmapOnboardingPage`. Koç: `SmapStudentRow`, `SmapStudentTile`, `SmapAttentionRow`, `SmapMeetingRow`, `SmapCodeCard`. Program: `SmapDayChip`, `SmapCalendar`, `SmapHourSlot`, `SmapWeekGrid`, `SmapProgramItemRow`, `SmapProgramRow`, `SmapTimeWheel`. Kamera: `SmapCameraOverlay`, `SmapCameraStatusPill`, `SmapShutterButton`, `SmapCornerHandles`/`SmapLoupe`, `SmapStepRow`/`SmapStepList`, `SmapFormCheckView` | K2 |
| **K4 Overlay** | `SmapBottomSheet` (+ boylar, klavye, meşgul) → `SmapConfirmSheet`, `SmapCardSheet`, SelectField sheet'i, TimeWheel sheet'i, AvatarPicker sheet'i, `SmapAnswerFixSheet`; `SmapCardDeck`; `SmapToast` + controller | K3 |
| **K5 Kabuk ve durum** | `SmapRootBand`, `SmapHomeBand`, `SmapDetailBar`, `SmapContextStrip`, `SmapOfflineStrip`, `SmapBottomBar` + `SmapCameraButton`, `SmapStudentScope`, `SmapShell` + router (§3), `SmapEmptyState`, `SmapErrorState`, `SmapStatusView`, `AsyncSection` durum makinesi (iskelet → 15 sn → hata) | K4 |
| **K6 Varlıklar** (paralel) | §2.Y logo/ikon üretimi, launcher ve splash ayarı, avatar yeniden adlandırma, kil seti (asıl dosyalar gelince), temizlik | — |
| **K7 Ekranlar** | §4 grupları (§3 route'larıyla) | K5 |


---

## 3. Kabuk ve navigasyon

### 3.1 Yönlendirme altyapısı

- **Bugün:** Navigator 1; `MaterialPageRoute` push'ları; named route yalnız `/onboarding`, `/login`, `/home`; go_router yok. Hesap sekmesinde `AccountNavNotifier` + `AccountRoute` enum (hub, account, payment, savedCards, contracts, notifications). Rol `userRole` string'inden ('coach'). Kök sekmeler: HomeFlowScreen, AnalyticsView, MyCardScreen ("Derslerim"), AccountFlowScreen.
- **Hedef [Karar]:** `go_router` (yeni bağımlılık). Rol başına bir `StatefulShellRoute.indexedStack` (öğrenci 4 dal, koç 4 dal); her dalın kendi `Navigator`'ı (sekme başına yığın, T1.9). Tam ekran akışlar (kamera, sonuç anı, yeni program, giriş/kayıt, onboarding, hesap silme ilerleme) **root navigator**'da (`parentNavigatorKey: rootKey`), alt çubuk görünmez. Sheet'ler route değildir; root navigator'da `showSmapSheet` ile açılır (alt çubuğun ve perdenin üstünde).
- Eski named route'lar alias: `/login` → `/auth/login`, `/onboarding` → `/onboarding/intro`; `AccountNavNotifier`/`AccountRoute` kalkar.
- **Global redirect sırası (açılışta ve her `refreshListenable` değişiminde):** (1) min sürüm altında → `/blocking/force-update`; (2) sunucu bakım yanıtı → `/blocking/maintenance`; (3) tanıtım görülmedi → `/onboarding/intro`; (4) oturum yok → `/welcome` (tanıtım görüldüyse); (5) rol `student` → `/home`, `coach` → `/coach/home`, diğer → `/blocking/unknown-role`. Oturum düşerse (401) global `SessionExpiredSheet` açılır, route değişmez.
- **İçerik ekranının sekmesi [Karar; T3.1, T6.10, 7.6/8.1 panolarından]:** Deneme Detay ve Soru Detay her zaman **Analizlerim** dalında; Ders detayı, Konu detayı ve Kart destesi her zaman **Derslerim** dalında; Programım **Anasayfa** dalında; koçta öğrenci verisi **Öğrencilerim** dalında. Başka sekmeden açılırken `context.go(...)` ile o dala geçilir; geri o dalın yığınında yürür. Seçili sekmeye yeniden dokunmak dalın köküne döner ve başa kaydırır.

### 3.2 Alt çubuk (`SmapBottomBar`)

- Öğrenci: Anasayfa · Analizlerim · **Okut** · Derslerim · Hesap. Koç: Anasayfa · Öğrencilerim · **Okut** · Görüşmelerim · Hesap (D-29).
- Okut sekme değildir: `/scan` akışını root'ta açar (koçta önce öğrenci seçim sheet'i).
- Gizlendiği yerler (root route'lar): kamera akışı (`/scan/*`), sonuç anı, onboarding, giriş/kayıt/şifre sıfırlama, genel blok ekranları, yeni program akışı, hesap silme ilerleme/bitti. Kart destesi (8.1) ve Soru Detay (5.7) **alt çubukludur** (panolarda çizili; kit 1.19'daki "kart oturumunda gizli" kuralının yerini aldı) [Ç-61].

### 3.3 Üst bar ailesi (9 tür → 2 tür + varyantlar)

| Tür | Bileşen | Nerede |
|---|---|---|
| Kök bant | `SmapRootBand` (134; sekmeli 174; segmentli 178; küçülmüş 110) | Analizlerim (sekmeli), Derslerim (segmentli), Hesap (+ProfileSummary), Öğrencilerim, Görüşmelerim |
| Selam bandı | `SmapHomeBand` | Anasayfa (öğrenci, koç) |
| Detay barı | `SmapDetailBar` (+ büyük başlık → kısa bar) | Bütün detay ekranları, 2.x ekranları (yalnız geri) |
| Bağlam şeridi | `SmapContextStrip` (DetailBar altında) | Koç bağlamındaki öğrenci ekranları |
| Kamera barı | `SmapCameraOverlay` üst barı (koyu) | 4.2–4.4, 4.10-4 |
| Bar yok | — | Splash, sonuç anı (yalnız Kapat), tam ekran durum ekranları |

### 3.4 Sheet çerçevesi

Seçim ve onaylar alttan sheet (ortadaki dialoglar kalkar). Bütün sheet'ler `SmapBottomSheet` / `SmapConfirmSheet` üstüne:

| Sheet | Pano | Boy | Not |
|---|---|---|---|
| Sözleşme metni (Kullanım Koşulları / KVKK) | 2.5 | full | Kayıt onay bağlantıları |
| Sınıf / Alan seçimi | 2.5, 9.2 | small | Radyo satırları, seçince kapanır |
| Oturum sona erdi | 2.7-2 | small | Kapatılamaz |
| Kamera izni (öncesi / reddedildi) | 4.1 | medium | Anasayfa üstünde |
| Öğretici | 4.2 | full | Kamera üstünde, koyu perde |
| Optik okuma kapalı | 4.10-2 | small | Tek "Tamam" |
| Cevap Düzelt | 4.7 | full | Kolon → soru → şık |
| Okutmadan çıkılsın mı? | 4.7 | confirm | normal |
| Talep onayı | 4.9 | confirm | normal + özet kutusu |
| Bildirim izni ön açıklaması | 5.2 | small | Bayrakla kapalı (T2.17) |
| Süzgeç (Analizlerim) | 6.1 | medium | Sınav, Alan, Ders |
| Süz ve Sırala (Denemelerim) | 6.2 | medium | Tarih, Sıralama |
| Web'de | 7.1 | small | |
| Kart (CardSheet) | 7.3, 5.6, 5.7, 8.1 | full | |
| Yazar | 7.4 | full | |
| Kartı Bildiklerim'e taşı | 8.1 | confirm | normal + "Bir daha sorma" |
| Konu ekle (Çantam/Dersler) | 3.5 | full | |
| Saat seçici (program saati) | 3.6 | small | TimeWheel; çizilmemiş, 9.6 kalıbıyla |
| Program kaydedilmesin mi? | 3.5 | confirm | normal |
| Günü sıfırla / Programı iptal | 3.6 | confirm | danger |
| Çıkış | 9.1 | confirm | normal |
| Avatar seç | 9.2 | medium | |
| Değişiklikler kaydedilmesin mi? | 9.2 | confirm | normal |
| Hesabın silinsin mi? | 9.4 | confirm | danger |
| Koç bağlantısı kaldırılsın mı? | 9.5 | confirm | danger |
| Koçluk kodu nedir? | 9.5 | small | Tek "Tamam" |
| Sessiz saat başlangıcı/bitişi | 9.6 | small | TimeWheel |
| Öğrenci ekle / eklendi | 10.3 | full | Credentials bir kez |
| Yeni görüşme | 10.5 | full | |
| Öğrenci seç (koç kamera, yeni görüşme) | 10.5, T9.9 | full | Çizilmemiş: radyo satırı + avatar + arama [Karar] |
| Not ekle / düzenle | 10.6 | medium | Klavye üstü eylem |
| Not silinsin mi? | 10.6 | confirm | danger |

### 3.5 Global katmanlar

- **Toast:** shell'in üstünde tek `Overlay`; alt çubuk varken bottom 110, yokken güvenli alan + 16; ekran `toastBottomInset` verebilir.
- **Çevrimdışı şeridi:** `ConnectivityNotifier` (shell); her ekranın bar/band'inin altına `SmapOfflineStrip` eklenir (sliver olarak, içeriği iter, bant köşesi düzleşir).
- **Oturum sona erdi:** Dio interceptor 401 (ya da sunucunun oturum düşme yanıtı; bugün `validateStatus < 500`, `followRedirects: false`) → root'ta `SessionExpiredSheet`; bekleyen gönderimler bekletilir; girişten sonra aynı ekrana dönülür.
- **Durum çubuğu:** RootBand/HomeBand/kamera üstünde açık içerik; kanvas zeminli ekranlarda temaya göre.
- **SharedPreferences anahtarları:** `onboarding_seen`, `onboarding_role`, `onboarding_grade`, `onboarding_field` (kayıtta silinir), `omd_tutorial_hidden`, `omd_corner_hint_hidden`, `notif_primer_shown`, `card_learn_confirm_skip` [Karar ad], `lessons_exam_type` (TYT/AYT son seçimi, T5.8/T6.6), `lesson_detail_cat_<lessonId>` [Karar], `edebiyat_section`, `program_view` (Gün/Hafta), `exam_favorites` (deneme id seti, D-25), `theme_mode` [Karar: sistem varsayılan].

### 3.6 Route haritası (tam)

Kısaltmalar: **N** navigator (R = root, Ö0–Ö3 öğrenci dalları, K0–K3 koç dalları); **AÇ** alt çubuk; **Bar** üst bar.

**Kök, kabuk dışı**

| Path | Ekran (sınıf) | Pano | N | AÇ | Bar | Not |
|---|---|---|---|---|---|---|
| `/splash` | `SplashScreen` | 2.1-1 | R | — | yok | Redirect kararlarını verir |
| `/onboarding/intro` | `OnboardingPager` | 2.1-2/3/4 | R | — | yok ("Geç") | 3 sayfa, bir kez |
| `/onboarding/role` | `RolePickerScreen` | 2.2-1 | R | — | Detail (geri) | |
| `/onboarding/grade` | `GradeFieldScreen` | 2.2-2/3 | R | — | Detail | Yalnız öğrenci |
| `/onboarding/camera` | `CameraPrimerScreen` | 2.2-4 | R | — | yok | |
| `/welcome` | `WelcomeScreen` | 2.2-5 | R | — | yok | Çıkış/silme sonrası da |
| `/auth/login` | `LoginScreen` (alias `/login`) | 2.3 | R | — | Detail | Sosyal varyant bayrakla |
| `/auth/forgot-password` | `ForgotPasswordFlow` (iç adımlar email → code → new → done) | 2.4 | R | — | Detail | Uç yoksa gizli (D-18) |
| `/auth/register?role=student\|coach` | `SignupScreen` | 2.5–2.6 | R | — | Detail (+ yapışkan rol segmenti) | |
| `/blocking/force-update` | `ForceUpdateScreen` | 2.7-1 | R | — | yok | Geri kapalı |
| `/blocking/maintenance` | `MaintenanceScreen` | 2.7-3 | R | — | yok | Öne gelince yeniden dener |
| `/blocking/unknown-role` | `UnknownRoleScreen` | 2.7-4 | R | — | yok | |
| `/scan?studentId=` | `OmrCaptureScreen` | 4.3 (+4.1, 4.2 sheet) | R | — | Kamera | Koçta `studentId` zorunlu |
| `/scan/corners` | `OmrCornerScreen` | 4.4 | R | — | Kamera | |
| `/scan/upload` | `OmrUploadScreen` | 4.5–4.6 | R | — | yok | |
| `/scan/review` | `FormCheckScreen` | 4.7–4.8 | R | — | Detail (X) | PopScope → çıkış onayı |
| `/scan/exam-not-found` | `ExamRequestScreen` | 4.9 | R | — | Detail (X) | |
| `/scan/error?type=formNotFound\|offline\|cameraUnavailable` | `OmrErrorView` | 4.10 | R | — | X | |
| `/scan/result/:examId` | `ResultMomentScreen` | 5.1 (+5.2 sheet) | R | — | X | Ayrılırken `go` |
| `/home/program/new` | `NewProgramFlow` (adımlar days → grid → name) | 3.5 | R | — | Detail (X / geri + "Adım N/3") | Tam ekran |
| `/account/delete/progress` | `DeleteAccountProgressScreen` | 9.4-4 | R | — | yok | Geri kapalı |
| `/account/delete/done` | `DeleteAccountDoneScreen` | 9.4-5 | R | — | yok | Tamam → `/welcome` |
| `/dev/gallery` | `ComponentGallery` | — | R | — | Detail | Yalnız debug |

**Öğrenci kabuğu (`StatefulShellRoute`, 4 dal)**

| Path | Ekran | Pano | N | AÇ | Bar | Not |
|---|---|---|---|---|---|---|
| `/home` | `HomeScreen` | 3.1–3.3 | Ö0 | ✓ | HomeBand | RefreshIndicator |
| `/home/program` | `ProgramListScreen` | 3.4 k1–2, 3.7 | Ö0 | ✓ (Anasayfa seçili) | Detail + BarAction "Yeni Program" | |
| `/home/program/:programId?view=day\|week&date=` | `ProgramDetailScreen` (+ `editMode`) | 3.4 k3–4, 3.6, 3.8 | Ö0 | ✓ | Detail + "Düzenle"/"Bitti" | |
| `/analytics?tab=genel\|denemelerim` | `AnalyticsScreen` | 6.1–6.4 | Ö1 | ✓ | RootBand (sekmeli) | |
| `/analytics/exam/:examId?tab=genel\|sorular\|konular\|kartlar` | `ExamDetailScreen` | 5.3–5.10 | Ö1 | ✓ | Detail + yapışkan TabBar | |
| `/analytics/exam/:examId/question?lesson=&q=` | `QuestionDetailScreen` | 5.7 | Ö1 | ✓ | Detail | |
| `/lessons` | `LessonsScreen` | 7.1 | Ö2 | ✓ | RootBand (segmentli TYT/AYT) | |
| `/lessons/deck?lessonId=&examId=&group=eksik\|bildik\|favori` | `CardDeckScreen` | 8.1–8.2 | Ö2 | ✓ | Detail | `/lessons/:lessonId`'den önce tanımlanır |
| `/lessons/:lessonId?cat=tyt\|ayt\|sos2\|all&eksik=1&section=topics\|authors` | `LessonDetailScreen` (Edebiyat: segmentli) | 7.2, 7.4 | Ö2 | ✓ | Detail | |
| `/lessons/:lessonId/topics/:topicId?focus=firstMissing&cat=` | `TopicDetailScreen` | 7.3, 7.6 | Ö2 | ✓ | Detail | |
| `/account` | `AccountScreen` | 9.1 | Ö3 | ✓ | RootBand + ProfileSummary | |
| `/account/profile` | `ProfileScreen` (view/edit) | 9.2, 9.4-1 | Ö3 | ✓ | Detail + "Düzenle"/"Kaydet" | |
| `/account/password` | `PasswordScreen` | 9.3 | Ö3 | ✓ | Detail | |
| `/account/delete` | `DeleteAccountInfoScreen` | 9.4-2/3 | Ö3 | ✓ | Detail | |
| `/account/coaching` | `CoachingScreen` | 9.5 | Ö3 | ✓ | Detail | Yalnız öğrenci |
| `/account/notifications` | `NotificationsScreen` | 9.6 | Ö3 | ✓ | Detail | |
| `/account/agreements` | `AgreementsScreen` | 9.7-1 | Ö3 | ✓ | Detail | |
| `/account/agreements/:docId` | `AgreementReader` | 9.7-2 | Ö3 | ✓ | Detail (kısa) | |

**Koç kabuğu (`StatefulShellRoute`, 4 dal)**

| Path | Ekran | Pano | N | AÇ | Bar | Not |
|---|---|---|---|---|---|---|
| `/coach/home` | `CoachHomeScreen` | 10.1 | K0 | ✓ | HomeBand (coach) | |
| `/coach/students` | `StudentsScreen` | 10.2 (+10.3 sheet) | K1 | ✓ | RootBand + Plus | |
| `/coach/students/:studentId?tab=analysis\|exams\|program` | `StudentProfileScreen` (`StudentScope(coachView)`) | 10.4 k1–3 | K1 | ✓ | Detail + "Görüşme Planla" + ContextStrip + TabBar | |
| `/coach/students/:studentId/exams/:examId?tab=` | `ExamDetailScreen` (koç bağlamı) | 10.4 k4, 5.3–5.6 | K1 | ✓ | Detail + ContextStrip + TabBar | Favori yok |
| `/coach/students/:studentId/exams/:examId/question?lesson=&q=` | `QuestionDetailScreen` (koç) | 5.7 | K1 | ✓ | Detail + ContextStrip | "Kartları Çalış" yok [Karar] |
| `/coach/meetings` | `MeetingsScreen` | 10.5 k1, k4 | K2 | ✓ | RootBand + Plus | |
| `/coach/meetings/:meetingId` | `MeetingDetailScreen` | 10.5 k3, 10.6 | K2 | ✓ | Detail + "Düzenle" | |
| `/coach/account` | `AccountScreen(role: coach)` | 9.1-4 | K3 | ✓ | RootBand + ProfileSummary | |
| `/coach/account/profile` · `/password` · `/notifications` · `/agreements` · `/agreements/:docId` · `/delete` | Hesap alt ekranları (koç) | 9.2–9.4, 9.6–9.7 | K3 | ✓ | Detail | Profilde Sınıf/Alan yok |

**Geçiş kuralları**

| Nereden | Eylem | Hedef |
|---|---|---|
| Sonuç anı 5.1 | "Detaylı Analiz" | `go('/analytics/exam/:id?tab=genel')` (kamera yığını kapanır, T3.1); ilk başarılı okumada önce 5.2 |
| Sonuç anı 5.1 | Kart satırı | `go('/analytics/exam/:id?tab=kartlar')` |
| Sonuç anı 5.1 | "Anasayfa" / Kapat | `go('/home')` [Karar: Kapat = Anasayfa] |
| Sonuç anı (koç) | "Detaylı Analiz" | `go('/coach/students/:sid/exams/:id')` |
| Anasayfa | "Analizi Gör" | `go('/analytics/exam/:lastExamId')` [Karar] |
| Anasayfa | Bugün satırı | `go('/lessons/:lessonId/topics/:topicId?focus=firstMissing')` |
| Anasayfa | Ders karosu | `go('/lessons/:lessonId?cat=<son seçim>')`; Web'de karosu → Web'de sheet |
| Anasayfa | "Programım" / "Haftalık Programını Kur" | `push('/home/program')` / `push('/home/program/new')` |
| Anasayfa | "İlk Denemeni Okut" | Okut akışı |
| Konular 5.5 | "Bu Konuyu Çalış" / satır | `go('/lessons/:lessonId/topics/:topicId?focus=firstMissing')` |
| Kartlar 5.6, Soru Detay 5.7 | "Kartları Çalış" | `go('/lessons/deck?examId=:id&group=eksik')` |
| Ders Detayı 7.2 | "Kartlarım" | `push('/lessons/deck?lessonId=:id&group=eksik')` |
| Denemelerim satırı | dokunma | `push('/analytics/exam/:id')` |
| Okut (her sekme) | dokunma | izin yoksa 4.1 sheet; bakımdaysa 4.10-2 sheet; değilse `push('/scan')` (koçta önce öğrenci seç) |
| Çekim | deklanşör | `/scan/corners` → "Devam" `/scan/upload` → başarı `/scan/review` → onay → `mexamFound` ise `/scan/result/:id`, değilse `/scan/exam-not-found` |
| Çıkış / Hesap silindi | — | `go('/welcome')`, oturum temizlenir |
| Koç Anasayfa | öğrenci karosu / dikkat satırı | `go('/coach/students/:id')` |
| Koç Anasayfa | görüşme satırı | `go('/coach/meetings/:id')` |
| Görüşme detayı | "Öğrencinin verileri" | `go('/coach/students/:sid')` |


---

## 4. Ekranlar

**Ortak:** her ekranın dört durumu (iskelet → 15 sn → hata, boş, hata + Tekrar Dene, çevrimdışı) §2 C76–C78 kalıbıyla; bölümler kendi durumunu taşır. Veri yoksa alan hiç çizilmez (boş kutu, "0" ya da tire yok). Koyu panosu olmayan ekranlar token'larla türetilir. Metin dili "sen"; metinler birebir (D-30 yalnız Türkçe; **[Karar]** metinler `lib/core/strings/smap_strings_tr.dart` sabitlerinde, aşağıdaki anahtar adlarıyla). Mevcut kod dosyaları "Kod:" satırında.

### 4.A Açılış, tanıtım, giriş, kayıt (SMAP-02, Tur 7)

Yatay kenar boşluğu 24; alt düğmeler alttan 42; içerik top 110 (DetailBar'lı ekranlar).

#### 2.1-1 Açılış · `/splash` · `SplashScreen`
- **Düzen:** tam ekran `#0F294A` (iki temada); ortada `SmapLockup.vertical` (işaret 78,6 × 104, alt kanca `#FF6600`, üst kanca `#FFFFFF`; "SMAP" 40/1·800·−0,02em `#FFFFFF`; aralık 20). İşaret ilk karede; solma yok.
- **Durum:** 1 sn'den uzun sürerse işaretin altında spinner ([Karar] 24, lacivert üstü beyaz, 32 altta). Hazır olunca 250 ms geçiş.
- **Veri:** min sürüm ([Karar] uzaktan config; uç yok), oturum (`/ajax/checkUser`), bakım bayrağı; redirect §3.1. Native splash (`flutter_native_splash`) aynı görüntü.

#### 2.1-2/3/4 Tanıtım · `/onboarding/intro` · `OnboardingPager` (3 sayfa `PageView`)
- **Sayfa:** `SmapOnboardingPage` (§C60). "Geç" 1. ve 2. sayfada (top 54, right 8) → `/onboarding/role` [Karar]. Görsel alanı top 112, 380; başlık top 528 display; gövde `bodyReading` `#556173`; alt blok PageDots + `primary` ("Devam Et"; 3. sayfada "Başla" → `/onboarding/role`).
- **Görseller (widget olarak kurulur):**
  1. 250 × 330 telefon maketi, radius 28, gölge `0 12 32 rgba(15,41,74,.16)`; içinde form, turuncu kesikli dörtgen ve köşe tutamaçları; altta 56'lık turuncu kamera düğmesi (radius 16, Camera 28).
  2. 300 genişlikte ExamCard özeti (dolgu 16, gölge `0 12 32 rgba(15,41,74,.12)`): "AYT · Türkiye Geneli Deneme 6", "67,5" metric-lg + "net" + "+8,25" (ArrowUp), DybSmall 86/74/0, 268 × 120 NetChart (eksen 40, 55, 70; tarih "8 May." – "5 Eki."; ad "AYT net grafiği: 8 Mayıs 48,5 netten 5 Ekim 67,5 nete").
  3. 296 genişlikte konu kartı (satırlar dolgu 12/14, TextAa glif 32): "Fiilde Çatı" (3 eksik), "Noktalama İşaretleri" (3 eksik), "Cümlenin Öğeleri" (2 eksik); üstünde 236 genişlikte bilgi kartı (dolgu 14, gölge `0 16 32 rgba(15,41,74,.18)`): "Tarih · bilgi kartı" (Bank 24), 17/24·700 "Edirne-Segedin Antlaşması (1444)", 13/20 "Haçlılarla Osmanlı Devleti'nin imzaladığı ilk antlaşma.", 40 yükseklikte primary "Öğrendim" (15 pt, radius 10).
- **Metinler:** `onbSkip`="Geç"; `onbIntro1Title`="Optik formunu kamerayla okut"; `onbIntro1Body`="Deneme bitince formunun fotoğrafını çek; cevapların sayılır, netin hesaplanır."; `onbIntro2Title`="Netini ve gelişimini gör"; `onbIntro2Body`="Her denemenin neti, doğru-yanlış dağılımı ve önceki denemene göre farkı tek ekranda."; `onbIntro3Title`="Eksiklerini konu konu kapat"; `onbIntro3Body`="Kaçırdığın konular eksik listene girer; konu anlatımı ve bilgi kartlarıyla tamamlarsın."; `commonContinue`="Devam Et"; `onbStart`="Başla"; `onbPageA11y`="3 ekrandan {n}.".
- **Hareket:** sayfa 350 standard; görsel parçaları 250 ms gecikmeli. **Veri:** statik; `onboarding_seen`. **Koyu:** çizilmemiş (token).

#### 2.2-1 Rol · `/onboarding/role` · `RolePickerScreen`
- **Düzen:** geri (top 54, left 4); display "SMAP'i nasıl kullanacaksın?" (top 110) + `bodyLarge` `#556173` "Ekranların buna göre hazırlanır." (8 altta); radiogroup "Rol" (top 240, aralık 12): iki `SmapRoleOption`; `primary` "Devam Et" alttan 42.
- **Metinler:** `roleTitle`, `roleSubtitle` (yukarıda); `roleStudent`="Öğrenciyim", `roleStudentDesc`="Denemelerini okut, eksiklerini kapat."; `roleCoach`="Öğrenci Koçuyum", `roleCoachDesc`="Öğrencilerinin gelişimini izle, görüşmelerini planla.".
- **Davranış:** [Karar] varsayılan seçim Öğrenciyim (panoda seçili çizili). Öğrenci → 2.2-2; Koç → 2.2-4. Seçim yerel (`onboarding_role`), kayıt formuna taşınır. Girişte rol sorulmaz (T7.2).

#### 2.2-2/3 Sınıf ve alan · `/onboarding/grade` · `GradeFieldScreen`
- **Düzen:** geri; display "Kaçıncı sınıftasın?" (top 110); sınıf radiogroup (top 170, aralık 8): kare çipler 56 × 48 "9", "10", "11", "12", "Mezun" (88); 20/28 "Alanın" (top 258); alan radiogroup (12 altta, aralık 8): `SmapChip.lg` "Sayısal", "Eşit Ağırlık", "Sözel", "Dil"; `primary` "Devam Et".
- **9.–10. sınıf (2.2-3):** alan çipleri yerine `SmapNoticeBox.info`: `gradeNoFieldInfo`="9. ve 10. sınıfta alan seçilmez; 11. sınıfa geçince Hesap'tan eklersin." Devam Et hemen açık.
- **Kural [Karar]:** 11/12/Mezun'da alan seçilmeden "Devam Et" basılırsa alan grubunun altında hata "Alanını seç." + odak; buton dolu kalır (§C01 doğrulama kuralı). Koç bu adımı görmez.
- **Metinler:** `gradeTitle`="Kaçıncı sınıftasın?", `fieldTitle`="Alanın". **Veri:** yerel (`grade`, `field`) → kayıt payload'u.

#### 2.2-4 Kamera ön açıklaması · `/onboarding/camera` · `CameraPrimerScreen`
- **Düzen:** top 150 ortalı: 96 daire `#E2EAF4` + Camera 48 `#36537C`; display başlık (28 altta); `bodyReading` `#556173` (12 altta); altta `primary` "Kameraya İzin Ver" + tam genişlik `text` "Sonra". Geri yok.
- **Metinler:** `camPrimerTitle`="Formunu okutmak için kamera gerekli"; `camPrimerBody`="SMAP kamerayı yalnız optik formunu çekerken kullanır. Bir sonraki adımda telefonun izin isteyecek."; `camPrimerAllow`="Kameraya İzin Ver"; `camPrimerLater`="Sonra".
- **Davranış:** "İzin Ver" sistem iletişim kutusu (`permission_handler`); "Sonra" izinsiz geçer (ilk okutmada 4.1 yeniden sorar). → 2.2-5.

#### 2.2-5 Hoş geldin · `/welcome` · `WelcomeScreen`
- **Düzen:** top 150: kil Harita L 160; display başlık (28 altta); `bodyReading` `#556173`; `primary` "Kayıt Ol" + `secondary` "Giriş Yap" (aralık 12, alttan 42). Geri yok.
- **Metinler:** `welcomeTitle`="SMAP'e hoş geldin"; `welcomeBody`="Hesabın varsa giriş yap; yoksa birkaç adımda kaydol. Seçtiklerin kayıt formuna gelir."; `authRegister`="Kayıt Ol"; `authLogin`="Giriş Yap".
- **Navigasyon:** Kayıt Ol → `/auth/register?role=<seçim>`; Giriş Yap → `/auth/login`. Çıkış ve hesap silme sonrası buraya dönülür.

#### 2.3 Giriş · `/auth/login` · `LoginScreen`
- **Düzen:** geri; `SmapLockup.horizontal` (top 110, left 24); form top 174, aralık 20: 24/32 "Giriş yap"; `SmapTextField` "Kullanıcı adı"; `SmapTextField.password` "Şifre"; sağa yaslı `text` "Şifremi Unuttum" (üst −8); `primary` "Giriş Yap". Alt satır (alttan 34, aralık 2): 15/24 `#556173` "Hesabın yok mu?" + `text` "Kayıt Ol".
- **Kareler:** (1) boş, etiketli, odak kullanıcı adında; (2) gönderiliyor: düğmede 20 beyaz spinner + "Giriş yapılıyor", alanlar kilitli; 15 sn yanıt yoksa bağlantı hatası ([Karar] metin `errNetwork`="Bağlanamadık. Bağlantını kontrol edip tekrar dene." ErrorBox'ta); (3) hatalı bilgi: `SmapNoticeBox.error` (`role=alert`) "Şifremi Unuttum" ile düğme arasında; hangi alanın yanlış olduğu söylenmez; şifre temizlenir, odak şifrede, `error` haptiği; (4) sosyal varyant (D-17, bayrak): başlığın altında iki eşit `secondary` (aralık 12, 20 × 20 logo yer tutucu radius 6) "Apple ile Devam Et" / "Google ile Devam Et", altında ayraç + 13/20·600 "ya da kullanıcı adınla".
- **Metinler:** `loginTitle`="Giriş yap"; `fieldUsername`="Kullanıcı adı"; `fieldPassword`="Şifre"; `loginForgot`="Şifremi Unuttum"; `loginSubmit`="Giriş Yap"; `loginSubmitting`="Giriş yapılıyor"; `loginNoAccount`="Hesabın yok mu?"; `authRegister`="Kayıt Ol"; `a11yShowPassword`="Şifreyi göster"; `a11yHidePassword`="Şifreyi gizle"; `loginErrorInvalid`="Kullanıcı adı ya da şifre hatalı. Tekrar dene ya da şifreni sıfırla."; `loginApple`="Apple ile Devam Et"; `loginGoogle`="Google ile Devam Et"; `loginOrUsername`="ya da kullanıcı adınla".
- **Davranış:** klavye kullanıcı adında "ileri", şifrede "git" (gönderir). Kullanıcı adı kırpılır/küçültülür; şifre olduğu gibi. "Beni Hatırla" yok (oturum açık kalır, PersistCookieJar). Başarıda rol: öğrenci → `/home`, koç → `/coach/home`, bilinmeyen → `/blocking/unknown-role`. Test bilgileri koddan silinir. Şifremi Unuttum → `/auth/forgot-password` (uç yoksa bağlantı gizli, D-18).
- **Veri:** `/student/login` (mevcut). Sosyal: `google_sign_in` var ama çağrılmıyor; Apple paketi yok; sunucu ucu belirsiz. **Koyu:** çizilmemiş.

#### 2.4 Şifremi Unuttum · `/auth/forgot-password` · `ForgotPasswordFlow`
- **Ortak:** geri (adımda bir önceki adıma); içerik top 110, yatay 24, aralık 20; başlık 24/32, açıklama 15/24 `#556173` (6 altta). Her adımda tek iş ve tek birincil. Adımlar arası 350 ms yatay geçiş.
- **1 E-posta:** "Şifreni sıfırla" / "Hesabındaki e-posta adresini yaz; 6 haneli bir kod gönderelim."; "E-posta" (odaklı, e-posta klavyesi); `primary` "Kod Gönder". Kayıtsız e-postaya da aynı yanıt.
- **2 Kod:** "Kodu gir" / "Kodu {email} adresine gönderdik. Gelen kutunda yoksa istenmeyen klasörüne bak."; `SmapCodeInput` ("Doğrulama kodu"); `text` (pasif, sayaçlı) "Kodu Tekrar Gönder (0:24)"; `text` "E-postayı Değiştir". Otomatik doldurma, yapıştırma, 6. hanede kendiliğinden doğrulama; tekrar gönderme 30 sn; kod 10 dk.
- **3 Yeni şifre:** "Yeni şifreni belirle"; "Yeni şifre" (yardım "En az 8 karakter.") ve "Yeni şifre (tekrar)"; `primary` "Şifreyi Güncelle"; eşleşmezse "Şifreler aynı değil.".
- **4 Bitti** (`role=status`): `SmapStatusView.blocking` top 200: 96 `#E4F4EA` + CheckCircle 48 `#0B6E3E`; display "Şifren güncellendi"; "Yeni şifrenle giriş yapabilirsin."; `primary` "Giriş Yap" (kullanıcı adını hazır getirir); `success` haptiği.
- **Metinler:** `fpTitle`="Şifreni sıfırla"; `fpBody`; `fieldEmail`="E-posta"; `fpSendCode`="Kod Gönder"; `fpCodeTitle`="Kodu gir"; `fpCodeBody`; `fpCodeLabel`="Doğrulama kodu"; `fpResendIn`="Kodu Tekrar Gönder ({m}:{ss})"; `fpResend`="Kodu Tekrar Gönder"; `fpChangeEmail`="E-postayı Değiştir"; `fpNewTitle`="Yeni şifreni belirle"; `fieldNewPassword`="Yeni şifre"; `fieldNewPasswordRepeat`="Yeni şifre (tekrar)"; `pwRule`="En az 8 karakter."; `fpUpdate`="Şifreyi Güncelle"; `fpDoneTitle`="Şifren güncellendi"; `fpDoneBody`="Yeni şifrenle giriş yapabilirsin."; hatalar `fpErrCode`="Kod hatalı ya da süresi dolmuş. Yeni kod iste.", `fpErrTooMany`="Çok fazla deneme yaptın. 10 dakika sonra tekrar dene.", `errEmailFormat`="E-posta adresi eksik görünüyor. Örn: ad@alan.com", `pwMismatch`="Şifreler aynı değil."; toast `errSendFailed`="Gönderilemedi. Bağlantını kontrol edip tekrar dene.".
- **Hareket:** kod hatası kutular 150 ms sallanır + `error`; bitti `success`.
- **Veri:** `email`, `code`, `newPassword`. **Backend:** uç yok (kod gönder, doğrula, güncelle) → feature flag `forgotPasswordEnabled`; kapalıyken giriş ekranındaki bağlantı gizli.

#### 2.5–2.6 Kayıt · `/auth/register?role=student|coach` · `SignupScreen`
- **Üst (kare 1):** geri; içerik top 110, yatay 24, aralık 20: 24/32 "Kayıt ol"; rol `SmapSegmented` "Öğrenci" | "Öğrenci Koçu"; `SmapAvatarPicker.inline` (başlık satırı "Avatarın" 14/20·600 + "7 avatar" 13/20 `#556173`; 7 × 46, space-between, 10 altta; adlar "Avatar N" / "Avatar 1, seçili"); "Ad Soyad"; "Kullanıcı adı" (canlı kontrol; olumluysa CheckCircle 22 + "Bu kullanıcı adı boşta."); "E-posta".
- **Kaydırılmış:** bar 102 `#F2F4F7` + 17/24 "Kayıt ol"; rol segmenti yapışık (top 102, dolgu 0/24/12, alt çizgi `0 1 0 #DCE2E9`); içerik top 174: "Şifre" (yardım "En az 8 karakter.") ve "Şifre (tekrar)"; öğrenci: `SmapSelectField` "Sınıf" ("12. Sınıf") ve "Alan" ("Eşit Ağırlık"); koç (kare 3): Sınıf/Alan yerine `SmapNoticeBox.info` "Kaydın tamamlanınca koçluk kodun oluşur. Öğrencilerin bu kodla sana bağlanır; kodun Hesap › Koçluk'ta durur."; onay `SmapCheckbox` "[Kullanım Koşulları]'nı ve [KVKK Aydınlatma Metni]'ni okudum, kabul ediyorum." (bağlantılar metni full sheet'te açar); `primary` "Kayıt Ol"; altında 15/24 `#556173` "Hesabın var mı?" + `text` "Giriş Yap" (üst −8).
- **Alan kuralları:** önceden dolu alan yok; zorunlu yıldızsız, isteğe bağlı alan yok; rol ve seçimler 2.2'den gelir, değiştirilebilir. Koç örneği "Mehmet Özkan".
- **Durumlar (2.6):**
  1. Kullanıcı adı alınmış: alan hata + "Bu kullanıcı adı alınmış."; altında 13/20 `#556173` "Boşta olan:" + `SmapChip.md` öneri "alparslan.k" (dokununca alan dolar, kontrol yeniden çalışır, `selectionClick`). E-posta hatası "E-posta adresi eksik görünüyor. Örn: ad@alan.com".
  2. Gönderimde: "Şifre (tekrar)" hata "Şifreler aynı değil."; onay kutusu hata kenarı + "Kaydolmak için metinleri onaylaman gerekiyor."; odak ilk hatalı alana (350 ms kaydırma), `error` bir kez.
  3. Metinler yüklenemedi: onay satırı yerine `SmapNoticeBox.error` "Sözleşme metinleri yüklenemedi. Kaydolmak için metinleri görebilmen gerekiyor." + `text` "Tekrar Dene"; "Kayıt Ol" pasif + altında ortalı yardım "Metinler yüklenince kayıt açılır."; yüklenince 250 ms'de onay satırına döner.
  4. 10. sınıf (örnek Mert Yıldız): "Sınıf"="10. Sınıf"; "Alan" pasif "Seçilmez" + yardım "9. ve 10. sınıfta alan seçilmez.".
- **Metinler:** `registerTitle`="Kayıt ol"; `roleSegStudent`="Öğrenci"; `roleSegCoach`="Öğrenci Koçu"; `avatarLabel`="Avatarın"; `avatarCount`="{n} avatar"; `fieldFullName`="Ad Soyad"; `usernameFree`="Bu kullanıcı adı boşta."; `usernameTaken`="Bu kullanıcı adı alınmış."; `usernameSuggest`="Boşta olan:"; `fieldPasswordRepeat`="Şifre (tekrar)"; `fieldGrade`="Sınıf"; `gradeValue`="{n}. Sınıf"; `fieldField`="Alan"; `fieldNotSelectable`="Seçilmez"; `fieldNotSelectableReason`="9. ve 10. sınıfta alan seçilmez."; `coachCodeInfo`; `consentText`="{terms}'nı ve {kvkk}'ni okudum, kabul ediyorum." (`terms`="Kullanım Koşulları", `kvkk`="KVKK Aydınlatma Metni"); `consentRequired`; `legalLoadFailed`; `legalRegisterLocked`; `commonRetry`="Tekrar Dene"; `hasAccount`="Hesabın var mı?"; [Karar] kayıt hatası toast `errRegisterFailed`="Kaydın tamamlanamadı. Bağlantını kontrol edip tekrar dene.".
- **Davranış:** kullanıcı adı kontrolü 400 ms, iptal edilebilir, spinner alanın sağında; çevrimdışıyken "Bağlanınca kontrol edilecek.". Kayıt sonrası öğrenci → `/home` (yeni kullanıcı hâli 3.1-3), koç → `/coach/home`. Bildirim izni burada sorulmaz (D-23). Onay sürüm numarasıyla kaydedilir.
- **Veri:** `role`, `avatarId` (1–7), `fullName`, `username`, `email`, `password`, `grade` (9/10/11/12/Mezun), `field` (Sayısal/EA/Sözel/Dil/null), `consent` + sözleşme sürümleri → `/student/register` (koç kaydı aynı uç mu belirtilmemiş); `/ajax/checkUsername`; `/ajax/getLegalDocuments`.

#### 2.7 Genel ekranlar (`SmapStatusView.blocking`)
Ortak: top 190 ortalı; 96 ikon dairesi; display başlık (28 altta); tek cümle `bodyReading` `#556173` (12 altta); en çok iki düğme (alttan 42). İllüstrasyon, iç kod yok.

| Kare | Route | Görsel | Metin | Eylem / davranış |
|---|---|---|---|---|
| 1 Zorunlu güncelleme | `/blocking/force-update` | uygulama ikonu 96, radius 21,5 | `forceUpdateTitle`="Yeni sürüm gerekli"; `forceUpdateBody`="Bu sürüm artık desteklenmiyor. Devam etmek için SMAP'i güncelle; verilerin hesabında duruyor." | `primary` `update`="Güncelle" → mağaza (URL belirtilmemiş); kapatılamaz, geri çalışmaz |
| 2 Oturum sona erdi | global sheet (`role=alertdialog`) | 40 daire `#E2EAF4` + Clock 22 `#36537C`; içerik dolgu 20/24/0, alt bant üst 24 | `sessionExpiredTitle`="Oturumun sona erdi"; `sessionExpiredBody`="Güvenliğin için yeniden giriş yapman gerekiyor. Okuttuğun denemeler hesabında duruyor." | `primary` "Giriş Yap"; perde/sürükleme kapatmaz; 401'de açılır; bekleyen gönderimler sırada; girişten sonra aynı ekrana |
| 3 Bakım | `/blocking/maintenance` | 96 `#E2EAF4` + Wrench 48 `#36537C` | `maintenanceTitle`="SMAP şu an bakımda"; `maintenanceBody`="Kısa süre içinde geri döneceğiz. Verilerin güvende; bakım bitince kaldığın yerden devam edersin." | `quiet` "Tekrar Dene"; süre vaadi yok; öne gelince kendiliğinden dener |
| 4 Bilinmeyen rol | `/blocking/unknown-role` | 96 `#FCEAEA` + WarningCircle 48 `#C42D35` | `unknownRoleTitle`="Hesabın açılamadı"; `unknownRoleBody`="Hesap türün tanınmadı. Çıkış yapıp yeniden giriş yapmayı dene; sorun sürerse bize yaz." | `primary` `reLogin`="Yeniden Giriş Yap" + `text` `contactSupport`="Destek'e Yaz" (e-posta taslağı; adres belirtilmemiş) |

Koyu: çizilmemiş.

### 4.B Anasayfa ve Programım (SMAP-03, Tur 6)

Yatay kenar 16.

#### 3.1–3.3 Anasayfa · `/home` · `HomeScreen`
- **Kod:** `HomeFlowScreen` (yeniden yazılır). Tek soruyu cevaplar: "Bugün ne yapmalıyım?" En çok 4 bölüm.
- **Yapı:** `CustomScrollView`: `SmapHomeBand.student` (SliverPersistentHeader) + gövde (dolgu 24/16/140, bölümler arası 28, bölüm içi 12): Bugün, Son denemen, Derslerin. `RefreshIndicator`.
- **(b) Bugün:** `SmapSectionHeader` "Bugün" + meta "Cumartesi, 10 Ekim · Ekim 2. Hafta" ({gün}, {d} {ay} · {programAdı}) + `text` "Programım" (bölümün tek bağlantısı). Kart (radius 16) içinde `SmapProgramItemRow`'lar: 10:00 Türkçe "Fiilde Çatı"; 14:00 Tarih "Kurtuluş Savaşı Hazırlık Dönemi"; 20:00 Coğrafya "İklim Bilgisi". Tamamlama işareti yok.
- **(c) Son denemen:** `SmapSectionHeader` "Son denemen" + `SmapExamSummaryCard`: "Türkiye Geneli Deneme 6"; "Örnek Yayınları · AYT · 5 Eki. 2026"; "67,5" + "net" + "+8,25" + "önceki AYT'ye göre"; 86 doğru, 74 yanlış, 0 boş; "En çok kaçırdığın konu"; "Kurtuluş Savaşı Hazırlık Dönemi'nde 13 sorudan 9'unu kaçırdın."; "Analizi Gör".
- **(d) Derslerin:** `SmapSectionHeader` "Derslerin" + meta "Eksiği en çok olandan başlar"; `SmapSubjectTile` şeridi: Tarih 60, Coğrafya 44, Türkçe 31, Fizik 14, Biyoloji 11, Kimya 9, Türk Dili ve Edebiyatı 3, Matematik "Web'de", Geometri "Web'de".
- **Kare 2 kaydırılmış:** HomeBand 110 (avatar 32, selam 17/24, sağda "YKS'ye 252 gün").
- **Kare 3 yeni kullanıcı:** Bugün meta yalnız "Cumartesi, 10 Ekim", "Programım" yok; kart (dolgu 16/16/8): 15/24 "Haftalık programın yok. Bir hafta kurduğunda günün konuları burada görünür." + `text` "Haftalık Programını Kur" (sol −12). Son denemen: boş hâl ("Henüz deneme okutmadın." / "Optik formunu okuttuğunda netin, doğru-yanlış dağılımın ve en çok kaçırdığın konu burada görünür." / `primary` Camera 20 "İlk Denemeni Okut"). Derslerin: meta yok; karolarda yalnız glif ve ad (eksik ve "Web'de" etiketi yok [Karar: panodaki gibi]).
- **Durumlar (3.2):** (1) iskelet: bant hemen; Bugün iskeleti 80 × 24 başlık, 170 × 14 alt satır, 3 satır (64): 44 × 18, 36 × 36 (radius 12), 60 × 12, 90/180/110 × 16; Son denemen iskeleti 140 × 24 başlık + kart dolgu 16, aralık 10 (200 × 18, 120 × 14, 130 × 36, 220 × 16, 100% × 48 radius 12). (2) bölüm hatası (Bugün): `SmapErrorState.section` "Bugünün programı yüklenemedi." + "Tekrar Dene" (yalnız o bölüm); diğerleri çalışır; Derslerin hatası "Dersler yüklenemedi.". (3) çevrimdışı: bant altında şerit, bant köşeleri düzleşir, son kaydedilen program ve deneme. (4) %130: hg 26/34, cdn 52/60, cdl 19,5/26, cds/c13/tm 17/26, t20 26/36, tn 21/30, tt/b15 19,5/30, nv 52/62, düğme 20,8/28, küçük D/Y/B 19,5/26 (harf 17); ad ve konu kesilmez.
- **Metinler:** `homeGreeting`="Merhaba, {firstName}"; `homeDaysLeftLabel`="gün kaldı"; `homeExamDate`="YKS · {date}"; `homeDaysLeftShort`="YKS'ye {n} gün"; `a11yCountdown`="YKS'ye {n} gün kaldı. Sınav {date}."; `homeToday`="Bugün"; `homeTodaySub`="{weekday}, {d} {month} · {programName}"; `homeMyProgram`="Programım"; `a11yProgramRow`="{time}, {subject}, {topic}"; `homeLastExam`="Son denemen"; `examMeta`="{publisher} · {type} · {date}"; `netLabel`="net"; `deltaVsPrev`="önceki {type}'ye göre"; `dybCorrect`="doğru", `dybWrong`="yanlış", `dybBlank`="boş"; `homeMostMissed`="En çok kaçırdığın konu"; `homeMostMissedSentence`="{topic}'nde {total} sorudan {wrong}'unu kaçırdın."; `homeSeeAnalysis`="Analizi Gör"; `homeSubjects`="Derslerin"; `homeSubjectsSub`="Eksiği en çok olandan başlar"; `eksikCount`="{n} eksik"; `onWeb`="Web'de"; `homeNoProgram`; `setupWeeklyProgram`="Haftalık Programını Kur"; `homeNoExamTitle`="Henüz deneme okutmadın."; `homeNoExamBody`; `scanFirstExam`="İlk Denemeni Okut"; `homeTodayError`="Bugünün programı yüklenemedi."; `homeSubjectsError`="Dersler yüklenemedi."; sekmeler `tabHome`="Anasayfa", `tabAnalysis`="Analizlerim", `tabScan`="Okut", `tabLessons`="Derslerim", `tabAccount`="Hesap"; `a11yScan`="Okut: deneme formunu kamerayla okut".
- **Etkileşim:** §3.6 geçişleri. Kaydırınca bant küçülür; çekip yenile, bırakınca `selectionClick`.
- **Veri:** üç bağımsız istek: (1) bugünün programı `/student/getMyWeeklies` (istemcide bugüne süz; programın tarih aralığı alanı); (2) son deneme özeti `/student/getMyMockExams` (perPage 1) + `/student/getMexamSubjectDetail` (en çok kaçırılan konu; fark aynı türün bir öncekine göre — hazır alan yoksa istemcide son iki aynı tür deneme); (3) ders eksikleri `/ajax/getGeneralLessons` + `/student/getLessonsTotalMissing` (azalan; webOnly bayrağı). Ad/avatar oturumdan (`UserModel.name`, `photo`); sayaç cihaz saatinden (YKS tarihi [Karar] uzaktan config, varsayılan 19 Haziran 2027).
- **Koyu (3.3):** bant `#0F294A`; kart `#121D31`, ayraç `#26354D`; delta `#9BB3D3`; D/Y/B koyu; ders karoları koyu; EksikTag `#33270F` / `#F2C46D`; primary `#C5D4E8` / `#091A31`; BottomBar koyu. (Mağaza karesi 1.)

#### 3.4 Programım · `/home/program` · `ProgramListScreen`; `/home/program/:programId` · `ProgramDetailScreen`
- **Liste (kare 1):** geri; 24/32 "Programım" (top 110); `SmapBarAction` (Plus) "Yeni Program"; `SmapSearchField` "Program ara" (top 158); kart (top 222) içinde `SmapProgramRow`: "Ekim 2. Hafta" + "Bu hafta" (turuncu nokta = bugün aralıkta); motto "Her gün biraz daha"; "5–11 Ekim 2026".
- **Arama sonucu yok (kare 2):** "kasım" + temizle; kart (`role=status`) "“kasım” ile eşleşen program yok" / "Program adında ve mottosunda arar; büyük-küçük harf ve I/ı farkı gözetmez." / `text` "Aramayı Temizle". Arama istemcide, ad + motto, tr katlama, 150 ms.
- **Gün (kare 3):** BarAction "Düzenle"; başlık: 24/32 program adı, 15/24 `#556173` motto, 13/20 tarih aralığı; `SmapSegmented` "Gün" | "Hafta" (top 206, radiogroup "Görünüm"); `SmapDayChip` şeridi (top 262, 7 gün): Pzt 5 … **Cmt 10** … Paz 11; 17/24 "Cumartesi, 10 Ekim" + 13/20 "3 çalışma" (top 342); kart içinde `SmapProgramItemRow`'lar (top 380); en sonda `textDanger` (ArrowCounterClockwise 20) "Günü Sıfırla" (onaylı, 3.6).
- **Hafta (kare 4):** başlık bara inmiş (102, `#F2F4F7`, 17/24 program adı + "Düzenle"); segment top 110; `SmapWeekGrid` (top 166, 604 yükseklik, yatay kayar).
- **Metinler:** `programTitle`="Programım"; `newProgram`="Yeni Program"; `programSearchHint`="Program ara"; `thisWeek`="Bu hafta"; `programDateRange`="{start}–{end} {month} {year}"; `searchNoMatch`="“{q}” ile eşleşen program yok"; `programSearchHelp`; `clearSearch`="Aramayı Temizle"; `a11yClearSearch`="Aramayı temizle"; `edit`="Düzenle"; `viewDay`="Gün"; `viewWeek`="Hafta"; gün kısaltmaları "Pzt","Sal","Çar","Per","Cum","Cmt","Paz"; `studyCount`="{n} çalışma"; `resetDay`="Günü Sıfırla".
- **Davranış:** satır Gün görünümünde bugünü açar (bugün aralıkta değilse ilk günü); Gün/Hafta cihazda hatırlanır; bloğa ya da satıra dokunma → 7.3; uzun basınca saat değiştirme yalnız düzenleme modunda. Koçta salt okunur (10.4).
- **Veri:** programlar (id, ad, motto, başlangıç, bitiş, günler → maddeler: tarih, saat, dersId, konuId, konu adı) `/student/getMyWeeklies`.
- **Koyu:** Hafta 3.8: bar `#0A1424`; ızgara `#26354D`; saat etiketi `#A9B5C6`; bloklar koyu ders tonları (Türkçe `#2D211C`/`#E2A98D`, Tarih `#2C2513`/`#E3B651`, Coğrafya `#12293C`/`#7DB9EC`); bugün çizgisi `#FF8533`; segment `#213049`, seçili `#C5D4E8`; kenar gölgesi `#0A1424`→saydam. (Mağaza karesi 7.) Gün ve Liste koyu token'la.

#### 3.5 Yeni Program · `/home/program/new` · `NewProgramFlow` (root, tam ekran)
- **Akış:** Günler → Izgara → Ad ve motto → Programım (toast "Program kaydedildi.", 4 sn, `success`). Geri her adımda seçimleri korur.
- **Ortak üst:** adım 1'de X ("Vazgeç"), 2–3'te CaretLeft "Geri"; sağda 13/20·600 `#556173` "Adım N/3"; başlık 24/32 (top 110) + 15/24 `#556173` (4 altta). **Ortak alt bant:** `#FFFFFF`, üst çizgi `0 -1 0 #DCE2E9`, dolgu 12/24/42; tek `primary`.
- **1 Günler:** "Hangi günler çalışacaksın?" / "Birden çok gün seçebilirsin; geçmiş günler seçilemez."; `SmapCalendar` (top 206; "Ekim 2026"); lejant "Bugün" (top 572); alt bantta 16/24·700 "6 gün seçildi" + 13/20 "12–17 Ekim" (12 altta) + "Devam Et". Çoklu seçim, aralık şart değil, `selectionClick`.
- **2 Izgara:** "Konuları yerleştir" / "Boş bir saate dokun, konu seç. Izgara 06:00–23:00."; seçilen günler `SmapDayChip.large` (top 186; seçili günde "2 konu"); `SmapHourSlot` kartı (top 278). Boş saate dokunma → konu sheet'i; yerleşince 250 enter.
- **3 Konu seç (sheet, `role=dialog` "Konu ekle"):** başlık "{Gün} {d} {Ay} · {saat}" ("Pazartesi 12 Ekim · 16:00") + Kapat; `SmapSegmented` "Çantam" | "Dersler" + 13/20 `#556173` "Çantam: denemelerinden çıkan eksik konuların."; `SmapRadioListTile`'lar (min 56, dolgu 8/24; grup başlığı 13/20·700, dolgu 12/24/0); sağda EksikTag; alt satır "Programda: Pzt 10:00" ya da "Son denemede 13 sorudan 9'u yanlış · Programda: Pzt 14:00"; `primary` "Ekle". Çantam = eksik konular derse göre gruplu; programdaki konu işaretli ama yeniden eklenebilir; Dersler tüm konuları listeler.
- **4 Ad ve motto:** "Programına ad ver"; "Program adı" (zorunlu); "Motto (isteğe bağlı)" (20 altta) + yardım "Program listesinde adın altında görünür."; özet kartı (top 378, dolgu 4/16): "Günler" → "12–17 Ekim 2026 · 6 gün"; "Çalışmalar" → "3 çalışma, hepsi Pazartesi" + 13/20 "Salı–Cumartesi henüz boş; kaydettikten sonra ekleyebilirsin."; `primary` "Programı Kaydet". Hata olursa toast ([Karar] "Program kaydedilemedi. Bağlantını kontrol edip tekrar dene.") ve form korunur.
- **Vazgeç (X):** değişiklik varsa normal ConfirmSheet "Program kaydedilmesin mi?" ([Karar] gövde "Seçtiğin günler ve konular silinecek.", düğmeler "Kaydetmeden Çık" / "Vazgeç").
- **Metinler:** `stepOf`="Adım {n}/3"; `npDaysTitle`; `npDaysBody`; `prevMonth`="Önceki ay"; `nextMonth`="Sonraki ay"; `today`="Bugün"; `daysSelected`="{n} gün seçildi"; `npGridTitle`; `npGridBody`; `topicCount`="{n} konu"; `addTopic`="Konu Ekle"; `a11yEmptySlot`="{time}, boş, konu ekle"; `a11yRemoveTopic`="{topic}, çıkar"; `srcBag`="Çantam"; `srcLessons`="Dersler"; `bagHelp`; `inProgramAt`="Programda: {day} {time}"; `lastExamWrong`="Son denemede {total} sorudan {wrong}'u yanlış"; `add`="Ekle"; `npNameTitle`="Programına ad ver"; `fieldProgramName`="Program adı"; `fieldMotto`="Motto"; `optional`="(isteğe bağlı)"; `mottoHelp`; `summaryDays`="Günler"; `summaryStudies`="Çalışmalar"; `saveProgram`="Programı Kaydet"; `toastProgramSaved`="Program kaydedildi."; `discardConfirm`="Program kaydedilmesin mi?".
- **Veri:** ders/konu ağacı `/student/getAllMainSubjects`; Çantam (eksik konular + sayısı + son deneme bağlamı) kaynağı belirtilmemiş (olası `getLessonsTotalMissing`/`getSubSubjects`); kaydet `{name, motto?, dates[], items[{date, hour, subjectId, topicId}]}` → `/student/addNewProgram`. "Ekim 2. Hafta" = ayın ilk tam haftası (T6.1); geçmiş gün seçilemez (T6.7).

#### 3.6 Program · Düzenle, Sıfırla, İptal · `/home/program/:id` (`editMode`)
- **Düzenleme modu:** geri gizli; sağda BarAction "Bitti" (yalnız modu kapatır; değişiklikler anında kaydedilir, T6.9). `SmapProgramItemRow.edit` satırları; altında `secondary` (Plus) "Konu Ekle" (ızgara sheet'i); en altta `textDanger` "Günü Sıfırla" (ArrowCounterClockwise) ve "Programı İptal Et" (Trash). Saat düğmesi → `SmapTimeWheel` sheet ([Karar] başlık "Çalışma saati", 06:00–23:00, `primary` "Kaydet").
- **Günü sıfırla (danger ConfirmSheet):** "Cumartesi'yi sıfırlayalım mı?" / "10 Ekim'deki 3 çalışma programdan çıkar. Diğer günler değişmez." / "Günü Sıfırla" + "Vazgeç" (odak).
- **Sıfırlandı:** boş gün kartı (dolgu 20/16/8, ortalı): 15/24 `#556173` "Bu gün için çalışma yok." + `text` (Plus) "Konu Ekle"; toast "Cumartesi sıfırlandı." + "Geri Al" (6 sn).
- **Programı iptal (danger):** "Ekim 2. Hafta iptal edilsin mi?" / "Program listeden kalkar ve Anasayfa'daki Bugün bölümü boşalır. Bu işlem geri alınamaz." / "Programı İptal Et" + "Vazgeç" → liste + toast "Program iptal edildi.".
- **Metinler:** `done`="Bitti"; `a11yChangeTime`="Saat {time}, değiştir"; `a11yRemoveFromProgram`="{topic}, programdan çıkar"; `cancelProgram`="Programı İptal Et"; `resetDayTitle`="{weekday}'yi sıfırlayalım mı?" (ek uyumu); `resetDayBody`="{date}'deki {n} çalışma programdan çıkar. Diğer günler değişmez."; `cancel`="Vazgeç"; `emptyDay`="Bu gün için çalışma yok."; `toastDayReset`="{weekday} sıfırlandı."; `undo`="Geri Al"; `cancelProgramTitle`="{programName} iptal edilsin mi?"; `cancelProgramBody`; `toastProgramCancelled`="Program iptal edildi."; `toastTopicRemoved`="Konu çıkarıldı.".
- **Hareket:** çıkar 250 exit + toast + Geri Al; sıfırla satırları 150 aralıkla söner, `selectionClick` (silme kutlanmaz); onay sheet'i 350.
- **Veri:** `/student/updateProgram` (düzenleme başına); program silme ucu yok (belirtilmemiş); Geri Al için geri yükleme isteği ya da gecikmeli kayıt (§6.3 #24).

#### 3.7 Programım · Durumlar
1. **Boş:** geri + "Programım"; arama ve "Yeni Program" yok. Top 220, yan 32 ortalı: kil Ampul 128; 20/28 "Henüz programın yok" (24 altta); 15/24 `#556173` "Haftalık programını kurduğunda günün konuları burada ve Anasayfa'da görünür." (8 altta); `primary` "Haftalık Programını Kur" (24 altta).
2. **İskelet:** başlık ve arama hemen; satır iskeleti 40 × 40 (radius 12), 140 × 18, 170 × 14, 100 × 14.
3. **Hata (ekran):** `SmapErrorState.screen` top 240: "Programların yüklenemedi" / "Bağlantını kontrol edip tekrar dene." / `quiet` "Tekrar Dene" ([Karar] başlık "Programım" bar'da kalır).
4. **Çevrimdışı:** şerit top 102; "Yeni Program" pasif (`aria-disabled`); başlık top 158, arama 206, liste 270; 13/20 `#556173` (top 398) "Program kurmak ve düzenlemek için bağlantı gerekiyor. Kayıtlı programını görebilirsin."; bağlanınca "Bağlandın" 2 sn.
- **Metinler:** `programEmptyTitle`, `programEmptyBody`, `programsLoadError`="Programların yüklenemedi", `checkConnectionRetry`="Bağlantını kontrol edip tekrar dene.", `programOfflineNote`, `connected`="Bağlandın".


### 4.C Kamera ve optik okuma (SMAP-04, Tur 2)

Kamera aşaması (4.2 arka planı, 4.3, 4.4, 4.10-4) her temada koyu (`#000000` zemin, beyaz metin). Gönderim (4.5/4.6) ve sonrası temaya uyar. **Kod:** `views/optic_mark_detection_view/*`, `OmdRepository`, vendor `lib/vendor/flutter_document_scanner`, `camerawesome`/`camera` (yeniden düzenlenir).

**Durum makinesi (`OmrFlowController`):** `idle → permission → tutorial? → capturing → corners → preparing → uploading(progress) → reading → formCheck → submitting → (result | examNotFound) | error(network, timeout, server, maintenance, formNotFound, cameraUnavailable)`. Fotoğraf yolu (geçici dizin) her durumda taşınır, başarıya kadar silinmez. Mesajlar hata türünden üretilir; iç kod yok. Koçta `studentId` her istekte (T9.9).

#### 4.1 Kamera izni (sheet, Anasayfa/aktif sekme üstünde; medium)
- **Öncesi (Okut'a ilk dokunuş, sistem izni sorulmadan):** içerik dolgu 24/24/0 ortalı; işlevli görsel 160 × 170 (form + çerçeve; [Karar] `OmrTutorialIllustration` küçük hâli); 20/28 başlık (20 altta) + 15/24 `#556173` (8 altta); `primary` "Kameraya İzin Ver" + `quiet` "Sonra". Metinler 2.2-4 ile aynı (`camPrimerTitle`, `camPrimerBody`, `camPrimerAllow`, `camPrimerLater`). "Sonra" kapatır, sekmede kalınır; "İzin Ver" sistem kutusunu açar, sheet kapanır.
- **Reddedildi (kamera yerine açılır):** 40 daire `#FCEAEA` + CameraSlash 22 (çizgi 18) `#C42D35`; `camDeniedTitle`="Kamera izni kapalı"; `camDeniedBody`="Formunu okutabilmek için Ayarlar'da SMAP'e kamera izni ver. Sonra buraya dön; kaldığın yerden devam edersin."; `primary` `openSettings`="Ayarları Aç" (`openAppSettings`) + `quiet` "Vazgeç". Dönüşte izin kontrol edilir; verilmişse kamera 250 ms opaklıkla açılır.
- Açılış 350 enter, kapanış 250 exit; haptik yok.

#### 4.2 Öğretici (full sheet, kamera üstünde)
- **Arka plan:** kamera karesi + üst bar (Kapat `cameraTranslucent` X 20; ortada "Optik Form"; "?" Question 22 "Nasıl çekilir?"). Perde koyu `rgba(2,6,14,.64)`.
- **Sheet:** 20/28 "Formu böyle çek" (kapat düğmesi yok); çizim kutusu `#F2F4F7`, radius 16, dolgu 12, 330 × 250 (cevap alanı turuncu kesikli çerçeve dash 10 7 `#E05500`/`#FF6600`; ders adları şeridi kırmızı taralı `#C42D35`; numaralı rozetler) — `OmrTutorialIllustration` (CustomPainter); adım listesi (12 altta; satır dolgu 8/0, aralık 12; 28 daire `#E2EAF4`, rakam `#0F294A` 15/28·700; metin 16/24); `SmapCheckbox` "Bir daha gösterme" + `primary` "Anladım".
- **Metinler:** `tutTitle`="Formu böyle çek"; `tutStep1`="Cevap alanını çerçeveye al."; `tutStep2`="Ders adlarının yazdığı yatay şeridi dışarıda bırak."; `tutStep3`="Turuncu noktaları cevap alanının dört köşesine getir."; `dontShowAgain`="Bir daha gösterme"; `gotIt`="Anladım"; `scanTopTitle`="Optik Form"; `a11yHowToShoot`="Nasıl çekilir?"; `close`="Kapat".
- **Davranış:** ilk kamera açılışında bir kez (kamera hazır olunca 350 ms); "?" ile her zaman (o zaman "Bir daha gösterme" yok). "Anladım" 250 ms'de iner; önizleme kesilmez. Onay kutusunda `selectionClick`. Bayrak `omd_tutorial_hidden`.
- **Koyu:** çizilmemiş; sheet koyu tema rolleriyle.

#### 4.3 Çekim · `/scan` · `OmrCaptureScreen`
- `SmapCameraOverlay` (§C67): üst bar Kapat + "Optik Form" + "?"; kılavuz çerçeve; durum hapı (top 112); deklanşör (top 726). Eski logo ve "SMAP" yazısı yok. Flaş ve galeri yok.
- **Aranıyor:** `scanHintSearching`="Cevap alanını çerçeveye al.\nDers adları şeridi dışarıda kalsın."
- **Form bulundu:** turuncu dörtgen + köşe noktaları (4.4'e taşınır); hap Check 20 `#52CC8E` + `scanHintReady`="Hazır. Telefonu sabit tut ve çek."
- **Hareket:** kenar bulununca çerçeve köşeleri 150 ms saydamlaşır, dörtgen 150 ms belirir; hap çapraz geçiş; deklanşör `mediumImpact`, önizleme 100 ms donar, köşe ekranı 250 ms.
- **Navigasyon:** Kapat → önceki sekme (`pop`); "?" → 4.2; deklanşör → 4.4. Sonraki seferlerde Okut doğrudan buraya (4.1/4.2 atlanır).
- **Veri:** yerel kamera; kenar algılama DocumentScanner konturu; otomatik çekim yok (T2.3).
- **Koç:** öncesinde öğrenci seçim sheet'i (§3.4); sonuç seçilen öğrenciye.
- **Bakım:** Okut'a basınca sunucudan "okuma açık" bayrağı okunur; kapalıysa kamera açılmadan 4.10-2 sheet'i (bayrak yoksa ilk gönderimde) (T2.16).

#### 4.4 Köşe Düzenleme · `/scan/corners` · `OmrCornerScreen`
- **Üst bar:** Kapat + "Köşeleri Ayarla" (sağda 48 boşluk, "?" yok).
- **İpucu kartı (yalnız ilk kez):** top 110, yatay 16, `#18263D`, radius 16, dolgu 12, aralık 12, metin `#EDF1F6`; beyaz mini örnek 44 × 64 (radius 8, dolgu 4); 15/24·600 `cornersHint`="Noktaları cevap alanının köşelerine getir." + 13/20 `#A9B5C6` `cornersHintSub`="Ders adları şeridi dışarıda kalsın." + `text` (40) "Bir daha gösterme" (`omd_corner_hint_hidden`). Sürüklerken gizlenir.
- `SmapCornerHandles` + `SmapLoupe` (§C68).
- **Alt bant:** 132 yükseklik, `rgba(10,20,36,.92)`, dolgu 16/16/0, aralık 12: `secondary` (koyu set) "Tekrar Çek" (150 genişlik) + `primary` (koyu set `#C5D4E8`) "Devam" (flex).
- **Metinler:** `cornersTitle`="Köşeleri Ayarla"; `retake`="Tekrar Çek"; `next`="Devam".
- **Davranış:** "Devam" fotoğrafı kırpar (eklentinin ikinci düzenleme sayfası yok), gönderim 250 ms'de açılır; "Tekrar Çek" kameraya döner (öğretici yeniden açılmaz). Fotoğraf hazırlama: uzun kenar 2400 px, JPEG %85, isolate'te `image` paketi (T2.5).

#### 4.5–4.6 Gönderim · `/scan/upload` · `OmrUploadScreen`
- **Düzen:** başlık bölgesi (`role=status`, `aria-live=polite`; top 78, yatay 16): 24/32 başlık + 15/24 `#556173` (4 altta). Fotoğraf kartı (top 168, left 95, 212 genişlik, dolgu 8, radius 16, `shadowRaised`): görüntü 196 × 238, ad "Okunan form görüntüsü: dört kolon, kırk satır". `SmapStepList` kartı (top 450, yatay 16). `text` "Vazgeç" (top 774, ortalı).
- **Kareler:**
  1. Hazırlanıyor: spinner "Fotoğraf hazırlanıyor" · bekliyor "Gönderilecek" · bekliyor "Cevaplar okunacak". Süre yazılmaz.
  2. Gönderiliyor: ✓ "Fotoğraf hazırlandı" · "Gönderiliyor" + "%64" + 8 pt çubuk (gerçek yükleme yüzdesi) · "Cevaplar okunacak".
  3. Okunuyor: ✓ "Fotoğraf hazırlandı" · ✓ "Gönderildi" · spinner "Cevapların okunuyor". 30 sn yanıt yoksa 4.
  4. Gönderilemedi: başlık "Formun gönderilemedi" + "Bağlantı koptu. Fotoğrafın duruyor; tekrar gönderebilir ya da yeniden çekebilirsin."; 2. adım hata "Gönderilemedi"; düğmeler (top 704, aralık 12) `primary` "Tekrar Dene" + `quiet` "Yeni Fotoğraf". Sayfa kapanmaz, fotoğraf kaybolmaz. Zaman aşımında gövde "Sunucu yanıt vermedi.". `error` haptiği.
- **Metinler:** `uploadTitle`="Formun okunuyor"; `uploadSub`="Birkaç saniye sürebilir."; `stepPreparing`="Fotoğraf hazırlanıyor"; `stepPrepared`="Fotoğraf hazırlandı"; `stepToSend`="Gönderilecek"; `stepSending`="Gönderiliyor"; `stepSent`="Gönderildi"; `stepSendFailed`="Gönderilemedi"; `stepToRead`="Cevaplar okunacak"; `stepReading`="Cevapların okunuyor"; `percent`="%{n}"; `uploadFailTitle`; `uploadFailBody`; `uploadTimeoutBody`="Sunucu yanıt vermedi."; `newPhoto`="Yeni Fotoğraf"; `a11yInProgress`="Sürüyor"; `a11yUploadProgress`="Gönderim".
- **Etkileşim:** "Vazgeç" gönderimi durdurur (`CancelToken`), fotoğrafla 4.4'e döner. Başarı → 4.7. Adım değişimi 250 çapraz geçiş; yüzde her %10'da duyurulur; başarı haptiği burada değil (5.1'de).
- **Veri:** `opticimage` (`OmdRepository.sendOMImageToServer`) → `answersArray`, `opticImageFileName`, `originalImageFileName`, `mexamFound`, `success`. Yüzde için dio `onSendProgress`; zaman aşımı gönderim 60 sn, okuma 30 sn (bugün global 10 sn). Bugün base64 + `user_data` POST; multipart JPEG desteği backend sorusu (§6.3 #2). **Taban adres bugün placeholder** (`lib/core/constants/api_constants.dart:14` `apiBaseUrl = 'https://wfdsvfsdg.com/'`) — düzeltilmeden akış çalışmaz.
- **Koyu (4.6):** kanvas `#0A1424`, metin `#EDF1F6` / `#A9B5C6`; kart `#121D31`; ray `#213049`; dolgu `#FF8533`; hata `#FF8F8F`; spinner `#34445F` / `#C5D4E8`; bitti `#C5D4E8` + `#091A31`; primary `#C5D4E8`; fotoğraf kartı koyu gölge %40. (Kameradan sonra beyaz ekran sıçraması olmasın.)

#### 4.7–4.8 Form Kontrol · `/scan/review` · `FormCheckScreen` + `SmapAnswerFixSheet`
- **Düzen:** Kapat (X 24, top 54, left 4) — düzeltme varsa normal ConfirmSheet `exitScanConfirm`="Okutmadan çıkılsın mı?" ([Karar] gövde "Düzelttiğin cevaplar kaydedilmeyecek.", düğmeler "Çık" / "Vazgeç"); 24/32 "Form Kontrol" (top 102) + 15/24 `#556173` "Okunan cevapları formunla karşılaştır."; görüntü kartı (top 172, 370 genişlik, dolgu 12; görüntü 346 × 212; "Formu büyüt"); 13/20 `#556173` (top 412) "İki parmakla yakınlaştırabilirsin."; özet satırı (top 444, aralık 16): 16/24·700 "160 cevap okundu" + 20 `#7E8A9B` daire (Minus 12) "2 boş" (+ düzeltme varsa `#0F294A` PencilSimple 18 "2 düzeltme"); `SmapSegmented.counter` (top 480): "1. kolon" … "4. kolon", alt "boş yok" / "N boş" (kolon adı yerine sıra no: deneme henüz tanınmadı); 13/20·600 `#556173` (top 548) "3. kolon · 40 soru · düzeltmek için soruya dokun"; formCheck ızgarası (top 574, left 20; 5 × 66, aralık 8). Alt bant (114, `#FFFFFF`, üst çizgi `#DCE2E9`, dolgu 16/16/0, aralık 12): `secondary` (PencilSimple 20) "Düzelt" (120) + `primary` "Cevapları Onayla" (flex).
- **Cevap Düzelt sheet'i** (full; kolon → soru → şık): başlık "Cevap Düzelt" + 13/20·600 `#556173` sayaç ("Düzeltme yok" / "N düzeltme"; hep görünür) + Kapat. Gövde (dolgu 12/24/0, aralık 16): "Kolon" + düz `SmapSegmented`; "Soru" + `quiet` 48 Minus ("Önceki soru") + 88 genişlik alan (`role=spinbutton`, ortalı 700, "Soru numarası") + `quiet` 48 Plus ("Sonraki soru"), yanında 13/20 "Okunan" + 15/24·600 değer (gri daire + "Boş"); "Formdaki işaretin" + kare çipler A–E (48) + "Boş" (64); `primary` "Düzeltmeyi Ekle" (şık seçilmeden pasif); ayraç; 17/24 "Düzeltmeler" (8 altta): boşken 15/24 `#556173` "Henüz düzeltme yok. Okunan cevap formundakinden farklıysa yukarıdan ekle."; satır min 56, üst çizgi `#E8ECF1`: 15/24·600 "3. kolon · 12. soru" + 15/24 "Boş → C" + X 20 ("Düzeltmeyi kaldır: 3. kolon, 12. soru"). Alt boşluk 42. Hücreye dokunulunca kolon ve soru dolu gelir, yalnız şık seçilir; açılışta seçili soruya odak.
- **Kareler:** (1) okunan form ve özet; (2) sheet boş liste (Soru 12, seçili C); (3) sheet iki düzeltme ("3. kolon · 12. soru Boş → C", "4. kolon · 31. soru Boş → A"), Soru 31 şık seçilmemiş → Ekle pasif; (4) düzeltildi, gönderiliyor: özet "0 boş" + "2 düzeltme", kolonlar "boş yok", "Düzelt" pasif, primary spinner + "Gönderiliyor" (ek onay sorulmaz).
- **4.8 Durumlar:** (1) görüntü yükleniyor: 346 × 212 iskelet + 13/20·600 "Form görüntüsü yükleniyor"; ızgara hemen çalışır; 15 sn'de gelmezse kartta "Görüntü yüklenemedi" + `text` "Tekrar Dene" ([Karar] `SmapErrorState.section` kalıbı). (2) gönderilemedi: satır içi uyarı (`role=alert`; top 684, yatay 16, `#FCEAEA`, radius 12, dolgu 12/16, aralık 12; WarningCircle 24 `#C42D35`; 15/24 "Cevaplar gönderilemedi. Düzeltmelerin duruyor; tekrar dene."); birincil "Tekrar Dene" olur; düzeltmeler kaybolmaz; çevrimdışıysa "Bağlantı yok. Bağlantı gelince tekrar dene."; uyarı 250 ms alttan + `error`. Boş durum yok.
- **Metinler:** `reviewTitle`="Form Kontrol"; `reviewSub`; `a11yZoomForm`="Formu büyüt"; `pinchHint`="İki parmakla yakınlaştırabilirsin."; `answersRead`="{n} cevap okundu"; `blankCount`="{n} boş"; `correctionCount`="{n} düzeltme"; `noCorrection`="Düzeltme yok"; `columnN`="{n}. kolon"; `noBlank`="boş yok"; `columnCaption`="{n}. kolon · {q} soru · düzeltmek için soruya dokun"; `fix`="Düzelt"; `confirmAnswers`="Cevapları Onayla"; `sending`="Gönderiliyor"; `fixSheetTitle`="Cevap Düzelt"; `fieldColumn`="Kolon"; `fieldQuestion`="Soru"; `readValue`="Okunan"; `blank`="Boş"; `yourMark`="Formdaki işaretin"; `addCorrection`="Düzeltmeyi Ekle"; `corrections`="Düzeltmeler"; `correctionsEmpty`; `correctionRow`="{col}. kolon · {q}. soru"; `correctionChange`="{from} → {to}"; `imageLoading`="Form görüntüsü yükleniyor"; `imageLoadFailed`="Görüntü yüklenemedi"; `answersSendFailed`; `answersOffline`; a11y "Önceki soru", "Sonraki soru", "Soru numarası", "{n}. soru, okunan {x}", "{n}. soru, boş okundu, düzeltmek için dokun", "{n}. soru, düzeltildi: {x}", "Düzeltmeyi kaldır: {col}. kolon, {q}. soru".
- **Hareket:** şık `selectionClick`; "Düzeltmeyi Ekle" satırı listenin başına 250 ms kayarak girer, sayaç güncellenir.
- **Veri:** giriş `answersArray` (4 kolon × 40 soru; örnek 160 cevap; 2 boş: 3. kolon 12, 4. kolon 31), `opticImageFileName` (görüntü URL'si). Düzeltmeler `Map<(int kolon, int soru), String şık>`; gönderimde uygulanır → `answerArray` (`sendAnswerArrayToServer`) → `mexamFound`, `success`. `mexamFound` Map ise 5.1, değilse 4.9. Sonuç örneği 86 D · 74 Y · 0 B. **Koyu:** çizilmemiş.

#### 4.9 Deneme Bulunamadı · `/scan/exam-not-found` · `ExamRequestScreen`
- **Düzen:** Kapat (X); 24/32 başlık (top 102) + 15/24 `#556173` (8 altta); bilgi kartı (20 altta, dolgu 12/16, aralık 12): Clock 24 `#36537C` + 15/24; alanlar (28 altta, aralık 20): "Yayınevi" ve "Deneme adı" (ikisi zorunlu); `primary` "Analizimi Hazırlayın" (top 784; klavye açıkken klavyenin üstünde).
- **Kareler:** (1) boş; (2) doğrulama: alanlar hata + "Yayınevini yaz." / "Deneme adını yaz."; odak ilk hatalı alana; `error`; sallanma yok; (3) onay (normal ConfirmSheet): "Talep oluşturulsun mu?" + özet kutusu (`#F2F4F7`, radius 12, dolgu 4/16; satırlar dolgu 12/0, ayraç `#DCE2E9`; dt 13/20·600 `#556173`, dd 16/24·600 2 altta) + 15/24 `#556173` "Analizin hazır olunca Analizlerim › Denemelerim'de görünür." + `primary` "Talebi Gönder" + `quiet` "Vazgeç"; (4) talep alındı (`role=status`, `SmapStatusView.flow` top 220, yan 32): 80 `#E4F4EA` + CheckCircle 40 `#0B6E3E`; 24/32 "Talebin alındı" (24 altta) + 15/24 `#556173` (8 altta); `primary` "Anasayfa" → `go('/home')`; `success`; 250 ms çapraz geçiş. Bildirim sözü yok (T2.14).
- **Metinler:** `enfTitle`="Bu deneme henüz sistemde yok"; `enfBody`="Yayınevini ve deneme adını yaz; analizini en geç 72 saat içinde hazırlayalım."; `enfSaved`="Cevapların kaydedildi. Yeniden okutman gerekmez."; `fieldPublisher`="Yayınevi", `fieldPublisherHint`="Örn: Örnek Yayınları"; `fieldExamName`="Deneme adı", `fieldExamNameHint`="Örn: Türkiye Geneli Deneme 7"; `enfSubmit`="Analizimi Hazırlayın"; `errPublisherRequired`="Yayınevini yaz."; `errExamNameRequired`="Deneme adını yaz."; `enfConfirmTitle`="Talep oluşturulsun mu?"; `enfConfirmNote`; `sendRequest`="Talebi Gönder"; `enfDoneTitle`="Talebin alındı"; `enfDoneBody`="En geç 72 saat içinde hazır. Hazır olunca Analizlerim › Denemelerim'de görünecek."; `goHome`="Anasayfa".
- **Veri:** `publisher`, `examName` + kayıtlı cevaplar → `examrequest` (`sendExamDetailToServer` → `success`). Ölü `_submitRequest` kalkar. Listeden deneme seçme yok [Ç-43]. **Koyu:** çizilmemiş.

#### 4.10 Hata ekranları · `/scan/error?type=` · `OmrErrorView`
Kalıp `SmapStatusView.flow`: 80 rozet, 24/32 başlık (kamera karesinde 20/28), tek cümle (neden + ne yapmalı), en fazla iki düğme; 250 ms çapraz geçiş; odak birincil; Kapat sol üstte; hata `role=alert`, bilgi `role=status`.

| Kare | Tetik | Görsel | Metin | Eylem |
|---|---|---|---|---|
| 1 Form bulunamadı (`formNotFound`) | sunucu cevap alanını seçemedi | hata rozeti, WarningCircle 40; kap top 200, yan 32 | `formNotFoundTitle`="Formu bulamadık"; `formNotFoundBody`="Fotoğrafta cevap alanı seçilemedi. Formun tamamı görünsün, ışık yansımasın, ders adları şeridi dışarıda kalsın." | (top 724) `primary` "Yeni Fotoğraf" + `quiet` `howToShoot`="Nasıl Çekilir?" (4.2); `error` |
| 2 Optik okuma kapalı | Okut'a basınca bakım bayrağı | small sheet: 40 `#E2EAF4` + Wrench 22, 20/28 + 15/24 | `omrClosedTitle`="Optik okuma şu an kapalı"; `omrClosedBody`="Kısa bir bakım yapıyoruz. Birazdan tekrar dene." | `primary` `ok`="Tamam"; tahmini süre yalnız sunucu verirse; haptik yok |
| 3 Bağlantı yok (planlı, kuyruk gelince) | — | offline rozeti `#E8ECF1` / `#3E4858`, WifiSlash 40 | `offlineTitle`="Bağlantı yok"; `offlineQueuedBody`="Fotoğrafın telefonunda saklandı. Bağlantı gelince gönderilecek." | `primary` "Tamam" + `quiet` `retryNow`="Şimdi Tekrar Dene". **v1'de kullanılmaz** (kuyruk yok; 4.5 kare 4 kalıbı) [Ç-44] |
| 4 Kamera açılamadı (`cameraUnavailable`) | kamera aşaması (koyu) | Kapat `cameraTranslucent`; rozet `#18263D` / `#EDF1F6`, CameraSlash 36; kap top 260; başlık 20/28 | `cameraFailTitle`="Kamera açılamadı"; `cameraFailBody`="Başka bir uygulama kamerayı kullanıyor olabilir. Onu kapatıp tekrar dene." | `primary` (koyu set `#C5D4E8`) "Tekrar Dene" (top 784); `error`; eklentinin "No Camera" metni gösterilmez |

### 4.D Deneme sonucu ve detay (SMAP-05, Tur 2 #12–15, Tur 3)

#### 5.1 Sonuç Anı · `/scan/result/:examId` · `ResultMomentScreen` (root, alt çubuk yok)
- **Kod:** `omd_result_flow_view.dart` (eski 3 adımlı akış) kalkar.
- **Düzen (kare 1, AYT · EA):**
  1. Kapat (`plain` X 24, "Kapat"; x=4, y=54).
  2. Kimlik satırı (y=106, aralık 16, dikey ortalı): `SmapExamHeader.moment` kapak 56 × 76; yayınevi 13/20·600 `#556173`; ad 17/24·700 (2 altta); tür Tag + tarih 13/20 (6 altta, arası 8).
  3. Net bloğu (y=206, `role=status`): "67,5" metric-xl + "net" 17/24·600 (taban hizalı, arası 8); delta 15/24 (aralık 6, 2 altta): ArrowUp 18 + "+8,25" 700 `delta` + "önceki AYT denemene göre" `#556173`.
  4. `SmapDybCounter.large` (y=322): Doğru 86 · Yanlış 74 · Boş 0.
  5. Puan türü `SmapSegmented` (y=404, "Puan türü"): Eşit Ağırlık (seçili) · Sayısal · Sözel.
  6. StatBox ikilisi (y=464, 2 sütun, aralık 8): "412,63" / "Yerleştirme puanı"; "48.215." / "Sıra".
  7. Alan neti (y=564): 15/24·700 "Eşit Ağırlık neti 40" + 13/20 `#556173` "Türk Dili ve Edebiyatı–Sosyal Bilimler 1 ve Matematik".
  8. Kart satırı (y=632, `button` kart, min 64, dolgu 12/16, aralık 12): 40 daire `#E2EAF4` / `#36537C` (koyu `#1A2B45` / `#9BB3D3`) + Cards 22; 15/24·600 "Bu denemeden 23 bilgi kartı eklendi" (flex); CaretRight 20.
  9. Eylem satırı (y=778, alta sabit, aralık 12): `quiet` "Anasayfa" (132) + `primary` "Detaylı Analiz" (flex).
- **Kare 2 (TYT, eksik veri):** yayınevi yok; "TYT Genel Deneme 9", "TYT", "28 Eylül 2026"; net "74,75"; "+3,25" "önceki TYT denemene göre"; 80 · 21 · 19. Segment, puan, alan neti ve kart satırı **çizilmez** (TYT'de puan türü yok; "0"/tire yok).
- **Durumlar:** eksik alan çizilmez; Sayısal/Sözel seçilince o alanın neti; puan/sıra yoksa kutular çizilmez; OBP satırı yok. Tek istekten beslenir; [Karar] yükleme gerekmez (veri `answerArray` yanıtından gelir); kart sayısı yanıtta yoksa satır yok.
- **Ekran okuyucu:** "Türkiye Geneli Deneme 6, 67,5 net, önceki AYT denemene göre 8,25 artış. 86 doğru, 74 yanlış, 0 boş."
- **Hareket:** gelişte bir kez `success`; içerik 250 ms 8 pt yukarı kayarak belirir (hareketi azaltta opaklık); konfeti, dönen sayaç, parlama yok.
- **Navigasyon:** §3.6. İlk başarılı okumada ayrılırken önce 5.2 (bayrak açıksa).
- **Veri:** sonuç nesnesi (`mexamFound`): mexam {_id, name, type, image}, yayınevi, tarih, true, wrong, pass, net (net sunucuda D − Y ÷ 4); delta (aynı türdeki önceki denemeye göre; kaynak §6.3 #20); `points[]`, `ranks[]` (aimType indeksiyle; yalnız öğrencinin alanı); `aytNets` {EA 40, SAY 37,5, SÖZ 30} (anahtarlar 2/3/4); kart sayısı `getTotalInfoCard` (PersistCookieJar istemcisine taşınır). Eski avatar `NetworkImage` hatası ekranla birlikte kalkar.
- **Koyu (kare 3; mağaza karesi 3):** kapak `#213049` + ikon `#6B7D97`; Tag `#213049`; delta `#9BB3D3`; D/Y/B koyu, glif `#0A1424`; kartlar `#121D31`; kart satırı ikonu `#1A2B45` / `#9BB3D3`; düğmeler koyu.
- Kapak yer tutucu 56 × 76 (sunucudan); yayınevi ve ad ayrı satır (D-32); "(Test)" ve "Deneme: N" yok (D-33).

#### 5.2 Bildirim izni (small sheet, 5.1 üstünde) · `NotificationPrimerSheet`
- Tutamaç; ortalı başlık bloğu (dolgu 28/24/0): 64 daire `#E2EAF4` + Bell 32 `#0F294A` ([Karar] koyu `#1A2B45` / `#9BB3D3`); 20/28 başlık (16 altta); 15/24 `#556173` (8 altta). Kapat yok. Eylem: `primary` "Bildirimlere İzin Ver" + `quiet` "Sonra".
- **Metinler:** "Sonucun hazır olunca haber verelim mi?" · "Sistemde olmayan bir denemeyi okuttuğunda analizini hazırlayınca bildirim gönderelim. Hesap › Bildirimler'den istediğin zaman kapatabilirsin." · "Bildirimlere İzin Ver" · "Sonra".
- **Davranış:** yalnız ilk başarılı okumada, 5.1'den "Anasayfa" ya da "Detaylı Analiz" ile ayrılırken bir kez (D-23). İzin Ver → sistem kutusu → sheet 250 ms kapanır → hedef ekran. Sonra → bir daha sormaz. Bayrak `notif_primer_shown`. **Feature flag `notificationsEnabled` kapalıyken hiç gösterilmez** (T2.17). Haptik yok.

#### 5.3–5.10 Deneme Detay · `/analytics/exam/:examId?tab=` · `ExamDetailScreen`
- **Kod:** `analytics/.../my_test_result_detail_screen.dart`, `my_test_results_detail_widgets.dart` (yeniden yazılır). `CustomScrollView`: SliverAppBar (`SmapDetailBar` büyük → kısa) + `SmapExamHeader.detail` + yapışkan `SmapTabBar` (`SliverPersistentHeader`; Genel · Sorular · Konular · Kartlar, "Deneme bölümleri") + sekme içeriği. Alt çubuk görünür, Analizlerim seçili.
- **Başlık (5.3 kare 1, AYT):** geri; kapak 48 × 64; "Örnek Yayınları"; "Türkiye Geneli Deneme 6"; "AYT" + "5 Ekim 2026"; "67,5" metric-lg + "net"; Doğru 86 · Yanlış 74 · Boş 0; puan kartı "Eşit Ağırlık" — "412,63" "Yerleştirme puanı" · "48.215." "Sıra". Sekmeler y=430.
- **Kaydırılmış (kare 2):** kısa bar "Türkiye Geneli Deneme 6" (2 satıra kadar); sekmeler y=102'ye yapışır; liste y=166.
- **TYT (kare 3):** yayınevi ve puan kartı yok; sekmeler y=318. Boş parça gri çubuk.
- **Veri:** başlık ve test kırılımı tek istekten (`lessonInfo` JSON string → model; test başına name, true, wrong, pass, net, soru sayısı; test neti sunucudan). Eski `true = result['wrong']` hatası düzeltilir. Sorular, Konular, Kartlar ayrı ve tembel yüklenir; her biri kendi bölüm durumunu taşır. Ekran bütünüyle yalnız başlık verisi gelmezse hata verir.
- **Hareket:** büyük başlık 250 ms kısa bara; sekme göstergesi 250, içerik 150 çapraz geçiş, `selectionClick`; çubuklar ilk açılışta 350 ms dolar.

**Genel sekmesi (5.3):** test listesi kartı (dolgu 0/16) `SmapTestBarRow`'lar. AYT: "Türk Dili ve Edebiyatı–Sosyal Bilimler 1" 18,75 (23/17/0, 40 soru) · "Sosyal Bilimler 2" 11,25 (17/23/0, 40) · "Matematik" 21,25 (25/15/0, 40) · "Fen Bilimleri" 16,25 (21/19/0, 40). TYT: "Türkçe" 30,5 (32/6/2, 40) · "Sosyal Bilimler" 13 (14/4/2, 20) · "Temel Matematik" 20,75 (22/5/13, 40) · "Fen Bilimleri" 10,5 (12/6/2, 20). Liste sonunda dipnot (yan 20, 13/20 `#556173`, aralık 4): "Net = doğru − yanlış ÷ 4; boş neti etkilemez." ve "Puan türüne göre net: Eşit Ağırlık 40 · Sayısal 37,5 · Sözel 30.".

**Sorular sekmesi (5.4):** `SmapSegmented.counter` ("Soru süzgeci"): "Tümü"/"160 soru" · "Yanlışlar"/"74 yanlış" · "Boşlar"/"boş yok" [Ç-10]. Akordeon yığını (kartlar arası 8): test başlığı + ızgara (`SmapQuestionCell.result`, 5 sütun, aralık 6). İlk test açık.
- Kare 1 örnek işaretler (işaret→doğru): 1 E→B, 2 B→E, 3 A→B, 4 A→D, 5 E→C, 6 B, 7 C→A, 8 C→A, 9 A, 10 B, 11 A→D, 12 E→B, 13 E→A, 14 A, 15 C→D, 16 D, 17 D, 18 C→B, 19 B, 20 B, 21 D, 22 E, 23 E, 24 C, 25 A→E, 26 C, 27 A, 28 A, 29 E, 30 C, 31 C→A, 32 D, 33 E→C, 34 E, 35 A→D, 36 B, 37 B→E, 38 E, 39 D, 40 A (şıklar örnek, T3.3).
- Kare 2 Yanlışlar: ilk testte 17 hücre; kapalı testler sayaçlarıyla durur.
- Kare 3 Boşlar boş: bölüm boş kartı (dolgu 28/24, ortalı): 32 × 32 `#7E8A9B` + Minus 18; 16/24·700 "Boş bıraktığın soru yok" (12 altta); 13/20 `#556173` "Bu denemedeki 160 sorunun hepsini işaretledin." (4 altta); `text` "Tüm Soruları Göster" (8 altta). Görsel yok.
- Hücre → 5.7; süzgeç değişince ızgara 150 ms çapraz geçiş + `selectionClick`; akordeon 250.
- **Veri:** soru başına sıra, işaret, doğru cevap, durum — kaynak belirtilmemiş (`questionsArrStr` yalnız `{order,type}`; backend §6.3 #9).

**Konular sekmesi (5.5):** `SmapMostMissedCard` (y=166): "En çok kaçırdığın konu" / "Cumhuriyet Edebiyatı" / "12 sorudan 7'sini kaçırdın." / "Bu Konuyu Çalış". Ders başlığı (y=348): 17/24 "Türk Dili ve Edebiyatı" + sağda 13/20 `#556173` "zayıftan güçlüye" (taban, iki uç); harfli D/Y/B "12 D 12 Y 0 B" + "24 soru" (4 altta, aralık 12). Konu kartı (y=412) `SmapTopicResultRow`'lar: "İslamiyet Etkisindeki Türk Edebiyatı (Divan-Halk Edebiyatı)" 0/2/0 Az soru %0 · "Nazım Bilgisi" 0/1/0 Az soru %0 · "Söz Sanatları" 0/1/0 Az soru %0 · "Cumhuriyet Edebiyatı" 5/7/0 %42 · "Batı Edebiyatı ve Akımları" 1/0/0 Az soru %100. Satır ve "Bu Konuyu Çalış" → 7.3 (ilk eksik madde). **Veri:** `GET /student/getMexamSubjectDetail?mexamId` (ders başına D/Y/B, konu başına d/y/b/n).

**Kartlar sekmesi (5.6):** `SmapInfoHeaderCard` (y=494): "23 bilgi kartı eklendi" / "Bu denemede yanlış ve boş bıraktığın sorulardan."; `primary` "Kartları Çalış" (y=590); ders grubu başlığı (y=662): Tarih karosu 32 (radius 10, `#FBF1DA` / Bank 20 `#8C6106`) + 17/24 "Tarih"; `SmapCardPreview`'lar (y=706, aralık 8): "Edirne-Segedin Antlaşması (1444)" / "Haçlılarla Osmanlı Devleti'nin imzaladığı ilk antlaşma. Tuna sınır olur, on yıl savaş yapılmaz." / "Eksiklerimde"; "Otlukbeli Savaşı (1473)" / "Fatih Sultan Mehmet – Uzun Hasan (Akkoyunlu)." Grup içi sıra denemedeki soru sırası; ders başına sayı yoksa grup sayacı yok; yeni kart eksik kabul edilir. Karta dokunma → `SmapCardSheet`; "Kartları Çalış" → 8.1 (bu denemenin kartları). **Veri:** `GET /student/getMexamItemDetail?mexamId` → item {_id, name, desc, mainSubject{name}}, favorite. Koyu: token (Tarih `#2C2513` / `#E3B651`).

**5.8 Durumlar:** (1) iskelet (yalnız ilk yükleme; sekmeler gerçek ve dokunulur): (16,102) 48 × 64 r6→8; (76,106) 110 × 16; (76,130) 220 × 24; (76,160) 90 × 16; (16,186) 120 × 40; D/Y/B x=16/146/276, y=246, 100 × 52; puan (16,318) 370 × 96 r16; liste kartı y=494 dolgu 16 aralık 14: 3 × (16 yükseklik 220/150/120 + 12 yükseklik radius full). (2) ders verisi yok (TYT başlığıyla) bölüm kartı y=382: "Ders kırılımı yok" / "Netin ve doğru, yanlış, boş sayıların hesaplandı; bu deneme için ders bazında sonuç gelmedi." (3) hata (ekran) y=230: "Deneme yüklenemedi" / "Bağlantını kontrol edip tekrar dene." / "Tekrar Dene" (hata gelişinde haptik yok; Tekrar Dene başarısızsa `error`). (4) çevrimdışı: kısa bar + şerit (y=102) + sekmeler y=142 + liste y=206, önbellekteki deneme. Bölüm boş metinleri: "Bu deneme için soru ayrıntısı yok." · "Konu analizi henüz hazır değil." · "Bu denemeden kart eklenmedi.".

**5.9 Koyu (Genel ve Sorular; mağaza karesi 4) / 5.10 Konular koyu:** kanvas `#0A1424`; kart `#121D31`; metin `#EDF1F6` / `#A9B5C6`; kapak `#213049` + ikon `#6B7D97`; Tag `#213049`; çubuk ve sayaçlar `#52CC8E` / `#F07575` / `#6E7C92`; ayraç `#26354D`; sekme göstergesi `#FF8533`; segment başparmağı `#C5D4E8` (sayaç renkleri T11.7 düzeltmesiyle: seçili başlık `#091A31`, sayaç `#1A3357`); kısa bar `#0A1424`; hücreler doğru `#121D31` + `#26354D`, yanlış `#3B1D22`, boş `#213049`, doğru cevap `#52CC8E`; halka ray `#213049`, yay `#9BB3D3`, metin `#EDF1F6`; `primary` `#C5D4E8` / `#091A31`.

#### 5.7 Soru Detay · `/analytics/exam/:examId/question?lesson=&q=` · `QuestionDetailScreen`
- **Kod:** `question_detail_page.dart` (iki sekmeli + CardSwiper) yeniden yazılır.
- **Kare 1 (yanlış):** geri; 24/32 "31. soru" (y=102) + 13/20·600 `#556173` "Türk Dili ve Edebiyatı–Sosyal Bilimler 1 · Tarih" (sarar); cevap kartı (y=174, dolgu 16, 2 sütun, aralık 12): her sütunda etiket 13/20·600 `#556173` + satır (aralık 10, 6 altta) 24 D/Y/B çipi + harf 32/40·800: "İşaretin" C (Yanlış çipi `#D8333A`), "Doğru cevap" A (Doğru çipi `#0B6E3E`) [Ç-64]; 17/24 "Soru Analizi" (y=290) + 15/24 açıklama (6 altta); 17/24 "İlgili kartlar" + 13/20·600 `#556173` "2 kart" (y=430); yatay carousel (y=466, sol 16 sağ 0, aralık 8; kart 264 genişlik, dolgu 16; ikinci kart kenardan taşar) — `SmapCardPreview` kompakt; `primary` "Kartları Çalış" (y=630); telif notu (y=700, aralık 10): Image 20 `#556173` + 13/20 `#556173` "Sorunun fotoğrafı telif hakları nedeniyle paylaşılamıyor.".
- **Kare 2 (doğru, açıklama yok):** "6. soru" / "Türk Dili ve Edebiyatı–Sosyal Bilimler 1 · Türk Dili ve Edebiyatı"; cevap kartı (y=198) tek satır (aralık 16): "İşaretin" B + 15/24·600 "İşaretin doğru cevap."; "Soru Analizi" (y=318): 15/24 `#556173` "Bu soru için çözüm açıklaması yok."; ilgili kart yoksa bölüm çizilmez; telif notu y=420.
- "Fotoğraf Çek", "Soru Bankam", önceki/sonraki soru gezinmesi yok (T3.9). Karta dokunma → CardSheet; geri → ızgara.
- **Veri:** `POST /student/getQuestion {mexam, questionOrder, lessonOrder}` → question.desc, question.items[] (mainSubject.name, name, desc), cards[], description. Açıklama kart metninden (T3.8). **Koyu:** token.

### 4.E Analizlerim (SMAP-06, Tur 4)

#### 6.1–6.4 Analizlerim · `/analytics?tab=genel|denemelerim` · `AnalyticsScreen`
- **Kod:** `analytics_screen.dart`, `general_tab.dart`, `net_chart_card.dart`, `stats_grid.dart`, `general_filter_panel.dart`, `analytics_view_provider.dart`, `my_test_results_tab.dart`, `my_test_results_card.dart` (yeniden yazılır).
- **Bant:** `SmapRootBand` "Analizlerim" + bant içi `SmapTabBar.onNavy` "Genel" (gösterge 46) · "Denemelerim" (98), "Analizlerim bölümleri". "Analiz" ve "Harita" sekmeleri yok (D-4). İçerik y=190.

**Genel (6.1):**
- Süzgeç satırı (y=190, iki uç): `SmapFilterPill` "TYT · Genel" + CaretDown 18 ("Süzgeç: TYT · Genel") + 13/20·600 `#556173` "6 deneme".
- `SmapNetChart` kartı (y=246): "Net gelişimi" / "Son 6 deneme" / "net · TYT 0–120 · son nokta vurgulu". TYT verisi: 22 Nis. 61,5 · 14 May. 64,25 · 17 Haz. 68 · 4 Ağu. 66,75 · 15 Eyl. 71,5 · 28 Eyl. 74,75; balon "TYT Genel Deneme 9 · 28 Eyl." / "74,75 net".
- StatGrid (y=566): "6" / "Çözülen deneme" · "67,79" / "Ortalama net" / "+3,25 son denemede" · "381,40" / "Ortalama puan" · "182.430" / "Ortalama sıralama".
- **Kare 2 (AYT, eksik veri):** "AYT · Genel", "4 deneme", "Son 4 deneme", "net · AYT 0–160 · son nokta vurgulu"; AYT verisi 8 May. 48,5 · 2 Ağu. 55 · 21 Eyl. 59,25 · 5 Eki. 67,5 (balon "Türkiye Geneli Deneme 6 · 5 Eki." / "67,5 net"); kutular yalnız "4" ve "57,56" + "+8,25 son denemede".
- **Kare 3 (Süzgeç sheet'i, medium):** "Süzgeç" + Kapat; gövde dolgu 12/24/0, alanlar arası 20: "Sınav" segmenti TYT · AYT; "Alan" segmenti (yalnız AYT) Eşit Ağırlık · Sayısal · Sözel · Dil + yardım "Ders listesi alanına göre değişir. Profildeki alanın seçili gelir."; "Ders" çipleri (md, sarar, aralık 8): Genel · Türk Dili ve Edebiyatı · Tarih · Coğrafya · Matematik (EA listesi; ders listesi `getLessons`'tan); `primary` "Uygula".
- **Davranış:** süzgeç değişince grafik ve kutular aynı süzgeçten güncellenir (350 ms, `selectionClick`). "AYT · Genel" = bütün AYT testlerinin toplam neti; alan yalnız ders listesini değiştirir (T4.1). Değişim = son − sondan bir önceki (aynı süzgeç); iki deneme yoksa satır yok.
- **Veri:** `GET /student/getLineChartData {type, lesson, aimType}` → mockexams[{date, net, name}], user{aimType}, totalQuestion; `GET /student/getTotal {general, type, lesson, aimType}` → count, ortNet, data[] (points/ranks; ortalama puan/sıra); `GET /student/getLessons`. Sabit `aimType = 2` kalkar; profildeki alan kullanılır. `mexam.type == 1` TYT (aimType gönderilmez).

**Denemelerim (6.2):**
- `SmapSegmented.counter` (y=190, "Sınav türü"): "Tümü"/"10 deneme" · "TYT"/"6 deneme" · "AYT"/"4 deneme".
- Özet satırı (y=254): 13/20·600 `#556173` "Tüm tarihler · En yeni önce" + `text` (SlidersHorizontal 20, sağ −12) "Süz ve Sırala".
- Liste kartı (y=306) `SmapExamRow`'lar: "Türkiye Geneli Deneme 6" · AYT · "5 Eki. 2026" · "· Örnek Yayınları" · 86/74/0 · 67,5 · favori açık; "TYT Genel Deneme 9" · TYT · "28 Eyl. 2026" · 80/21/19 · 74,75; "AYT denemesi" · "21 Eyl. 2026" · 59,25; "TYT denemesi" · "15 Eyl. 2026" · 71,5; "TYT denemesi" · "4 Ağu. 2026" · 66,75; "AYT denemesi" · "2 Ağu. 2026" · 55.
- **Süz ve Sırala sheet'i (medium):** "Tarih" çipleri "Tüm tarihler" (seçili) · "Son 30 gün" · "Son 3 ay" · "Bu eğitim yılı" ([Karar] 1 Eylül'den itibaren); "Sıralama" radyoları "En yeni önce" (seçili) · "En yüksek net önce"; `primary` "Uygula".
- **Boş (kare 3):** `SmapEmptyState.screen` (y=230): Harita 128; "Henüz deneme yok"; "İlk denemeni okuttuğunda sonuçların, netin ve eksik konuların burada görünür."; `primary` (Camera 20, dolgu 0/20) "İlk Denemeni Okut" → Okut. Genel sekmesi de aynı boşu gösterir.
- Sonsuz kaydırma 8'erli, altta spinner, "Hepsi bu kadar" yok. Favori yalnız cihazda (D-25); favoriye göre süzme yok. Satır → 5.3.
- **Veri:** `POST /student/getMyMockExams {page, perPage: 8, filter{types, nets, dates}}` (+ yeni `sort=newest|net`) → enrichedMockExams[{itemName, net, true, wrong, pass, mexam{order, image, type}, date, isStarred}]. Sunucudaki `isStarred` yok sayılır.

**6.3 Durumlar:** (1) iskelet: bant ve sekmeler hemen; (16,190) 140 × 40 radius full; grafik kartı y=246, 304 yükseklik, dolgu 16 (120 × 20 + 16 boşluk + 220 yükseklik); 4 kutu 181 × 88 radius 16 (16,566), (205,566), (16,662), (205,662). (2) tek deneme: süzgeç "1 deneme"; kart (y=246, dolgu 20): 13/20·600 `#556173` "İlk denemen"; "74,75" metric-lg + "net"; 15/24 "TYT Genel Deneme 9 · 28 Eylül 2026"; 13/20 `#556173` "İkinci denemenden sonra gelişim grafiğin burada çizilir." (12 altta); kutular (y=470) "1" / "Çözülen deneme" ve "74,75" / "Ortalama net", delta yok. (3) hata (y=260): "Analizlerin yüklenemedi" / "Bağlantını kontrol edip tekrar dene." / "Tekrar Dene" (sekmeler çalışır; Denemelerim ayrı yüklenir). (4) çevrimdışı: şerit bandın altında (akışta, bant köşeleri düzleşir [Ç-65]); süzgeç yalnız önbellekteki türlerle; grafik balonsuz. Deneme yoksa iki sekme de 6.2 boşunu gösterir; "Geçen ay" hiçbir yerde yok; hata ve çevrimdışı haptiksiz.

**6.4 Koyu (Genel; mağaza karesi 5):** bant `#0F294A`; kanvas `#0A1424`; kart ve StatBox `#121D31`; ızgara `#26354D`; eksen `#A9B5C6`; çizgi `#9BB3D3`, alan %14; noktalar dolgu `#121D31` kenar `#9BB3D3`; son nokta `#FF8533` kenar `#121D31`; balon ters yüzey `#EDF1F6`, 1. satır `#36537C`, 2. satır `#0A1424`; delta `#9BB3D3` [Ç-8]; çip saydam + kenar `#6B7D97`.


### 4.F Derslerim ve konular (SMAP-07, Tur 5)

#### 7.1 Derslerim · `/lessons` · `LessonsScreen`
- **Kod:** sekme bugün `MyCardScreen` / `my_card_page.dart` (kart ızgarası) → yerine `LessonsScreen`. Eski TYT/AYT/SOS-2 diyaloğu (`home/.../lesson_navigation_helper.dart`) **kalkar**.
- **Düzen:** `SmapRootBand` "Derslerim" + `SmapSegmented.onNavy` TYT · AYT ("Sınav türü"; bant 178; seçim `lessons_exam_type`). Ders kartı (y=194) `SmapSubjectRow`'lar.
- **TYT satırları:** Türkçe "28 eksik" · Tarih (41/64 kart) "60 eksik" · Coğrafya "44 eksik" · Matematik "Web'de" · Geometri "Web'de" · Fizik "7 eksik" · Kimya "9 eksik" · Biyoloji "11 eksik". (Eksik etiketi `SmapEksikTag` [Ç-12].)
- **AYT satırları:** Türk Dili ve Edebiyatı (Feather) "3 eksik" · Tarih (alt satır "Türk Dili ve Edebiyatı–Sosyal Bilimler 1 testi", etiketsiz) · Tarih-2 ("Sosyal Bilimler 2 testi", nötr "eksik yok") · Coğrafya ("Türk Dili ve Edebiyatı–Sosyal Bilimler 1 testi", etiketsiz) · Coğrafya-2 ("Sosyal Bilimler 2 testi", etiketsiz) · Matematik "Web'de" · Fizik "7 eksik".
- **WebOnlySheet (small):** başlık bloğu (dolgu 24/24/0, aralık 12): Matematik karosu 40 + 20/28 "Kavram haritan web'de" (padding-top 6); 15/24 `#556173` "Matematik ve Geometri kavram haritan şimdilik smaptr.com'da." (12 altta); `primary` (ArrowSquareOut 20) "Web'de Aç" (`url_launcher`, harici tarayıcı; URL belirtilmemiş) + `quiet` "Tamam". "Haber ver" yok.
- **Kurallar:** ad TYT/AYT öneksiz; kart ilerlemesi yalnız gerçek veriyle; veri yoksa etiket yok; seçim cihazda hatırlanır ve ders detayına taşınır (Tarih-2 → Tarih detayı SOS-2 seçili; `defaultFilterValue` 4); çevrimdışında Web'de dersler gizlenir.
- **Etkileşim:** satır → 7.2 (Edebiyat → 7.4 segmentli detay); Web'de satırı → sheet. Okunuş "Matematik, web'de açılır".
- **Veri:** `GET /student/getLessonsTotalMissing` (ders ve kategori bazında eksik); `GET /student/getInfoCardsInfo` → infoObj[lessonId]{missCount, trueCount, favoriteCount, totalCards}; ders kimlikleri `core/constants/lesson_constants.dart` (`lessonTyt`/`lessonAyt`).
- **Koyu:** çizilmemiş; bant navy kalır, karolar koyu ders renkleri.

#### 7.2 Ders Detayı · `/lessons/:lessonId?cat=&eksik=` · `LessonDetailScreen`
- **Kod:** `analytics/.../lesson_detail_page.dart` (getMainSubjects, resultByType).
- **Düzen:** geri; başlık (y=102, aralık 12): `SmapSubjectGlyph` 40 + 24/32 ad; süzgeç satırı (y=158, iki uç): `SmapFilterPill` (Flag 16) "Eksiklerim (31)" (toggled) + `text` (Cards 20, sağ −12) "Kartlarım" (Tarih'te "Kartlarım · 41/64"); `SmapSegmented.counter` (y=214, "Kategori"); konu kartı (y=286) `SmapTopicRow`'lar.
- **Türkçe · TYT (kare 1):** segment "Tümü"/"31 eksik" · "TYT"/"28 eksik" (seçili) · "AYT"/"3 eksik"; konular 1 Sözcükte Anlam · 2 Cümlede Anlam · 3 Ses Bilgisi · 4 Yazım Kuralları · 5 Anlatım Yöntemleri · 6 Paragraf · 7 Söz Öbekleri · 8 Cümlenin Öğeleri "2 eksik" · 9 Fiilde Çatı "3 eksik" · 10 Cümle Türleri · 11 Anlatım Bozuklukları · 12 Noktalama İşaretleri "3 eksik".
- **Eksiklerim açık (kare 2):** yalnız 8, 9, 12 (numaralar korunur); dipnot (y=490, yan 20, 13/20 `#556173`) "Yalnız eksiği olan konular. Numaralar tam listedeki sırayı korur.".
- **Tarih · SOS-2 (kare 3):** "Eksiklerim (60)", "Kartlarım · 41/64"; segment "TYT"/"60 eksik" · "AYT" (sayaçsız) · "SOS-2"/"eksik yok" (seçili); konular 1 İki Savaş Arasındaki Dönemde Türkiye ve Dünya · 2 İkinci Dünya Savaşı Sürecinde Türkiye ve Dünya · 3 İkinci Dünya Savaşı Sonrasında Türkiye ve Dünya · 4 Toplumsal Devrim Çağında Dünya ve Türkiye · 5 21. Yüzyılın Eşiğinde Türkiye ve Dünya.
- **Kurallar:** numara istemcide 1..n; SOS-2 seçeneği yalnız Tarih ve Coğrafya'da; segment seçenekleri panodaki gibi (Tarih/Coğrafya: TYT · AYT · SOS-2, "Tümü" yok; diğer dersler Tümü · TYT · AYT) [Ç-35, açık soru]; eksik işareti amber EksikTag.
- **Etkileşim:** satır → 7.3; "Kartlarım" → 8.1 (ders destesi); segment 250 + `selectionClick`. Okunuş: segment "TYT, 28 eksik"; etiket "3 eksik".
- **Veri:** `GET /student/mainSubjects?lessonId` + kategoriye göre eksik (resultByType). Türkçe toplamı 31 (28+3), konu bazında 8 — fark sunucudan (T5.2).

#### 7.3 Konu Detayı · `/lessons/:lessonId/topics/:topicId?focus=firstMissing` · `TopicDetailScreen`
- **Kod:** `subject_detail_page.dart` (getSubSubjectsAndItems; `statusArray` içindeki "0" = eksik).
- **Düzen (kare 1):** geri; başlık (y=102): 24/32 "Sözcükte Anlam"; 13/20·600 `#556173` "Türkçe · TYT · 1. konu" (2 altta); 15/24 "5 alt başlık · 25 madde" (6 altta). Akordeon yığını (y=206, kartlar arası 8): `SmapAccordion` alt başlık kartları → madde satırları (§C50) + `SmapExampleBox` + `text` "Kartı Aç".
- **İçerik örneği:** "Anlamı Yönünden Sözcükler" (4 madde, 1 eksik): 1 Temel Anlam (Eksik): tanım "Bir sözcüğün akla gelen ilk anlamıdır. Sözlük anlamı da denir." / Örnek "Bazı insanlar karanlıktan korkar." / ""Karanlık" burada ışıksız anlamında, temel anlamıyla kullanılmış."; 2 Yan Anlam; 3 Mecaz Anlam; 4 Terim Anlam. Diğer alt başlıklar: "Sözcükler Arası Anlam İlişkileri" 9 madde · "Mecaz Oluşturma Yolları" 9 madde · "Yansıma Sözcükler" 1 madde · "Kalıplaşmış Söz Öbekleri" 2 madde.
- **Kaydırılmış (kare 2):** kısa bar "Sözcükte Anlam"; içerik y=128; açık madde "Yan Anlam": "Bir sözcüğün temel anlamıyla bağlantılı olarak kazandığı yeni anlamdır." / "Yorganın yüzü kirlenmiş." / ""Yüz" insanın yüzü değil, yorganın dış tarafı: temel anlamla bağlantılı yan anlam.".
- **CardSheet (kare 3):** bağlam "Türkçe · Sözcükte Anlam"; başlık "Temel Anlam"; favori (Star 22 `#697586`, "Favorilere ekle"); Kapat; gövde (dolgu 12/24/0): EksikTag "Eksik", tanım `bodyReading` (12 altta), ExampleBox (12 altta); `primary` "Öğrendim" yalnız kart eksikse; ilk "Öğrendim"de 8.1 onayı.
- **Kurallar ve hareket:** açılışta ilk eksik maddeye 350 ms `ensureVisible` ve madde açılır (hareketi azaltta `jumpTo`); akordeon 250; sheet 350; "Öğrendim" `success`; bilinmeyen kart durumu çizilmez; alt başlık yoksa boş metin "Bu konunun içeriği hazırlanıyor.".
- **Veri:** `GET /student/getSubSubjects?mainSubjectId` + `POST /student/getItems {subjectIds, type}` → subSubjects, itemsArray (itemData, statusArray). "Öğrendim" → `learnedItem?itemId` ya da `learnedCard?item` (hangisi belirtilmemiş; §6.3). Favori → `GET /student/addFavoriteMobil?item`.
- **Açık madde:** madde başına kart durumu sunucuda varsa alt başlığa "4 kartın 3'ü öğrenildi" satırı eklenebilir.
- **Koyu (7.6; mağaza karesi 6):** kart `#121D31`; ExampleBox `#18263D`; gövde `#EDF1F6` 16/26; EksikTag `#33270F` / `#F2C46D`; numara rozeti `#213049`; ayraç `#26354D`; BottomBar koyu, Derslerim aktif.

#### 7.4 Edebiyat · Yazar ve Eserler · `/lessons/:edebiyatId?section=authors`
- **Kod:** `edebiyat_lesson_detail_page.dart`.
- **Düzen:** başlık (y=102): Edebiyat karosu (`#F6E7EC` / `#8A2F4E`, Feather) + 24/32 "Türk Dili ve Edebiyatı"; `SmapSegmented` (y=158, "Bölüm") "Konular" · "Yazar ve Eserler" (seçili; `edebiyat_section`); yazar kartı (y=218) `SmapAuthorRow`'lar: NK Namık Kemal (Tanzimat) · Ş Şinasi (Tanzimat) · ZP Ziya Paşa (Tanzimat) · TF Tevfik Fikret (Servet-i Fünun) · HZ Halit Ziya Uşaklıgil (Servet-i Fünun) · MA Mehmet Akif Ersoy (Millî Edebiyat Dönemi). "Konular" seçiliyken 7.2 konu listesi (Eksiklerim + sayaçlı kategori segmenti dahil) gösterilir [Karar].
- **AuthorSheet (full):** başlık avatar 56 (baş harf 17·700) + 20/28 "Namık Kemal" + 13/20·600 `#556173` "Tanzimat" + Kapat; gövde (dolgu 16/24/0): 17/24 "Hakkında" + `bodyReading` (4 altta) "Tanzimat Dönemi'nin şair ve yazarı; "vatan şairi" olarak bilinir. Edebiyatı toplumu eğitmenin aracı olarak gördü."; 17/24 "Eserleri" (16 altta); gruplar (8 altta): tür 13/20·700 `#556173` + eserler `bodyReading` " · " ile: "Roman": "İntibah · Cezmi"; "Tiyatro": "Vatan yahut Silistre · Gülnihal · Akif Bey · Zavallı Çocuk · Kara Bela · Celaleddin Harzemşah"; `primary` "Öğrendim".
- **Veri:** `GET /student/yazarEserMainSubjects`, `GET /student/getSubjectAuthors?itemId`, `learnedItem`; fotoğraflar `assets/authors` (38 MB); fotoğraf null olabilir (T5.7).
- **Koyu:** token (Edebiyat `#301A27` / `#E494BE`).

#### 7.5 Derslerim ve Konular · Durumlar
1. **İskelet (Derslerim):** bant ve segment hemen; kart y=194, dolgu 4/16; 6 satır × 72: 40 × 40 (radius 12) + 18 yükseklik çizgi (genişlik 120/90/140/110/100/80).
2. **Süzgeç boş (Tarih · Eksiklerim · SOS-2):** kart y=286: "Bu süzgeçte gösterilecek konu yok" / "SOS-2'de eksik konun yok. Tüm SOS-2 konularını görmek için süzgeci kapat." / `text` "Süzgeci Kapat".
3. **Hata (konu detayı):** y=240: "Konu yüklenemedi" / "Bağlantını kontrol edip tekrar dene." / "Tekrar Dene"; geri her zaman açık.
4. **Çevrimdışı:** bant köşeleri düzleşir; şerit bandın altında akışta; kart y=254; Web'de dersler gizli.
- Boş metinler: ders detayı Eksiklerim "Bu süzgeçte gösterilecek konu yok."; konu detayı "Bu konunun içeriği hazırlanıyor.". Hata ve çevrimdışı haptiksiz.

### 4.G Kart destesi (SMAP-08, Tur 5)

#### 8.1–8.2 Kart Destesi · `/lessons/deck?lessonId=&examId=&group=` · `CardDeckScreen`
- **Kod:** `my_card_lesson_detail_page.dart` (failedCards / successCards / favoriteCards), `my_cards_detail_page.dart` (CardSwiper) → tek ortak deste.
- **Girişler:** 7.2 "Kartlarım", 5.6 ve 5.7 "Kartları Çalış" (deneme kartları), 7.3 kart. Alt çubuk görünür, Derslerim seçili [Ç-61].
- **Düzen:** geri; 24/32 "Tarih Kartları" (y=102; deneme girişinde [Karar] "Deneme Kartları"); `SmapSegmented.counter` (y=150, "Kart grubu"): "Eksiklerim"/"23 kart" · "Bildiklerim"/"41 kart" · "Favorilerim"/"6 kart" (boşsa "kart yok"); `SmapSessionProgress` (y=222) "12/23"; `SmapCardDeck` (ön kart y=258, yan 16; arka kart 1 y=270 yan 28; arka kart 2 y=282 yan 40; 380 yükseklik); eylemler (y=676): `secondary` "Detay" (120) + `primary` "Öğrendim".
- **Ön kart örneği:** Tarih karosu 28 (Bank 15) + "Tarih"; favori; "Edirne-Segedin Antlaşması (1444)"; gövde; EksikTag "Eksik".
- **İlk Öğrendim (ConfirmSheet normal):** gövde dolgu 20/24/0: "Kartı Bildiklerim'e taşıyalım mı?" / ""Edirne-Segedin Antlaşması (1444)" eksiklerinden çıkıp Bildiklerim'e geçecek." (8 altta) / `SmapCheckbox` "Bir daha sorma" (8 altta); eylem (üst 12): `primary` "Öğrendim" + `quiet` "Vazgeç" (odak Vazgeç'te). Seçim `card_learn_confirm_skip`.
- **Taşındı:** sayaçlar 22 · 42 · 6; oturum 13/23; sıradaki kart "Otlukbeli Savaşı (1473)"; toast "Kart Bildiklerim'e taşındı." + "Geri Al" (6 sn). Toast eylem satırının 8 üstünde [Ç-36]; eylem satırı görünür kalır.
- **Eksiklerim boş:** `SmapEmptyState.screen` (y=260): dersin kil görseli (Tarih → Sütun) 128; "Bu derste eksik kartın kalmadı." (24 altta); "Bildiklerim'deki 64 kartı tekrar etmek istersen oradan devam edebilirsin." (8 altta); `text` "Bildiklerime Geç" (12 altta); sekmeler "kart yok" · "64 kart" · "6 kart".
- **Diğer boş metinler:** Bildiklerim "Henüz öğrendiğin kart yok."; Favorilerim "Favoriye eklediğin kart yok." (deneme girişinde [Karar] görsel `clay_map`).
- **Etkileşim:** §C52 (kaydırma yalnız sonraki karta; öğrenme yalnız düğmeyle; iyimser güncelleme; Geri Al 6 sn; hareketi azaltta çapraz geçiş; `customActions`). "Detay" → `SmapCardSheet` [Karar]. Bildiklerim'de yalnız "Detay".
- **Veri:** `GET /student/getLessonInfoCards?lesson` → failedCards / successCards / favoriteCards [{item{_id, name, desc, mainSubject}, favorite}]; `GET /student/learnedCard?item`; `GET /student/addFavoriteMobil?item`; deneme girişinde `getMexamItemDetail`. Oturum sayacı açılıştaki eksik sayısıyla başlar (T5.4). Geri Al için geri alma ucu yok (§6.3 #24).
- **Koyu (8.2; mağaza karesi 6):** kart `#121D31`, metin `#EDF1F6`; sürüklenen kart gölgesi `#000` %56 (token; pano %40); arka kart 1 `shadowRaised` koyu; oturum dolgusu `#FF8533`; Tarih karosu `#2C2513` / `#E3B651`; Star `#6B7D97`; EksikTag `#33270F` / `#F2C46D`; arka kartlar opaklık %50 ve %75.


### 4.H Hesap (SMAP-09, Tur 8)

Koyu panosu yok; token'la türetilir (gruplar `#121D31`, kanvas `#0A1424`, ayraç `#26354D`, ikon/alt metin `#A9B5C6`, tehlikeli `#FF8F8F`, girdi `#121D31` + `#6B7D97`, salt okunur `#213049`, odak `#9BB3D3`, sheet `#18263D`). **Ödeme, paketler, kayıtlı kartlar, faturalar, paywall v1'de yok** (D-4): `lib/features/profile/presentation/screens/payment_settings/**`, `.../saved_cards/**`, `AccountRoute.payment`/`savedCards` ve `AccountFlowScreen` case'leri kalkar.

#### 9.1 Hesap · `/account` (koç `/coach/account`) · `AccountScreen`
- **Öğrenci üst (kare 1):** `SmapRootBand` "Hesap" + `SmapProfileSummary` (av-1 56, "Alparslan Kuloğlu", "12. Sınıf · Eşit Ağırlık", "Koçun: Mehmet Özkan"; bant ≈206; içerik top 222). Gruplar (aralık 20):
  - "Hesap": [UserCircle] "Profil" / "Ad, e-posta, telefon, sınıf ve alan" ›; [Lock] "Şifre" ›
  - "Koçluk": [Users] "Koçluk" / "Mehmet Özkan" › (koç yoksa [Karar] alt metin "Koçunla bağlan")
  - "Bildirimler": [Bell] "Bildirimler" / "Deneme sonucu, koç, görüşme, hatırlatıcı" ›
  - "Yasal": [FileText] "Sözleşmeler" / "Kullanım Koşulları, KVKK, Gizlilik" ›
- **Alt (kare 2, kaydırılmış; bant 110):** "Destek": [Envelope] "Bize Yaz" / "E-posta uygulaman açılır" + ArrowSquareOut 20; başlıksız grup [SignOut] "Çıkış Yap" (danger, oksuz); en altta ortalı 13/20 `#556173` "Sürüm 3.0.0 (300)" (uzun basınca kopyalanır).
- **Çıkış onayı (normal ConfirmSheet):** "Çıkış yapılsın mı?" / "Tekrar girmek için kullanıcı adın ve şifren gerekecek. Okuttuğun denemeler hesabında kalır." (bekleyen gönderim varsa "Gönderilmeyi bekleyen 1 form var; çıkarsan silinir.") / `primary` "Çıkış Yap" + `quiet` "Vazgeç" → `/ajax/logout` → `/welcome`.
- **Koç (kare 4):** ProfileSummary av-2, "Mehmet Özkan", "Öğrenci koçu", "Koçluk kodun: MOZK-4821" (okunuş "Profil: Mehmet Özkan, öğrenci koçu, koçluk kodu MOZK-4821"). "Hesap" grubu: Profil ([Karar] alt metin "Ad, e-posta ve telefon" [Ç-46]), Şifre. "Koçluk" grubu: dokunulamayan satır [Users] "Koçluk kodun" + kod 15/24·700 harf aralığı 0,5 "MOZK-4821" + iki 48 ikon düğmesi Copy 22 ("Kodu kopyala") ve ShareNetwork 22 ("Kodu paylaş", sağ −12). Bildirimler, Yasal, Destek, Çıkış, sürüm öğrenciyle aynı (T8.10). Alt çubuk koç seti.
- **Etkileşim:** ProfileSummary/Profil → 9.2; Şifre → 9.3; Koçluk → 9.5 (öğrenci); Bildirimler → 9.6; Sözleşmeler → 9.7; Bize Yaz → `mailto:` taslağı (sürüm + cihaz bilgisi; adres belirtilmemiş); Kopyala → toast "Kod kopyalandı."; Paylaş → sistem paylaşımı.
- **Veri:** ad, avatar, sınıf, alan (oturum/`UserProvider`); koç adı `/student/getStudentsCoach`; koçluk kodu koç profilinden (`refCode`); sürüm `package_info_plus`; bekleyen form sayısı (v1 kuyruk yok → 0).
- Kırmızı yalnız Çıkış satırında; onay düğmesi lacivert (T8.9). Hesabı Sil burada yok (Profil'in altında).

#### 9.2 Profil · `/account/profile` · `ProfileScreen` (view/edit) + `AvatarSheet`, `GradeSheet`, `FieldSheet`
- **Görüntüleme:** geri + `SmapBarAction` (PencilSimple) "Düzenle"; 24/32 "Profil" (top 110); form (top 158, aralık 16): av-1 72 + `text` "Avatarı Değiştir" (sol −12, aralık 16); salt okunur alanlar: "Ad Soyad"="Alparslan Kuloğlu"; "Kullanıcı adı"="alparslan.k" + Lock; "E-posta"="alparslan@ornek.com"; "Telefon"="+90 5XX XXX XX XX"; "Sınıf"="12. Sınıf"; "Alan"="Eşit Ağırlık"; en altta ayraç (8 altta) + `textDanger` (Trash 20, sol −12) "Hesabı Sil" → `/account/delete`.
- **Düzenleme:** sol `text` "Vazgeç" (top 54, left 4); sağ dolu BarAction "Kaydet" (değişiklik yoksa pasif); Ad Soyad, E-posta normal alan; Kullanıcı adı salt okunur + yardım "Kullanıcı adı değiştirilemez."; Telefon maskeli (+90, sayı klavyesi); Sınıf, Alan `SmapSelectField`. Başarı → görüntüleme + toast "Profilin güncellendi."; hata → form korunur + toast "Kaydedilemedi. Bağlantını kontrol edip tekrar dene."; Vazgeç + değişiklik → normal ConfirmSheet "Değişiklikler kaydedilmesin mi?" ([Karar] gövde "Yaptığın değişiklikler silinecek.", düğmeler "Kaydetmeden Çık" / "Vazgeç"). E-posta değişirse yeni adrese 6 haneli kod (2.4 CodeInput; ekran çizilmemiş — [Karar] `SmapBottomSheet.full` içinde 2.4 kod adımı); doğrulanana kadar eski adres geçerli.
- **Avatar sheet (medium):** "Avatarını seç" / "7 avatar" + Kapat; `SmapAvatarPicker.sheet`; `primary` "Bu Avatarı Kullan" (seçim Kaydet ile kalıcı).
- **Sınıf sheet (small):** "Sınıf" + Kapat; radyo satırları (dolgu 12/24) "9. Sınıf", "10. Sınıf", "11. Sınıf", "12. Sınıf" (seçili), "Mezun"; altında 13/20 `#556173` (dolgu 8/24/0) "9. ya da 10. sınıfı seçersen alan kaldırılır."; alt boşluk 42; seçince kapanır.
- **Alan sheet (çizilmemiş, aynı kalıp):** "Alan": Sayısal, Eşit Ağırlık, Sözel, Dil; 9.–10. sınıfta Alan pasif "Seçilmez".
- **Koç:** Sınıf ve Alan yok.
- **Veri:** yalnız değişen alanlar (PATCH; bugün POST `/student/updateStudent`); e-posta doğrulama ucu yok; avatar id → `photo` dosya adı.

#### 9.3 Şifre · `/account/password` · `PasswordScreen`
- Geri; 24/32 "Şifre"; form (top 166, aralık 20): "Mevcut şifre", "Yeni şifre" (yardım "En az 8 karakter."), "Yeni şifre (tekrar)" — üçü `password` varyantı; `primary` "Şifreyi Güncelle" (yükleniyor varyantı; alanlar dolmadan pasif `.bp.off` — 9.3 panosu, kit 1.9 "pasif yerine doğrulama" kuralının istisnası).
- **Hatalar:** "Mevcut şifren doğru değil." (alan hata; odak orada; yeni şifreler korunur); "Yeni şifre eskisiyle aynı olamaz."; "Şifreler aynı değil.".
- **Başarı:** 9.1'e dön + toast (success ikonu) "Şifren güncellendi." + `success`; bu cihaz açık kalır, diğer oturumlar kapanır. "Şifremi unuttum" bağlantısı yok.
- **Veri:** şifre değiştirme ucu yok (bugün sahte SnackBar) → yeni uç.

#### 9.4 Hesabı Sil · `/account/delete` → `/account/delete/progress` → `/account/delete/done`
- **Giriş:** Profil'in en altı (9.4 kare 1: bar opak 102 + "Profil" 17/24 + "Düzenle"; Telefon, Sınıf, Alan; ayraç; "Hesabı Sil").
- **Açıklama ekranı (alt çubuklu):** geri; 24/32 "Hesabını sil"; 16/24·600 "Hesabını silersen:" (16 altta); liste (12 altta, aralık 12, 16/24; her madde X 18 (çizgi 22) `#C42D35` + 10 aralık): "Okuttuğun 10 deneme ve analizleri silinir." · "Eksik konuların, programların ve bilgi kartı ilerlemen silinir." · "Koçun Mehmet Özkan ile bağlantın kalkar." (koç yoksa [Karar] gizli) · "Bu işlem geri alınamaz."; 15/24 `#556173` (20 altta) "Yalnız bir süre ara vermek istiyorsan çıkış yapman yeterli; verilerin hesabında kalır."; alta sabit (bottom 118, yan 16, aralık 12) `danger` "Hesabımı Sil" + `quiet` "Vazgeç".
- **Tehlikeli onay:** "Hesabın silinsin mi?" / "Alparslan Kuloğlu hesabı ve bütün verilerin kalıcı olarak silinecek. Bu işlem geri alınamaz." / `danger` "Hesabımı Sil" + `quiet` "Vazgeç" (odak). Kelime yazdırma ve yeniden kimlik doğrulama yok (D-28).
- **Siliniyor (root, tam ekran, geri kapalı):** `SmapStatusView.busy` top 300: spinner 48; "Hesabın siliniyor" 20/28 (24 altta); "Uygulamayı kapatma." 15/24 `#556173` (6 altta); `role=status`. Hata → açıklama ekranına dönüş + [Karar] `SmapNoticeBox.error` "Hesabın silinemedi. Bağlantını kontrol edip tekrar dene." (düğmelerin üstünde) + `error`.
- **Silindi:** `SmapStatusView.blocking` top 220: 96 `#E4F4EA` + CheckCircle 48 `#0B6E3E`; 24/32 "Hesabın silindi" (28 altta); 16/24 `#556173` "Verilerin silindi. İstersen yeni bir hesapla yeniden başlayabilirsin." (10 altta); `primary` "Tamam" (bottom 42, yan 24) → `/welcome`. Oturum kapanır; haptik yok.
- **Davranış:** `/ajax/deleteAccount`, idempotent; bekleyen form kuyruğu temizlenir; koça bildirim gitmez; yasal saklama sunucu kuralı. Deneme sayısı sunucudan (T8.7). Koç için akış belirtilmemiş ([Karar] aynı akış; 3. madde "Öğrencilerinle bağlantın kalkar.").
- **Koyu:** danger `#FF8F8F` / `#3B0A10`; daire `#3B1D22` / `#FF8F8F`; X ikonları `#FF8F8F`; başarı `#15301F` / `#52CC8E`; spinner `#34445F` / `#C5D4E8`.

#### 9.5 Koçluk · `/account/coaching` · `CoachingScreen` (yalnız öğrenci)
- **Koçu var:** geri; 24/32 "Koçluk"; içerik top 158, aralık 16: `SmapCoachCard` (av-2 64, "Mehmet Özkan", "Koçun", ayraç, "Sıradaki görüşme", "12 Ekim 2026 Pazartesi · 16:00" [Ç-41]); `SmapNoticeBox.info` "Mehmet Özkan denemelerini, analizlerini ve programını görebilir."; `textDanger` "Bağlantıyı Kaldır" (sol −12).
- **Kaldır onayı (danger):** "Koç bağlantısı kaldırılsın mı?" / "Mehmet Özkan gelişimini artık göremeyecek. Yeniden bağlanmak için koçluk kodunu tekrar girmen gerekir." / "Bağlantıyı Kaldır" + "Vazgeç" → toast "Koç bağlantın kaldırıldı." → koçu yok hâli.
- **Koçu yok:** aralık 20: 16/24 `#556173` "Koçunun verdiği kodu gir; koçun denemelerini, analizlerini ve programını görebilsin."; "Koçluk kodu" (`masked` `AAAA-0000`, örnek "MOZK-4821"; yardım "4 harf ve 4 rakam; tire kendiliğinden gelir."); `primary` "Koça Bağlan"; `text` (Question 20, margin −8 0 0 −12) "Koçluk Kodu Nedir?". Hata "Bu kodla bir koç bulunamadı. Kodu koçundan yeniden iste."; başarı toast "Mehmet Özkan'a bağlandın." (ek uyumu) → koçu var hâli.
- **"Koçluk kodu nedir?" sheet (small, Kapat ve ikon yok):** dolgu 20/24/0: "Koçluk kodu nedir?"; iki paragraf `bodyReading` (10 altta): "Koçluk kodu, koçunun SMAP hesabına özel koddur; dört harf ve dört rakamdan oluşur." / "Kodu koçundan iste. Girdiğinde koçun denemelerini, analizlerini ve programını görebilir. Bağlantıyı istediğin an buradan kaldırabilirsin."; `primary` "Tamam".
- **Veri:** `/student/getStudentsCoach`; `/student/addCoach?code=`; `/student/deleteCoach` (bugün `queryParams` isteğe eklenmiyor — düzeltilmeli); sıradaki görüşme kaynağı yok (§6.3 #15).
- **Koyu (1.24 kare 4 çizili):** sheet `#18263D`; ikon dairesi `#3B1D22` / `#FF8F8F`; gövde `#A9B5C6`; danger `#FF8F8F` / `#3B0A10` (7,74); Vazgeç `#213049` / `#EDF1F6`, halka 2 `#18263D` + 4 `#9BB3D3`.

#### 9.6 Bildirimler · `/account/notifications` · `NotificationsScreen` + `TimeWheelSheet`
- **Ayarlar:** geri; 24/32 "Bildirimler"; içerik top 158, aralık 20: `SmapNoticeBox.info` "Bildirimler planlı: tercihlerin şimdiden kaydedilir, bildirimler açıldığında bunlara göre gelir."; grup "Kategoriler" (ikonsuz satırlar + Switch, hepsi açık): "Deneme sonucun hazır" / "Okuttuğun denemenin analizi bitince" · "Koçun deneme ya da ödev atadı" / "Mehmet Özkan yeni bir şey atadığında" · "Görüşme planlandı" / "Koçun bir görüşme planladığında" · "Çalışma hatırlatıcısı" / "Programındaki çalışmanın saatinde"; grup "Sessiz saatler": [Clock] "Sessiz saatler" / "Bu saatlerde bildirim gelmez" + Switch; "Başlangıç" — "22:00" ›; "Bitiş" — "08:00" › (ikon yeri gizli); altbilgi 13/20 `#556173` (margin −8 4 0) "Değişiklikler anında kaydedilir.". Kaydet düğmesi yok.
- **Sistem izni kapalı:** InfoBox yerine `SmapNoticeBox.warning` (`role=alert`) "Bildirim izni kapalı. Telefonunun ayarlarından SMAP'e izin verirsen bu tercihler geçerli olur." + `text` "Ayarları Aç" (`openAppSettings`); bütün anahtarlar pasif açık (`#DCE2E9`), başlıklar `#697586`; Başlangıç/Bitiş normal renk.
- **Saat sheet'i:** "Sessiz saat başlangıcı" (bitiş için [Karar] "Sessiz saat bitişi") + Kapat; `SmapTimeWheel` (20 · 21 · **22** · 23 · 00 / 50 · 55 · **00** · 05 · 10); `primary` "Kaydet".
- **Davranış:** varsayılanlar hepsi açık, sessiz saatler açık 22:00–08:00 (D-24); anahtar değişince anında PUT; hata → anahtar geri + toast ([Karar] "Kaydedilemedi. Bağlantını kontrol edip tekrar dene."); sessiz saatler kapalıyken Başlangıç/Bitiş gizli; izin `permission_handler`, uygulama öne gelince yeniden okunur; izin burada istenmez (5.2). Kategori 2 alt metni koç adını kullanır (koç yoksa [Karar] "Koçun yeni bir şey atadığında").
- **Koç:** kategoriler çizilmemiş ([Karar] "Görüşme hatırlatıcısı" / "Görüşmeden 1 saat önce" + sessiz saatler; T9.8).
- **Veri:** tercih ucu yok → yeni uç; push altyapısı kapalı (T8.4). `notification_toggle_tile.dart` yeniden yazılır.
- **Koyu:** Switch açık `#C5D4E8` + `#091A31`; WarningBox `#33270F` / `#F2C46D`; çark bandı `#213049`.

#### 9.7 Sözleşmeler · `/account/agreements`, `/account/agreements/:docId` · `AgreementsScreen`, `AgreementReader`
- **Liste:** geri; 24/32 "Sözleşmeler"; içerik top 158, aralık 12: tek grup, satırlar FileText 24 + ›: "Kullanım Koşulları" / "Sürüm 1.2 · 1 Eylül 2026" · "KVKK Aydınlatma Metni" / "Sürüm 1.1 · 1 Eylül 2026" · "Gizlilik Politikası" / "Sürüm 1.1 · 1 Eylül 2026"; altbilgi 13/20 `#556173` (margin 0 4) "Kayıt olurken bu sürümleri onayladın. Bir metin değişirse uygulama açılışında yeni sürümü onaylaman istenir.".
- **Okuma:** bar kısa hâlde (`#F2F4F7`, geri + 17/24 "Kullanım Koşulları"); gövde top 118: 13/20 `#556173` "Sürüm 1.2 · Yürürlük 1 Eylül 2026"; bölüm başlıkları 17/24·700 (margin 20 0 6); paragraflar `bodyReading` (margin 0 0 10). Örnek: "1. Taraflar ve konu" — "Bu koşullar, SMAP uygulamasını kullanan öğrenci ve koçlar için geçerlidir. Uygulamayı kullanarak bu koşulları kabul etmiş olursun."; "2. Hesabın" — "Hesabının güvenliğinden sen sorumlusun. Kullanıcı adını ve şifreni kimseyle paylaşma; paylaşıldığını düşünürsen şifreni değiştir."; "3. Okutulan formlar" — "Okuttuğun optik formların görüntüsü yalnız sonucunu hesaplamak için işlenir. Ayrıntılar KVKK Aydınlatma Metni'nde.". Metin uygulama tipografisiyle (web görünümü değil; `flutter_html` ile başlık/paragraf eşlemesi [Karar]).
- **Veri:** `/ajax/getLegalDocuments` (name, title, version, content, isActive; tarih alanı yok — §6.3 #13). Yeni sürüm onayı açılışta (bu grupta değil). `contract_card.dart` değişir. Durumlar 1.22 kalıbı.

### 4.I Koç modu (SMAP-10, Tur 9)

Koyu panosu yok (token). Bütün öğrenci ekranları koçta `SmapStudentScope(coachView: true)` ile, salt okunur.

#### 10.1 Koç Anasayfa · `/coach/home` · `CoachHomeScreen`
- **Bant:** `SmapHomeBand.coach`: av-2 40 + "Merhaba, Mehmet" + "5 öğrenci · önümüzdeki 7 günde 2 görüşme". İçerik top 182, bölümler arası 28.
- **Öğrencilerin:** `SmapSectionHeader` "Öğrencilerin" + `text` (Plus 20) "Öğrenci Ekle" (10.3 sheet); `SmapStudentTile` şeridi: "Alparslan Kuloğlu" + "Son deneme 5 Eki." · "Elif Şahin" · "Kerem Aydın" · "Mert Yıldız" · "Zeynep Kaya".
- **Dikkat gerektirenler:** `SmapSectionHeader` "Dikkat gerektirenler"; boşken §C33 boş kartı; dolu (kare 2) `SmapAttentionRow`'lar: [Clock] "Alparslan Kuloğlu" / "45 gündür deneme okutmadı" / "Son deneme 17 Haz. 2026 · TYT"; [TrendDown] "Alparslan Kuloğlu" / "Son iki TYT denemesinde net düştü" / "68 → 66,75 · 17 Haz. ve 4 Ağu." (iki ayrı günün görünümü; T9.1). Okunuş "Alparslan Kuloğlu, 45 gündür deneme okutmadı, son deneme 17 Haziran".
- **Yaklaşan görüşmeler:** `SmapSectionHeader` "Yaklaşan görüşmeler"; kart içinde `SmapMeetingRow.dateBlock`: "12 Eki." "Alparslan Kuloğlu" / "Pazartesi 16:00 · Öğrenci"; "15 Eki." "Elif Şahin" / "Perşembe 19:30 · Veli". ([Karar] görüşme yoksa bölüm kartı "Önümüzdeki 7 günde görüşme yok." + `text` "Yeni Görüşme".)
- **Öğrencisi yok (kare 3):** bant alt satırı "Henüz öğrencin yok"; içerik top 190, aralık 16: `SmapAvatarStack` boş durum (av-1, av-4, av-3; 72, −16 bindirme, 4 pt `#F2F4F7` halka); "İlk öğrencini ekle" 20/28 (20 altta); "Öğrencin koçluk kodunla kendi hesabından bağlanabilir ya da hesabını sen açabilirsin." 15/24 `#556173` (6 altta); `primary` (Plus) "Öğrenci Ekle"; `SmapCodeCard`.
- **İskelet (kare 4):** bant hemen; 140 × 24 başlık; üç tile (48 daire + 70 × 14); 190 × 24; 88 kart; 180 × 24; 128 kart; aralık 14. Bölüm hataları kendi yerinde ([Karar] "Öğrenciler yüklenemedi.", "Dikkat listesi yüklenemedi.", "Görüşmeler yüklenemedi.").
- **Kurallar (D-27):** iki kural: 14+ gün deneme yok; aynı türde son iki denemede net düşüşü. Hedef, ödev tamamlama, giriş sıklığı yok. Sunucuda hesaplanır (her gece + her okumada; `last_exam_at ≤ now − 14 gün`), kanıt alanlarıyla.
- **Gezinme:** §3.6. Kopyala → "Kod kopyalandı."; Paylaş → sistem.
- **Veri:** `/coach/getMyStudents` (`Student.totalMexam` var; son deneme tarihi ve son net eklenmeli); dikkat listesi yeni uç; `/coach/getInterviews` (`filter.dates`, sayfalama); bant sayaçları.

#### 10.2 Öğrencilerim · `/coach/students` · `StudentsScreen`
- **Liste:** `SmapRootBand` "Öğrencilerim" + Plus ("Öğrenci ekle"); `SmapSearchField` "Öğrenci ara" (top 150); sayaç (top 210, sol 20) 13/20·600 `#556173` "5 öğrenci"; kart (top 238) `SmapStudentRow`'lar: "Alparslan Kuloğlu" / "12. Sınıf · Eşit Ağırlık · 10 deneme" + "67,5" "son net"; "Elif Şahin" / "11. Sınıf · Sayısal"; "Kerem Aydın" / "Mezun · Sözel"; "Mert Yıldız" / "10. Sınıf"; "Zeynep Kaya" / "12. Sınıf · Eşit Ağırlık". Alfabetik (Türkçe).
- **Arama:** "aydin" → "1 öğrenci" → "Kerem **Aydın**" (vurgu); "AYDIN" ve "aydın" aynı sonuç.
- **Sonuç yok:** kart (top 214, dolgu 24/16/12, ortalı): 16/24·700 "“selin” ile eşleşen öğrenci yok"; 13/20 `#556173` "Ad ve soyadda arar; büyük-küçük harf ve I/ı/İ/i farkı gözetmez."; `text` "Aramayı Temizle".
- **Öğrenci yok:** içerik top 200, yatay 24: üç avatar; "Henüz öğrencin yok" (24 altta); "Öğrencinin hesabını sen aç ya da koçluk kodunu paylaş; bağlanan öğrenciler burada listelenir." (8 altta); düğmeler (24 altta, aralık 12) `primary` (Plus) "Öğrenci Ekle" + `secondary` (ShareNetwork) "Kodunu Paylaş".
- **Veri:** `/coach/getMyStudents` (ad, soyad, avatar, sınıf, alan, deneme sayısı, son net). 50'den fazla öğrencide arama sunucuda. Durumlar 1.22 kalıbı.

#### 10.3 Öğrenci Ekle (full sheet) · `AddStudentSheet` + `CredentialsSheet`
- **Form:** "Öğrenci ekle" / "Hesabını sen aç ya da kodunu paylaş." + Kapat; içerik (dolgu 12/24/0, aralık 16): iki sütun (aralık 12) "Ad"="Zeynep", "Soyad"="Kaya"; "Kullanıcı adı"="zeynep.kaya" + `SmapBarAction.inline` "Kontrol Et" (sonuç "Bu kullanıcı adı boşta."); "Şifre" (maskeli + Eye) + inline "Oluştur" + yardım "Öğrencine ilet; ilk girişte değiştirmesi önerilir."; iki sütun `SmapSelectField` "Sınıf"="12. Sınıf", "Alan"="Eşit Ağırlık"; `primary` "Öğrenciyi Kaydet". Ayraç bölümü (dolgu 20/24/0): iki çizgi arasında 13/20·600 `#556173` "ya da"; 16/24·600 (margin 16 0 8) "Öğrencin kendi hesabıyla bağlansın"; `SmapCodeCard`; alt boşluk 42.
- **Kaydırılmış (kare 2):** Sınıf/Alan, kaydet, "ya da", CodeCard görünür.
- **Eklendi (CredentialsSheet):** "Zeynep Kaya eklendi" / "Giriş bilgilerini öğrencine ilet." + Kapat; (dolgu 16/24/0, aralık 16) "Kullanıcı adı"="zeynep.kaya" (salt okunur); "Şifre" maskeli + Eye; yardım "Bu ekranı kapatınca şifre yeniden gösterilmez."; `primary` (ShareNetwork) "Bilgileri Paylaş" + `quiet` "Tamam" → listeye dön + toast "Zeynep Kaya eklendi.".
- **Kurallar:** Ad ve Soyad ayrı; kullanıcı adı "Kontrol Et" ya da 400 ms canlı kontrol, kural harf/rakam/nokta/alt çizgi + küçük harf (T7.4), alınmışsa "Bu kullanıcı adı alınmış." + öneri çipi (2.6 kalıbı); "Oluştur" 10 karakter okunur şifre (I, l, 0, O yok); 9.–10. sınıfta Alan pasif; zorunlu alanlar dolunca çalışır, hata alanın altında; gönderimde sheet meşgul durumu; kayıtlı öğrenci koça bağlı gelir.
- **Backend:** `/ajax/checkUsername?name=`, `/coach/addNewStudent` (Mezun `seasonType 13`?). `add_student_dialog.dart` bu sheet ile değişir.
- **Koyu:** sheet `#18263D`; başarı satırı `#52CC8E`.

#### 10.4 Öğrenci Profili (koç bağlamı) · `/coach/students/:studentId?tab=` · `StudentProfileScreen`
- **Üst:** `SmapDetailBar` (geri + BarAction CalendarBlank "Görüşme Planla" → NewMeetingSheet öğrenci seçili); `SmapContextStrip` (top 102): av-1 24, "Alparslan Kuloğlu'nun verileri", "12. Sınıf · EA"; başlık (top 154) 24/32 "Alparslan Kuloğlu" + meta "alparslan.k · 10 deneme · son 5 Eki. 2026"; `SmapTabBar` (top 214) "Analiz" (52) · "Denemeler" (84) · "Program" (70).
- **Analiz (6.1 aynısı):** `SmapFilterPill` "TYT · Genel" + "6 deneme"; grafik kartı (top 330) NetChart 338 × 200 (X etiketleri 22 Nis. · 17 Haz. · 15 Eyl. · 28 Eyl.); StatBox ızgarası (top 618): "6" Çözülen deneme · "67,79" Ortalama net "+3,25 son denemede" (`delta`) · "381,40" Ortalama puan · "182.430" Ortalama sıralama.
- **Denemeler (6.2 satırları):** 13/20 "10 deneme · en yeni önce"; `SmapExamRow` (favorisiz): "Türkiye Geneli Deneme 6" AYT 5 Eki. 2026 Örnek Yayınları 86/74/0 67,5 · "TYT Genel Deneme 9" TYT 28 Eyl. 2026 80/21/19 74,75 · "AYT denemesi" 21 Eyl. 2026 59,25 · "TYT denemesi" 15 Eyl. 2026 71,5 · "TYT denemesi" 4 Ağu. 2026 66,75. Satır → koç Deneme Detay.
- **Program (3.4 gün görünümü, salt okunur):** 17/24 "Ekim 2. Hafta" / "Her gün biraz daha · 5–11 Ekim 2026"; DayChip şeridi (Pzt 5 … **Cmt 10** … Paz 11; seçili bugün, "10 Ekim, bugün"); ProgramItemRow'lar 10:00 Türkçe "Fiilde Çatı" · 14:00 Tarih "Kurtuluş Savaşı Hazırlık Dönemi" · 20:00 Coğrafya "İklim Bilgisi"; `SmapNoticeBox.info` "Programı Alparslan düzenler; sen görüntülersin." ([Karar] ad ilk addan); "Günü Sıfırla" ve "Düzenle" yok. ([Karar] Hafta görünümü segmenti de gösterilir, salt okunur.)
- **Deneme Detay (kare 4, 5.3 aynen):** ContextStrip barın altına girer, içerik 40 aşağı; bar eylemi yok; başlık, net, D/Y/B, puan kartı, sekmeler, test satırları ("Türk Dili ve Edebiyatı–Sosyal Bilimler 1" 18,75 · 23/17/0 · 40 soru; "Sosyal Bilimler 2" 11,25 · 17/23/0 · 40 soru).
- **Taşıma kuralı:** 6.1 → Analiz, 6.2 → Denemeler, 3.4 → Program, 5.3–5.7 → deneme ve soru detayı; farklar yalnız bağlam şeridi, düzenleme eylemlerinin olmaması ve öğrenciye özel öğelerin gizlenmesi.
- **Backend:** `getLineChartData`, `getTotal`, `getMyMockExams`, `getMyWeeklies`, `getMexamSubjectDetail`, `getMexamItemDetail`, `getQuestion` koç adına `studentId` ile — desteği belirtilmemiş (§6.3 #33).
- **Koyu:** ContextStrip `#1A2B45`; sekme göstergesi `#FF8533`; grafik koyu; delta `#9BB3D3`; D/Y/B koyu; ders renkleri koyu.

#### 10.5 Görüşmelerim · `/coach/meetings`, `/coach/meetings/:meetingId` · `MeetingsScreen`, `NewMeetingSheet`, `MeetingDetailScreen`
- **Liste:** `SmapRootBand` "Görüşmelerim" + Plus ("Yeni görüşme"); `SmapSearchField` "Görüşme ara" (öğrenci adında, tr katlama); "Kiminle" radiogroup (top 210, aralık 8, `SmapChip.md` tek seçim): "Tümü" (seçili) · "Öğrenci" · "Veli"; bölüm başlığı "Yaklaşan · 2" (top 266); `SmapMeetingRow.list`: "Alparslan Kuloğlu" / "12 Ekim 2026 Pazartesi · 16:00" + "Öğrenci" ›; "Elif Şahin" / "15 Ekim 2026 Perşembe · 19:30" + "Veli" ›. Geçmiş görüşmeler ayrı başlık altında, en yeni önce ([Karar] başlık "Geçmiş · N").
- **Yeni görüşme sheet'i (full):** "Yeni görüşme" + Kapat; (dolgu 12/24/0, aralık 16): "Öğrenci" `SmapSelectField` (avatar 28 + "Alparslan Kuloğlu"; öğrenci seç sheet'i); "Kiminle" `SmapSegmented` "Öğrenci" (seçili) / "Veli"; iki sütun (1,4fr / 1fr, aralık 12) "Tarih"="12 Ekim 2026 Pzt" ([Karar] `SmapCalendar` tekli seçim sheet'i), "Saat"="16:00" ([Karar] `SmapTimeWheel` sheet'i); "Not (isteğe bağlı)" `SmapTextArea` (min 88, placeholder "Örn: Deneme sonucunu birlikte inceleyeceğiz."); `primary` "Görüşmeyi Kaydet" ([Karar] doğrulama: öğrenci, tarih, saat zorunlu). Kaydedince listeye + toast "Görüşme kaydedildi."; öğrenciye "Görüşme planlandı" bildirimi (9.6); 1 saat önce koça hatırlatma.
- **Detay:** geri + BarAction (PencilSimple) "Düzenle" ([Karar] yeni görüşme sheet'ini dolu açar; silme bu sheet'te `textDanger` "Görüşmeyi Sil" + danger onay "Görüşme silinsin mi?"); başlık (top 110, aralık 20): avatar 56 + 24/32 "Alparslan Kuloğlu" + "Öğrenci görüşmesi" (veli: [Karar] "Veli görüşmesi"); kart: [CalendarBlank 24] "12 Ekim 2026 Pazartesi" / "16:00" (min 56, dokunulmaz); [ChartLine 24] "Öğrencinin verileri" / "Analiz, denemeler, program" › → 10.4; "Notlar" 20/28 + `text` (Plus) "Not Ekle"; not kartı (dolgu 16): `bodyReading` "Tarih eksikleri için haftada 3 saat ayrıldı." + `text` (PencilSimple) "Düzenle" ve `textDanger` (Trash) "Sil" (40, aralık 4).
- **Görüşme yok:** `SmapEmptyState.screen`: kil Hokka 128; "Henüz görüşme yok"; "Öğrencinle ya da velisiyle görüşme planladığında burada listelenir."; `primary` (Plus) "Yeni Görüşme".
- **Backend:** `/coach/getInterviews` (`filter.types`, `filter.dates`, `page`, `limit`; arama parametresi?), `/coach/addNewInterview`; `type == 1` → Öğrenci, aksi Veli. Düzenleme/silme uçları belirtilmemiş.

#### 10.6 Görüşme Notları · `NoteSheet` (medium, görüşme detayının üstünde)
- **Not ekle:** "Not ekle" / "12 Ekim 2026 · Alparslan Kuloğlu" + Kapat; `SmapTextArea` (min 120, odakta) placeholder "Örn: Deneme sonucunu birlikte inceleyeceğiz."; sayaç "0/500"; `primary` "Notu Kaydet" (metin yokken pasif).
- **Notu düzenle:** "Notu düzenle" (alt başlıksız); dolu metin, sayaç "44/500"; `primary` "Kaydet" (yalnız değişiklik varsa).
- **Silme onayı (danger; eylem üst 24):** "Not silinsin mi?" / "“Tarih eksikleri için haftada 3 saat ayrıldı.” notu silinecek." / `danger` "Notu Sil" + `quiet` "Vazgeç" (odak).
- **Silindi:** notlar kartı 15/24 `#556173` "Henüz not yok."; toast "Not silindi." + "Geri Al" (6 sn); süre dolunca kalıcı.
- **Davranış:** notlar yalnız koça (T9.7); kaydetme hatası → sheet açık, metin korunur, toast ([Karar] "Not kaydedilemedi. Bağlantını kontrol edip tekrar dene.").
- **Backend:** `/coach/addNewNote`, `/coach/editNote`, `/coach/deleteNote`; Geri Al için [Karar] silme isteği 6 sn bekletilir (istemci tarafı gecikmeli silme).
- **Koyu:** toast ters yüzey; "Geri Al" `#1A3357`.

**Rol farkları özeti:**

| Konu | Öğrenci | Koç |
|---|---|---|
| Alt çubuk | Anasayfa · Analizlerim · Okut · Derslerim · Hesap | Anasayfa · Öğrencilerim · Okut · Görüşmelerim · Hesap |
| ProfileSummary | sınıf · alan, "Koçun: …" | "Öğrenci koçu", "Koçluk kodun: …" |
| Koçluk | 9.5 ekranı | kod + Kopyala/Paylaş satırı |
| Profil | Sınıf ve Alan var | yok |
| Bildirim kategorileri | 4 kategori | görüşme hatırlatıcısı [Karar] |
| Kamera | kendi hesabına | öğrenci seçilir, sonuç onun hesabına |
| Öğrenci verisi | düzenler | salt okunur + ContextStrip; favori, Öğrendim, Günü Sıfırla yok |
| Görüşme notları | göremez | yalnız koç |


---

## 5. Akışlar (SMAP-00, Tur 10)

**Lejant (pano):** k-def ekran (beyaz kutu, içe 1 `#C3CBD6`) · k-tab kök sekme (`#0F294A`) · k-cam kamera (solda 5 pt `#FF6600` şerit) · k-dec karar (`#FCF1D9` + 1,5 `#8A5A00`) · k-sys sunucu (`#F2F4F7`) · k-ext uygulama dışı/başka akış (`#F2F4F7` + 1,5 `#9AA5B4`) · k-upd kendiliğinden güncellenir. Kutular 300 × 104, radius 16; oklar `#556173` 1,75, kesikli `6 6`.

### 5.1 Uygulamanın yolculuğu (0.1)

1. 2.1 Açılış ("Lacivert zemin, S-rota işareti") → 2.1 Tanıtım ("3 ekran: okut → analiz → eksikleri kapat") → 2.2 Rol ("Öğrenciyim ya da Öğrenci Koçuyum").
2. Öğrenci → 2.2 Sınıf ve alan ("Yalnız öğrenci; 9.–10. sınıfta alan yok") → 2.2 Kamera ön açıklaması. Koç → doğrudan Kamera ön açıklaması ("İzin ver ya da Sonra").
3. 2.2 Hoş geldin ("Kayıt Ol ya da Giriş Yap"): Kayıt Ol → 2.5·2.6 Kayıt ("Rol, 7 avatar, kullanıcı adı, şifre, sınıf ve alan"); Giriş Yap → 2.3 Giriş ("Kullanıcı adı ve şifre; Apple ve Google varyantı") → 2.4 Şifremi Unuttum ("E-posta → 6 haneli kod → yeni şifre").
4. Karar **Oturum** ("Rol hesaptan okunur · Öğrenci mi, koç mu?"): Koç → 10.1 (0.3); Öğrenci → alt çubuk.
5. Öğrenci dalları:
   - 3.1 Anasayfa ("Bugün, Son denemen, Derslerin") → 3.4 Programım ("Liste, gün ve hafta görünümü") → 3.5·3.6 ("Günler → ızgara → ad ve motto; Günü Sıfırla").
   - 6.1 Analizlerim ("Genel · Denemelerim") → 6.2 → 5.3–5.6 Deneme Detay → 5.7 Soru Detay.
   - 4.3 Okut (her sekmede; 0.2) → 4.1–4.10 → 5.1·5.2 Sonuç anı → Detaylı Analiz → 5.3–5.6.
   - 7.1 Derslerim ("TYT/AYT, eksikler, kartlar") → 7.2·7.4 → 7.3 → 8.1 Kart destesi.
   - 9.1 Hesap → 9.2–9.7 → 9.4·9.1 Hesabı Sil ya da Çıkış ("Onaylı; ardından Hoş geldin (2.2)").
6. 2.7 Genel ekranlar her an: zorunlu güncelleme, oturum sona erdi, bakım, bilinmeyen rol.

### 5.2 Bir denemenin yolculuğu (0.2)

1. Kâğıt optik form ("Deneme bitti; form elde") → 4.3 Okut ("Alt çubuktaki kamera, her sekmede").
2. 4.1 Kamera izni ("Yalnız ilk sefer; reddedilirse Ayarlar") → 4.2 Öğretici ("Yalnız ilk sefer") → 4.3 Çekim ("Formu çerçeveye al, deklanşör"). Sonraki seferlerde Okut → doğrudan Çekim.
3. 4.4 Köşeler ("Dört köşe cevap alanına oturur") → 4.5·4.6 Gönderim ("Yükleniyor"; v1'de bağlantı yoksa hata kalıbı, kuyruk yok [Ç-44]).
4. Sunucu: okuma ve net ("Net = D − Y ÷ 4, sunucuda", D-1) → 4.7·4.8 Form Kontrol ("Boş ve çift işaretleri düzelt; Cevapları Onayla").
5. Karar "Deneme tanındı mı?": **Evet** → 5.1 Sonuç anı ("Net, D/Y/B, fark, eklenen kartlar") → 5.2 Bildirim izni ("İlk başarılı okumada bir kez") → 5.3–5.6 → 5.7 ("Hücreden; işaretin ve doğru cevap"), 7.3 ("Bu Konuyu Çalış; ilk eksik maddede"), 8.1 ("Kartları Çalış; Eksiklerim"). **Hayır** → 4.9 Deneme bulunamadı (talep gönder → Anasayfa) [Ç-43].
6. 4.10 Hata ekranları her an: bakım, kamera açılamadı, form bulunamadı, bağlantı yok.
7. Okuma bitince kendiliğinden güncellenenler (k-upd; istemcide ilgili sağlayıcılar invalid edilir [Karar]): 3.1 ("Son denemen; Derslerin eksikleri"), 6.1 ("Grafikte yeni nokta, kutular"), 6.2 ("Listenin başında"), 7.1 ("Eksik sayıları"), 10.1 ("Dikkat kuralları yeniden hesaplanır"), 10.4 ("Koçun Denemeler sekmesi").

### 5.3 Koçun yolculuğu (0.3)

1. 2.2 Rol: Öğrenci Koçuyum ("Sınıf ve alan sorulmaz") → 2.2 Kamera ön açıklaması ("Koç da form okutabilir") → 2.2 Hoş geldin → 2.5 Kayıt (koç) ("Koçluk kodu kayıttan sonra oluşur").
2. 10.1 Koç Anasayfa ("Öğrenci yoksa: İlk öğrencini ekle"): Okut → 4.3 (koç; "Öğrenci seçilir; sonuç onun hesabına"); Öğrenci Ekle → 10.3 ("Hesabı koç açar; giriş bilgileri bir kez") → 10.2; Kodunu Paylaş → kod ("MOZK-4821; öğrenci 9.5'te girer") → 10.2.
3. 10.2 Öğrencilerim ("Arama I/ı/İ/i; satırda son net") → 10.4 Öğrenci profili ("Bağlam şeridi; Anasayfa karosundan ve dikkat satırından da") → 6.1 Analiz · 6.2·5.3 Denemeler ("Deneme Detay koç bağlamında") · 3.4 Program ("Salt okunur") · Görüşme Planla → 10.5 Yeni görüşme.
4. 10.5 Görüşmelerim ("Arama, Kiminle süzgeci") → Yeni ("Öğrenci, Öğrenci/Veli, tarih, saat") → Görüşme detayı ("Tarih, saat, öğrencinin verileri") → Not → 10.6 ("Ekle, düzenle, onaylı sil, geri al"); kesikli → 9.6 öğrenciye bildirim ("Görüşme planlandı").
5. 9.1 Hesap (koç): "Koçluk kodu: Kopyala, Paylaş".

---

## 6. Kararlar, varsayımlar, geliştirici notları, backend bağımlılıkları ve açık sorular

### 6.1 Çözülen çelişkiler (`[Ç-n]`)

Kural §0.2: teslim (11.12–11.16) > sonraki tur G maddesi > sonraki tur markup'ı > kit.

| # | Konu | Seçenekler | Karar |
|---|---|---|---|
| Ç-1 | warning/eksik koyu | 1.4 `#EBC25B`/`#33280F` · 11.12 `#F2C46D`/`#33270F` | 11.12 |
| Ç-2 | success koyu zemin | 1.4 `#133325` · 11.12 `#15301F` | 11.12 `#15301F`; `dybCorrectBg` koyu `#133325` kalır |
| Ç-3 | Boş token adı | `dybEmpty` (1.4, Tur 1) · `dybBlank` (11.12) | `dybBlank` |
| Ç-4 | `SmapColors` alanları | 11.12 listesi · Tur 1 listesi | Birleşim (+`bar`, `primaryPressed`, `dybOn`, `dybCorrectBg`, `chartArea`, `chartSeries`; `subject` haritası 11.12 biçiminde) |
| Ç-5 | Deneme Detay rakam stilleri | 1.6 net metric-xl, puan metric-lg · 11.12 metric-lg / metric-md | 11.12 |
| Ç-6 | Koyu girdi zemini | 1.1 `#213049` · 11.12 `#121D31` | `#121D31` |
| Ç-7 | Form hatasında sallanma | 1.8 hiç · 11.15 kod kutuları | Yalnız kod kutuları ([Karar] ±6 pt, 150 ms) |
| Ç-8 | Değişim rengi | 5.1/6.1/6.4 notları success/`#52CC8E` · Tur 10 `delta` | `delta` (`#36537C`/`#9BB3D3`) |
| Ç-9 | Çip boyu ve seçili işaret | Kit 36 + Check · ekranlar 40/48 Check'siz, 6.1 noktasız | `sm`36/`md`40/`lg`48; Check yok (ekranlar); 6.1 ders noktası yok |
| Ç-10 | Tümü/Yanlışlar/Boşlar | Kit seçim çipi · 5.4 sayaçlı segment | Sayaçlı segment |
| Ç-11 | EksikTag ağırlığı | G3 13/600 · CSS 13/700 | 600 |
| Ç-12 | Derslerim satır eksik etiketi | 7.1 nötr Tag · 11.13 EksikTag | EksikTag; sıfırda nötr "eksik yok" |
| Ç-13 | Ders satırı glif karosu | Kit 48 · Tur 5 40 | 40 |
| Ç-14 | Konu satırı | Kit numara sütunu 24, satır 56 · Tur 5 rozet 28, satır 64 | Tur 5 |
| Ç-15 | SessionProgress | G5 4 pt · 8.1 8 pt; sayaç 15/24·700 · 13/20·700 | 4 pt; 13/20·700 |
| Ç-16 | Radyo seçili | Kit 2 halka + 12 nokta · ekranlar içe 7 | İçe 7 (koyu `#C5D4E8`) |
| Ç-17 | Spinner renkleri | Kit `#E8ECF1`/`#264066` · 4.5/9.4 `#DCE2E9`/`#0F294A` | Ekran değerleri; koyu `#34445F`/`#C5D4E8` |
| Ç-18 | Favori seçili | 1.16 `#556173` Fill · 6.2 `#0F294A` | `#0F294A` Star Fill; kapalı `#697586` |
| Ç-19 | Soru ızgarası aralığı | Not 8 · 5.4 markup 6 (66 hücre) | 6 (G1 "66 pt hücre" ile tutarlı); formCheck ızgarası 8 |
| Ç-20 | Kapak köşesi | 11.12 radius-sm 8 · markup 6 | 8 |
| Ç-21 | Kısa detay barı başlığı | Kit 15/20·600 ortalı · ekranlar 17/24·700 sola | 17/24·700 sola, 2 satır; ayraç (kit) korunur |
| Ç-22 | Sheet eylem alanı alt dolgusu | Kit 50 · ekranlar 42 | Güvenli alan + 8 (≈42) |
| Ç-23 | Çevrimdışı dönüş metni | 1.22 "Bağlantı geri geldi" · 11.15 "Bağlandın" | "Bağlandın" |
| Ç-24 | Arama temizle düğmesi | Kit 48 / X 20 · ekran 40 / 24 daire / X 12 | Görsel ekran, dokunma 48 |
| Ç-25 | CodeCard | Tur 9 kod 24/800 · pano 24/32·700 ls 1; düğmeler 44 | metric-md 700 + ls 1; `secondary.md` 40 |
| Ç-26 | Saat slotu çıkar | 3.5 40 · 3.6 notu 48 | Görsel 40, dokunma 48 |
| Ç-27 | Akordeon sağ öğesi | Kit 32 daire · 5.4/7.3 dairesiz | Dairesiz ok (24/22/20) |
| Ç-28 | Lockup ölçüleri | 1.26 64+44, 88+32 · Tur 7 36+24, 104+40 | Tur 7 |
| Ç-29 | Tam ekran durum ikonu | 64 (1.22) · 80 (3.7, 4.9, 4.10, 5.8, 6.3, 7.5) · 96 (2.7, 2.4, 9.4) | Üç kademe: sekme içi ErrorState 80 + 20/28; akış 80 + 24/32; blok 96 + display |
| Ç-30 | StudentRow yüksekliği | CSS 64 · not 72 | 72 (iki satır kuralı) |
| Ç-31 | AvatarPicker boyu | Kit 96 · ekranlar 46/72 | 46 (satır içi), 72 (sheet) |
| Ç-32 | Sekme göstergesi rengi | Bant `#FF6600` · ekran içi `#E05500` | İkisi de (lacivertte 4,98 için bilinçli) |
| Ç-33 | DybLarge değeri | 11.12 notu metric-sm · 11.13/markup 24/32 | metric-md 24/32 |
| Ç-34 | WeekGrid saat sütunu | Tur 6 notu 40 · 11.13/markup 44 | 44 |
| Ç-35 | Tarih/Coğrafya segmentinde "Tümü" yok | Kural yok | Panodaki gibi; açık soru (§6.5) |
| Ç-36 | 8.1 toast eylem satırına biniyor | Pano satırı gizlemiş | Toast satırın 8 üstünde; satır görünür (6 sn "Öğrendim" kilitlenmesin) |
| Ç-37 | Çalışma kartı köşesi | G5/not 24 · markup 16 | 24 |
| Ç-38 | Çalışma kartı gölgesi | Not yalnız sürüklenirken · markup duran kartta | Yalnız sürüklenirken |
| Ç-39 | Uzun sheet üst boşluğu | Kit güvenli alan + 8 · 10.3 top 90 | Güvenli alan + 8 |
| Ç-40 | Toast ikonu | Kit ikonlu · 9.3 ikonsuz | İkonlu |
| Ç-41 | Görüşme tarih ayırıcısı | 9.5 virgül · 10.5 orta nokta | " · " |
| Ç-42 | "Sonra" düğmesi | 2.2-4 text · 4.1 quiet | Bağlama göre ikisi (tam ekran text, sheet quiet) |
| Ç-43 | Deneme bulunamadı | 0.2 "listeden seç ya da talep" · 4.9 yalnız talep | 4.9 |
| Ç-44 | Çevrimdışı gönderim | 0.2 "sırada" · 4.10-3/T2.15 v1 kuyruk yok | Kuyruk yok; 4.5 hata kalıbı |
| Ç-45 | shadow-raised alfası | 4.7 büyüt düğmesi %16 · token %8 | Token %8 |
| Ç-46 | Koç Profil satırı alt metni | 9.1-4 öğrenciyle aynı (sınıf, alan) | "Ad, e-posta ve telefon" |
| Ç-47 | "Koçun deneme ya da ödev atadı" kategorisi | 9.6 var · T9.6 koç atama yok | Çizildiği gibi; backend sorusu |
| Ç-48 | Deneme kartı | Kit 1.16 ExamCard (56 × 76) · Tur 4 ExamRow | ExamRow; kit kartı kullanılmaz (özet kartı 3.1'de) |
| Ç-49 | BarAction ikon boyu | 11.13 20 · 9.x/10.4 markup 18 | 20 |
| Ç-50 | body-lg "okumada 16/26" | Yeri belirtilmemiş | `SmapText.bodyReading` + kullanım listesi (§1.11) |
| Ç-51 | Bulanıklık σ | CSS = σ · mihr blurPx = 2σ | σ = CSS değeri (20/8) |
| Ç-52 | Koyu odak boşluğu | Belirtilmemiş · 1.24 `#18263D` | Altta kalan yüzey rengi |
| Ç-53 | Negatif değişim işareti | Belirtilmemiş | U+2212 "−" |
| Ç-54 | Koyu grafik balonu | 1.4 `#E8ECF1`/`#556173`/`#1B2232` · 6.4 `#EDF1F6`/`#36537C`/`#0A1424` | 6.4 |
| Ç-55 | Sekme içerik geçişi | 1.8 yatay · 5.3 150 ms çapraz | Çapraz geçiş |
| Ç-56 | Toast eylem metni rengi | T1.23/kit beyaz kalın · 10.6 `#C5D4E8` | `#FFFFFF`·700 |
| Ç-57 | Sheet kapat X | Kit 20 · ekranlar 18 | 18 |
| Ç-58 | Şifre kuralı | İpucu "En az 8 karakter." · kodda kural yok | İstemcide 8; sunucu doğrulaması istenir |
| Ç-59 | Hata kutusu ikonu | 2.3 metni "Warning" · CSS WarningCircle | WarningCircle |
| Ç-60 | Analizlerim sekme ikonu | 1.19 ChartLineUp · ekran SVG ChartLine | ChartLineUp |
| Ç-61 | Kart destesi / Soru Detay alt çubuğu | 1.19 "kart oturumunda gizli" · 5.7/7.6/8.1 görünür | Görünür; deste Derslerim dalında |
| Ç-62 | Program saati stili | Tur 6 15/700 · Tur 10 body-strong 15/600 | body-strong |
| Ç-63 | Ders satırı kart ilerleme metni | Kit "41 / 64 kart biliniyor" · 7.1 "41/64 kart" | "41/64 kart" |
| Ç-64 | 5.7 cevap çipleri | Markup'ta renk tanımsız | D/Y/B renkleri (İşaretin yanlışsa Yanlış, doğruysa Doğru çipi) |
| Ç-65 | Çevrimdışı şeridi konumu | 6.3 mutlak + yuvarlak bant · 1.22/7.5 akışta + düz köşe | 1.22/7.5 |

### 6.2 Başlıca geliştirici kararları (`[Karar]`, panoda yok)

- go_router + rol başına `StatefulShellRoute`; içerik ekranının sabit sekmesi (§3.1); route haritası (§3.6).
- Bileşen konumu `lib/core/ui/` + debug `ComponentGallery` (`/dev/gallery`).
- Ek paketler: `go_router`, `phosphor_flutter`, `permission_handler`, `share_plus`, `connectivity_plus`, `package_info_plus`, `url_launcher` (mevcut değilse); kaldırılacak: `cupertino_icons`, `appinio_swiper`, (kullanım bitince) `http`.
- `SmapText.bodyReading` 16/26; `SmapColors.inverseSurface/onInverseSurface`; koyu `chartSeries`; koyu iskelet parıltısı %6; `surfaceTint` saydam; `NoSplash`.
- Haptik kanal `smap/haptics`; kod kutusu sallanma ±6 pt; sheet fırlatma eşiği 700 px/sn.
- Alan kısaltmaları SAY/EA/SÖZ/DİL; Subject enum adları; avatar id ↔ dosya adı eşlemesi.
- Çizilmemiş sheet'ler (saat seçici 3.6, öğrenci seçici, tarih seçici, alan sheet'i, e-posta doğrulama) mevcut kalıplarla.
- Çizilmemiş onay ve hata metinleri: "Kaydetmeden Çık", "Yaptığın değişiklikler silinecek.", "Seçtiğin günler ve konular silinecek.", "Düzelttiğin cevaplar kaydedilmeyecek.", "Çık", "Kaydedilemedi. Bağlantını kontrol edip tekrar dene.", "Program kaydedilemedi. …", "Not kaydedilemedi. …", "Kaydın tamamlanamadı. …", "Bağlanamadık. Bağlantını kontrol edip tekrar dene.", "Alanını seç.", "Sessiz saat bitişi", "Çalışma saati", "Geçmiş · N", "Veli görüşmesi", "Önümüzdeki 7 günde görüşme yok.", "Koçunla bağlan", "Koçun yeni bir şey atadığında", "Öğrencilerinle bağlantın kalkar.", "Deneme Kartları", bölüm hataları "Öğrenciler yüklenemedi." / "Dikkat listesi yüklenemedi." / "Görüşmeler yüklenemedi.". Ürün sahibi onaylamalı.
- Sonuç anında Kapat = Anasayfa; "Analizi Gör" = son denemenin Deneme Detay'ı; 8.1 "Detay" = CardSheet; "Geç" = Rol ekranı.
- Feature flag'ler (§6.4); not silmede 6 sn istemci gecikmesi.

### 6.3 Backend bağımlılıkları

| # | Konu | Tasarımın beklediği | Bugünkü kod | Soru / gerek |
|---|---|---|---|---|
| 1 | Optik okuma tabanı | `opticimage`, `answerArray`, `examrequest` gerçek host | `apiBaseUrl = 'https://wfdsvfsdg.com/'` (placeholder); Dio `https://www.smaptr.com`; görseller smaptr.com.tr / www.smaptr.com.tr / smaptr.com | Gerçek host? Tek taban adres? |
| 2 | Fotoğraf yükleme | 2400 px JPEG %85, yüzdeli, 60/30 sn | base64 + `user_data` POST | Multipart JPEG? Boyut sınırı? |
| 3 | Hata türleri | network, timeout, server, maintenance; form bulunamadı ↔ deneme bulunamadı | `mexamFound` Map değilse "bulunamadı"; Left'te mesaj yok | Yapılandırılmış hata kodu? |
| 4 | Bakım bayrağı | Kamera açılmadan "okuma açık" | Yok | Yeni uç |
| 5 | Zorunlu güncelleme | Min sürüm | Yok | Uç ya da remote config; mağaza URL'leri |
| 6 | Oturum / rol | SessionExpired, UnknownRole | `validateStatus < 500`, `followRedirects: false`; rol `student`/`coach` | Oturum düşünce ne döner (401/302)? Rol değer seti? |
| 7 | Şifremi unuttum | E-posta → 6 hane (10 dk, tekrar 30 sn) → yeni şifre | Uç yok | Gelmezse akış gizli (D-18) |
| 8 | Şifre değiştirme | Gerçek; diğer oturumlar kapanır | Sahte SnackBar | Yeni uç |
| 9 | Soru başına şık | "işaretin C, doğru cevap A" | `questionsArrStr` yalnız `{order, type}` | İşaretlenen ve doğru şık alanı? (Sorular sekmesi buna bağlı) |
| 10 | E-posta değişimi | Doğrulama kodu | Yok | Yeni uç |
| 11 | Profil güncelleme | PATCH; avatar, sınıf, alan, telefon | POST `/student/updateStudent` | Kısmi güncelleme? Alanlar destekleniyor mu? |
| 12 | Kullanıcı adı kontrolü | Canlı, öneri | `/ajax/checkUsername` (koç kullanıyor; kayıt simüle) | Kural aynı mı? Öneri alanı? |
| 13 | Sözleşmeler | Ad, sürüm, tarih; sürümle onay | `/ajax/getLegalDocuments` (name, title, version, content, isActive); kayıt `accepted*Version` | Tarih alanı? |
| 14 | Hesap silme | İdempotent; deneme sayısı | `/ajax/deleteAccount` | İdempotent mi? Sayı nereden? |
| 15 | Koç bağlantısı | Kodla bağlan/kaldır, `AAAA-0000`, sıradaki görüşme | `addCoach`, `deleteCoach` (coachId göndermiyor), `getStudentsCoach` | Sıradaki görüşme ucu; `deleteCoach` düzeltmesi; `refCode` biçimi |
| 16 | Bildirim tercihleri ve push | 4 kategori, sessiz saatler, anahtar başına PUT, cihaz token'ı | Yok; push paketi yok | Tercih + token uçları, gönderim altyapısı |
| 17 | Sosyal giriş | Apple ve Google | `google_sign_in` var, çağrılmıyor; Apple paketi yok | Sunucu ucu? |
| 18 | Alan/sınıf kodları | Sayısal, EA, Sözel, Dil; Mezun | Kayıt 2/3/4 (Dil yok); koç dialogu 1/2/3/4; Mezun = 13; koç dialogunda Mezun yok | Tek resmî eşleme? |
| 19 | Anasayfa "Bugün" | Bugünün çalışmaları | `/student/getMyWeeklies` | Bugün ucu mu, istemci süzmesi mi? Tarih aralığı alanı? |
| 20 | "Son denemen" | Net, D/Y/B, aynı türün öncekine fark, en çok kaçırılan konu | `getMyMockExams` + `getMexamSubjectDetail` | Özet ucu mu, istemci birleştirmesi mi? |
| 21 | Ders eksikleri | Ders ve TYT/AYT/SOS-2 kırılımı | `/student/getLessonsTotalMissing`, `resultByType` | Ders toplamı ↔ konu toplamı farkı (T5.2) |
| 22 | Kart ilerlemesi | Ders başına öğrenilen/toplam; madde başına kart durumu | Yalnız örnekte (Tarih 41/64) | Alan mevcut mu? |
| 23 | Sonuç anı | Tek istek; kart sayısı | `answerArray` yanıtı + ayrı `getTotalInfoCard` (elle çerez) | Kart sayısı `answerArray` yanıtına eklenebilir mi? |
| 24 | Geri Al | Öğrendim (6 sn), Günü Sıfırla, not silme | `learnedCard`/`learnedItem` var; geri alma yok; `deleteNote` var | Geri alma ucu mu, istemci gecikmesi mi? |
| 25 | Program iptali ve anında kayıt | "Programı İptal Et"; düzenleme başına kayıt | `addNewProgram`, `updateProgram`; silme yok | Silme ucu; parçalı güncelleme |
| 26 | Analizlerim | Kullanıcının alanı; AYT toplam neti | `getLineChartData` + `getTotal` ayrı; `aimType = 2` sabit | Birleşik uç mu, paralel istek mi? |
| 27 | Denemelerim sıralama | `sort=newest\|net`; hazır tarih aralıkları | `filter{types,nets,dates}`, `page`, `perPage: 8` | `sort`? "Bu eğitim yılı" sınırı? |
| 28 | Koç dikkat listesi | İki kural + kanıt | Yok | Yeni uç |
| 29 | Koç öğrenci listesi | Deneme sayısı, son net, son deneme tarihi | `getMyStudents`; `totalMexam` var | Son net/tarih alanı |
| 30 | Öğrenci Ekle | Mezun dahil sınıf, alan | `/coach/addNewStudent` | `seasonType 13` kabul? |
| 31 | Görüşmeler | Arama, Kiminle süzgeci, yıllı tarih; düzenleme/silme | `getInterviews` (sayfalı, `filter{types,dates}`), `addNewInterview` | Arama parametresi? Düzenle/sil uçları? |
| 32 | Koç hatırlatması | Görüşmeden 1 saat önce | Yok | Zamanlanmış push |
| 33 | Koç bağlamında öğrenci | Analiz, Denemeler, Program salt okunur | Koç analiz ekranı var | Bütün uçlar `studentId` alıyor mu? |
| 34 | Koç kamerası | Form seçilen öğrenciye | Yok | Okuma isteklerine `studentId` |
| 35 | Bildirim kategorisi | "Koçun deneme ya da ödev atadı" | T9.6: koç atama yok | v1'de kalacak mı? |
| 36 | "Deneme sonucun hazır" | Talep edilen deneme analizi bitince | `examrequest` var | Asenkron olay / durum alanı? |
| 37 | Web'de dersler | "Web'de Aç" | URL yok | URL? |
| 38 | YKS tarihi | 19 Haziran 2027 (örnek) | Yok | Sabit mi, remote config mi? |
| 39 | Sürüm, destek adresi, sözleşme tarihleri | Derleme ve sunucudan | Yok | Destek adresi? |
| 40 | Deneme favorisi | Yalnız cihazda | Modelde `isStarred` var, yazılmıyor | Sunucu `isStarred` yok sayılır (onay) |
| 41 | Kapak görselleri | Sunucudan | `/uploads/{image}` farklı host'larda | Tek host? |

### 6.4 Feature flag'ler [Karar]

| Flag | Varsayılan | Etki |
|---|---|---|
| `forgotPasswordEnabled` | false (uç yok) | 2.3 "Şifremi Unuttum" bağlantısı ve 2.4 akışı |
| `socialLoginEnabled` | false | 2.3 kare 4 varyantı |
| `notificationsEnabled` | false (T2.17, T8.4) | 5.2 sheet'i; 9.6 InfoBox "planlı" metni açıkken kalkar |
| `offlineQueueEnabled` | false (T2.15) | 4.10-3 ekranı |
| `passwordChangeEnabled` | uç gelince true | 9.3 |
| `attentionListEnabled` | uç gelince true | 10.1 Dikkat bölümü (kapalıyken bölüm çizilmez) |
| Remote: `minAppVersion`, `omrEnabled`, `yksDate`, `webLessonsUrl`, `supportEmail`, `storeUrls` | — | 2.7, 4.10-2, 3.1, 7.1, 9.1 |

### 6.5 Açık sorular (ürün sahibi / backend)

1. §6.3'teki 41 maddenin cevapları (özellikle #1 taban adres, #9 soru şıkları, #16 bildirim, #18 alan kodları, #33–34 koç `studentId`).
2. Logo/launcher ikonu: lacivert pafta mı açık sürüm mü (T1.34).
3. Kil illüstrasyonların asıl 3x dosyaları (1.25); sosyal giriş resmî varlıkları; cihaz çerçevesi ve logo dosyaları (mağaza).
4. Tarih/Coğrafya ders detayında "Tümü" seçeneğinin olmama kuralı [Ç-35].
5. Bildirim kategorisi "Koçun deneme ya da ödev atadı" v1'de kalsın mı [Ç-47]; koçun bildirim kategorileri.
6. Koç için Hesabı Sil akışı ve metinleri.
7. Ham puan (`pointsHam`, `ranksHam`) gösterilecek mi (T3.2).
8. Yeni kullanıcı Anasayfa'sında Matematik/Geometri "Web'de" etiketi kasıtlı olarak mı yok.
9. [Karar] işaretli bütün metinlerin onayı (§6.2).
10. Koç bağlamında "Bu Konuyu Çalış"/"Kartları Çalış" gizlensin mi (bu belgede gizli).
11. Sözleşme yeni sürüm onayı akışı (açılışta; çizilmemiş).
12. Hafta ızgarası bloklarında konu adı (bugün yalnız ders adı; Tur 6 açık madde).

### 6.6 Brif Ek D kararları (D-1…D-33)

| ID | Karar | Kod / backend |
|---|---|---|
| D-1 | Net = D − Y ÷ 4, sunucu hesaplar; çeyrek adım, virgüllü | İstemci net hesaplamaz; `NumberFormat('#,##0.##','tr')` |
| D-2 | Gösterilecek gerçek veriler (deneme: net, D/Y/B, yerleştirme ve ham puan, sıra, test D/Y/B, soru durumu ve şık, konu D/Y/B ve yüzde; eksikler: ders, TYT/AYT/SOS-2, konu; içerik: madde sayısı, madde ve kart durumu, eksik/bilinen/favori; analiz: liste, tarih, sayı, ortalama net, puan, sıra; program, görüşme, notlar, koçun öğrenci listesi) | Hepsi sunucudan; kritik eksik §6.3 #9 |
| D-3 | Gösterilmeyecekler: geçen aya göre değişim, konu tamamlama %, "N/20 konu", ders başına alt başlık/madde/kart toplamı, "%60", elmas/coin/puan/seri/rozet, hedef net, "Başarısız (Derece)", sabit OBP, görev tamamlama | Varsayılanlar, sabitler ve `UserModel.points` gösterimi silinir |
| D-4 | v1'de yok: SmapLab, Gelen Kutusu, SmapCoach, Müfredat, Kaynak Takibi, Analiz sekmesi, Harita, Ödeme ve Paketler, Kayıtlı Kartlarım, faturalar, paywall, Soru Bankam, soru fotoğrafı, oyunlar; "Yakında" yalnız kitte | Rotalar, menüler, `showUnderConstruction` kalkar |
| D-5 | Matematik/Geometri "Web'de" + sheet + "Web'de Aç" | URL gerekir |
| D-6 | Birincil düğme lacivert dolgu, beyaz metin | `SmapButton.primary` |
| D-7 | Turuncu: kamera, seçili/konum, ilerleme, "bugün"; metin olarak yalnız koyu turuncu | Seçim lacivert (T1.6) |
| D-8 | Kamera düğmesi turuncu dolgu, lacivert ikon, "Okut" | `SmapCameraButton` |
| D-9 | Kök sekmede lacivert bant; ad/avatar yalnız Anasayfa ve Hesap | Açık zeminli DetailBar (T1.4) |
| D-10/11/12 | Plus Jakarta Sans · Phosphor Regular/Fill · tek renk ders glifi | TTF, `phosphor_flutter`, `SmapColors.subject` |
| D-13 | Mevcut 3D avatar seti, öğrenci ve koçta ortak | 7 avatar; sunucuda `photo` dosya adı |
| D-14 | Koyu çizilen ekranlar: 3.3 · 4.3–4.4 (her temada koyu), 4.6 · 5.1-3 · 5.9, 5.10 · 6.4 · 7.6 · 8.2 · 3.8 | Koyu ColorScheme; kamera zorla koyu; mağaza bu ekranlardan |
| D-15 | Flaş ve galeri yok | `image_picker` kullanılmaz |
| D-16 | Yalnız gerçek gönderim adımları | dio `onSendProgress` |
| D-17 | Sosyal giriş ayrı varyant | Bayrak; sunucu ucu belirsiz |
| D-18 | Şifremi unuttum e-posta + 6 hane; uç yoksa gizli | Feature flag |
| D-19/20 | Alanlar Sayısal, EA, Sözel, Dil; 9–10'da alan yok · Sınıflar 9, 10, 11, 12, Mezun | `aimType` eşlemesi tutarsız (§6.3 #18) |
| D-21 | YKS tarihi örnek 19 Haziran 2027; geri sayım cihazda | Kaynak belirtilmemiş |
| D-22 | Dokunma hedefi 48 | `MaterialTapTargetSize.padded` |
| D-23 | Bildirim izni ilk başarılı okumadan sonra | 5.2 + `notif_primer_shown` |
| D-24 | Sessiz saatler 22:00–08:00 | Tercih ucu |
| D-25 | Deneme favorisi yalnız cihazda | SharedPreferences; koçta yıldız yok |
| D-26 | Programda tamamlama yok | Tamamlama alanı kullanılmaz |
| D-27 | Koçta dikkat yalnız iki kural | Sunucu ucu |
| D-28 | Hesap silme: açıklama → tehlikeli onay; kelime yazdırma yok | `/ajax/deleteAccount` |
| D-29 | Öğrenci ve koç sekmeleri | `SmapBottomBar(role)` |
| D-30 | Yalnız Türkçe | `tr`; ARB zorunlu değil |
| D-31 | Toast alt çubuğun üstünde; 4 sn, Geri Al'lı 6 sn | Geri alma uçları |
| D-32 | "(Test)" eki yok; yayınevi ve ad ayrı satır | `publisherName`, `itemName` ayrı |
| D-33 | "Deneme: N" yok; denemeler tarihle ayrılır | `mexam.order` gösterimi kalkar |

### 6.7 Tur varsayımları (11.16, 134 madde; kod/backend etkisiyle)

**Tur 1:** 1.1 "Design System" artifact'ı kullanılmadı · 1.2 42 ekran görüntüsü piksel ölçümüyle doğrulandı, 5 yanlış düzeltildi · 1.3 kanvas `#F5F7F9`→`#F2F4F7`, başlık `#1C1F33`→`#1B2232` · 1.4 açık zeminli DetailBar, kısa barda en çok 2 satır · 1.5 ince turuncu orange-600 (koyu 400) · 1.6 seçim lacivert · 1.7 segment başparmağı lacivert · 1.8 alt çubuk etiketi 12 pt istisna, FittedBox + uzun basış balonu · 1.9 alt çubuk sekme içinde, tam ekranda gizli (sekme başına navigator + root) · 1.10 güvenli alan 62/34, klavye 336 şematik (`MediaQuery`) · 1.11 kamera düğmesi 56, radius-lg, 16 yukarı · 1.12 kök bant 134/178/110 · 1.13 kartlar kenarsız/gölgesiz; gölge yalnız sürüklenen kart, kamera düğmesi, toast, balon · 1.14 D/Y/B renkleri, sayı metin renginde, koyuda açıklık ters · 1.15 ders glifleri ve tonları (Kimya 296°, Edebiyat 340°) · 1.16 başarı halkası tek renk, "Soru yok" · 1.17 net sıfırsız, puan 2 hane, "5 Eki." · 1.18 iptal sözlüğü · 1.19 onay başlığı cümle düzeni · 1.20 zorunlu yıldız yok, "(isteğe bağlı)" · 1.21 şifre ipucu "En az 8 karakter." (kodda kural yok; backend) · 1.22 placeholder yalnız beyaz zeminde · 1.23 toast eylemi beyaz kalın; koyuda toast ve şerit ters yüzey · 1.24 iskelet 15 sn'de hataya · 1.25 koç rozeti "Koç" · 1.26 avatar 190, kil 140 kırpım; üretimde 3x; kapaklar yer tutucu · 1.27 ikonlar `phosphor_flutter` · 1.28 örnek şıklar/kullanıcı adı/alt başlıklar · 1.29 ders kart toplamı yalnız Tarih (41/64; backend alanı) · 1.30 font gömülü · 1.31 örnek avatar atamaları (Mert = koç avatarı) · 1.32 kil seti ikon seti değil · 1.33 ders satırında glif · 1.34 logo örgülü S; varsayılan lacivert pafta (karar kullanıcıda) · 1.35 wordmark ExtraBold.

**Tur 2:** 2.1 kamera aşaması her temada koyu; gönderim ve sonuç açık+koyu · 2.2 öğretici koyu çizilmedi · 2.3 kenar algılama DocumentScanner konturu, otomatik çekim yok · 2.4 eklentinin düzenleme adımı kalktı · 2.5 2400 px, JPEG %85 (isolate; backend boyut/format) · 2.6 gönderim 60 sn, okuma 30 sn · 2.7 kolonlar sıra no, kolon başına 40 satır (`answersArray` indeksli) · 2.8 örnekte 2 boş düzeltildi · 2.9 Onayla ek onay sormaz; X + düzeltme → çıkış onayı (PopScope) · 2.10 alan netleri `aytNets` (2/3/4) · 2.11 puan/sıra yalnız öğrencinin alanı · 2.12 TYT'de yayınevi, puan, kart sayısı yok (null çizilmez) · 2.13 "Türkiye Geneli Deneme 7" örnek · 2.14 talep sonrası bildirim sözü yok · 2.15 çevrimdışı kuyruk planlı, v1 hata kalıbı · 2.16 bakım bayrağı kamera öncesi; yoksa ilk gönderimde · 2.17 bildirim izni sheet'i bayrakla kapalı.

**Tur 3:** 3.1 Deneme Detay alt çubuklu, Analizlerim seçili; sonuç anından açılınca kamera akışı kapanır · 3.2 puan bloğu yalnız öğrencinin alanı; ham puan çizilmedi · 3.3 doğru/yanlış dizilimi örnek; soru başına şık backend'de yok · 3.4 ders sayaçları 12/12/0 · 3.5 eşitlik soru sayısıyla, "Az soru" 1–2 · 3.6 "En çok kaçırdığın konu" yanlışa göre, eşitlikte düşük yüzde · 3.7 Kartlar sekmesinde ders başına sayı yok · 3.8 Soru Detay açıklaması kart metninden; AYT Tarih-1 = 25–34 · 3.9 önceki/sonraki soru yok · 3.10 Konular koyu Tur 10'da (5.10).

**Tur 4:** 4.1 "AYT · Genel" bütün AYT testlerinin toplamı; alan yalnız ders listesini değiştirir · 4.2 AYT ortalama 57,56, TYT 67,79 (sunucu) · 4.3 tek ders kutuları sunucudan · 4.4 EA listesine Matematik; ders ID'leri sunucudan alınmalı · 4.5 adsız deneme "tür + denemesi" · 4.6 liste, ızgara değil · 4.7 hazır tarih aralıkları ("Bu eğitim yılı" sınırı belirtilmemiş) · 4.8 favori yalnız cihazda · 4.9 tek deneme örneği.

**Tur 5:** 5.1 eksik dağılımı Ek C'den; `resultByType` null ise çizilmez · 5.2 Türkçe 31 (28+3), konu bazında 8, fark sunucudan · 5.3 Sözcükte Anlam 5 alt başlık 25 madde · 5.4 oturum 12/23; sekmeler 22·42 olur · 5.5 kaydırma yalnız sonraki karta; öğrenme yalnız düğmeyle · 5.6 onay ilk sefer, "Bir daha sorma" cihazda, 6 sn Geri Al (geri alma ucu yok) · 5.7 yazar listesi örnek; fotoğrafsız baş harf · 5.8 TYT/AYT seçimi cihazda; Tarih-2 → SOS-2 seçili (`defaultFilterValue` 4) · 5.9 çevrimdışında Web'de gizli · 5.10 Matematik EA AYT listesinde; Geometri de Web'de.

**Tur 6:** 6.1 "Ekim 2. Hafta" = 5–11 Ekim 2026 (ayın ilk tam haftası) · 6.2 son deneme en son okunan; fark aynı türün öncekine göre · 6.3 selam profilin ilk adı · 6.4 YKS 19 Haziran 2027; 10 Ekim 2026'dan 252 gün · 6.5 ders şeridi eksik azalan; Mat/Geo sonda · 6.6 Anasayfa'dan ders detayı son TYT/AYT seçimiyle; ilk açılışta TYT · 6.7 geçmiş gün seçilemez · 6.8 Çantam = eksik konular · 6.9 düzenleme anında kaydedilir; "Bitti" modu kapatır · 6.10 Programım alt çubukta değil, Anasayfa yığınında.

**Tur 7:** 7.1 tanıtım 3 ekran; rol/sınıf/alan kayda kadar cihazda · 7.2 girişte rol hesaptan · 7.3 "Beni Hatırla" yok, oturum açık (PersistCookieJar; oturum süresi backend) · 7.4 kullanıcı adı harf/rakam/nokta/alt çizgi, küçük harf · 7.5 şifre ≥ 8 · 7.6 Hoş geldin'de Kayıt Ol birincil · 7.7 resmî Apple/Google varlıkları; Apple paketi yok · 7.8 sıfırlamada kayıtsız e-postaya aynı yanıt; kod 10 dk; tekrar 30 sn · 7.9 koç kaydı alanları boş · 7.10 bakım/bilinmeyen rolde süre ve adres yok.

**Tur 8:** 8.1 sürüm satırı örnek, derlemeden · 8.2 sözleşme sürüm/tarihleri sunucudan (tarih alanı yok) · 8.3 destek adresi yok; taslak sürüm + cihaz bilgisi · 8.4 bildirim altyapısı kapalı, tercihler şimdiden kaydedilir · 8.5 kategoriler ve sessiz saatler varsayılan açık · 8.6 Hesabı Sil Profil'in en altında · 8.7 silinecek deneme sayısı 10 (backend) · 8.8 koçluk kodu 4 harf + 4 rakam (`refCode`) · 8.9 çıkış onayı normal · 8.10 koçun Hesap'ı aynı yapıda, Sınıf/Alan yok.

**Tur 9:** 9.1 dikkat kuralları Ek C'de tetiklenmiyor; kare 2 örnek · 9.2 diğer öğrencilerin deneme verisi yok (null-safe) · 9.3 öğrenciler alfabetik, Türkçe · 9.4 Öğrenci Ekle örneği Zeynep Kaya (12, EA) · 9.5 Mert av-2 · 9.6 koç programı yalnız görür · 9.7 görüşme notları yalnız koça (backend ACL) · 9.8 görüşmeden 1 saat önce hatırlatma · 9.9 koçta da kamera, form seçilen öğrenciye (`studentId`).

**Tur 10:** 10.1 değişim rengi delta · 10.2 koç panoları kod sırası · 10.3 akış kodları pano no · 10.4 eşleme pano düzeyinde · 10.5 parlama ve kil yalnız mağazada.

**Tur 11:** 11.1 cihaz çerçevesi ve logo dosyaları gelmedi · 11.2 mağaza boyutları doğrulanmadı (1320 × 2868 / 1290 × 2796; Play 9:16, 2–8 görsel; 1024 × 500) · 11.3 mağaza başlıkları öneri · 11.4 koç ekranları mağazada yok · 11.5 kil: Harita, Sütun, Ampul · 11.6 mağaza arayüzleri markasız · 11.7 5.9 segment sayaçlarının koyu rengi düzeltildi (kodda koyu sayaç renkleri) · 11.8 Play = App Store karelerinin üst %82'si · 11.9 kare sırası: ne yapar, nasıl, ne alırım, ayrıntılar.

### 6.8 "Yapma" kuralları (denetim listesi; Tur 1–11)

Genel: (1) emoji yok; (2) gradyanlı hero + cam istatistik kartı + ilerleme halkası üçlüsü yok (tek gradyanlar iskelet parıltısı ve kaydırma solması); (3) elmas, coin, seri, rozet yok; (4) eksensiz grafik yok, noktalar dokunulur, hedef çizgisi yok; (5) kategori başına renkli hap/kart şeridi yok; (6) üstü çizili görev, tamamlama yüzdesi/işareti yok; (7) parıltı, blob, konfeti yok; `BackdropFilter` yalnız alt çubuk ve perde; (8) "kart + başlık + Tümü ›" yok; (9) büyük harfli harf aralıklı üst etiket, "eyebrow + selam + gri alt satır" yok; (10) koyu tema açığın tersi değil.
Renk: (11) turuncunun yeri §1.5; (12) turuncu üstüne beyaz metin ve turuncu düğme yok; (13) kırmızı yalnız Çıkış satırı, tehlikeli metin düğmeleri, tehlikeli onay ve yanlış cevap; eksik amber; (14) değişim yeşil değil, delta.
Tipografi ve metin: (15) 13 pt altı metin yok (alt çubuk 12 istisna), gövde ≥ 15; (16) büyük harfli düğme yok, `tr` dönüşümü; (17) iç kod ("D-", "Ek C", "Tur"), "Hata:" öneki, ham Exception yok; (18) "İptal" yok, "Evet" yerine eylem adı; (19) zorunlu yıldızı yok, kanvasta placeholder yok; (20) uzun adlar kesilmez (en çok 2 satır).
Veri: (21) Ek C dışı değer varsayım olarak işaretlenir; (22) veri yoksa alan çizilmez; (23) bağlamsız sayı/etiketsiz rozet yok; (24) "geçen ay" yok; (25) sabit OBP, "Deneme: N", "(Test)" yok.
Etkileşim: (26) ekranda tek birincil (kamera/deklanşör hariç); (27) sonuç anında konfeti, dönen sayaç, parlama yok, yalnız `success`; (28) önceden dolu alan yok; (29) "Yakında" sheet'i ve "Haber ver" yok; (30) ödeme, paket, coin, kayıtlı kart yok; (31) Kaydet yalnız Profil düzenlemede, anahtarlar anında kaydeder; (32) hesap silmede kelime yazdırma ve yeniden kimlik doğrulama yok, odak Vazgeç'te; (33) kart öğrenme kaydırmayla olmaz; (34) otomatik çekim, flaş, galeri yok; (35) bildirim izni bağlamsız istenmez; (36) koç görünümünde düzenleme ve öğrenciye özel eylemler yok; (37) dikkat listesinde iki kural dışında sinyal yok.
Görsel varlıklar: (38) kil yalnız onboarding, ekran düzeyi boş durum ve mağazada, ekranda en fazla bir, ders satırında yok; (39) logo ikonunda parlama/gradyan yok; ad ve avatar yalnız Anasayfa ve Hesap'ta; logo yalnız açılış ve girişte; (40) font çalışma anında indirilmez.
Tanıtım ve mağaza: (41) süre, sıralama, puan, "yapay zeka" vaadi yok; (42) ad yalnız "SMAP" ("Stundent map" yok); (43) kaldırılan özellikler görünmez; (44) puan, yorum, indirme sayısı ve turuncu metin yok; (45) kil nesneler metnin üstüne binmez, en çok 3; (46) telefonlar kesim çizgisine 40 px'ten fazla yaklaşmaz; (47) parlama, rota ve kil yalnız mağaza görsellerinde.
Denetim yöntemi (Tur 10): telefon karelerinde emoji, büyük harfli metin, iç kod, üstü çizili metin, turuncu üstünde beyaz, alt çubuk ve perde dışında bulanıklık taranır; lint: 13 pt altı metin, görsel alt metni, erişilebilirlik adı; elle: D/Y/B dili, yazı ölçeği, turuncunun yeri, koyu tema listesi.

### 6.9 Erişilebilirlik özeti

- Dokunma 48; metin ölçeği 1,3'te düzen kırılmaz; ikon düğmeleri tooltip + `semanticLabel`.
- D/Y/B tek okunuş: `Semantics(label: '86 doğru, 74 yanlış, 0 boş', excludeSemantics: true)`.
- Sayaç, grafik, akordeon (`expanded`), segment (radyo grubu), sekme (tablist), anahtar ("…, açık, anahtar"), tehlikeli satır ("…, düğme, onay ister"), hücre okunuşları ilgili bileşende.
- Canlı bölgeler: kamera ipucu `status`; gönderim `aria-live`; hata kutusu/toast `alert`; bilgi `status`.
- Kart destesi `customActions`; köşe noktaları `onIncrease/onDecrease`; saat çarkı ayarlanabilir.

### 6.10 Mağaza (Tur 11, SMAP-12): uygulama için anlamı

- Mağazada kullanılan koyu ekranlar birebir doğru olmalı: 1 → 3.3 kare 1; 2 → 4.3 kare 2; 3 → 5.1 kare 3; 4 → 5.9 kare 2; 5 → 6.4 kare 1; 6 → 7.6 kare 1 ve 8.2 kare 1; 7 → 3.8 kare 1. Dışa aktarma ×3: 1206 × 2622. Bir ekran değişirse yalnız o telefon yeniden alınır.
- Panorama ×3 9030 × 2796, x = 0, 1290, 2580… 7 dilim. App Store `appstore-01…07.png` (1320 × 2868 için %2,6 büyütme, yanlardan toplam 3 px kırpma; 1290 × 2796 aynı kaynak). Play: dilimin üst 1290 × 2293'ü → 1080 × 1920 (`play-phone-01…07.png`). Öne çıkan 1024 × 500 (`play-feature.png`). RGB, saydamlıksız PNG.
- Metinler: (1) "Denemeni okut, eksiğini kapat" / "YKS'ye hazırlanırken her denemenden ders çıkar." (2) "Optik formunu kamerayla okut" / "Köşeleri oturt, gönder; cevapların sayılır." (3) "Netin ve D/Y/B'n tek ekranda" / "Önceki denemene göre farkını da görürsün." (4) "Her soruda ne olduğunu gör" / "İşaretin, doğru cevap ve kaçırdığın konu." (5) "Gelişimini grafikte izle" / "Her deneme grafiğe yeni bir nokta ekler." (6) "Eksiklerini konu konu kapat" / "Konu anlatımı ve bilgi kartlarıyla tekrar et." (7) "Haftanı planla, bugüne odaklan" / "Eksik konularından haftalık program kur." Öne çıkan: "SMAP Denemeni okut, eksiğini kapat" + "Net, D/Y/B, konu analizi ve bilgi kartları tek uygulamada." Arama alt başlığı "Deneme okut, eksiğini kapat"; kategori "Eğitim" (örnek).
- Kesim: başlık ve alt satır üst %35'te; gerçek boyda başlık 114 px, alt satır 51 px; küçük boyda (104 px) başlıklar iki satır; telefonlar kesim çizgisine 40 px'ten fazla yaklaşmaz.
- Mağaza bileşenleri: StoreDevice (ekran 804 × 1748, kenar %3, köşe %16, gölge 0 30 60 %50 siyah); StorePanel (430 × 932; başlık 38/44·800; alt satır 17/24·500); Rota (14 px orange-500 çizgi, 44 px %22 hale, beyaz kesikli orta çizgi); zemin navy-900 → `#0A1424`, parlamalar turuncu %20 ve `#36537C` %55; kil 92–104 px (gerçek 276–312), en çok 3; uygulama ikonu arama sonucunda 64 px.
- Uygulamaya yansıyan: v1 vitrin özellikleri (optik okuma, net ve D/Y/B, soru ayrıntısı, net grafiği, konu ve bilgi kartları, haftalık program); koç özellikleri mağazada yok; ad yalnız "SMAP"; launcher ikonu 1.26 paftasına geçer.

---

## 7. Eski uygulamadan kaldırılan / eklenen

### 7.1 Kaldırılanlar

**Özellik ve menü:** coin/puan parası (`smapc.png`, `UserModel.points` gösterimi, kişi kartındaki %0 çubuğu); Anasayfa kişi kartı; Anasayfa menü ızgarası (Analiz, Denemelerim, Derslerim, Gelen Kutusu, SmapLab, Programım); içeriksiz aylık takvim; koç menüsü (SmapCoach, Analizler, Müfredat, Kaynak Takibi) ve koç öğrenci diyaloğunun 4 düğmesi (yerine StudentProfileScreen); ders girişindeki TYT/AYT/SOS-2 diyaloğu; "Yakında" diyalogları, "Yayınladığında Haber Ver", "Kaydınız Alındı"/"Talebiniz Alındı"; Analizlerim "Analiz" ve "Harita" sekmeleri, "Genel ▾" açılır filtre-sekmesi; Ödeme ve Paketler, Kayıtlı Kartlarım, İngilizce fatura satırları, paywall; Soru Bankam, "Fotoğraf Çek", sahte veri çağıran "Tekrar Dene" (Soru Detay); Oyunlar; "Beni Hatırla"; profil ve şifrenin tek sayfada olması, kalem ikonlu karışık düzenleme; bildirimlerdeki geliştirici anahtarları ("Aktif", "Kullanıcılar Görebilsin", "Varsayılan Bildirim", "Mobilde Göster", "Otomatik Güncellemeleri Aç") ve turuncu "Değişiklikleri Kaydet"; koç kartındaki "Başarısız (Derece)"; onaysız not silme ve onaysız çıkış; profil altındaki onaysız kırmızı "Hesabımı Sil" bağlantısı.

**Optik okuma:** üst çubuktaki logo ve "SMAP"; eklentinin düzenleme adımı (iki sayfa); "Hatırlatma" yönerge diyaloğu; kırmızı "GERİ" ve turuncu "GÖNDER" diyaloğu; "Denemeniz Analiz Ediliyor!" tek ekranı; "Düzenleme Yap", "Düzenlemeler (N)", "LİSTEYE EKLE", iki ayrı düzeltme sheet'i ve "Onaylıyor musunuz?" diyaloğu; sonuç akışının 3 adımı ve boş "İlerle"; sonuç ekranındaki avatar (`NetworkImage` hatası); iç kodlu SnackBar'lar ("Gönderim hatası 590: …", "Hata: …"); ölü `_submitRequest`; "Denemen Henüz Sistemde Mevcut Değil", "Üzgünüz…"; tek sayfalık "sayfa göstergesi", büyük harfli "ANLADIM", "beyaz noktalar" metni.

**Sahte ve sabit veri:** "OBP notunuz 85"; "+18.2% gecen ay"; "Deneme: N" ve "(Test)"; her derste "%75 · 15/20 · 4 Alt Başlık · 26 Madde · 8 Bilgi Kartı"; alt başlıklarda sabit "%60"; sarı/eşik renkli halka; etiketsiz rozetler (31, 60, 44, 3); önceden dolu test kullanıcıları ("student", "usernametest", "test@smap.tr", şifreler); koç formundaki "Tamamla".

**Tanıtım ve görseller:** 5 tanıtım ekranı (→ 3), `ob1-6.png` (7,7 MB), `loginImage.png` (gezginler/harita), "5 saniyede", "yapay zeka destekli", Coin 5590, Oyunlar, Gelen Kutusu vaatleri, "Tanıtımı atla" bağlantısı; eski üçgen logo ve ≈40 varyant; "Stundent map"; çok renkli ders PNG'leri ve stok menü illüstrasyonları.

**Görsel sistem:** 12'den fazla lacivert ve 9 turuncu ton; 5 gri ailesi; `#22C55E` anahtar ve indigo dialog düğmesi; 9 üst bar türü ve 6 segment kopyası; 22 köşe yarıçapı ve 57 gölge; ortada açılan dialoglar; büyük harfli düğmeler; emojili SnackBar'lar; `cupertino_icons`; gri seed.

**Kod tarafında kaldırılacak/yeniden yazılacak (silmeden önce referans kontrolü):**
- `lib/core/theme/app_colors.dart`, `app_theme.dart` (göç sonrası).
- `lib/features/profile/presentation/screens/payment_settings/**` (`current_plan_card`, `invoice_*`, `payment_invoice_mock`), `.../saved_cards/**`, `AccountNavNotifier`, `AccountRoute`, `AccountFlowScreen` case'leri.
- `home/.../lesson_navigation_helper.dart` (TYT/AYT/SOS-2 diyaloğu), `showUnderConstruction` çağrıları, menü ızgarası ve kişi kartı.
- `views/optic_mark_detection_view/omd_result_flow_view.dart` ve eski OMR diyalogları.
- `features/my_card/**` (`my_card_page.dart`, `my_card_lesson_detail_page.dart`, `my_cards_detail_page.dart`) → `LessonsScreen` + `CardDeckScreen`.
- `question_detail_page.dart`, `my_test_result_detail_screen.dart`, `lesson_detail_page.dart`, `subject_detail_page.dart`, `edebiyat_lesson_detail_page.dart`, `analytics_screen.dart` ve sekmeleri, `notification_toggle_tile.dart`, `contract_card.dart`, `add_student_dialog.dart` → yeni ekranlarla değişir.
- Giriş/kayıttaki test kimlik bilgileri; `aimType = 2` sabiti; `true = result['wrong']` hatası; `deleteCoach` parametre hatası.

### 7.2 Eklenenler

- **Temel:** koyu tema (token + D-14 ekranları); durum kalıpları (iskelet → 15 sn → hata, bölüm hatası, çevrimdışı şeridi + önbellek); Geri Al'lı toast; akış haritası; haptik sözlüğü ve hareketi azalt desteği; bileşen kiti + galeri.
- **Açılış/giriş:** Splash; 3 sayfalık tanıtım; Rol, Sınıf/Alan, Kamera ön açıklaması, Hoş geldin; sosyal giriş varyantı; gerçek Şifremi Unuttum (e-posta + 6 hane); canlı kullanıcı adı kontrolü + öneri; sözleşme onay kutusu (sürümlü); zorunlu güncelleme, oturum sona erdi, bakım, bilinmeyen rol.
- **Optik okuma:** kamera izin sheet'i ("Ayarları Aç"); 3 adımlı öğretici; kılavuzlu çekim + kenar algılama; büyüteçli köşe ekranı; yüzdeli 3 adımlı gönderim; fotoğrafı koruyan hata ve tekrar deneme; Form Kontrol (özet, sayaçlı kolonlar, boş okunan işaretli) + Cevap Düzelt; doğrulamalı talep ekranı; hata ekranları; tek ekran sonuç anı; bildirim izni ön açıklaması; koç için öğrenci seçimi.
- **Deneme:** yapışkan 4 sekme; Tümü/Yanlışlar/Boşlar; "Az soru"; "Bu Konuyu Çalış", "Kartları Çalış"; tek ekran Soru Detay.
- **Analizlerim:** süzgeç sheet'i (sınav, alan, ders); eksenli NetChart; delta'lı StatBox; süzülüp sıralanan, sayfalı Denemelerim; yerel favori.
- **Dersler ve kartlar:** eksik süzgeci ve sayaçlı segment; akordeonlu Konu Detayı + ExampleBox + ilk eksiğe kaydırma; CardSheet; ortak CardDeck (eskiden ulaşılamıyordu); Yazar sheet'i; Web'de sheet'i.
- **Anasayfa ve Program:** YKS sayacı, Bugün, Son denemen, Derslerin; Gün ve Hafta görünümü; 3 adımlı yeni program; düzenleme modu; çalışan arama; onaylı ve geri alınabilir Günü Sıfırla; Programı İptal Et.
- **Hesap:** gruplu Hesap + sürüm satırı; görüntüle/düzenle Profil (avatar, sınıf, alan değişimi yeni); gerçek Şifre; Hesabı Sil akışı; Koçluk (bağlı/bağlı değil, kod maskesi); kategorili Bildirimler + sessiz saatler + TimeWheel; Sözleşmeler + okuyucu; Bize Yaz.
- **Koç:** Koç Anasayfa (öğrenci şeridi, dikkat gerektirenler, yaklaşan görüşmeler); Türkçe vurgulu arama; Öğrenci Ekle + bir kez gösterilen giriş bilgileri; ContextStrip'li öğrenci profili; Görüşmelerim (Kiminle süzgeci, yıllı tarih); yeni görüşme, görüşme detayı, notlar (onaylı sil, geri al); koç Hesap'ında kod kartı.
- **Mağaza:** 7 karelik panorama, App Store ve Play kesimleri, öne çıkan görsel; yeni launcher ikonu ve splash.
