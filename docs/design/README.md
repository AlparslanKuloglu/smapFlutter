# SMAP · Tasarım (Claude Design çıktıları)

Uygulamanın görsel ve davranışsal tek hedefi bu klasördeki panolardır. Kod, panoya "pano X.Y · kare N" diye atıf yapar (widget doc yorumları, görev tanımları); o atıfın karşılığı burada.

## Klasörler

| Yol | İçerik | Ne zaman kullanılır |
|---|---|---|
| `kaynak/SMAP-00.html` … `SMAP-13.html` | Claude Design'ın tur tur dışa aktardığı **asıl** dosyalar (tek dosyalık HTML paketleri). Tarayıcıda açılır. | Bir panonun aslını görmek, yeniden dışa aktarmak. |
| `kaynak/SMAP-14.pdf` | Tur 12 · Adım A (14.1–14.7), PDF olarak geldi. | Aynı. |
| `panolar/png/SMAP-NN_<pano>.png` | Her panonun tam çözünürlüklü görüntüsü (127 pano). | Ekran yazarken ve gözden geçirirken bakılacak görüntü. |
| `panolar/SMAP-NN/<pano>/text.txt` | Panonun bütün metni: başlık, kare açıklamaları, Bileşenler, Kural, Veri, Varsayımlar, Erişilebilirlik. | Metinleri **birebir** almak; kurallar ve veri notları. |
| `panolar/SMAP-NN/<pano>/board.html` + `styles.css` | Panonun HTML'i ve CSS'i (HTML gelen turlarda). | Kesin ölçü, renk, boşluk okumak (`width`, `padding`, `font-size`…). |
| `panolar/AKIS.md` | 13.x akış panolarının metne dökülmüş hâli: ekranlar arası geçişler. | Bir ekranın nereden açılıp nereye gittiğini bulmak. |

`SMAP-NN` → tur: `00` kapak ve içindekiler · `01` temeller (renk, tipografi, bileşen kiti, logo) · `02` açılış, tanıtım, giriş, kayıt · `03` Anasayfa ve Programım · `04` kamera ve optik okuma · `05` sonuç anı ve Deneme Detay · `06` Analizlerim · `07` Derslerim ve konular · `08` Kart Destesi · `09` Hesap · `10` koç ekranları · `11` teslim panoları (11.12 token tablosu, 11.13 bileşenler, 11.14 ekran–bileşen eşlemesi, 11.15 hareket ve haptik, 11.16 varsayımlar) · `12` mağaza görselleri · `13` akışlar · `14` Tur 12, geri gelen özellikler.

## Öncelik (çelişki olursa)

1. Proje kararları: `docs/SMAP_Ana_Plan.md` (K1–K16) ve `docs/SMAP_UI_Rehberi_Duzeltmeler.md`.
2. Tur 12 panoları (`SMAP-14`): "Yerine geçtiği kare: 10.4·3" gibi etiketlerle eski kareleri geçersiz kılar.
3. Teslim panoları 11.12–11.16: daha önceki turların değerlerini geçersiz kılar (ör. token değerleri 11.12'den alınır).
4. Diğer panolar.

Eski uygulamanın ekran görüntüleri ve önceki brifler hedef **değildir**.

## Okuma ipuçları

- Kare numarası soldan sağa: "pano 10.4 · kare 3" = `SMAP-10_03-10-4-…png` içindeki üçüncü telefon.
- Ölçüler panoda pt cinsindendir (Flutter'da dp ile aynı). Renkler panoda hex olarak yazılır; kodda **asla** hex kullanılmaz, karşılığı `SmapColors` rolüdür (`docs/spec/01_tokenlar.md`).
- Panodaki örnek veriler (ad, net, tarih) uydurma değil, "Ek C" örnek veri setidir; testlerde aynı değerler kullanılır, uygulamada sahte veri gösterilmez.

## Yeni bir tur geldiğinde

1. Dışa aktarılan dosyayı `kaynak/` altına `SMAP-NN.html` ya da `SMAP-NN.pdf` adıyla koy.
2. PDF ise panolara çevir: `tool/design/pdf_to_boards.sh docs/design/kaynak/SMAP-15.pdf` (poppler gerekir: `brew install poppler`). Her sayfa bir panodur; `panolar/png/` ve `panolar/SMAP-15/<pano>/text.txt` üretilir.
3. HTML paketi ise tarayıcıda açıp panoları tek tek PNG olarak dışa aktar (Claude Design'dan PNG/PDF dışa aktarımı da olur) ve metni `text.txt` olarak yanına koy; ya da PDF olarak dışa aktarıp 2. adımı kullan.
4. Yeni panoların hangi eski kareleri geçersiz kıldığını (`Yerine geçtiği kare`) `docs/DURUM.md`'ye yaz.
