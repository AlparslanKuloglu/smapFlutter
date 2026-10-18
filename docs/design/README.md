# SMAP · Tasarım (Claude Design çıktıları)

Uygulamanın görsel ve davranışsal tek hedefi bu klasördeki panolardır. Kod, panoya "pano X.Y kare N" diye atıf yapar (widget doc yorumları, görev tanımları; İngilizce yorumlarda "board X.Y", görev tanımlarında kısaca "X.Y·N" de geçer); o atıfın karşılığı burada.

## Klasörler

| Yol | İçerik | Ne zaman kullanılır |
|---|---|---|
| `kaynak/SMAP-00.html` … `SMAP-14.html` | Claude Design'ın sayfa sayfa dışa aktardığı **asıl** dosyalar (tek dosyalık HTML paketleri). Tarayıcıda açılır. `SMAP-13.html` akış panolarının ("SMAP · Flow") son hâli, `SMAP-11.html` Tur 12 ekleriyle (11.18 ve "Tur 12 Eki" panoları) son hâli. | Bir panonun aslını görmek, yeniden dışa aktarmak. |
| `panolar/png/SMAP-NN_<pano>.png` | Her panonun tam çözünürlüklü görüntüsü. | Ekran yazarken ve gözden geçirirken bakılacak görüntü. |
| `panolar/SMAP-NN/<pano>/text.txt` | Panonun bütün metni: başlık, kare açıklamaları, Bileşenler, Kural, Veri, Varsayımlar, Erişilebilirlik. | Metinleri **birebir** almak; kurallar ve veri notları. |
| `panolar/SMAP-NN/<pano>/board.html` (+ eski turlarda `styles.css`) | Panonun çizilmiş HTML'i ve CSS'i (fontlar çıkarılmış). | Kesin ölçü, renk, boşluk okumak (`width`, `padding`, `font-size`…). |
| `panolar/AKIS.md` | 13.x akış panolarının metne dökülmüş hâli: ekranlar arası geçişler. | Bir ekranın nereden açılıp nereye gittiğini bulmak. |
| `kil/1x/*.png` | Kil görsel seti (pano 1.25): `kitap` Türkçe · `hokka` Edebiyat ve koç görüşmeleri boş durumu · `sutun` Tarih · `kure` Coğrafya · `islemler` Matematik · `piramit` Geometri · `atom` Fizik · `erlenmeyer` Kimya · `yaprak` Biyoloji · `ampul` Programım boş durumu · `harita` Denemelerim boş durumu, tanıtım ve mağaza. 140 px, yalnız 1x; 2x/3x için tasarımcıdan 480 px asıllar istendi. | Uygulamaya varlık eklerken, boş durum ve "eksik kalmadı" ekranları. Uygulamadaki kopyaları `assets/illustrations/clay/` altında; ekranda `AppClay` (`ClayPicture`, `lib/shared/ui/illustrations/app_clay.dart`) çizer. Satırlarda kullanılmaz; L 160 pt, M 128 pt, salt süs (`ExcludeSemantics`). |
| `magaza/play-one-cikan/` | Google Play "öne çıkan görsel" varyantları (A–E, 1024×500 ve @2x) ve eski ekranlı açık varyant. | Mağaza kaydı hazırlanırken. |
| `magaza/eski-playstore/` | 2025'teki eski Play Store görselleri. | Yalnız karşılaştırma; hedef değil. |
| `tasarim-paketi/` | Claude Design'a gönderilen paket: brif (`SMAP_Claude_Design_Brifi.md`, Ek A–D; "D-n" atıflarının metni), ekran envanteri, eski uygulamanın 42 ekran görüntüsü (`ekranlar/`) ve anlatımı, eski görsel dilin denetimi, mağaza görselleri prompt'u ve cihaz çerçeveleri (`magaza/`). | Bir kararın gerekçesini, "D-n" ya da "Ek C" atfını bulmak. |
| `brifler/` | Claude Design'a verilen ilk prompt, Anasayfa revizyon prompt'u ve mağaza görselleri prompt'unun ilk sürümü. | Tarihçe; hedef değil. |

