import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/features/cards/application/deck_lessons.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/shared/ui/illustrations/app_clay.dart';

void main() {
  group('lesson to picture (board 1.25)', () {
    test('every lesson of the set has its own picture', () {
      expect(ClayPicture.forSubject(SubjectKey.turkce), ClayPicture.kitap);
      expect(ClayPicture.forSubject(SubjectKey.edebiyat), ClayPicture.hokka);
      expect(ClayPicture.forSubject(SubjectKey.tarih), ClayPicture.sutun);
      expect(ClayPicture.forSubject(SubjectKey.cografya), ClayPicture.kure);
      expect(ClayPicture.forSubject(SubjectKey.fizik), ClayPicture.atom);
      expect(ClayPicture.forSubject(SubjectKey.kimya), ClayPicture.erlenmeyer);
      expect(ClayPicture.forSubject(SubjectKey.biyoloji), ClayPicture.yaprak);
    });

    test('Matematik, Geometri and an unknown lesson have none', () {
      expect(ClayPicture.forSubject(SubjectKey.matematik), isNull);
      expect(ClayPicture.forSubject(SubjectKey.geometri), isNull);
      expect(ClayPicture.forSubject(null), isNull);
    });

    test('no two lessons share a picture', () {
      final pictures = [
        for (final subject in SubjectKey.values)
          ?ClayPicture.forSubject(subject),
      ];
      expect(pictures.toSet().length, pictures.length);
    });

    test('the picture follows the backend lesson id of the deck', () {
      for (final lesson in ExamLessonCatalog.all) {
        expect(
          DeckLessons.pictureOf(lesson.id),
          ClayPicture.forSubject(lesson.subject),
          reason: lesson.name,
        );
      }
      expect(DeckLessons.pictureOf('663e37a24fb443839593141b'), isNotNull);
      expect(DeckLessons.pictureOf('663e387c4fb443839593141c'), isNull);
      expect(DeckLessons.pictureOf('unknown'), isNull);
      expect(DeckLessons.pictureOf(null), isNull);
    });
  });

  group('assets', () {
    test('the eleven pictures are bundled, 140 px PNGs', () {
      expect(ClayPicture.values, hasLength(11));
      for (final picture in ClayPicture.values) {
        final file = File(picture.asset.keyName);
        expect(file.existsSync(), isTrue, reason: picture.name);
        final bytes = file.readAsBytesSync();
        // PNG signature, then the IHDR width and height.
        expect(bytes.sublist(1, 4), 'PNG'.codeUnits, reason: picture.name);
        final header = ByteData.sublistView(bytes, 16, 24);
        expect(header.getUint32(0), 140, reason: '${picture.name} width');
        expect(header.getUint32(4), 140, reason: '${picture.name} height');
      }
    });

    test('the two sizes are L 160 and M 128', () {
      expect(ClaySize.large.edge, 160);
      expect(ClaySize.medium.edge, 128);
    });
  });
}
