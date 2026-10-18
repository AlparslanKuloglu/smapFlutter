import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:fake_async/fake_async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/features/account/presentation/account/sheets/coach_code_viewmodel.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';
import 'package:smap/features/coach/application/coach_code_actions.dart';
import 'package:smap/l10n/app_localizations_tr.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

import '../account_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeUserService user;
  late ValueNotifier<bool> online;
  late ToastService toast;
  late List<String> copied;
  late List<(String, Rect?)> shared;
  late CoachCodeViewModel viewModel;

  const noCode = UserDto(id: 'coach-1', name: 'Mehmet Özkan', role: 'coach');

  CoachCodeViewModel build({Duration? timeout}) {
    toast = recordingToast();
    return viewModel = CoachCodeViewModel(
      currentUser: user,
      actions: CoachCodeActions(
        copyText: (text) async => copied.add(text),
        shareText: (text, {origin}) async => shared.add((text, origin)),
        toast: toast,
      ),
      online: online,
      timeout: timeout ?? const Duration(seconds: 15),
    );
  }

  setUp(() {
    user = FakeUserService(mehmetOzkan());
    online = ValueNotifier<bool>(true);
    copied = [];
    shared = [];
  });

  tearDown(() {
    viewModel.dispose();
    toast.dispose();
    online.dispose();
  });

  group('the code (pano 14.11 kare 2)', () {
    test('opens at once with the code the session brought', () async {
      build();

      expect(viewModel.state, SectionState.ready);
      expect(viewModel.code, 'MOZK-4821');
      await viewModel.init();
      expect(user.refreshCalls, 0);
    });

    test('a code of another shape is shown as the server wrote it', () {
      user = FakeUserService(
        const UserDto(id: 'c', role: 'coach', refCode: 'mozk4821'),
      );
      build();

      expect(viewModel.code, 'MOZK-4821');
    });
  });

  group('loading (kare 4)', () {
    test('without a stored code the session is asked once, under a '
        'skeleton', () async {
      user = FakeUserService(noCode)..refreshAnswer = mehmetOzkan();
      build();
      expect(viewModel.state, SectionState.loading);
      expect(viewModel.code, isNull);

      await viewModel.init();

      expect(user.refreshCalls, 1);
      expect(viewModel.state, SectionState.ready);
      expect(viewModel.code, 'MOZK-4821');
    });

    test('no answer in 15 s is the error, never an endless skeleton', () {
      fakeAsync((async) {
        user = FakeUserService(noCode);
        final gate = Completer<void>();
        user.refreshGate = gate.future;
        final vm = build();
        unawaited(vm.init());

        async.elapse(const Duration(seconds: 14));
        expect(vm.state, SectionState.loading);
        async.elapse(const Duration(seconds: 2));
        expect(vm.state, SectionState.error);
      });
    });
  });

  group('error (kare 5)', () {
    test('a failed request is the error; "Tekrar Dene" asks again', () async {
      user = FakeUserService(noCode);
      build();
      await viewModel.init();
      expect(viewModel.state, SectionState.error);
      expect(viewModel.code, isNull);

      user.refreshAnswer = mehmetOzkan();
      final retry = viewModel.retry();
      expect(viewModel.state, SectionState.loading);
      await retry;

      expect(viewModel.state, SectionState.ready);
      expect(viewModel.code, 'MOZK-4821');
    });

    test('an answer with no code is the error too', () async {
      user = FakeUserService(noCode)..refreshAnswer = noCode;
      build();

      await viewModel.init();

      expect(viewModel.state, SectionState.error);
    });

    test('copy and share do nothing without a code', () async {
      user = FakeUserService(noCode);
      build();
      await viewModel.init();

      await viewModel.copy();
      await viewModel.share(AppLocalizationsTr());

      expect(copied, isEmpty);
      expect(shared, isEmpty);
      expect(toastText(toast), isNull);
    });
  });

  group('copy and share (kare 3)', () {
    test('"Kopyala" puts the code on the clipboard and says so', () async {
      build();

      await viewModel.copy();

      expect(copied, ['MOZK-4821']);
      expect(toastText(toast), 'Kod kopyalandı.');
      expect(toastKind(toast), AppToastKind.success);
    });

    test(
      '"Kopyala" plays the selection click, not the success haptic',
      () async {
        final calls = <String>[];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, (call) async {
              if (call.method == 'HapticFeedback.vibrate') {
                calls.add('${call.arguments}');
              }
              return null;
            });
        addTearDown(
          () => TestDefaultBinaryMessengerBinding
              .instance
              .defaultBinaryMessenger
              .setMockMethodCallHandler(SystemChannels.platform, null),
        );
        build();

        await viewModel.copy();
        await Future<void>.delayed(Duration.zero);

        expect(calls, ['HapticFeedbackType.selectionClick']);
      },
    );

    test('"Paylaş" sends the sentence with the code and the button\'s '
        'rectangle', () async {
      build();
      const origin = Rect.fromLTWH(210, 700, 160, 48);

      await viewModel.share(AppLocalizationsTr(), origin: origin);

      expect(shared, [
        (
          "SMAP koçluk kodum: MOZK-4821. Hesap › Koçluk'a girerek bana "
              'bağlanabilirsin.',
          origin,
        ),
      ]);
    });
  });

  group('offline (kare 6)', () {
    test(
      'the stored code is shown with its note and both actions work',
      () async {
        online.value = false;
        build();

        expect(viewModel.state, SectionState.ready);
        expect(viewModel.showStoredNote, isTrue);
        await viewModel.copy();
        expect(copied, ['MOZK-4821']);
      },
    );

    test('the note goes away with the connection', () {
      online.value = false;
      build();
      expect(viewModel.showStoredNote, isTrue);

      online.value = true;

      expect(viewModel.showStoredNote, isFalse);
    });

    test('with no stored code there is no note, only the error', () async {
      online.value = false;
      user = FakeUserService(noCode);
      build();

      await viewModel.init();

      expect(viewModel.state, SectionState.error);
      expect(viewModel.showStoredNote, isFalse);
    });
  });
}
