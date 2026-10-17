# GRUP B: ekran spesifikasyonu (SMAP-05 · 06 · 07 · 08 ve 11.14)

**Kaynaklar:** her panonun `board.html` (satır içi stiller), `styles.css`, `text.txt` dosyaları ve PNG'ler (5.4, 5.7, 7.1, 8.1 gözle kontrol edildi). Bağlam için şunlar da okundu: SMAP-11 11.3, 11.4, 11.5, 11.10 (geliştirici notları), 11.12 (token), 11.13 (bileşen), 11.15 (hareket), 11.16 (varsayımlar) ve SMAP-00 0.1–0.2 (akış).

**Kod tarafı:** smapFlutter `lib/` ve mihr_ui `lib/` yalnızca okundu, hiçbir dosya değiştirilmedi.

**Değer kuralları:**
- Tüm ölçüler pt cinsindendir (pano px = pt).
- "y=" değeri, 402×874 telefon karesinde (radius 56) öğenin üstten mutlak konumudur.
- Bir değer panoda yoksa "belirtilmemiş" yazıldı.

---

## 0. Ortak temel (grubun tamamında geçerli)

### 0.1 Kare ve yazı

**Telefon karesi:**
- Zemin bg-canvas: açık #F2F4F7, koyu #0A1424.
- Dynamic Island: 126×37, y=11.
- Home göstergesi: 134×5, açıkta #1B2232, koyuda #EDF1F6.

**Yazı:**
- Font Plus Jakarta Sans (400, 500, 600, 700, 800; woff2 dosyaları `res/` içinde).
- Tüm rakamlar `font-variant-numeric: tabular-nums` (FontFeature.tabularFigures).

**Yazı sınıfları (CSS → token):**

| Sınıf | Değer | Token |
|---|---|---|
| `.t24` | 24/32 · 700 · −0,3 | title-lg |
| `.t20` | 20/28 · 700 · −0,2 | title-md |
| `.t17` | 17/24 · 700 · −0,1 | headline |
| `.b16` | 16/24; okumada 16/26 | body-lg |
| `.b15` | 15/24 | body |
| `.c13` | 13/20 | caption |
| `.tn` | 16/24 · 600 | title-sm |
| `.tm` | 13/20 · #556173 (koyu #A9B5C6) | — |

`.mu` rengi #556173, koyuda #A9B5C6.

### 0.2 Düğmeler

Hepsi 48 yükseklik ve radius 12. Etiket 16/24 · 600, ikon aralığı 8.

| Sınıf | Rol | Açık | Koyu |
|---|---|---|---|
| `.bp` | primary | #0F294A / #FFFFFF | #C5D4E8 / #091A31 |
| `.bp.off` | primary, pasif | #DCE2E9 / #9AA5B4 | #213049 / #56657C |
| `.bo` | outline | #FFFFFF zemin, #0F294A metin, iç kenar 1,5 #0F294A | şeffaf, #C5D4E8 metin ve kenar |
| `.bq` | quiet | #E8ECF1 / #1B2232 | #213049 / #EDF1F6 |
| `.bt` | text | yatay padding 12, #1A3357, ikon aralığı 6 | #9BB3D3 |

**İkon düğmeleri:**
- `.ib`: 48×48, radius 12.
- `.xi` (sheet kapatma): 36 daire, #E8ECF1 / #1B2232; koyuda #213049 / #EDF1F6. İçinde X ikonu, 18 pt.

**mihr_ui eşlemesi.** mihr_ui'de yalnızca tema, düğmeler ve FrostedContainer var.
- `.bp` → MihrPrimaryButton.xl (48 pt). brandSolid #0F294A, radius 12 olmalı.
- `.bo` → MihrSecondaryButton.xl. Kenar gri yerine 1,5 pt #0F294A'ya override edilmeli.
- `.bq` → birebir karşılığı yok. SoftPrimary marka tonlu, tasarım nötr #E8ECF1 istiyor. Yeni "quiet" varyantı ya da tema override gerekir.
- `.bt` → MihrTertiaryButton.xl (ghost) ya da MihrLinkButton, metin rengi text-action olarak.
- Bulanıklık: alt çubukta blur(20px), scrim'de blur(8px). mihr BackdropBlurStyle preset'leri sm σ4/8px, md σ8/16px, lg σ12/24px, xl σ20/40px. CSS blur değeri σ'dır; hangi preset'e eşleneceği belirtilmemiş, karar gerekli.

### 0.3 Kabuk bileşenleri

**BottomBar (öğrenci):**
- Ölçü ve zemin: 402×102, radius 24 24 0 0. Açıkta rgba(255,255,255,0.92), koyuda rgba(18,29,49,0.92). Backdrop blur 20. Üst çizgi inset 1px #DCE2E9, koyuda #26354D.
- Sıra: Anasayfa (House), Analizlerim (ChartLine), Okut, Derslerim (BookOpen), Hesap (UserCircle).
- Öğe: 82,5 genişlik, padding-top 14, aralık 6, ikon 24. Etiket 12/16 · 600, aktifte 700.
- Renk: pasif #556173, aktif #0F294A; koyuda #A9B5C6 ve #EDF1F6.
- Aktif göstergesi: üstte 32×4, radius 0 0 4 4, #E05500 (koyu #FF8533).
- Okut: 72 genişlikli yuva içinde 56×56 radius 16 düğme, #FF6600 zemin, Camera ikonu 28 pt #0F294A. Konum top −16, left 8. Gölge 0 2 8 rgba(15,41,74,0.08); koyuda rgba(0,0,0,0.4). "Okut" etiketi 12/16 · 700, #1B2232 (koyu #EDF1F6), top 44.

