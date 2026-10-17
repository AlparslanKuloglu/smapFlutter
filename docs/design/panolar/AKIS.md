# SMAP — Ekran Akışı (SMAP-13'ten)

Kaynak: `docs/design/panolar/SMAP-13/*` (12 akış panosu, 181 ekran) ve Tur 12 akışları `SMAP-14/12-13-13-…`, `SMAP-14/13-13-14-…`, PNG'ler `docs/design/panolar/png/SMAP-13_*.png`.
Gösterim: `→ [dokunulan yer]` dokunuşla geçiş, `⇢` kendiliğinden geçiş. `(2.3·1)` = kaynak pano 2.3, kare 1.

## 13.1 İlk açılış ve kayıt
Açılış (2.1·1) ⇢ Tanıtım 1 · okut (2.1·2) → [Devam Et] Tanıtım 2 · analiz (2.1·3) → [Devam Et] Tanıtım 3 · eksikler (2.1·4) → [Başla]
Rol (2.2·1) → [Öğrenciyim, Devam Et] Sınıf ve alan (2.2·2; 9–10. sınıfta alan yok: 2.2·3) → [Devam Et] Kamera ön açıklaması (2.2·4) → [İzin Ver | Sonra] Hoş geldin (2.2·5)
- Rol = "Öğrenci Koçuyum" → sınıf sorulmaz, doğrudan kamera ön açıklaması.
- Hoş geldin → [Giriş Yap] 13.2 · → [Kayıt Ol] Kayıt üst (2.5·1; alan hataları 2.6·1) → kaydır → Kayıt alt (2.5·2; gönderim hataları 2.6·2, metinler yüklenemedi 2.6·3, 10. sınıf 2.6·4, koç kaydı alt 2.5·3) → [Kayıt Ol] Anasayfa · yeni kullanıcı (3.1·3)

## 13.2 Giriş ve şifre
Giriş (2.3·1; gönderiliyor 2.3·2, hatalı bilgi 2.3·3, Apple/Google 2.3·4) → [Giriş Yap] öğrenci → 13.3, koç → 13.11 (rol hesaptan okunur)
→ [Şifremi Unuttum] E-posta (2.4·1) → [Kod Gönder] 6 haneli kod (2.4·2) ⇢ kod tamamlanınca Yeni şifre (2.4·3) → [Şifreyi Güncelle] Güncellendi (2.4·4) → [Giriş Yap] Giriş

## 13.3 Anasayfa ve Programım (alt çubuk · Anasayfa)
Anasayfa (3.1·1; kaydırılmış 3.1·2, iskelet 3.2·1, bölüm hatası 3.2·2, çevrimdışı 3.2·3, metin %130 3.2·4, koyu 3.3·1) → [Programım]
Programım liste (3.4·1; arama sonuç yok 3.4·2, boş 3.7·1, iskelet 3.7·2, hata 3.7·3, çevrimdışı 3.7·4) → [Yeni Program]
Yeni program: Günler (3.5·1) → [Devam Et] Izgara (3.5·2) → [boş saate dokun] Konu seç (3.5·3) → [Ekle, Devam Et] Ad ve motto (3.5·4) → [Programı Kaydet] Program · gün (3.4·3) → [Hafta] Program · hafta (3.4·4; koyu 3.8·1)
→ [Düzenle] Düzenleme modu (3.6·1) → [Günü Sıfırla] onay (3.6·2) → Gün sıfırlandı (3.6·3) · [Programı İptal Et] onay (3.6·4)

## 13.4 Deneme okutma (alt çubuk · Okut, her sekmede)
Kamera izni (4.1·1, yalnız ilk sefer; reddedildi 4.1·2) → [Kameraya İzin Ver] Öğretici (4.2·1, yalnız ilk sefer, sonra "?" ile) → [Anladım]
Çekim · aranıyor (4.3·1) ⇢ form bulununca Çekim · bulundu (4.3·2; kamera açılamadı 4.10·4) → [Fotoğraf çek]
Köşeler · ilk kez (4.4·1) → [köşeyi sürükle] Sürükleniyor (4.4·2) → [Devam]
Gönderim hazırlanıyor (4.5·1) ⇢ Gönderiliyor %64 (4.5·2; koyu 4.6·1) ⇢ Okunuyor (4.5·3; gönderilemedi 4.5·4 / koyu 4.6·2, çevrimdışı planlı 4.10·3, okuma geçici kapalı 4.10·2, form bulunamadı 4.10·1)
⇢ okuma bitince Form Kontrol (4.7·1) → [Düzelt] Cevap düzelt (4.7·2) → [Düzeltmeyi Ekle] İki düzeltme (4.7·3) → [Cevapları Onayla] Gönderiliyor (4.7·4; görüntü yükleniyor 4.8·1, gönderilemedi 4.8·2)
- Deneme tanınmazsa → 13.5
⇢ deneme tanınınca Sonuç anı · AYT (5.1·1; TYT eksik veriyle 5.1·2, AYT koyu 5.1·3) ⇢ ilk okumada Bildirim izni (5.2·1) → [Detaylı Analiz] 13.6

