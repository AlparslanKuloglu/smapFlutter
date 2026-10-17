# SMAP — Mağaza Görselleri Prompt'u (Claude Design)

> **Ne zaman kullanılır:** Tasarım brifinin 11. turu. Uygulama tasarımı (Tur 1–10) bittikten sonra, **aynı projede** uygulanır. Bütün veriler brifin Ek C'siyle aynıdır. Uygulamada olmayan ya da verisi olmayan hiçbir özellik (Harita, hedef net, koç ataması, mesajlaşma, geçen aya göre değişim) gösterilmez.
> **Ekle:** `magaza/bezel-iphone.png`, `magaza/bezel-pixel.png`, `magaza/bezel-ipad.png`, `magaza/splash_logo.png`. Varsa referans olarak Sleepia mağaza görsellerinden 2–3 tanesi.

---

## ROL & HEDEF

Sen App Store / Google Play için premium mağaza görselleri tasarlayan bir kreatif direktörsün. Bu projede az önce tasarladığın **SMAP redesign ekranlarını** kullanarak 7 panellik bir mağaza görsel seti + Google Play feature graphic üreteceksin. Telefonlardaki tüm ekranlar **senin bu projede tasarladığın yeni ekranların DARK MODE halleri** olmalı; eski uygulama ekranlarını kullanma.

Kalite çıtası: eklediğim Sleepia görselleri. O setin dilini SMAP markasına çevir — mor/amber yerine **lacivert gece + turuncu parıltı**.

---

## GÖRSEL DİL (Sleepia reçetesi → SMAP)

**Tek panorama.** 7 görsel tek bir geniş şerit olarak tasarlanır, sonra panellere kesilir. Yan yana dizildiğinde kesintisiz okunmalı: arka plan dokusu, parıltılar ve aşağıdaki **ROTA** çizgisi dikişlerden kesintisiz geçer. Dikişlerin üzerine oturan nesneler (optik form, kil kitap, kart yelpazesi) iki paneli birbirine bağlar.

