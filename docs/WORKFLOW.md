# SMAP · Çalışma modeli

Bu uygulama 2026 Ekim'inde eski kod tabanından ekran ekran yeniden yazıldı. İş, bir **koordinatörün** yönettiği, birbirine dokunmayan küçük görevlere bölündü; görevleri **uygulayıcılar** (çoğunlukla yapay zekâ ajanları, Claude) yazdı; koordinatör her sonucu kendisi inceleyip birleştirdi. Bu belge o modeli anlatır: aynı kaliteyle devam etmek için izlenecek yol budur. Teknik kurallar `AGENTS.md`'de, mimari ve tarifler `docs/DEVELOPING.md`'de.

---

## 1. Akış (bir iş nasıl yapılır)

```
Tasarım / ihtiyaç ──► Görev tanımı ──► Çalışma ağacı ──► Uygulama ──► Koordinatör incelemesi ──► Entegrasyon ──► Simülatör doğrulaması ──► Durum panosu
   (docs/design)       (docs/gorevler)   (tool/wt.sh)     (task/<id>)    (§6 kontrol listesi)       (redesign/main)    (pano ile yan yana)        (docs/DURUM.md)
```

Küçük bir düzeltme için bu adımların hepsi gerekmez; bir ekranı, bir özelliği ya da birden çok kişinin/ajanın paralel çalıştığı her işi bu yolla yapın.

## 2. Roller

| Rol | Ne yapar | Ne yapmaz |
|---|---|---|
| **Koordinatör** (kıdemli geliştirici ya da üst ajan) | İşi görevlere böler, görev tanımını yazar, çalışma ağacını açar, sonucu **kendisi** inceler, ortak dosyaları bağlar, birleştirir, simülatörde doğrular, durum panosunu günceller. | İncelemeyi başkasına devretmez; incelemeden birleştirmez. |
| **Uygulayıcı** (geliştirici ya da ajan) | Yalnız kendi çalışma ağacında ve **kendine verilen dosyalarda** çalışır; testleri yazar; commit eder; rapor yazar. | Ortak dosyalara commit atmaz; push etmez; başka görevin dosyasına dokunmaz. |

Ajanlarla çalışırken önerilen düzen: koordinatör güçlü bir model (bu projede Claude Opus), uygulayıcılar hızlı ve yetenekli bir model (bu projede Claude Sonnet, yüksek düşünme). Her ajana tek görev, tek çalışma ağacı.

## 3. Görev tanımı

Her görev `docs/gorevler/<id>.md` dosyasında yazılır. Ortak giriş metni şablonu `docs/gorevler/_ortak.md`'dedir: çalışma dizini, önce okunacaklar, hazır olanlar, route kuralı, ortak dosyalar, yasaklar, simülatör, test ve doğrulama, rapor biçimi. Bu projenin geçmiş görev tanımlarının bir kısmı örnek olarak `docs/history/gorevler/`'dedir (en olgun örnekler: `t12a.md`–`t12e.md`, `t12k.md`); güncel şablonla yazılmış en yeni örnek `docs/history/gorevler/t12p.md`'dir (biten görevin tanımı oraya taşınır). Eski tanımlardaki simülatör ve doğrulama satırları eskidir (t12a–t12c'de iOS 18.x ve DerivedData temizliği yok; hiçbirinde `tool/format.sh` yok, t12p'de yerine `dart format .` var): bunlar için `_ortak.md`'yi ve §8'i esas alın. Bir görev tanımı şu bölümlerden oluşur:

1. **Başlık ve pano atfı:** `Görev T12C · Edebiyat … — panolar 14.5, 14.6, 14.7. 7.4·1 ve 7.4·2'nin yerine geçer.`
2. **Ortak metin** (`_ortak.md`, `{ID}` ve `{id}` doldurulmuş).
3. **SAHİP OLDUĞUN dosyalar:** glob listesi. Uygulayıcı bunların dışına yazmaz. Başka bir görevin dosyasına ihtiyaç varsa "DAR izin" açıkça yazılır ("yalnız `student` parametresi eklemek için").
4. **Pano kuralları / bilinen farklar:** her kare için beklenen metin, bileşen, davranış; panodaki Türkçe metinler birebir.
5. **Veri:** kullanılacak uçlar, alanlar, bilinen backend açıkları ve bayraklar.
6. **Test ve doğrulama:** hangi VM/saf mantık testleri; `tool/format.sh` temiz, `flutter analyze` 0 sorun, `flutter test`, `tool/ui_rules.sh` (dosya boyu sınırları dahil), iOS simülatör build'i.
7. **Rapor biçimi:** değişen dosyalar, pano karşılaştırması (görüntü yollarıyla), kararlar/varsayımlar, "Koordinatöre notlar" (route, DI, ARB, galeri, pubspec ihtiyaçları), açık sorular.

