import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/utils/turkish_text.dart';

void main() {
  group('lower', () {
    const cases = {
      'IŞIK': 'ışık',
      'İPEK': 'ipek',
      'İSTANBUL': 'istanbul',
      'ÇAĞRI': 'çağrı',
      'Öğretmen': 'öğretmen',
      'AbCİI': 'abciı',
      '': '',
    };
    cases.forEach((input, expected) {
      test(
        '$input -> $expected',
        () => expect(TurkishText.lower(input), expected),
      );
    });

    test('Dart toLowerCase gets it wrong, which is why this exists', () {
      expect('IŞIK'.toLowerCase(), isNot('ışık'));
      expect('i'.toUpperCase(), 'I'); // not 'İ'
    });
  });

  group('upper', () {
    const cases = {
      'ışık': 'IŞIK',
      'istanbul': 'İSTANBUL',
      'çağrı': 'ÇAĞRI',
      'iI': 'İI',
      'öğretmen': 'ÖĞRETMEN',
    };
    cases.forEach((input, expected) {
      test(
        '$input -> $expected',
        () => expect(TurkishText.upper(input), expected),
      );
    });
  });

  group('capitalize and titleCase', () {
    test('capitalize', () {
      expect(TurkishText.capitalize('işık'), 'İşık');
      expect(TurkishText.capitalize('ışık'), 'Işık');
      expect(TurkishText.capitalize('ahmet yılmaz'), 'Ahmet yılmaz');
      expect(TurkishText.capitalize(''), '');
    });

    const cases = {
      'MEHMET ÖZKAN': 'Mehmet Özkan',
      'ilknur': 'İlknur',
      'IŞIK ÇELİK': 'Işık Çelik',
      'ayşe-nur': 'Ayşe-Nur',
      "AHMET'İN": "Ahmet'in",
      'İSTANBUL': 'İstanbul',
      '': '',
    };
    cases.forEach((input, expected) {
      test(
        'titleCase $input -> $expected',
        () => expect(TurkishText.titleCase(input), expected),
      );
    });
  });

  group('fold', () {
    const cases = {
      'Çay': 'cay',
      'IŞIK': 'isik',
      'İPEK': 'ipek',
      'ığüşöç': 'igusoc',
      'ĞÜŞÖÇİI':
          'gusoci'
          'i',
      'NEVRESİM': 'nevresim',
      'Nevresim': 'nevresim',
      'Kâğıt': 'kagit',
      'Özkan': 'ozkan',
    };
    cases.forEach((input, expected) {
      test(
        '$input -> $expected',
        () => expect(TurkishText.fold(input), expected),
      );
    });

    test('keeps the length, so an offset maps back to the original', () {
      for (final text in [
        'İstanbul',
        'IŞIK',
        'Çay Bardağı',
        'ÖĞRENCİ İŞLERİ',
      ]) {
        expect(TurkishText.fold(text).length, text.length, reason: text);
      }
    });

    test('I and İ, ı and i all fold to i', () {
      expect(
        {
          for (final c in ['I', 'ı', 'İ', 'i']) TurkishText.fold(c),
        },
        {'i'},
      );
    });
  });

  group('contains', () {
    test('ignores case and Turkish marks', () {
      expect(TurkishText.contains('Çay Bardağı', 'cay'), isTrue);
      expect(TurkishText.contains('Çay Bardağı', 'BARDAGI'), isTrue);
      expect(TurkishText.contains('Mehmet Özkan', 'OZ'), isTrue);
      expect(TurkishText.contains('Ipek', 'ıpek'), isTrue);
      expect(TurkishText.contains('Ipek', 'ipek'), isTrue);
      expect(TurkishText.contains('Mehmet Özkan', 'ayşe'), isFalse);
    });

    test('a blank query matches everything', () {
      expect(TurkishText.contains('Mehmet', ''), isTrue);
      expect(TurkishText.contains('Mehmet', '   '), isTrue);
    });
  });

  group('matchesTokens (name search)', () {
    test('every query word starts some word of the text', () {
      expect(TurkishText.matchesTokens('Mehmet Özkan', 'mehmet oz'), isTrue);
      expect(TurkishText.matchesTokens('Mehmet Özkan', 'oz meh'), isTrue);
      expect(TurkishText.matchesTokens('Mehmet Özkan', 'OZKAN'), isTrue);
      expect(TurkishText.matchesTokens('İbrahim Çelik', 'ibr cel'), isTrue);
      expect(TurkishText.matchesTokens('İbrahim Çelik', 'ıbr çel'), isTrue);
    });

    test('it is a prefix match, not a substring match', () {
      expect(TurkishText.matchesTokens('Mehmet Özkan', 'ehm'), isFalse);
      expect(TurkishText.matchesTokens('Mehmet Özkan', 'kan'), isFalse);
    });

    test('one unmatched word fails the whole query', () {
      expect(
        TurkishText.matchesTokens('Mehmet Özkan', 'mehmet yilmaz'),
        isFalse,
      );
    });

    test('a blank query matches', () {
      expect(TurkishText.matchesTokens('Mehmet Özkan', ''), isTrue);
    });
  });

  group('matchRanges (highlight in the original text)', () {
    test('one range per query word, as original offsets', () {
      expect(TurkishText.matchRanges('Mehmet Özkan', 'oz meh'), [
        (start: 0, end: 3),
        (start: 7, end: 9),
      ]);
      expect(TurkishText.matchRanges('İbrahim', 'ıbr'), [(start: 0, end: 3)]);
    });

    test('overlapping ranges are merged', () {
      expect(TurkishText.matchRanges('Mehmet Özkan', 'me meh'), [
        (start: 0, end: 3),
      ]);
    });

    test('no ranges for a blank query or an unmatched word', () {
      expect(TurkishText.matchRanges('Mehmet', ''), isEmpty);
      expect(TurkishText.matchRanges('Mehmet', 'x'), isEmpty);
      expect(TurkishText.matchRanges('Mehmet Özkan', 'meh yilmaz'), isEmpty);
    });

    test('the substring of the range is the matched start of the word', () {
      const text = 'Çağrı Özdemir';
      final range = TurkishText.matchRanges(text, 'cag').single;
      expect(text.substring(range.start, range.end), 'Çağ');
    });
  });

  group('compare (Turkish alphabetical order)', () {
    test('the classic list', () {
      final list = ['Zeytin', 'Çay', 'Cam', 'Dolap', 'ısıtıcı', 'iplik'];
      list.sort(TurkishText.compare);
      expect(list, ['Cam', 'Çay', 'Dolap', 'ısıtıcı', 'iplik', 'Zeytin']);
    });

    test('o ö, s ş, u ü, g ğ order', () {
      final list = [
        'Şeker',
        'Sütlaç',
        'Ödev',
        'Oda',
        'Ürün',
        'Uçak',
        'Ğ',
        'Gül',
        'Hal',
      ];
      list.sort(TurkishText.compare);
      expect(list, [
        'Gül',
        'Ğ',
        'Hal',
        'Oda',
        'Ödev',
        'Sütlaç',
        'Şeker',
        'Uçak',
        'Ürün',
      ]);
    });

    test('students by name', () {
      final names = [
        'Zeynep Ak',
        'Çağlar Tan',
        'Ali Veli',
        'İlker Su',
        'Işıl Yurt',
        'Elif Kaya',
      ];
      names.sort(TurkishText.compare);
      expect(names, [
        'Ali Veli',
        'Çağlar Tan',
        'Elif Kaya',
        'Işıl Yurt',
        'İlker Su',
        'Zeynep Ak',
      ]);
    });

    test('case does not matter and equal text compares 0', () {
      expect(TurkishText.compare('ali', 'ALİ'), 0);
      expect(TurkishText.compare('Işık', 'ışık'), 0);
      expect(TurkishText.compare('a', 'B'), lessThan(0));
    });

    test('digits and spaces sort before letters', () {
      expect(TurkishText.compare('2 Ocak', 'Aralık'), lessThan(0));
      expect(TurkishText.compare('Ali', 'Ali Veli'), lessThan(0));
    });
  });

  group('TurkishSuffix', () {
    group('dative', () {
      const cases = {
        'Ahmet': "Ahmet'e",
        'Ayşe': "Ayşe'ye",
        'Ali': "Ali'ye",
        'Mehmet Özkan': "Mehmet Özkan'a",
        'Cumartesi': "Cumartesi'ye",
        'Salı': "Salı'ya",
        'Pazar': "Pazar'a",
        'Çarşamba': "Çarşamba'ya",
        'Perşembe': "Perşembe'ye",
        'TYT': "TYT'ye",
        'AYT': "AYT'ye",
        'YKS': "YKS'ye",
        'KPSS': "KPSS'ye",
        'Okul': "Okul'a",
        'Göl': "Göl'e",
      };
      cases.forEach((input, expected) {
        test(
          '$input -> $expected',
          () => expect(TurkishSuffix.dative(input), expected),
        );
      });
    });

    group('accusative', () {
      const cases = {
        'Cumartesi': "Cumartesi'yi",
        'Pazartesi': "Pazartesi'yi",
        'Salı': "Salı'yı",
        'Çarşamba': "Çarşamba'yı",
        'Perşembe': "Perşembe'yi",
        'Cuma': "Cuma'yı",
        'Pazar': "Pazar'ı",
        'Ahmet': "Ahmet'i",
        'Mehmet Özkan': "Mehmet Özkan'ı",
        'Okul': "Okul'u",
        'Göl': "Göl'ü",
        'TYT': "TYT'yi",
      };
      cases.forEach((input, expected) {
        test(
          '$input -> $expected',
          () => expect(TurkishSuffix.accusative(input), expected),
        );
      });
    });

    group('genitive', () {
      const cases = {
        'Ayşe': "Ayşe'nin",
        'Ali': "Ali'nin",
        'Salı': "Salı'nın",
        'Ahmet': "Ahmet'in",
        'Mehmet Özkan': "Mehmet Özkan'ın",
        'Okul': "Okul'un",
        'Göl': "Göl'ün",
      };
      cases.forEach((input, expected) {
        test(
          '$input -> $expected',
          () => expect(TurkishSuffix.genitive(input), expected),
        );
      });
    });

    group('locative', () {
      const cases = {
        'Matematik': "Matematik'te",
        'Ahmet': "Ahmet'te",
        'Ankara': "Ankara'da",
        'Okul': "Okul'da",
        'Türkçe': "Türkçe'de",
        'Ayşe': "Ayşe'de",
        'İstanbul': "İstanbul'da",
        'TYT': "TYT'de",
        'KPSS': "KPSS'de",
      };
      cases.forEach((input, expected) {
        test(
          '$input -> $expected',
          () => expect(TurkishSuffix.locative(input), expected),
        );
      });

      test("a possessed topic takes 'nde / 'nda: {topic}'nde", () {
        expect(
          TurkishSuffix.locative(
            "Kurtuluş Savaşı Hazırlık Dönemi",
            possessed: true,
          ),
          "Kurtuluş Savaşı Hazırlık Dönemi'nde",
        );
        expect(
          TurkishSuffix.locative('Kurtuluş Savaşı', possessed: true),
          "Kurtuluş Savaşı'nda",
        );
        expect(
          TurkishSuffix.locative('Osmanlı Devleti', possessed: true),
          "Osmanlı Devleti'nde",
        );
      });
    });

    group('ablative', () {
      test('plain and possessed', () {
        expect(TurkishSuffix.ablative('Ankara'), "Ankara'dan");
        expect(TurkishSuffix.ablative('Ahmet'), "Ahmet'ten");
        expect(
          TurkishSuffix.ablative('Dönemi', possessed: true),
          "Dönemi'nden",
        );
      });
    });

    group('numbers (the {wrong} templates)', () {
      const possessive = {
        '0': "0'ı", // sıfır
        '1': "1'i", // bir
        '2': "2'si", // iki
        '3': "3'ü", // üç
        '4': "4'ü", // dört
        '5': "5'i", // beş
        '6': "6'sı", // altı
        '7': "7'si", // yedi
        '8': "8'i", // sekiz
        '9': "9'u", // dokuz
        '10': "10'u", // on
        '12': "12'si", // on iki
        '13': "13'ü", // on üç
        '15': "15'i", // on beş
        '20': "20'si", // yirmi
        '30': "30'u", // otuz
        '40': "40'ı", // kırk
        '50': "50'si", // elli
        '60': "60'ı", // altmış
        '70': "70'i", // yetmiş
        '80': "80'i", // seksen
        '90': "90'ı", // doksan
        '100': "100'ü", // yüz
        '160': "160'ı", // yüz altmış
        '1000': "1000'i", // bin
        '2000000': "2000000'u", // milyon
      };
      possessive.forEach((input, expected) {
        test('possessive $input -> $expected', () {
          expect(TurkishSuffix.possessive(input), expected);
        });
      });

      const accusative = {
        '9': "9'unu",
        '13': "13'ünü",
        '6': "6'sını",
        '2': "2'sini",
        '5': "5'ini",
        '1': "1'ini",
        '4': "4'ünü",
        '40': "40'ını",
      };
      accusative.forEach((input, expected) {
        test('possessiveAccusative $input -> $expected', () {
          expect(TurkishSuffix.possessiveAccusative(input), expected);
        });
      });

      test('dative and locative of a number follow how it is read', () {
        expect(TurkishSuffix.dative('3'), "3'e"); // üç
        expect(TurkishSuffix.dative('6'), "6'ya"); // altı
        expect(TurkishSuffix.dative('9'), "9'a"); // dokuz
        expect(TurkishSuffix.locative('5'), "5'te"); // beş
        expect(TurkishSuffix.locative('9'), "9'da"); // dokuz
      });
    });

    group('spelled capitals', () {
      test('are read by their last letter name', () {
        expect(TurkishSuffix.dative('TYT'), "TYT'ye"); // te
        expect(TurkishSuffix.dative('LGS'), "LGS'ye"); // se
        expect(TurkishSuffix.dative('ALİ'), "ALİ'ye");
        expect(TurkishSuffix.genitive('TYT'), "TYT'nin");
      });

      test('a longer all-caps word with a vowel is a word, not an acronym', () {
        expect(TurkishSuffix.dative('AYŞE'), "AYŞE'ye");
        expect(TurkishSuffix.dative('MEHMET'), "MEHMET'e");
        expect(TurkishSuffix.dative('KEREM'), "KEREM'e");
      });

      test('the override decides when the heuristic is wrong', () {
        expect(TurkishSuffix.dative('ALP'), "ALP'ye"); // read as letters
        expect(TurkishSuffix.dative('ALP', spelled: false), "ALP'a");
        expect(TurkishSuffix.dative('Alp'), "Alp'a");
      });
    });

    test('the templates of the spec', () {
      expect(
        "${TurkishSuffix.locative('Kurtuluş Savaşı Hazırlık Dönemi', possessed: true)} 13 sorudan "
            "${TurkishSuffix.possessiveAccusative('9')} kaçırdın.",
        "Kurtuluş Savaşı Hazırlık Dönemi'nde 13 sorudan 9'unu kaçırdın.",
      );
      expect(
        'Son denemede 74 sorudan ${TurkishSuffix.possessive('13')} yanlış',
        "Son denemede 74 sorudan 13'ü yanlış",
      );
      expect(
        '${TurkishSuffix.accusative('Cumartesi')} sıfırlayalım mı?',
        "Cumartesi'yi sıfırlayalım mı?",
      );
      expect(
        'önceki ${TurkishSuffix.dative('TYT')} göre',
        "önceki TYT'ye göre",
      );
      expect(
        '${TurkishSuffix.genitive('Mehmet Özkan')} verileri',
        "Mehmet Özkan'ın verileri",
      );
      expect(
        '${TurkishSuffix.dative('Mehmet Özkan')} bağlandın',
        "Mehmet Özkan'a bağlandın",
      );
    });

    test('a blank word is an error', () {
      expect(() => TurkishSuffix.dative(''), throwsArgumentError);
      expect(() => TurkishSuffix.dative('   '), throwsArgumentError);
    });

    test('surrounding spaces are trimmed', () {
      expect(TurkishSuffix.dative('  Ayşe '), "Ayşe'ye");
    });
  });
}
