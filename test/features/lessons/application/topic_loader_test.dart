import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/features/lessons/application/lesson_category.dart';
import 'package:smap/features/lessons/application/topic_loader.dart';
import 'package:smap/features/lessons/data/lesson_content_repository.dart';

import '../../../core/network/fake_adapter.dart';
import '../../exams/data/data_harness.dart';
import 'lesson_samples.dart';

/// A backend that lists topics per backend lesson and answers the content of
/// any topic.
class _TopicBackend {
  _TopicBackend(this.topics, {this.failLesson});

  /// Backend lesson id to its topics (id to name), in order.
  final Map<String, List<(String, String)>> topics;
  final String? failLesson;
  final List<String> asked = [];
  Object? itemsQuery;

  late final FakeAdapter adapter = FakeAdapter((options) {
    switch (options.path) {
      case '/student/mainSubjects':
        final lesson = options.queryParameters['lessonId'] as String;
        asked.add(lesson);
        if (lesson == failLesson) {
          return jsonResponse({'success': false}, status: 500);
        }
        return jsonResponse({
          'success': true,
          'subjects': [
            for (final (id, name)
                in topics[lesson] ?? const <(String, String)>[])
              {'_id': id, 'name': name},
          ],
        });
      case '/student/getSubSubjects':
        return jsonResponse({
          'success': true,
          'subSubjects': [
            {'_id': 'ss-1', 'name': 'Alt başlık'},
          ],
        });
      case '/student/getItems':
        itemsQuery = options.queryParameters['type'];
        return jsonResponse({
          'success': true,
          'itemsArray': [
            [
              {'_id': 'i-1', 'name': 'Madde'},
            ],
          ],
        });
    }
    return jsonResponse({'error': 'no route'}, status: 404);
  });
}

void main() {
  final tarih = generalLesson('Tarih');
  final turkce = generalLesson('Türkçe');

  TopicLoader loaderOver(_TopicBackend backend) =>
      TopicLoader(LessonContentRepository(networkOver(backend.adapter)));

  group('TopicLoader.targets', () {
    test('a lesson with tracks starts at the track of the link', () {
      final targets = TopicLoader.targets(
        tarih,
        cat: LessonCat.sos2,
        saved: LessonCat.tyt,
      );
      expect(targets.map((t) => (t.cat, t.typeValue, t.backendLessonId)), [
        (LessonCat.sos2, 4, tarih.ids.sos2),
        (LessonCat.tyt, 1, tarih.ids.tyt),
        (LessonCat.ayt, 3, tarih.ids.ayt),
      ]);
    });

    test('without a category it starts at the device exam type', () {
      final targets = TopicLoader.targets(tarih, saved: LessonCat.ayt);
      expect(targets.first.cat, LessonCat.ayt);
    });

    test('a track the lesson does not have falls back to its first track', () {
      final fizik = generalLesson('Fizik');
      final targets = TopicLoader.targets(
        fizik,
        cat: LessonCat.sos2,
        saved: LessonCat.tyt,
      );
      expect(targets.map((t) => t.cat), [LessonCat.tyt, LessonCat.ayt]);
      expect(targets.map((t) => t.typeValue), [1, 2]);
    });

    test(
      '"Tümü" on a lesson with tracks is no choice: the device type wins',
      () {
        final targets = TopicLoader.targets(
          tarih,
          cat: LessonCat.all,
          saved: LessonCat.ayt,
        );
        expect(targets.first.cat, LessonCat.ayt);
      },
    );

    test(
      'a lesson without tracks has one place: "Tümü" without a category',
      () {
        final targets = TopicLoader.targets(turkce, saved: LessonCat.ayt);
        expect(targets, [
          TopicTarget(
            backendLessonId: turkce.ids.single!,
            typeValue: 9,
            cat: LessonCat.all,
          ),
        ]);
      },
    );

    test('a lesson without tracks reads the category of the link', () {
      expect(
        TopicLoader.targets(
          turkce,
          cat: LessonCat.tyt,
          saved: LessonCat.ayt,
        ).single.typeValue,
        1,
      );
      expect(
        TopicLoader.targets(
          turkce,
          cat: LessonCat.ayt,
          saved: LessonCat.tyt,
        ).single.typeValue,
        2,
      );
    });
  });

  group('TopicLoader.load', () {
    test(
      'reads the topic under its track and numbers it in its list',
      () async {
        final backend = _TopicBackend({
          tarih.ids.sos2!: [('t-1', 'Bir'), ('t-2', 'İkinci Dünya Savaşı')],
        });

        final content = (await loaderOver(backend).load(
          lesson: tarih,
          topicId: 't-2',
          cat: LessonCat.sos2,
          saved: LessonCat.tyt,
        )).rightOrNull!;

        expect(content.topicName, 'İkinci Dünya Savaşı');
        expect(content.number, 2);
        expect(content.cat, LessonCat.sos2);
        expect(content.subSubjects.single.items.single.name, 'Madde');
        expect(backend.itemsQuery, 4);
        expect(backend.asked, [tarih.ids.sos2]);
      },
    );

    test('tries the other tracks when the topic is not in the first', () async {
      final backend = _TopicBackend({
        tarih.ids.tyt!: [('t-1', 'TYT konusu')],
        tarih.ids.ayt!: [('t-9', 'AYT konusu')],
      });

      final content = (await loaderOver(
        backend,
      ).load(lesson: tarih, topicId: 't-9', saved: LessonCat.tyt)).rightOrNull!;

      expect(content.cat, LessonCat.ayt);
      expect(backend.itemsQuery, 3, reason: 'AYT of a lesson with SOS-2');
      expect(backend.asked, [tarih.ids.tyt, tarih.ids.ayt]);
    });

    test('a topic that no track lists is not found', () async {
      final backend = _TopicBackend({
        tarih.ids.tyt!: [('t-1', 'Bir')],
      });

      final result = await loaderOver(
        backend,
      ).load(lesson: tarih, topicId: 'nope', saved: LessonCat.tyt);

      expect(result.leftOrNull?.code, AppErrorCode.notFound);
    });

    test(
      'a failing request is the failure; the next track is not tried',
      () async {
        final backend = _TopicBackend({}, failLesson: tarih.ids.tyt);

        final result = await loaderOver(
          backend,
        ).load(lesson: tarih, topicId: 't-1', saved: LessonCat.tyt);

        expect(result.leftOrNull, isNotNull);
        expect(result.leftOrNull?.code, isNot(AppErrorCode.notFound));
        expect(backend.asked, [tarih.ids.tyt]);
      },
    );

    test('a lesson without tracks reads "Tümü" without a category', () async {
      final backend = _TopicBackend({
        turkce.ids.single!: [('k-1', 'Sözcükte Anlam')],
      });

      final content = (await loaderOver(backend).load(
        lesson: turkce,
        topicId: 'k-1',
        saved: LessonCat.tyt,
      )).rightOrNull!;

      expect(content.cat, LessonCat.all);
      expect(content.number, 1);
      expect(backend.itemsQuery, 9);
    });
  });
}
