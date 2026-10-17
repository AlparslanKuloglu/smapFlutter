# 03 · Sunum katmanı: ekran kalıbı ve yeni ekran tarifi

Bu bölüm, SMAP'te bir ekranın nasıl kurulduğunu anlatır: `StackedView` kabuğu, bağlamsız ViewModel, seçicili bölümler, bölüm durumları, sheet'ler, toast, "Geri Al" bekletmesi, geri tuşu, haptik ve erişilebilirlik. Projeyi ilk kez açan deneyimli bir Flutter geliştiricisi (ve AI ajanları) içindir; her iddia koddaki gerçek bir dosyaya ve sembole bağlıdır. Sonunda kopyalanabilir bir **yeni ekran tarifi** (bölüm 16) ve kontrol listesi vardır.

Komşu bölümler: mimari ve katmanlar için [01_mimari.md](01_mimari.md), veri katmanı (repository, DTO, `Either`) için [02_veri.md](02_veri.md), komutlar ve araçlar için [05_araclar.md](05_araclar.md), özellik haritası için [06_ozellikler.md](06_ozellikler.md), tasarım sistemi (token'lar, kit, galeri) için [04_tasarim_sistemi.md](04_tasarim_sistemi.md), giriş için [../DEVELOPING.md](../DEVELOPING.md). Kuralların kısa özeti `AGENTS.md`'de ("Architecture", "UI rules") durur.

## 1. Büyük resim

Sunum katmanı feature-first MVVM'dir ve `stacked` kullanır. Bir ekran dört parçadan oluşur:

| Parça | Nerede | Sorumluluğu |
|---|---|---|
| View kabuğu | `<screen>_view.dart` | `StackedView`; ViewModel'i kurar, sayfa iskeletini verir. |
| ViewModel | `<screen>_viewmodel.dart` | Durum ve eylemler. `BuildContext` bilmez. |
| Bölümler | `widgets/*.dart` (`part` dosyaları) | Her biri bir `SelectorViewModelWidget`. |
| Sheet'ler | `sheets/` | `AppSheet` ile açılan, tipli sonuç döndüren modal'lar. |

Saf mantık (sıralama, kurallar, modeller) `lib/features/<f>/application/` altında durur ve birim testlidir. Örnekler: `lib/features/coach/application/meeting_list_logic.dart`, `note_rules.dart`, `note_delete_hold.dart`.

Dört kural bu katmanın omurgasıdır:

- ViewModel hiçbir zaman `get_it`'e kaydedilmez. `viewModelBuilder` servisleri `locator`'dan alıp ona verir (`lib/dependency_injection/injection_container.dart` başlığı bunu söyler).
- Navigasyon, sheet ve toast ViewModel'e arayüz veya lambda olarak gelir.
- Kök view `reactive => false` olur. Yeniden çizimi bölümlerin seçicileri yönetir.
- Görsel iş yalnızca `lib/shared/ui` (`App*` bileşenleri) ve feature widget'larıyla yapılır ([04_tasarim_sistemi.md](04_tasarim_sistemi.md)).

## 2. Temsilî ekranların klasör iskeleti

**Görüşmelerim** (`lib/features/coach/presentation/meetings/`), tam kalıp:

```
meetings_view.dart             # StackedView + _MeetingsPage + part bildirimleri
meetings_viewmodel.dart        # BaseViewModel
meetings_navigator.dart        # abstract interface class MeetingsNavigator
stack_meetings_navigator.dart  # StackRouter üzerinde uygulama
meetings_dialogs.dart          # abstract interface class MeetingsDialogs
sheet_meetings_dialogs.dart    # AppSheet ile uygulama
widgets/   meetings_band.dart, meetings_controls.dart, meetings_list.dart, meetings_states.dart   # part'lar
sheets/    new_meeting_sheet.dart, student_picker_sheet.dart, meeting_date_sheet.dart, meeting_picker_field.dart
detail/    meeting_detail_view.dart, meeting_detail_viewmodel.dart,
           widgets/ (meeting_detail_header, _notes, _states), sheets/note_sheet.dart
```

Liste ve detay aynı navigator ve dialogs arayüzünü paylaşır. Detay alt ekranı kendi `detail/` klasöründedir.

**Anasayfa** (`lib/features/home/presentation/home/`) daha yalındır. Navigator veya dialogs arayüzü yoktur: `home_view.dart`, `home_viewmodel.dart` ve `widgets/` altında `home_band.dart`, `home_today.dart`, `home_last_exam.dart`, `home_subjects.dart`, `home_skeletons.dart`.

Ekranın dışında kalan, ama ona bağlanan dosyalar:

- Rota listesi feature kökünde durur: `lib/features/coach/coach_meetings_routes.dart`, `lib/features/home/home_routes.dart`. Sekme listelerini `lib/app/router/routes/shell_routes.dart` birleştirir, tam ekran akışları `AppRouter.routes` (`lib/app/router/app_router.dart`) listeler.
- DI kaydı feature kökündeki `*_module.dart` içindedir (`lib/features/coach/coach_module.dart`: `registerCoachData`, `registerCoachSession`) ve `lib/dependency_injection/injection_container.dart` listelerine eklenir.
- Metinler `lib/l10n/arb/<feature>_tr.arb` dosyasındadır.

## 3. View kabuğu: `StackedView` + `reactive => false`

`MeetingsView` kabuğun tam örneğidir (`meetings_view.dart`, sınıf `MeetingsView`):

```dart
@RoutePage()
class MeetingsView extends StackedView<MeetingsViewModel> {
  const MeetingsView({super.key});

  @override
  bool get reactive => false;

  @override
  void onViewModelReady(MeetingsViewModel viewModel) => viewModel.init();

  @override
  MeetingsViewModel viewModelBuilder(BuildContext context) => MeetingsViewModel(
    interviews: locator<InterviewRepository>(),
    navigator: StackMeetingsNavigator(context.router),
    dialogs: SheetMeetingsDialogs(l10n: AppLocalizations.of(context)),
    toast: locator<ToastService>(),
    online: locator<ConnectivityService>().online,
    // The shell preview (no account) has no session scope.
    students: locator.isRegistered<CoachStudentsService>()
        ? locator<CoachStudentsService>()
        : null,
  );

  @override
  Widget builder(BuildContext context, MeetingsViewModel viewModel, Widget? child) =>
      _MeetingsPage(viewModel: viewModel);
}
```

Dikkat edilecek noktalar:

- `reactive => false` olduğu için ViewModel `notifyListeners()` çağırınca kök `builder` yeniden çalışmaz. Yalnızca seçicisi değişen bölüm çizilir.
- `builder` çoğu ekranda `const _XxxPage()` döndürür (`HomeView`, `MeetingDetailView`). Meetings'te `_MeetingsPage` bir `StatefulWidget`'tır, çünkü `TextEditingController` widget'a aittir. ViewModel controller tutmaz; "Aramayı Temizle" için `searchCleared` `ValueNotifier<int>`'ını artırır ve sayfa dinler.
- `onViewModelReady` içinde `init()` bir kez çağrılır. ViewModel `_started` bayrağıyla ikinci çağrıyı yok sayar. `init()` `Future` döndürüyorsa (`HomeViewModel`) view `unawaited(viewModel.init())` yazar.
- `@RoutePage()` ile `XxxView` otomatik `XxxRoute` olur (`AppRouter`, `replaceInRouteName: 'Page|Screen|View,Route'`). Rota argümanı gerektiren view, ilgili tipi re-export eder: `meeting_detail_view.dart` sonunda `export '…meeting_models.dart' show MeetingEntry;` vardır, çünkü üretilen `MeetingDetailRoute` bu tipi adlandırır.
- `import 'package:stacked/stacked.dart' hide StackedRouterExtensions;` satırı 31 dosyada tekrar eder. Nedeni: `stacked` kendi `context.router` uzantısını (`StackedRouterExtensions`) dışa aktarır ve auto_route'unkiyle çakışır. Router kullanan her view/part kök dosyasında aynı satırı kopyalayın.

### 3.1 Bir ekranı hem sayfa hem bölüm olarak vermek

Bir ekran başka bir ekranın içine bölüm olarak gömülecekse ViewModel aynı kalır, iki view yazılır. Örnek: `ProgramDetailView` (kendi çubuğu olan sayfa) ve `ProgramDetailSection` (koçun öğrenci profilinde "Program" sekmesi; sliver'ları ev sahibinin kaydırma alanına verir), ikisi de `lib/features/schedule/presentation/program_detail/program_detail_view.dart` içindedir ve `_detailViewModel(...)` ile aynı ViewModel'i kurar.

Ev sahibi ile gömülü bölüm arasındaki durum köprüsü `ProgramEditLink`'tir (`lib/features/schedule/application/program_edit_link.dart`): ev sahibi (`StudentProfileView`'ın sayfa `State`'i) bir link üretir ve bölüme verir; bölümün ViewModel'i `attach` ile "Bitti" eylemini bağlar, düzenleme başlayıp bitince `report(editing:, title:)` çağırır; ev sahibinin çubuğu `editing`'i dinler ve `finish()` çağırır. ViewModel dispose olurken `detach()` çağırır (güncelleme bir microtask'a ertelenir, ağaç sökülürken ev sahibine yeniden çizim dedirtmemek için). Koç görünümü için kitteki `StudentScope` ([04_tasarim_sistemi.md](04_tasarim_sistemi.md)) bölümü sarar.

## 4. ViewModel kuralları (context'siz)

### 4.1 Navigasyon

İki desen vardır, ikisi de gerçektir.

**Desen A: arayüz + `Stack*Navigator`** (sekme yığınındaki ekranlar, hedef kalıp). ViewModel yalnızca arayüzü tanır:

```dart
// meetings_navigator.dart
abstract interface class MeetingsNavigator {
  Future<void> openMeeting(MeetingEntry meeting);
  Future<void> openStudentData({required String studentId, required String name, String? photo});
}
```

Uygulama ayrı dosyadadır ve `context.router` ile kurulur (`stack_meetings_navigator.dart`):

```dart
class StackMeetingsNavigator implements MeetingsNavigator {
  const StackMeetingsNavigator(this._router);
  final StackRouter _router;

  @override
  Future<void> openMeeting(MeetingEntry meeting) =>
      _router.push(MeetingDetailRoute(meetingId: meeting.id, meeting: meeting));
  // ...
  }) => _router.navigate(
    CoachStudentsTabRoute(
      children: [
        const StudentsRoute(),
        StudentProfileRoute(studentId: studentId, tab: 'program'),
      ],
    ),
  );
```

`push` aynı sekmenin yığınına ekler, alt çubuk kalır. `navigate(...TabRoute(children: [...]))` sekmeyi değiştirir ve o sekmenin yığınını kurar. Sekme başına yığın kuralı pano 1.19'dan gelir.

Bu desenin nedeni testtir: testler arayüzü sahteleyip çağrıları kaydeder (`FakeMeetingsNavigator`, `test/features/coach/presentation/meetings/meetings_fakes.dart`).

Adlandırma iki önek taşır. Sekme yığınındaki ekranlar `Stack*` kullanır (`StackMeetingsNavigator`, `StackStudentsNavigator`, `StackLessonsNavigator`, `StackExamDetailNavigator`, `StackResultMomentNavigator`, `StackAccountNavigator`); tam ekran akışlar `Router*` kullanır (`RouterScanNavigator`, `RouterRegisterNavigator`, `RouterProgramNavigator`, `RouterPasswordNavigator`, `RouterAccountDeletionNavigator`). Yeni sekme ekranı için `Stack*` önekini seçin.

**Desen B: enjekte edilen `AppRouter`** (kök veya kabuk ekranlar). ViewModel doğrudan `AppRouter` alır: `HomeViewModel(router: locator<AppRouter>())` onu yalnızca kamerayı açmak için kullanır (`ScanEntry.start(_router)`). Aynı şeyi `AnalyticsViewModel` (kamera), `ShellViewModel`, `LoginViewModel`, `ForgotPasswordViewModel`, `StartupViewModel` ve `MaintenanceViewModel` yapar. `AGENTS.md`'deki "navigasyon enjekte edilen `AppRouter` ile" cümlesi bu desene dayanır.

**Home'daki geçiş durumu.** Anasayfa'daki geçişler ViewModel'de değil view dosyasında, `context.navigateTo(...)` (ve `context.router.push`) ile yapılır: `home_view.dart` içindeki özel `_openExam`, `_openLesson`, `_openTopic`, `_openProgram`, `_openProgramSetup`. ViewModel dokümanı bunu açıkça söyler: "the screens it cannot route to yet are opened by the view". Yeni ekranda bu kısayolu kopyalamayın; Desen A hedeflenen kalıptır, Home bir istisnadır.

### 4.2 Sheet'ler (`*Dialogs`)

Ekran, ViewModel'e sheet'leri bir arayüzle verir. `MeetingsDialogs` içinde üç yöntem vardır: `newMeeting(...)`, `writeNote(...)`, `confirmDeleteNote(...)`. Hepsi `Future<bool>` döndürür. Kaydeden sheet'ler için `typedef MeetingSubmit = Future<bool> Function(MeetingDraft)` ve `NoteSubmit` tanımlıdır (`meetings_dialogs.dart`).

Uygulama `SheetMeetingsDialogs`'tır. Context taşımaz, sheet `AppSheet.navigatorKey` üzerinden kök navigator'da açılır:

```dart
@override
Future<bool> confirmDeleteNote({required String text}) async {
  final result = await AppConfirmSheet.show(
    title: l10n.coachMeetings_noteDeleteTitle,
    message: l10n.coachMeetings_noteDeleteBody(text),
    confirmLabel: l10n.coachMeetings_noteDeleteAction,
    cancelLabel: l10n.common_cancel,
    danger: true,
  );
  return result.confirmed;
}
```

`l10n` metni view'dan `AppLocalizations.of(context)` ile gelir. Uygulama yalnızca Türkçe olduğu için bu güvenlidir (`sheet_meetings_dialogs.dart` doc'u).

