import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/domain/user_role.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/features/account/data/dtos/legal_document_dto.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/auth/application/register/consent_text_parts.dart';
import 'package:smap/features/auth/application/register/register_legal_texts.dart';
import 'package:smap/features/auth/application/register/register_rules.dart';
import 'package:smap/features/auth/application/register/username_live_check.dart';
import 'package:smap/features/auth/data/dtos/new_registration.dart';
import 'package:smap/features/auth/data/dtos/register_outcome.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';
import 'package:smap/features/auth/presentation/register/register_navigator.dart';
import 'package:smap/features/auth/presentation/register/register_notice.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

/// `AuthRepository.register`.
typedef RegisterSubmit =
    Future<AppResult<RegisterOutcome>> Function(NewRegistration registration);

/// `SessionManager.signIn`: the same credentials the account was made with.
typedef RegisterSignIn =
    Future<AppResult<UserDto>> Function({
      required String username,
      required String password,
    });

/// `AccountRepository.getLegalDocuments`.
typedef LegalDocumentsLoader =
    Future<AppResult<List<LegalDocumentDto>>> Function();

/// Opens a legal text for reading (`LegalTextSheet.show`).
typedef LegalTextOpener = Future<void> Function(LegalDocumentDto document);

/// Asks the screen to move focus (and scroll) to [field]; [serial] makes two
/// requests for the same field distinct.
@immutable
class RegisterFocusRequest {
  const RegisterFocusRequest(this.field, this.serial);

  final RegisterField field;
  final int serial;
}

/// The sign-up screen (pano 2.5 and 2.6; spec §4.A "2.5–2.6").
///
/// Holds the form's values and what the rules and the server say about them;
/// the text controllers and focus nodes stay in the view. A field shows its
/// issue after it lost focus with something in it, or after "Kayıt Ol" was
/// pressed, and then keeps it live while the person types; a taken user name
/// shows at once.
///
/// **Submit.** Validates; on issues, focus goes to the first one
/// ([focusRequest]). Otherwise `register`; the account is made, the same
/// credentials sign in (`SessionManager.signIn`, the legacy behaviour of the
/// router bridge) and the router's guards move the signed-in person to the
/// shell. A "user name in use" answer becomes the field error with a free
/// suggestion; every other failure is a [RegisterNotice] above the button.
class RegisterViewModel extends BaseViewModel {
  RegisterViewModel({
    required RegisterNavigator navigator,
    required UsernameChecker checkUsername,
    required LegalDocumentsLoader loadLegalDocuments,
    required RegisterSubmit register,
    required RegisterSignIn signIn,
    required Future<void> Function() clearOnboardingDraft,
    required LegalTextOpener openLegalText,
    UserRole? role,
    SchoolGrade? grade,
    StudyTrack? track,
    Duration usernameDebounce = kUsernameDebounce,
  }) : _navigator = navigator,
       _loadLegalDocuments = loadLegalDocuments,
       _register = register,
       _signIn = signIn,
       _clearDraft = clearOnboardingDraft,
       _openLegalText = openLegalText,
       _role = role == UserRole.coach ? UserRole.coach : UserRole.student,
       _grade = grade,
       _track = RegisterRules.trackFor(grade, track) {
    _check = UsernameLiveCheck(
      checker: checkUsername,
      onChanged: _notify,
      debounce: usernameDebounce,
    );
  }

  /// The seven avatars in the order the picker shows them (`assets/avatars`);
  /// the file name is what `photo` carries.
  static const List<String> avatarFiles = [
    '1avatarN3.png',
    '3avatarN3.png',
    '4avatarN3.png',
    '5avatarN3.png',
    '6avatarN3.png',
    '8avatarN3.png',
    '9avatarN3.png',
  ];

  final RegisterNavigator _navigator;
  final LegalDocumentsLoader _loadLegalDocuments;
  final RegisterSubmit _register;
  final RegisterSignIn _signIn;
  final Future<void> Function() _clearDraft;
  final LegalTextOpener _openLegalText;
  late final UsernameLiveCheck _check;

  /// Focus and scroll requests for the view.
  final ValueNotifier<RegisterFocusRequest?> focusRequest =
      ValueNotifier<RegisterFocusRequest?>(null);
  int _focusSerial = 0;

  UserRole _role;
  int _avatar = 0;
  String _fullName = '';
  String _username = '';
  String _email = '';
  String _password = '';
  String _passwordRepeat = '';
  SchoolGrade? _grade;
  StudyTrack? _track;
  bool _consent = false;
  final Set<RegisterField> _shown = {};

  AsyncSection<RegisterLegalTexts> _legal =
      const AsyncSection<RegisterLegalTexts>.loading();
  bool _submitting = false;
  RegisterNotice? _notice;
  bool _accountCreated = false;
  bool _disposed = false;

  // ── Values the sections select on ────────────────────────────────────

  UserRole get role => _role;
  int get avatarIndex => _avatar;
  SchoolGrade? get grade => _grade;
  StudyTrack? get track => _track;
  bool get consent => _consent;
  AsyncSection<RegisterLegalTexts> get legal => _legal;
  bool get submitting => _submitting;
  RegisterNotice? get notice => _notice;
  UsernameCheckState get usernameCheck => _check.state;

  /// Whether "Kayıt Ol" can be pressed: the legal texts are there.
  bool get canSubmit => _legal.isReady && !_submitting;

  RegisterFormValues get _values => RegisterFormValues(
    role: _role,
    fullName: _fullName,
    username: _username,
    email: _email,
    password: _password,
    passwordRepeat: _passwordRepeat,
    grade: _grade,
    track: _track,
    consent: _consent,
    usernameStatus: _check.state.status,
  );

