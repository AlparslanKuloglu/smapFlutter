# SMAP · Çalışma modeli

Bu uygulama 2026 Ekim'inde eski kod tabanından ekran ekran yeniden yazıldı. İş, bir **koordinatörün** yönettiği, birbirine dokunmayan küçük görevlere bölündü; görevleri **uygulayıcılar** (çoğunlukla yapay zekâ ajanları, Claude) yazdı; koordinatör her sonucu kendisi inceleyip birleştirdi. Bu belge o modeli anlatır: aynı kaliteyle devam etmek için izlenecek yol budur. Teknik kurallar `AGENTS.md`'de, mimari ve tarifler `docs/DEVELOPING.md`'de.

---

## 1. Akış (bir iş nasıl yapılır)

```
Tasarım / ihtiyaç ──► Görev tanımı ──► Çalışma ağacı ──► Uygulama ──► Koordinatör incelemesi ──► Entegrasyon ──► Simülatör doğrulaması ──► Durum panosu
   (docs/design)       (docs/gorevler)   (tool/wt.sh)     (task/<id>)    (§5 kontrol listesi)       (redesign/main)    (pano ile yan yana)        (docs/DURUM.md)
```

Küçük bir düzeltme için bu adımların hepsi gerekmez; bir ekranı, bir özelliği ya da birden çok kişinin/ajanın paralel çalıştığı her işi bu yolla yapın.

## 2. Roller

| Rol | Ne yapar | Ne yapmaz |
|---|---|---|
| **Koordinatör** (kıdemli geliştirici ya da üst ajan) | İşi görevlere böler, görev tanımını yazar, çalışma ağacını açar, sonucu **kendisi** inceler, ortak dosyaları bağlar, birleştirir, simülatörde doğrular, durum panosunu günceller. | İncelemeyi başkasına devretmez; incelemeden birleştirmez. |
| **Uygulayıcı** (geliştirici ya da ajan) | Yalnız kendi çalışma ağacında ve **kendine verilen dosyalarda** çalışır; testleri yazar; commit eder; rapor yazar. | Ortak dosyalara commit atmaz; push etmez; başka görevin dosyasına dokunmaz. |

Ajanlarla çalışırken önerilen düzen: koordinatör güçlü bir model (bu projede Claude Opus), uygulayıcılar hızlı ve yetenekli bir model (bu projede Claude Sonnet, yüksek düşünme). Her ajana tek görev, tek çalışma ağacı.

## 3. Görev tanımı

Her görev `docs/gorevler/<id>.md` dosyasında yazılır (geçmiş örnekler: `docs/history/gorevler/`). Ortak giriş metni `docs/history/gorevler/_ortak.md`'dedir: çalışma dizini, önce okunacaklar, hazır olanlar, route kuralı, ortak dosyalar, yasaklar, test ve doğrulama, rapor biçimi. Bir görev tanımı şu bölümlerden oluşur:

1. **Başlık ve pano atfı:** `Görev T12C · Edebiyat … — panolar 14.5, 14.6, 14.7. 7.4·1 ve 7.4·2'nin yerine geçer.`
2. **Ortak metin** (`_ortak.md`, `{ID}` doldurulmuş).
3. **SAHİP OLDUĞUN dosyalar:** glob listesi. Uygulayıcı bunların dışına yazmaz. Başka bir görevin dosyasına ihtiyaç varsa "DAR izin" açıkça yazılır ("yalnız `student` parametresi eklemek için").
4. **Pano kuralları / bilinen farklar:** her kare için beklenen metin, bileşen, davranış; panodaki Türkçe metinler birebir.
5. **Veri:** kullanılacak uçlar, alanlar, bilinen backend açıkları ve bayraklar.
6. **Test ve doğrulama:** hangi VM/saf mantık testleri; `flutter analyze` 0 sorun, `flutter test`, `tool/ui_rules.sh`, iOS simülatör build'i.
7. **Rapor biçimi:** değişen dosyalar, pano karşılaştırması (görüntü yollarıyla), kararlar/varsayımlar, "Koordinatöre notlar" (route, DI, ARB, galeri, pubspec ihtiyaçları), açık sorular.

İyi bir görev **tek bir özellik alanına** düşer ve sahip olduğu dosyalar aynı anda çalışan başka bir görevle kesişmez. Boyut: bir ajanın 30–90 dakikada bitirebileceği kadar (bir ekran ya da bir ekran ailesi).

## 4. Çalışma ağacı ve dallar