`AppSheet.navigatorKey` bir kez `lib/app/app_module.dart` içinde, router ilk kurulurken atanır. Context verilmezse ve anahtar yoksa `AppSheet.show` hiçbir şey açmaz ve `null` döner (`lib/shared/ui/sheets/app_sheet.dart`).

### 4.3 Toast: `ToastText` lambda'ları

Metin, context olmayan yerde `ToastText = String Function(AppLocalizations)` lambda'sıyla verilir. `ToastService` çözümlemeyi yapar:

```dart
_toast.error((l) => l.coachMeetings_noteSaveFailed);
_toast.success((l) => l.coachMeetings_noteAdded);
_toast.undo((l) => l.coachMeetings_noteDeleted, onUndo: _undoDelete);
```

Davranış (`lib/core/services/toast_service.dart`):

- Aynı anda tek toast gösterilir, yenisi eskisini değiştirir. Kök navigator'ın overlay'inde çizilir, router gerekmez.
- Toast 4 sn durur, `undo` ile 6 sn (`SmapDurations.toast`, `undoToast`). Ekran okuyucu açıksa kapatılana kadar kalır.
- `error` hata haptiğini, `success` başarı haptiğini kendisi çalar. Eylem zaten kendi haptiğini çaldıysa `haptic: false` verin. `undo` haptik çalmaz.
- Alt çubuğun 8 pt üstünde durur. Yüksekliği `ToastService.bottomBarHeight`'tan alır; kabuğun ViewModel'i (`ShellViewModel`) bunu çubukla senkron tutar. Kart destesi toast'u eylem satırının üstüne kaldırmak için değeri geçici artırır (`CardDeckViewModel`, 6. bölüm sonunda).
- Kalıcı hata toast'la anlatılmaz, ekranda durum olarak çizilir (`toast_slot.dart` doc'u).

Çevrimdışı şeridi ekranların değil kabuğun işidir (`lib/app/shell/widgets/shell_offline_strip.dart`, kitteki `AppOfflineStrip`). Yalnız sheet açıkken şeridi sheet'in üstünde göstermek için `AppSheet.show(online: ...)` kullanılır (bölüm 9).

## 5. Seçici (`SelectorViewModelWidget`) ve değer sözleşmesi

`AGENTS.md`: "her veri bölümü, değişmez değerler üzerinde record seçiciyle bir `SelectorViewModelWidget`; eylemler `getParentViewModel(context, listen: false)`".

**Tek değerli seçici.** `_MeetingsBand` yalnızca `bool offline` seçer (`widgets/meetings_band.dart`):

```dart
class _MeetingsBand extends SelectorViewModelWidget<MeetingsViewModel, bool> {
  const _MeetingsBand();

  @override
  bool selector(MeetingsViewModel viewModel) => viewModel.offline;

  @override
  Widget build(BuildContext context, bool offline) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<MeetingsViewModel>(context, listen: false);
    return AppRootBand(
      title: l10n.nav_tabMeetings,
      squareCorners: offline,
      action: AppIconButton(
        icon: PhosphorIconsRegular.plus,
        semanticLabel: l10n.coachMeetings_newA11y,
        variant: AppIconButtonVariant.onNavy,
        onPressed: () => unawaited(viewModel.newMeeting()),
      ),
    );
  }
}
```

**Record seçici.** Birden çok alana bağımlı bölümlerde `typedef` ile adlandırılmış record (`_ControlsData = ({SectionState state, MeetingWith kind})`, `meetings_controls.dart`) veya konumsal record kullanılır (`_BodyData = (SectionState state, MeetingEntry? meeting)` `meeting_detail_header.dart`'ta; `_TodayData`, `_BandData` Home'da). Record'lar alan eşitliğini otomatik verir.

