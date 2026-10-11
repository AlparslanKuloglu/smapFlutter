import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/cards/data/card_repository.dart';
import 'package:smap/features/cards/data/dtos/card_answers.dart';
import 'package:smap/features/cards/data/mappers/card_mappers.dart';

import '../../../core/network/fake_adapter.dart';
import '../../exams/data/data_harness.dart';
import 'card_fixtures.dart';

void main() {
  NetworkService? network;

  CardRepository repositoryOver(FakeAdapter adapter) {
    network = networkOver(adapter);
    return CardRepository(network!);
  }

  tearDown(() => network?.dispose());

  group('card counts', () {
    test('reads the three counters of every lesson', () {
      final totals = InfoCardsInfoResponse.fromBody(
        cardsInfoAnswer(),
      ).toDomain();

      final turkce = totals.of('663e37a24fb443839593141b')!;
      expect(turkce.missCount, 12);
      expect(turkce.trueCount, 30);
      expect(turkce.favoriteCount, 2);
      final tarih = totals.of('66214a6982ff212039ea3294')!;
      expect(tarih.missCount, 0);
      expect(tarih.trueCount, isNull, reason: 'not sent: unknown, not zero');
      expect(totals.of('other'), isNull);
      expect(totals.totalMissing, 12);
    });

    test('an answer without counters is empty', () {
      for (final body in <Object?>[
        {'success': true},
        {'success': true, 'infoData': 'x'},
        {
          'success': true,
          'infoData': {'infoObj': <String, Object?>{}},
        },
        {
          'success': true,
          'infoData': {
            'infoObj': {'a': 'x'},
          },
        },
      ]) {
        final totals = InfoCardsInfoResponse.fromBody(body).toDomain();
        expect(totals.totalMissing, 0, reason: '$body');
      }
      expect(InfoCardsInfoResponse.fromBody(null).toDomain().byLesson, isEmpty);
    });

    test('getTotals asks the endpoint and sends the student id', () async {
      final adapter = FakeAdapter.json(cardsInfoAnswer());
      final repository = repositoryOver(adapter);

      final totals = (await repository.getTotals(
        studentId: 'stu',
      )).rightOrNull!;

      expect(totals.byLesson, hasLength(2));
      expect(adapter.last.method, 'GET');
      expect(adapter.last.path, '/student/getInfoCardsInfo');
      expect(adapter.last.queryParameters, {'studentId': 'stu'});
    });

    test('getTotals failures are values', () async {
      var repository = repositoryOver(FakeAdapter.json({'success': false}));
      expect(
        (await repository.getTotals()).leftOrNull?.code,
        AppErrorCode.validation,
      );
      network!.dispose();

      repository = repositoryOver(
        FakeAdapter((_) => textResponse('', contentType: 'text/plain')),
      );
      expect(
        (await repository.getTotals()).leftOrNull?.code,
        AppErrorCode.server,
      );
      network!.dispose();

      repository = repositoryOver(offlineAdapter());
      expect(
        (await repository.getTotals()).leftOrNull?.code,
        AppErrorCode.offline,
      );
    });
  });

  group('lesson decks', () {
    test('reads the three decks', () async {
      final adapter = FakeAdapter.json(lessonCardsAnswer());
      final repository = repositoryOver(adapter);

      final decks = (await repository.getLessonDecks(
        lessonId: '66214a6982ff212039ea3294',
      )).rightOrNull!;

      expect(adapter.last.path, '/student/getLessonInfoCards');
      expect(adapter.last.queryParameters, {
        'lesson': '66214a6982ff212039ea3294',
      });
      expect(decks.missing.map((c) => c.itemId), ['item-1', 'item-2']);
      expect(decks.known.map((c) => c.itemId), ['item-3']);
      expect(decks.favorites.map((c) => c.itemId), ['item-2']);
      expect(decks.isEmpty, isFalse);

      final first = decks.missing.first;
      expect(first.name, 'Yavuz Selim Dönemi');
      expect(first.mainSubjectName, 'Osmanlı Tarihi');
      expect(first.descriptions, ['Birinci.', 'İkinci.']);
      expect(first.text, 'Birinci. İkinci.');
      expect(first.isFavorite, isFalse);
      expect(first.canAct, isTrue);
      expect(decks.missing.last.isFavorite, isTrue);
      expect(decks.missing.last.descriptions, ['Tek paragraf.']);
      expect(
        decks.known.single.mainSubjectName,
        isNull,
        reason: 'mainSubject came as an id',
      );
    });

    test('a lesson without cards is three empty decks', () async {
      final repository = repositoryOver(
        FakeAdapter.json({
          'success': true,
          'data': {
            'failedCards': <Object>[],
            'successCards': <Object>[],
            'favoriteCards': <Object>[],
          },
        }),
      );

      final decks = (await repository.getLessonDecks(
        lessonId: 'x',
      )).rightOrNull!;

      expect(decks.isEmpty, isTrue);
    });

    test('an answer without data is empty decks, not a crash', () async {
      final repository = repositoryOver(FakeAdapter.json({'success': true}));

      final decks = (await repository.getLessonDecks(
        lessonId: 'x',
      )).rightOrNull!;

      expect(decks.isEmpty, isTrue);
    });

    test('decks that are not lists read as empty', () {
      final decks = LessonInfoCardsResponse.fromBody({
        'success': true,
        'data': {
          'failedCards': 'x',
          'successCards': {'a': 1},
        },
      }).toDomain();

      expect(decks.isEmpty, isTrue);
    });

    test('a card without an id can be read but not acted on', () {
      final decks = LessonInfoCardsResponse.fromBody({
        'success': true,
        'data': {
          'failedCards': [
            {
              'item': {'name': 'Kimliksiz'},
            },
          ],
        },
      }).toDomain();

      expect(decks.missing.single.canAct, isFalse);
      expect(decks.missing.single.itemId, isNull);
    });

    test('withFavorite flips only the star', () {
      final card = LessonInfoCardsResponse.fromBody(
        lessonCardsAnswer(),
      ).toDomain().missing.first;

      final starred = card.withFavorite(true);

      expect(starred.isFavorite, isTrue);
      expect(starred.name, card.name);
      expect(starred.descriptions, card.descriptions);
      expect(starred.itemId, card.itemId);
    });

    test('a refused read is a failure', () async {
      final repository = repositoryOver(
        FakeAdapter.json({
          'success': false,
          'message': 'Ders yok',
        }, status: 404),
      );

      final failure = (await repository.getLessonDecks(
        lessonId: 'x',
      )).leftOrNull!;

      expect(failure.code, AppErrorCode.notFound);
    });
  });

  group('writes', () {
    test('markLearned sends the item and no student id', () async {
      final adapter = FakeAdapter.json({'success': true});
      final repository = repositoryOver(adapter);

      final result = await repository.markLearned(itemId: 'item-1');

      expect(result.isRight(), isTrue);
      expect(adapter.last.method, 'GET');
      expect(adapter.last.path, '/student/learnedCard');
      expect(adapter.last.queryParameters, {'item': 'item-1'});
    });

    test('toggleFavorite sends the item', () async {
      final adapter = FakeAdapter.json({'success': true});
      final repository = repositoryOver(adapter);

      final result = await repository.toggleFavorite(itemId: 'item-2');

      expect(result.isRight(), isTrue);
      expect(adapter.last.path, '/student/addFavoriteMobil');
      expect(adapter.last.queryParameters, {'item': 'item-2'});
    });

    test('a refused write is a failure with the backend message', () async {
      final repository = repositoryOver(
        FakeAdapter.json({'success': false, 'message': 'Kart bulunamadı'}),
      );

      final failure = (await repository.markLearned(itemId: 'x')).leftOrNull!;

      expect(failure.code, AppErrorCode.validation);
      expect(failure.serverMessage, 'Kart bulunamadı');
    });

    test('an empty answer or a lost session is a failure', () async {
      var repository = repositoryOver(
        FakeAdapter((_) => textResponse('', contentType: 'text/plain')),
      );
      expect(
        (await repository.toggleFavorite(itemId: 'x')).leftOrNull?.code,
        AppErrorCode.server,
      );
      network!.dispose();

      repository = repositoryOver(
        FakeAdapter.json({'success': false}, status: 401),
      );
      expect(
        (await repository.toggleFavorite(itemId: 'x')).leftOrNull?.code,
        AppErrorCode.sessionExpired,
      );
    });
  });
}
