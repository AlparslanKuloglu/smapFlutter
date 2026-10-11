import 'dart:async';

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/schedule/application/program_view_preference.dart';
import 'package:smap/features/schedule/presentation/program_detail/program_detail_viewmodel.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/feedback/toast_slot.dart';

import 'program_harness.dart';

void main() {
  late ProgramRig rig;
  late ProgramDetailViewModel viewModel;

  ProgramDetailViewModel build({
    String id = 'w-ekim-2',
    bool readOnly = false,
    ProgramViewMode? mode,
    DateTime? day,
    ProgramViewPreference? preference,
  }) => ProgramDetailViewModel(
    programId: id,
    schedule: rig.schedule,
    toast: rig.toast,
    dialogs: rig.dialogs,
    navigator: rig.navigator,
    online: rig.online,
    preference: preference ?? ProgramViewPreference(),
    readOnly: readOnly,
    requestedMode: mode,
    requestedDay: day,
    clock: () => rig.now,
  );

  setUp(() {
    rig = ProgramRig();
    viewModel = build();
  });

  tearDown(() {
    viewModel.dispose();
    rig.dispose();
  });

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 30));

  group('loading', () {
    test('shows the board program on today, in the Gün view', () async {
      expect(viewModel.section.state, SectionState.loading);

      await viewModel.load();

      expect(viewModel.section.state, SectionState.ready);
      expect(viewModel.detail!.name, 'Ekim 2. Hafta');
      expect(viewModel.detail!.span.rangeLabel, '5–11 Ekim 2026');
      expect(viewModel.selectedDay, DateTime(2026, 10, 10));
      expect(viewModel.mode, ProgramViewMode.day);
      expect(viewModel.detail!.countOn(viewModel.selectedDay), 3);
    });

    test('opens on the requested day and view', () async {
      final asked = build(
        mode: ProgramViewMode.week,
        day: DateTime(2026, 10, 8),
      );
      addTearDown(asked.dispose);

      await asked.load();

      expect(asked.mode, ProgramViewMode.week);
      expect(asked.selectedDay, DateTime(2026, 10, 8));
    });

    test('a program the server does not list is an error', () async {
      final missing = build(id: 'nope');
      addTearDown(missing.dispose);

      await missing.load();

      expect(missing.section.state, SectionState.error);
    });

    test('a failed load is an error and Tekrar Dene loads', () async {
      rig.server.failList = true;
      await viewModel.load();
      expect(viewModel.section.state, SectionState.error);

      rig.server.failList = false;
      await viewModel.retry();
      expect(viewModel.section.state, SectionState.ready);
    });

    test('the Gün / Hafta choice is remembered', () async {
      final preference = ProgramViewPreference();
      final first = build(preference: preference);
      addTearDown(first.dispose);
      await first.load();

      first.setMode(ProgramViewMode.week);
      final second = build(preference: preference);
      addTearDown(second.dispose);

      expect(second.mode, ProgramViewMode.week);
      expect(preference.persists, isFalse);
    });
  });

  group('edit mode', () {
    setUp(() async => viewModel.load());

    test('Düzenle opens it on the Gün view, Bitti only closes it', () async {
      viewModel.setMode(ProgramViewMode.week);

      viewModel.startEditing();
      expect(viewModel.editing, isTrue);
      expect(viewModel.mode, ProgramViewMode.day);

      viewModel.finishEditing();
      expect(viewModel.editing, isFalse);
      expect(rig.server.updates, isEmpty);
    });

    test('switching to Hafta closes edit mode', () {
      viewModel.startEditing();

      viewModel.setMode(ProgramViewMode.week);

      expect(viewModel.editing, isFalse);
    });

    test('a coach cannot edit', () async {
      final coach = build(readOnly: true);
      addTearDown(coach.dispose);
      await coach.load();

      coach.startEditing();
      coach.removeEntry(coach.detail!.entries.first);

      expect(coach.editing, isFalse);
      expect(coach.canEdit, isFalse);
      expect(rig.server.updates, isEmpty);
    });

    test('offline, editing is off', () {
      rig.online.value = false;

      viewModel.startEditing();

      expect(viewModel.canEditNow, isFalse);
      expect(viewModel.editing, isFalse);
    });

    test('Programı İptal Et is not offered: flag closed, no delete call', () {
      expect(viewModel.canCancel, isFalse);
    });
  });

  group('instant save', () {
    setUp(() async => viewModel.load());

    test('removing a topic saves at once and offers Geri Al', () async {
      final fiil = viewModel.detail!.entries.first;

      viewModel.removeEntry(fiil);
      expect(viewModel.detail!.entries, hasLength(2));
      await settle();

      expect(rig.server.lastTasks, [
        '2026-10-10 14:00 Kurtuluş Savaşı Hazırlık Dönemi',
        '2026-10-10 20:00 İklim Bilgisi',
      ]);
      expect(rig.toastText, 'Konu çıkarıldı.');
      expect(rig.toastKind, AppToastKind.success);
    });

    test('Geri Al puts the topic back and saves it', () async {
      viewModel.removeEntry(viewModel.detail!.entries.first);
      await settle();

      rig.undo();
      await settle();

      expect(viewModel.detail!.entries, hasLength(3));
      expect(rig.server.lastTasks, hasLength(3));
      expect(rig.server.lastTasks, contains('2026-10-10 10:00 Fiilde Çatı'));
    });

    test('a new time is saved', () async {
      rig.dialogs.time = const TimeOfDay(hour: 11, minute: 30);

      await viewModel.changeTime(viewModel.detail!.entries.first);
      await settle();

      expect(rig.server.lastTasks.first, '2026-10-10 11:30 Fiilde Çatı');
      expect(viewModel.detail!.entries.first.timeLabel, '11:30');
    });

    test('a dismissed time wheel changes nothing', () async {
      await viewModel.changeTime(viewModel.detail!.entries.first);
      await settle();

      expect(rig.server.updates, isEmpty);
    });

    test('a topic from the hour grid is saved on the selected day', () async {
      rig.dialogs.slot = (hour: 16, choice: noktalamaChoice());
      viewModel.selectDay(DateTime(2026, 10, 12));

      await viewModel.addTopic();
      await settle();

      expect(
        rig.server.lastTasks,
        contains('2026-10-12 16:00 Noktalama İşaretleri'),
      );
      expect(viewModel.detail!.countOn(DateTime(2026, 10, 12)), 1);
      expect(viewModel.detail!.span.days, hasLength(14));
    });

    test('the program knows where its topics already sit', () async {
      rig.dialogs.slot = null;

      await viewModel.addTopic();

      final placements = rig.dialogs.lastPlacements!;
      expect(placements.length, 3);
      expect(placements.values.map((e) => e.timeLabel), contains('14:00'));
    });

    test('a failed save goes back to the saved state and says so', () async {
      rig.server.failWrites = true;

      viewModel.removeEntry(viewModel.detail!.entries.first);
      await settle();

      expect(viewModel.detail!.entries, hasLength(3));
      expect(
        rig.toastText,
        'Kaydedilemedi. Bağlantını kontrol edip tekrar dene.',
      );
      expect(rig.toastKind, AppToastKind.error);
    });

    test('a save that is still running does not lose later changes', () async {
      final hold = Completer<void>();
      rig.server.holdWrites = hold;
      final first = viewModel.detail!.entries[0];
      final second = viewModel.detail!.entries[1];

      viewModel.removeEntry(first);
      await settle();
      viewModel.removeEntry(second);
      rig.server.holdWrites = null;
      hold.complete();
      await settle();
      await settle();

      expect(rig.server.lastTasks, ['2026-10-10 20:00 İklim Bilgisi']);
      expect(viewModel.detail!.entries, hasLength(1));
    });

    test('changes made one after the other all arrive', () async {
      final first = viewModel.detail!.entries[0];
      final second = viewModel.detail!.entries[1];

      viewModel.removeEntry(first);
      viewModel.removeEntry(second);
      await settle();
      await settle();

      expect(rig.server.lastTasks, ['2026-10-10 20:00 İklim Bilgisi']);
      expect(viewModel.detail!.entries, hasLength(1));
    });
  });

  group('Günü Sıfırla', () {
    setUp(() async => viewModel.load());

    test(
      'asks first, then empties the day and keeps it in the strip',
      () async {
        await viewModel.resetDay();
        await settle();

        expect(rig.dialogs.resetAsked, 1);
        expect(rig.dialogs.resetDay, DateTime(2026, 10, 10));
        expect(rig.dialogs.resetCount, 3);
        expect(viewModel.detail!.countOn(DateTime(2026, 10, 10)), 0);
        expect(viewModel.detail!.days, hasLength(7));
        expect(rig.server.lastTasks, isEmpty);
        expect(rig.toastText, 'Cumartesi sıfırlandı.');
      },
    );

    test('Vazgeç leaves the day alone', () async {
      rig.dialogs.resetAnswer = false;

      await viewModel.resetDay();
      await settle();

      expect(viewModel.detail!.entries, hasLength(3));
      expect(rig.server.updates, isEmpty);
      expect(rig.toastText, isNull);
    });

    test('Geri Al brings the three topics back', () async {
      await viewModel.resetDay();
      await settle();

      rig.undo();
      await settle();

      expect(viewModel.detail!.entries, hasLength(3));
      expect(rig.server.lastTasks, hasLength(3));
    });

    test('an empty day is not asked about', () async {
      viewModel.selectDay(DateTime(2026, 10, 9));

      await viewModel.resetDay();

      expect(rig.dialogs.resetAsked, 0);
    });
  });
}
