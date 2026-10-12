import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/account/application/legal_entries.dart';
import 'package:smap/features/account/data/dtos/legal_document_dto.dart';

LegalDocumentDto _doc(
  String id,
  String? name, {
  String? title,
  String? version,
  bool? isActive,
  String? content,
}) => LegalDocumentDto(
  id: id,
  name: name,
  title: title,
  version: version,
  isActive: isActive,
  content: content,
);

void main() {
  group('LegalKind.of', () {
    test('knows the three texts by their machine name', () {
      expect(LegalKind.of('kullanim_kosullari'), LegalKind.terms);
      expect(LegalKind.of('kvkk_aydinlatma_metni'), LegalKind.kvkk);
      expect(LegalKind.of(' gizlilik_politikasi '), LegalKind.privacy);
      expect(LegalKind.of('cerez'), LegalKind.other);
      expect(LegalKind.of(null), LegalKind.other);
    });
  });

  group('LegalEntry.listOf', () {
    test('lists the active documents in the design order', () {
      final entries = LegalEntry.listOf([
        _doc('3', 'gizlilik_politikasi', title: 'Gizlilik Politikası'),
        _doc('1', 'kullanim_kosullari', title: 'Kullanım Koşulları'),
        _doc('2', 'kvkk_aydinlatma_metni', title: 'KVKK Aydınlatma Metni'),
      ]);

      expect(entries.map((e) => e.kind), [
        LegalKind.terms,
        LegalKind.kvkk,
        LegalKind.privacy,
      ]);
    });

    test('an old inactive version is not listed', () {
      final entries = LegalEntry.listOf([
        _doc('1', 'kullanim_kosullari', version: '1.0.0', isActive: false),
        _doc('2', 'kullanim_kosullari', version: '1.2.0'),
      ]);

      expect(entries.map((e) => e.version), ['1.2.0']);
    });

    test('a document without the flag counts as active', () {
      expect(
        LegalEntry.listOf([_doc('1', 'kullanim_kosullari')]),
        hasLength(1),
      );
    });

    test('an unknown document needs a title of its own', () {
      final entries = LegalEntry.listOf([
        _doc('1', 'cerez'),
        _doc('2', 'cerez_politikasi', title: 'Çerez Politikası'),
      ]);

      expect(entries.map((e) => e.title), ['Çerez Politikası']);
      expect(entries.single.kind, LegalKind.other);
    });

    test('unknown documents follow the known ones, in the server order', () {
      final entries = LegalEntry.listOf([
        _doc('a', 'x', title: 'A'),
        _doc('b', 'kvkk_aydinlatma_metni'),
        _doc('c', 'y', title: 'C'),
      ]);

      expect(entries.map((e) => e.key), ['b', 'a', 'c']);
    });

    test('a known document without a title has none of its own', () {
      final entry = LegalEntry.listOf([
        _doc('1', 'kvkk_aydinlatma_metni', title: '  '),
      ]).single;

      expect(entry.title, isNull);
      expect(entry.kind, LegalKind.kvkk);
    });

    test('the version is trimmed and may be missing', () {
      final entries = LegalEntry.listOf([
        _doc('1', 'kullanim_kosullari', version: ' 1.2.0 '),
        _doc('2', 'gizlilik_politikasi', version: ''),
      ]);

      expect(entries[0].version, '1.2.0');
      expect(entries[1].version, isNull);
    });

    test('an empty answer is an empty list', () {
      expect(LegalEntry.listOf(const []), isEmpty);
    });
  });

  group('LegalReading.htmlOf', () {
    test('HTML passes through trimmed', () {
      expect(
        LegalReading.htmlOf('  <h2>1. Taraflar</h2><p>Metin</p> '),
        '<h2>1. Taraflar</h2><p>Metin</p>',
      );
    });

    test('plain text becomes paragraphs and line breaks, escaped', () {
      expect(
        LegalReading.htmlOf(
          'Birinci paragraf\nikinci satır\n\nİkinci a < b & son',
        ),
        '<p>Birinci paragraf<br>ikinci satır</p>'
        '<p>İkinci a &lt; b &amp; son</p>',
      );
    });

    test('no text is no HTML', () {
      expect(LegalReading.htmlOf(null), '');
      expect(LegalReading.htmlOf('  \n '), '');
    });

    test('isHtml tells markup from a lone comparison', () {
      expect(LegalReading.isHtml('<p>a</p>'), isTrue);
      expect(LegalReading.isHtml('a < b ve b > c'), isFalse);
    });
  });
}
