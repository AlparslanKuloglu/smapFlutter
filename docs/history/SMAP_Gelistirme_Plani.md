# SMAP Geliştirme Planı (smapFlutter)

Tarih: 2026-10-10 · Kapsam: SMAP Flutter istemcisi ve Claude Design redesign'ının koda geçirilmesi

**Kısaltmalar**
- `SMAP/` = .
- `SLP/` = Sleepia (repo dışı referans uygulama)
- `MEM/` = Memora (repo dışı referans uygulama) (Memora)
- `SHP/` = Sepello (repo dışı referans uygulama) (Sepello)
- Efor ölçeği (tek geliştirici): S ≤ 1 gün, M = 2–5 gün, L = 1–3 hafta

---

## 1. Yönetici özeti

- **Bugünkü durum:** SMAP işlevsel ama mimari geçişi yarıda kalmış bir kod tabanı. Vendor hariç 199 dosya ve yaklaşık 35,7 bin satır.
  - Clean-architecture iskeletini yalnızca auth kullanıyor. Diğer 6 feature'da yaklaşık 31 ölü stub var.
  - Gerçek veri erişimi widget'ların içinde `new`lenen `lib/repository/*` sınıflarıyla yapılıyor ve hepsi ham `Map<String,dynamic>` döndürüyor.
  - DI yok. Navigasyon 3 ayrı mekanizmayla, HTTP 3 ayrı yığınla çalışıyor. Kodda 231 `setState` var ve tek test kırık.
- **Referans appler aynı reçetede buluşuyor:** Sleepia, Memora ve Shoplist'in hepsi şunları kullanıyor:
  - get_it (session scope ile), stacked MVVM, auto_route guard'ları
  - Tek Dio/vexana istemcisi ve `AppException` + `Either` hata modeli
  - dart_mappable, mihr_ui + ThemeExtension, gen-l10n, ToastService
  - Crashlytics, Analytics, FCM, backend public-config ve force update

  SMAP'te bunların hiçbiri yok. Ama dio, dartz ve provider zaten bağımlılık olarak duruyor. Bu yüzden iş sıfırdan yazmak değil, modül taşımak.
- **Mağazaya bugün çıkılamıyor:**
  - iOS Info.plist'te kamera izin metni yok. Optik okuma ilk açılışta uygulamayı çökertir.
  - Android release build debug anahtarıyla, şablon uygulama kimliğiyle imzalanıyor.
  - 1024 px iOS ikonu alfa kanallı.
  - Ödeme, kayıtlı kart ve fatura ekranları sahte veri gösteriyor.
- **En büyük 3 risk:**
  1. **Güvenlik ve KVKK.**
     - Login ekranında test hesabının kullanıcı adı ve şifresi önceden doldurulmuş geliyor (`login_screen.dart:19-20`).
     - Optik okuma (OMR) uçları oturumsuz çalışıyor ve kullanıcı kimliğini istemcinin gönderdiği `user` JSON'undan alıyor.
     - KVKK onay sürümleri backend'e hiç gitmiyor.
     - Reşit olmayan öğrencilerin verisi ve Google idToken release log'larına yazılıyor.
     - Öğrenci modelinde `password` alanı var.
  2. **Ürün güveni.**
     - Analiz ekranlarında uydurma rakamlar gerçek veri gibi gösteriliyor: her kartta "+18.2% geçen ay", her konuda "%75, 15/20 Konu tamamlandı".
     - Şifre değiştirme hiç API çağırmadan "başarılı" diyor.
     - Ödeme, kart ve bildirim ekranları mock.
  3. **Çekirdek akışın (OMR) kırılganlığı.**
     - OMR ayrı bir ağ yığınında, TODO işaretli bir base URL ile çalışıyor.
     - Kamera izni reddedilirse kapatma tuşu olmayan sonsuz bir spinner çıkıyor.
     - Tam çözünürlüklü görüntü UI isolate'ında base64'e çevriliyor. Timeout ve retry yok; hata olunca çekilen fotoğraf kayboluyor.
     - Gömülü (vendored) tarayıcı 2021 tarihli OpenCV kullanıyor; Play'in 16 KB sayfa boyutu şartında risk var.
     - Crash raporlama olmadığı için sahada ne olduğunu göremiyoruz.
- **Redesign ancak altyapıdan sonra yapılabilir.** Yeni tasarım bugünkü kodun üzerine giydirilirse iş 2–3 kat büyür:
  - 400'den fazla hardcoded `Color(0x..)`, 507 `Colors.*` ve 439 inline `TextStyle` var.
  - 2.652 satırlık god widget'lar var.
  - Önerilen sıra: Faz 0 (1 hafta), ardından Faz 1 altyapısı (token, component kit, DI, router, network), sonra ekran ekran redesign.
- **Tasarım spec'inde karar bekleyen öğeler var.** "Kayıtlı Kartlarım" ve "Yeni Kart Ekle", "geçen aya göre +18.2%" tile'ı, fatura listesi, Harita, "Bugün" görevleri ve elmas/coin, backend verisi ya da mağaza politikası kararı gerektiriyor. Bunlar karar verilmeden kodlanmamalı (bkz. §7).

**Tahmini süre (1 geliştirici):**

| Faz | Süre |
|---|---|
| Faz 0 | 6–8 iş günü |
| Faz 1 | 4–5 hafta |
| Faz 2 | 7–9 hafta |
| Faz 3 | 4–6 hafta (Faz 2 ile kısmen paralel) |
| Faz 4 | Sürekli, ayrıca 2 hafta toparlama |

---

## 2. Mimari karşılaştırma tablosu

