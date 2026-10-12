import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/features/account/data/account_repository.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';
import 'package:smap/l10n/app_localizations_tr.dart';
import 'package:smap/services/current_user_service.dart';
import 'package:smap/shared/ui/feedback/toast_host.dart';
import 'package:smap/shared/ui/feedback/toast_slot.dart';
import 'package:stacked/stacked.dart';

/// Shared fakes of the E14b view model tests (Şifre, Hesabı Sil, Koçluk,
/// Bildirimler). Values follow the boards and Ek C: Alparslan Kuloğlu, 12.
/// sınıf, Eşit Ağırlık, 10 exams; coach Mehmet Özkan, `MOZK-4821`.

const AppException offline = AppException(code: AppErrorCode.offline);
const AppException timeout = AppException(code: AppErrorCode.timeout);
const AppException refused = AppException(
  code: AppErrorCode.validation,
  statusCode: 400,
);

/// Alparslan Kuloğlu, a student with a coach (6 TYT + 4 AYT = 10 exams).
const UserDto alparslan = UserDto(
  id: 'student-1',
  name: 'Alparslan Kuloğlu',
  role: 'student',
  seasonType: 12,
  aimType: 2,
  coach: 'coach-1',
  totalMexam: 10,
);

/// The same student without a coach.
const UserDto alparslanNoCoach = UserDto(
  id: 'student-1',
  name: 'Alparslan Kuloğlu',
  role: 'student',
  seasonType: 12,
  aimType: 2,
  totalMexam: 10,
);

const UserDto mehmet = UserDto(
  id: 'coach-1',
  name: 'Mehmet Özkan',
  role: 'coach',
  refCode: 'MOZK-4821',
  photo: 'avatars/2avatarN3.png',
);

const UserDto ayse = UserDto(
  id: 'coach-2',
  name: 'Ayşe Demir',
  role: 'coach',
  refCode: 'ADEM-1907',
  photo: 'avatars/4avatarN3.png',
);

/// The account endpoints, answering what the test tells them to.
class FakeAccountRepository implements AccountRepository {
  AppResult<UserDto?> myCoach = const Right(null);
  AppResult<UserDto> addResult = const Right(ayse);
  AppResult<Unit> removeResult = const Right(unit);
  AppResult<Unit> deleteResult = const Right(unit);

  /// When set, the call waits for it.
  Future<void>? myCoachGate;
  Future<void>? deleteGate;

  int myCoachCalls = 0;
  final List<String> added = [];
  final List<String> removed = [];
  int deleteCalls = 0;

  @override
  Future<AppResult<UserDto?>> getMyCoach() async {
    myCoachCalls++;
    await myCoachGate;
    return myCoach;
  }

  @override
  Future<AppResult<UserDto>> addCoach(String refCode) async {
    added.add(refCode);
    return addResult;
  }

  @override
  Future<AppResult<Unit>> removeCoach(String coachId) async {
    removed.add(coachId);
    return removeResult;
  }

  @override
  Future<AppResult<Unit>> deleteAccount() async {
    deleteCalls++;
    await deleteGate;
    return deleteResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The signed-in user the screens read.
class FakeUserService
    with ListenableServiceMixin
    implements CurrentUserService {
  FakeUserService(this._user);

  UserDto? _user;
  int refreshes = 0;

  void set(UserDto? user) {
    _user = user;
    notifyListeners();
  }

  @override
  UserDto? get user => _user;

  @override
  bool get isCoach => _user?.role == 'coach';

  @override
  bool get isStudent => !isCoach;

  @override
  Future<AppResult<UserDto>> refresh() async {
    refreshes++;
    final user = _user;
    return user == null ? const Left(offline) : Right(user);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeToastPresenter implements ToastPresenter {
  @override
  bool screenReaderOn = false;

  @override
  bool present(ToastSlot slot, ValueListenable<double?> barHeight) => true;
}

/// A toast service whose current text can be read back in Turkish.
class ToastProbe {
  ToastProbe() : service = ToastService(presenter: FakeToastPresenter());

  final ToastService service;
  final AppLocalizationsTr l10n = AppLocalizationsTr();

  /// The toast on screen, or `null`.
  String? get text => service.slot.current.value?.title(l10n);

  /// Whether the toast on screen is an error.
  bool get isError => service.slot.current.value?.kind == AppToastKind.error;

  void dispose() => service.dispose();
}
