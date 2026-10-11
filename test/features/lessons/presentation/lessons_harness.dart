import 'dart:async';

import 'package:dio/dio.dart' show ResponseBody;
import 'package:flutter/foundation.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/features/cards/data/card_repository.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/features/lessons/application/lesson_category.dart';
import 'package:smap/features/lessons/application/lessons_service.dart';
import 'package:smap/features/lessons/data/lesson_content_repository.dart';
import 'package:smap/features/lessons/presentation/lessons_navigator.dart';
import 'package:smap/l10n/app_localizations_tr.dart';
import 'package:smap/shared/ui/feedback/toast_host.dart';
import 'package:smap/shared/ui/feedback/toast_slot.dart';

// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../../core/network/fake_adapter.dart';
import '../../exams/data/data_harness.dart';
import '../application/lesson_samples.dart';

/// Records where the screens lead.
class RecordingNavigator implements LessonsNavigator {
  final List<String> calls = [];

  @override
  Future<void> openLesson(
    String lessonId, {
    LessonCat? cat,
    LiteratureSection? section,
  }) async => calls.add('lesson:$lessonId:${cat?.key}:${section?.key}');

  @override
  Future<void> openTopic({
    required String lessonId,
    required String topicId,
    LessonCat? cat,
  }) async => calls.add('topic:$lessonId:$topicId:${cat?.key}');

  @override
  Future<void> openCardDeck({
    required String backendLessonId,
    required String lessonName,
  }) async => calls.add('deck:$backendLessonId:$lessonName');
}

class _Presenter implements ToastPresenter {
  @override
  bool screenReaderOn = false;

  @override
  bool present(ToastSlot slot, ValueListenable<double?> barHeight) => true;
}

/// The words of the toast on screen, `null` when none.
String? toastText(ToastService toast) =>
    toast.slot.current.value?.title(AppLocalizationsTr());

/// The `tytAyt`/`mindMap`/`edebiyat` flags as the server writes them.
Map<String, Object?> _generalLesson(GeneralLessonSpec spec) => {
  '_id': spec.id,
  'name': spec.name,
  'order': spec.order,
  'tytAyt': spec.hasTrackChoice ? 1 : 0,
  'mindMap': spec.isWebOnly ? 1 : 0,
  'edebiyat': spec.isLiterature ? 1 : 0,
};

/// A topic's items for `getItems`: "Temel Anlam" missing (record `p-1`),
/// "Yan Anlam" learned, "Mecaz Anlam" without a record.
List<Object?> _items() => [
  {
    '_id': 'i-1',
    'name': 'Temel Anlam',
    'desc': [
      'Bir sözcüğün akla gelen ilk anlamıdır.',
      'Örnek: Bazı insanlar karanlıktan korkar. (Cümledeki karanlık, '
          'ışıksız anlamında kullanılmıştır.)',
    ],
    'itemData': {
      '_id': 'p-1',
      'status': 0,
      'statusArray': [0],
    },
  },
  {
    '_id': 'i-2',
    'name': 'Yan Anlam',
    'itemData': {
      '_id': 'p-2',
      'status': 1,
      'statusArray': [1],
    },
  },
  {'_id': 'i-3', 'name': 'Mecaz Anlam'},
];

/// The server the lesson screens talk to, scripted per test.
class LessonsBackend {
  LessonsBackend() {
    final turkce = generalLesson('Türkçe').ids.single!;
    final tarih = generalLesson('Tarih').ids;
    topics = {
      turkce: [
        for (final (i, name) in [
          'Sözcükte Anlam',
          'Cümlede Anlam',
          'Ses Bilgisi',
          'Yazım Kuralları',
          'Anlatım Yöntemleri',
          'Paragraf',
          'Söz Öbekleri',
          'Cümlenin Öğeleri',
          'Fiilde Çatı',
          'Cümle Türleri',
          'Anlatım Bozuklukları',
          'Noktalama İşaretleri',
        ].indexed)
          ('t-${i + 1}', name),
      ],
      tarih.tyt!: [('h-1', 'İslamiyet Öncesi'), ('h-2', 'Osmanlı')],
      tarih.ayt!: [('a-1', 'AYT Tarih konusu')],
      tarih.sos2!: [
        ('s-1', 'İki Savaş Arasındaki Dönemde Türkiye ve Dünya'),
        ('s-2', 'İkinci Dünya Savaşı Sürecinde Türkiye ve Dünya'),
      ],
    };
    // Missing counts under filter 1 (TYT): topics 8, 9 and 12 (pano 7.2).
    byType = {
      turkce: {
        '1': {'t-8': 2, 't-9': 3, 't-12': 3},
      },
      tarih.sos2!: {'4': <String, int>{}},
    };
  }