| Konu | SMAP (bugün) | Sleepia | Memora | Shoplist | Öneri (kaynak) |
|---|---|---|---|---|---|
| Klasör yapısı | `features/` ile legacy `views/`, `repository/`, `http_service/` yan yana duruyor. 6 feature'da boş stub var. OMR `lib/views`'ta. | core/data/domain/features/shared ayrımı. Strangler göçü yazılı bir roadmap ile yapılıyor. | domain/data/config/core/services/features/shared ayrımı, CLAUDE.md var. | app/core/features/{data,domain,presentation}/shared ayrımı, kurallar AGENTS.md'de. | Shoplist'in feature-first düzeni, Memora'nın `config/api/requests` ayrımı ve Sleepia'nın roadmap doküman alışkanlığı. `SHP/AGENTS.md`, `MEM/lib/config/api/requests/` |
| State mgmt | 10 ChangeNotifier, 231 setState, FutureBuilder. bloc yalnızca transitive bağımlılık olarak var. | stacked; SelectorViewModelWidget ile kapsamlı rebuild. | stacked; ReactiveViewModel + listenableServices, işlem başına busy key. | stacked; VM'ler constructor injection ile kuruluyor. | stacked MVVM, yalnızca constructor injection. `MEM/lib/features/history/presentation/history_viewmodel.dart`, `SHP/lib/features/lists/presentation/lists/lists_viewmodel.dart` |
| DI | Yok. Repo'lar widget içinde `new`leniyor. İki ayrı UserProvider var. | get_it ve hot-restart guard var, session scope yok. | get_it fazlı kurulum, `session` scope, ilk kurulumda Keychain temizliği. | get_it, session scope ve DI smoke testi. | Memora'nın yapısı ve Shoplist'in DI testi. Rol bazlı servisler session scope'ta. `MEM/lib/dependency_injection/`, `SHP/test/dependency_inj/injection_container_test.dart` |
| Routing | Named route'lar, 32 inline MaterialPageRoute ve enum nav notifier'ları. Auth guard yok. | AuthGate durum makinesi ve imperative push. | auto_route; ForceUpdate guard'ı Auth guard'ından önce, reevaluateListenable ile. | auto_route; AuthGuard kararını hedef route'tan veriyor. | auto_route; Force > Onboarding > Auth > Role guard zinciri; öğrenci ve koç için ayrı AutoTabsRouter. `MEM/lib/config/router/app_router.dart`, `SHP/lib/app/router/guards/auth_guard.dart` |
| Network / hata modeli | 3 yığın (DioClient, rest_api_package, http). `validateStatus < 500`. `_makeRequest` 5 kez kopyalanmış, Map dönüyor, hatalar Exception string'i. | vexana NetworkService, typed request sınıfları, tek seferlik (single-flight) refresh, AppException + EitherOr. | Sleepia ile aynı; ek olarak marker header ile auth, zorunlu çıkış ve multipart request. | Sealed Failure ve ErrorHandler switch. | Memora'nın network ve errors katmanı; mesajlar l10n'e bağlanır. Datasource hata fırlatır, repository Either döner (Shoplist kuralı). `MEM/lib/core/network/`, `MEM/lib/core/errors/` |
| Token / güvenlik | Cookie oturumu Documents dizininde, user JSON düz prefs'te. 401 yönetimi yok. Test hesabı prefill. | TokenManager secure storage'da; token çifti atomik yazılıyor, eski veri için migrasyon köprüsü var. | TokenManager ve ilk kurulumda Keychain temizliği. | Oturumu Firebase Auth saklıyor. | Sleepia'nın TokenManager'ı (cookie/JWT kararına göre uyarlanır) ve Memora'nın Keychain temizliği. `SLP/lib/core/network/token_manager.dart` |
| Local storage | Anahtarlar dağınık; `user_data` 7 yerde decode ediliyor, `bagItemsStr` global. | prefs, Hive CE JSON box'ları ve dosyalar. | Anahtarları sahibi servis tutuyor; tokenlar secure storage'da. | DevicePreferences facade'ı (allowList), kullanıcı verisi uid ile ayrılmış. | Shoplist'in DevicePreferences'ı; offline tarama kuyruğu için Sleepia'nın LocalStore'u. `SHP/lib/core/services/device_preferences.dart`, `SLP/lib/services/local_store.dart` |
| l10n | Yok. Dil tr_TR'ye sabit, 264 literal Text var, navigasyon görünen etikete göre yapılıyor. | gen-l10n, 10 dil, LocaleService, Accept-Language header'ı. | gen-l10n, feature önekli anahtarlar, ToastText. | gen-l10n, şablon dosya app_tr.arb. | Shoplist'in l10n.yaml'ı (tr şablon), Memora'nın LocaleService'i ve ToastText. `SHP/l10n.yaml`, `MEM/lib/services/locale_service.dart` |
| Tema / design tokens | AppTheme 25 satır ve seed rengi gri. 400'den fazla Color literal, textTheme hiç kullanılmıyor, dark mode yok. | mihr_ui (dark) ve SleepiaColors extension. | mihr_ui light/dark ve ThemeService. | mihr_ui, SepelloColors (light/dark/lerp), AppMotion, component galerisi. | mihr_ui ve SmapColors ThemeExtension (D/Y/B renkleri, 9 ders rengi). `SHP/lib/core/theme/sepello_colors.dart`, `SHP/lib/core/theme/app_motion.dart` |
| Analytics | Yok. | AppEvents facade'ı (GA4, Meta, TikTok, Clarity) ve PurchaseAttribution. | AnalyticsService ve AnalyticsRouteObserver. | Kapalı event sözlüğü, kişisel veri (PII) yok. | Shoplist'in servisi ve PII kuralları (kullanıcıların çoğu reşit değil). `SHP/lib/core/services/analytics/analytics_service.dart` |
| Crash | Yok; `FlutterError.onError` tanımlı değil. | runZonedGuarded, non-fatal kayıt, `_isLibraryNoise` filtresi. | Aynı yapı ve `flutter_error_filters`. | Crashlytics, custom key'ler, dSYM yükleme script'i. | Memora'nın bootstrap'i ve Shoplist'in custom key'leri (rol, flavor). `MEM/lib/core/utils/flutter_error_filters.dart`, `SHP/lib/main_initializer.dart` |
| Remote config / force update | Yok. | Backend public-config dikeyi, ExperimentService, ForceUpdateService. | AppConfigService ve ForceUpdateGuard. | Firestore FlagService; force update yok. | Sleepia'nın AppConfig dikeyi, Memora'nın guard'ı ve resume'da yeniden kontrol. `SLP/lib/services/app_config_service.dart`, `SLP/lib/services/force_update_service.dart` |
| Push | Yok; bildirim ayarları ekranı yalnızca setState çağırıyor. | FCM, izin isteği ertelenmiş, cihaz kaydı var; bildirime dokununca yönlendirme yok. | FCM ve OneSignal, oturuma bağlı; dokununca yönlendirme yok. | FCM, NotificationRouter (oturum açılana kadar bekletme) ve primer sheet. | Shoplist'in router'ı ve primer'ı; Firestore cihaz kaydı REST `/devices`'a çevrilir. `SHP/lib/features/notifications/` |
| IAP / paywall | Fatura, kart ve plan mock; ödeme SDK'sı yok. | in_app_purchase, backend doğrulama, PurchaseFlow. | IapService, PremiumService, PremiumViewModel (session scope'ta). | Yok (RevenueCat planlanmış). | Memora'nın IapService'i ve Sleepia'nın PremiumService'i + PurchaseFlow'u. `MEM/lib/services/iap_service.dart`, `SLP/lib/shared/purchase/purchase_flow.dart` |
| Onboarding | İki kopya: `features/onboarding` ve `views/onboarding`. | VM ile yönetiliyor; flag ilk frame'den önce okunuyor. | PageView ve VM; navigasyonu guard yapıyor. | Bağlamsal; adımları enum olan VM. | Tek VM: rol seçimi > alan/hedef > kamera izni primer > hesap. `SLP/lib/features/onboarding/presentation/onboarding_viewmodel.dart` |
| Rating | Yok. | ReviewService (eşikler, 120 gün aralık). | Aynı. | Yok. | Sleepia'nın ReviewService'i. `SLP/lib/services/review_service.dart` |
| Deep link | Yok. | Yok. | Yalnızca çözülemeyen link için fallback. | Davet kodu, share intent, notification router. | app_links ve Shoplist'in InviteCode'u (koç-öğrenci eşleştirme için). `SHP/lib/features/sharing/invite_code.dart` |
| Test | 1 test, o da kırık. | 16 saf unit test. | 3 test. | mocktail ile VM testleri, DI smoke testi, env testi. | Shoplist'in test pratikleri; ek olarak golden test. `SHP/test/` |
| Lint / codegen | Varsayılan flutter_lints, 307 analyzer bulgusu, codegen yok. | flutter_lints ve performans kuralları. | very_good_analysis, dart_mappable, build.yaml. | very_good_analysis, dart_mappable, build.yaml. | `SHP/analysis_options.yaml`, `SHP/build.yaml` |
| CI / release | CI yok, git geçmişi tek commit, release debug imzalı. | VS Code task'ları, sürüm artırma script'i, obfuscate. | VS Code task'ları, R8, key.properties. | GitHub Actions (lockfile, codegen diff, analyze, test); prod imza guard'ı. | Shoplist'in ci.yml'ı ve imza guard'ı, Sleepia'nın sürüm artırma script'i. `SHP/.github/workflows/ci.yml`, `SLP/tool/bump_build_version.dart` |
| Env / flavor | Yok; 5 farklı origin, 16 hardcoded URL noktası. | Yok (kopyalanmamalı). | Yok (kopyalanmamalı). | AppEnv, dev/prod flavor, iOS xcconfig ve test. | `SHP/lib/core/config/app_config.dart` ve `SHP/android/app/build.gradle.kts` |
| Logging | 58 print ve 57 debugPrint; idToken ve kişisel veri log'a gidiyor. | AppLogger (yalnız kDebugMode), ama az kullanılıyor. | AppLogger, token maskeleme. | AppLogger. | Memora'nın AppLogger'ı, `avoid_print` lint'i; release'de hatalar Crashlytics.log'a. `MEM/lib/core/services/app_logger.dart` |

---

## 3. Kritik bulgular (önem sırasına göre)

### Kritik

**K1. Login ekranında önceden doldurulmuş test hesabı**
- **Kanıt:** `SMAP/lib/features/auth/presentation/screens/login_screen.dart:19-20`. Kullanıcı adı ve şifre controller'ları dolu başlatılıyor (değerler burada tekrarlanmadı). Aynı şey ölü kopyada da var: `lib/views/auth/login_view.dart:19-20`.
- **Düzeltme:**
  - Controller'ları boş başlat ve `views/auth/login_view.dart`'ı sil.
  - Hesabı backend'de devre dışı bırak ya da şifresini değiştir.
  - Geliştirme kolaylığı gerekirse değerleri yalnızca dev flavor'da, gitignored `env/dev.json` üzerinden ver.

**K2. iOS'ta kamera izin metni yok, tarama ilk açılışta çöker**
- **Kanıt:** `SMAP/ios/Runner/Info.plist`'te hiçbir `NS*UsageDescription` anahtarı yok. Kamera `lib/vendor/flutter_document_scanner/.../bloc/app/app_bloc.dart:60,77`'de açılıyor.
- **Düzeltme:**
  - Türkçe `NSCameraUsageDescription` ekle.
  - camerawesome ve image_picker'ı kaldır; böylece mikrofon, konum ve fotoğraf izin metni zorunluluğu da düşer.
  - `CFBundleDevelopmentRegion=tr` ve `ITSAppUsesNonExemptEncryption=false` ekle.

**K3. OMR uçları oturumsuz, kimliği istemciden alıyor, host placeholder**
- **Kanıt:**
  - `lib/http_service/rest_api_http_service.dart:14-17`: interceptor'sız ve timeout'suz çıplak `Dio()`.
  - `lib/core/constants/api_constants.dart:11-14`: TODO işaretli host.
  - `lib/repository/optic_requests/requests/send_om_image_request.dart:13`: `authorize=false`.
  - `lib/views/optic_mark_detection_view/omd_loading.dart:912-933`: `user` alanı prefs'teki JSON'dan alınıp body'ye koyuluyor, görüntü base64 olarak gidiyor.
- **Düzeltme:**
  - OMR çağrılarını oturumu taşıyan tek NetworkService'e al ve host'u AppEnv'den oku.
  - Body'deki `user` alanını kaldır; backend kimliği oturumdan türetmeli (§7-S2).
  - Görüntüyü multipart olarak gönder; progress, 30–60 sn timeout ve retry ekle.

