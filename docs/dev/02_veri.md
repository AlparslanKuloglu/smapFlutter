# 02 · Veri katmanı: ağ, hata modeli, DTO, yeni uç, oturum, çevrimdışı

Bu bölüm uygulamanın backend ile nasıl konuştuğunu anlatır: tek HTTP istemcisi (`NetworkService`), hata modeli, yapılandırma ve bayraklar, gevşek JSON'u okuyan DTO'lar, yeni bir uç eklemenin adımları, oturumun ve cihaz verisinin nerede tutulduğu, çevrimdışı davranış ve önbellekli servisler. Projeyi ilk kez açan deneyimli bir Flutter geliştiricisi (ve AI ajanları) için yazıldı; bir repository, DTO, istek ya da oturum davranışına dokunmadan önce okunmalıdır.

Yollar repo köküne göredir; satır numarası verilmez, adı `grep` ile bulun. Uygulamanın iskeleti (açılış, DI, router, guard'lar) [01_mimari.md](01_mimari.md)'de, ekranların bu veriyi nasıl kullandığı [03_ekran.md](03_ekran.md)'de, codegen ve test araçları [05_araclar.md](05_araclar.md)'dadır. "Spec §6.3 #N" atfı, `docs/spec/SMAP_Flutter_Spec.md` içindeki backend bağımlılıkları tablosunun N. maddesidir; sunucudan beklenenler ve ekran yazılırken çıkan ek sorular [../Backend_Sorulari_Ek.md](../Backend_Sorulari_Ek.md)'dedir. Kod yorumlarında geçen "S4", "S7", "S10" gibi kodlar eski backend soru numaralarıdır; karşılığı spec §6.3'tedir.

---

## 1. Katmanlara genel bakış

```
View → ViewModel (context'siz)
        └─ servis (ListenableServiceMixin; session scope)   lib/features/<f>/application/*_service.dart
            └─ Repository  (Either<AppException, T>)          lib/features/<f>/data/*_repository.dart
                └─ İstek fabrikası (BaseRequest<T>)           lib/features/<f>/data/requests/*_requests.dart
                    └─ NetworkService.send  (tek Dio)         lib/core/network/network_service.dart
                        └─ decoder: DTO.fromBody (dart_mappable + hook'lar)
                                                              lib/features/<f>/data/dtos/ (+ generated/)
                            └─ mapper (DTO → domain)          lib/features/<f>/data/mappers/
```

- **`domain/`**: bağımsız değer tipleri (`ExamDetail`, `ExamPage`, `LessonMissing` gibi) ve sabitler. Kural (AGENTS.md): domain sabitleri kendi feature'ında kalır, `core/`'a taşınmaz.
- **`application/`**: saf mantık ve servisler (`LessonsService`, `CoachStudentsService`, `ScheduleService`). Birim testlenir.
- **`data/`**: HTTP ve JSON okuma. UI metni içermez.
- ViewModel'ler get_it'e kaydedilmez. Servisler `viewModelBuilder` içinde `locator`'dan verilir ([01_mimari.md](01_mimari.md) §3).
- Uygulamada **tek HTTP istemcisi** vardır: `NetworkService`. Eski istemci ve eski yardımcılar silindi; yeni istek yazarken başka istemci kurmayın.
- **Dosya düzeni feature'dan feature'a değişir.** Mapper katmanı (`data/mappers/`) yalnız exams, analytics, cards ve lessons'ta vardır. Auth, account, coach ve schedule DTO/`LegacyEnvelope` okumasını doğrudan repository ya da istek dosyasında yapar; scan düz dosyalardan oluşur (`scan_repository`, `scan_requests`, `scan_camera`, `scan_vision`, `scan_gallery_picker`). Yeni feature'da en yakın benzerini (veri sözleşmesi uyuşan) örnek alın: zarfı `success` bayrağıyla gelen okuma uçları için exams, yazma/liste uçları için coach ya da schedule.

---

## 2. NetworkService (`lib/core/network/network_service.dart`)

### 2.1. Kurulum ve davranış

- `NetworkService` tek bir `Dio` sarar. Kurulumda şunlar verilir: `baseUrl = config.apiBaseUrl`, `followRedirects: false`, `validateStatus` yalnız 2xx.
- Kimlik doğrulama **çerez tabanlıdır**: backend `connect.sid` çerezini kullanır. `CookieManager(cookieJar)` interceptor'ı bu çerezi taşır. Kavanoz `NetworkService.createPersistentCookieJar()` ile `<documents>/.cookies/` altında kurulur (§8.3).
- Debug modda `MaskingLogInterceptor` eklenir (`logTraffic ?? kDebugMode`). Maskeleme `LogMasker.defaultSensitiveKeys` listesiyle yapılır: `cookie`, `setcookie`, `connectsid`, `session`, `password` ve türevleri, `token` ve türevleri, `secret`, `code`, `otp`, `userdata` vb. Uzun metin ve listeler kısaltılır.
- `send<T>()` hiçbir zaman fırlatmaz, `Either<AppException, T>` döner. Üç yakalama dalı vardır:
  - decoder hatası → `AppException.parse` (kod `unknown`);
  - `DioException` → `mapDioException` (§3);
  - diğer her şey → `AppException.from`.
- **Otomatik yeniden deneme (retry) yoktur.** `lib/core/network/` içinde retry geçmez. `BaseRequest.resolveBody` yorumu "her deneme için çağrılır" der; `FormData` tek kullanımlık olduğu için body her `send` çağrısında yeniden kurulur.
- `send` iptal (`CancelToken`) ve ilerleme (`onSendProgress`, `onReceiveProgress`) alır; optik okuma "Vazgeç" ve yükleme yüzdesi için bunları kullanır.
- `NetworkService.dio` ham istemciyi açar ve `MultipartRequest` / `UploadFile` / `NetworkTimeouts.upload` tanımlıdır; bugün feature kodunda kullanılmaz (OMR gövdesi base64 JSON'dur, §12). Yeni ihtiyaç için hazırdır.

### 2.2. Zaman aşımları

`NetworkTimeouts` sınıfı (spec §6.3 #2):

| Alan | Değer |
|---|---|
| `connect` | 15 sn |
| `receive` | 30 sn |
| `send` | 30 sn |
| `upload` (`MultipartRequest`) | 60 sn |

`BaseRequest.sendTimeout` ve `receiveTimeout` istek başına bunları ezer. Örnekler:

- `AuthRequests.login` ve `RegisterRequests.register`: 15/15 sn.
- `AuthRequests.checkUser` ve `logout`: receive 8 sn.
- OMR istekleri: `SmapDurations.submitTimeout` (60 sn) ve `readTimeout` (30 sn), `lib/core/theme/app_motion.dart`.

### 2.3. Çoklu host

`ApiHost.api` yolu `baseUrl`'e ekler. `ApiHost.omr` ise tam URL kurar: `'${_config.omrBaseUrl}${request.path}'`. OMR host'u backend'de hâlâ açık soru olduğu için varsayılan olarak API host'una eşittir (`AppConfig.resolve`, spec §6.3 #1).

### 2.4. Başarı kuralı

- Yalnız 2xx başarıdır. 3xx **başarı değildir**: backend oturum yokken login sayfasına yönlendirir.
- Gerçekten yönlendirmeyle başarılı olan çağrılar bunu `successStatuses: {302}` ile bildirir: login, logout ve register.

```dart
// lib/features/auth/data/requests/auth_requests.dart
static BaseRequest<LoginResponse> login({
  required String username,
  required String password,
}) => BaseRequest<LoginResponse>(
  method: HttpMethod.post,
  path: '/student/login',
  body: <String, String>{'username': username, 'password': password},
  requiresSession: false,
  successStatuses: const {302},
  sendTimeout: const Duration(seconds: 15),
  receiveTimeout: const Duration(seconds: 15),
  decoder: LoginResponse.fromBody,
);
```

### 2.5. Gövde çözme

Backend bazen JSON'u JSON olmayan content-type ile yollar. `_decodeBody` ham string'i `{`/`[` ile başlıyorsa bir kez `jsonDecode` eder. Boş gövde `null` olur. Düz metin metin olarak kalır. Decoder'lar bu yüzden `Object?` alır (`Map`, `List`, `String` ya da `null`).

---

## 3. Hata modeli

### 3.1. AppException ve AppErrorCode

- `AppException` (`lib/core/errors/app_exception.dart`): repository'lerin döndürdüğü tek hata tipidir. Alanlar: `code`, `message`, `statusCode`, `path`, `serverMessage`, `cause`, `stackTrace`.
- **Kullanıcıya gösterilecek metin taşımaz.** UI mesajı `code`'dan seçer. `message` ve `serverMessage` yalnız log ve doğrulama metinleri içindir.
- `AppErrorCode` değerleri: `network`, `timeout`, `offline`, `unauthorized`, `sessionExpired`, `forbidden`, `notFound`, `validation`, `server`, `maintenance`, `cancelled`, `unknown`.
- Her kodun bir `l10nKey`'i vardır; metinler `lib/l10n/arb/errors_tr.arb`'dedir. UI, kodu bir `switch` ile metne çevirir (örnek: `loginErrorText` in `lib/features/auth/presentation/login/login_error_text.dart`).
- Yardımcılar: `isRetryable` ("Tekrar Dene" göster), `requiresSignIn`, `isSilent`; `AppException.isOffline`, `isSessionExpired`, `isCancelled`.

### 3.2. Durum kodu eşlemesi (`lib/core/network/dio_error_mapper.dart`)

`mapStatus`, `requiresSession` ve `sessionExpiredStatuses` ile birlikte şöyle çalışır:

| Durum | `requiresSession: true` | `requiresSession: false` |
|---|---|---|
| 401 / 403 (`kDefaultSessionExpiredStatuses = {401, 403}`) | `sessionExpired` | 401 → `unauthorized`, 403 → `forbidden` |
| 3xx | `sessionExpired` | `unknown` ("unexpected redirect") |
| 404 | `notFound` | `notFound` |
| 400 / 409 / 422 | `validation` | `validation` |
| 408 | `timeout` | `timeout` |
| 503 | `maintenance` | `maintenance` |
| diğer ≥500 | `server` | `server` |
| 429 | `server` | `server` |
| listede olmayan (ör. 410, 418) | `unknown` | `unknown` |

`serverMessage`, yanıt gövdesindeki `message` alanıdır (yalnız metinse, boş değilse ve 300 karakteri aşmıyorsa).

Bağlantı hataları şöyle eşlenir:

- Connect timeout ve cihaz çevrimdışı → `offline`; aksi halde connect timeout → `timeout`. Send/receive/transform timeout → `timeout`.
- DNS veya "network unreachable" (`_isNoRoute`) → `offline`. Cihaz çevrimdışı okunuyorsa (`deviceOnline == false`) her bağlantı hatası `offline`'dır.
- Reddedilen veya sıfırlanan bağlantı → `network` (bu sunucu tarafıdır). `badCertificate` → `network`.
- `cancel` → `cancelled`.

Cihazın bağlantı okuması (`deviceOnline`) yalnız **belirsiz bağlantı hatalarında** devreye girer. Yanıt veren bir 5xx hiçbir zaman `offline` olmaz: backend hatası "bağlantı yok" şeridi göstermemelidir. `AppErrorCode.offline` ile `server` bu yüzden ayrıdır.

### 3.3. Oturum düşmesi

`NetworkService._reportSessionExpiry`:

- Yalnız `requiresSession` olan bir istek `sessionExpired` alırsa `onSessionExpired` akışına `SessionExpiredEvent(path, statusCode)` yazılır.
- Olay oturum başına **bir kez** yayımlanır: eşzamanlı 401'ler tek olay üretir.
- `markSessionStarted()` yeniden silahlandırır. Bunu `pushSessionScope` ve `SessionManager` (restore ve signIn) çağırır.
- `SessionManager` olayı dinler ve durumu `signedOut(expired: true)` yapar (bkz. §9).

### 3.4. Either yardımcıları

- `lib/core/extensions/either_extensions.dart` (dartz `Either` için): `rightOrNull`, `leftOrNull`, `rightOr`, `when`, `onRight`, `onLeft`; `AppException` hataları için `errorCode`, `failedWith(code)`; `Future<Either>` zincirleri için `mapRight`, `bindRight`.
- `lib/core/errors/app_result.dart`: `typedef AppResult<T> = Either<AppException, T>` ve `guard` / `guardAsync` (fırlatabilen dosya ya da platform çağrıları için kenar sarmalayıcı; `NetworkService` bunlara ihtiyaç duymaz).

---

## 4. Yapılandırma (`lib/core/config/`)

### 4.1. AppConfig ve `--dart-define`

`AppConfig.fromEnvironment()` şu anahtarları okur (`String.fromEnvironment`). Hepsi isteğe bağlıdır; boş değer üretim varsayılanına düşer.

| Anahtar | Varsayılan |
|---|---|
| `API_BASE_URL` | `https://www.smaptr.com` |
| `OMR_BASE_URL` | API ile aynı |
| `CDN_BASE_URL` | `https://smaptr.com.tr` |
| `SUPPORT_EMAIL` | yok (satır gizlenir, adres uydurulmaz) |
| `YKS_DATE` | `2027-06-19` |
| `APP_STORE_ID` | yok (mağaza linki gizlenir) |
| `PLAY_PACKAGE` | `com.studentmap.smap` (uygulamanın mağaza kimliği) |

- Çalıştırma: `flutter run --dart-define-from-file=config/dev.json`. Şablon `config/dev.json.example`; gerçek `config/dev.json` git'te yoktur (`.gitignore`).
- Hatalı değer (şemasız URL, ISO olmayan tarih, geçersiz e-posta) debug'da `assert` ile patlar. Release'te varsayılana düşer.
- Gizli bilgi konulmaz: dart-define değerleri binary'den okunabilir.
- `AppConfig.resolve(...)` saf çözümleyicidir ve testler için açıktır (`test/core/config/app_config_test.dart`).
- Debug'a özgü başka define'lar: `THEME_MODE`, `SHELL_PREVIEW`, `SHELL_PREVIEW_TAB` (ortam), `SCAN_GALLERY` (simülatörde galeriden okutma; release'te hep `false`), galeri için `GALLERY_*` ([01_mimari.md](01_mimari.md) §2, [05_araclar.md](05_araclar.md)).

### 4.2. FeatureFlags (`lib/core/config/feature_flags.dart`)

Bayraklar derleme zamanı sabitidir. Kapalı özellik ya rota listesine eklenmez ya da giriş noktası çizilmez. Bayrak, ilgili endpoint'in indiği değişiklikte `true` yapılır.

| Bayrak | Değer | Neden |
|---|---|---|
| `forgotPasswordEnabled` | false | Kod gönder, doğrula ve yeni şifre uçları yok (spec §6.3 #7, D-18). Kapalıyken giriş ekranındaki bağlantı çizilmez ve `ForgotPasswordRoute` rota listesinde yoktur. Açmak için `ForgotPasswordRepository` locator'a kaydedilmeli. |
| `socialLoginEnabled` | false | Apple/Google asset'leri, paket ve sunucu ucu yok (§6.3 #17). |
| `programDeleteEnabled` | false | Program silme/iptal ucu yok (§6.3 #25). Kapalıyken "Programı İptal Et" düğmesi çizilmez. |
| `passwordChangeEnabled` | false | Şifre değiştirme ucu yok (§6.3 #8). Kapalıyken Hesap satırı çizilmez ve `PasswordRoute` listede yoktur. Açmak için `PasswordRepository` kaydedilmeli. |
| `notificationsEnabled` | false | Tercih ucu ve push yok (§6.3 #16, D-23). Ekran açık; tercihler cihazda tutulur, bilgi kutusu "planlı" der. |
| `omrEnabled` | **true** | Backend bakım bayrağı verene kadar açık (§6.3 #4). Kapalıyken "Okut" kamerayı açmaz, "Optik okuma şu an kapalı" sheet'i çıkar. |
| `offlineQueueEnabled` | false | Çevrimdışı fotoğraf kuyruğu yok. v1'de hata ekranı gösterilir (pano 4.5 kare 4). |
| `attentionListEnabled` | false | D-27 kurallarını hesaplayan uç yok (§6.3 #28, #29). Kapalıyken bölüm hiç çizilmez; "kimse dikkat gerektirmiyor" kartı kimsenin kontrol etmediği bir iddia olurdu. |
| `coachProgramWriteEnabled` | **true** | Koç, öğrencisi adına program kurar ve düzenler (Tur 12 A). Sunucunun `?studentId=` ile yazılanı öğrencinin hesabına işlediği varsayılır (T12.8, backend'e açık soru, `Backend_Sorulari_Ek.md` Y4). İşlemiyorsa `false` yapılır; Program sekmesi salt okunur davranışa döner ve `NewProgramRoute` öğrenciyle açılamaz. |

Bayrağı açmadan önce, bayrağın doc yorumundaki "Opening it also needs ..." satırını (repository kaydı, kuyruk vb.) okuyun. Bayrakların rota ve UI etkisi için [01_mimari.md](01_mimari.md) §10 tuzak 10.

---

## 5. dart_mappable: DTO + hook + generated

- `lib/core/mappable/hooks.dart` backend'in gevşek JSON'u için ortak hook'ları taşır:
  - `LenientIntHook`, `LenientDoubleHook` (virgüllü "12,5" okur), `LenientBoolHook`, `LenientStringHook`, `BlankToNullHook`, `LenientDateTimeHook`.
  - `IgnoreFieldsHook` (encode'da alan düşürür; bugün hiçbir DTO kullanmıyor).
- Skaler hook'lar yalnız **decode**'da (`beforeDecode`) çalışır. Okunamayan değeri değiştirmeden geçirirler; dart_mappable kendi tip hatasını verir.
- Bu hook'lar okunamayanı geçirdiği için tek bir tuhaf alan bütün cevabı düşürebilir. Bu yüzden feature'larda bir kat daha vardır: `OrNull` hook'ları. Bunlar "okunamıyorsa `null`" der:
  - `TextOrNullHook`, `IntOrNullHook`, `DoubleOrNullHook`, `BoolOrNullHook`, `DateOrNullHook`, `ObjectOrNullHook`, `CoachRefHook` (`lib/features/auth/data/dtos/lenient_hooks.dart`).
  - Liste ve iç içe hook'lar: `ObjectHook`, `MapListHook`, `PositionalMapListHook`, `StringListHook`, `IntListHook`, `IdRefHook` vb. (`lib/features/exams/data/dtos/lenient_list_hooks.dart`). Bunlara feature'a özel hook'lar eklenir: `exam_hooks.dart` (`KeepRawObjectHook`, `TopicAnalysisHook`, ...) ve `lesson_hooks.dart` (`ItemStatusHook`, `LessonMissingMapHook`, ...).
- **Dosya düzeni:** DTO dosyası `part 'generated/<ad>.mapper.dart';` içerir. Üretim `build.yaml` ile `lib/<yol>/generated/<ad>.mapper.dart` altına yapılır. Üretilen dosyalar git'te izlenir ve CI güncel olduklarını denetler.
- Üretim komutu: `dart run build_runner build -d`.
- `build.yaml` `renameMethods` ayarı **ters** çalışır: `fromJson`/`toJson` bir **Map** alır ve verir; string'li sürümler `fromJsonString`/`toJsonString`'dir. Bu yüzden `UserDto.fromJson(Map<String, dynamic>)` Map bekler ve `user.toJson()` Map döner (`jsonEncode`'a verilir).

Tipik DTO (`lib/features/lessons/data/dtos/lesson_answers.dart`):

```dart
@MappableClass(ignoreNull: true)
class SuccessResponse with SuccessResponseMappable implements ApiEnvelope {
  const SuccessResponse({this.success, this.message});

  factory SuccessResponse.fromBody(Object? data) {
    final map = bodyMap(data);
    if (map == null) return const SuccessResponse();
    return SuccessResponseMapper.fromJson(map);
  }

  @override
  @MappableField(hook: BoolOrNullHook())
  final bool? success;
  @override
  @MappableField(hook: TextOrNullHook())
  final String? message;
}
```

Notlar:

- Her alan nullable'dır; uydurma varsayılan verilmez. Eksik veri UI'da çizilmez (AGENTS.md: sahte veri yok).
- Sunucu anahtarı farklıysa `@MappableField(key: 'true', ...)` kullanılır. Örnek: `NetBreakdownDto.correct` için `key: 'true'` (`lib/features/exams/data/dtos/mock_exam_dto.dart`).
- Gizli alan (`password`, `__v`) DTO'ya hiç konulmaz. Böylece decode'da düşer ve `toJson` ile geri yazılamaz (`UserDto`, `CoachStudentDto`).
- Bir sunucu nesnesini aynen geri postalamak gerekirse `KeepRawObjectHook` ve `raw` alanı kullanılır (`ExamDefinitionDto.raw` → `getQuestion` gövdesi).

---

## 6. Cevap zarfları: iki desen

Legacy Node backend cevapları `{success, message, ...}` zarfındadır. İki bağımsız yardımcı vardır; hangi feature'ın hangisini kullandığını bilmek gerekir.

**A. `ApiEnvelope` + `requireSuccess`** (`lib/features/exams/data/api_support.dart`): her cevap DTO'su `ApiEnvelope` uygular ve repository `result.requireSuccess(path)` çağırır. Exams, analytics, lessons ve cards bunu kullanır.

- `success: true` → değer.
- `success: false` → `validation` (+ `serverMessage`).
- Bayrak yok (boş gövde, HTML) → `server`.

**B. `LegacyEnvelope`** (`lib/core/domain/legacy_envelope.dart`): decoder ham gövdeyi `LegacyEnvelope.read` ile sarar. Repository `isSuccess`, `isRejected`, `rejection(path)`, `unusable(path, detail)`, `object(key)`, `objects(key)`, `readList(key, decode)` ile anlamı kendi verir. Kayıt (`register`), account, coach ve schedule bunu kullanır. `message` okunurken `message` yoksa `msg` anahtarına bakılır (account uçları iki yazımı da kullanır). `readList` bozuk satırı atlar, bir satır yüzünden listeyi düşürmez.

**C. Login ve `checkUser`** kendi küçük DTO'larını kullanır (`LoginResponse`, `CheckUserResponse`) ve anlamı repository verir (§9).

`compactQuery(params, {studentId})` null ve boş değerleri URL'den çıkarır. Koç bir öğrencinin verisini okurken `studentId` query parametresi olarak eklenir. Her uç bunu onurlandırır mı? Sunucuya bağlı açık soru (spec §6.3 #33, `Backend_Sorulari_Ek.md` Y3); istemci tarafında doğrulanamaz.

---

## 7. Yeni uç (endpoint) nasıl eklenir

Örnek akış `GET /student/getMexamItemDetail` (exams) üzerinden anlatılır. Kendi feature'ınızın `data/` klasöründe aynı sırayı izleyin.

**Adım 1 – DTO / cevap sınıfı** (`data/dtos/<f>_answers.dart`)

- `@MappableClass(ignoreNull: true)` ile cevabı tanımlayın. Alanlara `OrNull` hook'ları koyun.
- `ApiEnvelope` uyguluyorsanız `success` ve `message` ekleyin.
- `fromBody(Object? data)` fabrikasında `bodyMap(data)` kullanın; null dönerse boş cevap verin.
- Ardından `dart run build_runner build -d` çalıştırın.

**Adım 2 – İstek fabrikası** (`data/requests/<f>_requests.dart`)

```dart
// lib/features/exams/data/requests/exam_requests.dart
static BaseRequest<ExamItemDetailResponse> itemDetail({
  required String mexamId,
  String? studentId,
}) => BaseRequest<ExamItemDetailResponse>(
  method: HttpMethod.get,
  path: '/student/getMexamItemDetail',
  query: compactQuery({'mexamId': mexamId}, studentId: studentId),
  decoder: ExamItemDetailResponse.fromBody,
);
```

Kontrol listesi:

- Herkese açık uç mu (login, register, yasal metinler `getLegalDocuments`, kullanıcı adı kontrolü `checkUsername`, OMR uçları)? O zaman `requiresSession: false`. Aksi halde 401 yanlışlıkla "oturum bitti" sayılır.
- Backend başarıyı 302 ile mi bildiriyor? O zaman `successStatuses: {302}`. Yoksa 302 "oturum düştü" okunur.
- Yazma işlemlerinde `studentId` eklenmez (`learnedItem`, `learnedCard`).
- Yükleme için `MultipartRequest`, farklı host için `host: ApiHost.omr`.
- Uzun sürebilen çağrılarda `sendTimeout` / `receiveTimeout` verin.

**Adım 3 – Mapper** (`data/mappers/<f>_mappers.dart`). DTO'dan domain nesnesine extension yazın:

```dart
extension NetBreakdownDtoMapping on NetBreakdownDto {
  DybCounts? get counts => dybOf(correct, wrong, pass);

  NetBreakdown toDomain() => NetBreakdown(net: net, counts: counts);
}
```

Eksik değer `null` (bilinmiyor) kalır, 0'a çevrilmez. Örnek: `LessonEntry.missing` null ise `SubjectOrdering.tileOrder` bunu sıfır sayar ama UI "bilinmiyor" ile "0"ı ayırır.

**Adım 4 – Repository metodu** (`data/<f>_repository.dart`)

```dart
Future<AppResult<ExamCardBreakdown>> getCardBreakdown({
  required String examId,
  String? studentId,
}) async {
  final result = await _network.send(
    ExamRequests.itemDetail(mexamId: examId, studentId: studentId),
  );
  return result
      .requireSuccess('/student/getMexamItemDetail')
      .map((response) => response.toDomain());
}
```

`Either` içinde kalın; `throw` etmeyin. "Cevap geldi ama kullanılamaz" durumlarını açıkça eşleyin. Örnek: `getQuestion`, `question` nesnesi yoksa `AppErrorCode.notFound` döner.

**Adım 5 – DI.** `registerXxxData(GetIt l)` içinde `registerLazySingleton`. Yeni repository ise `lib/features/<f>/<f>_module.dart`'a ekleyin; yeni modülse işlevi `lib/dependency_injection/injection_container.dart` içindeki `kDataModules` listesine ekleyin (ortak dosya, [01_mimari.md](01_mimari.md) §3.3). Servis kullanıcıya özelse `registerXxxSession` ve `kSessionModules` (§11).

**Adım 6 – Test.** Önce veri ve VM testleri yazılır (AGENTS.md "Definition of done"). Mevcut yardımcılar:

- `test/core/network/fake_adapter.dart`: `FakeAdapter.json(body, status:)`, `FakeAdapter.failing(...)`, `FakeAdapter(handler)`; `textResponse` ve `jsonResponse`; `adapter.last` ve `adapter.requests`.
- `test/features/exams/data/data_harness.dart`: `networkOver(adapter)`, `routedAdapter` (yol → gövde; bilinmeyen yol 404), `offlineAdapter()`. Exams, analytics, lessons ve cards veri testleri bunu paylaşır.
- Fikstürler: `test/features/exams/data/exam_fixtures.dart` (`tytResultJson`, `examsAnswer`, ...), `test/features/auth/data/auth_fixtures.dart` (`FakeBackend`, `FakeSecureStore`, `buildNetwork`).
- Oturum testleri: `test/services/session_harness.dart` (`SessionHarness`).

```dart
final adapter = FakeAdapter.json(examsAnswer([tytResultJson(), aytResultJson()]));
final repository = repositoryOver(adapter);
final result = await repository.getMyExams(page: 2);
// ...
expect(adapter.last.path, '/student/getMyMockExams');
expect(adapter.last.queryParameters, {'page': 2, 'perPage': 8});
```

Şu durumları mutlaka sınayın:

- Başarılı cevap.
- `success: false`.
- Boş gövde veya HTML gövde (→ `server`).
- Bozuk satırlar (atlanmalı).
- Çevrimdışı.
- İstek yolu, sorgu ve gövde.

---

## 8. Cihaz verisi

### 8.1. DevicePreferences (`lib/core/services/device_preferences.dart`)

- `SharedPreferencesWithCache` üstündedir; `runApp`'ten önce yüklenir. Okuma senkron, yazma `await`'li ama fırlatmaz.
- **Yalnız `allowedKeys`'teki anahtarlar** yüklenir ve okunur. Yeni anahtarı önce sabit olarak ekleyip kümeye koyun, doc yorumu yazın. Aksi halde okuma `null` döner, yazma yutulur; debug'da `assert(false)` patlar, release'te log'a uyarı düşer. Bu dosya ortak dosyadır ([../WORKFLOW.md](../WORKFLOW.md) §5).
- Anahtarlar: `ui.themeMode`, `onboarding.completed`, `onboarding.draft`, `device.installId`, `scan.cameraPrimerAnswered`, `scan.tutorialSeen`, `scan.cornersHintHidden`, `cards.skipLearnedConfirm`, `notif.primerAnswered`, `lessons.examType`, `analytics.favoriteExams`, `lessons.literatureSection`, `schedule.programView`, `notif.preferences`.
- Hesap verisi (kullanıcı JSON'u, çerez) buraya konmaz.
- AGENTS.md, özelliklerde `SharedPreferences.getInstance`'ı yasaklar. Tek meşru kullanım yerleri legacy göç sınıfları ve `SessionStore`'daki legacy anahtar temizliğidir (§8.2). **`tool/ui_rules.sh` bu kuralı denetlemez**; inceleme yakalar.

### 8.2. Oturum deposu ve güvenli depo

- `SecureValueStore` arayüzü; üretimde `FlutterSecureValueStore`. iOS'ta `first_unlock_this_device`: arka planda açılışta okunur, iCloud'a gitmez, başka cihaza geri yüklenmez.
- `SessionStore` (`lib/features/auth/data/session/session_store.dart`): son kullanıcı JSON'unu tek anahtarda (`smap.session.user`, `{"v":1,"user":{...}}`) saklar. Amaç "iyimser açılış": çevrimdışıyken de son kullanıcıyla açılmak.
- Okuma 3 kez denenir (300 ms arayla). Sürekli başarısızsa `null` döner ama silmez (Keychain açılışta geçici hata verebilir). Geçerli JSON değilse kayıt silinir.
- Oturumun kendisi **çerezdir**; bu depo yalnız kullanıcıyı önbelleğe alır. `clear()` önbelleği ve legacy oturum anahtarlarını (`user_data`, `isLoggedIn`, `connect_sid`, `bagItemsStr`) siler.
- `kMirrorLegacyUserData = false` (`lib/features/auth/auth_module.dart`): eski düz metin `user_data` kopyası artık yazılmaz; göç onu siler.

### 8.3. Legacy göçler ve çerez kavanozu

- **`LegacySessionMigration`** (`lib/features/auth/data/session/legacy_session_migration.dart`): eski `SharedPreferences['user_data']` (parola hash'li kullanıcı belgesi) güvenli depoya taşınır. Sıra: yaz → geri oku doğrula → düz kopyayı sil. Sonuçlar: `nothingToMigrate`, `migrated`, `secureStoreWins`, `corrupt`, `writeFailed`. Hiç fırlatmaz ve idempotenttir. Çerez dosyasına dokunmaz; böylece oturum açık kullanıcı açık kalır. Ölü anahtarlar (`isLoggedIn`, `connect_sid`) her durumda silinir. `SessionManager._restore` bunu ilk iş olarak çalıştırır.
- **`LegacyOnboardingMigration`** (`lib/features/startup/data/legacy_onboarding_migration.dart`): eski `onboarding_completed` bayrağı `DevicePreferences.onboardingCompletedKey`'e taşınır. Yeni değer doğrulanmadan eski anahtar silinmez. `false` bayrak silinir ve kullanıcı tanıtımı yeniden görür. Yeni uygulamada tamamlanmış bayrak asla geri alınmaz. `MainInitializer._initialize` içinde çalışır.
- **Çerez kavanozu:** `NetworkService.createPersistentCookieJar()` `<documents>/.cookies/` altında `PersistCookieJar` kurar. Yol ve biçim eski istemciyle aynıdır, bu yüzden güncellemede oturum korunur. **Bu yolu değiştirmeyin.**

---

## 9. Oturum ve kullanıcı verisi akışı

### 9.1. SessionManager (`lib/services/session_manager.dart`)

- Kök scope'ta, `registerSingleton` ile hemen oluşturulur (lazy değil): ilk istek patladığında `onSessionExpired` dinliyor olmalıdır.
- Durum `SessionState` sealed sınıfıdır (`unknown`, `restoring`, `signedIn(user, verified)`, `signedOut(expired)`). Router, `RouteRefresh` aracılığıyla `SessionManager`'ı dinler ([01_mimari.md](01_mimari.md) §5.4).
- Aynı anda tek `signIn`, tek `restore`, tek `revalidate` ve tek çıkış çalışır; tekrar çağrılar mevcut işe katılır ya da hata döner. Kimlik değişimlerini sayan bir `_epoch`, eski bir kontrolün sonucunun yeni durumu ezmesini engeller.

### 9.2. Açılış (`restore`)

1. Legacy göçü çalışır.
2. Çerez yoksa `signedOut` olur. Artakalan önbellek kullanıcısı silinir (iOS Keychain yeniden kurulumda yaşayabilir).
3. Önbellek kullanıcısı varsa hemen `signedIn(cached, verified: false)` olur, scope açılır. Cihaz çevrimiçiyse arka planda `revalidate()` çalışır.
4. Kullanıcı yok ama çerez varsa (yalnız çevrimiçiyse) `checkUser` ile sunucuya sorulur.
5. Çerez kavanozu okunamıyorsa "oturum yok" varsayılmaz (çerez var sayılır).

### 9.3. Giriş (`signIn`)

- `/student/login` yanıtına tek başına güvenilmez: ardından `checkUser` oturumu doğrulamalıdır. `AuthRepository.login`, gövdeyi okur (`LoginResponse.isAuthenticated`); gövdesi `success: false` olan ya da oturum kanıtı taşımayan yanıt `unauthorized` olur. 400/404 gibi istemci hataları da yanlış kimlik bilgisi sayılır (`unauthorized`); 403 `forbidden`, 5xx `server` kalır.
- Her adım başarısız olursa geri alınır: `_rollbackLogin` önce `logout` çağırır (best-effort), sonra çerezi siler.
- Login'in kabul edip `checkUser`'ın reddettiği durum `unauthorized` olur (bu bir "oturum süresi doldu" değil, başarısız girişlerdir).
- Aynı kullanıcı yeniden girerse açık scope korunur, başka biri girerse scope baştan kurulur (`_enterScopeFor`).

### 9.4. Çıkış (`signOut`, `completeAccountDeletion`)

- UI önce çıkar: durum hemen `signedOut`, böylece ViewModel'ler servislerden önce yok olur.
- Sonra, cihaz çevrimiçiyse sunucuya `logout` gider (8 sn zaman aşımı, hata temizliği durdurmaz).
- Sonra çerezler, önbellek, legacy anahtarlar ve DI scope temizlenir.
- `completeAccountDeletion` aynı temizliği `logout` çağrısı **yapmadan** yapar: oturum sunucuda artık yok. Silme çağrısını hesap ekranı yapar (`AccountRepository.deleteAccount`); bu metot yalnız yerel yarısıdır ve silme "bitti" ekranının "Tamam"ında çağrılır.

### 9.5. Oturum düşmesi

- Oturum gerektiren bir çağrı 401/403/3xx alınca `NetworkService` olay yayımlar, `SessionManager` durumu `signedOut(expired: true)` yapar ve **scope'u korur**. (Yeniden doğrulama sırasında `checkUser` oturumu reddederse de aynı geçiş olur.)
- Kullanıcı ekranında kalır. `SessionExpiredCoordinator` "Oturumun sona erdi" sheet'ini açar. Sheet'in tek düğmesi giriş ekranını mevcut ekranın üstüne açar; giriş başarılıysa auth guard onu kapatır ve kullanıcı olduğu yerde devam eder. Giriş yapmadan çıkarsa sheet yeniden sorar ([01_mimari.md](01_mimari.md) §5.5).

### 9.6. CurrentUserService (`lib/services/current_user_service.dart`)

- Kullanıcının reaktif değeridir (`ReactiveValue<UserDto?>`) ve **`session` scope'unda** yaşar (`registerAuthSession`). Böylece bir ViewModel önceki kullanıcıyı hiç okuyamaz.
- `SessionManager`'ı dinler. Çıkışta son kullanıcıyı bırakır: "oturum bitti" sheet'inin arkasındaki ekran verisini korur.
- `update(user)` önbelleğe yazar (`SessionManager.updateUser`), `refresh()` `/ajax/checkUser` ile yeniler.
- `role` → `UserRole` (`lib/core/domain/user_role.dart`). `fromLegacy` büyük/küçük harf duyarsızdır: `student`, `coach` ve `teacher` (koç sayılır). Bilinmeyen rol `unknown` olur ve "bilinmeyen rol" ekranına gider; sessizce öğrenci uygulamasını açmaz.

### 9.7. Session scope

Kapsamın ne zaman açılıp kapandığı [01_mimari.md](01_mimari.md) §3.2'de anlatılır. Veri açısından özet: kullanıcıya bağlı önbellekler `kSessionModules` ile kayıt olur (`CurrentUserService`, `LessonsService`, `LiteratureService`, `ScheduleService`, `CoachStudentsService`); kapsam düşünce hepsi `dispose` edilir. Böylece çıkıp başka hesapla giren kullanıcı öncekinin dersini, programını veya öğrenci listesini göremez.

---

## 10. Çevrimdışı davranış

- `ConnectivityService` (`lib/core/services/connectivity_service.dart`): `connectivity_plus` üstünde tek okuma. Bilinmeyen durum **çevrimiçi** sayılır (yanlış "çevrimdışı" indirmeleri durdurur). Captive Wi-Fi de çevrimiçi okunur; gerçek hatayı `NetworkService` bildirir.
- `online` (`ValueListenable<bool>`) ViewModel ve şerit içindir. `onlineChanges` ayrı değerlerin akışıdır. `isNotCellular`, yalnız hücresel bağlantı yoksa true döner.
- `NetworkService` bunu yalnız belirsiz bağlantı hatalarında kullanır (§3.2).
- `SessionManager`, çevrimdışıyken `revalidate` yapmaz ve sunucuyu aramaz. Başarısız bir kontrol (çevrimdışı, zaman aşımı, 5xx) durumu değiştirmez; kullanıcı önbellekle çalışmaya devam eder.
- **UI tarafı:** `AsyncSection.failed` (`lib/shared/ui/feedback/section_state.dart`) `offline` hatasını `SectionState.offline`'a, diğerlerini `error`'a çevirir. Veri varken bölüm `ready` kalır ve çevrimdışı şeridi (`OfflineStripController`, `lib/shared/ui/feedback/offline_strip_logic.dart`) durumu anlatır. Her yükleme 15 sn'lik iskelet sınırı altındadır (`AsyncSection.load` → `withSkeletonTimeout`, `SmapDurations.skeletonTimeout`). Bölüm durumları [03_ekran.md](03_ekran.md)'de.
- Çevrimdışı fotoğraf kuyruğu yoktur (`offlineQueueEnabled = false`).

---

## 11. Önbellekli servisler

Ortak kalıp:

- `ListenableServiceMixin` + `ReactiveValue`.
- `load()` tazeyse önbellekten yanıtlar, değilse çeker. `refresh()` / `forceRefresh: true` her zaman çeker.
- Süren çekime katılır, çift istek atmaz.
- Başarısız yenileme önceki veriyi **korur** ve hatayı raporlar.
- `dispose` scope ile birlikte çalışır.

| Servis | Tazelik | Not |
|---|---|---|
| `LessonsService` (`lib/features/lessons/application/lessons_service.dart`) | `freshFor` = 5 dk | Dersler ve eksik sayıları birlikte çekilir, biri düşse diğeri korunur. Koç farklı `studentId` verirse önce önceki öğrencinin verisi düşer. `markLearnedLocally` öğrenildi işaretinden sonra isteksiz sayaç düşürür. `_generation` sayacı eski çekimin sonucunu yok sayar. |
| `LiteratureService` (`lib/features/lessons/application/literature_service.dart`) | oturum boyunca | Edebiyat ağacı (dönem → alt başlık → yazar → eser); her seviye kendi `AsyncSection`'ında. "Öğrendim" buradan geçer (`PendingLearns` ile), kaydedilince `LessonsService.refresh()` çağrılır. |
| `CoachStudentsService` (`lib/features/coach/application/coach_students_service.dart`) | `staleAfter` = 5 dk | Yalnız koç kabuğunda dokunun. `addStudent` yeni öğrenciyi listeye ekler. `invalidate` / `clear` / `dispose`. |
| `ScheduleService` (`lib/features/schedule/application/schedule_service.dart`) | `staleAfter` = 2 dk | `studentId` başına `ScheduleSnapshot`; konu listesi (`mainSubjects`) oturum boyunca saklanır. Yazmalar sıraya girer (`_writeTail`). Bilinen sınır: yazma bitmeden başlayan bir yenileme eski veriyle yazma sonucunu geçici ezebilir. |

Geri Al için sunucuda uç olmadığından yazma isteği ekranda tutulur: `PendingLearns` (`lib/features/cards/application/pending_learns.dart`, kart "Öğrendim", 6 sn; `LiteratureService` de kullanır) ve `NoteDeleteHold` (`lib/features/coach/application/note_delete_hold.dart`, not silme). Pencere geçince istek gider; "Geri Al" gelirse hiç gitmez; ekrandan çıkarken `flush` kalanları gönderir.

---

## 12. Backend'in bilinen eksikleri

Tam liste `docs/spec/SMAP_Flutter_Spec.md` §6.3'tedir (41 madde); ekran yazılırken çıkan ek sorular [../Backend_Sorulari_Ek.md](../Backend_Sorulari_Ek.md)'dedir. Aşağıda istemcinin davranışını belirleyen başlıca açıklar, istemcide nerede göründükleriyle:

| §6.3 | Eksik veya açık soru | İstemcide nerede |
|---|---|---|
| #1 | OMR host'u belirsiz; `OMR_BASE_URL` verilmezse API host'unu paylaşır. | `app_config.dart`, `scan_repository.dart` |
| #2 | OMR yükleme biçimi (base64 mi multipart JPEG mi) ve zaman aşımı sorusu. Şimdilik eski base64 JSON biçimi. | `scan_requests.dart` |
| #4 | Optik okuma için bakım bayrağı ucu yok. | `feature_flags.dart` (`omrEnabled`) |
| #5 | Public config ucu (`/public-config`: zorunlu güncelleme, bakım) yok; `DisabledStartupGate` kayıtlı. | `startup_gate.dart`, `startup_module.dart` |
| #7, #8 | Şifre sıfırlama (kod gönder / doğrula / yeni şifre) ve şifre değiştirme uçları yok. | `forgot_password_repository.dart`, `password_repository.dart` |
| #9 | `questionsArrStr` yalnız `{order, type}` taşır; işaretlenen ve doğru şık gelmez. | `exam_detail.dart` |
| #11 | `updateStudent`: yeni alanları (avatar, sınıf, alan) kabul eder mi ve sunucu birleştirir mi. | `account_repository.dart`, `profile_update.dart` |
| #12 | Kullanıcı adı çakışmasının sözleşmesi belirsiz (metne bakılıyor); kullanıcı adı önerisi yok. | `register_outcome.dart`, `username_check.dart` |
| #13 | Yasal metinlerde tarih yok; sürümle onay kaydı yalnız tasarımda. `sendAcceptedVersions = true`; sunucu bilinmeyen alana itiraz ederse `false` yapılabilir. | `legal_document_dto.dart`, `register_requests.dart` |
| #15 | Koçluk kodu biçimi (`AAAA-0000`, tire sorusu). Legacy `deleteCoach` parametresini hiç göndermiyordu. | `coach_code.dart`, `account_requests.dart` |
| #16, #35 | Push ve bildirim tercihi ucu yok; "koç atadı" kategorisi v1'de karşılıksız. | `feature_flags.dart`, `notification_preferences.dart` |
| #17 | Sosyal giriş: Apple/Google uç ve asset'leri yok. | `feature_flags.dart` |
| #18 | `aimType` (2 EA, 3 SAY, 4 SÖZ) ve Dil eşlemesi açık; eski koç diyaloğunun değerleri yanlış olabilir. | `ayt_field.dart`, `study_track.dart` |
| #19 | Program tarih tutmaz; kapsam konuların günlerinden çıkarılır. | `program_span.dart` |
| #20, #23, #27 | Deneme listesi filtre (`nets`, `dates`) değer biçimleri doğrulanmadı; `sort` yok. | `exam_page.dart`, `exam_repository.dart` |
| #21 | "Eksik" sayıları için `getLessonsTotalMissing`; `studentId` desteği belirsiz. | `lessons_service.dart`, `lesson_content_repository.dart` |
| #22 | Ders başına toplam kart sayısı cevapta yok; toplam gösterilmez. | `card_totals.dart` |
| #24 | Öğrenildi veya favori için geri alma ucu yok; `addFavoriteMobil` tersine çeviren (toggle) uçtur, açıkça set etmez. | `card_repository.dart`, `card_requests.dart` |
| #25 | Program silme / iptal ve gün sıfırlama / kısmi güncelleme ucu yok. | `schedule_repository.dart`, `feature_flags.dart` |
| #26 | Analiz serisinde `itemName` alanı varsayım. | `net_series.dart` |
| #28, #29 | "Dikkat gerektirenler" ve öğrenci belgesinde son net/son deneme tarihi yok. | `attention_item.dart`, `coach_student_dto.dart` |
| #30 | "Mezun" (13) değeri ve koçun bunu gönderebilmesi açık. | `user_dto.dart`, `school_grade.dart` |
| #31 | Görüşmelerde toplam/sonraki sayfa işareti, metin araması, "kiminle" filtresi, görüşme düzenleme ve silme yok. | `interview_page.dart`, `interview_repository.dart` |
| #33 | Koç `studentId`'sini tüm uçlar onurlandırıyor mu belirsiz. | `exam_repository.dart`, `card_repository.dart`, `Backend_Sorulari_Ek.md` Y3 |
| #40 | Sunucunun yıldızı (`isStarred`) yok sayılır; favoriler cihazda tutulur. | `mock_exam_dto.dart` |
| #41 | Konu ikonları host'u (`smaptr.com/subjectIcons/`) CDN host'u mu belirsiz. | `main_subjects.dart` |
| T12.8 | Koç `?studentId=` ile yazdığı programı öğrencinin hesabına işliyor mu. | `feature_flags.dart` (`coachProgramWriteEnabled`), `Backend_Sorulari_Ek.md` Y4 |

---

## 13. Tuzaklar

1. **`requiresSession` unutulursa herkese açık uç oturumu düşürür.** Varsayılan `true`. Login, register, `checkUsername`, `getLegalDocuments` ve OMR uçları `false` yazılmalı. Yoksa yanlış şifre "oturum bitti" sheet'ini açar. Tersine, oturum gerektiren bir ucu `false` bırakırsanız 401 `unauthorized` görünür ve oturum akışı hiç tetiklenmez.
2. **302'yi başarı sanmayın veya başarıyı 302'den bekleyin.** Redirect takibi kapalı. Login, logout ve register `successStatuses: {302}` ister. Diğer her 302 "oturum yok"tur. Login 2xx/302 ile gelse bile gövde `success: false` olabilir; `LoginResponse.isAuthenticated` gövdeye bakar.
3. **`checkUser` tek doğruluk kaynağıdır.** Login cevabına güvenmeyin. Başarısız `checkUser`, login'i geri alır (çerezi siler).
4. **Oturum düşme olayı bir kez yayımlanır.** Yeni oturum başlatan kod `markSessionStarted()` çağırmalı. `pushSessionScope` ve `SessionManager` bunu yapar; elle oturum kuran her yeni kod yoluna eklemeyi unutmayın.
5. **Kullanıcıya ham hata gösterilmez.** `AppException.message` ve `serverMessage` UI metni değildir. Yalnız `validation` için `serverMessage` anlamlıdır. UI, `errors_*` ARB anahtarlarını `AppErrorCode`'dan seçer.
6. **Çevrimdışı ile sunucu hatası farklıdır.** 5xx yanıtı hiçbir zaman `offline` olmaz; yeni eşlemede bunu bozmayın.
7. **DTO alanını katı yazmayın.** Backend `12`, `"12"`, `"12,5"`, `""` ve obje karışımı yollar. Skaler hook'lar tek başına okunamayanı geçirir ve tek bozuk alan tüm cevabı düşürür; bu yüzden `OrNull` hook'ları kullanılır. Liste satırı bozuksa `readList` veya `MapListHook` atlar.
8. **Hook'lar encode'da çalışmaz.** `toJson` çıktısı sunucudan gelen biçimi garanti etmez. `SessionStore` ve OMR gövdesi `UserDto.toJson()` kullanır; bu bilinçli bir ödünleşimdir.
9. **`fromJson` bir `Map` alır.** `build.yaml` yeniden adlandırması yüzünden string ayrıştırma `fromJsonString`'dir. Yeni DTO yazarken karıştırmayın. Üretilen `.mapper.dart` dosyalarını git'e ekleyin ve DTO değişince `build_runner`'ı çalıştırın.
10. **Feature'lar arası import.** `exams`, `lessons`, `cards`, `analytics`, `schedule` ve `coach` DTO'ları `auth/data/dtos/lenient_hooks.dart`'ı; exams/lessons/cards/analytics ayrıca `exams/data/api_support.dart`'ı import eder. Dosyalardaki yorumlar bunları ileride `lib/core`'a taşımayı önerir. Taşımadan önce tüm import'ları güncelleyin; yeni uç yazarken kopyalamak yerine yeniden kullanın.
11. **Cihaz tercihleri çıkışta silinmez.** `DevicePreferences.clear()` hiçbir yerden çağrılmıyor. `analytics.favoriteExams`, `lessons.examType`, `notif.preferences`, `onboarding.draft` hesaba değil cihaza bağlıdır; aynı cihazda hesap değiştirince önceki kullanıcının favori sonuç kimlikleri ve bildirim tercihleri kalabilir. Hesaba özel yeni bir değer eklerseniz bunu hesaba katın ve çıkışta temizlemeyi düşünün.
12. **`DevicePreferences` izinli anahtar listesi.** Yeni anahtarı `allowedKeys`'e eklemeden kullanırsanız okuma `null` döner, yazma sessizce yutulur ve debug'da `assert` patlar.
13. **`SharedPreferences.getInstance` yasak, ama otomatik denetlenmiyor.** AGENTS.md yasaklar; `tool/ui_rules.sh` bu örüntüyü aramaz (denetlediği örüntüler: ham renk, `TextStyle(`, `fontSize:`, `Icons.`, diyalog ve `SnackBar`, `Navigator.push`, `print(`, `Widget _build`, sunumda ham `Duration(`, dosya boyu). Meşru kullanım yalnız legacy göç sınıfları ve `SessionStore`'daki legacy anahtar temizliğidir; başka yerde inceleme yakalamalıdır.
14. **Kod yorumundan değil istek dosyasından okuyun.** Görüşme tarihi `interview_requests.dart`'ta saat dilimsiz yerel zaman (`date.toLocal().toIso8601String()`) olarak gider; UTC'ye çevirmek her kayıtlı görüşmeyi cihaz farkı kadar kaydırır. Sunucunun UTC'yi kabul edip etmediği doğrulanmadı (`Backend_Sorulari_Ek.md` G1). Git geçmişi: `1fc4fec` ("görüşme tarihi legacy biçimine döndü").
15. **Sabit host.** `kSubjectIconBaseUrl` (`lib/features/lessons/domain/main_subjects.dart`) `AppConfig` dışında sabitlenmiş (`https://smaptr.com/subjectIcons/`), oysa CDN varsayılanı `smaptr.com.tr`'dir. Host değişirse iki yerde güncelleyin. OMR çağrıları `requiresSession: false` olduğundan çerez gerekmez; kullanıcı gövdede taşınır.
16. **OMR gövdesi tüm kullanıcı belgesini taşır.** `opticimage` ve `examrequest`, eski biçim korunduğu için oturumdaki kullanıcının JSON'unu (`user`) gönderir (`ScanJobService` → `UserDto.toJson()`). Sunucu yalnız `_id` ile yetinebiliyorsa küçültülmeli (`Backend_Sorulari_Ek.md` Y5, KVKK).
17. **Servis önbelleği ve scope.** Kullanıcıya özel önbelleği kök scope'a değil `kSessionModules`'a kaydedin (`registerXxxSession`). Yoksa çıkış yapan kullanıcının verisi sonrakine sızar. Koç servisleri öğrenci oturumunda lazy olduğu için maliyetsizdir; yalnız koç kabuğu ister.
18. **Servisler arası yarış.** `ScheduleService` yazma-yenileme yarışı (§11) bilinen bir sınırdır. Pull-to-refresh ile anlık kaydı aynı anda tetiklemeyin; ekranlar yazmanın bitmesini beklemeli.
19. **Geri Al için sunucu ucu yok.** "Geri Al" gösteren her yeni akış isteği tutma (`PendingLearns` / `NoteDeleteHold` kalıbı) ile kurulmalı. Çıkarken `flush` etmeyi unutursanız yazma kaybolur. Notlar konumla adreslenir, bu yüzden aynı anda tek silme bekleyebilir.
20. **Ortak dosyalar.** `injection_container.dart`, `pubspec.yaml`, `build.yaml`, `app_router.dart`, `app_tr.arb` ve `device_preferences.dart` değişiklikleri ortak dosya kuralına tabidir ([../WORKFLOW.md](../WORKFLOW.md) §5, AGENTS.md "Shared files"): paralel işlerde çakışır, bu yüzden tek elden bağlanır.
21. **Çalışan özelliği silmeyin.** AGENTS.md kuralı: gerçek backend'e karşı çalışan özellik kaldırılamaz. Yalnız ölü, erişilemez, mock veya "yakında" kodu grep kanıtıyla silinebilir (`dart run tool/unreachable_files.dart` buna yardımcıdır).

---

## İlgili dosyalar

- Ağ ve hata: `lib/core/network/{network_service,base_request,dio_error_mapper,log_masker,masking_log_interceptor,session_expired_event}.dart`, `lib/core/errors/{app_exception,app_error_code,app_result}.dart`, `lib/core/extensions/either_extensions.dart`
- Yapılandırma: `lib/core/config/{app_config,feature_flags}.dart`, `config/dev.json.example`, `build.yaml`
- DTO ve zarf: `lib/core/mappable/hooks.dart`, `lib/core/domain/legacy_envelope.dart`, `lib/features/exams/data/api_support.dart`, `lib/features/auth/data/dtos/lenient_hooks.dart`, `lib/features/exams/data/dtos/{lenient_list_hooks,exam_hooks}.dart`, `lib/features/lessons/data/dtos/lesson_hooks.dart`
- Örnek uç akışı: `lib/features/exams/data/{exam_repository.dart,requests/exam_requests.dart,mappers/exam_mappers.dart,dtos/exam_answers.dart}`
- Oturum: `lib/services/{session_manager,current_user_service}.dart`, `lib/features/auth/data/{auth_repository.dart,session/session_store.dart,session/secure_value_store.dart,session/legacy_session_migration.dart}`, `lib/features/startup/data/legacy_onboarding_migration.dart`, `lib/features/startup/application/session_expired_coordinator.dart`
- Cihaz ve bağlantı: `lib/core/services/{device_preferences,connectivity_service}.dart`, `lib/shared/ui/feedback/{section_state,offline_strip_logic}.dart`
- Önbellekli servisler: `lib/features/lessons/application/{lessons_service,literature_service}.dart`, `lib/features/coach/application/{coach_students_service,note_delete_hold}.dart`, `lib/features/schedule/application/schedule_service.dart`, `lib/features/cards/application/pending_learns.dart`
- DI: `lib/dependency_injection/injection_container.dart`, `lib/features/*/*_module.dart`
- Test yardımcıları: `test/core/network/fake_adapter.dart`, `test/features/exams/data/{data_harness,exam_fixtures}.dart`, `test/features/auth/data/auth_fixtures.dart`, `test/services/session_harness.dart`
- Diğer bölümler: [01_mimari.md](01_mimari.md), [03_ekran.md](03_ekran.md), [04_tasarim_sistemi.md](04_tasarim_sistemi.md), [05_araclar.md](05_araclar.md), [06_ozellikler.md](06_ozellikler.md), [../DEVELOPING.md](../DEVELOPING.md), [../Backend_Sorulari_Ek.md](../Backend_Sorulari_Ek.md)