  /// Topics per backend lesson (id and name, in order).
  late Map<String, List<(String, String)>> topics;

  /// `resultByType` per backend lesson: filter value to subject counts.
  late Map<String, Map<String, Map<String, int>>> byType;

  /// Missing counts per general lesson id (`getLessonsTotalMissing`).
  Map<String, Map<String, int>> missing = {
    generalLesson('Türkçe').id: {'1': 28, '2': 3},
    generalLesson('Tarih').id: {'1': 60, '3': 0},
    generalLesson('Fizik').id: {'1': 7, '2': 7},
  };

  /// Deck counters per exam lesson id.
  late Map<String, Map<String, int>> cards = {
    generalLesson('Tarih').ids.tyt!: {'missCount': 23, 'trueCount': 41},
  };

  bool lessonsFail = false;
  bool cardsFail = false;
  bool subjectsFail = false;
  bool contentFail = false;
  bool learnFail = false;
  bool favoriteFail = false;
  bool authorsFail = false;
  bool noItems = false;

  /// While set, every request waits for it.
  Completer<void>? gate;

  /// What was asked: the path with its query, in order.
  final List<String> asked = [];
  final List<String> learned = [];
  final List<String> favorited = [];

  int count(String path) => asked.where((a) => a.startsWith(path)).length;

  late final FakeAdapter adapter = FakeAdapter((options) async {
    final wait = gate;
    if (wait != null) await wait.future;
    final query = options.queryParameters;
    asked.add(
      '${options.path}${query.isEmpty ? '' : '?${query.entries.map((e) => '${e.key}=${e.value}').join('&')}'}',
    );
    ResponseBody failure() => jsonResponse({'success': false}, status: 500);
    switch (options.path) {
      case '/ajax/getGeneralLessons':
        return lessonsFail
            ? failure()
            : jsonResponse({
                'generalLessons': [
                  for (final spec in LessonCatalog.generalLessons)
                    _generalLesson(spec),
                ],
              });
      case '/student/getLessonsTotalMissing':
        return lessonsFail
            ? failure()
            : jsonResponse({'success': true, 'lessonObj': missing});
      case '/student/getInfoCardsInfo':
        return cardsFail
            ? failure()
            : jsonResponse({
                'success': true,
                'infoData': {'infoObj': cards},
              });
      case '/student/mainSubjects':
        if (subjectsFail) return failure();
        final id = query['lessonId'] as String;
        return jsonResponse({
          'success': true,
          'filterObjs': [
            {'name': 'TYT', 'value': 1},
            {'name': 'AYT', 'value': 2},
          ],
          'subjects': [
            for (final (topicId, name)
                in topics[id] ?? const <(String, String)>[])
              {'_id': topicId, 'name': name},
          ],
          'resultByType': byType[id] ?? <String, Object?>{},
        });
      case '/student/getSubSubjects':
        return contentFail
            ? failure()
            : jsonResponse({
                'success': true,
                'subSubjects': [
                  {'_id': 'ss-1', 'name': 'Anlamı Yönünden Sözcükler'},
                ],
              });
      case '/student/getItems':
        return jsonResponse({
          'success': true,
          'itemsArray': [noItems ? <Object?>[] : _items()],
        });
      case '/student/learnedItem':
        final id = query['itemId'] as String;
        if (learnFail) return failure();
        learned.add(id);
        return jsonResponse({'success': true});
      case '/student/addFavoriteMobil':
        final id = query['item'] as String;
        if (favoriteFail) return failure();
        favorited.add(id);
        return jsonResponse({'success': true});
    }
    return jsonResponse({'error': 'no route'}, status: 404);
  });
}