İyi bir görev **tek bir özellik alanına** düşer ve sahip olduğu dosyalar aynı anda çalışan başka bir görevle kesişmez. Boyut: bir ajanın 30–90 dakikada bitirebileceği kadar (bir ekran ya da bir ekran ailesi).

## 4. Çalışma ağacı ve dallar

```bash
tool/wt.sh t12c            # ../smapFlutter-wt/t12c, dal task/t12c, taban redesign/main
tool/wt.sh t15a main       # tabanı başka bir dal olan görev
```

- Entegrasyon dalı: `redesign/main` (teslimde ana dala alınır; sonra `WT_BASE` ya da ikinci argümanla değiştirin).
- Uygulayıcı yalnız kendi dalına commit atar (Conventional Commits, Türkçe özet; ör. `feat(coach): …`).
- Koordinatör birleştirirken `git merge --no-ff task/<id>` kullanır; dal ve çalışma ağacı birleştirmeden sonra silinir (`git worktree remove ../smapFlutter-wt/<id>`, `git branch -d task/<id>`), o çalışma ağacının Xcode DerivedData klasörü de (§8).

## 5. Ortak dosyalar (yalnız koordinatör)

Bu dosyalar birden çok görevin kesiştiği yerlerdir; paralel commit'ler çakışır ya da birbirini bozar:

- `pubspec.yaml`, `pubspec.lock`, `build.yaml`, `analysis_options.yaml`, `l10n.yaml`
- `lib/app/router/app_router.dart` (+ üretilen `app_router.gr.dart`), `lib/app/router/routes/shell_routes.dart`, `lib/app/shell/*_shell_view.dart`
- `lib/dependency_injection/injection_container.dart`
- `lib/l10n/app_tr.arb` ve üretilen `lib/l10n/app_localizations*.dart` (uygulayıcı yalnız `lib/l10n/arb/<feature>_tr.arb` yazar)
- `lib/gen/assets.gen.dart`, `lib/features/debug/gallery_registry.dart`, `lib/core/services/device_preferences.dart` (yeni anahtar `allowedKeys`'e girer; kişiye aitse `accountKeys`'e de: oturum bitince `SessionManager` onları `clearAccount` ile siler)
- Platform dosyaları (`Info.plist`, `AndroidManifest.xml`, `build.gradle*`, `project.pbxproj`), görev açıkça sahiplenmedikçe.

Uygulayıcı bunlara ihtiyaç duyarsa **yerelde dener, geri alır** ve raporundaki "Koordinatöre notlar"a yazar (gerekiyorsa bir patch dosyası bırakır). Feature'lar kendi listelerini sunar: `<f>_routes.dart`, `<f>_module.dart`, `lib/l10n/arb/<f>_tr.arb`; koordinatör bunları ortak dosyalara bağlar.

## 6. Koordinatör inceleme protokolü

Her görev için, birleştirmeden önce, sırayla:

