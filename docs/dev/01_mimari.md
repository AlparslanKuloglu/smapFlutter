# 01 · Uygulama iskeleti: açılış, DI, router, guard'lar, kabuk

Bu bölüm uygulamanın iskeletini anlatır: uygulama nasıl açılır, bağımlılıklar nerede kaydedilir, oturum kapsamı (`session` scope) neyi yönetir, rotalar ve guard'lar nasıl çalışır, iki rol (öğrenci, koç) iki ayrı kabuğa nasıl yerleşir. Projeyi ilk kez açan deneyimli bir Flutter geliştiricisi (ve AI ajanları) içindir; yeni ekran, yeni rota, yeni modül ya da yeni guard kuralı eklemeden önce okunmalıdır.

Yollar, aksi belirtilmedikçe repo köküne göredir (`lib/...`). Sınıf ve metot adları koddaki adlardır; satır numarası verilmez, adı `grep` ile bulun. Bir doc comment ile davranış çelişirse davranış doğrudur. Ekran içi kalıp (View/ViewModel, seçiciler, durumlar) için [03_ekran.md](03_ekran.md), veri katmanı için [02_veri.md](02_veri.md), araçlar ve CI için [05_araclar.md](05_araclar.md), özellik haritası için [06_ozellikler.md](06_ozellikler.md), genel giriş için [../DEVELOPING.md](../DEVELOPING.md).

"Spec §6.3 #N" atfı, `docs/spec/SMAP_Flutter_Spec.md` içindeki backend bağımlılıkları tablosunun N. maddesidir; "pano X.Y · kare N" atfının karşılığı [../design/README.md](../design/README.md)'dedir. Bu bölümde "ortak dosya" dediğimiz dosyalar, birden çok işin kesiştiği yerlerdir (`app_router.dart`, `injection_container.dart`, `shell_routes.dart`, `pubspec.yaml` vb.). Listesi ve neden ayrı ele alındıkları [../WORKFLOW.md](../WORKFLOW.md) §5 ve `AGENTS.md` "Shared files" başlığındadır.

---

## 1. Büyük resim

- **Ne:** Tek bir `AppRouter` (auto_route), tek bir `GetIt` konteyneri (`locator`) ve tek bir oturum sahibi (`SessionManager`) vardır. Feature-first MVVM (stacked) kullanılır; ViewModel'ler get_it'e kaydedilmez.
- **Oturum durumu** (`SessionState`) iki şeyi yönetir:
  - `session` adlı DI kapsamının açılıp kapanması;
  - router guard zincirinin yeniden çalışması (`RouteRefresh`).
- **İki rol, iki kabuk:** öğrenci `StudentShellRoute`, koç `CoachShellRoute`. Her kabukta 4 sekme ve ortada kamera ("Okut") düğmesi vardır. Her sekmenin kendi gezinme yığını vardır.
- **Tam ekran akışlar** (tarama, sonuç anı, yeni program, hesap silme ilerleme ve bitti ekranları) kök yığındadır; kabuğu ve alt çubuğu örterler.
- **Kabuk dışı ekranlar** (giriş, kayıt, duraklatıcı ekranlar, intro) feature'ların `..._routes.dart` listelerinden `AppRouter.routes` içinde birleştirilir.
- **Neden böyle:** oturumun tek sahibi olması, çıkışta ya da hesap silmede önceki kullanıcının verisinin sonrakine sızmasını yapısal olarak engeller (§3.2). Guard mantığının saf fonksiyon olması, yönlendirme kurallarının testlenebilir olmasını sağlar (§5).

Üç navigasyon biçimi vardır (ayrıntı §8):

| Ne zaman | Hangi router |
|---|---|
| Sekme içi detay ekranı (alt çubuk kalır) | Sayfanın kendi `StackRouter`'ı (`context.router`) |
| Tam ekran akış (alt çubuk örtülür) | Kök `AppRouter` (`locator<AppRouter>()` ya da `context.router.root`) |
| Başka sekmeye geçip orada ekran açmak | `context.navigateTo(XxxTabRoute(children: [...]))` |

---

## 2. Açılış sırası (soğuk başlangıç)

1. **`lib/main.dart`**: tek satır, `MainInitializer.run()` çağrılır.
2. **`MainInitializer.run`** (`lib/main_initializer.dart`) her şeyi `runZonedGuarded` içinde başlatır:
   - `_boot`: `WidgetsFlutterBinding.ensureInitialized()`, `FlutterNativeSplash.preserve(...)` (native splash ilk kareyi tutar), `_installErrorHandlers()`.
   - `_installErrorHandlers`: `FlutterError.onError` ve `PlatformDispatcher.onError` aynı `AppLogger`'a bağlanır.
3. **`_initialize()`** sırayla şunları yapar:
   - `configureDependencies()` (core, data ve services fazları, bkz. §3);
   - `initializeDateFormatting('tr_TR')` ve `'tr'`;
   - `LegacyOnboardingMigration.run()`: eski "intro görüldü" bayrağını `DevicePreferences`'a taşır.
4. **`_initialize` hata verirse** `BootFailureApp(onRetry: _retry)` açılır (`lib/app/boot_failure_app.dart`) ve native splash kaldırılır. Bu ekranda tek bir `AppStatusView` ve "Tekrar Dene" vardır. `_retry`, `resetDependencies()` çağırıp `_start()`'ı yeniden çalıştırır. Bu uygulamanın router'ı yoktur; l10n'i `lookupAppLocalizations` ile doğrudan okur.
5. **Hata yoksa** (`_start` içinde):
   ```dart
   final handover = locator<LaunchHandover>();
   // Starts the restore; the launch screen awaits the same future.
   unawaited(locator<SessionManager>().restore());
   runApp(const SmapApp());
   await handover.done.timeout(
     StartupTiming.nativeSplashPatience,
     onTimeout: () {},
   );
   FlutterNativeSplash.remove();
   ```
   - `restore()` arka planda başlar, `runApp` hemen çağrılır.
   - Native splash, `LaunchHandover` tamamlanınca ya da en geç 1 sn sonra (`StartupTiming.nativeSplashPatience = spinnerDelay = 1 sn`) kalkar.
6. **`SmapApp`** (`lib/app/app.dart`) bir `MaterialApp.router` kurar:
   - Tema: `SmapTheme.light()` / `SmapTheme.dark()`; mod sistemi izler (`AppThemeMode.current`). Debug'da `--dart-define=THEME_MODE=dark|light|system` ile zorlanabilir, release bu define'ı yok sayar.
   - Dil yalnız Türkçe (`Locale('tr')`).
   - `routerConfig` şöyle kurulur:
     ```dart
     late final RouteRefresh _refresh = RouteRefresh(locator<SessionManager>());
     late final RouterConfig<UrlState> _config = _router.config(
       reevaluateListenable: _refresh,
     );
     ```
   - `SessionExpiredCoordinator` burada başlatılır (§5.5).
7. **İlk rota `StartupRoute`** (`path: '/'`, `initial: true`, `lib/features/startup/startup_routes.dart`):
   - `StartupViewModel.start()` (`lib/features/startup/presentation/startup/startup_viewmodel.dart`) `await _session.restore()` yapar. `restore()` aynı future'ı döndürür (`_restoring ??= _restore()`), ikinci kez çalışmaz.
   - Sonra `StartupGate.check()` çağrılır. Gate bugün `DisabledStartupGate`'dir ve her zaman `StartupBlock.none` döner. Zorunlu güncelleme ve bakım ekranlarına yalnız bu dikişten gidilebilir; backend'de public config endpoint'i (`/public-config`; `docs/spec/SMAP_Flutter_Spec.md` §6.3 #5, kod yorumlarında "S10") olmadığı için canlıda bu iki ekran açılmaz. **Bakım ya da zorunlu güncelleme "kill switch"i şu an yoktur.**
   - Hedef `StartupViewModel.targetFor(...)` ile bulunur: blok varsa `forceUpdate`/`maintenance`, yoksa `resolveLaunchTarget` (`lib/app/router/guards/route_access.dart`). `resolveLaunchTarget` sırası: intro görülmediyse `onboarding`, oturum yoksa `welcome`, varsa rolün hedefi (`studentShell`, `coachShell` ya da `unknownRole`).
   - `await _router.replaceAll([_router.pageFor(target)])` ile yığın tamamen değişir. `finally` içinde `LaunchHandover.complete()` çağrılır.
   - 1 sn içinde yanıt gelmezse `showSpinner` yanar.
   - Hedef sayfalar 250 ms opacity geçişiyle girer (`fadeRouteType`, `lib/app/router/app_router.dart`); bu geçiş aynı zamanda "reduce motion" biçimidir.
