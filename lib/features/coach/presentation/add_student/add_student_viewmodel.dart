import 'dart:math';
import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/auth/application/register/register_rules.dart';
import 'package:smap/features/auth/application/register/username_live_check.dart';
import 'package:smap/features/coach/application/add_student_rules.dart';
import 'package:smap/features/coach/application/coach_code_actions.dart';
import 'package:smap/features/coach/application/password_generator.dart';
import 'package:smap/features/coach/application/student_avatars.dart';
import 'package:smap/features/coach/data/add_student_outcome.dart';
import 'package:smap/features/coach/domain/new_student.dart';
import 'package:smap/l10n/app_localizations.dart';

/// `CoachStudentsService.addStudent`: creates the student and puts the created
/// one into the session's list.
typedef AddStudentSubmit =
    Future<AppResult<AddStudentOutcome>> Function(NewStudent student);

/// Asks the screen to move focus (and scroll) to [field]; [serial] makes two
/// requests for the same field distinct.
@immutable
class AddStudentFocusRequest {
  const AddStudentFocusRequest(this.field, this.serial);

  final AddStudentField field;
  final int serial;
}

/// How long the form waits after the last key before it asks whether the user
/// name is free (pano 10.3 "Alan kuralları": "yazmadan 400 ms sonra canlı
/// kontrol"; the sign-up form's own wait is longer, task E4).
const Duration kAddStudentUsernameDebounce = SmapDurations.usernameDebounce;

/// The form of "Öğrenci ekle" (pano 10.3 kare 1 and 2; spec §4.I 10.3; Tur 12
/// D for the avatar).
///
/// Holds the form's values and what the rules and the server say about them;
/// the text controllers and focus nodes stay in the view. A field shows its
/// issue after it lost focus with something in it, or after "Öğrenciyi Kaydet"
/// was pressed, and then keeps it live while the coach types; a taken user
/// name shows at once.
///
/// - The user name is lower-cased and kept to letters, digits, "." and "_"
///   (decision 7.4); 400 ms after the last key, or at once on "Kontrol Et",
///   the server is asked (`checkUsername`). A taken name offers a free
///   neighbour (the surname's initial, a number) found by asking the server
///   too.
/// - "Oluştur" makes a readable 10-character password ([PasswordGenerator]);
///   it is returned so the view can write it into its field.
/// - A student of 9th or 10th grade has no track (the field turns passive).
///   The avatar starts on the first of the seven and need not be chosen.
///
/// **Submit.** Validates; on issues, focus goes to the first one
/// ([focusRequest]). Otherwise the student is created: the sheet is busy
/// meanwhile ([submitting]); a "user name in use" answer becomes the field
/// error with a free suggestion; every other failure stays as [failure] above
/// the button and the sheet keeps what was typed. A saved student comes back
/// as an [AddedStudent], carrying the password the coach has to pass on (the
/// server never sends it back).
///
/// The ViewModel holds no `BuildContext`: copying and sharing the coaching
/// code go through the injected [CoachCodeActions].
class AddStudentViewModel extends BaseViewModel {
  AddStudentViewModel({
    required UsernameChecker checkUsername,
    required AddStudentSubmit addStudent,
    required CoachCodeActions codeActions,
    String? coachCode,
    Random? random,
    Duration usernameDebounce = kAddStudentUsernameDebounce,
  }) : _addStudent = addStudent,
       _codeActions = codeActions,
       _coachCode = coachCode?.trim(),
       _random = random ?? Random.secure() {
    _check = UsernameLiveCheck(
      checker: checkUsername,
      onChanged: _notify,
      debounce: usernameDebounce,
    );
  }

  final AddStudentSubmit _addStudent;
  final CoachCodeActions _codeActions;
  final String? _coachCode;
  final Random _random;
  late final UsernameLiveCheck _check;

  /// Focus and scroll requests for the view.
  final ValueNotifier<AddStudentFocusRequest?> focusRequest =
      ValueNotifier<AddStudentFocusRequest?>(null);
  int _focusSerial = 0;

  int _avatar = StudentAvatars.initialIndex;
  String _firstName = '';
  String _lastName = '';
  String _username = '';
  String _password = '';
  SchoolGrade? _grade;
  StudyTrack? _track;
  final Set<AddStudentField> _shown = {};

  bool _submitting = false;
  AppException? _failure;
  bool _disposed = false;

  // ── Values the sections select on ────────────────────────────────────

  int get avatarIndex => _avatar;
  SchoolGrade? get grade => _grade;
  StudyTrack? get track => _track;
  bool get submitting => _submitting;

  /// Why the last save failed, shown above "Öğrenciyi Kaydet"; `null` while
  /// nothing failed.
  AppException? get failure => _failure;

  /// Where the live check of the user name stands.
  UsernameCheckState get usernameCheck => _check.state;

  /// The coach's coaching code as the account holds it; `null` without one
  /// (the "ya da" section is then not drawn).
  String? get coachCode {
    final code = _coachCode;
    return code == null || code.isEmpty ? null : code;
  }

