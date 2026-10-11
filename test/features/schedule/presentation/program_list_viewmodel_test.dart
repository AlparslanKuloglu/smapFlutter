import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/schedule/presentation/program_list/program_list_viewmodel.dart';

import '../program_fixtures.dart';
import 'program_harness.dart';

void main() {
  late ProgramRig rig;
  late ProgramListViewModel viewModel;

  ProgramListViewModel build() => ProgramListViewModel(
    schedule: rig.schedule,
    navigator: rig.navigator,
    online: rig.online,
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

  test('starts as the skeleton and shows the programs once loaded', () async {
    expect(viewModel.phase, ProgramListPhase.loading);

    await viewModel.load();

    expect(viewModel.phase, ProgramListPhase.content);
    final program = viewModel.visible.items.single;
    expect(program.name, 'Ekim 2. Hafta');
    expect(program.motto, 'Her gün biraz daha');
    expect(program.isThisWeek, isTrue);
    expect(program.span!.rangeLabel, '5–11 Ekim 2026');
  });

  test('a student with no program sees the empty state', () async {
    rig.server.weeklies = [];

    await viewModel.load();

    expect(viewModel.phase, ProgramListPhase.empty);
    expect(viewModel.canCreate, isTrue);
  });

  test('a failed first load is the error, and Tekrar Dene recovers', () async {
    rig.server.failList = true;

    await viewModel.load();
    expect(viewModel.phase, ProgramListPhase.error);

    rig.server.failList = false;
    await viewModel.retry();
    expect(viewModel.phase, ProgramListPhase.content);
  });

  test('a saved list stays on screen when a refresh fails', () async {
    await viewModel.load();
    rig.server.failList = true;

    await viewModel.load(force: true);

    expect(viewModel.phase, ProgramListPhase.content);
    expect(viewModel.visible.items, hasLength(1));
  });

  test('the search matches name and motto, folds Turkish letters', () async {
    await viewModel.load();

    viewModel.setQuery('  BİRAZ ');
    expect(viewModel.query, 'BİRAZ');
    expect(viewModel.visible.items, hasLength(1));

    viewModel.setQuery('kasım');
    expect(viewModel.visible.items, isEmpty);
    expect(viewModel.phase, ProgramListPhase.content);

    viewModel.setQuery('');
    expect(viewModel.visible.items, hasLength(1));
  });

  test('a row opens the program', () async {
    await viewModel.load();

    viewModel.openProgram(viewModel.visible.items.single);

    expect(rig.navigator.opened, ['w-ekim-2']);
  });

  test('Yeni Program opens the flow and then the program it returns', () async {
    await viewModel.load();
    rig.navigator.newFlowResult = 'w-created';

    await viewModel.startNewProgram();

    expect(rig.navigator.newFlows, 1);
    expect(rig.navigator.opened, ['w-created']);
  });

  test('a flow left without saving opens nothing', () async {
    await viewModel.load();

    await viewModel.startNewProgram();

    expect(rig.navigator.newFlows, 1);
    expect(rig.navigator.opened, isEmpty);
  });

  test('offline, Yeni Program is off and the saved list stays', () async {
    await viewModel.load();
    rig.online.value = false;

    expect(viewModel.online, isFalse);
    expect(viewModel.canCreateNow, isFalse);
    await viewModel.startNewProgram();

    expect(rig.navigator.newFlows, 0);
    expect(viewModel.phase, ProgramListPhase.content);
  });

  test('the connection coming back reloads a failed list', () async {
    rig.server.failList = true;
    await viewModel.load();
    expect(viewModel.phase, ProgramListPhase.error);

    rig.server.failList = false;
    rig.online.value = false;
    rig.online.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(viewModel.phase, ProgramListPhase.content);
  });

  test('a coach reads: no Yeni Program', () async {
    final readOnly = ProgramListViewModel(
      schedule: rig.schedule,
      navigator: rig.navigator,
      online: rig.online,
      readOnly: true,
      clock: () => rig.now,
    );
    addTearDown(readOnly.dispose);
    await readOnly.load();

    expect(readOnly.canCreate, isFalse);
    expect(readOnly.canCreateNow, isFalse);
  });

  test('a program saved elsewhere shows without a new load', () async {
    await viewModel.load();
    var notified = 0;
    viewModel.addListener(() => notified++);

    await rig.schedule.createWeekly(
      ekimIkinciHaftaDraft().copyWith(name: 'Ekim 3. Hafta'),
    );

    expect(notified, greaterThan(0));
    expect(viewModel.all.items.map((p) => p.name), contains('Ekim 3. Hafta'));
  });
}
