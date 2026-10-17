# SMAP: Claude Design Tur 12 brifi (çalışan ama yeni tasarımda olmayan özellikler)

## Rasit için: nasıl kullanılır (bu bölümü yapıştırma)

**Doğrulama özeti.** Denetçilerin "korunmalı" ve "sahibine sor" dediği maddelerin kodunu tek tek okudum.
- Altı özellik bugün gerçekten çalışıyor: erişilebilir durumdalar ve gerçek uçlara istek atıyorlar. Hiçbirini sahte saymadım.
  - koçun öğrencisi adına program kurup düzenlemesi,
  - Deneme Detay'da ham puan ve ham puan sırası,
  - Edebiyat'ta eser başına durum ve "Öğrendim",
  - Öğrenci Ekle'deki avatar seçimi,
  - e-posta değişikliği,
  - koçun tek adımda değiştirilmesi.
- Bunlara yedinci bir madde ekledim: koç hesabındaki "Koçluk kodu ne işe yarar?" açıklaması. Statik bir metin ama bugün çalışıyor ve yeni tasarımda yok.
- İki madde koşullu, çünkü istemci isteği gönderiyor ama sunucunun ne yaptığını koddan göremiyorum:
  - koç adına program yazma: sunucu, `studentId` ile gelen yazmayı öğrencinin hesabına mı işliyor?
  - koçu değiştirme: `addCoach` mevcut bağı yenisiyle değiştiriyor mu?
- Coin ve ilerleme yüzdesi beklemede. İstemci sunucudaki `points` ve `progress` alanlarını yalnız gösteriyor. Cihazda ikisi de 0 ve %0 görünüyor.
- Denetim raporunda düzelttiğim iki nokta:
  - `getMyWeeklies` bir POST isteği; bir denetçi GET yazmıştı (`lib/repository/weekly_repository.dart:39-45`).
  - Çantam satırında yalnız konu adı ve ders adı geliyor (`add_topic_popup.dart:203-243`). 3.5·3'teki "Son denemede 13 sorudan 9'u yanlış" alt satırının verisi yok.

**Adımlar**
1. SMAP tasarımını üreten **aynı** Claude Design projesinde yeni bir mesaj aç. Yeni proje açma.
2. **"YAPIŞTIR ⬇︎"** ile **"YAPIŞTIR SONU"** arasındaki her şeyi yapıştır.
3. Aynı mesaja aşağıdaki görüntüleri ekle. İlk mesajdaki belgeler projede zaten var, onları yeniden ekleme.
4. Tasarımcı "Adım A"yı yapıp duracak. **`devam`** yazınca "Adım B"ye geçecek.
5. Bitince **14 · Geri Gelen Özellikler (Tur 12)** sayfasını önceki dışa aktarımlar gibi **`SMAP-14.html`** olarak indir ve `tasarim-html/SMAP-14.html` olarak kaydet. 13.13 akışı ve 11.x ekleri de bu sayfada olacak, tek dosya yeter.
6. Turun sonundaki "Varsayımlar" listesini bana getir.
7. Sahibin cevapları çizimi durdurmaz. Cevaplar yalnız A ile F panolarının uygulanıp uygulanmayacağını ve B'deki ham puan satırının kalıp kalmayacağını belirler.

**Eklenecek görüntüler (`tasarim-paketi/ekranlar/`)**

| Özellik | Ekle | Görüntü yok; çekebilirsen ekle |
|---|---|---|
| A · Koç: öğrenci programı | Yok (koç ekranlarının görüntüsü hiç yok) | Koç hesabıyla Öğrencilerim › öğrenci › Program listesi (`43-koc-ogrenci-programlari.png`) ve bir programın düzenleme ekranı (`44-koc-program-duzenle.png`) |
| B · Ham puan | `24-deneme-detay-genel.png`, `25-deneme-detay-genel-alt.png` ("Deneme Sonucu / Sıralama" anahtarı) | "Sıralama" açıkken (`45-deneme-detay-siralama.png`) |
| C · Edebiyat | `30-derslerim-ayt.png` (Edebiyat satırı) | Yazar ve Eserler dönem listesi (`46-edebiyat-donemler.png`), yazar diyaloğu (kırmızı ve yeşil eser kutuları) (`47-edebiyat-yazar.png`) |
| D · Öğrenci Ekle avatarı | `07-kayit-ogrenci.png` (aynı avatar seçici) | — |
| E · E-posta | `32-profil-sifre-ust.png` | — |
| F · Koçu değiştir | `32-profil-sifre-ust.png`, `33-profil-sifre-alt.png` | Düzenleme modunda koç kartı, "Değiştir · Sil" görünür hâlde (`48-profil-koc-degistir.png`) |
| G · Koçluk kodu açıklaması | Yok | Koç hesabında "?" diyaloğu (`49-koc-kodu-nedir.png`) |

`34`, `35` ve `37` numaralı görüntüleri **ekleme**. Bunlar ödeme, kayıtlı kartlar ve eski bildirim ekranları; sahteydiler ve kaldırıldılar.