**K4. Uydurma metrikler gerçek veri gibi gösteriliyor**
- **Kanıt:**
  - `lib/features/analytics/presentation/models/analytics_general_data.dart:138-139`: `'+18.2%'` ve `'gecen ay'` varsayılan değer olarak atanmış.
  - `screens/lesson_bar.dart:17-22,37`: sabit 0.75 ve "15/20 Konu tamamlandı".
  - Aynı kalıp `lesson_detail_page.dart:522-527`, `edebiyat_lesson_detail_page.dart:714,738` ve `subject_detail_page.dart:291`'de.
  - Kullanılmayan veri üreticiler hâlâ kodda: `AnalyticsGeneralData.mock()` ve `analytics_view_provider.dart:396-446`.
- **Düzeltme:**
  - Bu alanları nullable yap; veri yoksa hiç gösterme.
  - `mock()` ve `_buildGeneralData`'yı sil.
  - Backend'in hangi alanları verebileceğini netleştir (§7-S8).

**K5. Android release debug anahtarıyla imzalanıyor, uygulama kimliği şablon**
- **Kanıt:** `SMAP/android/app/build.gradle.kts:23-24` (TODO + `com.smap.smap`) ve `:35-37` (`signingConfigs.getByName("debug")`). iOS bundle ID'si de aynı şablon değer.
- **Düzeltme:**
  - Kalıcı applicationId ve bundle ID'ye karar ver; ilk mağaza yüklemesinden sonra değişmez.
  - İmzayı `key.properties` ile kur. Shoplist'teki gibi, anahtar yoksa prod release build'i başarısız olsun.
  - R8, `--obfuscate` ve `--split-debug-info` ekle.

### Yüksek

**Y1. Şifre değiştirme ve şifremi unuttum sahte**
- **Kanıt:** `account_settings_screen.dart:749-774` API çağırmadan SnackBar'da başarı gösteriyor. `forgot_password_screen.dart:288-292` her kodu geçerli sayıyor.
- **Düzeltme:** Endpoint varsa bağla, yoksa Faz 0'da bu akışları gizle.

**Y2. KVKK onay sürümleri backend'e gitmiyor**
- **Kanıt:** `register_provider.dart:52-66` `accepted*Version` alanlarını ekliyor, ama `auth_remote_data_source.dart:30-35` yalnızca `{"userType", "data": userJson}` gönderiyor (doğrulandı). Ayrıca `legal_document.dart:24` sürüm yoksa `'1.0.0'` varsayıyor.
- **Düzeltme:**
  - Sürüm alanlarını body'ye ekle.
  - Yasal dokümanlar yüklenemezse kayıt butonunu kapat.
  - Varsayılan sürüm atamayı kaldır.

**Y3. Hassas veri log'lara yazılıyor**
- **Kanıt:**
  - `services/google_auth_service.dart:27-28`: e-posta ve idToken.
  - `repository/coach_repository.dart:102-112` ve `repository/weekly_repository.dart:89-116`: tam URI ve response gövdesi.
  - `repository/home_repository.dart:64`: öğrenci listesi.
  - `omd_loading.dart:899`: `print(userData)`.
- **Düzeltme:** Hepsini AppLogger'a (yalnızca kDebugMode) çevir, `avoid_print` lint'ini aç, Authorization ve Cookie header'larını maskele.

**Y4. Öğrenci modelinde `password` alanı**
- **Kanıt:** `domain/models/student_model.dart:8,96,127`; veri `/coach/getMyStudents`'tan geliyor.
- **Düzeltme:** Alanı istemciden kaldır; backend projection'ı düzeltilmeli (§7-S4).

**Y5. Mock ödeme, kart ve bildirim ekranları canlıda erişilebilir**
- **Kanıt:**
  - `payment_settings_screen.dart:21,59`: PaymentInvoiceMock.
  - `saved_cards_screen.dart:14-33`: sabit kart listesi.
  - `current_plan_card.dart:25,34`: "249 ₺".
  - `notifications_screen.dart:65`: "Kaydet" butonu `onPressed: () {}`.
  - Giriş noktası `account_screen.dart:99-117`.
- **Düzeltme:** Faz 0'da menüden kaldır. Gerçek paywall Faz 3.4'teki karardan sonra gelir.

**Y6. Oturum süresi dolunca (401) bir şey olmuyor**
- **Kanıt:**
  - `core/network/dio_client.dart:21` `validateStatus < 500`; tek interceptor `:43`'teki CookieManager.
  - `auth_repository_impl.dart:75-77`: login 302'yi başarı sayıyor, `success` alanını kontrol etmiyor.
- **Düzeltme:**
  - Varsayılan validateStatus'a dön.
  - 401 gelince interceptor `SessionManager.endSession`'ı çağırsın, guard kullanıcıyı login'e atsın.
  - Login'de `success` alanını kontrol et.

**Y7. OMR sonuç ekranı her zaman `connect.sid=null` gönderiyor**
- **Kanıt:** `omd_result_flow_view.dart:226-235` prefs'teki `connect_sid` anahtarını okuyor. Bu anahtarı yazan tek metodun (`auth_local_data_source.dart:26`) hiç çağıranı yok.
- **Düzeltme:** İsteği DioClient'a taşı ve `http` paketini kaldır.

**Y8. İki ayrı UserProvider instance'ı**
- **Kanıt:** `main.dart:45`'teki instance repository'ye enjekte ediliyor, `main.dart:73`'teki farklı bir instance ağaçta. Ayrıca `main.dart:107,142`'de `build` içinde `loadUserData` çağrılıyor.
- **Düzeltme:** Faz 0'da tek instance'ı `.value` ile ver. Faz 1'de yerine SessionManager gelsin.

**Y9. Kamera izni reddi veya başlatma hatası sonsuz spinner bırakıyor**
- **Kanıt:** `vendor/.../app_bloc.dart:50-90` try/catch içermiyor. `take_photo_document_page.dart:58-72` loading durumunda spinner, failure durumunda boş Container gösteriyor.
- **Düzeltme:** Memora'nın fork'unu al: failure state ve `onFailure` var. "Ayarları Aç" ekranı için `MEM/lib/core/utils/open_app_settings.dart` ve `MEM/lib/features/scan/presentation/scan_page.dart` kullanılabilir.

**Y10. Görüntü işleme ana thread'de, upload sıkıştırmasız**
- **Kanıt:**
  - `OpenCVPlugin.kt:17,86`: tam çözünürlükte bilateralFilter Android main looper'da çalışıyor.
  - `crop_bloc.dart:60-61,183-184`: senkron `readAsBytesSync`.
  - `omd_loading.dart:913`: UI isolate'ında base64.
  - `rest_api_http_service.dart:14-17`: timeout yok.
- **Düzeltme:**
  - `MEM/lib/core/utils/image_upload_compressor.dart` mantığını `Isolate.run` içinde uygula: uzun kenar yaklaşık 2000 px, JPEG kalitesi 85.
  - Multipart ve `onSendProgress` ekle.
  - Hata olursa dosyayı sakla ve "Tekrar dene" sun.

**Y11. Vendored tarayıcı eski ve `lib/` içinde**
- **Kanıt:** `vendor/flutter_document_scanner/flutter_document_scanner_android/android/build.gradle:5,28,45,51`: Kotlin 1.8.20, compileSdk 33, minSdk 16, `com.quickbirdstudios:opencv:4.5.1`.
- **Düzeltme:**
  - Memora'nın fork'unu `packages/` altına al (org.opencv 4.12.0, camera ^0.12.0+1; doğrulandı).
  - Önce SMAP'e özgü değişikliklerin diff'ini al.
  - 16 KB hizalamasını `zipalign -c -P 16` ile doğrula.

**Y12. iOS 1024 ikonunda alfa kanalı var**
- **Kanıt:** `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png` ve `pubspec.yaml:78-81`.
- **Düzeltme:** Kare ve opak bir kaynak kullan, `remove_alpha_ios: true` ver, Android için adaptive icon ekle.

**Y13. Crash raporlama yok**
- **Kanıt:** `main.dart:30-36`'da hata yakalayıcı yok.
- **Düzeltme:** Faz 0'ın sonunda Crashlytics bootstrap'ini kur.

**Y14. Kullanılmayan bağımlılıklar ve bloc'un transitive kullanımı**
- **Kanıt:** camerawesome, image_picker, image, jpeg_encode, web_socket_channel ve cupertino_icons hiç import edilmiyor. flutter_inappwebview ve google_sign_in yalnızca ölü dosyalarda. bloc `pubspec.yaml`'da tanımlı değil ama `main.dart:2`'de import ediliyor.
- **Düzeltme:** Bu paketleri kaldır. BlocObserver ve `context.read` için bloc importlarını sil; `context.read` provider'dan zaten geliyor.