```bash
tool/wt.sh t12c            # ../smapFlutter-wt/t12c, dal task/t12c, taban redesign/main
tool/wt.sh t15a main       # tabanı başka bir dal olan görev
```

- Entegrasyon dalı: `redesign/main` (teslimde ana dala alınır; sonra `WT_BASE` ya da ikinci argümanla değiştirin).
- Uygulayıcı yalnız kendi dalına commit atar (Conventional Commits, Türkçe özet; ör. `feat(coach): …`).
- Koordinatör birleştirirken `git merge --no-ff task/<id>` kullanır; dal ve çalışma ağacı birleştirmeden sonra silinir (`git worktree remove`, `git branch -D`).

## 5. Ortak dosyalar (yalnız koordinatör)

Bu dosyalar birden çok görevin kesiştiği yerlerdir; paralel commit'ler çakışır ya da birbirini bozar:

- `pubspec.yaml`, `pubspec.lock`, `build.yaml`, `analysis_options.yaml`, `l10n.yaml`
- `lib/app/router/app_router.dart` (+ üretilen `app_router.gr.dart`), `lib/app/router/routes/shell_routes.dart`, `lib/app/shell/*_shell_view.dart`
- `lib/dependency_injection/injection_container.dart`
- `lib/l10n/app_tr.arb` ve üretilen `lib/l10n/app_localizations*.dart` (uygulayıcı yalnız `lib/l10n/arb/<feature>_tr.arb` yazar)
- `lib/gen/assets.gen.dart`, `lib/features/debug/gallery_registry.dart`, `lib/core/services/device_preferences.dart`
- Platform dosyaları (`Info.plist`, `AndroidManifest.xml`, `build.gradle*`), görev açıkça sahiplenmedikçe.

Uygulayıcı bunlara ihtiyaç duyarsa **yerelde dener, geri alır** ve raporundaki "Koordinatöre notlar"a yazar (gerekiyorsa bir patch dosyası bırakır). Feature'lar kendi listelerini sunar: `<f>_routes.dart`, `<f>_module.dart`, `lib/l10n/arb/<f>_tr.arb`; koordinatör bunları ortak dosyalara bağlar.

## 6. Koordinatör inceleme protokolü

Her görev için, birleştirmeden önce, sırayla:

1. **Kapsam:** `git diff --stat redesign/main...task/<id>` ve `--name-status`. Yalnız sahip olunan dosyalar mı? Silinenler gerçekten ölü mü (`dart run tool/unreachable_files.dart`, `grep`)?
2. **Kural taraması:** `tool/ui_rules.sh` (ham renk, `TextStyle(`, Material ikon, diyalog, `Navigator.push`, `print(`) ve dosya boyları (view ≤ 250, part ≤ 300, VM ≤ 500, sunumda hiçbir dosya > 400 satır).
3. **Kodu okumak:** özellikle VM'ler, navigasyon, sheet'ler, veri eşlemeleri, tarih/saat dilimi, hata ve çevrimdışı yolları. Bu projede inceleme sırasında yakalanan gerçek hatalar için §9'a bakın.
4. **Birleştir ve bağla:** `git merge --no-ff`, ortak dosyalar (route listeleri, DI, ARB), sonra `dart run tool/merge_arb.dart && flutter gen-l10n && dart run build_runner build -d`.
5. **Çalıştır:** `flutter analyze` (0 sorun), `flutter test`, `tool/ui_rules.sh`, `flutter build ios --simulator --debug`.
6. **Gözle doğrula:** simülatörde ekranı aç (oturum yoksa `--dart-define=SHELL_PREVIEW=student|coach`), pano PNG'siyle yan yana karşılaştır: açık, koyu (`THEME_MODE=dark`), büyük metin (≈1,35), boş/hata/iskelet durumları.
7. **Karar:** birleştir · düzeltme listesiyle aynı uygulayıcıya iade (en çok iki tur; sonra koordinatör bitirir) · geri al.
8. **Kapat:** `docs/DURUM.md` satırını güncelle (commit, not, açık sorular), çalışma ağacını sil.

## 7. Paralellik kuralları

- Aynı anda çalışan görevlerin sahip olduğu dosyalar **kesişmez**. Kesişiyorsa görevleri sıraya koyun.
- Ortak kit (`lib/shared/ui/**`) ve tema (`lib/core/theme/**`) tek bir görevin sahipliğindedir; diğerleri kit sorunu bulursa düzeltmez, raporlar.
- Önce veri ve mantık (DTO, repository, saf mantık + test), sonra ViewModel (+ test), sonra görünüm.
- Bir görev başka bir görevin ekranına bağlanacaksa (henüz yoksa), geçici bağlantı `lib/features/legacy/legacy_links_<id>.dart` gibi tek bir dosyada tutulur ve hedef görev birleşince silinir. (Bu projede bütün geçici köprüler kapandı.)

