import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/features/account/application/avatar_catalog.dart';
import 'package:smap/features/account/application/profile_draft.dart';
import 'package:smap/features/account/data/account_repository.dart';
import 'package:smap/features/account/domain/profile_update.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/account/presentation/account_dialogs.dart';
import 'package:smap/features/account/presentation/account_navigator.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';
import 'package:smap/services/current_user_service.dart';

/// The two states of the profile screen (pano 9.2 "Mod state ile değişir,
/// ayrı route değildir").
enum ProfileMode {
  /// Kare 1: read only, "Düzenle" in the bar.
  view,

  /// Kare 2: the fields are open, "Vazgeç" and "Kaydet" in the bar.
  edit,
}

/// What the bar of the profile draws: the mode and whether "Kaydet" works.
@immutable
class ProfileBarData {
  const ProfileBarData({
    required this.mode,
    required this.canSave,
    this.canEdit = true,
  });

  final ProfileMode mode;

  /// There is an account to edit ("Düzenle" is drawn).
  final bool canEdit;

  /// Something changed, the device is online and no save is running.
  final bool canSave;

  @override
  bool operator ==(Object other) =>
      other is ProfileBarData &&
      other.mode == mode &&
      other.canSave == canSave &&
      other.canEdit == canEdit;

  @override
  int get hashCode => Object.hash(mode, canSave, canEdit);
}

/// Asks the form to move the focus to the field of [issue] (pano 14.9
/// Erişilebilirlik: "odak hatalı alana gider"). [tick] makes two requests
/// for the same field different values, so the listener hears both.
@immutable
class ProfileFocusRequest {
  const ProfileFocusRequest(this.issue, this.tick);

  final ProfileIssue issue;
  final int tick;

  @override
  bool operator ==(Object other) =>
      other is ProfileFocusRequest &&
      other.issue == issue &&
      other.tick == tick;

  @override
  int get hashCode => Object.hash(issue, tick);
}

/// What the open form draws besides the text the fields keep themselves:
/// the user name, the grade and track choices and the field errors. Typing
/// changes none of it, so the form does not rebuild per keystroke.
@immutable
class ProfileEditData {
  const ProfileEditData({
    required this.userName,
    required this.hasGradeFields,
    required this.grade,
    required this.track,
    required this.issues,
  });

  /// The login name, shown locked.
  final String? userName;

  /// Student: the "Sınıf" and "Alan" fields exist (a coach has none).
  final bool hasGradeFields;
  final SchoolGrade? grade;
  final StudyTrack? track;
  final Set<ProfileIssue> issues;

  @override
  bool operator ==(Object other) =>
      other is ProfileEditData &&
      other.userName == userName &&
      other.hasGradeFields == hasGradeFields &&
      other.grade == grade &&
      other.track == track &&
      setEquals(other.issues, issues);

  @override
  int get hashCode => Object.hash(
    userName,
    hasGradeFields,
    grade,
    track,
    Object.hashAllUnordered(issues),
  );
}

/// What the read-only form draws (kare 1): the account's values, and which
/// ones exist (a field without data is not drawn).
@immutable
class ProfileViewData {
  const ProfileViewData({
    required this.draft,
    required this.userName,
    required this.hasGradeFields,
  });

  final ProfileDraft draft;
  final String? userName;
  final bool hasGradeFields;

  @override
  bool operator ==(Object other) =>
      other is ProfileViewData &&
      other.draft == draft &&
      other.userName == userName &&
      other.hasGradeFields == hasGradeFields;

  @override
  int get hashCode => Object.hash(draft, userName, hasGradeFields);
}

/// The logic of Profil (pano 9.2 kare 1 to 4; spec §4.H 9.2; flow 13.10;
/// route `/account/profile`).
///
/// - It reads and shows the account from `CurrentUserService` (on the device:
///   no skeleton). "Düzenle" opens the form as a [ProfileDraft]; "Kaydet" is
///   off until a field changed, and while the device is offline.
/// - Saving checks only the fields that changed (name, e-mail, phone), sends
///   only those (`updateStudent`), then reloads the account
///   (`CurrentUserService.refresh`) so the header of Hesap and Anasayfa show
///   the new values; if the reload fails the server's answer, or the sent
///   fields applied to the account, are used instead. A failure keeps the
///   form and says so in a toast; a success returns to the read-only view
///   with "Profilin güncellendi." (a text only: no success haptic, pano 14.9
///   kare 3).
/// - The e-mail is saved straight away, with the other fields (pano 14.9,
///   T12.19: the backend has no verification endpoint, so there is no code
///   step). It is checked on leaving the field and on "Kaydet" ("@", a domain
///   and an extension); trimmed and lower cased when sent. While a field
///   error shows, "Kaydet" is off and the focus goes to that field.
/// - "Vazgeç" (and the back gesture) with changes asks "Değişiklikler
///   kaydedilmesin mi?".
/// - The avatar is chosen in a sheet; like the other fields it is saved with
///   "Kaydet". "Avatarı Değiştir" in the read-only view opens the form first.
/// - "Hesabı Sil" opens E14b's screen; it is not drawn while the route is
///   not in the router.
class ProfileViewModel extends ReactiveViewModel {
  ProfileViewModel({
    required CurrentUserService currentUser,
    required AccountRepository accounts,
    required AccountNavigator navigator,
    required AccountDialogs dialogs,
    required ToastService toast,
    required ValueListenable<bool> online,
  }) : _currentUser = currentUser,
       _accounts = accounts,
       _navigator = navigator,
       _dialogs = dialogs,
       _toast = toast,
       _online = online {
    _online.addListener(_onOnlineChanged);
  }

