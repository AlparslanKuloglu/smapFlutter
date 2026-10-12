import 'dart:async';
import 'dart:math';
import 'dart:ui' show Rect;

import 'package:dartz/dartz.dart';
// ignore: depend_on_referenced_packages
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/auth/application/register/username_live_check.dart';
import 'package:smap/features/coach/application/add_student_rules.dart';
import 'package:smap/features/coach/application/coach_code_actions.dart';
import 'package:smap/features/coach/data/add_student_outcome.dart';
import 'package:smap/features/coach/data/dtos/coach_student_dto.dart';
import 'package:smap/features/coach/domain/new_student.dart';
import 'package:smap/features/coach/domain/username_check.dart';
import 'package:smap/features/coach/presentation/add_student/add_student_texts.dart';
import 'package:smap/features/coach/presentation/add_student/add_student_viewmodel.dart';
import 'package:smap/l10n/app_localizations_tr.dart';

import '../../../account/presentation/account_settings_fakes.dart';
import '../../coach_fixtures.dart';

/// What the scripted server knows: which user names are taken, what "save"
/// answers, and what it was sent.
class _Backend {
  Set<String> taken = {};
  bool offline = false;
  final List<String> checked = [];
  final List<NewStudent> saved = [];
  AppResult<AddStudentOutcome>? saveAnswer;
  Completer<void>? saveGate;

  Future<AppResult<UsernameCheck>> check(String name) async {
    checked.add(name);
    if (offline) {
      return const Left(AppException(code: AppErrorCode.offline));
    }
    return Right(UsernameCheck(available: !taken.contains(name)));
  }

