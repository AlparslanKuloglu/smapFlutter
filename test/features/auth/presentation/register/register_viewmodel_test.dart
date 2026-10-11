import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/domain/user_role.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/features/account/data/dtos/legal_document_dto.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/auth/application/register/consent_text_parts.dart';
import 'package:smap/features/auth/application/register/register_rules.dart';
import 'package:smap/features/auth/data/dtos/new_registration.dart';
import 'package:smap/features/auth/data/dtos/register_outcome.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';
import 'package:smap/features/auth/presentation/register/register_navigator.dart';
import 'package:smap/features/auth/presentation/register/register_notice.dart';
import 'package:smap/features/auth/presentation/register/register_viewmodel.dart';
import 'package:smap/features/coach/domain/username_check.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

LegalDocumentDto _doc(String name, String version) => LegalDocumentDto(
  id: name,
  name: name,
  title: name,
  version: version,
  content: '<p>$name</p>',
);

final _documents = [
  _doc('kullanim_kosullari', '1.2.0'),
  _doc('kvkk_aydinlatma_metni', '1.1.0'),
  _doc('gizlilik_politikasi', '1.0.0'),
];

class _Navigator implements RegisterNavigator {
  int logins = 0;

  @override
  void openLogin() => logins++;
}

/// Everything the ViewModel talks to, scripted.
class _World {
  final navigator = _Navigator();
  final calls = <String>[];
  final registrations = <NewRegistration>[];
  final opened = <LegalDocumentDto>[];
  final takenNames = <String>{};
  AppResult<List<LegalDocumentDto>> legalAnswer = Right(_documents);
  AppResult<RegisterOutcome> registerAnswer = const Right(
    RegisterOutcome.registered,
  );
  AppResult<UserDto> signInAnswer = Right(UserDto.fromJson({'_id': 'u1'}));
  Completer<void>? registerGate;

  Future<AppResult<UsernameCheck>> checkUsername(String name) async {
    calls.add('check:$name');
    return Right(UsernameCheck(available: !takenNames.contains(name)));
  }

  Future<AppResult<List<LegalDocumentDto>>> loadLegal() async {
    calls.add('legal');
    return legalAnswer;
  }

  Future<AppResult<RegisterOutcome>> register(NewRegistration r) async {
    calls.add('register');
    registrations.add(r);
    await registerGate?.future;
    return registerAnswer;
  }

  Future<AppResult<UserDto>> signIn({
    required String username,
    required String password,
  }) async {
    calls.add('signIn:$username');
    return signInAnswer;
  }

  Future<void> clearDraft() async => calls.add('clearDraft');

  Future<void> openLegal(LegalDocumentDto d) async => opened.add(d);

  RegisterViewModel viewModel({
    UserRole? role,
    SchoolGrade? grade,
    StudyTrack? track,
  }) => RegisterViewModel(
    navigator: navigator,
    checkUsername: checkUsername,
    loadLegalDocuments: loadLegal,
    register: register,
    signIn: signIn,
    clearOnboardingDraft: clearDraft,
    openLegalText: openLegal,
    role: role,
    grade: grade,
    track: track,
    usernameDebounce: const Duration(milliseconds: 5),
  );
}

/// Fills a complete student form.
void _fill(RegisterViewModel vm, {bool consent = true}) {
  vm
    ..onFullName('Alparslan Kuloğlu')
    ..onUsername('alparslan.k')
    ..onEmail('alparslan@ornek.com')
    ..onPassword('Gizli#2026')
    ..onPasswordRepeat('Gizli#2026')
    ..setGrade(SchoolGrade.grade12)
    ..setTrack(StudyTrack.esitAgirlik)
    ..setConsent(consent);
}

