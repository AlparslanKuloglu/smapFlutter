import 'dart:convert';
import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/scan/data/scan_repository.dart';
import 'package:smap/features/scan/domain/answer_correction.dart';
import 'package:smap/features/scan/domain/answer_grid.dart';
import 'package:smap/features/scan/domain/optic_reading.dart';

import '../../../core/network/fake_adapter.dart';
import '../scan_fixtures.dart';

const omrHost = 'https://omr.example.test';

ScanRepository repository(FakeAdapter adapter) => ScanRepository(
  NetworkService(
    config: AppConfig.resolve(omrBaseUrl: omrHost),
    cookieJar: CookieJar(),
    logTraffic: false,
    httpClientAdapter: adapter,
  ),
);

Map<String, dynamic> body(RequestOptions options) =>
    options.data as Map<String, dynamic>;

void main() {
  final jpeg = Uint8List.fromList([0xFF, 0xD8, 1, 2, 3, 4]);
  const user = {'_id': 'u1', 'name': 'Ayşe Yılmaz', 'seasonType': 12};

  group('opticimage (pano 4.5)', () {
    test(
      'posts the legacy body to the OMR host: base64 image and the user',
      () async {
        final adapter = FakeAdapter.json(sampleOpticJson());
        final result = await repository(
          adapter,
        ).readImage(jpeg: jpeg, user: user);
        expect(result.isRight(), isTrue);
        final sent = adapter.last;
        expect(sent.method, 'POST');
        expect(sent.uri.toString(), '$omrHost/opticimage');
        expect(sent.contentType, 'application/json');
        expect(body(sent), {'image': base64Encode(jpeg), 'user': user});
      },
    );

    test('leaves the user out when there is none (the old flow did)', () async {
      final adapter = FakeAdapter.json(sampleOpticJson());
      await repository(adapter).readImage(jpeg: jpeg, user: null);
      expect(body(adapter.last).keys, ['image']);
    });

    test(
      'is not sent with the session: a 401 is not "session expired"',
      () async {
        final adapter = FakeAdapter.json({'success': false}, status: 401);
        final result = await repository(
          adapter,
        ).readImage(jpeg: jpeg, user: user);
        expect(result.leftOrNull!.code, isNot(AppErrorCode.sessionExpired));
      },
    );

    test(
      'the deadlines are the design\'s: 60 s to send, 30 s to read',
      () async {
        final adapter = FakeAdapter.json(sampleOpticJson());
        await repository(adapter).readImage(jpeg: jpeg, user: user);
        expect(adapter.last.sendTimeout, const Duration(seconds: 60));
        expect(adapter.last.receiveTimeout, const Duration(seconds: 30));
      },
    );

    test(
      'reads what the reader found (pano 4.7: 160 answers, 2 blank)',
      () async {
        final result = await repository(
          FakeAdapter.json(sampleOpticJson()),
        ).readImage(jpeg: jpeg, user: user);
        final reading = result.rightOrNull!;
        expect(reading.grid!.totalCells, 160);
        expect(reading.opticImageFileName, 'optic_160.jpg');
        expect(reading.originalImageFileName, 'original_160.jpg');
        expect(reading.success, isTrue);
      },
    );

    test('a reading without an answer area has no grid', () async {
      final result = await repository(
        FakeAdapter.json({'success': true, 'answersArray': null}),
      ).readImage(jpeg: jpeg, user: user);
      expect(result.rightOrNull!.foundForm, isFalse);
    });

    test('a 503 is the maintenance state', () async {
      final result = await repository(
        FakeAdapter.json({'msg': 'bakım'}, status: 503),
      ).readImage(jpeg: jpeg, user: user);
      expect(result.leftOrNull!.code, AppErrorCode.maintenance);
    });

    test('a body that is not an object is a failure, not a crash', () async {
      final result = await repository(
        FakeAdapter((_) => textResponse('<html></html>')),
      ).readImage(jpeg: jpeg, user: user);
      expect(result.isLeft(), isTrue);
    });

    test('a broken connection is a failure the screens can sort', () async {
      final adapter = FakeAdapter.failing(
        (options) => DioException.connectionError(
          requestOptions: options,
          reason: 'no route',
        ),
      );
      final result = await repository(
        adapter,
      ).readImage(jpeg: jpeg, user: user);
      expect(
        result.leftOrNull!.code,
        anyOf(AppErrorCode.network, AppErrorCode.offline),
      );
    });
  });

  group('answerArray (pano 4.7 kare 4)', () {
    test(
      'posts the reading as it came and the corrections as the old edits',
      () async {
        final reading = sampleReading();
        final adapter = FakeAdapter.json(sampleAnswerJson());
        final corrections = AnswerCorrections.none
            .add(
              const AnswerCell(3, 12),
              read: AnswerChoice.blank,
              to: AnswerChoice.c,
            )
            .add(
              const AnswerCell(4, 31),
              read: AnswerChoice.blank,
              to: AnswerChoice.a,
            );
        final result = await repository(
          adapter,
        ).sendAnswers(reading: reading, corrections: corrections);
        expect(result.isRight(), isTrue);
        final sent = adapter.last;
        expect(sent.uri.toString(), '$omrHost/answerArray');
        expect(body(sent), {
          'original_data': {
            'mexamFound': null,
            'success': true,
            'answersArray': sampleAnswerColumns(),
            'opticImageFileName': 'optic_160.jpg',
            'originalImageFileName': 'original_160.jpg',
          },
          'edits': {
            'Kolon 3': {'12': 'C'},
            'Kolon 4': {'31': 'A'},
          },
        });
      },
    );

    test('no corrections is an empty edits object', () async {
      final adapter = FakeAdapter.json(sampleAnswerJson());
      await repository(adapter).sendAnswers(
        reading: sampleReading(),
        corrections: AnswerCorrections.none,
      );
      expect(body(adapter.last)['edits'], isEmpty);
    });

    test('says which exam the answers belong to', () async {
      final result = await repository(FakeAdapter.json(sampleAnswerJson()))
          .sendAnswers(
            reading: sampleReading(),
            corrections: AnswerCorrections.none,
          );
      final reply = result.rightOrNull!;
      expect(reply.examFound, isTrue);
      expect(reply.examId, '6527f1c2a4b5d8e9f0123456');
    });

    test('an exam the system does not know is "false", not an id', () async {
      final result =
          await repository(
            FakeAdapter.json(sampleAnswerJson(found: false)),
          ).sendAnswers(
            reading: sampleReading(),
            corrections: AnswerCorrections.none,
          );
      final reply = result.rightOrNull!;
      expect(reply.examFound, isFalse);
      expect(reply.examId, isNull);
      expect(reply.mexamFound, false);
    });
  });

  group('examrequest (pano 4.9)', () {
    test(
      'posts the publisher, the name, the answers with their images and the user',
      () async {
        final reading = sampleReading();
        final reply = AnswerReply.fromJson(sampleAnswerJson(found: false));
        final adapter = FakeAdapter.json({'success': true});
        final result = await repository(adapter).sendExamRequest(
          publisherName: 'Örnek Yayınları',
          examName: 'Türkiye Geneli Deneme 7',
          answers: reply,
          reading: reading,
          user: user,
        );
        expect(result.isRight(), isTrue);
        final sent = adapter.last;
        expect(sent.uri.toString(), '$omrHost/examrequest');
        final data = body(sent);
        expect(data['publisherName'], 'Örnek Yayınları');
        expect(data['examName'], 'Türkiye Geneli Deneme 7');
        expect(data['user'], user);
        final answerData = data['answerData'] as Map<String, dynamic>;
        expect(answerData['mexamFound'], false);
        expect(answerData['images'], {
          'original_image': 'original_160.jpg',
          'read_image': 'optic_160.jpg',
        });
        expect(data.keys, ['publisherName', 'examName', 'answerData', 'user']);
      },
    );

    test('a refusal (success: false) is a failure', () async {
      final result = await repository(FakeAdapter.json({'success': false}))
          .sendExamRequest(
            publisherName: 'x',
            examName: 'y',
            answers: AnswerReply.fromJson(sampleAnswerJson(found: false)),
            reading: sampleReading(),
            user: user,
          );
      expect(result.isLeft(), isTrue);
    });
  });

  group('OpticReading', () {
    test('writes the five keys of the old model', () {
      final reading = OpticReading.fromJson(const {
        'success': true,
        'mexamFound': {'_id': 'x'},
        'answersArray': [
          ['A'],
        ],
        'opticImageFileName': 'a.jpg',
        'originalImageFileName': 'b.jpg',
        'extra': 1,
      });
      expect(reading.toLegacyJson().keys, [
        'mexamFound',
        'success',
        'answersArray',
        'opticImageFileName',
        'originalImageFileName',
      ]);
    });

    test('a field of the wrong type reads as missing', () {
      final reading = OpticReading.fromJson(const {
        'mexamFound': false,
        'success': 'yes',
        'answersArray': 'nope',
        'opticImageFileName': '  ',
      });
      expect(reading.mexamFound, isNull);
      expect(reading.success, isNull);
      expect(reading.answersArray, isNull);
      expect(reading.opticImageFileName, isNull);
      expect(reading.foundForm, isFalse);
    });
  });
}
