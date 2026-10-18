import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:smap/core/domain/user_role.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/features/account/application/legal_entries.dart';
import 'package:smap/features/account/data/account_repository.dart';
import 'package:smap/features/account/presentation/account_dialogs.dart';
import 'package:smap/features/account/presentation/account_navigator.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';
import 'package:smap/l10n/app_localizations_tr.dart';
import 'package:smap/services/current_user_service.dart';
import 'package:smap/services/session_manager.dart';
import 'package:smap/shared/ui/feedback/toast_host.dart';
import 'package:smap/shared/ui/feedback/toast_slot.dart';
import 'package:stacked/stacked.dart';

import '../../../core/network/fake_adapter.dart';
import '../../schedule/network_harness.dart';

/// The student of the design's Hesap and Profil boards (pano 9.1, 9.2).
UserDto alparslan({
  String name = 'Alparslan Kuloğlu',
  String? email = 'alparslan@ornek.com',
  String? phone = '05321234567',
  int? seasonType = 12,
  int? aimType = 2,
  String? photo = '1avatarN3.png',
}) => UserDto(
  id: 'student-1',
  name: name,
  userName: 'alparslan.k',
  email: email,
  phone: phone,
  role: 'student',
  seasonType: seasonType,
  aimType: aimType,
  photo: photo,
);

/// The coach of the design's coach Hesap board (pano 9.1 kare 4).
UserDto mehmetOzkan() => const UserDto(
  id: 'coach-1',
  name: 'Mehmet Özkan',
  userName: 'mehmet.ozkan',
  email: 'mehmet@ornek.com',
  role: 'coach',
  refCode: 'MOZK-4821',
  photo: '4avatarN3.png',
);

