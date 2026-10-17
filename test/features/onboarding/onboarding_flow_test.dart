import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/config/feature_flags.dart';
import 'package:smap/core/domain/user_role.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/onboarding/application/onboarding_flow.dart';

/// The flow with the role step part of it (`coachSignUpEnabled: true`).
OnboardingFlowState _open({
  OnboardingStep step = OnboardingStep.intro,
  int introPage = 0,
  OnboardingSelections selections = const OnboardingSelections(),
}) => OnboardingFlowState(
  step: step,
  introPage: introPage,
  selections: selections,
  coachSignUpEnabled: true,
);

/// The same with the role step closed, the shipped state.
OnboardingFlowState _closed({
  OnboardingStep step = OnboardingStep.intro,
  int introPage = 0,
  OnboardingSelections selections = const OnboardingSelections(),
}) => OnboardingFlowState(
  step: step,
  introPage: introPage,
  selections: selections,
);

void main() {
  const student = OnboardingSelections();
  const coach = OnboardingSelections(role: UserRole.coach);

  group('OnboardingSelections', () {
    test('starts as a student with nothing else picked', () {
      expect(student.role, UserRole.student);
      expect(student.grade, isNull);
      expect(student.track, isNull);
      expect(student.asksGrade, isTrue);
      expect(student.asksTrack, isFalse);
    });

    test('11, 12 and Mezun ask for a track; 9 and 10 do not', () {
      for (final grade in [
        SchoolGrade.grade11,
        SchoolGrade.grade12,
        SchoolGrade.graduate,
      ]) {
        final picks = student.withGrade(grade);
        expect(picks.asksTrack, isTrue, reason: '$grade');
        expect(picks.trackMissing, isTrue, reason: '$grade');
      }
      for (final grade in [SchoolGrade.grade9, SchoolGrade.grade10]) {
        final picks = student.withGrade(grade);
        expect(picks.asksTrack, isFalse, reason: '$grade');
        expect(picks.trackMissing, isFalse, reason: '$grade');
      }
    });

    test('moving to 9 or 10 drops a track picked for 12', () {
      final picks = student
          .withGrade(SchoolGrade.grade12)
          .withTrack(StudyTrack.sayisal)
          .withGrade(SchoolGrade.grade10);

      expect(picks.track, isNull);
    });

    test('moving between 11, 12 and Mezun keeps the track', () {
      final picks = student
          .withGrade(SchoolGrade.grade11)
          .withTrack(StudyTrack.sozel)
          .withGrade(SchoolGrade.graduate);

      expect(picks.track, StudyTrack.sozel);
    });

    test('a track without a backend code (Dil) cannot be picked', () {
      final base = student.withGrade(SchoolGrade.grade12);

      expect(base.withTrack(StudyTrack.dil), base);
      expect(base.withTrack(StudyTrack.esitAgirlik).track, isNotNull);
    });

    test('the sign-up form gets no grade and track from a coach', () {
      final picks = coach
          .withGrade(SchoolGrade.grade12)
          .withTrack(StudyTrack.sayisal);

      final handed = picks.forRegistration();

      expect(handed.role, UserRole.coach);
      expect(handed.grade, isNull);
      expect(handed.track, isNull);
    });

    test('the sign-up form gets what a student picked', () {
      final picks = student
          .withGrade(SchoolGrade.grade12)
          .withTrack(StudyTrack.esitAgirlik);

      expect(picks.forRegistration(), picks);
    });

    test('a role switch keeps the grade and track for the way back', () {
      final picks = student
          .withGrade(SchoolGrade.grade12)
          .withTrack(StudyTrack.sayisal)
          .withRole(UserRole.coach)
          .withRole(UserRole.student);

      expect(picks.grade, SchoolGrade.grade12);
      expect(picks.track, StudyTrack.sayisal);
    });
  });

  group('OnboardingFlowState.next (role step open)', () {
    test('the intro pages come one after the other', () {
      var state = _open();

      state = state.next()!;
      expect((state.step, state.introPage), (OnboardingStep.intro, 1));
      state = state.next()!;
      expect((state.step, state.introPage), (OnboardingStep.intro, 2));
      state = state.next()!;
      expect(state.step, OnboardingStep.role);
    });

    test('a student goes role, grade, camera, then the flow ends', () {
      var state = _open(step: OnboardingStep.role);

      state = state.next()!;
      expect(state.step, OnboardingStep.grade);
      state = state.withPicks(student.withGrade(SchoolGrade.grade10));
      state = state.next()!;
      expect(state.step, OnboardingStep.camera);
      expect(state.next(), isNull);
    });

    test('a coach skips the grade step: role, camera', () {
      final state = _open(step: OnboardingStep.role, selections: coach).next()!;

      expect(state.step, OnboardingStep.camera);
    });

    test('the grade step does not move without a grade', () {
      final state = _open(step: OnboardingStep.grade);

      expect(state.next(), state);
    });

    test('the grade step does not move for 12 without a track', () {
      final state = _open(
        step: OnboardingStep.grade,
        selections: student.withGrade(SchoolGrade.grade12),
      );

      expect(state.next(), state);
      expect(
        state.withPicks(state.selections.withTrack(StudyTrack.sayisal)).next(),
        isNotNull,
      );
    });
  });

  group('OnboardingFlowState.previous (role step open)', () {
    test('the first intro page has nowhere to go back to', () {
      expect(_open().previous(), isNull);
    });

    test('Back walks the intro pages down, then leaves for nothing', () {
      final state = _open(introPage: 2);

      final back = state.previous()!;

      expect((back.step, back.introPage), (OnboardingStep.intro, 1));
    });

    test('Back from the role question returns to the intro', () {
      final state = _open(step: OnboardingStep.role, introPage: 2);

      final back = state.previous()!;

      expect((back.step, back.introPage), (OnboardingStep.intro, 2));
    });

    test('Back from the camera goes to the grade step for a student', () {
      final state = _open(step: OnboardingStep.camera);

      expect(state.previous()!.step, OnboardingStep.grade);
    });

    test('Back from the camera goes to the role step for a coach', () {
      final state = _open(step: OnboardingStep.camera, selections: coach);

      expect(state.previous()!.step, OnboardingStep.role);
    });

    test('Back keeps the picks', () {
      final picks = student
          .withGrade(SchoolGrade.grade12)
          .withTrack(StudyTrack.sayisal);
      final state = _open(step: OnboardingStep.camera, selections: picks);

      expect(state.previous()!.previous()!.selections, picks);
    });
  });

  group('OnboardingFlowState (role step open)', () {
    test('"Geç" goes straight to the role question', () {
      final state = _open(introPage: 1);

      expect(state.skipIntro().step, OnboardingStep.role);
    });

    test('a stored grade step of a coach is moved back to the role step', () {
      final state = _open(step: OnboardingStep.grade, selections: coach);

      expect(state.normalized().step, OnboardingStep.role);
    });
  });

  group('OnboardingFlowState (role step closed)', () {
    test('the default is the shipped flag value', () {
      expect(FeatureFlags.coachSignUpEnabled, isFalse);
      expect(const OnboardingFlowState().coachSignUpEnabled, isFalse);
    });

    test('the last intro page leads to the grade step, not the role step', () {
      var state = _closed();

      state = state.next()!.next()!;
      expect((state.step, state.introPage), (OnboardingStep.intro, 2));
      state = state.next()!;

      expect(state.step, OnboardingStep.grade);
      expect(state.selections.role, UserRole.student);
    });

    test('"Geç" goes straight to the grade question', () {
      expect(_closed(introPage: 1).skipIntro().step, OnboardingStep.grade);
    });

    test('Back from the grade step returns to the intro page it left', () {
      final back = _closed(
        step: OnboardingStep.grade,
        introPage: 2,
      ).previous()!;

      expect((back.step, back.introPage), (OnboardingStep.intro, 2));
    });

    test('a student goes grade, camera, then the flow ends', () {
      var state = _closed(
        step: OnboardingStep.grade,
        selections: student.withGrade(SchoolGrade.grade10),
      );

      state = state.next()!;
      expect(state.step, OnboardingStep.camera);
      expect(state.previous()!.step, OnboardingStep.grade);
      expect(state.next(), isNull);
    });

    test('the grade step still waits for a grade and a track', () {
      final noGrade = _closed(step: OnboardingStep.grade);
      final noTrack = _closed(
        step: OnboardingStep.grade,
        selections: student.withGrade(SchoolGrade.grade12),
      );

      expect(noGrade.next(), noGrade);
      expect(noTrack.next(), noTrack);
    });

    test('a stored role step is moved on to the grade step', () {
      expect(
        _closed(step: OnboardingStep.role).normalized().step,
        OnboardingStep.grade,
      );
    });

    test('a coach in a stored state becomes a student', () {
      final fixed = _closed(
        step: OnboardingStep.grade,
        selections: coach,
      ).normalized();

      expect(fixed.step, OnboardingStep.grade);
      expect(fixed.selections.role, UserRole.student);
    });

    test('a coach stored on the camera step returns to the grade question', () {
      final fixed = _closed(
        step: OnboardingStep.camera,
        selections: coach,
      ).normalized();

      expect(fixed.step, OnboardingStep.grade);
      expect(fixed.selections.role, UserRole.student);
    });

    test('a student stored on the camera step stays there', () {
      final state = _closed(
        step: OnboardingStep.camera,
        selections: student.withGrade(SchoolGrade.grade10),
      );

      expect(state.normalized(), state);
    });

    test('copyWith keeps the flag', () {
      expect(_closed().copyWith(introPage: 1).coachSignUpEnabled, isFalse);
      expect(_open().copyWith(introPage: 1).coachSignUpEnabled, isTrue);
    });
  });
}

extension on OnboardingFlowState {
  OnboardingFlowState withPicks(OnboardingSelections picks) =>
      copyWith(selections: picks);
}
