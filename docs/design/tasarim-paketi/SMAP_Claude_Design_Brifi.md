# SMAP: Claude Design yeniden tasarım brifi

## Rasit için: nasıl kullanılır (bu bölümü yapıştırma)

1. Claude Design'da yeni bir proje aç.
2. İlk mesaja **"YAPIŞTIR ⬇︎"** ile **"YAPIŞTIR SONU"** arasındaki her şeyi yapıştır.
3. Aynı mesaja şunları ekle:
   - `ekranlar/` klasöründeki 42 görüntü. Dosya adları numaralı, brif bu numaralara atıf yapıyor.
   - Eklenebiliyorsa üç belge: `SMAP_Ekran_Envanteri.md`, `SMAP_Gorsel_Dil.md`, `SMAP_Ekran_Goruntuleri.md`. Eklenemezse sorun değil; brif tek başına yeter.
   - Mağaza görselleri için `magaza/` klasöründeki 5 dosya: `SMAP_Magaza_Gorselleri_Prompt.md`, üç bezel PNG'si ve `splash_logo.png`. Bunlar Tur 11'de kullanılacak; ilk mesaja eklersen sonra yeniden eklemen gerekmez.
4. Tasarımcı Tur 1'i yapıp duracak. Her tur bittiğinde yalnız **`devam`** yaz. 11 tur var, sonuncusu mağaza görselleri. Turların metni ilk mesajda olduğu için yeniden yapıştırmana gerek yok.
5. Bir şeyi değiştirmek istersen "Tur 4'te şunu değiştir" yazman yeterli.
6. Her turun sonunda bir "Varsayımlar" listesi çıkacak. Fırsat bulursan bu listeyi bana getir; uygulamanın işleyişine göre düzeltirim.

---

## YAPIŞTIR ⬇︎

## 0. Çalışma biçimi (önce bunu oku)

**Soru sorma politikası.** Ürün sahibi çoğu zaman bilgisayar başında olmayacak ve sorularına cevap veremeyecek.
1. Soru sorma. Belirsiz bir noktada önce **Ek D**'deki varsayılan kararı uygula.
2. Ek D'de cevabı yoksa, gerçek veriyle uyumlu en sade seçeneği seç. Bunu turun sonundaki **"Varsayımlar"** listesine yaz ve devam et.
3. Bir ekranı çizmeni imkânsız kılan bir çelişki varsa, turun sonunda tek cümleyle sor. O ekranı yine de bir varsayımla çiz.

**Turlar.**
- Her mesajda yalnız bir tur yap ve tur bitince dur.
- Kullanıcı `devam` yazınca bir sonraki tura geç.
- "Devam edeyim mi?" gibi onay sorusu sorma.
- Turlar birbirinin üstüne kurulur. Tur 1'de tanımladığın bileşenleri sonraki turlarda yeniden icat etme. Genişletmen gerekirse genişlet ve "Ne değişti" listesine yaz.

