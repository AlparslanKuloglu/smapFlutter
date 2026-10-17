import 'dart:convert';

import 'package:smap/core/config/feature_flags.dart';
import 'package:smap/core/domain/user_role.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/onboarding/application/onboarding_flow.dart';

/// Reads and writes the onboarding draft in `DevicePreferences`
/// (`onboardingDraftKey`): where the flow stands and what was picked, so an
/// app that is closed in the middle opens at the same step with the same
/// choices (UI guide §7 E2, spec 2.2 "Seçimler kayda kadar yalnız cihazda").
///
/// The value is one JSON object:
/// `{"step":"grade","introPage":2,"role":"student","grade":12,"track":"sayisal"}`.
/// A value that cannot be read is the same as no draft (the flow starts
/// over); nothing here throws. The sign-up screen calls [clear] once the
/// account exists ("kayıtta silinir", spec §6.2).
///
/// `coachSignUpEnabled` (`FeatureFlags.coachSignUpEnabled`, given by the
/// view model that reads) shapes what is read: closed, a draft left on the
/// device with the role "coach" (or on the role step) reads as a student on
/// the grade step.
class OnboardingDraftStore {
  const OnboardingDraftStore(this._preferences);

  final DevicePreferences _preferences;

  /// Whether a draft is stored (the user went through, or into, the flow on
  /// this device).
  bool get exists =>
      (_preferences.getString(DevicePreferences.onboardingDraftKey) ?? '')
          .isNotEmpty;

  /// The stored state, or the start of the flow when there is none (or it is
  /// unreadable).
  OnboardingFlowState read({
    bool coachSignUpEnabled = FeatureFlags.coachSignUpEnabled,
  }) {
    final raw = _preferences.getString(DevicePreferences.onboardingDraftKey);
    if (raw == null || raw.isEmpty) {
      return OnboardingFlowState(coachSignUpEnabled: coachSignUpEnabled);
    }
    return decode(raw, coachSignUpEnabled: coachSignUpEnabled);
  }

  Future<void> write(OnboardingFlowState state) => _preferences.setString(
    DevicePreferences.onboardingDraftKey,
    encode(state),
  );

  /// Forgets the draft (the account exists, or the user signed out).
  Future<void> clear() =>
      _preferences.remove(DevicePreferences.onboardingDraftKey);

  /// The JSON of [state].
  static String encode(OnboardingFlowState state) {
    final picks = state.selections;
    return jsonEncode({
      'step': state.step.name,
      'introPage': state.introPage,
      'role': picks.role.wireName,
      'grade': ?picks.grade?.code,
      'track': ?picks.track?.name,
    });
  }

  /// Reads [raw]; anything wrong falls back to the default for that field.
  static OnboardingFlowState decode(
    String raw, {
    bool coachSignUpEnabled = FeatureFlags.coachSignUpEnabled,
  }) {
    final fresh = OnboardingFlowState(coachSignUpEnabled: coachSignUpEnabled);
    final Object? json;
    try {
      json = jsonDecode(raw);
    } on FormatException {
      return fresh;
    }
    if (json is! Map<String, Object?>) return fresh;

    final role = UserRole.fromLegacy(json['role']);
    final grade = json['grade'] is int
        ? SchoolGrade.fromCode(json['grade'] as int)
        : null;
    StudyTrack? track;
    for (final candidate in StudyTrack.selectable) {
      if (candidate.name == json['track']) track = candidate;
    }
    final page = json['introPage'];
    final selections = OnboardingSelections(
      role: role.isKnown ? role : UserRole.student,
      grade: grade,
      track: track,
    );
    return OnboardingFlowState(
      step: OnboardingStep.fromName(json['step']) ?? OnboardingStep.intro,
      introPage:
          page is int && page >= 0 && page < OnboardingFlowState.introPageCount
          ? page
          : 0,
      selections: grade != null && !grade.requiresTrack
          ? selections.withGrade(grade)
          : selections,
      coachSignUpEnabled: coachSignUpEnabled,
    ).normalized();
  }
}