1. **Kapsam:** `git diff --stat redesign/main...task/<id>` ve `--name-status`. Yalnız sahip olunan dosyalar mı? Silinenler gerçekten ölü mü (`dart run tool/unreachable_files.dart`, `grep`)?
2. **Kural taraması:** `tool/ui_rules.sh`: ham renk, `TextStyle(`, `fontSize:`, Material ikon, diyalog, `Navigator.push`, `print(`, `Widget _build…`, sunumda ham `Duration(` ve dosya boyları (ekran `_view` ≤ 250, part ≤ 300, ViewModel ≤ 500, diğer sunum/kit dosyaları ≤ 400 satır). Betik bunları kendisi denetler; CI'da da çalışır.
3. **Kodu okumak:** özellikle VM'ler, navigasyon, sheet'ler, veri eşlemeleri, tarih/saat dilimi, hata ve çevrimdışı yolları. Bu projede inceleme sırasında yakalanan gerçek hatalar için §9'a bakın.
4. **Birleştir ve bağla:** `git merge --no-ff`, ortak dosyalar (route listeleri, DI, ARB), sonra `dart run tool/merge_arb.dart && flutter gen-l10n && dart run build_runner build -d`.
5. **Çalıştır:** `tool/format.sh` (git'teki Dart dosyalarını `lib/vendor` hariç biçimler, yeni dosyalar önce `git add` edilir; CI aynı betiği `--output=none --set-exit-if-changed` ile denetler, `dart format .` kullanmayın), `flutter analyze` (0 sorun), `flutter test`, `tool/ui_rules.sh`, `flutter build ios --simulator --debug`.
6. **Gözle doğrula:** simülatörde ekranı aç (oturum yoksa `--dart-define=SHELL_PREVIEW=student|coach`), pano PNG'siyle yan yana karşılaştır: açık, koyu (`THEME_MODE=dark`), büyük metin (≈1,35), boş/hata/iskelet durumları.
7. **Karar:** birleştir · düzeltme listesiyle aynı uygulayıcıya iade (en çok iki tur; sonra koordinatör bitirir) · geri al.
8. **Kapat:** `docs/DURUM.md` satırını güncelle (commit, not, açık sorular), çalışma ağacını sil.

## 7. Paralellik kuralları

- Aynı anda çalışan görevlerin sahip olduğu dosyalar **kesişmez**. Kesişiyorsa görevleri sıraya koyun.
- Ortak kit (`lib/shared/ui/**`) ve tema (`lib/core/theme/**`) tek bir görevin sahipliğindedir; diğerleri kit sorunu bulursa düzeltmez, raporlar. Kit'i o sırada sahiplenen görev yoksa görev tanımı belirli bir kit dosyasına dar izin verebilir (yalnız ekleme, galeri sayfasıyla; ör. Tur 12'de T12D `AppAvatarPicker`'a radyo varyantı, T12E `AppTextField`'a `semanticLabel` ve `readOnlyLock` ekledi). Kit değişikliği bütün ekranlara yayılır; koordinatör onu ayrıca okur.
- Önce veri ve mantık (DTO, repository, saf mantık + test), sonra ViewModel (+ test), sonra görünüm.
- Bir görev başka bir görevin ekranına bağlanacaksa (henüz yoksa), geçici bağlantı `lib/features/legacy/legacy_links_<id>.dart` gibi tek bir dosyada tutulur ve hedef görev birleşince silinir. (Bu projede bütün geçici köprüler kapandı.)

## 8. Simülatör, hesap ve güvenlik kuralları

- **Gerçek oturumun bulunduğu simülatöre ajanlar dokunmaz.** Her ajan kendi simülatörünü en yeni iOS ile oluşturur:
  `xcrun simctl create "SMAP-<ID>" "iPhone 17 Pro" com.apple.CoreSimulator.SimRuntime.iOS-26-2` (eski iOS 18.x çalışma zamanlarını kullanmayın). Paylaşılan simülatörde ajanlar birbirinin build'ini ezer ve dokunuşları karışır.
- **İş bitince temizlik (disk dolar):** `xcrun simctl shutdown <udid>; xcrun simctl delete <udid>` (simülatör zaten kapalıysa `shutdown` hata verir; `;` sayesinde `delete` yine çalışır) ile yalnız o görevin simülatörü, ve `~/Library/Developer/Xcode/DerivedData/Runner-*` içinden `info.plist` → `WorkspacePath` değeri o görevin çalışma ağacını gösteren klasör silinir. Her çalışma ağacı ayrı bir DerivedData (birkaç GB) üretir; silinmezse onlarca GB birikir. Kullanıcının kendi simülatörlerine ve başka projelerin DerivedData'sına dokunulmaz.
- Simülatörde uygulama **silinmez** (oturum gider); yalnız üstüne kurulur. İş bitince dart-define'sız temiz build bırakılır.
- **Canlı sunucuda hesapla giriş yapılmaz, yazan istek atılmaz.** Veri dolu hâli görmek için geçici sahte repository/ağ adaptörü kullanılır ve commit edilmez. Optik okuma için `OMR_BASE_URL` verilmezse fotoğraf canlı API sunucusuna gider: test ederken yerel bir sahte sunucu kullanın.
- Kimlik bilgisi dosyaları (`*.jks`, `*.keystore`, `key.properties`, `google-services*.json`, `GoogleService-Info.plist`, `.env*`, `*.p8`, `*adminsdk*.json`) açılmaz, içerikleri hiçbir yere yazılmaz. Android yayın imzası `android/key.properties`'ten okunur (dosya yoksa debug anahtarı); anahtar sahibindedir, git'te yoktur.
- Push ve PR yalnız sorumlunun onayıyla.