/// The session's account, reactive like `CurrentUserService`; the reload
/// ([refresh]) answers what the test scripts.
class FakeUserService
    with ListenableServiceMixin
    implements CurrentUserService {
  FakeUserService(this._user);

  UserDto? _user;

  /// What `refresh` answers; a failure when `null`.
  UserDto? refreshAnswer;

  /// When set, `refresh` waits for it.
  Future<void>? refreshGate;
  int refreshCalls = 0;
  final List<UserDto> updates = [];

  void set(UserDto? user) {
    _user = user;
    notifyListeners();
  }

  @override
  UserDto? get user => _user;

  @override
  UserRole get role => _user?.userRole ?? UserRole.unknown;

  @override
  bool get isStudent => role.isStudent;

  @override
  bool get isCoach => role.isCoach;

  @override
  Future<AppResult<UserDto>> refresh() async {
    refreshCalls++;
    await refreshGate;
    final answer = refreshAnswer;
    if (answer == null) {
      return const Left(AppException(code: AppErrorCode.network));
    }
    _user = answer;
    notifyListeners();
    return Right(answer);
  }

  @override
  Future<void> update(UserDto user) async {
    updates.add(user);
    _user = user;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The session manager, only for "Çıkış Yap".
class FakeSession implements SessionManager {
  int signOuts = 0;
  Completer<void>? gate;

  @override
  Future<void> signOut() async {
    signOuts++;
    await gate?.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Records where the screens lead; [available] are the E14b destinations the
/// "router" has.
class RecordingNavigator implements AccountNavigator {
  RecordingNavigator({Set<AccountDestination>? available})
    : available = available ?? AccountDestination.values.toSet();

  final Set<AccountDestination> available;
  final List<String> calls = [];

  /// Runs when a destination opens, to play what happens while its screen is
  /// up (the coach link changes in "Koçluk").
  FutureOr<void> Function(AccountDestination destination)? whileOpen;

  @override
  bool canOpen(AccountDestination destination) =>
      available.contains(destination);

  @override
  Future<void> open(AccountDestination destination) async {
    if (!canOpen(destination)) return;
    calls.add('open:${destination.name}');
    await whileOpen?.call(destination);
  }

  @override
  Future<void> openProfile() async => calls.add('profile');

  @override
  Future<void> openContracts() async => calls.add('contracts');

  @override
  Future<void> openContract(LegalEntry entry) async =>
      calls.add('contract:${entry.key}');
}

/// The answers of the sheets, scripted per test.
class ScriptedDialogs implements AccountDialogs {
  bool logout = true;
  bool discard = true;
  int? avatar;
  final List<String> calls = [];

  @override
  Future<bool> confirmLogout({int pendingForms = 0}) async {
    calls.add('logout:$pendingForms');
    return logout;
  }

  @override
  Future<bool> confirmDiscardEdits() async {
    calls.add('discard');
    return discard;
  }

  @override
  Future<int?> pickAvatar({int? selectedIndex}) async {
    calls.add('avatar:$selectedIndex');
    return avatar;
  }

  @override
  Future<void> showCoachCode() async => calls.add('coachCode');
}

class _Presenter implements ToastPresenter {
  @override
  bool screenReaderOn = false;

  @override
  bool present(ToastSlot slot, ValueListenable<double?> barHeight) => true;
}

/// A toast service that records into its slot instead of drawing.
ToastService recordingToast() => ToastService(presenter: _Presenter());

/// The words of the toast on screen, `null` when none.
String? toastText(ToastService toast) =>
    toast.slot.current.value?.title(AppLocalizationsTr());

/// The kind of the toast on screen.
AppToastKind? toastKind(ToastService toast) => toast.slot.current.value?.kind;

/// The account endpoints, scripted per test; each can be told to fail.
class AccountBackend {
  Map<String, Object?>? coach;
  bool coachFails = false;
  bool coachOffline = false;
  Completer<void>? coachGate;

  Map<String, Object?>? updateAnswer = {'success': true};
  int updateStatus = 200;
  bool updateOffline = false;

  List<Object?> legalDocuments = [];
  int legalStatus = 200;
  bool legalOffline = false;
  Completer<void>? legalGate;

  final List<String> paths = [];

  late final FakeAdapter adapter = FakeAdapter((options) async {
    paths.add(options.path);
    switch (options.path) {
      case '/student/getStudentsCoach':
        await coachGate?.future;
        if (coachOffline) throw _offline(options);
        if (coachFails) return jsonResponse({'success': false}, status: 500);
        return jsonResponse({'success': true, 'coach': ?coach});
      case '/student/updateStudent':
        if (updateOffline) throw _offline(options);
        return jsonResponse(updateAnswer, status: updateStatus);
      case '/ajax/getLegalDocuments':
        await legalGate?.future;
        if (legalOffline) throw _offline(options);
        return jsonResponse(legalDocuments, status: legalStatus);
    }
    return jsonResponse({'error': 'no route'}, status: 404);
  });

  DioException _offline(RequestOptions options) => DioException.connectionError(
    requestOptions: options,
    reason: 'offline',
    error: const SocketException('Failed host lookup'),
  );

  late final NetworkService network = buildNetwork(adapter);
  late final AccountRepository repository = AccountRepository(network);

  /// The body of the last `updateStudent`.
  Object? get lastUpdateBody => adapter.requests
      .lastWhere((r) => r.path == '/student/updateStudent')
      .data;

  int count(String path) => paths.where((p) => p == path).length;

  void dispose() => network.dispose();
}

/// A legal document as the server writes it.
Map<String, Object?> legalJson(
  String id,
  String name, {
  String? title,
  String? version,
  String? content,
  bool? isActive,
}) => {
  '_id': id,
  'name': name,
  'title': ?title,
  'version': ?version,
  'content': ?content,
  'isActive': ?isActive,
};

/// The student's coach as `getStudentsCoach` writes it.
Map<String, Object?> coachJson() => {
  '_id': 'coach-1',
  'name': 'Mehmet Özkan',
  'role': 'coach',
  'refCode': 'MOZK-4821',
  'photo': '4avatarN3.png',
};