**Y15. Ortam ayrımı yok, URL'ler dağınık**
- **Kanıt:** 16 hardcoded URL noktası, 5 farklı origin (bkz. `dio_client.dart:17`, `api_constants.dart:14` ve UI dosyalarında yaklaşık 10 görsel URL'si).
- **Düzeltme:** Faz 1.3'teki AppEnv ve ImageUrlBuilder.

### Orta

- **O1. deleteCoach coachId göndermiyor.** `repository/profile_repository.dart:35-41`'de `queryParams` oluşturuluyor ama `get`'e verilmiyor (doğrulandı). Düzeltme: `queryParameters: queryParams`.
- **O2. Koç drill-down ekranlarında studentId kayboluyor.**
  - Kanıt: `analytics_screen.dart:31` repository'yi studentId ile kuruyor. Gidilen ekranlar onu studentId olmadan yeniden kuruyor: `my_test_result_detail_screen.dart:37`, `lesson_detail_page.dart:42`, `subject_detail_page.dart:31`, `edebiyat_lesson_detail_page.dart:217/327/1098/1719/1809`.
  - Düzeltme: Kısa vadede repository'yi constructor ile geçir. Faz 1'de "görüntülenen öğrenci" bağlamı session scope'ta tutulsun. Backend'de sahiplik kontrolü (IDOR) doğrulansın.
- **O3. Hesap silme yerel veriyi temizlemiyor ve GET ile yapılıyor.** `account_settings_screen.dart:203-236`, `auth_remote_data_source.dart:82-85`. Düzeltme: logout ile aynı temizliği yap; backend `DELETE` kullansın.
- **O4. Logout ve hesap değişiminde eski veri kalıyor.** `home_provider.dart:47-95` app genelinde yaşıyor; `schedule_list_page.dart:64-65`'teki `bagItemsStr` global. Düzeltme: logout'ta session scope'u düşür; kullanıcı verisini uid ile ayır.
- **O5. Offline açılışta kullanıcı login'e atılıyor.** `auth_repository_impl.dart:59-63` her hatada `setLoggedIn(false)` yapıyor. Düzeltme: iyimser açılış (`SLP/lib/services/auth_service.dart:107-158`); ağ hatası oturumun geçersiz olduğu anlamına gelmez.
- **O6. Rol string'leri tutarsız.** `root_screen.dart:75,79` `'coach'` ile, `:135` var olmayan `'teacher'` değeriyle karşılaştırıyor (doğrulandı). `user_model.dart:24`'te `?? 'student'` fallback'i var. Düzeltme: `enum UserRole`; bilinmeyen rol gelirse hata ekranı göster, sessizce öğrenci UI'ı açma.
- **O7. Yükleniyor, boş ve hata durumları karışık.** `home_students_cards.dart:19` ve `home_lessons_cards.dart:31` boş listeyi "yükleniyor" sayıyor. `login_provider.dart:28-41` SnackBar'da stack trace gösteriyor. `my_test_result_detail_screen.dart:183,213` ham exception metnini gösteriyor. Düzeltme: AsyncStateView ve `AppException.displayMessage`.
- **O8. Bilinmeyen ders id'sinde çökme.** `home_lessons_cards.dart:107`'de `orElse: () => {}` sonrası `selectedLesson['name']` String'e atanıyor ve TypeError fırlatıyor (doğrulandı). Düzeltme: `lesson_navigation_helper.dart` ile tekilleştir ve null-safe yap.
- **O9. Cookie Documents dizininde ve yedeğe giriyor.** `dio_client.dart:32-40`; AndroidManifest'te `allowBackup` varsayılan değerde. Düzeltme: Application Support dizinine taşı, yedekten hariç tut veya `allowBackup=false` yap.
- **O10. Sosyal giriş butonları çalışmıyor.** `social_sign_up_content.dart:98` ve `login_screen.dart:174-177`. Düzeltme: v1'de gizle ya da Google ile Apple'ı birlikte sun (App Store kuralı 4.8).
- **O11. Yön kilidi sızıyor ve iPad hedefleniyor.** Vendor `document_scanner.dart:214-216`, `build()` içinde portrait kilidi koyuyor ve geri almıyor. `project.pbxproj` `TARGETED_DEVICE_FAMILY "1,2"`. Düzeltme: kilidi `main`'e taşı; v1'in iPhone-only olup olmayacağına karar ver.
- **O12. Kopyalanmış bileşenler ve god widget'lar.** SubTopicDetailPage 2 kez, LessonBar 3 kez tanımlı. `edebiyat_lesson_detail_page.dart` 2.652 satır. Faz 2'de çözülür.
- **O13. Ana ekranda "yakında" kalabalığı.** Koç ana ekranındaki 6 karonun 4'ü stub (`home_menu_grid.dart:176-226`). Matematik ve Geometri "web sitesini kullanın" dialog'u açıyor (`lesson_navigation_helper.dart:32-41`). Düzeltme: gizle ya da tek bir ComingSoonSheet kullan. Backend'e bağlanmadan "haber ver" denmesin.
- **O14. Erişilebilirlik.** Kodda hiç Semantics yok. Kamera FAB'ı etiketsiz (`custom_bottom_nav_bar.dart:235-264`). Turuncu üzerine beyaz metin 2,94:1 kontrastta. Düzeltme: Faz 1.13 component kit ve Faz 2.12.

### Düşük

- **Asset ve splash:** Paket 67 MB asset taşıyor. Native splash yapılandırılmamış, `LaunchImage` şablon PNG'si.
- **Analyzer:** `flutter analyze` 307 bulgu veriyor; 17'si `use_build_context_synchronously`.
- **Sürüm ve kimlik:** `pubspec.yaml`'da sürüm 1.0.0+1 ve açıklama şablon metin. Android etiketi "smap", iOS "Smap".
- **Repo:** README şablon, git geçmişi tek commit.

---

## 4. Yol haritası

**Temel ilke: dikey dilim.** Faz 2'de her ekran UI ile birlikte DTO, repository (Either), VM, l10n anahtarları ve golden testiyle taşınır. `Map<String,dynamic>` üzerine yeni UI yazılmaz.

### Faz 0: Acil düzeltmeler ve güvenlik (1 hafta, 6–8 iş günü)

| # | Ne | Neden | Kaynak | Efor | Bağımlılık |
|---|---|---|---|---|---|
| 0.1 | Git hijyeni: branch modeli; `.gitignore`'a `env/*.json`, `key.properties`, `*.jks`. Ölü dosyalardaki "modified" değişiklikleri karara bağla. | Geçmiş tek commit, review imkânı yok. | `SHP/.gitignore` | S | – |
| 0.2 | Login prefill'ini kaldır, test hesabını devre dışı bırak. | K1 | – | S | Backend |
| 0.3 | Info.plist'e Türkçe kamera izin metni, `CFBundleDevelopmentRegion=tr`, `ITSAppUsesNonExemptEncryption=false`. Kullanılmayan paketleri sil (camerawesome, image_picker, image, jpeg_encode, web_socket_channel, flutter_inappwebview, google_sign_in, cupertino_icons); flutter_image_compress kalsın. Ölü dosyaları sil (`views/auth`, `views/main_webview`, `views/onboarding`, `services/google_auth_service.dart`, `socket_constants.dart`, `throttler`, `optic_requests` kopyaları). bloc importlarını kaldır. | K2, Y14 | – | S | – |
| 0.4 | Sahte veri ve akışları kaldır: +18.2%, %75 meta satırı, `mock()`. Ödeme, Kayıtlı Kartlar ve Bildirimler menüden çıksın. Şifre değiştir ve şifremi unuttum API'ye bağlansın ya da gizlensin. Sahte kullanıcı adı kontrolü ve sosyal giriş butonları gizlensin. | K4, Y1, Y5, O10 | – | M | §7 S7, S8 |
| 0.5 | KVKK onay sürümlerini register body'sine ekle; yasal dokümanlar yüklenemezse kayıt kapalı olsun. | Y2 | – | S | §7 S6 |
| 0.6 | print ve debugPrint'i AppLogger'a çevir, `avoid_print` lint'ini aç. | Y3 | `MEM/lib/core/services/app_logger.dart` | S | – |
| 0.7 | `StudentModel.password` alanını kaldır. | Y4 | – | S | §7 S4 |
| 0.8 | Hata paketi: deleteCoach parametresi; `getTotalInfoCard` DioClient'a; tek UserProvider; `home_lessons_cards.dart:107` null-safe; hesap silmede temizlik; `'teacher'` yerine rol enum'u; drill-down'a studentId geçirme. | O1, Y7, Y8, O8, O3, O6, O2 | – | M | – |
| 0.9 | OMR acil önlemler: rest_api Dio'ya timeout (connect 15 sn, send/receive 60 sn), host'u config'den okuma, mümkünse cookie jar'ı paylaşma. | K3 (kısmi) | – | S | §7 S2 |
| 0.10 | Tarayıcıyı Memora'nın fork'uyla değiştir (SMAP diff'ini yeniden uygula), `packages/` altına taşı. İzin reddi için "Ayarları Aç" ekranı; portrait kilidini `main`'e al. | Y9, Y11, O11 | `MEM/lib/vendor/flutter_document_scanner`, `MEM/lib/core/utils/open_app_settings.dart`, `MEM/lib/features/scan/presentation/scan_page.dart` | M | 0.3 |
| 0.11 | Release imzası, applicationId/bundle ID kararı, ikonda alfa kaldırma. | K5, Y12 | `SHP/android/app/build.gradle.kts` | S | §7 P6 |
| 0.12 | Firebase (dev ve prod projeleri) ve Crashlytics bootstrap: refactor başlamadan sahayı görmek için. | Y13 | `MEM/lib/main.dart` (L26-71), `MEM/lib/core/utils/flutter_error_filters.dart`, `SHP/lib/main_initializer.dart` | S | Firebase hesabı |

### Faz 1: Altyapı temeli (4–5 hafta; redesign'dan önce şart)

| # | Ne | Neden | Kaynak | Efor | Bağımlılık |
|---|---|---|---|---|---|
| 1.1 | Hedef klasör yapısını kur ve CLAUDE.md/AGENTS.md yaz. 31 stub'ı sil. `lib/views/optic_mark_detection_view`'ı `features/scan`'e taşı (bu adımda yalnızca taşıma). `lib/repository` ve `lib/http_service` Faz 2'de dilim dilim emekliye ayrılır. | Hangi katmanın gerçek olduğu bugün belli değil. | `SHP/AGENTS.md`, `MEM/CLAUDE.md` | S | 0.3 |
| 1.2 | Lint ve CI temeli: very_good_analysis kademeli açılır (vendor ve generated hariç tutulur). Shoplist'in CI'ındaki flutter job'u alınır: lockfile, analyze, test. Kırık `widget_test.dart` silinir, yerine DI smoke testi gelir. | Refactor'un güvenlik ağı. | `SHP/analysis_options.yaml`, `SHP/.github/workflows/ci.yml`, `SHP/test/dependency_inj/injection_container_test.dart` | M | 0.1 |
| 1.3 | Env/flavor: AppEnv (apiBaseUrl, omrBaseUrl, cdnBaseUrl, appStoreId), `--dart-define-from-file`. Android'de dev/prod productFlavor, iOS'ta xcconfig ve scheme, flavor'a göre Firebase plist. 16 URL noktası ve bir ImageUrlBuilder AppEnv'den beslenir. | Staging yok; URL'ler 13 dosyaya dağılmış. | `SHP/lib/core/config/app_config.dart` (+ `SHP/test/core/config/app_config_test.dart`), `SHP/ios/scripts/apply_firebase_config.sh`, `SHP/ios/Flutter/dev.xcconfig` | M | 0.11, 0.12 |
| 1.4 | Bootstrap: MainInitializer, runZonedGuarded, native splash preserve, ilk frame'den sonra ertelenmiş servis başlatma. | Açılış hızı ve hata yakalama. | `SHP/lib/main_initializer.dart`, `MEM/lib/core/startup/post_frame_startup.dart`, `SLP/lib/main.dart:67-262` | S | 0.12 |
| 1.5 | DI: fazlı get_it composition root, repository kayıtları, `session` scope. | Repo'lar widget içinde `new`leniyor. | `MEM/lib/dependency_injection/{injection_container,repository_registrations,session_scope_registration}.dart` | M | 1.4 |
| 1.6 | Hata modeli: AppException, AppErrorCode, ErrorCategory, EitherOr. `error_messages.dart` yerine AppErrorCode'dan l10n anahtarına eşleme. SMAP'in kontrolsüz cast yapan `dartz_extension.dart:4-5`'i değiştirilir. | Hata modeli tutarsız. | `MEM/lib/core/errors/*`, `MEM/lib/core/extensions/dartz_extension.dart` | S | – |
| 1.7 | Network: tek NetworkService (Dio/vexana), auth interceptor (cookie ya da bearer), typed request sınıfları, `api_extension` fold. 401'de zorunlu çıkış. `http` ve rest_api_package kaldırılır. OMR uçları multipart request sınıfı olur. | 3 HTTP yığını, 401 yönetimi yok, K3. | `MEM/lib/core/network/*`, `MEM/lib/config/api/requests/base_request_model.dart`, `MEM/lib/config/api/requests/photos_requests.dart` (multipart L60-80), `SLP/lib/core/network/token_manager.dart` | L | 1.3, 1.5, 1.6; §7 S1 |
| 1.8 | SessionManager, UserRole enum ve TokenStore. UserProvider, AppStartNotifier ve HomeProvider'daki global state session scope'a taşınır. İyimser açılış; logout ve hesap silmede tam temizlik. | Y8, O4, O5, O6 | `MEM/lib/services/session_manager.dart`, `SHP/lib/services/session_manager.dart` (sıralama ve rollback), `SLP/lib/services/auth_service.dart:107-158` | M | 1.5, 1.7 |
| 1.9 | Router: auto_route; guard zinciri Force > Onboarding > Auth > Role. Öğrenci ve koç için ayrı AutoTabsRouter shell, typed route argümanları, global navigatorKey. Nav notifier'lar, named route'lar ve RootScreen'in 3 ayrı kompozisyonu silinir. | 3 ayrı navigasyon mekanizması; deep link ve push yönlendirmesi bugün imkânsız. | `MEM/lib/config/router/app_router.dart`, `SHP/lib/app/router/guards/auth_guard.dart`, `SHP/lib/app/router/stack_router_x.dart`, `MEM/lib/features/main/main_shell.dart` | L | 1.8 |
| 1.10 | Codegen: dart_mappable ve build.yaml. Auth, user, exam ve OMR DTO'larıyla başlanır; kalanlar Faz 2'de ekran ekran eklenir. | Map tabanlı veri katmanı runtime'da kırılıyor. | `SHP/build.yaml`, `SHP/lib/core/mappable/` | M | 1.2 |
| 1.11 | Design token'ları. Spec'teki renk tablosu doğrudan token kaynağı olur: mihr_ui ve SmapColors ThemeExtension (navy ve orange skalaları, D/Y/B semantik renkleri, 9 ders rengi, grafik serileri; light ve dark). Plus Jakarta Sans tipografisi, AppMotion, ThemeService, context extension'ları. Kontrast notu: turuncu (#FF6600) üzerine beyaz metin 2,94:1 olduğu için CTA'da koyu turuncu tonu veya navy metin kullanılmalı. | ~1.300 renk referansı, dark mode yok. | `SHP/lib/core/theme/sepello_colors.dart`, `SHP/lib/core/theme/app_motion.dart`, `SHP/lib/core/services/theme_service.dart`, `SHP/lib/core/extensions/context_extensions.dart`, `SLP/lib/core/theme/sleepia_theme.dart`, `mihr_ui paketi (pub)` | M | Claude Design token çıktısı |
| 1.12 | l10n altyapısı: l10n.yaml (şablon app_tr.arb, ayrıca app_en), `context.l10n`, LocaleService, ToastText. | 264 literal; navigasyon görünen etikete bağlı. | `SHP/l10n.yaml`, `MEM/lib/services/locale_service.dart`, `MEM/lib/core/services/toast_service.dart` | S | – |
| 1.13 | Shared UI kit ve component galerisi. Liste aşağıda. Her bileşen için golden testi (light, dark, metin ölçeği 1.3). | Spec'teki bileşen kütüphanesi; kopyalanmış widget'lar. | `SHP/lib/shared/ui/*`, `SHP/lib/core/services/toast_service.dart`, `MEM/lib/shared/reactive_widgets/busy_overlay.dart`, `SHP/lib/features/debug/component_gallery_view.dart` | L | 1.11, 1.12 |
| 1.14 | MVVM konvansiyonu ve pilot: stacked'e geçiş. Auth ve onboarding VM'e taşınır ve VM testi yazılır. Provider ChangeNotifier'lar kademeli olarak dönüştürülür. | 231 setState; test edilemeyen logic. | `MEM/lib/features/home/presentation/home_viewmodel.dart`, `SHP/test/features/auth/presentation/login_viewmodel_test.dart` | M | 1.5, 1.9 |

1.13'teki bileşenler:
- AppButton, AppField, AppCard, SectionHeader, LargeTitle/AppTopBar
- StatTile, TopicProgressBar (LessonBar'ın 3 kopyasının yerine), DYBBar (yığılmış yatay bar), DYBBadge, SubjectChip
- SegmentedTabs, WeekStrip/AppCalendar (2 takvimin yerine)
- AppSheet, AppConfirmSheet, ComingSoonSheet
- AsyncStateView (AppStateBlock ve Skeleton ile), EmptyState
- ToastService, BusyOverlay

### Faz 2: Redesign, ekran ekran (7–9 hafta)

**Her ekranın "bitti" tanımı:**
- DTO, repository (Either) ve VM hazır.
- Ekranda ham `Color(0x`, `TextStyle(` ve string literal kalmamış.
- AsyncStateView ile loading, empty ve error durumları var.
- Semantics etiketleri eklenmiş.
- Golden testi ve analytics event yer tutucuları yazılmış.

**Sıralama mantığı:**
- 2.1 Onboarding ve Auth küçük bir iş; guard'ları ve component kit'i doğrular.
- 2.2 Ana ekran en çok görülen ekran.
- 2.3 OMR çekirdek değer olduğu için erken.
- 2.4–2.5 Analiz zinciri OMR sonucundan beslenir.
- 2.6 sonrası içerik ve yardımcı ekranlar.

| # | Ekran (spec §) | Kodda ne değişir | Efor | Bağımlılık |
|---|---|---|---|---|
| 2.1 | Onboarding, Giriş, Kayıt, Şifremi Unuttum (§1–2) | İki onboarding tek VM'de birleşir (rol, alan, kamera izni primer'ı). Login ve kayıt VM'e taşınır; `register_form.dart` (16 setState) bölünür. Şifremi unuttum ancak API varsa açılır. Referans: `SLP/lib/features/onboarding/presentation/onboarding_viewmodel.dart`, `MEM/lib/features/onboarding/presentation/onboarding_viewmodel.dart` | M | 1.9, 1.13 |
| 2.2 | Shell, bottom nav, Anasayfa (§3) | `custom_bottom_nav_bar` erişilebilir olur; kamera FAB'ına etiket. Hero'daki YKS geri sayımı yerel hesaplanır. Son deneme özeti. Derslerim şeridi ve TYT/AYT bottom sheet'i (`home_lessons_cards` ile `lesson_navigation_helper` tekilleşir). Haftalık WeekStrip. "Bugün" kartı, "Eksiklerin haritası" ve elmas/coin backend verisi gelene kadar flag ile kapalı. Hızlı erişimde yalnızca canlı özellikler. | L | 2.1 |
| 2.3 | Kamera ve OMR akışı (§4) | `omd_loading.dart` (3 ekran, 1.081 satır) ve `omd_result_flow_view.dart` (1.663 satır) VM'lere bölünür. ScanJob durum makinesi: sıkıştır > yükle > doğrula > sonuç. Sıkıştırma Isolate'ta; ilerleme ve retry var, hata olursa görüntü saklanır. "İşleniyor" adımları ve sonuç "wow" ekranı. Referans: `MEM/lib/services/generation_service.dart` (iş kuyruğu), `MEM/lib/core/utils/image_upload_compressor.dart` | L | 1.7, 0.10 |
| 2.4 | Deneme Detay (§6) | `my_test_results_detail_widgets.dart` (1.495 satır) ve `my_test_result_detail_screen.dart` bölünür. DYBBar, 5 sütunlu soru ızgarası ve filtre, konu analizi kartları. Ders adları kesilmez. | L | 2.3 |
| 2.5 | Analizlerim: Genel, Denemelerim, Analiz (§5) | `analytics_view_provider` BuildContext'ten arındırılır, `dispose` eklenir. fl_chart ile dolgulu net grafiği ve hedef net çizgisi. StatTile'lardaki trend değeri yalnızca backend veriyorsa gösterilir. Harita sekmesi §7-S8'e bağlı; o zamana kadar ComingSoonSheet. | L | 2.4 |
| 2.6 | Derslerim, Ders detay, Konu detay (§7) | `edebiyat_lesson_detail_page.dart` (2.652), `subject_detail_page`, `lesson_detail_page` ve `lesson_bar` tek bir LessonDetail ve TopicDetail'e indirilir; ders tipi config ile seçilir. `lesson_constants`'taki ObjectId'ler backend kataloğundan gelir. | L | 1.10 |
| 2.7 | Kartlarım (§8) | appinio_swiper ile flutter_card_swiper'dan biri seçilir, diğeri kaldırılır. | M | 1.13 |
| 2.8 | Programım ve Takvim (§9) | Global `bagItemsStr` yerine session scope'ta ScheduleService. Arama ve filtre gerçekten çalışır. | M | 1.8 |
| 2.9 | Hesap (§11) | `account_settings_screen.dart` (1.179 satır, 21 setState) VM'e taşınır. Profil ve şifre gerçek API'ye bağlanır. "Hesabımı Sil" `DELETE` ve onay sheet'iyle (`SHP/lib/features/account/deletion/`). Sözleşmeler ekranı (`contracts_screen` zaten iyi bir örnek). Ödeme, Kartlar ve Paywall Faz 3.4 kararına bağlı. | M | 1.8 |
| 2.10 | Gelen Kutusu ve Koç Görüşmeleri (§10) | `interviews_screen.dart` (1.088 satır) VM'e ve bileşenlere bölünür. | M | 1.13 |
| 2.11 | Koç modu (§12) | Düz `my_students` ve `my_interviews` klasörleri katmanlara ayrılır. Türkçe-duyarlı arama (I/ı/İ/i). Stub karolar kaldırılır. Bakılan öğrencinin bağlamı session scope'ta tutulur (O2). | M | 1.8, 2.5 |
| 2.12 | Durum ekranları, erişilebilirlik ve metin ölçeği (§13) | Her ekranda AsyncStateView, 48 dp dokunma hedefleri, metin ölçeği 1.3'te golden testi. Erişilebilirlik spec'i takip edilir. | M | Sürekli |

Not: spec §11'deki "Kayıtlı Kartlarım (Visa/Mastercard)" ve "Yeni Kart Ekle", dijital abonelik için App Store 3.1.1 ve Play ödeme politikasıyla çelişir. Faz 3.4 kararı verilmeden kodlanmamalı.

### Faz 3: Büyüme (4–6 hafta, Faz 2 ile kısmen paralel)

| # | Ne | Neden | Kaynak | Efor | Bağımlılık |
|---|---|---|---|---|---|
| 3.1 | Analytics facade'ı ve SMAP event sözlüğü, route observer, `user_type` user property'si. PII yok (KVKK, reşit olmayan kullanıcılar). Events: `scan_started`, `scan_succeeded`, `scan_failed{reason}`, `exam_result_viewed`, `coach_student_added`, `paywall_viewed{placement}`, `purchase_completed`. | Bugün funnel verisi hiç yok. | `SHP/lib/core/services/analytics/{analytics_service,analytics_events}.dart`, `MEM/lib/core/services/analytics_route_observer.dart` | S–M | 1.4 |
| 3.2 | Remote config: backend `GET /public-config` ve AppConfig dikeyi. Flag'ler: `minSupportedVersion*`, `omrEnabled`, `freeScanLimit`, `paywallEnabled`, coming-soon özellik flag'leri, `supportEmail`. | Kill switch ve sürüm alt sınırı. | `SLP/lib/services/app_config_service.dart`, `SLP/lib/data/repositories/app_config_repository_impl.dart`, `SLP/lib/config/api/requests/app_config_requests.dart`, `SLP/lib/domain/models/app_config/public_config_dto.dart` | M | §7 S10 |
| 3.3 | Force update: servis, guard, sayfa, resume'da yeniden kontrol (AppLifecycleListener), `parseMinVersion` testi. | OMR ve API sözleşmesi değişince eski istemciler engellenebilmeli. | `SLP/lib/services/force_update_service.dart`, `MEM/lib/features/force_update/presentation/force_update_page.dart`, `MEM/lib/config/router/app_router.dart` (L102-122) | S | 3.2, 1.9 |
| 3.4 | IAP ve paywall. Önce iş modeli kararı (§7-P1). IAP seçilirse: IapService, PremiumService ve PurchaseFlow, trial_period (+ testi), LegalLinks, session scope'ta EntitlementService. Backend 402/429 dönünce paywall açılır. Kayıtlı kart ekranı tamamen kaldırılır. | Mock ödeme UI'ı; mağaza ödeme kuralları. | `MEM/lib/services/iap_service.dart`, `SLP/lib/services/premium_service.dart`, `SLP/lib/shared/purchase/purchase_flow.dart`, `SLP/lib/services/trial_period.dart`, `SLP/lib/services/price_format.dart`, `MEM/lib/core/constants/legal_links.dart` | L | Karar ve backend `/iap/*` |
| 3.5 | Push: FCM, REST `/devices`, NotificationRouter (oturum açılana kadar bekletme), primer sheet, ön planda gelen bildirim toast olarak. Route'lar: `exam_result_ready`, `coach_assigned_exam`, `interview_scheduled`, `subscription_expiring`. | Koç ile öğrenci arasındaki döngü. | `SHP/lib/features/notifications/{notification_service,notification_router,notification_primer_sheet}.dart`, `SLP/lib/services/push_notification_service.dart` | M | 1.9; §7 S10 |
| 3.6 | StudyReminderService: haftalık çalışma slotları, YKS geri sayımı, sessiz saatler. | Tutundurma (retention). | `SLP/lib/services/bedtime_reminder_service.dart`, `SHP/lib/features/notifications/presentation/quiet_hours_sheet.dart` | S–M | 3.5 |
| 3.7 | Rating: başarılı tarama ve sonuç görüntüleme sonrası `registerPositiveAction`. | Mağaza puanı. | `SLP/lib/services/review_service.dart` | S | 3.1 |
| 3.8 | Deep link ve koç davet kodu: app_links, InviteCode (ABCD-EFGH formatı), `/join/{code}` → guard'lardan sonra eşleştirme. | Koç-öğrenci eşleştirmesi. | `SHP/lib/features/sharing/invite_code.dart`, `SHP/lib/features/notifications/notification_router.dart` | M | 1.9, backend |
| 3.9 | Offline tarama kuyruğu ve cache-first: ConnectivityService, LocalStore (Hive CE), OmrUploadQueue outbox'ı, OfflineStrip. Analiz ve deneme listeleri önce cache'ten gösterilir. | Okulun zayıf Wi-Fi'ında tarama; sahadaki asıl risk. | `SLP/lib/services/connectivity_service.dart`, `SLP/lib/services/local_store.dart`, `SLP/lib/services/sleep/sleep_sync_service.dart:24-90`, `SHP/lib/features/main/main_view.dart` (OfflineStrip) | L | 2.3 |
| 3.10 | A/B: ExperimentService (+ testi); paywall ve onboarding varyantları. | Dönüşüm optimizasyonu. | `SLP/lib/domain/services/experiment_service.dart`, `SLP/test/experiment_service_test.dart` | S | 3.2 |

### Faz 4: Kalite (sürekli; ayrıca 2 hafta toparlama)

| # | Ne | Neden | Kaynak | Efor | Bağımlılık |
|---|---|---|---|---|---|
| 4.1 | Saf unit testler: net hesabı (4 yanlış 1 doğruyu götürür), puan ve sıralama formatı, `AppException.fromError`, force update parser'ı, AppEnv çözümü, InviteCode, ScanJob durum makinesi. | Kritik iş mantığında hiç test yok. | `SHP/test/core/config/app_config_test.dart`, `SLP/test/trial_period_test.dart` | M | Faz 1 |
| 4.2 | VM ve repository testleri (mocktail, http_mock_adapter): status code'dan AppErrorCode'a eşleme, 401'de çıkış. | Regresyon koruması. | `SHP/test/features/auth/presentation/login_viewmodel_test.dart` | M | 1.7 |
| 4.3 | Golden testleri: kit (light, dark, metin ölçeği 1.3), DYB bar, soru ızgarası, OMR sonuç ekranı. | Görsel regresyon. | – | M | 1.13 |
| 4.4 | CI'ı genişlet: codegen diff, golden, `core/theme` dışındaki `Color(0x` sayacı (hedef 0), build smoke testi. Flavor başına release workflow (Codemagic veya fastlane), dSYM ve sembol yükleme. | Manuel release süreci. | `SHP/.github/workflows/ci.yml`, `SHP/ios/scripts/upload_crashlytics_symbols.sh`, `SLP/tool/bump_build_version.dart` | M | 1.2 |
| 4.5 | Performans: OpenCV ağır işleri ana thread dışına (fork içinde) ya da ML Kit Document Scanner / VisionKit değerlendirmesi. cached_network_image. RootScreen'deki Consumer4 rebuild'ini kaldır; sekmeler lazy kurulsun. | Y10; düşük donanımlı Android cihazlarda ANR. | `SLP/lib/features/home_shell/home_shell.dart:44-60` | M | 2.3 |
| 4.6 | Asset diyeti: 67 MB'tan WebP'ye, 22 kopya dosyanın ve mojibake dosya adlarının temizliği; yazar fotoğrafları CDN'den gelsin. | Kurulum boyutu. | – | M | 1.3 |
| 4.7 | Release hijyeni: PrivacyInfo.xcprivacy, Data Safety formu, native splash, `.puro.json` ile Flutter sürüm sabitleme, README. | Mağaza uyumu. | `SLP/ios/Runner/PrivacyInfo.xcprivacy`, `SHP/.puro.json` | S | 0.11 |
| 4.8 | Erişilebilirlik denetimi: tarama akışı VoiceOver ve TalkBack ile uçtan uca. | O14 | – | S–M | 2.12 |

---

## 5. Referans applerden doğrudan taşınabilecek modüller

| Kaynak | SMAP'teki hedef | Uyarlama |
|---|---|---|
| `MEM/lib/core/errors/{app_error_code,error_category,app_exception,errors}.dart` | `lib/core/errors/` | `error_messages.dart` yerine l10n eşlemesi. Domain hataları: OmrFormNotDetected, ScanQuotaExceeded, CoachSeatLimit. |
| `MEM/lib/core/extensions/dartz_extension.dart` | `lib/core/extensions/dartz_extension.dart` | Mevcut kontrolsüz cast'lerin (L4-5) yerini alır. |
| `MEM/lib/core/network/{network_service,auth_interceptor,base_response_model,base_error_model}.dart` ve `MEM/lib/core/extensions/api_extension.dart` | `lib/core/network/` | Cookie oturumu sürerse CookieManager ve 401 handler kullanılır; refresh, backend kararına göre. |
| `MEM/lib/config/api/requests/base_request_model.dart` (+ multipart için `photos_requests.dart`) | `lib/config/api/requests/` | auth, exam, omr, analysis, weekly, coach, cards ve profile istek dosyaları. |
| `MEM/lib/domain/models/common/list_response_dto.dart` | `lib/domain/models/common/` | – |
| `SLP/lib/core/network/token_manager.dart` | `lib/core/network/token_store.dart` | JWT'ye geçilirse aynen; cookie kalırsa sadeleştirilmiş SessionStore. |
| `MEM/lib/dependency_injection/{injection_container,repository_registrations,session_scope_registration}.dart` | `lib/dependency_injection/` | Session scope'ta rol bazlı servisler. |
| `MEM/lib/services/session_manager.dart` (sıralama: `SHP/lib/services/session_manager.dart`) | `lib/services/session_manager.dart` | UserRole, rollback, push kaydını silme. |
| `MEM/lib/config/router/app_router.dart`, `SHP/lib/app/router/guards/auth_guard.dart`, `SHP/lib/app/router/stack_router_x.dart` | `lib/app/router/` | RoleGuard ve OnboardingGuard eklenir. |
| `SHP/lib/core/config/app_config.dart` (+ `SHP/test/core/config/app_config_test.dart`) | `lib/core/config/app_config.dart` | apiBaseUrl, omrBaseUrl, cdnBaseUrl. |
| `SHP/lib/main_initializer.dart`, `MEM/lib/core/utils/flutter_error_filters.dart`, `MEM/lib/core/startup/post_frame_startup.dart` | `lib/main_initializer.dart`, `lib/core/startup/` | Custom key'ler: role, flavor. |
| `MEM/lib/core/services/app_logger.dart` | `lib/core/services/app_logger.dart` | Release'de warning ve error seviyeleri Crashlytics.log'a. |
| `SHP/lib/core/services/toast_service.dart` ve `SHP/lib/shared/ui/feedback/app_toast.dart` | `lib/core/services/`, `lib/shared/ui/feedback/` | Router navigatorKey ile. |
| `MEM/lib/shared/reactive_widgets/busy_overlay.dart` | `lib/shared/reactive_widgets/` | – |
| `SHP/lib/shared/ui/feedback/{app_state_block,app_skeleton}.dart`, `SHP/lib/shared/ui/sheets/app_confirm_sheet.dart`, `SHP/lib/shared/ui/buttons/app_button.dart` | `lib/shared/ui/` | SMAP token'larına bağlanır. |
| `SHP/lib/core/theme/{sepello_colors,app_motion}.dart`, `SHP/lib/core/services/theme_service.dart`, `SHP/lib/core/extensions/context_extensions.dart` | `lib/core/theme/smap_colors.dart` vb. | D/Y/B ve 9 ders rengi eklenir. |
| `SHP/lib/features/debug/component_gallery_view.dart` | `lib/features/debug/` | `GALLERY` dart-define ile açılır. |
| `SHP/lib/core/services/device_preferences.dart` | `lib/core/services/` | SMAP anahtarları; `user_data` prefs'ten çıkarılır. |
| `SLP/lib/services/local_store.dart` | `lib/core/storage/local_store.dart` | OMR kuyruğu. |
| `SLP/lib/services/connectivity_service.dart` ve OfflineStrip (`SHP/lib/features/main/main_view.dart`) | `lib/core/services/`, `lib/shared/ui/` | – |
| `SLP/lib/services/sleep/sleep_sync_service.dart` (outbox deseni) | `lib/features/scan/data/omr_upload_queue.dart` | – |
| `MEM/lib/core/utils/image_upload_compressor.dart` (ve `SHP/lib/services/image_upload_service.dart`) | `lib/features/scan/data/image_compressor.dart` | ~2000 px, `Isolate.run`. |
| `MEM/lib/vendor/flutter_document_scanner` | `packages/flutter_document_scanner` | SMAP diff'i yeniden uygulanır. |
| `MEM/lib/core/utils/open_app_settings.dart` ve `MEM/lib/features/scan/presentation/scan_page.dart` (kamera kullanılamıyor UI'ı) | `lib/features/scan/presentation/` | – |
| `MEM/lib/services/generation_service.dart` (iş kuyruğu deseni) | `lib/features/scan/domain/scan_job_service.dart` | – |
| `SLP/lib/services/app_config_service.dart`, `SLP/lib/data/datasources/app_config/*`, `SLP/lib/data/repositories/app_config_repository_impl.dart`, `SLP/lib/domain/repositories/app_config_repository.dart`, `SLP/lib/domain/models/app_config/public_config_dto.dart`, `SLP/lib/config/api/requests/app_config_requests.dart` | `lib/features/app_config/` | Backend `/public-config` gerekir. |
| `SLP/lib/services/force_update_service.dart` ve `MEM/lib/features/force_update/presentation/force_update_page.dart` | `lib/features/force_update/` | Resume'da kontrol ve parser testi. |
| `SLP/lib/domain/services/experiment_service.dart` (+ `SLP/test/experiment_service_test.dart`) | `lib/domain/services/` | – |
| `SLP/lib/services/review_service.dart` | `lib/services/review_service.dart` | App Store ID AppEnv'den. |
| `SHP/lib/core/services/analytics/{analytics_service,analytics_events}.dart` ve `MEM/lib/core/services/analytics_route_observer.dart` | `lib/core/services/analytics/` | SMAP event sözlüğü. |
| `SHP/lib/features/notifications/{notification_service,notification_router,notification_primer_sheet}.dart` | `lib/features/notifications/` | Firestore cihaz yazımı yerine REST `/devices`. |
| `SLP/lib/services/bedtime_reminder_service.dart` | `lib/features/notifications/study_reminder_service.dart` | – |
| `MEM/lib/services/iap_service.dart`, `SLP/lib/services/premium_service.dart`, `SLP/lib/shared/purchase/purchase_flow.dart`, `SLP/lib/services/trial_period.dart` (+ test), `SLP/lib/services/price_format.dart`, `MEM/lib/core/constants/legal_links.dart` | `lib/features/premium/` | Rol bazlı entitlement. |
| `SHP/lib/features/sharing/invite_code.dart` | `lib/features/coach_pairing/invite_code.dart` | Aynen. |
| `SHP/lib/features/account/deletion/` | `lib/features/profile/account_deletion/` | `DELETE` endpoint'i. |
| `MEM/lib/services/locale_service.dart`, `SHP/l10n.yaml` | `lib/services/`, proje kökü | Şablon tr. |
| `SHP/analysis_options.yaml`, `SHP/build.yaml` | Proje kökü | `packages/` ve generated dosyalar hariç tutulur. |
| `SHP/.github/workflows/ci.yml` (yalnızca flutter job) | `.github/workflows/ci.yml` | – |
| `SHP/android/app/build.gradle.kts` (flavor ve imza guard'ı), `SHP/ios/scripts/{apply_firebase_config,upload_crashlytics_symbols}.sh`, `SHP/ios/Flutter/{dev,prod}.xcconfig` | `android/`, `ios/` | – |
| `SLP/tool/bump_build_version.dart` | `tool/` | – |
| `SLP/ios/Runner/PrivacyInfo.xcprivacy` | `ios/Runner/` | SMAP'in API kullanımına göre düzenlenir. |

---

## 6. Ürün tarafı öneriler

- **Streak ve oyunlaştırma.** Spec'teki hero'da "elmas/coin" var; bunun backend'de gerçek bir karşılığı olup olmadığı belirsiz.
  - Şablon olarak Sleepia'nın streak ve badge dikeyi alınabilir: `SLP/lib/config/api/requests/streak_requests.dart`, `SLP/lib/features/badges/`.
  - Streak'i "günün görevi" tamamlanınca saydırın: tarama, kart tekrarı veya konu okuma.
  - Ödüller kozmetik olsun; net ve puan verisine dokunmasın.
- **Hedef netler.** Onboarding'de hedef bölüm ve hedef net alınsın. Bu, analiz grafiğindeki hedef çizgisini (spec §5) ve ders bazında "hedefe kalan net" göstergesini besler. Backend'de bir hedef alanı gerekir.
- **Soru çözüm videoları.** Deneme Detay > Sorular'da hücreye dokununca bir sheet açılsın (spec §6). `question_detail_page.dart` zaten var. Asıl engel içerik lisansı (§7-P9).
- **Offline.** Faz 3.9'daki kuyrukla sınıfta toplu tarama yapılabilir. Son analizler ve bilgi kartları offline okunabilmeli; OMR yüklemesi bağlantı gelince otomatik gitmeli.
- **Ana ekran widget'ı.** home_widget paketiyle YKS geri sayımı, bugünün görevleri ve "Tara" kısayolu. "Bugün" verisi hazır olduktan sonra (Faz 2.2) yapılmalı.
- **Bildirim stratejisi.**
  - Öncelik sırası: işlemsel bildirimler (sonuç hazır, koç deneme veya ödev atadı, görüşme), sonra hatırlatıcılar (haftalık program, deneme günü), en son pazarlama (minimum düzeyde).
  - Varsayılan sessiz saat 22:00–08:00.
  - İzin primer'ı ilk başarılı taramadan sonra gösterilsin.
  - Kullanıcıların çoğu reşit olmadığı için agresif pazarlama push'u gönderilmesin.
- **Koç paneli.** Bugün koç ana ekranındaki 6 karonun 4'ü stub. Öncelik sırası:
  1. Risk sıralı öğrenci listesi (son 2 denemede net düşüşü, 7 gündür tarama yok).
  2. Öğrenci bazında deneme karşılaştırma.
  3. Toplu deneme/ödev atama.
  4. Davet koduyla eşleştirme.
  5. Görüşme notları.

  Koçun sınıf adına toplu tarama yapması OMR kuyruğuyla mümkün olur.
- **Matematik ve Geometri yerel içeriği.** Bu iki ders bugün "web sitesini kullanın" dialog'u açıyor (`lesson_navigation_helper.dart:32-41`). YKS'nin en çok sorusu bu derslerden geldiği için native konu sayfaları öncelikli olmalı.
- **Harita (imza ekran).** Konu bazında ustalık verisi gerekir (doğru oranı ve son karşılaşma). İlk sürüm, Analiz sekmesindeki konu verisinden basit bir node haritası olabilir. Veri yoksa ComingSoonSheet gösterilsin.

---

## 7. Açık sorular

### Backend

- **S1. Oturum modeli.** Cookie (`connect.sid`) mi kalacak, yoksa JWT access/refresh'e geçiş planlanıyor mu? Oturum süresi ve yenileme yöntemi ne?
- **S2. OMR sunucusu.** `api_constants.dart:14`'teki placeholder'ın gerçek host'u ne? Sunucu kimliği oturumdan mı doğruluyor, yoksa body'deki `user`'a mı güveniyor? Ana API ile aynı oturumu (aynı domain ya da token) paylaşabilir mi?
- **S3. OMR upload.** Multipart kabul ediliyor mu? Maksimum boyut ve çözünürlük ne? `success:false` hangi durumlarda dönüyor, hata kodları neler?
- **S4. Öğrenci şifresi.** `/coach/getMyStudents` `password` alanı döndürüyor mu, hash mi düz metin mi? Projection düzeltmesi ne zaman yapılır?
- **S5. Koç drill-down.** Uçlar studentId olmadan ne döndürüyor? Sahiplik kontrolü (IDOR) var mı?
- **S6. KVKK onayları.** Register endpoint'i KVKK, şartlar ve gizlilik sürümlerini hangi alan adlarıyla bekliyor? Reşit olmayan öğrenciler için veli onayı akışı gerekiyor mu?
- **S7. Hesap uçları.** Şifre değiştirme, şifremi unuttum (kod gönderimi), kullanıcı adı müsaitlik kontrolü ve `DELETE` ile hesap silme uçları var mı?
- **S8. Analiz verileri.** Şunlardan hangileri backend'de gerçekten mevcut?
  - "Geçen aya göre değişim"
  - Konu tamamlama yüzdesi
  - Alt başlık, madde ve kart sayıları
  - Harita için konu ustalığı
  - "Bugün" görevleri
  - Elmas/coin
  - Ders başına eksik sayısı
- **S9. Ders kataloğu.** `lesson_constants.dart`'taki 27 ObjectId kalıcı mı? Bir ders kataloğu endpoint'i verilebilir mi?
- **S10. Yeni uçlar.** `/public-config`, `/devices` (push), `/iap/validate` ve `/iap/subscription` eklenebilir mi? Hub backend'deki Sleepia uçları yeniden kullanılabilir mi?
- **S11. Ortamlar ve CDN.** Staging ortamı var mı? Görsel/CDN host'u tek mi? Şu an iki farklı TLD varyantı kullanılıyor.
- **S12. Test hesabı.** Login'de önceden doldurulmuş hesap gerçek bir kullanıcı mı? Devre dışı bırakıldı mı?

### Ürün

- **P1. Ödeme modeli.** Öğrenciye app içi abonelik mi (IAP zorunlu), web'den satış mı (o zaman mobilde satış UI'ı olmaz), yoksa koça B2B/koltuk satışı mı? Koç, öğrencisinin aboneliğini öder mi?
- **P2. Spec'teki ödeme ekranları.** "Kayıtlı Kartlarım", "Yeni Kart Ekle" ve fatura listesi kaldırılsın mı? Fatura için gerçek bir kaynak (backend, e-arşiv) var mı?
- **P3. Sosyal giriş.** Google ve Apple ile giriş v1'de olacak mı?
- **P4. Cihaz ve yön.** iPad ve yatay mod desteklenecek mi, yoksa v1 iPhone-only ve portrait mi?
- **P5. İngilizce.** Gerekli mi? ARB altyapısı her durumda kurulacak.
- **P6. Kimlik ve hesap.** Kalıcı applicationId ve bundle ID ne olacak (bugün şablon değer `com.smap.smap`)? Mağaza hesabının sahibi kim?
- **P7. "Yakında" özellikleri.** SmapLab, Gelen Kutusu, SmapCoach, Müfredat, Kaynak Takibi ve Harita için bir takvim var mı? Yoksa v1'de gizlensinler mi?
- **P8. Analytics ve yaş.** Analytics ve Crashlytics için KVKK aydınlatma metni güncellenecek mi? 13–18 yaş politikası ne olacak?
- **P9. İçerik.** Matematik ve Geometri içerikleri native gelecek mi? Soru çözüm videoları için içerik lisansı var mı?