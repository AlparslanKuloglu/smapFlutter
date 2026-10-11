import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/features/lessons/application/lesson_category.dart';
import 'package:smap/features/lessons/application/lesson_rows.dart';
import 'package:smap/features/lessons/presentation/lessons/lessons_viewmodel.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

import '../../application/lesson_samples.dart';
import '../lessons_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LessonsHarness harness;
  late ValueNotifier<bool> online;
  late List<Uri> opened;
  late List<String> webSheets;
  var webAnswer = true;
  late LessonsViewModel viewModel;

  Future<LessonsViewModel> create({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final model = LessonsViewModel(
      lessons: harness.lessons,
      cards: harness.cards,
      preferences: harness.preferences,
      online: online,
      webUri: Uri.parse('https://www.smaptr.com'),
      navigator: harness.navigator,
      openUrl: (uri) async {
        opened.add(uri);
        return true;
      },
      webSheet: (row, host) async {
        webSheets.add('${row.name}@$host');
        return webAnswer;
      },
      timeout: timeout,
    );
    return model;
  }

  setUp(() async {
    harness = await LessonsHarness.create();
    online = ValueNotifier<bool>(true);
    opened = [];
    webSheets = [];
    webAnswer = true;
    viewModel = await create();
  });

  tearDown(() async {
    viewModel.dispose();
    online.dispose();
    await harness.dispose();
  });

  test('starts on the skeleton', () {
    expect(viewModel.list.state, SectionState.loading);
    expect(viewModel.examType, LessonsExamType.tyt);
  });

  test(
    'loads the TYT list with the counts and the Tarih card progress',
    () async {
      await viewModel.init();

      final list = viewModel.list;
      expect(list.state, SectionState.ready);
      expect(list.rows.map((r) => r.name), [
        'Türkçe',
        'Tarih',
        'Coğrafya',
        'Matematik',
        'Geometri',
        'Fizik',
        'Kimya',
        'Biyoloji',
      ]);
      expect(list.rows[0].missing, 28);
      expect(list.rows[1].missing, 60);
      // The deck counters arrive on the side.
      await pumpEventQueue();
      final tarih = viewModel.list.rows[1];
      expect((tarih.cardsKnown, tarih.cardsTotal), (41, 64));
    },
  );

  test('the card counters failing leaves the list without progress', () async {
    harness.backend.cardsFail = true;

    await viewModel.init();
    await pumpEventQueue();

    expect(viewModel.list.state, SectionState.ready);
    expect(viewModel.list.rows.every((r) => r.cardsTotal == null), isTrue);
  });

  test(
    'the segment switches the list and the choice is kept (karar 5.8)',
    () async {
      await viewModel.init();

      viewModel.selectExamType(LessonsExamType.ayt);

      expect(viewModel.examType, LessonsExamType.ayt);
      expect(viewModel.list.rows.first.nameKind, LessonRowName.literature);
      expect(
        harness.preferences.getString(DevicePreferences.lessonsExamTypeKey),
        'ayt',
      );

      final next = await create();
      expect(next.examType, LessonsExamType.ayt, reason: 'remembered');
      next.dispose();
    },
  );

  test(
    'offline the web-only lessons are hidden, online they come back',
    () async {
      await viewModel.init();
      expect(viewModel.list.rows.any((r) => r.webOnly), isTrue);

      online.value = false;
      expect(viewModel.list.rows.any((r) => r.webOnly), isFalse);

      online.value = true;
      expect(viewModel.list.rows.any((r) => r.webOnly), isTrue);
    },
  );

  test('a row opens Ders Detayı on its own category', () async {
    await viewModel.init();
    final tarih = viewModel.list.rows[1];

    await viewModel.openRow(tarih);

    expect(harness.navigator.calls, [
      'lesson:${generalLesson('Tarih').id}:tyt:null',
    ]);
  });

  test('Tarih-2 of the AYT list opens Tarih on SOS-2 (karar 5.8)', () async {
    await viewModel.init();
    viewModel.selectExamType(LessonsExamType.ayt);
    final sos2 = viewModel.list.rows.firstWhere(
      (r) => r.nameKind == LessonRowName.sos2 && r.name == 'Tarih',
    );

    await viewModel.openRow(sos2);

    expect(harness.navigator.calls.single.endsWith(':sos2:null'), isTrue);
  });

  group('a web-only row', () {
    test('opens the sheet; its button opens the site', () async {
      await viewModel.init();
      final matematik = viewModel.list.rows.firstWhere((r) => r.webOnly);

      await viewModel.openRow(matematik);

      expect(webSheets, ['Matematik@smaptr.com']);
      expect(opened, [Uri.parse('https://www.smaptr.com')]);
      expect(harness.navigator.calls, isEmpty);
    });

    test('"Tamam" opens nothing', () async {
      await viewModel.init();
      webAnswer = false;

      await viewModel.openRow(viewModel.list.rows.firstWhere((r) => r.webOnly));

      expect(opened, isEmpty);
    });
  });

  group('failures', () {
    test(
      'the lessons failing show the error state; "Tekrar Dene" reloads',
      () async {
        harness.backend.lessonsFail = true;

        await viewModel.init();
        expect(viewModel.list.state, SectionState.error);

        harness.backend.lessonsFail = false;
        final retry = viewModel.retry();
        expect(viewModel.list.state, SectionState.loading);
        await retry;
        expect(viewModel.list.state, SectionState.ready);
      },
    );

    test(
      'no answer in time shows the error state, a late one still fills it',
      () async {
        final slow = await create(timeout: const Duration(milliseconds: 30));
        final gate = harness.backend.gate = Completer<void>();

        await slow.init();
        expect(slow.list.state, SectionState.error);

        gate.complete();
        await pumpEventQueue(times: 50);
        expect(slow.list.state, SectionState.ready);
        slow.dispose();
      },
    );

    test('a learned item elsewhere lowers the count here at once', () async {
      await viewModel.init();
      expect(viewModel.list.rows[0].missing, 28);

      harness.lessons.markLearnedLocally(
        generalLesson('Türkçe').id,
        LessonTrack.tyt,
      );
      await pumpEventQueue();

      expect(viewModel.list.rows[0].missing, 27);
    });
  });
}
