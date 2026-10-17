# SMAP (Student Map) — Claude Design Redesign Prompt

> Bu prompt'u Claude Design'a olduğu gibi yapıştır. Ardından mevcut ekran görüntülerini referans olarak ekle.

---

## ROL & HEDEF

Sen dünya standartlarında bir mobil ürün tasarımcısısın (Duolingo, Linear, Apple Fitness, Brilliant, Notion seviyesinde). **SMAP (Student Map)** adlı, Türkiye'de **YKS (TYT/AYT)** sınavına hazırlanan lise öğrencileri ve onların **öğrenci koçları** için geliştirilmiş bir Flutter eğitim uygulamasını baştan sona yeniden tasarlayacaksın.

Uygulamanın mevcut hali işlevsel ama görsel olarak 2021 civarında kalmış: ağır lacivert app bar'lar, her yerde aynı kart şablonu, tekrarlayan "4 Alt Başlık / 26 Madde / 8 Bilgi Kartı" meta satırları, karışık illüstrasyon stilleri (flat + 3D + emoji ikon), zayıf tipografik hiyerarşi, boş/sönük grafikler ve dağınık bilgi yoğunluğu.

**Hedef:** Marka kimliğini (lacivert + turuncu, "harita/yol" metaforu) koruyarak uygulamaya **2026 seviyesinde, premium, enerjik ama odaklı** bir görünüm kazandırmak. Öğrenci açtığında "bu ciddi bir sınav aracı ama aynı zamanda çalışmayı keyifli kılıyor" hissini almalı.

Çıktı: iPhone 16 Pro (393×852 pt) çerçevesinde, aşağıda listelenen tüm ekranların yüksek sadakatli tasarımları + bir mini design system sayfası. Tüm metinler **Türkçe**.

---

## MARKA & ÜRÜN BAĞLAMI

- **İsim:** SMAP — Student Map. Logo: turuncu-lacivert "S" harfi, harita kıvrımı gibi.
- **Metafor:** Öğrencinin YKS yolculuğunu bir **haritada** görmesi. Konular = duraklar, eksikler = işaretli noktalar, ilerleme = kat edilen yol. Bu metaforu ince dokunuşlarla kullan (rota çizgileri, pin ikonları, "Harita" sekmesi, ilerleme yolları) — kitsch olmadan.
- **Kullanıcılar:** 16–19 yaş öğrenciler (birincil), öğrenci koçları (ikincil — öğrenci listesi, görüşmeler, programlar).
- **Ana değer önerisi:** Deneme sınavının **optik formunu kamerayla okut → saniyeler içinde net, konu bazlı analiz ve eksik listesi** → eksik konuları bilgi kartları ve konu anlatımlarıyla kapat.
- **Ton:** Güven veren, motive eden, net. Çocuksu değil; "ciddi sınav koçu + iyi arkadaş".

---

## TASARIM SİSTEMİ

### Renkler (mevcut kod tabanından türetildi — koru ve rafine et)
| Token | Mevcut | Kullanım |
|---|---|---|
| `navy-900` | `#0F294A` / `#0D2744` | Marka zemini, hero alanlar, primary dark buton |
| `navy-700` | `#162A40` / `#1A365D` | İkincil koyu yüzeyler |
| `orange-500` | `#FF6600` | **Primary aksiyon**, aktif sekme, kamera FAB |
| `orange-400` | `#FF8A00` | Gradyan sonu, vurgular |
| `orange-50` | `#FFD4B3` → daha açık `#FFF1E6` | Seçili arka planlar, chip'ler |
| `text-primary` | `#1C1F33` | Başlıklar |
| `text-secondary` | `#64748B` / `#8A90A6` | Gövde/yardımcı metin |
| `surface` | `#FFFFFF` | Kartlar |
| `canvas` | `#F5F7F9` / `#F1F5F9` | Sayfa zemini |
| `border` | `#E2E8F0` | Ayraçlar |
| `success` | `#22C55E` | Doğru |
| `danger` | `#EF4444` | Yanlış / eksik |
| `neutral` | `#94A3B8` | Boş |

