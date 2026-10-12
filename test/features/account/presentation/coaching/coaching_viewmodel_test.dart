import 'dart:async';

import 'package:dartz/dartz.dart';
// ignore: depend_on_referenced_packages
import 'package:fake_async/fake_async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/features/account/application/coaching_logic.dart';
import 'package:smap/features/account/domain/coach_code.dart';
import 'package:smap/features/account/presentation/coaching/coaching_dialogs.dart';
import 'package:smap/features/account/presentation/coaching/coaching_viewmodel.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

import '../account_settings_fakes.dart';

class _FakeDialogs implements CoachingDialogs {
  bool confirmUnlinkAnswer = true;
  final List<String> unlinkAsked = [];
  int infoShown = 0;

  /// What the change sheet does: types [changeCode] and presses the button.
  String? changeCode;
  final List<CoachLinkResult> changeResults = [];
  int changeOpened = 0;

  @override
  Future<bool> confirmUnlink({required String coachName}) async {
    unlinkAsked.add(coachName);
    return confirmUnlinkAnswer;
  }

  @override
  Future<void> showCodeInfo() async => infoShown++;

  @override
  Future<CoachLink?> changeCoach({
    required CoachLink current,
    required Future<CoachLinkResult> Function(CoachCode code) submit,
  }) async {
    changeOpened++;
    final code = changeCode;
    if (code == null) return null;
    final result = await submit(CoachCode.tryParse(code)!);
    changeResults.add(result);
    return result.coach;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAccountRepository account;
  late FakeUserService user;
  late _FakeDialogs dialogs;
  late ToastProbe toast;
  late ValueNotifier<bool> online;
  late CoachingViewModel viewModel;

  CoachingViewModel build({Duration? timeout}) => CoachingViewModel(
    account: account,
    currentUser: user,
    dialogs: dialogs,
    toast: toast.service,
    online: online,
    timeout: timeout ?? const Duration(seconds: 15),
  );

  setUp(() {
    account = FakeAccountRepository();
    user = FakeUserService(alparslan);
    dialogs = _FakeDialogs();
    toast = ToastProbe();
    online = ValueNotifier<bool>(true);
    viewModel = build();
  });

  tearDown(() {
    viewModel.dispose();
    toast.dispose();
    online.dispose();
  });

  group('load', () {
    test('starts on the skeleton', () {
      expect(viewModel.state, SectionState.loading);
    });

    test('a coach is "Koçun var" (pano 9.5 kare 1)', () async {
      account.myCoach = const Right(mehmet);
      await viewModel.init();
      expect(viewModel.state, SectionState.ready);
      expect(viewModel.coach?.name, 'Mehmet Özkan');
      expect(viewModel.coach?.id, 'coach-1');
      expect(viewModel.coach?.code, 'MOZK-4821');
    });

    test('no coach is "Koçun yok" (kare 3)', () async {
      await viewModel.init();
      expect(viewModel.state, SectionState.empty);
      expect(viewModel.coach, isNull);
    });

    test(
      'a coach the app cannot name reads as none, not an empty card',
      () async {
        account.myCoach = const Right(UserDto(id: 'coach-9'));
        await viewModel.init();
        expect(viewModel.state, SectionState.empty);
      },
    );

    test(
      'a failed call is the error state; "Tekrar Dene" loads again',
      () async {
        account.myCoach = const Left(
          AppException(code: AppErrorCode.server, statusCode: 500),
        );
        await viewModel.init();
        expect(viewModel.state, SectionState.error);

        account.myCoach = const Right(mehmet);
        final retry = viewModel.retry();
        expect(viewModel.state, SectionState.loading);
        await retry;
        expect(viewModel.state, SectionState.ready);
      },
    );

    test('no connection is the offline state', () async {
      account.myCoach = const Left(offline);
      await viewModel.init();
      expect(viewModel.state, SectionState.offline);
    });

    test('no answer in 15 s is the error state, never an endless skeleton', () {
      fakeAsync((async) {
        final vm = build();
        account.myCoachGate = Completer<void>().future;
        unawaited(vm.init());
        async.elapse(const Duration(seconds: 14));
        expect(vm.state, SectionState.loading);
        async.elapse(const Duration(seconds: 2));
        expect(vm.state, SectionState.error);
        vm.dispose();
      });
    });
  });

  group('code field', () {
    test('"Koça Bağlan" opens at four letters and four digits', () {
      expect(viewModel.codeComplete.value, isFalse);
      viewModel.codeEdited('MOZK-48');
      expect(viewModel.codeComplete.value, isFalse);
      viewModel.codeEdited('MOZK-4821');
      expect(viewModel.codeComplete.value, isTrue);
    });
  });

  group('link (Koçun yok)', () {
    setUp(() async => viewModel.init());

    test('sends the code as AAAA-0000, toasts, and shows the coach', () async {
      account.addResult = const Right(mehmet);
      await viewModel.connect('mozk4821');
      expect(account.added, ['MOZK-4821']);
      expect(viewModel.state, SectionState.ready);
      expect(viewModel.coach?.name, 'Mehmet Özkan');
      expect(toast.text, "Mehmet Özkan'a bağlandın.");
      expect(user.refreshes, 1);
      expect(viewModel.isWorking, isFalse);
    });

    test(
      'a refused code is "Bu kodla bir koç bulunamadı..." under the field',
      () async {
        account.addResult = const Left(refused);
        await viewModel.connect('ABCD-1234');
        expect(viewModel.problem, CoachCodeProblem.notFound);
        expect(viewModel.state, SectionState.empty);
        expect(toast.text, isNull);
      },
    );

    test('typing clears the problem', () async {
      account.addResult = const Left(refused);
      await viewModel.connect('ABCD-1234');
      viewModel.codeEdited('ABCD-123');
      expect(viewModel.problem, isNull);
    });

    test('a failed connection is a toast, the field keeps its code', () async {
      account.addResult = const Left(offline);
      await viewModel.connect('ABCD-1234');
      expect(viewModel.problem, isNull);
      expect(viewModel.state, SectionState.empty);
      expect(toast.text, 'Gönderilemedi. Bağlantını kontrol edip tekrar dene.');
    });

    test('an incomplete code sends nothing', () async {
      await viewModel.connect('ABCD-12');
      expect(account.added, isEmpty);
    });
  });

  group('unlink', () {
    setUp(() async {
      account.myCoach = const Right(mehmet);
      await viewModel.init();
    });

    test(
      'asks, calls deleteCoach with the coach id, toasts, shows "Koçun yok"',
      () async {
        await viewModel.unlink();
        expect(dialogs.unlinkAsked, ['Mehmet Özkan']);
        expect(account.removed, ['coach-1']);
        expect(viewModel.state, SectionState.empty);
        expect(viewModel.coach, isNull);
        expect(toast.text, 'Koç bağlantın kaldırıldı.');
        expect(user.refreshes, 1);
      },
    );

    test('"Vazgeç" changes nothing', () async {
      dialogs.confirmUnlinkAnswer = false;
      await viewModel.unlink();
      expect(account.removed, isEmpty);
      expect(viewModel.state, SectionState.ready);
    });

    test('a failure is a toast and the coach stays', () async {
      account.removeResult = const Left(offline);
      await viewModel.unlink();
      expect(viewModel.state, SectionState.ready);
      expect(viewModel.coach?.name, 'Mehmet Özkan');
      expect(toast.isError, isTrue);
    });
  });

  group('change (Tur 12 F)', () {
    setUp(() async {
      account.myCoach = const Right(mehmet);
      await viewModel.init();
    });

    test('one addCoach call, no deleteCoach; the new coach shows', () async {
      dialogs.changeCode = 'ADEM-1907';
      account.addResult = const Right(ayse);
      await viewModel.changeCoach();
      expect(account.added, ['ADEM-1907']);
      expect(account.removed, isEmpty);
      expect(viewModel.coach?.name, 'Ayşe Demir');
      expect(toast.text, "Ayşe Demir'e bağlandın.");
      expect(viewModel.isWorking, isFalse);
    });

    test('the current coach\'s own code is refused without a call', () async {
      dialogs.changeCode = 'MOZK-4821';
      await viewModel.changeCoach();
      expect(account.added, isEmpty);
      expect(dialogs.changeResults.single.failure, CoachLinkFailure.sameCoach);
      expect(viewModel.coach?.name, 'Mehmet Özkan');
    });

    test('the server answering the same coach is "zaten koçun"', () async {
      dialogs.changeCode = 'XXXX-0000';
      account.addResult = const Right(mehmet);
      await viewModel.changeCoach();
      expect(dialogs.changeResults.single.failure, CoachLinkFailure.sameCoach);
    });

    test('an unknown code is "bulunamadı" and the coach stays', () async {
      dialogs.changeCode = 'ABCD-1234';
      account.addResult = const Left(refused);
      await viewModel.changeCoach();
      expect(dialogs.changeResults.single.failure, CoachLinkFailure.notFound);
      expect(viewModel.coach?.name, 'Mehmet Özkan');
      expect(toast.text, isNull);
    });

    test('a failed connection leaves the coach alone', () async {
      dialogs.changeCode = 'ABCD-1234';
      account.addResult = const Left(timeout);
      await viewModel.changeCoach();
      expect(dialogs.changeResults.single.failure, CoachLinkFailure.failed);
      expect(viewModel.coach?.name, 'Mehmet Özkan');
    });

    test('closing the sheet without a code changes nothing', () async {
      dialogs.changeCode = null;
      await viewModel.changeCoach();
      expect(dialogs.changeOpened, 1);
      expect(account.added, isEmpty);
      expect(viewModel.isWorking, isFalse);
    });

    test('offline it does not open', () async {
      online.value = false;
      expect(viewModel.isOnline, isFalse);
      await viewModel.changeCoach();
      expect(dialogs.changeOpened, 0);
    });
  });

  test('"Koçluk Kodu Nedir?" opens the sheet', () async {
    await viewModel.showCodeInfo();
    expect(dialogs.infoShown, 1);
  });
}