**Kanvas düzeni (baştan uygulama akışı sırasıyla).**
- Tur 1'de bu sayfaları aç; sonraki turlar kendi panolarını ilgili sayfaya koysun:
  - `0 · Akış Haritası` (son turda dolacak)
  - `1 · Temeller`
  - `2 · Açılış ve Giriş`
  - `3 · Anasayfa ve Programım`
  - `4 · Kamera ve Optik Okuma`
  - `5 · Deneme Sonucu ve Detay`
  - `6 · Analizlerim`
  - `7 · Derslerim ve Konular`
  - `8 · Bilgi Kartları`
  - `9 · Hesap`
  - `10 · Koç`
  - `11 · Notlar`
  - `12 · Mağaza Görselleri` (Tur 11'de dolacak)
- Bir sayfada her satır bir alt akıştır ve soldan sağa kullanım sırasıyla ilerler. Satırın üstüne kısa bir başlık koy, panoların arasına "→ nereden nereye" notu yaz.
- Pano adı kodla başlasın: `4.3 · Form Kontrol · 6 kare` (sayfa.sıra).
- Her turun "Ne değişti, neden", "Varsayımlar" ve geliştirici notları `11 · Notlar` sayfasına, tur numarasıyla gitsin.

---

## 1. Rolün

Kıdemli bir mobil ürün tasarımcısısın: iOS, Android ve tasarım sistemi deneyimin var. Görevin, yaşayan bir uygulamanın dilini **koruyarak toparlamak ve evriltmek**. Bu bir rebrand değil.

Uygulamanın çekirdeği çalışıyor ama görsel dil dağınık:
- 153 farklı renk kodu, 22 farklı köşe yarıçapı,
- 6 ayrı segment kontrolü, 9 ayrı üst bar,
- Doğru/Yanlış/Boş için 4 ayrı renk sözlüğü,
- birçok sahte metrik.

İşin büyük kısmı yeni bir görünüm icat etmek değil. Bu dağınıklığı tek bir dile toplamak, bilgi hiyerarşisini düzeltmek ve kırık akışları kapatmak.

## 2. Ürün

**SMAP (Student Map).** Türkiye'de YKS'ye hazırlanan lise öğrencileri ve öğrenci koçları için bir uygulama. Arayüz Türkçe.

**Ana değer.**
1. Kâğıt deneme sınavının optik formu kamerayla okutulur.
2. Sunucu cevapları okur; öğrenci yanlış okunanları düzeltir.
3. Net, Doğru/Yanlış/Boş, puan ve sıralama hesaplanır; ders ve konu bazında analiz çıkar.
4. Eksik konular belirlenir.
5. Öğrenci eksikleri konu anlatımı ve bilgi kartlarıyla kapatır.

**Kavramlar.**
- **Sınav türleri:**
  - TYT 120 sorudur: Türkçe 40, Sosyal Bilimler 20, Temel Matematik 40, Fen Bilimleri 20.
  - AYT alan testlerinden oluşur.
  - SOS-2, AYT'deki Tarih-2 ve Coğrafya-2 bölümüdür. Uygulamada yalnız Tarih ve Coğrafya derslerinde görünür.
- **Alan:** Sayısal, Eşit Ağırlık, Sözel, Dil. 9. ve 10. sınıfta alan seçilmez.
- **Deneme:**
  - Yayınevi, deneme adı, kapak görseli ve tarih.
  - Net, doğru, yanlış, boş; puan (yerleştirme ve ham) ve sıralama.
  - Test/ders bazında D/Y/B.
  - Soru bazında durum (doğru, yanlış, boş) ve işaretlenen şık.
  - Konu bazında D/Y/B ve başarı yüzdesi.
- **Net:** doğru − yanlış ÷ 4. Sunucu hesaplar ve değerler çeyrek adımla ilerler. Örnek: 86 D, 74 Y → **67,5 net**.
- **İçerik hiyerarşisi:** Ders → Konu → Alt başlık → Madde → Bilgi kartı.
  - Madde: tanım ve örnek.
  - Bilgi kartı: kısa kavram ya da soru kartı. Durumu "eksik" ya da "biliyor" olur.
  - Eksik: yanlış yapılan soruların bağlandığı madde ve kartlar.
- **Edebiyat:** ek bir katmanı var: Yazar → Eserler (33 tür: Şiir, Roman, Öykü…). Yazar fotoğrafları tarihî, siyah-beyaz vesikalık fotoğraflardır.
- **Matematik ve Geometri:** mobilde konu içeriği yok. Kavram haritası web'de (smaptr.com).
- **Programım:** öğrencinin kendi kurduğu ders programı.
  - Günler seçilir; 06:00–23:00 arası saatlik bir çizelgeye konular yerleştirilir.
  - "Çantam", eksik konulardan oluşan bir havuzdur.
  - Koç, öğrencisinin programını görür ve düzenler.
- **Koç:**
  - Öğrencisini ekler (kullanıcı adı ve şifre oluşturur) ya da öğrenci koçun kodunu girerek bağlanır.
  - Öğrencinin analizini, denemelerini ve programını görür.
  - Öğrenci ve veli görüşmeleri planlar, görüşme notları tutar.
- **Deneme bulunamadı:** okutulan deneme sistemde tanımlı değilse öğrenci yayınevi ve deneme adıyla talep bırakır. "En geç 72 saat içinde hazır" sözü verilir.

**Kullanıcılar.**
- Öğrenciler 9–12. sınıf ve mezunlardır; çoğu 16–19 yaşında ve reşit değil.
- Sınav kaygıları yüksek, telefonda çalışıyorlar, okul Wi-Fi'ı zayıf.
- Koçlar yetişkin; birden çok öğrenciyi takip ediyorlar.

**Ton.** Ciddi bir sınav aracı: motive eden ama çocuksu olmayan, "sen" diye hitap eden.

## 3. Hedef

1. Mevcut ekranları anlaşılır, tutarlı ve erişilebilir yapmak. Sahte veriyi kaldırmak, çıkmaz akışları kapatmak.
2. Tek bir tasarım dili kurmak: token'lar, bileşen kiti ve durumlar. Geliştirici bunu birebir koda dökecek.
3. Kodda hazır olduğu halde arayüzü olmayan ya da kırık olan akışları tasarlamak:
   - bilgi kartı destesi,
   - form kontrol ve düzeltme,
   - deneme bulunamadı,
   - kamera izni,
   - gönderim ilerlemesi,
   - gerçek kategorili bildirim ayarları,
   - Matematik ve Geometri için web durumu,
   - koç ekranları.

## 4. Görsel dil

**Koru:**
- Lacivert + turuncu marka ikilisi ve logo. Logo olduğu gibi kullanılır, yeniden çizilmez.
- Lacivert üst bant fikri, ama işlevli olarak (Ek D-9).
- Ortasında turuncu kamera düğmesi olan 5 yuvalı alt çubuk. Kamera uygulamanın kalbidir.
- 9 dersin renk kimliği (Ek A-4). Tonlar ayırt edilebilir olsun diye düzeltilebilir.
- 3D karikatür avatar seti (kayıtta seçilen 7 avatar).
- Konu anlatımının madde + örnek yapısı.

**Topla (her biri tek değere ya da tek bileşene inecek):**
- lacivert ve turuncu aileleri, nötr renkler,
- D/Y/B renkleri, köşe yarıçapları, gölgeler,
- üst bar varyantları, segment kontrolü,
- dialog ve sheet dili, ikon aileleri, buton stilleri.

**Bırak:**
- karışık stok "menü illüstrasyonları",
- 28 px'te okunmayan çok renkli ders illüstrasyonları,
- palet dışı renkler (indigo, mor, amber),
- emoji,
- Material'in varsayılan yeşil anahtarı.

## 5. Tasarım ilkeleri (her turda geçerli)

1. **Gerçek veri, gerçek sayı.** Uygulamada bugün sahte değerler var:
   - "+18.2% geçen ay",
   - her derste "%75 · 15/20 Konu tamamlandı · 4 Alt Başlık · 26 Madde · 8 Bilgi Kartı",
   - her alt başlıkta "%60",
   - öğrenci kartında "Başarısız (Derece)",
   - "249 ₺" plan ve İngilizce faturalar.

   Bunların hiçbiri tasarımda yer almaz. Yalnız Ek D-2'deki gerçek veriyi göster. Veri yoksa o alanı hiç çizme; boş kutu, "0" ya da tire koyma.
2. **D/Y/B tek bir dil.** Doğru, Yanlış ve Boş her ekranda aynı renk, aynı ikon şekli (✓ / ✕ / –) ve aynı sırayla gösterilir. Renk tek başına anlam taşımaz; ikon ve etiket hep yanındadır. Bu bileşen Tur 1'de bir kez tanımlanır.
3. **Türkçe sayı biçimi, tabular rakam.**
   - Sayılar: 67,5 net · 74,75 · 412,63 puan · 48.215. sıra · %42 · +8,25.
   - Tarih: "15 Eylül 2026", kısa hali "15 Eyl.".
   - Gün kısaltmaları: Pzt Sal Çar Per Cum Cmt Paz. "Pt" ya da "Cu" kullanma.
4. **Her sayı bağlamıyla gelir:** "67,5 net · öncekinden +8,25". Etiketsiz rozet sayısı yok. Bugün ders kartlarındaki "31" ya da "60" neyin sayısı belli değil; bunlar ders başına eksik sayısıdır, "31 eksik" diye yazılır.
5. **Bir ekran, bir birincil eylem.** Kamera düğmesi bunun dışında.
6. **Hiyerarşiyi tipografi kursun, kutular değil.** Her bölüm beyaz kart olmak zorunda değil; boşluk, başlık ve ince ayraç da bölümleri ayırır.
7. **Durumlar eksiksiz.** Her ekran için ilk yükleme (iskelet), boş, hata (Tekrar Dene) ve çevrimdışı durumunu çiz. Bugün hata durumları sessizce sonsuz iskelete dönüyor.
8. **Roller.** Öğrenci ve koç aynı uygulamayı farklı sekmelerle kullanır (Ek D-29). Koç bir öğrencinin ekranlarına "öğrenci bağlamında" girer; hangi öğrenciye baktığı her ekranda görünür.
9. **Erişilebilirlik (zorunlu):**
   - Dokunma hedefi en az 48 × 48 dp.
   - Metin kontrastı WCAG AA: 4,5:1, büyük metinde 3:1. İkon ve kontrol sınırlarında 3:1.
   - Turuncu `#FF6600` üstünde beyaz metin 2,94:1 verir, bu yüzden **turuncu üstüne beyaz metin yazılmaz**.
   - Metin %130 büyütüldüğünde düzen kırılmaz.
   - Uzun Türkçe adlar kesilmez: "Sosyal Bilimler 2", "İkinci Dünya Savaşı Sürecinde Türkiye ve Dünya", "İslamiyet Etkisindeki Türk Edebiyatı (Divan-Halk Edebiyatı)".
   - Her ikon düğmesinin erişilebilir bir adı vardır.
10. **Metin:**
    - "Sen" dili (bugün sen ve siz karışık). Kısa cümleler.
    - Düğme ve ekran başlıklarında Türkçe Title Case ("Analizi Gör"), gövdede cümle düzeni.
    - Büyük harfle yazılmış düğme yok: "ANLADIM" değil "Anladım".
    - Emoji yok; bugün mesajlarda 🎉 var.
    - Hata mesajında iç kod ya da ham hata metni yok: "Gönderim hatası 590" değil "Gönderilemedi. Bağlantını kontrol edip tekrar dene."
11. **Tek ikon ailesi:** Phosphor; normal durumda Regular, seçili durumda Fill. Aynı eylem her yerde aynı ikonla gösterilir.
12. **Metafor süs değildir.** "Harita/rota" ve "optik form" motifleri yalnız bir işlevi olduğu yerde kullanılır (kamera kılavuzu, form kontrol). Dekoratif rota çizgisi, harita deseni ya da noktalı süs çizgisi yok.

## 6. Kaçınılacak kalıplar

Bu uygulama için daha önce yapılan bir tasarım, aşağıdaki kalıplar yüzünden "yapay zekâ ürünü gibi" bulunup reddedildi. Hiçbirini kullanma:
- 👋 ile "Günaydın" selamı; emoji genel olarak.
- Gradyanlı hero + cam istatistik kartı + ilerleme halkası üçlüsü.
- "129 elmas · 0 coin · 12 gün seri" gibi çip satırları; verisi olmayan oyunlaştırma.
- Ekseni olmayan süs çizgi grafik; okunmayan grafik.
- Her kategori için renkli hap etiket; üstü çizili tamamlanmış görev.
- Turuncunun her yerde kullanılması: halka, link, nokta, düğme hepsi turuncu.
- 9–11 pt bilgi satırları. Gövde metni en az 15 pt, ikincil metin en az 13 pt.
- Parıltı (glow), renkli bulanık lekeler, konfeti.
- Her bölümün aynı "kart + başlık + Tümü ›" kalıbıyla tekrarlanması.
- Büyük harfli, harf aralıklı mono üst etiket + selam başlığı + gri alt cümle üçlüsü.
- Açık temanın renkleri ters çevrilmiş koyu tema.

Her turu bitirmeden işini bu listeye karşı kontrol et ve ihlalleri düzelt. Düzeltemediğin bir şey kalırsa `11 · Notlar`a yaz.

## 7. Teknik kısıtlar

- Uygulama Flutter ile yazılıyor. Web'e özgü efekt yok: karmaşık CSS filtreleri, blend mode, metin üstünde bulanıklık.
- Bulanıklık yalnız alt çubukta ve sheet perdesinde.
- Çerçeve **iPhone 16 Pro, 402 × 874 pt**. Android'de aynı düzen sistem geri hareketiyle çalışır; Android karelerinde iPhone çentiği çizme.
- Grafikler fl_chart ile çizilebilecek türden olmalı: çizgi, alan, çubuk, halka. 3D grafik yok.
- Yalnız dikey kullanım. iPad bu işin kapsamında değil.
- Seçim ve onay yüzeyleri alttan açılan sheet olur. Bugün ekranın ortasında açılan dialoglar (TYT/AYT seçimi, "yakında", onaylar) sheet'e taşınır.
- Yeni bir 3D ya da kil ikon seti üretme. İllüstrasyon yalnız onboarding ve boş durumlarda kullanılır; sade olur ve mevcut avatar stiliyle uyuşur.
- Yazı tipi **Plus Jakarta Sans**. Ürün planında seçildi ve Türkçe glifleri tam. Rakamlar tabular.
- Açık tema ana temadır. Koyu tema Tur 1'de token düzeyinde tanımlanır ve Ek D-14'teki ekranlar için ayrıca çizilir.

## 8. Her turda istenen çıktı

1. Hi-fi ekranlar, 402 × 874, gerçekçi örnek veriyle (Ek C). Koyu tema yalnız turun belirttiği ekranlarda.
2. Durum varyantları (ilke 7).
3. Bileşen notları: Tur 1'deki token adlarıyla (`navy-900`, `text-secondary`, `radius-card`, `space-16`…). Ölçüler 4 pt ızgarada.
4. Etkileşim ve hareket notları: süre, eğri, haptik.
5. "Ne değişti, neden" listesi: her değişiklik görüntü numarasıyla bir soruna bağlanır.
6. "Varsayımlar" listesi: Ek D'de olmayan ve kendi verdiğin her karar.
7. Kanvas: panolar ilgili sayfada, akış sırasıyla (Bölüm 0).

---

## Tur 1: Temeller ve bileşen kiti

**Bak:** 09, 11, 14, 19, 22, 24, 26, 31, 37 ve Ek A.

**Bugünkü sorunlar**
- **Renk:** en az 12 lacivert, 9 turuncu ve 5 ayrı nötr aile kullanılıyor. Tema seed rengi gri (`#7D858D`); bu yüzden elle stillendirilmemiş bileşenler griye düşüyor.
- **Şekil:** 22 farklı köşe yarıçapı var. İstatistik kartının içi 6, dışı 12.
- **Segment kontrolü:** 6 ayrı yazılmış; seçili durum için 4 farklı turuncu kullanılıyor.
- **D/Y/B:** 4 ayrı renk sözlüğü var. Bir ekranda "Doğru" lacivert, "Boş" bazen siyah, bazen gri.
- **Üst bar:** 9 ayrı yazılmış. Alt sayfalarda başlık yok; yalnız kullanıcı adı ve avatar görünüyor.
- **Tipografi:** yazı tipi tanımlı değil (sistem fontu), 18 farklı punto ve 9 pt metin var.
- **Dialog dili:** köşe yarıçapı 12, 16, 20 ve 24 arasında değişiyor. İptal düğmeleri "Vazgeç", "İptal", "Kapat", "Geri Al", "Tamam" diye karışık.
- **Kontrast:** kamera düğmesinde turuncu üstüne beyaz ikon yaklaşık 1,8:1; pasif sekme etiketi yaklaşık 2:1.
- **Diğer:** anahtar (switch) Material yeşili. Birincil düğme bazen lacivert, bazen soluk gri, bazen indigo.

**İstenen**
1. **Token tablosu, açık ve koyu tema:**
   - lacivert ve turuncu skalaları (50–950),
   - nötrler, yüzeyler, metin rolleri,
   - D/Y/B (renk ve ikon),
   - 9 ders rengi (açık zemin + vurgu, iki temada),
   - grafik serileri, durum renkleri (bilgi, başarı, uyarı, hata),
   - gölge (en çok 2), köşe yarıçapı (en çok 5 değer + tam yuvarlak), boşluk (4 pt ızgara), hareket süreleri.

   Her metin/zemin çiftinin kontrast oranını yaz.
2. **Tipografi ölçeği** (Plus Jakarta Sans): display, title, headline, body, caption. Net ve puan gibi büyük metrikler için ayrıca bir rakam stili.
3. **Düğmeler:**
   - türler: birincil (Ek D-6), ikincil, sessiz, tehlikeli, metin;
   - boylar: 48 ve 40;
   - durumlar: yükleniyor, pasif.
4. **Tek bir segment kontrolü:** 2–4 seçenek. Sayaçlı varyantta sayının ne olduğu yazar ("TYT · 28 eksik").
5. **Ekran içi sekme çubuğu** (Deneme Detay ve Analizlerim için). Kaydırılabilir varyantı olsun; son sekme kesilmesin.
6. **Çipler:** filtre ve seçim çipi; ders çipi (renk noktası + ad).
7. **Girdiler:** etiket alanın üstünde.
   - Türler: metin, şifre (göster/gizle), arama, açılır seçim, 6 haneli kod, çok satırlı.
   - Durumlar: hata, odak, pasif, salt okunur.
8. **Satır bileşeni:** ikon + başlık + alt metin + sağ öğe. Sağ öğe ok, değer, anahtar ya da rozet olabilir. Tehlikeli varyantı da olsun.
9. **D/Y/B ailesi:**
   - büyük ve küçük boy üçlü sayaç,
   - yığılmış yatay çubuk,
   - soru hücresi: soru numarası, işaretlenen şık, yanlışsa doğru şık ve durum.
10. **İlerleme:**
    - Ders renginde çubuk.
    - Başarı yüzdesi halkası. "Hiç soru yok" ile "%0" birbirinden ayırt edilebilmeli.
11. **Kartlar ve satırlar:**
    - ders satırı, konu satırı;
    - deneme kartı: kapak, ad, yayınevi, tarih, TYT/AYT, net;
    - istatistik kutusu: değer + etiket + bağlam. Sahte değişim değeri yok.
12. **Üst bar ailesi:**
    - kök sekme: lacivert bant, ekran başlığı, sağda tek eylem;
    - detay: geri + başlık + eylem;
    - kaydırınca küçülen davranış.
13. **Alt çubuk:**
    - Öğrenci: Anasayfa · Analizlerim · Kamera · Derslerim · Hesap.
    - Koç: Anasayfa · Öğrencilerim · Kamera · Görüşmelerim · Hesap.
    - Kamera düğmesinin "Okut" etiketi olsun, ikon kontrastı en az 3:1 (Ek D-8).
    - Seçili sekmenin tek bir turuncu göstergesi olsun.
14. **Sheet çerçevesi:** küçük, orta ve tam boy.
    - Parçalar: tutamaç, başlık + alt başlık, kapat, kaydırılabilir içerik, sabit alt eylem alanı.
    - Klavye açıkken alt eylem alanının davranışı.
    - İşlem sürerken kapanmayan "meşgul" durumu.
15. **Onay sheet'i:** normal ve tehlikeli varyant. Ayrıca bir "Yakında" sheet'i: tek varyant, yalnız "Tamam" düğmesi, "haber ver" yok. Ekranlarda kullanılmayacak, kitte dursun (Ek D-4).
16. **Bildirim (toast):** bilgi, başarı ve hata türleri; "Geri Al" eylemli varyant.
17. **Durum kalıpları:** iskelet, boş (ekran düzeyi ve bölüm düzeyi), hata (Tekrar Dene), çevrimdışı şeridi.
18. **Avatar:** tekli, üst üste binen (koç listesi), rol rozetli.

**Koyu tema:** token tablosu ve bileşen kitinin koyu sayfası.

**Kanvas:** 0–12 arası bütün sayfaları aç. Bu turun panoları `1 · Temeller`e.

---

## Tur 2: Kamera ve optik okuma

**Bak:** 38. Akışın diğer adımlarının görüntüsü yok; `SMAP_Ekran_Envanteri.md` §2.4'e göre çiz.

**Bugün akış şöyle:**
1. Kamera düğmesi.
2. İlk açılışta öğretici.
3. Çekim.
4. Köşe kırpma ve düzenleme.
5. "Hatırlatma" yönerge dialogu.
6. "Denemeniz Analiz Ediliyor!" bekleme ekranı.
7. Form Kontrol: sunucunun okuduğu form görseli, "Düzenleme Yap", "Düzenlemeler (N)", "Onayla".
8. Deneme sistemde varsa 3 adımlı sonuç akışı; yoksa "Denemen Henüz Sistemde Mevcut Değil" talep formu.

**Bugünkü sorunlar**
- **Öğretici (38):** metin "beyaz noktalar" diyor ama görseldeki noktalar turuncu. Tek sayfaya sayfa göstergesi konmuş, "ANLADIM" büyük harfle yazılmış, fotoğraf yapay görünüyor.
- **Çekim ve gönderim:**
  - Kamera izni reddedilince bir ekran yok.
  - Gönderim sırasında ilerleme yok, yalnız dönen gösterge var.
  - Hata olunca sayfa kapanıyor ve çekilen fotoğraf kayboluyor.
- **"Hatırlatma" dialogu:** "GÖNDER" düğmesi aslında yalnız "devam" demek; "GERİ" kırmızı.
- **Form Kontrol:** düzeltme için iki ayrı sheet ve bir onay dialogu gerekiyor; kolon, soru ve şık seçimi ham bir form gibi.
- **Sonuç akışı:**
  - 3 adım sürüyor ve "İlerle" düğmesi çalışmıyor.
  - "OBP notunuz 85" sabit yazılmış.
  - 2. adımda ders kartlarına dokunmak bir şey yapmıyor.
  - Kullanıcı avatarı yüklenmiyor.
- **Deneme bulunamadı formu:** alan doğrulaması yok.

**İstenen**
1. **İzin:** ilk kullanımda kamera izni primer'ı. İzin reddedildiyse "Ayarları Aç" ekranı.
2. **Öğretici:** tek ekran, 3 kısa adım, fotoğraf yerine illüstrasyon:
   - cevap alanını çerçeveye al,
   - ders adlarının yazdığı yatay şeridi dışarıda bırak,
   - 4 köşe noktasını formun köşelerine oturt.

   Altında "Bir daha gösterme" ve "Anladım".
3. **Çekim ekranı:** vizör ve cevap alanı kılavuzu; üstte kapat ve yardım; altta deklanşör. Flaş ve galeri yok (Ek D-15).
4. **Köşe düzenleme:** sürüklenebilir 4 köşe, büyüteç, "Tekrar Çek" ve "Devam". Bugünkü "Hatırlatma" dialogunun yerine bu ekranda tek satırlık bir ipucu ve küçük bir örnek görsel; "Bir daha gösterme".
5. **Gönderim:** yalnız gerçek adımlar gösterilir: "Fotoğraf hazırlanıyor" → "Gönderiliyor %NN" → "Cevapların okunuyor". Sahte adım ekleme. Zaman aşımı ya da hata olursa fotoğraf saklanır; "Tekrar Dene" ve "Yeni Fotoğraf" seçenekleri.
6. **Form Kontrol (çekirdek ekran):**
   - okunan form görseli yakınlaştırılabilir; altında okunan cevapların özeti;
   - bir soruyu düzeltmek tek bir sheet'te olur: kolon → soru numarası → şık (A–E, Boş);
   - yapılan düzeltmeler aynı sheet'te liste halinde görünür ve düzeltme sayısı her an belli;
   - birincil eylem "Cevapları Onayla".
7. **Sonuç anı:** 3 adım yerine tek ekran.
   - Yayınevi, deneme adı ve kapak.
   - Büyük net ve D/Y/B; varsa puan; varsa önceki denemeye göre fark.
   - AYT ise alan sekmeleri.
   - Kazanılan bilgi kartı sayısı: "Bu denemeden 23 bilgi kartı eklendi".
   - İki eylem: "Detaylı Analiz" (birincil) ve "Anasayfa".
   - Konfeti yok; başarı haptiği var.
8. **Deneme bulunamadı:**
   - Açıklama, ardından Yayınevi ve Deneme Adı alanları (zorunlu, doğrulamalı).
   - "Analizimi Hazırlayın" → onay → "Talebin alındı. En geç 72 saat içinde hazır."
9. **Hata ekranları:**
   - form algılanamadı,
   - okuma geçici olarak kapalı (bakım),
   - çevrimdışı: "Bağlantı gelince gönderilecek". Bu planlı bir özellik; panoya "planlı" notu düş.
10. **Bildirim izni:** ilk başarılı okumadan sonra primer: "Sonucun hazır olunca haber verelim mi?"

**Koyu tema:** çekim, gönderim, sonuç anı.

**Kanvas:** `4 · Kamera ve Optik Okuma`. Sonuç anı, `5 · Deneme Sonucu ve Detay`ın ilk panosu olur.

---

## Tur 3: Deneme Detay ve Soru Detay

**Bak:** 24, 25, 26, 27, 28.

**Bugünkü sorunlar**
- **Adlar:** ders kartlarında ad kesiliyor ("Sosyal Bilimle…" iki kez). Aynı test üç ekranda üç farklı adla geçiyor: "Sosyal Bilimler", "Sosyal Bilimle…", "AYT Türk Dili ve Edebiyatı".
- **Kimlik ve puan:**
  - Kapakta "DENEME 6" yazıyor, etikette "Deneme: 1"; başlıkta "(Test)" eki var.
  - "TYT puanınız…" bandı bir AYT ekranında çıkıyor; puan değeri hiçbir yerde görünmüyor.
- **Segment:** üst üste iki farklı segment stili var.
- **Sorular sekmesi:**
  - Doğru ve yanlış ikonları farklı biçimde.
  - Her hücrede "A" yazıyor; işaretlenen şık mı, doğru şık mı belli değil.
  - Başlık ile ızgara arasında 90 pt boşluk var.
  - Açık ve kapalı bölümlerde ok işareti aynı.
  - Rozetler etiketsiz.
- **Konu Analizi:**
  - Sarı halkanın kontrastı yaklaşık 1,2:1.
  - %41,67 aşağı yuvarlanıp %41 yazılıyor.
  - "0 doğru, 1 yanlış" ile "hiç veri yok" aynı görünüyor (%0).
  - Konular sıralanmıyor; adlar kesiliyor.
- **Bilgi Kartları sekmesi:** kartlara dokunmak bir şey yapmıyor.

**İstenen**
1. **Üst bölüm:**
   - Küçük kapak; yayınevi + deneme adı; tarih; TYT/AYT.
   - Büyük net ve D/Y/B (Boş dahil).
   - Puan ve sıralama tek blokta: yerleştirme puanı, ham puan, sıralama (yalnız varsa). OBP notu yalnız gerçek bir değer varsa.
2. **Sekmeler:** Genel · Sorular · Konular · Kartlar. Tur 1'deki tek sekme bileşeni kullanılır.
3. **Genel:** test başına D/Y/B yığılmış çubuk; adlar tam yazılır.
   - TYT: Türkçe, Sosyal Bilimler, Temel Matematik, Fen Bilimleri.
   - AYT: Türk Dili ve Edebiyatı–Sosyal Bilimler 1, Sosyal Bilimler 2, Matematik, Fen Bilimleri.
4. **Sorular:**
   - Test akordeonu; başlıktaki sayaçlar D/Y/B diye etiketli.
   - 5 sütunlu soru ızgarası. Hücrede soru numarası, öğrencinin işareti ve yanlışsa doğru şık.
   - Filtre: Tümü / Yanlışlar / Boşlar.
   - Hücreye dokununca Soru Detay açılır.
5. **Konular:**
   - Konular zayıftan güçlüye sıralı.
   - Başarı yüzdesi = doğru ÷ konudaki soru sayısı.
   - 1–2 soruluk konular "az soru" diye işaretli.
   - "Bu Konuyu Çalış" → konu detayı (Tur 5).
6. **Kartlar:** bu denemeden eklenen bilgi kartları, derse göre gruplu. "Kartları Çalış" → kart destesi (Tur 5).
7. **Soru Detay:**
   - Üstte ders, soru numarası, senin şıkkın ve doğru şık.
   - "Soru Analizi": açıklama + ilgili bilgi kartları (kaydırılabilir deste).
   - "Soru Fotoğrafı": telif nedeniyle paylaşılamadığını söyleyen sade bir not. "Fotoğraf Çek" ve "Soru Bankam" yok (Ek D-4).
8. **Durumlar:** iskelet, test verisi yok, hata.

**Koyu tema:** Genel ve Sorular.

**Kanvas:** `5 · Deneme Sonucu ve Detay`.

---

## Tur 4: Analizlerim

**Bak:** 19, 20, 21, 22, 23.

**Bugünkü sorunlar**
- **Grafik:**
  - Ekranın %37'sini kaplıyor ama bilgi vermiyor: çizgi 120'de doygun, neredeyse düz.
  - X ekseninde 6 seyrek etiket var, sonuncusu kesik.
  - Turuncu noktalı çizginin lejantı yok.
- **İstatistikler:** dört kutuda da sabit "+18.2% gecen ay" yazıyor. Sayı biçimi karışık: "118.30", "72.154".
- **Filtre:** "Genel ⌄" çipi bir filtre açıyor ama neyi süzdüğünü söylemiyor. Panelde başlığın altında 125 pt boşluk, gereksiz başlık tekrarı var ve arkada perde (scrim) yok.
- **Sekmeler:** 4 sekmenin 2'si (Analiz, Harita) "yakında" dialoguna çıkıyor (22, 23).
- **Denemelerim:** hepsinde "Deneme: 1" yazıyor, adlarda "(Test)" var, kapaklar şablon. Filtre ve sıralama yok; ekrana yalnız 4 kart sığıyor.
- **Başlık:** ekran başlığı yok.

**İstenen**
1. Ekran başlığı "Analizlerim". Sekmeler: Genel · Denemelerim. Analiz ve Harita v1'de görünmez.
2. **Filtre:** seçili değer tek satırda görünür ("TYT · Genel"); dokununca sheet açılır: sınav türü (TYT / AYT + alan) ve ders.
3. **Net grafiği:**
   - Noktalı çizgi ve hafif bir alan dolgusu.
   - Y ekseni sınav türüne göre (TYT 0–120). X ekseni deneme tarihleri, Türkçe.
   - Bir noktaya dokununca o denemenin adı, tarihi ve neti; son deneme vurgulu.
   - Hedef net çizgisi yok (veri yok).
4. **İstatistikler:**
   - "Genel" seçiliyken: çözülen deneme, ortalama net, ortalama puan, ortalama sıralama.
   - Tek ders seçiliyken: toplam doğru, yanlış, boş ve ortalama net.
   - Değişim yalnız son iki denemeden hesaplanabildiği yerde gösterilir ("son denemede +8,25"). "Geçen ay" karşılaştırması yok.
5. **Denemelerim:**
   - Okunur bir liste ya da sık bir ızgara; hangisini seçtiğini gerekçesiyle yaz.
   - Her öğede: kapak, ad, yayınevi, tarih, TYT/AYT, en belirgin öğe olarak net, küçük D/Y/B.
   - Favori yıldızı düşük vurguyla (yalnız cihazda saklanıyor).
   - Filtre: TYT/AYT ve tarih. Sıralama: en yeni / en yüksek net. Sonsuz kaydırma.
   - Boş durum: "İlk denemeni okut" → kamera.
6. **Durumlar:** hiç deneme yok (yeni kullanıcı); tek deneme (grafik yerine tek değer); hata; çevrimdışı (son veri + çevrimdışı şeridi).

**Koyu tema:** Genel.

**Kanvas:** `6 · Analizlerim`.

---

## Tur 5: Derslerim, konular ve bilgi kartları

**Bak:** 11–18, 29, 30, 39, 40, 41, 42. (11 ile 39 aynı ekran.)

**Bugünkü sorunlar**
- **Sahte veri:** her ders ve konu kartında aynı değerler var (%75, 15/20, 4/26/8). Konu kartında bile "15/20 Konu tamamlandı" yazıyor.
- **Renk:** her kartın şerit rengi rastgele (kahve, zeytin, mor dahil); dersin kimliği okunmuyor.
- **Sayılar ve rozetler:**
  - Başlığın sağındaki "31" ve segmentin altındaki 31/28/3 rozetleri etiketsiz; rozetler listeyle çakışıyor.
  - Konu numaraları 3, 4, 4, 5, 5, 6 diye gidiyor.
  - AYT sekmesi TYT listesini gösteriyor; "Tümü" ile "Sos-2" sekmeleri aynı.
  - Adlar kesiliyor ("İkinci Dünya Savaşı Sürecin…").
- **TYT/AYT/SOS-2 seçimi:** üç ilgisiz renkli düğmeli bir orta dialog; kapatma düğmesi yok (14, 17). Derslerim'den girince TYT sekmesindeyken bile yeniden soruluyor.
- **Konu detayı:**
  - "%60" yazıyor ama çubuk boş; 0/0/0 sayaçları etiketsiz.
  - Her bölümde 82 pt'lik yer tutucu bir kitap ikonu var.
  - Açık madde bazen kırmızı, bazen siyah.
  - Açıklama metni 12,5 pt ve soluk.
  - "Yansıma  Sözcükler" adında çift boşluk var.
- **Ölü akışlar:** "Eksikler" düğmesi bir şey yapmıyor. Bilgi kartı destesi (Eksiklerim / Bildiklerim / Favorilerim) kodda hazır ama hiçbir yerden açılmıyor.
- **Matematik/Geometri:** dokununca web'e yönlendiren, kendi içinde çelişen bir "yakında" dialogu açılıyor (23).

**İstenen**
1. **Derslerim:**
   - TYT / AYT segmenti.
   - Ders satırında: ders rengi + glif; ad ("TYT" öneki tekrar edilmez); etiketli eksik sayısı ("31 eksik"); gerçekse bilgi kartı ilerlemesi (bilinen / toplam). Sahte yüzde yok.
   - AYT'de Tarih-2 ve Coğrafya-2 (SOS-2) ayrımı açık görünür.
2. **TYT/AYT/SOS-2 seçimi:** dialog kaldırılır; seçim ders detayının içinde bir segment olur. Derslerim'de seçili olan segment taşınır, yeniden sorulmaz.
3. **Ders detayı:**
   - Başlıkta "Eksiklerim (31)" düğmesi; yalnız eksik konuları süzer.
   - Konu satırları 1'den n'ye kesintisiz numaralı; ad tam (2 satıra kadar); eksik varsa etiketi.
   - Segment sayaçları etiketli.
4. **Konu detayı (okuma ekranı):**
   - Alt başlık akordeonu: ad, madde sayısı, kart durumu (bilinen ✓ / eksik ✕, etiketli).
   - Madde: numara, ad, tanım. "Örnek" ayrı ve okunur bir kutuda; açıklama okunur boyda.
   - Eksik madde tek ve tutarlı bir işaretle gösterilir (renk + ikon).
   - Maddenin altındaki bilgi kartı simgeleri kart sheet'ini açar.
   - Sayfa ilk eksik maddeye kayar.
   - Okuma için gövde 16 pt; satır uzunluğu ve satır aralığı rahat.
5. **Bilgi kartı sheet'i:** kart başlığı, içerik; eksikse "Öğrendim"; favori.
6. **Kart destesi (Kartlarım):**
   - Giriş noktaları: ders detayındaki "Kartlarım", Deneme Detay › Kartlar, konu detayı.
   - Sekmeler: Eksiklerim · Bildiklerim · Favorilerim (sayılı).
   - Kaydırılabilir deste; eksik kartta "Öğrendim", her kartta "Detay"; oturum sayacı (12/40).
   - Her sekme için ayrı boş durum metni (Ek C).
   - "Öğrendim" onayı yalnız ilk seferde bir kez sorulur.
7. **Edebiyat:**
   - Konular / Yazar & Eserler segmenti.
   - Yazar listesi: fotoğraf, ad, dönem.
   - Yazar sheet'i: hakkında; eserler türe göre gruplu; "Öğrendim" işaretleri.
8. **Matematik ve Geometri:** ders satırında "Web'de" etiketi. Dokununca sheet: "Matematik ve Geometri kavram haritan şimdilik smaptr.com'da." + "Web'de Aç" + "Tamam". "Haber ver" yok.
9. **Durumlar:** iskelet, konu verisi yok, hata, çevrimdışı.

**Koyu tema:** konu detayı ve kart destesi.

**Kanvas:** `7 · Derslerim ve Konular`; kart destesi `8 · Bilgi Kartları`.

---

## Tur 6: Anasayfa ve Programım

**Bak:** 09, 10, 14, 17. Programım'ın görüntüsü yok; `SMAP_Ekran_Envanteri.md` §2.7'ye göre çiz.

**Bugünkü sorunlar**
- **Tekrar ve anlamsız veri:** kullanıcı adı ve avatar iki kez görünüyor. %0 ilerleme çubuğu dolu gibi duruyor; "0" coin anlamsız.
- **Ders çipleri:** rozetler (31, 60, 44) etiketsiz; son çip kesik.
- **3×2 menü:**
  - 3 farklı ikon stili var.
  - 2 karo "yakında" diyor (Gelen Kutusu, SmapLab).
  - "Derslerim" alt çubukta zaten var.
- **Takvim:** salt görsel; günlere dokunulamıyor, program verisi çizilmiyor. Gün kısaltmaları "Pt", "Cu". Alt satırı alt çubuğun altında kalıyor.
- **Sabit üst blok:** ekranın %25'ini kaplıyor.
- **Programım:** arama ve filtre çalışmıyor; boş ve hata durumu yok; her program kartında aynı takvim ikonu var.

**İstenen**
1. **Anasayfa tek bir soruyu cevaplar: "Bugün ne yapmalıyım?"** En çok 4 bölüm olur:
   - **a. Üst bant:** selam (emoji yok) ve YKS geri sayımı. Geri sayım cihazda hesaplanır; tarih Ek C'de.
   - **b. Bugün:** bugünkü programdaki konular (saat, ders, konu); veri Programım'dan gelir. Program yoksa "Haftalık Programını Kur" çağrısı. Tamamlandı işareti yok (veri yok).
   - **c. Son deneme:**
     - net, D/Y/B ve önceki denemeye göre fark;
     - en çok soru kaçırılan konu tek cümleyle: "Kurtuluş Savaşı Hazırlık Dönemi'nde 13 sorudan 9'unu kaçırdın.";
     - "Analizi Gör" düğmesi.

     Hiç deneme yoksa "İlk Denemeni Okut" → kamera.
   - **d. Derslerin:** yatay ders şeridi; her derste etiketli eksik sayısı ("31 eksik"); dokununca ders detayı.

   Kişi kartı (coin, ilerleme), menü ızgarası ve takvim kaldırılır. Gelen Kutusu ve SmapLab v1'de yok.
2. **Programım** (Anasayfa'daki "Bugün" bölümünden ve "Programım" bağlantısından açılır):
   - Program listesi: ad, motivasyon cümlesi, tarih aralığı; çalışan arama.
   - Yeni program:
     1. Gün seçimi (çoklu).
     2. 06:00–23:00 çizelgesi. Konular "Çantam" (eksik konular) ya da "Dersler" kaynağından yerleştirilir.
     3. Program adı ve motivasyon cümlesiyle kaydet.
   - Düzenleme ve iptal; "Günü Sıfırla" onay sheet'iyle.
3. **Durumlar:** yeni kullanıcı (deneme yok, program yok), iskelet, hata, çevrimdışı.

**Koyu tema:** Anasayfa.

**Kanvas:** `3 · Anasayfa ve Programım`.

---

## Tur 7: Açılış, onboarding, giriş ve kayıt

**Bak:** 01–08.

**Bugünkü sorunlar**
- **Onboarding:**
  - 5 slayt, eski arayüzün ekran görüntülerini gösteriyor (Kartlarım, Oyunlar, elmas 5590, "Profil" sekmesi).
  - Görsellerde "Lorem ipsum" ve yanlış ders etiketleri kalmış.
  - Başlıklar 4 satıra kadar uzuyor; "farketmeksizin" yazım hatası var.
  - "5 saniyede" diye ölçülmemiş bir süre iddiası var.
  - CTA soluk gri ve pasif görünüyor; son slaytta "Tanıtımı atla" duruyor.
- **Giriş:**
  - Alanlar etiketsiz; sen ve siz hitabı karışık.
  - Sosyal giriş birincil düğmeden önce geliyor; Google logosu tek renk "G".
  - Zeminde lacivert ile gri arasında sert bir geçiş var.
  - Alanlar test verisiyle önceden dolu geliyor.
- **Kayıt:**
  - "Tamamla" düğmesi ekranın altında kesik (07).
  - Placeholder ile girilmiş değer ayırt edilmiyor.
  - Rol değişince form zıplıyor.
  - Yasal metinde üç kalın, altı çizili bağlantı var.
- **Açılış:** splash yok; önce beyaz bir ekranda dönen gösterge çıkıyor.

**İstenen**
1. **Splash:** logo, lacivert zemin.
2. **Onboarding (ürün planındaki akış):**
   1. Yeni arayüzden parçalarla 3 tanıtım ekranı: okut → analiz → eksikleri kapat. Başlık en çok 2 satır; süre iddiası yok ("saniyeler içinde" yeterli).
   2. Rol seçimi: Öğrenciyim / Öğrenci Koçuyum.
   3. Öğrenciyse sınıf ve alan. 9–10. sınıfta alan sorulmaz; neden sorulmadığını tek satırla söyle.
   4. Kamera izni primer'ı; "Sonra" seçeneğiyle.
   5. Hesap: giriş ya da kayıt.
3. **Giriş:**
   - Kullanıcı adı ve şifre (etiketli, göster/gizle).
   - "Şifremi Unuttum"; birincil "Giriş Yap"; altta "Hesabın yok mu? Kayıt Ol".
   - Sosyal giriş ana tasarımda yok. Ayrı bir karede "Apple ve Google açıkken" varyantını çiz: Apple kurallarına uygun, iki düğme eşit ağırlıkta.
4. **Kayıt:**
   - Rol; avatar seçici (7 avatar, kaç tane olduğu görünür).
   - Ad Soyad; Kullanıcı Adı (canlı müsaitlik kontrolüyle); E-posta; Şifre ve Şifre Tekrar.
   - Öğrencide sınıf ve alan; koçta koçluk kodu hakkında bir bilgi satırı.
   - Yasal onay tek satır, bağlantılar sade; "Kayıt Ol".
   - Yasal metinler yüklenemezse kayıt kapalı olur: bunu hata durumu olarak çiz.
5. **Şifremi Unuttum:** e-posta → 6 haneli kod → yeni şifre → bitti.
6. **Genel ekranlar:** zorunlu güncelleme, oturum süresi doldu, bakım, bilinmeyen rol hatası.

**Kanvas:** `2 · Açılış ve Giriş`.

---

## Tur 8: Hesap

**Bak:** 31–37.

**Bugünkü sorunlar**
- **Profil ve şifre:**
  - Alt sayfaların başlığı yok; avatar iki kez görünüyor.
  - İki farklı alan stili kullanılıyor.
  - Şifre alanları için kaydet düğmesi yok (33).
  - "Hesabımı Sil" düğme gibi görünmüyor.
- **Sahte ekranlar:** Ödeme, Kayıtlı Kartlar ve faturalar tamamen sahte (34, 35).
- **Bildirimler (37):**
  - Etiketler bir web panelinden kopyalanmış ("Kullanıcılar Görebilsin", "Mobilde Göster").
  - Anahtarlar yeşil.
  - Anlık açılıp kapanan anahtarlar için ayrıca "Kaydet" düğmesi var.
- **Sözleşmeler:** palet dışı amber ikon; tarih ya da sürüm bilgisi yok.

**İstenen**
1. **Hesap ana ekranı:**
   - Profil özeti: avatar, ad, sınıf · alan, koç adı.
   - Gruplar: Hesap (Profil, Şifre), Koçluk, Bildirimler, Yasal (Sözleşmeler), Destek (e-posta).
   - Ayrı bir bölgede, onaylı "Çıkış Yap"; en altta sürüm numarası.
   - Ödeme ve Kayıtlı Kartlarım yok (Ek D-4).
2. **Profil:** ad, e-posta, telefon (+90 maskeli), sınıf, alan. "Düzenle" → "Kaydet". Avatar değiştirme (7 avatar).
3. **Koçluk:**
   - Koçu varsa: avatar, ad ve "Bağlantıyı Kaldır". Onay metni sonucu açıklasın: "Koçun gelişimini artık göremeyecek."
   - Koçu yoksa: koçluk kodu girişi ve "Koçluk Kodu Nedir?" açıklaması.
4. **Şifre:** mevcut şifre, yeni şifre, yeni şifre tekrar, kural ipucu; "Şifreyi Güncelle".
5. **Bildirimler:**
   - Kategoriler: deneme sonucun hazır; koçun deneme ya da ödev atadı; görüşme planlandı; çalışma hatırlatıcısı.
   - Sessiz saatler, varsayılan 22:00–08:00.
   - Sistem izni kapalıysa uyarı ve "Ayarları Aç".
   - Değişiklikler anında kaydedilir, "Kaydet" düğmesi yok.
   - Bildirim altyapısı planlı; panoya not düş.
6. **Sözleşmeler:** liste (ad, sürüm, tarih) ve okuma ekranı.
7. **Hesabı Sil:** neyin silineceğini anlatan ekran → tehlikeli onay sheet'i → işlem sürüyor → sonuç.
8. **Çıkış onayı.**

**Kanvas:** `9 · Hesap`.

---

## Tur 9: Koç

**Bak:** görüntü yok. `SMAP_Ekran_Envanteri.md` §2.3 (koç anasayfası) ve §2.9'a göre çiz.

**Bugünkü sorunlar**
- **Koç Anasayfa:**
  - 6 karonun 4'ü "yakında".
  - Öğrenci kartına dokununca 4 gri düğmeli bir dialog açılıyor.
  - "Kaynak Takibi" yalnız bir yer tutucu.
- **Öğrenci kartı:** her öğrencide sabit "Başarısız (Derece)" yazıyor.
- **Görüşmeler:** arama çalışmıyor; tarihte yıl yok; tür etiketi 11 pt ve soluk; mesajlarda emoji var.

**İstenen**
1. **Koç Anasayfa:**
   - Öğrenci şeridi: avatar, ad, son deneme tarihi.
   - "Dikkat gerektirenler": yalnız gerçek veriyle hesaplanabilen iki kural (Ek D-27).
   - Yaklaşan görüşmeler.
   - "Öğrenci Ekle".
2. **Öğrencilerim:**
   - Arama; Türkçe harflerde doğru çalışır (I/ı/İ/i).
   - Satır: avatar, ad, sınıf · alan, toplam deneme, varsa son net.
   - Dokununca öğrenci profili açılır.
3. **Öğrenci profili (koç bağlamı):**
   - Üstte bağlam şeridi: "Alparslan Kuloğlu'nun verileri".
   - Sekmeler: Analiz · Denemeler · Program.
   - Tur 3, 4 ve 6 ekranlarının koç bağlamındaki halini, onları yeniden çizmeden nasıl taşıdığını göster.
4. **Öğrenci Ekle sheet'i:**
   - Alanlar: ad, soyad; kullanıcı adı ("Kontrol Et"); şifre ("Oluştur" + göster); sınıf; alan.
   - "Öğrenciyi Kaydet".
   - Alternatif: koçluk kodunu paylaş (kod kartı + Kopyala / Paylaş).
5. **Görüşmelerim:**
   - Liste: öğrenci, tarih (yıllı), saat, tür (Öğrenci / Veli). Arama ve filtre.
   - "Yeni Görüşme" sheet'i: öğrenci, tür, tarih, saat.
   - Görüşme Detayı: notlar; not ekleme, düzenleme ve onaylı silme.
6. **Durumlar:**
   - Hiç öğrencisi olmayan koç: "İlk öğrencini ekle" ya da "Kodunu paylaş".
   - Görüşme yok.

**Kanvas:** `10 · Koç`.

---

## Tur 10: Tutarlılık, akış haritası ve devir

1. Bütün turları Bölüm 5 ve 6'ya karşı denetle ve düzelt.
2. Koyu tema listesini tamamla (Ek D-14).
3. **`0 · Akış Haritası`** sayfasına üç akış şeması çiz:
   - **a. Uygulamanın yolculuğu:** açılış → onboarding → giriş → Anasayfa → kamera → sonuç → Deneme Detay → konu → bilgi kartı.
   - **b. Bir denemenin yolculuğu:** okutma → form kontrol → sonuç → konu analizi → eksik → bilgi kartı → "Öğrendim".
   - **c. Koçun yolculuğu:** öğrenci ekleme → öğrencinin analizi → program → görüşme.
4. Her sayfada panoların akış sırasıyla dizildiğini, adlarının kodla başladığını ve aralarında geçiş notları olduğunu kontrol et.
5. **`11 · Notlar`**a geliştirici devrini yaz:
   - son token tablosu,
   - adlarıyla bileşen listesi,
   - hangi ekranda hangi bileşenlerin kullanıldığı,
   - hareket ve haptik tablosu,
   - bütün varsayımlar.

---

## Tur 11: Mağaza görselleri

**Kaynak:** `SMAP_Magaza_Gorselleri_Prompt.md` (ilk mesajın ekinde) ve aynı ekteki bezel ve logo dosyaları.

**Kurallar**
1. Mağaza görselleri bir pazarlama yüzeyidir. Bölüm 6'daki yasaklar uygulama arayüzü içindir; mağaza görsellerinde mağaza promptunun kendi görsel dili geçerlidir (parıltılar, panorama rotası, birkaç kil obje).
2. Görsellerdeki telefon ekranları yalnız bu projede tasarladığın ekranların **koyu tema** halleridir. Eski uygulama ekranlarını kullanma.
3. Veriler Ek C ile birebir aynı olur. Uygulamada olmayan ya da verisi olmayan hiçbir özellik gösterilmez: Harita, hedef net, koçun ödev ataması, mesajlaşma, geçen aya göre değişim, elmas ve coin.
4. Önce eksik koyu ekranları çiz (Ek D-14), sonra mağaza promptundaki çalışma sırasını izle:
   1. 7 panel tek bir panorama halinde;
   2. panellere kesme ve diğer formatlar;
   3. önizleme şeridi.
5. Bezel dosyaları ekli değilse cihaz çerçevesini sade ve jenerik çiz ve bunu "Varsayımlar"a yaz.
6. Bu turun ara onay adımları (panorama → kesim) için de kullanıcıyı bekleme. Panoramayı bitir, kendi kontrolünü yap, kesime geç.

**Kanvas:** `12 · Mağaza Görselleri`.

---

## Ek A: Kodda ölçülen mevcut görsel değerler

Ayrıntı `SMAP_Gorsel_Dil.md`de. Hedef, aşağıdaki dağınık değerleri tek bir skalaya indirmek.

**A-1. Lacivert.** Resmi değer `#0F294A`, kodda 66 kez kullanılıyor. Ayrıca şu tonlar var:
- `#162A40` (kamera, görüşme), `#0D2744` (giriş, koç), `#1A365D`, `#1E344A` (grafik çizgisi),
- `#10284A`, `#1F2937`, `#3D526D`.
- Logodaki lacivert `#2D3A54`.

Hedef: tek bir lacivert skalası, `navy-900 = #0F294A`.

**A-2. Turuncu.** Resmi değer `#FF6600`, kodda 96 kez kullanılıyor. Ayrıca şu tonlar var:
- `#FF8A00`, `#FF7A00`, `#FF6D00`, `#FF6F00`, `#F97316`, `#F68A3F`;
- SVG'lerde `#FF6400`; logoda `#F16D38`.

Hedef: tek bir turuncu skalası, `orange-500 = #FF6600`. Metin olarak kullanılacak daha koyu bir ton da gerekir (beyaz zeminde 4,5:1).

**A-3. Nötrler ve yüzeyler.**

| Rol | Değer | Not |
|---|---|---|
| Başlık metni | `#1C1F33` | |
| İkincil metin | `#8A90A6` | Beyaz zeminde 4,5:1'i tutmuyor, koyulaştır |
| Pasif sekme | `#B2BAC6` | |
| Kanvas | `#F5F7F9` | |
| Kart | `#FFFFFF` | |
| Kenar | `#E2E8F0` | |

Kodda bunlara ek olarak Tailwind slate ve gray aileleriyle Material `Colors.grey` karışık kullanılıyor.

**A-4. Ders renkleri** (açık zemin / vurgu):

| Ders | Açık zemin | Vurgu |
|---|---|---|
| Türkçe | `#F7EDE4` | `#A67762` |
| Tarih | `#FFEED6` | `#EAA353` |
| Coğrafya | `#D7EEFE` | `#3B97D3` |
| Matematik | `#FDE7E8` | `#FA4B56` |
| Geometri | `#CDE0FE` | `#3B69B0` |
| Fizik | `#DBF4FF` | `#0276A4` |
| Kimya | `#FFE5EB` | `#DB5669` |
| Biyoloji | `#D5F1CB` | `#12A335` |
| Edebiyat | `#F7F5E8` | `#D56C70` |

Matematik, Kimya ve Edebiyat birbirine çok yakın üç kırmızı-pembe. Tarih'in kehribarı marka turuncusuna yakın. İkisini de ayırt edilebilir hale getir.

**A-5. D/Y/B** bugün dört ayrı sözlükle çiziliyor:
- `#4CAF50 / #F44336 / siyah`
- `#10B981 / #EF4444 / #94A3B8`
- bir ekranda "Doğru" lacivert `#3D526D`
- iOS tonları `#34C759 / #FF383C`

Hedef: tek bir üçlü; renk + ikon şekli + etiket.

**A-6. Köşe yarıçapı:** 22 farklı değer. En sık olanlar 12, 16, 8, 10, 20, 6 ve 24. Üst bant alt köşeleri 32, kamera düğmesi 20. Hedef: en çok 5 değer + tam yuvarlak.

**A-7. Tipografi:** yazı tipi tanımsız (sistem fontu). 18 farklı punto (9–32), 528 satır içi metin stili. Hedef: Plus Jakarta Sans ve tek bir ölçek.

**A-8. Gölge:** 57 gölge, 6 farklı siyah alfa değeri. Hedef: en çok 2 gölge. Bir yüzeyde ya kenarlık ya gölge kullanılır, ikisi birden değil.

**A-9. Alt çubuk ve kamera düğmesi:**
- Alt çubuk 72 pt + güvenli alan, üst köşeleri 20.
- Seçili sekme göstergesi `#FF7A00`, seçili ikon `#FF6600`: aynı yerde iki farklı turuncu.
- Kamera düğmesi 74 × 74, köşesi 20, `#FF6600` zemin üstünde beyaz ikon, 12 pt yukarı taşıyor.

**A-10. Grafik:** fl_chart çizgisi `#1E344A`, 2 px, eğri. Noktası yok, alan dolgusu yok, yatay kılavuz çizgisi yok.

**A-11. Hareket:** yalnız örtük animasyonlar (çoğu 180–300 ms). Sayfa geçişleri varsayılan. İskelet animasyonu yok, haptik yok.

## Ek B: Ekran görüntüleri dizini

| No | Ekran | No | Ekran |
|---|---|---|---|
| 01–05 | Onboarding 1–5 | 24–25 | Deneme Detay › Genel (üst, alt) |
| 06 | Giriş | 26–27 | Deneme Detay › Sorular (üst, alt) |
| 07 | Kayıt › Öğrenci | 28 | Deneme Detay › Konu Analizi |
| 08 | Kayıt › Öğrenci Koçu | 29 | Derslerim › TYT |
| 09 | Anasayfa (üst) | 30 | Derslerim › AYT |
| 10 | Anasayfa (kaydırılmış) | 31 | Hesap |
| 11 | Türkçe konuları › Tümü | 32 | Profilim ve Şifre (üst; e-posta ve telefon örnekle değiştirildi) |
| 12 | Türkçe konuları › TYT | 33 | Profilim ve Şifre (alt) |
| 13 | Türkçe konuları › AYT | 34 | Ödeme ve Paketler (sahte, kalkacak) |
| 14 | Tarih: TYT / AYT / SOS-2 dialogu | 35 | Kayıtlı Kartlarım (sahte, kalkacak) |
| 15 | SOS-2 Tarih › Sos-2 | 36 | Sözleşmeler |
| 16 | SOS-2 Tarih › Tümü | 37 | Bildirimler (sahte etiketler) |
| 17 | Fizik: TYT / AYT dialogu | 38 | Kamera öğreticisi |
| 18 | TYT Fizik konuları | 39 | Ders detayı › Türkçe (11 ile aynı) |
| 19 | Analizlerim › Genel | 40 | Konu detayı › Sözcükte Anlam |
| 20 | Analizlerim › Genel, filtre açık | 41 | Konu detayı, iki madde açık |
| 21 | Analizlerim › Denemelerim | 42 | Konu detayı (kaydırılmış) |
| 22 | Denemelerim + "Analiz" yakında dialogu | | |
| 23 | Denemelerim + "Kavram Haritan" dialogu | | |

Görüntüsü olmayan akışlar envanterden çizilecek: kamera çekim, kırpma ve form kontrol; sonuç akışı; deneme bulunamadı; bilgi kartı destesi; Programım; koç ekranları; şifremi unuttum.

## Ek C: Örnek veri (bütün ekranlarda tutarlı kullan)

**Kişiler**
- **Öğrenci:** Alparslan Kuloğlu · 12. Sınıf · Eşit Ağırlık · kullanıcı adı `alparslan.k` · alparslan@ornek.com · +90 5XX XXX XX XX.
- **Koç:** Mehmet Özkan · koçluk kodu `MOZK-4821`.
- **Koçun diğer öğrencileri:** Elif Şahin (11. Sınıf, Sayısal), Kerem Aydın (Mezun, Sözel), Zeynep Kaya (12. Sınıf, Eşit Ağırlık), Mert Yıldız (10. Sınıf, alan yok).

**Tarihler**
- Bugün: 10 Ekim 2026, Cumartesi.
- YKS: 19 Haziran 2027 (örnek tarih) → **252 gün** kaldı.

**Son deneme (AYT)**
- "Türkiye Geneli Deneme 6" · Örnek Yayınları · 5 Ekim 2026.
- 86 D · 74 Y · 0 B → **67,5 net**. Önceki AYT 59,25 → **+8,25**.
- Testler:

| Test | D | Y | B |
|---|---|---|---|
| Türk Dili ve Edebiyatı–Sosyal Bilimler 1 | 23 | 17 | 0 |
| Sosyal Bilimler 2 | 17 | 23 | 0 |
| Matematik | 25 | 15 | 0 |
| Fen Bilimleri | 21 | 19 | 0 |

- Eşit Ağırlık yerleştirme puanı 412,63 · sıralama 48.215.
- Bu denemeden 23 bilgi kartı eklendi.

**TYT denemesi**
- "TYT Genel Deneme 9" · 28 Eylül 2026 · 80 D · 21 Y · 19 B → **74,75 net**.

| Test | D | Y | B |
|---|---|---|---|
| Türkçe | 32 | 6 | 2 |
| Sosyal Bilimler | 14 | 4 | 2 |
| Temel Matematik | 22 | 5 | 13 |
| Fen Bilimleri | 12 | 6 | 2 |

**Net geçmişi**
- TYT: 22 Nis. 61,5 · 14 May. 64,25 · 17 Haz. 68 · 4 Ağu. 66,75 · 15 Eyl. 71,5 · 28 Eyl. 74,75.
- AYT: 8 May. 48,5 · 2 Ağu. 55 · 21 Eyl. 59,25 · 5 Eki. 67,5.
- Toplam 10 deneme. TYT ortalama net 67,79 · ortalama puan 381,40 · ortalama sıralama 182.430.

**Eksikler (ders başına)**
- Türkçe 31 (TYT 28 · AYT 3) · Tarih 60 · Coğrafya 44 · Edebiyat 3 · Fizik 14 (TYT 7 · AYT 7) · Kimya 9 · Biyoloji 11 · Matematik ve Geometri: web'de.
- En çok kaçırılan konu: "Kurtuluş Savaşı Hazırlık Dönemi'nde 13 sorudan 9'unu kaçırdın."

**Konu analizi (AYT Türk Dili ve Edebiyatı)**

| Konu | D | Y | B |
|---|---|---|---|
| Cumhuriyet Edebiyatı | 5 | 7 | 0 |
| Söz Sanatları | 0 | 1 | 0 |
| Batı Edebiyatı ve Akımları | 1 | 0 | 0 |
| Nazım Bilgisi | 0 | 1 | 0 |
| İslamiyet Etkisindeki Türk Edebiyatı (Divan-Halk Edebiyatı) | 0 | 2 | 0 |

**Türkçe konuları**
1 Sözcükte Anlam · 2 Cümlede Anlam · 3 Ses Bilgisi · 4 Yazım Kuralları · 5 Anlatım Yöntemleri · 6 Paragraf · 7 Söz Öbekleri · 8 Cümlenin Öğeleri (2 eksik) · 9 Fiilde Çatı (3 eksik) · 10 Cümle Türleri · 11 Anlatım Bozuklukları · 12 Noktalama İşaretleri (3 eksik).

**Sözcükte Anlam › alt başlıklar**
- Anlamı Yönünden Sözcükler (4 madde: Temel Anlam, Yan Anlam, Mecaz Anlam, Terim Anlam)
- Sözcükler Arası Anlam İlişkileri (9 madde)
- Mecaz Oluşturma Yolları (9 madde)
- Yansıma Sözcükler (1 madde)
- Kalıplaşmış Söz Öbekleri (2 madde)

**Madde metinleri**
- **Temel Anlam:** "Bir sözcüğün akla gelen ilk anlamıdır. Sözlük anlamı da denir."
  - Örnek: "Bazı insanlar karanlıktan korkar." Cümledeki "karanlık", ışıksız anlamında kullanılmıştır.
- **Yan Anlam:** "Bir sözcüğün temel anlamıyla bağlantılı olarak kazandığı yeni anlamdır."
  - Örnek: "Yorganın yüzü kirlenmiş."

**Bilgi kartları**
- "Edirne-Segedin Antlaşması (1444): Haçlılarla Osmanlı Devleti'nin imzaladığı ilk antlaşma. Tuna sınır olur, on yıl savaş yapılmaz."
- "Otlukbeli Savaşı (1473): Fatih Sultan Mehmet – Uzun Hasan (Akkoyunlu)."
- Tarih kartları: Eksiklerim 23 · Bildiklerim 41 · Favorilerim 6.
- Boş durum metinleri:
  - Eksiklerim: "Bu derste eksik kartın kalmadı."
  - Bildiklerim: "Henüz öğrendiğin kart yok."
  - Favorilerim: "Favoriye eklediğin kart yok."

**Program:** "Ekim 2. Hafta" · "Her gün biraz daha". Bugün:
- 10:00 Türkçe · Fiilde Çatı
- 14:00 Tarih · Kurtuluş Savaşı Hazırlık Dönemi
- 20:00 Coğrafya · İklim Bilgisi

**Görüşmeler**
- 12 Ekim 2026, 16:00 · Öğrenci görüşmesi · Alparslan Kuloğlu.
  - Not: "Tarih eksikleri için haftada 3 saat ayrıldı."
- 15 Ekim 2026, 19:30 · Veli görüşmesi · Elif Şahin.

## Ek D: Varsayılan kararlar (soru sormadan bunları uygula)

| # | Konu | Karar |
|---|---|---|
| 1 | Net | Doğru − yanlış ÷ 4. Sunucu hesaplar. Çeyrek adımlarla ve virgülle gösterilir (67,5 · 74,75). |
| 2 | Gösterilecek gerçek veriler | **Deneme:** net, D/Y/B, puan (yerleştirme ve ham), sıralama, test bazında D/Y/B, soru durumları ve işaretlenen şık, konu bazında D/Y/B ve başarı yüzdesi. **Eksikler:** ders başına, TYT/AYT/SOS-2 başına ve konu başına eksik sayısı. **İçerik:** alt başlık başına madde sayısı; madde ve kart durumu (eksik / biliyor); kart sayıları (eksik, bilinen, favori). **Analiz:** deneme listesi ve tarihleri; çözülen deneme sayısı; ortalama net, puan ve sıralama. **Diğer:** program görevleri, görüşmeler ve notlar, koçun öğrenci listesi (sınıf, alan, toplam deneme). |
| 3 | Gösterilmeyecek veriler (sahte ya da verisi yok) | Geçen aya göre değişim; konu tamamlama yüzdesi ve "N/20 konu"; ders başına alt başlık, madde ve kart toplamları; alt başlıktaki "%60"; elmas, coin, puan, seri ve rozet; hedef net; "Başarısız (Derece)"; sabit OBP; görevlerin tamamlanma durumu. |
| 4 | v1'de görünmeyen özellikler | SmapLab, Gelen Kutusu, SmapCoach, Müfredat, Kaynak Takibi, Analiz sekmesi, Harita, Ödeme ve Paketler, Kayıtlı Kartlarım, faturalar, paywall, Soru Bankam, soru fotoğrafı çekme, oyunlar. "Yakında" sheet'i kitte durur ama hiçbir ekranda kullanılmaz. |
| 5 | Matematik ve Geometri | Ders satırında "Web'de" etiketi; dokununca sheet ve "Web'de Aç". |
| 6 | Birincil düğme | Lacivert dolgu (`navy-900`), beyaz metin. Turuncu üstüne beyaz metin kontrastı tutmuyor. |
| 7 | Turuncu | Kamera düğmesi, seçili durum, ilerleme ve "bugün" vurgusu. Metin olarak yalnız koyu turuncu tonla ya da 18 pt üstü kalın metinde. |
| 8 | Kamera düğmesi | Turuncu dolgu, lacivert ikon, altında "Okut" etiketi. Yuvarlatılmış kare biçimi kalabilir. |
| 9 | Üst bant | Kök sekmelerde lacivert bant, ekran başlığını taşır. Kullanıcı adı ve avatar yalnız Anasayfa'da (selamın içinde) ve Hesap'ta görünür. Detay ekranları için kompakt lacivert ya da açık zeminli üst bardan birini Tur 1'de seç ve her yerde onu kullan. |
| 10 | Yazı tipi | Plus Jakarta Sans. |
| 11 | İkon ailesi | Phosphor; normalde Regular, seçiliyken Fill. |
| 12 | Ders ikonları | Ders rengindeki zemin üstünde tek renk glif. Çok renkli illüstrasyon kullanılmaz. |
| 13 | Avatarlar | Mevcut 3D set korunur; öğrenci ve koç aynı seti kullanır. |
| 14 | Koyu tema çizilecek ekranlar | Anasayfa; Kamera (çekim, gönderim); Sonuç anı; Deneme Detay (Genel, Sorular, Konular); Analizlerim › Genel; Konu detayı; Kart destesi; Programım (haftalık görünüm). Mağaza görselleri bu koyu ekranlardan yapılır. |
| 15 | Flaş ve galeri | İkisi de yok. |
| 16 | Gönderim adımları | Yalnız gerçek adımlar: hazırlanıyor, gönderiliyor %, okunuyor. |
| 17 | Sosyal giriş | Ana tasarımda yok; ayrı bir varyant karesi olarak çizilir. |
| 18 | Şifremi unuttum | E-posta + 6 haneli kod. Sunucu ucu yoksa bu akış gizlenir; yine de çizilir. |
| 19 | Alanlar | Sayısal, Eşit Ağırlık, Sözel, Dil. 9–10. sınıfta alan yok. |
| 20 | Sınıflar | 9, 10, 11, 12, Mezun. |
| 21 | YKS tarihi | Örnek olarak 19 Haziran 2027; geri sayım cihazda hesaplanır. |
| 22 | Dokunma hedefi | 48 dp. |
| 23 | Bildirim izni | İlk başarılı okumadan sonra sorulur. |
| 24 | Sessiz saatler | Varsayılan 22:00–08:00. |
| 25 | Deneme favorisi | Yalnız cihazda saklanır; düşük vurguyla gösterilir. |
| 26 | Programda tamamlama | Yok. |
| 27 | Koç: "Dikkat gerektirenler" | Yalnız iki kural: "14 gündür deneme okutmadı" ve "son iki denemede net düştü". |
| 28 | Hesap silme | İki adım: açıklama ekranı → tehlikeli onay sheet'i. Kullanıcıya bir kelime yazdırılmaz. |
| 29 | Sekmeler | **Öğrenci:** Anasayfa · Analizlerim · Kamera · Derslerim · Hesap. **Koç:** Anasayfa · Öğrencilerim · Kamera · Görüşmelerim · Hesap. |
| 30 | Dil | Yalnız Türkçe. |
| 31 | Toast | Alt çubuğun hemen üstünde. 4 sn kalır; "Geri Al" eylemi varsa 6 sn. |
| 32 | Deneme adı | "(Test)" gibi ekler gösterilmez. Yayınevi ve deneme adı ayrı satırlarda. |
| 33 | "Deneme: N" etiketi | Gösterilmez (anlamsız). Denemeler tarihle ayırt edilir. |

## YAPIŞTIR SONU