  Future<AppResult<AddStudentOutcome>> save(NewStudent student) async {
    saved.add(student);
    await saveGate?.future;
    return saveAnswer ??
        Right(
          AddStudentOutcome.added(
            CoachStudentDto.fromJson(
              studentJson(
                id: 'new-1',
                name: student.firstName,
                surname: student.lastName,
              ),
            ),
          ),
        );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _Backend backend;
  late ToastProbe toast;
  late List<String> copied;
  late List<(String, Rect?)> shared;
  late AddStudentViewModel viewModel;

  AddStudentViewModel build({
    String? coachCode = 'MOZK-4821',
    Duration debounce = const Duration(milliseconds: 1),
  }) => AddStudentViewModel(
    checkUsername: backend.check,
    addStudent: backend.save,
    codeActions: CoachCodeActions(
      copyText: (text) async => copied.add(text),
      shareText: (text, {origin}) async => shared.add((text, origin)),
      toast: toast.service,
    ),
    coachCode: coachCode,
    random: Random(11),
    usernameDebounce: debounce,
  );

  /// Pauses long enough for a 1 ms debounce and the check behind it.
  Future<void> pause() =>
      Future<void>.delayed(const Duration(milliseconds: 30));

  /// Fills the form of pano 10.3 kare 1: Zeynep Kaya, 12. sınıf, EA.
  Future<void> fillBoardForm() async {
    viewModel
      ..onFirstName('Zeynep')
      ..onLastName('Kaya')
      ..onUsername('zeynep.kaya')
      ..onPassword('Kx7mP2qRtv')
      ..setGrade(SchoolGrade.grade12)
      ..setTrack(StudyTrack.esitAgirlik);
    await pause();
  }

  setUp(() {
    backend = _Backend();
    toast = ToastProbe();
    copied = [];
    shared = [];
    viewModel = build();
  });

  tearDown(() {
    viewModel.dispose();
    toast.dispose();
  });

  group('the form at the start (pano 10.3 kare 1)', () {
    test('the first avatar is chosen; nothing shows an issue', () {
      expect(viewModel.avatarIndex, 0);
      for (final field in AddStudentField.values) {
        expect(viewModel.issueFor(field), isNull);
      }
      expect(viewModel.submitting, isFalse);
      expect(viewModel.failure, isNull);
    });

    test('an avatar can be chosen; an index outside the seven cannot', () {
      viewModel.setAvatar(3);
      expect(viewModel.avatarIndex, 3);
      viewModel.setAvatar(7);
      viewModel.setAvatar(-1);
      expect(viewModel.avatarIndex, 3);
    });

    test('the coaching code is the coach\'s, or none', () {
      expect(viewModel.coachCode, 'MOZK-4821');
      expect(build(coachCode: null).coachCode, isNull);
      expect(build(coachCode: '  ').coachCode, isNull);
    });
  });

  group('user name (pano 10.3 "Alan kuralları")', () {
    test('is lower-cased and kept to letters, digits, "." and "_"', () async {
      viewModel.onUsername('ZEYNEP.Kaya_1 !-');
      await pause();
      expect(backend.checked, ['zeynep.kaya_1']);
    });

    test('is asked of the server 400 ms after the last key', () {
      fakeAsync((async) {
        final slow = build(debounce: kAddStudentUsernameDebounce);
        slow.onUsername('zeynep.kaya');
        async.elapse(const Duration(milliseconds: 399));
        expect(backend.checked, isEmpty);
        expect(slow.usernameCheck.status, UsernameStatus.idle);
        async.elapse(const Duration(milliseconds: 2));
        async.flushMicrotasks();
        expect(backend.checked, ['zeynep.kaya']);
        expect(slow.usernameCheck.status, UsernameStatus.available);
        slow.dispose();
      });
    });

    test('keys typed in a row ask once, about the last name', () {
      fakeAsync((async) {
        final slow = build(debounce: kAddStudentUsernameDebounce);
        for (final typed in ['z', 'ze', 'zey', 'zeyn']) {
          slow.onUsername(typed);
          async.elapse(const Duration(milliseconds: 100));
        }
        async.elapse(const Duration(milliseconds: 400));
        async.flushMicrotasks();
        expect(backend.checked, ['zeyn']);
        slow.dispose();
      });
    });

    test('a free name is "Bu kullanıcı adı boşta." (no issue)', () async {
      viewModel.onUsername('zeynep.kaya');
      await pause();
      expect(viewModel.usernameCheck.status, UsernameStatus.available);
      expect(viewModel.issueFor(AddStudentField.username), isNull);
    });

    test('a taken name is an issue at once, with a free suggestion', () async {
      backend.taken = {'zeynep'};
      viewModel
        ..onFirstName('Zeynep')
        ..onLastName('Kaya')
        ..onUsername('zeynep');
      await pause();
      expect(viewModel.usernameCheck.status, UsernameStatus.taken);
      expect(
        viewModel.issueFor(AddStudentField.username),
        AddStudentIssue.usernameTaken,
      );
      expect(viewModel.usernameCheck.suggestion, 'zeynep.k');
    });

    test('"Kontrol Et" asks at once, with no wait', () async {
      final slow = build(debounce: const Duration(seconds: 10));
      slow.onUsername('zeynep.kaya');
      expect(backend.checked, isEmpty);
      slow.checkUsernameNow();
      await pause();
      expect(backend.checked, ['zeynep.kaya']);
      expect(slow.usernameCheck.status, UsernameStatus.available);
      slow.dispose();
    });

    test('"Kontrol Et" on an empty name shows its issue', () {
      viewModel.checkUsernameNow();
      expect(
        viewModel.issueFor(AddStudentField.username),
        AddStudentIssue.usernameMissing,
      );
      expect(backend.checked, isEmpty);
    });

    test('offline says so and "Kontrol Et" asks again when back', () async {
      backend.offline = true;
      viewModel.onUsername('zeynep.kaya');
      await pause();
      expect(viewModel.usernameCheck.status, UsernameStatus.offline);

      backend.offline = false;
      viewModel.checkUsernameNow();
      await pause();
      expect(viewModel.usernameCheck.status, UsernameStatus.available);
    });
  });

  group('password ("Oluştur")', () {
    test('makes a readable 10-character password and keeps it', () {
      final password = viewModel.generatePassword();
      expect(password, matches(RegExp(r'^[A-HJ-NP-Za-km-z2-9]{10}$')));
      // It is the form's password now: no issue even before it is typed.
      expect(viewModel.issueFor(AddStudentField.password), isNull);
    });

    test('a second press makes a different one', () {
      expect(viewModel.generatePassword(), isNot(viewModel.generatePassword()));
    });
  });

  group('grade and track', () {
    test('the 10th grade drops the track', () {
      viewModel
        ..setGrade(SchoolGrade.grade12)
        ..setTrack(StudyTrack.sayisal)
        ..setGrade(SchoolGrade.grade10);
      expect(viewModel.track, isNull);
      expect(viewModel.grade, SchoolGrade.grade10);
    });

    test('the 12th grade keeps the track', () {
      viewModel
        ..setGrade(SchoolGrade.grade11)
        ..setTrack(StudyTrack.sozel)
        ..setGrade(SchoolGrade.graduate);
      expect(viewModel.track, StudyTrack.sozel);
    });
  });

  group('issues show when they should', () {
    test('a field filled and left shows its issue, an empty one does not', () {
      viewModel.onPassword('short');
      viewModel.blur(AddStudentField.password);
      viewModel.blur(AddStudentField.firstName);
      expect(
        viewModel.issueFor(AddStudentField.password),
        AddStudentIssue.passwordTooShort,
      );
      expect(viewModel.issueFor(AddStudentField.firstName), isNull);
    });

    test('and then keeps it live while the coach types', () {
      viewModel.onPassword('short');
      viewModel.blur(AddStudentField.password);
      viewModel.onPassword('longenough');
      expect(viewModel.issueFor(AddStudentField.password), isNull);
    });
  });

  group('submit', () {
    test(
      'an empty form shows every issue and sends focus to the first',
      () async {
        final requests = <AddStudentFocusRequest?>[];
        viewModel.focusRequest.addListener(
          () => requests.add(viewModel.focusRequest.value),
        );

        final added = await viewModel.submit();

        expect(added, isNull);
        expect(backend.saved, isEmpty);
        expect(requests.single?.field, AddStudentField.firstName);
        expect(
          viewModel.issueFor(AddStudentField.firstName),
          AddStudentIssue.firstNameMissing,
        );
        expect(
          viewModel.issueFor(AddStudentField.lastName),
          AddStudentIssue.lastNameMissing,
        );
        expect(
          viewModel.issueFor(AddStudentField.username),
          AddStudentIssue.usernameMissing,
        );
        expect(
          viewModel.issueFor(AddStudentField.password),
          AddStudentIssue.passwordMissing,
        );
        expect(
          viewModel.issueFor(AddStudentField.grade),
          AddStudentIssue.gradeMissing,
        );
        expect(viewModel.issueFor(AddStudentField.track), isNull);
      },
    );

    test('focus goes to the first wrong field, not always the first', () async {
      await fillBoardForm();
      viewModel.onPassword('x');
      final requests = <AddStudentFocusRequest?>[];
      viewModel.focusRequest.addListener(
        () => requests.add(viewModel.focusRequest.value),
      );
      await viewModel.submit();
      expect(requests.single?.field, AddStudentField.password);
    });

    test('the board form is sent as the server wants it', () async {
      await fillBoardForm();
      viewModel.setAvatar(3);

      final added = await viewModel.submit();

      expect(backend.saved, hasLength(1));
      expect(backend.saved.single.toDataObj(), {
        'name': 'Zeynep',
        'surname': 'Kaya',
        'userName': 'zeynep.kaya',
        'password': 'Kx7mP2qRtv',
        'seasonType': 12,
        'aimType': 2,
        'photo': '5avatarN3.png',
      });
      expect(added?.fullName, 'Zeynep Kaya');
      expect(added?.userName, 'zeynep.kaya');
      expect(added?.password, 'Kx7mP2qRtv');
      expect(added?.avatarIndex, 3);
      expect(added?.student.id, 'new-1');
    });

    test(
      'the first avatar goes with the student when none was chosen',
      () async {
        await fillBoardForm();
        await viewModel.submit();
        expect(backend.saved.single.photo, '1avatarN3.png');
      },
    );

    test('"Mezun" is saved as 13 (the server\'s acceptance is open)', () async {
      await fillBoardForm();
      viewModel
        ..setGrade(SchoolGrade.graduate)
        ..setTrack(StudyTrack.sozel);
      await viewModel.submit();
      expect(backend.saved.single.toDataObj()['seasonType'], 13);
    });

    test('a 10th grader is saved with no track', () async {
      await fillBoardForm();
      viewModel.setGrade(SchoolGrade.grade10);
      await viewModel.submit();
      expect(backend.saved.single.toDataObj().containsKey('aimType'), isFalse);
    });

    test('is busy while the student is saved, and only one runs', () async {
      await fillBoardForm();
      backend.saveGate = Completer<void>();

      final first = viewModel.submit();
      await Future<void>.delayed(Duration.zero);
      expect(viewModel.submitting, isTrue);
      expect(await viewModel.submit(), isNull);

      backend.saveGate!.complete();
      final added = await first;
      expect(added, isNotNull);
      expect(viewModel.submitting, isFalse);
      expect(backend.saved, hasLength(1));
    });

    test(
      'asks about a user name still being checked before it saves',
      () async {
        final slow = build(debounce: const Duration(seconds: 10));
        slow
          ..onFirstName('Zeynep')
          ..onLastName('Kaya')
          ..onUsername('zeynep.kaya')
          ..onPassword('Kx7mP2qRtv')
          ..setGrade(SchoolGrade.grade12)
          ..setTrack(StudyTrack.esitAgirlik);

        final added = await slow.submit();

        expect(backend.checked, ['zeynep.kaya']);
        expect(added, isNotNull);
        slow.dispose();
      },
    );

    test('a name that turns out taken stops the save', () async {
      backend.taken = {'zeynep.kaya'};
      final slow = build(debounce: const Duration(seconds: 10));
      slow
        ..onFirstName('Zeynep')
        ..onLastName('Kaya')
        ..onUsername('zeynep.kaya')
        ..onPassword('Kx7mP2qRtv')
        ..setGrade(SchoolGrade.grade12)
        ..setTrack(StudyTrack.esitAgirlik);

      final added = await slow.submit();

      expect(added, isNull);
      expect(backend.saved, isEmpty);
      expect(
        slow.issueFor(AddStudentField.username),
        AddStudentIssue.usernameTaken,
      );
      slow.dispose();
    });

    test(
      '"user name in use" from the save marks the field and offers a free one',
      () async {
        await fillBoardForm();
        backend.saveAnswer = const Right(AddStudentOutcome.userNameTaken());
        final requests = <AddStudentFocusRequest?>[];
        viewModel.focusRequest.addListener(
          () => requests.add(viewModel.focusRequest.value),
        );

        final added = await viewModel.submit();
        await pause();

        expect(added, isNull);
        expect(viewModel.failure, isNull);
        expect(
          viewModel.issueFor(AddStudentField.username),
          AddStudentIssue.usernameTaken,
        );
        expect(requests.single?.field, AddStudentField.username);
        expect(viewModel.usernameCheck.suggestion, 'zeynep.kaya.k');
        expect(viewModel.submitting, isFalse);
      },
    );

    test(
      'a failed save keeps the sheet and what was typed; retry works',
      () async {
        await fillBoardForm();
        backend.saveAnswer = const Left(
          AppException(code: AppErrorCode.server, statusCode: 500),
        );

        expect(await viewModel.submit(), isNull);
        expect(viewModel.failure?.code, AppErrorCode.server);
        expect(viewModel.submitting, isFalse);
        expect(viewModel.issueFor(AddStudentField.firstName), isNull);

        backend.saveAnswer = null;
        final added = await viewModel.submit();
        expect(added, isNotNull);
        expect(viewModel.failure, isNull);
        expect(backend.saved, hasLength(2));
      },
    );

    test('the notice for a failure never carries a server code', () async {
      final l10n = AppLocalizationsTr();
      String text(AppException failure) => addStudentFailureText(l10n, failure);

      expect(
        text(const AppException(code: AppErrorCode.offline)),
        l10n.errors_offline,
      );
      expect(
        text(const AppException(code: AppErrorCode.server)),
        l10n.errors_server,
      );
      expect(
        text(const AppException(code: AppErrorCode.unknown)),
        'Öğrenci eklenemedi. Bağlantını kontrol edip tekrar dene.',
      );
      expect(
        text(
          const AppException(
            code: AppErrorCode.validation,
            serverMessage: 'Bu e-posta kullanımda.',
          ),
        ),
        'Bu e-posta kullanımda.',
      );
    });
  });

  group('the coaching code card (pano 10.3 kare 1 and 2)', () {
    test('"Kopyala" copies the code and says "Kod kopyalandı."', () async {
      await viewModel.copyCode();
      expect(copied, ['MOZK-4821']);
      expect(toast.text, 'Kod kopyalandı.');
    });

    test('"Paylaş" shares the code in a sentence, anchored', () async {
      const origin = Rect.fromLTWH(1, 2, 3, 4);
      await viewModel.shareCode(AppLocalizationsTr(), origin: origin);
      expect(shared, [("SMAP'te koçluk kodum: MOZK-4821", origin)]);
    });

    test('a coach with no code has nothing to copy or share', () async {
      final none = build(coachCode: null);
      await none.copyCode();
      await none.shareCode(AppLocalizationsTr());
      expect(copied, isEmpty);
      expect(shared, isEmpty);
      none.dispose();
    });
  });

  group('the Turkish line of each issue', () {
    final l10n = AppLocalizationsTr();

    test('says what to do, in the "sen" tone', () {
      final lines = {
        for (final issue in AddStudentIssue.values)
          issue: addStudentIssueText(l10n, issue),
      };
      expect(lines[AddStudentIssue.firstNameMissing], 'Öğrencinin adını yaz.');
      expect(
        lines[AddStudentIssue.lastNameMissing],
        'Öğrencinin soyadını yaz.',
      );
      expect(lines[AddStudentIssue.usernameMissing], 'Bir kullanıcı adı yaz.');
      expect(lines[AddStudentIssue.usernameTaken], 'Bu kullanıcı adı alınmış.');
      expect(
        lines[AddStudentIssue.passwordMissing],
        "Bir şifre yaz ya da Oluştur'a dokun.",
      );
      expect(
        lines[AddStudentIssue.passwordTooShort],
        'Şifre en az 8 karakter olmalı.',
      );
      expect(lines[AddStudentIssue.gradeMissing], 'Sınıfı seç.');
      expect(lines[AddStudentIssue.trackMissing], 'Alanı seç.');
      expect(lines.values.toSet(), hasLength(AddStudentIssue.values.length));
    });
  });
}