  final CurrentUserService _currentUser;
  final AccountRepository _accounts;
  final AccountNavigator _navigator;
  final AccountDialogs _dialogs;
  final ToastService _toast;
  final ValueListenable<bool> _online;

  /// The account as it was when the form opened.
  ProfileDraft _start = const ProfileDraft();

  /// The form's values while it is open.
  ProfileDraft _draft = const ProfileDraft();
  ProfileMode _mode = ProfileMode.view;
  Set<ProfileIssue> _issues = const {};
  bool _saving = false;
  bool _disposed = false;
  int _focusTick = 0;

  /// The field that should take the focus (the first one with an error).
  final ValueNotifier<ProfileFocusRequest?> focusRequest =
      ValueNotifier<ProfileFocusRequest?>(null);

  @override
  List<ListenableServiceMixin> get listenableServices => [_currentUser];

  ProfileDraft _draftOfUser() {
    final user = _currentUser.user;
    return user == null ? const ProfileDraft() : ProfileDraft.fromUser(user);
  }

  /// The mode of the screen.
  ProfileMode get mode => _mode;

  /// Whether there is an account to show.
  bool get hasUser => _currentUser.user != null;

  /// The values of the account (view) or of the form (edit).
  ProfileDraft get draft => _mode == ProfileMode.edit ? _draft : original;

  /// The account's own values: live while reading, frozen at the moment the
  /// form opened while editing (a refresh underneath does not move the
  /// ground the changes are measured from).
  ProfileDraft get original =>
      _mode == ProfileMode.edit ? _start : _draftOfUser();

  /// The login name, never editable.
  String? get userName => _currentUser.user?.userName;

  /// Student side: the grade and track exist.
  bool get hasGradeFields => _currentUser.isStudent;

  /// "Hesabı Sil" is drawn only while E14b's screen is in the router.
  bool get canDeleteAccount => _navigator.canOpen(AccountDestination.deletion);

  /// The avatar file to show: the chosen one while editing.
  String? get photo => draft.photo;

  /// Whether the open form differs from the account.
  bool get hasChanges => _mode == ProfileMode.edit && _draft.hasChanges(_start);

  /// Whether "Kaydet" works: something changed, no field error is showing
  /// (pano 14.9 kare 2), the device is online and no save runs. Offline it
  /// switches on by itself when the connection returns (kare 4).
  bool get canSave =>
      hasChanges && _issues.isEmpty && _online.value && !_saving;

  /// The open form is offline: the line "Kaydetmek için bağlantı gerekiyor;
  /// girdiklerin korunuyor." shows under the title (pano 14.9 kare 4).
  bool get showOfflineNote => _mode == ProfileMode.edit && !_online.value;

  /// The bar's value.
  ProfileBarData get bar =>
      ProfileBarData(mode: _mode, canSave: canSave, canEdit: hasUser);

  /// The read-only form's value.
  ProfileViewData get viewData => ProfileViewData(
    draft: original,
    userName: userName,
    hasGradeFields: hasGradeFields,
  );

  /// The open form's value; the text fields keep their own text.
  ProfileEditData get editData => ProfileEditData(
    userName: userName,
    hasGradeFields: hasGradeFields,
    grade: _draft.grade,
    track: _draft.track,
    issues: _issues,
  );

  /// Whether leaving the screen would lose something ("Değişiklikler
  /// kaydedilmesin mi?").
  bool get hasUnsavedChanges => hasChanges;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  // ── Mode ──────────────────────────────────────────────────────────────

  /// "Düzenle": the form opens on the account's values.
  void edit() {
    if (_mode == ProfileMode.edit) return;
    _start = _draftOfUser();
    _draft = _start;
    _issues = const {};
    _mode = ProfileMode.edit;
    notifyListeners();
  }

  /// "Vazgeç": back to the read-only view; with changes it asks first.
  /// Returns whether the form was left.
  Future<bool> cancel() async {
    if (_mode != ProfileMode.edit || _saving) return false;
    if (hasChanges && !await _dialogs.confirmDiscardEdits()) return false;
    if (_disposed) return false;
    _leaveEdit();
    return true;
  }

