import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/features/account/application/profile_draft.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/account/presentation/profile/profile_viewmodel.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';

import 'account_harness.dart';

void main() {
  late AccountBackend backend;
  late FakeUserService user;
  late RecordingNavigator navigator;
  late ScriptedDialogs dialogs;
  late ValueNotifier<bool> online;
  late ToastService toast;
  late ProfileViewModel viewModel;

  ProfileViewModel build() {
    toast = recordingToast();
    return viewModel = ProfileViewModel(
      currentUser: user,
      accounts: backend.repository,
      navigator: navigator,
      dialogs: dialogs,
      toast: toast,
      online: online,
    );
  }

  /// The student's account as the server would answer after the save.
  Map<String, Object?> studentJson(UserDto base) => {
    'success': true,
    'student': {
      '_id': base.id,
      'name': base.name,
      'userName': base.userName,
      'email': base.email,
      'phone': base.phone,
      'role': base.role,
      'seasonType': base.seasonType,
      'aimType': base.aimType,
      'photo': base.photo,
    },
  };

  setUp(() {
    backend = AccountBackend();
    user = FakeUserService(alparslan());
    navigator = RecordingNavigator();
    dialogs = ScriptedDialogs();
    online = ValueNotifier<bool>(true);
  });

  tearDown(() {
    viewModel.dispose();
    backend.dispose();
    online.dispose();
  });

  group('reading (pano 9.2 kare 1)', () {
    test('shows the account and cannot be saved', () {
      build();

      expect(viewModel.mode, ProfileMode.view);
      expect(viewModel.hasUser, isTrue);
      expect(viewModel.draft.name, 'Alparslan Kuloğlu');
      expect(viewModel.draft.phone, '532 123 45 67');
      expect(viewModel.userName, 'alparslan.k');
      expect(viewModel.hasGradeFields, isTrue);
      expect(viewModel.photo, '1avatarN3.png');
      expect(viewModel.bar.canSave, isFalse);
      expect(viewModel.bar.canEdit, isTrue);
      expect(viewModel.hasUnsavedChanges, isFalse);
    });

    test('follows the account when it changes', () {
      build();

      user.set(alparslan(name: 'Alparslan K.'));

      expect(viewModel.viewData.draft.name, 'Alparslan K.');
    });

    test('a coach has no grade or track fields', () {
      user = FakeUserService(mehmetOzkan());
      build();

      expect(viewModel.hasGradeFields, isFalse);
      expect(viewModel.draft.grade, isNull);
    });

    test('without an account there is nothing to edit', () {
      user = FakeUserService(null);
      build();

      expect(viewModel.hasUser, isFalse);
      expect(viewModel.bar.canEdit, isFalse);
    });

    test(
      '"Hesabı Sil" is offered only while its screen is in the router',
      () async {
        build();
        expect(viewModel.canDeleteAccount, isTrue);
        await viewModel.openDeletion();
        expect(navigator.calls, ['open:deletion']);

        viewModel.dispose();
        navigator = RecordingNavigator(available: {});
        build();
        expect(viewModel.canDeleteAccount, isFalse);
      },
    );
  });

  group('editing (pano 9.2 kare 2)', () {
    test('"Düzenle" opens the form on the account\'s values', () {
      build();

      viewModel.edit();

      expect(viewModel.mode, ProfileMode.edit);
      expect(viewModel.draft, ProfileDraft.fromUser(alparslan()));
      expect(viewModel.editData.grade, SchoolGrade.grade12);
      expect(viewModel.editData.track, StudyTrack.esitAgirlik);
      expect(viewModel.editData.userName, 'alparslan.k');
    });

    test('"Kaydet" is off until a field changes, and comes off again', () {
      build().edit();
      expect(viewModel.bar.canSave, isFalse);

      viewModel.setName('Alparslan K.');
      expect(viewModel.bar.canSave, isTrue);
      expect(viewModel.hasUnsavedChanges, isTrue);

      viewModel.setName('Alparslan Kuloğlu');
      expect(viewModel.bar.canSave, isFalse);
    });

    test('"Kaydet" is off while the device is offline', () {
      build()
        ..edit()
        ..setName('Alparslan K.');

      online.value = false;
      expect(viewModel.bar.canSave, isFalse);

      online.value = true;
      expect(viewModel.bar.canSave, isTrue);
    });

    test('typing does not change what the form selects', () {
      build().edit();
      final before = viewModel.editData;

      viewModel
        ..setName('A')
        ..setEmail('a@b.com')
        ..setPhone('532 111 22 33');

      expect(viewModel.editData, before);
    });

    test('a grade without a track takes the track out of the form', () {
      build()
        ..edit()
        ..setGrade(SchoolGrade.grade10);

      expect(viewModel.editData.grade, SchoolGrade.grade10);
      expect(viewModel.editData.track, isNull);
    });
  });

  group('saving', () {
    test(
      'sends only the changed fields, reloads the account, says so',
      () async {
        final saved = alparslan(
          name: 'Alparslan K.',
          phone: '+90 532 999 88 77',
        );
        backend.updateAnswer = studentJson(saved);
        user.refreshAnswer = saved;
        build()
          ..edit()
          ..setName('Alparslan K.')
          ..setPhone('532 999 88 77');

        await viewModel.save();

        expect(backend.lastUpdateBody, {
          'name': 'Alparslan K.',
          'phone': '+90 532 999 88 77',
        });
        expect(user.refreshCalls, 1);
        expect(viewModel.mode, ProfileMode.view);
        expect(viewModel.draft.name, 'Alparslan K.');
        expect(toastText(toast), 'Profilin güncellendi.');
        expect(toastKind(toast), AppToastKind.success);
      },
    );

    test(
      'the e-mail is saved straight away (no verification endpoint)',
      () async {
        final saved = alparslan(email: 'yeni@ornek.com');
        backend.updateAnswer = studentJson(saved);
        user.refreshAnswer = saved;
        build()
          ..edit()
          ..setEmail('yeni@ornek.com');

        await viewModel.save();

        expect(backend.lastUpdateBody, {'email': 'yeni@ornek.com'});
        expect(viewModel.draft.email, 'yeni@ornek.com');
        expect(toastText(toast), 'Profilin güncellendi.');
      },
    );

    test('a reload that fails uses what the server echoed', () async {
      final saved = alparslan(name: 'Alparslan K.');
      backend.updateAnswer = studentJson(saved);
      build()
        ..edit()
        ..setName('Alparslan K.');

      await viewModel.save();

      expect(user.updates, hasLength(1));
      expect(user.updates.single.name, 'Alparslan K.');
      expect(viewModel.draft.name, 'Alparslan K.');
    });

    test(
      'with no echo either, the sent fields are applied to the account',
      () async {
        backend.updateAnswer = {'success': true};
        build()
          ..edit()
          ..setName('Alparslan K.')
          ..setGrade(SchoolGrade.grade11);

        await viewModel.save();

        final updated = user.updates.single;
        expect(updated.name, 'Alparslan K.');
        expect(updated.seasonType, 11);
        expect(updated.userName, 'alparslan.k');
        expect(viewModel.mode, ProfileMode.view);
        expect(viewModel.draft.grade, SchoolGrade.grade11);
      },
    );

    test('a refusal keeps the form and says so', () async {
      backend.updateAnswer = {'success': false, 'message': 'Hata'};
      build()
        ..edit()
        ..setName('Alparslan K.');

      await viewModel.save();

      expect(viewModel.mode, ProfileMode.edit);
      expect(viewModel.draft.name, 'Alparslan K.');
      expect(viewModel.bar.canSave, isTrue);
      expect(user.refreshCalls, 0);
      expect(
        toastText(toast),
        'Kaydedilemedi. Bağlantını kontrol edip tekrar dene.',
      );
      expect(toastKind(toast), AppToastKind.error);
    });

    test('offline while sending keeps the form too', () async {
      backend.updateOffline = true;
      build()
        ..edit()
        ..setName('Alparslan K.');

      await viewModel.save();

      expect(viewModel.mode, ProfileMode.edit);
      expect(toastKind(toast), AppToastKind.error);
    });

    test('can be tried again after a failure', () async {
      backend.updateStatus = 500;
      build()
        ..edit()
        ..setName('Alparslan K.');
      await viewModel.save();

      backend
        ..updateStatus = 200
        ..updateAnswer = studentJson(alparslan(name: 'Alparslan K.'));
      user.refreshAnswer = alparslan(name: 'Alparslan K.');
      await viewModel.save();

      expect(viewModel.mode, ProfileMode.view);
      expect(backend.count('/student/updateStudent'), 2);
    });

    test('a second press while it runs sends nothing more', () async {
      backend.updateAnswer = studentJson(alparslan(name: 'Alparslan K.'));
      user.refreshAnswer = alparslan(name: 'Alparslan K.');
      build()
        ..edit()
        ..setName('Alparslan K.');

      final first = viewModel.save();
      expect(viewModel.bar.canSave, isFalse);
      await viewModel.save();
      await first;

      expect(backend.count('/student/updateStudent'), 1);
    });

    test('a broken e-mail is not sent: the field says what is wrong', () async {
      build()
        ..edit()
        ..setEmail('alparslan@');

      await viewModel.save();

      expect(backend.count('/student/updateStudent'), 0);
      expect(viewModel.editData.issues, {ProfileIssue.emailInvalid});
      expect(viewModel.mode, ProfileMode.edit);
    });

    test('fixing the field takes its error away', () async {
      build()
        ..edit()
        ..setEmail('alparslan@');
      await viewModel.save();

      viewModel.setEmail('alparslan@ornek.com');

      expect(viewModel.editData.issues, isEmpty);
    });

    test('an emptied name is an error too', () async {
      build()
        ..edit()
        ..setName('  ');

      await viewModel.save();

      expect(viewModel.editData.issues, {ProfileIssue.nameMissing});
    });

    test('moving to the 10th grade sends the grade alone', () async {
      backend.updateAnswer = studentJson(alparslan(seasonType: 10));
      user.refreshAnswer = alparslan(seasonType: 10, aimType: null);
      build()
        ..edit()
        ..setGrade(SchoolGrade.grade10);

      await viewModel.save();

      expect(backend.lastUpdateBody, {'seasonType': 10});
      expect(viewModel.draft.grade, SchoolGrade.grade10);
      expect(viewModel.draft.track, isNull);
    });
  });

  group('leaving', () {
    test('"Vazgeç" without changes leaves the form without asking', () async {
      build().edit();

      final left = await viewModel.cancel();

      expect(left, isTrue);
      expect(viewModel.mode, ProfileMode.view);
      expect(dialogs.calls, isEmpty);
    });

    test('"Vazgeç" with changes asks, and the answer decides', () async {
      build()
        ..edit()
        ..setName('Alparslan K.');

      dialogs.discard = false;
      expect(await viewModel.cancel(), isFalse);
      expect(viewModel.mode, ProfileMode.edit);
      expect(viewModel.draft.name, 'Alparslan K.');

      dialogs.discard = true;
      expect(await viewModel.cancel(), isTrue);
      expect(viewModel.mode, ProfileMode.view);
      expect(viewModel.draft.name, 'Alparslan Kuloğlu');
      expect(dialogs.calls, ['discard', 'discard']);
    });

    test(
      'opening the form again starts from the account, not the old draft',
      () async {
        build()
          ..edit()
          ..setName('Alparslan K.');
        await viewModel.cancel();

        viewModel.edit();

        expect(viewModel.draft.name, 'Alparslan Kuloğlu');
        expect(viewModel.hasUnsavedChanges, isFalse);
      },
    );

    test('the back gesture asks only when something would be lost', () async {
      build();
      expect(await viewModel.confirmLeave(), isTrue);

      viewModel
        ..edit()
        ..setName('Alparslan K.');
      dialogs.discard = false;
      expect(await viewModel.confirmLeave(), isFalse);
      dialogs.discard = true;
      expect(await viewModel.confirmLeave(), isTrue);
      expect(dialogs.calls, ['discard', 'discard']);
    });

    test('"Vazgeç" while saving does nothing', () async {
      final gate = Completer<void>();
      backend.updateAnswer = studentJson(alparslan(name: 'Alparslan K.'));
      user.refreshAnswer = alparslan(name: 'Alparslan K.');
      backend.updateAnswer = studentJson(alparslan(name: 'Alparslan K.'));
      build()
        ..edit()
        ..setName('Alparslan K.');

      final saving = viewModel.save();
      final left = await viewModel.cancel();
      gate.complete();
      await saving;

      expect(left, isFalse);
      expect(dialogs.calls, isEmpty);
    });
  });

  group('the avatar (pano 9.2 kare 3)', () {
    test('opens the sheet on the avatar in use', () async {
      dialogs.avatar = null;
      build();

      await viewModel.changeAvatar();

      expect(dialogs.calls, ['avatar:0']);
    });

    test('from the reading view it opens the form first', () async {
      dialogs.avatar = 2;
      build();

      await viewModel.changeAvatar();

      expect(viewModel.mode, ProfileMode.edit);
      expect(viewModel.photo, '4avatarN3.png');
      expect(viewModel.bar.canSave, isTrue);
    });

    test('dismissing the sheet changes nothing, the form stays open', () async {
      dialogs.avatar = null;
      build();

      await viewModel.changeAvatar();

      expect(viewModel.mode, ProfileMode.edit);
      expect(viewModel.photo, '1avatarN3.png');
      expect(viewModel.bar.canSave, isFalse);
    });

    test('is saved with "Kaydet" as the file name', () async {
      dialogs.avatar = 1;
      backend.updateAnswer = studentJson(alparslan(photo: '3avatarN3.png'));
      user.refreshAnswer = alparslan(photo: '3avatarN3.png');
      build();
      await viewModel.changeAvatar();

      await viewModel.save();

      expect(backend.lastUpdateBody, {'photo': '3avatarN3.png'});
      expect(viewModel.photo, '3avatarN3.png');
    });

    test('an avatar outside the seven marks none in the sheet', () async {
      user = FakeUserService(alparslan(photo: 'user.png'));
      dialogs.avatar = null;
      build();

      await viewModel.changeAvatar();

      expect(dialogs.calls, ['avatar:null']);
    });
  });

  group('without an account', () {
    test('"Tekrar Dene" asks the server again', () async {
      user = FakeUserService(null);
      user.refreshAnswer = alparslan();
      build();

      await viewModel.retry();

      expect(user.refreshCalls, 1);
      expect(viewModel.hasUser, isTrue);
    });
  });
}