**Arka plan — "lacivert gece haritası":**
- Dikey gradyan `#14325C` → `#0D2744` (%55) → `#06132A`.
- Topografik eş yükselti çizgileri (beyaz, %4–6 opaklık), P3'teki dalışta ve P7'deki zirvede sıklaşır.
- ~180px grafik kâğıdı kareleri, %3 opaklık (eski setin kareli kâğıdının premium hali).
- Seyrek "şehir ışığı" noktaları. **Yıldız yok** (yıldız Sleepia'ya ait).
- Radyal parıltılar: sıcak `#FF6600` (P1 sonuç kartı ve optik form arkası, P5 alt, P7 YKS pini), soğuk `#2C5AA0` (P2–P4, P6).

**Panorama ipliği — ROTA** (Sleepia'daki ses dalgasının karşılığı):
- Tek, kesintisiz navigasyon rotası. Çekirdek `#FF8A00` ~7px, altında `#FF6600` 26px blur'lu %55 parıltı.
- **Kesikli → düz → kesikli:** Sol kenarda soluk kesikli "planlanan rota" olarak doğar. P1–P2 dikişindeki optik formun üzerinden **beyaz-sıcak tarama ışını** olarak geçer ve o andan itibaren düz/parlak olur. P7'de son denemeden sonra tekrar kesikli olur: önündeki yol.
- **Pin anlatısı** (renk + ikon birlikte): P1–P3 kırmızı `#EF4444` ✕ = eksik → P4 turuncu yarım halka = çalışılıyor → P5'ten itibaren yeşil `#22C55E` ✓ = kapandı.
- Rota P3'te telefonun **önünden** geçer (setteki tek ön geçiş); diğer panellerde arkadan.
- P6'da rota bir haftaya dönüşür (7 gün çentiği, bugün turuncu, görev gününde koç avatarı pini).
- P7'de rota **Deneme Net Grafiği'nin kendisi** olur ve sağ üstte büyük haloyla "YKS" varış pininde biter.

**Tipografi:**
- Eyebrow: IBM Plex Mono 500, büyük harf, 0.22em aralık, `#FF9F4A`. Türkçe İ ile yaz ("OPTİK", "BİLGİ").
- Başlık: Manrope 800, -0.045em, satır yüksekliği 1.04, `#F4F6FA`. 2 satır, satır başına ≤16 karakter.
- Vurgu kelimesi (başlıkta tam bir tane, aşağıda `*yıldızlı*`): Instrument Serif Italic, `#FF8A00`, 1.14em, hafif turuncu glow. Türkçe glifler (ı, ö, ü, ş, ğ) bozuksa PT Serif Italic'e düş.
- Alt metin: Manrope 500, `#A9B8CC`, ≤90 karakter, ünlem yok.
- Rakamlar Türkçe biçimde ve tabular: **67,5 · 74,75 · 381,40 · +8,25 · 182.430**.
- Tüm semboller (✓ ✕ – ↺ ▲ onay kutuları) SVG; emoji yok.

**Yüzen kartlar:** Uygulamadaki UI parçaları büyütülüp telefondan taşan cam kartlar olarak çizilir — `rgba(16,38,70,.93)`, içte 2px %16 beyaz çizgi, gölge `0 40px 90px rgba(2,8,20,.6)`, köşe 44px. Kartlardaki her veri, telefon ekranındaki veriyle **birebir aynı** olmalı.

**3D kil objeler** (uygulamanın avatar/ikon stiliyle aynı): katlanmış harita "S" logosu, kırmızı harita pini, kiremit renkli açık kitap, mezuniyet kepi, bilgi kartı yelpazesi.

**Cihazlar:** Eklediğim bezel PNG'lerini kullan; ekranı bezelin şeffaf deliğine yerleştir:
| Bezel | Boyut | Ekran deliği (x, y, w, h) | Köşe |
|---|---|---|---|
| bezel-iphone.png | 1350×2760 | 72, 69, 1206, 2622 | 182px |
| bezel-pixel.png | 1511×2896 | 183, 169, 1145, 2549 | — |
| bezel-ipad.png | 2300×3000 | 118, 124, 2064, 2752 | — |

Durum çubuğu: 9:41; pil, Wi-Fi ve sinyal dolu; bildirim yok. Telefona hafif `drop-shadow(0 70px 110px rgba(2,8,20,.75))`.

---

## 7 PANEL

### P1 — Hero
- **Eyebrow:** OPTİK OKUMA
- **Başlık:** Optiğini okut. / Eksiğini *kapat.*
- **Alt:** Kamerayla okut; netin, konu analizin ve eksiklerin saniyeler içinde hazır.
- **Telefon (0°):** Kamera, "İşleniyor" anı. Vizörde markasız bir AYT optik formu, 4 köşe kılavuzu yeşile kilitli, turuncu tarama çizgisi yolun yarısında. Üstte "AYT Deneme" hapı, altta "✓ Cevapların okundu · Konular eşleştiriliyor…".
- **Kartlar:**
  1. **Sonuç kartı** (setin en büyük kartı, turuncu kenar parıltılı, telefonun sağ altından taşar): mono "NET · AYT DENEME", dev "67,5", "✓ 86 Doğru · ✕ 74 Yanlış · – 0 Boş".
  2. **Eksik çipi** (ilk kırmızı pinin üstünde): ● Fiilde Çatı · `3 eksik` · turuncu "Kapat →".
  3. **Durum çipi** (telefonun sol kenarında): yeşil ✓ "Analiz hazır".
- **Objeler:** Sağ üstte turuncu halo üzerinde 3D kil "S" logosu. **P1|P2 dikişinde** −8° eğik, markasız gerçekçi optik form (2B kalemle doldurulmuş baloncuklar, köşelerde turuncu hedef işaretleri, çapraz bir kurşun kalem); rota onun üzerinden tarama ışını olarak geçer.

### P2 — Deneme Detayı
- **Eyebrow:** DENEME DETAYI
- **Başlık:** Her yanlışın / bir *adresi* var.
- **Alt:** Soru soru gör: ne işaretledin, doğrusu neydi. Yanlışları tek dokunuşla ayıkla.
- **Telefon (−3°):** Deneme Detay › Sorular. Üstte "Net 67,5 · Doğru 86 · Yanlış 74", açık akordeon, 5 sütunlu soru ızgarası (karışık ✓/✕/–), filtre "Tümü".
- **Kartlar:** D/Y/B kartı + yeşil/kırmızı yığılmış bar (sol alttan taşar) · ızgaradan kopan 2 büyütülmüş hücre: kırmızı "✕ 13 · Sen B · Doğru D", yeşil "✓ 12 · C" (telefondaki ızgarayla aynı) · P2|P3 dikişinde "✕ Yanlışlar `74`" çipi.
- **Obje:** P2|P3 dikişinde rotaya inen 3D kil kırmızı harita pini.

### P3 — Eksik Konular (imza panel)
- **Eyebrow:** EKSİK KONULAR
- **Başlık:** Sorun Tarih değil, / *Otlukbeli.*
- **Alt:** Eksiklerin konu konu çıkar. Neyi çalışacağın artık tahmin değil.
- **Telefon (0°):** Deneme Detay › Konular. Konular zayıftan güçlüye sıralı (Ek C'deki AYT Türk Dili ve Edebiyatı konuları). Harita ekranı v1'de yok, çizme.
- **Kartlar:**
  1. **"Neyi kaçırdın" liste kartı:** her satırda kırmızı pin + mono ders etiketi + kalın konu: `TARİH` Otlukbeli Savaşı · `EDEBİYAT` Aynadaki Yalan — Necip Fazıl · `BİYOLOJİ` Hidroliz ve ATP. Her satır rotadaki bir kırmızı pine kıl inceliğinde bir çizgiyle bağlı.
  2. Halka çipi: "%41 · Cumhuriyet Edebiyatı" (turuncu-kırmızı).
  3. Halka çipi: "%100 · Batı Edebiyatı" (yeşil).
- **Obje:** Rota bu panelde telefonun **önünden** geçer. P3|P4 dikişinde kiremit renkli 3D kil açık kitap; rota sayfaların arasından geçer.

### P4 — Konu Anlatımı
- **Eyebrow:** KONU ANLATIMI
- **Başlık:** Eksik nerede, / ders *orada.*
- **Alt:** Alt başlıklar, maddeler ve örneklerle konu anlatımı. Eksiğin olan konudan başla.
- **Telefon (0°):** Derslerim › Türkçe › Sözcükte Anlam. "Anlamı Yönünden Sözcükler" açık (Temel, Yan, Mecaz, Terim Anlam), "Mecaz Anlam" açık: tanım + turuncu çizgili "Örnek" kutusu.
- **Kartlar:** büyütülmüş "ÖRNEK · Mecaz Anlam" kutusu (sağdan taşar, metin telefondakiyle aynı) · eksik kartı "TÜRKÇE · 31 EKSİK": Cümlenin Öğeleri `2 Eksiğin var`, Fiilde Çatı `3 Eksiğin var` (yanında turuncu "çalışılıyor" pini) · mono meta hapı "5 alt başlık · 25 madde".
- **Obje:** P4|P5 dikişinde lacivert/turuncu/beyaz 3 fiziksel bilgi kartından yelpaze ("Aynadaki Yalan → Necip Fazıl Kısakürek", "Hidroliz → ATP harcanmaz"). Rota yelpazenin arkasından geçer, pinler burada yeşile döner.

### P5 — Bilgi Kartları
- **Eyebrow:** BİLGİ KARTLARI
- **Başlık:** Beş dakikan mı var? / Kartları *çevir.*
- **Alt:** Eksik konularının kartları hazır. Biliyorsan sağa, tekrar lazımsa sola kaydır.
- **Telefon (0°):** Kartlarım destesi, sağa kaydırmanın ortasında. Filtre "Tarih", sayaç "12/40", üst kart "Otlukbeli Savaşı kimler arasında oldu?", kenarında yeşil "Biliyorum" parıltısı.
- **Kartlar:** 3D flip ortasında −8° açıyla telefondan taşan dev kart, arka yüz: mono "TARİH", "1473 · Otlukbeli Savaşı", "Fatih Sultan Mehmet – Uzun Hasan (Akkoyunlu)" (P3'te açılan eksik burada kapanır) · solda turuncu "↺ Tekrar et", sağda yeşil "✓ Biliyorum" çipleri · "12 / 40" sayaç çipi.

### P6 — Koçluk
- **Eyebrow:** KOÇLUK
- **Başlık:** Koçun da / *aynı* haritada.
- **Alt:** Koçun denemelerini ve eksiklerini görür; haftalık programını birlikte kurarsınız.
- **Telefon (+3°):** Programım, haftalık görünüm: bugün turuncu; ders renginde bloklar "10:00 Türkçe · Fiilde Çatı", "14:00 Tarih · Kurtuluş Savaşı Hazırlık Dönemi", "20:00 Coğrafya · İklim Bilgisi". "Koç atadı" rozeti yok.
- **Kartlar:** koç kartı (3D kil avatar, "Mehmet Özkan", mono "ÖĞRENCİ KOÇUN", altında "Son görüşme 12 Ekim"; mesajlaşma yok) · koçun gözünden öğrenci satırı ("Alparslan Kuloğlu · Eşit Ağırlık", "Son net 67,5", kırmızı mini çipler "Tarih 60 · Coğrafya 44") · alttan yükselen "Bugün" kartı: saatli 3 konu satırı, onay kutusu yok (tamamlama verisi yok).
- **Obje:** Rota haftaya dönüşür. P6|P7 dikişinde "━ TYT netin" lejant hapı + 3D kil mezuniyet kepi.

### P7 — Gelişim (telefonsuz final)
- **Eyebrow:** GELİŞİM
- **Başlık:** Emeğin artık / *görünüyor.*
- **Alt:** Net grafiğin, ortalama puanın ve sıralaman tek ekranda, her denemeyle güncel.
- **Telefon yok.** Rota büyük bir Deneme Net Grafiği'ne dönüşür: her denemede parlayan nokta, altında %12→0 turuncu alan dolgusu, soluk kesikli kılavuz çizgiler; son denemeden sonra kesikli tırmanış ve sağ üstte büyük haloyla turuncu **"YKS"** pini (P1'deki kil S'nin eşi — seti kitap ayracı gibi kapatır).
- **Kartlar (alttan yığılır):** 2×2 istatistik kartı "10 çözülen deneme · 67,79 ortalama TYT neti · 381,40 ortalama puan · 182.430 ortalama sıralama" · trend satırı yeşil ▲ "+3,25 son TYT denemesinde" + küçük "TYT | AYT" segmenti. Grafik verisi Ek C'deki TYT net geçmişi.

---

## GOOGLE PLAY FEATURE GRAPHIC (1024×500)

- Aynı lacivert gece haritası zemin, sağda turuncu parıltı.
- **Sol (x≈56–460):** küçük S + "SMAP"; başlık "Optiğini okut. / Eksiğini *kapat.*" (~60px); altında mono "TYT · AYT DENEME ANALİZİ".
- **Sağ (x≈560–968): telefon/cihaz YOK.** −8° optik form, üzerinden geçen tarama ışını-rota; önünde çerçevesiz cam "67,5 NET · ✓ 86 · ✕ 74" kartı ve "● Fiilde Çatı · 3 eksik" çipi; rota kırmızı → turuncu → yeşil pinlerden geçip küçük bir "YKS" pininde biter.
- Kenarlardan ≥56px boşluk; orta kolon (x≈460–560) boş (video oynat butonu için). Küçük UI metni, "Yeni/Ücretsiz/İndir/#1" yok.

---

## ÇIKTI BOYUTLARI

| Mağaza | Tür | Boyut | Cihaz | Adet |
|---|---|---|---|---|
| App Store (`tr`) | iPhone 6.9" | **1320×2868** | bezel-iphone | 7 |
| App Store (`tr`) | iPad 13" | **2064×2752** | bezel-ipad (iPad ekranlarını tablet düzeninde yeniden kur) | 7 |
| Google Play (`tr-TR`) | Telefon | **1080×1920** | bezel-pixel (iPhone/Dynamic Island çerçevesi **asla**) | 7 |
| Google Play (`tr-TR`) | 10" tablet | **1440×2560** | çizilmiş jenerik tablet çerçevesi | 7 |
| Google Play (`tr-TR`) | Feature graphic | **1024×500** | cihaz yok | 1 |

Hepsi RGB, **alfasız** PNG. Play telefon ve tablet formatları daha kısa olduğu için telefonu biraz küçült ve yukarı al; başlık bloğu görselin ~%20'sini geçmesin. Her panel için Türkçe alt metin (≤140 karakter) de yaz.

---

## YASAKLAR (reddedilme sebepleri)

- "En iyi", "#1", "1 numara", indirme sayısı, ödül defnesi yok.
- "Ücretsiz", "İndirim", "Yeni", "Hemen indir" gibi fiyat/CTA metinleri yok. Paywall, Ödeme, Kayıtlı Kartlar ekranları hiçbir panelde görünmez.
- "5 saniye" gibi ölçülmemiş süre iddiası yok → "saniyeler içinde".
- ÖSYM logosu, yayınevi adı, gerçek deneme kapakları yok; optik form markasız.
- Apple setinde Android/Play rozeti; Play setinde iPhone çerçevesi yok.
- İlk 3 panelde mutlaka gerçek uygulama arayüzü olmalı.
- Emoji yok (👋 dahil); bütün semboller SVG.
- Kartlardaki veri ile telefondaki veri birebir aynı olmalı.

---

## ÇALIŞMA SIRASI

1. Önce 7 paneli **tek geniş panorama** olarak iPhone formatında göster (yan yana), dikişlerde rotanın ve objelerin sürekliliğini doğrula.
2. Onaydan sonra panellere kes ve diğer formatları (iPad, Play telefon, Play tablet, feature graphic) üret.
3. Son olarak 7 iPhone panelini yan yana küçük bir önizleme şeridi olarak göster (mağazada nasıl görüneceği).