## 9. Bu projede öğrenilenler (aynı hataya düşmeyin)

| Ne oldu | Neden | Kural |
|---|---|---|
| Okutma akışında X ve sistem Geri uygulamayı **dondurdu**. | Her aşama Geri'yi `PopScope(canPop: false)` ile tutup kapatma fonksiyonunu çağırıyordu; kapatma `maybePop()` ile aynı `PopScope`'a yeniden soruyordu: sonsuz döngü. | `PopScope` içinden çağrılan kapatma `router.pop()` (zorla) kullanır, `maybePop()` değil. Regresyon testi: `test/features/scan/presentation/router_scan_navigator_test.dart`. |
| Sekme ekranlarında son satır alt çubuğun altında kaldı. | Kabuktaki `Scaffold` gövdenin `viewPadding.bottom`'unu sıfırlıyor, `AppBottomBar.heightOf` 34 pt eksik hesaplıyordu. | Düzeltme kabukta (`shell_tab_stack.dart`); ekranlar her zaman `AppBottomBar.heightOf(context)` kullanır, kendi hesabını yapmaz. |
| Aynı görüşme iki ekranda 3 saat farklı göründü. | Bir ekran `toLocal()`, diğeri sunucu saatini olduğu gibi gösteriyordu. | Görüşme saatleri tek kuralla okunur (`MeetingMoment.wallClock`); sunucuya dilimsiz yerel saat gider (eski uygulamayla aynı). |
| Ajanlar aynı simülatörde birbirinin build'ini ezdi, kişisel veri kayıtlara düştü. | Paylaşılan simülatör, gerçek oturum. | §8 kuralları. |
| Bir uygulayıcı silmek istediği 90 görseli silemedi (izin reddi). | Geri alınamaz işlem. | Toplu silmeleri sorumlu onaylar; uygulayıcı listeyi ve kanıtı raporlar. |
| Ajanlar eski iOS 18.5 simülatörleri açtı; silinmiş çalışma ağaçlarının DerivedData'sı 22 GB tuttu. | Görev tanımı "mevcut simülatörle aynı çalışma zamanı" diyordu; DerivedData temizliği adımı yoktu. | §8: iOS 26.x, görev bitince simülatör ve DerivedData silinir; görev tanımı şablonunda yazılı. |
| "Sade" yazılan Tur 12 özellikleri tasarım gelince yeniden çizildi. | Tasarımsız uygulama geçici çözümdür. | Tasarımı olmayan özellik en sade hâliyle ve bayrakla yapılır; tasarım gelince görev "önce/sonra fark listesi" ile açılır. |

## 10. Yeni bir tasarım turu geldiğinde

1. Çıktıyı `docs/design/kaynak/SMAP-NN.html` olarak koyun, panolara çevirin: `python3 tool/design/html_to_boards.py docs/design/kaynak/SMAP-NN.html` (ayrıntı `docs/design/README.md`). Görsel varlıklar (kil, mağaza) `docs/design/` altındaki klasörlerine; uygulamada kullanılanlar ayrıca `assets/` altına (kil: `assets/illustrations/clay/`, ekranda `AppClay` çizer).
2. Panoları okuyun; her pano için "yerine geçtiği kare"yi ve mevcut koddaki karşılığını bulun.
3. Özellik alanlarına göre görevlere bölün (bir alan = bir görev; ortak kit ayrı görev).
4. Görev tanımlarını yazın: "bilinen farklar" listesi kare kare; metinler birebir; veri ve bayraklar.
5. Çalışma ağaçlarını açın, uygulayıcıları başlatın, §6'ya göre inceleyin ve birleştirin.
6. `docs/DURUM.md`'yi ve gerekirse `docs/Backend_Sorulari_Ek.md`'yi güncelleyin.