8. **Guard zinciri** `replaceAll` ile açılan sayfada da çalışır (§5). Ardından kabuk açılır, sekme yığınları kurulur (§6).

**Debug yardımcıları** (release'te kapalıdır):

- `ShellPreview` (`lib/app/shell/shell_preview.dart`): `--dart-define=SHELL_PREVIEW=student|coach` hesapsız kabuğu açar. `StartupViewModel`, `restore()` yerine kullanıcısız bir oturum kapsamı (`pushSessionScope()`) açıp kabuğa `replaceAll` yapar. `AccessGuard` başında `if (ShellPreview.active) return resolver.next();` olduğu için bu modda **tüm guard'lar kapalıdır**. `SHELL_PREVIEW_TAB` ile açılış sekmesi seçilir. `SHELL_PREVIEW` yalnız `--dart-define` ile verilen bir derleme zamanı sabitidir; `SHELL_PREVIEW_TAB` ise `lib/features/debug/launch_env.dart` (`debugLaunchEnv`) aracılığıyla ortam değişkeninden ya da geçici dizindeki dosyadan okunur. Hazır çalışma tanımları `.vscode/launch.json` içindedir ([05_araclar.md](05_araclar.md)).
- `lib/main_gallery.dart`: router'sız, DI'sız ayrı bir giriş noktasıdır (bileşen galerisi: `flutter run -t lib/main_gallery.dart`). Galeri sayfaları `lib/features/debug/pages/*_gallery.dart`, kayıt listesi `lib/features/debug/gallery_registry.dart` (ortak dosya). Kit için bkz. [04_tasarim_sistemi.md](04_tasarim_sistemi.md).

---

## 3. Bağımlılık enjeksiyonu (`lib/dependency_injection/injection_container.dart`)

Tek global `final GetIt locator = GetIt.instance;`. **ViewModel'ler asla get_it'e kaydedilmez.** `View.viewModelBuilder` içinde `locator<...>()` ile servisleri enjekte ederek kurar (örnek: `StartupView`, `StudentShellView`).

### 3.1. Fazlar

`configureDependencies()` üç faz çalıştırır. İkinci çağrı, `AppConfig` kayıtlıysa no-op'tur (hot restart ve testler için; `resetDependencies()` sonrası yeniden kurulabilir):

1. **core** (`_registerCore`, `await`'li): `AppLogger`, `AppConfig` (`--dart-define-from-file`; tümü isteğe bağlı, varsayılan prod), `DevicePreferences.load()`, `ConnectivityService` (`initialize()` çağrılır), `NetworkService` (çerez kavanozuyla, bkz. [02_veri.md](02_veri.md)). Hepsi `registerSingleton`'dır.
2. **data** (`kDataModules`): repository'ler.
3. **services** (`kServiceModules`): `registerAuthServices`, `registerStartupServices`, `registerAppServices`.

```dart
const List<ModuleRegistration> kDataModules = <ModuleRegistration>[
  registerAuthData,
  registerExamsData,
  registerAnalyticsData,
  registerLessonsData,
  registerCardsData,
  registerScheduleData,
  registerAccountData,
  registerCoachData,
  registerScanData,
];

const List<ModuleRegistration> kServiceModules = <ModuleRegistration>[
  registerAuthServices,
  registerStartupServices,
  registerAppServices,
];

const List<ModuleRegistration> kSessionModules = <ModuleRegistration>[
  registerAuthSession,
  registerLessonsSession,
  registerScheduleSession,
  registerCoachSession,
];
```

`typedef ModuleRegistration = void Function(GetIt l)`. Her feature `lib/features/<f>/<f>_module.dart` içinde `registerXxxData`, gerekirse `registerXxxSession` ya da `registerXxxServices` yazar. Bir modül şu biçimdedir (`analytics_module.dart`):

```dart
void registerAnalyticsData(GetIt l) {
  l.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepository(l<NetworkService>()),
  );
}
```

- **Kural:** `registerLazySingleton` kullan. Böylece faz içi sıra önemsiz kalır ve kullanılmayan feature açılışa maliyet bindirmez.
- **İstisna:** `SessionManager` kasıtlı olarak `registerSingleton`'dır (`lib/features/auth/auth_module.dart`): ilk 401 geldiğinde `NetworkService.onSessionExpired`'ı zaten dinliyor olmalıdır.
- Modülü olan feature'lar: account, analytics, auth, cards, coach, exams, lessons, scan, schedule, startup. Modülü olmayanlar: home, onboarding, shell, debug.
- `lib/app/app_module.dart` (`registerAppServices`) router ile toast servisini kaydeder:

```dart
..registerLazySingleton<AppRouter>(() {
  final router = AppRouter(
    session: () => l<SessionManager>().state,
    preferences: l<DevicePreferences>(),
    logger: l<AppLogger>(),
  );
  AppSheet.navigatorKey = router.navigatorKey;
  return router;
})
..registerLazySingleton<ToastService>(
  () => ToastService.navigator(l<AppRouter>().navigatorKey),
  dispose: (service) => service.dispose(),
)
```

`AppRouter`'ın `navigatorKey`'i iki yerde kullanılır:

- `ToastService`, toast'ları bu navigator'ın overlay'ine çizer; ana widget'ta host widget gerekmez.
- `AppSheet.navigatorKey` (statik alan), ViewModel'lerin context'siz sheet açmasını sağlar.

Başka servisler `startup` modülünden gelir (`registerStartupServices`): `StartupGate` (`DisabledStartupGate`), `LaunchHandover`, `StoreLauncher`.

### 3.2. `session` kapsamı

```dart
const String kSessionScope = 'session';

void pushSessionScope({List<ModuleRegistration> modules = kSessionModules}) {
  if (isSessionScopeActive) { /* uyarı logu */ return; }
  locator.pushNewScope(scopeName: kSessionScope);
  _runModules(modules);
  if (locator.isRegistered<NetworkService>()) {
    locator<NetworkService>().markSessionStarted();
  }
}

Future<void> popSessionScope() async {
  if (!isSessionScopeActive) return;
  await locator.dropScope(kSessionScope);
}
```

- **Kapsamın içine** kullanıcıya bağlı olanlar girer: `CurrentUserService` (`registerAuthSession`), `LessonsService` ve `LiteratureService` (`registerLessonsSession`), `ScheduleService`, `CoachStudentsService`. Kapsam düşünce `dispose`'ları çağrılır. Böylece çıkış ya da hesap silme, bir sonraki kullanıcıya önceki kullanıcının verisini sızdıramaz.
- **Repository'ler durumsuzdur**, kök kapsamdadır. Koç, öğrenci id'sini her çağrıda kendisi verir.
- **Kapsamı yalnız `SessionManager` açıp kapatır** (`lib/services/session_manager.dart`). İstisna: `ShellPreview` (§2).
- `SessionManager` kapsamı açma/kapama işlevlerini constructor'dan alır (`pushScope`/`popScope`); testler bunları sayaçla değiştirir (`test/services/session_harness.dart`). Aynı yolla `forgetAccountData` da alır; `registerAuthServices` ona `DevicePreferences.clearAccount`'u verir.
- **Cihazda kalan kişisel tercihler** kapsamda değil, `DevicePreferences`'tadır. Kişiye ait olanlar (kayıt taslağı, öğrenilen kart onayındaki "Bir daha sorma", favori denemeler, bildirim seçimleri) `DevicePreferences.accountKeys` kümesindedir ve oturum bitince silinir; cihaza ait olanlar (tema, intro görüldü, kamera ön açıklaması vb.) kalır.

Kapsam ne zaman açılır, ne zaman kapanır:

| Olay | Davranış | Kod |
|---|---|---|
| Açılış, çerez + önbellekte kullanıcı var | `_openScope(cached.id)`, durum hemen `signedIn(cached)`, internet varsa arka planda `revalidate()` | `_restore` |
| Açılış, çerez var ama önbellek yok | `checkUser` sonucu kullanıcı gelirse `_openScope` | `_restoreFromServer` |
| Açılış, çerez yok | Önbellek varsa silinir, `signedOut`, kapsam açılmaz | `_restore` |
| Giriş | `login` + `checkUser` doğrulaması, sonra `_enterScopeFor(user)` | `_signIn` |
| Oturum süresi doldu (401/403/3xx) | Durum `signedOut(expired: true)`. **Kapsam açık kalır** | `_onSessionExpired`, `_expire` |
| Aynı kullanıcı yeniden giriş | `_enterScopeFor` aynı id'de kapsamı korur | `_enterScopeFor` |
| Başka kullanıcı girişi | Eski kapsam kapatılır, temiz kapsam açılır | `_enterScopeFor` |
| `signOut()` / `completeAccountDeletion()` | Önce `signedOut` (ekranlar ve ViewModel'ler gider), sonra sunucuya logout (yalnız `signOut`, cihaz çevrimiçiyse), çerez ve önbellek temizliği, oturum vardıysa kişiye ait cihaz tercihlerinin silinmesi (`forgetAccountData` → `DevicePreferences.clearAccount`), `_closeScope()` | `_runEnd` |

`SessionState` geçişleri (`lib/features/auth/domain/session_state.dart`): `unknown → restoring → signedIn | signedOut`, `signedIn → signedOut(expired: true) → signedIn`. Oturum bakımı ayrıntıları (cookie jar, `SessionStore`, göçler, `checkUser`) [02_veri.md](02_veri.md) §9'dadır.

### 3.3. Yeni modül nasıl eklenir

1. `lib/features/<f>/<f>_module.dart` içinde `registerXxxData(GetIt l)` yaz (repository'ler `registerLazySingleton`).
2. Kullanıcıya özel önbellek ya da servis varsa `registerXxxSession(GetIt l)` ekle (§3.2); kök kapsama **koyma**.
3. İşlevleri `injection_container.dart` içindeki `kDataModules` / `kServiceModules` / `kSessionModules` listesine ekle (ortak dosya). Listeye eklemezsen çalışma zamanında "not registered" hatası alırsın.
4. `test/dependency_injection/injection_container_test.dart` kalıpları gösterir ("every registration of the real module lists resolves" listelere eklenen her kaydı çözer).

---

## 4. Router (`lib/app/router/app_router.dart`)

```dart
@AutoRouterConfig(replaceInRouteName: 'Page|Screen|View,Route')
final class AppRouter extends RootStackRouter implements RouteCatalog {
  ...
  @override
  List<AutoRoute> get routes => [
    ...startupRoutes,
    ...onboardingRoutes,
    ...authRoutes,
    ...registerRoutes,
    ...scheduleRootRoutes,
    ...accountSettingsRootRoutes,
    ...scanRootRoutes,
    ...resultMomentRootRoutes,
    ...shellRoutes,
  ];
```

- **İsimlendirme:** `XxxView`, `XxxPage`, `XxxScreen` sınıfı `XxxRoute` olur (`replaceInRouteName`). Örnek: `HomeTabPage` → `HomeTabRoute`, `LiteratureEraView` → `LiteratureEraRoute`.
- **Üretilen kod:** `app_router.gr.dart`, `part` dosyasıdır, git'te izlenir ve elle düzenlenmez. Bu yüzden `app_router.dart` **her View'i import etmek zorundadır**; yeni ekran eklerken buraya import da eklenir.
- **Kök liste sırası önemlidir:** kök rotalar kabuklardan önce gelir. Öğrenci kabuğunun prefix'i `/` olduğundan, sıra yanlışsa `/account/delete/progress` gibi bir yol `/account` kabuk çocuğu sanılır (yorum: `lib/features/account/account_settings_routes.dart`).
- **Sürüm kilidi:** `pubspec.yaml` içinde `auto_route: 11.1.0` pinlidir (11.2.0, `Viewport.scrollCacheExtent` kullandığından, sabitlenmiş Flutter 3.38.6 ile derlenmez). Flutter sürümünü yükseltmeden auto_route'u yükseltmeyin ([05_araclar.md](05_araclar.md)).

### 4.1. Yeni rota nasıl eklenir

1. **View'i yaz.** `lib/features/<f>/presentation/<screen>/<screen>_view.dart` içinde `@RoutePage()` ile. Yol ve sorgu parametreleri constructor'dadır (örnek: `lib/features/exams/presentation/exam_detail/exam_detail_view.dart`):
   ```dart
   @RoutePage()
   class ExamDetailView extends StackedView<ExamDetailViewModel> {
     const ExamDetailView({
       @PathParam('examId') required this.examId,
       @QueryParam('tab') this.tab,
       this.student,
       this.exam,
       super.key,
     });
   ```
   `student` ve `exam` yolda yoktur, argüman olarak taşınır (§10, tuzak 9).
2. **Feature'ın rota listesine ekle:** `lib/features/<f>/<f>_routes.dart` içinde bir `List<AutoRoute> get ...` getter'ı. Örnek (`lib/features/lessons/lessons_routes.dart`):
   ```dart
   List<AutoRoute> get lessonsTabRoutes => [
     AutoRoute(page: LessonsRoute.page, initial: true),
     AutoRoute(page: LessonDetailRoute.page, path: ':lessonId'),
     AutoRoute(page: TopicDetailRoute.page, path: ':lessonId/topics/:topicId'),
     AutoRoute(page: LiteratureEraRoute.page, path: ':lessonId/literature/:eraId'),
   ];
   ```
   - Sekme içi ekranlarda `initial: true` sekmenin kökü olan tek çocuktur.
   - `path` göreli yazılır. Kökte mutlak yazılır (`'/scan'`).
3. **Listeyi bağla** (ortak dosyalar):
   - Sekme içi ekranda: `lib/app/router/routes/shell_routes.dart` içinde ilgili sekmenin `children`'ına eklenir. Sabit yol, `:param` yolundan **önce** gelir.
   - Tam ekran akışta: `AppRouter.routes` içine, kabuklardan önce eklenir.
4. **Guard grubu gerekiyorsa:** `AppRouter._groups` haritasına eklenir. Yalnız kapılar ve kabuklar gruplanır; diğerleri `RouteGroup.other` olur ve guard'sızdır (§5.2, §10 tuzak 5).
5. **Kod üret:** `dart run build_runner build -d` (`--delete-conflicting-outputs`). CI üretilen dosyaların güncelliğini denetler ([05_araclar.md](05_araclar.md)).
6. **Test ekle:** `test/app/shell/shell_routes_test.dart` içindeki `namesOf('/yol')` kalıbı, yolun hangi rota zincirine çözüldüğünü doğrular.

---

## 5. Guard zinciri ve rol ayrımı (`lib/app/router/guards/`)

### 5.1. Yapı

- `AppRouter.guards` üç guard'dır, sırası sabittir (`test/app/router/app_router_test.dart` doğrular): `OnboardingGuard`, `AuthGuard`, `RoleGuard`.
- Üçü de `AccessGuard`'dan türer (`access_guard.dart`) ve her biri `route_access.dart`'taki **saf bir aşama fonksiyonunu** (`onboardingStage`, `authStage`, `roleStage`) çağırır. Mantık test edilebilir saf Dart'tır (`decideAccess` üçünü sırayla çalıştırır).
- `RouteCatalog` arayüzünü (`route_catalog.dart`) `AppRouter` uygular: `groupOf(routeName)` ve `pageFor(RouteTarget)`. Guard'lar üretilmiş rota sınıflarını bilmez.
- Karar **hedef rotaya** göre verilir (`resolver.route.name`), `router.current`'a göre değil. Aksi halde guard kendi yönlendirmesinde tetiklenir.
- Karar çıktıları:
  - `AccessAllow`: geçir.
  - `AccessRedirect(target)`: `resolver.next(false)` sonra `root.replaceAll([catalog.pageFor(target)])`.
  - `AccessReject`: navigasyonu sessizce düşür.

`AccessInput` alanları: `group`, `onboardingSeen`, `session` ve `shellInStack` (kök yığında zaten bir kabuk var mı).

### 5.2. Guard grupları (`RouteGroup`)

| Grup | Rotalar | Anlamı |
|---|---|---|
| `startup` | `StartupRoute` | Her zaman erişilir |
| `blocking` | `ForceUpdateRoute`, `MaintenanceRoute` | Oturumdan bağımsız durdurucu ekranlar |
| `onboarding` | `OnboardingRoute` | Yalnız intro görülmediyse |
| `signedOutEntry` | `WelcomeRoute`, `LoginRoute`, `RegisterRoute` | Yalnız oturum yokken |
| `studentShell` | `StudentShellRoute` | Yalnız giriş yapmış öğrenci |
| `coachShell` | `CoachShellRoute` | Yalnız giriş yapmış koç |
| `unknownRole` | `UnknownRoleRoute` | Rolü bilinmeyen hesap |
| `other` | geri kalan her şey | Guard yok |

### 5.3. Aşamalar

- **`onboardingStage`:**
  - `onboarding` grubuna intro görüldüyse `resolveLaunchTarget`'a yönlendirir, görülmediyse geçirir.
  - `signedOutEntry`, `studentShell`, `coachShell` ve `unknownRole` gruplarını intro görülmediyse introya yönlendirir.
- **`authStage`:**
  ```dart
  case RouteGroup.signedOutEntry:
    if (!session.isSignedIn) return const AccessDecision.allow();
    return input.shellInStack
        ? const AccessDecision.reject()
        : AccessDecision.redirect(_roleTargetOf(session));
  case RouteGroup.studentShell:
  case RouteGroup.coachShell:
  case RouteGroup.unknownRole:
    if (session.isSignedIn || session.isExpired) {
      return const AccessDecision.allow();
    }
    return session.isResolved
        ? const AccessDecision.redirect(RouteTarget.welcome)
        : const AccessDecision.reject();
  ```
  - Kapılar oturumsuzlar içindir. Giriş yapmış biri kapıya gelirse kabuğuna gider. Kabuk zaten açıksa (süresi dolan oturumda yeniden giriş) kapı kapanır.
  - Kabuklar oturum ister. Süresi dolmuş oturum da geçer; kullanıcı "oturum bitti" sheet'inin arkasındaki ekranda kalır.
  - Oturum henüz kararlaştırılmadıysa (`restoring`) hiçbir şey açılmaz (reject).
- **`roleStage`:** giriş yapmış kullanıcının rolü (`targetForRole`) ile hedef kabuk grubu uyuşmuyorsa kullanıcıyı kendi kabuğuna yönlendirir. Koç `/home` açmaya çalışırsa koç kabuğuna gider, tersi de aynı.

### 5.4. Oturum değişince yeniden değerlendirme

`RouteRefresh` (`lib/app/router/route_refresh.dart`), `SessionManager`'ı dinler ama yalnız `SessionRouteKey` (resolved, signedIn, expired, role) değişince `notifyListeners()` çağırır. Giriş butonunun busy bayrağı ya da profil fotoğrafı güncellemesi guard'ları tetiklemez.

auto_route 11.1.0 kaynağında `reevaluateListenable` → `AutoRouterDelegate` → `reevaluateGuards()` zinciri doğrulandı: yığındaki **tüm** sayfalar ve iç yığınlar için guard'lar yeniden çalıştırılır. Çıkış yapınca kabuk sayfası `authStage`'e takılır ve `replaceAll([WelcomeRoute])` yürür. Çıkışta ayrıca elle yönlendirme yazmaya gerek yoktur (`AccountViewModel.logout` yalnız `_session.signOut()` çağırır).

### 5.5. Oturum bitti akışı

`SessionExpiredCoordinator` (`lib/features/startup/application/session_expired_coordinator.dart`), durum `isExpired` olunca `SessionExpiredSheet.show` (kapatılamaz sheet) açar. "Giriş Yap" `router.push(const LoginRoute())` ile girişi mevcut ekranın üstünde açar. Giriş başarılı olunca `authStage`, `signedOutEntry` + `shellInStack` kombinasyonunda `reject` verir ve giriş sayfası kendiliğinden kapanır. Kullanıcı girişi kapatırsa sheet yeniden sorar.

### 5.6. Rol ayrımı: üç katman

1. **Kabuk:** guard'lar (yukarıda). `UserRole.fromLegacy` (`lib/core/domain/user_role.dart`): `student` öğrenci, `coach` ve `teacher` koç, gerisi `unknown` (büyük/küçük harf ve boşluk önemsizdir). `unknown`, sessizce öğrenci uygulamasını açmaz; `UnknownRoleRoute` ("Hesabın açılamadı") açar. Orada "Yeniden Giriş Yap" (`signOut()`) ve, yalnız `SUPPORT_EMAIL` yapılandırılmışsa, "Destek'e Yaz" (`StoreLauncher.writeSupport`) eylemleri vardır.
2. **Rota ağacı:** koçun Hesap sekmesinin çocukları `accountTabRoutes` + yalnız `NotificationsRoute`'tur (`lib/app/router/routes/shell_routes.dart`). Koçta Koçluk, Şifre ve Hesabı Sil rotaları yoktur. Koçun Hesap'ındaki "Koçluk" grubu bir rota açmaz: tek satırı koçun kodunu gösterir ve `CoachCodeSheet`'i açar (`AccountViewModel.openCoachCode`, `lib/features/account/presentation/account/sheets/coach_code_sheet.dart`).
3. **UI kapısı:** `StackAccountNavigator.canOpen` (`lib/features/account/presentation/stack_account_navigator.dart`), rotayı **ada göre** router koleksiyonunda arar. Rota o rolün ağacında yoksa Hesap satırı çizilmez ve dokunulmaz:
   ```dart
   bool canOpen(AccountDestination destination) {
     final name = _names[destination]!;
     RoutingController? controller = _router;
     while (controller != null) {
       if (controller.routeCollection.containsKey(name)) return true;
       controller = controller.parent();
     }
     return false;
   }
   ```
   Bu yüzden `FeatureFlags` (§10, tuzak 10) kapalıyken rota listeden çıkarsa satır da kaybolur.

Kapanmamış küçük rol kapıları ViewModel düzeyindedir. Örnekler: `ProfileViewModel.hasGradeFields => _currentUser.isStudent`; Hesap'ta `AccountMenuData.isCoach` koçta kod satırını, öğrencide Koçluk satırını çizdirir. Rol sorgusu için `CurrentUserService` (`role`, `isStudent`, `isCoach`) kullanılır.

---

## 6. Kabuk (`lib/app/shell/`)

- **`StudentShellView`** (`student_shell_view.dart`) ve **`CoachShellView`:** ikisi de `StackedView<ShellViewModel>`'dır, `reactive => false`. Her biri sabit bir `tabs` listesi tanımlar ve `ShellFrame(role:, tabs:, viewModel:)` döndürür.
  ```dart
  static const List<ShellTabSpec> tabs = [
    ShellTabSpec(route: HomeTabRoute()),
    ShellTabSpec(route: AnalyticsTabRoute()),
    ShellTabSpec(route: LessonsTabRoute()),
    ShellTabSpec(route: AccountTabRoute()),
  ];
  ```
  Koçta: `CoachHomeTabRoute`, `CoachStudentsTabRoute`, `CoachMeetingsTabRoute`, `CoachAccountTabRoute`. `ShellTabSpec` yalnız tek alanlı bir değer sınıfıdır (`route`).
- **Sekme kök sayfaları** (`tab_stack_pages.dart`): sekme başına bir `AutoRouter` alt sınıfı (`HomeTabPage`, `AnalyticsTabPage`, `LessonsTabPage`, `AccountTabPage`, `Coach...TabPage`). İçleri boştur; sekmenin kendi navigator'ını tutarlar.
- **`ShellFrame`** (`shell_frame.dart`): `AutoTabsRouter.builder(routes:, homeIndex: 0, ...)` kullanır; altında `Scaffold(extendBody: true)` ve `AppBottomBar` vardır.
  - Seçili olmayan sekmeye dokunmak sekmeyi gösterir. Seçili sekmeye tekrar dokunmak (`ShellBarPolicy.onTap`, `lib/features/shell/application/shell_bar_policy.dart`) yığını köke indirir (`popUntilRoot`) ve `scrollTabToTop` ile başa kaydırır.
  - Kamera ("Okut") sekme değildir. `ShellViewModel.openCamera` → `ScanEntry.start(router)` kök router'da izin ve bakım kapısını çalıştırır, sonra `ScanFlowRoute`'u kök yığına iter. Bu yüzden alt çubuk örtülür. Koç kabuğunda da aynı tarama açılır; öğrenci seçtirme (spec §6.3 #34) backend'e bağlıdır.
  - Android geri tuşu sırası kodda şöyle tasarlanmıştır: sekmenin yığını, sonra Anasayfa (`homeIndex: 0`), sonra uygulamadan çıkış.
  - **Dört sekme de kabuk açılırken kurulur.** `AutoTabsRouter.builder`, auto_route 11.1.0 kaynağına göre (`_AutoTabsRouterBuilderState.build`) her sekme için `KeepAliveTab` üretir ve varsayılan `initiallyLoaded = true`'dur; `lazyLoad` yalnız `AutoTabsRouter`'ın `IndexedStack` varyantındadır, `.builder` kurucusunda yoktur. Sonuç: kabuk açılınca dört sekmenin kök ekranları (ve ViewModel'leri) birlikte kurulur ve veri çekmeye başlar. Bu kaynak okumasıdır; cihazda ölçülmedi.
- **`_ShellTabStack`** (`widgets/shell_tab_stack.dart`): sekmeleri `IndexedStack` içinde tutar. Aktif olmayanlar `ExcludeSemantics` ve `ExcludeFocus` ile erişilebilirlik ve odak sırasından çıkarılır. Her sekmenin `MediaQuery`'si cihazın gerçek alt güvenli alanıyla düzeltilir (`extendBody` bunu sıfırlar). Ekranlar alt çubuk yüksekliğini `AppBottomBar.heightOf` ile kendileri ekler (68 + alt güvenli alan; iPhone 16 Pro'da 102).
- **`_ShellOfflineStrip`** (`widgets/shell_offline_strip.dart`): kabuğun üstünde çevrimdışı şeridi. Şerit görünürken üst güvenli alanı o alır, içerik aynı miktarda daralır, böylece sayfalar kaymaz.
- **`ShellViewModel`** (`lib/features/shell/presentation/shell_viewmodel.dart`):
  - Kök router'ı dinler. Tepedeki sayfa bir kabuksa toast'ın `bottomBarHeight`'ını alt çubuğa göre ayarlar (`updateBar`). Tam ekran akış kabuğu örtünce `null` yapar ve toast güvenli alana iner.
  - `shellRouteNames` iki kabuğun adlarını tutar.

---

## 7. Rota yolları (derin bağlantı tablosu)

**OS düzeyinde derin bağlantı (URL şeması, App Link, Universal Link) yoktur.** `AndroidManifest.xml`'de yalnız `MAIN/LAUNCHER` intent-filter'ı vardır; `Info.plist`'te `CFBundleURL*` ve `applinks` ifadeleri bulunmaz. Yani "derin bağlantı" burada router'ın yol çözümlemesi ve testleridir. Kök tam ekran akışlar ("itilir, bağlanmaz") yalnız programatik açılır.

**Kök rotalar** (`AppRouter.routes`):

| Yol | Rota (View) | Grup | Not |
|---|---|---|---|
| `/` | `StartupRoute` | startup | `initial: true`; test: `'/'` Startup'a çözülür |
| `/blocking/force-update` | `ForceUpdateRoute` | blocking | fade |
| `/blocking/maintenance` | `MaintenanceRoute` | blocking | fade; yeniden dene `StartupRoute`'a `replaceAll` |
| `/blocking/unknown-role` | `UnknownRoleRoute` | unknownRole | fade |
| `/onboarding/intro` | `OnboardingRoute` | onboarding | tek rota, içinde adımlar (3 tanıtım, rol (yalnız `FeatureFlags.coachSignUpEnabled` açıkken; bugün kapalı, rol hep öğrenci), sınıf ve alan, kamera ön açıklaması); fade |
| `/welcome` | `WelcomeRoute` | signedOutEntry | fade |
| `/auth/login` | `LoginRoute` | signedOutEntry | |
| `/auth/register` | `RegisterRoute` | signedOutEntry | `role`, `grade`, `track` isteğe bağlı argüman; `coachSignUpEnabled` kapalıyken rol bandı çizilmez ve `role` yok sayılır (kayıt hep öğrenci) |
| `/auth/forgot-password` | `ForgotPasswordRoute` | other | `FeatureFlags.forgotPasswordEnabled` kapalı olduğundan listede yok |
| `/program/new` | `NewProgramRoute` | other | Tam ekran; `student` argümanı (koç). `/home/program/new` değil: `program/:programId` ile çakışırdı |
| `/account/delete/progress` | `AccountDeletionProgressRoute` | other | Tam ekran, geri kapalı |
| `/account/delete/done` | `AccountDeletionDoneRoute` | other | Tam ekran, geri kapalı |
| `/scan` | `ScanFlowRoute` | other | Tam ekran, `ScanEntry.start` ile açılır |
| `/scan/result/:examId` | `ResultMomentRoute` | other | Tam ekran, tarama itişiyle açılır |

**Öğrenci kabuğu** (`StudentShellRoute`, `path: '/'`, boş prefix; çocuklar):

| Yol | Rota |
|---|---|
| `/home` | `HomeTabRoute` → `HomeRoute` |
| `/home/program` | `ProgramListRoute` |
| `/home/program/:programId?view=day\|week&date=yyyy-MM-dd` | `ProgramDetailRoute` |
| `/analytics?tab=genel\|denemelerim` | `AnalyticsTabRoute` → `AnalyticsRoute` |
| `/analytics/exam/:examId?tab=genel\|sorular\|konular\|kartlar` | `ExamDetailRoute` |
| `/analytics/exam/:examId/question?lesson=&q=` | `QuestionDetailRoute` |
| `/lessons` | `LessonsTabRoute` → `LessonsRoute` |
| `/lessons/deck?lessonId=&examId=&group=eksik\|bildik\|favori` | `CardDeckRoute` (`:lessonId`'den önce!) |
| `/lessons/:lessonId?cat=&eksik=&section=topics\|authors` | `LessonDetailRoute` |
| `/lessons/:lessonId/topics/:topicId?cat=&focus=` | `TopicDetailRoute` |
| `/lessons/:lessonId/literature/:eraId` | `LiteratureEraRoute` (Edebiyat dönem detayı) |
| `/account` | `AccountTabRoute` → `AccountRoute` |
| `/account/profile` | `ProfileRoute` |
| `/account/agreements` | `ContractsRoute` |
| `/account/agreements/read` | `ContractReaderRoute` (`document` argümanı zorunlu; yoldan açılamaz) |
| `/account/password` | `PasswordRoute` (`passwordChangeEnabled` kapalı, listede yok) |
| `/account/coaching` | `CoachingRoute` |
| `/account/notifications` | `NotificationsRoute` |
| `/account/delete` | `AccountDeletionRoute` (açıklama ekranı, Profil'den açılır) |

**Koç kabuğu** (`CoachShellRoute`, `path: '/coach'`):

| Yol | Rota |
|---|---|
| `/coach/home` | `CoachHomeTabRoute` → `CoachHomeRoute` |
| `/coach/students` | `StudentsRoute` |
| `/coach/students/exam/:examId` | `ExamDetailRoute` (koç görünümü; öğrenci `student` argümanıyla) |
| `/coach/students/exam/:examId/question?lesson=&q=` | `QuestionDetailRoute` |
| `/coach/students/program` | `ProgramListRoute` (`student` argümanı) |
| `/coach/students/program/:programId?view=&date=` | `ProgramDetailRoute` (`student` argümanı) |
| `/coach/students/:studentId?tab=analysis\|exams\|program` | `StudentProfileRoute` (sabit yollardan **sonra**) |
| `/coach/meetings` | `MeetingsRoute` |
| `/coach/meetings/:meetingId` | `MeetingDetailRoute` (`meeting` argümanı yolda yok) |
| `/coach/account` | `CoachAccountTabRoute` → `AccountRoute` |
| `/coach/account/profile`, `/agreements`, `/agreements/read` | `accountTabRoutes` (öğrenciyle ortak) |
| `/coach/account/notifications` | `NotificationsRoute` |

Aynı sayfa sınıfı birden çok ebeveyn altında kayıtlı olabilir (`ExamDetailRoute`, `QuestionDetailRoute`, `ProgramListRoute`, `ProgramDetailRoute` hem öğrenci hem koç ağacında; `AccountRoute` iki Hesap sekmesinde). Koç yolları `FeatureFlags.coachProgramWriteEnabled` ile program yazmayı açar ya da salt okunur bırakır; rota listesi bayraktan etkilenmez, ekranlar etkilenir.

---

## 8. Feature başına kalıp ve navigasyon

Bir feature'ın kök dizininde şu dosyalar bulunabilir:

- `<f>_module.dart`: DI kaydı (`registerXxxData`, `registerXxxSession`, `registerXxxServices`).
- `<f>_routes.dart`: rota listesi getter'ları.

Bir feature birden çok rota dosyası ve getter yazabilir:

- **Hesap:** `account_routes.dart` (`accountTabRoutes`), `account_settings_routes.dart` (`accountSettingsTabRoutes` ve `accountSettingsRootRoutes`).
- **Koç:** `coach_home_routes.dart`, `coach_students_routes.dart`, `coach_student_profile_routes.dart`, `coach_meetings_routes.dart`.
- **Auth:** `auth_routes.dart`, `register_routes.dart`.
- **Exams:** `exams_routes.dart` (`examsAnalyticsTabRoutes`), `result_moment_routes.dart` (`resultMomentRootRoutes`).
- **Schedule:** `scheduleHomeTabRoutes` (sekme içi) ve `scheduleRootRoutes` (kök) aynı dosyadadır (`schedule_routes.dart`).

Çoğu getter şu kalıbı izler: `...TabRoutes` sekme çocuklarıdır, `...RootRoutes` kök akışlardır. İstisnalar: `coachStudentProfileRoutes` bir sekme çocuğudur (`shell_routes.dart` içinde `CoachStudentsTabRoute`'un `children`'ında, `coachStudentsTabRoutes`'un yanında). `startupRoutes`, `onboardingRoutes`, `authRoutes`, `registerRoutes` ve `shellRoutes` ise `AppRouter.routes` kök listesine girer.

### 8.1. ViewModel'den gezinme

ViewModel context'siz kalır. Gezinme, enjekte edilen bir "navigator" arayüzünden yapılır (örnekler: `OnboardingNavigator` ile `RouterOnboardingNavigator(AppRouter)`, `LessonsNavigator` ile `StackLessonsNavigator(context.router)`, `AccountNavigator` ile `StackAccountNavigator(context.router)`). Üç yol vardır:

- **Kök router** (`AppRouter`, `locator`'dan ya da `context.router.root`): kök yığına iter, kabuğu örter. Kamera (`ScanEntry`), giriş, hesap silme, yeni program için.
- **Sayfanın kendi `StackRouter`'ı** (`context.router`): sekme yığınına iter, alt çubuk kalır. Ders, deneme, hesap alt ekranları için.
- **Çapraz sekme:** Anasayfa'dan Analizlerim ya da Derslerim'de ekran açmak için hedef sekmenin çocuk zinciriyle `navigateTo`. Örnek (`home_view.dart`):
  ```dart
  context.navigateTo(
    LessonsTabRoute(
      children: [
        const LessonsRoute(),
        LessonDetailRoute(lessonId: lessonId),
      ],
    ),
  );
  ```

`lib/app/router/stack_router_x.dart`:

- `StackRouter.belowName`: altındaki sayfanın adını verir.
- `StackRouter.pushOrPop`: iki sayfa birbirini açıyorsa yığını büyütmek yerine geri döner (Giriş ↔ Kayıt).
- `BuildContext.routeBelowName`: geri düğmesi etiketi içindir.

---

## 9. Klasör haritası (`lib/`)

**Kök dosyalar**
- `main.dart`: giriş noktası, `MainInitializer.run()` çağırır.
- `main_initializer.dart`: guarded zone, splash, DI, oturum geri yükleme ve BootFailure.
- `main_gallery.dart`: router'sız bileşen galerisi giriş noktası.

**`app/`**
- `app.dart`: `SmapApp`, `MaterialApp.router`, `RouteRefresh` ve `SessionExpiredCoordinator`.
- `app_module.dart`: `registerAppServices` (router ve toast).
- `app_theme_mode.dart`: sistem teması ve debug'da zorlama.
- `boot_failure_app.dart`: başlatma hatası ekranı.
- `router/`: `AppRouter`, üretilmiş `app_router.gr.dart`, `route_refresh.dart`, `stack_router_x.dart`.
- `router/guards/`: `access_guard`, üç guard (`onboarding_guard`, `auth_guard`, `role_guard`), `route_access.dart` (saf karar fonksiyonları), `route_catalog.dart`.
- `router/routes/shell_routes.dart`: iki kabuk ve sekme ağaçları.
- `shell/`: kabuk çerçevesi (`shell_frame.dart`), iki kabuk View'ı, `shell_tab_spec.dart`, sekme sayfaları (`tab_stack_pages.dart`), `shell_preview.dart`, `scroll_to_top.dart`.
- `shell/widgets/`: kabuk çevrimdışı şeridi ve sekme yığını (`shell_frame.dart`'ın `part` dosyaları).

**`dependency_injection/`**
- `injection_container.dart`: `locator`, üç faz listesi, `session` kapsamı.

**`core/`** (özelliğe özel olmayan altyapı; alan sabitleri burada tutulmaz)
- `config/`: `AppConfig` (dart-define) ve `FeatureFlags`.
- `domain/`: `UserRole` ve `LegacyEnvelope` (eski backend yanıt sarmalı).
- `errors/`: `AppException`, `AppErrorCode`, `AppResult` (`Either<AppException, T>`).
- `extensions/`: `Either` yardımcıları.
- `mappable/`: dart_mappable için gevşek JSON hook'ları.
- `network/`: Dio tabanlı `NetworkService`, `BaseRequest`, hata eşleme, log maskeleme, oturum bitti olayı.
- `services/`: `AppLogger`, `DevicePreferences`, `ConnectivityService`, `ToastService`, `AppHaptics`.
- `theme/`: renk (`SmapColors`, `SmapPalette`), yazı (`SmapText`), boşluk, yarıçap, hareket, gölge, tema ve ders tonları.
- `utils/`: `TrFormat` ve `TurkishText`.

**`services/`**
- `session_manager.dart`: oturumun tek sahibi.
- `current_user_service.dart`: oturum kapsamındaki reaktif kullanıcı.

**`shared/ui/`** (`App*` bileşen kiti; alt klasörler)
- `buttons/`, `controls/`, `feedback/` (boş/hata durumu, iskelet, toast, çevrimdışı şerit, `section_state.dart`), `identity/`, `illustrations/` (`AppClay` kil görselleri), `indicators/`, `inputs/`, `navigation/` (alt çubuk, bantlar, `StudentRef` ile `student_scope.dart`), `pickers/`, `sheets/` (`AppSheet`), `surfaces/` (kart, satır, akordiyon, bildirim kutusu), `text/`. Ayrıntı: [04_tasarim_sistemi.md](04_tasarim_sistemi.md).

**`features/`** (her biri çoğunlukla `application/` ve `presentation/` içerir; veri taşıyanlar `data/` ve `domain/` ekler; ekran kalıbı için [03_ekran.md](03_ekran.md), özellik haritası için [06_ozellikler.md](06_ozellikler.md))
- `account/`: Hesap (koçun kod sheet'i `account/sheets/` altında), Profil, Sözleşmeler, Şifre (bayraklı), Koçluk, Bildirimler, Hesabı Sil.
- `analytics/`: Analizlerim (Genel ve Denemelerim).
- `auth/`: giriş, kayıt, şifremi unuttum (bayraklı), oturum deposu ve eski göç.
- `cards/`: bilgi kartı destesi.
- `coach/`: koç anasayfası, öğrenciler, öğrenci profili, görüşmeler; Hesap'taki kod sheet'inin gövdesi de buradadır (`CodeCardSheetBody`, `presentation/widgets/code_card_sheet.dart`).
- `debug/`: bileşen galerisi (`pages/*_gallery.dart`), `launch_env`.
- `exams/`: deneme detay, soru detay, sonuç anı, bildirim izni sheet'i.
- `home/`: öğrenci Anasayfa.
- `lessons/`: Derslerim, ders detayı, konu detayı, Edebiyat (dönem, alt başlık, yazar, eser).
- `onboarding/`: intro ve Hoş geldin; kamera izni arayüzü (`CameraPermission`) da burada tanımlıdır.
- `scan/`: kamera ve optik okuma akışı.
- `schedule/`: Programım, program detayı ve yeni program.
- `shell/`: kabuğun saf mantığı ve ViewModel'i (View'lar `app/shell/`'de).
- `startup/`: açılış ekranı, durdurucu ekranlar, oturum bitti sheet'i.

**Diğer**
- `gen/`: `flutter_gen` çıktısı (`assets.gen.dart`, `fonts.gen.dart`).
- `l10n/`: `arb/*_tr.arb` feature dosyaları, birleşik `app_tr.arb` ve üretilmiş `app_localizations*.dart` ([05_araclar.md](05_araclar.md)).
- `vendor/flutter_document_scanner/`: pubspec'te `path:` bağımlılığı olan kopya tarayıcı paketi. `build.yaml`, `analysis_options.yaml` ve `tool/format.sh` onu hariç tutar; elle düzenlenmez.

**Test düzeni:** `test/` klasörü `lib/` yapısını yansıtır (`test/app/**`, `test/core/**`, `test/dependency_injection/**`, `test/services/**`, `test/features/<f>/{application,data,presentation}/**`, `test/shared/ui/**`). Router ve DI değişikliklerinde `test/app/**` ve `test/dependency_injection/**` birlikte güncellenir.

---

## 10. Tuzaklar

1. **`.gr.dart`'ı elle düzenleme; `build_runner`'ı yükseltme.**
   - Yeni View için `app_router.dart` içine import da gerekir; aksi halde `XxxRoute` üretilmez.
   - `pubspec.yaml`'da `build_runner: 2.13.1` pinlidir (yorum: 2.15 betiği AOT derler ve `objective_c` build hook'ları yüzünden kırılır).
   - `build.yaml`, `dart_mappable` metotlarını yeniden adlandırır: `fromJson` → `fromJsonString`, `fromMap` → `fromJson`. Üretilen kodu okurken şaşırtır ([02_veri.md](02_veri.md)).
2. **Yol sırası.** Sabit yol `:param`'dan önce gelmelidir:
   - `deck`, `:lessonId`'den önce.
   - Koç sabit yolları `exam/...` ve `program/...`, `:studentId`'den önce.
   - `/account/delete/progress`, kabuklardan önce (kök listede).
   - `/program/new` kasıtlı olarak `/home/program/new` değildir.
3. **`/` iki rotaya benziyor.** `StartupRoute` `/` yolunu alır, öğrenci kabuğu da prefix olarak `/` kullanır. Kabuğun kendi sayfası yoktur; çocuğuna (`home`, `analytics`...) çözülür. Kabuğa `/`'ye eşleşen bir çocuk eklersen Startup'ı gölgelersin (test: "the launch screen keeps '/'").
4. **Guard yalnız hedefe bakar.** `router.current` ile karşılaştırma guard'ı kendi yönlendirmesinde tetikler (`AccessGuard` yorumu). Yeni guard kuralı yazıyorsan `route_access.dart`'ta saf fonksiyon olarak yaz ve `test/app/router/route_access_test.dart`'a ekle.
5. **`RouteGroup.other` guard'sızdır.** `/scan`, `/scan/result/:examId`, `/program/new`, hesap silme ekranları gruba girmez. Oturum yokken açılamamalarının tek güvencesi, bunları yalnız oturumlu ekranların itmesi ve OS derin bağlantısının bulunmamasıdır. Yeni bir kök akış ekliyorsan bunu bil; dışarıdan bağlanabilir hale getirirsen guard grubu da eklemelisin.
6. **Oturum kapsamı servisleri kök kapsamdan erken çözülmez.**
   - Oturum kapsamındaki servisi (`CurrentUserService`, `LessonsService`...) kök kapsam servisinin constructor'ında `locator<...>()` ile çözersen oturum yokken hata alırsın ve eski kullanıcıyı yakalayabilirsin.
   - Doğru örnek `registerScanData`: `user: () => l<CurrentUserService>().user?.toJson()`, yani lazy bir kapanış; iş başlarken çözülür.
   - Süresi dolan oturumda kapsam kapatılmaz. Aynı kullanıcı yeniden girerse `_enterScopeFor` kapsamı korur, başkası girerse yeniden kurar.
7. **Modül kaydını unutma** (§3.3). `registerXxx`'i `kDataModules`/`kServiceModules`/`kSessionModules` listesine eklemezsen çalışma zamanında "not registered" hatası alırsın. Bu dosya ortak dosyadır.
8. **ViewModel'i get_it'e kaydetme.** `View.viewModelBuilder` içinde kurulur; `reactive => false` olan kök View, bölüm bazında `SelectorViewModelWidget` kullanır ([03_ekran.md](03_ekran.md)).
9. **Koç bağlamı yolda yok.** `StudentRef` (kimlik, ad, `ImageProvider` avatar, sınıf/alan metni, `aimType`; `lib/shared/ui/navigation/student_scope.dart`) `ExamDetailRoute(student:)`, `QuestionDetailRoute(student:)`, `ProgramListRoute(student:)`, `ProgramDetailRoute(student:)`, `NewProgramRoute(student:)` gibi rota argümanıyla taşınır, yolda yoktur. Yolda yalnız Profil için `:studentId` vardır. Argümansız açılan bir link koç bağlam şeridini ve öğrenci id'li istekleri kaybeder. `ExamDetailRoute.exam` ve `MeetingDetailRoute.meeting` de yolda yoktur; argümansız açılışta liste okunur.
10. **Bayrak = rota listesinde yok.** `FeatureFlags` derleme zamanı sabitleridir. Kapalı bayrak rotayı `AutoRoute` listesinden çıkarabilir (`forgotPasswordEnabled`, `passwordChangeEnabled`); `StackAccountNavigator.canOpen` bu yüzden satırı çizmez. Bayrağı açmak, o ekranın bağımlılığını (ör. `PasswordRepository`, `ForgotPasswordRepository`; ikisi de `application/` altında tanımlı ama kayıtsızdır) locator'a kaydetmeyi de gerektirir. Bayrak yorumlarında yazılıdır ([02_veri.md](02_veri.md) §4).
11. **`context.router` ile `AppRouter` farkı.** Sekme içi detay ekranını kök `AppRouter.push` ile itersen alt çubuk kaybolur, sekme yığını bozulur. Tam ekran akışı `context.router` ile itersen kabuğu örtmez. Sekme içi `context.router` (`StackLessonsNavigator(context.router)`), tam ekran kök `AppRouter` (`ScanEntry`, `LoginRoute`) kullanır.
12. **`AppSheet.navigatorKey` statiktir.** `registerAppServices` içindeki lazy `AppRouter` kurucusunda atanır. Uygulama kodunda `AppRouter(...)` ile ikinci bir örnek kurma; router'ı `locator<AppRouter>()` ile al (testlerde elle kurulur).
13. **`ShellPreview` guard'ları kapatır.** `--dart-define=SHELL_PREVIEW=...` açıkken `AccessGuard` hiçbir şeyi denetlemez ve oturum kapsamı kullanıcısız açılır. Release'te `kDebugMode` ile devre dışıdır. Git geçmişi: `c8978b3` ("önizlemede oturum kapsamı"), sekme ekranları oturum servislerini çözemediği için kapsamı eklemiştir.
14. **Alt boşluk (kabuk).** Sekme gövdesinde `MediaQuery` alt güvenli alanı `extendBody` ile sıfırlanır. `_ShellTabStack` cihazın değerini geri koyar (`deviceBottom`). Ekranlar alt çubuk yüksekliğini `AppBottomBar.heightOf` ile ekler. Geçmiş: `07c93b8` ("kabuk alt boşluğu"), `2dd31bc` (`account_bar_clearance` kaldırıldı, "kök neden kabukta"). Ekran bazlı elle boşluk sabiti ekleme.
15. **Sekme köküne dönüşte scroll.** `scrollTabToTop`, her rotanın kendi birincil scroll controller'ı olduğundan element ağacını gezip dikey `Scrollable`'ları kaydırır. Kabuğa tek controller bağlamayı deneme.
16. **Dört sekme birlikte kurulur** (§6). Bir sekmenin kök ekranına ağır iş koyarsan açılışta dört sekme aynı anda yük bindirir.
17. **Hesap silme çıkışı uzaktan logout yapmaz.** `completeAccountDeletion()` (`remote: false`) çerezi, önbelleği, kişiye ait cihaz tercihlerini (`DevicePreferences.clearAccount`) ve kapsamı temizler ama `/ajax/logout` çağırmaz, çünkü oturum sunucuda yoktur. `signOut()` ise yapar.
18. **Başlatma hatası ve tekrar deneme.** `MainInitializer._initialize` içinde fırlayan her şey `BootFailureApp`'a gider. `_retry`, `resetDependencies()` (`locator.reset()`) çağırır, ardından `_start()` yeniden çalışır. Modül kayıtlarında ve `DevicePreferences.load`'da fırlatan kod açılışı bloklar; bu yüzden kayıtlar lazy ve yan etkisiz olmalıdır. `DevicePreferences` yalnız `allowedKeys` içindeki anahtarları önbelleğe alır ve okutur; yeni anahtarı önce oraya ekle. Anahtar cihaza değil kişiye aitse `accountKeys`'e de ekle; yoksa çıkıştan sonra bir sonraki hesaba kalır ([02_veri.md](02_veri.md) §8).
19. **Bakım ve zorunlu güncelleme ekranları canlıda kapalıdır** (`DisabledStartupGate`, §2). Bu ekranları açmak için backend'in public config ucu ve `registerStartupServices` içindeki kaydın değişmesi gerekir.
20. **Kod ile yorum çelişirse kodu okuyun.** Bilinen bayat yorum kalmadı: `lib/features/coach/coach_students_routes.dart` sonundaki yorum bugün `ShellTabSpec.route`'u anar (eski `ShellTabContent` cümlesi düzeltildi; `ShellTabSpec` yalnız `route` taşır). Emin olmak için `grep`, `dart run tool/unreachable_files.dart` ve ilgili testi kullanın.
21. **Ölü kod silmeden önce kanıt.** `AGENTS.md`: gerçek backend'e karşı çalışan özellik silinmez; yalnız ölü, erişilemez, mock ya da "yakında" kodu grep kanıtıyla silinir. `dart run tool/unreachable_files.dart` erişilemeyen dosyaları listeler (giriş noktaları `lib/main.dart` ve `lib/main_gallery.dart`; `test/`'i ayrıca grep'leyin; koşullu import'u çözmez).
22. **CI'da yakalananlar** ([05_araclar.md](05_araclar.md)): `flutter pub get --enforce-lockfile`; l10n tazeliği (`dart run tool/merge_arb.dart` ve `flutter gen-l10n`, sonra `git status --porcelain lib/l10n` boş olmalı); `build_runner build -d` sonrası temiz `git status`; `tool/format.sh --output=none --set-exit-if-changed` (biçim denetimi, `lib/vendor` hariç); `flutter analyze --no-pub` (sıfır sorun); `tool/ui_rules.sh` (ham renk, `TextStyle(`, `fontSize:`, `Icons.`, diyalog/`SnackBar`, `Navigator.push`, `print(`, `Widget _build`, sunumda ham `Duration(` ve dosya boyu sınırları: ekranın `_view` dosyası 250, `part` 300, ViewModel 500, diğer sunum ve kit dosyaları 400 satır); `flutter test --no-pub`. CI, yalnız `docs/**` ve `*.md` değişikliklerinde çalışmaz.

---

## İlgili dosyalar

- Açılış ve DI: `lib/main.dart`, `lib/main_initializer.dart`, `lib/app/app.dart`, `lib/app/app_module.dart`, `lib/app/boot_failure_app.dart`, `lib/dependency_injection/injection_container.dart`, `lib/features/*/*_module.dart`
- Oturum: `lib/services/session_manager.dart`, `lib/services/current_user_service.dart`, `lib/core/services/device_preferences.dart` (`accountKeys`, `clearAccount`), `lib/features/auth/domain/session_state.dart`, `lib/features/startup/application/{startup_gate,launch_handover,startup_timing,session_expired_coordinator}.dart`, `lib/features/startup/presentation/startup/startup_viewmodel.dart`
- Router: `lib/app/router/app_router.dart` (+ üretilen `app_router.gr.dart`), `lib/app/router/route_refresh.dart`, `lib/app/router/stack_router_x.dart`, `lib/app/router/routes/shell_routes.dart`, `lib/features/*/*_routes.dart`
- Guard'lar: `lib/app/router/guards/{route_access,access_guard,route_catalog,onboarding_guard,auth_guard,role_guard}.dart`, `lib/core/domain/user_role.dart`, `lib/features/account/presentation/stack_account_navigator.dart`
- Kabuk: `lib/app/shell/*`, `lib/features/shell/application/shell_bar_policy.dart`, `lib/features/shell/presentation/shell_viewmodel.dart`, `lib/features/scan/presentation/scan_entry.dart`, `lib/shared/ui/navigation/app_bottom_bar.dart`
- Debug: `lib/app/shell/shell_preview.dart`, `lib/features/debug/launch_env.dart`, `lib/main_gallery.dart`, `.vscode/launch.json`
- Testler: `test/app/router/{app_router,route_access,route_refresh}_test.dart`, `test/app/shell/shell_routes_test.dart`, `test/dependency_injection/injection_container_test.dart`, `test/services/session_manager_test.dart`
- Diğer bölümler: [02_veri.md](02_veri.md), [03_ekran.md](03_ekran.md), [04_tasarim_sistemi.md](04_tasarim_sistemi.md), [05_araclar.md](05_araclar.md), [06_ozellikler.md](06_ozellikler.md), [../DEVELOPING.md](../DEVELOPING.md), [../WORKFLOW.md](../WORKFLOW.md)
