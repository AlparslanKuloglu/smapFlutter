import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/schedule/presentation/new_program/new_program_viewmodel.dart';
import 'package:smap/shared/ui/feedback/toast_slot.dart';

import 'program_harness.dart';

void main() {
  late ProgramRig rig;
  late NewProgramViewModel viewModel;

  setUp(() {
    rig = ProgramRig(server: ProgramServer(weeklies: []));
    viewModel = NewProgramViewModel(
      schedule: rig.schedule,
      toast: rig.toast,
      dialogs: rig.dialogs,
      navigator: rig.navigator,
      online: rig.online,
      defaultName: (month, week) => '$month $week. Hafta',
      clock: () => rig.now,
    );
  });

  tearDown(() {
    viewModel.dispose();
    rig.dispose();
  });

  void chooseDays() {
    for (var d = 12; d <= 17; d++) {
      viewModel.toggleDay(DateTime(2026, 10, d));
    }
  }

  Future<void> placeNoktalama({int hour = 10}) async {
    rig.dialogs.topic = noktalamaChoice();
    await viewModel.placeTopic(hour);
  }

  group('step 1: days', () {
    test('several days, oldest first, a second tap drops one', () {
      viewModel.toggleDay(DateTime(2026, 10, 14));
      viewModel.toggleDay(DateTime(2026, 10, 12));
      viewModel.toggleDay(DateTime(2026, 10, 13));
      expect(viewModel.days, [
        DateTime(2026, 10, 12),
        DateTime(2026, 10, 13),
        DateTime(2026, 10, 14),
      ]);

      viewModel.toggleDay(DateTime(2026, 10, 13));
      expect(viewModel.days, [DateTime(2026, 10, 12), DateTime(2026, 10, 14)]);
    });

    test('past days cannot be chosen, today can', () {
      viewModel.toggleDay(DateTime(2026, 10, 9));
      expect(viewModel.days, isEmpty);

      viewModel.toggleDay(DateTime(2026, 10, 10, 23));
      expect(viewModel.days, [DateTime(2026, 10, 10)]);
    });

    test('Devam Et needs a day', () {
      expect(viewModel.canContinue, isFalse);
      viewModel.next();
      expect(viewModel.step, NewProgramStep.days);

      chooseDays();
      expect(viewModel.canContinue, isTrue);
      viewModel.next();
      expect(viewModel.step, NewProgramStep.grid);
      expect(viewModel.gridDay, DateTime(2026, 10, 12));
    });

    test('the summary reads from the real choice', () {
      chooseDays();

      expect(viewModel.summary.range, '12–17 Ekim 2026');
      expect(viewModel.summary.dayCount, 6);
      expect(viewModel.summary.studyCount, 0);
    });
  });

  group('step 2: grid', () {
    setUp(() {
      chooseDays();
      viewModel.next();
    });

    test('a topic dropped on an empty hour is placed', () async {
      await placeNoktalama();

      expect(viewModel.entriesOn(DateTime(2026, 10, 12)), hasLength(1));
      expect(viewModel.countOn(DateTime(2026, 10, 12)), 1);
      expect(viewModel.entries.single.timeLabel, '10:00');
    });

    test('a dismissed topic sheet places nothing', () async {
      rig.dialogs.topic = null;

      await viewModel.placeTopic(10);

      expect(viewModel.entries, isEmpty);
    });

    test('an hour that already has a topic is not asked again', () async {
      await placeNoktalama();
      rig.dialogs.lastPlacements = null;

      await placeNoktalama();

      expect(viewModel.entries, hasLength(1));
      expect(rig.dialogs.lastPlacements, isNull);
    });

    test('the sheet is told where each topic already sits', () async {
      await placeNoktalama();
      viewModel.selectGridDay(DateTime(2026, 10, 13));

      await placeNoktalama(hour: 15);

      final sat = rig.dialogs.lastPlacements!.values.single;
      expect(sat.day, DateTime(2026, 10, 12));
      expect(sat.timeLabel, '10:00');
    });

    test('the X takes a topic out', () async {
      await placeNoktalama();

      viewModel.removeEntry(viewModel.entries.single);

      expect(viewModel.entries, isEmpty);
    });

    test('Devam Et needs a topic', () async {
      expect(viewModel.canContinue, isFalse);

      await placeNoktalama();

      expect(viewModel.canContinue, isTrue);
    });

    test('taking a day out of the choice takes its topics along', () async {
      await placeNoktalama();

      viewModel.back();
      viewModel.toggleDay(DateTime(2026, 10, 12));

      expect(viewModel.entries, isEmpty);
    });

    test('going back keeps the choices', () async {
      await placeNoktalama();

      expect(viewModel.back(), isTrue);
      expect(viewModel.step, NewProgramStep.days);
      expect(viewModel.days, hasLength(6));
      viewModel.next();

      expect(viewModel.entries, hasLength(1));
    });
  });

  group('step 3: name and save', () {
    setUp(() async {
      chooseDays();
      viewModel.next();
      await placeNoktalama();
      viewModel.next();
    });

    test('the name starts as the suggestion for the first day', () {
      expect(viewModel.step, NewProgramStep.name);
      expect(viewModel.name, 'Ekim 3. Hafta');
    });

    test('the summary says what was placed and what is empty', () {
      final summary = viewModel.summary;
      expect(summary.studyCount, 1);
      expect(summary.onlyDay, DateTime(2026, 10, 12));
      expect(summary.emptyDays.length, 5);
    });

    test('saving creates the program, toasts and closes with its id', () async {
      viewModel.setName('Ekim 3. Hafta');
      viewModel.setMotto('Her gün biraz daha');

      await viewModel.save();

      final sent = rig.server.adds.single;
      expect(sent['name'], 'Ekim 3. Hafta');
      expect(sent['motto'], 'Her gün biraz daha');
      expect((sent['tasks'] as List).single['title'], 'Noktalama İşaretleri');
      expect(rig.navigator.closed, isTrue);
      expect(rig.navigator.closedWith, 'w-new-1');
      expect(rig.toastText, 'Program kaydedildi.');
      expect(rig.toastKind, AppToastKind.success);
    });

    test('an empty name is not sent', () async {
      viewModel.setName('   ');

      await viewModel.save();

      expect(viewModel.nameError, isTrue);
      expect(rig.server.adds, isEmpty);
      expect(rig.navigator.closed, isFalse);

      viewModel.setName('Bir ad');
      expect(viewModel.nameError, isFalse);
    });

    test('a failed save toasts and keeps the form', () async {
      final failing = ProgramRig(server: ProgramServer(weeklies: []));
      addTearDown(failing.dispose);
      failing.server.failWrites = true;
      final vm = NewProgramViewModel(
        schedule: failing.schedule,
        toast: failing.toast,
        dialogs: failing.dialogs,
        navigator: failing.navigator,
        online: failing.online,
        defaultName: (m, w) => '$m $w',
        clock: () => failing.now,
      );
      addTearDown(vm.dispose);
      vm.toggleDay(DateTime(2026, 10, 12));
      vm.next();
      failing.dialogs.topic = noktalamaChoice();
      await vm.placeTopic(9);
      vm.next();

      await vm.save();

      expect(
        failing.toastText,
        'Kaydedilemedi. Bağlantını kontrol edip tekrar dene.',
      );
      expect(failing.toastKind, AppToastKind.error);
      expect(failing.navigator.closed, isFalse);
      expect(vm.saving, isFalse);
      expect(vm.name, isNotEmpty);
      expect(vm.entries, hasLength(1));
    });
  });

  group('leaving', () {
    test('nothing entered: closes without asking', () async {
      await viewModel.requestClose();

      expect(rig.dialogs.discardAsked, 0);
      expect(rig.navigator.closed, isTrue);
      expect(viewModel.interceptsBack, isFalse);
    });

    test('with changes it asks, and Vazgeç keeps the flow', () async {
      chooseDays();
      rig.dialogs.discardAnswer = false;

      await viewModel.requestClose();

      expect(rig.dialogs.discardAsked, 1);
      expect(rig.navigator.closed, isFalse);
      expect(viewModel.interceptsBack, isTrue);
    });

    test('with changes and a yes it closes', () async {
      chooseDays();

      await viewModel.requestClose();

      expect(rig.navigator.closed, isTrue);
      expect(rig.navigator.closedWith, isNull);
    });

    test('back on the first step is left to the caller', () {
      expect(viewModel.back(), isFalse);
    });
  });
}
