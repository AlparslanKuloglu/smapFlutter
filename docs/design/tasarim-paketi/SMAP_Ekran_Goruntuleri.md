# SMAP ekran görüntüleri: ekran ekran döküm

Bu belge `ekranlar/` klasöründeki 42 görüntünün her birini anlatır: ekranda ne var (gerçek metin ve sayılarla), hangi bileşenler kullanılmış ve gözle görülen sorunlar. Numaralar dosya adlarıyla aynıdır (`01-onboarding-1.png` … `42-konu-detay-alt.png`). 32 numaralı görüntüdeki e-posta ve telefon örnek değerle değiştirildi.

---

### 01 · Onboarding 1/5 (Optik okuma ve Deneme Sonuçlarım)
**İçerik:**
- Üstte iki iPhone çerçeveli mockup yan yana.
- Sol mockup: ahşap masada lamba, laptop, kitaplar, gözlük ve optik form fotoğrafı. Üzerinde köşe tarama çerçevesi ve beyaz yatay tarama çizgisi var. Altta üç kontrol: "Flaş kapalı", turuncu kamera butonu, "Galeri".
- Sağ mockup: SMAP anasayfası. Lacivert üst bar, hamburger, SMAP logosu, kız avatarı.
  - Çip sekmeler: "Genel", "Deneme Sonuçlarım" (aktif, turuncu), "Analiz", "Ha…" (kesik).
  - 2x2 deneme kartı. Hepsinde "90 net" ve "Deneme:1" çipi, sarı yıldız, kitap kapağı (Krallar AYT, Deneme 4 AYT, AYT Simülasyon Denemeleri, Deneme 5 AYT) var.
  - Kart başlığı: "Karekök Yayınları TYT 5 li Çözümlü Deneme Seti". Altta lacivert "Detay" butonu.
  - Alt bar: Anasayfa, Analizlerim, turuncu kamera FAB, Derslerim, Profil.
- Başlık: "Sana Dair En Detaylı Analiz: Tüm Denemeler! Yayınevi farketmeksizin!"
- Alt metin: "Optik formunu okuttuğunda denemen otomatik saptanır ve 5 saniyede analizin hazırlanır!"
- 5 çizgili sayfa göstergesi, ilki geniş.
- Buton "Devam Et". Link "Tanıtımı atla".

