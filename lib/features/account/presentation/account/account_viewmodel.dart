import 'dart:async';
import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/features/account/application/account_header.dart';
import 'package:smap/features/account/application/app_version.dart';
import 'package:smap/features/account/application/support_mail.dart';
import 'package:smap/features/account/data/account_repository.dart';
import 'package:smap/features/account/presentation/account_dialogs.dart';
import 'package:smap/features/account/presentation/account_navigator.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/services/current_user_service.dart';
import 'package:smap/services/session_manager.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

/// Opens a link outside the app (`url_launcher`); `false` when it could not.
typedef UrlOpener = Future<bool> Function(Uri uri);

/// Puts text on the clipboard.
typedef ClipboardWriter = Future<void> Function(String text);

/// Opens the system share sheet with [text]; [origin] is the rectangle of the
/// button that asked (an iPad anchors its popover there).
typedef TextSharer = Future<void> Function(String text, {Rect? origin});

/// What the "Koçluk" row and the groups of Hesap draw, an immutable value the
/// menu's selector compares (pano 9.1 kare 1, 2 and 4).
@immutable
class AccountMenuData {
  const AccountMenuData({
    required this.isCoach,
    required this.link,
    required this.coachName,
    required this.coachCode,
    required this.canOpenPassword,
    required this.canOpenCoaching,
    required this.canOpenNotifications,
    required this.hasSupport,
  });

  /// Coach side: the "Koçluk kodun" row instead of the "Koçluk" one.
  final bool isCoach;

  /// Student: whether the coach is known.
  final CoachLinkState link;

  /// Student: the coach's name when [link] is linked.
  final String? coachName;

  /// Coach: the code, as written.
  final String? coachCode;

  /// The E14b screens are in the router (see `AccountNavigator.canOpen`).
  final bool canOpenPassword;
  final bool canOpenCoaching;
  final bool canOpenNotifications;

  /// A support address is configured ("Bize Yaz").
  final bool hasSupport;

  @override
  bool operator ==(Object other) =>
      other is AccountMenuData &&
      other.isCoach == isCoach &&
      other.link == link &&
      other.coachName == coachName &&
      other.coachCode == coachCode &&
      other.canOpenPassword == canOpenPassword &&
      other.canOpenCoaching == canOpenCoaching &&
      other.canOpenNotifications == canOpenNotifications &&
      other.hasSupport == hasSupport;

  @override
  int get hashCode => Object.hash(
    isCoach,
    link,
    coachName,
    coachCode,
    canOpenPassword,
    canOpenCoaching,
    canOpenNotifications,
    hasSupport,
  );
}

/// The logic of Hesap, the root of the account tab (pano 9.1; spec §4.H 9.1;
/// flow 13.10; routes `/account` and `/coach/account`).
///
/// - The band and the groups read the signed-in account from
///   `CurrentUserService`: it is on the device, so there is no skeleton and
///   no error (the design draws none); a profile saved elsewhere changes the
///   band at once.
/// - A student's coach name comes from `getStudentsCoach`. Until it answers,
///   and when it fails, nothing about the coach is drawn; it is asked again
///   when the student comes back from "Koçluk".
/// - "Çıkış Yap" asks first (a normal, navy confirmation) and then ends the
///   session; the router takes the person to the welcome screen by itself.
/// - A coach's code is copied ("Kod kopyalandı.") or shared.
/// - "Bize Yaz" opens a mail draft with the version and the system; without a
///   configured address the row is not drawn.
///
/// The screens of E14b are reached through [AccountNavigator]; a destination
/// that is not in the router is not drawn.
class AccountViewModel extends ReactiveViewModel {
  AccountViewModel({
    required CurrentUserService currentUser,
    required AccountRepository accounts,
    required SessionManager session,
    required AccountNavigator navigator,
    required AccountDialogs dialogs,
    required ToastService toast,
    required AppConfig config,
    required Future<AppVersion?> Function() readVersion,
    required String Function() systemLabel,
    required UrlOpener openUrl,
    required ClipboardWriter copyText,
    required TextSharer shareText,
    int Function() pendingForms = _noPendingForms,
    Duration timeout = SmapDurations.skeletonTimeout,
  }) : _currentUser = currentUser,
       _accounts = accounts,
       _session = session,
       _navigator = navigator,
       _dialogs = dialogs,
       _toast = toast,
       _supportAddress = config.supportEmail,
       _readVersion = readVersion,
       _systemLabel = systemLabel,
       _openUrl = openUrl,
       _copyText = copyText,
       _shareText = shareText,
       _pendingForms = pendingForms,
       _timeout = timeout;

  /// There is no local send queue in this version (spec 9.1: "v1 kuyruk yok
  /// → 0").
  static int _noPendingForms() => 0;

  final CurrentUserService _currentUser;
  final AccountRepository _accounts;
  final SessionManager _session;
  final AccountNavigator _navigator;
  final AccountDialogs _dialogs;
  final ToastService _toast;
  final String? _supportAddress;
  final Future<AppVersion?> Function() _readVersion;
  final String Function() _systemLabel;
  final UrlOpener _openUrl;
  final ClipboardWriter _copyText;
  final TextSharer _shareText;
  final int Function() _pendingForms;
  final Duration _timeout;