  /// The back gesture on an open form with changes: asks, and answers
  /// whether the screen may be left.
  Future<bool> confirmLeave() async {
    if (!hasChanges) return true;
    if (_saving) return false;
    return _dialogs.confirmDiscardEdits();
  }

  void _leaveEdit() {
    _issues = const {};
    _mode = ProfileMode.view;
    notifyListeners();
  }

  // ── Form ──────────────────────────────────────────────────────────────

  void setName(String value) => _change(_draft.copyWith(name: value));

  void setEmail(String value) => _change(_draft.copyWith(email: value));

  void setPhone(String value) => _change(_draft.copyWith(phone: value));

  void setGrade(SchoolGrade value) => _change(_draft.withGrade(value));

  void setTrack(StudyTrack value) => _change(_draft.withTrack(value));

  /// Replaces the draft; a field error goes away when its field is fixed.
  /// Every selector compares its own value, so only what changed rebuilds:
  /// the bar when "Kaydet" switches on or off, the form when a choice or an
  /// error changes, never a text field while it is typed in.
  void _change(ProfileDraft next) {
    if (_mode != ProfileMode.edit || next == _draft) return;
    _draft = next;
    if (_issues.isNotEmpty) {
      // Only an error that is showing can go away while typing; a new one
      // waits for the field to be left or for "Kaydet".
      _issues = next.issuesAgainst(_start).intersection(_issues);
    }
    notifyListeners();
  }

  /// The e-mail field was left (pano 14.9 kare 2: "Denetim alandan çıkınca
  /// ya da Kaydet'e basınca"): a changed address that is not one gets its
  /// error under the field.
  void validateEmail() {
    if (_mode != ProfileMode.edit || _saving) return;
    final bad = _draft.hasEmailIssue(_start);
    if (bad == _issues.contains(ProfileIssue.emailInvalid)) return;
    _issues = {
      for (final issue in _issues)
        if (issue != ProfileIssue.emailInvalid) issue,
      if (bad) ProfileIssue.emailInvalid,
    };
    notifyListeners();
  }

  /// "Avatarı Değiştir": opens the sheet (the form first, when it was the
  /// read-only view) and takes the chosen avatar into the form.
  Future<void> changeAvatar() async {
    if (_saving) return;
    edit();
    final index = await _dialogs.pickAvatar(selectedIndex: _draft.avatarIndex);
    final file = AvatarCatalog.fileAt(index);
    if (file == null || _disposed) return;
    _change(_draft.copyWith(photo: file));
  }

  // ── Saving ────────────────────────────────────────────────────────────

  /// "Kaydet".
  Future<void> save() async {
    if (_mode != ProfileMode.edit || _saving) return;
    final update = _draft.toUpdate(_start);
    if (update == null) return;
    final issues = _draft.issuesAgainst(_start);
    if (issues.isNotEmpty) {
      // The field's error plays the error haptic itself (`AppFieldFrame`).
      _issues = issues;
      notifyListeners();
      focusRequest.value = ProfileFocusRequest(
        ProfileIssue.values.firstWhere(issues.contains),
        ++_focusTick,
      );
      return;
    }
    _saving = true;
    _issues = const {};
    notifyListeners();
    final result = await _accounts.updateProfile(update);
    if (_disposed) return;
    final failure = result.leftOrNull;
    if (failure != null) {
      _saving = false;
      _toast.error((l) => l.account_profileSaveFailed);
      notifyListeners();
      return;
    }
    await _reloadAccount(sent: update, echoed: result.rightOrNull);
    if (_disposed) return;
    _saving = false;
    _leaveEdit();
    _toast.success((l) => l.account_profileSaved, haptic: false);
  }

  /// Brings the session's account up to date after a save: the server's
  /// `checkUser` answer first, then what `updateStudent` echoed, then the
  /// sent fields applied to the account we had.
  Future<void> _reloadAccount({
    required ProfileUpdate sent,
    UserDto? echoed,
  }) async {
    final refreshed = (await _currentUser.refresh()).rightOrNull;
    if (refreshed != null) return;
    final base = echoed ?? _currentUser.user;
    if (base == null) return;
    await _currentUser.update(echoed ?? ProfileDraft.applied(base, sent));
  }

  /// "Tekrar Dene" of the unavailable state: asks the server for the
  /// account again.
  Future<void> retry() async {
    await _currentUser.refresh();
    notifyListeners();
  }

  // ── Elsewhere ─────────────────────────────────────────────────────────

  /// "Hesabı Sil": E14b's screen.
  Future<void> openDeletion() => _navigator.open(AccountDestination.deletion);

  void _onOnlineChanged() => notifyListeners();

  @override
  void dispose() {
    _disposed = true;
    _online.removeListener(_onOnlineChanged);
    focusRequest.dispose();
    super.dispose();
  }
}
