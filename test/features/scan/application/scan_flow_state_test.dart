import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/scan/application/corner_geometry.dart';
import 'package:smap/features/scan/application/form_quad.dart';
import 'package:smap/features/scan/application/scan_flow_state.dart';
import 'package:smap/features/scan/domain/optic_reading.dart';

import '../scan_fixtures.dart';

final photo = ScanPhoto(
  bytes: Uint8List.fromList([1, 2, 3]),
  size: const Size(3024, 4032),
);
final found = FormQuad.fromRect(const Rect.fromLTRB(0.1, 0.2, 0.9, 0.8));
final flat = Uint8List.fromList([9, 9]);

void main() {
  test('starts at the camera', () {
    expect(const ScanFlowState().stage, ScanStage.capture);
  });

  group('the way forward', () {
    test('the shutter opens the corners with the photo', () {
      final state = const ScanFlowState().captured(photo);
      expect(state.stage, ScanStage.corners);
      expect(state.photo, photo);
    });

    test(
      'the handles start on the guide when nothing was found, on the form when it was',
      () {
        expect(
          const ScanFlowState().captured(photo).cornersQuad,
          CornerGeometry.guideQuad,
        );
        final withForm = ScanPhoto(
          bytes: photo.bytes,
          size: photo.size,
          form: found,
        );
        expect(const ScanFlowState().captured(withForm).cornersQuad, found);
      },
    );

    test(
      'Devam starts the upload with the straightened picture and the handles',
      () {
        final state = const ScanFlowState()
            .captured(photo)
            .flattenedTo(flat, found);
        expect(state.stage, ScanStage.upload);
        expect(state.flattened, flat);
        expect(state.quad, found);
        expect(state.photo, photo);
      },
    );

    test('a reading with answers opens the check', () {
      final state = const ScanFlowState()
          .captured(photo)
          .flattenedTo(flat, found)
          .read(sampleReading());
      expect(state.stage, ScanStage.review);
      expect(state.reading, isNotNull);
    });

    test('a reading without an answer area is "Formu bulamadık"', () {
      final empty = OpticReading.fromJson(const {
        'success': true,
        'answersArray': <Object?>[],
      });
      final state = const ScanFlowState()
          .captured(photo)
          .flattenedTo(flat, found)
          .read(empty);
      expect(state.stage, ScanStage.error);
      expect(state.errorKind, ScanErrorKind.formNotFound);
    });

    test('an unknown exam opens the request and keeps the reading', () {
      final reading = sampleReading();
      final reply = AnswerReply.fromJson(sampleAnswerJson(found: false));
      final state = const ScanFlowState()
          .captured(photo)
          .flattenedTo(flat, found)
          .read(reading)
          .examNotFound(reply);
      expect(state.stage, ScanStage.request);
      expect(state.reading, reading);
      expect(state.reply, reply);
    });
  });

  group('the way back', () {
    test(
      'Vazgeç on the upload returns to the corners with the photo and the handles',
      () {
        final back = const ScanFlowState()
            .captured(photo)
            .flattenedTo(flat, found)
            .backToCorners();
        expect(back.stage, ScanStage.corners);
        expect(back.photo, photo);
        expect(back.cornersQuad, found);
        expect(back.flattened, isNull);
      },
    );

    test('Tekrar Çek forgets the photo', () {
      final state = const ScanFlowState().captured(photo).retake();
      expect(state, const ScanFlowState());
    });
  });

  group('the planned offline screen', () {
    test('the upload can go offline and retry with the same picture', () {
      final upload = const ScanFlowState()
          .captured(photo)
          .flattenedTo(flat, found);
      final offline = upload.offline();
      expect(offline.stage, ScanStage.error);
      expect(offline.errorKind, ScanErrorKind.offline);
      final retry = offline.retryUpload();
      expect(retry.stage, ScanStage.upload);
      expect(retry.flattened, flat);
    });
  });

  group('steps that do not apply change nothing', () {
    test('a reading outside the upload', () {
      const state = ScanFlowState();
      expect(state.read(sampleReading()), state);
      expect(state.flattenedTo(flat, found), state);
      expect(state.backToCorners(), state);
      expect(state.offline(), state);
      expect(state.retryUpload(), state);
      expect(
        state.examNotFound(
          AnswerReply.fromJson(sampleAnswerJson(found: false)),
        ),
        state,
      );
    });

    test('a second shutter', () {
      final state = const ScanFlowState().captured(photo);
      expect(state.captured(photo), state);
    });
  });
}