`SMAP-NN` → kanvas sayfası (sayfa numarası tur numarası değildir; ör. `02` Tur 7, `04` Tur 2 panolarını taşır): `00` akış haritası (Tur 10: 0.1 Uygulamanın Yolculuğu, 0.2 Bir Denemenin Yolculuğu, 0.3 Koçun Yolculuğu) · `01` temeller (renk, tipografi, bileşen kiti, logo) · `02` açılış, tanıtım, giriş, kayıt · `03` Anasayfa ve Programım · `04` kamera ve optik okuma · `05` sonuç anı ve Deneme Detay · `06` Analizlerim · `07` Derslerim ve konular · `08` Kart Destesi · `09` Hesap · `10` koç ekranları · `11` notlar ve teslim panoları (11.1–11.11 Tur 1–11 notları: ne değişti, varsayımlar, geliştirici notları; 11.12 token tablosu, 11.13 bileşenler, 11.14 ekran–bileşen eşlemesi, 11.15 hareket ve haptik, 11.16 varsayımlar, 11.17 ek akış ve onarımlar, 11.18 Tur 12 notları; Tur 12 ekleri 11.13 ek, 11.14 ek, 11.16 ek: T12.1–T12.30) · `12` mağaza görselleri · `13` akışlar · `14` Tur 12, geri gelen özellikler (14.1–14.12; sonunda akışlar 13.13 A–C ve 13.14 D–G).

## Öncelik (çelişki olursa)

1. Proje kararları: `docs/SMAP_Ana_Plan.md` (K1–K16) ve `docs/SMAP_UI_Rehberi_Duzeltmeler.md`.
2. Tur 12 panoları (`SMAP-14` ve `SMAP-11`'deki Tur 12 ekleri: 11.18, 11.13 ek, 11.14 ek, 11.16 ek / T12.1–T12.30): "Yerine geçtiği kare: 10.4·3" gibi etiketlerle eski kareleri geçersiz kılar; 11.16 ek'teki "Bu turla değişen varsayımlar" tablosu 11.16'daki eski varsayımların yerine geçer (11.13 ek ve 11.14 ek, 11.13 ile 11.14'ü değiştirmez, tamamlar).
3. Teslim panoları 11.12–11.16: daha önceki turların değerlerini geçersiz kılar (ör. token değerleri 11.12'den alınır).
4. Diğer panolar.

Eski uygulamanın ekran görüntüleri (`tasarim-paketi/ekranlar/`, `magaza/eski-playstore/`) ve brifler hedef **değildir**; panolar hedeftir.

## Okuma ipuçları

- Kare numarası soldan sağa: "pano 10.4 kare 3" = `SMAP-10_03-10-4-…png` içindeki üçüncü telefon.
- Ölçüler panoda pt cinsindendir (Flutter'da dp ile aynı). Renkler panoda hex olarak yazılır; kodda **asla** hex kullanılmaz, karşılığı `SmapColors` rolüdür (`docs/spec/01_tokenlar.md`).
- Panodaki örnek veriler (ad, net, tarih) uydurma değil, "Ek C" örnek veri setidir; testlerde aynı değerler kullanılır, uygulamada sahte veri gösterilmez.

## Yeni bir tur geldiğinde

1. Dışa aktarılan dosyayı `kaynak/` altına `SMAP-NN.html` adıyla koy (aynı sayfanın yeni sürümü gelirse eskisinin üstüne yaz; git geçmişi eskisini saklar).
2. Panolara çevir (Google Chrome gerekir, başka bağımlılık yok):

   ```bash
   python3 tool/design/html_to_boards.py docs/design/kaynak/SMAP-15.html
   ```

   Her pano için `panolar/png/SMAP-15_<pano>.png`, `panolar/SMAP-15/<pano>/board.html` ve `text.txt` üretilir. Tek panoyu yeniden çizmek için `--only 15.3`. Bu seçenek pano `<title>`'ının başındaki koda göre eşler. Başlığında kod olmayan panolar böyle seçilemez (ör. 11.12–11.16 ve 11.13 ek, 11.14 ek, 11.16 ek). Bu durumda betik hiçbir şey çizmeden ve hata vermeden çıkar; o panolar için bütün sayfayı yeniden çiz. Bir sayfanın yeni sürümünde önce o sayfanın eski `panolar/SMAP-NN/` klasörünü ve `png/SMAP-NN_*` dosyalarını sil; pano adları değişmiş olabilir.
3. Tasarım PDF olarak geldiyse: `tool/design/pdf_to_boards.sh docs/design/kaynak/SMAP-15.pdf` (poppler gerekir: `brew install poppler`). Her sayfa bir panodur. HTML gelirse HTML'i tercih et; ölçüler `board.html`'den okunur.
4. Görsel varlıklar (kil, ikon, mağaza) zip olarak gelirse açıp `kil/`, `magaza/` gibi klasörlere koy; uygulamada kullanılacak olanlar ayrıca `assets/` altına doğru çözünürlüklerle eklenir (kil: `assets/illustrations/clay/`; 2x/3x dosyaları yanındaki `2.0x/` ve `3.0x/` klasörlerine).
5. Yeni panoların hangi eski kareleri geçersiz kıldığını (`Yerine geçtiği kare`) `docs/DURUM.md`'ye yaz.
