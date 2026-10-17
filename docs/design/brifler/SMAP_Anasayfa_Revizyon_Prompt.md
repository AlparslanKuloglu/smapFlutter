# Claude Design — Anasayfa Revizyonu (AI-slop'tan çıkış)

> **Nasıl kullanılır:** Aşağıdaki "YAPIŞTIR" bölümünü Claude Design'daki aynı projeye mesaj olarak gönder.
> **Mesajla birlikte ekle:** İlham aldığın uygulamalardan (Dersio vb.) 4–8 **ekran görüntüsü**. Uygulama adını yazmak yetmez; model o uygulamanın bugünkü tasarımını bilmeyebilir ve bildiğini sanıp uydurabilir. Görsel ekleyip her birinden **neyi alacağını** tek cümleyle yaz.

---

## YAPIŞTIR ⬇︎

Anasayfa tasarımını beğenmedik. Ürün sahibinin yorumu: "AI slop gibi duruyor." Haklı; sebeplerini yazıyorum, sonra yeniden yapalım. Kusur sende değil, brief'te: anasayfaya 7 bölüm sığdırmanı istedik ve "premium, modern" gibi her şeye uyan sıfatlar verdik.

### Neden slop görünüyor (teşhis)
1. **Her şey aynı ağırlıkta.** "Bugün", "Son deneme", "Eksiklerin haritası", "Derslerim", hızlı erişim… hepsi aynı beyaz kart + başlık + "Tümü ›" kalıbı. Göz nereye bakacağını bilmiyor.
2. **Hazır AI-dashboard kalıpları:**
   - 👋 emojili "Günaydın" selamı
   - gradyanlı hero + cam istatistik kartı + ilerleme halkası
   - "129 elmas · 0 coin · 12 gün seri" çip satırı
   - eksenleri olmayan süs sparkline
   - her kategoriye renkli hap etiket
   - üstü çizili tamamlanmış görevler
3. **Turuncu her yerde:** halka, sparkline, "Kapat", "Tümü", noktalar, FAB. Asıl aksiyon kayboluyor.
4. **Metafor süs olarak kalmış.** "Eksiklerin haritası"ndaki noktalı dikey çizgi harita değil, dekorasyon.
5. **Mikro metin enflasyonu.** 9–11pt bilgi satırları; "%31 başarı · 13 sorunun 9'u yanlış" gibi istatistik dökümleri.
6. **Dark mode sadece renkleri ters çevrilmiş light mode.**

### Yeni brief: Anasayfa tek bir soruyu cevaplar
**"Şu an ne çalışmalıyım?"** Gerisi ikincil. Derslerim zaten bir sekme; Gelen Kutusu zil ikonuna, SmapLab ve Programım başka yerlere taşınabilir.

### Yasaklar (bunları kullanırsan tasarım reddedilir)
- **İçerik ve dil**
  - Emoji yok, 👋 dahil.
  - "Tümü ›" linki en fazla 1 tane.
  - İş görmeyen metrik yok: 0 coin, anlamsız elmas sayısı.
  - Renkli kategori hap etiketleri yok. Ders kimliği en fazla küçük bir renk noktası ya da hiçbiri.
- **Kalıplar**
  - Gradyan hero + cam kart + ilerleme halkası üçlüsü yok.
  - Aynı kart kalıbı art arda 3 kez tekrar etmeyecek.
  - Eksensiz süs grafik yok. Grafik varsa okunur olacak.
  - Noktalı dekoratif çizgi, glow ve blob arka plan yok.
  - Tamamlanan görevin üstü çizilmez; ✓ işaretlenip soluklaşır.
- **Görsel düzen**
  - Ekran başına tek turuncu öğe: birincil aksiyon. Kamera FAB'ı hariç.
  - 9–11pt metin yok. Gövde metni ≥15pt, ikincil metin ≥13pt.
  - İlk ekranda (fold üstü) en fazla 3 blok; anasayfanın tamamında en fazla 4 bölüm.
