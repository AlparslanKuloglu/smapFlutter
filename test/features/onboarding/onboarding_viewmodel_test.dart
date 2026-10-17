import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smap/core/domain/user_role.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/onboarding/application/camera_permission.dart';
import 'package:smap/features/onboarding/application/onboarding_draft.dart';
import 'package:smap/features/onboarding/application/onboarding_flow.dart';
import 'package:smap/features/onboarding/onboarding_navigation.dart';
import 'package:smap/features/onboarding/presentation/onboarding/onboarding_viewmodel.dart';
import 'package:smap/features/onboarding/presentation/welcome/welcome_viewmodel.dart';

class _FakeCamera implements CameraPermission {
  CameraPermissionState current = CameraPermissionState.notAsked;
  CameraPermissionState answer = CameraPermissionState.granted;
  int requests = 0;
  int settingsOpened = 0;

  @override
  Future<CameraPermissionState> status() async => current;

  @override
  Future<CameraPermissionState> request() async {
    requests++;
    current = answer;
    return answer;
  }

  @override
  Future<void> openSettings() async => settingsOpened++;
}

class _FakeNavigator implements OnboardingNavigator {
  final List<String> calls = [];
  OnboardingSelections? registered;

  @override
  Future<void> toWelcome() async => calls.add('welcome');

  @override
  Future<void> toLogin() async => calls.add('login');

  @override
  Future<void> toRegister(OnboardingSelections? selections) async {
    calls.add('register');
    registered = selections;
  }
}