**Kurallar:**
- Turuncu **sadece aksiyon ve ilerleme** içindir; dekorasyon için savurma.
- Doğru/Yanlış/Boş üçlüsü her yerde **aynı renk + aynı ikon şekli** ile tutarlı olsun (✓ / ✕ / –).
- Ders renkleri: her derse kendine ait yumuşak bir renk ver (Türkçe: kiremit, Matematik: kırmızı-pembe, Fizik: mor, Kimya: teal, Biyoloji: yeşil, Tarih: amber, Coğrafya: mavi, Edebiyat: bordo, Geometri: lacivert-mavi). Bu renkler kart aksanı, ilerleme barı ve ikon zemini olarak kullanılır.
- **Dark mode** varyantını da tasarla (navy tabanlı, turuncu aksanlı).

### Tipografi
- Font: **Plus Jakarta Sans** veya **Inter Display** (Türkçe karakterler ğ, ş, ı, İ, ç, ö, ü kusursuz olmalı).
- Ölçek: Display 34/40 Bold · Title 24/30 Bold · Headline 18/24 Semibold · Body 15/22 Regular · Caption 12/16 Medium · Sayısal veriler için **tabular figures**, büyük metrikler (net, puan, sıralama) için 40–56pt ağır rakamlar. Sayılar **Türkçe biçimde** yazılır: ondalık virgül, binlik nokta (67,5 · 118,30 · 549,81 · 72.154 · +%18,2).
- Mevcut uygulamadaki aşırı letter-spacing'i kaldır.

### Şekil, derinlik, hareket
- Köşe yarıçapları: kart 20, buton 14, chip 999, bottom sheet 28.
- Gölgeler çok yumuşak (y:4, blur:24, %6 opaklık); kenarlık + gölge aynı anda kullanma.
- Glassmorphism'i sadece tab bar ve üst header'ın scroll sırasında blur'lanmasında kullan.
- Mikro etkileşimler: ilerleme halkalarının dolması, doğru sayısının sayarak artması, kart basılınca hafif scale (0.98), sekme geçişlerinde matched-geometry indikatör.

### İkonografi & illüstrasyon
- Tek bir ikon ailesi: **Phosphor (duotone)** veya **SF Symbols benzeri** çizgisel ikonlar; turuncu/navy duotone.
- Ders/konu görselleri: mevcut karışık flat ikonlar yerine **tek tutarlı 3D-soft (clay) ikon seti** — aynı ışık açısı, aynı palet.
- Avatar'lar zaten 3D clay stilinde — bu stil uygulamanın tüm illüstrasyon dilini belirlesin.

### Bileşen kütüphanesi (design system sayfasında göster)
Buton (primary/secondary/ghost/destructive), segmented control (TYT/AYT/Tümü — sayaç rozetli), chip, input (label üstte, focus halinde turuncu halka), ders kartı, konu kartı, istatistik tile'ı, D/Y/B üçlüsü, ilerleme halkası, ilerleme barı, soru hücresi, bottom sheet, boş durum, "yakında" durumu, toast, tab bar.

---

## NAVİGASYON

Alt tab bar (5 öğe): **Anasayfa · Analizlerim · [Kamera FAB] · Derslerim · Hesap**
- Ortadaki kamera butonu uygulamanın kalbi: turuncu, yükseltilmiş, hafif glow; altında küçük "Okut" etiketi.
- Tab bar yüzer (floating), blur'lu, 24px yarıçaplı kapsül. Aktif sekme: dolgun ikon + turuncu nokta (mevcut üstteki turuncu çizgi + pembe arka plan yerine).
- Header: mevcut kalın lacivert blok yerine, **büyük başlıklı (large title)** ve scroll'da daralan bir header. Lacivert sadece Anasayfa hero'sunda ve önemli sonuç ekranlarında kullanılsın.

---