  AddStudentValues get _values => AddStudentValues(
    firstName: _firstName,
    lastName: _lastName,
    username: _username,
    password: _password,
    grade: _grade,
    track: _track,
    avatarIndex: _avatar,
    usernameStatus: _check.state.status,
  );

  String get _fullName => '$_firstName $_lastName'.trim();

  /// The issue [field] shows right now, `null` when none (yet).
  AddStudentIssue? issueFor(AddStudentField field) {
    final issue = AddStudentRules.issueOf(field, _values);
    if (issue == null) return null;
    if (issue == AddStudentIssue.usernameTaken) return issue;
    return _shown.contains(field) ? issue : null;
  }

  // ── Edits ────────────────────────────────────────────────────────────

  void setAvatar(int index) {
    if (index == _avatar || StudentAvatars.fileOf(index) == null) return;
    _avatar = index;
    _notify();
  }

  void onFirstName(String value) {
    _firstName = value;
    _notify();
  }

  void onLastName(String value) {
    _lastName = value;
    _notify();
  }

  /// A new user name; [raw] is normalized here too, so the check always asks
  /// about what will be sent. [immediately] skips the debounce (a tapped
  /// suggestion).
  void onUsername(String raw, {bool immediately = false}) {
    _username = RegisterRules.normalizeUserName(raw);
    _check.input(_username, fullName: _fullName, immediately: immediately);
    _notify();
  }

  /// "Kontrol Et": asks the server now. An empty name shows its issue instead.
  void checkUsernameNow() {
    if (_username.isEmpty) {
      _shown.add(AddStudentField.username);
      _notify();
      return;
    }
    // A name left unchecked while the device was offline is asked again.
    if (_check.state.status == UsernameStatus.offline) _check.input('');
    _check.input(_username, fullName: _fullName, immediately: true);
  }

  void onPassword(String value) {
    _password = value;
    _notify();
  }

  /// "Oluştur": a new readable password; the view writes it into its field.
  String generatePassword() {
    _password = PasswordGenerator.generate(_random);
    _notify();
    return _password;
  }

  void setGrade(SchoolGrade grade) {
    _grade = grade;
    _track = AddStudentRules.trackFor(grade, _track);
    _notify();
  }

  void setTrack(StudyTrack track) {
    _track = track;
    _notify();
  }

  /// A field lost focus: a value that is wrong starts showing its issue.
  void blur(AddStudentField field) {
    final hasValue = switch (field) {
      AddStudentField.firstName => _firstName.trim().isNotEmpty,
      AddStudentField.lastName => _lastName.trim().isNotEmpty,
      AddStudentField.password => _password.isNotEmpty,
      AddStudentField.username ||
      AddStudentField.grade ||
      AddStudentField.track => false,
    };
    if (hasValue && _shown.add(field)) _notify();
  }

  // ── Actions ──────────────────────────────────────────────────────────

  /// "Öğrenciyi Kaydet". Completes with the saved student, or `null` when the
  /// form has an issue, the save failed or one is already running.
  Future<AddedStudent?> submit() async {
    if (_submitting) return null;
    _failure = null;
    _shown.addAll(AddStudentField.values);
    await _check.settle(_username, fullName: _fullName);
    final issues = AddStudentRules.validate(_values);
    final request = AddStudentRules.toNewStudent(_values);
    if (issues.isNotEmpty || request == null) {
      _requestFocus(issues.keys.firstOrNull ?? AddStudentField.firstName);
      _notify();
      return null;
    }

    _submitting = true;
    _notify();
    final result = await _addStudent(request);
    if (_disposed) return null;
    _submitting = false;
    final outcome = result.rightOrNull;
    if (outcome == null) {
      _failure = result.leftOrNull;
      AppHaptics.error();
      _notify();
      return null;
    }
    switch (outcome) {
      case UserNameTaken():
        _check.markTaken(_username, fullName: _fullName);
        AppHaptics.error();
        _requestFocus(AddStudentField.username);
        _notify();
        return null;
      case StudentAdded(:final student):
        AppHaptics.success();
        _notify();
        return AddedStudent(
          student: student,
          fullName: _fullName,
          userName: request.userName,
          password: request.password,
          avatarIndex: _avatar,
        );
    }
  }

  /// The code card's "Kopyala": the code on the clipboard and the toast.
  Future<void> copyCode() async {
    final code = coachCode;
    if (code == null) return;
    await _codeActions.copy(code);
  }

  /// The code card's "Paylaş": the system share sheet with the code in a
  /// sentence; [origin] anchors an iPad's popover on the button.
  Future<void> shareCode(AppLocalizations l10n, {Rect? origin}) async {
    final code = coachCode;
    if (code == null) return;
    await _codeActions.share(
      l10n.coachWidgets_codeShareText(code),
      origin: origin,
    );
  }

  void _requestFocus(AddStudentField field) {
    _focusSerial++;
    focusRequest.value = AddStudentFocusRequest(field, _focusSerial);
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _check.dispose();
    focusRequest.dispose();
    super.dispose();
  }
}
