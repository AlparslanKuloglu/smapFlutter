import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/features/lessons/application/literature_loader.dart';
import 'package:smap/features/lessons/application/literature_tree.dart';
import 'package:smap/features/lessons/data/lesson_content_repository.dart';

import '../../../core/network/fake_adapter.dart';
import '../../exams/data/data_harness.dart';
import 'literature_samples.dart';

void main() {
  late LiteratureServer server;
  late LiteratureLoader loader;

  setUp(() {
    server = LiteratureServer();
    loader = LiteratureLoader(
      LessonContentRepository(
        networkOver(
          FakeAdapter(
            (options) async =>
                await server.handle(options) ??
                jsonResponse({'error': 'no route'}, status: 404),
          ),
        ),
      ),
    );
  });

  group('eras (pano 14.5 kare 1)', () {
    test(
      'reads the eras in the server order with their missing counts',
      () async {
        final eras = (await loader.eras()).rightOrNull!;

        expect(eras.map((e) => (e.name, e.missing)), [
          ('Tanzimat Dönemi', 2),
          ('Servet-i Fünun Dönemi', 1),
          ('Fecr-i Âti', null),
          ('Millî Edebiyat Dönemi', null),
          ('Cumhuriyet Dönemi', null),
        ]);
        expect(sumMissing(eras.map((e) => e.missing)), 3);
      },
    );

    test('a failing request is the failure', () async {
      server.failEras = true;

      expect((await loader.eras()).leftOrNull, isNotNull);
    });

    test('no era carries a count: the total is unknown, not zero', () {
      expect(sumMissing([null, null]), isNull);
      expect(sumMissing([null, 2, 1]), 3);
      expect(sumMissing(const []), isNull);
    });
  });

  group('sub-subjects (pano 14.5 kare 2)', () {
    test(
      'reads them with their counts and what is listed under them',
      () async {
        final subs = (await loader.subs('m-tanzimat')).rightOrNull!;

        expect(subs.map((s) => (s.name, s.missing)), [
          ('Birinci Dönem Sanatçıları', 2),
          ('İkinci Dönem Sanatçıları', null),
        ]);
        expect(subs.first.items.single.id, 'grp-1');
      },
    );

    test('asks for the Yazar ve Eserler tree, not the topics', () async {
      await loader.subs('m-tanzimat');

      expect(
        server.asked,
        contains('/student/getItems?edebiyat=true&yazarEserMode=true'),
      );
    });

    test('an era without sub-subjects is an empty list', () async {
      expect((await loader.subs('m-fecr')).rightOrNull, isEmpty);
    });

    test('a failing request is the failure', () async {
      server.failSubsOf.add('m-tanzimat');

      expect((await loader.subs('m-tanzimat')).leftOrNull, isNotNull);
    });
  });

  group('authors (pano 14.5 kare 2 and 3)', () {
    Future<LiteratureSub> sub(String era, int index) async =>
        (await loader.subs(era)).rightOrNull![index];

    test('reads the authors of a sub-subject in the server order', () async {
      final authors = (await loader.authors(
        await sub('m-tanzimat', 0),
      )).rightOrNull!;

      expect(authors.map((a) => a.name), [
        'Namık Kemal',
        'Şinasi',
        'Ziya Paşa',
      ]);
      expect(authors.map((a) => (a.workCount, a.missingCount)), [
        (8, 2),
        (3, 0),
        (6, 0),
      ]);
    });

    test('asks only for the authors of the accordion that opened', () async {
      await loader.authors(await sub('m-tanzimat', 1));

      expect(
        server.asked.where((a) => a.startsWith('/student/getSubjectAuthors')),
        ['/student/getSubjectAuthors?itemId=grp-2'],
      );
    });

    test(
      'a failing request fails the whole list: no list with a hole',
      () async {
        server.failGroups.add('grp-1');

        final result = await loader.authors(await sub('m-tanzimat', 0));

        expect(result.leftOrNull, isNotNull);
      },
    );

    test('no connection is the offline failure', () async {
      final offline = LiteratureLoader(
        LessonContentRepository(networkOver(offlineAdapter())),
      );

      final result = await offline.eras();

      expect(result.leftOrNull?.code, AppErrorCode.offline);
    });
  });
}
