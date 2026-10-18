# Görev tanımı şablonu

Yeni bir görev için bu dosyayı `docs/gorevler/<id>.md` olarak kopyalayın, `{id}` (ör. `t15a`) ve `{ID}` (ör. `T15A`) yerlerini doldurun, köşeli parantezli bölümleri yazın. Süreç `docs/WORKFLOW.md`'de; bu projenin geçmiş görevleri örnek olarak `docs/history/gorevler/`'de (en olgunları `t12a.md`–`t12e.md`, `t12k.md`).

---

Görev {ID} · [Alan: kısa ad] — pano [X.Y "Pano adı · N kare"], … [Yerine geçtiği kareler: "7.4·1 ve 7.4·2'nin yerine geçer."]

Çalışma dizini: ../smapFlutter-wt/{id} (git worktree, dal task/{id}, taban redesign/main; `tool/wt.sh {id}` ile açılır). Her komutu bu dizinde çalıştır. Push etme. Başka worktree'ye ya da ana çalışma kopyasına yazma. İlk iş `flutter pub get`.

ÖNCE OKU: AGENTS.md (bağlayıcı kurallar); docs/DEVELOPING.md ve ilgili bölümleri (docs/dev/03_ekran.md yeni ekran tarifi, 04_tasarim_sistemi.md kit kataloğu, 02_veri.md yeni uç tarifi, 06_ozellikler.md özellik haritası ve açık işler); docs/SMAP_Ana_Plan.md (K1–K16 kararları); docs/SMAP_UI_Uygulama_Rehberi.md §6 (widget bölme kuralları) ve docs/SMAP_UI_Rehberi_Duzeltmeler.md; ekran spec'i docs/spec/0[3-5]_ekranlar_*.md (kendi ekranların), docs/spec/SMAP_Flutter_Spec.md (route haritası, bileşenler); akış docs/design/panolar/AKIS.md; kararlar docs/spec/06_kararlar_varsayimlar.md.

