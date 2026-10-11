import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/account/data/dtos/legal_document_dto.dart';

void main() {
  test('reads a document as the legacy model read it', () {
    final doc = LegalDocumentDto.fromJson({
      '_id': 'doc-1',
      'name': 'kvkk_aydinlatma_metni',
      'title': 'KVKK Aydınlatma Metni',
      'version': '1.2.0',
      'content': '<p>Metin</p>',
      'isActive': true,
    });

    expect(doc.id, 'doc-1');
    expect(doc.name, 'kvkk_aydinlatma_metni');
    expect(doc.title, 'KVKK Aydınlatma Metni');
    expect(doc.version, '1.2.0');
    expect(doc.content, '<p>Metin</p>');
    expect(doc.isActive, isTrue);
    expect(doc.active, isTrue);
  });

  test('invents nothing for missing fields', () {
    final doc = LegalDocumentDto.fromJson(const {});

    expect(doc.id, isNull);
    expect(doc.name, isNull);
    expect(doc.title, isNull);
    expect(doc.version, isNull);
    expect(doc.content, isNull);
    expect(doc.isActive, isNull);
    expect(doc.active, isTrue, reason: 'only an explicit false retires one');
  });

  test('only an explicit false makes a document inactive', () {
    expect(LegalDocumentDto.fromJson({'isActive': false}).active, isFalse);
    expect(LegalDocumentDto.fromJson({'isActive': 'false'}).active, isFalse);
    expect(LegalDocumentDto.fromJson({'isActive': 0}).active, isFalse);
    expect(LegalDocumentDto.fromJson({'isActive': 'maybe'}).active, isTrue);
  });

  test('survives wrong types', () {
    final doc = LegalDocumentDto.fromJson({
      '_id': 12,
      'version': 2,
      'title': ['x'],
      'content': '   ',
    });

    expect(doc.id, '12');
    expect(doc.version, '2');
    expect(doc.title, isNull);
    expect(doc.content, isNull);
  });
}