## 8. Simülatör, hesap ve güvenlik kuralları

- **Gerçek oturumun bulunduğu simülatöre ajanlar dokunmaz.** Her ajan kendi simülatörünü oluşturur (`xcrun simctl create "SMAP-<ID>" "iPhone 16 Pro"`), işi bitince yalnız onu siler. Paylaşılan simülatörde ajanlar birbirinin build'ini ezer ve dokunuşları karışır.
- Simülatörde uygulama **silinmez** (oturum gider); yalnız üstüne kurulur. İş bitince dart-define'sız temiz build bırakılır.
- **Canlı sunucuda hesapla giriş yapılmaz, yazan istek atılmaz.** Veri dolu hâli görmek için geçici sahte repository/ağ adaptörü kullanılır ve commit edilmez. Optik okuma için `OMR_BASE_URL` verilmezse fotoğraf canlı API sunucusuna gider: test ederken yerel bir sahte sunucu kullanın.
- Kimlik bilgisi dosyaları (`*.jks`, `*.keystore`, `key.properties`, `google-services*.json`, `GoogleService-Info.plist`, `.env*`, `*.p8`) açılmaz, içerikleri hiçbir yere yazılmaz.
- Push ve PR yalnız sorumlunun onayıyla.

## 9. Bu projede öğrenilenler (aynı hataya düşmeyin)

| Ne oldu | Neden | Kural |
|---|---|---|
| Okutma akışında X ve sistem Geri uygulamayı **dondurdu**. | Her aşama Geri'yi `PopScope(canPop: false)` ile tutup kapatma fonksiyonunu çağırıyordu; kapatma `maybePop()` ile aynı `PopScope`'a yeniden soruyordu: sonsuz döngü. | `PopScope` içinden çağrılan kapatma `router.pop()` (zorla) kullanır, `maybePop()` değil. Regresyon testi: `test/features/scan/presentation/router_scan_navigator_test.dart`. |
| Sekme ekranlarında son satır alt çubuğun altında kaldı. | Kabuktaki `Scaffold` gövdenin `viewPadding.bottom`'unu sıfırlıyor, `AppBottomBar.heightOf` 34 pt eksik hesaplıyordu. | Düzeltme kabukta (`shell_tab_stack.dart`); ekranlar her zaman `AppBottomBar.heightOf(context)` kullanır, kendi hesabını yapmaz. |
| Aynı görüşme iki ekranda 3 saat farklı göründü. | Bir ekran `toLocal()`, diğeri sunucu saatini olduğu gibi gösteriyordu. | Görüşme saatleri tek kuralla okunur (`MeetingMoment.wallClock`); sunucuya dilimsiz yerel saat gider (eski uygulamayla aynı). |
| Ajanlar aynı simülatörde birbirinin build'ini ezdi, kişisel veri kayıtlara düştü. | Paylaşılan simülatör, gerçek oturum. | §8 kuralları. |
| Bir uygulayıcı silmek istediği 90 görseli silemedi (izin reddi). | Geri alınamaz işlem. | Toplu silmeleri sorumlu onaylar; uygulayıcı listeyi ve kanıtı raporlar. |
| "Sade" yazılan Tur 12 özellikleri tasarım gelince yeniden çizildi. | Tasarımsız uygulama geçici çözümdür. | Tasarımı olmayan özellik en sade hâliyle ve bayrakla yapılır; tasarım gelince görev "önce/sonra fark listesi" ile açılır. |

## 10. Yeni bir tasarım turu geldiğinde

1. Çıktıyı `docs/design/kaynak/` altına koyun, panolara çevirin (`docs/design/README.md`).
2. Panoları okuyun; her pano için "yerine geçtiği kare"yi ve mevcut koddaki karşılığını bulun.
3. Özellik alanlarına göre görevlere bölün (bir alan = bir görev; ortak kit ayrı görev).
4. Görev tanımlarını yazın: "bilinen farklar" listesi kare kare; metinler birebir; veri ve bayraklar.
5. Çalışma ağaçlarını açın, uygulayıcıları başlatın, §6'ya göre inceleyin ve birleştirin.
6. `docs/DURUM.md`'yi ve gerekirse `docs/Backend_Sorulari_Ek.md`'yi güncelleyin.