- **"AI ile üretilmiş uygulama" imzası** (ekteki Dersio görseli bunun örneği; ondan bunları ALMA)
  - Büyük harfli, harf aralıklı mono üst etiket + "İyi günler, Ayşe." selam başlığı + gri alt cümle üçlüsü.
  - Seçili günü dolu hap içinde gösteren haftalık gün şeridini ekranın kahramanı yapmak.
  - Koyu "SIRADAKİ …" kartı + sağ altta yuvarlak ok butonu.
  - Yuvarlak ikonlu "hızlı işlem" satırı (Ders ekle / Öğrenci ekle / …).
  - İndigo/mor vurgu rengi, her şeyde aynı 20–24px köşe, her bölüm aynı yumuşak beyaz kart.

### Özgünlük nereden gelecek: alanın kendi görsel dili
Başka uygulamalardan değil, **YKS'nin fiziksel dünyasından** ödünç al. Öğrenci bunları her gün elinde tutuyor; başka hiçbir uygulama bunları arayüz dili olarak kullanmıyor:
- **Optik form:** A–E baloncuk satırları, 2B kalemle doldurulmuş baloncuk, köşe hizalama kareleri, kenardaki zamanlama çizgileri. İlerleme, seçim ve durum göstergeleri bu baloncuklardan türetilebilir.
- **Deneme kitapçığı:** soru numaralarının dizilişi, kitapçık türü kutusu (A/B), sayfa başlığı tipografisi, sınav kâğıdının sıkı ve ciddi düzeni.
- **Kareli defter / ders notu:** ince ızgara, kenar boşluğu çizgisi, el ile alınmış not hissi; yalnızca doğru yerde (konu anlatımı, bilgi kartı).
- **Harita:** gerçek bir rota bilgisi taşıyorsa (bkz. A yönü).

Kural: Bu motifler süs değil, **bileşen** olmalı. Örneğin bugünkü 4 görev bir A–E baloncuk satırıdır; tamamlanan görev dolu baloncuktur.

### Yapman gerekenler
- **Hiyerarşiyi tipografi kursun, kutular değil.**
  - Ekranda tek bir dev öğe olsun.
  - Bölümler ille de kart olmasın: boşluk, başlık ve ince ayraç çizgisi kullan.
- **İstatistik yerine insan cümlesi yaz:**
  - ❌ "%31 başarı · 13 sorunun 9'u yanlış"
  - ✅ "Son denemede Kurtuluş Savaşı'nda 13 sorudan 9'unu kaçırdın."
- **Her sayı bağlamıyla gelsin:** "67,5 net · öncekinden +8,25".
- **Harita/rota metaforu ya bilgiyi taşısın ya hiç kullanılmasın.**
- **Dark mode'u ayrıca düşün:** daha az kenarlık, yüzey katmanlarıyla derinlik, kontrastı ayrıca ayarla.

### İlham görselleri (ekte)
Ekteki görsellerden şunları al (her görsel için doldur):
- `[görsel 1 — örn. Dersio soru ekranı]` → **Al:** ___ · **Alma:** ___
- `[görsel 2]` → **Al:** ___ · **Alma:** ___
- `[görsel 3]` → **Al:** ___ · **Alma:** ___

Kopyalama, bunları ilke olarak kullan. SMAP'in lacivert + turuncu kimliği ve kendi bileşen dili korunacak.

### Önce 4 farklı yön göster (sadece Anasayfa, light + dark)
Üçü birbirinden **gerçekten farklı** olsun; aynı layout'un renk varyasyonu olmasın.

