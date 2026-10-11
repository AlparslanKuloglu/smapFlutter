import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/account/data/dtos/legal_document_dto.dart';
import 'package:smap/features/auth/application/register/consent_text_parts.dart';
import 'package:smap/features/auth/application/register/register_legal_texts.dart';

LegalDocumentDto _doc(
  String name, {
  String? version = '1.0.0',
  String? content = '<p>Metin</p>',
  bool? active,
}) => LegalDocumentDto(
  id: name,
  name: name,
  title: name,
  version: version,
  content: content,
  isActive: active,
);

void main() {
  group('RegisterLegalTexts.pick', () {
    test('finds the terms, the KVKK notice and the privacy policy by name', () {
      final texts = RegisterLegalTexts.pick([
        _doc('gizlilik_politikasi', version: '1.1'),
        _doc('kvkk_aydinlatma_metni', version: '2.0'),
        _doc('kullanim_kosullari', version: '3.0'),
      ])!;

      expect(texts.terms.version, '3.0');
      expect(texts.kvkk.version, '2.0');
      expect(texts.privacy?.version, '1.1');
    });

    test('the privacy policy is optional', () {
      final texts = RegisterLegalTexts.pick([
        _doc('kvkk_aydinlatma_metni'),
        _doc('kullanim_kosullari'),
      ])!;

      expect(texts.privacy, isNull);
    });

    test('a missing terms or KVKK text closes the form', () {
      expect(RegisterLegalTexts.pick(const []), isNull);
      expect(RegisterLegalTexts.pick([_doc('kullanim_kosullari')]), isNull);
      expect(RegisterLegalTexts.pick([_doc('kvkk_aydinlatma_metni')]), isNull);
    });

    test('a retired document does not count; the active twin does', () {
      final texts = RegisterLegalTexts.pick([
        _doc('kullanim_kosullari', version: '1.0', active: false),
        _doc('kullanim_kosullari', version: '2.0'),
        _doc('kvkk_aydinlatma_metni'),
      ])!;
      expect(texts.terms.version, '2.0');

      expect(
        RegisterLegalTexts.pick([
          _doc('kullanim_kosullari', active: false),
          _doc('kvkk_aydinlatma_metni'),
        ]),
        isNull,
      );
    });

    test('a text with no content cannot be read, so it does not count', () {
      expect(
        RegisterLegalTexts.pick([
          _doc('kullanim_kosullari', content: '  '),
          _doc('kvkk_aydinlatma_metni'),
        ]),
        isNull,
      );
      expect(
        RegisterLegalTexts.pick([
          _doc('kullanim_kosullari'),
          _doc('kvkk_aydinlatma_metni', content: null),
        ]),
        isNull,
      );
    });

    test('equal texts compare equal, for a selector', () {
      final a = RegisterLegalTexts.pick([
        _doc('kullanim_kosullari'),
        _doc('kvkk_aydinlatma_metni'),
      ]);
      final b = RegisterLegalTexts.pick([
        _doc('kullanim_kosullari'),
        _doc('kvkk_aydinlatma_metni'),
      ]);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });

  group('ConsentTextParts.split', () {
    const template =
        "${ConsentTextParts.termsMark}'nı ve ${ConsentTextParts.kvkkMark}'ni "
        'okudum, kabul ediyorum.';

    test('cuts the sentence into two links and the words between', () {
      final parts = ConsentTextParts.split(
        template,
        termsLabel: 'Kullanım Koşulları',
        kvkkLabel: 'KVKK Aydınlatma Metni',
      );

      expect(parts, const [
        ConsentPart.link('Kullanım Koşulları', ConsentLink.terms),
        ConsentPart.text("'nı ve "),
        ConsentPart.link('KVKK Aydınlatma Metni', ConsentLink.kvkk),
        ConsentPart.text("'ni okudum, kabul ediyorum."),
      ]);
    });

    test('a sentence without marks is one plain part', () {
      expect(
        ConsentTextParts.split('Kabul', termsLabel: 'a', kvkkLabel: 'b'),
        const [ConsentPart.text('Kabul')],
      );
    });
  });
}