**DetailBar:**
- Büyük hâl: başlık içerikte. Geri düğmesi `.ib` x=4, y=54, CaretLeft 24.
- Kısa hâl: üst 102 pt şerit, zemin kanvas (#F2F4F7 / #0A1424). Geri ve başlık `.t17` y=54'te, 48 yükseklikli satırda, aralık 4.

**RootBand:**
- Zemin #0F294A (koyuda da lacivert), padding-top 62, radius 0 0 24 24.
- Başlık `.bnt`: 56 yükseklik, padding 0 16, 24/32 · 700 · −0,3, #FFFFFF.
- Bant içi sekmeler `.tabsn`: 48 yükseklik, alt boşluk 8. Etiket 15/24 · 600 #C5D4E8; aktif #FFFFFF · 700. Gösterge 3 pt, radius 999, **#FF6600**, genişliği etiket kadar.
- Bant içi segment `.bseg`: ray #1A3357, padding 4, aralık 4, radius 12. Düğme 36 yükseklik, radius 8, 14/20 · 600 #C5D4E8. Seçili #FFFFFF zemin, #0F294A metin. Sarmalayıcı padding 0 16 16.
- Bant yüksekliği: sekmeliyse 174 (içerik y=190'dan başlar), segmentliyse 178 (içerik y=194).

**InScreenTabs (`.tabs`):**
- 48 yükseklik, alt çizgi inset 1px #DCE2E9 (koyu #26354D).
- Etiket 15/24 · 600 #556173; aktif #1B2232 · 700. Koyuda #A9B5C6 ve #EDF1F6.
- Gösterge 3 pt, radius 999, #E05500 (koyu #FF8533). Genişlik etiket kadar: Genel 46, Sorular 62, Konular 64, Kartlar 58.

**Segment (`.seg`):**
- Ray #E8ECF1, padding 4, aralık 4, radius 12. Düğme min-h 36, radius 8, 14/20 · 600 #556173. Seçili #0F294A / #FFFFFF.
- Koyu: ray #213049, metin #A9B5C6, seçili #C5D4E8 / #091A31.

**Sayaçlı segment (`.seg.cnt`):**
- Düğme min-h 48, padding 4, iki satır.
- Üst satır `b`: 14/20 · 700 #1B2232 (seçili #FFFFFF).
- Alt satır `i`: 13/20 · 500, rengi #556173 devralır (seçili #C5D4E8).
- Koyu: `b` #EDF1F6, seçili `b` #091A31, seçili `i` #1A3357.
- Bir seçeneğin verisi yoksa yalnızca o seçeneğin sayaç satırı çizilmez.

**Chip ve etiket:**
- Chip (`.ch` / `.chp`): 40 yükseklik, padding 0 14, radius 999, #FFFFFF, 15/20 · 600 #1B2232, iç kenar 1px #697586, aralık 6. Seçili #0F294A / #FFFFFF, kenarsız. `.ch` koyu: şeffaf, #EDF1F6, kenar #6B7D97. `.chp` için koyu kural belirtilmemiş.
- Nötr etiket `.tg`: 24 yükseklik, padding 0 8, radius 8, #E8ECF1 / #1B2232, 13/20 · 600. Koyu #213049 / #EDF1F6.
- EksikTag `.ek`: 24 yükseklik, padding 0 8, radius 8, #FCF1D9 zemin, #8A5A00 metin, 13/20 · **700**, aralık 4, Flag ikonu 14 (stroke 20). Koyu #33270F / #F2C46D.

**D/Y/B ailesi.** Glifler: Doğru Check, Yanlış X, Boş Minus.

| | Açık | Koyu |
|---|---|---|
| Doğru | #0B6E3E | #52CC8E |
| Yanlış | #D8333A | #F07575 |
| Boş | #7E8A9B | #6E7C92 |
| Glif rengi | #FFFFFF | #0A1424 |

- **DybLarge:** üç sütunlu grid, aralık 12. Her sütunda satır (aralık 8): `.c24` çip (24 daire, glif 14, stroke 28) ve etiket `.dyl` (15/24 · 600 #556173). Altında değer `.dyv`: 24/32 · 700 · −0,4, üst boşluk 4.
- **DybSmall `.sm`:** `.c16` çip (16 daire, glif 10, stroke 32), aralık 4. Değer 15/20 · 700, harf ya da kelime 13 · 500 #556173 (koyu #A9B5C6). Grup aralığı 4/14; konu satırında kelimeli hâli 4/10.
- **StackedBar `.bar`:** 12 yükseklik, radius 999, parçalar arası 2, parça genişliği adet oranında (flex). Adet 0 ise parça çizilmez.

**Card:** `.card` #FFFFFF (koyu #121D31), radius 16.

**BottomSheet:**
- Kap `.sh`: #FFFFFF (koyu #18263D), radius 24 24 0 0, yükseklik içeriğe göre.
- Tutamaç `.hd`: 36×4, #C3CBD6 (koyu #34445F), üst boşluk 8.
- Başlık satırı `.shh`: padding 12 12 0 24, aralık 8. Başlık `.t20`, padding-top 8.
- Alt bant `.shf`: padding 16 24 42, sütun, aralık 12.
- Scrim: rgba(9,26,49,0.48), blur 8. `.scrim.dk2`: rgba(2,6,14,0.64).

**Form kontrolleri:**
- Alan etiketi `.fl`: 14/20 · 600, alt boşluk 8.
- Yardım `.hp`: 13/20 #556173, üst boşluk 6.
- Radio satırı `.cb`: min-h 48, aralık 12, 15/24. Radio 24 daire: seçili iç kenar 7 #0F294A, seçili değil 2 #697586.
- Checkbox `.cbx`: 24, radius 4, iç kenar 2 #697586 (koyu #6B7D97).

**Toast:** min-h 48, padding 12 16, radius 12, #0F294A, #FFFFFF 15/24, gölge 0 8 24 rgba(15,41,74,0.16). Eylem düğmesi 48 yükseklik, padding 0 4, 15 · 700 #FFFFFF. Koyu varyant belirtilmemiş.

**Durum kalıpları:**
- OfflineStrip `.off`: min-h 40, padding 8 16, #1B2232 zemin, #FFFFFF 13/20 · 600, aralık 10, WifiSlash 18. Koyu varyant belirtilmemiş.
- Skeleton `.sk`: #E8ECF1, radius 8. Koyu belirtilmemiş; token'a göre bg-sunken koyu #213049.
- ErrorState (ekran): left/right 32, ortalı.
  - #FCEAEA zeminli 80 daire içinde #C42D35 WarningCircle 40.
  - Başlık `.t20`, üst boşluk 20.
  - Açıklama `.b15.mu`, üst boşluk 6.
  - `.bq` "Tekrar Dene", tam genişlik, üst boşluk 20.
- Bölüm boş kartı: padding 24, ortalı. Başlık `.b16` · 700, açıklama `.c13.mu` (üst boşluk 4), isteğe bağlı `.bt` (üst boşluk 8).

### 0.4 İkonlar, hareket, haptik

**İkonlar (Phosphor Regular, 256 ızgara, stroke 16):** X, Check, Minus, CaretLeft, CaretRight, CaretUp, CaretDown, Image, ArrowUp, Cards, Bell, WarningCircle, WifiSlash, Sliders (dikey; muhtemelen "Sliders"), Star (seçiliyken dolu), Camera, House, ChartLine, BookOpen, UserCircle, Flag, ArrowSquareOut.

Ders glifleri ve ders renkleri (11.12):

| Ders | Glif | Açık zemin · vurgu | Koyu zemin · vurgu |
|---|---|---|---|
| Türkçe | TextAa | #F6ECE6 · #93573C | #2D211C · #E2A98D |
| Edebiyat | Feather | #F6E7EC · #8A2F4E | #301A27 · #E494BE |
| Tarih | Bank | #FBF1DA · #8C6106 | #2C2513 · #E3B651 |
| Coğrafya | Globe | #E1EFFA · #1E6FAE | #12293C · #7DB9EC |
| Matematik | MathOperations | #FDE8E8 · #C42A36 | #341B1B · #F7847F |
| Geometri | Angle | #E7E9FB · #4450BE | #1D2144 · #A3ABF4 |
| Fizik | Atom | #DDF2F2 · #08737A | #0E2B2D · #5FCBD0 |
| Kimya | Flask | #F7E8F7 · #93359A | #271B33 · #C89AE3 |
| Biyoloji | Dna | #E4F3E3 · #2B7A35 | #16291A · #80CC89 |

**Hareket token'ları (11.12 / 11.15):**
- Süre: instant 100, fast 150, base 250, slow 350, loop 1200 ms.
- Eğri: standard Cubic(0.2,0,0,1), enter Cubic(0,0,0,1), exit Cubic(0.3,0,1,1).
- Sheet açılış 350, kapanış 250 ms. Toast 250 ms; ekranda 4 sn, Geri Al varsa 6 sn.
- İskelet 1200 ms döngü. 15 sn içinde veri gelmezse hata durumuna geçer.

**Haptik:** selectionClick, mediumImpact, success, error.

**Delta rengi:** #36537C (koyu #9BB3D3). Tur 10 kararı: yeşil yalnızca "Doğru" içindir (bkz. §6 madde 1).

### 0.5 Mevcut kod ve backend (smapFlutter)

**Yönlendirme:** Navigator 1 kullanılıyor. MaterialPageRoute push'ları var; named route yalnızca `/onboarding`, `/login`, `/home`. go_router yok.

**Paketler:** provider, dio, fl_chart ^1.2.0, flutter_card_swiper ^7.2.0, appinio_swiper.

**Öğrenci kök sekmeleri:** HomeFlowScreen, AnalyticsView, MyCardScreen (şu an "Derslerim" sekmesi), AccountFlowScreen.

**Kullanılan uç noktalar:**
- AnalysisRepository: `GET /student/getLineChartData`, `GET /student/getLessons`, `GET /student/getTotal`, `POST /student/getMyMockExams`, `GET /student/getMexamSubjectDetail`, `GET /student/getMexamItemDetail`, `POST /student/getQuestion`, `GET /student/mainSubjects`, `GET /student/getSubSubjects`, `POST /student/getItems`, `GET /student/yazarEserMainSubjects`, `GET /student/getSubjectAuthors`, `GET /student/learnedItem`.
- CardsRepository: `GET /student/getInfoCardsInfo`, `GET /student/getLessonInfoCards`, `GET /student/learnedCard`, `GET /student/addFavoriteMobil`.
- HomeRepository: `GET /student/getLessonsTotalMissing`.
- OMD (optik okuma): `answerArray` yanıtı `mexamFound` ve `answersArray` taşır.

**Parametre notları:** `mexam.type == 1` TYT demektir (o zaman aimType gönderilmez). `getMyMockExams`: `perPage: 8`, gövde `{filter:{types,nets,dates}}`.

---

## 1. SMAP-05: Deneme Sonucu ve Detay

### 5.1 Sonuç Anı (3 kare)

- **Route önerisi:** `/exam/result`, ResultMomentScreen. Tam ekran modal; alt çubuk yok.
- **Mevcut kod:** views/optic_mark_detection_view/omd_result_flow_view.dart (eski üç adımlı akış).
- **Amaç:** Okuma bittiğinde tek ekranda net, D/Y/B, fark, varsa puan, eklenen kartlar ve "Detaylı Analiz" eylemi.

**Düzen (kare 1, AYT · EA):**
1. Kapat düğmesi (`.ib`, X 24, aria "Kapat"): x=4, y=54.
2. Kimlik satırı, y=106, aralık 16, dikey ortalı.
   - Kapak yer tutucusu 56×76, radius 8, #DCE2E9 zemin, Image 24 #697586 (aria "Deneme kapağı").
   - Yayınevi `.c13` · 600 mu.
   - Ad `.t17`, üst boşluk 2.
   - Etiket satırı (üst boşluk 6, aralık 8): tür etiketi (24 yükseklik, padding 0 8, radius 8, #E8ECF1, 13/20 · 600) ve tarih `.c13` mu.
3. Net bloğu, y=206, role=status.
   - "67,5": 56/64 · 800 · −1,5 (metric-xl).
   - "net": 17/24 · 600 mu, baseline hizalı, aralık 8.
   - Delta satırı `.b15`, aralık 6, üst boşluk 2: ArrowUp 18 (stroke 20) #36537C, "+8,25" #36537C · 700, ardından mu açıklama.
4. DybLarge, y=322.
5. Puan türü segmenti `.seg`, y=404, aria "Puan türü": Eşit Ağırlık (seçili) · Sayısal · Sözel.
6. StatBox ikilisi, y=464: 2 sütun, aralık 8, `.card` padding 16. Değer 24/32 · 700 · −0,4; etiket `.c13` · 600 mu.
7. Alan neti, y=564: "Eşit Ağırlık neti 40" `.b15` · 700; altında `.c13` mu testler satırı.
8. Kart satırı, y=632 (`button.card`): min-h 64, padding 12 16, aralık 12.
   - 40 daire #E2EAF4 zemin, Cards 22 #36537C (koyu #1A2B45 / #9BB3D3).
   - Metin `.b15` · 600, esnek.
   - CaretRight 20, mu renk.
9. Eylem satırı, y=778, aralık 12, alta sabit (kare 2'de de aynı y): `.bq` "Anasayfa" 132 genişlik + `.bp` "Detaylı Analiz" esnek.

**Kare 2 (TYT, eksik veriyle):**
- Yayınevi yok. Ad "TYT Genel Deneme 9", etiket "TYT", tarih "28 Eylül 2026".
- Net "74,75". Delta "+3,25" ve "önceki TYT denemene göre".
- D/Y/B: 80 · 21 · 19.
- Segment, puan, alan neti ve kart satırı **hiç çizilmez** ("0" ya da tire de yok). TYT'de puan türü sekmesi yok.

**Metinler (kare 1):** "Örnek Yayınları" · "Türkiye Geneli Deneme 6" · "AYT" · "5 Ekim 2026" · "67,5" · "net" · "+8,25" · "önceki AYT denemene göre" · "Doğru" 86 · "Yanlış" 74 · "Boş" 0 · "Eşit Ağırlık" · "Sayısal" · "Sözel" · "412,63" · "Yerleştirme puanı" · "48.215." · "Sıra" · "Eşit Ağırlık neti 40" · "Türk Dili ve Edebiyatı–Sosyal Bilimler 1 ve Matematik" · "Bu denemeden 23 bilgi kartı eklendi" · "Anasayfa" · "Detaylı Analiz".

**Ekran okuyucu:** "Türkiye Geneli Deneme 6, 67,5 net, önceki AYT denemene göre 8,25 artış. 86 doğru, 74 yanlış, 0 boş."

**Durumlar:**
- Eksik alan hiç çizilmez.
- Sayısal ya da Sözel seçilince yalnızca o alanın neti görünür; o alanın puanı ve sırası yoksa kutular çizilmez.
- OBP satırı yok.
- Loading, error ve empty durumu bu panoda belirtilmemiş; ekran tek istekten beslenir (11.2).

**Etkileşim ve gezinme:**
- "Detaylı Analiz" → 5.3 Genel.
- Kart satırı → 5.6 Kartlar.
- "Anasayfa" → 3.1.
- Kapat → hedefi belirtilmemiş.
- İlk başarılı okumada ayrılırken önce 5.2 açılır.
- Varsayım 3.1: Deneme Detay açılınca kamera akışı kapanır, ekran Analizlerim yığınına yerleşir.

**Veri ve kaynak:**
- `mexamFound` / sonuç nesnesi: mexam{_id, name, type, image}, yayınevi, tarih, true, wrong, pass, net.
- Önceki aynı türdeki denemeye göre delta. Kaynak belirtilmemiş: sunucuda yeni alan ya da getLineChartData'nın son iki noktası.
- points[], ranks[]: aimType (alan) indeksine göre.
- aytNets {EA 40, SAY 37,5, SÖZ 30} (varsayım 2.10).
- Kart sayısı: getTotalInfoCard; yanıtta yoksa satır çizilmez (11.2).
- Net hesabı sunucuda: D − Y ÷ 4.

**Hareket ve haptik:**
- Gelişte bir kez success haptiği.
- İçerik 250 ms'de 8 pt yukarı kayarak belirir; hareketi azalt açıksa yalnızca opaklık.
- Konfeti, dönen sayaç ve parlama yok.

**Koyu tema (kare 3):**
- Kapak #213049 zemin, ikon #6B7D97. Etiket #213049.
- Delta #9BB3D3.
- D/Y/B çipleri #52CC8E, #F07575, #6E7C92; glif #0A1424.
- Kartlar #121D31. Kart satırı ikonu #1A2B45 / #9BB3D3.
- Düğmeler koyu rollerde.

**Pano notları:** "Kapak yer tutucu 56 × 76 (sunucudan gelir); yayınevi ve ad ayrı satırda (Ek D-32), "(Test)" eki ve "Deneme: N" yok (Ek D-33)."

### 5.2 Bildirim İzni (1 kare)

- **Route önerisi:** route yok. NotificationPrimerSheet, 5.1 üstünde modal bottom sheet.
- **Amaç:** Bildirim iznini yalnızca ilk başarılı okumada, sonuç anından ayrılırken bir kez sormak.

**Düzen:**
- Arkada 5.1 görünür kalır; üstünde scrim.
- Sheet: tutamaç; ortalı başlık bloğu (padding 28 24 0).
  - 64 daire #E2EAF4 (navy-100) zemin, Bell 32 #0F294A.
  - Başlık `.t20`, üst boşluk 16.
  - Açıklama `.b15.mu`, üst boşluk 8.
- Kapat düğmesi yok.
- `.shf`: `.bp` "Bildirimlere İzin Ver" ve `.bq` "Sonra".

**Metinler:** "Sonucun hazır olunca haber verelim mi?" · "Sistemde olmayan bir denemeyi okuttuğunda analizini hazırlayınca bildirim gönderelim. Hesap › Bildirimler'den istediğin zaman kapatabilirsin." · "Bildirimlere İzin Ver" · "Sonra".

**Etkileşim:**
- "Bildirimlere İzin Ver" sistem iletişim kutusunu açar. Kutudan sonra sheet 250 ms'de kapanır ve hedef ekrana gidilir.
- "Sonra" bir daha sormaz; izin Hesap › Bildirimler'den açılır.
- Bayrak shared_preferences'ta `notif_primer_shown`.
- Paket: permission_handler.
- **Planlı:** Bildirim gönderimi Tur 8 kategorileriyle gelecek; o güne kadar bu sheet kapalı (varsayım 2.17).

**Hareket:** Sheet 350 ms, haptik yok.

**Koyu tema:** Pano yok. CSS `.dk .sh` #18263D, `.hd` #34445F; düğmeler koyu rollerde. Bell dairesinin koyu rengi belirtilmemiş (info-bg koyu #1A2B45 önerilir).

### 5.3 Deneme Detay · Genel (3 kare)

- **Route önerisi:** `/analytics/exam/:examId?tab=genel`, ExamDetailScreen. SliverAppBar ve yapışkan SliverPersistentHeader sekmeler (11.3).
- **Mevcut kod:** analytics/.../my_test_result_detail_screen.dart ve my_test_results_detail_widgets.dart.
- **Amaç:** Başlıkta net, D/Y/B ve puan; Genel sekmesinde her testin tam adı ve yığılmış çubuğu.

**Düzen (kare 1, AYT, kaydırılmamış):**
1. Geri düğmesi (CaretLeft): x=4, y=54.
2. ExamHeader, y=102, aralık 12.
   - Kapak 48×64, radius **6**, #DCE2E9, Image 22.
   - Yayınevi `.c13` · 600 mu.
   - Ad `.t20`, üst boşluk 2.
   - `.tg` "AYT" ve tarih `.c13` mu (üst boşluk 4, aralık 8).
3. Net, y=182: 40/48 · 800 · −1 (metric-lg) ve "net" (17 · 600 mu).
4. DybLarge, y=242.
5. Puan kartı, y=318: `.card`, padding 12 16.
   - Alan adı "Eşit Ağırlık" `.c13` · 600 mu.
   - İki sütun, aralık 12, üst boşluk 2: "412,63" / "Yerleştirme puanı" ve "48.215." / "Sıra" (24/32 · 700).
6. InScreenTabs, y=430, aria "Deneme bölümleri": Genel · Sorular · Konular · Kartlar.
7. Test listesi kartı, y=494, padding 0 16. Satırlar padding 14 0; ayraç 1px #E8ECF1 (koyu #26354D).
   - Satır içi: ad `.tn` (sarar) ve sağda net 17/24 · 700 nowrap + "net" `.tm` · 500.
   - StackedBar, üst boşluk 10.
   - Sayaç satırı (üst boşluk 8, aralık 12): DybSmall harfli ("23 D 17 Y 0 B") ve sağa yaslı `.tm` "40 soru".
8. BottomBar, aktif sekme Analizlerim.

**Kare 2 (kaydırılmış):**
- DetailBar kısa hâlde ("Türkiye Geneli Deneme 6", ad iki satıra kadar).
- Sekmeler y=102'ye yapışır. Liste y=166.
- y=598'de dipnot (left/right 20, `.c13.mu`): "Net = doğru − yanlış ÷ 4; boş neti etkilemez." ve "Puan türüne göre net: Eşit Ağırlık 40 · Sayısal 37,5 · Sözel 30." (araları 4).

**Kare 3 (TYT, puansız):**
- Yayınevi ve puan kartı çizilmez. Sekmeler y=318, liste y=382.
- Boş parça gri çubuk olarak görünür (Temel Matematik 13 boş).

**Metinler (testler):**
- AYT: "Türk Dili ve Edebiyatı–Sosyal Bilimler 1" 18,75 (23/17/0, 40 soru) · "Sosyal Bilimler 2" 11,25 (17/23/0, 40) · "Matematik" 21,25 (25/15/0, 40) · "Fen Bilimleri" 16,25 (21/19/0, 40).
- TYT: "Türkçe" 30,5 (32/6/2, 40) · "Sosyal Bilimler" 13 (14/4/2, 20) · "Temel Matematik" 20,75 (22/5/13, 40) · "Fen Bilimleri" 10,5 (12/6/2, 20).
- Çubuk aria: "40 sorudan 23 doğru, 17 yanlış, 0 boş".

**Grafik (StackedBar):**
- Tip: yatay yığılmış çubuk, test başına bir tane.
- Kodlama: parça genişliği adet; sıra D → Y → B; renkler D/Y/B token'ları.
- Eksen yok. Değerler sayaç satırında yazılı.

**Veri:**
- Başlık ve test kırılımı tek istekten gelir: sonuç nesnesindeki `lessonInfo` JSON string'i. Test başına name, true, wrong, pass, net, soru sayısı.
- Test neti sunucudan gelir; istemci hesaplamaz.
- Puan ve sıra: points/ranks dizileri, alan indeksiyle.
- Eski hata düzeltilecek: `true = result['wrong']`.

**Hareket:**
- Büyük başlık kaydırınca 250 ms'de kısa bara iner (standard).
- Sekme değişimi: gösterge 250 ms kayar, içerik 150 ms çapraz geçiş, selectionClick.
- Çubuklar ilk açılışta 350 ms'de dolar; hareketi azalt açıksa doğrudan son hâl.

**Koyu tema:** 5.9.

### 5.4 Deneme Detay · Sorular (3 kare)

- **Route önerisi:** `?tab=sorular`, QuestionGrid (SliverGrid, 5 sütun).
- **Amaç:** Testler akordeonda; her soru için numara, senin işaretin ve yanlışsa doğru cevap. Tümü / Yanlışlar / Boşlar süzgeci.

**Düzen:**
1. Kısa bar ve sekmeler (y=102).
2. Sayaçlı segment, y=166, aria "Soru süzgeci": "Tümü"/"160 soru", "Yanlışlar"/"74 yanlış", "Boşlar"/"boş yok".
3. Akordeon yığını, y=238, kartlar arası 8. Her kart `.card`, taşma kırpılır.
   - Başlık düğmesi: padding 12 12 12 16, aralık 8. Ad `.tn` (sarar); sayaç satırı (üst boşluk 4, aralık 4/12): DybSmall ve `.tm` "40 soru".
   - Ok: açıkken CaretUp 24, kapalıyken CaretDown 24 (mu renk).
   - Izgara: padding 0 8 8, **aralık 6**, 5 sütun (~66 pt hücre genişliği).
4. QuestionCell `.qc`: 76 yükseklik, radius 8, padding 6, ortalı sütun, space-between.
   - Numara `.qn`: 13/20 · 600 #556173, sola yaslı.
   - Durum çipi `.qs`: mutlak konum top 8 right 8, `.c16`.
   - İşaret `.qm`: 20/24 · 700.
   - Doğru cevap `.qa`: "Doğru B", 13/16 · 600 #0B6E3E. Doğru cevaplı hücrede `visibility:hidden` (yükseklik korunur).
   - Zeminler: doğru #FFFFFF + iç kenar 1px #DCE2E9; yanlış #FCEAEA (dyb-wrong-bg); boş bg-sunken #E8ECF1 (boş hücre çizilmedi, değer nottan).
   - Aria örnekleri: "Soru 1, yanlış, işaretin E, doğru cevap B"; "Soru 6, doğru, işaretin B".

**Kareler:**
- **Kare 1 (Tümü):** İlk test açık, 40 hücre.
  - Yanlış sorular: 1, 2, 3, 4, 5, 7, 8, 11, 12, 13, 15, 18, 25, 31, 33, 35, 37.
  - İşaretler: 1 E→B, 2 B→E, 3 A→B, 4 A→D, 5 E→C, 6 B, 7 C→A, 8 C→A, 9 A, 10 B, 11 A→D, 12 E→B, 13 E→A, 14 A, 15 C→D, 16 D, 17 D, 18 C→B, 19 B, 20 B, 21 D, 22 E, 23 E, 24 C, 25 A→E, 26 C, 27 A, 28 A, 29 E, 30 C, 31 C→A, 32 D, 33 E→C, 34 E, 35 A→D, 36 B, 37 B→E, 38 E, 39 D, 40 A.
  - Şıklar örnektir (varsayım 3.3).
- **Kare 2 (Yanlışlar):** İlk testte 17 hücre. Kapalı testler sayaçlarıyla durur; açılınca kendi yanlışları gelir.
- **Kare 3 (Boşlar, boş yok):** Bölüm boş kartı, y=238, padding 28 24, ortalı.
  - `.c24` 32×32 #7E8A9B, Minus 18.
  - Başlık "Boş bıraktığın soru yok" `.b16` · 700, üst boşluk 12.
  - Açıklama "Bu denemedeki 160 sorunun hepsini işaretledin." `.c13.mu`, üst boşluk 4.
  - `.bt` "Tüm Soruları Göster", üst boşluk 8.
  - Görsel yok.

**Etkileşim:**
- Hücreye dokunmak → 5.7. Basılıyken 0,97 ölçek, 100 ms.
- Akordeon 250 ms (standard); açılan bölüm görünür alana kayar.
- Süzgeç değişince ızgara 150 ms çapraz geçiş, selectionClick.

**Veri:** Soru başına sıra, işaret, doğru cevap ve durum. Kaynak belirtilmemiş: mevcut kodda `questionsArrStr` / `lessonInfo` görülüyor, teyit gerekli. Sorular sekmesi ayrı ve tembel yüklenir.

**Koyu tema:** 5.9 kare 2.

### 5.5 Deneme Detay · Konular (1 kare)

- **Route önerisi:** `?tab=konular`, TopicList.
- **Amaç:** "Neyi çalışmalıyım?" sorusuna cevap: zayıftan güçlüye konu listesi.

**Düzen:**
1. Kısa bar ve sekmeler.
2. Öne çıkan kart, y=166, padding 16.
   - "En çok kaçırdığın konu" `.c13` · 600 mu.
   - "Cumhuriyet Edebiyatı" `.t17`, üst boşluk 2.
   - "12 sorudan 7'sini kaçırdın." `.b15`, üst boşluk 2.
   - `.bp` "Bu Konuyu Çalış", üst boşluk 12.
3. Ders başlığı, y=348.
   - "Türk Dili ve Edebiyatı" `.t17` ve sağda "zayıftan güçlüye" `.c13.mu` (baseline, iki uçta).
   - DybSmall "12 D 12 Y 0 B" ve "24 soru" (üst boşluk 4, aralık 12).
4. Konu kartı, y=412. TopicResultRow `.tr`: aralık 12, padding 12 16, min-h 72, ayraç 1px #E8ECF1.
   - Ad `.tn`, kesilmez.
   - Kelimeli DybSmall ("0 doğru 2 yanlış 0 boş") ve gerekiyorsa `.tg` "Az soru" (aralık 6/10, üst boşluk 6).
   - Sağda yüzde halkası.

**Konu satırları:**
- "İslamiyet Etkisindeki Türk Edebiyatı (Divan-Halk Edebiyatı)": 0/2/0, Az soru, %0
- "Nazım Bilgisi": 0/1/0, Az soru, %0
- "Söz Sanatları": 0/1/0, Az soru, %0
- "Cumhuriyet Edebiyatı": 5/7/0, %42
- "Batı Edebiyatı ve Akımları": 1/0/0, Az soru, %100

**Grafik (yüzde halkası):**
- SVG 48×48, r=21, stroke 5, ray #E8ECF1.
- Yay #264066 (chart-line), linecap round, −90° döndürülmüş (üstten saat yönünde), dasharray = oran × 131,9. Örnek: %42 → 55,4.
- Merkezde "%42": 13 · 700 #1B2232.
- Tek renk, eşik rengi yok. %0'da yalnızca ray çizilir.

**Kurallar:**
- Yüzde = (d × 100 / n), en yakın tam sayıya yuvarlanır.
- Sıra zayıftan güçlüye; eşitlikte soru sayısı çok olan önce.
- n ≤ 2 ise "Az soru" etiketi.
- Öne çıkan kart en çok yanlışa göre seçilir; eşitlikte yüzdesi düşük olan (varsayım 3.6).
- Satırın tamamı dokunulur → konu detayı (7.3).
- "Bu Konuyu Çalış" → 7.3, ilk eksik madde açık.

**Veri:** `GET /student/getMexamSubjectDetail?mexamId`. Ders başına D/Y/B ve konu bazında d/y/b/n.

**Koyu tema:** 5.10.

### 5.6 Deneme Detay · Kartlar (1 kare)

- **Route önerisi:** `?tab=kartlar`, ExamCardList.
- **Amaç:** Bu denemeden eklenen bilgi kartları, derse göre gruplu.

**Düzen (başlık açık):**
- ExamHeader ve puan kartı 5.3 ile aynı. Sekmeler y=430.
- Bilgi kartı, y=494, padding 16, aralık 12.
  - 40 daire #E2EAF4, Cards 22 #36537C.
  - "23 bilgi kartı eklendi" `.t17`.
  - "Bu denemede yanlış ve boş bıraktığın sorulardan." `.c13.mu`.
- `.bp` "Kartları Çalış", y=590.
- Ders grubu başlığı, y=662, aralık 10: karo 32×32, **radius 10**, #FBF1DA zemin, Bank 20 #8C6106; "Tarih" `.t17`.
- Kart listesi, y=706, aralık 8. `button.card` padding 16:
  - Başlık `.b16` · 600.
  - Gövde `.b15.mu`, üst boşluk 4.
  - `.tg` "Eksiklerimde", üst boşluk 12.

**Kartlar:**
- "Edirne-Segedin Antlaşması (1444)" / "Haçlılarla Osmanlı Devleti'nin imzaladığı ilk antlaşma. Tuna sınır olur, on yıl savaş yapılmaz."
- "Otlukbeli Savaşı (1473)" / "Fatih Sultan Mehmet – Uzun Hasan (Akkoyunlu)."

**Kurallar:**
- Grup içinde sıra, denemedeki soru sırasıdır.
- Ders başına sayı yoksa grup sayacı çizilmez.
- Yeni kart eksik kabul edilir.

**Etkileşim:**
- "Kartları Çalış" → 8.1, bu denemenin kartlarıyla.
- Karta dokunmak → kart sheet'i (7.3 kare 3).
- Kaydırınca sekmeler yapışır.

**Veri:** `GET /student/getMexamItemDetail?mexamId`. Kart item{_id, name, desc, mainSubject{name}}, favorite.

**Koyu tema:** Pano yok. Token'lar ve `.dk` kurallarıyla türetilir; Tarih karosu koyuda #2C2513 / #E3B651.

### 5.7 Soru Detay (2 kare)

- **Route önerisi:** `/analytics/exam/:examId/question?lesson=:lessonOrder&q=:questionOrder`, QuestionDetailScreen.
- **Mevcut kod:** question_detail_page.dart (şu an iki sekmeli ve CardSwiper'lı).
- **Amaç:** Tek ekranda soru numarası, işaretin, doğru cevap, açıklama ve ilgili kartlar.

**Düzen (kare 1, yanlış):**
1. Geri düğmesi.
2. Başlık, y=102: "31. soru" `.t24`. Altında "Türk Dili ve Edebiyatı–Sosyal Bilimler 1 · Tarih" `.c13` · 600 mu (sarar).
3. Cevap kartı, y=174, padding 16, 2 sütun, aralık 12.
   - Her sütun: etiket `.c13` · 600 mu; satır (aralık 10, üst boşluk 6): 24 çip (glif 14, stroke 32) ve harf 32/40 · 800.
   - "İşaretin" C (X çipi), "Doğru cevap" A (Check çipi).
4. "Soru Analizi" `.t17`, y=290; açıklama `.b15`, üst boşluk 6.
5. İlgili kartlar başlığı, y=430: "İlgili kartlar" `.t17` ve "2 kart" `.c13` · 600 mu.
6. Yatay carousel, y=466: left 16, right 0, aralık 8, kart 264 genişlik, padding 16. İkinci kart kenardan taşar.
7. `.bp` "Kartları Çalış", y=630.
8. Telif notu, y=700, aralık 10: Image 20 mu ve "Sorunun fotoğrafı telif hakları nedeniyle paylaşılamıyor." `.c13.mu`.
9. BottomBar, aktif Analizlerim.

**Kare 2 (doğru, açıklama yok):**
- "6. soru" / "Türk Dili ve Edebiyatı–Sosyal Bilimler 1 · Türk Dili ve Edebiyatı".
- Cevap kartı y=198, satır düzeni, aralık 16: "İşaretin" B ve "İşaretin doğru cevap." `.b15` · 600.
- "Soru Analizi" y=318: "Bu soru için çözüm açıklaması yok." `.b15.mu`.
- İlgili kart yoksa bölüm hiç çizilmez. Telif notu y=420.

**Kurallar:**
- "Fotoğraf Çek" ve "Soru Bankam" yok.
- Önceki/sonraki soru gezinmesi yok (varsayım 3.9).

**Etkileşim:**
- Karta dokunmak → kart sheet'i.
- "Kartları Çalış" → 8.1.
- Geri → ızgara.

**Veri:** `POST /student/getQuestion {mexam, questionOrder, lessonOrder}`. Yanıt: question.desc, question.items[] (mainSubject.name, name, desc), cards[], description.

**Koyu tema:** Pano yok, türetilir.

**Pano hatası:** Bu panoda cevap çiplerinin zemin rengi tanımsız; PNG'de çip görünmüyor. Niyet D/Y/B rengi: yanlış #D8333A, doğru #0B6E3E (bkz. §6).

### 5.8 Deneme Detay · Durumlar (4 kare)

**Kare 1, İskelet:**
- Sekmeler hemen gelir ve dokunulabilir.
- İskelet blokları (x, y, ölçü):
  - (16, 102) 48×64, radius 6
  - (76, 106) 110×16
  - (76, 130) 220×24
  - (76, 160) 90×16
  - (16, 186) 120×40
  - D/Y/B: x=16, 146, 276; y=246; her biri 100×52
  - Puan bloğu: (16, 318) 370×96, radius 16
- Sekmeler gerçek, y=430.
- Kart y=494, padding 16, aralık 14, içinde 3 tekrar: 16 yükseklik (genişlik 220/150/120) ve 12 yükseklik radius 999.
- Parıltı 1200 ms; hareketi azalt açıksa düz. 15 sn'de veri yoksa kare 3.

**Kare 2, Ders verisi yok (TYT başlığıyla):**
- Bölüm boş kartı, y=382: "Ders kırılımı yok" / "Netin ve doğru, yanlış, boş sayıların hesaplandı; bu deneme için ders bazında sonuç gelmedi."

**Kare 3, Hata (ekran düzeyi):**
- y=230: "Deneme yüklenemedi" / "Bağlantını kontrol edip tekrar dene." / "Tekrar Dene".
- "Tekrar Dene" iskelete döner. Hata gelince haptik yok; "Tekrar Dene" başarısızsa error haptiği.

**Kare 4, Çevrimdışı:**
- Kısa bar, altında OfflineStrip (y=102, ters yüzey): "Çevrimdışısın. Son kaydedilen veriler gösteriliyor."
- Sekmeler y=142, liste y=206. Önbellekteki veri gösterilir.
- Bağlantı gelince şerit 250 ms'de kapanır; 11.15'e göre 2 sn "Bağlandın" gösterilir.

**Kurallar:**
- İskelet yalnızca ilk yüklemede.
- Sorular, Konular ve Kartlar ayrı yüklenir; her biri kendi bölüm düzeyi boş ve hata durumunu taşır.
- Bölüm boş metinleri: "Bu deneme için soru ayrıntısı yok." · "Konu analizi henüz hazır değil." · "Bu denemeden kart eklenmedi."
- Ekran bütünüyle yalnızca başlık verisi gelmezse hata verir.

### 5.9 Deneme Detay · Koyu (2 kare: Genel ve Sorular)

- Kanvas #0A1424, kart #121D31, metin #EDF1F6 / #A9B5C6.
- Kapak #213049 zemin, ikon #6B7D97. `.tg` #213049.
- Çubuk ve sayaçlar: #52CC8E, #F07575, #6E7C92. Ayraç #26354D.
- Sekme göstergesi #FF8533. Segment başparmağı #C5D4E8.
- Kısa bar zemini #0A1424. BottomBar koyu (bkz. §0.3).
- Hücreler: doğru #121D31 + iç kenar 1px #26354D; yanlış #3B1D22; boş #213049. Doğru cevap metni #52CC8E.
- Pano notu: "açıklık sırası tersine döner, gri tonlamada da ayrışır."

### 5.10 Deneme Detay · Konular · Koyu (1 kare)

- Yapı 5.5 ile aynı. Kanvas #0A1424, kart #121D31, satır ayracı #26354D.
- Kelimeli sayaç koyu D/Y/B tonlarında; çip glifi #0A1424.
- Halka: ray #213049, yay #9BB3D3, metin #EDF1F6. Eşik rengi yok.
- `.bp` #C5D4E8 / #091A31. Sekme göstergesi #FF8533.

---

## 2. SMAP-06: Analizlerim

### 6.1 Analizlerim · Genel (3 kare)

- **Route önerisi:** kök sekme `/analytics?tab=genel`, AnalyticsScreen (RootBand + TabBar). FilterSheet, NetChart, StatGrid (11.4).
- **Mevcut kod:** analytics_screen.dart, general_tab.dart, net_chart_card.dart, stats_grid.dart, general_filter_panel.dart, analytics_view_provider.dart.

**Düzen:**
1. RootBand: "Analizlerim". Bant içi sekmeler "Genel" (gösterge 46) · "Denemelerim" (gösterge 98), aria "Analizlerim bölümleri".
   - "Analiz" ve "Harita" sekmeleri v1'de yok (Ek D-4).
2. Süzgeç satırı, y=190, iki uçta: chip "TYT · Genel" + CaretDown 18 (aria "Süzgeç: TYT · Genel", aria-haspopup=dialog) ve "6 deneme" `.c13` · 600 mu.
3. Grafik kartı, y=246, padding 16.
   - Üst satır: "Net gelişimi" `.t17` ve "Son 6 deneme" `.c13` · 600 mu.
   - Grafik 338×214, üst boşluk 12.
   - Altyazı "net · TYT 0–120 · son nokta vurgulu" `.c13.mu`, üst boşluk 4.
4. StatGrid, y=566: 2 sütun, aralık 8.
   - StatBox `.sb`: #FFFFFF, radius 16, padding 16, sütun aralığı 2. Değer `.sv` 24/32 · 700 · −0,4; etiket `.sl` 13/20 · 600 #556173.
   - Delta satırı: 13 · 600 #36537C, ArrowUp 14 (stroke 24), aralık 4.
   - Kutular: "6" / "Çözülen deneme"; "67,79" / "Ortalama net" / "+3,25 son denemede"; "381,40" / "Ortalama puan"; "182.430" / "Ortalama sıralama".

**Grafik (NetChart, fl_chart LineChart):**
- Çizim alanı x 34–328, y 10–184. 5 yatay ızgara çizgisi, aralık 43,5, #DCE2E9, 1 pt.
- Y ekseni etiketleri x=28, sağa yaslı, 13 pt #556173. TYT: 120/90/60/30/0. AYT: 160/120/80/40/0.
- X: noktalar **eşit aralıklı (indeks)**, x=48 → 314. Etiketler y=206, ortalı, 13 pt: kısa tarih, ay noktalı.
- Çizgi: #264066, 2,5 pt, round join, düz parçalar (eğri yok).
- Alan: #264066, opaklık 0,10.
- Noktalar: r 4,5, dolgu #FFFFFF, kenar #264066 2 pt.
- Son nokta: r 7, #E05500, kenar #FFFFFF 2,5.
- Balon: 196×48, radius 8, #0F294A. Sağ kenarı x=328'e yaslı, üst kenarı noktanın 66 üstünde.
  - 1. satır 13 pt #C5D4E8 (x+12, y+19).
  - 2. satır 15 · 700 #FFFFFF (y+38).
- Hedef çizgisi yok (Ek D-3).
- TYT veri (y'den): 22 Nis. 61,5 · 14 May. 64,25 · 17 Haz. 68 · 4 Ağu. 66,75 · 15 Eyl. 71,5 · 28 Eyl. 74,75. Balon "TYT Genel Deneme 9 · 28 Eyl." / "74,75 net".
- AYT veri: 8 May. 48,5 · 2 Ağu. 55 · 21 Eyl. 59,25 · 5 Eki. 67,5. Balon "Türkiye Geneli Deneme 6 · 5 Eki." / "67,5 net".
- Grafik aria: "TYT net grafiği: 22 Nisan 61,5 netten 28 Eylül 74,75 nete, 6 deneme". Her nokta odaklanabilir, örnek okunuş: "TYT Genel Deneme 9, 28 Eylül, 74,75 net".

**Kare 2 (AYT, eksik veriyle):**
- "AYT · Genel", "4 deneme", "Son 4 deneme", "net · AYT 0–160 · son nokta vurgulu".
- Kutular yalnızca "4" ve "57,56" + "+8,25 son denemede". Ortalama puan ve sıralama yoksa kutu çizilmez.

**Kare 3 (Süzgeç sheet'i):**
- Başlık "Süzgeç" ve `.xi` kapat. Gövde padding 12 24 0, alanlar arası 20.
- "Sınav" segmenti: TYT · AYT.
- "Alan" segmenti (yalnızca AYT'de): Eşit Ağırlık · Sayısal · Sözel · Dil. Yardım metni: "Ders listesi alanına göre değişir. Profildeki alanın seçili gelir."
- "Ders" chip'leri (sarar, aralık 8): Genel · Türk Dili ve Edebiyatı · Tarih · Coğrafya · Matematik. Bu liste EA içindir; Matematik yeni eklendi.
- `.bp` "Uygula".

**Etkileşim:**
- Noktaya dokununca balon açılır (ad yoksa yalnızca tarih ve net). Balon dışına dokununca balon son noktaya döner.
- Süzgeç değişince grafik 350 ms'de yeniden çizilir, selectionClick.

**Veri:**
- `GET /student/getLineChartData {type, lesson, aimType}` → mockexams[{date, net, name}], user{aimType}, totalQuestion.
- `GET /student/getTotal {general, type, lesson, aimType}` → count, ortNet, data[] (points/ranks). Ortalama puan ve sıralama bu veriden.
- `GET /student/getLessons` → süzgeç dersleri.
- aimType sabit 2 kaldırılmalı; profildeki alan kullanılmalı.
- Değişim = son − sondan bir önceki (aynı süzgeçte). İki deneme yoksa satır yok.

**Koyu tema:** 6.4.

### 6.2 Denemelerim (3 kare)

- **Route önerisi:** `/analytics?tab=denemelerim`, ExamList (sayfalı, 8'erli) ve SortFilterSheet.
- **Mevcut kod:** my_test_results_tab.dart, my_test_results_card.dart.

**Düzen:**
1. RootBand, "Denemelerim" seçili.
2. Sayaçlı segment, y=190, aria "Sınav türü": "Tümü"/"10 deneme" · "TYT"/"6 deneme" · "AYT"/"4 deneme".
3. Özet satırı, y=254: "Tüm tarihler · En yeni önce" `.c13` · 600 mu ve `.bt` "Süz ve Sırala" (Sliders 20, margin-right −12).
4. Liste kartı, y=306. ExamRow `.tr`, üstten hizalı:
   - Kapak 40×54, radius 6, #DCE2E9 (ikonsuz).
   - Ad `.tn`, iki satıra kadar.
   - Meta satırı (aralık 4/8, üst boşluk 4): `.tg` tür, kısa tarih `.c13.mu`, "· yayınevi".
   - DybSmall, üst boşluk 6.
   - Sağda net 24/32 · 700 · −0,4 ve "net" `.c13` · 600 mu.
   - Favori `.ib` (margin −6 −12 0 0): Star 20. Kapalıyken #697586; açıkken dolu #0F294A. Aria "Favorilere ekle" / "Favorilerden çıkar", aria-pressed.

**Satırlar:**
- "Türkiye Geneli Deneme 6" · AYT · "5 Eki. 2026" · "· Örnek Yayınları" · 86/74/0 · 67,5 · favori açık
- "TYT Genel Deneme 9" · TYT · "28 Eyl. 2026" · 80/21/19 · 74,75
- "AYT denemesi" · "21 Eyl. 2026" · 59,25
- "TYT denemesi" · "15 Eyl. 2026" · 71,5
- "TYT denemesi" · "4 Ağu. 2026" · 66,75
- "AYT denemesi" · "2 Ağu. 2026" · 55

Ad yoksa başlık "tür + denemesi" olur; yayınevi ve D/Y/B çizilmez.

**Kare 2 (Süz ve Sırala sheet'i):**
- "Tarih" chip'leri: "Tüm tarihler" (seçili) · "Son 30 gün" · "Son 3 ay" · "Bu eğitim yılı".
- "Sıralama" radio'ları: "En yeni önce" (seçili) · "En yüksek net önce".
- `.bp` "Uygula".

**Kare 3 (Boş):**
- y=230: kil "Harita" görseli 128×128 (webp 140×140, alt="").
- "Henüz deneme yok" `.t20`, üst boşluk 24.
- "İlk denemeni okuttuğunda sonuçların, netin ve eksik konuların burada görünür." `.b15.mu`, üst boşluk 8.
- `.bp` "İlk Denemeni Okut": otomatik genişlik, padding 0 20, Camera 20, üst boşluk 24. Kamerayı açar.
- Genel sekmesi de aynı boş durumu gösterir.

**Kurallar:**
- Sonsuz kaydırma, 8'erli sayfa; altta küçük spinner. "Hepsi bu kadar" yazılmaz.
- Favori yalnızca cihazda saklanır (varsayım 4.8); favoriye göre süzme yok.
- Satır → 5.3.

**Veri:** `POST /student/getMyMockExams {page, perPage:8, filter{types,nets,dates}}` → enrichedMockExams[{itemName, net, true, wrong, pass, mexam{order, image, type}, date, isStarred}]. Sıralama parametresi yeni: `sort=newest|net` (11.4).

**Koyu tema:** Pano yok (D-14 listesinde yok). Token'larla türetilir.

### 6.3 Analizlerim · Durumlar (4 kare)

**Kare 1, İskelet:**
- Bant ve sekmeler hemen gelir.
- İskelet: (16, 190) 140×40 radius 999; grafik kartı y=246, 304 yükseklik, padding 16 (120×20 ve 16 boşlukla 220 yükseklik).
- 4 kutu 181×88, radius 16: (16, 566), (205, 566), (16, 662), (205, 662).

**Kare 2, Tek deneme:**
- Süzgeç "1 deneme". Kart y=246, padding 20:
  - "İlk denemen" `.c13` · 600 mu.
  - "74,75" 40/48 · 800 ve "net".
  - "TYT Genel Deneme 9 · 28 Eylül 2026" `.b15`.
  - "İkinci denemenden sonra gelişim grafiğin burada çizilir." `.c13.mu`, üst boşluk 12.
- Kutular y=470: "1" / "Çözülen deneme" ve "74,75" / "Ortalama net". Delta yok.

**Kare 3, Hata:** y=260: "Analizlerin yüklenemedi" / "Bağlantını kontrol edip tekrar dene." / "Tekrar Dene". Sekmeler çalışır; Denemelerim ayrı yüklenir.

**Kare 4, Çevrimdışı:**
- Şerit y=174 (bant köşesi bu karede yuvarlak kalmış). Süzgeç y=226, grafik y=282 (balonsuz), kutular y=580.
- Süzgeç yalnızca önbellekteki türlerle çalışır.

**Kurallar:**
- Deneme yoksa iki sekme de 6.2 boş durumunu gösterir.
- Grafik iki denemeden itibaren çizilir.
- "Geçen ay" ifadesi hiçbir yerde yok.
- Hata ve çevrimdışı durumunda haptik yok. Şerit 250 ms'de iner.

### 6.4 Analizlerim · Genel · Koyu (1 kare)

- Bant koyuda da #0F294A. Kanvas #0A1424, kart ve StatBox #121D31.
- Grafik: ızgara #26354D, eksen metni #A9B5C6, çizgi #9BB3D3, alan opaklığı 0,14. Noktalar dolgu #121D31, kenar #9BB3D3. Son nokta #FF8533, kenar #121D31.
- Balon ters yüzey: #EDF1F6 zemin, 1. satır #36537C, 2. satır #0A1424.
- Delta #9BB3D3 (pano notunda #52CC8E yazıyor; bkz. §6).
- Chip koyu: şeffaf, kenar #6B7D97.

---

## 3. SMAP-07: Derslerim ve Konular

### 7.1 Derslerim (3 kare)

- **Route önerisi:** kök sekme `/lessons`, LessonsScreen ve WebOnlySheet.
- **Mevcut kod:** Derslerim sekmesi şu an MyCardScreen / my_card_page.dart (kart ızgarası). Eski TYT/AYT/SOS-2 diyaloğu home/.../lesson_navigation_helper.dart içinde ve **kalkacak**.

**Düzen:**
1. RootBand "Derslerim" ve `.bseg` TYT · AYT (aria "Sınav türü"). Bant yüksekliği 178.
2. Ders kartı, y=194. SubjectRow `.rw`: aralık 12, padding 12 16, min-h 72, ayraç 1px #E8ECF1.
   - Glif karosu `.gt`: 40×40, radius 12, ders zemini ve ders vurgusu, glif 22.
   - Ad `.tn`. Alt satır isteğe bağlı: test adı `.tm` ya da kart ilerlemesi.
   - Kart ilerlemesi: `.trk` 8 pt ray, radius 999, #E8ECF1; dolgu ders vurgusu (Tarih #8C6106, %64). Yanında "41/64 kart" `.tm` · 600, aralık 8, üst boşluk 6.
   - Sağda etiket `.tg` (**nötr gri, bayraksız**) ve CaretRight 20 mu.
   - Web'de satırında ok yerine ArrowSquareOut 20 ve `.tg` "Web'de".

**TYT satırları:** Türkçe "28 eksik" · Tarih (41/64 kart) "60 eksik" · Coğrafya "44 eksik" · Matematik "Web'de" · Geometri "Web'de" · Fizik "7 eksik" · Kimya "9 eksik" · Biyoloji "11 eksik".

**AYT satırları (kare 2):**
- Türk Dili ve Edebiyatı (Feather) "3 eksik"
- Tarih, "Türk Dili ve Edebiyatı–Sosyal Bilimler 1 testi", etiketsiz
- Tarih-2, "Sosyal Bilimler 2 testi", "eksik yok"
- Coğrafya, "Türk Dili ve Edebiyatı–Sosyal Bilimler 1 testi", etiketsiz
- Coğrafya-2, "Sosyal Bilimler 2 testi", etiketsiz
- Matematik "Web'de"
- Fizik "7 eksik"

**Kare 3 (WebOnlySheet):**
- Başlık bloğu padding 24 24 0, aralık 12: Matematik karosu 40 ve "Kavram haritan web'de" `.t20` (padding-top 6).
- "Matematik ve Geometri kavram haritan şimdilik smaptr.com'da." `.b15.mu`, üst boşluk 12.
- `.bp` "Web'de Aç" (ArrowSquareOut 20) ve `.bq` "Tamam". "Haber ver" yok.

**Kurallar:**
- Ad TYT/AYT öneksiz yazılır.
- Kart ilerlemesi yalnızca gerçek veri varken çizilir.
- Veri yoksa etiket yok.
- Seçim cihazda hatırlanır ve ders detayına taşınır: Tarih-2 → Tarih detayı SOS-2 seçili açılır.
- Çevrimdışıyken Web'de dersler gizlenir.

**Etkileşim:**
- Satır → 7.2. Edebiyat satırı → 7.4 segmentli detay.
- Web'de satırı → sheet. "Web'de Aç" tarayıcıyı açar.
- Erişilebilirlik: "Matematik, web'de açılır".

**Veri:**
- `GET /student/getLessonsTotalMissing` (eksik sayıları, ders ve kategori bazında).
- `GET /student/getInfoCardsInfo` → infoObj[lessonId]{missCount, trueCount, favoriteCount, totalCards}.
- Ders kimlikleri: core/constants/lesson_constants.dart (lessonTyt / lessonAyt).

**Koyu tema:** Pano yok. Bant navy kalır; ders karoları koyu ders renkleriyle (bkz. §0.4).

### 7.2 Ders Detayı (3 kare)

- **Route önerisi:** `/lessons/:lessonId?cat=tyt|ayt|sos2|all&eksik=1`, LessonDetailScreen.
- **Mevcut kod:** analytics/.../lesson_detail_page.dart (getMainSubjects, resultByType).

**Düzen:**
1. Geri düğmesi.
2. Başlık, y=102, aralık 12: `.gt` 40 ve ad `.t24` (title-lg).
3. Süzgeç satırı, y=158, iki uçta:
   - `.chp` "Eksiklerim (31)": Flag 16 (stroke 20), aria-pressed. Seçiliyken lacivert.
   - `.bt` "Kartlarım" (Cards 20, margin-right −12). Tarih'te "Kartlarım · 41/64".
4. Sayaçlı segment, y=214, aria "Kategori".
5. Konu kartı, y=286. TopicRow `.rw`, min-h 64:
   - Numara rozeti `.nb`: 28 daire, #E8ECF1, 13/28 · 700.
   - Ad `.tn` (iki satıra kadar, kesilmez).
   - EksikTag ("2 eksik") ve CaretRight 20.

**Türkçe · TYT (kare 1):**
- Segment: "Tümü"/"31 eksik" · "TYT"/"28 eksik" (seçili) · "AYT"/"3 eksik".
- Konular: 1 Sözcükte Anlam · 2 Cümlede Anlam · 3 Ses Bilgisi · 4 Yazım Kuralları · 5 Anlatım Yöntemleri · 6 Paragraf · 7 Söz Öbekleri · 8 Cümlenin Öğeleri "2 eksik" · 9 Fiilde Çatı "3 eksik" · 10 Cümle Türleri · 11 Anlatım Bozuklukları · 12 Noktalama İşaretleri "3 eksik".

**Kare 2 (Eksiklerim süzgeci açık):**
- Yalnızca 8, 9 ve 12 listelenir; numaralar tam listedeki sırayı korur.
- y=490'da dipnot (left/right 20): "Yalnız eksiği olan konular. Numaralar tam listedeki sırayı korur."

**Kare 3 (Tarih · SOS-2):**
- "Eksiklerim (60)", "Kartlarım · 41/64".
- Segment: "TYT"/"60 eksik" · "AYT" (sayaçsız, veri yok) · "SOS-2"/"eksik yok" (seçili).
- Konular: 1 İki Savaş Arasındaki Dönemde Türkiye ve Dünya · 2 İkinci Dünya Savaşı Sürecinde Türkiye ve Dünya · 3 İkinci Dünya Savaşı Sonrasında Türkiye ve Dünya · 4 Toplumsal Devrim Çağında Dünya ve Türkiye · 5 21. Yüzyılın Eşiğinde Türkiye ve Dünya.
- Tarih segmentinde "Tümü" seçeneği yok (bkz. §6).

**Kurallar:**
- Numara 1..n istemcide, sunucu sırasından üretilir.
- SOS-2 seçeneği yalnızca Tarih ve Coğrafya'da var.
- Eksik işareti amber EksikTag'dir; kırmızı yanlış cevaba ayrılmıştır.

**Etkileşim:**
- Satır → 7.3.
- "Kartlarım" → 8.1 (ders destesi).
- Segment değişimi: 250 ms, selectionClick.
- Erişilebilirlik: segment "TYT, 28 eksik"; etiket "3 eksik".

**Veri:** `GET /student/mainSubjects?lessonId` ve kategoriye göre eksik sayıları (resultByType). Türkçe toplamı 31; konu bazında 8 eksik (varsayım 5.2), fark sunucudan gelir.

**Durumlar:** 7.5.

### 7.3 Konu Detayı (3 kare)

- **Route önerisi:** `/lessons/:lessonId/topics/:topicId?focus=firstMissing`, TopicDetailScreen ve CardSheet.
- **Mevcut kod:** subject_detail_page.dart (getSubSubjectsAndItems; statusArray içindeki "0" eksik demek).

**Düzen (kare 1):**
1. Başlık, y=102:
   - "Sözcükte Anlam" `.t24`.
   - "Türkçe · TYT · 1. konu" `.c13` · 600 mu, üst boşluk 2.
   - "5 alt başlık · 25 madde" `.b15`, üst boşluk 6.
2. Akordeon yığını, y=206, kartlar arası 8.
   - **Alt başlık başlığı:** padding 14 12 14 16, aralık 8. Ad `.t17`. Meta (aralık 4/8, üst boşluk 4): `.tm` "4 madde" ve gerekiyorsa `.ek` "1 eksik". Ok CaretUp/CaretDown 22.
   - **Madde satırı:** üst ayraç 1px #E8ECF1; padding 12 8 12 16; min-h 56; aralık 12. `.nb` numara, ad `.b16` · 600, `.ek` "Eksik", ok 20.
   - **Açık madde gövdesi:** padding 0 16 16 56.
     - Tanım `.b16`, satır yüksekliği 26.
     - ExampleBox `.ex` (üst boşluk 12): #F2F4F7 zemin (bg-canvas), radius 12, padding 12 16. İçinde "Örnek" 13 · 700 mu; örnek `.b16`/26 (üst boşluk 2); açıklama `.c13.mu` (üst boşluk 4).
     - `.bt` "Kartı Aç" (Cards 20, margin 8 0 −8 −12).

**İçerik:**
- "Anlamı Yönünden Sözcükler" (4 madde, 1 eksik):
  - 1 Temel Anlam (Eksik): "Bir sözcüğün akla gelen ilk anlamıdır. Sözlük anlamı da denir." / Örnek "Bazı insanlar karanlıktan korkar." / ""Karanlık" burada ışıksız anlamında, temel anlamıyla kullanılmış."
  - 2 Yan Anlam · 3 Mecaz Anlam · 4 Terim Anlam
- "Sözcükler Arası Anlam İlişkileri" 9 madde · "Mecaz Oluşturma Yolları" 9 madde · "Yansıma Sözcükler" 1 madde · "Kalıplaşmış Söz Öbekleri" 2 madde.

**Kare 2 (kaydırılmış):**
- Kısa bar "Sözcükte Anlam"; içerik y=128.
- Açık madde "Yan Anlam": "Bir sözcüğün temel anlamıyla bağlantılı olarak kazandığı yeni anlamdır." / "Yorganın yüzü kirlenmiş." / ""Yüz" insanın yüzü değil, yorganın dış tarafı: temel anlamla bağlantılı yan anlam."

**Kare 3 (CardSheet):**
- `.shh`: "Türkçe · Sözcükte Anlam" `.c13` · 600 mu; "Temel Anlam" `.t20` (üst boşluk 2); favori `.ib` Star 22 #697586 (aria "Favorilere ekle"); `.xi` kapat.
- Gövde padding 12 24 0: `.ek` "Eksik", tanım `.b16`/26 (üst boşluk 12), `.ex` (üst boşluk 12).
- `.bp` "Öğrendim": yalnızca kart eksikse görünür.
- İlk "Öğrendim"de bir kez onay istenir (8.1 kare 2).

**Kurallar ve hareket:**
- Açılışta ilk eksik maddeye 350 ms kaydırılır (Scrollable.ensureVisible, standard) ve madde açılır. Hareketi azalt açıksa jumpTo.
- Akordeon 250 ms; açılan madde görünür alana getirilir.
- Sheet 350 ms. "Öğrendim"de success haptiği.
- Bilinmeyen kart durumu çizilmez.
- Alt başlık yoksa boş metin: "Bu konunun içeriği hazırlanıyor."

**Veri:**
- `GET /student/getSubSubjects?mainSubjectId` ve `POST /student/getItems {subjectIds, type}` → subSubjects, itemsArray (itemData, statusArray).
- "Öğrendim" → `GET /student/learnedItem?itemId` ya da `learnedCard?item`; hangisinin kullanılacağı belirtilmemiş.
- Favori → `GET /student/addFavoriteMobil?item`.

**Koyu tema:** 7.6.

### 7.4 Edebiyat · Yazar ve Eserler (2 kare)

- **Route önerisi:** `/lessons/:edebiyatId?section=authors`, AuthorList ve AuthorSheet.
- **Mevcut kod:** edebiyat_lesson_detail_page.dart.

**Düzen:**
1. Başlık, y=102: Edebiyat karosu (#F6E7EC / #8A2F4E, Feather) ve "Türk Dili ve Edebiyatı" `.t24`.
2. Segment `.seg`, y=158, aria "Bölüm": "Konular" · "Yazar ve Eserler" (seçili). Seçim cihazda hatırlanır.
3. Yazar kartı, y=218. AuthorRow `.rw` (72 pt):
   - Fotoğraf 48 daire. Fotoğraf yoksa baş harf: #F6E7EC zemin, #8A2F4E, 15 · 700.
   - Ad `.tn`, dönem `.tm`, CaretRight.

**Yazarlar:** NK Namık Kemal (Tanzimat) · Ş Şinasi (Tanzimat) · ZP Ziya Paşa (Tanzimat) · TF Tevfik Fikret (Servet-i Fünun) · HZ Halit Ziya Uşaklıgil (Servet-i Fünun) · MA Mehmet Akif Ersoy (Millî Edebiyat Dönemi).

**AuthorSheet (uzun boy):**
- Başlık: avatar 56 (17 · 700), "Namık Kemal" `.t20`, "Tanzimat" `.c13` · 600 mu, `.xi` kapat.
- Gövde padding 16 24 0:
  - "Hakkında" `.t17`; metin `.b16`/26 (üst boşluk 4): "Tanzimat Dönemi'nin şair ve yazarı; "vatan şairi" olarak bilinir. Edebiyatı toplumu eğitmenin aracı olarak gördü."
  - "Eserleri" `.t17` (üst boşluk 16). Gruplar (üst boşluk 8): tür etiketi 13 · 700 mu, eserler `.b16`/26 " · " ile ayrılmış.
  - "Roman": "İntibah · Cezmi".
  - "Tiyatro": "Vatan yahut Silistre · Gülnihal · Akif Bey · Zavallı Çocuk · Kara Bela · Celaleddin Harzemşah".
- `.bp` "Öğrendim".

**Veri:**
- `GET /student/yazarEserMainSubjects`, `GET /student/getSubjectAuthors?itemId`, `learnedItem`.
- Fotoğraflar `assets/authors` klasöründen (38 MB).
- Yazar listesi Ek C'de yok; müfredattan örnek (varsayım 5.7).

**Koyu tema:** Pano yok. Edebiyat koyu renkleri #301A27 / #E494BE.

### 7.5 Derslerim ve Konular · Durumlar (4 kare)

**Kare 1, İskelet (Derslerim):**
- Bant ve segment hemen gelir. Kart y=194, padding 4 16.
- 6 satır, her biri 72 yükseklik: 40×40 radius 12 iskelet ve 18 yüksekliğinde çizgi (genişlik 120/90/140/110/100/80).
- 15 sn'de veri yoksa hata.

**Kare 2, Süzgeç boş (Tarih · Eksiklerim açık · SOS-2):**
- Kart y=286: "Bu süzgeçte gösterilecek konu yok" / "SOS-2'de eksik konun yok. Tüm SOS-2 konularını görmek için süzgeci kapat." / `.bt` "Süzgeci Kapat".

**Kare 3, Hata (konu detayı):** y=240: "Konu yüklenemedi" / "Bağlantını kontrol edip tekrar dene." / "Tekrar Dene". Geri dönüş her zaman açık.

**Kare 4, Çevrimdışı:**
- Bant köşeleri düzleşir (radius 0).
- Şerit bandın hemen altında, akış içinde, içeriği iter. Kart y=254.
- Web'de dersler gizlenir (Matematik ve Geometri yok).

**Boş metinler:**
- Ders detayı, Eksiklerim: "Bu süzgeçte gösterilecek konu yok."
- Konu detayı, alt başlık yok: "Bu konunun içeriği hazırlanıyor."

**Hareket:** İskelet 1200 ms, şerit 250 ms. Hata ve çevrimdışında haptik yok.

### 7.6 Konu Detayı · Koyu (1 kare)

- Kart #121D31. ExampleBox #18263D. Gövde #EDF1F6, 16/26.
- EksikTag #F2C46D metin, #33270F zemin.
- `.nb` #213049. Ayraç #26354D.
- BottomBar koyu, aktif Derslerim.

---

## 4. SMAP-08: Kart Destesi

### 8.1 Kart Destesi (4 kare)

- **Route önerisi:** `/cards/deck?lessonId=&examId=&group=eksik|bildik|favori`, CardDeckScreen.
- **Mevcut kod:** my_card_lesson_detail_page.dart (failedCards / successCards / favoriteCards), my_cards_detail_page.dart (CardSwiper).
- **Girişler:** ders detayında "Kartlarım", Deneme Detay › Kartlar (ve "Kartları Çalış"), konu detayındaki kart.

**Düzen:**
1. Geri düğmesi.
2. Başlık, y=102: "Tarih Kartları" `.t24`.
3. Sayaçlı segment, y=150, aria "Kart grubu": "Eksiklerim"/"23 kart" · "Bildiklerim"/"41 kart" · "Favorilerim"/"6 kart". Boş sekmede sayaç "kart yok".
4. SessionProgress, y=222, aralık 12:
   - `.trk` 8 pt, #E8ECF1; dolgu #E05500, %52.
   - "12/23" `.c13` · 700.
   - Aria "Oturum", aria-valuenow 12, aria-valuemax 23.
5. CardDeck:
   - Arka kart 2: y=282, left/right 40, 380 yükseklik, opaklık 0,5.
   - Arka kart 1: y=270, left/right 28, 380 yükseklik, opaklık 0,75, gölge 0 2 8 rgba(15,41,74,0.08).
   - Ön kart (`article.card`): y=258, left/right 16, min-h 392, padding 24, gölge 0 8 24 rgba(15,41,74,0.16).
   - Ön kart içi:
     - Üst satır: ders karosu `.gt` 28×28 (Bank 15) ve "Tarih" `.c13` · 700 (aralık 8); favori `.ib` Star 22 #697586 (margin −10 −12 0 0).
     - Başlık `.t20`, üst boşluk 20.
     - Gövde `.b16`/26, üst boşluk 12.
     - `.ek` "Eksik", mutlak konum left 24, bottom 20.
6. Eylemler, y=676, aralık 12: `.bo` "Detay" 120 genişlik ve `.bp` "Öğrendim" esnek. Bildiklerim sekmesinde yalnızca "Detay".

**Kare 2 (ConfirmSheet, ilk "Öğrendim"):**
- Gövde padding 20 24 0:
  - "Kartı Bildiklerim'e taşıyalım mı?" `.t20`.
  - ""Edirne-Segedin Antlaşması (1444)" eksiklerinden çıkıp Bildiklerim'e geçecek." `.b15.mu`, üst boşluk 8.
  - Checkbox "Bir daha sorma", üst boşluk 8.
- `.shf` (padding-top 12): `.bp` "Öğrendim" ve `.bq` "Vazgeç". Odak Vazgeç'te (11.13).
- "Bir daha sorma" seçimi cihazda saklanır.

**Kare 3 (Taşındı):**
- Sayaçlar 22 · 42 · 6 olur. Oturum 13/23 (%57). Sıradaki kart gelir: "Otlukbeli Savaşı (1473)".
- Toast, bottom 110, left/right 16: "Kart Bildiklerim'e taşındı." ve "Geri Al". 6 sn kalır.
- Bu karede eylem satırı `visibility:hidden` (bkz. §6).

**Kare 4 (Eksiklerim boş):**
- y=260: dersin kil görseli (Sütun) 128×128.
- "Bu derste eksik kartın kalmadı." `.t20`, üst boşluk 24.
- "Bildiklerim'deki 64 kartı tekrar etmek istersen oradan devam edebilirsin." `.b15.mu`, üst boşluk 8.
- `.bt` "Bildiklerime Geç", üst boşluk 12.
- Sekmeler: "kart yok" · "64 kart" · "6 kart".

**Diğer boş metinler:** Bildiklerim: "Henüz öğrendiğin kart yok." · Favorilerim: "Favoriye eklediğin kart yok."

**Etkileşim ve hareket:**
- Kaydırma yalnızca sonraki karta geçer: kart parmağı izler; %30 genişlik ya da 800 px/sn eşiği geçince 250 ms'de çıkar, sıradaki kart ölçekle öne gelir.
- Öğrenme yalnızca "Öğrendim" düğmesiyle: kart 250 ms'de sağa çıkar (exit eğrisi), success haptiği, iyimser güncelleme. Hata olursa geri alınır ve toast gösterilir. Geri Al 6 sn.
- Hareketi azalt açıksa kartlar kaymaz, çapraz geçiş kullanılır.
- Semantics customActions: "Sonraki kart" / "Önceki kart".
- "Detay" düğmesinin hedefi belirtilmemiş (muhtemelen CardSheet ya da konu).

**Veri:**
- `GET /student/getLessonInfoCards?lesson` → failedCards / successCards / favoriteCards[{item{_id, name, desc, mainSubject}, favorite}].
- `GET /student/learnedCard?item`, `GET /student/addFavoriteMobil?item`.
- Deneme girişinde kart kaynağı getMexamItemDetail.
- Oturum sayacı açılıştaki eksik kart sayısıyla başlar (varsayım 5.4).

**Alt çubuk:** Aktif Derslerim. Deneme Detay'dan girişte hangi sekmenin aktif olacağı belirtilmemiş.

### 8.2 Kart Destesi · Koyu (1 kare)

- Kart #121D31, metin #EDF1F6.
- Ön kart gölgesi 0 8 24 rgba(0,0,0,0.4). Arka kart 1'in gölgesi açık temadaki rgba(15,41,74,0.08) olarak kalmış.
- Oturum dolgusu #FF8533. Tarih karosu #2C2513 / #E3B651. Star #6B7D97.
- EksikTag #F2C46D / #33270F.
- Arka kartlar aynı yüzey, opaklık %50 ve %75.

---

## 5. 11.14 Ekran–Bileşen Eşlemesi (bu grubun satırları, birebir)

| Pano | Bileşenler |
|---|---|
| 5.1–5.2 Sonuç anı | DybLarge, metric-xl, delta, BottomSheet |
| 5.3–5.10 Deneme Detay | InScreenTabs, StackedBar, Accordion, QuestionCell, TopicResultRow, CardPreview |
| 6.1–6.4 Analizlerim | RootBand (sekmeli), Chip süzgeç, NetChart, StatBox, ExamRow |
| 7.1 Derslerim | RootBand (bant içi segment), SubjectRow, BottomSheet (Web'de) |
| 7.2 Ders Detayı | DetailBar, Chip (süzgeç), Segment (sayaçlı), TopicRow, EksikTag |
| 7.3 Konu Detayı | Accordion, ExampleBox, EksikTag, CardSheet |
| 7.4 Edebiyat | Segment, AuthorRow, BottomSheet |
| 8.1–8.2 Kart Destesi | Segment (sayaçlı), SessionProgress, CardDeck, ConfirmSheet, Toast, EmptyState (ders görseli) |

**11.14'te listelenmeyen ama panolarda kullanılan bileşenler:**
- ExamHeader (11.3 G3), DetailBar, BottomBar, StatBox (5.1 puan kutuları), Segment (5.1 puan türü, 6.1 sheet).
- DybSmall (5.3–5.6, 6.2), Toast ve durum kalıpları (OfflineStrip, Skeleton, ErrorState).

---

## 6. Tutarsızlıklar ve açık sorular

1. **Delta rengi:**
   - Pano notu ne diyor: 5.1 notu "fark 15/700 success", 6.1 notu "13/600 success", 6.4 notu "#52CC8E".
   - Markup ne diyor: #36537C, koyuda #9BB3D3.
   - Karar: 11.10 ve 11.12 delta token'ını kullanır (Tur 10 kararı). Pano notları güncel değil.
2. **Kapak köşesi:**
   - Pano notu ne diyor: 5.3 notu "48 × 64 (radius-sm)", yani 8.
   - Markup ne diyor: 6. 6.2'deki 40×54 kapak da radius 6; 5.1'deki 56×76 kapak radius 8.
3. **Soru ızgarası aralığı:**
   - Pano notu ne diyor: "8 pt aralık".
   - Markup ne diyor: gap 6, ızgara padding 0 8 8, hücre ~66×76.
4. **5.7 cevap çipleri:**
   - Durum: markup'ta zemin rengi yok, PNG'de çip görünmüyor (pano hatası).
   - Niyet: D/Y/B renkleri.
5. **Kart köşesi:**
   - Pano notu ne diyor: 8.1 notu ve 11.5 G5 "24 pt köşe".
   - Markup ne diyor: `.card` radius 16.
6. **Kart gölgesi:**
   - Pano notu ne diyor: "gölge yalnız sürüklenen kartta", yani shadow-overlay yalnızca sürüklenirken.
   - Markup ne diyor: duran ön kartta shadow-overlay var; arka kart 1'de shadow-raised var.
   - Koyu tema: ön kart rgba(0,0,0,.4) kullanıyor. Token'a göre overlay koyu %56, raised koyu %40.
7. **SessionProgress kalınlığı:**
   - Pano notu ne diyor: 11.5 G5 "4 pt".
   - Markup ne diyor: 8 pt (`.trk`).
8. **EksikTag ağırlığı:**
   - Pano notu ne diyor: G3 "13/600".
   - Markup ne diyor: CSS 13/20 · 700.
9. **Derslerim satır etiketi:**
   - Pano notu ne diyor: 7.2 notu "tek işaret her yerde" (bayrak + amber); 11.13 SubjectRow için EksikTag diyor.
   - Markup ne diyor: 7.1 ve 7.5'te nötr `.tg` (gri, bayraksız), PNG ile de doğrulandı.
   - Karar gerekli.
10. **Çevrimdışı şeridi:**
    - Pano notu ne diyor: 7.5 "bant köşeleri düzleşir (1.22)"; şerit akış içinde.
    - Markup ne diyor: 6.3'te bant radius 24 kalıyor, şerit mutlak konumda (y=174).
    - Öneri: 1.22 ve 7.5 kuralı izlenmeli.
11. **Sekme göstergesi rengi:** RootBand sekmelerinde #FF6600 (accent), InScreenTabs'ta #E05500 (accent-line, koyu #FF8533). İkisi farklı.
12. **DybLarge değer boyutu:**
    - Token tablosu ne diyor: "metric-sm 17/24 D/Y/B sayaçları".
    - Markup ne diyor: 24/32 · 700 (metric-md).
13. **NetChart X ekseni:** Noktalar eşit aralıklı (indeks). Etiketler tarih ama zamana orantılı değil.
14. **Tarih segmenti:** Tarih'te "Tümü" seçeneği yok (TYT/AYT/SOS-2); Türkçe'de var (Tümü/TYT/AYT). Kural belirtilmemiş.
15. **8.1 kare 3 çakışma:** Toast (bottom 110) eylem satırının (y=676) üstüne biniyor; panoda eylem satırı gizlenmiş. Davranış belirtilmemiş.
16. **Koyu varyantı tanımsız bileşenler:** OfflineStrip, Skeleton, Toast, `.chp`. Koyu panosu olmayan ekranlar: 5.2, 5.6, 5.7, 5.8, 6.2, 6.3, 7.1, 7.2, 7.4, 7.5. Bunlar token'larla türetilecek.
17. **Backend'de karşılığı belirsiz alanlar:**
    - Sonuç anı deltası.
    - Soru başına işaret ve doğru cevap (Sorular sekmesi).
    - Denemelerim sıralama parametresi.
    - Kategori bazında (TYT/AYT/SOS-2) eksik sayısı.
    - Kart ilerlemesi (öğrenilen / toplam).
    - "Öğrendim" için learnedItem mi learnedCard mı kullanılacağı.
18. **Bildirim izni sheet'i (5.2):** Tur 8'e kadar kapalı (varsayım 2.17).

---

## 7. İş bölme önerisi (Grup B)

Önkoşul: kit ve kabuk işi. SmapColors / SmapText ThemeExtension, RootBand, DetailBar, BottomBar, BottomSheet, ConfirmSheet, Toast, durum kalıpları ve mihr_ui düğme eşlemesi.

| Paket | İçerik |
|---|---|
| **B1 · Grup B bileşenleri** | ExamHeader, DybLarge, DybSmall, StackedBar, QuestionCell, TopicResultRow + PercentRing, StatBox, ExamRow, NetChart, SubjectRow, TopicRow, EksikTag, Accordion + ExampleBox, CardDeck, SessionProgress, AuthorRow. Her biri açık ve koyu. |
| **B2 · Sonuç anı** | 5.1 ResultMomentScreen ve 5.2 NotificationPrimerSheet (bayrakla kapalı). |
| **B3 · Deneme Detay** | 5.3–5.6 ExamDetailScreen (yapışkan sekmeler, sekme başına tembel yükleme), 5.7 QuestionDetailScreen, 5.8 durumları, 5.9–5.10 koyu tema. |
| **B4 · Analizlerim** | 6.1 Genel + FilterSheet, 6.2 Denemelerim + SortFilterSheet + sayfalama, 6.3 durumları, 6.4 koyu tema. |
| **B5 · Dersler** | 7.1 LessonsScreen + WebOnlySheet (eski TYT/AYT/SOS-2 diyaloğu kaldırılır), 7.2 LessonDetailScreen, 7.4 Edebiyat yazarları, 7.5 durumları. |
| **B6 · Konu ve kart** | 7.3 TopicDetailScreen + CardSheet, 7.6 koyu tema, 8.1 CardDeckScreen (onay, Geri Al, boş durumlar), 8.2 koyu tema. |

**Bağımlılıklar:**
- B2 → B3 (Detaylı Analiz, Kartlar).
- B3 → 7.3 ve 8.1 (Bu Konuyu Çalış, Kartları Çalış).
- B4 → B3 (satır → detay).
- B5 → B6.

Bu paket önerisi pano notlarından türetilmiştir; panolarda doğrudan bir iş bölme önerisi yok.

---

**Okunan dosyalar:**
- docs/design/panolar/SMAP-05/*, SMAP-06/*, SMAP-07/*, SMAP-08/*
- docs/design/panolar/SMAP-11/13-11-14-Ekran-Bileşen-Eşlemesi
- Bağlam: SMAP-11 11.3, 11.4, 11.5, 11.10, 11.12, 11.13, 11.15, 11.16; SMAP-00 0.1, 0.2
- lib (repository/analysis_repository.dart, repository/cards_repository.dart, repository/home_repository.dart, features/analytics/**, features/my_card/**, features/root/**, main.dart)
- mihr_ui paketi (pub) — lib (components/buttons/**, core/widgets/frosted_container.dart, core/theme/shadows/mihr_backdrop_blurs.dart)