**Özel değer sınıfı.** Record yetmiyorsa değer sınıfı `@immutable` olur ve `==`/`hashCode` elle yazılır. `MeetingListData` (`meetings_viewmodel.dart`) bunun örneğidir. Liste içeren değer `listEquals` ve `Object.hashAll` kullanır (`MeetingNotesData`, `meeting_detail_viewmodel.dart`).

**ViewModel değeri önbelleğe alır.** Seçici her `notifyListeners`'ta çağrılır. Eşit değer üretmek için ViewModel değeri bir kez kurar:

```dart
MeetingListData? _data;
MeetingListData get list => _data ??= _build();

void _publish() {
  _data = null;
  if (!_disposed) notifyListeners();
}
```

`_publish()` önbelleği boşaltır ve bildirir. Durum değiştiren her yol `notifyListeners()` yerine bunu çağırmalıdır.

**Eylem erişimi.** `getParentViewModel<T>(context, listen: false)`. `listen: false` zorunludur; yoksa bölüm tüm ViewModel'e abone olur ve seçicinin anlamı kalmaz. `onPressed` içindeki `Future` dönen çağrılar `unawaited(...)` ile sarılır.

**Hızlı değişen değerler** (kaydırma, sürükleme, geri sayım, canlı çerçeve) `ValueNotifier` + `ValueListenableBuilder` ile taşınır, ViewModel'i bildirmez. Gerçek örnekler: `ForgotPasswordViewModel._resendSeconds` (`resendSeconds` getter'ı), `ScanCaptureViewModel._liveForm`, `lib/features/cards/presentation/widgets/card_deck.dart` içindeki `_offset`, `_fade`, `_reveal`.

**`ReactiveViewModel` ne zaman.** Durum servislerde yaşıyorsa. `HomeViewModel extends ReactiveViewModel`, `listenableServices` döndürür ve `notifyListeners()`'ı ezip önce `_derive()` ile hazır değişmez değerleri hesaplar (Home `_publish` kullanmaz; her seçici değeri `_derive` ile hazırlanmış alanlardan okur). Kendi durumunu tutan ViewModel `BaseViewModel` olur (`MeetingsViewModel`). Aynı durum servisi için sheet'in kendi ViewModel'i de `ReactiveViewModel` olabilir (`AuthorSheetViewModel`, bölüm 9).

## 6. Bölüm durumları: `AsyncSection` / `SectionState` / `withSkeletonTimeout`

Her veri bölümü beş durumdan birindedir (`lib/shared/ui/feedback/section_state.dart`):

```dart
enum SectionState { loading, ready, empty, error, offline }
```

- **loading:** düzeni yansıtan iskelet çizilir.
- **empty:** veri geldi ama boş.
- **error:** başarısız veya süre aşımı, "Tekrar Dene" ile.
- **offline:** bağlantı yok ve gösterilecek veri yok. Veri varsa bölüm `ready` kalır, çevrimdışı şeridini (kabuk) anlatır.