Future<void> _tick() => Future<void>.delayed(const Duration(milliseconds: 30));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _World world;
  late RegisterViewModel vm;

  setUp(() {
    world = _World();
    vm = world.viewModel();
  });

  tearDown(() => vm.dispose());

  group('start', () {
    test('a student with nothing picked, the first avatar, no consent', () {
      expect(vm.role, UserRole.student);
      expect(vm.avatarIndex, 0);
      expect(vm.grade, isNull);
      expect(vm.track, isNull);
      expect(vm.consent, isFalse);
      expect(vm.legal.isLoading, isTrue);
      expect(vm.canSubmit, isFalse);
    });

    test('the role, grade and track of the welcome screen come along', () {
      final other = world.viewModel(
        role: UserRole.coach,
        grade: SchoolGrade.grade12,
        track: StudyTrack.sayisal,
      );
      addTearDown(other.dispose);

      expect(other.role, UserRole.coach);
      expect(other.grade, SchoolGrade.grade12);
      expect(other.track, StudyTrack.sayisal);
    });

    test('a track below grade 11 is dropped; an unknown role is a student', () {
      final other = world.viewModel(
        role: UserRole.unknown,
        grade: SchoolGrade.grade10,
        track: StudyTrack.sayisal,
      );
      addTearDown(other.dispose);

      expect(other.role, UserRole.student);
      expect(other.track, isNull);
    });
  });

  group('legal texts', () {
    test('load, and the form can be submitted', () async {
      await vm.loadLegal();

      expect(vm.legal.isReady, isTrue);
      expect(vm.canSubmit, isTrue);
    });

    test('a failed load closes the form; "Tekrar Dene" opens it', () async {
      world.legalAnswer = const Left(AppException(code: AppErrorCode.server));
      await vm.loadLegal();
      expect(vm.legal.isError, isTrue);
      expect(vm.canSubmit, isFalse);

      world.legalAnswer = Right(_documents);
      await vm.loadLegal();
      expect(vm.legal.isReady, isTrue);
      expect(world.calls.where((c) => c == 'legal'), hasLength(2));
    });

    test('no connection reads as a closed form too', () async {
      world.legalAnswer = const Left(AppException(code: AppErrorCode.offline));

      await vm.loadLegal();

      expect(vm.legal.state, SectionState.offline);
      expect(vm.canSubmit, isFalse);
    });

    test('a list without the terms or the KVKK notice is a failure', () async {
      world.legalAnswer = Right([_doc('gizlilik_politikasi', '1.0.0')]);

      await vm.loadLegal();

      expect(vm.legal.isError, isTrue);
    });

    test('a consent link opens its text', () async {
      await vm.loadLegal();

      await vm.openLegal(ConsentLink.terms);
      await vm.openLegal(ConsentLink.kvkk);

      expect(world.opened.map((d) => d.name), [
        'kullanim_kosullari',
        'kvkk_aydinlatma_metni',
      ]);
    });

    test('a consent link does nothing before the texts are there', () async {
      await vm.openLegal(ConsentLink.terms);

      expect(world.opened, isEmpty);
    });

    test('submit is ignored while the texts are not loaded', () async {
      _fill(vm);

      await vm.submit();

      expect(world.calls, isNot(contains('register')));
    });
  });

  group('editing', () {
    test('the role changes; an unknown role is ignored', () {
      vm.setRole(UserRole.coach);
      expect(vm.role, UserRole.coach);

      vm.setRole(UserRole.unknown);
      expect(vm.role, UserRole.coach);
    });

    test('an avatar out of range is ignored', () {
      vm.setAvatar(3);
      vm.setAvatar(7);
      vm.setAvatar(-1);

      expect(vm.avatarIndex, 3);
    });

    test('a grade below 11 drops the track', () {
      vm
        ..setGrade(SchoolGrade.grade12)
        ..setTrack(StudyTrack.sozel);
      expect(vm.track, StudyTrack.sozel);

      vm.setGrade(SchoolGrade.grade10);

      expect(vm.track, isNull);
    });

    test('the user name is normalized: Turkish lower case, no spaces', () {
      vm.onUsername('Alparslan K');
      world.takenNames.clear();

      vm.onUsername('ALPARSLAN.K');

      expect(vm.usernameCheck.name, 'alparslan.k');
    });
  });

  group('when a field shows its issue', () {
    test('a wrong e-mail only after it lost focus with text in it', () {
      vm.onEmail('alparslan@ornek');
      expect(vm.issueFor(RegisterField.email), isNull);

      vm.blur(RegisterField.email);

      expect(vm.issueFor(RegisterField.email), RegisterIssue.emailInvalid);
    });

    test('an empty field stays quiet on blur', () {
      vm.blur(RegisterField.email);
      vm.blur(RegisterField.fullName);

      expect(vm.issueFor(RegisterField.email), isNull);
      expect(vm.issueFor(RegisterField.fullName), isNull);
    });

    test('once shown, the issue goes away as soon as the text is right', () {
      vm.onEmail('alparslan@ornek');
      vm.blur(RegisterField.email);

      vm.onEmail('alparslan@ornek.com');

      expect(vm.issueFor(RegisterField.email), isNull);
    });

    test('different passwords show after the repeat lost focus', () {
      vm.onPassword('Gizli#2026');
      vm.onPasswordRepeat('Gizli#2027');
      expect(vm.issueFor(RegisterField.passwordRepeat), isNull);

      vm.blur(RegisterField.passwordRepeat);

      expect(
        vm.issueFor(RegisterField.passwordRepeat),
        RegisterIssue.passwordMismatch,
      );
    });

    test('a taken user name shows at once, with its suggestion', () async {
      world.takenNames.add('alparslan');
      world.takenNames.add('alparslan1');
      vm.onFullName('Alparslan Kuloğlu');

      vm.onUsername('alparslan');
      await _tick();

      expect(vm.issueFor(RegisterField.username), RegisterIssue.usernameTaken);
      expect(vm.usernameCheck.suggestion, 'alparslan.k');
    });
  });

  group('submit with issues', () {
    test('shows every issue and moves focus to the first', () async {
      await vm.loadLegal();
      vm.onEmail('alparslan@ornek');
      final requests = <RegisterFocusRequest?>[];
      vm.focusRequest.addListener(() => requests.add(vm.focusRequest.value));

      await vm.submit();

      expect(requests.single?.field, RegisterField.fullName);
      expect(
        vm.issueFor(RegisterField.fullName),
        RegisterIssue.fullNameMissing,
      );
      expect(vm.issueFor(RegisterField.email), RegisterIssue.emailInvalid);
      expect(vm.issueFor(RegisterField.grade), RegisterIssue.gradeMissing);
      expect(vm.issueFor(RegisterField.consent), RegisterIssue.consentMissing);
      expect(world.calls, isNot(contains('register')));
      expect(vm.submitting, isFalse);
    });

    test('pano 2.6 kare 2: passwords differ and no consent', () async {
      await vm.loadLegal();
      _fill(vm, consent: false);
      vm.onPasswordRepeat('Gizli#2027');
      final requests = <RegisterFocusRequest?>[];
      vm.focusRequest.addListener(() => requests.add(vm.focusRequest.value));

      await vm.submit();

      expect(requests.single?.field, RegisterField.passwordRepeat);
      expect(
        vm.issueFor(RegisterField.passwordRepeat),
        RegisterIssue.passwordMismatch,
      );
      expect(vm.issueFor(RegisterField.consent), RegisterIssue.consentMissing);
    });

    test('grade 10 asks for no track (pano 2.6 kare 4)', () async {
      await vm.loadLegal();
      _fill(vm);
      vm.setGrade(SchoolGrade.grade10);

      await vm.submit();

      expect(world.calls, contains('register'));
      expect(world.registrations.single.track, isNull);
      expect(world.registrations.single.aimType, isNull);
    });

    test('a coach has no grade or track to miss', () async {
      await vm.loadLegal();
      vm.setRole(UserRole.coach);
      vm
        ..onFullName('Mehmet Özkan')
        ..onUsername('mehmet')
        ..onEmail('mehmet@ornek.com')
        ..onPassword('Gizli#2026')
        ..onPasswordRepeat('Gizli#2026')
        ..setConsent(true);

      await vm.submit();

      final sent = world.registrations.single;
      expect(sent.role, UserRole.coach);
      expect(sent.grade, isNull);
      expect(sent.toBody()['userType'], 2);
    });
  });

  group('submit', () {
    test(
      'registers, clears the draft, then signs in with the same login',
      () async {
        await vm.loadLegal();
        _fill(vm);
        vm.setAvatar(2);

        await vm.submit();

        expect(
          world.calls.where((c) => !c.startsWith('check') && c != 'legal'),
          ['register', 'clearDraft', 'signIn:alparslan.k'],
        );
        final sent = world.registrations.single;
        expect(sent.fullName, 'Alparslan Kuloğlu');
        expect(sent.userName, 'alparslan.k');
        expect(sent.email, 'alparslan@ornek.com');
        expect(sent.password, 'Gizli#2026');
        expect(sent.passwordRepeat, 'Gizli#2026');
        expect(sent.grade, SchoolGrade.grade12);
        expect(sent.track, StudyTrack.esitAgirlik);
        expect(sent.photo, '4avatarN3.png');
        expect(sent.acceptedTermsVersion, '1.2.0');
        expect(sent.acceptedKvkkVersion, '1.1.0');
        expect(sent.acceptedPrivacyVersion, '1.0.0');
        expect(vm.notice, isNull);
        expect(vm.submitting, isFalse);
      },
    );

    test(
      'the button is busy while the call runs, and a second tap is ignored',
      () async {
        await vm.loadLegal();
        _fill(vm);
        world.registerGate = Completer<void>();

        final first = vm.submit();
        await _tick();
        expect(vm.submitting, isTrue);
        expect(vm.canSubmit, isFalse);
        await vm.submit();
        world.registerGate!.complete();
        await first;

        expect(world.registrations, hasLength(1));
        expect(vm.submitting, isFalse);
      },
    );

    test(
      'a failure is a notice above the button, and nothing is cleared',
      () async {
        await vm.loadLegal();
        _fill(vm);
        world.registerAnswer = const Left(
          AppException(code: AppErrorCode.offline),
        );

        await vm.submit();

        expect(vm.notice?.kind, RegisterNoticeKind.failed);
        expect(vm.notice?.code, AppErrorCode.offline);
        expect(world.calls, isNot(contains('clearDraft')));
        expect(world.calls.where((c) => c.startsWith('signIn')), isEmpty);
        expect(vm.submitting, isFalse);
      },
    );

    test('a validation refusal keeps the server text', () async {
      await vm.loadLegal();
      _fill(vm);
      world.registerAnswer = const Left(
        AppException(
          code: AppErrorCode.validation,
          serverMessage: 'E-posta kullanımda',
        ),
      );

      await vm.submit();

      expect(vm.notice?.serverMessage, 'E-posta kullanımda');
    });

    test('a taken user name from the server is the field error', () async {
      await vm.loadLegal();
      _fill(vm);
      world.registerAnswer = const Right(RegisterOutcome.userNameTaken);
      final requests = <RegisterFocusRequest?>[];
      vm.focusRequest.addListener(() => requests.add(vm.focusRequest.value));

      await vm.submit();

      expect(vm.issueFor(RegisterField.username), RegisterIssue.usernameTaken);
      expect(requests.last?.field, RegisterField.username);
      expect(vm.notice, isNull);
      expect(world.calls.where((c) => c.startsWith('signIn')), isEmpty);
      expect(vm.submitting, isFalse);
    });

    test('a user name that the live check found taken is not sent', () async {
      await vm.loadLegal();
      world.takenNames.add('alparslan.k');
      _fill(vm);
      await _tick();

      await vm.submit();

      expect(world.calls, isNot(contains('register')));
      expect(vm.issueFor(RegisterField.username), RegisterIssue.usernameTaken);
    });

    test('the sign-in that follows failing is its own notice', () async {
      await vm.loadLegal();
      _fill(vm);
      world.signInAnswer = const Left(AppException(code: AppErrorCode.network));

      await vm.submit();

      expect(vm.notice, const RegisterNotice.signInFailed());
      expect(world.calls, contains('clearDraft'));
    });

    test('after that, another tap only signs in again; nothing is registered '
        'twice', () async {
      await vm.loadLegal();
      _fill(vm);
      world.signInAnswer = const Left(AppException(code: AppErrorCode.network));
      await vm.submit();
      world.signInAnswer = Right(UserDto.fromJson({'_id': 'u1'}));

      await vm.submit();

      expect(world.registrations, hasLength(1));
      expect(world.calls.where((c) => c.startsWith('signIn')), hasLength(2));
      expect(vm.notice, isNull);
    });
  });

  test('"Giriş Yap" goes to the sign-in screen', () {
    vm.openLogin();

    expect(world.navigator.logins, 1);
  });

  test(
    'a view model disposed during a call does not notify afterwards',
    () async {
      await vm.loadLegal();
      _fill(vm);
      world.registerGate = Completer<void>();

      final pending = vm.submit();
      await _tick();
      vm.dispose();
      world.registerGate!.complete();

      await expectLater(pending, completes);
      // Disposed twice by tearDown would throw; the guard makes it a no-op.
      vm = world.viewModel();
    },
  );
}
