import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/schedule/application/program_entry.dart';
import 'package:smap/features/schedule/presentation/sheets/topic_picker/topic_picker_viewmodel.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

import '../program_fixtures.dart';
import 'program_harness.dart';

void main() {
  late ProgramRig rig;

  setUp(() => rig = ProgramRig());
  tearDown(() => rig.dispose());

  TopicPickerViewModel build({
    Map<String, ProgramEntry> placements = const {},
  }) => TopicPickerViewModel(schedule: rig.schedule, placements: placements);

  test('Çantam is grouped by lesson with the bag items', () async {
    final viewModel = build();
    addTearDown(viewModel.dispose);

    await viewModel.init();

    expect(viewModel.bag.state, SectionState.ready);
    final group = viewModel.bag.data!.single;
    expect(group.lessonName, 'TYT Tarih');
    expect(group.choices.single.title, 'Tarih Biliminin Tanımı');
    expect(group.choices.single.itemId, 'i1');
  });

  test('an empty bag is the empty state', () async {
    rig.server.bag = [];
    final viewModel = build();
    addTearDown(viewModel.dispose);

    await viewModel.init();

    expect(viewModel.bag.state, SectionState.empty);
  });

  test('Dersler loads when its segment opens, once', () async {
    final viewModel = build();
    addTearDown(viewModel.dispose);
    await viewModel.init();
    expect(rig.server.subjectCalls, 0);

    await viewModel.setSource(TopicSource.lessons);
    await viewModel.setSource(TopicSource.bag);
    await viewModel.setSource(TopicSource.lessons);

    expect(rig.server.subjectCalls, 1);
    final groups = viewModel.lessons.data!;
    expect([for (final g in groups) g.lessonName], ['TYT Türkçe', 'TYT Tarih']);
    expect(groups.first.choices.map((c) => c.title), [
      'Noktalama İşaretleri',
      'Cümlenin Öğeleri',
    ]);
    expect(viewModel.shown, viewModel.lessons);
  });

  test('one radio choice, Ekle needs it', () async {
    final viewModel = build();
    addTearDown(viewModel.dispose);
    await viewModel.init();
    final choice = viewModel.bag.data!.single.choices.single;
    expect(viewModel.selected, isNull);

    viewModel.select(choice);

    expect(viewModel.selected, choice);
    expect(viewModel.isSelected(choice.key), isTrue);
    expect(viewModel.isSelected('lesson:other'), isFalse);
  });

  test(
    'a topic already in the program says where, and can be picked again',
    () async {
      final entry = ProgramEntry.of(ekimIkinciHaftaDraft().tasks[1]);
      final viewModel = build(placements: {entry.topicKey: entry});
      addTearDown(viewModel.dispose);
      await viewModel.init();
      await viewModel.setSource(TopicSource.lessons);

      final tarih = viewModel.lessons.data!.last.choices.single;
      final placed = viewModel.placedAt(tarih);

      expect(placed?.timeLabel, '14:00');
      viewModel.select(tarih);
      expect(viewModel.selected, tarih);
    },
  );

  test('a failed lesson load is an error and Tekrar Dene recovers', () async {
    final viewModel = build();
    addTearDown(viewModel.dispose);
    await viewModel.init();
    rig.server.failSubjects = true;

    await viewModel.setSource(TopicSource.lessons);
    expect(viewModel.lessons.state, SectionState.error);
    expect(viewModel.bag.state, SectionState.ready);

    rig.server.failSubjects = false;
    await viewModel.retry();
    expect(viewModel.lessons.state, SectionState.ready);
  });
}
