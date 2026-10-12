import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/features/scan/application/exam_request_form.dart';
import 'package:smap/features/scan/domain/optic_reading.dart';
import 'package:smap/features/scan/presentation/exam_request/scan_request_dialogs.dart';
import 'package:smap/features/scan/presentation/exam_request/scan_request_viewmodel.dart';
import 'package:smap/l10n/app_localizations_tr.dart';
import 'package:smap/shared/ui/feedback/toast_host.dart';
import 'package:smap/shared/ui/feedback/toast_slot.dart';

import '../scan_fakes.dart';
import '../scan_fixtures.dart';

class _Presenter implements ToastPresenter {
  @override
  bool screenReaderOn = false;

  @override
  bool present(ToastSlot slot, ValueListenable<double?> barHeight) => true;
}

class _Dialogs implements ScanRequestDialogs {
  bool answer = true;
  final List<({String publisher, String examName})> asked = [];

  @override
  Future<bool> confirmRequest({
    required String publisher,
    required String examName,
  }) async {
    asked.add((publisher: publisher, examName: examName));
    return answer;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final l10n = AppLocalizationsTr();
  late FakeScanRepository repository;
  late _Dialogs dialogs;
  late RecordingActions actions;
  late ToastService toast;
  late ScanRequestViewModel vm;

  setUp(() {
    repository = FakeScanRepository();
    dialogs = _Dialogs();
    actions = RecordingActions();
    toast = ToastService(presenter: _Presenter());
    vm = ScanRequestViewModel(
      reading: sampleReading(),
      reply: AnswerReply.fromJson(sampleAnswerJson(found: false)),
      repository: repository,
      user: () => const {'_id': 'u1'},
      dialogs: dialogs,
      actions: actions,
      toast: toast,
    );
  });

  tearDown(() {
    vm.dispose();
    toast.dispose();
  });

  void fill() {
    vm
      ..publisherChanged('Örnek Yayınları')
      ..examNameChanged('Türkiye Geneli Deneme 7');
  }

  group('the form (pano 4.9 kare 1 and 2)', () {
    test('shows no error before the first submit', () {
      expect(vm.publisherError, isNull);
      expect(vm.examNameError, isNull);
      expect(vm.phase, RequestPhase.form);
    });

    test(
      'submitting empty shows both errors and asks for the first field',
      () async {
        ExamRequestError? asked;
        vm.focusRequest.addListener(() => asked = vm.focusRequest.value);
        await vm.submit();
        expect(vm.publisherError, ExamRequestError.publisherRequired);
        expect(vm.examNameError, ExamRequestError.examNameRequired);
        expect(asked, ExamRequestError.publisherRequired);
        expect(dialogs.asked, isEmpty);
        expect(repository.requests, isEmpty);
      },
    );

    test(
      'with only the publisher filled, the exam name gets the focus',
      () async {
        vm.publisherChanged('Örnek Yayınları');
        ExamRequestError? asked;
        vm.focusRequest.addListener(() => asked = vm.focusRequest.value);
        await vm.submit();
        expect(vm.publisherError, isNull);
        expect(asked, ExamRequestError.examNameRequired);
      },
    );

    test('after the first submit the errors follow what is typed', () async {
      await vm.submit();
      vm.publisherChanged('Ö');
      expect(vm.publisherError, isNull);
      expect(vm.examNameError, ExamRequestError.examNameRequired);
    });
  });

  group('sending (pano 4.9 kare 3 and 4)', () {
    test('asks the confirmation with what was written, trimmed', () async {
      dialogs.answer = false;
      vm
        ..publisherChanged('  Örnek Yayınları ')
        ..examNameChanged('Türkiye Geneli Deneme 7');
      await vm.submit();
      expect(dialogs.asked.single.publisher, 'Örnek Yayınları');
      expect(dialogs.asked.single.examName, 'Türkiye Geneli Deneme 7');
      expect(repository.requests, isEmpty);
      expect(vm.phase, RequestPhase.form);
    });

    test(
      '"Talebi Gönder" sends the request with the user and shows "Talebin alındı"',
      () async {
        fill();
        await vm.submit();
        expect(repository.requests.single.publisher, 'Örnek Yayınları');
        expect(repository.requests.single.examName, 'Türkiye Geneli Deneme 7');
        expect(repository.users.single, {'_id': 'u1'});
        expect(vm.phase, RequestPhase.sent);
        expect(vm.sending, isFalse);
      },
    );

    test('is busy while it sends', () async {
      final gate = Completer<void>();
      repository.requestGate = gate.future;
      fill();
      final run = vm.submit();
      await Future<void>.delayed(Duration.zero);
      expect(vm.sending, isTrue);
      gate.complete();
      await run;
      expect(vm.sending, isFalse);
    });

    test('a failure keeps the form and tells why in a toast', () async {
      repository.request = Left(exception(AppErrorCode.offline));
      fill();
      await vm.submit();
      expect(vm.phase, RequestPhase.form);
      expect(vm.sending, isFalse);
      expect(toast.slot.current.value!.title(l10n), l10n.errors_offline);
    });

    test('a second press while it sends does nothing', () async {
      fill();
      final first = vm.submit();
      await vm.submit();
      await first;
      expect(repository.requests, hasLength(1));
    });
  });

  test('Anasayfa and Kapat leave through the flow', () {
    vm.goHome();
    vm.close();
    expect(actions.calls, ['goHome', 'close']);
  });
}