**`AsyncSection<T>`** durum + veri taşıyan, `==` tanımlı değişmez değerdir. Seçiciye doğrudan konabilir (`HomeViewModel.lastExam`). Kurucular: `.loading()`, `.ready(data)`, `.empty()`, `.error([e])`, `.offline()`. Yardımcılar: `AsyncSection.of`, `failed` (çevrimdışı hatayı `offline`'a ayırır), `load`.

`AsyncSection.load` çağrıyı 15 sn sınırı altında çalıştırır ve asla fırlatmaz:

```dart
static Future<AsyncSection<T>> load<T>(
  Future<T> Function() fetch, {
  bool Function(T data)? isEmpty,
  Duration timeout = SmapDurations.skeletonTimeout,
}) async {
  try {
    final data = await withSkeletonTimeout(fetch(), timeout: timeout);
    return of(data, isEmpty: isEmpty);
  } on Object catch (e) {
    return failed<T>(e);
  }
}
```

`withSkeletonTimeout` yalnızca `future.timeout(timeout)`'tir. Sınır `SmapDurations.skeletonTimeout` = 15 sn'dir (`lib/core/theme/app_motion.dart`). İstek iptal edilmez; gerekirse Dio `CancelToken` ayrıca kullanılmalıdır (doc'ta yazılı). Olay güdümlü yüklemeler için `SkeletonWatchdog` (başlat/durdur/zaman aşımı) vardır.

**Repository `Either` döner, ViewModel throw'a çevirir** ([02_veri.md](02_veri.md)). `MeetingsViewModel._unwrap<T>` bunu yapar: `(await answer).fold((AppException f) => throw f, (v) => v)`. Sonra `AsyncSection.load` onu duruma çevirir.

Bölüm widget'ı durumu `switch` ile çizer (`widgets/meetings_list.dart`, sınıf `_MeetingsListSection`):

```dart
return switch (data.state) {
  SectionState.loading => const _MeetingsSkeleton(),
  SectionState.empty => const _MeetingsEmpty(),
  SectionState.error || SectionState.offline => const _MeetingsError(),
  SectionState.ready =>
    data.sections.isEmpty && !data.hasMore
        ? _MeetingsNoMatch(data: data)
        : _MeetingGroups(data: data),
};
```

Gerçek kurallar:

- İskelet `AppSkeleton` + `SkeletonBox` ile ekranın gerçek biçimini taklit eder (`meetings_states.dart`, `home_skeletons.dart`). `AppSkeleton` ekran okuyucuya tek öğe olarak "Yükleniyor" okutur, kutuları atlar. Reduce motion'da parlama durur (`app_skeleton.dart`). İskelet yüksekliği gerçek bloğunkine eşit olmalıdır, yoksa yükleme bitince sayfa zıplar. Bu sözleşmeyi tutan tek widget testi `test/features/exams/presentation/exam_score_card_height_test.dart`'tır (`ExamScoreCard.fullHeight`).
- Boş, hata ve çevrimdışı için hazır bileşenler: `AppEmptyState.screen/section`, `AppErrorState.screen/section`. Bölüm düzeyi kartlar başlık alabilir; boş bölüm kartı `primaryAction: true` ile tam genişlik birincil düğme çizer. Ayrıntı [04_tasarim_sistemi.md](04_tasarim_sistemi.md)'de.
- Bölümler bağımsızdır. Home'da üç bölüm ayrı yüklenir ve biri düşerse diğerleri çalışır.
- Başarısız bir yenilemede ekrandaki veri korunur. `HomeViewModel._loadLastExam` içinde `if (!_lastExam.isReady && !_lastExam.isEmpty)` koşulu bunu sağlar. Meetings'te sessiz yenileme başarısızlığı toast olur (`_reload(skeleton: false)` içinde `coachMeetings_refreshFailed`).
- Sahte veri çizilmez. Alan eksikse çizilmez. `MeetingEntry.fromDto` null dönebilir ve liste `?MeetingEntry.fromDto(dto)` ile atlar.

## 7. Tek `CustomScrollView` ve sliver düzeni

Her ekranda bir `CustomScrollView` vardır. `NestedScrollView` ve `sliver_tools` kullanılmaz; `pubspec.yaml` ve `lib/` içinde yoktur. Bant (`AppRootBand`, `AppHomeBand`, `AppDetailBar`) ilk sliver'dır, içerik sliver'ları arkasından gelir ve en sonda alt çubuk boşluğu eklenir:

```dart
CustomScrollView(
  physics: const AlwaysScrollableScrollPhysics(),
  slivers: [
    const _MeetingsBand(),
    _MeetingsControls(search: _search),
    const _MeetingsListSection(),
    SliverToBoxAdapter(
      child: SizedBox(height: AppBottomBar.heightOf(context) + AppSpacing.s16),
    ),
  ],
),
```

- `RefreshIndicator`'a `edgeOffset: collapsedBand` verilir. Bant boyutu `RootBandMetrics` / `HomeBandMetrics(...).minExtent` ile ölçülür ve metin ölçeğine bağlıdır (`lib/shared/ui/navigation/band_math.dart`).
- Alt boşluk `AppBottomBar.heightOf(context)` ile verilir. Git geçmişi: `2dd31bc` eski `account_bar_clearance` yerine bunu getirdi, kök neden kabuktaydı (`1e86d60`).
- `PinnedHeaderSliver` yapışan başlık içindir: `AppContextStrip` (koçun öğrenci ekranları), sekme çubukları (`exam_detail_tabs.dart`, `student_profile_tabs.dart`), `register_view.dart`'ta `_RoleBar`.
- `SliverMainAxisGroup` bir bölümün birden çok sliver'ını tek sliver gibi gruplar. Örnekler: `analytics_general_body.dart`, `student_profile_body.dart`, `program_detail_header.dart`.
- Sekmeli ekranlarda gövde tembeldir: yalnızca açık sekme kurulur. `StudentProfile`'da ziyaret edilen sekme `SliverVisibility(maintainState: true)` ile korunur (`student_profile_body.dart`).
- Home'da bölümler `SliverList(delegate: SliverChildListDelegate.fixed([...]))` içinde dizilir, bölümler arası `_sectionGap = 28`.

Meetings detayında (`meeting_detail_view.dart`) `_DetailBar` ve `_DetailBody` aynı kalıpla yazılmıştır; gövde `SliverPadding` içinde `SliverList` olarak çizilir.

## 8. Part dosyalarına bölme ve boyut sınırları

Sınırlar (`AGENTS.md`): view kabuğu ≤ 250 satır, `part` dosyası ≤ 300, ViewModel ≤ 500, diğer her sunum ve kit dosyası ≤ 400. Kurallar:

- `Widget _buildX()` yazılmaz, sınıf widget'ı yazılır.
- Bir part dosyası tek bölüm taşır, `part of '../meetings_view.dart';` ile başlar. Özel `_Widget`'lar const kuruculudur.
- `part` bildirimleri ve ortak sabitler (`_sectionGap`, `_gutter`) kök view dosyasında durur. Bölümler kök view'ın import'larını paylaşır.
- `*_dialogs.dart` ve `*_navigator.dart` ayrı dosyadır. Aynı view paylaştığı için meetings ve detay ikisini birden kullanır.

**Sınırlar artık CI'da zorlanır.** `tool/ui_rules.sh` yasak desenlerin yanında satır sayısını da denetler: `part of` ile başlayan dosya 300, `*_viewmodel.dart` 500, `presentation/` altındaki `*_view.dart` 250, `lib/features/*/presentation` ve `lib/shared/ui` altındaki diğer dosyalar 400. Üretilen kod (`.g`, `.gr`, `.mapper`, `.freezed`) ve debug galerileri (`/debug/`) sayılmaz. Betiği çalıştırmak için `tool/ui_rules.sh` (repo kökünden); sınır aşılırsa `::error::File too long` yazar ve çıkış kodu 1 olur. Betik ayrıca `fontSize:`, `Widget _build` ve sunumda ham `Duration(` kullanımını yakalar (bkz. [04_tasarim_sistemi.md](04_tasarim_sistemi.md) §ui_rules).

Bu belge yazılırken en büyükler sınırın altındaydı: view kabuğu `register_view.dart` (249), ViewModel `analytics_viewmodel.dart` (485), diğer dosyalar `band_math.dart` (373) ve `app_segmented.dart` (372). Sınıra yaklaşınca bölün. Geçmişteki bölmeler: `02dcf63` (`StackLessonsNavigator` ayrı dosyaya, ViewModel 500'ün altına), `34bfe33`, `d8da851` (`AppHomeBand` satırları part dosyasına), `213a9e1` (`WeekGridMetrics` `week_grid_parts.dart`'a), `2f90369` (`AppSheetFrame` başlık ve alt parçaları `app_sheet_frame_parts.dart`'a).

`tool/ui_rules.sh` hâlâ denetlemez: `Text('literal')` (metinler ARB'den gelir), `reactive`, `toUpperCase`, `SharedPreferences.getInstance`, mihr renk ve tipografi getter'ları. Bunlar incelemede yakalanır.

## 9. `AppSheet` ve tipli sonuç

Tüm diyaloglar `AppSheet` sheet'idir. `showDialog`, `AlertDialog`, `showModalBottomSheet` ve `SnackBar` yasaktır (`tool/ui_rules.sh` ile CI'da denetlenir). Sheet bir değer döner; yazan, toast gösteren ve geri alan çağıran ViewModel'dir.

`NoteSheet` (`meetings/detail/sheets/note_sheet.dart`) deseni:

```dart
static Future<bool> show({required NoteSubmit submit, String? initialText,
    DateTime? date, String? studentName, BuildContext? context}) async {
  final saved = await AppSheet.show<bool>(
    context: context,
    builder: (_) => NoteSheet._(submit: submit, initialText: initialText,
        date: date, studentName: studentName),
  );
  return saved ?? false;
}
```

Bu kalıbın tutarlı parçaları:

- Özel kurucu + statik `show(...)`. İsteğe bağlı `BuildContext? context` ViewModel'siz çağrı için `null` kalır.
- `AppSheet.show<T>` `T?` döner. Kapatma (sürükle, perde, Geri) `null`'dır. `SheetOutcome` ve `.outcome` uzantısı "vazgeçti" ile "değer seçti"yi ayırmak içindir (`SheetSubmitted`, `SheetDismissed`; `valueOr`, `valueOrNull`, `when`).
- Kaydeden çağıran ViewModel'dir. Sheet'e `submit` (`Future<bool> Function(...)`) verilir: sheet meşgulken çağırır, `true` ise `Navigator.of(context).pop(true)`, `false` ise sheet açık kalır ve girdi korunur. Hata toast'unu ViewModel (ya da onun kullandığı akış) basar: `NewMeetingFlow`, `MeetingDetailViewModel._saveNew`.
- `AppSheetFrame(busy: _busy, ...)` meşgul durumunu görselleştirir: Kapat gizlenir, sürükleme, perde ve Android Geri engellenir, birincil düğme döner. Kaydetme sırasında başka yoldan kapanmaz. Kaydedilmemiş girdi için `onCloseAttempt` vardır. Çerçevenin başlık ve alt düğme bandı parçaları `lib/shared/ui/sheets/app_sheet_frame_parts.dart`'tadır (`part`).
- Onay sheet'i `AppConfirmSheet.show` + `ConfirmResult`'tır. `danger: true` kırmızı onay + odaklı "Vazgeç" verir. Perdeye dokunmak "Vazgeç" sayılır.
- Boyut: `AppSheetSize.small` (varsayılan), `medium`, `full`. Sheet açılış 350 ms, kapanış 250 ms, reduce motion'da 150 ms fade (`app_sheet_route.dart`).
- Sheet içinde sheet açılabilir: `NewMeetingSheet` içinden `StudentPickerSheet.show` ve `MeetingDateSheet.show` çağrılır, aynı kök navigator'da.
- **Sheet üstünde çevrimdışı şeridi.** Sheet kabuğun şeridini örter. Çevrimdışıyken şeridin sheet'in üstünde görünmesi gerekiyorsa `AppSheet.show(online: <ValueListenable<bool>>)` verin; kit `AppOfflineStrip`'i sheet'in üstüne koyar ve sheet'i aşağı iter. Örnek: `AuthorSheet.show` (`lib/features/lessons/presentation/literature/sheets/author_sheet.dart`) `online: online ?? service.online` geçer.
- **Sheet'in kendi ViewModel'i.** Sheet'in durumu bir servisten besleniyorsa sheet kendi `ViewModelBuilder<...>.reactive` ile bir ViewModel kurabilir (`AuthorSheet` + `AuthorSheetViewModel`). Kural aynıdır: ViewModel context bilmez, servis dışarıdan gelir.

## 10. 6 sn bekletmeli "Geri Al"

Sunucuda silmeyi veya "Öğrendim"i geri alma ucu yoktur (`note_delete_hold.dart` ve `pending_learns.dart` doc'ları; `docs/spec/SMAP_Flutter_Spec.md` §6.3 #24). Bu yüzden öğe ekrandan hemen kalkar, istek cihazda tutulur, 6 sn dolunca gider, "Geri Al" önce gelirse hiç gitmez.

`NoteDeleteHold` (`lib/features/coach/application/note_delete_hold.dart`) tek bekleyen silmeyi yönetir: `hold(note)`, `cancel()`, `flush()`, `dispose()`. Zamanlayıcı `HoldTimerFactory` ile enjekte edilir, testte elle tetiklenir.

`MeetingDetailViewModel` içinde kullanım:

```dart
Future<void> deleteNote(MeetingNote note) async {
  if (!canWrite) return;
  await _settle();
  final target = _fresh(note);
  if (target == null || _disposed) return;
  final confirmed = await _dialogs.confirmDeleteNote(text: target.text);
  if (!confirmed || _disposed) return;
  _hold.hold(PendingNoteDelete(index: target.index, text: target.text));
  _publish();
  _toast.undo((l) => l.coachMeetings_noteDeleted, onUndo: _undoDelete);
}
```

Sıra: onay sheet'i, `hold`, ekrandan gizleme (`_buildNotes` bekleyen ve uçuştaki notu süzer), toast + "Geri Al".

Bu kalıbın kuralları:

- Notlar konumla (`deleteIndex`) adreslenir. Bu yüzden aynı anda tek silme bekler. Başka her yazma (`addNote`, `editNote`, `deleteNote`) önce `_settle()` ile bekleyeni gönderir ve sunucu listesini yeniden okur.
- Ekrandan çıkarken `dispose()` önce `unawaited(_hold.flush())` çağırır, sonra `_hold.dispose()`. Aksi halde bekleyen silme kaybolur.
- "Geri Al" geç kalırsa (istek gitti) hiçbir şey yapmaz: `cancel()` `null` döner. Testi: `'"Geri Al" after the request went out finds nothing to undo'` (`meeting_detail_viewmodel_test.dart`).
- Ekran okuyucu açıkken toast kapanmaz. Bu durumda "Geri Al" pencere bittikten sonra da basılabilir; geç-basma testi bu yüzden gerçekçidir.
- Sıra tutarsızlığı: `CardDeckViewModel._commitLearn` önce toast'u, sonra bekletmeyi başlatır ("The toast first, then the hold: both last 6 s, so the toast is gone before the request can leave"). `MeetingDetailViewModel.deleteNote` ve `LiteratureService` ise bekletmeyi toast'tan önce başlatır; toast birkaç milisaniye geç kapanır. Zararsızdır (geç basış `cancel() == null` ile karşılanır) ama yeni kodda deste sırasını (önce toast, sonra bekletme) izleyin.

**Kart destesi** aynı kalıbı çoklu anahtarla uygular. `PendingLearns` (`lib/features/cards/application/pending_learns.dart`) `Map<String, Timer>` tutar. `CardDeckViewModel._commitLearn` kartı çıkarır (`_removedAt[key]` ile eski sırayı saklar), `AppHaptics.success()` çalar, `_toast.undo(...)` ve `_pending.schedule(key)` çağırır. `_undo` kartı eski yerine koyar (`_putBack`). Deste ayrıca toast'u eylem satırının üstüne kaldırır: `_toast.bottomBarHeight` değerini `toastLift` kadar artırır ve çıkarken geri alır. `LiteratureService` (`lib/features/lessons/application/literature_service.dart`) Edebiyat "Öğrendim"i için aynı `PendingLearns`'i kullanır.

## 11. `PopScope` + kapatma kuralı

Kural: Geri'yi `PopScope(canPop: false)` ile tutan ekranın "kapat" yolu `maybePop` değil `pop` olmalıdır.

Nedeni (git `5171288`): her aşama Geri'yi kendi `PopScope`'uyla tutup `viewModel.close()` çağırıyordu. `close()` `maybePop` çağırınca router yine aynı `PopScope`'a soruyor, o yine `close()` çağırıyor ve sonsuz döngü uygulamayı donduruyordu (Kamera açılamadı, Form Kontrol, Talep ve hata ekranlarındaki X ve sistem Geri).

Düzeltme `lib/features/scan/presentation/scan_flow/scan_navigator.dart` içindedir:

```dart
/// `pop`, not `maybePop`: every stage blocks Back with its own `PopScope`
/// and answers it by calling this; `maybePop` would ask that `PopScope`
/// again, which calls this again, and the loop froze the app.
@override
void close() => _router.pop();
```

Ekranın kalıbı (`scan_error_view.dart`):

```dart
PopScope(
  canPop: false,
  onPopInvokedWithResult: (didPop, _) {
    if (!didPop) viewModel.close();
  },
  child: ...
```

Regresyon testi `test/features/scan/presentation/router_scan_navigator_test.dart`'tır. `StackRouter` sahtesi `pop` ve `maybePop` çağrılarını kaydeder; test `close()` sonrası listenin tam `['pop']` olduğunu doğrular. Aynı kural başka yerlerde yorumla yazılıdır: `ForgotPasswordViewModel.finish()` (`_router.pop<String?>(name)`), `RouterAccountDeletionProgressNavigator.showFailure()` (`pop<bool>(false)`), `notification_primer_sheet.dart` (`Navigator.of(context).pop()`).

Hâlâ `maybePop` kullanan yerler engelsiz ekranlardır (`RouterAccountDeletionNavigator.close`, `RouterPasswordNavigator.close`, `ForgotPasswordViewModel`'in ilk adımı, sheet'lerdeki "Kapat" düğmeleri). Orada `maybePop` doğrudur, çünkü karşıda `PopScope(canPop: false)` yoktur. Kural: engelli ekran `pop`, engelsiz ekran `maybePop`.

`PopScope` kullanan ekranlar: scan aşamaları, `ResultMomentView` (`canPop: false`, `viewModel.openHome()`), `ProfileView`, `OnboardingView`, `ForgotPasswordView`, `new_program_frame.dart`, `AppStatusView(blocking: true)`. `AppDetailBar`'ın Geri düğmesi varsayılan olarak `Navigator.maybePop` çağırır (`app_detail_bar.dart` doc'u). Engelli ekranda `onLeading` ile kendi yolunuzu verin.

## 12. Haptikler

Yalnızca `AppHaptics.selection / medium / success / error` ve yalnızca sonuçlarda (`lib/core/services/app_haptics.dart`):

- `selection`: seçim değişti (segment, sekme, çip, anahtar vb.), çekip yenilemede bırakma.
- `medium`: deklanşör.
- `success` ve `error`: sonuç hazır, istek alındı, gönderim veya okuma hatası, doğrulama hatası, hata toast'u.

Çağrılar ateşle-unut'tur (`await` yok). Eksik kanal veya kapalı haptik hata fırlatmaz. Kaydırma, basma, akordiyon, sheet ve iskelet haptik çalmaz. Reduce motion haptiği susturmaz (`docs/spec/SMAP_Flutter_Spec.md` §1.13).

Çağrı yerleri: ViewModel'ler (`HomeViewModel.refresh` → `selection`, `CardDeckViewModel._commitLearn` → `success`), `ToastService` (`error`/`success` kendiliğinden). Aynı sonuca hem `ToastService` hem eylem haptik çalarsa `haptic: false` verin. Doğrudan `HapticFeedback` çağırmayın.

## 13. Erişilebilirlik kalıpları

`AGENTS.md` "Accessibility" maddelerinin koddaki karşılıkları:

- **İkon düğmesi:** `AppIconButton` `semanticLabel`'i zorunlu parametre alır. Aynı metin tooltip ve erişilebilir ad olur (`app_icon_button.dart`). Örnek: `semanticLabel: l10n.coachMeetings_newA11y`.
- **Başlık:** `Semantics(header: true, child: Text(...))`. Örnekler: `_DetailHeader`, `AppConfirmSheet`, `AppErrorState`, `AppEmptyState`.
- **Tek okunuş (kart/satır):** satırın içeriği birleştirilip tek etiket yapılır, çocuklar dışlanır. `_MeetingRow` (`widgets/meetings_list.dart`): `Semantics(container: true, button: true, label: spoken, excludeSemantics: true, onTap: onTap, child: AppRow(...))`. `spoken` ad, tarih, saat ve tür etiketinin `.join(', ')`'idir; avatar `decorative: true`'dur.
- **`MergeSemantics`:** `TopicRow`, `AuthorRow`, `SubjectRow`, `WorkRow`, `TopicResultRow`. İçeride etiketli `Semantics` + `ExcludeSemantics(AppRowShell(...))`.
- **`liveRegion: true`:** durum değişen alanlar (`AppErrorState`, `AppEmptyState`, "sonuç yok" kartı, yükleme ve hata durumları). Kart destesinde `InfoCardFace` kartı yalnızca yeni kart geldiğinde `liveRegion: announce` ile duyurur. Okuma sırasını `sortKey: OrdinalSortKey(0)` verir: önce kart, sonra yıldız (`OrdinalSortKey(1)`).
- **Çip grubu:** `Semantics(container: true, label: l10n.coachMeetings_withLabel, child: AppChipGroup(...))` ile gruba ad verilir.
- **Yalnızca ekran okuyucu metni:** l10n anahtarı `…A11y` ile biter. Örnekler: `coachMeetings_newA11y`, `coachMeetings_noteFieldA11y`, `coachMeetings_a11yKindStudent`.
- **Hedef:** 48 dp. `AppSegmented` seçenek dokunma alanı 48'dir (`07c93b8`). Düğmeler `AppButton` ile kullanılır; mihr_ui düğmelerinde `tapTargetSize: MaterialTapTargetSize.padded` örnek başına verilmelidir ve `AppButtonStyles.of` bunu zaten yapar.
- **Metin ölçeği:** `AGENTS.md` 1,3 diyor. Fiilî düzeltmeler ve galeri 1,35 ile yapıldı (`465e035`; galeride "Metin 1,35" anahtarı, `GallerySettings.largeTextScale`). Ölçüyü `MediaQuery.textScalerOf(context).scale(...)` ile alıp boyutları ona bağlayın. Örnekler: `TopicRow` 1,25+ ölçekte etiketi alta indirir, `WeekGridMetrics` tavan 1,5, `RootBandMetrics`.
- **Reduce motion:** `context.motion(duration, reduced: AppMotion.reducedFade)`. `reduced` zorunludur (neden: [04_tasarim_sistemi.md](04_tasarim_sistemi.md) §hareket).

## 14. Temsilî ekran: Anasayfa (öğrenci)

`HomeView` (`reactive => false`, `builder` yalnızca `const _HomePage()`):

- ViewModel `schedule`, `lessons`, `exams`, `currentUser`, `router`, `yksDate` alır; hepsi `locator`'dan view tarafından enjekte edilir. `clock` ve `timeout` isteğe bağlıdır ve test içindir.
- Üç bağımsız bölüm: `_TodaySection`, `_LastExamSection`, `_SubjectsSection`. Her biri kendi seçicisi, iskeleti, hata ve boş durumuyla çalışır.
- Bant (`_HomeBand`) veriyi cihazdan alır (ad, avatar, sayaç), istek beklemez. Seçici `(String, String?, int?, DateTime)` record'udur (`_BandData`: ad, fotoğraf, kalan gün, sınav tarihi). Sayaç gece yarısı `Timer` ile yenilenir (`watchMidnight`).
- Çekip yenilemede `onRefresh: getParentViewModel<HomeViewModel>(context, listen: false).refresh`. `refresh` önce `AppHaptics.selection()` çalar, sonra üç yüklemeyi `Future.wait` ile yeniler.
- Doğrudan `AsyncSection` seçen bölüm (`_LastExamSection`) ile `(AsyncSection, DateTime)` record'u seçen bölüm (`_TodaySection`) birlikte durur. Veri biçimi bölümün ihtiyacına göre seçilir.
- Test: `test/features/home/presentation/home_viewmodel_test.dart` gerçek servisler ve sahte HTTP adaptörüyle çalışır; 15 sn kuralını `timeout: Duration(milliseconds: 40)` ile doğrular.

## 15. Temsilî ekran: Görüşmelerim ve Detay

**Liste.** Sunucu sayfalar (8'erli). `loadMore`, `_more` Future'ıyla aynı anda tek sayfa çeker. `_token` yarış koruması içindir: her `_reload` `++_token` yapar ve gelen cevap `token != _token` ise atılır. Arama yüklenen sayfalarda çalışır (sunucuda arama parametresi yok, `docs/spec/SMAP_Flutter_Spec.md` §6.3 #31) ve `_loadForSearch` kalan sayfaları sınırlı (`maxSearchPages`, varsayılan 30) yürüyerek sonucu tamamlar. "Kiminle" seçimi sunucu filtresidir (`filter.types`) ve ilk sayfadan yeniden yükler.

Görünüm sayfa sonuna yaklaşınca sonraki sayfayı ister: `NotificationListener<ScrollMetricsNotification>` + `ScrollUpdateNotification`, `metrics.extentAfter < 400` (`_loadAhead`). Satırlar tamamen ekrana sığmıyorsa da tetiklenir.

**Yeni görüşme.** `NewMeetingFlow` (`lib/features/coach/application/new_meeting_flow.dart`) tüm akışı (öğrencileri oku, sheet'i aç, kaydet, toast bas) context'siz yürütür. Görüşmelerim, öğrenci profili ve koç anasayfası aynı akışı kullanır. `run` asla fırlatmaz ve yalnızca kaydedildiğinde `true` döner. Kaydedilirse ViewModel listeyi sessiz yeniler: `unawaited(_reload(skeleton: false))`.

**Detay.** Başlık, listeden gelen `MeetingEntry` ile hemen çizilir. Notlar her zaman sunucudan yeniden okunur (konumla adreslendikleri için). Derin bağlantıda `meeting` yoksa iskelet gösterilir ve `InterviewLocator` görüşmeyi listede arar. Ekran durumu (`screenState`) ve not durumu (`_notesState`) ayrıdır: not hatası ekranın geri kalanını bozmaz (`_NotesError`).

Testler: `meetings_viewmodel_test.dart`, `meeting_detail_viewmodel_test.dart`, ortak sahteler `meetings_fakes.dart` (`FakeInterviewRepository`, `FakeMeetingsDialogs`, `FakeMeetingsNavigator`, `ToastProbe`, `ManualTimers`). `ToastProbe` gerçek `ToastService`'i sahte sunucuyla sarar ve toast metnini, `hasUndo`'yu, `pressUndo()`'yu verir.

## 16. Yeni ekran tarifi

Örnek: koç tarafında "Duyurular" listesi, `lib/features/coach/` altında. Ekran adı `announcements`. Adımları sırayla izleyin; her birinin karşılığı yukarıdaki bölümlerde ve gerçek bir örnek dosyada vardır (Görüşmelerim).

### 16.1 Başlamadan

- Pano, kare ve spec numarasını belirleyin: `docs/design/panolar/SMAP-NN/<pano>/text.txt` (metinler, kurallar) ve `board.html` (kesin ölçü), görüntü `docs/design/panolar/png/`, akışlar `docs/design/panolar/AKIS.md`, spec `docs/spec/`. Tur 12 panoları (`SMAP-14`) eski karelerin önüne geçer; yer: `docs/design/README.md`. Her widget doc'u panoyu ve kareyi anar ve Türkçe metni alıntılar (`AGENTS.md`).
- Paylaşılan dosyalara (`pubspec.yaml`, `lib/app/router/app_router.dart`, `lib/app/router/routes/shell_routes.dart`, `lib/dependency_injection/injection_container.dart`, `lib/features/debug/gallery_registry.dart`, üretilen `lib/l10n/app_tr.arb`) paralel çalışırken tek elden dokunulur; kuralın ayrıntısı `../WORKFLOW.md` §5'te. Tek kişi çalışıyorsa bunları kendiniz bağlarsınız; aşağıdaki "bağlama" adımları bu dosyalara gider.
- Önce veri ve ViewModel testleri, sonra view (`AGENTS.md` "Definition of done").

### 16.2 Klasör yapısı

```
lib/features/coach/
  application/        announcement_logic.dart, announcement_models.dart      # saf mantık
  data/               announcement_repository.dart, dtos/                     # Either<AppException, T>
  presentation/announcements/
    announcements_view.dart            # ≤ 250
    announcements_viewmodel.dart       # ≤ 500
    announcements_navigator.dart       # abstract interface class
    stack_announcements_navigator.dart
    announcements_dialogs.dart         # abstract interface class (sheet varsa)
    sheet_announcements_dialogs.dart
    widgets/  announcements_band.dart, announcements_list.dart, announcements_states.dart   # part'lar ≤ 300
    sheets/   new_announcement_sheet.dart
  coach_announcements_routes.dart      # List<AutoRoute> get ...
lib/l10n/arb/coach_announcements_tr.arb
lib/features/debug/pages/…_gallery.dart   # yeni jenerik bileşen varsa
test/features/coach/presentation/announcements/…
test/features/coach/application/…         # saf mantık testi
```

### 16.3 Dosya dosya ne yazılır

1. **`application/*`:** saf Dart, Flutter bağımlılığı yok (model, süzme, sıralama, kural). Sabitler feature'da kalır, `core/`'a konmaz.
2. **`data/*`:** repository `Either<AppException, T>` döner ([02_veri.md](02_veri.md)). DTO'lar dart_mappable. DI kaydı feature'ın `coach_module.dart`'ında `registerLazySingleton` ile yapılır.
3. **`announcements_navigator.dart`:** yalnızca ViewModel'in ihtiyaç duyduğu çıkışlar.
   ```dart
   abstract interface class AnnouncementsNavigator {
     Future<void> openAnnouncement(AnnouncementEntry entry);
   }
   ```
   Doc yorumu pano/kare numarasını ve "testte kaydedilebilsin" gerekçesini anar.
4. **`stack_announcements_navigator.dart`:** `const StackAnnouncementsNavigator(this._router)`, `StackRouter` alır. Sekme içi ekran `push`, başka sekme `navigate(XxxTabRoute(children: [...]))`.
5. **`announcements_dialogs.dart`:** sheet başına bir yöntem, sonuç tipli (`Future<bool>`, `Future<T?>`). Kaydeden sheet için `typedef XxxSubmit = Future<bool> Function(Draft)`.
6. **`sheet_announcements_dialogs.dart`:** `const SheetAnnouncementsDialogs({required this.l10n})`, `AppConfirmSheet` ve kendi sheet'lerini çağırır.
7. **`announcements_viewmodel.dart`:**
   - `extends BaseViewModel`; servis durumu paylaşıyorsa `ReactiveViewModel`.
   - Kurucuda yalnızca arayüz ve servis alın: `navigator`, `dialogs`, `toast`, `online` (`ValueListenable<bool>`), isteğe bağlı `Duration timeout = SmapDurations.skeletonTimeout` ve `DateTime Function()? clock`.
   - Bölüm başına değişmez veri sınıfı veya `AsyncSection<T>`. Önbellek `_data ??= _build()`, `_publish()`.
   - `init()` (tek sefer, `_started`), `retry()`, `refresh()`.
   - Yükleme `AsyncSection.load(...)` ile 15 sn altında, `_token` ve `_disposed` korumalı.
   - Toast: `_toast.error((l) => l.coachAnnouncements_…)`. Haptik yalnızca sonuçta.
   - `dispose()`'ta dinleyicileri ve `ValueNotifier`'ları kaldırın.
8. **`announcements_view.dart`:**
   - `@RoutePage() class AnnouncementsView extends StackedView<AnnouncementsViewModel>`; `import 'package:stacked/stacked.dart' hide StackedRouterExtensions;`.
   - `reactive => false`, `onViewModelReady → init()`, `viewModelBuilder` servisleri `locator`'dan verir.
   - `part 'widgets/…';` satırları, `_AnnouncementsPage` içinde tek `CustomScrollView` + bant + bölümler + `SizedBox(height: AppBottomBar.heightOf(context) + AppSpacing.s16)`.
   - Sayfa, `RefreshIndicator(edgeOffset: <bant minExtent>)` ile çekip yenilemeyi alır.
   - Rota parametresi varsa `@PathParam('id')` ve tipi `export … show X;` ile dışarı verin.
9. **`widgets/*.dart` (part):** `part of '../announcements_view.dart';`. Her biri bir `SelectorViewModelWidget<VM, T>`. Beş durum için `switch` yazın. İskelet gerçek düzeni yansıtsın, boş/hata `AppEmptyState`/`AppErrorState` ile çizilsin. Eylem `getParentViewModel<VM>(context, listen: false)`. Satır tek okunuşlu `Semantics` ile sarılsın.
10. **`sheets/*.dart`:** özel kurucu + `static Future<T> show({... BuildContext? context})`, içeride `AppSheet.show<T>`. Kaydetme `submit` ile, `AppSheetFrame(busy: _busy, ...)`.
11. **`coach_announcements_routes.dart`:** `List<AutoRoute> get coachAnnouncementsTabRoutes => [AutoRoute(page: AnnouncementsRoute.page, initial: true), ...]`. Doc yorumunda yol tablosu yazılır (`coach_meetings_routes.dart` modeli).
12. **l10n:** `lib/l10n/arb/coach_announcements_tr.arb`. Anahtar `<feature>_<camelCase>`, paylaşılan `common_*`, yalnızca ekran okuyucu için `…A11y`. Her anahtara `@key.description` yazın (pano ve kare). Sonra `dart run tool/merge_arb.dart` ve `flutter gen-l10n`.

### 16.4 Bağlama (paylaşılan dosyalar)

- **Rota:** `lib/app/router/routes/shell_routes.dart` içinde ilgili sekmenin `children`'ına `...coachAnnouncementsTabRoutes`. Yeni bir sekme ekliyorsanız `ShellTabSpec.tabs` (`lib/app/shell/coach_shell_view.dart`, tip `shell_tab_spec.dart`'ta) de güncellenir. Tam ekran akış ise `AppRouter.routes` (`app_router.dart`) listesine. Üretilen `XxxRoute` için `dart run build_runner build -d`.
- **DI:** `registerCoachData` (repository) ve gerekirse `registerCoachSession` (oturum kapsamlı servis); yeni bir feature modülü ise `registerXxx` fonksiyonunu `injection_container.dart` içindeki `kDataModules` / `kServiceModules` / `kSessionModules` listesine ekleyin. ViewModel kaydedilmez.
- **Galeri:** yeni jenerik bileşen `lib/shared/ui/…`'a ve galeri sayfası `lib/features/debug/pages/…_gallery.dart` içine aynı değişiklikte eklenir; `gallery_registry.dart` listesine tek satır eklenir. Galeri: `flutter run -t lib/main_gallery.dart`; tema, metin ölçeği, reduce motion ve anlamsal ağaç (`GALLERY_SEMANTICS=true`) denetlenir. Feature'a özgü widget'lar (`MeetingRow`) `coach_gallery.dart` gibi sayfalarda gösterilir. Görüşmelerim ekranının kendisi galeride yoktur, yalnızca bileşenleri vardır. Ayrıntı: [04_tasarim_sistemi.md](04_tasarim_sistemi.md).

### 16.5 Test

- `test/features/coach/presentation/announcements/` altında ViewModel testi ve ortak `…_fakes.dart`: sahte repository, `FakeAnnouncementsNavigator`, `FakeAnnouncementsDialogs`, `ToastProbe` ve elle zamanlayıcı. `meetings_fakes.dart` bire bir model alınabilir.
- Zorunlu senaryolar: ilk yükleme, boş, hata, çevrimdışı, 15 sn sınırı (`timeout` kısaltılarak), yeniden dene, başarısız yenileme ekranı korur, `dispose` sonrası bildirim yok, yarışan iki yükleme. Geri Al varsa: ekrandan hemen kalkar, 6 sn sonra gider, "Geri Al" gönderimi iptal eder, geç "Geri Al" etkisizdir, çıkışta `flush`.
- Navigator için router sahtesiyle yöntem testi; engelli ekran varsa `pop`/`maybePop` ayrımı (`router_scan_navigator_test.dart` modeli).
- Widget ve golden testi yazılmaz (`AGENTS.md`); arayüz galeride ve simülatörde doğrulanır. Tek istisna, iskelet ile gerçek blok yüksekliğinin eşitliği (`exam_score_card_height_test.dart`).
- Saf mantık testi `test/features/<f>/application/` altına gider. Meetings'te bu testlerin bir kısmı `test/features/coach/presentation/meetings/application/` altına konmuş, tutarsızdır; yeni testi `application/` altında yazın.

### 16.6 Kontrol listesi

- [ ] Klasör: `lib/features/<f>/presentation/<screen>/` altında `_view`, `_viewmodel`, `widgets/`, `sheets/`; saf mantık `application/`, veri `data/`.
- [ ] `StackedView` + `reactive => false`; `viewModelBuilder` servisleri `locator`'dan veriyor; ViewModel kaydedilmemiş; `hide StackedRouterExtensions` import'u var.
- [ ] ViewModel `BaseViewModel` (servis durumu paylaşılıyorsa `ReactiveViewModel`); `BuildContext`, `Navigator`, `showDialog` yok. Navigasyon arayüzle (`Stack*Navigator`), sheet `*Dialogs` ile, metin `ToastText` ile.
- [ ] `init()` tek sefer (`_started`); `retry()`, `refresh()`; her `await` sonrası `token`/`_disposed` kontrolü; `dispose()` temizliyor.
- [ ] Her bölüm bir `SelectorViewModelWidget`; seçici değeri record veya `==` tanımlı `@immutable`; ViewModel değeri `_data ??= _build()` ile önbelleğe alıyor, `_publish()` kullanıyor; eylem `listen: false`.
- [ ] Tek `CustomScrollView`; alt boşluk `AppBottomBar.heightOf`; `RefreshIndicator(edgeOffset:)`; `NestedScrollView`/`sliver_tools` yok.
- [ ] Her bölümde iskelet (gerçek düzeni yansıtan, 15 sn sınırlı), boş, hata ("Tekrar Dene"), çevrimdışı; sahte veri yok.
- [ ] Sheet'ler `AppSheet`, tipli sonuçlu; kaydetme `submit` + `busy`; hata toast'u ViewModel'den.
- [ ] Geri'yi tutan ekranda `close()` = `pop`, regresyon testi var.
- [ ] Geri Al varsa 6 sn bekletme kalıbı, önce toast sonra bekletme, `flush`/`dispose` testleri.
- [ ] Haptik yalnızca `AppHaptics.*` ve yalnızca sonuçta.
- [ ] a11y: ikon düğmesinde `semanticLabel`, başlıkta `header`, durumda `liveRegion`, satırda tek okunuş, 48 dp hedef, metin ölçeği 1,35'te kırpılma yok, reduce motion'da 150 ms fade.
- [ ] Renk/metin/boşluk/ikon yalnızca token ve `App*` üzerinden; yasak desenler yok.
- [ ] Dosya boyları: view ≤ 250, part ≤ 300, ViewModel ≤ 500, diğer ≤ 400 (`tool/ui_rules.sh` denetler).
- [ ] Her widget doc'unda pano/kare ve Türkçe metin alıntısı; l10n anahtarları `<feature>_<camelCase>`, her anahtarda `@key.description`; ARB birleştirildi ve `gen-l10n` çalıştırıldı.
- [ ] Rota (`…_routes.dart` + `shell_routes.dart`/`AppRouter.routes`), DI (`*_module.dart` + `injection_container.dart` listeleri), galeri (`gallery_registry.dart`) bağlandı; `build_runner` çalıştırıldı.
- [ ] Testler: ViewModel, navigator, saf mantık; `test/features/<f>/…` altında.
- [ ] Komutlar temiz: `dart format .`, `dart run tool/merge_arb.dart && flutter gen-l10n`, `dart run build_runner build -d`, `flutter analyze --no-pub` (yeni dosyalarda sıfır), `tool/ui_rules.sh`, `flutter test --no-pub`. CI aynı sırayı koşar ve eskimiş l10n/üretilmiş kodu reddeder (`.github/workflows/ci.yml`).

## 17. Tuzaklar

1. **`maybePop` ile kapatma döngüsü.** `PopScope(canPop: false)` olan ekranın `close()`'u `pop` olmalı (bkz. bölüm 11). Sonsuz döngü uygulamayı dondurdu (`5171288`). Engelli ekran için navigator'a `close()` yazarken `router.pop()` yazın ve sahte router testi ekleyin.
2. **Seçici değerine `==` yazmamak.** Eşitliği olmayan özel sınıf her bildirimde "değişti" sayılır ve bölüm yeniden çizilir. Record, `AsyncSection`, `@immutable` + `==`/`hashCode` kullanın. Liste içeriyorsa `listEquals`/`Object.hashAll`. ViewModel değeri `_data ??= _build()` ile önbelleğe alır, `_publish()` boşaltır.
3. **`getParentViewModel(context)` varsayılanıyla dinlemek.** Eylem için `listen: false` verin. Veriye `selector` üzerinden erişin, bölümün içinden `viewModel.x` okumayın.
4. **ViewModel içinde `BuildContext` veya `locator` kullanmak.** Servisi `viewModelBuilder` verir. Metin lambda ile (`(l) => l.key`) gider. Sheet `*Dialogs`, rota `*Navigator` arayüzünden çıkar. Aksi halde test yazılamaz. (`MeetingDetailViewModel`'deki `locator` parametresi `InterviewLocator`'dır, get_it değil.)
5. **`reactive => false` unutulması.** Kök view her bildirimde yeniden çizilir ve seçici izolasyonu boşa gider.
6. **Yarış ve ömür koruması.** Her `await` sonrası `token != _token || _disposed` kontrolü yapın. `dispose` sonrası `notifyListeners` çağırmayın (`_publish` bunu korur). `init()` `_started` ile tek sefer çalışır. Dinleyiciyi `dispose`'ta, yalnız `_started` ise kaldırın.
7. **Silmeyi sunucuya hemen göndermek.** Geri alma ucu yoktur. Bekletme kalıbını (`NoteDeleteHold`/`PendingLearns`) kullanın, ekrandan çıkarken `flush`, toast 6 sn ile hold süresini eşit tutun, önce toast sonra bekletme. Konumla adreslenen listede aynı anda tek silme bekletin ve başka yazmadan önce `_settle()` ile sunucu listesini yeniden okuyun.
8. **Denetlenmeyenler.** `tool/ui_rules.sh` renk/ikon/metin stili/diyalog/rota/`print`/`fontSize`/`Widget _build`/ham `Duration(`/dosya boyu denetler. Denetlemez: `Text('literal')`, `reactive`, `toUpperCase`, `SharedPreferences.getInstance` (tercihler `DevicePreferences`'tan geçer; ham kullanım yalnız eski veri göçlerinde kalır), mihr getter'ları. Yalnız satır başındaki `//` yorumu muaftır; `kod(); // Colors.red` gibi satır sonu yorum takılır. `Duration.zero` yakalanmaz ama `reduced:` yerinde kasıtlı kullanılmalıdır.
9. **Koyu tema ve Material atası.** `AppStatusView` kendi `Material`'ını verir. Açılış, bakım ve zorunlu güncelleme ekranlarında dış `Material` sarmalayıcıları kaldırıldı (`ebe65a2`). Dışarıdan ata Material olmadan `Text` sarı çift alt çizgiyle çizilir (`07c93b8`, `33e7e1b`). Yeni tam ekran görünümde `Scaffold` veya `Material` eksik olmasın. Sheet üstü şerit de aynı yüzden `Material(type: transparency)` içine konur (`app_sheet_route.dart`).
10. **Alt boşluk.** Alt çubuğun altında kalmayı `AppBottomBar.heightOf(context)` ile çözün. El ile sabit değer kullanmak Hesap ekranlarında düğmelerin çubuğun altına düşmesine yol açtı (`33e7e1b`).
11. **Büyük metinle kesilen sabit ölçüler.** Sabit yükseklik veya genişlik metin ölçeğiyle büyümezse 1,35'te kırpılır (`465e035`, `700ecff`). Ölçüyü `textScaler.scale(...)` ile çarpın, gerekirse 1,25+ ölçekte düzeni dikeye çevirin (`TopicRow`, Form Kontrol alt düğmeleri).
12. **Boş `Semantics` adı.** Karta `semanticLabel` verilmezse çocuklar ayrı düğüm olur veya adsız "button" okunur (`07c93b8`: `AppCard.semanticLabel` tek düğüm). Satırı `Semantics(container, button, label, excludeSemantics)` ile tek okunuşa indirin, avatarı `decorative: true` yapın.
13. **Ham `Duration(...)` ve `Duration.zero` varsayılanı.** Süreyi `AppMotion`/`SmapDurations` ve `context.motion(..., reduced:)` ile alın. `reduced` parametresi bilerek zorunludur. Sunumda ham `Duration(` artık CI'ı düşürür.
14. **Bağlamsız sheet ve toast.** Sheet bağlamsız açılacaksa `AppSheet.navigatorKey` kurulu olmalıdır (router ilk kurulduğunda atanır, `lib/app/app_module.dart`); aksi halde sessizce `null` döner. Galeri uygulaması (`main_gallery.dart`) router ve DI kullanmaz; orada sheet'leri bağlamla açın (`BuildContext? context` parametresi).
15. **Önizleme ve oturum kapsamı.** Koç kabuğunun hesapsız önizlemesinde (`SHELL_PREVIEW`) oturum kapsamı yoktur. `locator.isRegistered<CoachStudentsService>()` kontrolü bu yüzden vardır (`MeetingsView.viewModelBuilder`). Oturum kapsamındaki servisleri `locator<>()` ile okurken önizleme yolunu düşünün (`c8978b3`).
16. **Türkçe büyük/küçük harf.** `toUpperCase()` kullanmayın, `TurkishText` kullanın. Sayı ve tarihi yalnızca `TrFormat` ile yazın (`TrFormat.sira`, `uzunTarihGun`, `saat`).
17. **l10n sırası.** ARB parçalarını (`lib/l10n/arb/<feature>_tr.arb`) düzenleyin, sonra `dart run tool/merge_arb.dart`, sonra `flutter gen-l10n`. `lib/l10n/app_tr.arb` üretilmiştir, elle düzenlenmez. Aynı anahtar iki parçada olursa birleştirme hata verir.
18. **Eski yorumlara güvenmek.** Eski legacy kod FIN2'de silindi (`29e8798`). Bir doc yorumu koduyla çelişirse koda ve `AGENTS.md`'ye güvenin; yorumu da düzeltin.

## 18. İlgili dosyalar

- Kurallar ve çalışma modeli: `AGENTS.md`, `../WORKFLOW.md`, `../DEVELOPING.md`.
- Örnek ekranlar: `lib/features/coach/presentation/meetings/` (liste, detay, sheet'ler), `lib/features/home/presentation/home/`, gömülebilir ekran `lib/features/schedule/presentation/program_detail/program_detail_view.dart`, sheet'in kendi ViewModel'i `lib/features/lessons/presentation/literature/sheets/`.
- Durum ve süre: `lib/shared/ui/feedback/section_state.dart`, `lib/core/theme/app_motion.dart`, `lib/core/services/toast_service.dart`, `lib/core/services/app_haptics.dart`.
- Sheet çekirdeği: `lib/shared/ui/sheets/app_sheet.dart`, `app_sheet_frame.dart`, `app_sheet_frame_parts.dart`, `app_sheet_route.dart`, `app_confirm_sheet.dart`, `sheet_outcome.dart`.
- Bekletme: `lib/features/coach/application/note_delete_hold.dart`, `lib/features/cards/application/pending_learns.dart`.
- Geri tuşu: `lib/features/scan/presentation/scan_flow/scan_navigator.dart`, `test/features/scan/presentation/router_scan_navigator_test.dart`.
- Rota ve DI: `lib/app/router/app_router.dart`, `lib/app/router/routes/shell_routes.dart`, `lib/dependency_injection/injection_container.dart`, `lib/app/app_module.dart`.
- Denetimler: `tool/ui_rules.sh`, `.github/workflows/ci.yml`, `tool/merge_arb.dart`.
- Test örnekleri: `test/features/coach/presentation/meetings/`, `test/features/home/presentation/home_viewmodel_test.dart`.
- Tasarım kaynağı: `docs/design/README.md`, `docs/spec/`, `../SMAP_UI_Uygulama_Rehberi.md`.