## 13.5 Deneme bulunamadı
Talep formu (4.9·1) → [Analizimi Hazırlayın] Doğrulama (4.9·2) → Onay (4.9·3) → [Talebi Gönder] Talep alındı (4.9·4) → Anasayfa

## 13.6 Deneme detay (Sonuç anı · Denemelerim · Anasayfa "Analizi Gör")
Genel AYT (5.3·1; TYT puansız 5.3·3, iskelet 5.8·1, ders verisi yok 5.8·2, hata 5.8·3, çevrimdışı 5.8·4, koyu 5.9·1) → kaydır (5.3·2)
→ [Sorular] Tümü (5.4·1; koyu 5.9·2) → [Yanlışlar] (5.4·2; boşlar boş 5.4·3) → [soru hücresi] Soru Detay (5.7·1; doğru, açıklamasız 5.7·2)
→ [Konular] (5.5·1; koyu 5.10·1) → [Kartlar] (5.6·1) → [Bu Konuyu Çalış] 13.8 · [Kartları Çalış] 13.9

## 13.7 Analizlerim (alt çubuk)
Genel TYT (6.1·1; AYT eksik veri 6.1·2, iskelet 6.3·1, tek deneme 6.3·2, hata 6.3·3, çevrimdışı 6.3·4, koyu 6.4·1) → [TYT · Genel çipi] Süzgeç (6.1·3) → [Uygula] → Denemelerim (6.2·1; boş 6.2·3) → [Süz ve Sırala] (6.2·2) → [satır] 13.6

## 13.8 Derslerim ve konular (alt çubuk)
Derslerim TYT (7.1·1; web'de sheet'i 7.1·3, iskelet 7.5·1, çevrimdışı 7.5·4) → [ders] Ders detayı (7.2·1; Tarih SOS-2 7.2·3, süzgeç boş 7.5·2) → [Eksiklerim (31)] süzgeç (7.2·2) → [konu] Konu detayı (7.3·1; yüklenemedi 7.5·3, koyu 7.6·1) → kaydır (7.3·2) → [Kartı Aç] Kart sheet'i (7.3·3) → 13.9
AYT: Derslerim AYT (7.1·2) → [Türk Dili ve Edebiyatı] Yazar ve Eserler (7.4·1) → [yazar] Yazar sheet'i (7.4·2)

## 13.9 Bilgi kartları (Ders detayı · Kartlarım | Deneme Detay · Kartları Çalış)
Eksiklerim (8.1·1; koyu 8.2·1) → [Öğrendim] ilk onay (8.1·2) → [Öğrendim] Kart taşındı (8.1·3, geri alınabilir) ⇢ son kart da öğrenilince Eksiklerim boş (8.1·4). Desteler: Eksiklerim, Bildiklerim, Favorilerim.

## 13.10 Hesap (alt çubuk)
Hesap (9.1·1; kaydırılmış 9.1·2) → [Çıkış Yap] onay (9.1·3) → 13.1 Hoş geldin
Profil (9.2·1) → [Düzenle] (9.2·2) → [Avatarı Değiştir] (9.2·3) → [Bu Avatarı Kullan / sınıf alanı] Sınıf sheet'i (9.2·4)
Şifre (9.3·1; mevcut hatalı 9.3·2) → [Şifreyi Güncelle] (9.3·3)
Koçluk: Koçun var (9.5·1) → [Bağlantıyı Kaldır] onay (9.5·2) → Koçun yok (9.5·3) → [Koçluk Kodu Nedir?] (9.5·4)
Bildirimler (9.6·1; sistem izni kapalı 9.6·2) → [sessiz saat] Saat seçici (9.6·3)
Sözleşmeler (9.7·1) → [Kullanım Koşulları] Okuma (9.7·2)
Hesabı sil (Profil en altı): Giriş noktası (9.4·1) → Açıklama (9.4·2) → [Hesabımı Sil] Tehlikeli onay (9.4·3) → Siliniyor (9.4·4) ⇢ Silindi (9.4·5) → 13.1
- **Final tasarımda Ödeme/Paketler, Kayıtlı Kartlar ve fatura ekranı yok.**

