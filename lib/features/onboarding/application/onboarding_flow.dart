import 'package:flutter/foundation.dart';

import 'package:smap/core/domain/user_role.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';

/// The inner steps of the intro flow (spec §3.6: `/onboarding/intro`,
/// `/onboarding/role`, `/onboarding/grade`, `/onboarding/camera`; pano 2.1
/// kare 2-4 and 2.2 kare 1-4). The three intro pages are one step with a
/// page index; the welcome screen is its own route.
enum OnboardingStep {
  /// The 3-page carousel (pano 2.1 kare 2-4).
  intro,

  /// "SMAP'i nasıl kullanacaksın?" (pano 2.2 kare 1).
  role,

  /// "Kaçıncı sınıftasın?" and, for 11, 12 and Mezun, "Alanın" (pano 2.2
  /// kare 2 and 3). Students only.
  grade,

  /// "Formunu okutmak için kamera gerekli" (pano 2.2 kare 4).
  camera;

  /// Reads a stored [name]; `null` for anything unknown.
  static OnboardingStep? fromName(Object? name) {
    for (final step in values) {
      if (step.name == name) return step;
    }
    return null;
  }
}

/// What the user picked before sign-up: role, school year and study track.
///
/// Kept on the device until the account exists, then handed to the sign-up
/// form (spec 2.2 "Seçimler kayda kadar yalnız cihazda tutulur"). The role
/// starts as "Öğrenciyim" (spec §4.A 2.2-1 [Karar]); grade and track start
/// empty.
@immutable
class OnboardingSelections {
  const OnboardingSelections({
    this.role = UserRole.student,
    this.grade,
    this.track,
  }) : assert(
         role == UserRole.student || role == UserRole.coach,
         'Only student and coach are choices',
       );

  final UserRole role;
  final SchoolGrade? grade;
  final StudyTrack? track;

  /// The role question is followed by the grade step only for a student.
  bool get asksGrade => role == UserRole.student;

  /// The track question shows (11, 12, Mezun).
  bool get asksTrack => asksGrade && (grade?.requiresTrack ?? false);

  /// "Devam Et" of the grade step is live once the question is answered
  /// enough: a grade, and for 11/12/Mezun, a track is checked on the tap
  /// (the button stays filled; spec §4.A 2.2-2/3 [Karar]).
  bool get hasGrade => grade != null;

  /// 11, 12 or Mezun is picked but no track yet.
  bool get trackMissing => asksTrack && track == null;

  OnboardingSelections withRole(UserRole value) =>
      OnboardingSelections(role: value, grade: grade, track: track);

  /// Picking 9 or 10 drops a track picked earlier: those years have none.
  OnboardingSelections withGrade(SchoolGrade value) => OnboardingSelections(
    role: role,
    grade: value,
    track: value.requiresTrack ? track : null,
  );

  /// A track the backend has no code for ([StudyTrack.dil]) cannot be
  /// picked; the call is ignored.
  OnboardingSelections withTrack(StudyTrack value) {
    if (!StudyTrack.selectable.contains(value)) return this;
    return OnboardingSelections(role: role, grade: grade, track: value);
  }

  /// What the sign-up form receives: a coach has no grade or track, and a
  /// grade without a track question has none either.
  OnboardingSelections forRegistration() => OnboardingSelections(
    role: role,
    grade: asksGrade ? grade : null,
    track: asksTrack ? track : null,
  );

  @override
  bool operator ==(Object other) =>
      other is OnboardingSelections &&
      other.role == role &&
      other.grade == grade &&
      other.track == track;

  @override
  int get hashCode => Object.hash(role, grade, track);

  @override
  String toString() => 'OnboardingSelections($role, $grade, $track)';
}

/// Where the flow stands: step, intro page and picks. Pure; the view model
/// only holds one and asks it where Back and "Devam Et" lead.
@immutable
class OnboardingFlowState {
  const OnboardingFlowState({
    this.step = OnboardingStep.intro,
    this.introPage = 0,
    this.selections = const OnboardingSelections(),
  }) : assert(introPage >= 0 && introPage < introPageCount);

  /// Number of intro pages (pano 2.1 kare 2-4).
  static const int introPageCount = 3;

  final OnboardingStep step;
  final int introPage;
  final OnboardingSelections selections;

  bool get onLastIntroPage => introPage == introPageCount - 1;

  /// The step on the way back; the root of the flow has none.
  OnboardingFlowState? previous() => switch (step) {
    OnboardingStep.intro when introPage > 0 => copyWith(
      introPage: introPage - 1,
    ),
    OnboardingStep.intro => null,
    OnboardingStep.role => copyWith(step: OnboardingStep.intro),
    OnboardingStep.grade => copyWith(step: OnboardingStep.role),
    OnboardingStep.camera => copyWith(
      step: selections.asksGrade ? OnboardingStep.grade : OnboardingStep.role,
    ),
  };

  /// The state after "Devam Et" or "Başla"; `null` after the camera step
  /// (the flow is over: on to the welcome screen). A grade step whose
  /// question is not answered stays where it is.
  OnboardingFlowState? next() => switch (step) {
    OnboardingStep.intro when !onLastIntroPage => copyWith(
      introPage: introPage + 1,
    ),
    OnboardingStep.intro => copyWith(step: OnboardingStep.role),
    OnboardingStep.role => copyWith(
      step: selections.asksGrade ? OnboardingStep.grade : OnboardingStep.camera,
    ),
    OnboardingStep.grade =>
      selections.hasGrade && !selections.trackMissing
          ? copyWith(step: OnboardingStep.camera)
          : this,
    OnboardingStep.camera => null,
  };

  /// "Geç" on the first two intro pages: straight to the role question.
  OnboardingFlowState skipIntro() => copyWith(step: OnboardingStep.role);

  /// A stored state made consistent: a coach cannot be on the grade step.
  OnboardingFlowState normalized() =>
      step == OnboardingStep.grade && !selections.asksGrade
      ? copyWith(step: OnboardingStep.role)
      : this;

  OnboardingFlowState copyWith({
    OnboardingStep? step,
    int? introPage,
    OnboardingSelections? selections,
  }) => OnboardingFlowState(
    step: step ?? this.step,
    introPage: introPage ?? this.introPage,
    selections: selections ?? this.selections,
  );

  @override
  bool operator ==(Object other) =>
      other is OnboardingFlowState &&
      other.step == step &&
      other.introPage == introPage &&
      other.selections == selections;

  @override
  int get hashCode => Object.hash(step, introPage, selections);
}