void main() {
  late DevicePreferences device;
  late OnboardingDraftStore draft;
  late _FakeCamera camera;
  late _FakeNavigator navigator;

  Future<void> boot() async {
    SharedPreferences.setMockInitialValues({});
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    device = await DevicePreferences.load();
    draft = OnboardingDraftStore(device);
    camera = _FakeCamera();
    navigator = _FakeNavigator();
  }

  /// The groups below this one are the flow with the role step open (the
  /// boards of pano 2.2); [open] false is the shipped flag value.
  OnboardingViewModel viewModel({bool open = true}) => OnboardingViewModel(
    draft: draft,
    preferences: device,
    camera: camera,
    navigator: navigator,
    coachSignUpEnabled: open,
  );

  bool? seen() => device.getBool(DevicePreferences.onboardingCompletedKey);

  /// Lets the fire-and-forget draft write and the camera status read finish.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  setUp(boot);

  group('intro', () {
    test('starts on the first page of the intro, a student', () {
      final vm = viewModel();

      expect(vm.step, OnboardingStep.intro);
      expect(vm.introPage.value, 0);
      expect(vm.selections.role, UserRole.student);
    });

    test('"Devam Et" turns the pages and "Başla" opens the role question', () {
      final vm = viewModel()..next();
      expect(vm.introPage.value, 1);
      vm.next();
      expect(vm.introPage.value, 2);
      expect(vm.step, OnboardingStep.intro);

      vm.next();

      expect(vm.step, OnboardingStep.role);
    });

    test('a swipe sets the page', () {
      final vm = viewModel()..setIntroPage(2);

      expect(vm.introPage.value, 2);
    });

    test('"Geç" opens the role question', () {
      final vm = viewModel()..skipIntro();

      expect(vm.step, OnboardingStep.role);
    });

    test('Back goes down the pages and then has nowhere to go', () {
      final vm = viewModel()..setIntroPage(1);

      expect(vm.back(), isTrue);
      expect(vm.introPage.value, 0);
      expect(vm.back(), isFalse);
    });
  });

  group('role, grade and track', () {
    test('a student gets the grade step; a coach goes to the camera', () {
      final student = viewModel()
        ..skipIntro()
        ..next();
      expect(student.step, OnboardingStep.grade);

      final coach = viewModel()
        ..skipIntro()
        ..selectRole(UserRole.coach)
        ..next();
      expect(coach.step, OnboardingStep.camera);
    });

    test('9 and 10 go on with no track', () {
      final vm = viewModel()
        ..skipIntro()
        ..next()
        ..selectGrade(SchoolGrade.grade10)
        ..next();

      expect(vm.step, OnboardingStep.camera);
      expect(vm.selections.track, isNull);
    });

    test('12 without a track shows the error and stays', () {
      final vm = viewModel()
        ..skipIntro()
        ..next()
        ..selectGrade(SchoolGrade.grade12)
        ..next();

      expect(vm.step, OnboardingStep.grade);
      expect(vm.trackError, isTrue);

      vm
        ..selectTrack(StudyTrack.sayisal)
        ..next();

      expect(vm.trackError, isFalse);
      expect(vm.step, OnboardingStep.camera);
    });

    test('picking another grade clears the error', () {
      final vm = viewModel()
        ..skipIntro()
        ..next()
        ..selectGrade(SchoolGrade.grade12)
        ..next()
        ..selectGrade(SchoolGrade.grade9);

      expect(vm.trackError, isFalse);
    });

    test('Dil cannot be picked', () {
      final vm = viewModel()
        ..skipIntro()
        ..next()
        ..selectGrade(SchoolGrade.grade12)
        ..selectTrack(StudyTrack.dil);

      expect(vm.selections.track, isNull);
    });

    test('Back works on every step and keeps the picks', () {
      final vm = viewModel()
        ..skipIntro()
        ..next()
        ..selectGrade(SchoolGrade.grade12)
        ..selectTrack(StudyTrack.esitAgirlik)
        ..next();
      expect(vm.step, OnboardingStep.camera);

      expect(vm.back(), isTrue);
      expect(vm.step, OnboardingStep.grade);
      expect(vm.forward, isFalse);
      expect(vm.selections.grade, SchoolGrade.grade12);
      expect(vm.selections.track, StudyTrack.esitAgirlik);

      expect(vm.back(), isTrue);
      expect(vm.step, OnboardingStep.role);
      expect(vm.back(), isTrue);
      expect(vm.step, OnboardingStep.intro);
      expect(vm.introPage.value, 0, reason: 'where "Geç" was tapped');
      expect(vm.back(), isFalse);
    });
  });

  group('role step closed (FeatureFlags.coachSignUpEnabled false)', () {
    OnboardingViewModel closed() => viewModel(open: false);

    test('the shipped flag is closed, so the default view model is too', () {
      expect(
        OnboardingViewModel(
          draft: draft,
          preferences: device,
          camera: camera,
          navigator: navigator,
        ).coachSignUpEnabled,
        isFalse,
      );
    });

    test('"Başla" on the last page opens the grade question', () {
      final vm = closed()
        ..next()
        ..next()
        ..next();

      expect(vm.step, OnboardingStep.grade);
      expect(vm.selections.role, UserRole.student);
    });

    test('"Geç" opens the grade question', () {
      final vm = closed()..skipIntro();

      expect(vm.step, OnboardingStep.grade);
    });

    test('a coach cannot be picked', () {
      final vm = closed()
        ..skipIntro()
        ..selectRole(UserRole.coach);

      expect(vm.selections.role, UserRole.student);
    });

    test('grade, track and camera work as for a student', () {
      final vm = closed()
        ..skipIntro()
        ..selectGrade(SchoolGrade.grade12)
        ..next();
      expect(vm.step, OnboardingStep.grade);
      expect(vm.trackError, isTrue);

      vm
        ..selectTrack(StudyTrack.sayisal)
        ..next();
      expect(vm.step, OnboardingStep.camera);
    });

    test('Back goes camera, grade, intro and then has nowhere to go', () {
      final vm = closed()
        ..setIntroPage(2)
        ..next()
        ..selectGrade(SchoolGrade.grade10)
        ..next();
      expect(vm.step, OnboardingStep.camera);

      expect(vm.back(), isTrue);
      expect(vm.step, OnboardingStep.grade);
      expect(vm.back(), isTrue);
      expect(vm.step, OnboardingStep.intro);
      expect(vm.introPage.value, 2);
      expect(vm.back(), isTrue);
      expect(vm.introPage.value, 1);
    });

    test('the stored state is a student on the grade step', () async {
      closed()
        ..skipIntro()
        ..selectGrade(SchoolGrade.grade11);
      await settle();

      final stored = draft.read(coachSignUpEnabled: false);

      expect(stored.step, OnboardingStep.grade);
      expect(stored.selections.role, UserRole.student);
    });

    test('a coach draft of an older build opens as a student on the grade '
        'step', () async {
      await draft.write(
        const OnboardingFlowState(
          step: OnboardingStep.camera,
          selections: OnboardingSelections(role: UserRole.coach),
          coachSignUpEnabled: true,
        ),
      );

      final vm = closed();

      expect(vm.step, OnboardingStep.grade);
      expect(vm.selections.role, UserRole.student);
    });

    test('a draft on the role step opens on the grade step', () async {
      await draft.write(const OnboardingFlowState(step: OnboardingStep.role));

      expect(closed().step, OnboardingStep.grade);
    });

    test('the flow still ends with the flag set and welcome open', () async {
      final vm = closed()
        ..skipIntro()
        ..selectGrade(SchoolGrade.grade9)
        ..next();

      await vm.later();

      expect(seen(), isTrue);
      expect(navigator.calls, ['welcome']);
    });
  });

  group('draft', () {
    test('the step and the picks are stored as they change', () async {
      viewModel()
        ..skipIntro()
        ..next()
        ..selectGrade(SchoolGrade.grade11)
        ..selectTrack(StudyTrack.sozel);
      await settle();

      final stored = draft.read();
      expect(stored.step, OnboardingStep.grade);
      expect(stored.selections.grade, SchoolGrade.grade11);
      expect(stored.selections.track, StudyTrack.sozel);
    });

    test('a reopened app continues where it was', () async {
      viewModel()
        ..skipIntro()
        ..next()
        ..selectGrade(SchoolGrade.grade12)
        ..selectTrack(StudyTrack.sayisal)
        ..next();
      await settle();

      final reopened = viewModel();

      expect(reopened.step, OnboardingStep.camera);
      expect(reopened.selections.grade, SchoolGrade.grade12);
      expect(reopened.selections.track, StudyTrack.sayisal);
    });

    test('the intro page is restored too', () async {
      viewModel().setIntroPage(2);
      await settle();

      expect(viewModel().introPage.value, 2);
    });
  });

  group('camera primer', () {
    OnboardingViewModel atCamera() => viewModel()
      ..skipIntro()
      ..selectRole(UserRole.coach)
      ..next();

    test(
      '"İzin Ver" asks once; granted sets the flag and opens welcome',
      () async {
        final vm = atCamera();

        await vm.allowCamera();

        expect(camera.requests, 1);
        expect(seen(), isTrue);
        expect(navigator.calls, ['welcome']);
      },
    );

    test('"Sonra" moves on without asking', () async {
      final vm = atCamera();

      await vm.later();

      expect(camera.requests, 0);
      expect(seen(), isTrue);
      expect(navigator.calls, ['welcome']);
    });

    test('the flag is not set before the flow ends', () {
      atCamera();

      expect(seen(), isNull);
    });

    test('a refusal stays on the step and offers the settings', () async {
      camera.answer = CameraPermissionState.denied;
      final vm = atCamera();

      await vm.allowCamera();

      expect(vm.step, OnboardingStep.camera);
      expect(vm.cameraState, CameraPermissionState.denied);
      expect(navigator.calls, isEmpty);
      expect(seen(), isNull);

      await vm.allowCamera();

      expect(camera.settingsOpened, 1);
      expect(camera.requests, 1, reason: 'the system asks only once');
    });

    test('"Sonra" still works after a refusal', () async {
      camera.answer = CameraPermissionState.denied;
      final vm = atCamera();
      await vm.allowCamera();

      await vm.later();

      expect(navigator.calls, ['welcome']);
    });

    test(
      'a permission refused earlier shows the settings button at once',
      () async {
        camera.current = CameraPermissionState.denied;
        final vm = atCamera();
        await settle();

        expect(vm.cameraState, CameraPermissionState.denied);
      },
    );

    test(
      'coming back from the settings with the permission moves on',
      () async {
        camera.answer = CameraPermissionState.denied;
        final vm = atCamera();
        await vm.allowCamera();

        camera.current = CameraPermissionState.granted;
        await vm.onResumed();

        expect(seen(), isTrue);
        expect(navigator.calls, ['welcome']);
      },
    );

    test('coming back from the settings without it stays', () async {
      camera.answer = CameraPermissionState.denied;
      final vm = atCamera();
      await vm.allowCamera();

      await vm.onResumed();

      expect(navigator.calls, isEmpty);
      expect(vm.step, OnboardingStep.camera);
    });

    test('two quick taps open welcome once', () async {
      final vm = atCamera();

      await Future.wait([vm.later(), vm.later()]);

      expect(navigator.calls, ['welcome']);
    });

    test(
      'the draft is kept when the flow ends (the sign-up reads it)',
      () async {
        final vm = viewModel()
          ..skipIntro()
          ..next()
          ..selectGrade(SchoolGrade.grade12)
          ..selectTrack(StudyTrack.sayisal)
          ..next();

        await vm.later();

        expect(draft.exists, isTrue);
        expect(draft.read().selections.grade, SchoolGrade.grade12);
      },
    );
  });

  group('WelcomeViewModel', () {
    WelcomeViewModel welcome({bool open = true}) => WelcomeViewModel(
      draft: draft,
      navigator: navigator,
      coachSignUpEnabled: open,
    );

    test('"Kayıt Ol" hands the picks to the sign-up form', () async {
      await draft.write(
        const OnboardingFlowState(
          step: OnboardingStep.camera,
          selections: OnboardingSelections(
            grade: SchoolGrade.grade12,
            track: StudyTrack.esitAgirlik,
          ),
        ),
      );

      await welcome().register();

      expect(navigator.calls, ['register']);
      expect(navigator.registered?.role, UserRole.student);
      expect(navigator.registered?.grade, SchoolGrade.grade12);
      expect(navigator.registered?.track, StudyTrack.esitAgirlik);
    });

    test('a coach hands over the role only', () async {
      await draft.write(
        const OnboardingFlowState(
          step: OnboardingStep.camera,
          selections: OnboardingSelections(
            role: UserRole.coach,
            grade: SchoolGrade.grade12,
          ),
        ),
      );

      await welcome().register();

      expect(navigator.registered?.role, UserRole.coach);
      expect(navigator.registered?.grade, isNull);
    });

    test(
      'closed: a coach left in the draft is handed over as a student',
      () async {
        await draft.write(
          const OnboardingFlowState(
            step: OnboardingStep.camera,
            selections: OnboardingSelections(
              role: UserRole.coach,
              grade: SchoolGrade.grade12,
            ),
            coachSignUpEnabled: true,
          ),
        );

        await welcome(open: false).register();

        expect(navigator.registered?.role, UserRole.student);
      },
    );

    test('with no draft on the device nothing is handed over', () async {
      await welcome().register();

      expect(navigator.calls, ['register']);
      expect(navigator.registered, isNull);
    });

    test('"Giriş Yap" opens the sign-in', () async {
      await welcome().login();

      expect(navigator.calls, ['login']);
    });
  });
}