## 13.11 Koç (giriş · koç hesabı)
Koç Anasayfa (10.1·1; dikkat gerektirenler 10.1·2, öğrenci yok 10.1·3, iskelet 10.1·4) → [Öğrencilerim] (10.2·1; arama sonuç yok 10.2·3, öğrenci yok 10.2·4) → [ara] Arama I/ı/İ/i (10.2·2) → [öğrenci] Öğrenci profili · Analiz (10.4·1) → [Program] düzenlenebilir program (Tur 12: 14.1, bkz. 13.13; 10.4·3 yalnız bayrak kapalıyken) · [Denemeler] (10.4·2) → [satır] Deneme Detay · koç bağlamı (10.4·4)
Öğrenci ekle (Öğrencilerim + | Koç Anasayfa): Form, avatarlı (14.8·1; Tur 12, bkz. 13.14) → kaydır Kod kartı (10.3·2) → [Öğrenciyi Kaydet] Eklendi (10.3·3) → Öğrencilerim
Görüşmelerim (10.5·1; görüşme yok 10.5·4) → [Yeni görüşme] (10.5·2) → [Kaydet] Detay (10.5·3) → [Not Ekle] (10.6·1) → [Düzenle] (10.6·2) → [Sil] onay (10.6·3) → Silindi (10.6·4)
Hesap · koç (14.11·1): [Koçluk kodun] Kod sheet'i (14.11·2) → [Kopyala | Paylaş]; Tur 12, bkz. 13.14
- Öğrenci ekranları koça aynı bileşenlerle + öğrenci adını taşıyan bağlam şeridiyle gelir.

## 13.12 Genel ekranlar (her an)
Zorunlu güncelleme (2.7·1) · Oturum sona erdi (2.7·2) · Bakım (2.7·3) · Bilinmeyen rol (2.7·4)

## 13.13 Tur 12 · Koç programı, puan kartı, Edebiyat (SMAP-14)
A · Programı görmek ve düzenlemek (13.11 Öğrenci profili · Program): Program sekmesi (14.1·1; programı yok 14.1·4, iskelet 14.3·1, hata 14.3·2, çevrimdışı 14.3·3, koyu 14.3·4) → [Düzenle] Düzenleme modu (14.1·3) → [Bitti] Program sekmesi
A · Programlar ve yeni program (Program sekmesi · Programlar satırı): Programlar (14.1·2) → [Yeni Program] Günler (14.2·1) → [Devam Et] Izgara (14.2·2) → [boş saate dokun] Konu seç · Çanta (14.2·3; öğrencide Çantam 14.2·6) → [Ekle, Devam Et] Ad ve motto (14.2·4) → [Programı Kaydet] Kaydedildi (14.2·5)
B · Puan kartında ham puan (13.6 Deneme Detay · Genel): Genel · AYT (14.4·1; TYT 14.4·2, koyu 14.4·3, iskelet 14.4·4, koç bağlamı 14.4·5)
C · Edebiyat (13.8 Derslerim › Türk Dili ve Edebiyatı): Dönemler (14.5·1; iskelet 14.7·1) → [dönem satırı] Dönem detayı (14.5·2; akordeon yükleniyor 14.5·3, bölüm hatası 14.7·2) → [yazar satırı] Yazar sheet'i (14.6·1; durum bilinmiyor 14.6·3, çevrimdışı 14.7·3, koyu 14.7·4) → [Öğrendim] Öğrendim sonrası (14.6·2)

## 13.14 Tur 12 · Öğrenci ekleme, e-posta, koç ve kod (SMAP-14)
D · Öğrenci eklerken avatar (13.11 Öğrencilerim · +): Form · avatar (14.8·1; çevrimdışı 14.8·4, kaydetme hatası 14.8·5, koyu 14.12·1) → [Öğrenciyi Kaydet] Eklendi (14.8·2) → [Tamam] Listede (14.8·3)
E · E-posta değişikliği (13.10 Hesap › Profil › Düzenle): Yeni adres (14.9·1; geçersiz adres 14.9·2, çevrimdışı 14.9·4, kaydetme hatası 14.9·5, koyu 14.12·2) → [Kaydet] Kaydedildi (14.9·3)
F · Koçu değiştirmek (13.10 Hesap › Koçluk): Koçun var (14.10·1; çevrimdışı 14.10·6, koyu 14.12·3) → [Koçu Değiştir] Yeni kod (14.10·2; kod bulunamadı 14.10·3) → [Koçu Değiştir] Değiştiriliyor (14.10·4) ⇢ Yeni koç (14.10·5)
G · Koçun koçluk kodu (13.11 Koç · Hesap): Hesap · Koçluk kodun (14.11·1) → [satıra dokun] Kod sheet'i (14.11·2; yükleniyor 14.11·4, hata 14.11·5, çevrimdışı 14.11·6, koyu 14.12·4) → [Kopyala] Kopyalandı (14.11·3)