**Sahibin cevabına bağlı noktalar.** Sorular sende.
- Koç adına program yazma (A).
- `addCoach` eski bağı değiştiriyor mu (F).
- Ham puan gösterilsin mi (B, spec §6.5 #7).
- E-posta doğrulama ucu gelecek mi (E).
- Coin ve ilerleme sunucuda gerçekten hesaplanıyor mu. Cevap "evet" olursa ne ölçtüklerini de öğren (puan neyle artar, ilerleme neyin yüzdesi). Ek metni ona göre yazarım. Şimdilik çizilmiyor.

---

## YAPIŞTIR ⬇︎

## Tur 12 · Mevcut uygulamada çalışan ama yeni tasarımda olmayan özellikler

### 0. Bağlam

SMAP yeniden tasarımı bitti: Tur 1–11, teslim panoları 11.12–11.16 ve akış panoları 13.1–13.12. Uygulama koda dökülürken eski uygulamayı tek tek denetledik. Senin tasarımında olmayan özelliklerin bir kısmının bugün **gerçek veriyle çalıştığı** ortaya çıktı. Bu özellikler gerçek sunucu uçlarına istek atıyor, kullanıcı onlara ulaşabiliyor ve işe yarıyorlar.

Ürün sahibinin kararı: **çalışan hiçbir özellik kaldırılmaz, yeni tasarıma taşınır.** Yalnız sahte veri gösteren, "yakında" diyen ya da hiçbir yerden açılmayan özellikler kalkar. Bu turda yedi özelliği mevcut tasarım diline taşıyacaksın (A–G).

Ek D-4'teki liste değişmiyor. SmapLab, Gelen Kutusu, SmapCoach, Müfredat, Kaynak Takibi, Analiz ve Harita sekmeleri, ödeme, kayıtlı kartlar, faturalar, Soru Bankam, soru fotoğrafı, oyunlar, ay takvimi, coin ve eski bildirim anahtarları sahteydi. **Hiçbiri geri gelmez.** "Yakında" sheet'i yine hiçbir ekranda kullanılmaz.

### 1. Çalışma biçimi

- İlk mesajdaki kurallar aynen geçerli: Bölüm 0 (soru sorma politikası, Varsayımlar), Bölüm 5 (ilkeler), Bölüm 6 (kaçınılacak kalıplar), Bölüm 7 (teknik kısıtlar), Ek C (örnek veri) ve Ek D (varsayılan kararlar). Teslim panolarındaki son hâl (11.12–11.16) de geçerli.
- Bu tur iki adımdır: **Adım A** (A, B, C) ve **Adım B** (D, E, F, G, koyu kareler, akış ve teslim ekleri). Adım A'yı bitir ve dur. Kullanıcı `devam` yazınca Adım B'yi yap. Onay sorusu sorma.
- Belirsiz bir noktada en sade ve gerçek veriyle uyumlu seçeneği seç, "Varsayımlar"a `T12.n` numarasıyla yaz ve devam et.
- Eski panoları **değiştirme**. Değişen eski karelerin yeni hâlini 14 sayfasına çiz ve karenin altına "yerine geçtiği kare: 10.4·3" gibi bir not yaz.

### 2. Kesin kurallar

1. **Yalnız mevcut tasarım sistemi.** Token'lar 1.1–1.8, kit 1.9–1.26. Bileşenleri 11.13'teki adlarıyla kullan:
   - Kabuk: RootBand, HomeBand, DetailBar, ContextStrip, BottomBar, BottomSheet, ConfirmSheet, Toast.
   - Durumlar: OfflineStrip, Skeleton, EmptyState, ErrorState; InfoBox, WarningBox ve ErrorBox.
   - Kontroller: Button, BarAction (inline varyantı dahil), Segment, InScreenTabs, Chip, TextField, SearchField, CodeInput, SelectField, Radio, Switch.
   - Satırlar ve kartlar: SettingsRow, ListGroup, SectionHeader, TopicRow, AuthorRow, EksikTag, Accordion, ExampleBox, StatBox, ProgramRow, ProgramItemRow, CoachCard, ProfileSummary, CodeCard.
   - Program: DayChip, WeekGrid, HourSlot, Calendar, TimeWheel.
   - Kimlik: AvatarPicker, Avatar.

   Yeni bileşen icat etme. Bir bileşeni genişletmen gerekirse onu mevcut bir bileşenin varyantı yap ve 11.13 ekine "G" maddesi olarak yaz. Yeni bir ad zorunlu kalırsa bütün turda en çok bir tane olabilir; gerekçesini yaz.
2. **Sahte sayı yok.** Yalnız her özelliğin "Gerçek veri" listesindeki alanları göster. Değer yoksa alanı çizme; "0", tire ya da boş kutu koyma. Örnek veri Ek C'den ve bu brifin §7'sinden gelir. Ek C dışındaki her değeri Varsayımlar'a yaz.
3. **Durumlar eksiksiz.** Her yeni ekranda ve her yeni bölümde şu durumlar çizilir: ilk yükleme (iskelet), boş, hata (Tekrar Dene) ve çevrimdışı (OfflineStrip + son veri). Bir durum anlamsızsa, örneğin bir sheet'in "boş" hâli, nedenini Varsayımlar'a yaz. Her özelliğin **ana ekranının koyu hâli** çizilir.
4. **Metin kuralları.**
   - "Sen" dili, kısa cümleler.
   - Düğmelerde Türkçe Title Case; büyük harfli düğme yok.
   - "İptal" yerine "Vazgeç"; "Evet" yerine eylemin adı.
   - Emoji yok.
   - Hata metninde iç kod yok: "Bağlantını kontrol edip tekrar dene."
   - 13 pt altı metin yok; uzun adlar kesilmez (en çok 2 satır).
5. **Kaçınılacak kalıplar (Bölüm 6 ve 6.8):**
   - "kart + başlık + Tümü ›" tekrarı yok;
   - turuncu üstüne beyaz metin yok;
   - parıltı, gradyan hero ve konfeti yok;
   - verisi olmayan oyunlaştırma yok;
   - üstü çizili görev ve tamamlama yüzdesi yok.
6. **Koç bağlamı.** Koç bir öğrencinin verisindeyken her ekranda ContextStrip görünür; tam ekran akışlarda (3.5 gibi) da başlığın altında yer alır.
7. **Her birincil eylem tek.** Ekranda bir birincil düğme olur.
8. **Erişilebilirlik.** Dokunma hedefi 48 dp. Kontrast AA. Her yeni ikon düğmesinin ve durum işaretinin okunuş metnini kartın notuna yaz.

### 3. Yerleşim: hangi özellik nereye

İlkeler:
- Yeni sekme yok.
- Anasayfa'ya yeni bölüm yok; Anasayfa tek bir soruyu cevaplar ("Bugün ne yapmalıyım?").
- Menü ızgarası geri gelmez.
- Her özellik, verisinin ait olduğu ekranın içine girer.

| Özellik | Yer | Neden |
|---|---|---|
| A · Koç: öğrencinin programı | Öğrencilerim › öğrenci › 10.4 **Program** sekmesi. Koç Anasayfa'daki öğrenci şeridi ve Görüşme Detayı'ndaki "Öğrencinin verileri" de buraya açılır. | Koç programı bugün öğrenci kartından açıyor. 10.4 zaten öğrencinin programını gösteriyor; yalnız düzenleme eklenir. |
| B · Ham puan | 5.3 Deneme Detay başlığındaki **puan kartının içi** (koçta 10.4·4) | Aynı denemenin puan verisi. Ayrı bir "Sıralama" anahtarı gerekmez. |
| C · Edebiyat eser durumu | Derslerim › Türk Dili ve Edebiyatı › **Yazar ve Eserler** segmenti (7.4) → dönem detayı → yazar sheet'i | Sunucu veriyi dönem → alt başlık → yazar sırasıyla, katman katman veriyor. |
| D · Öğrenci avatarı | 10.3 Öğrenci Ekle sheet'inin başı | Bugün aynı formda. Kayıttaki (2.5) avatar seçicinin aynısı. |
| E · E-posta doğrulama | 9.2 Profil düzenleme kaydından açılan tam boy sheet | 9.2 bu adımı şart koşuyor ama çizmedi. |
| F · Koçu değiştir | 9.5 Koçluk "koçu var" hâli, "Bağlantıyı Kaldır"ın üstü | Bugün koç kartında "Değiştir" var. |
| G · Koçluk kodu açıklaması | 9.1·4 koç Hesap'ında Koçluk grubunun altbilgisi | Bugün kod alanının yanında "?" var. |

---

### 4. Özellikler

#### A · Koç: öğrencinin programını kurma ve düzenleme (14.1–14.3)

**Neden geri geliyor.** Bugün koç, öğrencisinin kartındaki "Program"dan o öğrencinin bütün programlarını görüyor, "+" ile onun adına yeni program kuruyor, bir programı açıp düzenleyip kaydediyor. Bütün istekler öğrencinin kimliğiyle gidiyor. 10.4·3 bunu salt okunur yaptı.

**Kural değişikliği.**
- 6.8 #36 ("koç görünümünde düzenleme yok") ve T9.6'ya **tek istisna: Program.**
- Koç bağlamında favori yıldızı, "Öğrendim", "Bu Konuyu Çalış" ve "Kartları Çalış" yine yok.
- "Programı İptal Et" koçta çizilmez: silme ucu yok ve bugün koçta da yok.

**14.1 · Koç · Öğrencinin Programı · 4 kare**
1. **Program sekmesi** (10.4·3'ün yerine):
   - DetailBar eylemi "Görüşme Planla" olarak kalır.
   - Program başlık satırında 17/24 "Ekim 2. Hafta" ve sağda `BarAction.inline` (PencilSimple) "Düzenle". Altında "Her gün biraz daha · 5–11 Ekim 2026".
   - Gün | Hafta Segment'i, DayChip şeridi ve ProgramItemRow'lar.
   - InfoBox'ın metni değişir: "Bu programı Alparslan da görür ve düzenleyebilir. Yaptığın değişiklik onun programına hemen yansır."
   - En altta SettingsRow [CalendarBlank] "Programlar" / "3 program" ›.
2. **Programlar** (3.4·1'in koç bağlamındaki hâli):
   - DetailBar: geri ve BarAction (Plus) "Yeni Program". Altında ContextStrip.
   - Başlık 24/32 "Programlar"; SearchField "Program ara".
   - ProgramRow'lar (§7'deki üç program).
   - Satıra dokununca o programın Gün görünümü açılır (kare 1 düzeninde).
3. **Düzenleme modu** (3.6·1'in koç bağlamındaki hâli):
   - ContextStrip ve "Bitti".
   - ProgramItemRow.edit, `secondary` "Konu Ekle", `textDanger` "Günü Sıfırla" (3.6'daki onay ve Geri Al aynen).
   - Değişiklikler 3.6'daki gibi anında kaydedilir.
4. **Öğrencinin programı yok:**
   - Sekme içinde EmptyState (bölüm düzeyi): "Alparslan'ın programı yok" / "Onun için bir hafta kurabilirsin; Alparslan programı kendi Anasayfa'sında görür."
   - `primary` (Plus) "Program Kur".

**14.2 · Koç · Öğrenci İçin Yeni Program · 4 kare** (3.5'in dört adımı; tam ekran akışta başlığın altında ContextStrip)
1. **Günler:** "Hangi günler çalışacak?" / "Alparslan için birden çok gün seçebilirsin; geçmiş günler seçilemez."
2. **Izgara:** 3.5·2 aynen (06:00–23:00, saatlik).
3. **Konu seç sheet'i:**
   - Segment "Çanta" | "Dersler".
   - Yardım: "Çanta: Alparslan'ın denemelerinden çıkan eksik konular."
   - Çanta satırı: konu adı + ders adı ("Kurtuluş Savaşı Hazırlık Dönemi" · "AYT Tarih").
   - **EksikTag ve "Son denemede…" alt satırı çizilmez:** Çanta verisinde bu alanlar yok. Aynı düzeltmeyi 3.5·3 için de nota yaz.
   - "Programda: Pzt 10:00" satırı kalır; istemcide hesaplanır.
4. **Ad ve motto:**
   - "Programa ad ver".
   - Özet kartı; `primary` "Programı Kaydet".
   - Toast "Program Alparslan'ın hesabına kaydedildi." gösterilir ve kare 14.1·1'e dönülür.
   - Vazgeç onayı 3.5'teki gibi.

**14.3 · Koç · Program · Durumlar ve Koyu · 4 kare**
1. İskelet: sekme içi; 3.7·2 satır iskeleti.
2. Hata: `ErrorState.section` "Programlar yüklenemedi" / "Bağlantını kontrol edip tekrar dene." / "Tekrar Dene". ContextStrip ve sekmeler kalır.
3. Çevrimdışı:
   - OfflineStrip; "Düzenle" ve "Yeni Program" pasif.
   - Not: "Program kurmak ve düzenlemek için bağlantı gerekiyor. Kayıtlı programı görebilirsin."
4. Koyu: 14.1·1.
- Kaydetme hatası kare olarak çizilmez, nota yazılır: toast "Program kaydedilemedi. Bağlantını kontrol edip tekrar dene."; form ve değişiklik korunur.

**Gerçek veri** (her istekte `?studentId=` var)
- `POST /student/getMyWeeklies`, gövde `{filter:{dates:[]}}`. Yanıtta:
  - `weeklies[]`: `_id`, `name`, `motto`, `tasks[]`;
  - `bagItems[]` (öğrencinin Çantası).
- Görev alanları: `day` (YYYY-AA-GG), `hour`, `minute`, `lesson`, `lessonName`, `mainSubject`, `subject`, `item`, `title` (konu adı), `lessonColor`.
- Çanta öğesi: `data.name` (konu adı), `lesson.name` (ör. "AYT Tarih") ve kimlik alanları. Eksik sayısı ya da deneme bağlamı yok.
- `GET /student/getAllMainSubjects`: Dersler sekmesindeki ders ve konu ağacı.
- `POST /student/addNewProgram` `{dataObj:{name, motto, tasks}}`.
- `POST /student/updateProgram` `{dataObj:{weeklyId, name, motto, tasks}}`.
- Program silme ucu yok. Tarih aralığı alanı yok; aralık görev günlerinden çıkarılır.

**Okunuş:** "Alparslan'ın programını düzenle" ("Düzenle" inline düğmesi için).

**Açık sorular** (Varsayımla çiz):
- Sunucu, koç oturumundaki yazmayı öğrencinin hesabına mı işliyor? İşlemiyorsa geliştirici bu panoları bayrakla kapatır ve 10.4·3 geçerli kalır.
- Öğrenci ve koç aynı anda düzenlerse son kayıt geçerli olur. Çakışma ekranı çizme.
- Öğrenciye bildirim yok (push kapalı). "Öğrenciye bildirildi" gibi bir metin yazma.

#### B · Deneme Detay: ham puan ve ham puan sırası (14.4)

**Neden geri geliyor.** Bugün Deneme Detay › Genel › "Sıralama" görünümünde yerleştirme puanı ve sırasının yanında **ham puan ve ham puan sırası** da var. Değerler sunucudan geliyor. 5.3 yalnız yerleştirme puanını çizdi (T3.2).

**14.4 · Deneme Detay · Puan Kartı · 3 kare**
1. **AYT:**
   - Kart başlığı "Eşit Ağırlık".
   - Üst satır: "412,63" Yerleştirme puanı · "48.215." Sıra.
   - İnce ayraç; alt satır: "398,12" Ham puan · "52.904." Sıra.
2. **TYT:** puan verisi varsa kart başlığı "TYT". "384,05" Yerleştirme puanı · "176.320." Sıra; "371,90" Ham puan · "189.004." Sıra.
3. **Koyu:** 5.9·1 üstünde kare 1.

**Kurallar**
- Ham değer yoksa alt satır çizilmez. İki puan da yoksa kart çizilmez (bugünkü 5.3·3 gibi).
- Yalnız öğrencinin alanındaki puan türü gösterilir. Eski Eşit Ağırlık / Sayısal / Sözel sekmeleri sahteydi ve kalkıyor.
- "Deneme Sonucu / Sıralama" anahtarı yok. OBP satırı yok.
- 5.1 sonuç anına ham puan eklenmez; yalnız Deneme Detay'da görünür.
- Koçta 10.4·4 aynı kartı kullanır.
- 5.8·1'deki iskelette puan bloğunun yüksekliğini yeni karta göre güncelle.

**Gerçek veri:** deneme satırındaki `points[]`, `ranks[]`, `pointsHam[]`, `ranksHam[]` (puan türü başına dizi) ve `mexam.type` (1 = TYT). Ayrı istek yok.

**Metinler:** "Yerleştirme puanı", "Ham puan", "Sıra". Okunuş: "Ham puan 398,12, sıra 52.904".

**Açık soru:** ürün sahibi ham puanı istemezse alt satır kalkar (§6.5 #7). AYT dizisindeki sıranın hangi puan türüne karşılık geldiği backend'e soruldu.

#### C · Edebiyat: dönem → alt başlık → yazar → eser; eser başına durum ve "Öğrendim" (14.5–14.7)

**Neden geri geliyor.** Bugün Yazar ve Eserler'de öğrenci:
- dönemleri eksik eser sayılarıyla görüyor;
- dönem açılınca alt başlıkları (akordeon) ve yazarları görüyor;
- her yazarın eserlerini türe göre gruplu görüyor; her eserin yanında **eksik (✕) ya da biliyor (✓)** durumu var;
- eksik bir esere dokununca sunucuya "öğrendim" yazıyor.

Sayfa ilk eksik esere kayıyor; eksik eseri olan alt başlık ve yazar vurgulu. 7.4 bunu düz bir yazar listesine ve yazar düzeyinde tek bir "Öğrendim"e indirdi; eser başına durum ve öğrenme kayboldu.

**14.5 · Edebiyat · Dönemler ve Yazarlar · 3 kare**
1. **Yazar ve Eserler · dönemler** (7.4·1'in yerine):
   - Segment "Konular" · "Yazar ve Eserler · 3 eksik" (sayaçlı).
   - TopicRow'lar: sıra numarası, dönem adı ve EksikTag "2 eksik eser". Eksik yoksa etiket çizilmez.
2. **Dönem detayı** (DetailBar ekranı):
   - Başlık "Tanzimat Dönemi" + meta "2 eksik eser".
   - Accordion'lar alt başlıklardır; her biri EksikTag'li.
   - Açık akordeonda AuthorRow'lar: fotoğraf (yoksa baş harf), ad, "8 eser" ve eksik varsa EksikTag "2 eksik".
   - İlk eksiği olan akordeon açık gelir ve sayfa oraya kayar (7.3'teki "ilk eksiğe kaydır" kuralı).
3. **Akordeon yükleniyor:** yazarlar akordeon açılınca yüklenir; akordeonun içinde 3 satır iskeleti.

**14.6 · Edebiyat · Yazar Sheet'i · 3 kare**
1. **AuthorSheet** (tam boy; 7.4·2'nin yerine):
   - Başlık: fotoğraf 56, "Namık Kemal", "Tanzimat Dönemi", Kapat.
   - "Hakkında" (paragraflar).
   - "Eserleri" + "8 eser · 2 eksik".
   - Tür grupları: tür başlığı ve sayısı ("Roman · 2"). Her eser kendi satırında: ad (bodyReading), sağda durum.
     - Eksik eser: 7.3'teki eksik işareti, "Eksik" etiketi ve `text` "Öğrendim".
     - Bilinen eser: ✓ "Biliyorsun".
   - Yazar düzeyindeki tek "Öğrendim" ve alt eylem bandı **kalkar**.
2. **Öğrendim sonrası:**
   - "İntibah" ✓ olur (250 ms); sayaç "8 eser · 1 eksik" olur.
   - Toast "İntibah bildiklerine eklendi." + "Geri Al" (6 sn).
   - Arkadaki dönem ve alt başlık sayaçları da düşer.
3. **Eser durumu bilinmiyor ve eser yok:**
   - Durum verisi gelmeyen eserde yalnız ad görünür; durum çizilmez (eski "?" ikonu kalkar).
   - Hiç eser yoksa bölüm boş metni: "Bu yazarın eser listesi henüz yok."

**14.7 · Edebiyat · Durumlar ve Koyu · 4 kare**
1. Dönem listesi iskeleti.
2. Bölüm hatası: "Yazarlar yüklenemedi." + "Tekrar Dene" (akordeon içinde ya da listede).
3. Çevrimdışı:
   - Önbellekteki liste; "Öğrendim" pasif.
   - Satır notu: "Öğrendim'i kaydetmek için bağlantı gerekiyor."
4. Koyu: AuthorSheet (Edebiyat koyu tonları).
- Kaydetme hatası kare olarak çizilmez, nota yazılır: satır eksiğe döner ve toast "Kaydedilemedi. Bağlantını kontrol edip tekrar dene." çıkar.

**Gerçek veri**
- Dönemler: `GET /student/yazarEserMainSubjects` → `mainSubjects[]`: `_id`, `name`, `order`, `itemDataCount` (eksik eser sayısı). Segment sayacı bunların toplamıdır.
- Dönem detayı: `GET /student/getSubSubjects?mainSubjectId=` ve `POST /student/getItems?edebiyat=true&yazarEserMode=true` → alt başlık `name`, `itemDataCount`, eksik eserler (`itemDatas`), yazar öğeleri (`itemsArray`).
- Yazar: `GET /student/getSubjectAuthors?itemId=` (akordeon açılınca) → `name`, `image` (tarihî siyah-beyaz fotoğraf; yoksa baş harf), `desc[]` (paragraflar), `works[]`.
- Eser (`works[]` öğesi): `eser` (ad), `type` (tür kodu; 33 tür adı: Şiir, Roman, Tiyatro…), `itemData{_id, status}` (0 eksik, 1 biliyor; alan yoksa durum yok).
- Öğrendim: `GET /student/learnedItem?itemId=` (eser başına).
  - Geri alma ucu yok. "Geri Al" 8.1'deki gibi istemcide çalışır: istek 6 sn sonra gider.
- Dönem satırında yazar sayısı gelmiyor; "N yazar" yazma.
- Bugünkü yazar yıldızı yalnız yerel ve kaydedilmiyor; taşınmaz.

**Okunuş:** "İntibah, roman, eksik. Öğrendim olarak işaretle."

#### D · Öğrenci Ekle: avatar seçimi (14.8)

**Neden geri geliyor.** Bugün koç öğrenci eklerken 7 avatardan birini seçiyor. Seçim sunucuya `photo` olarak yazılıyor ve öğrencinin avatarı oluyor. 10.3 formunda avatar yok.

**14.8 · Öğrenci Ekle · Avatar · 2 kare**
1. **10.3·1, avatarlı:**
   - Formun başında 2.5 Kayıt'taki satır içi AvatarPicker: 7 avatar, seçili olan halkalı, "7 avatar" yazılı.
   - Listedeki ilk avatar seçili gelir; avatar seçmek zorunlu değil.
2. **Eklendi (CredentialsSheet):** başlıkta "Zeynep Kaya eklendi" yanında seçilen avatar (56).

Öğrencilerim'de yeni satır seçilen avatarla görünür. 10.3'ün bütün durumları geçerli.

**Gerçek veri:** `POST /coach/addNewStudent`. `dataObj.photo` = avatar dosya adı; diğer alanlar 10.3'teki gibi.

**Okunuş:** "Avatar 4/7, seçili".

#### E · Profil: e-posta değişikliğini doğrulama (14.9)

**Neden geri geliyor.** Bugün öğrenci ve koç Profil'de e-postasını değiştirip kaydedebiliyor; yeni adres doğrudan sunucuya yazılıyor. 9.2 e-posta değişimini 6 haneli koda bağladı ama kod adımını çizmedi. Çizim olmazsa geliştirici bugün çalışan e-posta değişimini kapatmak zorunda kalır.

**14.9 · Profil · E-posta Doğrulama · 4 kare**
1. **9.2 düzenleme, e-posta değişmiş:** alanın altında yardım metni: "Kaydedince yeni adresine bir kod göndereceğiz. Doğrulayana kadar eski adresin geçerli."
2. **Kod sheet'i** (BottomSheet tam boy, 2.4 CodeInput):
   - "E-postanı doğrula" / "alparslan.kuloglu@ornek.com adresine 6 haneli bir kod gönderdik."
   - CodeInput; 6. hane girilince doğrulama kendiliğinden başlar (2.4 gibi).
   - Altta "Kodu tekrar gönder · 0:24". Süre dolunca `text` "Kodu Tekrar Gönder".
3. **Hatalı kod:** alan hatası "Kod doğru değil. Tekrar dene." Süresi dolmuş kod için nota yaz: "Kodun süresi doldu. Yeni kod iste."
4. **Doğrulama bekliyor** (sheet kapatıldı):
   - Profil görüntüleme; e-posta alanında eski adres.
   - Altında WarningBox "alparslan.kuloglu@ornek.com doğrulanmayı bekliyor." + `text` "Kodu Gir".

**Notlar (kare gerekmez)**
- Başarı: sheet kapanır, toast "E-postan güncellendi." çıkar.
- Kod gönderilemezse toast "Kod gönderilemedi. Bağlantını kontrol edip tekrar dene."
- Adres başka hesapta kayıtlıysa alan hatası "Bu e-posta başka bir hesapta kayıtlı." (Varsayım).
- Çevrimdışıyken Kaydet pasif (9.2 kuralı).
- **Yedek:** doğrulama ucu yokken e-posta bugünkü gibi doğrudan kaydedilir ve 9.2'nin normal toast'ı "Profilin güncellendi." çıkar. Bunu panoya not olarak yaz.
- Koçta aynı akış.

**Gerçek veri:** bugün `POST /student/updateStudent` gövdesindeki `email`. Doğrulama uçları yok (§6.3 #10).

#### F · Koçluk: koçu tek adımda değiştirme (14.10)

**Neden geri geliyor.** Bugün koçu olan öğrenci Profil'de "Değiştir"e basıp yeni koçluk kodu girerek koçunu değiştirebiliyor. Bunun için kullanılan istek, ilk bağlanmadakiyle aynı (`addCoach`). 9.5'te yalnız "Bağlantıyı Kaldır" var; değişim iki adıma ve arada koçsuz kalınan bir duruma dönüştü.

**Koşul:** sunucunun yeni kodla eski bağı değiştirdiği doğrulanırsa uygulanır. Doğrulanmazsa 9.5'teki iki adımlı yol kalır. Panoyu yine çiz.

**14.10 · Koçluk · Koçunu Değiştir · 4 kare**
1. **9.5·1, düğmeli:** CoachCard ve InfoBox; altında `text` (ArrowsLeftRight) "Koçunu Değiştir", onun altında `textDanger` "Bağlantıyı Kaldır".
2. **Değiştirme sheet'i** (orta boy):
   - "Koçunu değiştir" + Kapat.
   - WarningBox: "Mehmet Özkan ile bağlantın kalkacak. Yeni koçun denemelerini, analizlerini ve programını görebilecek."
   - Maskeli TextField "Yeni koçunun kodu" (AAAA-0000; yardım "4 harf ve 4 rakam; tire kendiliğinden gelir.").
   - `primary` "Koçu Değiştir"; gönderim sırasında sheet'in meşgul durumu.
   - Ayrı onay sheet'i yok; uyarı bu sheet'in içinde (Varsayım).
3. **Hata:**
   - Kod bulunamazsa: "Bu kodla bir koç bulunamadı. Kodu koçundan yeniden iste."
   - Girilen kod mevcut koçunsa: "Bu kod zaten koçun Mehmet Özkan'a ait."
4. **Başarı:** 9.5·1 "Ayşe Demir" ile görünür; toast "Ayşe Demir'e bağlandın." Yeni koçun sıradaki görüşmesi yoksa o satır çizilmez.

Çevrimdışıyken "Koçu Değiştir" pasiftir. Not: "Koçunu değiştirmek için bağlantı gerekiyor."

**Gerçek veri:**
- `GET /student/addCoach?code=` (bugün koç bağlıyken de çağrılıyor).
- `GET /student/getStudentsCoach` → mevcut koçun adı, koçluk kodu ve fotoğrafı.

#### G · Koç Hesap: "Koçluk kodu ne işe yarar?" (14.11)

**Neden geri geliyor.** Bugün koç, Profil'deki koçluk kodu alanının yanındaki "?" ile kodun ne işe yaradığını anlatan bir metin açıyor. 9.1·4'te kod, Kopyala ve Paylaş var; açıklama yok.

**14.11 · Hesap · Koç · Koçluk Kodu · 2 kare**
1. **9.1·4:** Koçluk grubunun altbilgisinde `text` (Question 20) "Koçluk kodu ne işe yarar?".
2. **Küçük sheet** (9.5·4 düzeni):
   - Başlık "Koçluk kodu ne işe yarar?"
   - Paragraf 1: "Öğrencin bu kodu kendi hesabında Hesap › Koçluk bölümüne girer; böylece hesabı seninkine bağlanır."
   - Paragraf 2: "Bağlanan öğrenciler Öğrencilerim'de listelenir; denemelerini, analizlerini ve programını görürsün. Hesabını senin açtığın öğrenciler zaten bağlı gelir."
   - `primary` "Tamam".

Kod yoksa satır ve altbilgi çizilmez. **Veri:** oturumdaki koçluk kodu (`refCode`); metin statik.

**14.12 · Tur 12 · Koyu · 4 kare:** 14.8·1, 14.9·2, 14.10·2, 14.11·2.

---

### 5. Adımlar

- **Adım A:** 14.1–14.7 (A, B, C).
- **Adım B:** 14.8–14.12 (D, E, F, G, koyu), sonra 13.13 akışı ve teslim ekleri (§6).

### 6. Teslim

1. **Kanvas.** Yeni sayfa aç: `14 · Geri Gelen Özellikler (Tur 12)`.
   - Satırlar akış sırasıyla: Koç programı → Deneme Detay → Edebiyat → Öğrenci Ekle → Profil e-posta → Koçluk → Koç Hesap → Koyu.
   - Pano adları kodla başlar: `14.1 · Koç · Öğrencinin Programı · 4 kare`. Panoların arasına "→ nereden nereye" notu yaz.
2. **`13.13 · Tur 12 Akışları · N ekran`.** Bu panoyu 14 sayfasının sonuna koy ve 13.x gösterimini kullan. Gösterim: `→ [dokunulan yer]` dokunuşla geçiş, `⇢` kendiliğinden geçiş, `(14.n·k)` pano ve kare. Akışlar:
   - Koç programı: Öğrencilerim (10.2·1) → [öğrenci] Analiz (10.4·1) → [Program] Program (14.1·1) → [Düzenle] Düzenleme modu (14.1·3) → [Bitti] → [Programlar] Programlar (14.1·2) → [Yeni Program] Günler (14.2·1) → Izgara (14.2·2) → Konu seç · Çanta (14.2·3) → Ad ve motto (14.2·4) → [Programı Kaydet] Program (14.1·1) + toast.
   - Edebiyat: Derslerim AYT (7.1·2) → [Türk Dili ve Edebiyatı] Dönemler (14.5·1) → [dönem] Dönem detayı (14.5·2) → [yazar] Yazar sheet'i (14.6·1) → [Öğrendim] Öğrenildi + Geri Al (14.6·2).
   - Ham puan: akış değişmez; 5.3 ve 10.4·4 içinde (14.4).
   - Öğrenci Ekle: Öğrencilerim + → Form, avatarlı (14.8·1) → [Öğrenciyi Kaydet] Eklendi (14.8·2).
   - E-posta: Profil (9.2·1) → [Düzenle] (14.9·1) → [Kaydet] Kod sheet'i (14.9·2; hatalı kod 14.9·3) ⇢ doğrulandı, toast; sheet kapanırsa Doğrulama bekliyor (14.9·4).
   - Koçu değiştir: Koçluk (14.10·1) → [Koçunu Değiştir] Sheet (14.10·2; hata 14.10·3) → [Koçu Değiştir] Bağlandın (14.10·4).
   - Koç Hesap: Hesap · koç (14.11·1) → [Koçluk kodu ne işe yarar?] Sheet (14.11·2).
3. **`11.13 ek · Bileşen Listesi (Tur 12)`.**
   - Hedef: yeni bileşen yok. Kullanılan varyantları yaz:
     - ContextStrip'in tam ekran akış içindeki hâli;
     - program başlık satırında `BarAction.inline`;
     - AuthorRow'un eser sayısı ve EksikTag ile kullanımı;
     - durumlu eser satırı (en yakın mevcut satırın varyantı);
     - sheet içinde satır içi AvatarPicker;
     - Profil'de satır içi WarningBox;
     - sheet içinde CodeInput.
   - Yeni ad zorunlu kaldıysa gerekçesini yaz.
4. **`11.14 ek · Ekran–Bileşen Eşlemesi (Tur 12)`.** 14.1–14.12'nin her biri için kullanılan bileşenler.
5. **`11.16 ek · Varsayımlar (Tur 12)`.**
   - Yeni varyasyonlar `T12.n` numarasıyla.
   - Güncellenen eski varsayımlar:
     - T9.6: koç programı düzenleyebilir.
     - T3.2: ham puan çizildi.
     - T5.7: yazar listesi dönemli.
     - 6.8 #36: Program istisnası.
6. **`11.17 · Tur 12 · Ne değişti, varsayımlar, geliştirici notları`.**
   - "Ne değişti, neden": her madde bugün çalışan bir özelliğe bağlanır.
   - Varsayımlar.
   - Geliştirici notları: uçlar ve koşullar. A ve F sunucu davranışına bağlı. E'nin doğrulama ucu yok, yedek davranışla çalışır.

Bitirmeden işini Bölüm 5, Bölüm 6 ve 6.8 listelerine karşı denetle. Düzeltemediğin bir şey kalırsa 11.17'ye yaz.

### 7. Örnek veri ekleri (Ek C'ye ek; hepsini Varsayımlar'a yaz)

- **Alparslan'ın programları:**
  - "Ekim 2. Hafta" · "Her gün biraz daha" · 5–11 Ekim 2026 (Bu hafta);
  - "Deneme haftası" · "Az ama her gün" · 28 Eylül–4 Ekim 2026;
  - "Yaz tekrarı" · motto yok · 17–23 Ağustos 2026.
- **Çanta örnekleri:** "Kurtuluş Savaşı Hazırlık Dönemi" · AYT Tarih; "Fiilde Çatı" · TYT Türkçe; "İklim Bilgisi" · TYT Coğrafya; "Noktalama İşaretleri" · TYT Türkçe.
- **Ham puan:**
  - Türkiye Geneli Deneme 6 (EA): ham puan 398,12 · sıra 52.904.
  - TYT Genel Deneme 9: yerleştirme 384,05 · sıra 176.320; ham 371,90 · sıra 189.004.
- **Edebiyat:**
  - Dönemler: 1 Tanzimat Dönemi (2 eksik eser) · 2 Servet-i Fünun Dönemi (1) · 3 Fecr-i Âti · 4 Millî Edebiyat Dönemi · 5 Cumhuriyet Dönemi.
  - Tanzimat alt başlıkları: "Birinci Dönem Sanatçıları" (Şinasi, Namık Kemal, Ziya Paşa; 2 eksik) · "İkinci Dönem Sanatçıları" (Recaizade Mahmut Ekrem, Abdülhak Hamit Tarhan, Sami Paşazade Sezai).
  - Namık Kemal, 8 eser:
    - Roman: İntibah (eksik), Cezmi;
    - Tiyatro: Vatan yahut Silistre (eksik), Gülnihal, Akif Bey, Zavallı Çocuk, Kara Bela, Celaleddin Harzemşah.
  - Tevfik Fikret: "Rübab-ı Şikeste" eksik.
  - Toplam 3 eksik eser; Ek C'deki Edebiyat 3 ile aynı.
- **Yeni koç:** Ayşe Demir · AYDM-3307.
- **Yeni e-posta:** alparslan.kuloglu@ornek.com.
- **Zeynep Kaya'nın avatarı:** 7 avatarın 4'üncüsü.

## YAPIŞTIR SONU

---

## Ek: karar tablosu (yapıştırma)

Kanıt yolları `smapFlutter/lib/` altındadır.

### A. Tur 12'ye gidenler (çalışıyor, tasarımda yok ya da eksik)

| Özellik | Durum | Uçlar | Kanıt | Karar |
|---|---|---|---|---|
| Koç: öğrencisi adına program kurma ve düzenleme | İstemcide çalışıyor; sunucunun yazmayı öğrencinin hesabına işlediği doğrulanmadı | `POST /student/getMyWeeklies`, `GET /student/getAllMainSubjects`, `POST /student/addNewProgram`, `POST /student/updateProgram` (hepsi `?studentId=`) | `features/my_students/my_students_screen.dart:157-167`; `features/home/presentation/widgets/home_students_cards.dart:305-316`; `features/home/presentation/screens/coach_programs_screen.dart:68`; `.../my_schedule_page/my_schedule_page.dart:14`; `repository/weekly_repository.dart:17-19, 39-45, 50-56, 62-70, 86-89`; `.../schedule_list_page/schedule_list_page.dart:103-121, 149-176` (rol kontrolü yok); `.../add_lessons_page/add_lessons_page.dart:685-687, 696, 701` | 14.1–14.3 (koşullu bayrak) |
| Deneme Detay: ham puan ve sırası | Gerçek veri (EA/SAY/SÖZ sekmeleri sahte) | Deneme satırı: `pointsHam`, `ranksHam` (`getMyMockExams`) | `features/analytics/presentation/screens/my_test_result_detail_screen.dart:259-277, 264` (`_currentType` hep 0), `:343-351`, `:377-384`; `.../widgets/my_test_results_detail_widgets.dart:206-224` (statik sekmeler) | 14.4; sekmeler kalkar |
| Edebiyat: dönem hiyerarşisi, eser durumu, eser başına "Öğrendim" | Çalışıyor | `GET /student/yazarEserMainSubjects`, `GET /student/getSubSubjects`, `POST /student/getItems?edebiyat&yazarEserMode`, `GET /student/getSubjectAuthors`, `GET /student/learnedItem` | `features/home/presentation/widgets/lesson_navigation_helper.dart:46-57`; `features/analytics/presentation/screens/edebiyat_lesson_detail_page.dart:247-256, 651, 665-686, 1106-1110, 1166-1185, 1812-1825, 2316-2351, 2384-2398, 2519-2522`; `repository/analysis_repository.dart:173-253` | 14.5–14.7 |
| Öğrenci Ekle: avatar seçimi | Çalışıyor | `POST /coach/addNewStudent` (`dataObj.photo`) | `features/my_students/add_student_dialog.dart:37-38, 120-132, 296-350`; `repository/coach_repository.dart:79-86` | 14.8 |
| E-posta değişikliği | Çalışıyor (doğrulamasız) | `POST /student/updateStudent` (`email`) | `features/profile/presentation/screens/account_settings/account_settings_screen.dart:842-848, 309-310, 361-372, 376-383`; `repository/profile_repository.dart:43-49` | 14.9 (doğrulama adımı + yedek) |
| Koçu tek adımda değiştirme | İstemcide çalışıyor; sunucunun eski bağı değiştirdiği doğrulanmadı | `GET /student/addCoach?code=` | `account_settings_screen.dart:936-944, 776-781, 326-330, 399-421`; `repository/profile_repository.dart:26-33` | 14.10 (koşullu) |
| Koç: koçluk kodu açıklaması | Çalışıyor (statik metin + oturumdaki `refCode`) | Yok (kod oturum verisinden) | `account_settings_screen.dart:47-49, 130-136, 519-561, 959-972` | 14.11 |

### B. Çalışıyor ve tasarımda karşılığı var (Tur 12 gerekmez)

| Özellik | Uçlar | Kanıt | Tasarımdaki yeri / not |
|---|---|---|---|
| Öğrenci Programım (liste, yeni, düzenle, Çantam) | `getMyWeeklies` (POST), `getAllMainSubjects`, `addNewProgram`, `updateProgram` | `repository/weekly_repository.dart:39-70`; `schedule_list_page.dart:51-65`; `add_topic_popup.dart:203-243` | 3.4–3.7. Not: Çantam = `getMyWeeklies.bagItems`; yalnız konu ve ders adı var, 3.5·3'teki "Son denemede…" satırının verisi yok |
| Ad, avatar, alan etiketi (üst bar, kişi kartı) | Oturum (`/student/login`, `/ajax/checkUser`) | `features/shared/presentation/provider/user_provider.dart:11-19` | 3.1 HomeBand, 9.1 ProfileSummary |
| Anasayfa ders şeridi (eksik sayılı) | `/ajax/getGeneralLessons`, `/student/getLessonsTotalMissing` | `features/home/presentation/provider/home_provider.dart:59-104` | 3.1 "Derslerin" |
| TYT/AYT/SOS-2 diyaloğu | `getLessonsTotalMissing` | `lesson_navigation_helper.dart:10-72, 108-203` | 7.1 ve 7.2 segmentleri |
| Menü kısayolları (Analiz, Denemelerim, Derslerim; koç Öğrencilerim, Görüşmelerim) | Hedef ekranların uçları | `home_menu_grid.dart:134-245` | Alt çubuk; ızgara kalkar |
| Koç Anasayfa öğrenci şeridi ve diyaloğu | `/coach/getMyStudents` | `home_students_cards.dart:230-318`; `home_provider.dart:90-95` | 10.1 → 10.4 (program düzenleme A'da) |
| Sözleşmeler | `/ajax/getLegalDocuments` | `auth_remote_data_source.dart:70-80`; `contracts_screen.dart:37-38, 52-83` | 9.7 (repository hatayı yutuyor: `auth_repository_impl.dart:150-153`) |
| Profil görüntüle ve düzenle | `/student/updateStudent` | `account_settings_screen.dart:361-372`; `profile_repository.dart:43-52` | 9.2 (kayıttan sonra UserProvider tazelenmeli) |
| Hesabımı Sil | `/ajax/deleteAccount` | `auth_remote_data_source.dart:82-92`; `account_settings_screen.dart:152-258` | 9.4 (silmeden sonra çerez temizliği eklenmeli) |
| Çıkış Yap | `/ajax/logout` | `auth_repository_impl.dart:157-178`; `account_screen.dart:13-83` | 9.1 |
| Bağlı koçu görme; kodla bağlanma; bağlantıyı kaldırma | `getStudentsCoach`, `addCoach`, `deleteCoach` (parametre gitmiyor) | `profile_repository.dart:19-41`; `account_settings_screen.dart:106-129, 399-431, 589-730` | 9.5 (`deleteCoach` düzeltilmeli) |
| Koçun kendi kodunu görmesi | Oturumdaki `refCode` | `account_settings_screen.dart:130-136` | 9.1·4 Kopyala/Paylaş (açıklama G'de) |
| Analizlerim · Genel | `getTotal`, `getLineChartData` | `analytics_view_provider.dart:21-62` | 6.1 (sabit `aimType = 2` ve "+18.2%" kalkar) |
| Denemelerim | `getMyMockExams` | `analytics_view_provider.dart:64-98` | 6.2 |
| Deneme favori yıldızı | Yok (yalnız yerel, kalıcı değil) | `my_test_results_card.dart:14-20, 107` | 6.2, cihazda kalıcı (D-25) |
| Deneme Detay Genel, Sorular, Konular, Kartlar | Satır yükü, `getMexamSubjectDetail`, `getMexamItemDetail` | `my_test_result_detail_screen.dart:67-70, 241-262` | 5.3–5.6 (`true = result['wrong']` hatası düzeltilmeli) |
| Soru Detay · Soru Analizi | `/student/getQuestion` | `question_detail_page.dart:48-104` | 5.7 |
| Koçun öğrenci analizi | `getTotal`, `getLineChartData`, `getMyMockExams` (`?studentId=`) | `coach_analytics_screen.dart:67-70`; `analysis_repository.dart:266-268` | 10.4 (deneme detayının alt isteklerine `studentId` eklenmeli: `my_test_result_detail_screen.dart:37`) |
| Öğrencilerim, Öğrenci Ekle (avatar hariç) | `getMyStudents`, `checkUsername`, `addNewStudent` | `my_students_screen.dart:31-51, 96-123`; `add_student_dialog.dart:62, 136` | 10.2, 10.3 |
| Görüşmelerim, yeni görüşme, notlar | `getInterviews`, `addNewInterview`, `addNewNote`, `editNote`, `deleteNote` | `interviews_screen.dart:101-106, 632`; `interview_detail_screen.dart:39, 323, 456` | 10.5, 10.6 |
| Derslerim, Ders Detayı, Konu Detayı | `getInfoCardsInfo`, `mainSubjects`, `getSubSubjects`, `getItems` | `my_card_page.dart:52`; `lesson_detail_page.dart:75`; `subject_detail_page.dart:39` | 7.1–7.3 (sahte sayılar kalkar) |
| Bilgi kartı desteleri (bugün erişilemiyor) | `getLessonInfoCards`, `learnedCard`, `addFavoriteMobil` | `my_card_page.dart:116-130` (çağrılmıyor); `my_card_info_card.dart:61, 201` | 8.1 geri getiriyor |
| Kavram Haritan (Matematik, Geometri) | Yok (web'i işaret eden metin) | `lesson_navigation_helper.dart:30-42` | D-5 "Web'de Aç" (URL gerekiyor) |

### C. Kaldırılanlar (sahte, yakında ya da ölü)

| Özellik | Durum | Kanıt | Neden |
|---|---|---|---|
| Programım arama ve tarih süzgeci | Sahte | `schedule_list_page.dart:99-102, 193-196`; `weekly_repository.dart:33-37` | Arama listeyi süzmüyor, süzgeç yalnız paneli kapatıyor. Arama 3.4'te çalışır hâliyle var |
| Anasayfa ay takvimi | Sahte | `home_provider.dart:20-40, 118-122`; `home_month_calendar.dart:61-69` | Hiçbir veriye bağlı değil |
| Kaynak Takibi (menü, diyalog, kart) | Yakında | `home_menu_grid.dart:226-240`; `analytics_view_provider.dart:470`; `section_placeholder.dart:13` | Yalnız yer tutucu |
| SmapCoach, koç "Analizler", Müfredat | Yakında | `home_menu_grid.dart:176-225` | Yalnız yakında diyaloğu |
| SmapLab, Gelen Kutusu | Yakında | `home_menu_grid.dart:158-175` | Arkasında uç ya da ekran yok |
| "Haber Ver" / "Kaydınız Alındı" | Sahte onay | `app_dialog.dart:105-167`; `home_menu_grid.dart:186-238` (boş callback'ler) | Hiçbir şey kaydedilmiyor |
| Analizlerim "Analiz" ve "Harita" sekmeleri | Yakında | `analytics_view_provider.dart:109-125`; `analytics_screen.dart:80-81` | İçerik yok |
| Oyunlar | Yalnız tanıtım görseli | `onboarding_page.dart:43` | Kodda yok |
| Soru Bankam, "Fotoğraf Çek", sahte "Tekrar Dene", Soru Detay kart yıldızı | Sahte | `question_detail_page.dart:106-140, 292, 400, 546, 577-590` | Uç yok; "Tekrar Dene" sabit veri gösteriyor |
| Ödeme ve Paketler, faturalar | Sahte | `current_plan_card.dart:25, 34`; `payment_settings_screen.dart:21, 30`; `payment_invoice_mock.dart:3-18` | Sabit plan, uydurma faturalar |
| Kayıtlı Kartlarım | Sahte | `saved_cards_screen.dart:15-33` | Sabit kartlar, boş düğmeler; mağaza politikası riski |
| IAP / paywall | Kod yok | `pubspec.yaml:30-64` | Taşınacak bir şey yok; gelir modeli ayrı karar |
| Bildirimlerdeki 6 anahtar ve "Değişiklikleri Kaydet" | Sahte | `notifications_screen.dart:13-18, 30-55, 65` | Değer kaydedilmiyor; 9.6 yeni özellik |
| Şifre değiştirme (eski) | Sahte başarı | `account_settings_screen.dart:749-774` | Uç yok; 9.3'te gerçek sürümü çizili (uç gelince) |
| Sözleşme onay kutusu ve göz ikonu | Ölü | `contract_card.dart:64-91, 98-121`; `contracts_screen.dart:127-129` | Ekranda görünmüyor |
| Ülke ve Şehir alanları | Ölü | `account_settings_screen.dart:978-1000` | Ekranda yok. Kayıt yalnız değişen alanları göndermeli (`:365-366`) |
| `_saveCoachingCode` | Ölü, sahte | `account_settings_screen.dart:563-587` | Çağrılmıyor; API'siz başarı metni |
| "Eksik Ders Konu Dağılımları" grafiği | Ölü | `general_tab.dart:22` | Yorum satırında |
| Eski WebView kabuğu | Ölü | `views/main_webview/main_inapp_webview.dart:9` (referans yok) | Hiçbir yerden açılmıyor |
| `views/` altındaki giriş ve onboarding kopyaları | Ölü | `main.dart:17, 21, 97-118` | Derlenen akışta yok |
| Ölü yardımcılar ve mock veri | Ölü | `my_card_dummy_data.dart`; `analytics_general_data.dart:24`; `analytics_view_provider.dart:396-445` | Kullanılmıyor (`/student/getLessons` ucu 6.1 süzgecinde yeniden kullanılacak) |

### D. Beklemede (sahibin cevabı)

| Özellik | Durum | Kanıt | Karar |
|---|---|---|---|
| Kişi kartında coin (`points`) ve ilerleme (`progress`) | İstemci sunucu alanını yalnız gösteriyor; hesaplayan ya da kazandıran kod yok; cihazda 0 ve %0 | `domain/models/user_model.dart:27-28`; `features/home/presentation/widgets/home_person_card.dart:30, 78-86, 104-106`; `tasarim-paketi/SMAP_Ekran_Goruntuleri.md:229, 251` | Şimdilik çizilmiyor (D-3). Sahibi "sunucu gerçekten hesaplıyor" derse, ne ölçtüğü öğrenilir ve Anasayfa dışında, Hesap'ta bir yer için ek brif yazılır |