PANOLAR: docs/design/panolar/png/SMAP-NN_<pano>.png (görsel; mutlaka GÖR) ve docs/design/panolar/SMAP-NN/<pano>/{text.txt,board.html} (metinler, kurallar, varsayımlar; ölçü ve renkleri board.html'den oku). Teslim panoları (SMAP-11: 11.12 token, 11.13 bileşen, 11.14 ekran–bileşen, 11.15 hareket/haptik, 11.16 varsayımlar ve Tur 12 ekleri) önceki turları geçersiz kılar. Panodaki her kareyi, "Yerine geçtiği kare" etiketini, Bileşenler/Kural/Veri/Varsayımlar/Erişilebilirlik notlarını harfiyen uygula; Türkçe metinler BİREBİR aynı. Koyu tema: panodaki koyu kare; değerleri token rolleriyle karşıla (ham renk yok). Mevcut kod varsa ÖNCE oku, panoyla kare kare karşılaştırıp fark listesini çıkar (raporda ver), sonra farkları kapat.

HAZIR OLANLAR: kit lib/shared/ui/** (galeri: lib/features/debug/pages/*), alan bileşenleri lib/features/<f>/presentation/widgets, veri katmanı lib/features/<f>/{data,domain,application} (kullan; eksik metot gerekiyorsa yalnız EKLE ve gerekçele), lib/services/{session_manager,current_user_service}.dart, lib/core/config/{app_config,feature_flags}.dart, DevicePreferences (hesaba ait anahtarlar `accountKeys`'te; oturum bitince SessionManager `clearAccount` ile siler; yeni anahtar ortak dosyada, koordinatörün işi), AppHaptics, ToastService, TrFormat/TurkishText/TurkishSuffix. Örnek ekranlar (aynı kaliteyi tut): lib/features/analytics/presentation/analytics/, lib/features/lessons/presentation/{lesson_detail,topic_detail}/, lib/features/home/presentation/home/.

SAHİP OLDUĞUN dosyalar: [glob listesi; ör. lib/features/<f>/presentation/<ekran>/**, lib/l10n/arb/<f>_tr.arb, test/features/<f>/**]. Bunların dışına yazma. [Başka görevin dosyasına dar izin gerekiyorsa açıkça: "yalnız `student` parametresi eklemek için".] Paralel çalışan görevler: [id → alan]; onların dosyalarına dokunma.

ORTAK DOSYALAR — COMMIT ETME: pubspec.yaml, pubspec.lock, build.yaml, analysis_options.yaml, l10n.yaml, lib/app/router/{app_router.dart,app_router.gr.dart,routes/shell_routes.dart}, lib/app/shell/*_shell_view.dart, lib/dependency_injection/injection_container.dart, lib/l10n/app_tr.arb + app_localizations*.dart, lib/gen/assets.gen.dart, lib/features/debug/gallery_registry.dart, lib/core/services/device_preferences.dart, platform dosyaları (Info.plist, AndroidManifest.xml, build.gradle*). Gerekirse yerelde üret ve dene, commit'ten önce geri al, gereken değişikliği "Koordinatöre notlar"a yaz (gerekirse patch dosyası bırak).

ROUTE KURALI: lib/features/<f>/<f>_routes.dart içinde sekme çocukları `List<AutoRoute> get <x>TabRoutes`, tam ekranlar `<x>RootRoutes`; DI kayıtları lib/features/<f>/<f>_module.dart. Bunları ortak dosyalara koordinatör bağlar.

YASAKLAR: AGENTS.md "UI rules"; sahte veri gösterme (veri yoksa alanı çizme); bayrak arkasındaki özelliği bayraksız açma; kimlik bilgisi dosyalarını açma, içeriklerini hiçbir yere yazma (`android/key.properties`, `*.jks`, `*.keystore`, `google-services*.json`, `GoogleService-Info.plist`, `.env*`, `*.p8`); yerini aldığın eski dosyaları sil (yalnız onları; grep ve `dart run tool/unreachable_files.dart` ile kanıtla).

BİLİNEN HEDEF (panoyla doğrula): [kare kare: metin, bileşen, davranış, durumlar (iskelet, boş, hata, çevrimdışı), koyu, okunuş, haptik]

VERİ: [uçlar, alanlar, bilinen backend açıkları, bayraklar]

TEST: VM ve saf mantık unit testleri (durumlar, metinler, hata ve çevrimdışı yolları); widget testi yalnız ölçü/okunuş için gerekirse. Mevcut testler yeşil kalsın.

DOĞRULAMA: kod üretimi güncel (`dart run build_runner build -d`, `dart run tool/merge_arb.dart && flutter gen-l10n`; özelliğin `lib/features/<f>/data/dtos/generated/*.mapper.dart` dosyalarını commit et, ortak üretilenleri — ORTAK DOSYALAR'daki gibi — geri al), yeni dosyalar `git add` edildikten sonra `tool/format.sh` temiz (betik yalnız git'in izlediği dosyaları biçimler; denetim, CI'daki gibi: `tool/format.sh --output=none --set-exit-if-changed`), `flutter analyze` 0 sorun, `flutter test` yeşil, `tool/ui_rules.sh` temiz (dosya boyu sınırları dahil), `flutter build ios --simulator --debug`.

SİMÜLATÖR: Gerçek oturumun bulunduğu simülatöre dokunma (kaldırma, kurma, kapatma yok). Kendi simülatörünü oluştur: `xcrun simctl create "SMAP-{ID}" "iPhone 17 Pro" com.apple.CoreSimulator.SimRuntime.iOS-26-2` (en yeni iOS; 18.x kullanma). Debug araçları: `--dart-define=SHELL_PREVIEW=student|coach`, `--dart-define=THEME_MODE=dark`, `tool/sim_env.sh <udid> SHELL_PREVIEW_TAB=0..3` ve ardından `xcrun simctl launch <udid> com.studentmap.smap` (iOS 26'da `SIMCTL_CHILD_` uygulamaya ulaşmaz), galeri `-t lib/main_gallery.dart`. Veri dolu hâli görmek için GEÇİCİ sahte repository/ağ adaptörü kullanabilirsin; commit etme, işin sonunda sil. Canlı sunucuda hesapla giriş yapma, yazan istek atma. Her kareyi panoyla yan yana karşılaştırmadan bitirme (açık, koyu, büyük metin, durumlar). İş bitince: `xcrun simctl shutdown <udid>; xcrun simctl delete <udid>` ile (simülatör zaten kapalıysa shutdown hata verir; `;` sayesinde silme yine çalışır) YALNIZ kendi simülatörünü ve bu worktree'nin Xcode DerivedData klasörünü sil (`~/Library/Developer/Xcode/DerivedData/Runner-*` içinden `info.plist` WorkspacePath'i ../smapFlutter-wt/{id}'i gösteren).

COMMIT: dal task/{id}, Conventional Commits (Türkçe özet; ör. `feat(coach): …`).

RAPOR (Türkçe, kısa): önce/sonra fark listesi (kare kare), değişen dosyalar, pano karşılaştırması (görüntü yolları), kararlar/varsayımlar, analyze/test/ui_rules sonuçları, "Koordinatöre notlar" (route listeleri, DI, ARB, galeri, pubspec, silinecek dosyalar), açık sorular (eksik backend alanları).
