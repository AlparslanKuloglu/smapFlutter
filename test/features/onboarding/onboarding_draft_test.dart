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
import 'package:smap/features/onboarding/application/onboarding_draft.dart';
import 'package:smap/features/onboarding/application/onboarding_flow.dart';

void main() {
  late DevicePreferences device;
  late OnboardingDraftStore store;

  Future<void> start([Map<String, Object> values = const {}]) async {
    SharedPreferences.setMockInitialValues(values);
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    device = await DevicePreferences.load();
    store = OnboardingDraftStore(device);
  }

  const full = OnboardingFlowState(
    step: OnboardingStep.camera,
    introPage: 2,
    selections: OnboardingSelections(
      grade: SchoolGrade.grade12,
      track: StudyTrack.esitAgirlik,
    ),
  );

  group('OnboardingDraftStore', () {
    test(
      'with nothing stored the flow starts at the first intro page',
      () async {
        await start();

        expect(store.exists, isFalse);
        expect(store.read(), const OnboardingFlowState());
      },
    );

    test('a written draft is read back as it was', () async {
      await start();

      await store.write(full);

      expect(store.exists, isTrue);
      expect(store.read(), full);
    });

    test('a draft survives a restart (a new DevicePreferences)', () async {
      await start();
      await store.write(full);

      final reopened = OnboardingDraftStore(await DevicePreferences.load());

      expect(reopened.read(), full);
    });

    test('clear forgets it', () async {
      await start();
      await store.write(full);

      await store.clear();

      expect(store.exists, isFalse);
      expect(store.read(), const OnboardingFlowState());
    });

    test(
      'a coach draft is read as a coach while the role step is open',
      () async {
        await start();
        const coach = OnboardingFlowState(
          step: OnboardingStep.camera,
          selections: OnboardingSelections(role: UserRole.coach),
          coachSignUpEnabled: true,
        );

        await store.write(coach);

        expect(store.read(coachSignUpEnabled: true), coach);
      },
    );

    test('a coach draft is read as a student on the grade step when the '
        'role step is closed', () async {
      await start();
      await store.write(
        const OnboardingFlowState(
          step: OnboardingStep.camera,
          selections: OnboardingSelections(role: UserRole.coach),
          coachSignUpEnabled: true,
        ),
      );

      final read = store.read();

      expect(read.selections.role, UserRole.student);
      expect(read.step, OnboardingStep.grade);
      expect(read.coachSignUpEnabled, isFalse);
    });

    test('with no draft the flow starts with the flag it is given', () async {
      await start();

      expect(store.read(coachSignUpEnabled: true).coachSignUpEnabled, isTrue);
      expect(store.read().coachSignUpEnabled, isFalse);
    });
  });

  group('OnboardingDraftStore.decode', () {
    test('garbage is the start of the flow', () {
      for (final raw in ['', 'nope', '[]', '"x"', '{"step": 5}', '{']) {
        expect(
          OnboardingDraftStore.decode(raw),
          const OnboardingFlowState(),
          reason: raw,
        );
      }
    });

    test('an unknown step, role, grade or track falls back field by field', () {
      final state = OnboardingDraftStore.decode(
        '{"step":"party","introPage":9,"role":"teacher","grade":99,'
        '"track":"astro"}',
        coachSignUpEnabled: true,
      );

      // "teacher" is read as a coach by UserRole.fromLegacy; the rest is
      // dropped.
      expect(state.step, OnboardingStep.intro);
      expect(state.introPage, 0);
      expect(state.selections.role, UserRole.coach);
      expect(state.selections.grade, isNull);
      expect(state.selections.track, isNull);
    });

    test('Dil (no code) is not restored as a pick', () {
      final state = OnboardingDraftStore.decode(
        '{"step":"grade","role":"student","grade":12,"track":"dil"}',
      );

      expect(state.selections.track, isNull);
    });

    test('a track stored for grade 10 is dropped', () {
      final state = OnboardingDraftStore.decode(
        '{"step":"grade","role":"student","grade":10,"track":"sayisal"}',
      );

      expect(state.selections.grade, SchoolGrade.grade10);
      expect(state.selections.track, isNull);
    });

    test('the grade step of a coach is moved back to the role step', () {
      final state = OnboardingDraftStore.decode(
        '{"step":"grade","role":"coach"}',
        coachSignUpEnabled: true,
      );

      expect(state.step, OnboardingStep.role);
    });

    test('closed: the role step, and a coach on any step, move on as a '
        'student', () {
      final onRole = OnboardingDraftStore.decode('{"step":"role"}');
      final coachGrade = OnboardingDraftStore.decode(
        '{"step":"grade","role":"coach"}',
      );
      final coachIntro = OnboardingDraftStore.decode(
        '{"step":"intro","introPage":1,"role":"coach"}',
      );

      expect(onRole.step, OnboardingStep.grade);
      expect(coachGrade.step, OnboardingStep.grade);
      expect(coachGrade.selections.role, UserRole.student);
      expect(coachIntro.step, OnboardingStep.intro);
      expect(coachIntro.introPage, 1);
      expect(coachIntro.selections.role, UserRole.student);
    });
  });
}
