import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/domain/user_role.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/onboarding/application/onboarding_flow.dart';

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

  group('OnboardingFlowState.next', () {
    test('the intro pages come one after the other', () {
      var state = const OnboardingFlowState();

      state = state.next()!;
      expect((state.step, state.introPage), (OnboardingStep.intro, 1));
      state = state.next()!;
      expect((state.step, state.introPage), (OnboardingStep.intro, 2));
      state = state.next()!;
      expect(state.step, OnboardingStep.role);
    });

    test('a student goes role, grade, camera, then the flow ends', () {
      var state = const OnboardingFlowState(step: OnboardingStep.role);

      state = state.next()!;
      expect(state.step, OnboardingStep.grade);
      state = state.withPicks(student.withGrade(SchoolGrade.grade10));
      state = state.next()!;
      expect(state.step, OnboardingStep.camera);
      expect(state.next(), isNull);
    });

    test('a coach skips the grade step: role, camera', () {
      final state = const OnboardingFlowState(
        step: OnboardingStep.role,
        selections: coach,
      ).next()!;

      expect(state.step, OnboardingStep.camera);
    });

    test('the grade step does not move without a grade', () {
      const state = OnboardingFlowState(step: OnboardingStep.grade);

      expect(state.next(), state);
    });

    test('the grade step does not move for 12 without a track', () {
      final state = OnboardingFlowState(
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

  group('OnboardingFlowState.previous', () {
    test('the first intro page has nowhere to go back to', () {
      expect(const OnboardingFlowState().previous(), isNull);
    });

    test('Back walks the intro pages down, then leaves for nothing', () {
      const state = OnboardingFlowState(introPage: 2);

      final back = state.previous()!;

      expect((back.step, back.introPage), (OnboardingStep.intro, 1));
    });

    test('Back from the role question returns to the intro', () {
      const state = OnboardingFlowState(
        step: OnboardingStep.role,
        introPage: 2,
      );

      final back = state.previous()!;

      expect((back.step, back.introPage), (OnboardingStep.intro, 2));
    });

    test('Back from the camera goes to the grade step for a student', () {
      const state = OnboardingFlowState(step: OnboardingStep.camera);

      expect(state.previous()!.step, OnboardingStep.grade);
    });

    test('Back from the camera goes to the role step for a coach', () {
      const state = OnboardingFlowState(
        step: OnboardingStep.camera,
        selections: coach,
      );

      expect(state.previous()!.step, OnboardingStep.role);
    });

    test('Back keeps the picks', () {
      final picks = student
          .withGrade(SchoolGrade.grade12)
          .withTrack(StudyTrack.sayisal);
      final state = OnboardingFlowState(
        step: OnboardingStep.camera,
        selections: picks,
      );

      expect(state.previous()!.previous()!.selections, picks);
    });
  });

  group('OnboardingFlowState', () {
    test('"Geç" goes straight to the role question', () {
      const state = OnboardingFlowState(introPage: 1);

      expect(state.skipIntro().step, OnboardingStep.role);
    });

    test('a stored grade step of a coach is moved back to the role step', () {
      const state = OnboardingFlowState(
        step: OnboardingStep.grade,
        selections: coach,
      );

      expect(state.normalized().step, OnboardingStep.role);
    });
  });
}

extension on OnboardingFlowState {
  OnboardingFlowState withPicks(OnboardingSelections picks) =>
      copyWith(selections: picks);
}
