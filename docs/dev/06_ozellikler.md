# 06 · Özellik haritası, Tur 12 durumu ve açık işler

Bu bölüm `lib/features/` altındaki her klasörün ne yaptığını tek yerde toplar: öğrenciye ya da koça ne sunduğu, hangi ekranları ve rota yollarını verdiği, hangi panoyu izlediği, hangi repository ve uçlarla konuştuğu, hangi bayraktan etkilendiği. Ardından Tur 12 özelliklerinin bugünkü hâli, bayrak tablosu, eski koddan geçişin kısa hikâyesi ve sahibine kalan açık işler gelir. Bir özelliğe dokunmadan önce o özelliğin satırını ve alt bölümünü okuyun; "bu neden böyle" sorusunun cevabı çoğu zaman bir backend eksiği ya da bir Tur 12 kararıdır.

Yollar repo köküne göredir; satır numarası verilmez, adı `grep` ile bulun. Kod ile doc yorumu çelişirse kod doğrudur. "Spec §6.3 #N" atfı `docs/spec/SMAP_Flutter_Spec.md` içindeki backend bağımlılıkları tablosunun N. maddesidir; "Y1", "G1", "K3", "D2" gibi kodlar [../Backend_Sorulari_Ek.md](../Backend_Sorulari_Ek.md)'deki sorulardır; "T12.n" Tur 12 varsayımlarıdır (`docs/design/panolar/SMAP-11/20-11-16-ek-Varsayımlar-Tur-12-Eki/text.txt`). "Pano X.Y kare N" atfının görüntüsü ve metni [../design/README.md](../design/README.md)'de anlatılan yerdedir. İskelet ve rota zinciri [01_mimari.md](01_mimari.md), veri katmanı [02_veri.md](02_veri.md), ekran kalıbı [03_ekran.md](03_ekran.md), tasarım sistemi [04_tasarim_sistemi.md](04_tasarim_sistemi.md), araçlar ve yayın listesi [05_araclar.md](05_araclar.md), genel giriş [../DEVELOPING.md](../DEVELOPING.md).

---

## 1. Genel görünüm

- **İki rol, iki kabuk.** Öğrenci kabuğu `/` (sekmeler `/home`, `/analytics`, `/lessons`, `/account`), koç kabuğu `/coach` (sekmeler `/coach/home`, `/coach/students`, `/coach/meetings`, `/coach/account`). İkisinde de ortada "Okut" düğmesi vardır. Kabuklar `lib/app/router/routes/shell_routes.dart`'ta tanımlıdır, widget'ları `lib/app/shell/` altındadır ([01_mimari.md](01_mimari.md) §6).
- **Klasör kalıbı.** Her özellik `data/` (repository, DTO, istek), `domain/` (model), `application/` (saf mantık ve önbellekli servis), `presentation/<ekran>/` (View, ViewModel, `widgets/` part dosyaları, `sheets/`) ile kökte `<f>_routes.dart` ve `<f>_module.dart` taşır. Her klasörde hepsi yoktur: örneğin `home` ve `onboarding`'in modülü, `shell` ve `debug`'ın rotası yoktur.
- **Paylaşılan ekranlar.** `ExamDetailRoute`, `QuestionDetailRoute`, `ProgramListRoute`, `ProgramDetailRoute` hem öğrenci hem koç yığınında kayıtlıdır; koç bağlamı yoldan değil `student:` (`StudentRef`) argümanından gelir. `AnalyticsViewModel` koçun Öğrenci Profili'nde, `ProgramListViewModel`/`ProgramDetailViewModel` koçun Program sekmesinde yeniden kullanılır.
- **Tam ekran akışlar** (`/scan`, `/scan/result/:examId`, `/program/new`, `/account/delete/progress`, `/account/delete/done`) kök yığındadır, kabuklardan önce listelenir ve alt çubuğu örter.
- **Sahte veri yok.** Sunucunun vermediği alan çizilmez; uç gelmeyen özellik bayrakla kapalıdır ya da gerçek hata durumunu gösterir.

## 2. Özellik tablosu