**A — "Rota"**
- Anasayfa bir dikey rota.
- En üstte tek ve büyük "Sıradaki durak" var: "Problemler · 40 soru · koçun atadı" ve **Başla** butonu.
- Altında bu haftanın durakları aynı çizgi üzerinde: tamamlanan dolu, bugün turuncu, gelecek boş.
- Eksik konular ayrı bir kart değil, rotanın üzerinde kırmızı pinler.
- Son deneme rotada bir kilometre taşı.

**B — "Editoryal"**
- Neredeyse hiç kart yok, gazete ya da Apple Hava Durumu sakinliğinde.
- En üstte dev "67,5" ve tek satır içgörü: "Tarih seni 9 soru geriye çekti."
- Tek buton: "Bu eksiği kapat".
- Altında ince çizgilerle ayrılmış 3 satırlık "Bugün" listesi.

**C — "Odak"**
- Ekran bugünün planından tek görevi gösterir.
- Üstte Instagram story çubuğu gibi 4 segmentli bir gün ilerlemesi.
- Ortada mevcut görev büyük, "Başla" ile süre başlar.
- Yana kaydırınca sıradaki görev gelir.
- Diğer her şey aşağıdan çekilen bir sheet'te.

**D — "Optik"**
- Arayüzün tamamı optik form dilinden türetilir.
- Bugünün görevleri, her biri bir baloncuk olan bir satır: dolu = bitti, turuncu halka = şimdi, boş = sırada.
- Son deneme, cevap kâğıdı başlığı ciddiyetinde dizilmiş tek blok: büyük "67,5 NET", altında D/Y/B.
- Eksik konular, sınav kâğıdındaki gibi numaralı satırlar; yanlış sayısı kadar kırmızı işaretli baloncuk.
- Kenarda optik formun zamanlama çizgilerini andıran ince bir dikey şerit sayfa ritmini verir.

Her yön için 2 cümleyle neden işe yaradığını yaz.

**Son adım:** Göndermeden önce her yönü yukarıdaki yasak listesine karşı kontrol et. İhlal ettiğin maddeleri dürüstçe listele ve düzelt.

Biz bir yön seçince onu detaylandıracağız. Seçilen yönün dili diğer ekranlara (Analizlerim, Deneme Detay, Derslerim…) taşınacak; o ekranlara şimdilik dokunma.

---

## İPUÇLARI (sana, prompt'a değil)

- **Sıfat değil kısıt ver.** "Modern, premium, temiz" gibi sıfatlar, modelin eğitim verisinde en sık gördüğü ortalama tasarımı üretir; slop'un kaynağı budur. Ölçülebilir yasaklar ve kurallar ise onu ortalamadan uzaklaştırır.
- **Uygulama adı değil ekran görüntüsü ver.** "Dersio gibi" yazmak yetmez. Model Dersio'nun bugünkü tasarımını bilmiyor olabilir ve uydurur. Görsel ekle ve neyi alacağını söyle: "boşluk kullanımı", "soru kartının tek odaklı olması", "tipografi ölçeği".
- **Farklı sektörlerden referans karıştır.** Sadece eğitim uygulamalarına bakarsan yine eğitim-uygulaması kalıbı çıkar. Örneğin:
  - Apple Fitness/Sağlık özet ekranı: tek büyük rakam hiyerarşisi
  - Things 3: sakin görev listesi
  - Linear mobil: yoğun ama sessiz bilgi
  - Duolingo yolu: sadece A yönü için
  - Revolut ana ekranı: tek birincil aksiyon
- **Önce dağıt, sonra daralt.** Tek ekran için 3 farklı yön iste, birini seç, sonra diğer ekranlara yay. 13 ekranı birden istemek her ekranı ortalamaya çeker.
- **Kendi kendini eleştirtmek işe yarıyor.** "Yasak listesine göre ihlallerini say" adımı modeli çıktısını yeniden kontrol etmeye zorlar.
- **Müşteriye bitmiş ekran değil 3 yön göster.** "Hangisi bizim?" sorusu "beğendin mi?" sorusundan çok daha verimli bir geri bildirim üretir.