## ANTI-SLOP KURALLARI (tüm ekranlar)
- Emoji yok. Gradyan hero + cam kart + ilerleme halkası üçlüsü yok. Blob/glow arka plan yok.
- Aynı "kart + başlık + Tümü ›" kalıbı art arda tekrar etmez; bölümler boşluk, başlık ve ince ayraçla da ayrılabilir.
- Ekran başına tek turuncu öğe (birincil aksiyon; kamera FAB'ı hariç).
- Renkli kategori hap etiketleri yok; ders kimliği küçük bir renk noktası.
- 9–11pt metin yok; gövde ≥15pt, ikincil ≥13pt. Hiyerarşiyi tipografi kurar.
- Eksensiz süs grafik, noktalı dekoratif çizgi, iş görmeyen metrik (0 coin vb.) yok.
- İstatistik dökümü yerine doğal Türkçe içgörü cümlesi; her sayı bağlamıyla.
- Dark mode ters çevrilmiş light mode değildir; ayrıca tasarlanır.
- Her ekranı göndermeden önce bu listeye karşı kontrol et ve ihlalleri düzelt.

## EKRANLAR (hepsini tasarla)

### 1. Onboarding (4–5 sayfa)
Mevcut: küçük telefon mockup'ı + uzun başlık + gri buton. **Yeni:** Her sayfada tam genişlikte, hareketli bir kahraman görsel (gerçek UI parçalarının yüzen 3D kart kompozisyonu), kısa ve vurucu başlık (max 2 satır), turuncu primary buton, sağ üstte "Atla".
Sayfalar: ① Optiğini okut, 5 saniyede analiz ② Eksik konularını haritada gör ③ Bilgi kartlarıyla tekrar et ④ Koçunla birlikte planla ⑤ "YKS yolculuğun başlıyor" + Hemen Başla.

### 2. Giriş / Kayıt / Şifremi Unuttum
- Giriş: üstte lacivert zemin üzerinde harita çizgisi deseni + logo, altta beyaz bottom sheet'te form. Kullanıcı adı, şifre (göster/gizle), Beni hatırla, Şifremi unuttum, Apple & Google ile devam, "Hesabın yok mu? Kayıt ol".
- Kayıt: **Öğrenci / Öğrenci Koçu** segmented seçimi, yatay kaydırılabilir avatar seçici (seçili avatar büyür), Ad Soyad, kullanıcı adı, e-posta, şifre ×2, **Sınıf** (sadece öğrencide) + **Alan** (Sayısal/EA/Sözel/Dil), sözleşme onayı checkbox'ı (KVKK, Kullanım Koşulları, Gizlilik linkleri).
- Mevcut açık mavi input zeminleri yerine beyaz input + ince kenarlık + odakta turuncu halka.

### 3. Anasayfa (en önemli ekran)
Anasayfa tek soruyu cevaplar: **"Şu an ne çalışmalıyım?"** En fazla 4 bölüm, fold üstünde en fazla 3 blok. Tek dev öğe (sıradaki görev ya da son net), tek turuncu birincil aksiyon. Derslerim sekmede zaten var; Gelen Kutusu zil ikonuna taşınır. Eksik konular ve son deneme, istatistik dökümü yerine insan cümlesiyle verilir ("Son denemede Kurtuluş Savaşı'nda 13 sorudan 9'unu kaçırdın."). Önce 3 farklı yön göster (Rota / Editoryal / Odak), biri seçilince detaylandır. Ayrıntı: `SMAP_Anasayfa_Revizyon_Prompt.md`.

### 4. Kamera / Optik Okuma Akışı
- **Tutorial bottom sheet:** "Noktaları Köşelere Getirin" — gerçek fotoğraf yerine temiz bir illüstrasyon/animasyon: optik form, cevap alanı çerçevelenmiş, 4 köşe noktası turuncu. Adımlar 1-2-3 şeklinde, "Bir daha gösterme", "Anladım".
- **Kamera ekranı:** Tam ekran vizör, ortada akıllı köşe kılavuzu, otomatik algılandığında yeşil çerçeve + haptik, alt bar: galeri / deklanşör / flaş. Üstte deneme seçimi (yayın + deneme adı).
- **Köşe düzenleme ekranı:** Sürüklenebilir 4 turuncu köşe, büyüteç (loupe), "Tekrar Çek" / "Okut".
- **İşleniyor:** Taranan formun üzerinden geçen tarama çizgisi animasyonu, "Cevapların okunuyor…" → "Konular eşleştiriliyor…" adımları.
- **Sonuç anı (wow ekranı):** Lacivert zemin, büyük net sayısı sayarak artar (67.5), D/Y/B, önceki denemeye göre değişim, konfeti çok hafif, "Detaylı Analiz" CTA.

### 5. Analizlerim
Üst sekmeler: **Genel · Denemelerim · Analiz · Harita** (mevcut gri dikdörtgen butonlar yerine kaydırılabilir segmented/underline tab).
- **Genel:** TYT/AYT segment, ders filtresi (yatay chip'ler: Genel, Türkçe, Tarih, Coğrafya, Matematik, Geometri, Fizik, Kimya, Biyoloji — mevcut 3×3 büyük ızgara yer kaplıyor). **Deneme Net Grafiği**: gerçek dolgulu alan grafiği, gradient, nokta etiketleri, hedef net çizgisi (mevcut grafik düz ve boş görünüyor). 2×2 istatistik tile: Çözülen Deneme (71), Ortalama Net (118.30), Ort. Sıralama (72.154), Ortalama Puan (549.81) — her biri trend oku ve "geçen aya göre +18.2%" ile.
- **Denemelerim:** Liste veya 2'li ızgara; her kartta deneme kapak görseli, yayın adı, tarih, net (büyük), TYT/AYT etiketi, favori yıldızı. Filtre/sıralama.
- **Analiz:** Güçlü / zayıf konular, konu başına başarı halkası, karşılaşma sayısı.
- **Harita:** Derslerin ve konuların node'lar halinde bir rota/harita üzerinde gösterildiği, renklerle (yeşil=sağlam, turuncu=geliştirilmeli, kırmızı=eksik) işaretlendiği imza ekran. Bu uygulamanın "SMAP" isminin karşılığı — en yaratıcı ekran bu olsun.
- **"Yakında" durumu:** Mevcut mor butonlu dialog yerine marka renklerinde, illüstrasyonlu bottom sheet: "Yayınlandığında haber ver" (turuncu) + "Kapat".

### 6. Deneme Detay
Sekmeler: **Genel · Sorular · Konu Analizi · Bilgi Kartları**
- **Genel:** Kapak görseli küçültülmüş + başlık "AYT Deneme (Test)", Deneme no, büyük metrik satırı (Net 67.5 · Doğru 86 · Yanlış 74), puan bilgilendirme notu (OBP 85), "Deneme Sonucu / Sıralama" segment, ders bazlı kartlar (Sosyal Bilimler-1, Sosyal Bilimler-2, Matematik, Fen Bilimleri) — her birinde D/Y/B ve **yığılmış yatay bar** (yeşil/kırmızı/gri). Ders adları kesilmesin ("Sosyal Bilimle…" sorunu).
- **Sorular:** Ders başlıkları akordeon (D/Y/B rozetli); soru ızgarası 5 sütun, her hücre: soru no, öğrencinin cevabı, doğru cevap; doğru=yeşil zemin tonu, yanlış=kırmızı ton, boş=gri. Filtre: Tümü / Yanlışlar / Boşlar. Hücreye dokununca soru çözümü bottom sheet'i.
- **Konu Analizi:** Konu kartları (Cumhuriyet Edebiyatı, Söz Sanatları, Batı Edebiyatı…) — başarı yüzdesi halkası, D/Y/B; yüzdeye göre sıralama; uzun konu adları 2 satırda düzgün kırılsın.
- **Bilgi Kartları:** Bu denemedeki yanlışlardan üretilen kartlar, swipe destesi önizlemesi.

### 7. Derslerim
- TYT/AYT segment. Ders listesi: her ders kartında 3D ikon, ders adı, ilerleme barı (ders renginde), "15/20 konu tamamlandı", sağda **tek satırda** kompakt meta (📘 4 · ☰ 26 · 🃏 8) — mevcut 3 satırlık tekrar eden meta bloğunu sadeleştir.
- **Ders detay (ör. Türkçe, TYT Fizik, SOS-2 Tarih):** Large title + sağ üstte "Eksiklerim (31)" kırmızı chip; Tümü/TYT/AYT(/SOS-2) segment sayaçlı; konu kartları numaralı, "2 Eksiğin var" kırmızı etiketi konu adının yanında; uzun konu adları ("İkinci Dünya Savaşı Sürecinde…") iki satıra düzgün sığsın.
- **Konu detay (ör. Sözcükte Anlam):** Alt başlıklar akordeon kartlar (Anlamı Yönünden Sözcükler, Sözcükler Arası Anlam İlişkileri, Mecaz Oluşturma Yolları…), içinde numaralı maddeler (Temel Anlam, Yan Anlam, Mecaz Anlam, Terim Anlam). Madde açılınca: tanım + **"Örnek"** ayrı vurgulu kutu (alıntı stili), açıklama italik. Her alt başlıkta D/Y/B mini istatistik ve ilerleme. Okuma deneyimi için rahat satır aralığı, sol tarafta ince ilerleme çizgisi.

### 8. Bilgi Kartları (Kartlarım)
Swipe desteli flashcard deneyimi: ön yüz soru/kavram, dokununca 3D flip ile arka yüz. Sağa kaydır = "Biliyorum" (yeşil), sola = "Tekrar et" (turuncu). Üstte ders/konu filtresi, ilerleme sayacı (12/40). Oturum sonu özet ekranı.

### 9. Programım / Takvim
Haftalık görünüm + gün detay; ders blokları ders renginde. Koç tarafından atanmış görevler rozetli. "Ders ekle", "Gün seç" akışları bottom sheet.

### 10. Gelen Kutusu & Koç Görüşmeleri
Koç mesajları, görüşme kartları (tarih, süre, notlar), görüşme detayı.

### 11. Hesap
- **Hesap ana:** Üstte profil kartı (avatar, ad, alan, koç adı), altında gruplanmış iOS-stili liste: Profilim ve Şifre · Ödeme ve Paketler · Kayıtlı Kartlarım · Sözleşmeler · Bildirimler · (ayrı grup) Çıkış Yap (kırmızı).
- **Profil & Şifre:** Hesap Bilgileri (Ad Soyad, E-posta, Telefon) düzenlenebilir; Öğrenci Koçluğu kartı (koç avatarı + ad + mesaj at); Şifre ve Güvenlik bölümü; en altta "Hesabımı Sil" (destructive, onaylı).
- **Ödeme ve Paketler:** Mevcut plan kartı (Yıllık Avantaj – 12 Aylık, 249 ₺/ay) premium görünümlü gradient kart, "Planı Değiştir"; fatura geçmişi tablo yerine liste (fatura no, tarih, tutar, indir ikonu).
- **Paywall / Plan seçimi:** Aylık / 6 Aylık / Yıllık plan kartları, "En Popüler" rozeti, özellik karşılaştırması, turuncu CTA.
- **Kayıtlı Kartlarım:** Kartlar gerçek kart görünümünde (Mastercard/Visa logolu, **** 5678), varsayılan rozeti, swipe ile sil, "Yeni Kart Ekle".
- **Sözleşmeler:** Gizlilik Politikası, Aydınlatma Metni, Kullanım Koşulları — sade liste + okuma ekranı.
- **Bildirimler:** Toggle listesi (Aktif, Bildirimleri Aç, Kullanıcılar Görebilsin, Varsayılan Bildirim, Mobilde Göster, Otomatik Güncellemeler) — her birinin altına 1 satır açıklama; değişiklik olursa beliren sticky "Kaydet" butonu.

### 12. Koç Modu (ikincil)
Öğrencilerim listesi (avatar, son net, trend, eksik sayısı), öğrenci analiz ekranı, program atama, görüşme planlama.

### 13. Durum ekranları
Boş durumlar (henüz deneme yok → "İlk optiğini okut"), yükleniyor (skeleton), hata, internet yok, "yakında".

---

## MEVCUT TASARIMDAKİ SORUNLAR (mutlaka çöz)
1. Her ekranda aynı ağır lacivert header → yer israfı, monoton.
2. Ders kartlarında 3 satırlık tekrar eden meta (Alt Başlık / Madde / Bilgi Kartı) → görsel gürültü.
3. Karışık ikon/illüstrasyon stilleri → tek tutarlı 3D-soft set.
4. Ortada açılan küçük dialog'lar (TYT/AYT seçimi, "yakında") → bottom sheet.
5. Kesilen metinler ("Sosyal Bilimle…", "İki Savaş Arasındaki Dön…") → layout esnekliği.
6. Boş ve okunaksız net grafiği → zengin, etiketli grafik.
7. Gri dikdörtgen sekme butonları → modern segmented/underline tab.
8. Ana ekranda net bir "bugün ne yapmalıyım?" cevabı yok → görev odaklı anasayfa.
9. Mor buton gibi palet dışı renkler → sadece sistem paleti.
10. Turuncu çok fazla yerde → sadece aksiyon/ilerleme.

## ERİŞİLEBİLİRLİK
WCAG AA kontrast, min 44pt dokunma alanı, Dynamic Type desteği, renk tek başına anlam taşımasın (D/Y/B'de ikon + renk).

## ÇIKTI BEKLENTİSİ
1. Design system sayfası (renk, tipografi, bileşenler, ikonlar, light + dark).
2. Yukarıdaki tüm ekranlar, gerçekçi Türkçe örnek verilerle (öğrenci: Alparslan Kuloğlu, Eşit Ağırlık; koç: Mehmet Özkan).
3. Şu ekranların dark mode versiyonları (mağaza görsellerinde bunlar kullanılacak): Anasayfa, Kamera/İşleniyor, Deneme Sonuç (wow anı), Deneme Detay › Sorular, Analiz Haritası, Konu Detay, Kartlarım, Programım, Analizlerim › Genel.
4. Kamera akışının adım adım prototip bağlantıları.
