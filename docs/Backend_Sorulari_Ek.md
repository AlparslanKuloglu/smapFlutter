# SMAP · Backend soruları (ek, uygulama sırasında çıkanlar)

Ana liste: `spec/SMAP_Flutter_Spec.md` §6.3 (41 madde) ve `SMAP_Ana_Plan.md` §5. Bu belge, ekranlar yazılırken ortaya çıkan ve o listede olmayan soruları ekler. Uygulama bunların hiçbirinde sahte veri göstermiyor; cevap gelene kadar ilgili bölüm ya gizli (bayrak) ya da gerçek hata durumunda.

## Yayını engelleyenler (önce bunlar)

| # | Konu | Neden önemli | Bugün uygulama ne yapıyor |
|---|---|---|---|
| Y1 | Optik okuma sunucusunun gerçek adresi (§6.3 #1) | Eski kodda da adres sahte bir yer tutucuydu (`wfdsvfsdg.com`); okuma hiçbir sürümde gerçek sunucuya gitmiyordu. | Adres verilmezse API sunucusuna gidiyor ve "Formu bulamadık" hatası çıkıyor. Adres derlemede `--dart-define=OMR_BASE_URL=…` ile verilebilir. |
| Y2 | `answersArray` biçimi | Okunan cevapların ekranda gösterilmesi ve düzeltilmesi buna bağlı. | 4 sütun × 40 soru, her hücre A–E ya da boş için `null` varsayıldı. Farklıysa akış "Formu bulamadık"a düşer. Örnek bir gerçek yanıt yeterli. |
| Y3 | Koç oturumu `studentId` ile öğrenci verisini okuyabiliyor mu (§6.3 #33) | Koçun Öğrenci Profili (Analiz, Denemeler, Program, Deneme Detay) buna bağlı. | Uçlar `?studentId=` ile çağrılıyor: `getTotal`, `getLineChartData`, `getMyMockExams`, `getMexamSubjectDetail`, `getMexamItemDetail`, `getMyWeeklies`, `getAllMainSubjects`. Kabul edilmezse bölüm hata gösteriyor. |
| Y4 | Koç, öğrencisi adına program yazabiliyor mu | Tur 12 A: koç öğrencinin programını kurup düzenliyor (eski uygulamada vardı). | `addNewProgram` ve `updateProgram` `studentId` ile gönderiliyor. Sunucu bunu öğrencinin hesabına işlemiyorsa yazma bayrakla kapatılmalı. |

| Y5 | Okuma isteklerindeki `user` alanı (gizlilik) | `opticimage` ve `examrequest`, eski uygulamanın biçimi korunduğu için oturumdaki kullanıcının bütün belgesini (ad, e-posta, telefon, okul no vb.) taşıyor. | Okuma servisi yalnız `_id` (ya da oturum çerezi) ile yetinebiliyorsa gövde küçültülmeli; KVKK açısından gereksiz kişisel veri gönderilmemeli. |

## Görüşmeler ve tarih/saat

| # | Soru | Bağlam |
|---|---|---|
| G1 | Görüşme tarihi hangi saat diliminde saklanıyor ve dönüyor? | Uygulama eski uygulama gibi tarihi dilimsiz yerel saat (`2026-10-14T16:00:00`) olarak gönderiyor, dönen saati de çevirmeden gösteriyor. Sunucu UTC'ye çevirip `Z` ile döndürüyorsa saatler 3 saat kayar. |
| G2 | `getInterviews` `filter.dates` günü hangi saat diliminde yorumluyor? "Önümüzdeki N gün" için doğrudan bir parametre var mı? | Koç Anasayfa'daki "Yaklaşan görüşmeler" 8 günlük tarih listesiyle istiyor. |
| G3 | Tek bir görüşmeyi kimliğiyle getiren uç var mı? | Yok; Görüşme Detayı görüşmeyi tarih aralığında arayıp bulamazsa bütün listeyi sayfa sayfa geziyor. |
| G4 | `addNewInterview` not alanı alıyor mu, yeni görüşmeyi yanıtta her zaman döndürüyor mu? | Not ikinci istekle (`addNewNote`) ekleniyor; yanıtta görüşme yoksa not eklenemiyor ve kullanıcıya söyleniyor. |
| G5 | Sayfa boyutu 8 sabit mi, daha büyük `perPage` kabul ediliyor mu? | Görüşme aramasında eksik sayfalar sırayla çekiliyor. |

## Koç ve öğrenci listesi

| # | Soru | Bağlam |
|---|---|---|
| K1 | Koçun eklediği öğrencide `name` yalnız ad, `surname` ayrı mı geliyor; bu bütün kayıt yollarında aynı mı? | Ekranlar adı `name + surname` olarak birleştiriyor. |
| K2 | Öğrenci listesinde sunucuda arama var mı (50'den fazla öğrenci)? | Arama şimdilik yalnız istemcide. |
| K3 | Koçluk kodunun resmî kaynağı `refCode` mu, biçimi `AAAA-0000` mı? | Kod kartı `refCode`'u gösteriyor; yoksa kart çizilmiyor. |
| K4 | Koçun "Okut" düğmesi: öğrenci seçme (§6.3 #34) gelene kadar ne yapmalı? | Eski uygulama gibi okuma koçun kendi hesabına gidiyor. Ürün kararı: düğme gizlensin mi? |

## Deneme ve kartlar

| # | Soru | Bağlam |
|---|---|---|
| D1 | Denemeden eklenen kartlar listelenebiliyor mu? | Deneme Detay › Kartlar yalnız sayıyı gösterebiliyor (`getTotalInfoCard`). |
| D2 | Ham puan ve ham puan sırası (Tur 12 B) AYT'de hangi puan türüne ait? | Deneme Detay'da öğrencinin alanına göre gösteriliyor. |

## Ürün kararları (backend değil)

- Kullanılmayan 90 görselin silinmesi (14,4 MB): `gorevler/fin3_kullanilmayan_gorseller.txt`.
- Kil illüstrasyonların (Harita, Ampul, Hokka) 2x/3x dosyaları; şu an 140 px ve ekranda bulanık.
- Programım hafta ızgarası blokları panoda 36 dp, erişilebilirlik kuralının (48 dp) altında: dokunma alanı görünmez biçimde genişletilsin mi?
- Uygulama kimliği (`com.smap.smap`), imza, sürüm numarası, destek e-postası, App Store kimliği.