| Klasör | Ne yapar | Ekranlar (View) ve yollar | Pano | Veri (repository / uç) | Bayrak |
|---|---|---|---|---|---|
| `startup` | Açılışta oturumu geri yükler ve ilk ekranı seçer; durdurucu ekranlar; oturum düşünce "Oturumun sona erdi" sheet'i | `StartupView` `/`; `ForceUpdateView` `/blocking/force-update`; `MaintenanceView` `/blocking/maintenance`; `UnknownRoleView` `/blocking/unknown-role`; `SessionExpiredSheet` (sheet) | 2.1 kare 1; 2.7 kare 1–4; akış 13.12 | Uç yok. `SessionManager`, `StartupGate` (kayıtlı olan `DisabledStartupGate`), `StoreLauncher` | Yok (public config ucu yok, spec §6.3 #5) |
| `onboarding` | Giriş öncesi tanıtım (3 sayfa), sınıf ve alan, kamera ön açıklaması; hoş geldin kapısı | `OnboardingView` `/onboarding/intro` (adımlar tek rotada); `WelcomeView` `/welcome` | 2.1 kare 2–4; 2.2 kare 1–5; akış 13.1 | Uç yok. Seçimler cihazda (`OnboardingDraftStore`), kamera izni (`CameraPermission`) | `coachSignUpEnabled` (rol adımı) |
| `auth` | Giriş, kayıt, (kapalı) şifremi unuttum; oturum verisi ve göçü | `LoginView` `/auth/login`; `RegisterView` `/auth/register`; `ForgotPasswordView` `/auth/forgot-password` (bayrak kapalı, listede yok) | 2.3; 2.4; 2.5; 2.6; akış 13.2 | `AuthRepository`: `/student/login`, `/ajax/checkUser`, `/ajax/logout`, `/student/register`; kayıtta `/ajax/checkUsername` (`CoachStudentRepository`) ve `/ajax/getLegalDocuments` (`AccountRepository`) | `forgotPasswordEnabled`, `socialLoginEnabled`, `coachSignUpEnabled` |
| `home` | Öğrenci Anasayfa: bant (ad, avatar, YKS sayacı), "Bugün", "Son denemen", "Derslerin" | `HomeView` `/home` | 3.1–3.3; akış 13.3 | Kendi repository'si yok: `ScheduleService`, `ExamRepository` (`getMyMockExams`), `LessonsService` | Yok |
| `schedule` | Haftalık program: liste, gün/hafta görünümü, düzenleme, yeni program; koçta öğrencinin programı | `ProgramListView` `/home/program`; `ProgramDetailView` `/home/program/:programId?view=&date=`; `NewProgramView` `/program/new` (kök). Koçta `/coach/students/program`, `/coach/students/program/:programId` | 3.4–3.8; koçta 14.1–14.3 (10.4 kare 3'ün yerine) | `ScheduleRepository` + `ScheduleService`: `/student/getMyWeeklies`, `/student/getAllMainSubjects`, `/student/addNewProgram`, `/student/updateProgram` (koçta `?studentId=`) | `programDeleteEnabled`, `coachProgramWriteEnabled` |
| `scan` | Optik form okutma: izin kapısı, çekim, köşeler, gönderim, form kontrol, deneme bulunamadı, hatalar | `ScanFlowView` `/scan` (kök; aşamalar `ScanCaptureView`, `ScanCornersView`, `ScanUploadView`, `ScanReviewView`, `ScanRequestView`, `ScanErrorView`) | 4.1–4.10; akış 13.4, 13.5 | `ScanRepository`, OMR host'unda `/opticimage`, `/answerArray`, `/examrequest` (oturumsuz, base64 JSON) | `omrEnabled`, `offlineQueueEnabled` |
| `exams` | Sonuç anı, Deneme Detay (Genel, Sorular, Konular, Kartlar), Soru Detay, bildirim izni sheet'i | `ResultMomentView` `/scan/result/:examId` (kök); `ExamDetailView` `/analytics/exam/:examId?tab=`; `QuestionDetailView` `/analytics/exam/:examId/question?lesson=&q=`; koçta `/coach/students/exam/:examId[/question]` | 5.1–5.10; 14.4 (puan kartı); akış 13.6 | `ExamRepository`: `/student/getMyMockExams`, `/student/getMexamSubjectDetail`, `/student/getMexamItemDetail`, `/student/getQuestion`, `/student/getTotalInfoCard` | `notificationsEnabled` (izin sheet'i) |
| `analytics` | Analizlerim: Genel (net grafiği, toplamlar) ve Denemelerim (sayfalı liste, favori); koç profilinde Analiz/Denemeler | `AnalyticsView` `/analytics?tab=genel\|denemelerim`; `StudentAnalyticsView` (koç profilinde gömülü, rota değil) | 6.1–6.4; koçta 10.4 kare 1–2; akış 13.7 | `AnalyticsRepository`: `/student/getTotal`, `/student/getLineChartData`; liste için `ExamRepository.getMyExams` | Yok |
| `lessons` | Derslerim, Ders Detayı, Konu Detayı, Edebiyat dönem → yazar → eser | `LessonsView` `/lessons`; `LessonDetailView` `/lessons/:lessonId?cat=&eksik=&section=topics\|authors`; `TopicDetailView` `/lessons/:lessonId/topics/:topicId?cat=&focus=`; `LiteratureEraView` `/lessons/:lessonId/literature/:eraId`; sheet'ler `AuthorSheet`, `CardSheet`, `WebOnlySheet` | 7.1–7.6; 14.5–14.7; akış 13.8 | `LessonsService`, `LiteratureService`, `LessonContentRepository`: `/ajax/getGeneralLessons`, `/student/getLessonsTotalMissing`, `/student/mainSubjects`, `/student/yazarEserMainSubjects`, `/student/getSubSubjects`, `/student/getItems`, `/student/getSubjectAuthors`, `/student/learnedItem`; deste sayaçları `CardRepository` | Yok |
| `cards` | Bilgi kartı destesi: ders destesi ya da bir denemenin kazandırdığı kartlar; Öğrendim ve favori | `CardDeckView` `/lessons/deck?lessonId=&examId=&group=eksik\|bildik\|favori` | 8.1–8.2; akış 13.9 | `CardRepository`: `/student/getInfoCardsInfo`, `/student/getLessonInfoCards`, `/student/learnedCard`, `/student/addFavoriteMobil`; denemeden `getTotalInfoCard` | Yok |
| `account` | Hesap (iki rol), Profil, Sözleşmeler, Şifre (kapalı), Koçluk (öğrenci), Bildirimler, Hesabı Sil (öğrenci); koçun kod sheet'i | `AccountView` `/account`, `/coach/account`; `ProfileView` `…/profile`; `ContractsView` `…/agreements`; `ContractReaderView` `…/agreements/read`; `PasswordView` `/account/password` (listede yok); `CoachingView` `/account/coaching`; `NotificationsView` `…/notifications`; `AccountDeletionView` `/account/delete`; `AccountDeletionProgressView` `/account/delete/progress` ve `AccountDeletionDoneView` `/account/delete/done` (kök); sheet'ler `ChangeCoachSheet`, `CoachingCodeInfoSheet`, `CoachCodeSheet`, `AvatarSheet` | 9.1–9.7; 14.9–14.11; 14.12 kare 2–4 (koyu); akış 13.10 | `AccountRepository`: `/student/updateStudent`, `/ajax/getLegalDocuments`, `/ajax/deleteAccount`, `/student/getStudentsCoach`, `/student/addCoach`, `/student/deleteCoach`; `CurrentUserService` (`refCode`, profil yenileme) | `passwordChangeEnabled`, `notificationsEnabled` |
| `coach` | Koç Anasayfa, Öğrencilerim ve Öğrenci Ekle, Öğrenci Profili (Analiz, Denemeler, Program), Görüşmelerim ve notlar | `CoachHomeView` `/coach/home`; `StudentsView` `/coach/students`; `StudentProfileView` `/coach/students/:studentId?tab=analysis\|exams\|program`; `MeetingsView` `/coach/meetings`; `MeetingDetailView` `/coach/meetings/:meetingId`; sheet'ler `AddStudentSheet`, `CredentialsSheet`, `NewMeetingSheet`, `NoteSheet` | 10.1–10.6; 14.1–14.3 (Program), 14.8 (avatar); akış 13.11, 13.13, 13.14 | `CoachStudentRepository` + `CoachStudentsService`: `/coach/getMyStudents`, `/ajax/checkUsername`, `/coach/addNewStudent`; `InterviewRepository`: `/coach/getInterviews`, `/coach/addNewInterview`, `/coach/addNewNote`, `/coach/editNote`, `/coach/deleteNote` | `attentionListEnabled`, `coachProgramWriteEnabled` |
| `shell` | Kabuğun saf kararları: sekmeye dokunma, alt çubuk görünürlüğü, toast yüksekliği, "Okut" | Ekran yok (kabuk widget'ları `lib/app/shell/`) | 1.19; şerit 1.22 kare 6 | Yok | Yok |
| `debug` | Bileşen galerisi (ayrı giriş noktası), debug başlangıç değerleri | `ComponentGalleryView` ve 13 galeri sayfası (`lib/main_gallery.dart`, router'sız) | Kit panoları (1.x, 11.13) | Yok | Galeri `attentionListEnabled`'ı okur |

## 3. Özellik ayrıntıları

### 3.1 `startup`

- **Akış.** `StartupViewModel`, zaten çalışan `SessionManager.restore()`'u bekler, `StartupGate`'e sorar ve yığını hedefle değiştirir: durdurucu ekran, tanıtım, hoş geldin ya da rolün kabuğu. Native splash ilk kareyi en çok `StartupTiming.nativeSplashPatience` (1 sn) tutar; cevap gecikirse spinner çıkar. Açılış ekranının guard'ı yoktur, hedefi kendisi seçer ([01_mimari.md](01_mimari.md) §2, §5).
- **Durdurucu ekranlar kapalıdır.** `registerStartupServices` `DisabledStartupGate` kaydeder; her zaman `StartupBlock.none` döner. Zorunlu güncelleme ve bakım ekranları rota olarak vardır ama canlıda tetiklenmez. Public config ucu gelince yalnız bu kayıt değişir.
- **Bilinmeyen rol.** Rolü öğrenci ya da koç olmayan hesap (`UserRole.fromLegacy`, `teacher` koç sayılır) `UnknownRoleView`'a gider; sessizce öğrenci uygulaması açılmaz.
- **Oturum düşmesi.** `SessionExpiredCoordinator` 401'de sheet'i açar; tek düğmesi girişi mevcut ekranın üstüne açar, başarılı girişte kullanıcı olduğu yere döner.
- **Göç.** `LegacyOnboardingMigration` eski `onboarding_completed` bayrağını `DevicePreferences`'a taşır (yoksa güncellemeden sonra herkes tanıtımı yeniden görürdü).
- **Testler:** `test/features/startup/`.

### 3.2 `onboarding`

- **Tek rota, iç adımlar.** `/onboarding/intro` içinde `OnboardingStep.intro` (3 sayfa) → `role` → `grade` (sınıf ve alan) → `camera`. Spec'teki `/onboarding/role`, `/grade`, `/camera` ayrı rota değildir: tek geri yığını ve uygulama kapanınca kalınan adıma dönmek için (`onboarding_routes.dart`).
- **Koç kaydı kapalı.** `coachSignUpEnabled = false` iken rol adımı atlanır (tanıtımdan sınıf adımına geçilir) ve taslakta kalmış bir "koç" seçimi öğrenciye düşer (`OnboardingFlowState`, `OnboardingDraftStore.read`, `WelcomeViewModel`).
- **Kurallar.** 9. ve 10. sınıfta alan sorulmaz (`SchoolGrade.requiresTrack`); "Dil" alanı seçilemez, çünkü backend'de kodu yoktur (`StudyTrack.dil`, spec §6.3 #18). Seçimler yalnız cihazda tutulur ve `RegisterRoute(role:, grade:, track:)` ile kayda geçer. Taslak kişiye ait sayılır, oturum bitince silinir (`DevicePreferences.accountKeys`).
- **Hoş geldin** (`/welcome`, pano 2.2 kare 5) giriş öncesi kapıdır; çıkış ve hesap silme buraya döner.
- **Testler:** `test/features/onboarding/`.

### 3.3 `auth`

- **Giriş.** `SessionManager.signIn` → `/student/login` → `/ajax/checkUser` ile doğrulama; başarı gövdedeki `success` ile anlaşılır, 302 tek başına kanıt değildir ([02_veri.md](02_veri.md) §9.3). Giriş ekranındaki "Şifremi Unuttum" bağlantısı ve sosyal giriş düğmeleri bayrakla çizilmez.
- **Kayıt.** Canlı kullanıcı adı denetimi (`UsernameLiveCheck`, `/ajax/checkUsername`; doluysa öneri), sözleşmeler (`getLegalDocuments`, `LegalTextSheet`), sonra `register` ve aynı bilgilerle giriş. Gövde: `userType` (1 öğrenci, 2 koç), `data.name` = tam ad, `data.firstName` = son kelime dışındaki her şey, `data.surname` = son kelime (`NewRegistration.splitFullName`; sahibin eski koddaki değişikliğinden taşındı). `RegisterRequests.sendAcceptedVersions = true`: `accepted*Version` alanları üst düzeyde gider; sunucu reddederse `false` yapılır (spec §6.3 #13).
- **Koç kaydı kapalı.** `coachSignUpEnabled = false` iken kayıt ekranı rol bandını çizmez ve her zaman öğrenci gönderir. Koç yalnız "Giriş Yap" ile girer; rol hesaptan okunur.
- **Bilerek boş arayüzler.** `ForgotPasswordRepository` ve (account'taki) `PasswordRepository` arayüz olarak yazılıdır, uygulamaları ve kayıtları yoktur. Ekranları ve ViewModel'leri hazırdır.
- **Oturum verisi.** `SessionStore` (güvenli depo), `LegacySessionMigration` (eski düz metin `user_data` → güvenli depo), `UserDto` her alanı isteğe bağlı okur ([02_veri.md](02_veri.md) §8–9).
- **Testler:** `test/features/auth/` (`application/`, `data/`, `domain/`, `presentation/{login,register,forgot_password}`).

### 3.4 `home`

- **Üç bağımsız bölüm**, her biri kendi `SectionState`'iyle: "Bugün" (`ScheduleService`; backend'de "bugün" ucu yok, gün cihazda süzülür, spec §6.3 #19), "Son denemen" (`getMyMockExams`'ın ilk sayfası; aynı türdeki öncekine fark ve en zayıf konu istemcide, #20), "Derslerin" (`LessonsService`). Biri düşerse diğerleri çalışır.
- **Bant** (ad, avatar, YKS sayacı) cihazdadır, istek atmaz; sayaç ve "Bugün" gece yarısı yeniden hesaplanır. YKS tarihi `AppConfig.yksDate`'ten gelir (varsayılan örnek tarih; gerçek tarih sahibin kararı).
- **Gezinme** View'dadır (`home_view.dart` sonundaki `_openExam`, `_openLesson`, `_openTopic`, `_openProgram`, `_openProgramSetup`): Deneme Detay ve Ders/Konu kendi sekmelerinde `context.navigateTo(XTabRoute(children: [...]))` ile açılır; Programım Anasayfa yığınına itilir; Yeni Program kök yığına itilir.
- **Testler:** `test/features/home/`.

### 3.5 `schedule`

- **Anında kayıt.** Sunucuda kısmi güncelleme yoktur; her değişiklik taslağa hemen uygulanır ve programın tamamı `ScheduleService.updateWeekly` ile, sırayla gönderilir. Başarısız kayıt ekranı son kaydedilen hâle döndürür. Konu silme ve "Günü Sıfırla" 6 sn "Geri Al" sunar; bu yerel bir düzenlemedir, sunucu geri alması değildir.
- **Çevrimdışı.** Kayıtlı program okunur; "Düzenle", düzenleme eylemleri ve "Günü Sıfırla" bağlantı ister.
- **"Konu ekle" sheet'i** (`TopicPickerSheet`): "Çantam" (denemelerin bıraktığı eksik konular, dersi her adın altında yazan düz liste; Tur 12 A ile öğrencide de böyle) ve "Dersler" (bütün konular, ilk açılışta `getAllMainSubjects`, oturum boyunca saklı).
- **Koç bağlamı (Tur 12 A).** Her istek `studentId` taşır. `coachProgramWriteEnabled` açıkken koç "Düzenle", "Yeni Program", "Program Kur" görür ve "Bu programı … da görür ve düzenleyebilir." notu çizilir; kapalıyken Program sekmesi salt okunur 10.4 kare 3 davranışına döner. Koçun konuları açılmaz, başarısız kayıt "Program kaydedilemedi. …" toast'ıdır (pano 14.3). Yeni Program koçta `NewProgramRoute(student:)` ile açılır ve kayıttan sonra Program sekmesine dönülür (T12.6).
- **Yol.** Yeni Program `/program/new`'dir; `/home/program/new` olsaydı `/home/program/:programId` onu "new" kimlikli program sanardı.
- **Bilinen sınır.** `ScheduleService`'te yazma bitmeden başlayan yenileme, sonucu bir sonraki yenilemeye kadar eski veriyle ezebilir ([02_veri.md](02_veri.md) §11).
- **Backend açıkları:** program silme/iptal ucu yok (#25, `programDeleteEnabled`), program tarih tutmaz (#19, `program_span.dart`), koçun yazmasının öğrencinin hesabına işlenmesi doğrulanmadı (T12.8, Y4), öğrenci ve koç aynı anda düzenlerse son kayıt geçerli (T12.9).
- **Testler:** `test/features/schedule/`; koç sekmesi `test/features/coach/presentation/student_profile/`.

### 3.6 `scan`

- **Kapı.** "Okut" `ScanEntry.start(router)`'ı çağırır. `ScanLauncher` (saf karar `application/scan_launcher.dart`) sırasıyla bakar: okuma kapalıysa `OmrClosedSheet`; izin hiç sorulmadıysa ön açıklama (`CameraPrimerSheet`, pano 4.1); reddedildiyse ayar sheet'i (`CameraDeniedSheet`); aksi hâlde `/scan` kök yığına itilir. Sheet'ler kameradan önce, öğrencinin bulunduğu ekranın üstünde açılır.
- **Tek rota, aşamalar.** `ScanStage`: `capture` (4.3) → `corners` (4.4) → `upload` (4.5) → `review` (Form Kontrol, 4.7) → `request` (Deneme Bulunamadı, 4.9) ya da `error` (4.10). Fotoğraf başarıya kadar aşamadan aşamaya taşınır. Ekran dik kilitlidir. Okuma tanınınca `ResultMomentRoute` ile değiştirilir (`replace`).
- **Uçlar.** `ScanRepository` üç OMR çağrısını eski gövdeyle yapar: JSON içinde base64 fotoğraf ve `user` olarak oturumdaki kullanıcının JSON'u, oturum çerezi olmadan (`requiresSession: false`). OMR host'u `AppConfig.omrBaseUrl`; `OMR_BASE_URL` verilmezse API host'u kullanılır.
- **Bayraklar.** `omrEnabled = true` (bakım ucu yok, #4; bugün aynı metni 503 de gösterir). `offlineQueueEnabled = false`: bağlantısız yükleme 4.5 kare 4 hatasını gösterir ve fotoğraf o ekranda kalır; 4.10 kare 3 ekranı yazılıdır ama bayrağın arkasındadır.
- **Koç.** Koç kabuğundaki "Okut" da aynı akışı açar; öğrenci seçimi (pano 9.9, görev E19) backend `studentId` desteği (#34) gelene kadar yapılmadı, okuma koçun kendi hesabına gider (K4: düğme gizlensin mi, ürün kararı).
- **Belge tarayıcı** `lib/vendor/flutter_document_scanner` altında yerel pakettir; dokunulmaz, biçimlenmez, analizden hariçtir.
- **Backend açıkları:** Y1 OMR adresi (#1), Y2 `answersArray` biçimi, #2 multipart JPEG mi base64 mi, Y5 gövdedeki kullanıcı belgesi (KVKK).
- **Testler:** `test/features/scan/` (`application/`, `data/`, `domain/`, `presentation/`).

### 3.7 `exams`

- **Tek sonucu bulmak.** Backend'de "id ile tek deneme" ucu yoktur. Listeden açılan ekran sonucu argümanla devreder (`ExamDetailRoute(exam:)`) ve istek atmaz. Bağlantıyla açılınca `ExamFinder` Denemelerim'i en yeniden başlayarak sayfa sayfa okur: en çok 10 sayfa, yani en yeni 80 sonuç; bulamazsa `notFound`.
- **Deneme Detay.** Sekmeler Genel, Sorular, Konular, Kartlar (`?tab=genel|sorular|konular|kartlar`). Sorular kendi isteğini atmaz, sonucun içinden okunur. Konular (`getMexamSubjectDetail`) ve Kartlar (`getMexamItemDetail`) sekmeleri ilk açıldıklarında yüklenir ve kendi iskelet/boş/hata hâllerini taşır. Sonuç yüklendikten sonra başarısız yenileme onu ekrandan kaldırmaz.
- **Puan kartı (Tur 12 B).** `ExamScoreCard`: yerleştirme puanı ve sırası, altında ham puan ve ham sıra (T12.11). Değeri olmayan sütun, ham değer yoksa alt satır, hiç değer yoksa kart çizilmez. AYT için puan dizilerinin hangi yuvası okunacağı öğrencinin alanıyla seçilir (`ExamScores.slotFor`: TYT 0, AYT alanın `aimType`'ı 2/3/4); alan bilinmiyorsa tahmin edilmez.
- **Koç bağlamı.** Her istek öğrencinin kimliğini taşır; "Bu Konuyu Çalış" ve "Kartları Çalış" gizlidir (spec §6.5 #10).
- **Soru hücresi.** İşaretlenen ve doğru şık harfleri bugün hep boştur: `questionsArrStr` yalnız `{order, type}` taşır (#9). Hücre yalnız sonucu gösterir.
- **Sonuç Anı.** `ResultMomentLoader` yeni sonucu ve aynı türdeki bir öncekini listeden bulur (fark yalnız ona göre). Kart sayısı (`getTotalInfoCard`) yanında yüklenir, yalnız satır ekler. Success haptiği bir kez çalar. Ham puan burada bilerek yoktur (Tur 12 B: "5.1 sonuç anına ham puan eklenmez"). Çıkarken bildirim izni sheet'i (pano 5.2) bir kez önerilir, ama `notificationsEnabled` kapalı olduğu için bugün önerilmez.
- **Backend açıkları:** #9 şıklar, D1 denemeden eklenen kartların listesi, D2 ham puan ve ham sıranın AYT'de hangi puan türüne ait olduğu, "id ile tek deneme" ucu, Y3 koç `studentId`'si (#33).
- **Testler:** `test/features/exams/` (`application/`, `data/`, `presentation/`, `presentation/result_moment/`).

### 3.8 `analytics`

- **Genel** `getTotal` ve `getLineChartData`'yı birlikte, seçili `AnalyticsFilter` için okur; cevaplar filtre başına oturum boyunca saklanır. AYT alanı oturumdaki kullanıcıdan gelir, sabit değildir (eski ekran 2'yi zorluyordu).
- **Denemelerim** `getMyMockExams`'ı 8'erli sayfalar. Tür sunucuya gider, tarih aralığı istemcide kesilir (`ExamListQuery`). Sekme ilk açıldığında yüklenir ve sayfalarını korur. Sıralama parametresi yoktur (#27).
- **Favori yıldızı** yalnız cihazdadır (`ExamFavorites`, `DevicePreferences`; sunucunun `isStarred` alanı yok sayılır, #40). Kişiye ait sayılır, oturum bitince silinir.
- **Koç bağlamı.** `StudentAnalyticsView` aynı `AnalyticsViewModel`'i öğrenci kimliğiyle, bantsız ve sliver olarak Öğrenci Profili'ne gömer; favori yıldızı yoktur, satır Deneme Detay'ı koç görünümünde açar.
- **Testler:** `test/features/analytics/`.

### 3.9 `lessons`

- **Derslerim.** Dokuz genel ders `lesson_catalog.dart`'ta sabittir (backend ObjectId'leri). Liste ve eksik sayıları `LessonsService`'tedir (oturum kapsamı, 5 dk taze). Deste sayaçları (`getInfoCardsInfo`) yanda yüklenir; düşerse yalnız kart ilerlemesi çizilmez. TYT/AYT seçimi cihazda saklanır. Matematik ve Geometri "Web'de" dersidir (`isWebOnly`): satır `WebOnlySheet`'i açar, çevrimdışıyken listeden çıkar.
- **Ders Detayı.** Kategorisiyle açılır (`?cat=tyt|ayt|sos2|all`); "Eksiklerim" eksikli konuları süzer. Türk Dili ve Edebiyatı'nda ikinci segment "Yazar ve Eserler"dir (seçim cihazda): dönem listesi (`yazarEserMainSubjects`) burada gösterilir ve satır dönem detayını açar. Boş dönem listesi hata sayılır (T12.16).
- **Edebiyat (Tur 12 C).** `LiteratureEraView` (`/lessons/:lessonId/literature/:eraId`) dönemin alt başlıklarını akordeon olarak gösterir (`getSubSubjects` + `getItems`); açılan akordeon yazarlarını kendisi yükler (doğrudan yazar olan öğe ya da `getSubjectAuthors` ile açılan grup), hatası kendi içinde kalır. İlk eksikli akordeon açılır ve oraya kaydırılır. Yazar satırı `AuthorSheet`'i açar: türüne göre gruplu eserler, eser başına Eksik / Öğrendim / Biliyorsun. Bütün sayaçlar `LiteratureService`'ten okunduğu için "Öğrendim" hepsini aynı karede düşürür.
- **Öğrendim'in iki biçimi.** Edebiyatta (`LiteratureService`) ve kart destesinde istek 6 sn `PendingLearns`'te bekletilir, "Geri Al" önce gelirse hiç gitmez. Konu Detayı'ndaki kart sheet'inde ise `learnedItem` hemen gider, başarısızlıkta madde geri döner; geri alma yoktur.
- **Konu Detayı.** `focus=firstMissing` ile ilk eksikli alt konuyu ve maddesini açıp oraya kaydırır; yoksa ilk alt konu açılır. Madde metni "Örnek:" paragraflarından ayrıştırılır (`ItemTextParser`).
- **Backend açıkları:** #21 eksik sayılarında `studentId`, #24 geri alma ucu, #41 konu ikonları sabit host'tan (`kSubjectIconBaseUrl`), Edebiyat alt başlık öğelerinin gerçek veri yapısı canlıyla doğrulanmadı (§4).
- **Testler:** `test/features/lessons/` (`application/`, `data/`, `presentation/{lessons,lesson_detail,topic_detail,literature}`).

### 3.10 `cards`

- **Deste.** `CardDeckLoader` dersin destelerini ya da (`examId` ile) denemenin kazandırdığı kartları okur. Üç sayaç ve oturum toplamı gelen kartlardan hesaplanır; ders başına toplam kart sayısı cevapta yoktur, çizilmez (#22).
- **Kaydırma yalnız sonraki karta geçer**, kartı öğrenmez. "Öğrendim" yalnız düğmeyle (ya da kart sheet'inden) çalışır; ilk seferde onay sorar ("Bir daha sorma" cihazda, kişiye ait). İstek `PendingLearns` ile 6 sn bekletilir; ekrandan çıkarken bekleyenler gönderilir (`flush`), başarısız istek kartı Eksiklerim'e geri koyar.
- **Yıldız** `addFavoriteMobil` bir aç/kapa (toggle) ucudur; yıldız hemen döner, istek düşerse geri döner.
- **Kil görsel.** Ders destesinin ekran düzeyi boş hâlinde dersin kil görseli çizilir (`AppClay`, Tur 12 K).
- **Testler:** `test/features/cards/`.

### 3.11 `account`

- **Hesap** iki rol için aynı sayfadır (`AccountView`), cihazdaki hesaptan okunur. Öğrencide "Koçun: …" satırı `getStudentsCoach` cevap verince çizilir. Koçta "Koçluk" grubunda değer satırı "Koçluk kodun" vardır; satırın tamamı `CoachCodeSheet`'i açar (Tur 12 G). "Bize Yaz" `SUPPORT_EMAIL` yoksa çizilmez.
- **Görünürlük rotaya bağlıdır.** `StackAccountNavigator.canOpen` hedef rotanın router'da olup olmadığına bakar; listede olmayan rotanın satırı çizilmez. Koç Hesap yığınına yalnız `accountTabRoutes` ve `NotificationsRoute` eklidir; bu yüzden koçta Koçluk, Şifre ve Hesabı Sil yoktur (koç için Hesabı Sil, spec §6.5 #6, açık).
- **Profil (Tur 12 E, pano 14.9).** Düzenle → `ProfileDraft`. Yalnız değişen alanlar `updateStudent` ile gider, sonra `CurrentUserService.refresh`. E-posta doğrulama kodu yoktur (T12.19, #10): adres "Kaydet"le hemen değişir, alanın altında "Kaydedince hemen değişir; doğru yazdığından emin ol." yazar. Denetim alandan çıkınca ve "Kaydet"te çalışır ("@", alan adı, uzantı); hata varken "Kaydet" pasif, odak hatalı alana gider; adres kırpılıp küçük harfe çevrilir. Çevrimdışıyken başlığın altında "Kaydetmek için bağlantı gerekiyor; girdiklerin korunuyor." görünür ve bağlantı gelince "Kaydet" kendiliğinden açılır. Başarı toast'ı "Profilin güncellendi." haptiksizdir.
- **Koçluk (öğrenci; Tur 12 F, pano 14.10).** Koç yoksa `AAAA-0000` maskeli kod alanı ve tek `addCoach`; koç varsa kart, çerçeveli "Koçu Değiştir" ve tehlikeli "Bağlantıyı Kaldır" (onaylı `deleteCoach`). "Koçu Değiştir" `ChangeCoachSheet`'i açar (`AppSheetSize.full`): ikinci onay yoktur (T12.21), sekiz karakter dolmadan düğme pasif, denerken sheet meşgul ve kapanmaz; hata sheet'i kodla açık tutar ("bulunamadı", "zaten bu koç", diğerleri "tekrar dene"). Başarıda kart yeni koçu gösterir, toast "…'e bağlandın." success haptiğiyle çalar, odak karta gider ve kart `getStudentsCoach` ile arka planda yenilenir. Önce `deleteCoach` çağrılmaz (T12.24, açık soru). Çevrimdışıyken iki eylem de pasiftir.
- **Koçun kod sheet'i (Tur 12 G, pano 14.11).** `CoachCodeSheet` + `CoachCodeViewModel` (`presentation/account/sheets/`), gövdesi `CodeCardSheetBody` (`lib/features/coach/presentation/widgets/code_card_sheet.dart`). Kod hesabın `refCode`'udur ve oturum cevabıyla cihazdadır; sheet onu hemen, çevrimdışıyken de gösterir ("Kod cihazında saklı; …" notuyla). Yalnız cihazda yoksa `CurrentUserService.refresh()` 15 sn sınırıyla çağrılır; kod gelmezse hata ve "Tekrar Dene". "Kopyala" `CoachCodeActions.copy` ile `selectionClick` çalar ve "Kod kopyalandı." toast'ını gösterir; "Paylaş" sistem paylaşımını cümleyle açar. Kod yenileme yoktur (T12.26). Eski `CodeInfoAudience.coach` kaldırıldı; `CoachingCodeInfoSheet` yalnız öğrencinin "Koçun yok" hâlindedir.
- **Bildirimler** tercihleri cihazda tutar (`NotificationPreferencesStore`), sunucuya bir şey gitmez; bayrak kapalıyken bilgi kutusu "planlı" der. Koç yalnız sessiz saatleri görür.
- **Hesabı Sil** (öğrenci): açıklama `/account/delete` (Profil'den), tehlikeli onay, sonra tam ekran `/account/delete/progress` ve `/account/delete/done` (geri kapalı). Yerel temizlik (`SessionManager.completeAccountDeletion`, uzaktan logout yok) "Tamam"da yapılır. Başarısızlık açıklama ekranında satır içi hata kutusudur.
- **Şifre** ekranı yazılıdır ama `passwordChangeEnabled = false` olduğundan rota listede yoktur.
- **Backend açıkları:** #10 e-posta doğrulama, #11 `updateStudent` birleştirme, #13 sözleşme tarihleri, #15 / K3 koçluk kodu biçimi ve `refCode`'un resmî kaynak olup olmadığı, T12.24 `addCoach`'un eski bağı kendisi kaldırıp kaldırmadığı.
- **Testler:** `test/features/account/` (`application/`, `data/`, `domain/`, `presentation/` altında `account_viewmodel_test.dart`, `profile_viewmodel_test.dart`, `account/coach_code_viewmodel_test.dart`, `coaching/`, `deletion/`, `notifications/`, `password/`).

### 3.12 `coach`

- **Koç Anasayfa.** Bölümler bağımsızdır: öğrenciler (`CoachStudentsService`, Öğrencilerim'le ortak, alfabetik), önümüzdeki yedi günün görüşmeleri (`getInterviews`), "Dikkat gerektirenler" yalnız `attentionListEnabled` açıksa (kapalıyken iskelet ve boş kart dahil hiç çizilmez). Bant (ad, avatar, koçluk kodu) cihazdandır. Öğrencisi olmayan koç, kod kartıyla tam sayfa boş hâli görür. Kopyala/Paylaş `CoachCodeActions` üzerinden Hesap'taki sheet'le aynı davranır.
- **Öğrencilerim.** Liste `getMyStudents`; arama yalnız istemcidedir (K2). Listede son net ve son deneme tarihi yoktur, çizilmez (#29). Ad `name + surname` birleştirilerek yazılır (K1).
- **Öğrenci Ekle (Tur 12 D, pano 14.8).** `AddStudentSheet` (`full`). Kullanıcı adı küçük harfe çevrilir; son tuştan 400 ms sonra ya da "Kontrol Et" ile `checkUsername` sorulur, doluysa boş bir komşu önerilir. "Oluştur" 10 karakterlik okunur bir şifre üretir. Avatar `AppAvatarPicker`'ın radyo grubu biçimidir (`groupLabel`, `optionLabelOf`), sağda "4 / 7" sayacı; ilk avatar seçili gelir (T12.17) ve `photo` olarak gider; sunucu `photo` dönmezse listede gönderilen avatar gösterilir. Çevrimdışıyken kaydetme kapalıdır ve neden satırı görünür; başarısızlık hata toast'ı ve error haptiğidir, form korunur. Kaydedilen öğrencinin giriş bilgileri `CredentialsSheet`'te gösterilir (sunucu şifreyi geri vermez).
- **Öğrenci Profili.** Yoldaki `studentId` koçun listesinde bulunur (yoksa önce liste okunur; bulunmazsa "Öğrenci bulunamadı"). Sekmeler Analiz, Denemeler, Program (`?tab=analysis|exams|program`); sekme ilk açıldığında kurulur ve korunur. Program sekmesi Tur 12 A'dır (§3.5). Bar eylemi "Görüşme Planla" `NewMeetingFlow`'u öğrenci seçili açar (çevrimdışıyken de açılır, T12.7).
- **Görüşmeler.** `getInterviews` 8'erli sayfa; "Kiminle" seçimi sunucuya `filter.types` olarak gider; metin araması sunucuda yoktur, yüklü sayfalarda Türkçe katlamayla yapılır ve arama sürerken kalan sayfalar sırayla çekilir (#31). Yeni görüşmenin notu ikinci istektir (`addNewInterview` not almaz, G4). Tarih dilimsiz yerel saat olarak gider ve öyle okunur (`MeetingMoment.wallClock`, G1).
- **Notlar konumla adreslenir** (`editIndex`, `deleteIndex`): Görüşme Detayı notları her zaman sunucudan yeniden okur, her yazmadan sonra görüşmeyi tekrar okur. Not silme 6 sn `NoteDeleteHold`'da bekler; başka bir yazma ya da ekrandan çıkmak bekleyen silmeyi önce gönderir. Görüşmenin kendisini düzenleme/silme ucu yoktur, "Düzenle" çizilmez. Tek görüşmeyi getiren uç olmadığından bağlantıyla açılan detay `InterviewLocator` ile listeyi gezer (G3).
- **Testler:** `test/features/coach/` (`application/`, `data/`, `domain/`, `presentation/{coach_home,students,add_student,student_profile,meetings}`).

### 3.13 `shell`

- `ShellBarPolicy` (saf): seçili sekmeye yeniden dokunmak yığını köke indirir ve başa kaydırır; alt çubuk yalnız kök yığının tepesinde bir kabuk varken görünür; toast yüksekliği buna göre ayarlanır.
- `ShellViewModel`: `ToastService.bottomBarHeight`'ı alt çubukla eşler, "Okut"u kök router'da açar (kamera düğmesinin medium haptiği).
- Kabuk widget'ları (`StudentShellView`, `CoachShellView`, `ShellFrame`, çevrimdışı şeridi `widgets/shell_offline_strip.dart`, `ShellPreview`) `lib/app/shell/`'dedir. Dört sekme bir `IndexedStack` içinde birlikte kurulur ve kurulu kalır.
- **Testler:** `test/features/shell/`, `test/app/shell/shell_routes_test.dart`.

### 3.14 `debug`

- `lib/main_gallery.dart` ayrı giriş noktasıdır; router ve DI kullanmaz. `ComponentGalleryView` 13 sayfayı (`pages/*_gallery.dart`: düğmeler, seçimler, koç, kontroller, alan bileşenleri, geri bildirim, kimlik, göstergeler, girdiler, gezinme, seçiciler, sheet'ler, yüzeyler) `gallery_registry.dart` ile listeler. Galeri ayarları `gallery_settings.dart`'ta, debug başlangıç değerleri (`SIMCTL_CHILD_*` ortamı ya da geçici dosya) `launch_env.dart`'tadır. Yalnız debug araçlarıdır; release yolunda okunmaz ([04_tasarim_sistemi.md](04_tasarim_sistemi.md) §12, [05_araclar.md](05_araclar.md) §7).
- Testi yoktur; görsel doğrulama galeride ve simülatörde panoyla yan yana yapılır.

## 4. Tur 12 (A–G) durumu

Tur 12, eski uygulamada olup ilk turlarda tasarımı çizilmemiş yedi özelliği geri getirdi (`docs/SMAP_Tasarim_Brifi_Tur12.md`; panolar `SMAP-14` 14.1–14.12, akışlar 13.13–13.14, varsayımlar T12.1–T12.30). Yedisi de kodda ve `redesign/main`'dedir. Kalan sorular sunucunun davranışıyla ilgilidir; uygulama hiçbirinde tahmin edilmiş veri göstermez.

| Kalem | Pano | Bugün ne yapıyor | Kalan soru / bayrak |
|---|---|---|---|
| **A** Koç öğrencinin programını kurar ve düzenler | 14.1–14.3 | Öğrenci Profili › Program: bu haftanın (yoksa en yeni) programı gömülü `ProgramDetailView` olarak; "Düzenle"/"Bitti", "Programlar" satırı, `NewProgramRoute(student:)`; Çanta düz liste (öğrencide de); çevrimdışı satırı. Yazma `addNewProgram`/`updateProgram` + `?studentId=` | `coachProgramWriteEnabled = true`. T12.8 / Y4: sunucu koçun yazmasını öğrencinin hesabına işliyor mu? İşlemiyorsa bayrak `false` yapılır; sekme 10.4 kare 3'ün salt okunur hâline döner. T12.9 (eşzamanlı düzenleme), T12.10 (öğrenciye bildirim yok) |
| **B** Deneme Detay'da ham puan ve sırası | 14.4 | `ExamScoreCard`: yerleştirme puanı/sıra ve ham puan/ham sıra iki satır; olmayan değer çizilmez; iskelet 163 pt. Sonuç Anı'na eklenmedi | D2: AYT'de ham puan ve ham sıra hangi puan türüne ait? Uygulama AYT için öğrencinin alanının yuvasını okur |
| **C** Edebiyat dönem → yazar → eser | 14.5–14.7 | Dönem listesi Ders Detayı'nda, `LiteratureEraView`, akordeon içi yükleme ve hata, `AuthorSheet`'te eser başına durum, 6 sn "Geri Al"lı Öğrendim, sheet üstünde çevrimdışı şeridi | Alt başlık öğelerinin gerçek veri yapısı (yazar öğesi mi, `getSubjectAuthors` ile açılan grup mu; `works[]` alanları) canlı veriyle doğrulanmadı |
| **D** Öğrenci eklerken avatar | 14.8 | Radyo grubu avatar seçici, "4 / 7" sayacı, eklendi sheet'inde avatar, çevrimdışı neden satırı, hata toast'ı | `photo` dönmezse gönderilen avatar gösterilir; sunucunun alanı saklayıp saklamadığı canlıyla denenmedi |
| **E** Profil e-posta | 14.9 | Doğrulamasız değişim (T12.19), yardım satırı, alandan çıkınca ve "Kaydet"te biçim denetimi, çevrimdışı notu, haptiksiz başarı toast'ı | E-posta doğrulama ucu yok (#10); gelirse 2.4'ün kod kutuları kullanılacak |
| **F** Koçu tek adımda değiştirme | 14.10 | `ChangeCoachSheet` (`full`), maske `AAAA-0000`, tek `addCoach` sonra `getStudentsCoach`; ikinci onay yok (T12.21) | T12.24: `addCoach` eski bağı kendisi kaldırıyor mu? Kaldırmıyorsa istemci önce `deleteCoach` çağırmalı; ekran aynı kalır |
| **G** Koçun koçluk kodu | 14.11 | Hesap'ta değer satırı → `CoachCodeSheet` (yükleniyor, hata, çevrimdışı), Kopyala toast'ı, Paylaş metni | K3: `refCode` kodun resmî kaynağı mı, biçimi `AAAA-0000` mı? Kod yenileme yok (T12.26) |

Tur 12 ile birlikte gelen iki iş daha:

- **Kil görselleri (T12K, pano 1.25).** `AppClay` + `ClayPicture` (`lib/shared/ui/illustrations/app_clay.dart`), 11 dosya `assets/illustrations/clay/` altında; eski `ClayIllustration` kaldırıldı. Bugünkü kullanım yerleri: hoş geldin ekranı ve ekran düzeyi boş durumlar (Programım, Görüşmelerim, Analizlerim Genel, kart destesi). Dosyalar 140 px; 2x/3x asıllar tasarımcıdan bekleniyor.
- **Koç kaydı bayrağı (T12P).** `coachSignUpEnabled = false`: sahip canlı uygulamada kayıt formundan "Öğrenci / Koç" seçimini kaldırdı (origin/main `e615595`). Tanıtımdaki rol adımı ve kayıttaki rol bandı gizli; panodaki hâl bayrakla geri açılır. Karar sahibindir.

## 5. Özellik bayrakları

Bütün bayraklar `lib/core/config/feature_flags.dart`'ta derleme zamanı sabitidir. Kapalı özellik ya rota listesine girmez (`if (FeatureFlags.x) AutoRoute(...)`) ya da giriş noktası çizilmez. Bayrağı açmadan önce doc yorumundaki "Opening it also needs …" cümlesini okuyun; çoğunda bayrak tek başına yetmez. Bayrağı ViewModel'e kurucu argümanıyla veren yerlerde (`coachWriteEnabled`, `coachSignUpEnabled`) iki hâl de testlidir.

| Bayrak | Değer | Etkilediği yer | Açmak (ya da kapatmak) için gereken |
|---|---|---|---|
| `forgotPasswordEnabled` | false | Giriş'teki bağlantı, `/auth/forgot-password` | Kod gönder / doğrula / yeni şifre uçları (#7); `ForgotPasswordRepository` uygulaması ve `registerAuthData`'da kaydı |
| `socialLoginEnabled` | false | Giriş'teki Apple/Google düğmeleri (eylemsiz) | Resmî logo varlıkları, Apple ve Google paketleri (projede yok), sunucu ucu (#17), düğmelerin bağlanması |
| `programDeleteEnabled` | false | "Programı İptal Et" | Silme/iptal ucu (#25) ve `ProgramDetailViewModel.deleteProgram`'a çağrının verilmesi |
| `passwordChangeEnabled` | false | Hesap'taki Şifre satırı, `/account/password` | Şifre değiştirme ucu (#8); `PasswordRepository` uygulaması ve `registerAccountData`'da kaydı |
| `notificationsEnabled` | false | Bildirimler'deki "planlı" kutusu, Sonuç Anı'ndaki izin sheet'i (5.2) | Tercih ucu ve push altyapısı (#16, `PUT /devices`), tercihlerin sunucuya yazılması; platform bildirim izinleri ([05_araclar.md](05_araclar.md) §14) |
| `omrEnabled` | **true** | "Okut" kapısı; kapalıyken `OmrClosedSheet` | Sunucu bakım bayrağı verince sabit yerine sunucudan okunmalı (#4) |
| `offlineQueueEnabled` | false | Bağlantısız yüklemede 4.10 kare 3 ekranı | Fotoğraf kuyruğunun kendisi (yok); ekran hazır |
| `attentionListEnabled` | false | Koç Anasayfa "Dikkat gerektirenler" | D-27 kurallarını hesaplayan uç (#28, #29); `AttentionRepository` uygulaması ve kaydı |
| `coachProgramWriteEnabled` | **true** | Koçun Program sekmesi, koçta `NewProgramRoute` | Kapatmak: sunucu koçun `?studentId=` ile yazdığını öğrencinin hesabına işlemiyorsa (T12.8, Y4) |
| `coachSignUpEnabled` | false | Tanıtımdaki rol adımı, kayıttaki rol bandı | Ürün kararı (sahip); açmak tek satırdır, panodaki davranış geri gelir |

## 6. Göç hikâyesi

- **Yeniden yazım.** Uygulama Ekim 2026'da Claude Design'da hazırlanan tasarıma göre eski kod tabanından ekran ekran yeniden yazıldı (Tur 1–12, görev görev ilerleme `docs/DURUM.md`'de). Her görev kendi dalında çalıştı; ortak dosyaları (router, DI, ARB, `pubspec.yaml`) yalnız koordinatör bağladı ([../WORKFLOW.md](../WORKFLOW.md)). Bir süre eski ekranlar yeni kabuğun içinde geçici köprülerle yaşadı; her dalga kendi eski ekranlarını sildi.
- **Eski kod yok.** FIN2 (`29e8798`) son köprüleri (Provider katmanı, eski repository'ler, eski tema ve ağ istemcisi) ve kullanılmayan paketleri kaldırdı. Bugün eski ekran, eski ağ istemcisi ya da Provider tabanlı durum yoktur.
- **Kalan yalnız cihaz verisinin göçüdür:** `LegacySessionMigration` (eski düz metin kullanıcı kaydı → güvenli depo), `LegacyOnboardingMigration` (tanıtım bayrağı), eski istemciyle aynı çerez kavanozu yolu (`<documents>/.cookies/`; güncellemede oturum açık kalsın diye, değiştirilmez). Adında "Legacy" geçen `LegacyEnvelope` (sunucunun `{success, message, …}` zarfı) ve `UserRole.fromLegacy` ölü kod değildir; canlı sözleşmedir ([02_veri.md](02_veri.md) §6, §8.3).
- **Sahibin eski koddaki değişiklikleri.** Sahip bu sırada eski kod tabanında (origin/main) çalışmaya devam etti: 11–17 Ekim arasında 13 commit. Hepsi incelendi; ilgili olanlar taşındı: uygulama kimliği `com.studentmap.smap` (Android + iOS), Android release imzası `android/key.properties` ile (anahtar sahibinde, git'te yok), sürüm `1.0.0+3` (eski uygulama +1 ve +2 yükledi), kayıt gövdesinde `name` tam ad ve yeni `firstName` (§3.3), koç kaydının kaldırılması (`coachSignUpEnabled`, §4). Geri kalanı görsel denemeler ya da artık olmayan eski ekranlara aitti. Sahibin sildiği 36 eski logo denemesi bizim dalda hâlâ duruyor (§7.2).

## 7. Açık işler

### 7.1 Backend soruları

Tam liste: spec §6.3 (41 madde) ve [../Backend_Sorulari_Ek.md](../Backend_Sorulari_Ek.md). Yayını engelleyenler önce:

- **Y1** optik okuma sunucusunun gerçek adresi (#1), **Y2** `answersArray` biçimi, **Y3** koç oturumunun `studentId` ile öğrenci verisini okuyabilmesi (#33), **Y4** koçun öğrencisi adına program yazabilmesi (T12.8), **Y5** okuma isteklerindeki gereksiz kişisel veri.
- Görüşme saat dilimi ve sayfalama (G1–G5), koç ve öğrenci listesi (K1–K4), deneme kartları ve AYT ham puan türü (D1–D2).
- Tur 12'den: T12.24 (`addCoach` eski bağı kaldırıyor mu), Edebiyat alt başlık veri yapısı.
- Bayrak bekleyen uçlar §5'te: şifre sıfırlama ve değiştirme, sosyal giriş, program silme, bildirim tercihi ve push, okuma bakım bayrağı, dikkat listesi, public config (zorunlu güncelleme, bakım).

### 7.2 Sahibin kararları

- **Koç kaydı:** `coachSignUpEnabled` kapalı kalsın mı (§4)? Koç için Hesabı Sil (spec §6.5 #6) ve koçun "Okut" düğmesi (K4) de ürün kararıdır.
- **Kullanılmayan görseller:** 90 dosya (≈14 MB) silinmeyi bekliyor; liste `docs/history/gorevler/fin3_kullanilmayan_gorseller.txt`. Sahip bunların 36 eski logo denemesini kendi dalında zaten sildi. `assets/ikonlar.zip` ve `assets/menuIcons/students2.zip` de `- assets/` girdisiyle pakete giriyor.
- **Yayın:** release anahtarı ve yayın derlemesi (sahipte), mağazadaki son build numarası, iOS imzası, mağaza metin ve görselleri, `SUPPORT_EMAIL`, `APP_STORE_ID`, gerçek `YKS_DATE`. Ayrıntı ve işaretli liste: [05_araclar.md](05_araclar.md) §14.
- Programım hafta ızgarası blokları panoda 36 dp (48 dp erişilebilirlik kuralının altında); dokunma alanı görünmez biçimde genişletilsin mi?

### 7.3 Tasarımdan beklenenler

- Kil görsellerin 2x/3x asılları (şu an 140 px, ekranda bulanık; 480 px bekleniyor).
- Sosyal giriş için resmî Apple/Google varlıkları (bayrak açılmadan önce).

### 7.4 Bilinen sınırlar

- **Koçluk kartı kalıcı önbellekte değil.** Pano 14.10 kare 6 çevrimdışında kartı "önbellekten" çizer; uygulama `getStudentsCoach`'u her açılışta yeniden okur. Koçluk ekranı çevrimdışı açılırsa kart yerine çevrimdışı durumu görünür. Oturum boyunca saklayan bir servis ya da cihaz kaydı gerekir.
- **Koç ekranlarında çevrimdışı şeridinin yeri.** T12.7 ve pano 14.3 şeridi üst çubuğun altında, bağlam şeridinin üstünde ister. Şerit kabuğun işidir (`_ShellOfflineStrip`) ve sayfanın en üstünde, çubuğun da üstünde çizilir. Sheet açıkken şerit sheet'in üstündedir (`AppSheet.show(online:)`).
- **Dört sekme birlikte kurulur** (`IndexedStack`). Her sekmenin kök ekranı açılışta veri ister; bir sekmenin köküne ağır iş koymayın ([01_mimari.md](01_mimari.md) §6).
- **Tek sonuç araması 80 sonuçla sınırlı** (`ExamFinder`, `ResultMomentLoader`): daha eski bir denemeye yalnız bağlantıyla gidilirse "bulunamadı" çıkar. Listeden açmak etkilenmez.
- **Görüşme araması** yüklenen sayfaları gezer; çok uzun listede yavaştır (sunucu araması yok, #31).
- **Yazma ile yenileme yarışı** `ScheduleService`'te (§3.5).
- **Hesaba ait cihaz tercihleri** oturum bitince (`signOut`, hesap silme) `DevicePreferences.clearAccount` ile silinir. Süresi dolan oturumun sheet'inden başka bir hesapla girilirse silinmez ([02_veri.md](02_veri.md) §9.3).

## 8. Tuzaklar

1. **Sabit yol, `:param`'dan önce.** `/lessons/deck` `:lessonId`'den, koçun `exam/…` ve `program/…` yolları `:studentId`'den önce listelenir; kök tam ekran rotalar kabuklardan önce gelir. Sıra bozulursa "deck" ders kimliği, `/account/delete/progress` `/account`'un çocuğu sanılır (`shell_routes.dart`, `AppRouter.routes`).
2. **Bayrak = rota yok.** Kapalı bayrağın rotası listede değildir; satırı çizen `StackAccountNavigator.canOpen` de bu yüzden onu göstermez. Bayrağı açmak yetmez, arayüzü uygulayıp locator'a kaydetmek gerekir (§5).
3. **Koç bağlamı argümandadır.** Paylaşılan rotayı `student:` vermeden açarsanız ekran koçun kendi (boş) verisini okur ve bağlam şeridi çıkmaz. Yeni bir koç ekranı yazarken `StudentRef`'i rota argümanıyla taşıyın.
4. **Çapraz sekme gezintisi iç içe rota ister.** Başka sekmede ekran açmak için `context.navigateTo(XTabRoute(children: [...]))`; kök `AppRouter.push` alt çubuğu ve sekme yığınını bozar (`home_view.dart` örnekleri).
5. **"Geri Al" sunucuda yok.** Öğrendim (`PendingLearns`) ve not silme (`NoteDeleteHold`) isteği tutar; ekrandan çıkarken `flush` edilmezse yazma kaybolur. İsteği hemen göndermek "Geri Al"ı bozar. Konu Detayı'ndaki Öğrendim bilerek bekletmesizdir; ikisini karıştırmayın.
6. **Notlar konumla adreslenir.** Yazmadan sonra görüşmeyi yeniden okumadan indekse güvenmeyin; aynı anda tek silme bekleyebilir.
7. **Metin alanlı sheet'i tercihen `medium`/`full` açın.** Tur 12 E'den beri `AppSheetRoute` (`_SheetViewportFrame`) yalnız `medium` ve `full` sheet'lerin görüntü alanını klavye kadar kısaltır ve bu sheet'lerde `AppSheetFrame`'in düğme bandı alt boşluğu yok sayar (bant klavyenin hemen üstünde kalır). `small` sheet kaldırılmaz; onun bandı eskisi gibi klavyeyle birlikte yükselir (`ignoreBottomInset` yalnız orta/tam boyda açık). Örnekler: `ChangeCoachSheet` ve `AddStudentSheet` `full`; `NoteSheet` `small` (tek alanlı kısa form). Yeni bir formu klavye açıkken cihazda deneyin.
8. **Puan yuvası tahmin edilmez.** AYT puanı, sırası ve ham değerleri öğrencinin alanının yuvasından okunur (`ExamScores.slotFor`); alan bilinmiyorsa değer çizilmez. Koç bağlamında alan `StudentRef`'ten gelir.
9. **`aimType` tabloları çakışır.** Eski kayıt formu Sayısal=3, EA=2, Sözel=4; eski koç penceresi Sayısal=1, EA=2, Sözel=3, Dil=4 gönderiyordu. Enum'lar ilkini izler (`study_track.dart`); eski pencereyle eklenmiş öğrencilerin alanı yanlış olabilir (#18). "Mezun" 13'tür; koçun gönderebilmesi açık (#30).
10. **Kayıt gövdesini bölmeyin.** `name` tam addır, `firstName` + `surname` ayrıca gider; sunucu ve sahibin canlı uygulaması bu biçimi bekler.
11. **Canlı sunucuda yazan deneme yapmayın.** Kayıt, koç bağlama, öğrenci ekleme, program kaydetme ve hesap silme gerçek veriyi değiştirir. Veri dolu hâli galeride, VM testlerinde ya da geçici sahte repository ile görün.
12. **Kil görsel kuralları.** `AppClay` yalnız tanıtım, hoş geldin ve ekran düzeyi boş durumlarda, ekranda en çok bir tane; satırda, çipte, düğmede, bölüm düzeyi boş durumda yok. Dosya yoksa yer tutucu çizilmez.

## İlgili dosyalar

- Rotalar: `lib/app/router/routes/shell_routes.dart`, `lib/app/router/app_router.dart`, `lib/features/*/*_routes.dart`
- Bayraklar ve yapılandırma: `lib/core/config/feature_flags.dart`, `lib/core/config/app_config.dart`
- DI: `lib/features/*/*_module.dart`, `lib/dependency_injection/injection_container.dart`
- Tur 12 dosyaları: `lib/features/coach/presentation/student_profile/widgets/student_profile_program.dart`, `lib/features/schedule/presentation/{program_list,program_detail,new_program}/`, `lib/features/exams/presentation/widgets/exam_score_card.dart`, `lib/features/lessons/presentation/literature/`, `lib/features/lessons/application/{literature_service,literature_loader,literature_tree,literature_authors}.dart`, `lib/features/coach/presentation/add_student/`, `lib/features/account/presentation/profile/`, `lib/features/account/presentation/coaching/sheets/change_coach_sheet.dart`, `lib/features/account/presentation/account/sheets/{coach_code_sheet,coach_code_viewmodel}.dart`, `lib/features/coach/presentation/widgets/code_card_sheet.dart`, `lib/features/coach/application/coach_code_actions.dart`, `lib/shared/ui/illustrations/app_clay.dart`
- Göç: `lib/features/auth/data/session/legacy_session_migration.dart`, `lib/features/startup/data/legacy_onboarding_migration.dart`, `lib/core/domain/legacy_envelope.dart`, `lib/services/session_manager.dart`, `lib/core/services/device_preferences.dart`
- Belgeler: `docs/DURUM.md`, [../Backend_Sorulari_Ek.md](../Backend_Sorulari_Ek.md), `docs/SMAP_Tasarim_Brifi_Tur12.md`, `docs/spec/SMAP_Flutter_Spec.md` §6.3–6.5, `docs/history/gorevler/` (görev tanımları, `fin3_kullanilmayan_gorseller.txt`)
- Testler: `test/features/<özellik>/`, `test/app/shell/shell_routes_test.dart`, `test/app/router/`
- Diğer bölümler: [01_mimari.md](01_mimari.md), [02_veri.md](02_veri.md), [03_ekran.md](03_ekran.md), [04_tasarim_sistemi.md](04_tasarim_sistemi.md), [05_araclar.md](05_araclar.md), [../DEVELOPING.md](../DEVELOPING.md), [../WORKFLOW.md](../WORKFLOW.md)