  /// The issue [field] shows right now, `null` when none (yet).
  RegisterIssue? issueFor(RegisterField field) {
    final issue = RegisterRules.issueOf(field, _values);
    if (issue == null) return null;
    if (issue == RegisterIssue.usernameTaken) return issue;
    return _shown.contains(field) ? issue : null;
  }

  // ── Loading ──────────────────────────────────────────────────────────

  /// Loads the legal texts; "Tekrar Dene" calls it again.
  Future<void> loadLegal() async {
    _legal = const AsyncSection<RegisterLegalTexts>.loading();
    _notify();
    final loaded = await AsyncSection.load<RegisterLegalTexts>(() async {
      final documents = (await _loadLegalDocuments()).fold(
        (failure) => throw failure,
        (documents) => documents,
      );
      final texts = RegisterLegalTexts.pick(documents);
      if (texts == null) throw StateError('legal texts missing');
      return texts;
    });
    _legal = loaded;
    _notify();
  }

  // ── Edits ────────────────────────────────────────────────────────────

  void setRole(UserRole role) {
    if (role == _role || !role.isKnown) return;
    _role = role;
    _notice = null;
    _notify();
  }

  void setAvatar(int index) {
    if (index == _avatar || index < 0 || index >= avatarFiles.length) return;
    _avatar = index;
    _notify();
  }

  void onFullName(String value) {
    _fullName = value;
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

  void onEmail(String value) {
    _email = value;
    _notify();
  }

  void onPassword(String value) {
    _password = value;
    _notify();
  }

  void onPasswordRepeat(String value) {
    _passwordRepeat = value;
    _notify();
  }

  void setGrade(SchoolGrade grade) {
    _grade = grade;
    _track = RegisterRules.trackFor(grade, _track);
    _notify();
  }

  void setTrack(StudyTrack track) {
    _track = track;
    _notify();
  }

  void setConsent(bool value) {
    _consent = value;
    _notify();
  }

  /// A field lost focus: a value that is wrong starts showing its issue.
  void blur(RegisterField field) {
    final hasValue = switch (field) {
      RegisterField.fullName => _fullName.trim().isNotEmpty,
      RegisterField.username => false,
      RegisterField.email => _email.trim().isNotEmpty,
      RegisterField.password => _password.isNotEmpty,
      RegisterField.passwordRepeat => _passwordRepeat.isNotEmpty,
      RegisterField.grade ||
      RegisterField.track ||
      RegisterField.consent => false,
    };
    if (hasValue && _shown.add(field)) _notify();
  }

  // ── Actions ──────────────────────────────────────────────────────────

  /// Opens the text behind a consent link in a reading sheet.
  Future<void> openLegal(ConsentLink link) async {
    final texts = _legal.data;
    if (texts == null) return;
    await _openLegalText(link == ConsentLink.terms ? texts.terms : texts.kvkk);
  }

  void openLogin() => _navigator.openLogin();

  /// "Kayıt Ol".
  Future<void> submit() async {
    if (_submitting || !_legal.isReady) return;
    if (_accountCreated) {
      await _signInAfterRegister();
      return;
    }
    _notice = null;
    _shown.addAll(RegisterField.values);
    await _check.settle(_username, fullName: _fullName);
    final issues = RegisterRules.validate(_values);
    if (issues.isNotEmpty) {
      // The field frames play the error haptic themselves; the consent row
      // has no frame, so a failed consent alone plays it here.
      if (issues.keys.every((f) => f == RegisterField.consent)) {
        AppHaptics.error();
      }
      _focusSerial++;
      focusRequest.value = RegisterFocusRequest(
        issues.keys.first,
        _focusSerial,
      );
      _notify();
      return;
    }

    _submitting = true;
    _notify();
    final result = await _register(_registration());
    if (_disposed) return;
    final outcome = result.rightOrNull;
    if (outcome == null) {
      _notice = RegisterNotice.failed(result.leftOrNull!);
      _finishSubmit();
      return;
    }
    if (outcome == RegisterOutcome.userNameTaken) {
      _check.markTaken(_username, fullName: _fullName);
      AppHaptics.error();
      _focusSerial++;
      focusRequest.value = RegisterFocusRequest(
        RegisterField.username,
        _focusSerial,
      );
      _finishSubmit();
      return;
    }
    AppHaptics.success();
    _accountCreated = true;
    await _clearDraft();
    await _signInAfterRegister();
  }

  Future<void> _signInAfterRegister() async {
    _submitting = true;
    _notice = null;
    _notify();
    final signedIn = await _signIn(username: _username, password: _password);
    if (_disposed) return;
    if (signedIn.isLeft()) _notice = const RegisterNotice.signInFailed();
    // Signed in: the router's guards take the person to the shell.
    _finishSubmit();
  }

  void _finishSubmit() {
    _submitting = false;
    _notify();
  }

  NewRegistration _registration() {
    final texts = _legal.data;
    final isStudent = _role == UserRole.student;
    return NewRegistration(
      role: _role,
      fullName: _fullName.trim(),
      userName: _username,
      email: _email.trim(),
      password: _password,
      passwordRepeat: _passwordRepeat,
      photo: avatarFiles[_avatar],
      grade: isStudent ? _grade : null,
      track: isStudent ? RegisterRules.trackFor(_grade, _track) : null,
      acceptedTermsVersion: texts?.terms.version,
      acceptedKvkkVersion: texts?.kvkk.version,
      acceptedPrivacyVersion: texts?.privacy?.version,
    );
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