  CoachLinkState _link = CoachLinkState.unknown;
  String? _coachName;
  AppVersion? _version;
  bool _started = false;
  bool _signingOut = false;
  bool _disposed = false;
  AccountHeader? _header;
  AccountMenuData? _menu;

  @override
  List<ListenableServiceMixin> get listenableServices => [_currentUser];

  /// The summary of the band; `null` without an account.
  AccountHeader? get header {
    if (_header != null) return _header;
    final user = _currentUser.user;
    return _header = user == null
        ? null
        : AccountHeader.of(user, coachName: _coachName);
  }

  /// What the groups draw.
  AccountMenuData get menu {
    final cached = _menu;
    if (cached != null) return cached;
    final head = header;
    return _menu = AccountMenuData(
      isCoach: _currentUser.isCoach,
      link: _link,
      coachName: _coachName,
      coachCode: head?.coachCode,
      canOpenPassword: _navigator.canOpen(AccountDestination.password),
      canOpenCoaching: _navigator.canOpen(AccountDestination.coaching),
      canOpenNotifications: _navigator.canOpen(
        AccountDestination.notifications,
      ),
      hasSupport: _supportAddress != null,
    );
  }

  /// The installed version, `null` until it is read (or when the platform
  /// gives none).
  AppVersion? get version => _version;

  @override
  void notifyListeners() {
    _header = null;
    _menu = null;
    super.notifyListeners();
  }

  /// Reads the version and, for a student, the coach; the view calls it once.
  Future<void> init() async {
    if (_started) return;
    _started = true;
    await Future.wait([_loadVersion(), _loadCoach()]);
  }

  Future<void> _loadVersion() async {
    try {
      _version = await _readVersion();
    } on Object {
      _version = null;
    }
    if (!_disposed) notifyListeners();
  }

  Future<void> _loadCoach() async {
    if (!_currentUser.isStudent) return;
    try {
      final result = await withSkeletonTimeout(
        _accounts.getMyCoach(),
        timeout: _timeout,
      );
      // A failed call changes nothing: the last known coach stays, or
      // nothing is drawn about the coach.
      result.fold((_) {}, (coach) {
        final name = coach?.displayName?.trim();
        _link = coach == null ? CoachLinkState.none : CoachLinkState.linked;
        _coachName = coach == null || name == null || name.isEmpty
            ? null
            : name;
      });
    } on Object {
      // Timeout or an unexpected failure: same as a failed call.
    }
    if (!_disposed) notifyListeners();
  }

  // ── Navigation ────────────────────────────────────────────────────────

  /// The profile summary and the "Profil" row.
  Future<void> openProfile() => _navigator.openProfile();

  Future<void> openPassword() => _navigator.open(AccountDestination.password);

  /// "Koçluk": the student's coach screen; the coach is asked again when it
  /// closes (it may have been added or removed there).
  Future<void> openCoaching() async {
    await _navigator.open(AccountDestination.coaching);
    if (!_disposed) await _loadCoach();
  }

  Future<void> openNotifications() =>
      _navigator.open(AccountDestination.notifications);

  Future<void> openContracts() => _navigator.openContracts();

  // ── Actions ───────────────────────────────────────────────────────────

  /// "Çıkış Yap": the confirmation, then the end of the session. A second
  /// press while it runs does nothing.
  Future<void> logout() async {
    if (_signingOut) return;
    final confirmed = await _dialogs.confirmLogout(
      pendingForms: _pendingForms(),
    );
    if (!confirmed || _signingOut) return;
    _signingOut = true;
    try {
      await _session.signOut();
    } finally {
      _signingOut = false;
    }
  }

  /// The coach's code to the clipboard, with "Kod kopyalandı.".
  Future<void> copyCode() async {
    final code = header?.coachCode;
    if (code == null) return;
    await _copyText(code);
    _toast.success((l) => l.account_coachCodeCopied);
  }

  /// The coach's code to the system share sheet; [origin] is the share
  /// button's rectangle.
  Future<void> shareCode(AppLocalizations l10n, {Rect? origin}) async {
    final code = header?.coachCode;
    if (code == null) return;
    await _shareText(l10n.account_coachCodeShareText(code), origin: origin);
  }

  /// A long press on the version line copies it, for a support request.
  Future<void> copyVersion() async {
    final version = _version;
    if (version == null) return;
    await _copyText(version.plain);
    _toast.info((l) => l.account_versionCopied);
  }

  /// "Bize Yaz": a mail draft to the support address with the app version and
  /// the system. Does nothing without an address; a failed open is a toast.
  Future<void> writeSupport(AppLocalizations l10n) async {
    final address = _supportAddress;
    if (address == null) return;
    final version = _version;
    final uri = SupportMail.compose(
      address: address,
      subject: l10n.account_supportMailSubject,
      details: [
        if (version != null) l10n.account_supportMailVersion(version.plain),
        l10n.account_supportMailSystem(_systemLabel()),
      ],
    );
    var opened = false;
    try {
      opened = await _openUrl(uri);
    } on Object {
      opened = false;
    }
    if (!opened && !_disposed) {
      _toast.error((l) => l.account_supportMailFailed);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