**Bileşenler:**
- Beyaz zemin. Başlık koyu lacivert (~#1B3A66) kalın, ~28pt, ortalı, 3 satır. Alt metin açık gri (~#8A8F9A), harf aralığı geniş.
- "Devam Et" tam genişlik, soluk lavanta-gri dolgu (~#E8ECF4), lacivert yazı, köşe ~13pt, yüksekliği ~55pt.
- "Tanıtımı atla" altı çizili gri metin.
- Mockup içi yazılar geometrik sans (Poppins benzeri). Uygulama gerçekte Inter benzeri.

**Sorunlar:**
- Birincil CTA "Devam Et" soluk gri-lavanta. Pasif/disabled görünüyor, vurgu yok.
- Mockup içi metin ~5-6px. Hiçbiri okunmaz.
- Mockup eski arayüz: alt barda "Profil" yazıyor (gerçek uygulamada "Hesap"). Sekme satırında "Ha…" kesik.
- "farketmeksizin" yazım hatası (doğrusu "fark etmeksizin"). Başlıktaki her kelime büyük harfle başlıyor, Türkçe başlık için alışılmadık.
- Telefon içinde telefon kompozisyonu. Sol mockup fotoğraf, sağ mockup UI, iki farklı görsel dil.
- Başlık y-konumu slaytlar arasında sıçrıyor (bkz. 03 ve 05).

### 02 · Onboarding 2/5 (Bilgi kartı / eksik giderme)
**İçerik:**
- Tek mockup, karartılmış (koyu overlay). Lacivert üst bar: SMAP logosu, sağda hamburger.
- Kırmızı rozetli satır "Tüm Eksiklerimi Getir" (rozet 24).
- Satır "5. İslam Medeniyetinin Doğuşu" (rozet 3).
- Yırtık kâğıt dokulu beyaz kart:
  - Tarih illüstrasyonu (sütun, küre, vazo, miğfer, "HISTORY" kitabı).
  - Kalın italik başlık: "Edirne- Segedin Antlaşması (1444)".
  - İtalik gövde: "Anadolu'daki iç karışıklıklardan Sırp ve Macarların yararlanmak istemeleri ve Hünyadi Yanoş'un Osmanlı ordusunu yenmesi üzerine mücadele başladı. Osmanlıların başarılı ile sonuçlanan sefer sonunda Edirne-Segedin anlaşması yapıldı. Bu antlaşmaya göre Tuna Nehri'nin sınır olacağı ve on yıl savaş yapılmayacağı şeklinde uzlaşmaya varılmıştır. Haçlılarla Osmanlı Devleti'nin imzaladığı ilk anlaşmadır."
- Altta "İç ve Dış Olaylar" satırı ve "+" ile kart ikonlu iki kare buton.
- Başlık: "Smap Neyi Bilmediğini Belirler ve Eksiklerini Gidermeni Sağlar"
- Alt metin: "Yapay zeka destekli analizlerimizle hangi konuya ne kadar çalışman gerektiğini sana söyleyelim."
- Göstergede 2. çizgi aktif. "Devam Et", "Tanıtımı atla".

**Bileşenler:**
- Mockup ~375px/920 genişlikte, üst kenarı y≈215 (01'de 240).
- Kâğıt kart düz flat illüstrasyon, kenarları pürüzlü. Kırmızı rozet ~#D0312D.
- Diğer bileşenler 01 ile aynı.

**Sorunlar:**
- Mockup karartılmış. Ortadaki beyaz kâğıt bloğu dışında her şey okunmaz.
- Başlık "Yapay zeka destekli analiz" vaadi veriyor ama görsel statik bir tarih bilgi kartı. Mesaj ile görsel uyuşmuyor.
- Mockup'ta hamburger sağda. 01 ve 03'te solda. Aynı uygulama için tutarsız.
- Mockup boyutu slayttan slayta değişiyor, başlık konumu sıçrıyor.
- Kart gövde metni mockup'ta ~6px, okunmaz.

### 03 · Onboarding 3/5 (Net grafiği ve kümülatif ilerleme)
**İçerik:**
- Mockup: lacivert üst bar, hamburger, SMAP, kız avatarı.
- Çip sekmeler: "Genel" (aktif turuncu), "Deneme Sonuçlarım", "Analiz", "Ha…".
- Kart: "Deneme Net Grafiği" / "TYT Denemeleri".
  - Çizgi grafik, biri lacivert biri turuncu iki dalgalı çizgi.
  - Y ekseni: 120 Net, 100 Net, 80 Net, 60 Net, 40 Net.
  - X ekseni: 12 Oct, 16 Oct, 18 Oct, 20 Oct, 22 Oct, 24 Oct.
- 2x2 istatistik kartı, hepsinde "+18.2% geçen ay":
  - "78 Ortalama Net"
  - "105 Ortalama Puan"
  - "158 Ort. Sıralama"
  - "121 Toplam Doğru"
- Başlık: "Denemelerini Okut ve Sana Ait Kümülatif Birikimle İlerlemeni Adım Adım Takip Et!" (4 satır)
- Alt metin: "Sınav maratonunda kendine hedefler koy ve bu hedeflere ne kadar yaklaştığını anlık olarak izle."
- Göstergede 3. çizgi aktif.

**Bileşenler:**
- İstatistik kartı beyaz, ikon turuncu açık-şeftali kare içinde, alt kenarda turuncu kalın çizgi.
- Grafik çizgileri lacivert (~#1B2E4B) ve turuncu (#FF6A00), eğri (spline).

**Sorunlar:**
- Başlık 4 satır. Son satırda yetim "Et!" kalmış.
- X ekseninde İngilizce "Oct". Uygulamada Türkçe ay kısaltması ("Nis.", "May.") kullanılıyor.
- Mockup verisi (78 net, 40-120 ekseni) gerçek uygulama (118.30, 0-120 ekseni, bkz. 19) ile uyuşmuyor.
- Başlık cümlesi uzun ve ağır: "Kümülatif Birikimle", "Adım Adım Takip Et".
- Mockup alt barı kesik.

### 04 · Onboarding 4/5 (Güçlü ve zayıf konular)
**İçerik:**
- Mockup: aynı üst bar, hamburger, SMAP, **erkek** avatar.
- Çip sekmeler: "Genel", "Deneme Sonuçlarım", "Analiz" (aktif), "Ha…".
- Kart:
  - Segment TYT (aktif turuncu) / AYT.
  - "Ders Listesi" başlığı, altında yer tutucu "Lorem ipsum dolor sit."
  - 3x3 kesikli kenarlı ders karosu: Genel, Kimya, Biyoloji (kesikli turuncu seçili), Matematik, Tarih, Türkçe, Fizik, Coğrafya, Geometri.
- Kart "Zayıf Konuların":
  - Dairesel ilerleme "46%": "Madde Geçişleri", alt satır "Tarih", sağda gri rozet 12.
  - "28%": "Hücre ve Organelleri", "Tarih", 10.
  - "10%": "Kalıtım", "Tarih", 4 (kesik).
  - Sağda dikey kaydırma çubuğu.
- Başlık: "Güçlü ve Zayıf Yanların: Konularla Karşılaşma Sayıların ve Başarı Yüzdelerin"
- Alt metin: "Anlamadığın soruların çözümlerine tek tıkla ulaş, eksik konu bırakmadan ilerle."
- Göstergede 4. çizgi aktif.

**Bileşenler:**
- Dairesel progress: ince lacivert halka + turuncu yay. Rozetler gri-lavanta kare.
- Ders karoları 1px kesikli çerçeve, ikonlar çizgi stili.

**Sorunlar:**
- Mockup'ta "Lorem ipsum dolor sit." yer tutucusu duruyor.
- Veri uyuşmuyor: "Madde Geçişleri" (Kimya konusu), "Hücre ve Organelleri" ve "Kalıtım" (Biyoloji) hepsinin ders etiketi "Tarih".
- Ders sırası uygulamadakinden farklı (Genel, Kimya, Biyoloji, Matematik…). Gerçekte Genel, Türkçe, Tarih… (bkz. 20).
- Başlık dilbilgisi bozuk: "Konularla Karşılaşma Sayıların ve Başarı Yüzdelerin".
- Başlıkta "Güçlü" vaadi var, mockup yalnızca "Zayıf Konuların" gösteriyor.
- Mockup ölçeği ~340px, başlık y≈1015 (01-02'de 1100).

### 05 · Onboarding 5/5 (Anasayfa genel görünüm, son slayt)
**İçerik:**
- Mockup (eski anasayfa):
  - Üst bar: SMAP, hamburger, sırt çantası ikonu (turuncu rozet 1).
  - Yatay ders kartları: "Türkçe" (kırmızı rozet 11), "Tarih" (2), "Coğrafya" (2), "Edebiyat" (kesik).
  - Kullanıcı kartı: "Alparslan Kuloğlu", elmas ikonu "5590", turuncu ilerleme çubuğu "70%".
  - Menü 3x2: "Analiz", "Denemelerim", "Programım", "Kartlarım", "Oyunlar", "Gelen Kutusu" (kırmızı rozet 1).
  - Takvim: lejant "Deneme" (turuncu), "Ödev" (lacivert), "Görüşme" (yeşil); başlık "Aralık", "Pazartesi, 29 Aralık 2025"; "Pt Sal Çar Per Cu Cmt Paz", 1-7.
- Başlık: "YKS'ye Son Teknoloji ile Hazırlan"
- Alt metin: "Şimdi SMAP dünyasına katıl ve hayalindeki üniversite için en büyük adımı at!"
- Buton "Hemen Başla". Link "Tanıtımı atla". Göstergede 5. çizgi aktif.

**Bileşenler:**
- Mockup en büyük (~415px). Ders kartları beyaz, renkli flat illüstrasyon.
- Elmas ikonu sarı-turuncu.
- Son slaytta da CTA soluk lavanta-gri.

**Sorunlar:**
- Mockup gerçek uygulamayla örtüşmüyor. Kartlarım, Oyunlar, elmas 5590 ve "Profil" artık yok. Gerçekte Derslerim, SmapLab ve "Hesap" var (bkz. 09). Takvim "Aralık 2025" (bugün Ekim 2026).
- Son slaytta "Tanıtımı atla" gereksiz, çünkü zaten sondayız.
- Son slaytın CTA'sı "Hemen Başla" bile pasif görünüyor.
- Mockup'ta üst bar sağdaki sırt çantası ikonu uygulamada yok.
- Başlık 2 satır, 01-04'ten farklı y-konumu, içerik zıplıyor.

### 06 · Giriş (Kullanıcı Girişi)
**İçerik:**
- Statü çubuğu lacivert zeminde. "16:34" ve ikonlar koyu gri, neredeyse görünmez.
- Beyaz yuvarlak kart içinde:
  - S logosu (lacivert-turuncu squircle).
  - "SMAP'e hoş geldin!"
  - "Öğrenme yolculuğunuza başlamaya hazır mısınız?"
  - İllüstrasyon: iki gezgin (şapkalı sırt çantalı kız, işaret eden erkek) lacivert-turuncu katlanmış haritaya bakıyor, harita üzerinde konum iğnesi, şeftali blob arka plan.
  - "Kullanıcı Girişi"
  - Alan 1: "student". Alan 2: "••••••••".
  - Onay kutusu "Beni Hatırla", sağda link "Şifremi unuttum".
  - Ayraç "veya hesabınızla bağlanın". Yuvarlak butonlar: Apple logosu, kırmızı "G".
  - Lacivert buton "Giriş Yap".
  - "Hesabın yok mu? **Kayıt ol**"

**Bileşenler:**
- Arka plan iki renkli: üst yarı lacivert (~#0F2744), alt açık gri-mavi (~#EEF2F8). Geçişte y≈1000'de sert çizgi var.
- Beyaz kart köşe ~28pt, kenarlardan ~16pt boşluk.
- Giriş alanları dolgulu açık mavi (~#E9F0FA), köşe ~17pt, yükseklik ~49pt, etiketsiz.
- Giriş Yap butonu lacivert (~#0F2744), ~50pt, gölgeli.
- Apple/Google butonları beyaz daire, ~46pt, hafif gölge.
- Tipografi Inter benzeri, kalın lacivert başlıklar.

**Sorunlar:**
- Alanlarda etiket/placeholder ayrımı yok. Boş halde hangisinin kullanıcı adı olduğu anlaşılmaz.
- Hitap tutarsız: "yolculuğunuza", "hazır mısınız", "hesabınızla" (siz) ile "Hesabın yok mu?" (sen). Onboarding "sen" kullanıyor.
- Sosyal giriş butonları ana CTA'dan **önce**, ayraç da birincil butonun üstünde. Hiyerarşi ters.
- Google butonu tek renk kırmızı "G". Resmi çok renkli logo değil, marka kuralına aykırı.
- Statü çubuğu saati ve ikonları lacivert üstünde koyu gri, düşük kontrast.
- Arka plandaki lacivert/gri sert geçiş kartın arkasında kenarlarda görünüyor, kasıtsız bölünme gibi.
- Onay kutusu klasik köşeli koyu çerçeveli, uygulamanın yuvarlak diliyle uyuşmuyor.
- "Şifremi unuttum" ve "Kayıt ol" küçük, dokunma alanı dar.
- İllüstrasyonun bej-kahve insan stili, uygulamanın 3D avatar stilinden farklı.
- Kart dikey olarak dolu, illüstrasyon ~%25 yer kaplıyor.

### 07 · Kayıt Ol › Öğrenci
**İçerik:**
- Aynı lacivert/gri iki katmanlı zemin, beyaz kart.
- Üstte "<" geri oku, ortalı başlık "Kayıt Ol".
- İki buton: "Öğrenci" (lacivert dolu, seçili), "Öğrenci Koçu" (lacivert 2px çerçeve).
- Avatar seçici: ortada mavi zeminli 3D erkek avatar (kızıl saçlı, gri-mavi ceket), iki yanda "<" ">" oku.
- Alanlar: "Ad Soyad", "usernametest", "test@smap.tr", şifre "••••••••" + göz-kapalı ikonu, şifre tekrar "••••••••" + göz-kapalı ikonu, açılır "Sınıfınız" + ▼.
- Metin: "Kayıt olarak **Kullanım Koşulları**'nı kabul etmiş olursunuz. **KVKK Aydınlatma Metni** ve **Gizlilik Politikası**'nı inceleyebilirsiniz."
- Lacivert butonun üst kenarı en altta ince şerit olarak görünüyor, buton kesik.

**Bileşenler:**
- Giriş ekranı ile aynı alan stili (açık mavi dolgu, ~17pt köşe, ~54pt yükseklik).
- Seçili rol butonu lacivert dolu, seçili olmayan çerçeveli. Köşe ~15pt.
- Avatar ~90pt daire, 3D render stili.
- Linkler kalın lacivert altı çizili.

**Sorunlar:**
- "Tamamla" butonu altta kesiliyor, yalnızca üst ~4px görünüyor. CTA ilk bakışta yok.
- "Ad Soyad", "usernametest" ve "test@smap.tr" aynı koyu renkte. Placeholder mı girilmiş değer mi ayırt edilmez. Etiket yok.
- Rol seçimi segmented değil, iki ayrı buton. Ayrı ayrı çerçeve/dolgu kullanıyor.
- Avatar seçicide kaç seçenek olduğu belli değil, ok butonları küçük.
- Kart altında ~80px boş gri şerit, kart zeminle uyumsuz bitiyor.
- Geri oku küçük (~32pt), dokunma hedefi dar.
- Yasal metin kalın altı çizili üç link içeriyor, görsel gürültü.

### 08 · Kayıt Ol › Öğrenci Koçu
**İçerik:**
- 07 ile aynı. Farklar:
  - Rol seçimi tersine döndü: "Öğrenci" çerçeveli, "Öğrenci Koçu" dolu lacivert.
  - "Sınıfınız" açılır alanı yok.
  - Alanlar: "Ad Soyad", "usernametest", "test@smap.tr", iki şifre alanı.
  - Yasal metin yukarı kayıyor.
  - Lacivert buton "Tamamla" tam görünüyor (gölgeli).

**Bileşenler:**
- 07 ile aynı bileşenler. "Tamamla" ~50pt, tam genişlik, lacivert, gölgeli.

**Sorunlar:**
- Rol değişince form yüksekliği değişiyor, alan kaybı ve buton sıçraması var (layout shift).
- Koç için ek alan yok (kurum, branş, öğrenci kodu gibi). Rol seçmenin amacı formda görünmüyor.
- CTA metni "Tamamla", başlık "Kayıt Ol". Eylem adı tutarsız.
- Avatar erkek kalıyor, koç için ayrı avatar seti yok.
- 07'deki diğer sorunlar (etiket yok, hitap, alt boş şerit) aynen geçerli.

### 09 · Anasayfa (üst)
**İçerik:**
- Üst bar lacivert (~#11294A), alt köşeleri yuvarlak. Sol: S logosu beyaz squircle içinde. Sağ: "Alparslan Kuloğlu" (beyaz), altında "Eşit Ağırlık" (turuncu), 3D erkek avatar.
- Ders çipleri (yatay kaydırma, sağda kesik), her çipin sağ alt köşesinde turuncu rakamlı beyaz daire rozet:
  - "Türkçe" 31
  - "Tarih" 60
  - "Coğrafya" 44
  - "Edebiyat" 3… (kesik)
- Lacivert kullanıcı kartı: avatar, "Alparslan Kuloğlu", altın coin'li pil "0", beyaz doldurulmuş ilerleme çubuğu, "0%".
- Menü ızgarası 3x2: "Analiz", "Denemelerim", "Derslerim", "Gelen Kutusu", "SmapLab", "Programım".
- Takvim kartı: "<  Ekim 2026  >", "Pt Sal Çar Per Cu Cmt Paz", 28 29 30 (soluk gri) 1 2 3 4, 5 6 7 8 9 **10** (turuncu çemberli, bugün) 11 (alt satır nav bar altında kesik).
- Alt bar: Anasayfa (aktif, turuncu, şeftali pill içinde ikon, solda turuncu üst çizgi), Analizlerim, ortada büyük turuncu kamera FAB, Derslerim, Hesap.

**Bileşenler:**
- Ders çipleri ~90pt kare, beyaz, 1px açık çerçeve, ~17pt köşe, çipin üst yarısında flat illüstrasyon (açık kitap, sütun+kalem, küre+kitaplar, tüy kalem+kitap), altında koyu etiket.
- Menü kareleri ~114pt, beyaz, 1px açık çerçeve, ~17pt köşe, flat illüstrasyon + kalın lacivert etiket.
- Takvim: dış kart açık gri (~#F5F6F9), iç kart beyaz, ızgara çizgisi ince.
- FAB ~79pt kare, köşe ~22pt, turuncu (~#FF6A00), beyaz kamera ikonu. Nav arka planı beyaz, üst köşeler yuvarlak.
- İnaktif sekme etiketi açık gri-mavi (~#B8C0D0). Aktif turuncu, kalın.
- Tipografi Inter benzeri, harf aralığı geniş.

**Sorunlar:**
- İlerleme çubuğu "0%" iken izi tamamen beyaz ve dolu. İlerlemenin 100% göründüğü okunuyor, 0% yazısıyla çelişiyor.
- Kullanıcı adı ve avatar aynı ekranda iki kez (üst bar + kullanıcı kartı). Tekrarlayan meta satırı.
- Ders çiplerindeki rozetlerin (31, 60, 44, 3…) anlamı açıklanmıyor (konu sayısı mı, eksik mi?). "Edebiyat" rozeti sağ kenarda kesik.
- Menü ikonları üç farklı stilde ve palette: Analiz (renkli çizgi-flat), Derslerim (mavi kimlik kartı metaforu, dersle ilgisi yok), Gelen Kutusu (soluk gri zarf, rozetsiz), SmapLab (kırmızı butona basan el, anlamsız), Programım (kırmızı-gri takvim). Görsel ağırlık eşit değil.
- Menü kareleri büyük (~114pt) ve ikon küçük, içeride boşluk fazla. Okunmamış sayısı gösterilmiyor.
- Takvim bugünden başka işaret göstermiyor. Onboarding'deki Deneme/Ödev/Görüşme lejantı yok, olay noktası yok. Hafta kısaltmaları standart dışı: "Pt" (Pzt olmalı), "Cu" (Cum olmalı).
- Takvim alt barın altında kesiliyor. Alt satır görünmüyor.
- İnaktif nav etiketleri soluk (~2:1 kontrast). "Analizlerim" etiketi FAB'a ~15px mesafede sıkışık.
- Coin "0" ve "0%" için boş durum açıklaması yok.
- Üst bar köşe yuvarlaması ile ders çipleri üst barın alt kenarını kesiyor, beyaz kartlar lacivert/beyaz sınırında duruyor.

### 10 · Anasayfa (aşağı kaydırılmış)
**İçerik:**
- Üst bar ve ders çipleri (Türkçe 31, Tarih 60, Coğrafya 44, Edebiyat 3…) sabit kalıyor, altındaki içerik kayıyor.
- Menü ilk sırası ("Analiz", "Denemelerim", "Derslerim") ders çiplerinin altında kesik: yalnızca etiketler ve ikonların küçük parçaları (kırmızı/mavi/yeşil kıymık) görünüyor.
- İkinci sıra tam: "Gelen Kutusu", "SmapLab", "Programım".
- Takvim tam görünür: "Ekim 2026", 28 29 30 (gri) 1 2 3 4 / 5 6 7 8 9 **10** 11 / 12 13 14 15 16 17 18 / 19 20 21 22 23 24 25 / 26 27 28 29 30 31 1 (gri).
- Alt bar aynı.

**Bileşenler:**
- Takvim iç kartı beyaz, ince çizgili ızgara, bugün turuncu çemberli şeftali dolgulu.
- Sabit blok (üst bar + çipler) ekran yüksekliğinin ~%25'ini (≈220pt) kaplıyor.

**Sorunlar:**
- Üst bar + ders çipleri sabit (sticky) olduğu için ekranın ~%25'i kaybediliyor.
- Menü kareleri çiplerin altında sert bir çizgide kesiliyor, kıymık ikon parçaları yarım görünüyor.
- Takvimde hiçbir gün işaretli değil (olay/ödev yok). Alan geniş, bilgi taşımıyor.
- Haftanın günleri "Pt", "Cu" standart dışı.
- Menü satırı "Analiz/Denemelerim/Derslerim" tek satır kısmen görünürken ikinci sıra tam. Okuma kopuk.

### 11 · Konu listesi: Türkçe › Tümü
**İçerik:**
- Üst bar lacivert, alt köşeleri yuvarlak. "<", ortalı beyaz başlık "Türkçe". Sağda pembe-açık dolgulu, kırmızı çerçeveli pil: kırmızı kart ikonu + "31".
- Segmentli kontrol: "Tümü" (aktif, beyaz pill, turuncu yazı) | "TYT" | "AYT". Alt kenarda asılı daire rozetler: 31, 28, 3.
- Konu kartları (hepsinde aynı meta):
  - 1 "Sözcükte Anlam" (kırmızı-turuncu, A-Z kitap)
  - 2 "Cümlede Anlam" (mavi, konuşma balonu)
  - 3 "Ses Bilgisi" (turuncu-sarı, çeviri ikonu)
  - 4 "Yazım Kuralları" (kahverengi, açık kitap tik-çarpı)
  - 5 "Anlatım Yöntemleri" (sarı, 2 satıra bölünmüş başlık)
  - 6 "Paragraf" (turuncu-kırmızı, "A≡")
  - 7. kart alta kesik (mor şerit).
- Her kartta: "%75", "15/20 Konu tamamlandı", sağda "4 Alt Başlık", "26 Madde", "8 Bilgi Kartı", yuvarlak gri düğme içinde turuncu ok.

**Bileşenler:**
- Kartlar beyaz, ~17pt köşe, sol kenarda 8px renkli şerit (kart başına farklı: turuncu, mavi, amber, kahve, sarı, kırmızı-turuncu).
- Küçük resim kare ~64pt, pastel zemin + ikon. Numara rozeti şeftali kare. Başlık kalın lacivert.
- İlerleme çubuğu kartın vurgu renginde gradyan, iz açık gri, dolu ~%75.
- Meta sütunu açık gri (~#8892A6) ~11pt, ikonlu (kitap, liste, turuncu kart).
- Zemin açık gri (~#F1F3F7).

**Sorunlar:**
- Tüm kartlarda aynı değerler: "%75", "15/20 Konu tamamlandı", "4 Alt Başlık", "26 Madde", "8 Bilgi Kartı". Yer tutucu veri gibi.
- Terminoloji karışık: bir *konu* kartının içinde "15/20 **Konu** tamamlandı" yazıyor.
- Yüzde formatı "%75", anasayfa ve onboarding'de "70%", "0%", "46%". Tutarsız.
- Vurgu rengi (şerit + ilerleme gradyanı + küçük resim zemini) her kartta farklı: turuncu, mavi, amber, kahve, sarı, kırmızı, mor, zeytin. Anlamsız renk kodlaması ve palet dışı kahve/zeytin/mor.
- Başlıktaki pil "31" etiketsiz, anlamı yok. Kırmızı renk uyarı çağrışımı yapıyor.
- Segmentli kontrolün alt kenarına asılan 31/28/3 rozetleri listenin üstüyle neredeyse çakışıyor (rozet dibi y≈410, liste y≈435). Konumları sekme içinde sağ alta yapışık, ortalı değil.
- Meta metin açık gri ~11pt, düşük kontrast (~3:1).
- İkon dili tutarsız: bazıları renkli flat, bazıları outline, bazıları jenerik şekil.
- Alt kart home indicator'ın altında kalıyor, alt safe-area boşluğu yok.
- Başlık 2 satıra düşünce numara rozeti ile hizası bozuluyor ("Anlatım Yöntemleri").

### 12 · Konu listesi: Türkçe › TYT (kaydırılmış)
**İçerik:**
- Başlık "Türkçe", sağ pil "28". Sekme "TYT" aktif (turuncu), rozetler 31, 28, 3.
- Listenin üstünde bir önceki kartın alt kenarı (sarı şerit) sekme çubuğunun altında kesik.
- Kartlar:
  - 15 "Söz Öbekleri" (turuncu, ataç ikonu)
  - 16 "Cümlenin Öğeleri" (amber, mavi insan silüeti) kırmızı çip "2 Eksiğin var"
  - 17 "Fiilde Çatı" (kırmızı-pembe, çatı ikonu) "3 Eksiğin var"
  - 18 "Cümle Türleri" (kiremit, soru işareti)
  - 19 "Anlatım Bozuklukları" (mor, 2 satır başlık)
  - 20 "Noktalama İşaretleri" (sarı, kalem ikonu, 2 satır başlık) "3 Eksiğin var"
- Hepsinde "%75", "15/20 Konu tamamlandı", "4 Alt Başlık", "26 Madde", "8 Bilgi Kartı".

**Bileşenler:**
- "N Eksiğin var" çipi açık pembe zemin (~#FDE3E3), kırmızı yazı (~#E5484D), ~11pt, meta sütununun üstünde.
- Diğer bileşenler 11 ile aynı.

**Sorunlar:**
- Çip yalnızca bazı kartlarda var ve meta sütununu aşağı itiyor. Sütun dikey hizası kartlar arasında bozuluyor.
- "2 Eksiğin var" tuhaf ifade ("2 eksik" yeterli). Küçük kırmızı-üstü-pembe, kontrast ~3.9:1.
- Eksiği olan kartlar da diğerleriyle aynı "%75" gösteriyor. Eksik ile ilerleme çelişiyor.
- "Cümlenin Öğeleri" başlığı çipin ve meta sütununun neredeyse dibine kadar uzuyor (x≈572/590).
- Bir önceki kartın kesik kenarı sekme çubuğunun altında net bir sınır olmadan görünüyor.
- Numaralar 15-20: TYT listesinde sayaç kaydırma konumundan mı genel sıradan mı geliyor belirsiz.
- "Fiilde Çatı", "Cümle Türleri", "Cümlenin Öğeleri" ikonları jenerik, konu ile bağı zayıf.

### 13 · Konu listesi: Türkçe › AYT (kaydırılmış)
**İçerik:**
- Başlık "Türkçe", sağ pil "3". Sekme "AYT" aktif, rozetler 31, 28, 3.
- Liste, 12 ile **aynı kartlar**, aynı sırada: 15 Söz Öbekleri, 16 Cümlenin Öğeleri, 17 Fiilde Çatı, 18 Cümle Türleri, 19 Anlatım Bozuklukları, 20 Noktalama İşaretleri. "Eksiğin var" çipleri yok.
- Her kartta "%75", "15/20 Konu tamamlandı", "4 Alt Başlık", "26 Madde", "8 Bilgi Kartı".

**Bileşenler:**
- 11-12 ile aynı. Çip yokken meta sütunu karta dikey ortalı.

**Sorunlar:**
- Veri tutarsız: AYT sekmesi ve pil yalnızca 3 konu diyor, liste TYT ile aynı en az 6 kartı gösteriyor. Filtre uygulanmıyor veya eski kaydırma/liste duruyor.
- "Eksiğin var" çipleri bu sekmede yok, yani aynı konu iki sekmede farklı durumda.
- Sekme değişince kaydırma konumu korunuyor (liste 15'ten başlıyor). Kullanıcı AYT listesinin başını göremiyor.
- 12'deki diğer sorunlar (aynı veri, renk kodu, kontrast) geçerli.

### 14 · Anasayfa üzerinde Tarih kategori dialog'u (3 seçenek)
**İçerik:**
- Arkada anasayfa (10'daki kaydırılmış hal), koyu scrim (~%60 siyah).
- Beyaz dialog, köşe ~17pt, ortalı: "Tarih" (kalın siyah), "Dersin kategorisini seçin" (gri).
- Üç buton: "TYT" (çelik mavi ~#44709B, beyaz yazı, sağ üst köşede beyaz daire içinde kırmızı "60"), "AYT" (koyu lacivert ~#263A52), "SOS-2" (gri-mavi ~#8B96A5).

**Bileşenler:**
- Dialog genişliği ~280pt. Butonlar ~65pt genişlik, ~55pt yükseklik, ~15pt köşe.
- Rozet beyaz daire, kırmızı sayı, ince gri kenar.

**Sorunlar:**
- Üç buton üç ilgisiz renk: çelik mavi, koyu lacivert, gri. Marka paletinde (lacivert/turuncu) çelik mavi ve gri yok.
- Gri "SOS-2" butonu pasif görünüyor, beyaz yazı kontrastı ~3:1.
- "60" rozeti yalnızca TYT'de. AYT ve SOS-2'de sayı yok, sayı sıfır mı bilinmiyor.
- Dialog başlığı siyah (#1A1A1A), uygulamanın başlıkları lacivert. Font da uygulamanın harf aralığından farklı.
- Kapatma (X) veya iptal yok. Kullanıcı dışarı dokunmayı bilmek zorunda.
- Ders → kategori için ek bir modal adım. Ders çipinde doğrudan seçim yok.
- Rozet sayısı çipteki "60" ile aynı bilgiyi tekrarlıyor.

### 15 · Konu listesi: SOS-2 Tarih › Sos-2 sekmesi
**İçerik:**
- Başlık "SOS-2 Tarih", sağ pil "0". Segment: "Tümü" | "Sos-2" (aktif). Rozet yok.
- Kartlar:
  - 22 "İki Savaş Arasındaki Dön…" (kırmızı, grafik+coin)
  - 23 "İkinci Dünya Savaşı Sürecin…" (zeytin, tank)
  - 24 "İkinci Dünya Savaşı Sonrası…" (mavi, pusula/NATO benzeri)
  - 25 "Toplumsal Devrim Çağınd…" (bej, kalkan yumruklar)
  - 26 "21.yy'ın Eşiğinde Türkiye ve Dünya" (mavi, dünya+yörünge)
- Her kartta "%75", "15/20 Konu tamamlandı", "4 Alt Başlık", "26 Madde", "8 Bilgi Kartı".
- Alt ~300px boş gri alan.

**Bileşenler:**
- 11 ile aynı kart. İki sekmeli segment (Tümü | Sos-2), rozetsiz.

**Sorunlar:**
- Başlıklar elips ile kesiliyor: "İki Savaş Arasındaki Dön…", "İkinci Dünya Savaşı Sürecin…", "İkinci Dünya Savaşı Sonrası…", "Toplumsal Devrim Çağınd…". Sağdaki meta sütunu genişliğin ~%40'ını alıyor, en önemli metin kesiliyor.
- Pil "0" ama liste 5 konu gösteriyor. Sayaç tutarsız.
- Numaralar 22-26: ayrı bir SOS-2 listesi için 22'den başlıyor. Genel sıra mı bilinmiyor.
- Segmentte "Sos-2" yazımı, başlıkta "SOS-2". Büyük/küçük harf tutarsız.
- Segmentte rozet yok. Türkçe/Fizik'te var, tutarsız.
- Alt boşluk büyük, boş durum veya yardımcı içerik yok.

### 16 · Konu listesi: SOS-2 Tarih › Tümü sekmesi
**İçerik:**
- 15 ile aynı. "Tümü" aktif (turuncu), "Sos-2" pasif. Pil "0". Liste aynı 5 kart (22-26) ve aynı kesik başlıklar.

**Bileşenler:**
- 15 ile aynı.

**Sorunlar:**
- "Tümü" ve "Sos-2" sekmeleri aynı 5 kartı gösteriyor. İkinci sekme gereksiz.
- 15'teki diğer sorunlar (kesik başlıklar, pil "0", rozetsiz segment) geçerli.

### 17 · Anasayfa üzerinde Fizik kategori dialog'u (2 seçenek)
**İçerik:**
- Arkada anasayfa, ders çip satırı sağa kaydırılmış: "Geometri" (sol kenarda kesik), "Fizik" (rozet 14), "Kimya", "Biyoloji".
- Dialog: "Fizik", "Dersin kategorisini seçin". İki buton: "TYT" (çelik mavi, rozet 14) ve "AYT" (koyu lacivert). Koyu scrim.

**Bileşenler:**
- 14 ile aynı dialog. İki buton olduğu için her biri ~85pt genişlikte.

**Sorunlar:**
- Geometri, Kimya, Biyoloji çiplerinde rozet yok. Fizik'te 14 var. Sayı 0 ise gizleniyor mu belirsiz, kullanıcıya açıklama yok.
- Çip satırında "Matematik" görünmüyor, sıra net değil.
- 14'teki diğer sorunlar (renk, X yok, dialog başlık rengi, ek modal adım) geçerli.

### 18 · Konu listesi: TYT Fizik
**İçerik:**
- Başlık "TYT Fizik", sağ pil "7". Segment: "Tümü" (rozet 7) | "TYT" (aktif, rozet 7) | "AYT" (rozetsiz).
- Kartlar:
  - 3 "Fizik Bilimine Giriş" (kahve, "E=mc²" tahta)
  - 4 "Enerji" (sarı, şimşek)
  - 4 "Madde ve Özellikleri" (pembe, terazi) çip "1 Eksiğin var"
  - 5 "Isı ve Sıcaklık" (kırmızı, termometre) "2 Eksiğin var"
  - 5 "Hareket ve Kuvvet" (indigo, iki üst üste mor daire) "1 Eksiğin var"
  - 6 "Elektrostatik" (mor, artı-eksi atom çizimi)
- Her kartta "%75", "15/20 Konu tamamlandı", "4 Alt Başlık", "26 Madde", "8 Bilgi Kartı".

**Bileşenler:**
- 11-12 ile aynı kartlar. "Hareket ve Kuvvet" ikonu iki mor daire (jenerik).

**Sorunlar:**
- Numaralar 3, 4, 4, 5, 5, 6. Çift numara ve 3'ten başlıyor, sıra numarası olarak çalışmıyor.
- "Hareket ve Kuvvet" ikonu iki örtüşen mor daire, konu ile ilgisiz yer tutucu.
- Pil "7" ama ekranda 6 kart tam görünüyor, 7.'si alta kesik.
- "AYT" sekmesinde rozet yok.
- "Madde ve Özellikleri", "Isı ve Sıcaklık", "Hareket ve Kuvvet" eksik çipi var ama hepsi "%75".
- 11-12'deki diğer sorunlar (aynı meta, rastgele renk, kontrast) geçerli.

### 19 · Analizlerim › Genel (grafik)
**İçerik:**
- Üst bar (lacivert, düz alt kenar): logo, "Alparslan Kuloğlu", "Eşit Ağırlık", avatar. Ekran başlığı yok.
- Çip sekmeler (yatay): "Genel ⌄" (turuncu dolu, beyaz yazı), "Denemelerim", "Analiz", "Harita" (sağ kenarda kesik).
- Kart "Deneme Net Grafiği" / "TYT Genel":
  - Y ekseni: 120 Net, 90 Net, 60 Net, 30 Net, 0 Net.
  - X ekseni: 22 Nis., 8 May., 14 May., 17 Haz., 4 Ağu., 15 Eyl.
  - Lacivert çizgi 120 Net seviyesinde neredeyse düz, hafif çukurlar. Altta turuncu noktalı çizgi (0 Net hizası).
- 2x2 istatistik kartı:
  - "71" / "Çözülen Deneme" / "+18.2% gecen ay"
  - "118.30" / "Ortalama Net" / "+18.2% gecen ay"
  - "72.154" / "Ort. Sıralama" / "+18.2% gecen ay"
  - "549.81" / "Ortalama Puan" / "+18.2% gecen ay"
- Alt bar: Analizlerim aktif.

**Bileşenler:**
- Çip sekmeleri gri (~#E8EAEE) dolgulu, aktif turuncu (#FF6A00), köşe ~11pt, ~32pt yükseklik.
- Grafik kartı beyaz, ~17pt köşe, çok açık dikey kılavuz çizgileri.
- İstatistik kartı: şeftali kare içinde turuncu çizgi ikon, büyük kalın lacivert değer (~28pt), gri etiket, delta kalın lacivert + gri "gecen ay", alt kenarda ~6px turuncu bar.
- Eksen metni açık gri (~#9AA3B2).

**Sorunlar:**
- Grafik düz çizgi: net değerleri 120'de doygun. Grafik ~%37 ekran yüksekliğini alıyor ve bilgi vermiyor.
- X ekseninde 6 etiket, 71 deneme için çok seyrek ve düzensiz aralıklı (22 Nis., 8 May., 14 May., 17 Haz., 4 Ağu., 15 Eyl.). Son etiket sağ kenarda kesik.
- Turuncu noktalı çizgi açıklanmıyor, lejant yok.
- "+18.2% gecen ay" yazım hatası ("geçen" olmalı) ve dört kartta aynı değer (yer tutucu). Delta rengi yön göstermiyor (yeşil/kırmızı yok).
- Sayı biçimi Türkçe değil: "118.30" ve "549.81" ondalık nokta kullanıyor, "72.154" binlik nokta. Karışık. Türkçede "118,30" olmalı.
- "Harita" çipi sağ kenarda kesik, kaydırma ipucu yok.
- Üst bar anasayfa ile aynı, "Analizlerim" başlığı yok. Ekranın kimliği yalnızca alt barda.
- Üst bar düz alt kenarlı, anasayfa yuvarlak köşeli. Tutarsız.
- Eksen metinleri düşük kontrast (~2.5:1).
- Örnek veri gerçekçi değil: Ortalama Net 118.30 (maksimum 120).

### 20 · Analizlerim › Genel, ders açılır paneli açık
**İçerik:**
- Çip "Genel ⌃" (ok yukarı). Beyaz açılır kart (çipin hemen altından, ~17pt+ köşe):
  - Segment "TYT" (aktif, turuncu) | "AYT".
  - Başlık "Ders Listesi".
  - Başlığın altında ~125px boş boşluk.
  - 3x3 ders karosu: "Genel" (turuncu çerçeveli, seçili), "Türkçe", "Tarih", "Coğrafya", "Matematik", "Geometri", "Fizik", "Kimya", "Biyoloji".
- Panelin altında: "72.154 Ort. Sıralama +18.2% gecen ay", "549.81 Ortalama Puan +18.2% gecen ay".

**Bileşenler:**
- Karolar beyaz, 1.5px açık gri-mavi çerçeve, ~17pt köşe, ~80pt yükseklik. İkon soluk gri-mavi çizgi stili, tint kare içinde. Seçili: turuncu çerçeve + turuncu etiket + şeftali ikon zemini.
- Segment açık mavi-gri iz (~#F1F4FA), aktif beyaz pill.

**Sorunlar:**
- "Ders Listesi" başlığı ile ızgara arasında ~125px boş boşluk: eksik alt başlık (onboarding'de "Lorem ipsum dolor sit." idi) yüzünden kalmış.
- Panelde ok/işaretçi ve scrim yok. Altındaki istatistik kartlarının üstüne gölge yayılıyor, grafik tamamen örtülüyor.
- İkonlar soluk gri çizgi (~#A9B3C5), düşük kontrast. Fizik ikonu elma (Newton), anlaşılması zor. Anasayfa ders çipleri renkli illüstrasyon kullanıyor: aynı dersler için iki farklı ikon seti.
- Panelde onay/kapat yok, seçim hemen mi uygulanıyor belirsiz.
- "Ders Listesi" başlığı gereksiz tekrar.
- Ders sırası (Genel, Türkçe, Tarih, Coğrafya, Matematik, Geometri, Fizik, Kimya, Biyoloji) onboarding mockup'ındaki sıradan farklı.

### 21 · Analizlerim › Denemelerim
**İçerik:**
- Çip sekmeler: "Genel ⌄" (gri, pasif), "Denemelerim" (turuncu aktif), "Analiz", "Harita" (kesik).
- 2 sütunlu deneme kartları (açık gri #F4F5F8, kenarlıksız):
  - "67.5 net" | çip "Deneme: 1" | kapak: Türkiye Geneli Deneme 6 AYT (turuncu kapak) | yıldız | "AYT Deneme (Test)" | lacivert "Detay".
  - "120 net" | "Deneme: 1" | kapak: Deneme 9 TYT (mavi kapak) | "Smap TYT Deneme (Test)" (2 satır) | "Detay".
  - Üçüncü ve dördüncü kart: "120 net", "Deneme: 1", "Smap TYT Deneme (Test)", "Detay".
  - Beşinci ve altıncı kart: "120 net", "Deneme: 1", mavi kapak (alta kesik).

**Bileşenler:**
- Kart ~145pt genişlik, ~236pt yükseklik, ~17pt köşe, iç boşluk ~14pt.
- Net değeri kalın lacivert, "Deneme: N" çipi açık gri pill.
- Kapak görseli açık gri kutu içinde kitap şablonu, sağ üstte turuncu-sarı yıldız outline.
- Başlık ince çizgiler arasında. "Detay" lacivert dolu, ~20pt köşe, gölgeli, sağa hizalı.

**Sorunlar:**
- Hepsinde "Deneme: 1". Numara artmıyor, anlamı belirsiz.
- Kapak görselleri şablon, her deneme aynı görünüyor. Tarih, branş, TYT/AYT metin rozeti yok.
- Başlıkta "(Test)" geçiyor, yer tutucu isim. "net" küçük harfli, grafikte "Net" büyük.
- "67.5" ondalık nokta. Türkçede "67,5".
- Başlığın altında ve üstünde çift ince ayraç çizgisi, dekoratif.
- "Detay" sağda, solunda boş alan. Kart başına ~236pt ve ekranda yalnızca 4 kart görünüyor.
- Yıldız ikonu (~13pt) küçük, dokunma hedefi <44pt, anlamı etiketsiz (favori mi?).
- TYT/AYT filtre ve sıralama yok.
- Net değeri (en önemli veri) çip ile aynı ağırlıkta.

---

### Özet tablo
| No | Ekran | Ana sorun |
|---|---|---|
| 01 | Onboarding 1/5 | Soluk "Devam Et" CTA'sı pasif gibi, mockup metni okunmaz, "farketmeksizin" |
| 02 | Onboarding 2/5 | Karartılmış mockup, hamburger sağda, mesaj/görsel uyumsuz |
| 03 | Onboarding 3/5 | Başlıkta yetim "Et!", grafikte İngilizce "Oct" |
| 04 | Onboarding 4/5 | "Lorem ipsum" kalmış, ders etiketleri hatalı ("Tarih") |
| 05 | Onboarding 5/5 | Mockup eski arayüz (Kartlarım, Oyunlar, elmas 5590, Profil), son slaytta "Tanıtımı atla" |
| 06 | Giriş | Etiket yok, hitap karışık, sosyal giriş CTA'dan önce, statü çubuğu görünmez |
| 07 | Kayıt Ol (Öğrenci) | "Tamamla" CTA'sı kesik, placeholder/değer ayırt edilmez |
| 08 | Kayıt Ol (Koç) | Form yüksekliği zıplıyor, koça özel alan yok |
| 09 | Anasayfa (üst) | 0% çubuk dolu görünüyor, iki kez isim, tutarsız menü ikonları |
| 10 | Anasayfa (kaydırılmış) | Sabit blok ~%25, menü sert kesiliyor, takvim boş |
| 11 | Türkçe › Tümü | Tüm kartlar aynı veri, rastgele renk kodu, anlamsız pil "31" |
| 12 | Türkçe › TYT | Eksik çipi hizayı bozuyor, "%75" ile çelişiyor |
| 13 | Türkçe › AYT | AYT listesi TYT ile aynı, rozet 3 ile uyuşmuyor |
| 14 | Tarih kategori dialog'u | Üç ilgisiz renk, gri SOS-2 pasif görünüyor, X yok |
| 15 | SOS-2 Tarih › Sos-2 | Başlıklar elips ile kesik, pil 0 ama 5 kart |
| 16 | SOS-2 Tarih › Tümü | Tümü ile Sos-2 aynı liste |
| 17 | Fizik kategori dialog'u | Rozet yalnızca Fizik'te, 14 ile aynı sorunlar |
| 18 | TYT Fizik | Numaralar 3,4,4,5,5,6, yer tutucu ikon |
| 19 | Analizlerim › Genel | Düz grafik, "gecen ay" hatası, ondalık nokta |
| 20 | Analizlerim › Genel açılır | Başlık altı ~125px boşluk, soluk ikonlar, iki ikon seti |
| 21 | Analizlerim › Denemelerim | Hepsi "Deneme: 1", şablon kapak, "(Test)" isim |

### Birden çok görselde geçen ekranlar
- **Onboarding akışı**: 01, 02, 03, 04, 05 (5 sayfa, aynı iskelet).
- **Kayıt Ol**: 07 (Öğrenci) ve 08 (Öğrenci Koçu), rol durumuna göre.
- **Anasayfa**: 09 (üst), 10 (kaydırılmış). Ayrıca 14 ve 17'de scrim altında kaydırılmış halde.
- **Kategori dialog'u**: 14 (Tarih, 3 buton) ve 17 (Fizik, 2 buton).
- **Türkçe konu listesi**: 11 (Tümü), 12 (TYT, kaydırılmış), 13 (AYT, kaydırılmış).
- **SOS-2 Tarih listesi**: 15 (Sos-2 sekmesi), 16 (Tümü sekmesi).
- **Konu listesi şablonu** (aynı kart tasarımı): 11, 12, 13, 15, 16, 18.
- **Analizlerim**: 19 (grafik), 20 (Genel açılır panel açık), 21 (Denemelerim sekmesi). Hepsinde aynı üst bar ve çip sekme satırı.

### Bu 21 görselde bulunmayan ekranlar
Derslerim, Hesap, Konu detay, Bilgi kartları, Kamera tutorial sheet'i, "Yakında" dialog'u ve Deneme Detay bu görsellerde yok. Alt çubuktaki "Derslerim" ve "Hesap" sekmeleri hiçbirinde açılmamış. Anasayfadaki "Derslerim" menü kutusu ile alt çubuktaki "Derslerim" sekmesi aynı adla duruyor.

---

Ölçüler: 402×874 pt çerçevede yaklaşık değerlerdir. Renk kodları gözle tahmindir.

**Ortak kabuk.** Aşağıdaki bileşenler birçok ekranda tekrar ettiği için bir kez tarif ediliyor.

- **Üst bar (ana sekmeler)**
  - Lacivert (~#112A4A), alt kenarı düz.
  - Solda beyaz squircle içinde "S" logosu: lacivert-turuncu gradient, ~40 pt.
  - Sağda beyaz yarı kalın isim "Alparslan Kuloğlu", altında turuncu (~#FF6A00) "Eşit Ağırlık".
  - En sağda 3D/Pixar tarzı, açık mavi zeminli, beyaz halkalı karakter avatar (~36 pt).
- **Alt sekme çubuğu**
  - Beyaz, üst köşeleri yuvarlak, hafif gölge.
  - Sıra: Anasayfa, Analizlerim, ortada kamera FAB'ı, Derslerim, Hesap.
  - FAB: ~79×74 pt turuncu (#FF6A00) squircle, içinde açık şeftali renkli kamera ikonu.
  - İkonlar solgun gri (~#C9CED8) düz şekiller, etiketler gri (~#9CA3AF).
  - Aktif sekme: turuncu kalın etiket, ikonun arkasında şeftali hap zemin (~#FDD8BE), çubuğun üst kenarında ~8 px turuncu çizgi.
- **Ortak sorun**
  - İkon–etiket kontrastı düşük.
  - FAB ikonu turuncu üstünde ~1.8:1 kontrastta.
  - FAB, "Analizlerim" ve "Derslerim" etiketlerine ~4–10 pt yaklaşıyor.
  - Alt sekme çubuğu Analizlerim, Derslerim ve Hesap ana ekranlarında var. Deneme Detay, ders detay ve konu detayında yok. Hesap alt sayfalarında var.

---

### 22 · Analizlerim › Denemelerim + "Analiz" Yakında dialogu
**İçerik**
- Arka plan karartılmış (dim). Üst bar ortak kabuktaki gibi.
- Chip satırı: "Genel ⌄" (açılır), "Denemelerim" (seçili, turuncu dolgu), "Analiz", "Harita".
- Arkadaki kartlar:
  - 1. satır: "67.5 net" + gri hap "Deneme: 1" ve "120 net" + "Deneme: 1".
  - 3. satır: "120 net" + "Deneme: 1" ve "120 net" + "Deneme: 1".
  - Alt satırdaki kartlarda "TÜRKİYE GENELİ DENEME 9 TYT" mavi kapak küçük resmi ve altın sarısı yıldız (outline).
- Dialog metni:
  - Başlık: "Analiz".
  - Gövde: "Güçlü ve zayıf konularını takip edebileceğin ve karşılaşma ve doğru/yanlış/boş istatistiklerini görebileceğin analiz ekranı."
  - Kalın satır: "Çok yakında hazır."
  - Gri satır: "Bu özellik henüz geliştirilme aşamasındadır. Yayınlandığında ilk sizin haberiniz olsun ister misiniz?"
  - Buton: "Yayınlandığında Haber Ver" (zil ikonlu).
  - Metin butonu: "Kapat".
- Alt çubukta "Analizlerim" aktif.

**Bileşenler**
- Dialog: beyaz, ~20 pt radius, merkez hizalı.
- İkon: indigo (~#3F51B5) çapraz çekiç-anahtar (Material "construction"), ~34 pt.
- Başlık turuncu kalın ~24 pt.
- Gövde koyu gri-lacivert (~#374151), yarı kalın ~17 pt.
- Birincil buton indigo (~#3F51B5), ~10 pt radius, tam genişlik.
- "Kapat" soluk gri (~#9E9E9E).
- Chip'ler dikdörtgen, ~14 px radius, ~31 pt yüksek. Seçili turuncu, diğerleri gri.

**Sorunlar**
- Dialogun birincil butonu ve ikonu indigo. Markada yalnızca turuncu ve lacivert var, indigo palet dışı.
- Metinde "doğru/" satır sonunda kalıp "yanlış/boş" bir alt satıra düşüyor.
- "karşılaşma ve doğru/yanlış/boş istatistiklerini" cümlesi anlam olarak belirsiz.
- Sen/siz karışık: "takip edebileceğin" (sen) ile "ilk sizin haberiniz olsun ister misiniz?" (siz) aynı dialogda.
- Gövde, "Çok yakında hazır." ve gri açıklama arasında belirgin hiyerarşi yok. Gövde de kalın, tek fark boyut ve renk.
- "Kapat" kontrastı düşük (~2.7:1) ve metin butonu, dokunma alanı küçük.
- 4 üst chip'ten 2'si (Analiz, Harita) boş "Yakında" dialoguna çıkıyor, yani ölü uç. Seçili chip "Denemelerim" olarak kalıyor.
- Dialog genel ikonla geliyor. Marka illüstrasyonu yok.
- "Genel ⌄" neyi süzdüğünü söylemiyor.
- Arkadaki 4 kartın hepsinde "Deneme: 1" yazıyor, kapakta ise "DENEME 9". Etiket ve görsel çelişiyor.

---

### 23 · Analizlerim › Denemelerim + "Kavram Haritan" Yakında dialogu
**İçerik**
- Arka plan 22 ile aynı.
- Dialog başlığı: "Kavram Haritan".
- Gövde 1: "Matematik ve Geometri'deki durumunu görsel olarak takip edebileceğin bu modül mobilde de çok yakında kullanılabilecek."
- Gövde 2 (kalın): "Web kısmında ise şu anda hazır. smaptr.com'dan giriş yaparak kavram haritanı görebilirsin"
- Gri: "Bu özellik henüz geliştirilme aşamasındadır. Yayınlandığında ilk sizin haberiniz olsun ister misiniz?"
- Buton: "Yayınlandığında Haber Ver". Metin butonu: "Kapat".

**Bileşenler**
- 22 ile aynı şablon.
- Dialog daha uzun (~480 pt ekran yüksekliğinin %60'ı).

**Sorunlar**
- Çelişki: "Web kısmında ise şu anda hazır" deniyor, hemen altında "Bu özellik henüz geliştirilme aşamasındadır". Şablon metin özelliğe uymuyor.
- "smaptr.com" düz metin: dokunulamıyor, kopyalanamıyor. İkinci paragrafın sonunda nokta yok.
- Aynı sen/siz karışıklığı var.
- Şablon yüzünden "Yayınlandığında Haber Ver" bu kez web'de hazır bir özellik için çıkıyor. Birincil eylem "web'de aç" olmalıydı.
- Dialogda dört paragraf aynı ağırlıkta (kalın) ve hiyerarşi yok.

---

### 24 · Deneme Detay › Genel (üst)
**İçerik**
- Başlık: "Deneme Detay" (geri oku solda).
- Sekmeler: "Genel" (seçili), "Sorular", "Konu Analizi", "Bilgi Kartları".
- Deneme kapağı: "TÜRKİYE GENELİ DENEME 6", "YÜKSEKÖĞRETİM KURUMLARI SINAVI / ALAN YETERLİLİK TESTİ AYT". Form alanları: T.C. KİMLİK NUMARASI, ADI, SOYADI, SALON NO, SIRA NO. Ayrıca "ADAYIN DİKKATİNE!" ve "Adayın imzası:" bloğu, yayınevi logosu.
- "Deneme: 1" (gri).
- "AYT Deneme (Test)" (büyük, kalın).
- Üç istatistik kartı:
  - "Net Sayısı" **67.5** (turuncu)
  - "Doğru Sayısı" **86** (lacivert-gri)
  - "Yanlış Sayısı" **74** (kırmızı)
- Şeftali bilgi bandı (~#FDE6D8): "*TYT puanınız son çözdüğünüz denemeye göre hesaplanmıştır. OBP notunuz 85 olarak alınmıştır."
- İkili toggle: "Deneme Sonucu" (seçili) | "Sıralama".
- Sonuç kartları (2 sütun):
  - "Sosyal Bilimle…" (açık kitap ikonu): Doğru **23**, Yanlış **17**, Boş **0**.
  - "Sosyal Bilimle…" (sütun+kalem ikonu): Doğru **17**, Yanlış **23**, Boş **0**.

**Bileşenler**
- Üst bar: lacivert, alt köşeleri ~24 pt yuvarlak, ortada başlık.
- Sekme grubu: lacivert üstüne yarı saydam koyu zemin (~#2B3F5A) ve içinde beyaz hap (seçili: turuncu metin).
- Sayfa zemini ~#F3F4F6.
- İstatistik kartları: ~#F8F9FB, ~16 pt radius, border/gölge yok. Değerler ~40 pt kalın.
- Toggle: stadium şekilli. Seçili slate-lacivert dolgu (~#3D516E) üzerinde beyaz metin. Seçili olmayan taraf beyaz üzerinde gri-mavi metin.
- Kapak: dikdörtgen, köşe yuvarlaması yok, düşük çözünürlüklü fotoğraf (~150×200 pt).
- Ders ikonları: düz (flat) illüstrasyon.

**Sorunlar**
- İki kart da "Sosyal Bilimle…" diye kesilmiş. Hangisinin "Sosyal Bilimler", hangisinin "Sosyal Bilimler - 2" olduğu ayırt edilemiyor.
- Kapak "DENEME 6" diyor, etiket "Deneme: 1".
- Kapak bulanık/düşük çözünürlüklü ve köşeleri yuvarlanmamış.
- Bantta "TYT puanınız" geçiyor, ama ekran "AYT Deneme". Üstelik ekranda hiçbir yerde puan değeri gösterilmiyor.
- Başlıkta "(Test)" ve genel kartlarda "Boş" toplamı yok. Net, Doğru ve Yanlış var, Boş yok.
- İki farklı segmented stil üst üste: üstte lacivert içinde beyaz hap/turuncu metin, altta slate dolgulu hap. Seçili renkler birbirini tutmuyor.
- 4 sekmeli grupta "Konu Analizi" ve "Bilgi Kartları" etiketleri kutuya ~8 pt boşlukla sığıyor. Font büyüdüğünde taşar.
- İstatistik kartları sayfa zeminine neredeyse karışıyor (kart ~#F8F9FB, zemin ~#F3F4F6).
- Sosyal Bilimler kartlarında ikonlar "Türkçe" (kitap) ve "Tarih" (sütun) ikonlarının tekrarı.

---

### 25 · Deneme Detay › Genel (kaydırılmış)
**İçerik**
- Kapak resminin alt kısmı üst barın altına kesilmiş. "Adayın imzası:" bloğu ve yayınevi logosu görünüyor.
- Aynı "Deneme: 1", "AYT Deneme (Test)", üç istatistik kartı (67.5 / 86 / 74) ve şeftali bant.
- Toggle: "Deneme Sonucu" | "Sıralama".
- Kartlar:
  - "Sosyal Bilimle…" 23 / 17 / 0
  - "Sosyal Bilimle…" 17 / 23 / 0
  - "Matematik" (sinüs eğrisi + eksen ikonu, cyan-kırmızı) Doğru **25**, Yanlış **15**, Boş **0**
  - "Fen Bilimleri" (kırmızı-mavi deney şişeleri) Doğru **21**, Yanlış **19**, Boş **0**

**Bileşenler**
- 24 ile aynı. Üst bar sabit, içerik altından kayıyor. Alt sekme çubuğu yok.

**Sorunlar**
- Üst bar sabit ama kapak resmi çıkıntısı bara sert bir çizgiyle kesiliyor, fade yok.
- Sayfada 4 ders kartı var, bu 160 soruyu (86+74) açıklıyor ama Boş sütununun hepsi 0 ve bunun bir kısa özeti yok.
- Rakamlar tutarlı: 23+17+25+21 = 86 D, 17+23+15+19 = 74 Y. Ancak bu sayılar sınav tipiyle (AYT) ders adlarını ("Sosyal Bilimler", "Fen Bilimleri") TYT yapısıyla karıştırıyor.
- Sayfanın son kartı ile ekran sonu arasında ~80 px boşluk var, ama "Sıralama" tabına geçmeden bu bölümün işlevi belli olmuyor.

---

### 26 · Deneme Detay › Sorular (üst)
**İçerik**
- Sekmeler: "Sorular" seçili.
- Bölüm başlığı: "Sosyal Bilimler". Sağda rozetler: yeşil **23**, kırmızı **17**, gri **0**, ardından ⌄ chevron.
- Başlıkla grid arasında ~90 pt boş alan.
- 5 sütunlu soru grid'i (1–30 görünür). Her karo: durum ikonu, numara, altında harf "A".
  - 1–5: hepsi ✕ (kırmızı)
  - 6 ✓, 7 ✕, 8 ✕, 9 ✓, 10 ✓
  - 11 ✕, 12 ✕, 13 ✕, 14 ✓, 15 ✕
  - 16 ✓, 17 ✓, 18 ✕, 19 ✓, 20 ✓
  - 21–24 ✓, 25 ✕
  - 26–30 ✓
- Harf: ✓ olanlarda yeşil "A", ✕ olanlarda kırmızı "A".

**Bileşenler**
- Karolar: beyaz, ~13 pt radius, ~66×85 pt.
- ✕: pembe (~#FDE2E2) daire içinde kırmızı çarpı (~20 pt). ✓: dairesiz, yeşil (~#10B981) tik.
- Numara koyu, kalın ~20 pt.
- Rozetler: mint (~#D6F1E5) / pembe / gri zemin, ince kenarlıklı, ~8 pt radius.

**Sorunlar**
- Doğru ve yanlış durum ikonları tutarsız: yanlışta daire zemin var, doğruda yok.
- Başlık ile grid arasında ~90 pt kullanılmayan boşluk.
- Tüm 40 sorunun harfi "A". Bunun öğrencinin işareti mi doğru şık mı olduğu belli değil. Yanlış sorularda doğru şık hiç gösterilmiyor.
- Bölüm açık olduğu halde chevron aşağı bakıyor (27'deki kapalı başlıklarla aynı), durum anlaşılmıyor.
- Karolar dokunulabilir görünmüyor, ama hiçbir işlev ipucu yok.
- Rozetler ders adı ile aynı satırda, etiketsiz: 23/17/0 sayılarının D/Y/B olduğu rozet renginden çıkarılıyor.
- Alt sınırda 26–30 satırı ana ekran göstergesinin altına giriyor (kaydırma alanı güvenli alan payı yok).

---

### 27 · Deneme Detay › Sorular (kaydırılmış)
**İçerik**
- 16–20 satırı kısmen üst barın altında.
- 21–25: ✓✓✓✓✕. 26–30: ✓✓✓✓✓.
- 31 ✕, 32 ✓, 33 ✕, 34 ✓, 35 ✕.
- 36 ✓, 37 ✕, 38 ✓, 39 ✓, 40 ✓.
- Ardından ince gri ayraç ve kapalı bölümler:
  - "Sosyal Bilimler - 2" rozetler **17 / 23 / 0**
  - "Matematik" **25 / 15 / 0**
  - "Fen Bilimleri" **21 / 19 / 0**
  - Hepsinde ⌄ chevron.

**Bileşenler**
- 26 ile aynı. Kapalı bölüm başlıkları ~65 pt aralıkla, ayraç ince gri.

**Sorunlar**
- Genel'de "Sosyal Bilimle…" diye kesilen ad burada "Sosyal Bilimler - 2" olarak tam görünüyor. Ad üç ekranda üç biçimde: "Sosyal Bilimler" / "Sosyal Bilimle…" / "AYT Türk Dili ve Edebiyatı" (28).
- Son karo satırı ile ayraç arasında ~60 pt boşluk. Kapalı başlıklar arası ~58 pt, sıkışık değil ama düzensiz.
- Açık ve kapalı bölümde aynı chevron, durumu ayırt etmek imkânsız.
- Rozetlerin x konumu satırdan satıra ~2–4 pt kayıyor (rakam genişliğine bağlı), kolonlar hizalanmıyor.
- Sayımlar tutarlı: 17 yanlış, 23 doğru (26–27'deki karolardan sayıldı).

---

### 28 · Deneme Detay › Konu Analizi
**İçerik**
- Sekme: "Konu Analizi" seçili.
- Bölüm başlığı: "AYT Türk Dili ve Edebiyatı", rozetler yeşil **12**, kırmızı **12**, gri **0**, ⌄.
- Konu kartları:
  1. "Cumhuriyet Edebiyatı": Doğru **5**, Yanlış **7**, Boş **0** — halka **41%** (sarı)
  2. "Söz Sanatları ( Edebi Sanatlar)" (2 satır): **0 / 1 / 0** — **0%**
  3. "Batı Edebiyatı ve Akımları": **1 / 0 / 0** — **100%** (yeşil)
  4. "Nazım Bilgisi": **0 / 1 / 0** — **0%**
  5. "İslamiyet Etkisindeki Türk Edebiyatı (Divan-Halk Edebi…" (kesik): **0 / 2 / 0** — **0%**

**Bileşenler**
- Kartlar: beyaz, ~14 pt radius, hafif gölge.
- Konu adı kalın lacivert.
- Etiketler: "Doğru" açık yeşil, "Yanlış" açık kırmızı, "Boş" gri; altında değerler (yeşil/kırmızı/gri kalın).
- Sağda ~58 pt halka gösterge (~12 px kalınlık, iz ~#E2E8F0). 41% için sarı (~#FFEB3B), 100% için yeşil (~#4CAF50). % metni halkanın içinde koyu.

**Sorunlar**
- Bölüm adı Sorular/Genel'deki "Sosyal Bilimler" ile uyuşmuyor ("AYT Türk Dili ve Edebiyatı").
- Kesik metin: "İslamiyet Etkisindeki Türk Edebiyatı (Divan-Halk Edebi…". "Söz Sanatları ( Edebi" içinde parantez sonrası fazladan boşluk.
- Sarı halka (~#FFEB3B) beyaz üstünde ~1.2:1 kontrast, neredeyse görünmüyor. Yeşil/sarı Material renkleri palet dışı.
- 5/12 = %41.67 gösterimde "41%" (aşağı yuvarlama, 42 değil).
- 0 doğru + 1 yanlış (0%) ile hiç veri yok (0%) aynı halka. Yanlış ağırlıklı konular, güçlü konulardan ayırt edilmiyor.
- "Doğru/Yanlış/Boş" etiketleri açık renkte (açık yeşil ~1.9:1) kontrast düşük.
- Kart yükseklikleri başlık satır sayısına göre değişiyor (~95 pt vs ~118 pt), liste dengesiz.
- Zayıf konular sıralanmıyor: sıra soru sırasında, zayıf konu önceliği yok.

---

### 29 · Derslerim › TYT
**İçerik**
- Üst bar (ortak). Hemen altında sekme grubu: "TYT" (seçili, beyaz hap, turuncu) | "AYT".
- Ders kartları:
  1. "1 TYT Türkçe": %75, 15/20 Konu tamamlandı, 4 Alt Başlık, 26 Madde, 8 Bilgi Kartı
  2. "2 TYT Tarih": aynı sayılar
  3. "3 TYT Coğrafya": aynı sayılar
  4. "4 TYT Matematik": aynı sayılar
  5. "5 TYT Geometri": aynı sayılar
  6. "TYT Fi…" (altta kesik)
- Alt sekme: "Derslerim" aktif.

**Bileşenler**
- Sekme grubu: açık gri-beyaz (~#F5F6F8), üst yarısı lacivert barın üstünde.
- Kart: beyaz, ~17 pt radius, sol kenarda ~4 pt kalın renkli şerit (kahverengi, amber, mavi, kırmızı-coral, koyu mavi, cyan).
- Sol ikon karosu: ~64 pt, pastel zemin (krem, şeftali, açık mavi, açık pembe, açık mavi), flat illüstrasyon (açık kitap, sütun+kalem, dünya küresi, sinüs eğrisi, silindir+üçgen cetvel).
- Orta: peach kare içinde sıra numarası, kalın lacivert ders adı, kart rengine göre gradient ilerleme çubuğu, "%75", gri "15/20 Konu tamamlandı".
- Sağ: gri ikonlu 3 satır meta ("4 Alt Başlık", "26 Madde", "8 Bilgi Kartı"), turuncu oklu açık gri yuvarlak buton (~24 pt).

**Sorunlar**
- Beş kartın hepsi aynı sayılarla: %75, 15/20, 4/26/8. Ders ilerlemesi hiç ayırt edilemiyor (yer tutucu veri).
- Aynı bilgi iki yerde: çubuk + "%75" + "15/20 Konu tamamlandı" üçü de ilerlemeyi söylüyor.
- Başlıkta "TYT" tekrarı: sekme zaten TYT.
- Sıra numarası rozeti ("1", "2"…) anlam taşımıyor, yer kaplıyor.
- "TYT Matematik" başlığı meta sütununa ~16 pt yaklaşıyor (satır sonuna 545/583 px).
- Başlık satırları farklı uzunlukta olunca (sonraki ekranda) ilerleme çubuğu aşağı kayıyor.
- Header sekme grubu hem lacivert hem açık zemine taşıyor, üst bar alt kenarı düz iken Deneme Detay'da yuvarlak: iki farklı header stili.
- 6. kart FAB ve alt çubuğun altında kalıyor.
- Alt sekmede FAB, "Derslerim" etiketine ~10 pt yakın.

---

### 30 · Derslerim › AYT
**İçerik**
- Sekme: "AYT" seçili.
- Kartlar (hepsi %75, 15/20 Konu tamamlandı, 4 Alt Başlık, 26 Madde, 8 Bilgi Kartı):
  1. "1 AYT Türk Dili ve Edebiyatı" (2 satır, tüy+kitap ikonu, pembe-kırmızı şerit)
  2. "2 AYT Tarih" (amber, sütun ikonu)
  3. "3 AYT Coğrafya" (mavi, dünya küresi)
  4. "4 AYT Tarih-2" (amber, aynı sütun ikonu)
  5. "5 AYT Coğrafya-2" (mavi, aynı küre ikonu)
  6. "AYT M…" (altta kesik)

**Bileşenler**
- 29 ile aynı.

**Sorunlar**
- "AYT Tarih-2" ve "AYT Coğrafya-2" ilk iki kartla aynı ikon, renk ve rakamlar: ayırt etmek için yalnızca "-2" var.
- İki satırlı "AYT Türk Dili ve Edebiyatı" başlığı çubuğu ~9 pt aşağı itiyor, kartlar arası dikey hizalama bozuluyor.
- "AYT Coğrafya-2" başlığı ~38 px ile meta sütununa değiyor.
- Kart sırası alan mantığını (Eşit Ağırlık: Matematik/Edebiyat öncelikli) yansıtmıyor, Matematik 6. sırada.
- Sekme geçişi tek ekran, 29'daki sorunların hepsi geçerli.

---

### 31 · Hesap (ana)
**İçerik**
- Üst bar (ortak). Başlık yok.
- Menü satırları (turuncu ikon, sağda gri chevron): "Profilim ve Şifre", "Ödeme ve Paketler", "Kayıtlı Kartlarım", "Sözleşmeler", "Bildirimler".
- İnce ayraç, ardından kırmızı "Çıkış Yap" (kırmızı ok-kapı ikonu).
- Alt kısım boş. Alt sekme: "Hesap" aktif.

**Bileşenler**
- Satırlar: ~#F8F9FB zemin, ~12 pt radius, ~52 pt yükseklik.
- İkonlar ~17 pt, turuncu flat (kimlik kartı, sepet, kart, pano, zil).
- Etiketler koyu lacivert ~17 pt, orta ağırlık.
- "Çıkış Yap": kırmızı (~#EF4444), kırmızı-pembe ikon.

**Sorunlar**
- Satır zemini beyaz üzerinde ~#F8F9FB. Satırlar neredeyse zeminle aynı, sınırlar belirsiz.
- Ekranın ~%25'i (y 1215–1740 arası) boş. Yardım/destek, sürüm, koç bağlantısı gibi hiçbir şey yok.
- Üst barda kullanıcı bilgisi var ama Hesap ekranı kendi başına profil özeti göstermiyor. İsim/avatar üst barla tekrar.
- Menü ikonları küçük ve satır boyuna göre ~20% alan kullanıyor.
- "Çıkış Yap" menü satırlarıyla aynı kartta, ayrım yalnızca ayraç ve renk. Onay ekranı bu görüntüde yok.

---

### 32 · Hesap › Profilim ve Şifre (üst)
**İçerik**
- Üst bar: geri oku, sağda isim/avatar. Merkezde ayrıca büyük avatar (~90 pt) üst barın alt kenarına taşıyor.
- "Hesap Bilgileri" ve sağda kalem ikonu.
- Alanlar:
  - Ad Soyad: "Alparslan Kuloğlu"
  - E-Mail Adresi: "alparslan@ornek.com"
  - Telefon Numarası: "5XX XXX XX XX"
  - Öğrenci Koçluğu: kırmızı zeminli 3D erkek avatarı + "Mehmet Özkan"
- Ayraç. "Şifre ve Güvenlik" ve kalem ikonu (altta kesik).

**Bileşenler**
- Üst bar alt köşeleri yuvarlak (~24 pt).
- Büyük avatar: açık mavi (~#B5D9F0) zemin, beyaz halka.
- Etiketler kalın koyu ~15 pt. Salt-okunur alanlar ~#F5F5F5 dolgu, ince kenarlık, ~14 pt radius.
- "Öğrenci Koçluğu" kutusu beyaz, kenarlıklı.
- Kalem ikonları siyah, ~21 pt.

**Sorunlar**
- Avatar iki kez: sağ üstte küçük, merkezde büyük.
- Sayfa başlığı yok: sadece geri oku ve isim, hangi sayfada olunduğu anlaşılmıyor.
- İki farklı alan stili: gri dolgulu salt-okunur alanlar ve beyaz kenarlıklı "Öğrenci Koçluğu".
- Kalem ikonu siyah (marka turuncusu değil) ve ~21 pt, dokunma hedefi 44 pt'ten küçük.
- Telefon "5XX XXX XX XX" ülke kodu/maske yok.
- Üst bar + büyük avatar ekranın ~%26'sını kaplıyor.

---

### 33 · Hesap › Profilim ve Şifre (kaydırılmış)
**İçerik**
- Üst bar ve büyük avatar sabit. "Öğrenci Koçluğu" etiketi ve kutusu (Mehmet Özkan) avatarın altına kayıyor.
- "Şifre ve Güvenlik" + kalem.
- Üç alan: "Mevcut Şifre", "Yeni Şifre", "Yeni Şifre Tekrar" (hepsi göz-kapalı ikonlu).
- Ayraç. Kırmızı "Hesabımı Sil" (çöp kutusu ikonu).

**Bileşenler**
- Parola alanları: beyaz, kenarlıklı, placeholder soluk gri. Göz-kapalı ikon gri.
- "Hesabımı Sil": kırmızı metin + outline çöp ikonu, kutusuz.

**Sorunlar**
- Sabit üst bar + avatar kaydırılabilir alanı ekranın ~%62'sine düşürüyor, avatar içerik üstüne biniyor (kutu kenarı avatarın altında kesiliyor).
- Parola alanları düzenlenebilir görünüyor ama sayfada "Kaydet/Şifreyi Güncelle" butonu yok. Kalem ikonuyla akış belirsiz.
- "Hesabımı Sil" ikonu x=55 px'de, diğer içerik kenarı 38 px'de, soldan hizalı değil.
- Yıkıcı eylem bir buton gibi görünmüyor, onay adımı görünmüyor.
- Alan stilleri 32 ile aynı, iki stil karışık.

---

### 34 · Hesap › Ödeme ve Paketler
**İçerik**
- Üst bar (başlıksız).
- Plan kartı: "Plan: Yıllık Avantaj - 12 Aylık", "249 ₺ / Aylık", gri pasif buton "Planı Değiştir".
- Tablo başlığı: "Fatura Numarası ⌄", "Kesilme Tarihi ⌄".
- Satırlar:
  - Invoice #1023 — May 15, 2022
  - Invoice #1024 — Apr 17, 2022
  - Invoice #1025 — Mar 20, 2022
  - Invoice #1026 — Feb 20, 2022
  - Invoice #1027 — Jan 23, 2022
  - Invoice #1028 — Dec 26, 2021
  - Invoice #1029 — Nov 28, 2021
  - Invoice #1030 — Oct 31, 2021
  - Invoice #1031 — Oct 3, 2021 (yarım kesik)
- Sayfalama: "‹ Geri", [1] (turuncu), "2", "…", "68", "İleri ›".

**Bileşenler**
- Plan kartı: beyaz, kenarlıklı, ~17 pt radius. Başlık kalın, fiyat gri.
- "Planı Değiştir": gri (~#E0E0E0) zemin, gri metin (pasif görünüm).
- Tablo: beyaz, kenarlık, başlık satırı ~#F3F4F6. Fatura no koyu, tarih gri.
- Sayfa chip'i: turuncu, ~8 pt radius.

**Sorunlar**
- Fatura satırları İngilizce ("Invoice", "May 15, 2022") Türkçe uygulamada. Tarihler 2021–2022 (bugün 2026).
- 68 sayfa fatura bir öğrenci için gerçekçi değil (şablon veri).
- "249 ₺ / Aylık" ile "Yıllık Avantaj - 12 Aylık" birlikte belirsiz (yıllık mı aylık mı ödeniyor).
- "Planı Değiştir" pasif görünüyor, neden olduğu açıklanmamış.
- Tabloda tutar/durum/indir sütunu yok, satırlar dokunulabilir değil.
- Tablo iç içe kaydırma alanı gibi, son satır (#1031) yarıda kesiliyor.
- Sayfa başlığı yok.

---

### 35 · Hesap › Kayıtlı Kartlarım
**İçerik**
- Üst bar (başlıksız).
- Kart 1: Mastercard logosu (kırmızı-turuncu daireler), "**** **** **** 5678", sağda ⋮.
- Kart 2 (koyu lacivert 2 px kenarlıklı): "VISA", "★ Varsayılan" etiketi, "**** **** **** 1234", ⋮.
- Kart 3: "VISA", "**** **** **** 7892", ⋮.
- Turuncu tam genişlik buton: "Yeni Kart Ekle".
- Alt kısım boş.

**Bileşenler**
- Kartlar: beyaz, ince kenarlıklı, ~17 pt radius. Seçili kart koyu lacivert kenarlık.
- "Varsayılan": gri (~#D9DDE3) zemin, siyah yıldız.
- Numara aralıklı monospace-benzeri ~22 pt.
- "Yeni Kart Ekle": turuncu (#FF6A00), ~9 pt radius, kartlardan daha az yuvarlak.

**Sorunlar**
- Kart sahibi adı, son kullanma tarihi veya etiket yok. Kart yalnızca logo + maskeli numara.
- Logo kilitlenmeleri tutarsız: Mastercard sadece daireler, VISA kelime işareti.
- ⋮ menüsü ~6 px genişlikte, dokunma hedefi küçük.
- Maskeleme "****" yıldız, uygulama başka yerlerde noktalı karakterler kullanmıyor.
- Varsayılan kart ikinci sırada, ilk değil.
- Sayfa başlığı yok.

---

### 36 · Hesap › Sözleşmeler
**İçerik**
- Üst bar (başlıksız).
- 3 kart: "Gizlilik Politikası", "Aydınlatma Metni", "Kullanım Koşulları". Her birinde amber doküman ikonu, sağda göz ikonu.
- Alt kısım boş.

**Bileşenler**
- Kartlar: beyaz, kenarlıklı, ~17 pt radius, ~99 pt yüksek.
- İkon: amber (~#FFAB00) kâğıt, ~44 pt, Google Docs benzeri.
- Başlık kalın lacivert. Göz ikonu gri outline.

**Sorunlar**
- Kartlarda içerik dikey ortalı değil: üst boşluk ~16 pt, alt ~30 pt.
- Amber (#FFAB00) doküman ikonu palet dışı.
- Yürürlük tarihi, versiyon veya "kabul edildi" durumu yok.
- Kullanım Koşulları sonda, genelde ilk sırada beklenir.
- Sayfa başlığı yok.

---

### 37 · Hesap › Bildirimler
**İçerik**
- Üst bar (başlıksız).
- 6 anahtar (solda anahtar, sağda etiket):
  - "Aktif" (açık)
  - "Bildirimleri Aç" (açık)
  - "Kullanıcılar Görebilsin" (kapalı)
  - "Varsayılan Bildirim" (kapalı)
  - "Mobilde Göster" (kapalı)
  - "Otomatik Güncellemeleri Aç" (kapalı)
- Turuncu buton "Değişiklikleri Kaydet".

**Bileşenler**
- Anahtar: ~52×32 pt, açık durumda yeşil (~#22C55E) ve koyu yeşil halka, kapalı gri (~#E5E7EB). Beyaz thumb.
- Satırlar ince gri ayraçlı. Etiket ~17 pt orta ağırlık.

**Sorunlar**
- Anahtarlar yeşil, marka turuncusu değil.
- Etiketler web yönetim panelinden kalma: "Kullanıcılar Görebilsin", "Mobilde Göster" mobil uygulamada anlamsız. "Aktif" neyin aktif olduğunu söylemiyor.
- "Aktif" ve "Bildirimleri Aç" birbirini tekrar ediyor.
- Gruplama veya açıklama metni yok.
- Anahtar solda, etiket sağda (iOS'ta tersi).
- Anlık uygulanması beklenen anahtarlar için ayrıca "Değişiklikleri Kaydet" butonu var.
- Sayfa başlığı yok.

---

### 38 · Kamera tutorial (tam ekran)
**İçerik**
- Düz lacivert zemin (~#162B45), alt sekme çubuğu yok. Sağ üstte soluk gri "Kapat".
- Fotoğraf: ahşap masada "TYT-AYT CEVAP KAĞIDI" optik form, yanında laptop, gözlük, kalem, silgi, kalemtıraş. Formda beyaz kesikli dikdörtgen ve dört turuncu köşe noktası, cevap kutusunun sağ alt bloğunu çevreliyor.
- Başlık: "Noktaları Köşelere Getirin".
- Gövde: "Ders isimlerinin yer aldığı yatay dikdörtgeni dahil etmeyin. Beyaz noktaları cevap kutusunun dört köşesiyle eşleştirin. Bu, doğru okuma için önemlidir."
- Tek beyaz hap sayfa göstergesi.
- Onay kutusu: "Bir daha gösterme".
- Beyaz hap buton: "ANLADIM".

**Bileşenler**
- Fotoğraf: ~28 pt radius, ~3 px gri-mavi (~#5B6C84) kenarlık, ~330×350 pt, yapay üretim izlenimi (bulanık metin, yumuşak ışık).
- Başlık beyaz kalın ~26 pt. Gövde açık gri-beyaz regular ~17 pt, merkez hizalı.
- Buton beyaz, tam yuvarlak, lacivert büyük harf kalın metin.

**Sorunlar**
- Metin "Beyaz noktaları" diyor, görselde noktalar turuncu (beyaz kenarlı).
- İkinci satır başında fazladan boşluk var ("Beyaz noktaları…" satırı içeri girintili).
- Sayfa göstergesi tek hap: tek sayfalı tutorial için gereksiz, çok sayfa izlenimi veriyor.
- "ANLADIM" büyük harf, uygulamada başka hiçbir butonda büyük harf yok. Birincil buton beyaz, uygulamanın birincil rengi turuncu.
- Fotoğraf yapay görünüyor, optik formun yazıları okunmuyor.
- "Kapat" soluk ve küçük, "Bir daha gösterme" kutusu 44 pt altında dokunma hedefi.
- Metin 5 satır, önemli kural ("Ders isimlerinin yer aldığı yatay dikdörtgeni dahil etmeyin") vurgusuz.

---

### 39 · Ders detay › Türkçe (konu listesi)
**İçerik**
- Üst bar: geri oku, "Türkçe", sağda pembe kenarlıklı rozet (pembe kart ikonu + "31").
- Sekme grubu: "Tümü" (seçili) | "TYT" | "AYT". Altlarında sayaç daireleri: **31**, **28**, **3**.
- Konu kartları (hepsi %75, 15/20 Konu tamamlandı, 4 Alt Başlık, 26 Madde, 8 Bilgi Kartı):
  1. "1 Sözcükte Anlam" (coral şerit, A-Z kitap ikonu)
  2. "2 Cümlede Anlam" (mavi, konuşma balonu)
  3. "3 Ses Bilgisi" (amber, A/文 çeviri ikonu)
  4. "4 Yazım Kuralları" (kahverengi, tik/çarpı kitap)
  5. "5 Anlatım Yöntemleri" (2 satır, sarı, A/B kolonları)
  6. "6 Paragraf" (coral, turuncu "A≡")

**Bileşenler**
- Kart yapısı 29 ile aynı. Şerit renkleri sırayla dönüyor (coral, mavi, amber, kahverengi, sarı, coral).
- Sayaç daireleri beyaz, gölgeli, turuncu rakamlı.

**Sorunlar**
- Başlık merkezde değil (x≈435 yerine 460), sağdaki rozet nedeniyle ~11 pt sola kaymış.
- Rozetteki "31" neyi saydığı belli değil. Kart ikonu "Bilgi Kartı" gibi, ama sayı "Tümü" sayacıyla aynı.
- Sayaç daireleri sekme grubunun alt-sağ köşesinde kenara taşıyor, bildirim rozetine benziyor.
- Konu kartında "15/20 Konu tamamlandı": bir konunun içinde 20 konu olmaz, ders kartının metni tekrar kullanılmış.
- Tüm kartlarda aynı sayılar (yer tutucu). "4 Alt Başlık", detayda (40–42) en az 5 alt başlık var.
- Şerit renkleri anlamsız, 1. ve 6. kart aynı coral.
- Sekme grubu header kenarına taşıyor (29'daki gibi).
- Alt sekme çubuğu yok, geri dönüş yalnızca üst okla.

---

### 40 · Konu detay › Sözcükte Anlam
**İçerik**
- Üst bar: geri oku, "Sözcükte Anlam" (ortada).
- Beyaz levha içinde bölümler:
  - "Anlamı Yönünden Sözcükler" (açık): çubuk, "%60", "4 Madde", üç sayaç (lacivert-gri / yeşil / kırmızı kart ikonu) hepsi 0. Sağda büyük gri yer tutucu kitap ikonu, yukarı ok.
  - Alt maddeler: **1 Temel Anlam** (kırmızı, açık, yukarı ok pembe dairede). Madde metni: "• Bir sözcüğün akla gelen ilk anlamıdır. Sözlük anlamı da denir." "• Örnek: Bazı insanlar karanlıktan korkar. (Cümledeki karanlık, ışıksız anlamında kullanılmıştır.)"
  - **2 Yan Anlam**, **3 Mecaz Anlam**, **4 Terim Anlam** (kapalı, aşağı ok).
  - "Sözcükler Arası Anlam İlişkileri": "9 Madde", %60, 0/0/0.
  - "Mecaz Oluşturma Yolları" (altta kesik).

**Bileşenler**
- Levha beyaz, ~17 pt radius. Bölümler ince ayraçla ayrılıyor.
- Yer tutucu ikon: ~82 pt, ~#E9EAEE zemin, koyu slate outline kitap.
- Ok butonları: ~24 pt gri daire. Açıklama metni ~12.5 pt, soluk gri (~#8B93A7).

**Sorunlar**
- "%60" yazıyor ama çubukta dolu kısım görünmüyor, sayaçlar 0/0/0.
- Üç sayaç ikonunun ne anlama geldiği etiketli değil.
- Açık madde kırmızı ("Temel Anlam"), kırmızı genelde hata/zayıf anlamı taşır. Marka vurgusu turuncu.
- Yer tutucu kitap ikonu her bölümde aynı ve çok büyük, bölüm başına ~82 pt alan.
- Bölüm ok butonu (x≈833) ile madde ok butonu (x≈815) hizalı değil.
- Açıklama metni küçük ve düşük kontrastlı (~3:1).
- Konu kartında "4 Alt Başlık / 26 Madde" yazıyordu, burada 5+ başlık ve farklı madde sayıları var (4+9+9+1+2…).

---

### 41 · Konu detay › Sözcükte Anlam (iki madde açık)
**İçerik**
- 40 ile aynı üst kısım. "2 Yan Anlam" da açık (yukarı ok):
  - "• Bir sözcüğün temel anlamıyla bağlantılı olarak kazandığı yeni anlamdır."
  - "• Örnek: Yorganın yüzü kirlenmiş. (Yüz temel anlamıyla insanın önde olan tarafı demektir. Bu cümlede de önde olan kısım anlamıyla bağlantılı kullanıldığı için yan anlam kazanmıştır.)"
- "3 Mecaz Anlam", "4 Terim Anlam" kapalı. Altta "Sözcükler Arası Anlam İlişkileri" başlığı.

**Bileşenler**
- 40 ile aynı. Çoklu açılım destekleniyor (akordeon tek-açık değil).

**Sorunlar**
- "Temel Anlam" kırmızı, "Yan Anlam" aynı açık durumda siyah. Açık-durum renk kodu tutarsız, kırmızının anlamı belli değil.
- "Yan Anlam" ok butonu gri daire, "Temel Anlam"ınki pembe daire.
- Uzun örnek metni (5 satır) küçük ve soluk, okunması zor.
- Parantez içi açıklamalar madde işaretiyle aynı seviyede, ayrım yok.

---

### 42 · Konu detay › Sözcükte Anlam (kaydırılmış)
**İçerik**
- Üstte "Yan Anlam" açıklamasının son satırları: "…insanın önde olan tarafı demektir. Bu cümlede de önde olan kısım anlamıyla bağlantılı kullanıldığı için yan anlam kazanmıştır.)"
- "3 Mecaz Anlam", "4 Terim Anlam" (kapalı).
- Bölümler (hepsi %60, 0/0/0, yer tutucu kitap ikonu):
  - "Sözcükler Arası Anlam İlişkileri" — 9 Madde
  - "Mecaz Oluşturma Yolları" — 9 Madde
  - "Yansıma  Sözcükler" — 1 Madde
  - "Kalıplaşmış Söz Öbekleri" — 2 Madde

**Bileşenler**
- 40 ile aynı.

**Sorunlar**
- "Yansıma  Sözcükler" içinde çift boşluk.
- Her bölümde aynı "%60", aynı 0/0/0 ve aynı gri ikon: yer tutucu veri ve görsel.
- Her bölüm başlığı ~135 pt yer kaplıyor, ikon alanı bunun yarısından fazlası.
- Bölümler arası ayrım yalnızca ince çizgi.
- Çubuk dolu görünmüyor (40'taki sorun).

---

## Özet tablo

| No | Ekran | Ana sorun |
|---|---|---|
| 22 | Analizlerim › Denemelerim + Analiz dialogu | Indigo buton/ikon palet dışı, ölü uç "Yakında", sen/siz karışık |
| 23 | Analizlerim + Kavram Haritan dialogu | "Web'de hazır" ile "geliştirilme aşamasında" çelişkisi, düz metin URL |
| 24 | Deneme Detay › Genel (üst) | İki kart da "Sosyal Bilimle…", kapak "DENEME 6" vs "Deneme: 1", "TYT puanınız" ama puan yok |
| 25 | Deneme Detay › Genel (kaydırılmış) | Kapak üst barda sert kesiliyor, Boş toplamı yok |
| 26 | Deneme Detay › Sorular (üst) | Tutarsız ✓/✕ ikonları, ~90 pt boş alan, tüm harfler "A" ve belirsiz, chevron durumu göstermiyor |
| 27 | Deneme Detay › Sorular (kaydırılmış) | Bölüm adı 3 ekranda 3 farklı, açık/kapalı chevron aynı |
| 28 | Deneme Detay › Konu Analizi | Sarı halka ~1.2:1, %41 floor, "Edebi…" kesik, bölüm adı uyuşmuyor |
| 29 | Derslerim › TYT | Hepsi %75 / 15/20 / 4-26-8, üç kez tekrar eden ilerleme, "TYT" öneki tekrarı |
| 30 | Derslerim › AYT | "-2" kartları aynı ikon/renk, 2 satırlık başlık çubuğu kaydırıyor |
| 31 | Hesap (ana) | Satırlar zeminle aynı tonda, ~%25 boş alan, yardım/sürüm yok |
| 32 | Profilim ve Şifre (üst) | Çift avatar, başlık yok, iki alan stili, gerçek PII görünüyor |
| 33 | Profilim ve Şifre (kaydırılmış) | Sabit üst bar+avatar alanı daraltıyor, Kaydet butonu yok, "Hesabımı Sil" hizasız |
| 34 | Ödeme ve Paketler | İngilizce faturalar, 68 sayfa, pasif "Planı Değiştir", belirsiz fiyat |
| 35 | Kayıtlı Kartlarım | Sahip/SKT yok, logo kilitlenmeleri tutarsız, ⋮ küçük |
| 36 | Sözleşmeler | Palet dışı amber ikon, dikey ortalama yok, tarih/versiyon yok |
| 37 | Bildirimler | Web paneli etiketleri, yeşil anahtarlar, anlık anahtar + Kaydet butonu |
| 38 | Kamera tutorial | "Beyaz nokta" vs turuncu görsel, tek noktalı gösterge, büyük harf buton |
| 39 | Ders detay › Türkçe | Başlık merkezde değil, "31" rozeti belirsiz, konu kartında "15/20 Konu" |
| 40 | Konu detay (1 madde açık) | "%60" ama boş çubuk, kırmızı açık durum, devasa yer tutucu ikon |
| 41 | Konu detay (2 madde açık) | Açık madde renkleri tutarsız, küçük soluk açıklama |
| 42 | Konu detay (kaydırılmış) | "Yansıma  Sözcükler" çift boşluk, tüm bölümlerde aynı %60/0-0-0 |

## Birden fazla görüntüde geçen ekranlar

- **Analizlerim › Denemelerim (arka plan):** 22 ve 23, iki farklı "Yakında" dialoguyla.
- **Deneme Detay › Genel:** 24 (üst) ve 25 (kaydırılmış).
- **Deneme Detay › Sorular:** 26 (üst) ve 27 (kaydırılmış).
- **Derslerim:** 29 (TYT) ve 30 (AYT), aynı ekranda sekme durumu.
- **Hesap › Profilim ve Şifre:** 32 (üst) ve 33 (kaydırılmış).
- **Konu detay › Sözcükte Anlam:** 40 (1 madde açık), 41 (2 madde açık), 42 (kaydırılmış).

## Görüntülerde olmayan ekranlar

- Anasayfa.
- Analizlerim'in "Genel ⌄" açılır menüsü ve Denemelerim listesinin dialogsuz hali.
- Deneme Detay › Sıralama ve Bilgi Kartları sekmeleri.
- Konu Analizi'nin diğer bölümleri.
- Bilgi kartı ekranı.