/// Everything a lesson ViewModel needs, over one [LessonsBackend].
class LessonsHarness {
  LessonsHarness._(this.backend, this.preferences);

  static Future<LessonsHarness> create({
    LessonsBackend? backend,
    Map<String, Object> prefs = const {},
  }) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData(prefs);
    final harness = LessonsHarness._(
      backend ?? LessonsBackend(),
      await DevicePreferences.load(),
    );
    harness.network = networkOver(harness.backend.adapter);
    harness.content = LessonContentRepository(harness.network);
    harness.cards = CardRepository(harness.network);
    harness.lessons = LessonsService(repository: harness.content);
    return harness;
  }

  final LessonsBackend backend;
  final DevicePreferences preferences;
  late NetworkService network;
  late LessonContentRepository content;
  late CardRepository cards;
  late LessonsService lessons;
  final RecordingNavigator navigator = RecordingNavigator();
  final ToastService toast = ToastService(presenter: _Presenter());

  Future<void> dispose() async {
    lessons.dispose();
    network.dispose();
    toast.dispose();
  }
}

/// Teaches a [LessonsBackend] the Yazar ve Eserler tree: one era with
/// Namık Kemal (two missing works) and Şinasi (no works).
class LiteratureBackendHooks {
  LiteratureBackendHooks(this.harness);

  final LessonsHarness harness;

  void install() {
    final base = harness.backend.adapter;
    final backend = harness.backend;
    final adapter = FakeAdapter((options) async {
      final failAuthors = backend.authorsFail;
      switch (options.path) {
        case '/student/yazarEserMainSubjects':
          if (failAuthors) {
            return jsonResponse({'success': false}, status: 500);
          }
          return jsonResponse({
            'success': true,
            'mainSubjects': [
              {'_id': 'm-1', 'name': 'Edebi Dönemler'},
            ],
          });
        case '/student/getSubSubjects'
            when options.queryParameters['mainSubjectId'] == 'm-1':
          return jsonResponse({
            'success': true,
            'subSubjects': [
              {'_id': 'ss-era', 'name': 'Batı Etkisinde Gelişen Edebiyat'},
            ],
          });
        case '/student/getItems'
            when options.queryParameters['yazarEserMode'] == 'true':
          return jsonResponse({
            'success': true,
            'itemsArray': [
              [
                {'_id': 'era-1', 'name': 'Tanzimat'},
              ],
            ],
          });
        case '/student/getSubjectAuthors':
          return jsonResponse({
            'success': true,
            'authors': [
              {
                '_id': 'au-nk',
                'name': 'Namık Kemal',
                'itsYazar': 1,
                'yazarCategory': 'era-1',
                'works': [
                  {
                    'eser': 'İntibah',
                    'type': '2',
                    'itemData': {
                      '_id': 'w-1',
                      'status': 1,
                      'statusArray': [1],
                    },
                  },
                  {
                    'eser': 'Vatan yahut Silistre',
                    'type': '6',
                    'itemData': {
                      '_id': 'w-3',
                      'status': 0,
                      'statusArray': [0],
                    },
                  },
                  {
                    'eser': 'Gülnihal',
                    'type': '6',
                    'itemData': {
                      '_id': 'w-4',
                      'status': 0,
                      'statusArray': [0],
                    },
                  },
                ],
              },
              {
                '_id': 'au-s',
                'name': 'Şinasi',
                'itsYazar': 1,
                'yazarCategory': 'era-1',
                'works': <Object>[],
              },
            ],
          });
      }
      return base.handler(options);
    });
    harness.network.dispose();
    harness.network = networkOver(adapter);
    harness.content = LessonContentRepository(harness.network);
    harness.cards = CardRepository(harness.network);
    harness.lessons.dispose();
    harness.lessons = LessonsService(repository: harness.content);
  }
}
